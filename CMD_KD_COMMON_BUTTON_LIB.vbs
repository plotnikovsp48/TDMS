'use CMD_KD_GLOBAL_VAR_LIB 
use CMD_KD_COMMON_LIB
use CMD_KD_FILE_LIB
use CMD_MARK_LIB
'=============================================
Sub BTN_PADD_OnClick()
    frmName = thisForm.SysName
    lev = GetGlobalVarrible("WinLevel")' чтобы не увеличить счетчик
    curLev = lev
    if lev <> "" then  
      lev = lev - 1
      'call SetGlobalVarrible("WinLevel", lev) 
    end if
  
  'If not ThisApplication.Dictionary.Exists("SetRecip") Then ThisApplication.Dictionary.Add "SetRecip",True
     call  SetGlobalVarrible("ShowForm", "FORM_KD_CORDENTS")  
     Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
     EditObjDlg.Object = ThisObject
     if EditObjDlg.Show then 
     end if

    ' call SetGlobalVarrible("WinLevel", curLev) 'возвращает текущее значение

     'If ThisApplication.Dictionary.Exists("SetRecip") Then ThisApplication.Dictionary.Remove "SetRecip"
     'RemoveGlobalVarrible("ShowForm")
     call  SetGlobalVarrible("ShowForm", frmName)  
     RemoveGlobalVarrible("CompAuto")' чтобы перечитался список
End Sub

'=============================================
Sub BTN_PDELL_OnClick()
    call Del_FromTable("ATTR_KD_TCP", "ATTR_KD_CPADRS")
End Sub

'=============================================
Sub BTN_DEL_PRO_OnClick()
  call Del_FromTable("ATTR_KD_TLINKPROJ", "ATTR_KD_LINKPROJ" ) 
End Sub

'=============================================
Sub BTN_LOAD_FILE_OnClick()
    LoadFileToDoc("FILE_KD_ANNEX")
End Sub

'=============================================
Sub BTN_UnLoad_OnClick()
    call UnloadFilesFromDoc
End Sub

'=============================================
Sub BTN_DEL_APP_OnClick()
    call DelFilesFromDoc
    call ShowFileName()
End Sub
'=============================================
sub AddReplDoc(DocObj, CurReply)   
    Set ReplyRows = DocObj.Attributes("ATTR_KD_VD_REPGAZ").Rows

    'Проверка нет ли добавляемого письма в списке
    DocObj.Permissions = SysAdminPermissions
    if not IsExistsObjItemCol(ReplyRows,CurReply,0) then
      Set NewRow = ReplyRows.Create
      NewRow.Attributes(0).Value = CurReply 
      NewRow.Attributes(1).Value = CurReply.Attributes("ATTR_KD_TOPIC").value 
' добавляем получателя, если можем
      if CurReply.Attributes.Has("ATTR_KD_CPADRS") then 
        set cordent = CurReply.Attributes("ATTR_KD_CPADRS").object 
        call thisApplication.ExecuteScript("FORM_KD_CORDENTS", "AddCorDent", DocObj,cordent, false)
        call SetProjByDoc(DocObj,CurReply)
      elseif  CurReply.Attributes.Has("ATTR_KD_TCP") then 
        Set Rows = CurReply.Attributes("ATTR_KD_TCP").Rows
        if rows.count > 0 then _
        set cordent =  Rows(0).Attributes("ATTR_KD_CPADRS").object
        call thisApplication.ExecuteScript("FORM_ID_CARD","SetCordent",DocObj,Cordent, false)
      end if  
    else
      msgBox "Письмо " & CurReply.Description & " уже есть в списке. Добавление не будет произведено.",vbInformation
    end if   
      
end sub
'=============================================
sub SetProjByDoc(DocObj,CurReply)   
  if DocObj.ObjectDefName <> "OBJECT_KD_DOC_OUT" then exit sub
  for each row in CurReply.Attributes("ATTR_KD_TLINKPROJ").rows
    set  proj = row.Attributes("ATTR_KD_LINKPROJ").Object
    if not proj is nothing then _
      call AddNewProjSilent(DocObj, proj,true) 
  next

