USE "CMD_DLL"


'================================================================
' Возвращает корневую папку для размещения договора
'----------------------------------------------------------------
' GetContractRoot: TDMSObject - корневой объект для договоров
'================================================================
Function GetContractRoot()
  Set GetContractRoot = Nothing
  'Определяем контейнер "Договоры"
  
  ObjDefName = "OBJECT_CONTRACT"
'  Set GetContractRoot = thisApplication.ExecuteScript("CMD_KD_FOLDER","GET_FOLDER","",thisApplication.ObjectDefs(ObjDefName))
  
  Set GetContractRoot = ThisApplication.GetObjectByGUID("{519D5F9D-D680-4642-BAEE-573455D6778E}")
  If GetContractRoot Is Nothing Then
    Set Objects = ThisApplication.ObjectDefs(ObjDefName).Objects
    If Objects.count > 0 Then
      Set GetContractRoot  = Objects(0)
'  For Each Obj in Objects
'    If Obj.Content.Count <> 0 Then
'      Set GetContractRoot = Obj
'      Exit Function
'    End If
'  Next
    End If
  End If
End Function

'================================================================
' Создает объект Договор
'----------------------------------------------------------------
' Obj: TDMSObject - Документ-основание
' CreateContract: TDMSObject - Созданный договор
'================================================================
Function CreateContract(Obj)
    Set CreateContract = nothing
    ThisScript.SysAdminModeOn
        
    Set clsRoot = ThisApplication.Classifiers("NODE_CONTRACT_CLASS")
    cnt = clsRoot.Classifiers.Count
    Dim ContractClassArray()
    ReDim ContractClassArray(cnt)
    i = 0
    for each chObjType in clsRoot.Classifiers
      ContractClassArray(i)= chObjType.Description
      i=i+1
    next
    
    Set SelDlg = ThisApplication.Dialogs.SelectDlg
    SelDlg.SelectFrom = ContractClassArray
    SelDlg.Caption = "Выбор класса договора"
    SelDlg.Prompt = "Выберите класс договора:"
    
    RetVal = SelDlg.Show
      
    'Если пользователь отменил диалог или ничего не выбрал, закончить работу.
    If ( (RetVal <> TRUE) or (UBound(SelDlg.Objects)<0) ) Then  
      exit function
    end if
   
    SelectedArray = SelDlg.Objects  
    if SelectedArray(0) = "" then exit function
    
    Set cls = clsRoot.Classifiers.Find(SelectedArray(0))
    Set CreateContract =  CreateContractByClass(Obj, cls)
  
End Function

'================================================================
' Создает объект Договор с предустановленным классом договора
'----------------------------------------------------------------
' CreateContract: TDMSObject - Созданный договор
'================================================================
Function CreateContractByClass(objType, cls)
  Set CreateContractByClass = Nothing
  
  Set ObjRoots = GetContractRoot()

  If ObjRoots Is Nothing Then 
    Msgbox "Не могу найти папку Договоры. Операция завершена!", vbCritical, "Объект не был создан"
    Exit Function
  End If
  Set NewObj = Nothing
  'Создаем объект
  ObjRoots.Permissions = SysAdminPermissions
  On error Resume Next
  Set NewObj = ObjRoots.Objects.Create("OBJECT_CONTRACT")
  If NewObj Is Nothing or err.Number <> 0 Then
    err.clear
    on error GoTo 0
    Exit Function
  End If
      NewObj.Attributes("ATTR_CONTRACT_CLASS").Classifier = cls
      Call FillCompany(NewObj)
      Call SetBaseDocInfo(objType,NewObj)
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
      Dlg.Object = NewObj
      RetVal = Dlg.Show
      
      If NewObj.StatusName = "STATUS_CONTRACT_DRAFT" Then
        If Not RetVal Then
          NewObj.Erase
          Exit Function
        End If
      End If
    Set CreateContractByClass = NewObj
End Function

