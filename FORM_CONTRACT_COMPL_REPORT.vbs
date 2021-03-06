' Форма ввода - Акт
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.
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

  Call ShowAttrData(Form, Obj)
  Call SetButtonsEnabled(Obj)
  Call ShowCCRType(Obj)
  Call ShowFile(0) 
  Call SetFieldAutoComp()
End Sub

Sub ShowCCRType(Obj)
  If Obj.Attributes.Has("ATTR_CCR_INCOMING") Then
    If Obj.Attributes("ATTR_CCR_INCOMING").Value = True Then
      ThisForm.Controls("T_CCR_TYPE").Value = "Акт подрядчика" 
    Else
      ThisForm.Controls("T_CCR_TYPE").Value = "Акт Заказчика"   
    End If
  End If
End Sub

Sub SetButtonsEnabled(Obj)
  set cCtl=ThisForm.controls
  Set CU = ThisApplication.CurrentUser
  isAuth = IsAuthor(Obj,CU)
  isSign = IsSigner(Obj,CU)
  isChck = IsChecker(Obj,CU)
  isRegd = Obj.Attributes("ATTR_REGISTERED")
  isCCRGroupMem = CU.Groups.has("GROUP_CCR")
  '===============================================
  
  ' Акт подрядчика
  isCntrCCR = (Obj.Attributes("ATTR_CCR_INCOMING").Value = True)
  
  ' Акт Заказчика
  isCstmCCR = Not isCntrCCR
  
  cCtl("BTN_TO_AGREE").Visible = isCntrCCR
'  cCtl("ATTR_CONTRACTOR").Visible = isCntrCCR
'  Call SetControlVisible(ThisForm,"ATTR_USER_CHECKED",isCntrCCR)
  
  cCtl("BTN_COCOREPORT_SEND_TO_CHECK").visible = isCntrCCR
  cCtl("BTN_COCOREPORT_ENDORSE").visible = isCntrCCR
  
  Call SetContractorField()
    'Доступность кнопки "Зарегистрировать"
  cCtl("BUTTON_REGISTRATION").Enabled = CheckBtnReg(Obj) 'And (Not isRegistered(Obj))   'str 25/01/2018 Возможность изменить в любом статусе
  cCtl("BUTTON_REGISTRATION").Visible = cCtl("BUTTON_REGISTRATION").Enabled

'  cCtl("ATTR_DATA").Readonly =  Not (Obj.Attributes("ATTR_DATA").Empty = True And isAuth And isRegd)
'  cCtl("BTN_KD_ADD_CONTR").Enabled = (Obj.Attributes("ATTR_CONTRACT").Empty = True) And isAuth
'  cCtl("BTN_KD_DEL_CONTR").Enabled = (Obj.Attributes("ATTR_CONTRACT").Empty = False)  And isAuth
  'cCtl("BTN_ADD_SCAN").Enabled =  isAuth
 ' cCtl("BTN_OUT_DOC_PREPARE").Enabled = (Obj.StatusName = "STATUS_COCOREPORT_SIGNED")  And isAuth
  cCtl("BTN_OUT_DOC_PREPARE").Enabled = True
  cCtl("BTN_IS_SIGNED_BY_CONTRACTOR").Enabled = (Not Obj.Attributes("ATTR_IS_SIGNED_BY_CORRESPONDENT")) And (isAuth or isCCRGroupMem)
  cCtl("BTN_IS_SIGNED_BY_CONTRACTOR").Visible = ((Not Obj.Attributes("ATTR_IS_SIGNED_BY_CORRESPONDENT")) And (isAuth or isCCRGroupMem)) _
                                                 And isCstmCCR
  
  If isCntrCCR Then 
    Call SetInCCRButtonsEnabled(Obj)
  Else
    Call SetOutCCRButtonsEnabled(Obj)
  End If
End Sub

