
'USE "CMD_KD_COMMON_BUTTON_LIB"
'USE "CMD_KD_COMMON_LIB"
USE "CMD_DLL_COMMON_BUTTON"
USE "CMD_DLL"
USE "CMD_S_DLL"
USE "CMD_DLL_CONTRACTS"
USE "CMD_DLL_ROLES"
USE "CMD_FILES_LIBRARY"
USE "CMD_PROJECT_DOCS_LIBRARY"

Sub Form_BeforeShow(Form, Obj)
  Call SetLabels(Form, Obj)
  set cCtl=Form.controls
  
'  If Obj.Attributes("ATTR_CONTRACT").Empty = False Then
'    If not Obj.Attributes("ATTR_CONTRACT").Object is Nothing Then
'      cCtl("CMD_CONTRACTOR_ADD").Readonly = True
'      cCtl("CMD_CONTRACTOR_CREATE").Readonly = True
'    End If
'  End If  
  Call ThisApplication.ExecuteScript("CMD_DLL", "ShowBtnIcon",Form,Obj)
  Call ShowAttrData(Form, Obj)
  Call SetButtonsEnabled(Obj)
  Call ShowFile(0) 
  Call SetFieldAutoComp()
End Sub

Sub SetButtonsEnabled(Obj)
  ThisScript.SysAdminModeOn
  set cCtl=ThisForm.controls
  Set CU = ThisApplication.CurrentUser
  isAuth = IsAuthor(Obj,CU)
  isSign = IsSigner(Obj,CU)
  
'  cCtl("BTN_KD_ADD_CONTR").Enabled = (Obj.Attributes("ATTR_CONTRACT").Empty = True) And isAuth
'  cCtl("BTN_KD_DEL_CONTR").Enabled = (Obj.Attributes("ATTR_CONTRACT").Empty = False)  And isAuth
'  
'  cCtl("BTN_KD_ADD_CONTR").Enabled = (Obj.Attributes("ATTR_CONTRACT").Empty = True) And isAuth
'  cCtl("BTN_KD_DEL_CONTR").Enabled = (Obj.Attributes("ATTR_CONTRACT").Empty = False)  And isAuth
  
  'Доступность кнопки "Зарегистрировать"
  cCtl("BUTTON_REGISTRATION").Enabled = CheckBtnReg(Obj)' And (Not isRegistered(Obj))
  'cCtl("BTN_ADD_SCAN").Enabled =  isAuth
  
  cCtl("BTN_TO_AGREE").Enabled = (Obj.StatusName = "STATUS_AGREEMENT_DRAFT") And isAuth
  cCtl("BTN_AGREEMENT_SEND_TO_SIGN").Enabled = (Obj.StatusName = "STATUS_AGREEMENT_AGREED") And isAuth
  cCtl("BTN_AGREEMENT_SIGN").Enabled = (Obj.StatusName = "STATUS_AGREEMENT_FOR_SIGNING")  And isSign
  cCtl("BTN_AGREEMENT_BACK_TO_WORK").Enabled = (Obj.StatusName = "STATUS_AGREEMENT_FOR_SIGNING")  And isSign
  cCtl("BTN_IS_SIGNED_BY_CONTRACTOR").Enabled = (Not Obj.Attributes("ATTR_IS_SIGNED_BY_CORRESPONDENT")) And isAuth
  
  cCtl("BTN_OUT_DOC_PREPARE").Enabled = True
End Sub

' Выбор контрагента
Sub CMD_CONTRACTOR_ADD_OnClick()
  Set o = ThisObject
  Set oCorr = GetCompany ()
  If oCorr is Nothing Then Exit Sub
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetAttr", o,"ATTR_CONTRACTOR",oCorr)
End Sub

Sub CMD_CONTRACTOR_CREATE_OnClick()
  Set NewOrg = CreateOrg()
  Set o = ThisObject
  aDef = "ATTR_CONTRACTOR"
  If Not NewOrg Is Nothing Then
    Call ThisApplication.ExecuteScript("CMD_DLL", "SetAttr", o,aDef,NewOrg)
  End If
End Sub