'================================================================
' Возвращает значение системного атрибута Моя компания
'----------------------------------------------------------------
' CreateContract: TDMSObject - Созданный договор
'================================================================
Function GetMyCompany()
  Set GetMyCompany = Nothing
  If ThisApplication.Attributes.Has("ATTR_MY_COMPANY") Then
    If ThisApplication.Attributes("ATTR_MY_COMPANY").Empty = False Then
      If not ThisApplication.Attributes("ATTR_MY_COMPANY").Object is Nothing Then
        Set GetMyCompany = ThisApplication.Attributes("ATTR_MY_COMPANY").Object
      End If
    End If
  End If
End Function
'==========================================================================================================
Sub FillCompany(Obj)
  Set cls = Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier
  If cls.SysName = "NODE_CONTRACT_EXP" Then
    Obj.Attributes("ATTR_CUSTOMER").Object =  GetMyCompany
  ElseIf cls.SysName = "NODE_CONTRACT_PRO" Then
    Obj.Attributes("ATTR_CONTRACTOR").Object =  GetMyCompany
  End If
End Sub
'==========================================================================================================
Sub SetBaseDocInfo(BaseObj,Obj)
  If BaseObj Is Nothing Then Exit Sub
  If Obj Is Nothing Then Exit Sub
  Call ThisApplication.ExecuteScript ("CMD_S_DLL","SetLinkToBaseDoc",BaseObj,Obj,"Документ-основание")
  
  Select Case BaseObj.ObjectDefName
    Case "OBJECT_PURCHASE_OUTSIDE" ' Договор создается из внешней закупки
      ' Атрибут закупка
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", Obj, "ATTR_TENDER", BaseObj, True
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", Obj, "ATTR_CONTRACT_wTENDER", True, True
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", Obj, "ATTR_PURCHASE_FROM_EI", False, True
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", Obj, "ATTR_CONTRACT_SUBJECT", BaseObj.Attributes("ATTR_NAME"), True
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", Obj, "ATTR_CUSTOMER", BaseObj.Attributes("ATTR_TENDER_CLIENT").Object, True
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", Obj, "ATTR_CURATOR", BaseObj.Attributes("ATTR_TENDER_CURATOR").User, True

    Case "OBJECT_TENDER_INSIDE" ' Договор создается из внутренней закупки
      ' Атрибут закупка
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", Obj, "ATTR_TENDER", BaseObj, True
      
      AttrName0 = "ATTR_TENDER_METHOD_NAME"
      If BaseObj.Attributes.Has(AttrName0) and Obj.Attributes.Has(AttrName0) Then
        Call AttrValueCopy(BaseObj.Attributes(AttrName0),Obj.Attributes(AttrName0))
      End If
      
      AttrName0 = "ATTR_TENDER_REASON_POINT"
      AttrName1 = "ATTR_PURCHASE_BASIS"
      If BaseObj.Attributes.Has(AttrName0) and Obj.Attributes.Has(AttrName1) Then
        Call AttrValueCopy(BaseObj.Attributes(AttrName0),Obj.Attributes(AttrName1))
      End If
          
      AttrName0 = "ATTR_TENDER_SMSP_EXCLUDE_CODE"
      AttrName1 = "ATTR_SMSP_EXCLUDE_CODE"
      If BaseObj.Attributes.Has(AttrName0) and Obj.Attributes.Has(AttrName1) Then
        Call AttrValueCopy(BaseObj.Attributes(AttrName0),Obj.Attributes(AttrName1))
      End If
      
      AttrName0 = "ATTR_TENDER_WORK_START_PLAN_DATA"
      AttrName1 = "ATTR_STARTDATE_PLAN"
      If BaseObj.Attributes.Has(AttrName0) and Obj.Attributes.Has(AttrName1) Then
        Call AttrValueCopy(BaseObj.Attributes(AttrName0),Obj.Attributes(AttrName1))
      End If
      
      AttrName0 = "ATTR_TENDER_WORK_END_PLAN_DATA"
      AttrName1 = "ATTR_ENDDATE_PLAN"
      If BaseObj.Attributes.Has(AttrName0) and Obj.Attributes.Has(AttrName1) Then
        Call AttrValueCopy(BaseObj.Attributes(AttrName0),Obj.Attributes(AttrName1))
      End If
          
      AttrName0 = "ATTR_TENDER_PAY_CONDITIONS"
      AttrName1 = "ATTR_DUE_DATE"
      If BaseObj.Attributes.Has(AttrName0) and Obj.Attributes.Has(AttrName1) Then
        Call AttrValueCopy(BaseObj.Attributes(AttrName0),Obj.Attributes(AttrName1))
      End If
    Case Else
  End Select
