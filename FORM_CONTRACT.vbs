' Автор: Стромков С.А.
'
' Библиотека функций стандартной версии
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2017 г.

'USE "CMD_KD_COMMON_BUTTON_LIB"
'USE "CMD_KD_COMMON_LIB"
USE "CMD_DLL_COMMON_BUTTON"
USE "OBJECT_CONTRACT"
USE "CMD_DLL"
USE "CMD_S_DLL"
USE "CMD_DLL_CONTRACTS"
USE "CMD_DLL_ROLES"
USE "CMD_FILES_LIBRARY"
USE "CMD_PROJECT_DOCS_LIBRARY"


'USE "CMD_DIALOGS"

Sub Form_BeforeShow(Form, Obj)
  ThisScript.SysAdminModeOn
  Call SetLabels(Form, Obj)
  Call ThisApplication.ExecuteScript("CMD_DLL", "ShowBtnIcon",Form,Obj)
  
  Set cCtl = Form.controls 
  If Obj.StatusName <> "STATUS_CONTRACT_CLOSED" Then
    cCtl("TXT_ATTR_CONTRACT_CLOSE_TYPE") = ""
  Else
    cCtl("TXT_ATTR_CONTRACT_CLOSE_TYPE") = Obj.Attributes("ATTR_CONTRACT_CLOSE_TYPE").Value
  End If
  
  Set ContrClass = Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier

  Call SetClassDependentControls (ContrClass)
  Call ShowAttrData(Form, Obj)
  
  Call SetControls(Form,Obj)
  Call SetCoredentControls(Form,Obj)
  
  Call SetFilesActionButtonLocked(Form,False)
  Call SetTendrBlock(Form,Obj)
  Call SetButtonsEnabled(Obj)
  Call SetFieldAutoComp()
End Sub

'========================================================================================================================
Sub SetCoredentControls(Form,Obj)
  ThisApplication.DebugPrint "SetCoredentControls " & Time
'  Set cls = Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier
'  If cls Is Nothing Then Exit Sub
'  cClass = Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier.SysName
'  set cCtl=Form.controls 
  isCnEdt = ThisApplication.CurrentUser.Groups.Has("GROUP_CONTRACTS")

  
  If IsExpenceContract(Obj) Then
    ' Отключена зависимость от принадлежности контрагента к субъектам малого и среднего бизнеса
    ' 19.01.2018. Кейс ФБ №6394
'    Form.controls("ATTR_DAY_TYPE").ReadOnly = Not (Not Obj.Attributes("ATTR_KD_COREDENT_TYPE") And isCnEdt)
    Form.controls("ATTR_DAY_TYPE").ReadOnly = Not isCnEdt
  End If
End Sub

'========================================================================================================================
Function ContractClass(Obj)
  ContractClass = ""
  Set cls = Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier
  If cls Is Nothing Then Exit Function
  ContractClass = Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier.SysName
End Function

'========================================================================================================================
Function IsProfitContract(Obj)
  ThisApplication.DebugPrint "IsProfitContract " & Time
  IsProfitContract = ContractClass(Obj) = "NODE_CONTRACT_PRO"
End Function

Function IsExpenceContract(Obj)
  ThisApplication.DebugPrint "IsExpenceContract " & Time
  IsExpenceContract = ContractClass(Obj) = "NODE_CONTRACT_EXP"
End Function

'========================================================================================================================
Sub SetControls(Form,Obj)
  Set CU = ThisApplication.CurrentUser
  Set cCtl = Form.controls
  OldContr = CheckOldContract(Obj)
  FinishStatus = CheckAttrsFinish(Obj)
  StName = Obj.StatusName
  
  cCtl("QUERY_FILES_IN_DOC").Visible = Obj.Permissions.ViewFiles = 1
  cCtl("T_FILES_DENY").Visible = Not cCtl("QUERY_FILES_IN_DOC").Visible
  
  If OldContr = True or FinishStatus = True Then
    cCtl("ATTR_REG_NUMBER").Readonly = False
    'Открываем в любом статусе для договрников. см. Ниже
    ' str 29/01/2018
'    cCtl("EDIT_ATTR_DATA").Readonly = False
'    cCtl("EDIT_ATTR_DATA").Enabled = True
  Else
    If Obj.Attributes("ATTR_REGISTERED") = True And Obj.Attributes("ATTR_REG_NUMBER").Empty=False Then
      cCtl("ATTR_REG_NUMBER").Readonly = True
    End If
  End If
  cCtl("ATTR_REG").Readonly = not OldContr
  'Obj.Attributes("ATTR_IS_SIGNED_BY_CORRESPONDENT").Value = True
  'Obj.Attributes("ATTR_REGISTERED").Value = True
  'Obj.Attributes("ATTR_REG").User = CU
                                      
  If Obj.Attributes("ATTR_ENDDATE_PLAN").Empty = True Then 
    cCtl("EDIT_ATTR_ENDDATE_PLAN").Value = vbNullString
  Else
    cCtl("EDIT_ATTR_ENDDATE_PLAN").Value = Obj.Attributes("ATTR_ENDDATE_PLAN").Value
  End If
  
  If Obj.Attributes("ATTR_STARTDATE_PLAN").Empty = True Then 
    cCtl("EDIT_ATTR_STARTDATE_PLAN").Value = vbNullString
  Else
    cCtl("EDIT_ATTR_STARTDATE_PLAN").Value = Obj.Attributes("ATTR_STARTDATE_PLAN").Value
  End If
  
  cCtl("ATTR_CONTACT_PERSON").ReadOnly = True

  'Доступность полей Сроки
  ' Открываем во всех статусах. см. Ниже
  ' str 29.01.2018
'  cCtl("ATTR_STARTDATE_PLAN").ReadOnly = (Obj.statusName <> "STATUS_CONTRACT_DRAFT")
'  cCtl("ATTR_ENDDATE_PLAN").ReadOnly = (Obj.statusName <> "STATUS_CONTRACT_DRAFT")
  
  '------------------------------------------------------------------------------------------------
  ' Управление контролами договорников
  '------------------------------------------------------------------------------------------------
  'Доступность атрибута "Тип договора"
  
'  If Obj.Attributes.Has("ATTR_CONTRACT_MAIN") Then
'    If Obj.Attributes("ATTR_CONTRACT_MAIN").Empty = False Then
'      cCtl("ATTR_CONTRACT_TYPE").ReadOnly = True
'    End If
'  End If
  isCnEdt = ThisApplication.Groups("GROUP_CONTRACTS").Users.Has(CU)
  
'  If StName = "STATUS_KD_AGREEMENT" or StName = "STATUS_CONTRACT_DRAFT" or StName = "STATUS_CONRACT_DRAFT_OLD" Then
'    Check = False
'  Else
'    Check = True
'  End If
  cCtl("EDIT_ATTR_ENDDATE_PLAN").Readonly = Not isCnEdt 'Check
  cCtl("EDIT_ATTR_STARTDATE_PLAN").Readonly = Not isCnEdt 'Check
  cCtl("EDIT_ATTR_DATA").Readonly = Not isCnEdt
  
  cCtl("ATTR_CONTRACT_INCIDENTAL").ReadOnly = Not isCnEdt
  cCtl("ATTR_CONTRACT_MAIN").ReadOnly = Not isCnEdt
  cCtl("ATTR_CONTRACT_TYPE").ReadOnly = Not ((Obj.Attributes("ATTR_CONTRACT_MAIN").Empty = True) And isCnEdt)
  cCtl("ATTR_CONTRACT_SUBJECT").ReadOnly = Not isCnEdt
