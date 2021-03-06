' Автор: Стромков С.А.
'
' Договор 
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016 г.

USE "FORM_HISTORY_OF_CHANGE"
USE "CMD_DLL_ROLES"
USE "CMD_DLL_CONTRACTS"

Sub Object_BeforeCreate(Obj, p_, Cancel)
  If Not IsGroupMemberMessage(ThisApplication.CurrentUser,"GROUP_CONTRACTS") Then 
    Cancel = True
    Exit Sub
  End If

  sysID = ThisApplication.ExecuteScript ("CMD_KD_REGNO_KIB","Get_Sys_Id",Obj)
  If sysID = 0 Then 
    Cancel = True
    Exit Sub
  Else  
    Obj.Attributes("ATTR_KD_IDNUMBER").value = sysID
  End if
  
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",p_,p_.Status,Obj,Obj.ObjectDef.InitialStatus)
  
  ' Установка атрибутов
  Call SetAttrs(p_,Obj)
  
  ThisScript.SysAdminModeOn
  'Исполнитель
  'Call ConractorFill(Obj)
  
  'Подписант
  Set Signer = ThisApplication.ExecuteScript("CMD_DLL", "SignerGet")
  If not Signer is Nothing Then
    Obj.Attributes("ATTR_SIGNER").User = Signer
  End If
  
  'If not p_ is Nothing Then
  '  Set Dict = ThisApplication.Dictionary(p_.GUID)
  '  'Ссылка на основной договор
  '  Set MainObj = Nothing
  '  If Dict.Exists("MainContract") Then
  '    ObjGuid = Dict.Item("MainContract")
  '    Dict.Remove("MainContract")
  '    Set MainObj = ThisApplication.GetObjectByGUID(ObjGuid)
  '  End If
  '
  '  If not MainObj is Nothing Then
  '    'Основной договор
  '    Obj.Attributes("ATTR_CONTRACT_MAIN").Object = MainObj
  '    'Договор субподряда
  '    If Dict.Exists("SubContract") Then
  '      Dict.Remove("SubContract")
  '      'Вид договора
  '      Obj.Attributes("ATTR_CONTRACT_TYPE") = ThisApplication.Classifiers.FindBySysId("NODE_CONTRACT_TYPE_5")
  '      'Заказчик
  '      If ThisApplication.Attributes.Has("ATTR_MY_COMPANY") Then
  '        If ThisApplication.Attributes("ATTR_MY_COMPANY").Empty = False Then
  '          If not ThisApplication.Attributes("ATTR_MY_COMPANY").Object is Nothing Then
  '            Obj.Attributes("ATTR_CUSTOMER").Object = ThisApplication.Attributes("ATTR_MY_COMPANY").Object
  '          End If
  '        End If
  '      End If
  '    'Дополнительное соглашение
  '    ElseIf Dict.Exists("ContractAdd") Then
  '      Dict.Remove("ContractAdd")
  '      'Вид договора
  '      Obj.Attributes("ATTR_CONTRACT_TYPE") = ThisApplication.Classifiers.FindBySysId("NODE_CONTRACT_TYPE_7")
  '        
  '    End If
  '  End If    
  'End If
End Sub

Private Sub SetAttrs(Parent,Obj)
  'Устанавливаем ссылку договора на себя
  Call ThisApplication.ExecuteScript ("CMD_DLL", "SetAttr_F", Obj, "ATTR_CONTRACT", Obj, True)
End Sub


Sub Object_Created(Obj, Parent)
  ' Установка ролей
  Call SetRoles(Obj)
  
  ThisScript.SysAdminModeOn
  ' Добавление выборок
  Call ThisApplication.ExecuteScript("CMD_Update_CONTRACT_Q","AddSubQ",Obj)
  ThisScript.SysAdminModeOff
End Sub

Sub ContextMenu_BeforeShow(Commands, Obj, Cancel)
  ' Для расходного договора скрываем команду Создать договор субподряда
  If Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier.SysName = "NODE_CONTRACT_EXP" Then
    Commands.Remove ThisApplication.Commands("CMD_SUBCONTRACT_CREATE")
  End If
  
  ' Команда Создать Этап для согласующего
  Set user = ThisApplication.CurrentUser