Sub SetInCCRButtonsEnabled(Obj)
' Акт подрядчика
  ThisScript.SysAdminModeOn
  set cCtl=ThisForm.controls
  Set CU = ThisApplication.CurrentUser
  '--------------------------------------------
  isLock = ObjectIsLockedByUser(Obj)
  '---------------------------------------
  isAuth = IsAuthor(Obj,CU)
  isSign = IsSigner(Obj,CU)
  isChck = IsChecker(Obj,CU)
  isExec = ThisApplication.ExecuteScript("CMD_KD_USER_PERMISSIONS", "isInic",CU, Obj)
  '---------------------------------------------
  isEdit = (Obj.StatusName = "STATUS_COCOREPORT_DRAFT" Or _
            Obj.StatusName = "STATUS_COCOREPORT_EDIT")
  isAgreed = Obj.StatusName = "STATUS_COCOREPORT_AGREED"
  isChckin = Obj.StatusName = "STATUS_COCOREPORT_CHECK"
  isChcked = Obj.StatusName = "STATUS_COCOREPORT_CHECKED"
  isSignin = Obj.StatusName = "STATUS_COCOREPORT_FOR_SIGNING"
  '----------------------------------------------
  isCntrCCR = (Obj.Attributes("ATTR_CCR_INCOMING").Value = True)
    ' Кнопка - На согласование
    
    cCtl("BTN_TO_AGREE").Enabled = isEdit And (isAuth or isExec) And isCntrCCR And not isLock
    cCtl("BTN_TO_AGREE").Visible = isEdit And (isAuth or isExec) And isCntrCCR
  
  
    cCtl("BTN_COCOREPORT_SEND_TO_CHECK").Enabled = isAgreed  And isAuth And not isLock
    cCtl("BTN_COCOREPORT_SEND_TO_CHECK").Visible = isAgreed  And isAuth
    
    cCtl("BTN_COCOREPORT_ENDORSE").Enabled = isChckin  And isChck And not isLock
    cCtl("BTN_COCOREPORT_ENDORSE").Visible = isChckin  And isChck
    
    cCtl("BTN_COCOREPORT_SEND_TO_SIGN").Enabled = isChcked  And isAuth And not isLock
    cCtl("BTN_COCOREPORT_SEND_TO_SIGN").Visible = isChcked  And isAuth
    
    cCtl("BTN_COCOREPORT_SIGN").Enabled = isSignin  And (isSign Or isAuth) And not isLock
    cCtl("BTN_COCOREPORT_SIGN").Visible = isSignin  And (isSign Or isAuth)
    
    res1 = isChckin  And isChck
    res2 = isSignin  And (isSign Or isAuth)
    cCtl("BTN_COCOREPORT_BACK_TO_WORK").Enabled = res1 or res2 And not isLock
    cCtl("BTN_COCOREPORT_BACK_TO_WORK").Visible = res1 or res2
End Sub

