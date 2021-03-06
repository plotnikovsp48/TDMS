use CMD_KD_COMMON_LIB
use CMD_KD_COMMON_BUTTON_LIB
use CMD_KD_ORDER_LIB
use CMD_KD_USER_PERMISSIONS

'=============================================
Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description

'  call SetGlobalVarrible("ShowForm", "FORM_ORDER_DONE")

  isExec = fIsExec(Obj)
  isInWork = Obj.StatusName = "STATUS_KD_ORDER_IN_WORK" or Obj.StatusName = "STATUS_KD_ORDER_SENT"
  if not isExec or not isInWork then SetNotEnable
  if isExec and isInWork then Check_DocProj(obj)
'  if not isExec then
'    msgbox "Невозможно отметить исполнение, т.к. Вы не являетесь исполнителем", vbCritical
'    thisForm.Close
'    exit sub
'  end if
'  if not isInWork then
'    msgbox "Невозможно отметить исполнение, т.к. поручение не в работе", vbCritical
'    thisForm.Close
'    exit sub
'  end if
'  
 
  Set field = thisForm.Controls("TDMSEDIT_NOTE").ActiveX ' TDMSEditCtrl
  set def = ThisApplication.AttributeDefs("ATTR_KB_POR_RESULT") ' тип атрибута Дата\Время
  field.AttributeDef = def
  thisForm.Controls("TDMSEDIT_NOTE").ActiveX.Value = thisObject.Attributes("ATTR_KB_POR_RESULT").Value
  thisForm.Controls("TDMSEDIT_NOTE").Enabled = isExec and isInWork
  CreateTree(thisObject)
    'SetContolEnable()  
End Sub

'=============================================
sub Check_DocProj(obj)
  set docObj =  obj.Attributes("ATTR_KD_DOCBASE").Object
  if docObj is nothing then exit sub
  if not docObj.IsKindOf("OBJECT_KD_BASE_DOC") then exit sub
  
  txt = ThisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "CheckDogProj", docObj)
  if txt = "" then exit sub
  res = msgbox( "Для документа основания " & docObj.description &" не установлена связь с проектом." & _
          "Установить связь документа с проектом? Нажмите: " & vbNewLine &_
            "Да - чтобы выбрать проект " & vbNewLine &_
            "Нет - чтобы поставить признак Не связан с проектом/договором " & vbNewLine &_
            "Отмена - чтобы продолжить работу без внесения изменений в документ ", _
        vbQuestion + vbYesNoCancel, "Установить связь документа с проектом?")
  Select Case   res
    case vbYes call AddProj(docObj)
    case vbNo call setWithOut(docObj)
    case vbCancel exit sub
  end select   
end sub
'=============================================
sub setWithOut(docObj)
  docObj.Permissions = sysadminPermissions
  docObj.Attributes("ATTR_KD_WITHOUT_PROJ").Value = true
  docObj.Update
end sub
'=============================================
sub SetNotEnable()
  for each contl in thisForm.Controls
    contl.Enabled = false
  next
end sub
''=============================================
'sub SetContolEnable()
'  isAproving = thisObject.StatusName = "STATUS_KD_AGREEMENT"
'  isExec = IsExecutor(thisApplication.CurrentUser, thisObject)
'  isContr = IsController(thisApplication.CurrentUser, thisObject)
'  isApr = IsAprover(thisApplication.CurrentUser, thisObject)
'  isCanEd = isCanEdit()
''thisForm.Controls("BTN_SEND").Enabled = ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_ADD_APRV").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_DEL_APR").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_APROVE").Enabled = (isApr and isAproving) 
'  thisForm.Controls("BTN_REJECT").Enabled = (isApr and isAproving) 
'  thisForm.Controls("BTN_APR_CHANGE").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_LOAD_FILE").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_DEL_APP").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_CHECKOUT").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_CHECKIN").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  
'  thisForm.Controls("BTN_SEND_TO_CHECK").Enabled = isExec and thisObject.StatusName = "STATUS_KD_DRAFT"
'  ifSt = (thisObject.StatusName = "STATUS_KD_CHECK") or (thisObject.StatusName = "STATUS_SIGNING") _
'      or(thisObject.StatusName = "STATUS_KD_AGREEMENT")
'  thisForm.Controls("BTN_RETURN").Enabled = (isExec or isContr) and ifSt
'  
''  thisForm.Controls("").Enabled = isApr
'  
'end sub