end sub


'=============================================
Sub BTN_REPLY_ADD_OnClick()

    Set Q = ThisApplication.Queries("QUERY_KD_DOC_TO_REP")
    select case thisObject.ObjectDefName 
        case "OBJECT_KD_DOC_IN" Q.Parameter("PARAM0") = "OBJECT_KD_DOC_OUT"
        case "OBJECT_KD_DOC_OUT" Q.Parameter("PARAM0") = "OBJECT_KD_DOC_IN"
        Case Else  Q.Parameter("PARAM0") = thisObject.ObjectDefName
    end select    
    Set Objs = Q.Objects

    set SelObjDlg = thisApplication.Dialogs.SelectDlg'SelectObjectDlg
    SelObjDlg.Prompt = "Выберите один или несколько документов:"
    SelObjDlg.SelectFrom = Q.Sheet'SelectFromObjects = Objs

    RetVal = SelObjDlg.Show 
     If (RetVal<>TRUE) Then Exit Sub  
     Set ObjCol = SelObjDlg.Objects
     if (ObjCol.RowsCount=0) Then Exit Sub  
    
     For Each obj In ObjCol.Objects
         call AddReplDoc(thisObject, obj)   
     Next
    if not isCanedit() then thisObject.saveChanges(16384)
End Sub
'=============================================
Sub BTN_REPLY_DELETE_OnClick()
 call Del_FromTable("ATTR_KD_VD_REPGAZ", "ATTR_KD_D_REFGAZNUM" ) 
End Sub
'=============================================
Sub BTN_TO_CONTROL_OnClick()
  set btnfav = thisForm.Controls("BTN_TO_CONTROL").ActiveX
  if HasMark(thisObject, "на контроле") then 
      call dellMark(thisObject, "на контроле")
      btnfav.Image = thisApplication.Icons("IMG_ONCONTROL_PASSIVE")
'      msgbox "Снято с контроля"
      thisForm.Close true
  else    
      call CreateMark("на контроле",thisObject, false)
      btnfav.Image = thisApplication.Icons("IMG_ONCONTROL_ACTIVE")
 '    msgbox "Поставлено на контроль"
  end if
  thisForm.Refresh
End Sub
'=============================================
Sub BTN_TO_FAV_OnClick()
  set btnfav = thisForm.Controls("BTN_TO_FAV").ActiveX
  if HasMark(thisObject, "избранное") then 
      call dellMark(thisObject, "избранное")
      btnfav.Image = thisApplication.Icons("IMG_IMPORTANT_PASSIVE")
'      msgbox "Удалено из избранного"
  else    
      call CreateMark("избранное",thisObject, false)
      btnfav.Image = thisApplication.Icons("IMG_IMPORTANT_ACTIVE")
'     msgbox "Добавлено в избранное"
  end if
  thisForm.Refresh
End Sub
'=============================================
Sub BTN_SAVE_TEMPLATE_OnClick()
  set btnfav = thisForm.Controls("BTN_SAVE_TEMPLATE").ActiveX
  if HasMark(thisObject, "шаблон") then 
      call dellMark(thisObject, "шаблон")
      btnfav.Image = thisApplication.Icons("IMG_SAVE_ENABLED")
      msgbox "Метка шаблон снята"
  else      
      call CreateMark("шаблон",thisObject, false)
      btnfav.Image = thisApplication.Icons("IMG_SAVE")
     msgbox "Метка шаблон установлена"
  end if
  thisForm.Refresh
End Sub