Sub SetOutCCRButtonsEnabled(Obj)
'Акт заказчика

  ThisScript.SysAdminModeOn
  set cCtl=ThisForm.controls
  Set CU = ThisApplication.CurrentUser
  '--------------------------------------------
  isLock = ObjectIsLockedByUser(Obj)
  '---------------------------------------
  isAuth = IsAuthor(Obj,CU)
  isSign = IsSigner(Obj,CU)
  isChck = IsChecker(Obj,CU)
  isExec = ThisApplication.ExecuteScript("CMD_KD_USER_PERMISSIONS", "isInic",CU, Obj)
  '---------------------------------------------
  isEdit = (Obj.StatusName = "STATUS_COCOREPORT_DRAFT" Or _
            Obj.StatusName = "STATUS_COCOREPORT_EDIT")
  isAgreed = Obj.StatusName = "STATUS_COCOREPORT_AGREED"
  isChckin = Obj.StatusName = "STATUS_COCOREPORT_CHECK"
  isChcked = Obj.StatusName = "STATUS_COCOREPORT_CHECKED"
  isSignin = Obj.StatusName = "STATUS_COCOREPORT_FOR_SIGNING"
  isSgnd = Obj.StatusName = "STATUS_COCOREPORT_SIGNED"
  '----------------------------------------------
  isCntrCCR = (Obj.Attributes("ATTR_CCR_INCOMING").Value = True)
  isSgndByCor = Obj.Attributes("ATTR_IS_SIGNED_BY_CORRESPONDENT")
    
    
    cCtl("BTN_COCOREPORT_SEND_TO_SIGN").Enabled = isEdit And isAuth And not isLock
    cCtl("BTN_COCOREPORT_SEND_TO_SIGN").Visible = isEdit And isAuth
    
    cCtl("BTN_COCOREPORT_SIGN").Enabled = isSignin  And (isSign Or isAuth) And not isLock
    cCtl("BTN_COCOREPORT_SIGN").Visible = isSignin  And (isSign Or isAuth)
    
    cCtl("BTN_IS_SIGNED_BY_CONTRACTOR").visible = Not isSgndByCor
      
    res1 = isSgnd  And isAuth
    res2 = isSignin  And (isSign Or isAuth)
    cCtl("BTN_COCOREPORT_BACK_TO_WORK").Enabled = (res1 or res2) And Not isSgndByCor And not isLock
    cCtl("BTN_COCOREPORT_BACK_TO_WORK").Visible = (res1 or res2) And Not isSgndByCor
      
End Sub

'Функция проверки доступности кнопки "Зарегистрировать"
Function CheckBtnReg(Obj)
  CheckBtnReg = False
  isReg = isRegistered(Obj)
  ' Str открыл в любом статусе регистрацию
'  If Obj.StatusName = "STATUS_COCOREPORT_SIGNED" And (Not isReg) Then
    Set u = Obj.Attributes("ATTR_AUTOR").User
    If u Is Nothing Then Exit Function
    Set cu = ThisApplication.CurrentUser
    CheckBtnReg = (u.SysName = cu.SysName) or cu.Groups.has("GROUP_CCR")
    
    If (u.SysName = cu.SysName) = False Then Exit Function
      CheckBtnReg = True
'  End If
End Function

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  If Attribute <> OldAttribute Then
    Call RoleUpdate (Obj,Attribute.AttributeDefName)
  End If
  
  If Attribute.AttributeDefName = "ATTR_CONTRACT" Then
    Set Contractor =  GetContractContractor(MainObj)
      If Not Contractor Is Nothing Then
        If Obj.Attributes("ATTR_CONTRACTOR").Object.Handle <> Contractor.Handle Then
          Obj.Attributes("ATTR_CONTRACTOR").Object = Contractor
        End If
      End If
  ElseIf Attribute.AttributeDefName = "ATTR_CONTRACTOR" Then
    Obj.Attributes("ATTR_CONTRACT").Object = Nothing
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

'Кнопка - Добавить накладную
Sub BUTTON_ADD_OnClick()
  Set TableRows = ThisObject.Attributes("ATTR_TINVOICES").Rows
  Set Query = ThisApplication.Queries("QUERY_CONTRACT_COMPL_REPORT_INVOICE")
  Set Contract = ThisApplication.ExecuteScript("CMD_S_NUMBERING","ObjectLinkGet",ThisObject,"ATTR_CONTRACT")
'  If Contract is Nothing Then
'    Msgbox "Должен быть заполнен атрибут ""Договор""", vbExclamation
'    Exit Sub
'  End If
'  Query.Parameter("OBJ") = Contract

  Set project = ThisObject.Attributes("ATTR_PROJECT").Object
  If project is Nothing Then
    msgbox "Проект не задан!",vbCritical,"Ошибка"
    Exit Sub
  End If

  Query.Parameter("PROJ") = project

  Set Objects = Query.Objects
  Call QueryObjectsFilter(Objects,"ATTR_INVOICE",TableRows)
  
  If Objects.Count <> 0 Then
    Set Dlg = ThisApplication.Dialogs.SelectObjectDlg
    Dlg.Caption = "Выбор накладной"
    Dlg.SelectFromObjects = Objects
    If Dlg.Show Then
      For Each Obj in Dlg.Objects
        Set NewRow = TableRows.Create
        NewRow.Attributes("ATTR_INVOICE").Object = Obj
      Next
      'ThisForm.Refresh
    End If
  Else
    Msgbox "Нет доступных для выбора накладных.", vbExclamation
    Exit Sub
  End If