End Sub

'====================================================================
' Проверка подписания документа двумя сторонами
'--------------------------------------------------------------------
' Obj: TDMSObject - проверяемый документ (договор, соглашение, акт)
' IsSignedBothSides:Boolean - True: Подписан обеими сторонами
'                             False: Не подписан обеими сторонами
'====================================================================
Function IsSignedBothSides(Obj)
  IsSignedBothSides = False
  Signed1 = IsSignedByContractor(Obj)
  Signed2 = IsSigned(Obj)
  IsSignedBothSides = Signed1 And Signed2
End Function

'==========================================================================================================
Function SignedByContractor(Obj)
  SignedByContractor = False
  ThisScript.SysAdminModeOn
  ans = msgbox ("Пометить " & Obj.Description & " как подписанный контрагентом?",vbQuestion+vbYesNo)
  If ans = vbNo Then Exit Function
  
  If Obj.Attributes.Has("ATTR_IS_SIGNED_BY_CORRESPONDENT") = False Then
    Obj.Attributes.Create ThisApplication.AttributeDefs("ATTR_IS_SIGNED_BY_CORRESPONDENT")
  End If
  Obj.Attributes("ATTR_IS_SIGNED_BY_CORRESPONDENT") = True
  SignedByContractor = True
End Function


'====================================================================
' Проверка подписания документа контрагентом
'--------------------------------------------------------------------
' Obj: TDMSObject - проверяемый документ (договор, соглашение, акт)
' IsSignedBothSides:Boolean - True: Подписан контрагентом
'                             False: Не подписан контрагентом
'====================================================================
Function IsSignedByContractor(Obj)
  IsSignedByContractor = False
  If Obj.Attributes.Has("ATTR_IS_SIGNED_BY_CORRESPONDENT") = False Then Exit Function
  IsSignedByContractor = Obj.Attributes("ATTR_IS_SIGNED_BY_CORRESPONDENT").Value
End Function

'====================================================================
' Проверка подписания документа с нашей стороны
'--------------------------------------------------------------------
' Obj: TDMSObject - проверяемый документ (договор, соглашение, акт)
' IsSignedBothSides:Boolean - True: Подписан с нашей стороны
'                             False: Не подписан с нашей стороны
'====================================================================
Function IsSigned(Obj)
  IsSigned = False
  check = False
  sName = Obj.StatusName
  Select Case Obj.ObjectDefName
    Case "OBJECT_CONTRACT" ' Договор
      If sName = "STATUS_CONTRACT_SIGNED" Or sName = "STATUS_CONTRACT_COMPLETION" Then check = True
    
    Case "OBJECT_CONTRACT_COMPL_REPORT" ' Акт
      If sName = "STATUS_COCOREPORT_SIGNED" Then check = True
    
    Case "OBJECT_AGREEMENT" ' Соглашение
      If sName = "STATUS_AGREEMENT_SIGNED" Then check = True
  End Select
  IsSigned = check