'=============================================
Sub BTN_CHECKOUT_OnClick()
  Word_Check_Out()
End Sub

'=============================================
Sub BTN_CHECKIN_OnClick()
  Word_Check_IN()
End Sub

'=============================================
sub CreateTree(cOrder)
    set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX  
    if ax_Tee is nothing then exit sub
    ax_Tee.DeleteAllItems
    ax_Tee.Font.Size = 10
    set parOrder = thisObject.parent
    if not parOrder is nothing then
        if not parOrder.IsKindOf("OBJECT_KD_ORDER") then set parOrder = nothing
    end if
    if parOrder is nothing then set parOrder = thisObject
    if cOrder is nothing then set cOrder = thisObject
    call CreateChild(ax_Tee,0,parOrder, cOrder)
end sub
'=============================================
Sub BTN_SEND_REP_OnClick()
  txt = thisObject.Attributes("ATTR_KB_POR_RESULT").Value
    if trim(txt) <> "" then 
       call SendReport(ThisObject,txt)
    else
       msgBox "Невозможно отправить отчет, т.к. текст отчета не задан", vbCritical, "Отчет не отправлен"
    end if     
End Sub
'=============================================
Sub BTN_SAVE_OnClick()
  thisScript.SysAdminModeOn
  thisObject.saveChanges(16384)' .Update
  thisForm.Close false
End Sub
'=============================================
Sub BTN_ORDER_CARD_OnClick()
  call SetGlobalVarrible("ShowForm", "FORM_KD_ORDER_CARD")
  Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
  CreateObjDlg.Object = thisObject
  ans = CreateObjDlg.Show
End Sub
'=============================================
Sub BTN_TEXT_OnClick()
  call ShowComment("Текст поручения", thisObject.Attributes("ATTR_KD_TEXT").value)
End Sub
'=============================================
Sub BTN_REP_OnClick()
  txt = GetEditComment("Текст отчета", thisObject.Attributes("ATTR_KB_POR_RESULT").value)
  if not isEmpty(txt) then
      ThisScript.SysAdminModeOn
      thisObject.Permissions = SysAdminPermissions
      thisObject.Attributes("ATTR_KB_POR_RESULT").value = txt
      thisForm.Controls("TDMSEDIT_NOTE").ActiveX.Value = txt
      thisObject.Update 
  end if
End Sub
'=============================================
Sub BTN_COM_OnClick()
  call ShowComment("Замечания по отчету", thisObject.Attributes("ATTR_KB_POR_COMMENT").value)
End Sub
'=============================================
Sub BTN_HIST_OnClick()
  call ShowComment("История", thisObject.Attributes("ATTR_KD_HIST_NOTE").value)
End Sub
'=============================================
Sub BTN_CREATE_DOC_OnClick()
  set doc = thisObject.Attributes("ATTR_KD_DOCBASE").Object
  if not doc is nothing then 
    if doc.ObjectDefName <> "OBJECT_KD_DOC_IN" then set doc = nothing ' только для ВД
  end if
  set newDoc = Create_Doc(doc)
  if not newDoc is nothing then 
    AddResDoc( newDoc)
  end if
  SetAllDocs(thisObject)
End Sub
'=============================================
Sub BTN_ADD_DOC_OnClick()
    Add_Doc()
End Sub
'=============================================
Sub BTN_DEL_DOC_OnClick()
  call Del_FromTable("ATTR_KD_POR_RESDOC", 0)
  SetAllDocs(thisObject)
End Sub
'=============================================
Sub BTN_ADD_CHI_DOC_OnClick()
  Set s = thisForm.Controls("QUERY_ORDERS_DOC").ActiveX
  If s.SelectedItem < 0 Then 
     msgbox "Не выбран документ!"
     Exit Sub 
  end if  
  
  for i = 0 to s.Count-1 ' для всех выделенных файлов
      if s.IsItemSelected(i) then _
         call AddResDoc(s.ItemObject(i))   
  Next
  SetAllDocs(thisObject)