'  cCtl("ATTR_CONTRACTOR").ReadOnly = Not isCnEdt
  cCtl("ATTR_DUE_DATE").ReadOnly = Not isCnEdt
  cCtl("ATTR_CURATOR").ReadOnly = Not isCnEdt
  cCtl("ATTR_SIGNER").ReadOnly = Not isCnEdt
End Sub

'========================================================================================================================
Function check2(Obj)
  check2 = True
  If Obj.Attributes("ATTR_CUSTOMER").Empty = True Or Obj.Attributes("ATTR_CONTRACTOR").Empty = True Then Exit Function
  If Obj.Attributes("ATTR_CUSTOMER").Object.Handle = Obj.Attributes("ATTR_CONTRACTOR").Object.Handle Then Exit Function
  check2 = False
End Function

'=========================================================================================================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  Obj.Permissions= SysAdminPermissions
  cClass = Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier.SysName
  ' Атрибут - "Срок оплаты"
  If Attribute.AttributeDefName = "ATTR_DUE_DATE" Then
    If cClass = "NODE_CONTRACT_EXP" Then
      If Obj.Attributes("ATTR_KD_COREDENT_TYPE") = True Then
        If Obj.Attributes("ATTR_DUE_DATE") > ThisApplication.Attributes("ATTR_DUE_DATE_FOR_SMALL_BUSINESS") Then
          msgbox "Максимальный срок оплаты для предприятий малого и среднего бизнеса - " & _
          ThisApplication.Attributes("ATTR_DUE_DATE_FOR_SMALL_BUSINESS") & " дней", vbExclamation,"ВНИМАНИЕ!"
          Cancel = True
        End If
      End If
    End If
  'Атрибут - Заказчик
  ElseIf Attribute.AttributeDefName = "ATTR_CUSTOMER" Then
    If Obj.Attributes("ATTR_CONTRACTOR").Empty = False Then
      If Not Attribute.Object Is Nothing Then 
        If Obj.Attributes("ATTR_CONTRACTOR").Object.Handle = Attribute.Object.Handle Then
          Msgbox "Выберите другого Заказчика",vbCritical, "Ошибка выбора Заказчика"
          Cancel = true
        End If
      End If
    End If
  'Атрибут - Исполнитель
  ElseIf Attribute.AttributeDefName = "ATTR_CONTRACTOR" Then
    If Obj.Attributes("ATTR_CUSTOMER").Empty = False Then
      If Not Attribute.Object Is Nothing Then 
        If Obj.Attributes("ATTR_CUSTOMER").Object.Handle = Attribute.Object.Handle Then
          Msgbox "Выберите другого Исполнителя",vbCritical, "Ошибка выбора Исполнителя"
          Cancel = true
        End If
      End If
    End If
  'Атрибут - На тендерной основе
  ElseIf Attribute.AttributeDefName = "ATTR_CONTRACT_wTENDER" Then
    Flag = Attribute.Value
    If not Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier is Nothing Then
      If Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier.SysName = "NODE_CONTRACT_EXP" Then
        Obj.Attributes("ATTR_PURCHASE_FROM_EI") = Not Flag
        Form.Controls("ATTR_TENDER").Readonly = Not Flag
      End If
    End If
    
    Obj.Attributes("ATTR_TENDER").Object = Nothing
    Call PurchaseAttrsCheck(Form,Obj)
    
  'Атрибут - Закупка у ЕП
  ElseIf Attribute.AttributeDefName = "ATTR_PURCHASE_FROM_EI" Then
    Flag = Attribute.Value
    Obj.Attributes("ATTR_CONTRACT_wTENDER") = not Flag
    Call PurchaseAttrsCheck(Form,Obj)
    Call ClearFields

  'Атрибут - Срок оплаты
  ElseIf Attribute.AttributeDefName = "ATTR_DUE_DATE" Then
    Call FullFillDatePlan(Obj)
  ElseIf Attribute.AttributeDefName = "ATTR_STARTDATE_PLAN" Then
    If Attribute.Empty = False Then
      If Obj.Attributes("ATTR_ENDDATE_PLAN").Empty = False Then
        If Attribute.Value > Obj.Attributes("ATTR_ENDDATE_PLAN") Then
          msgbox "Дата начала работ не может быть позднее даты окончания" , vbExclamation,"Ошибка даты"
          Cancel = True
        End If
      End If
    End If
  ElseIf Attribute.AttributeDefName = "ATTR_ENDDATE_PLAN" Then
    If Attribute.Empty = False Then
      If Obj.Attributes("ATTR_STARTDATE_PLAN").Empty = False Then
        If Attribute.Value < Obj.Attributes("ATTR_STARTDATE_PLAN") Then
          msgbox "Дата окончания работ не может быть ранее даты начала" , vbExclamation,"Ошибка даты"
          Cancel = True
        End If
      End If
    End If
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER" Then
    Set cClass = Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier
      If cClass.SysName = "NODE_CONTRACT_EXP" Then
'        Obj.SaveChanges
        Obj.Attributes("ATTR_LOT").Object = Nothing
        Obj.Attributes("ATTR_TENDER_OKPD2").Classifier = Nothing
      '  If Attribute.Empty = False Then
          If Not Attribute.Object Is Nothing Then
            Set TenderMethod = Attribute.Object.Attributes("ATTR_TENDER_METHOD_NAME").Classifier
            Obj.Attributes("ATTR_TENDER_METHOD_NAME").Classifier = TenderMethod
            Set ATTR_TENDER_REASON_POINT = Attribute.Object.Attributes("ATTR_TENDER_REASON_POINT").Classifier
            
            Obj.Attributes("ATTR_PURCHASE_BASIS").Classifier = ATTR_TENDER_REASON_POINT
           
            Obj.Attributes("ATTR_SMSP_EXCLUDE_CODE").Classifier = Attribute.Object.Attributes("ATTR_TENDER_SMSP_EXCLUDE_CODE").Classifier
          End If  
          Call PurchaseAttrsCheck(Form,Obj)
          Call ReasonPointEnable3(Obj,Form)
        End If 
   ' End If
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_METHOD_NAME" Then
    Call ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB", "ReasonPointEnable",Obj,Form)
    Call ReasonPointEnable2(Obj,Form)
  ElseIf Attribute.AttributeDefName = "ATTR_LOT" Then
    If Attribute.Empty = False Then 
      Set oLot = Attribute.Object
      Set cls = oLot.Attributes("ATTR_TENDER_OKPD2").Classifier
    Else
      Set cls = Nothing
    End If
    ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", Obj, "ATTR_TENDER_OKPD2", cls, True
  ElseIf Attribute.AttributeDefName = "ATTR_CURATOR" Then
    Set Dict = ThisApplication.Dictionary(Obj.GUID)
    If Dict.Exists("ATTR_CURATOR") = False Then
      Dict.Add "ATTR_CURATOR", True
    Else
      Dict.Item("ATTR_CURATOR") = True
    End If
  End If
End Sub

Sub SetTendrBlock(Form,Obj)
  Set cu = ThisApplication.CurrentUser
  set cCtl=Form.controls 
