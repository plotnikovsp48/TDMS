' Форма ввода - Накладная
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

USE "CMD_DLL_COMMON_BUTTON"
USE "CMD_DLL"
USE "CMD_FILES_LIBRARY"
USE "CMD_PROJECT_DOCS_LIBRARY"
USE "CMD_DLL_ROLES"

Sub Form_BeforeShow(Form, Obj)
  Call SetLabels(Form, Obj)
  Call SetButtonsEnabled(Form, Obj)
  Call SetControls(Form,Obj)
  Call ShowFile(0) 
End Sub

'Кнопка - "Зарегистрировать"
Sub BUTTON_REGISTRATION_OnClick()
  'Добавляем атрибут к договору
  Set Obj = ThisObject
  Set CU = ThisApplication.CurrentUser
  Obj.Permissions = SysAdminPermissions
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
        Obj.Attributes("ATTR_KD_ISSUEDATE").Value = Dict.Item("DATA")
        Obj.Attributes("ATTR_REGISTERED").Value = True
        Obj.Attributes("ATTR_REG").User = CU
        Obj.Attributes("ATTR_PROJECT_ORDINAL_NUM").Value = Num
        Obj.Update
        'Создание поручения
        Set u = Nothing
        Set Project = ThisApplication.ExecuteScript("CMD_S_NUMBERING","ObjectLinkGet",Obj,"ATTR_PROJECT")
        If not Project is Nothing Then
          If Project.Attributes.Has("ATTR_PROJECT_GIP") Then
            If Project.Attributes("ATTR_PROJECT_GIP").Empty = False Then
              If not Project.Attributes("ATTR_PROJECT_GIP").User is Nothing Then
                Set u = Project.Attributes("ATTR_PROJECT_GIP").User
              End If
            End If
          End If
        End If
        resol = "NODE_4E1FB947_3927_4101_9C25_D52838C999F6"
        ObjType = "OBJECT_KD_ORDER_REP"
        txt = "Прошу подготовить сопроводительное письмо к накладной """ & Obj.Description & """"
        planDate = DateAdd ("d", 1, Date) 'Date + 1
        
        ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,u,CU,resol,txt,PlanDate
      End If
      Call SetDataEnabled(ThisForm, Obj)
    End If
    Dict.RemoveAll
  End If
End Sub

Sub QUERY_FILES_IN_DOC_Selected(iItem, action)
  Call QueryFileSelect(ThisForm,iItem,Action)
  If iItem <> -1 and Action = 2 Then
    ThisForm.Controls("BTN_DELETE_FILES").Enabled = True
  Else
    ThisForm.Controls("BTN_DELETE_FILES").Enabled = False
  End If
  Call ShowFile(iItem)
End Sub

Sub SetButtonsEnabled(Form, Obj)
  Set CU = ThisApplication.CurrentUser
 
  isLock = ObjectIsLockedByUser(Obj)
  '---------------------------------------------------------
  isAuth = IsAuthor(Obj,CU)
  isChck = IsChecker(Obj,CU)
  isSign = IsSigner(Obj,CU)
  isRegd = Obj.Attributes("ATTR_REGISTERED")
  '---------------------------------------------------------
  isOnSign = (Obj.StatusName = "STATUS_INVOICE_ONSIGN")
  isOnCheck = (Obj.StatusName = "STATUS_INVOICE_ONCHECK")
  isSignd = (Obj.StatusName = "STATUS_INVOICE_SIGNED")
  isDrft = (Obj.StatusName = "STATUS_INVOICE_DRAFT")
  isEdit = (Obj.StatusName = "STATUS_INVOICE_EDIT")
  isCmpl = (Obj.StatusName = "STATUS_INVOICE_FORTHEPICKING")
  
  With Form.Controls
    .Item("BUTTON_REGISTRATION").Enabled = (CheckBtnReg(Obj) And isAuth) And not isLock
    .Item("BUTTON_REGISTRATION").Visible = CheckBtnReg(Obj) And isAuth
    Call SetDataEnabled(Form, Obj)
    
    .Item("BTN_INVOICE_SEND_TO_CHECK").Enabled = (isAuth And (isCmpl Or isEdit)) And not isLock
    .Item("BTN_INVOICE_SEND_TO_CHECK").Visible = isAuth And (isCmpl Or isEdit)
    
    .Item("BTN_INVOICE_TO_SIGN").Enabled = isChck And isOnCheck And not isLock
    .Item("BTN_INVOICE_TO_SIGN").Visible = isChck And isOnCheck
    
    .Item("BTN_INVOICE_SIGN").Enabled = isSign And isOnSign And not isLock
    .Item("BTN_INVOICE_SIGN").Visible = isSign And isOnSign
    
    .Item("BTN_INVOICE_BACK_TO_WORK").Enabled = ((isSign And isOnSign) Or (isChck And isOnCheck)) And not isLock
    .Item("BTN_INVOICE_BACK_TO_WORK").Visible = (isSign And isOnSign) Or (isChck And isOnCheck)

    .Item("BTN_INVOICE_INVALIDATED").Enabled = ((isAuth And isEdit) Or _
                        (isChck And isOnCheck) Or _
                        (isSign And isOnSign) Or _
                        (isAuth And isSignd)) And not isLock
    .Item("BTN_INVOICE_INVALIDATED").Visible = (isAuth And isEdit) Or _
                        (isChck And isOnCheck) Or _
                        (isSign And isOnSign) Or _
                        (isAuth And isSignd)
                        
    .Item("BTN_INVOICE_SENT").Enabled = isAuth And isSignd And not isLock
    .Item("BTN_INVOICE_SENT").Visible = isAuth And isSignd
    
    .Item("BTN_INVOICE_CLOSE").Enabled = isAuth And (Obj.StatusName = "STATUS_INVOICE_SENDED") And not isLock
    .Item("BTN_INVOICE_CLOSE").Visible = isAuth And Obj.StatusName = "STATUS_INVOICE_SENDED"
    
'    .Item("ATTR_INVOICE_RECIPIENT").ReadOnly = Not((isAuth And isCmpl) And Not isLock)
    .Item("ATTR_INVOICE_RECIPIENT").ReadOnly = Not((isAuth And (isDrft or isCmpl or isEdit)) And Not isLock)
    
    .Item("BTN_OUT_DOC_PREPARE").Enabled = True
      
  End With
End Sub

Sub SetDataEnabled(Form, Obj)
  isAuth = IsAuthor(Obj,ThisApplication.CurrentUser)
  isRegd = Obj.Attributes("ATTR_REGISTERED")
  With Form.Controls
    .Item("ATTR_KD_ISSUEDATE").Readonly = Not (Obj.Attributes("ATTR_KD_ISSUEDATE").Empty And isAuth And isRegd)
  End With
End Sub
'Функция проверки доступности кнопки "Зарегистрировать"
Function CheckBtnReg(Obj)
  CheckBtnReg = (Not Obj.Attributes("ATTR_REGISTERED") And _
                 Obj.StatusName = "STATUS_INVOICE_FORTHEPICKING")
End Function

Sub BTN_INVOICE_SEND_TO_CHECK_OnClick()
  ThisObject.Permissions = SysAdminPermissions 
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_INVOICE_SEND_TO_CHECK", "Main", ThisObject)
  If Res = True Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

Sub BTN_INVOICE_TO_SIGN_OnClick()
  ThisObject.Permissions = SysAdminPermissions 
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_INVOICE_TO_SIGN", "Main", ThisObject)
  If Res = True Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub
Sub BTN_INVOICE_SIGN_OnClick()
  ThisObject.Permissions = SysAdminPermissions 
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_INVOICE_SIGN", "Main", ThisObject)
  If Res = True Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub


Sub BTN_INVOICE_BACK_TO_WORK_OnClick()
  ThisObject.Permissions = SysAdminPermissions 
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_INVOICE_BACK_TO_FORTHEPICKING", "Main", ThisObject)
  If Res = True Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub
Sub BTN_INVOICE_INVALIDATED_OnClick()
  ThisObject.Permissions = SysAdminPermissions 
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_INVOICE_INVALIDATED", "Main", ThisObject)
  If Res = True Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

Sub BTN_INVOICE_SENT_OnClick()
  ThisObject.Permissions = SysAdminPermissions 
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_INVOICE_SEND", "Main", ThisObject)
  If Res = True Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

Sub BTN_INVOICE_CLOSE_OnClick()
  ThisObject.Permissions = SysAdminPermissions 
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_INVOICE_CLOSE", "Main", ThisObject)
  If Res = True Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

Sub SetControls(Form,Obj)
  With Form.Controls
    .Item("ATTR_AUTOR").ReadOnly = Not (Obj.Attributes("ATTR_AUTOR").Empty = True Or _
                                        (Not IsCanEdit(Obj)))
  End With
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  Select Case Attribute.AttributeDefName
    Case "ATTR_INVOICE_RECIPIENT"
      If Attribute.Empty = False Then
        Set oRec = Attribute.Object
        If oRec.Attributes.Has("ATTR_CORDENT_ADDRES") Then
          address = oRec.Attributes("ATTR_CORDENT_ADDRES")
          If Obj.Attributes("ATTR_INVOICE_ADDRESS") <> address Then
            Obj.Attributes("ATTR_INVOICE_ADDRESS") = address
          End If
        End If
      Else
        Obj.Attributes("ATTR_INVOICE_ADDRESS") = vbNullString
      End If
  End Select
End Sub