'  isApr = ThisApplication.ExecuteScript("CMD_KD_USER_PERMISSIONS","IsCanAprove",user,Obj)
  isApr = ThisApplication.ExecuteScript("CMD_KD_USER_PERMISSIONS","IsAprover",user,Obj)
  If isApr Then
    Commands.Add ThisApplication.Commands("CMD_CONTRACT_STAGE_CREATE")
  End If
End Sub

Sub Object_StatusChanged(Obj, Status)
  If Status is Nothing Then Exit Sub
  ThisScript.SysAdminModeOn
  Call SetIcon(Obj)
  'Определение статуса после согласования
  StatusAfterAgreed = ""
  Set Rows = ThisApplication.Attributes("ATTR_AGREENENT_SETTINGS").Rows
  For Each Row in Rows
    If Row.Attributes("ATTR_KD_OBJ_TYPE").Value = Obj.ObjectDefName Then
      StatusAfterAgreed = Row.Attributes("ATTR_KD_FINISH_STATUS")
      Exit For
    End If
  Next
  
  If Status.SysName = "STATUS_KD_AGREEMENT" Then
    Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","Close_Return_order",Obj)
  End If
  
  'Отработка маршрутов для механизма согласования
  If Status.SysName = "STATUS_KD_AGREEMENT" or Status.SysName = StatusAfterAgreed Then
    If Obj.Dictionary.Exists("PrevStatusName") Then
      sName = Obj.Dictionary.Item("PrevStatusName")
      If ThisApplication.Statuses.Has(sName) Then
        If sName <> "STATUS_EDIT" Then
          Set PrevSt = ThisApplication.Statuses(sName)
          Call ThisApplication.ExecuteScript("CMD_ROUTER","RunNonStatusChange",Obj,PrevSt,Obj,Status.SysName) 
        End If
      End If
    End If
  End If
  
  ' Постобработка согласования
  If Obj.Dictionary.Exists("PrevStatusName") Then
    sName = Obj.Dictionary.Item("PrevStatusName")
    If sName = "STATUS_KD_AGREEMENT" Then
      Call ThisApplication.ExecuteScript("CMD_PROJECT_DOCS_LIBRARY","AgreementPostProcess",Obj) 
    End If
  End If
  
  ' заполняем дату перехода в статус Договор заключен
  ' str 29/01/2018
  If Obj.StatusName= "STATUS_CONTRACT_COMPLETION" Then
    d = FormatDateTime(Obj.StatusModifyTime,vbShortDate)
    ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", Obj, "ATTR_CONTRACT_CONCLUSION_DATE_SYS", d, True
  End If
End Sub

Sub Object_StatusBeforeChange(Obj, Status, Cancel)
  ThisScript.SysAdminModeOn
  'Создание строки в таблице История состояний
  Call TEventStatusChanges(Obj)
  'Записываем текущий статус в словарь
  Obj.Dictionary.Item("PrevStatusName") = Obj.StatusName
End Sub

Sub Object_Modified(Obj)
'ThisApplication.AddNotify "Object_Modified"
'  Set Dict = ThisApplication.Dictionary("DelObjOperation")
  Check = True
  'Отключено, т.к. в некоторых случаях вызывает ошибку
  ' 30.01.2018
'  If Dict.Exists("exe") Then
'    If Dict.Item("exe") = True Then Check = False
'  End If
  If Check = True Then
    'Синхронизация роли и атрибута "Подписант"
    Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_SIGNER","ROLE_SIGNER")
    
    If ThisApplication.Dictionary(Obj.GUID).Exists("ATTR_CURATOR") Then
      'Синхронизация роли и атрибута "Куратор договора"
      Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_CURATOR","ROLE_CONTRACT_RESPONSIBLE")
      Call SyncCuratorToStages(Obj)
      ThisApplication.Dictionary(Obj.GUID).Remove("ATTR_CURATOR")
    End If
  End If
End Sub