End Function
'==========================================================================================================
Sub SetRegistrationDate (Obj)
'  Set dlg = ThisApplication.Dialogs.SimpleEditDlg
'  msgbox "Здесь будет диалог указания даты регистрации акта"
End Sub
'==========================================================================================================
'Возвращает контрагента с договора'
Function GetContractContractor(Obj)
  Set GetContractContractor = Nothing
  Set MyCompany = GetMyCompany
  If MyCompany Is Nothing Then Exit Function
  
  Set Customer = Obj.Attributes("ATTR_CUSTOMER").Object
  Set Contractor = Obj.Attributes("ATTR_CONTRACTOR").Object
  If Not Customer Is Nothing Then
    If Customer.Handle <> MyCompany.Handle Then
      Set GetContractContractor = Customer
      Exit Function
    ElseIf Not Contractor Is Nothing Then
      If Contractor.Handle <> MyCompany.Handle Then
        Set GetContractContractor = Contractor
        Exit Function
      End If
    End If
  End If  
End Function
'==========================================================================================================
Function IsCurator(Obj,user_)
  IsCurator = False
  If Obj Is Nothing Then Exit Function
  If Obj.Attributes.Has("ATTR_CURATOR") = False Then Exit Function
  If user_ Is Nothing Then 
    Set user = ThisApplication.CurrentUser
  Else
    Set user = user_
  End If
  Set uCur = Obj.Attributes("ATTR_CURATOR").User
  If uCur Is Nothing Then
    If Obj.Attributes.Has("ATTR_CONTRACT") Then
      Set oContr = Obj.Attributes("ATTR_CONTRACT").Object
      If Not oContr Is Nothing Then
        If oContr.Attributes.Has("ATTR_CURATOR") Then
          Set u = oContr.Attributes("ATTR_CURATOR").User
          If Not u Is Nothing Then
            If u.Handle <> user.Handle Then Exit Function
          Else
            Exit Function
          End If
        Else
          Exit Function
        End If
      Else
        Exit Function
      End If
    Else
      Exit Function
    End If
  Else
    If uCur.Handle <> user.Handle Then Exit Function
  End If
  IsCurator = True
End Function
'==========================================================================================================
' Возвращает куратора договора
Function GetContractCurator(Obj)
  Set GetContractCurator = Nothing
      
  If Obj.Attributes.Has("ATTR_CURATOR") Then
    If Obj.Attributes("ATTR_CURATOR").User Is Nothing Then
      Set oContr = Obj.Attributes("ATTR_CONTRACT").Object
      If Not oContr Is Nothing Then
        If oContr.Attributes.Has("ATTR_CURATOR") Then
          Set u = oContr.Attributes("ATTR_CURATOR").User
          If u Is Nothing Then Exit Function
        Else
          Exit Function
        End If
      Else
        Exit Function
      End If
    Else
      Set u = Obj.Attributes("ATTR_CURATOR").User
    End If
  Else
    Set oContr = Obj.Attributes("ATTR_CONTRACT").Object
      If Not oContr Is Nothing Then
        If oContr.Attributes.Has("ATTR_CURATOR") Then
          Set u = oContr.Attributes("ATTR_CURATOR").User
          If u Is Nothing Then Exit Function
        Else
          Exit Function
        End If
      Else
        Exit Function
      End If
  End If
  Set GetContractCurator = u
End Function
'==========================================================================================================
Function isRegistered(Obj)
  isRegistered = False
    If Obj.Attributes.Has("ATTR_REGISTERED") Then
      isRegistered = Obj.Attributes("ATTR_REGISTERED")
    End If
End Function
'==========================================================================================================
Sub Files_DragAndDropped(FilesPathArray, Object, Cancel)

'    If Not IsAuthor(Obj) Then 
'      msgbox "Только автор документа может добавлять файлы", vbExclamation
'      cancel = True
'      Exit Sub
'    End If
    if Ubound(FilesPathArray)>0 then 
      For i=0 to Ubound(FilesPathArray)
        msgbox FilesPathArray(i) 'AddFilesToDoc
        'call LoadFileByObj("FILE_KD_ANNEX", FilesPathArray(i), true, Object)
        Call LoadFiles(Object,"FILE_KD_ANNEX",FilesPathArray(i),False)
      Next 
    else
      Call LoadFiles(Object,"FILE_CONTRACT_DOC",FilesPathArray(0),False)