End Sub

'Кнопка - Удалить накладную
Sub BUTTON_DEL_OnClick()
  Set Table = ThisForm.Controls("ATTR_TINVOICES")
  Set TableRows = ThisObject.Attributes("ATTR_TINVOICES").Rows
  If Table.SelectedObjects.Count <> 0 Then
    Key = Msgbox("Удалить связь с выбранными накладными?",vbYesNo+vbQuestion)
    If Key = vbYes Then
      For Each Row in Table.SelectedObjects
        TableRows.Remove Row
      Next
    End If
  End If
End Sub

Sub RoleUpdate(Obj,AttrName)
  ' Автор
  If AttrName = "ATTR_AUTHOR" Then
    Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_AUTOR","ROLE_AUTHOR")
  End If
  ' Подписант
  If AttrName = "ATTR_SIGNER" Then
    Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_SIGNER","ROLE_SIGNER")
  End If
End Sub

' Кнопка - на проверку
Sub BTN_COCOREPORT_SEND_TO_CHECK_OnClick()
  Res = ThisApplication.ExecuteScript("CMD_COCOREPORT_SEND_TO_CHECK","Main",ThisObject)
  If Res Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

' Кнопка - На подпись
Sub BTN_COCOREPORT_SEND_TO_SIGN_OnClick()
  Res = ThisApplication.ExecuteScript("CMD_COCOREPORT_SEND_TO_SIGN","Main",ThisObject)
  If Res Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

' Кнопка - Подписать
Sub BTN_COCOREPORT_SIGN_OnClick()
  Res = ThisApplication.ExecuteScript("CMD_COCOREPORT_SIGN","Main",ThisObject)
  If Res Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

' Кнопка - На доработку
Sub BTN_COCOREPORT_BACK_TO_WORK_OnClick()
  Res = ThisApplication.ExecuteScript("CMD_COCOREPORT_BACK_TO_WORK","Main",ThisObject)
  If Res Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

' Кнопка - Завизировать
Sub BTN_COCOREPORT_ENDORSE_OnClick()
  Res = ThisApplication.ExecuteScript("CMD_COCOREPORT_ENDORSE","Main",ThisObject)
  If Res Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

' Кнопка - Добавить связь с договором
Sub BTN_KD_ADD_CONTR_OnClick()
  Call AddContract(ThisObject)
  SetContractorField()
End Sub

' Добавить связь с договором
Sub AddContract(Obj)
'  Set q = ThisApplication.CreateQuery
'  q.Permissions = sysadminpermissions
'  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_CONTRACT"
'  q.AddCondition tdmQueryConditionStatus, "<>'STATUS_CONTRACT_CLOSED'"
  
  Set q = ThisApplication.Queries("QUERY_CONTRACTS_FOR_CCR")
  
  If Not Obj.Attributes("ATTR_CONTRACTOR").Object Is Nothing Then
  
  q.Parameter("CUSTOMER") = Obj.Attributes("ATTR_CONTRACTOR").Object.Handle
  q.Parameter("CONTRACTOR") = Obj.Attributes("ATTR_CONTRACTOR").Object.Handle
  
  End If
  
  If q.Objects.count = 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1604
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
  Obj.Attributes("ATTR_CONTRACT_STAGE").Object = Nothing
  Obj.Attributes("ATTR_PROJECT").Object = Nothing
    
  Obj.Attributes("ATTR_CCR_INCOMING").Value = _
    (ObjCol.Item(0).Attributes("ATTR_CONTRACT_CLASS").Classifier.SysName = "NODE_CONTRACT_EXP")
  Call ShowCCRType(Obj)
  If Obj.Attributes("ATTR_CONTRACTOR").Empty = True Then
   ' Заполняем контрагента
   Set Contractor =  GetContractContractor(ObjCol.Item(0))
   Obj.Attributes("ATTR_CONTRACTOR").Object = Contractor
  End If
