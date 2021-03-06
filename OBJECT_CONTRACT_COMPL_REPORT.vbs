' Автор: Стромков С.А.
'
' Договор 
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016 г.

USE "CMD_S_DLL"
USE "CMD_DLL_ROLES"
USE "CMD_DLL_CONTRACTS"

Sub Object_BeforeCreate(Obj, Parent, Cancel)

  sysID = ThisApplication.ExecuteScript ("CMD_KD_REGNO_KIB","Get_Sys_Id",Obj)
  if sysID = 0 then 
      Cancel = true
      exit sub
  else  
    Obj.Attributes("ATTR_KD_IDNUMBER").value = sysID
  end if
  
  'Подписант
  ' Отключаем автозаполнение подписанта, т.к. за него действует ответственный бухгалтер
  ' 26.01.2018
'  Set User = ThisApplication.ExecuteScript("CMD_DLL", "SignerGet")
'  If not User is Nothing Then
'    Obj.Attributes("ATTR_SIGNER").User = User
'  End If
  
  
  If not Parent is Nothing Then
    If Parent.Attributes.Has("ATTR_CONTRACT_CLASS") Then
      If not Parent.Attributes("ATTR_CONTRACT_CLASS").Classifier is Nothing Then
        Set Clf = Parent.Attributes("ATTR_CONTRACT_CLASS").Classifier
        If Clf.Code = "-" Then
          Obj.Attributes("ATTR_CCR_INCOMING").Value = True ' Акт подрядчика
          'Проверяющий
          ' Проверяющего убрали с акта подрядчика 26.01.2018
'          Set User =  ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetChiefByID","ID_CCR_SIGNER")
'          Obj.Attributes("ATTR_USER_CHECKED").User = User
        ElseIf Clf.Code = "+" Then
          Obj.Attributes("ATTR_CCR_INCOMING").Value = False
        End If
      End If
    End If
  End If
  
  Call SetRoles(Obj)
  'Заполнение атрибутов
  Set Dict = ThisApplication.Dictionary(Obj.ObjectDefName)
  If Dict.Exists("Contract") Then
    ObjGuid = Dict.Item("Contract")
    Dict.Remove("Contract")
    Set MainObj = ThisApplication.GetObjectByGUID(ObjGuid)
    If not MainObj is Nothing Then
      Obj.Attributes("ATTR_CONTRACT").Object = MainObj

      ' Разовая сделка
      If MainObj.Attributes.Has("ATTR_CONTRACT_INCIDENTAL") Then
        If MainObj.Attributes("ATTR_CONTRACT_INCIDENTAL") = True Then
          Set cls = ThisApplication.Classifiers.FindBySysId("NODE_KD_ZA_SDELKA")
        Else
          Set cls = ThisApplication.Classifiers.FindBySysId("NODE_KD_ZA_DOGOVOR")
        End If
      Else
        Set cls = ThisApplication.Classifiers.FindBySysId("NODE_KD_ZA_DOGOVOR")
      End If
      If Not cls Is Nothing Then Obj.Attributes("ATTR_KD_ZA_MAINDOC").Classifier = cls
      'Входящий
      If MainObj.Attributes.Has("ATTR_CONTRACT_CLASS") Then
        If not MainObj.Attributes("ATTR_CONTRACT_CLASS").Classifier is Nothing Then
          Set Clf = MainObj.Attributes("ATTR_CONTRACT_CLASS").Classifier
          If Clf.Code = "-" Then
            Obj.Attributes("ATTR_CCR_INCOMING").Value = True
          ElseIf Clf.Code = "+" Then
            Obj.Attributes("ATTR_CCR_INCOMING").Value = False
          End If
        End If
      End If
            
      ' Заполняем контрагента
      Set Contractor =  GetContractContractor(MainObj)
      Obj.Attributes("ATTR_CONTRACTOR").Object = Contractor
    End If
  Else
  
  End If
End Sub

