USE "CMD_KD_LIB_DOC_IN"
'use CMD_KD_COMMON_LIB
use CMD_KD_COMMON_BUTTON_LIB 
use CMD_KD_GLOBAL_VAR_LIB  
use CMD_MARK_LIB
use CMD_KD_ORDER_LIB
use CMD_KD_CURUSER_LIB
'Set CurrentUser = ThisApplication.CurrentUser
'set FSO = CreateObject("Scripting.FileSystemObject")
'docStat = ThisObject.StatusName

'=============================================
Sub Form_BeforeShow(Form, Obj) 
 ' on error resume next   
    form.Caption = form.Description  
    call RemoveGlobalVarrible("AgreeObj")
    call RemoveGlobalVarrible("Settings") ' EV чтобы наверняка новое значение

'  thisapplication.AddNotify CStr(Timer()) & " - SetChBox"
    SetChBox()
'  thisapplication.AddNotify CStr(Timer()) & " - ShowUsers"
    ShowUsers()
'  thisapplication.AddNotify CStr(Timer()) & " - ShowKTNo"
    ShowKTNo()
'  thisapplication.AddNotify CStr(Timer()) & " - SetAutoComp"
    SetAutoComp()
'  thisapplication.AddNotify CStr(Timer()) & " - SetPersAutoComp"
    SetPersAutoComp()
'  thisapplication.AddNotify CStr(Timer()) & " - CreateTree"
  if obj.StatusName <> "STATUS_KD_DRAFT" then _
    CreateTree(nothing)
    ShowSysID()
    ShowBtnIcon()
'  thisapplication.AddNotify CStr(Timer()) & " - EnabledCtrl"
    EnabledCtrl()    
    ShowFile(0)
'  thisapplication.AddNotify CStr(Timer()) & " - end "

  if err.Number <> 0 then   msgbox err.Description, vbCritical
  on error goto 0  
End Sub
'=============================================
sub SetChBox()
'  set chk = thisForm.Controls("CHECKBOX1").ActiveX
  set chk = thisForm.Controls("TDMSEDITCHECKNO").ActiveX
  chk.buttontype = 4

  if chk is nothing then exit sub
  If ThisForm.Controls("ATTR_KD_VD_INСNUM").Value = "Без номера" Then 
       Chk.value = true
       ThisForm.Controls("ATTR_KD_VD_INСNUM").Readonly = true
  else 
       Chk.value = false
  End if  
  
  set chk = thisForm.Controls("TDMSEDITCHECKSHOW").ActiveX
  chk.buttontype = 4
  Chk.value = false
  
  set chk = thisForm.Controls("TDMSED_IMP").ActiveX
  chk.buttontype = 4
  Chk.value = thisObject.Attributes("ATTR_KD_IMPORTANT").Value

  set chk = thisForm.Controls("TDMSED_URG").ActiveX
  chk.buttontype = 4
  Chk.value = thisObject.Attributes("ATTR_KD_URGENTLY").Value

end sub

'=============================================
sub CreateTree(curOrder)
     set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX  
     if ax_Tee is nothing then exit sub
     ax_Tee.DeleteAllItems
'     ax_Tee.Font.Bold = true
     ax_Tee.Font.Size = 10
     if curOrder is nothing then set curOrder = GetCurUserRealOrder()'thisApplication.GetObjectByGUID("{CD59008D-BB2D-4B0D-ADFE-E6EC6D447B3F}")  
     set query = thisApplication.Queries("QUERY_KD_FIRST_ORDER")
     query.Parameter("PARAM0") = thisObject.Handle
     set objs = query.Objects
     for each order in objs
        call CreateChild(ax_Tee,0,order, curOrder)
     next
end sub
'=============================================
Sub TDMSTREEOrder_DblClick(hItem,bCancelDefault)
    set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX 
    if ax_Tee is nothing then exit sub
    set cOrder = ax_Tee.GetItemData(hItem)
    if cOrder is nothing then exit sub
    fName = thisForm.SysName
    call  RemoveGlobalVarrible("ShowForm")
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = cOrder
    ans = CreateObjDlg.Show
    CreateTree(cOrder)
    call  SetGlobalVarrible("ShowForm", fName)  
End Sub