'=============================================
sub ShowBtnIcon()
  set btnfav = thisForm.Controls("BTN_TO_FAV").ActiveX
  if HasMark(thisObject, "избранное") then
      btnfav.Image = thisApplication.Icons("IMG_IMPORTANT_ACTIVE")
  else
      btnfav.Image = thisApplication.Icons("IMG_IMPORTANT_PASSIVE")
  end if
  set btnfav = thisForm.Controls("BTN_TO_CONTROL").ActiveX
  if HasMark(thisObject, "на контроле") then
      btnfav.Image = thisApplication.Icons("IMG_ONCONTROL_ACTIVE")
  else
      btnfav.Image = thisApplication.Icons("IMG_ONCONTROL_PASSIVE")
  end if
  if thisForm.Controls.Has("BTN_SAVE_TEMPLATE") then 
    set btnfav = thisForm.Controls("BTN_SAVE_TEMPLATE").ActiveX
    thisForm.Controls("BTN_SAVE_TEMPLATE").Enabled = true
    thisForm.Controls("BTN_FROM_TEMP").Enabled = IsCanEdit()
    if HasMark(thisObject, "шаблон") then
        btnfav.Image = thisApplication.Icons("IMG_SAVE")
    else
        btnfav.Image = thisApplication.Icons("IMG_SAVE_ENABLED")
    end if
  end if
end sub
'=============================================
sub ShowSysID()
  on error resume next
  thisForm.Controls("STSYSID").Value = "ID "& thisObject.Attributes("ATTR_KD_IDNUMBER").value
  if err.Number <> 0 then 
    txt = "Ошибка открытия формы " & err.Description
    txt = txt & vbNewLine & "Форма - " & thisForm.Description
    txt = txt & vbNewLine & "Объект - " & thisObject.Description & " - "& thisObject.ObjectDefName
    txt = txt & vbNewLine & "Пожалуйста, сообщите разработчикам" 
    msgbox txt, VbCritical, "Ошибка открытия формы "
    err.clear
  end if
  on error goto 0
end sub
'=============================================
sub ShowKTNo()
  if thisform.Attributes("ATTR_KD_KT").Value = true then 'or thisform.Attributes("ATTR_KD_KI").Value = true then 
      thisForm.Controls("ATTR_KD_KOF_NO").Visible = true
      thisForm.Controls("STATIC13").Visible = true
  else    
      thisForm.Controls("ATTR_KD_KOF_NO").Visible = false
      thisForm.Controls("STATIC13").Visible = false
  end if
end sub
'=============================================
Sub TDMSED_IMP_ButtonClick(bCancelDefaultOperation)

   set checkbox = thisForm.Controls("TDMSED_IMP").ActiveX
   checkbox.Value = not checkbox.Value
   thisScript.SysAdminModeOn
   thisObject.Attributes("ATTR_KD_IMPORTANT").Value =  checkbox.Value
   if not IsCanEdit() then  thisObject.Update
   bCancelDefaultOperation = true

End Sub
'=============================================
Sub TDMSED_URG_ButtonClick(bCancelDefaultOperation)
   set checkbox = thisForm.Controls("TDMSED_URG").ActiveX
   checkbox.Value = not checkbox.Value
   thisScript.SysAdminModeOn
   thisObject.Attributes("ATTR_KD_URGENTLY").Value =  checkbox.Value
   if not IsCanEdit() then  thisObject.Update
   bCancelDefaultOperation = true

End Sub

'=============================================
Sub QUERY_KD_FILES_IN_DOC_DblClick(iItem, bCancelDefault)
  Thisscript.SysAdminModeOn
  Set s = thisForm.Controls("QUERY_KD_FILES_IN_DOC").ActiveX
  set File = s.ItemObject(iItem) 
  File_CheckOut(file)
  s.SelectedItem = -1
  bCancelDefault = true

End Sub
'=============================================
Sub QUERY_KD_FILES_IN_DOC_Selected(iItem, action)
   ShowFile(iItem)
End Sub
'=============================================
Sub BTN_RELATIONS_OnClick()
    frmName = thisForm.SysName
    call SetGlobalVarrible("ShowForm", "FORM_KD_DOC_LINKS")
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = thisObject
    ans = CreateObjDlg.Show
    call SetGlobalVarrible("ShowForm", frmName)
