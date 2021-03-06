use CMD_KD_TEMPL_LIB

'=================================
Sub Form_BeforeShow(Form, Obj)
  setCntrEnable()
End Sub

'=================================
sub  setCntrEnable()
  if thisApplication.CurrentUser.Groups.Has("Администраторы шаблонов") then 
      thisForm.Controls("ATTR_KD_T_REGIONS").Enabled = true
      thisForm.Controls("ATTR_KD_T_REGIONS").ReadOnly = false
      thisForm.Controls("BTN_ALL_REG").Enabled = true
      thisForm.Controls("ATTR_KD_PERS_TEMPL").Enabled = true
  end if
end sub
'=================================
Sub ATTR_NAME_BeforeModify(Text,Cancel)
  if not checkTmplName(text, thisObject.ObjectDefName) then 
    msgbox "Шаблон с таким наименование существует. " & vbNewLine & "Введите другое наименование"
    cancel = true
  end if  
End Sub
'=================================
Sub BTN_ADD_USER_OnClick()
    Add_User_Click()
End Sub
'=================================
Sub BTN_ADD_GROUP_OnClick()
    set selObj = thisApplication.Dialogs.SelectDlg '.SelectObjectDlg
    selObj.Prompt = "Выберите пользователей"
    SelObj.SelectFrom = thisApplication.Groups
    RetVal = selObj.Show 
    Set projObjs = selObj.Objects
    If (RetVal<>TRUE) Or (projObjs.count = 0) Then Exit Sub
    for each user in projObjs
       call Add_User(user, false,thisForm)  
    next
End Sub
'=================================
Sub BTN_ALL_REG_OnClick()
  set q = thisApplication.Queries("QUERY_KD_ALL_REGION")
  set objs = q.Objects
  for each obj in objs
    call addReg(obj,true)
  next 
End Sub
'=================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  if attribute.AttributeDefName = "ATTR_KD_PERS_TEMPL" then _
         call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", Obj)
End Sub
'=================================
Sub Form_BeforeClose(Form, Obj, Cancel)
  txt =  checkTeml(obj)
  if txt <> "" then
    msgbox "Не все обязательные поля заданы - " & vbNewLine & txt, vbCritical, "Ошибка"
    cancel = true
    exit sub
  end if
End Sub
'=================================
Sub BTN_DEL_USER_OnClick()
    call Del_FromTable("ATTR_KD_ORDER_RECIPIEND", 0 )      
End Sub