'      AddFilesToDoc(FilesPathArray(0))   
    end if
    Object.Permissions = SysAdminPermissions
    Object.upDate
End Sub
'==========================================================================================================
Sub File_Erased(File, Object)
  thisScript.SysAdminModeOn
  Call ThisApplication.ExecuteScript("OBJECT_DOC","File_Erased",File, Object)
'   pdfFileName = ThisApplication.ExecuteScript("OBJECT_KD_BASE_DOC","getFileName",File.FileName) & ".pdf"
'   if object.Files.Has(pdfFileName) then 
'      on error resume next
'      object.Files(pdfFileName).Erase
'      if err.Number<> 0 then err.Clear
'      on error goto 0
'    end if
End Sub
'==========================================================================================================
Sub File_CheckedIn(File, Object)
  dim FileDef
'  if IsExistsGlobalVarrible("FileTpRename") then call ReNameFiles(file,Object)
  FileDef =  File.FileDefName
  'call AddToFileList(file,object)   ' Пока нет такой таблицы
    select case FileDef
      case "FILE_KD_SCAN_DOC","FILE_KD_EL_SCAN_DOC"  Object.Files.Main = File 'если скан документ
      case "FILE_CONTRACT_DOC","FILE_KD_ANNEX","FILE_DOC_DOC","FILE_KD_WORD"
        call ThisApplication.ExecuteScript("OBJECT_KD_BASE_DOC","delElScan",file,Object)' call CreatePDFFromFile(File.WorkFileName, Object, nothing) ' .WorkFileName .FileName
    end select  
    
  If Object.StatusName= "STATUS_CONTRACT_COMPLETION" or Object.StatusName= "STATUS_AGREEMENT_FORCED" Then
    Call FileEditNotify(Object)
  End If
End Sub

'=========================================================================================================
Sub ShowAttrData(Form, Obj)
  Set cCtl = Form.Controls
  Call SetChBox(Form, Obj)
  If Obj.Attributes("ATTR_DATA").Empty = True Then 
    cCtl("EDIT_ATTR_DATA").Value = vbNullString
  Else
    cCtl("EDIT_ATTR_DATA").Value = FormatDateTime(Obj.Attributes("ATTR_DATA").Value, vbShortDate)
  End If
  
  cCtl("EDIT_ATTR_DATA").Readonly = Not (ThisApplication.CurrentUser.Groups.Has("GROUP_CONTRACTS") And _
                                          Obj.Attributes("ATTR_REGISTERED").Value = True)
                                    
' 22.01.2018 str
'  cCtl("EDIT_ATTR_DATA").Readonly = Not (Obj.Attributes("ATTR_DATA").Empty = True And _
'                                    Obj.Attributes("ATTR_REGISTERED").Value = True And _
'                                    ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsAuthor",Obj,Nothing)) 
End Sub
'==========================================================================================================
sub SetChBox(Form, Obj)
  List = "ATTR_DATA,ATTR_STARTDATE_PLAN,ATTR_ENDDATE_PLAN"
  arr = Split(List,",")
  
  For each aDefName In arr
    If Form.Controls.Has("EDIT_" & aDefName) Then
      set chk = Form.Controls("EDIT_" & aDefName).ActiveX
    set def = ThisApplication.AttributeDefs(aDefName) ' тип атрибута Дата\Время
    chk.AttributeDef = def
    End If
  Next
  