End Sub
' Кнопка - Удалить связь с договором
Sub BTN_KD_DEL_CONTR_OnClick()
  Call Deletecontract(ThisObject)
  SetContractorField()
End Sub


Sub SetContractorField()
  Set CU = ThisApplication.CurrentUser
  isAuth = IsAuthor(THisObject,CU)
  ThisForm.Controls("ATTR_CONTRACTOR").ReadOnly = Not (THisObject.Attributes("ATTR_CONTRACT").Empty = True And isAuth)
End Sub

' Удалить связь с договором
Sub DeleteContract(Obj)
  ans = msgbox ("Удалить связь с договором?", vbQuestion+vbYesNo)
  If ans = vbYes Then
    Obj.Attributes("ATTR_CONTRACT").object = Nothing
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

'Кнопка - "Зарегистрировать"
Sub BUTTON_REGISTRATION_OnClick()
  Set Obj = ThisObject
  Set CU = ThisApplication.CurrentUser
  Obj.Permissions = SysAdminPermissions
  'Добавляем атрибут к акту
  If Obj.Attributes.Has("ATTR_PROJECT_ORDINAL_NUM") = False Then
    Obj.Attributes.Create ThisApplication.AttributeDefs("ATTR_PROJECT_ORDINAL_NUM")
    Obj.Update
  End If
  
  
  Set Form = ThisApplication.InputForms("FORM_GetRegNumber")
  Form.Attributes("ATTR_OBJECT").Object = Obj
  Form.Controls("BUTTON_AUTO").Visible = True
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

Sub BUTTON_DOCS_ADD_OnClick()
  ThisScript.SysAdminModeOn
  Set TableRows = ThisObject.Attributes("ATTR_DOCS_TLINKS").Rows
  
  If ThisObject.Attributes.Has("ATTR_CONTRACT") Then 
    Set oContr = ThisObject.Attributes("ATTR_CONTRACT").Object
    If oContr is Nothing Then Exit Sub
  End If
  If ThisObject.Attributes.Has("ATTR_PROJECT") Then
    Set Project = ThisObject.Attributes("ATTR_PROJECT").Object
    If Project is Nothing Then 
      msgbox "Проект не задан!",vbCritical,"Ошибка"
      Exit Sub
    End If
  End If

  
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "'OBJECT_WORK_DOCS_SET' Or 'OBJECT_VOLUME' Or 'OBJECT_INVOICE'"
  q.AddCondition tdmQueryConditionAttribute,  Project, "ATTR_PROJECT"
  If ThisObject.Attributes("ATTR_CCR_INCOMING") = True Then
    q.AddCondition tdmQueryConditionAttribute,  1, "ATTR_SUBCONTRACTOR_WORK"
    q.AddCondition tdmQueryConditionAttribute,  oContr, "ATTR_CONTRACT_SUBCONTRACTOR"
  End If
  
  Set Objects = q.Objects
  Objects.Sort True
  If Objects.count = 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1701
    Exit Sub
  End If  
  
  'Исключаем объекты, которые уже есть в таблице
  ThisApplication.ExecuteScript "CMD_DLL", "QueryObjectsFilter", Objects, "ATTR_DOC_REF", TableRows
  
  If Objects.Count = 0 Then
    Msgbox "В системе нет подходящих объектов.", vbExclamation
    Exit Sub
  End If
  
  Set Dlg = ThisApplication.Dialogs.SelectObjectDlg
  Dlg.SelectFromObjects = Objects
  If Dlg.Show Then
    If Dlg.Objects.Count <> 0 Then
      For Each Obj in Dlg.Objects
        'Проверка на наличие задания в таблице
        Check = True
        GUID = Obj.GUID
        For Each Row in TableRows
          If Row.Attributes("ATTR_DOC_REF").Empty = False Then
            If not Row.Attributes("ATTR_DOC_REF").Object is Nothing Then
              If Row.Attributes("ATTR_DOC_REF").Object.GUID = GUID Then
                Check = False
                Exit For
              End If
            End If
          End If
        Next
        If Check = True Then
          'Создаем новую запись в таблице
          Set NewRow = TableRows.Create
          NewRow.Attributes("ATTR_DOC_REF").Object = Obj
          NewRow.Attributes("ATTR_USER").Value = ThisApplication.CurrentUser
          NewRow.Attributes("ATTR_DATA").Value = ThisApplication.CurrentTime
        End If
      Next
      ThisForm.Refresh
      ThisApplication.ExecuteScript "CMD_DLL", "TableRowsSort", TableRows, "ATTR_DOC_REF"
    End If
  End If