'  If cu.Groups.Has("GROUP_TENDER") Then
    ' Доступность блока управления закупками
    'На тендерной основе
    Call PurchaseAttrsCheck(Form,Obj)
    'Доступность кнопки "Создать закупку
    Call PurchaseBtnCheck(Form,Obj)
    'Доступность атрибутов ЕИС
    Call EISatrCheck(Form,Obj)
    Call ReasonPointEnable3(Obj,Form)
'  End If
End Sub

'Событие - Изменен атрибут
Sub PurchaseAttrsCheck(Form,Obj)
  Set cls = Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier
  If cls Is Nothing Then Exit Sub
  Flag = Not Obj.Attributes("ATTR_TENDER").Object Is Nothing
  'Form.Controls("ATTR_TENDER").Enabled = Obj.Attributes("ATTR_CONTRACT_wTENDER").Value
  If Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier.SysName = "NODE_CONTRACT_PRO" Then
    Form.Controls("ATTR_TENDER").ReadOnly = Not Obj.Attributes("ATTR_CONTRACT_wTENDER").Value
    sListAttrs = "ATTR_TENDER_METHOD_NAME,ATTR_PURCHASE_BASIS,ATTR_LOT,ATTR_EIS_NUM,ATTR_EIS_PUBLISH,ATTR_FULFILLDATE_PLAN," &_
                  "ATTR_EIS_PUBLISH_FACT,ATTR_FULFILLDATE_FACT,ATTR_CONTRACT_FULFILL_DOCBASE,CMD_CONTRACT_TENDER_EDIT"
    Call SetControlVisible(Form,sListAttrs,False)
  Else
  '========== Реализовать блокировку по кнопке и разблокировку при выходе
    Form.Controls("ATTR_TENDER").ReadOnly = False
    Form.Controls("ATTR_TENDER_METHOD_NAME").ReadOnly = Flag
  End If
End Sub

Sub ReasonPointEnable2(Obj,Form)
  ThisScript.SysAdminModeOn
  AttrName = "ATTR_TENDER_METHOD_NAME"
  Check = True

  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      If StrComp(Obj.Attributes(AttrName).Value, "Закупка у единственного поставщика",vbTextCompare) = 0 Then
        Check = False
      End If
    End If
  End If
  If Not Obj.Attributes("ATTR_TENDER").Object Is Nothing Then Check = True
  If Check Then
    Obj.Attributes("ATTR_PURCHASE_BASIS").Classifier = Nothing
    Obj.Attributes("ATTR_TENDER_OKPD2").Classifier = Nothing
  End If
  Form.Controls("ATTR_PURCHASE_BASIS").ReadOnly = (Check)
  Form.Controls("ATTR_TENDER_OKPD2").ReadOnly = (Check)
End Sub

Sub ReasonPointEnable3(Obj,Form)
  ThisScript.SysAdminModeOn
  AttrName = "ATTR_TENDER_METHOD_NAME"
  Check = True
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      If StrComp(Obj.Attributes(AttrName).Value, "Закупка у единственного поставщика",vbTextCompare) = 0 Then
        Check = False
      End If
    End If
  End If
  If Not Obj.Attributes("ATTR_TENDER").Object Is Nothing Then 
    check1 = True 'закупка задана
  Else
    check1 = False 'закупка не задана
  End If

  Form.Controls("ATTR_PURCHASE_BASIS").ReadOnly = (Check) Or check1
  Form.Controls("ATTR_SMSP_EXCLUDE_CODE").ReadOnly = check1
  Form.Controls("ATTR_TENDER_OKPD2").ReadOnly = check1
  Form.Controls("ATTR_LOT").ReadOnly = Not check1
End Sub

Sub SetButtonsEnabled(Obj)
  ThisScript.SysAdminModeOn
  set cCtl = ThisForm.controls
  Set CU = ThisApplication.CurrentUser
  isLock = ObjectIsLockedByUser(Obj)
  
  OldContr = CheckOldContract(Obj)
  isAuth = IsAuthor(Obj,CU)
  isSign = IsSigner(Obj,CU)
  isCrtr = IsCurator(Obj,CU)
  isExec = ThisApplication.ExecuteScript("CMD_KD_USER_PERMISSIONS", "isInic",CU, Obj)
  isSignedByContr = IsSignedByContractor(Obj)
  'isRgst = isRegistered(Obj) 'Obj.Attributes("ATTR_REGISTERED").Value
  isIssuer = ThisApplication.Groups("GROUP_CONTRACTS_ISSUE").Users.Has(CU)
  '--------------------------------------------------------
  isEdit = Obj.StatusName = "STATUS_CONTRACT_DRAFT"
  isAgreed = Obj.StatusName = "STATUS_CONTRACT_AGREED"
  isSgnd = Obj.StatusName = "STATUS_CONTRACT_SIGNED"
  isSignin = Obj.StatusName = "STATUS_CONTRACT_FOR_SIGNING"
  '--------------------------------------------------------
  'Доступность кнопки "Зарегистрировать"
  cCtl("BUTTON_REGISTRATION").Enabled = CheckBtnReg(Obj)' And Not isRgst
  
  ' не показывать, если стоит признак подписано контрагентом
  cCtl("BTN_CONTRACT_SIGNED_BY_CONTRACTOR").Enabled = (Not isSignedByContr) And _
                                            (isSgnd or isAgreed or _
                                             isEdit)  And (isAuth Or isSign)
  cCtl("BTN_CONTRACT_SEND_TO_SIGN").Enabled = (isAgreed)  And isAuth
  
  cCtl("BTN_CONTRACT_SIGN").Enabled = (isSignin)  And (isSign or isIssuer) 
  cCtl("BTN_CONTRACT_BACK_TO_WORK").Enabled = ((isSignin) And (isSign or isIssuer)) or _
                                              ((isSgnd) And (isSign or isIssuer) And not isSignedByContr)
  
  cCtl("BTN_CONTRACT_PLAY_PAUSE").Enabled = _
            (Obj.StatusName = "STATUS_CONTRACT_COMPLETION" or Obj.StatusName = "STATUS_CONTRACT_PAUSED") And isCrtr
  
  
  ' Кнопка - На согласование
  cCtl("BTN_TO_AGREE").Enabled = isEdit And (isAuth or isExec) And not isLock
  cCtl("BTN_TO_AGREE").Visible = isEdit And (isAuth or isExec)

' Доступ к кнопке только для сотрудников группы Управление договорами или оформление договора (Протокол Красноярск) 
'  cCtl("BTN_OUT_DOC_PREPARE").Enabled = True
  If isIssuer = True and OldContr = False Then
    cCtl("BTN_OUT_DOC_PREPARE").Enabled = True
  Else
    cCtl("BTN_OUT_DOC_PREPARE").Enabled = False
  End If
  
  cCtl("CMD_CONTACT_PERSON_ADD").Enabled = isEdit And isAuth And not isLock
  If OldContr = True Then cCtl("CMD_CONTACT_PERSON_ADD").Enabled = True
  cCtl("BTN_SAVE").Enabled = (ThisObject.Permissions.Edit = True) And not isLock

  'Кнопки примечаний
  cCtl("CMD_ADD_COMMENT").Enabled = not isLock
  cCtl("CMD_EDIT_COMMENT").Enabled = not isLock
  
  Call ContractPlayPause(ThisForm,Obj)