Sub CMD_CONTACT_PERSON_ADD_OnClick()
  Dim q
  Set q = ThisApplication.Queries("QUERY_CONTACT_PERSON_FOR_CONTRACT")
  
  Set o = ThisObject
  Set param0 = Nothing
  
  If o.Attributes("ATTR_CONTRACTOR").Empty = False Then
    If not o.Attributes("ATTR_CONTRACTOR").Object is Nothing Then
      If o.Attributes("ATTR_CONTRACTOR").Object.handle <> ThisApplication.Attributes("ATTR_MY_COMPANY").Object.Handle Then
        Set param0 = o.Attributes("ATTR_CONTRACTOR").Object
      End If
    End If
  End If
  
  If param0 is Nothing Then 
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1612, ThisObject.Description
    Exit Sub
  End If

  q.Parameter("PARAM0") = param0
  Set Objects = q.Objects
    If Objects.Count = 0 Then
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1610, param0.Description
      Exit Sub
    End If
  
  Set us = SelectObjectDialog (q,"Выберите только одно контактное лицо:")
  If us is Nothing Then Exit Sub
  set u =  param0.Objects.Item(us.CellValue(0,0))
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetAttr", o,"ATTR_CORDENT_USER",u)
  txt = u.Description
  If u.Attributes.Has("ATTR_CORR_ADD_POSITION") and u.Attributes("ATTR_CORR_ADD_POSITION").Empty = False Then
    txt = txt & ", " & u.attributes("ATTR_CORR_ADD_POSITION")
  End If
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetAttr", o,"ATTR_CONTACT_PERSON_STR",txt)
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  Set oContr = Obj.Attributes("ATTR_CONTRACT").Object
  If Attribute <> OldAttribute Then
    Call RoleUpdate (Obj,Attribute.AttributeDefName)
  End If
  
  If Attribute.AttributeDefName = "ATTR_STARTDATE_PLAN" Then
  
    ' Проверяем дату начала этапа с датой начала договора
    If Not oContr Is Nothing Then
      If oContr.Attributes("ATTR_STARTDATE_PLAN") > Attribute Then
        msgbox "Дата начала не может быть раньше даты начала работ по договору", vbExclamation,"Ошибка даты"
        Cancel = True
      End If
    End If
    
    If Attribute.Empty = False Then
      If Obj.Attributes("ATTR_ENDDATE_PLAN").Empty = False Then
        If Attribute.Value > Obj.Attributes("ATTR_ENDDATE_PLAN") Then
          msgbox "Дата начала не может быть позднее даты окончания", vbExclamation,"Ошибка даты"
          Cancel = True
        End If
      End If
    End If
  ElseIf Attribute.AttributeDefName = "ATTR_ENDDATE_PLAN" Then
  ' Проверяем дату окончания этапа с датой окончания договора
    If Not oContr Is Nothing Then
      If oContr.Attributes("ATTR_ENDDATE_PLAN") < Attribute Then
        msgbox "Дата окончания не может быть позднее даты окончания работ по договору", vbExclamation,"Ошибка даты"
        Cancel = True
      End If
    End If
    
    If Attribute.Empty = False Then
      If Obj.Attributes("ATTR_STARTDATE_PLAN").Empty = False Then
        If Attribute.Value < Obj.Attributes("ATTR_STARTDATE_PLAN") Then
          msgbox "Дата окончания не может быть ранее даты начала" , vbExclamation,"Ошибка даты"
          Cancel = True
        End If
      End If
    End If
  End If
End Sub

'Событие - Выделен файл в выборке
Sub QUERY_FILES_IN_DOC_Selected(iItem, action)
  Call QueryFileSelect(ThisForm,iItem,Action)
  If iItem <> -1 and Action = 2 Then
    ThisForm.Controls("BTN_DELETE_FILES").Enabled = True
  Else
    ThisForm.Controls("BTN_DELETE_FILES").Enabled = False
  End If
  Call ShowFile(iItem)
End Sub