Sub Object_PropertiesDlgInit(Dialog, Obj, Forms)
  StName = Obj.StatusName
  Call ShowDefaultForm(Dialog, Obj, Forms)
  ' Закрываем информационные поручения 
  ResolList = "NODE_CORR_REZOL_INF,NODE_COR_STAT_MAIN,NODE_COR_DEL_MAIN" ',NODE_KD_NOTICE,
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,ResolList)
  
  ' отмечаем все поручения по документу прочитанными
  if obj.StatusName <> "STATUS_CONTRACT_DRAFT" then _
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","Set_OrdersReaded",Obj
  
  if Obj.Permissions.ViewFiles <> 1 then 
    Dialog.InputForms.Remove Dialog.InputForms("FORM_KD_DOC_AGREE")
    Dialog.InputForms.Remove Dialog.InputForms("FORM_KD_DOC_ORDERS")
    Dialog.InputForms.Remove Dialog.InputForms("FORM_CONTRACT_LINKS")
    Dialog.InputForms.Remove Dialog.InputForms("FORM_HISTORY_OF_CHANGE")
    Dialog.InputForms.Remove Dialog.InputForms("FORM_KD_HIST")
    Dialog.InputForms.Remove Dialog.InputForms("FORM_CONTRACT_INFO")
    Dialog.InputForms.Remove Dialog.InputForms("FORM_CONTRACT_STAGES")
    Dialog.InputForms.Remove Dialog.InputForms("FORM_PLAN_DATES")
    Dialog.InputForms.Remove Dialog.InputForms("FORM_CO_AUTHORS")
  End If

  'Скрываем форму "Информация о договоре"
  Set User = ThisApplication.CurrentUser
  If User.Groups.Has("GROUP_CONTRACTS") = False and User.SysName <> "SYSADMIN" Then
    If Dialog.InputForms.Has("FORM_CONTRACT_INFO") Then
      Dialog.InputForms.Remove Dialog.InputForms("FORM_CONTRACT_INFO")
    End If
  End If
  
  'Скрываем формы старого договора при создании
  OldContract = False
  AttrName = "ATTR_OLD_CONTRACT"
  If Obj.Attributes.Has(AttrName) Then OldContract = Obj.Attributes(AttrName).Value
  If OldContract = True and StName = "STATUS_CONRACT_DRAFT_OLD" Then
    For Each Form in Dialog.InputForms
      If Form.Sysname <> "FORM_CONTRACT" and Form.Sysname <> "FORM_CONTRACT_INFO" Then
        Dialog.InputForms.Remove Form
      End If
    Next
  End If
End Sub

'Процедура заполнения поля "Исполнитель"
Sub ConractorFill(Obj)
  If StrComp(Obj.Attributes("ATTR_CONTRACT_TYPE").Value, "Государственный контракт", vbTextCompare) = 0 Then
    If ThisApplication.Attributes.Has("ATTR_MY_COMPANY") Then
      If ThisApplication.Attributes("ATTR_MY_COMPANY").Empty = False Then
        If not ThisApplication.Attributes("ATTR_MY_COMPANY").Object is Nothing Then
          Obj.Attributes("ATTR_CONTRACTOR").Object = ThisApplication.Attributes("ATTR_MY_COMPANY").Object
        End If
      End If
    End If
  End If
End Sub

' Установка ролей
Private Sub SetRoles(o_)
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  Set uCur=o_.attributes("ATTR_CURATOR").User 
  
  Call ThisApplication.ExecuteScript("CMD_DLL","DelDefRole",o_,"ROLE_CONTRACT_AUTOR")
  Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",o_,"ROLE_CONTRACT_AUTOR",CU)
  
  Call ThisApplication.ExecuteScript("CMD_DLL","DelDefRole",o_,"ROLE_CONTRACT_RESPONSIBLE_DRAFT")
  Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",o_,"ROLE_CONTRACT_RESPONSIBLE_DRAFT",CU)
  
  If Not uCur Is Nothing Then
    Call ThisApplication.ExecuteScript("CMD_DLL", "DelDefRole",o_,"ROLE_CONTRACT_RESPONSIBLE")
    Call ThisApplication.ExecuteScript("CMD_DLL", "SetRole",o_,"ROLE_CONTRACT_RESPONSIBLE",uCur)
  End If
End Sub

Sub Object_BeforeModify(Obj, Cancel)
  Call SetDescription(Obj)
End Sub


Extern GetContractCode [Alias ("Договор"), HelpString ("Договор")]
Function GetContractCode(Obj) 
  GetContractCode = ""
    Set contr = Nothing
    If Obj.Attributes.Has("ATTR_CONTRACT") Then
      Set contr = Obj.Attributes("ATTR_CONTRACT").Object
    End If
    If Contr Is Nothing Then
      If Obj.Attributes.Has("ATTR_PROJECT") Then
        set proj = Obj.Attributes("ATTR_PROJECT").Object
        If Not Proj Is Nothing Then 
          If Proj.Attributes.Has("ATTR_CONTRACT") Then
            Set contr = Proj.Attributes("ATTR_CONTRACT").Object
          End If
        End If
      End If
    End If
    
    If Not Contr Is Nothing Then
      GetContractCode = Contr.Attributes("ATTR_REG_NUMBER")
    End If