End Sub

Sub ContractPlayPause(Form,Obj)
  set cCtl=Form.controls
  Set btnPlay = cCtl("BTN_CONTRACT_PLAY_PAUSE").ActiveX
  If Obj.StatusName = "STATUS_CONTRACT_PAUSED" Then
    btnPlay.Image = ThisApplication.Icons.SystemIcon(245)
  ElseIf Obj.StatusName = "STATUS_CONTRACT_COMPLETION" Then
    btnPlay.Image = ThisApplication.Icons.SystemIcon(253)
  Else
    cCtl("BTN_CONTRACT_PLAY_PAUSE").visible = False
  End If
End Sub

' Выбор Заказчика
Sub CMD_CUSTOMER_ADD_OnClick()
  Set o = ThisObject
  Set oCorr = ThisApplication.ExecuteScript("CMD_S_DLL", "GetCompany")
  If oCorr is Nothing Then Exit Sub
  Set Obj = oCorr.Objects.Item(oCorr.CellValue(0,0))
  If o.Attributes("ATTR_CONTRACTOR").Empty = False Then
    If o.Attributes("ATTR_CONTRACTOR").Object.Handle = Obj.Handle Then
      msgbox "Выберите другого Заказчика",vbCritical, "Ошибка выбора Заказчика"
      Exit Sub
    Else
      o.Attributes("ATTR_CUSTOMER").Object = Obj 
    End If
  Else
    o.Attributes("ATTR_CUSTOMER").Object = Obj  
  End If
  
  Call ContractorBusTypeCheck(o)
End Sub

' Выбор исполнителя
Sub CMD_CONTRACTOR_ADD_OnClick()

  Set o = ThisObject
  Set oCorr = ThisApplication.ExecuteScript("CMD_S_DLL", "GetCompany")
  If oCorr is Nothing Then Exit Sub
  Set Obj = oCorr.Objects.Item(oCorr.CellValue(0,0))
  If o.Attributes("ATTR_CUSTOMER").Empty = False Then
    If o.Attributes("ATTR_CUSTOMER").Object.Handle = Obj.Handle Then
      msgbox "Выберите другого Исполнителя",vbCritical, "Ошибка выбора Исполнителя"
      Exit Sub
    Else
      o.Attributes("ATTR_CONTRACTOR").Object = Obj 
    End If
  Else
    o.Attributes("ATTR_CONTRACTOR").Object = Obj  
  End If
  
  Call ContractorBusTypeCheck(o)
End Sub

'Процедура копирования значения атрибута "Малое/среднее предпринимательство" с Исполнителя
Sub ContractorBusTypeCheck(Obj)
  ThisScript.SysAdminModeOn

  Set org = GetContractContractor(Obj)
  If org Is Nothing Then Exit Sub
  Call AttrsSyncBetweenObjs(org,Obj,"ATTR_KD_COREDENT_TYPE,ATTR_TENDER_SMSP_TYPE")
  
'  AttrName = "ATTR_KD_COREDENT_TYPE"
'  Set Contractor = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "ObjectLinkGet", Obj,"ATTR_CONTRACTOR")
'  Set Customer = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "ObjectLinkGet", Obj,"ATTR_CUSTOMER")
'  Set MyCompany = ThisApplication.Attributes("ATTR_MY_COMPANY").Object
  
'  If not Customer is Nothing Then
'    If Customer.handle <> MyCompany.Handle Then
'      If Customer.Attributes.Has(AttrName) Then
'        If Obj.Attributes(AttrName).Value <> Customer.Attributes(AttrName).Value Then
'          Obj.Attributes(AttrName).Value = Customer.Attributes(AttrName).Value
'          Obj.Attributes("ATTR_TENDER_SMSP_TYPE").Value = Customer.Attributes("ATTR_TENDER_SMSP_TYPE").Value
'        End If
'      Else
'        Obj.Attributes(AttrName).Value = False
'      End If
'    End If
'  Else
'    Obj.Attributes(AttrName).Value = False
'  End If
'  If not Contractor is Nothing Then
'    If Contractor.handle <> MyCompany.Handle Then
'      If Contractor.Attributes.Has(AttrName) Then
'        If Obj.Attributes(AttrName).Value <> Contractor.Attributes(AttrName).Value Then
'          Obj.Attributes(AttrName).Value = Contractor.Attributes(AttrName).Value
'          Obj.Attributes("ATTR_TENDER_SMSP_TYPE").Value = Contractor.Attributes("ATTR_TENDER_SMSP_TYPE").Value
'        End If
'      Else
'        Obj.Attributes(AttrName).Value = False
'      End If
'    End If
'  Else
'    Obj.Attributes(AttrName).Value = False
'  End If
  
  Call DueCheck (Obj)
  Call SetCoredentControls(ThisForm,Obj)
End Sub

Sub DueCheck (Obj)
  Set contrClass = Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier
  If contrClass Is Nothing Then Exit Sub
  cClass = Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier.SysName
  maxDue = ThisApplication.Attributes("ATTR_DUE_DATE_FOR_SMALL_BUSINESS").Value
    If cClass = "NODE_CONTRACT_EXP" Then
      If Obj.Attributes("ATTR_KD_COREDENT_TYPE") = True Then
        If Obj.Attributes("ATTR_DUE_DATE") > maxDue Then
          msgbox "Срок оплаты превышает допустимое значение!" & Chr(13) & _
          "Срок оплаты будет установлен в " & maxDue & " дней", vbExclamation,"ВНИМАНИЕ!"
          Obj.Attributes("ATTR_DUE_DATE") = maxDue
        End If
        Set clf = ThisApplication.Classifiers("NODE_DAY_TYPE").Classifiers.Find("Календарных дней")
        If Not clf Is Nothing Then Obj.Attributes("ATTR_DAY_TYPE").Classifier = clf
      End If
    End If
End Sub

'Событие - Выделен файл в выборке
Sub QUERY_FILES_IN_DOC_Selected(iItem, action)
  Call QueryFileSelect(ThisForm,iItem,Action)
'  If iItem <> -1 and Action = 2 Then
'    ThisForm.Controls("BTN_DELETE_FILES").Enabled = True
'  Else
'    ThisForm.Controls("BTN_DELETE_FILES").Enabled = False
'  End If
  'Call ShowFile(iItem)
End Sub
' Создать Заказчика
Sub CMD_CUSTOMER_CREATE_OnClick()
  Set NewOrg = CreateOrg()
  If Not NewOrg Is Nothing Then
    Set Obj = ThisObject
    aDef = "ATTR_CUSTOMER"
    Call ThisApplication.ExecuteScript("CMD_DLL", "SetAttr", Obj,aDef,NewOrg)
    Call ContractorBusTypeCheck(Obj)
  End If
End Sub

' Создать Исполнителя
Sub CMD_CONTRACTOR_CREATE_OnClick()
  Set NewOrg = CreateOrg()
  If Not NewOrg Is Nothing Then
    Set Obj = ThisObject
    aDef = "ATTR_CONTRACTOR"
    Call ThisApplication.ExecuteScript("CMD_DLL", "SetAttr", Obj,aDef,NewOrg)
    Call ContractorBusTypeCheck(Obj)
  End If
End Sub