''=============================================
'sub CreateChild(ax_Tee, parObj,chiObj,curOrder)
'  set user = chiObj.Attributes("ATTR_KD_OP_DELIVERY").user
'  if user is nothing then exit sub
'  txt = thisApplication.ExecuteScript("OBJECT_KD_DOC_OUT", "GetUserFIO", user) & " | к "
'  toDate = chiObj.Attributes("ATTR_KD_POR_PLANDATE").value
'  if trim(toDate) = "" then 
'    toDate = "..."
'  else
'    toDate = left(toDate, 5)
'  end if
'  txt = txt & toDate & " | " & chiObj.Attributes("ATTR_KD_TEXT").value
'  ch = ax_Tee.InsertItem(txt,parObj,0)  
'  call ax_Tee.SetItemData(ch,chiObj)
'  call ax_Tee.SetItemIcon(ch, chiObj.Icon)
'  for each order in chiObj.Content
'    call CreateChild(ax_Tee,ch,order,curOrder)
'  next
'  if not curOrder is nothing then 
'    if curOrder.handle = chiObj.handle then 
'      chiNo = ch
'      ax_Tee.SelectedItem = ch
'    end if
'  end if
'  ax_Tee.Expand(ch)
'end sub

'=============================================
sub SetAutoComp()
      Set ctrl = thisForm.Controls("ATTR_KD_CPNAME").ActiveX
      Set query = ThisApplication.Queries("QUERY_KD_CORDENT")
      set result = query.Objects
      ctrl.ComboItems = result
end sub
'=============================================
sub SetPersAutoComp()
  Set ctrl = thisForm.Controls("ATTR_KD_CPADRS").ActiveX
  set cordent = thisObject.Attributes("ATTR_KD_CPNAME").Object
  set result = thisApplication.ExecuteScript("CMD_KD_OUT_LIB", "GetPersQuery", cordent)
  ctrl.ComboItems = result
end sub
'=============================================

'=============================================
Sub BTN_REG_OnClick()
    'проверка на заполнение полей
    mes = Check_Fields ()
    
    If not mes = "" Then
       msgbox mes, vbCritical, "Не заполнены обязательные поля!"
       Exit Sub
    End if
    'проверяем дубликаты
    if not CheckDouble (true)  then 
      if thisObject.Attributes("ATTR_KD_VD_INСNUM").Value = "Без номера" then 
        ans = msgbox ("Вы уверены, что хотите зарегистрировать документ несмотря на найденные дубликаты?", _
            vbQuestion + vbYesNo,"Зарегистрировать документ?")
        if ans <> vbYes then exit sub              
      else
          exit sub
      end if     
    end if      
      ' проверяем есть скан
'    set file = GetFileByType("FILE_KD_SCAN_DOC")
'    if file is nothing then 
'      msgBox "Невозможно зарегистрировать документ, т.к. не приложен скан документа!", vbCritical, "Регистрация невозможна"
'      exit sub
'    end if

    ThisObject.Attributes("ATTR_KD_NUM").Value = GetNewNO(thisObject)
    ThisObject.Attributes("ATTR_KD_ISSUEDATE").Value = Now
    ThisObject.Attributes("ATTR_KD_REG").User = ThisApplication.CurrentUser
    ThisObject.Status = ThisApplication.Statuses("STATUS_KD_REGISTERED")
    thisObject.Update
    Set_Permission (thisObject)
'    msgBox "Документ зарегистрирован", vbInformation
End Sub

'=============================================
Function EnabledCtrl()
  
  on error resume next  
  orderEn = false 
  orderEn = thisApplication.ExecuteScript(thisObject.ObjectDefName,"CanIssueOrder", thisObject)
  if err.Number <> 0 then err.clear

  docStat = ThisObject.StatusName
  isSec = isSecretary(GetCurUser())
  thisform.Controls("BTN_TO_EXEC").Enabled = (orderEn and isSec) or (docStat = "STATUS_KD_VIEWED_RUK")
  thisform.Controls("BTN_TO_NOTE").Enabled = (orderEn and isSec) or (docStat = "STATUS_KD_VIEWED_RUK")
  thisform.Controls("BTN_REG").Enabled = isSec and docStat = "STATUS_KD_DRAFT"