End Sub


Sub BUTTON_DOCS_DEL_OnClick()
  ThisScript.SysAdminModeOn
  Set Table = ThisForm.Controls("ATTR_DOCS_TLINKS")
  Arr = Table.ActiveX.SelectedRows
  'Подтверждение удаления
  Key = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion + vbYesNo, 1607, UBound(Arr)+1)
  If Key = vbNo Then Exit Sub
  
  'Удаление строк
  For i = 0 to UBound(Arr)
    Set Row = Table.ActiveX.RowValue(Arr(i))    
    Row.Erase
  Next
  ThisForm.Refresh
End Sub

Sub CMD_CONTRACT_STAGE_SEL_OnClick()
  Call ThisApplication.ExecuteScript ("CMD_S_DLL", "SetContractStage", ThisObject,"ATTR_CONTRACT_STAGE")
End Sub

Sub CMD_CONTRACT_STAGE_DEL_OnClick()
  ans = msgbox ("Удалить связь с этапом договора?", vbQuestion+vbYesNo)
  If ans = vbYes Then
    ThisObject.Attributes("ATTR_CONTRACT_STAGE").Object= Nothing
  End If
End Sub

Sub BTN_PROJECT_DEL_OnClick()
  ans = msgbox ("Удалить связь с проектом?", vbQuestion+vbYesNo)
  If ans = vbYes Then
    ThisObject.Attributes("ATTR_PROJECT").Object= Nothing
  End If
End Sub


Sub BTN_PROJECT_SEL_OnClick()

  Set Objects = GetProjectsForContract(ThisObject)
  If Objects Is Nothing Then 
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1701
    Exit Sub
  End If
  If Objects.count = 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1701
    Exit Sub
  End If  
  
  If Objects.count > 1 Then 
    Call SetProject(SelectObjDlg(Objects))
    Exit Sub
  End If
    
  If Objects.count = 1 Then 
    Call SetProject(Objects(0))
    Exit Sub
  End If
End Sub

Function GetProjectsForContract(Obj)
  Set GetProjectsForContract = Nothing
  If Obj.Attributes.Has("ATTR_CONTRACT") = False Then Exit Function
  
  Set oContr = Obj.Attributes("ATTR_CONTRACT").Object
  If oContr Is Nothing Then Exit Function

  If Obj.Attributes("ATTR_CCR_INCOMING") = True Then
    Set oMainContr = oContr.Attributes("ATTR_CONTRACT_MAIN").Object
    If oMainContr Is Nothing Then Exit Function
    Set contr = oMainContr
  Else
    Set contr = oContr
  End If
  
  Set q = ThisApplication.Queries("QUERY_PROJECTS_FOR_CCR")
  q.Parameter("CONTRACT") = contr
  Set Objects = q.Objects
  If Objects.Count = 0 Then
    msgbox "Нет проектов, связанных с указанным договором",vbInformation,"Выбор проекта"
  End If
  Set GetProjectsForContract = Objects
End Function

Sub SetProject(Obj)
  If ThisObject.Attributes.Has("ATTR_PROJECT") Then
    ThisObject.Attributes("ATTR_PROJECT").Object = Obj
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