'Кнопка - Выбрать контактное лицо
Sub CMD_CONTACT_PERSON_ADD_OnClick()
  Set Obj = ThisObject
  Set CorObj = Nothing
  Set MyComp = Nothing
  Set Query = ThisApplication.Queries("QUERY_CONTACT_PERSON_FOR_CONTRACT")
  
  'Определяем корреспондента
  If ThisApplication.Attributes.Has("ATTR_MY_COMPANY") Then
    If ThisApplication.Attributes("ATTR_MY_COMPANY").Empty = False Then
      If not ThisApplication.Attributes("ATTR_MY_COMPANY").Object is Nothing Then
        Set MyComp = ThisApplication.Attributes("ATTR_MY_COMPANY").Object
      End If
    End If
  End If
  Set Contractor = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "ObjectLinkGet", Obj,"ATTR_CONTRACTOR")
  Set Customer = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "ObjectLinkGet", Obj,"ATTR_CUSTOMER")
  If MyComp is Nothing Then Exit Sub
  If not Customer is Nothing Then
    If Customer.Guid <> MyComp.Guid Then Set CorObj = Customer
  End If
  If MyComp is Nothing and not Contractor is Nothing Then
    If Contractor.Guid <> MyComp.Guid Then Set CorObj = Contractor
  End If
  
  If CorObj is Nothing Then 
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1612, Obj.Description
    Exit Sub
  End If

  Query.Parameter("CORRESPONDENT") = CorObj
  Set Objects = Query.Objects
  If Objects.Count = 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1610, CorObj.Description
    Exit Sub
  End If
  
  Set us = SelectObjectDialog (Query,"Выберите только одно контактное лицо:")
  If us is Nothing Then Exit Sub
  set u =  CorObj.Objects.Item(us.CellValue(0,0))
  'Call ThisApplication.ExecuteScript("CMD_DLL", "SetAttr", Obj,"ATTR_CORDENT_USER",u)
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetAttr", Obj,"ATTR_CONTACT_PERSON",u)
  txt = u.Description
  If u.Attributes.Has("ATTR_CORR_ADD_POSITION") Then
    If u.Attributes("ATTR_CORR_ADD_POSITION").Empty = False Then
      txt = txt & ", " & u.attributes("ATTR_CORR_ADD_POSITION").Value
    End If
  End If
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetAttr", Obj,"ATTR_CONTACT_PERSON_STR",txt)
End Sub

'Кнопка - "Зарегистрировать"
Sub BUTTON_REGISTRATION_OnClick()
  Set Obj = ThisObject
  Set CU = ThisApplication.CurrentUser
  OldContr = CheckOldContract(Obj)
  Obj.Permissions = SysAdminPermissions
  'Добавляем атрибут к договору
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
        If OldContr = False Then Obj.Update
      End If
    End If
    Dict.RemoveAll
  End If
End Sub

'Процедура управления доступностью и видимостью кнопки "Создать закупку"
Sub PurchaseBtnCheck(Form,Obj)
  Check = False
'  If Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier.SysName = "NODE_CONTRACT_PRO" Then
    Set User = ThisApplication.CurrentUser
    If User.Groups.Has("GROUP_TENDER_INICIATORS") Or _
        User.Groups.Has("GROUP_TENDER")    Then
      
    '  If Obj.StatusName = "STATUS_CONTRACT_SIGNED" or _
     ' Obj.StatusName = "STATUS_CONTRACT_COMPLETION" Then
        'If Obj.Attributes("ATTR_CONTRACT_wTENDER") = True Then
          'If Obj.Attributes("ATTR_TENDER").Object Is Nothing Then
            Check = True
          'End If
        'End If
      'End If
    End If
'  End If
'  Form.Controls("BUTTON_PURCHASE_CREATE").Visible = Check
  Form.Controls("BUTTON_PURCHASE_CREATE").Enabled = Check
End Sub

'Процедура управления доступностью атрибутов ЕИС
Sub EISatrCheck(Form,Obj)
  isStarted = Obj.StatusName = "STATUS_CONTRACT_COMPLETION"
  isFinish = Obj.StatusName = "STATUS_CONTRACT_CLOSED"
  isEdit = Obj.StatusName = "STATUS_EDIT"
  isExec = ThisApplication.CurrentUser.Groups.Has("GROUP_TENDER") = True
  
  Form.Controls("CMD_CONTRACT_TENDER_EDIT").Enabled = isExec And not isEdit
  Form.Controls("ATTR_EIS_NUM").ReadOnly = Not ((isStarted And isExec) or (isEdit And isExec))
  Form.Controls("ATTR_EIS_PUBLISH").ReadOnly = Not ((isStarted And isExec) or (isEdit And isExec))
  Form.Controls("ATTR_EIS_PUBLISH_FACT").ReadOnly = Not ((isFinish And isExec) or (isEdit And isExec))
  Form.Controls("ATTR_FULFILLDATE_FACT").ReadOnly = Not ((isFinish And isExec) or (isEdit And isExec))
  Form.Controls("ATTR_CONTRACT_FULFILL_DOCBASE").ReadOnly = Not ((isFinish And isExec) or (isEdit And isExec))
End Sub

'Процедура изменения класса договора
Sub ContractClassChange(Obj,sType)
  Set MyComp = Nothing
  If ThisApplication.Attributes.Has("ATTR_MY_COMPANY") Then
    If ThisApplication.Attributes("ATTR_MY_COMPANY").Empty = False Then
      If not ThisApplication.Attributes("ATTR_MY_COMPANY").Object is Nothing Then
        Set MyComp = ThisApplication.Attributes("ATTR_MY_COMPANY").Object
      End If
    End If
  End If
  Set Contractor = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "ObjectLinkGet", Obj,"ATTR_CONTRACTOR")
  Set Customer = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "ObjectLinkGet", Obj,"ATTR_CUSTOMER")
  If MyComp is Nothing Then Exit Sub
  If not Customer is Nothing and not Contractor is Nothing Then
    If Customer.Guid = Contractor.Guid Then Exit Sub
    If Customer.Guid <> MyComp.Guid and Contractor.Guid <> MyComp.Guid Then Exit Sub
  End If
  
  Set Clfs = ThisApplication.Classifiers("NODE_CONTRACT_CLASS")
  If sType = 1 Then
    If not Contractor is Nothing Then
      If Contractor.Guid = MyComp.Guid Then
        Set Clf = Clfs.Classifiers.Find("+")
      Else
        Set Clf = Clfs.Classifiers.Find("-")
      End If
    End If
  ElseIf sType = 2 Then
    If not Customer is Nothing Then
      If Customer.Guid = MyComp.Guid Then
        Set Clf = Clfs.Classifiers.Find("-")
      Else
        Set Clf = Clfs.Classifiers.Find("+")
      End If
    End If
  End If
  If not Clf is Nothing Then
    Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier = Clf
  End If
End Sub

'Процедура заполнения атрибута "Срок исполнения договора (план)"
Sub FullFillDatePlan(Obj)
  a = ""
  b = ""
  If Obj.Attributes.Has("ATTR_ENDDATE_PLAN") Then
    a = Obj.Attributes("ATTR_ENDDATE_PLAN").Value
  End If
  If Obj.Attributes.Has("ATTR_DUE_DATE") Then
    b = Obj.Attributes("ATTR_DUE_DATE").Value
  End If
  Obj.Attributes("ATTR_FULFILLDATE_PLAN").Value = a + b