End Sub
'=============================================
Sub BTN_HIST_OnClick()
    call SetGlobalVarrible("ShowForm", "FORM_KD_HIST")
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = thisObject
    ans = CreateObjDlg.Show

End Sub
'=============================================
Sub BTN_ORDERS_OnClick()
    CheckTwoDialogs(thisForm)
  
    call SetGlobalVarrible("ShowForm", "FORM_KD_DOC_ORDERS")
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = thisObject
    ans = CreateObjDlg.Show
End Sub
'=============================================
sub CheckTwoDialogs(Form)
  lev = thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","GetGlobalVarrible","WinLev")
 ' msgbox "Открытых дополнительных окон = " & lev
  set dictForm = thisapplication.Dictionary("forms_card_orders_agree")
  if (not isempty(dictForm("last"))) and lev > 1 then
    dictForm("last").close
  end if
  set dictForm("last") = Form
end sub

'=============================================
Sub ATTR_KD_KT_Modified()
  ShowKTNo()
  thisObject.Attributes("ATTR_KD_SUFFIX").Value = Get_Suffix(thisObject) 
End Sub
' EV т.к. на создании ИД нет этих контролов
''=============================================
'Sub ATTR_KD_WITHOUT_PROJ_Modified()
'  SetProjEnable()
'End Sub
'=============================================
sub SetProjEnable()
  isEnabled = not thisObject.Attributes("ATTR_KD_WITHOUT_PROJ").Value
  thisForm.Controls("CMD_KD_ADD_CONTR").Enabled = isEnabled
  thisForm.Controls("CMD_KD_DEL_CONTR").Enabled = isEnabled
  thisForm.Controls("CMD_KD_ADD_PROJ").Enabled = isEnabled
  thisForm.Controls("BTN_DEL_PRO").Enabled = isEnabled
end sub
'=============================================
Sub BTN_AGREE_OnClick()
    CheckTwoDialogs(thisForm)
  
    call SetGlobalVarrible("ShowForm", "FORM_KD_DOC_AGREE")
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = thisObject
    ans = CreateObjDlg.Show

End Sub
'=============================================
Sub BTN_KD_ADD_CONTR_OnClick()
  AddContr(thisObject)
End Sub
'=============================================
Sub BTN_KD_DEL_CONTR_OnClick()
  call DelContr(thisObject)
End Sub
'=============================================
Sub BTN_KD_ADD_PROJ_OnClick()
  call AddProj(thisObject)
End Sub
'=============================================
Sub BTN_KD_ADD_COMMENT_OnClick()
  AskAddComment("ATTR_KD_NOTE")
End Sub
'=============================================
Sub BTN_KD_EDIT_COMMENT_OnClick()
  call EidtComment("ATTR_KD_NOTE")
End Sub
'=============================================
Sub BTNPackUnLoad_OnClick()
   UnloadFilesFromDoc()
End Sub
'=============================================
Sub ATTR_KD_WITHOUT_PROJ_Modified()
  if thisObject.Attributes("ATTR_KD_WITHOUT_PROJ").Value then 
    if DelContr(thisObject) then
       thisForm.Refresh
    else
      thisObject.Attributes("ATTR_KD_WITHOUT_PROJ") = false 
    end if
  end if
End Sub
'=============================================
Sub BTN_CARD_OnClick()
  oldName = thisForm.SysName
  CheckTwoDialogs(thisForm)

'  if dictForm.Exists("last") then
'    set lastFrm = dictForm("last") 
'    if not lastFrm is nothing then lastFrm.close
'  end if
 