End Sub
'=============================================
Sub BUT_ADD_FILE_OnClick()
   LoadFileToDoc("FILE_KD_ANNEX")
End Sub
'=============================================
Sub BUT_DEL_FILE_OnClick()
   call DelFilesFromDoc
End Sub
'=============================================
Sub BTN_ADD_FROM_CHI_OnClick()
  CopyFromChi(false)
'  call thisApplication.ExecuteScript("FORM_KD_EXCUTION","AddFiles","QUERY_ORDERS_FILES", thisObject)

End Sub
'=============================================
Sub BTN_ADD_ALL_OnClick()
  CopyFromChi(true)
End Sub
'=============================================
sub CopyFromChi(isAll)
  Set s = thisForm.Controls("QUERY_ORDERS_FILES").ActiveX
  If s.SelectedItem < 0 and not isAll Then 
     msgbox "Не выбран файл!"
     Exit Sub 
  end if  
  
  for i = 0 to s.Count-1 ' для всех выделенных файлов
      if s.IsItemSelected(i) or isAll then 
        set file = s.ItemObject(i)
        call CopyFileWithPdf(thisObject, file)
'        If not thisObject.Files.Has(file.FileName) then 
'          Set NewObjFile = thisObject.Files.AddCopy(file, file.FileName)
'          newObjFile.CheckOut newObjFile.WorkFileName
'        else
'          msgbox "Невозможно добавить файл, т.к. файл с таким наименование уже добавлен", vbCritical, "Добавление отменено"
'        End If
      end if  
  next
  thisObject.Update  
end sub
'=============================================
Sub BTN_CHI_ORDER_OnClick()
  set cOrder = GetOrderFromTree()
  if cOrder is nothing then exit sub

  call SetGlobalVarrible("ShowForm", "FORM_KD_ORDER_CARD")
  Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
  CreateObjDlg.Object = cOrder
  ans = CreateObjDlg.Show
End Sub
'=============================================
Sub QUERY_KD_FILES_IN_DOC_Selected(iItem, action)
  ShowFile(iItem)
End Sub

''=============================================
'Sub QUERY_KD_FILES_IN_DOC_DblClick(iItem, bCancelDefault)
'  Thisscript.SysAdminModeOn
'  Set s = thisForm.Controls("QUERY_KD_FILES_IN_DOC").ActiveX
'  set File = s.ItemObject(iItem) 
'  File_CheckOut(file)
'  bCancelDefault = true
'End Sub

'=============================================
Sub TDMSTREEOrder_DblClick(hItem,bCancelDefault)
    set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX 
    if ax_Tee is nothing then exit sub
    set cOrder = ax_Tee.GetItemData(hItem)
    if cOrder is nothing then exit sub
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = cOrder
    ans = CreateObjDlg.Show
    if ans then CreateTree(cOrder)
End Sub

'=============================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  if form.Controls.Has("TXT_" & Attribute.AttributeDefName) then ShowUser(Attribute.AttributeDefName)
  if Attribute.AttributeDefName = "ATTR_KD_OP_DELIVERY" then 
    set docObj = obj.Attributes("ATTR_KD_DOCBASE").Object
    if not docObj is nothing then 
      if docObj.attributes.has("ATTR_KD_KI") then _
         if docObj.attributes("ATTR_KD_KI").value = true then _
            call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", docObj)
      end if
  end if
  if Attribute.AttributeDefName = "ATTR_KD_POR_PLANDATE" then
    Text = Attribute.Value'thisForm.Attributes("ATTR_KD_POR_PLANDATE").Value
    if isDate(Text) then
      newDate = CDate(Text)
      If newDate < Date then
        msgbox "Невозможно задать контрольную дату меньше текущей даты"
        cancel = true
      end if
    end if
  end if
End Sub
'=============================================
Sub TDMSEDIT_NOTE_Modified()
  val = thisForm.Controls("TDMSEDIT_NOTE").Value 
  thisObject.Attributes("ATTR_KB_POR_RESULT").Value = val
End Sub