End Function


function Check_FinishStatus(stName)
  Check_FinishStatus = False
'  Check_FinishStatus = (stName = "STATUS_CONTRACT_COMPLETION") or _
'                        (stName = "STATUS_CONTRACT_PAUSED") or _
'                        (stName = "STATUS_CONTRACT_CLOSED")
end function


'Т.е. функция должна называться Check_FinishStatus(stName) и в нее передается текущий статус объекта
'Создавать ее надо для кажного типа объекта, а не для родителя

' Тогда для каждого типа объекта необходимо определить функцию, 
' которая возвращает список доступных для добавления типов файлов по статусам и возможностям пользователя.  
' В функцию передается текущий документ 
'=============================================
function GetTypeFileArr(docObj)
  Set CU = ThisApplication.CurrentUser
  isAuth = IsAuthor(docObj,CU)
  isSign = IsSigner(docObj,CU)
  isChck = IsChecker(docObj,CU)
  isInit = IsInitiator(docObj,CU)
  isCanAppr = ThisApplication.ExecuteScript("CMD_KD_USER_PERMISSIONS","IsCanAprove",CU,docObj)

  ' A.O. 17.01.2018 Право добавления файлов для загруженных договоров
  If ThisApplication.Groups("GROUP_CONTRACTS").Users.has(CU) Then
    If docObj.Attributes("ATTR_AUTOR")<>"" then
      If docObj.Attributes("ATTR_AUTOR").User.Handle = ThisApplication.Users("SYSADMIN").Handle Then
        GetTypeFileArr = array("Договор","Приложение","Скан документа")  
        Exit function
      End If
    End If
  End If

  st = docObj.StatusName
  select case st
    case "STATUS_CONTRACT_DRAFT","STATUS_CONRACT_DRAFT_OLD"
      if isAuth  then _
          GetTypeFileArr = array("Договор","Приложение","Скан документа")  
    case "STATUS_CONTRACT_FOR_SIGNING"
      if isSign then _
          GetTypeFileArr = array("Приложение","Скан документа")  
    case "STATUS_CONTRACT_AGREED"
      if isAuth then _
          GetTypeFileArr = array("Приложение","Скан документа")  
    case "STATUS_CONTRACT_COMPLETION"
      if isSign or isAuth then _
          GetTypeFileArr = array("Приложение","Скан документа")  
    case "STATUS_CONTRACT_PAUSED"
'      if isAuth then _
          GetTypeFileArr = array("Приложение","Скан документа") 
    case "STATUS_KD_AGREEMENT"
    ' Приложение добавлено по требованию Красноярского ОП 17.01.2018
    ' Включено для всех 24.01.2018
'    if IsCanAprove(cUser, docObj) or HasReview(cUser,docObj) then _
'      if isCanAppr then _
          GetTypeFileArr = array("Приложение","Скан документа")   
    case "STATUS_CONTRACT_CLOSED"
'      if isAuth then _
          GetTypeFileArr = array("Приложение","Скан документа")
    case "STATUS_CONTRACT_SIGNED"
      if isSign or isAuth then _
          GetTypeFileArr = array("Приложение","Скан документа")
  end select
end function

Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
'ThisApplication.AddNotify "Object_PropertiesDlgBeforeClose - Start - " & Time
  Obj.Permissions = SysAdminPermissions
  
  guid = Obj.GUID
  Set dict = ThisApplication.Dictionary(guid)
  
  If OkBtnPressed = True Then
    Cancel = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckBeforeClose",Obj)
    If Cancel Then Exit Sub
      Call Set_ATTR_DATA(Obj)
      Call Set_StartEndATTR_DATA(Obj)
      Obj.SaveChanges
  Else
    NeedSave = False
'    If Dict.Exists("ATTR_TENDER") Then NeedSave = True
    
    If Obj.Permissions.Edit <> 1 Then