End Sub

' Кнопка - На подписание
Sub BTN_CONTRACT_SEND_TO_SIGN_OnClick()
  Res = ThisApplication.ExecuteScript("CMD_CONTRACT_SEND_TO_SIGN","Main",ThisObject)
  If Res Then
    ThisObject.Savechanges(0)
    ThisForm.Close True
  End If
End Sub

' Кнопка - Подписать
Sub BTN_CONTRACT_SIGN_OnClick()
  Res = ThisApplication.ExecuteScript("CMD_CONTRACT_SIGN","Main",ThisObject)
  
  flag = ThisApplication.ExecuteScript("CMD_DLL_CONTRACTS","IsSignedByContractor",ThisObject)
  If flag = true Then
    Res = ThisApplication.ExecuteScript("CMD_CONTRACT_TO_COMPLETION","Main",ThisObject)
  End If
  If Res Then
    ThisObject.Savechanges(0)
    ThisForm.Close True
  End If
End Sub

' Кнопка - На доработку
Sub BTN_CONTRACT_BACK_TO_WORK_OnClick()
  Res = ThisApplication.ExecuteScript("CMD_CONTRACT_BACK_TO_WORK","Main",ThisObject)
  If Res Then
    ThisObject.Savechanges(0)
    ThisForm.Close True
  End If
End Sub

Sub BTN_CONTRACT_PLAY_PAUSE_OnClick()
  Set Obj = ThisObject
  If Obj.StatusName = "STATUS_CONTRACT_PAUSED" Then 
    Call ContractPlay(Obj)
  ElseIf Obj.StatusName = "STATUS_CONTRACT_COMPLETION" Then 
    Call ContractPause(Obj)
  End If
End Sub

Sub ContractPlay(Obj)
  Res = ThisApplication.ExecuteScript("CMD_CONTRACT_TO_PLAY","Main",Obj)
  If Res Then
    ThisObject.Savechanges(0)
    ThisForm.Close True
  End If
End Sub

Sub ContractPause(Obj)
  Res = ThisApplication.ExecuteScript("CMD_CONTRACT_TO_PAUSE","Main",Obj)
  If Res Then
    ThisObject.Savechanges(0)
    ThisForm.Close True
  End If
End Sub

Sub bViewFile_OnClick()
  Set cu = ThisApplication.CurrentUser
  Set Obj = ThisObject
  if Obj.Permissions.ViewFiles=tdmAllow then
    if Obj.Permissions.EditFiles=tdmallow then
      Call BlockFilesOpenFile(ThisForm,ThisObject,False)
      'Call ThisApplication.ExecuteCommand ("CMD_VIEW",ThisObject)
    Else
      msgbox "У вас нет прав на просмотр файла!"
    End If
  Else
      msgbox "У вас нет прав на просмотр файла!"
  End If
  
End Sub

' Кнопка Подписано контрагентом
Sub BTN_CONTRACT_SIGNED_BY_CONTRACTOR_OnClick()
  ThisScript.SysAdminModeOn
  If SignedByContractor(ThisObject) = False Then Exit Sub
  Res = ThisApplication.ExecuteScript("CMD_CONTRACT_TO_COMPLETION","Main",ThisObject)
  If Res Then
    ThisObject.Savechanges(0)
    ThisForm.Close True
  End If
End Sub

Sub SetClassDependentControls (cls)
  If cls Is Nothing Then Exit Sub
  Set CU = ThisApplication.CurrentUser
  isCnEdt = ThisApplication.Groups("GROUP_CONTRACTS").Users.Has(CU)
  
''  IsProfitContract(Obj)
''  IsProfitContract = ContractClass(Obj) = "NODE_CONTRACT_PRO"
''End Function
isExpC = cls.SysName = "NODE_CONTRACT_EXP"
isProC = not isExpC

  Set cCtrl = ThisForm.Controls
'      Case "NODE_CONTRACT_EXP" ' Расходный
          cCtrl("ATTR_CUSTOMER").ReadOnly= not (isProC And isCnEdt And ThisObject.Attributes("ATTR_CUSTOMER").empty = True) 'not isCnEdt And isExpC
          cCtrl("CMD_CUSTOMER_ADD").Enabled= isProC And isCnEdt
          cCtrl("CMD_CUSTOMER_CREATE").Enabled= isProC And isCnEdt
          sListAttrs = "ATTR_CONTRACT_wTENDER"
          Call SetControlVisible(ThisForm,sListAttrs,isProC And not isCnEdt)
'                     
'    Case "NODE_CONTRACT_PRO" ' Доходный
          cCtrl("ATTR_CONTRACTOR").ReadOnly= not (not isProC And isCnEdt And ThisObject.Attributes("ATTR_CONTRACTOR").empty = True) 'not isCnEdt And isProC
          cCtrl("CMD_CONTRACTOR_ADD").Enabled= Not isProC And isCnEdt
          cCtrl("CMD_CONTRACTOR_CREATE").Enabled= Not isProC And isCnEdt
          sListAttrs = "ATTR_CONTRACT_INCIDENTAL,ATTR_TENDER_OKPD2,ATTR_PURCHASE_BASIS,ATTR_PURCHASE_FROM_EI," & _
                        "ATTR_SMSP_EXCLUDE_CODE,ATTR_TENDER_OKPD2,ATTR_CONTRACT_MAIN"
          Call SetControlVisible(ThisForm,sListAttrs,Not isProC And not isCnEdt)
  
''  Select Case cls.SysName
''    Case "NODE_CONTRACT_EXP" ' Расходный
''          cCtrl("ATTR_CUSTOMER").ReadOnly= not isCnEdt
''          cCtrl("CMD_CUSTOMER_ADD").Enabled= False
''          cCtrl("CMD_CUSTOMER_CREATE").Enabled= False
''          sListAttrs = "ATTR_CONTRACT_wTENDER"
''          Call SetControlVisible(ThisForm,sListAttrs,False)
''                     
''    Case "NODE_CONTRACT_PRO" ' Доходный
''          cCtrl("ATTR_CONTRACTOR").ReadOnly= not isCnEdt
''          cCtrl("CMD_CONTRACTOR_ADD").Enabled= False
''          cCtrl("CMD_CONTRACTOR_CREATE").Enabled= False
''          sListAttrs = "ATTR_CONTRACT_INCIDENTAL,ATTR_TENDER_OKPD2,ATTR_PURCHASE_BASIS,ATTR_PURCHASE_FROM_EI," & _
''                        "ATTR_SMSP_EXCLUDE_CODE,ATTR_TENDER_OKPD2,ATTR_CONTRACT_MAIN"
''          Call SetControlVisible(ThisForm,sListAttrs,False)
''  End Select
'  Select Case cls.SysName
'    Case "NODE_CONTRACT_EXP" ' Расходный
'          cCtrl("ATTR_CUSTOMER").ReadOnly= True
'          cCtrl("CMD_CUSTOMER_ADD").Enabled= False
'          cCtrl("CMD_CUSTOMER_CREATE").Enabled= False
'          sListAttrs = "ATTR_CONTRACT_wTENDER"
'          Call SetControlVisible(ThisForm,sListAttrs,False)
'                     
'    Case "NODE_CONTRACT_PRO" ' Доходный
'          cCtrl("ATTR_CONTRACTOR").ReadOnly= True
'          cCtrl("CMD_CONTRACTOR_ADD").Enabled= False
'          cCtrl("CMD_CONTRACTOR_CREATE").Enabled= False
'          sListAttrs = "ATTR_CONTRACT_INCIDENTAL,ATTR_TENDER_OKPD2,ATTR_PURCHASE_BASIS,ATTR_PURCHASE_FROM_EI," & _
'                        "ATTR_SMSP_EXCLUDE_CODE,ATTR_TENDER_OKPD2,ATTR_CONTRACT_MAIN"
'          Call SetControlVisible(ThisForm,sListAttrs,False)
'  End Select
End Sub