'  set chk = thisForm.Controls("EDIT_ATTR_DATA").ActiveX
'  set def = ThisApplication.AttributeDefs("ATTR_DATA") ' тип атрибута Дата\Время
'  chk.AttributeDef = def
'  
'  set chk = thisForm.Controls("EDIT_ATTR_STARTDATE_PLAN").ActiveX
'  set def = ThisApplication.AttributeDefs("ATTR_STARTDATE_PLAN") ' тип атрибута Дата\Время
'  chk.AttributeDef = def
'  
'  set chk = thisForm.Controls("EDIT_ATTR_ENDDATE_PLAN").ActiveX
'  set def = ThisApplication.AttributeDefs("ATTR_ENDDATE_PLAN") ' тип атрибута Дата\Время
'  chk.AttributeDef = def
end sub
'==========================================================================================================
Sub EDIT_ATTR_DATA_Modified()
  Set Obj = ThisObject
  aData = ThisForm.Controls("EDIT_ATTR_DATA").Value
  If ThisForm.Controls("EDIT_ATTR_DATA").Value <> "" Then
    Obj.Attributes("ATTR_DATA") = FormatDateTime(CDate(ThisForm.Controls("EDIT_ATTR_DATA").Value), vbShortDate)
  End If
  guid = Obj.GUID
  Set dict = ThisApplication.Dictionary(guid)
  If Not dict Is Nothing Then
    If dict.Exists("ATTR_DATA") Then
      dict.Remove("ATTR_DATA")
    End If
  End If
  dict.Add "ATTR_DATA", aData
End Sub
'==========================================================================================================
Sub Set_ATTR_DATA(Obj)
  ThisScript.SysAdminModeOn
  guid = Obj.GUID
  Set dict = ThisApplication.Dictionary(guid)
  If dict.Exists("ATTR_DATA") Then
    Obj.Permissions = SysAdminPermissions
    If dict.Item("ATTR_DATA") = "" Then
      Obj.Attributes("ATTR_DATA").Value = ""
    Else
      Obj.Attributes("ATTR_DATA").Value = FormatDateTime(CDate(dict.Item("ATTR_DATA")), vbShortDate)
    End If
'    dict.Remove("ATTR_DATA")
'    Obj.SaveChanges(0)
  End If
End Sub
'==========================================================================================================
Sub Set_StartEndATTR_DATA(Obj)
'ThisApplication.AddNotify "Set_StartEndATTR_DATA - Start - " & Time
  ThisScript.SysAdminModeOn
  
  guid = Obj.GUID
  Set dict = ThisApplication.Dictionary(guid)
  If dict.Exists("ATTR_STARTDATE_PLAN") = False And dict.Exists("ATTR_ENDDATE_PLAN") = False Then Exit Sub
  
  
  List = "ATTR_STARTDATE_PLAN,ATTR_ENDDATE_PLAN"
  
  arr = Split(List,",")
  
  guid = Obj.GUID
  Set dict = ThisApplication.Dictionary(guid)
  
  For each aDefName In arr
    If dict.Exists(aDefName) Then
      If Obj.Attributes.Has(aDefName) Then
        Val = Left(dict.Item(aDefName),10)
        If Obj.Attributes(aDefName).Value <> Val Then
          Obj.Attributes(aDefName).Value = Val
        End If
      End If
    End If
  Next
'  ThisApplication.AddNotify "Set_StartEndATTR_DATA - End - " & Time
End Sub
'==========================================================================================================
Function SetFieldAutoComp()
  Set SetFieldAutoComp = Nothing
  Set ctrl = thisForm.Controls("ATTR_SIGNER").ActiveX
  If ThisObject.IsKindOf("OBJECT_CONTRACT_COMPL_REPORT") Then
    Set SetFieldAutoComp = ThisApplication.Users
    Exit Function
  End If
    Set query = ThisApplication.Queries("QUERY_KD_SINGERS")
    Set result = query.Sheet.Users
    Set SetFieldAutoComp = result
    ctrl.ComboItems = result
end Function

Function ADD_STAGE_ToTree(Obj)
  Set ADD_STAGE_ToTree = Nothing
  ThisScript.SysAdminModeOn

  Set ADD_STAGE_ToTree = Create_Contract_Stage(Obj)