Sub ContextMenu_BeforeShow(Commands, Obj, Cancel)
  'Удаление команды Отправить на подпись
  If Obj.Attributes.Has("ATTR_CCR_INCOMING") Then
    If Obj.Attributes("ATTR_CCR_INCOMING").Value = True Then
      Commands.Remove ThisApplication.Commands("CMD_COCOREPORT_SEND_TO_SIGN")
    End If
  End If
  'Добавление команды Вернуть на доработку
  Check = False
  If Obj.StatusName = "STATUS_COCOREPORT_SIGNED" and Obj.Attributes.Has("ATTR_CCR_INCOMING") and _
  Obj.Attributes.Has("ATTR_IS_SIGNET_BY_CORRESPONDENT") Then
    If Obj.Attributes("ATTR_CCR_INCOMING").Value = False and _
    Obj.Attributes("ATTR_IS_SIGNET_BY_CORRESPONDENT").Value = False Then
      Check = True
    End If
  End If
  If Check = False Then Commands.Remove ThisApplication.Commands("CMD_COCOREPORT_BACK_TO_WORK")
End Sub


' Установка ролей
Private Sub SetRoles(Obj)
  'Устанавливаем роль Гип в соответствии с формой
  Obj.Permissions = SysAdminPermissions 
  Set u = ThisApplication.CurrentUser
  Set gAllUs = ThisApplication.Groups("ALL_USERS")
  
  Call ThisApplication.ExecuteScript("CMD_DLL", "DelDefRole",Obj,"ROLE_VIEW")
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetRole",Obj,"ROLE_VIEW",gAllUs)
  
  Call ThisApplication.ExecuteScript("CMD_DLL", "DelDefRole",Obj,"ROLE_RESPONSIBLE")
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetRole",Obj,"ROLE_RESPONSIBLE",u)
  
  Call ThisApplication.ExecuteScript("CMD_DLL", "DelDefRole",Obj,"ROLE_STRUCT_DEVELOPER")
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetRole",Obj,"ROLE_STRUCT_DEVELOPER",u)
  
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_AUTOR","ROLE_INITIATOR")
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_AUTOR","ROLE_AUTHOR")
End Sub

Sub Object_Created(Obj, Parent)
'  ' Автор
'  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_SIGNER","ROLE_SIGNER")
End Sub

Sub Object_StatusChanged(Obj, Status)
  If Status is Nothing Then Exit Sub
  ThisScript.SysAdminModeOn
  
  'Определение статуса после согласования
  StatusAfterAgreed = ""
  Set Rows = ThisApplication.Attributes("ATTR_AGREENENT_SETTINGS").Rows
  For Each Row in Rows
    If Row.Attributes("ATTR_KD_OBJ_TYPE").Value = Obj.ObjectDefName Then
      StatusAfterAgreed = Row.Attributes("ATTR_KD_FINISH_STATUS")
      Exit For
    End If
  Next
  'Отработка маршрутов для механизма согласования
  If Status.SysName = "STATUS_KD_AGREEMENT" or Status.SysName = StatusAfterAgreed Then
    If Obj.Dictionary.Exists("PrevStatusName") Then
      sName = Obj.Dictionary.Item("PrevStatusName")
      If ThisApplication.Statuses.Has(sName) Then
        Set PrevSt = ThisApplication.Statuses(sName)
        Call ThisApplication.ExecuteScript("CMD_ROUTER","RunNonStatusChange",Obj,PrevSt,Obj,Status.SysName) 
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
End Sub

Sub Object_StatusBeforeChange(Obj, Status, Cancel)
  ThisScript.SysAdminModeOn
  'Записываем текущий статус в словарь
  Obj.Dictionary.Item("PrevStatusName") = Obj.StatusName
End Sub

Sub Object_BeforeModify(Obj, Cancel)
ThisApplication.DebugPrint "Object_BeforeModify " & Time
  Call SetDescription(Obj)
    ' Автор
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_SIGNER","ROLE_SIGNER")
End Sub