Sub ClearFields
  If ThisObject.Attributes("ATTR_CONTRACT_wTENDER") = True Then
    ThisObject.Attributes("ATTR_PURCHASE_BASIS").Classifier = nothing
  Else
    ThisObject.Attributes("ATTR_TENDER").Object = nothing
  End If
End Sub

Sub ATTR_CUSTOMER_BeforeAutoComplete(Text)
  Set ctrl = ThisForm.Controls("ATTR_CUSTOMER").ActiveX
  Set query = ThisApplication.Queries("QUERY_S_ENTERPRIZES")

  If Len(text)>2 then
    ctrl.ComboItems = query.Objects
  End If
End Sub

Sub ATTR_CONTRACTOR_BeforeAutoComplete(Text)
  Set ctrl = ThisForm.Controls("ATTR_CONTRACTOR").ActiveX
  Set query = ThisApplication.Queries("QUERY_S_ENTERPRIZES")

  If Len(text)>2 then
    ctrl.ComboItems = query.Objects
  End If
End Sub

Sub BUTTON_PURCHASE_CREATE_OnClick()
  Set tender = ThisApplication.ExecuteScript("CMD_PURCHASE_CREATE","Main",ThisObject)
  If tender Is Nothing Then Exit Sub
  ThisForm.Controls("ATTR_TENDER").Value = tender ' Заполняем закупкой для быстрого отображения
  ThisObject.Permissions = SysAdminPermissions
  ThisObject.Attributes("ATTR_TENDER").Object = tender
'  guid = ThisObject.GUID
'  Set dict = ThisApplication.Dictionary(guid)
'  Set Dict = ThisObject.Dictionary
'  Dict.Add "ATTR_TENDER", True

  For Each Child in tender.Objects ' Заполняем первым лотом
    If Child.ObjectDefName = "OBJECT_PURCHASE_LOT" Then
     If Child.Attributes.Has("ATTR_TENDER_LOT_NAME") Then
      If Child.Attributes("ATTR_TENDER_LOT_NAME").Empty = False Then
       ThisForm.Controls("ATTR_LOT").Value = Child
       exit for
      End If
     End If
    End If
  next
  ThisObject.SaveChanges 0
End Sub

'Sub BTN_TO_AGREE_OnClick()
'  ThisForm.Close True
'  
'  Set dict = ThisApplication.Dictionary(ThisObject.GUID & "ActiveForm")
'  
'  If Not dict.Exists("FORM_KD_DOC_AGREE") Then 
'    dict.Add "FORM_KD_DOC_AGREE", True
'  End If 
'  
'  Call ThisApplication.ExecuteScript ("CMD_DOC_SENT_TO_AGREED", "Run", ThisObject)
'End Sub


' Кнопка - На согласование
Sub BTN_TO_AGREE_OnClick()
  ThisForm.Close True
  
  ' Запоминаем, какую форму нужно активировать при переоткрытии диалога свойств
  Set dict = ThisObject.Dictionary
  If Not dict.Exists("FormActive") Then 
    dict.Add "FormActive", "FORM_KD_DOC_AGREE"
  End If
  
  Call ThisApplication.ExecuteScript ("CMD_DOC_SENT_TO_AGREED", "Run", ThisObject)
End Sub


Sub EDIT_ATTR_STARTDATE_PLAN_Modified()
  Set Obj = ThisObject
  
  StartData = ""
  EndData = ""
  aData = ""
  If ThisForm.Controls("EDIT_ATTR_STARTDATE_PLAN").Value <> "" Then
    aData = CDate(ThisForm.Controls("EDIT_ATTR_STARTDATE_PLAN").Value)
  End If
  
  
  StartData = Obj.Attributes("ATTR_STARTDATE_PLAN").Value
  EndData = Obj.Attributes("ATTR_ENDDATE_PLAN").Value
  If EndData <> vbNullString And aData <> vbNullString Then
        If aData > EndData Then
          msgbox "Дата начала работ не может быть позднее даты окончания: " & EndData , vbExclamation,"Ошибка даты"
          ThisForm.Controls("EDIT_ATTR_STARTDATE_PLAN").Value = StartData
          Exit Sub
        End If
  End If
  If ThisForm.Controls("EDIT_ATTR_STARTDATE_PLAN").Value <> "" Then
    Obj.Attributes("ATTR_STARTDATE_PLAN").Value = FormatDateTime(ThisForm.Controls("EDIT_ATTR_STARTDATE_PLAN").Value, vbShortDate)
  End If
  guid = Obj.GUID
  Set dict = ThisApplication.Dictionary(guid)
  If Not dict Is Nothing Then
    If dict.Exists("ATTR_STARTDATE_PLAN") Then
      dict.Remove("ATTR_STARTDATE_PLAN")
    End If
  End If
  dict.Add "ATTR_STARTDATE_PLAN", aData
End Sub

Sub EDIT_ATTR_ENDDATE_PLAN_Modified()
  Set Obj = ThisObject
  StartData = ""
  EndData = ""
  aData = ""
  If ThisForm.Controls("EDIT_ATTR_ENDDATE_PLAN").Value <> "" Then
    aData = CDate(ThisForm.Controls("EDIT_ATTR_ENDDATE_PLAN").Value)
  End If
  
  StartData = Obj.Attributes("ATTR_STARTDATE_PLAN").Value
  EndData = Obj.Attributes("ATTR_ENDDATE_PLAN").Value
  If StartData <> vbNullString And aData <> vbNullString Then
        If aData < StartData Then
          msgbox "Дата окончания работ не может быть ранее даты начала: " & StartData , vbExclamation,"Ошибка даты"
          ThisForm.Controls("EDIT_ATTR_ENDDATE_PLAN").Value = EndData
          Exit Sub
        End If
  End If
  
  If ThisForm.Controls("EDIT_ATTR_ENDDATE_PLAN").Value <> "" Then
    Obj.Attributes("ATTR_ENDDATE_PLAN").Value = FormatDateTime(ThisForm.Controls("EDIT_ATTR_ENDDATE_PLAN").Value, vbShortDate)
  End If
  guid = Obj.GUID
  Set dict = ThisApplication.Dictionary(guid)
  If Not dict Is Nothing Then
    If dict.Exists("ATTR_ENDDATE_PLAN") Then
      dict.Remove("ATTR_ENDDATE_PLAN")
    End If
  End If
  dict.Add "ATTR_ENDDATE_PLAN", aData
  call FullFillDatePlan(Obj)
End Sub