'    If Obj.StatusName = "STATUS_CONTRACT_AGREED" or Obj.StatusName = "STATUS_CONTRACT_FOR_SIGNING" Then
      If dict.Exists("ATTR_DATA") or dict.Exists("ATTR_STARTDATE_PLAN") or dict.Exists("ATTR_ENDDATE_PLAN") Then
        ans = msgbox("Сохранить изменения?",vbQuestion+vbYesNo,"Сохранить изменения")
        If ans = vbYes Then
          Call Set_ATTR_DATA(Obj)
'          Call Set_StartEndATTR_DATA(Obj)
          Obj.SaveChanges
'          NeedSave = True
        End If
      End If
    End If
'    Obj.SaveChanges
'    If NeedSave Then Obj.SaveChanges
  End If
  
  
'    'If OkBtnPressed Then
'    Call Set_StartEndATTR_DATA(Obj)
'    'End If
''  If Obj.StatusName = "STATUS_CONTRACT_DRAFT" Then
''    If OkBtnPressed Then
''      Call Set_StartEndATTR_DATA(Obj)
''    End If
'  If Obj.StatusName = "STATUS_CONTRACT_AGREED" or Obj.StatusName = "STATUS_CONTRACT_FOR_SIGNING" Then
'    If OkBtnPressed Then
'      Call Set_ATTR_DATA(Obj)
'    Else
'      If dict.Exists("ATTR_DATA") or dict.Exists("ATTR_STARTDATE_PLAN") or dict.Exists("ATTR_ENDDATE_PLAN") Then
'        ans = msgbox("Сохранить изменения?",vbQuestion+vbYesNo,"Сохранить изменения")
'        If ans = vbYes Then
'          Call Set_ATTR_DATA(Obj)
'          Obj.SaveChanges
'        End If
'      End If
'    End If
'  ElseIf Obj.StatusName = "STATUS_CONTRACT_SIGNED" Then
'    
'    If dict.Exists("ATTR_DATA") or dict.Exists("ATTR_STARTDATE_PLAN") or dict.Exists("ATTR_ENDDATE_PLAN") Then
'      ans = msgbox("Сохранить изменения?",vbQuestion+vbYesNo,"Сохранить изменения")
'      If ans = vbYes Then
'        Call Set_ATTR_DATA(Obj)
'        Call Set_StartEndATTR_DATA(Obj)
'        Obj.SaveChanges
'      End If
'    End If
'  Else
'    Call Set_StartEndATTR_DATA(Obj)
'    If Not OkBtnPressed Then
'      If dict.Exists("ATTR_STARTDATE_PLAN") or dict.Exists("ATTR_ENDDATE_PLAN") Then
'        ans = msgbox("Сохранить изменения?",vbQuestion+vbYesNo,"Сохранить изменения")
'        If ans = vbYes Then
'          Obj.SaveChanges
'        End If
'      End If
'    End If
'  End If
'  If dict.Exists("ATTR_TENDER") Then dict.Remove("ATTR_TENDER") 
  If dict.Exists("ATTR_DATA") Then dict.Remove("ATTR_DATA") 
  If dict.Exists("ATTR_STARTDATE_PLAN") Then dict.Remove("ATTR_STARTDATE_PLAN") 
  If dict.Exists("ATTR_ENDDATE_PLAN") Then dict.Remove("ATTR_ENDDATE_PLAN") 
'  If OkBtnPressed Then
  If Obj.StatusName = "STATUS_EDIT" Then
    If Obj.Permissions.LockOwner = True Then
      If Obj.Attributes("ATTR_PREVIOUS_STATUS").Empty = False Then
        If ThisApplication.Statuses.Has(Obj.Attributes("ATTR_PREVIOUS_STATUS").Value) Then
          Obj.Status = ThisApplication.Statuses(Obj.Attributes("ATTR_PREVIOUS_STATUS").Value)
          Obj.Attributes("ATTR_PREVIOUS_STATUS").Value = ""
          Obj.SaveChanges
          Obj.Unlock Obj.Permissions.LockType
        End If
      End If
    End If
  End If
'  ThisApplication.AddNotify "Object_PropertiesDlgBeforeClose - End - " & Time

  if obj.permissions.view <> 0 then
    if thisObject.Permissions.LockOwner then 
      if ThisObject.Permissions.Locked = true Then 
        ThisObject.Unlock ThisObject.Permissions.LockType
      end if
    end if
  end if
End Sub

'Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
'ThisApplication.AddNotify "Object_PropertiesDlgBeforeClose - Start - " & Time
'  Obj.Permissions = SysAdminPermissions
'  If OkBtnPressed = True Then
'    Cancel = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckBeforeClose",Obj)
'    If Cancel Then Exit Sub
'  End If
'  guid = Obj.GUID
'  Set dict = ThisApplication.Dictionary(guid)
'    'If OkBtnPressed Then
'    Call Set_StartEndATTR_DATA(Obj)
'    'End If
''  If Obj.StatusName = "STATUS_CONTRACT_DRAFT" Then
''    If OkBtnPressed Then
''      Call Set_StartEndATTR_DATA(Obj)
''    End If
'  If Obj.StatusName = "STATUS_CONTRACT_AGREED" or Obj.StatusName = "STATUS_CONTRACT_FOR_SIGNING" Then
'    If OkBtnPressed Then
'      Call Set_ATTR_DATA(Obj)
'    Else
'      If dict.Exists("ATTR_DATA") or dict.Exists("ATTR_STARTDATE_PLAN") or dict.Exists("ATTR_ENDDATE_PLAN") Then
'        ans = msgbox("Сохранить изменения?",vbQuestion+vbYesNo,"Сохранить изменения")
'        If ans = vbYes Then
'          Call Set_ATTR_DATA(Obj)
'          Obj.SaveChanges
'        End If
'      End If
'    End If
'  ElseIf Obj.StatusName = "STATUS_CONTRACT_SIGNED" Then
'    Call Set_ATTR_DATA(Obj)
'    Call Set_StartEndATTR_DATA(Obj)
'    If dict.Exists("ATTR_DATA") or dict.Exists("ATTR_STARTDATE_PLAN") or dict.Exists("ATTR_ENDDATE_PLAN") Then
'      ans = msgbox("Сохранить изменения?",vbQuestion+vbYesNo,"Сохранить изменения")
'      If ans = vbYes Then
'        Obj.SaveChanges
'      End If
'    End If
'  Else
'    Call Set_StartEndATTR_DATA(Obj)
'    If Not OkBtnPressed Then
'      If dict.Exists("ATTR_STARTDATE_PLAN") or dict.Exists("ATTR_ENDDATE_PLAN") Then
'        ans = msgbox("Сохранить изменения?",vbQuestion+vbYesNo,"Сохранить изменения")
'        If ans = vbYes Then
'          Obj.SaveChanges
'        End If
'      End If
'    End If
'  End If
'  
'  If dict.Exists("ATTR_DATA") Then dict.Remove("ATTR_DATA") 
'  If dict.Exists("ATTR_STARTDATE_PLAN") Then dict.Remove("ATTR_STARTDATE_PLAN") 
'  If dict.Exists("ATTR_ENDDATE_PLAN") Then dict.Remove("ATTR_ENDDATE_PLAN") 
''  If OkBtnPressed Then
'  If Obj.StatusName = "STATUS_EDIT" Then
'    If Obj.Permissions.LockOwner = True Then
'      If Obj.Attributes("ATTR_PREVIOUS_STATUS").Empty = False Then
'        If ThisApplication.Statuses.Has(Obj.Attributes("ATTR_PREVIOUS_STATUS").Value) Then
'          Obj.Status = ThisApplication.Statuses(Obj.Attributes("ATTR_PREVIOUS_STATUS").Value)
'          Obj.Attributes("ATTR_PREVIOUS_STATUS").Value = ""
'          Obj.SaveChanges
'          Obj.Unlock
'        End If
'      End If
'    End If
'  End If
'  ThisApplication.AddNotify "Object_PropertiesDlgBeforeClose - End - " & Time
'End Sub


function CanIssueOrder(DocObj)
'  CanIssueOrder = false
  ' Даем возможность выдавать поручения в любом статусе (совещание от 26.12.2017. Кейс 6280)
'  docStat = DocObj.StatusName
'  str = ";STATUS_CONTRACT_DRAFT;STATUS_CONTRACT_COMPLETION;STATUS_CONTRACT_PAUSED;STATUS_CONTRACT_SIGNED;STATUS_KD_AGREEMENT;"
'  if Instr(";" & str & ";", ";" & docStat & ";") > 0 then _
'      CanIssueOrder = true