'  thisform.Controls("BTN_ADD_CONTR").Enabled = isSec and docStat = "STATUS_KD_DRAFT"
  thisform.Controls("BTN_DEL_CONTRDENT").Enabled = isSec and docStat = "STATUS_KD_DRAFT"
  thisform.Controls("BTN_ADD_SCAN").Enabled = isSec and (docStat = "STATUS_KD_REGISTERED" or docStat = "STATUS_KD_VIEWED_RUK")
'  thisform.Controls("BTN_ADD_ORDER").Enabled = isSec and docStat = "STATUS_KD_VIEWED_RUK"
  thisform.Controls("BUT_ADD_FILE").Enabled = CanAddFile()'isSec 'and (docStat = "STATUS_KD_DRAFT" )
  thisform.Controls("BUT_DEL_FILE").Enabled = CanAddFile()'isSec 'and (docStat = "STATUS_KD_DRAFT")
  thisform.Controls("BTNCHECK_DOUBLE").Enabled = isSec and docStat = "STATUS_KD_DRAFT" 
  thisform.Controls("BTN_ORDERS").Enabled = orderEn
  thisform.Controls("CMD_COPY_DOC").Enabled = isSec
'  thisform.Controls("CMD_COPY_DOC").Enabled = isSec
  
End Function

''=============================================
'Sub CHECKBOX1_Change()

'   if not IsCanEdit() then 
'     SetChBox()
'     exit sub
'   end if
'   set chk = thisForm.Controls("CHECKBOX1").ActiveX
'   
'   With ThisForm.Controls("ATTR_KD_VD_INСNUM")
'    If chk.Value = true Then
'       .Value = "Без номера"
'       .ReadOnly = True
'    Else
'       .Value = "" 
'       .ReadOnly = False
'    End if   
'   End With 
'End Sub

'=============================================
Sub BUT_ADD_FILE_OnClick()
    'AddFilesToDoc("")
    Add_application()
End Sub

'=============================================
Sub BUT_DEL_FILE_OnClick()
    DelFilesFromDoc()
    ThisObject.Update
End Sub

'=============================================
Sub BTN_ADD_CONTR_OnClick()
'  call BTN_PADD_OnClick()
   thisObject.Update ' чтобы можно было отменить выбор получателя
   frmName = thisForm.SysName
   RemoveGlobalVarrible("ShowForm")

    Set Q = ThisApplication.Queries("QUERY_COR_GET_CORDENTs")
    Set SelObjDlg = ThisApplication.Dialogs.SelectDlg
    SelObjDlg.SelectFrom = Q.Sheet
    RetVal = SelObjDlg.Show
    If RetVal Then
       Set Cordent = SelObjDlg.Objects.Objects(0)
       ThisForm.Attributes("ATTR_KD_CPNAME") = Cordent.Parent
       ThisForm.Attributes("ATTR_KD_CPADRS") = Cordent
       RemoveGlobalVarrible("CompAuto")' чтобы перечитался список
       SetAutoComp()
       SetpersAutoComp()
    End if
    call SetGlobalVarrible("ShowForm",frmName)
End Sub

'=============================================
sub SetCordent(docObj,Cordent, siln)
  if Cordent is nothing then exit sub
  ans = vbYes
  if not IsCanEditObj(docObj) then exit sub
  if docObj.Attributes("ATTR_KD_CPNAME") <>"" or   docObj.Attributes("ATTR_KD_CPADRS") <> "" then
    if not siln then ans = msgbox("Вы уверены, что хотите заменить контрагента?", vbYesNo, "Заменить контрагента?")
  end if
  if ans <> vbYes then exit sub
  docObj.Attributes("ATTR_KD_CPNAME") = Cordent.Parent
  docObj.Attributes("ATTR_KD_CPADRS") = Cordent
'  SetAutoComp()
'  SetpersAutoComp()
end sub
'=============================================
Sub BTN_DEL_CONTRDENT_OnClick()
   ThisForm.Attributes("ATTR_KD_CPNAME") = ""
   ThisForm.Attributes("ATTR_KD_CPADRS") = ""
End Sub