End Function

Function Create_Contract_Stage(Obj)
  Obj.Permissions = SysAdminPermissions
  Set Create_Contract_Stage = Nothing
    ObjDefName = "OBJECT_CONTRACT_STAGE"
  'Использование словаря для заполнения атрибутов объекта
'  Set oContr = GetContract(Obj)
'  ThisApplication.Dictionary(ObjDefName).Item("Contract") = oContr.Guid
  
  'Создаем объект
'  Set NewObj = ThisApplication.ObjectDefs(ObjDefName).CreateObject
  set NewObj = Obj.Objects.Create(ObjDefName)

  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = NewObj
  RetVal = Dlg.Show
  If NewObj.StatusName = "STATUS_CONTRACT_STAGE_DRAFT" Then
    If Not RetVal Then
      NewObj.Erase
      Exit Function
    End If
  End If  
  Set Create_Contract_Stage = NewObj
End Function


function DEL_STAGE_FromTree()
    DEL_STAGE_FromTree = false
    set stage = GetStageFromTree()
    if stage is nothing then exit function
    If Stage.Objects.count > 0 Then exit function
    if stage.StatusName = "STATUS_CONTRACT_STAGE_DRAFT" then
      if True = True Then 'fIsAutor(stage) then 
          stage.Permissions = sysAdminPermissions
          stage.Erase
          DelNodeFromFree()
          DEL_STAGE_FromTree = true
      else
        msgbox "Невозможно удалить этап " & stage.Description & _
              ", т.к. оно выдано другим пользователем " & stage.Attributes("ATTR_KD_AUTH").User.Description
      end if
    else
      msgbox "Невозможно удалить этап " & stage.Description & ", т.к. он уже " & stage.Status.Description
    end if
End function

function GetStageFromTree()
    set GetStageFromTree = nothing
    set ax_Tee = thisForm.Controls("TDMSTREEStage").ActiveX 
    if ax_Tee is nothing then exit function
    hItem = ax_Tee.SelectedItem 
    if hItem = 0 then 
      'msgbox "Поручение не выбрано", vbInformation
      exit function
    end if
    set GetStageFromTree = ax_Tee.GetItemData(hItem)
end function

sub DelNodeFromFree()
    set ax_Tee = thisForm.Controls("TDMSTREEStage").ActiveX 
    if ax_Tee is nothing then exit sub
    hItem = ax_Tee.SelectedItem 
    if hItem = 0 then exit sub
    ax_Tee.DeleteItem(hItem) 
end sub

function GetStagesToApplay() 
  set GetStagesToApplay =  nothing
  set query = thisAppLication.Queries("QUERY_GET_ORDER_TO_APPLAY")
  query.Parameter("PARAM0") = thisObject.handle
  query.Parameter("PARAM1") = thisApplication.CurrentUser
  set objs = query.Objects
  if objs.Count = 0 then exit function
  if objs.Count = 1 then 
    set GetOrderToApplay = objs(0)
    exit function
  end if
  'если не принятое получение
  for each order in objs
    if order.StatusName = "STATUS_KD_REPORT_READY" then set GetOrderToApplay = order
  next
  'если нет то 
  set GetStagesToApplay = objs(0)
end function


'==============================================================================
' Функция возвращает ссылку на договор
'------------------------------------------------------------------------------
' o_:TDMSObject - Объект к которому добавляется ссылка
'==============================================================================
Function GetContract(o_)
  Set GetContract = Nothing
  If o_ Is Nothing Then Exit Function
  if VarType(o_)<>9 Then Exit Function
  check = False
  If o_.ObjectDefName = "OBJECT_CONTRACT" Then
    Set GetContract = o_
    Exit Function
  Else
    If o_.Attributes.Has("ATTR_CONTRACT") Then
      If o_.Attributes("ATTR_CONTRACT").Empty = False Then
        If Not o_.Attributes("ATTR_CONTRACT").Object Is Nothing Then
          check = True
        End If
      End If
    End If
  End If
  
  If check Then
    Set GetContract = o_.Attributes("ATTR_CONTRACT").Object
  Else
    Set GetContract = GetUplinkObj(o_,"OBJECT_CONTRACT")
  End If