'  set settings = thisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB","GetSettingsByObjS", thisObject, true)
'  if not settings is nothing then 
'    fName =  settings.Attributes("ATTR_KD_OBJ_CARD_FORM").value
'    if fName <> "" then 
'        call SetGlobalVarrible("ShowForm", fName)
'    else
'        call RemoveGlobalVarrible("ShowForm")
'    end if
'  else
'    call RemoveGlobalVarrible("ShowForm")
'  end if     
'  select case  thisObject.ObjectDefName
'    case "OBJECT_KD_DOC_OUT" call SetGlobalVarrible("ShowForm", "FORM_KD_OUT_CARD")
'    case "OBJECT_KD_MEMO" call SetGlobalVarrible("ShowForm","FORM_KD_MEMO_CARD")
'    case "OBJECT_KD_DOC_IN"   call SetGlobalVarrible("ShowForm", "FORM_ID_CARD")
'    case "OBJECT_KD_DIRECTION" call SetGlobalVarrible("ShowForm", "FORM_ORD_CARD")
'  end select 
    fName = ""
    on error resume next  
    fName =  thisApplication.ExecuteScript(thisObject.ObjectDefName,"GetCardName")
    if err.Number <>0 then err.clear
    on error goto 0
    if fName = "" then 
        msgbox "Форма карточки не определена", vbCritical
        exit sub
    else
        call SetGlobalVarrible("ShowForm", fName)
    end if
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = thisObject
    ans = CreateObjDlg.Show
'    if ans then _
    call SetGlobalVarrible("ShowForm", oldName)
End Sub
'=============================================
Sub BTN_FROM_TEMP_OnClick()

    Set Q = ThisApplication.Queries("QUERY_DOC_TEMPLS")
    Q.Parameter("PARAM0") = thisObject.ObjectDefName
'    Set Objs = Q.Objects

    set SelObjDlg = thisApplication.Dialogs.SelectDlg'SelectObjectDlg
    SelObjDlg.Prompt = "Выберите шаблон документов для копирования:"
    SelObjDlg.SelectFrom = Q.Sheet'SelectFromObjects = Objs

    RetVal = SelObjDlg.Show 
    If (RetVal<>TRUE) Then Exit Sub  
    Set ObjCol = SelObjDlg.Objects
    if (ObjCol.RowsCount = 0) Then Exit Sub  
    
    set docObj = ObjCol.Objects(0)
 
    if not CopyAttrs(docObj,thisObject) then 
      msgbox "Не удалось скопировать атрибуты документа", vbCritical, "Ошибка"
      exit sub
    end if
    
    if not copyFiles(docObj,thisObject) then 
      msgbox "Не удалось скопировать файлы", vbCritical, "Ошибка"
      exit sub
    end if
  
    thisForm.Refresh

End Sub
'=============================================
Sub BTN_NEWDOC_OnClick()
  call Create_Doc(thisObject)
End Sub

'=============================================
Sub ATTR_KD_KI_Modified()
  ShowKTNo()
  call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", thisObject)
End Sub
'=============================================
' обрабока галки показывать не актуальные
Sub TDMSEDITCHECKSHOW_ButtonClick(bCancelDefaultOperation)
   set checkbox = thisForm.Controls("TDMSEDITCHECKSHOW").ActiveX
   if checkbox.Value = false then
    checkbox.Value = true
   else 
    checkbox.Value = false
   end if
   call SetGlobalVarrible("ShowOldFile", checkbox.Value)
   bCancelDefaultOperation = true
   thisForm.Refresh
End Sub
'=============================================
' устанвока галки показывать не актуальные
sub SetShowOldFailFlag()
  set edit = thisForm.Controls("TDMSEDITCHECKSHOW").ActiveX
  edit.buttontype = 4
  if IsExistsGlobalVarrible("ShowOldFile") then  
      edit.Value =  GetGlobalVarrible("ShowOldFile")
  else   
      if thisApplication.CurrentUser.Attributes.Has("ATTR_KD_SHOWUNACTUAL")  then 
        edit.Value = thisApplication.CurrentUser.Attributes("ATTR_KD_SHOWUNACTUAL").Value
      else
        edit.Value = true
      end if
      call SetGlobalVarrible("ShowOldFile", edit.Value)
      thisForm.Refresh
  end if
end sub