''=============================================
'Sub QUERY_KD_FILES_IN_DOC_DblClick(iItem, bCancelDefault)
'  Thisscript.SysAdminModeOn
'  Set s = thisForm.Controls("QUERY_KD_FILES_IN_DOC").ActiveX
'  set File = s.ItemObject(iItem) 
'  File_CheckOut(file)
'  bCancelDefault = true
''    Set s = thisForm.Controls("QUERY_KD_FILES_IN_DOC").ActiveX
''    Set File = s.ItemObject(iItem)
''    Set dict = ThisApplication.Dictionary("Files")
''    If dict.Exists("FileName") Then 
''       dict.Item("FileName") = File.FileName
''    else
''       dict.Add "FileName", File.FileName
''    end if 
''    Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
''    EditObjDlg.Object = ThisObject
''    EditObjDlg.ActiveForm = EditObjDlg.InputForms("FORM_CORR_PDF")
''    EditObjDlg.Show 
''    bCancelDefault = True
'End Sub

'=============================================
Sub ATTR_KD_CPNAME_ButtonClick(Cancel)
    Cancel = True
End Sub
'=============================================
Sub ATTR_KD_CPADRS_ButtonClick(Cancel)
  Cancel = true   
End Sub
'=============================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  if form.Controls.Has("TXT_" & Attribute.AttributeDefName) then ShowUser(Attribute.AttributeDefName)
  
  if Attribute.AttributeDefName = "ATTR_KD_VD_SENDDATE" then
      if Attribute.Value > date then
          msgbox "Дата отправки ВД не может быть больше текущей даты", vbCritical, "Изменение отменено"
          cancel = true
      end if 
  end if
  
End Sub

'=============================================
Sub BTN_ADD_SCAN_OnClick()
  LoadFileToDoc("FILE_KD_RESOLUTION")
  Set_Doc_Ready(thisObject)
End Sub

'=============================================
Sub BTN_ADD_ORDER_OnClick()
   call CreateOrders(nothing, thisObject)
End Sub

'=============================================
Sub TDMSEDITCHECKNO_ButtonClick(bCancelDefaultOperation)
   if not IsCanEdit() then 
     SetChBox()
     bCancelDefaultOperation = true
     exit sub
   end if
   set checkbox = thisForm.Controls("TDMSEDITCHECKNO").ActiveX
   With ThisForm.Controls("ATTR_KD_VD_INСNUM")
   If checkbox.Value = false Then
       checkbox.Value = true
       .Value = "Без номера"
       .ReadOnly = True
    Else
       checkbox.Value = false  
       .Value = "" 
       .ReadOnly = False
    End if   
   End With 
   bCancelDefaultOperation = true
End Sub
'=============================================
Sub ATTR_KD_KT_Modified()
  ShowKTNo()
End Sub
'=============================================
Sub ATTR_KD_KI_Modified()
  ShowKTNo()
  call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", thisObject)
End Sub
'=============================================
Sub ATTR_KD_CPNAME_Modified()
  SetPersAutoComp()
  Set ctrl = thisForm.Controls("ATTR_KD_CPADRS").ActiveX
  if IsEmpty(ctrl.ComboItems) then 
       msgbox "Невозможно добавить контрагента " & thisForm.Attributes("ATTR_KD_CPNAME").Value & _
          " в текущий входящий документ " & thisObject.Description & ", т.к. для него не задано ни одно контактное лицо", vbExclamation
      thisForm.Attributes("ATTR_KD_CPNAME").Value = ""
      thisForm.Attributes("ATTR_KD_CPADRS").Value = ""
  else
    if Ubound(ctrl.ComboItems) = 0 then
      'tst = ctrl.ComboItems(0)
      ar = thisapplication.Utility.ArrayToVariant(ctrl.ComboItems) 
      hnd = ar(0)
      set user = thisApplication.Utility.GetObjectByHandle(hnd)
      if not user is nothing then 
        thisForm.Attributes("ATTR_KD_CPADRS").Value = user
      end if
    else 
      thisForm.Attributes("ATTR_KD_CPADRS").Value = ""
    end if 
  end if
  thisForm.Refresh
End Sub
'=============================================
Sub ATTR_KD_CPADRS_Modified()
  set contr = thisObject.Attributes("ATTR_KD_CPNAME").Object
  if not contr is nothing then exit sub ' если контрагент задан, что не меняем
  
  set user = thisObject.Attributes("ATTR_KD_CPADRS").Object
  if user is nothing then exit sub
  set userContr = user.Attributes("ATTR_COR_USER_CORDENT").object
  if userContr is nothing then exit sub
  thisObject.Attributes("ATTR_KD_CPNAME").object = userContr
  SetPersAutoComp()
  thisForm.Refresh