'  docStat = DocObj.StatusName
'  excludestr = ";STATUS_CONTRACT_DRAFT;STATUS_CONTRACT_COMPLETION;STATUS_CONTRACT_PAUSED;STATUS_CONTRACT_SIGNED;STATUS_KD_AGREEMENT;"
'  if Instr(";" & excludestr & ";", ";" & docStat & ";") < 1 then _
'      CanIssueOrder = true
  CanIssueOrder = true
end function


Sub AfterAgreeProcessing(Obj)
  Call SendOrder1(Obj)
  Call SendMessage(Obj)
End Sub

' Отправка поручения подписанту
Sub SendOrder1(Obj)
  List = "ATTR_SIGNER"
  
  arr = Split(List,",")
  
  For each ar In arr
    If Obj.Attributes.Has(ar) Then
      Set uToUser = Obj.Attributes(ar).User
      If Not uToUser Is Nothing Then
        Set uFromUser = Obj.Attributes("ATTR_AUTOR").User'ThisApplication.CurrentUser
        resol = "NODE_KD_SING"
        txt = Obj.Description
        planDate = DateAdd ("d", 1, Date) 'Date + 1
        ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
      End If
    End If
  Next
End Sub

'==============================================================================
' Отправка оповещения ответственному о возврате тома утверждающим
'------------------------------------------------------------------------------
' o_:TDMSObject - завизированный комплект
'==============================================================================
Private Sub SendMessage(Obj)
  
  'Оповещение пользователя
  Set u = Obj.Attributes("ATTR_SIGNER").User
  If Not u Is Nothing Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1611, u, Obj, Nothing, Obj.Description, ThisApplication.CurrentUser.Description,ThisApplication.CurrentTime
  End If
  
'  If Not u Is Nothing Then
'    If uCol.Has(u) = False Then
'      uCol.Add u
'    End If
'  End If
  
  Set us = ThisApplication.Groups("GROUP_CONTRACTS_ISSUE").Users
'  Set uCol = ThisApplication.CreateCollection(tdmUsers)
  
  For each u In us
'    uCol.Add  u
'  Next
'  
'  For each u In uCol
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1613, u, Obj, Nothing, Obj.Description, ThisApplication.CurrentUser.Description,ThisApplication.CurrentTime
  Next
End Sub

function CopyAttrsFromDocBase(newObj, docBase)
  CopyAttrsFromDocBase = False
  If NewObj Is Nothing or docBase Is Nothing Then Exit Function
'  Set cp = docBase.Attributes("").User
  Set Table = NewObj.Attributes("ATTR_KD_TCP")
  
  Set NewRow = Table.Rows.Create
  
  If NewObj.ObjectDefName = "OBJECT_KD_DOC_OUT" Then
    ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F",newObj, "ATTR_KD_AGREENUM", docBase, False
    ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F",newObj, "ATTR_KD_WITHOUT_PROJ", False, False
    ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F",newObj, "ATTR_KD_ID_LINKCHKBX", 0, False
    ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F",NewRow, "ATTR_KD_CPNAME", GetContractor(docBase), False
  End If

  CopyAttrsFromDocBase = True
end function

Sub SyncCuratorToStages(Obj)
  ThisScript.SysAdminModeOn
  Set progress = ThisApplication.Dialogs.ProgressDlg
  Progress.position = 0
  Progress.Start
  
  Set q = ThisApplication.Queries("QUERY_CONTRACT_STAGES_BY_CONTRACT")
  q.Parameter("PARAM0") = Obj
  count = q.Objects.Count
  i=0
  For each oStage In q.Objects
    i = i + 1
    Progress.position = count* i/100
    progress.Text = "Обновление информации по этапам договора: " & i & " из " & count
    Call ThisApplication.ExecuteScript("OBJECT_CONTRACT_STAGE","SyncCuratorFromContract",oStage)
  Next
  Progress.position = 100
  Progress.Stop
End Sub


Function GetContractor(Obj)
  Set GetContractor = Nothing
  If IsEmpty(Obj) Then Exit Function
  If Obj Is Nothing Then Exit Function
  Set cls = Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier
  If cls Is Nothing Then Exit Function
  
  If cls.Description = "Доходный" Then
    Set GetContractor = Obj.Attributes("ATTR_CUSTOMER").Object
  ElseIf cls.Description = "Расходный" Then
    Set GetContractor = Obj.Attributes("ATTR_CONTRACTOR").Object
  End If
End Function