Sub ATTR_TENDER_ButtonClick(Cancel)
  If ThisForm.Controls("ATTR_TENDER").ReadOnly = True Then Exit Sub
  isPro = IsProfitContract(ThisObject)
  set dlg = ThisApplication.Dialogs.SelectDlg
  set q = ThisApplication.Queries("QUERY_TENDERS_FOR_CONTRACT")
  If isPro = True Then 
    q.Parameter("PARAM0") = "='OBJECT_PURCHASE_OUTSIDE'"
  Else
    q.Parameter("PARAM0") = "='OBJECT_TENDER_INSIDE'"
  End If
  dlg.SelectFrom = q.Objects
  RetVal = dlg.Show
  If (RetVal<>TRUE) Or (dlg.Objects.Count=0) Then 
    Cancel = True 
    Exit Sub
  End If
  ThisForm.Controls("ATTR_TENDER").Value = dlg.Objects(0)
  cancel = True
End Sub

Sub ATTR_TENDER_BeforeAutoComplete(Text)
  If Len(text) > 0 Then
    isPro = IsProfitContract(ThisObject)
  
    Set q = ThisApplication.Queries("QUERY_TENDERS_FOR_CONTRACT")
    If isPro = True Then 
      q.Parameter("PARAM0") = "='OBJECT_PURCHASE_OUTSIDE'"
    Else
      q.Parameter("PARAM0") = "='OBJECT_TENDER_INSIDE'"
    End If
      ThisForm.Controls("ATTR_TENDER").ActiveX.comboitems = q.Objects
  End If
End Sub

Sub ATTR_CONTRACT_FULFILL_DOCBASE_ButtonClick(Cancel)
  If ThisForm.Controls("ATTR_CONTRACT_FULFILL_DOCBASE").ReadOnly = True Then 
    Cancel = True 
    Exit Sub
  End If
  
  Set dlg = thisApplication.Dialogs.SearchObjectDlg
  RetVal = dlg.Show
  If (RetVal<>TRUE) Or (dlg.Objects.Count=0) Then 
    Cancel = True 
    Exit Sub
  End If
  ThisForm.Controls("ATTR_CONTRACT_FULFILL_DOCBASE").Value = dlg.Objects(0)
  Cancel = True
End Sub

'Функция проверки договора - старый или нет
Function CheckOldContract(Obj)
  CheckOldContract = False
  AttrName = "ATTR_OLD_CONTRACT"
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Value = True and Obj.StatusName = "STATUS_CONRACT_DRAFT_OLD" Then
      CheckOldContract = True
    End If
  End If
End Function

'Функция проверки доступности атрибутов в финальном статусе
Function CheckAttrsFinish(Obj)
  CheckAttrsFinish = False
  If Obj.StatusName <> "STATUS_CONTRACT_COMPLETION" Then Exit Function
  Set CU = ThisApplication.CurrentUser
  If CU.Groups.Has("GROUP_CONTRACTS") = False Then Exit Function
  CheckAttrsFinish = True
End Function

Sub BTN_NEWDOC_OnClick()

  Call Create_Ref_Doc(ThisObject)

End Sub

function Create_Ref_Doc(docBase)
    set Create_Ref_Doc = nothing
    
    ThisScript.SysAdminModeOn
  
    if thisApplication.CurrentUser.SysName <> GetCurUser().SysName then
      msgbox "Создавать документ можно только от своего имени. "& vbNewLine _
        & "Выберите себя в оперативной панели, чтобы создать новый документ.", vbExclamation, _
        "Измените пользователя в оператичной панели"
      exit function
    end if
    set objType = thisApplication.ObjectDefs("OBJECT_KD_BASE_DOC")
    cnt = objType.SubObjectDefs.Count
    dim LetterTypesArray()  
    Redim LetterTypesArray(cnt)

    set User = GetCurUser()
    IsSec = isSecretary(User)
    isCanCrContr = User.Groups.Has("GROUP_CONTRACTS")
    isCanCrTenderInt = User.Groups.Has("GROUP_TENDER_INICIATORS")
    isCanCrCCR = User.Groups.Has("GROUP_CCR")
    i = 0
'    if isSec then 
'      LetterTypesArray(i) = "Входящий документ"
'      i = 1
'    end if
'EV TODO    убрать потом после разработки всех документов
'    LetterTypesArray(i) = "Исходящий документ"
'    i = i+1
'    LetterTypesArray(i) = "Служебная записка"
'    i = i+1
'    LetterTypesArray(i) = "ОРД"
'    i = i+1
'    LetterTypesArray(i) = "Заявка на оплату"
'    i = i+1
'    LetterTypesArray(i) = "Протокол"
    if isCanCrContr then 
      i = i+1
      LetterTypesArray(i) = "Договор"
      i = i+1
      LetterTypesArray(i) = "Соглашение"
    end if
    
    if isCanCrTenderInt then 
      i = i+1
      LetterTypesArray(i) = "Внутренняя закупка"
    end if
    
    if isCanCrCCR then 
      i = i+1
      LetterTypesArray(i) = "Акт"
    end if
    
'    i = i+1
'    LetterTypesArray(i) = "Без документа-основания" 
'    
'    for each chObjType in objType.SubObjectDefs
'      if chObjType.SysName <>"OBJECT_KD_DOC_IN" then 
'         LetterTypesArray(i)= chObjType.Description
'         i=i+1
'      end if   
'    next

    Set SelDlg = ThisApplication.Dialogs.SelectDlg
    SelDlg.SelectFrom = LetterTypesArray
    SelDlg.Caption = "Выбор типа документа"
    SelDlg.Prompt = "Выберите тип документа:"
    
    RetVal = SelDlg.Show
      
    'Если пользователь отменил диалог или ничего не выбрал, закончить работу.
    If ( (RetVal <> TRUE) or (UBound(SelDlg.Objects)<0) ) Then  
      exit function
    end if
   
    SelectedArray = SelDlg.Objects  
    if SelectedArray(0) = "" then exit function
    
    set objType = thisApplication.ObjectDefs(SelectedArray(0))
    if objType.SysName = "OBJECT_CONTRACT" then ' EV для договора отдельная функция
      set Create_Ref_Doc = thisApplication.ExecuteScript("CMD_DLL_CONTRACTS", "CreateContract", docBase)
'      if not Create_Doc is nothing then 
'        call AddResDocFiles(docBase, Create_Doc, "Является документом основанием для договора", false)
'        docBase.Permissions = SysadminPermissions
'        docBase.SaveChanges(16384)
'      end if
    ElseIf objType.SysName = "OBJECT_AGREEMENT" then ' EV для соглашения отдельная функция
      set Create_Ref_Doc = thisApplication.ExecuteScript("CMD_AGREEMENT_CREATE", "Create_Agreement", docBase)
    ElseIf objType.SysName = "OBJECT_TENDER_INSIDE" then ' EV для закупки отдельная функция
      Set Create_Ref_Doc = ThisApplication.ExecuteScript("CMD_PURCHASE_CREATE","Main",docBase)
    else
      set Create_Ref_Doc =  Create_Doc_by_Type(objType, docBase)
    end if
end function


Sub BTN_ShowTenderInTree_OnClick()
  Set Obj = ThisObject.Attributes("ATTR_TENDER").Object
  Call ShowInTree(Obj)
End Sub

Sub BTN_OPENTENDER_OnClick()
  Set Obj = ThisObject.Attributes("ATTR_TENDER").Object
  Call JumpToObj(Obj)
End Sub