End Function

Sub ATTR_SIGNER_ButtonClick(Cancel)
    Set source = SetFieldAutoComp()
    set dlg = ThisApplication.Dialogs.SelectUserDlg
    dlg.SelectFromUsers = source
    RetVal = dlg.Show
    If (RetVal<>TRUE) Or (dlg.Users.Count=0) Then 
      Cancel = True 
      Exit Sub
    End If
    ThisForm.Controls("ATTR_SIGNER").Value = dlg.Users(0)
    cancel = True
End Sub

'Функция проверки доступности кнопки "Зарегистрировать-соглашение"
'Function CheckBtnReg(Obj)
'  CheckBtnReg = False
'  Set cu = ThisApplication.CurrentUser
'  isAuth = IsAuthor(Obj,CU)
'  IsReg = Obj.Attributes("ATTR_REGISTERED").Value
'  canRegister = IsGroupMember(CU,"GROUP_CONTRACTS")
'  
'  ' Оставляем рагистрацию соглашения во всех статусах
'  If isAuth or canRegister Then
''    If Obj.Attributes("ATTR_CONTRACT_TYPE").Empty = False and _
''      Obj.Attributes("ATTR_CUSTOMER").Empty = False and not IsReg Then
'      CheckBtnReg = True
''    End If
'  End If
'  
''  If Obj.StatusName = "STATUS_AGREEMENT_AGREED" Then
''    Set u = Obj.Attributes("ATTR_AUTOR").User
''    If u Is Nothing Then Exit Function
''    
''    If (u.SysName = cu.SysName) = False Then Exit Function
'''    Set Roles = Obj.RolesForUser(ThisApplication.CurrentUser)
'''    If Roles.Has("ROLE_AGREEMENT_AUTHOR") Then
''      If Obj.Attributes("ATTR_AGREEMENT_TYPE").Empty = False and _
''      Obj.Attributes("ATTR_CONTRACTOR").Empty = False Then
''        CheckBtnReg = True
''      End If
''    End If
''  'End If
'End Function
'Функция проверки доступности кнопки "Зарегистрировать-договор"
Function CheckBtnReg(Obj)
  CheckBtnReg = False
  Set CU = ThisApplication.CurrentUser
  isAuth = IsAuthor(Obj,CU)
  IsReg = Obj.Attributes("ATTR_REGISTERED").Value
  canRegister = IsGroupMember(CU,"GROUP_CONTRACTS")

  OldContr = ThisApplication.ExecuteScript("FORM_CONTRACT","CheckOldContract",Obj)
  
  ' Добавлен статус "На согласовании"
 
    If OldContr = True Then
      CheckBtnReg = True
    ElseIf isAuth or canRegister Then
'      If Obj.Attributes("ATTR_CONTRACT_TYPE").Empty = False and _
'      Obj.Attributes("ATTR_CUSTOMER").Empty = False and not IsReg Then
        CheckBtnReg = True
'      End If
    End If
'  End If
End Function


Sub FileEditNotify(Obj)
  If ThisApplication.Groups.Has("GROUP_CONTRACT_FILES_EDIT_NOTIFY") = False Then
    Exit Sub
  End If
  Set gr = ThisApplication.Groups("GROUP_CONTRACT_FILES_EDIT_NOTIFY")
  For Each user In gr.Users
    Set uFromUser = ThisApplication.CurrentUser
    resol = "NODE_CORR_REZOL_INF"
    txt = "Изменены файлы: " & Obj.ObjectDef.Description & " " & Obj.Description
    planDate = DateAdd ("d", 1, Date)
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",user,uFromUser,resol,txt,planDate
  Next
End Sub