'Кнопка - "Зарегистрировать"
Sub BUTTON_REGISTRATION_OnClick()
  Set Obj = ThisObject
  Set CU = ThisApplication.CurrentUser
  Obj.Permissions = SysAdminPermissions
  'Добавляем атрибут к соглашению
  If Obj.Attributes.Has("ATTR_PROJECT_ORDINAL_NUM") = False Then
    Obj.Attributes.Create ThisApplication.AttributeDefs("ATTR_PROJECT_ORDINAL_NUM")
    Obj.Update
  End If
  
  Set Form = ThisApplication.InputForms("FORM_GetRegNumber")
  Form.Attributes("ATTR_OBJECT").Object = Obj
  RetVal = Form.Show
  If RetVal = True  Then
    Set Dict = Form.Dictionary
    If Dict.Exists("BUTTON") Then
      If Dict.Item("BUTTON") = True Then
        Num = Dict.Item("NUM")
        Obj.Attributes("ATTR_REG_NUMBER").Value = Dict.Item("REGNUM")
        Obj.Attributes("ATTR_DATA").Value = Dict.Item("DATA") ' A.O. 22.01.2018
        Obj.Attributes("ATTR_KD_REGDATE").Value = FormatDateTime(Date, vbShortDate)
        Obj.Attributes("ATTR_REGISTERED").Value = True
        Obj.Attributes("ATTR_REG").User = CU
        Obj.Attributes("ATTR_PROJECT_ORDINAL_NUM").Value = Num
        Obj.Update
      End If
    End If
    Dict.RemoveAll
    Call SetButtonsEnabled(Obj)
  End If
End Sub

Sub RoleUpdate(Obj,AttrName)
  ' Автор
  If AttrName = "ATTR_AUTOR" Then
    Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_AUTOR","ROLE_AGREEMENT_AUTHOR")
  End If
  ' Подписант
  If AttrName = "ATTR_SIGNER" Then
    Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_SIGNER","ROLE_SIGNER")
  End If
End Sub

' Кнопка - Удалить связь с договором
Sub BTN_KD_DEL_CONTR_OnClick()
  Call Deletecontract(ThisObject)
End Sub

' Удалить связь с договором
Sub DeleteContract(Obj)
  res = msgbox ("Удалить связь с договором?", vbQuestion+vbYesNo)
  If res = vbYes Then
    Obj.Attributes("ATTR_CONTRACT").object = Nothing
  End If
End Sub

' Кнопка - Добавить связь с договором
Sub BTN_KD_ADD_CONTR_OnClick()
  Call AddContract(ThisObject)
End Sub

' Добавить связь с договором
Sub AddContract(Obj)
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_CONTRACT"
  q.AddCondition tdmQueryConditionStatus, "<>'STATUS_CONTRACT_CLOSED'"
  If q.Objects.count = 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1156
    Exit Sub
  End If  
  
  
  Set Dlg = ThisApplication.Dialogs.SelectObjectDlg
  Dlg.SelectFromObjects = q.Objects
  Dlg.Prompt = "Выберите договор:"
  Dlg.Caption = "Договор"
  
  RetVal=Dlg.Show
  ' Если ничего не выбрано или диалог отменен, выйти
  Set ObjCol = Dlg.Objects
  If (RetVal<>TRUE) Or (ObjCol.Count=0) Then Exit Sub
  
  Obj.Attributes("ATTR_CONTRACT").Object = ObjCol.Item(0)
  Obj.Attributes("ATTR_CONTRACTOR").Object = ThisApplication.ExecuteScript("OBJECT_CONTRACT","GetContractor",ObjCol.Item(0))
End Sub

' Кнопка - На подпись
Sub BTN_AGREEMENT_SEND_TO_SIGN_OnClick()
  Res = ThisApplication.ExecuteScript("CMD_AGREEMENT_SEND_TO_SIGN","Main",ThisObject)
  If Res Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

' Кнопка - Подписать
Sub BTN_AGREEMENT_SIGN_OnClick()
  Res = ThisApplication.ExecuteScript("CMD_AGREEMENT_SIGN","Main",ThisObject)
  If Res Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

' Кнопка - На доработку
Sub BTN_AGREEMENT_BACK_TO_WORK_OnClick()
  Res = ThisApplication.ExecuteScript("CMD_AGREEMENT_BACK_TO_WORK","Main",ThisObject)
  If Res Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

Sub BTN_IS_SIGNED_BY_CONTRACTOR_OnClick()
  ThisScript.SysAdminModeOn  
  Res = ThisApplication.ExecuteScript("CMD_AGREEMENT_SIGN_BY_CONTRACTOR","Main",ThisObject)
  If Res Then
  SetButtonsEnabled(ThisObject)
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

Sub BTN_TO_AGREE_OnClick()
  ThisForm.Close True
  
  ' Запоминаем, какую форму нужно активировать при переоткрытии диалога свойств
  Set dict = ThisObject.Dictionary
  If Not dict.Exists("FormActive") Then 
    dict.Add "FormActive", "FORM_KD_DOC_AGREE"
  End If
  
  Call ThisApplication.ExecuteScript ("CMD_DOC_SENT_TO_AGREED", "Run", ThisObject)
End Sub