End Sub
''=============================================
'Sub BTN_NEWDOC_OnClick()
'    
'    call Create_Doc(nothing)
'End Sub
'=============================================
Sub BTN_TO_EXEC_OnClick()
  set curOrder = GetCurUserRealOrder()
  set cType = thisApplication.ObjectDefs(thisApplication.ObjectDefs("OBJECT_KD_ORDER_REP").Description)
  if CreateTypeOrder(curOrder, thisObject, cType) then
    if thisObject.StatusName = "STATUS_KD_REGISTERED" then
      ans = msgbox ("Отметить документ, как рассмотренный руководством?", vbQuestion + vbYESNo)
      if ans = vbYes then call BTN_ADD_SCAN_OnClick()
    end if
  end if
  CreateTree(nothing)
End Sub
'=============================================
Sub BTN_TO_NOTE_OnClick()
  'set curOrder = GetCurUserRealOrder()
  set cType = thisApplication.ObjectDefs(thisApplication.ObjectDefs("OBJECT_KD_ORDER_NOTICE").Description)
'  call CreateTypeOrder(curOrder, thisObject, cType) ' EV всегда в корне
  if CreateTypeOrder(nothing, thisObject, cType) then
    if thisObject.StatusName = "STATUS_KD_REGISTERED" then
      ans = msgbox ("Отметить документ, как рассмотренный руководством?", vbQuestion + vbYESNo)
      if ans = vbYes then call BTN_ADD_SCAN_OnClick()
    end if
  end if

  CreateTree(nothing)
End Sub
'=============================================
Sub BTNCHECK_DOUBLE_OnClick()
  '  thisObject.Update
    thisObject.SaveChanges(16384)   
    CheckDouble(false)  
'    call SetGlobalVarrible("ShowForm", "FORM_KD_DOUBLE_INDOC")
'    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
'    CreateObjDlg.Object = thisObject
'    ans = CreateObjDlg.Show
'    if not ans then 
'      thisObject.Erase
'      thisForm.Close
'    end if
End Sub

'=============================================
function CheckDouble (silent)
  CheckDouble = false
    if thisObject.Attributes("ATTR_KD_VD_INСNUM").value = "" or thisObject.Attributes("ATTR_KD_VD_SENDDATE").value = "" or _
      thisObject.Attributes("ATTR_KD_CPNAME").value = "" then
        if not silent then msgbox "Незаполнены обязательные поля", vbCritical
        exit function  
    end if    

    set qry = thisApplication.Queries("QUERY_DOUBLE_CHECK")
    qry.Parameter("PARAM0") = thisObject.Attributes("ATTR_KD_VD_INСNUM").value
    qry.Parameter("PARAM1") = thisObject.Attributes("ATTR_KD_VD_SENDDATE").value 
    qry.Parameter("PARAM2") = thisObject.Attributes("ATTR_KD_CPNAME").object
    qry.Parameter("PARAM3") = thisObject.Handle
  
    set objs = qry.Objects
    if objs.Count = 0 then  
      if not silent then msgbox "Дубликаты не найдены", vbInformation
      CheckDouble = true
      exit function
    end if
    frm = thisForm.SysName
    call SetGlobalVarrible("ShowForm", "FORM_KD_DOUBLE_INDOC")
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
'    CreateObjDlg.OkButtonText = "Вернуться к редактированию"
'    CreateObjDlg.CancelButtonText = "Удалить текущий документ"
    CreateObjDlg.Object = thisObject
    ans = CreateObjDlg.Show
    if not ans then 
      ans = msgbox("Вы уверены, что хотите удалить текущий документ?", vbQuestion + vbYesNo, "Удалить документ?")
      if ans = vbYes then 
        thisObject.Erase
        thisForm.Close
        CheckDouble = false
      end if
    end if
    thisObject.Update
    call SetGlobalVarrible("ShowForm", frm)
end function