Sub Object_PropertiesDlgInit(Dialog, Obj, Forms)
  Call ShowDefaultForm(Dialog, Obj, Forms)
  ' Закрываем информационные поручения 
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_CORR_REZOL_INF")
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_STAT_MAIN")
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_DEL_MAIN")
  ' отмечаем все поручения по документу прочитанными
  if obj.StatusName <> "STATUS_COCOREPORT_DRAFT" then _
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","Set_OrdersReaded",Obj
  
  'Для акта заказчика скрываем формы Согласование и Планирование оплаты
  CCRtype = Obj.Attributes("ATTR_CCR_INCOMING")
  Thisapplication.DebugPrint CCRtype
  If CCRtype = False Then
  ' Согласование
    If Dialog.InputForms.Has("FORM_KD_DOC_AGREE") Then
      Dialog.InputForms.Remove Dialog.InputForms("FORM_KD_DOC_AGREE")
    End If
    ' Планирование оплаты
    If Dialog.InputForms.Has("FORM_CCR_ZA_PAYMENT(1)") Then
      Dialog.InputForms.Remove Dialog.InputForms("FORM_CCR_ZA_PAYMENT(1)")
    End If
  End If
End Sub



'=============================================
' конечные статусы
' статусы из которых нельзя возвращать в работу
function Check_FinishStatus(stName)
  Check_FinishStatus = (stName = "STATUS_COCOREPORT_PAYMENT") or _
                        (stName = "STATUS_COCOREPORT_CHECKED") or _
                        (stName = "STATUS_COCOREPORT_EDIT") or _
                        (stName = "STATUS_COCOREPORT_INVALIDATED") or _
                        (stName = "STATUS_COCOREPORT_CLOSED")
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
  isInit  = IsInitiator(docObj,CU)
  isCanAppr = ThisApplication.ExecuteScript("CMD_KD_USER_PERMISSIONS","IsCanAprove",CU,docObj)

  st = docObj.StatusName
  select case st
    case "STATUS_COCOREPORT_DRAFT","STATUS_COCOREPORT_EDIT"
      if isAuth  then _
          GetTypeFileArr = array("Документ","Приложение","Скан документа")  
    case "STATUS_COCOREPORT_CHECK"
      if isChck then _
          GetTypeFileArr = array("Приложение","Скан документа")  
    case "STATUS_COCOREPORT_CHECKED"
      if isAuth  then _
          GetTypeFileArr = array("Приложение","Скан документа")  
    case "STATUS_COCOREPORT_FOR_SIGNING"
      if isSign or isAuth then _
          GetTypeFileArr = array("Приложение","Скан документа")  
    case "STATUS_COCOREPORT_SIGNED"
      if isAuth then _
          GetTypeFileArr = array("Приложение","Скан документа") 
    case "STATUS_KD_AGREEMENT"
      if isCanAppr then _
          GetTypeFileArr = array("Приложение","Скан документа")  
    case "STATUS_COCOREPORT_AGREED"
      if isAuth  then _
          GetTypeFileArr = array("Приложение","Скан документа")
    case "STATUS_COCOREPORT_PAYMENT"
      if isAuth  then _
          GetTypeFileArr = array("Приложение","Скан документа")
  end select
end function

function CanIssueOrder(DocObj)
'  CanIssueOrder = false
'  docStat = DocObj.StatusName
'  str = ";STATUS_COCOREPORT_SIGNED;STATUS_COCOREPORT_PAYMENT;"
'  if Instr(";" & str & ";", ";" & docStat & ";") > 0 then _
      CanIssueOrder = true
end function


Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
  If OkBtnPressed = True Then
    Cancel = Not CheckBeforeClose(Obj)
    If Cancel Then Exit Sub
    

  End If 
  Call Set_ATTR_DATA(Obj)
End Sub