'  set btnfav = thisForm.Controls("BTN_TO_CONTROL").ActiveX
'  if HasMark(thisObject, "избранное") then
'      btnfav.Image = thisApplication.Icons("IMG_IMPORTANT_ACTIVE")
'  else
'      btnfav.Image = thisApplication.Icons("IMG_IMPORTANT_PASSIVE")
'  end if
'  set btnfav = thisForm.Controls("BTN_TO_FAV").ActiveX
'  if HasMark(thisObject, "на контроле") then
'      btnfav.Image = thisApplication.Icons("IMG_ONCONTROL_ACTIVE")
'  else
'      btnfav.Image = thisApplication.Icons("IMG_ONCONTROL_PASSIVE")
'  end if

''=============================================
'Sub Files_DragAndDropped(FilesPathArray, Object, Cancel)

''    if not isSecretary(GetCurUser()) then 
''      cancel = true
''      exit sub ' EV только секретарь может добавлять файлы
''    end if
'    if Ubound(FilesPathArray)>=0 then 
'      For i=0 to Ubound(FilesPathArray)
'        'msgbox FilesPathArray(i) AddFilesToDoc
'        'call LoadFileByObj("FILE_KD_ANNEX", FilesPathArray(i), true, Object)
'        AddFile_application(FilesPathArray(i))
'      Next 
''    else
''      AddFilesToDoc(FilesPathArray(0))   
'    end if
''    Object.Permissions = SysAdminPermissions
''    Object.upDate
'End Sub
'=============================================
Sub BTN_ADD_COR_OnClick()

  frmName = thisForm.SysName
  RemoveGlobalVarrible("ShowForm")
  set cordent =  thisApplication.ExecuteScript("FORM_KD_CORDENTS","CreateOrg")
  call SetGlobalVarrible("ShowForm",frmName)

  if not cordent is nothing then 
    SetAutoComp()
    'SetPersAutoComp()
    ThisForm.Attributes("ATTR_KD_CPNAME") = cordent
    call ATTR_KD_CPNAME_Modified()
  end if
End Sub
'=============================================
Sub BTN_ADD_PERS_OnClick()
  frmName = thisForm.SysName
  RemoveGlobalVarrible("ShowForm")

  set pers = nothing
  set corDent = thisObject.Attributes("ATTR_KD_CPNAME").Object
  if corDent is nothing then
    set pers =  thisApplication.ExecuteScript("FORM_KD_CORDENTS","CreatePerson")  
  else 
    set pers =  thisApplication.ExecuteScript("FORM_KD_CORDENTS","CreatePersonByCord",CorDent)
  end if 
  if not pers is nothing then
     ThisForm.Attributes("ATTR_KD_CPNAME") = ""
     ThisForm.Attributes("ATTR_KD_CPADRS") = pers
     call ATTR_KD_CPADRS_Modified()
  end if
  call SetGlobalVarrible("ShowForm", frmName)
End Sub
'=============================================
Sub Form_BeforeClose(Form, Obj, Cancel)
   mes = Check_Fields ()
   If not mes = "" Then
      ans = msgbox(mes & vbNewLine & "Сохранить документ, несмотря на незаполненные поля?", vbCritical + VbYesNo,_
           "Сохранить документ, несмотря на незаполненные поля?")
      if ans = vbNo then   
        Cancel = true
        Exit Sub
      end if  
   End if
End Sub
'=============================================
Sub BTN_CANCEL_DOC_OnClick()
  set_Doc_Cancel
End Sub
'=============================================
Sub BTN_EDIT_COR_OnClick()
  set corDent = thisObject.Attributes("ATTR_KD_CPNAME").Object
  if corDent is nothing then exit sub
  frmName = thisForm.SysName
  RemoveGlobalVarrible("ShowForm")

  Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
  EditObjDlg.Object = corDent
  EditObjDlg.Show  
  call SetGlobalVarrible("ShowForm",frmName)
End Sub
'=============================================
Sub BTN_EDIT_PERS_OnClick()
  set corDent = thisObject.Attributes("ATTR_KD_CPADRS").Object
  if corDent is nothing then exit sub
  frmName = thisForm.SysName
  RemoveGlobalVarrible("ShowForm")

  Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
  EditObjDlg.Object = corDent
  EditObjDlg.Show  
  call SetGlobalVarrible("ShowForm",frmName)
End Sub
