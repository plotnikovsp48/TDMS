' Тип объекта - Внешняя закупка
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.
USE "CMD_FILES_LIBRARY"
USE "CMD_KD_USER_PERMISSIONS"
Sub Object_BeforeErase(Obj, Cancel)
ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  If Obj.RolesForUser(CU).Has("ROLE_PURCHASE_RESPONSIBLE") = False and CU.SysName <> "SYSADMIN" Then
    Msgbox "Удалить объект может только ""Ответственный по закупке""", VbCritical
    Cancel = True
    Exit Sub
  End If
  ThisScript.SysAdminModeOff
End Sub

Sub Object_BeforeCreate(Obj, Parent, Cancel)
  ThisScript.SysAdminModeOn
'  Создавать внешние закупки может только группа управления тендерной документацией
  If ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsGroupMember",ThisApplication.CurrentUser,"GROUP_TENDER") = False Then
    msgbox "У вас не достаточно прав на создание внешней закупки.",vbCritical,"Создание внешней закупки"
    Cancel = True
    Exit Sub
  End If
   ' - Электронная закупка
  Obj.Attributes("ATTR_TENDER_ONLINE") = True 
   ' - Состояние
  AttrName = "ATTR_TENDER_POS"
  If Obj.Attributes.Has(AttrName) Then
    Obj.Attributes(AttrName).value = "Закупка создана в системе"
  End If
  ' Дата получения информации - приравниваем к текущей
    Obj.Attributes("ATTR_TENDER_INFO_GET_TIME").Value = Date
  ' Получаем ID   
  sysID = ThisApplication.ExecuteScript ("CMD_KD_REGNO_KIB","Get_Sys_Id",Obj)
  if sysID = 0 then 
      Cancel = true
      exit sub
  else  
    Obj.Attributes("ATTR_KD_IDNUMBER").value = sysID
  end if
  Call SetAttrs(Obj)
  
  'Маршрут
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Parent,Parent.Status,Obj,Obj.ObjectDef.InitialStatus)
End Sub

Sub Object_Modified(Obj)
  ThisScript.SysAdminModeOn
  
  'Переводим в текст список подрядных организаций
   Tbl = "ATTR_TENDER_SUBCONTRACT_PRICE_TABLE" ' Таблица
   Atrstr = "ATTR_TENDER_ADDITIONAL_CONTRACTOR" ' Графы
   AttrTo = "ATTR_TENDER_SUBCONTRACT_ORG_LIST" ' Текстовый атрибут
   Excl = "ATTR_TENDER_MEMBER" ' Исключаем Организацию 
   TablStrToStr = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","TablStrToStr",ThisObject, Tbl, Atrstr, AttrTo) 
 'Сумма стоимости договоров подрядных организаций
   Tbl = "ATTR_TENDER_SUBCONTRACT_PRICE_TABLE" ' Таблица
   Atrstr = "ATTR_TENDER_CONTRACTOR_DIAL_PRICE" ' Графы
   AttrTo = "ATTR_TENDER_SUBCONTRACT_SUM" ' Текстовый атрибут
   
   TablStrValCalc = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","TablStrValCalc",Obj, Tbl, Atrstr, AttrTo) 
'  msgbox Obj.Attributes(AttrTo)
  'Сумма стоимости договора общества  
   AttrFr = "ATTR_TENDER_OFFERS_PRICE"
   Val = Obj.Attributes(AttrFr).value - Obj.Attributes(AttrTo).value
   AttrTo = "ATTR_TENDER_DIAL_PRICE" ' Текстовый атрибут
   Call ThisApplication.ExecuteScript("CMD_DLL","SETATTR_F",Obj,AttrTo,Val,True)
   'Процент стоимости договоров подрядных организаций
   Tbl = "ATTR_TENDER_SUBCONTRACT_PRICE_TABLE" ' Таблица
   Atrstr = "ATTR_TENDER_PERCENT" ' Графы
   AttrTo = "ATTR_TENDER_PERCENT" ' Текстовый атрибут
   TablStrPerCalc = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","TablStrValCalc",ThisObject, Tbl, Atrstr, AttrTo) 
  'Процент стоимости Организации  
   Val = (100.00 - Obj.Attributes("%").value)
   Call ThisApplication.ExecuteScript("CMD_DLL","SETATTR_F",Obj,"ATTR_TENDER_ORG_PRICE_PART",Val,True)
   'Стоимость договоров участников
   Tbl = "ATTR_TENDER_COMPETITOR_PRICE_TABLE" ' Таблица
   Atrstr = "ATTR_TENDER_CLIENT_NAME,ATTR_TENDER_DIAL_PRICE" ' Графы
   AttrTo = "ATTR_TENDER_COMPETITOR_PRICE_LIST" ' Текстовый атрибут
   TablStrPerCalc = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","TablStrToStr",ThisObject, Tbl, Atrstr, AttrTo) 
  'Модификация роли "Инициатор согласования"
'  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","InitiatorModified",Obj,"")
  ThisApplication.Dictionary(Obj.GUID).Item("ObjEdit") = False
  
  
End Sub

'Событие Изменение статуса
'----------------------------------------------
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
' Call SendOrderStatusChanged(Obj)
End Sub

Sub Object_PropertiesDlgInit(Dialog, Obj, Forms)
  Set CU = ThisApplication.CurrentUser
   ThisScript.SysAdminModeOn
 'Помечаем прочитанные поручения. Проверка отключена т.к. ответственный может назначаться в начальном статусе
'  if obj.StatusName <> "STATUS_T_TASK_IN_WORK" then _
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","Set_OrdersReaded",Obj
'    End if 
  
  ' отмечаем все поручения по документу прочитанными
  if obj.StatusName <> "STATUS_TENDER_OUT_PLANING" then _
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","Set_OrdersReaded",Obj
    ' Скрываем прочитанные поручения
     Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_CORR_REZOL_INF")
     Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_STAT_MAIN")
    Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_DEL_MAIN")
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","Set_OrdersReaded",Obj
        
  'Доступность формы Согласование
'  FormName = "FORM_KD_DOC_AGREE"
'  AttrName = "ATTR_AGREEMENT_ENABLED"
'  If Dialog.InputForms.Has(FormName) and Obj.Attributes.Has(AttrName) Then
'    If Obj.Attributes(AttrName) = False Then
'      Dialog.InputForms.Remove(FormName)
'    End If
'  End If
  
  'Определение активной формы
'  If Obj.Dictionary.Exists("FormActive") Then
'    FormName = Obj.Dictionary.Item("FormActive")
'    If Dialog.InputForms.Has(FormName) Then
'      Dialog.ActiveForm = Dialog.InputForms(FormName)
'    End If
'    Obj.Dictionary.Remove("FormActive")
'  End If



Set CU = ThisApplication.CurrentUser
  If Obj.Dictionary.Exists("FormActive") Then
    FormName = Obj.Dictionary.Item("FormActive")
    If Dialog.InputForms.Has(FormName) Then
      Dialog.ActiveForm = Dialog.InputForms(FormName)
    End If
    Obj.Dictionary.Remove("FormActive")
  Else
    Dialog.ActiveForm = Dialog.InputForms("FORM_TENDER_OUTSIDE_MAIN")
 
  '  Для всех в статусе "На согласовании" активная форма Документ.Согласование
   If Obj.StatusName = "STATUS_KD_AGREEMENT" Then
    Dialog.ActiveForm = Dialog.InputForms("FORM_KD_DOC_AGREE")
   End If
 End If
End Sub

'Событие До изменения статуса
'----------------------------------------------
Sub Object_StatusBeforeChange(Obj, Status, Cancel)
  ThisScript.SysAdminModeOn
  sNameOld = Obj.StatusName
  sNameNew = ""
  If not Status is Nothing Then
    sNameNew = Status.SysName
  End If
  
  'Записываем текущий статус в словарь
  Obj.Dictionary.Item("PrevStatusName") = sNameOld
  Obj.Attributes("ATTR_PREVIOUS_STATUS").Value = sNameOld
  
'  If sNameOld = "STATUS_KD_AGREEMENT" Then
'    'Скрываем форму Согласование

'    AttrName = "ATTR_AGREEMENT_ENABLED"
'    If Obj.Attributes.Has(AttrName) Then
'      If Obj.Attributes(AttrName).Value = True Then Obj.Attributes(AttrName).Value = False
'    End If
'   End If
    
      'При переходе из статуса Плановая в статус Одобрена, назначается роль Инициатора согласования Ответственному Группы
'    If sNameNew = "STATUS_TENDER_OUT_ADD_APPROVED" and sNameOld = "STATUS_TENDER_OUT_PLANING"  Then
''     
'      AttrName = "ATTR_TENDER_RESP_OUPPKZ"
'      RoleName = "ROLE_INITIATOR"
'      Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName)
'        If not User is Nothing Then
'        Set Roles = Obj.RolesForUser(User)
'         If Roles.Has(RoleName) = False Then
'         Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,User)
'       End If
'    End If
'   End If
      
    'При переходе из статуса На утверждении в статус Разработка документации, назначается роль Ответственному за мат., Куратору и ПЭО
    
'    ' Отв. за материалы
'    If sNameNew = "STATUS_TENDER_OUT_IN_WORK" Then 'and sNameOld = "STATUS_KD_AGREEMENT" 
'      AttrName = "ATTR_TENDER_DOC_RESP"
'      RoleName = "ROLE_TENDER_MATERIAL_RESP"
'      Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName)
'      If not User is Nothing Then
'       ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,User,"ROLE_TENDER_MATERIAL_RESP,ROLE_INITIATOR" 'Роли
'      End If
'    ' Куратор
'      AttrName = "ATTR_TENDER_CURATOR"
'      RoleName = "ROLE_TENDER_MATERIAL_RESP"
'      Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName)
'      If not User is Nothing Then
'      ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,User,"ROLE_TENDER_MATERIAL_RESP,ROLE_INITIATOR" 'Роли

'    End If
' 'Руководителю ПЭО
' ' Отв. за материалы
'      AttrName = "ATTR_TENDER_PEO_CHIF"
'      RoleName = "ROLE_TENDER_KP_DESI"
'      Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,"ROLE_TENDER_KP_DESI")
'      If not User is Nothing Then
'      ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,User,"ROLE_TENDER_KP_DESI,ROLE_INITIATOR" 'Роли Руководителю ПЭО
'        Set Roles = Obj.RolesForUser(User)
'        If Roles.Has(RoleName) = False Then
'          Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,User.SysName)
'        End If
'       ' Инициатор согласования 
'       RoleName = "ROLE_INITIATOR"
'          If Roles.Has(RoleName) = False Then
'          Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,User.SysName)
'          End If
'      End If
'    End If
 
'  Выдача поручений   
 Call SendOrderStatusChanged(Obj,sNameOld,sNameNew)
End Sub

'Процедура задания значений атрибутам
Sub SetAttrs(Obj)
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  
  'Ответственное структурное подразделение за подготовку заявки
'  AttrName = "ATTR_TENDER_DEPT_RESP"
'  If Obj.Attributes.Has(AttrName) Then
'    Set Dept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetDept", CU)
'    If not Dept is Nothing Then Obj.Attributes(AttrName).Object = Dept
'  End If
  
  'Ответственный руководитель (бывший Главный бухгалтер)
  AttrName = "ATTR_TENDER_ACC_CHIF"
  Set Dept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetDeptByID","ID_TENDER_INSIDE_DISTR_STRU_OBJ")
  If not Dept is Nothing Then
    Set User = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetChiefByDept",Dept)
    If not User is Nothing Then Obj.Attributes(AttrName).User = User
  End If
  
  'Руководитель группы
  AttrName = "ATTR_TENDER_GROUP_CHIF"
  If Obj.Attributes.Has(AttrName) Then
'    OrgName = "Группа по участию в конкурентных закупках"
 If not Dept is Nothing Then
     Set Dept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetDeptByID","ID_TENDER_OUT_DEPT")
     Set User = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetChiefByDept",Dept)
'    Set User = ThisApplication.ExecuteScript("CMD_DLL", "OrgUserGet", OrgName)
    If not User is Nothing Then Obj.Attributes(AttrName).User = User
  End If
  End If
  'Руководитель ПЭО
  AttrName = "ATTR_TENDER_PEO_CHIF"
  If Obj.Attributes.Has(AttrName) Then
    OrgName = "Планово-экономический отдел"
    Set User = ThisApplication.ExecuteScript("CMD_DLL", "OrgUserGet", OrgName)
    If not User is Nothing Then Obj.Attributes(AttrName).User = User
  End If
  
  'Ответственный за  подготовку закупочной документации
'  AttrName = "ATTR_TENDER_DOC_RESP"
'  If Obj.Attributes.Has(AttrName) Then
'    Set Dept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetDept", CU)
'    If not Dept is Nothing Then
'      Set User = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetChiefByDept", Dept)
'      Obj.Attributes(AttrName).User = User
'    End If
'  End If
  
'Добавляем пользователй по умолчанию в списки поручений 
  Set p = Obj.Parent
  If Not p Is Nothing Then  
    Call ThisApplication.ExecuteScript("CMD_DLL","AttrsSyncBetweenObjs",p,Obj,"ATTR_TENDER_OUT_FLOW_CASTOM")
    Call ThisApplication.ExecuteScript("CMD_DLL","AttrsSyncBetweenObjs",p,Obj,"ATTR_TENDER_OUT_ORDER_TO_WORK_CASTOM")
  End If
End Sub
  'Контекстное меню
'  ---------------------------------------------------------
Sub ContextMenu_BeforeShow(Commands, Obj, Cancel)
  ThisScript.SysAdminModeOn
  Set cU = ThisApplication.CurrentUser
  Set cG = CU.Groups
  Set cR = Obj.RolesForUser(cU)
  sName = Obj.StatusName
  pStatus = Obj.Attributes("ATTR_PREVIOUS_STATUS").Value
  AttrName = "ATTR_TENDER_STATUS"
  AttrStatus = False
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      If not Obj.Attributes(AttrName).Classifier is Nothing Then
        If Obj.Attributes(AttrName).Classifier.Code = 2 Then AttrStatus = True
      End If
    End If
  End If
  
  'Утвердить участие
  RoleName = "ROLE_PURCHASE_RESPONSIBLE"
  Check = True
  If cR.Has(RoleName) Then
    If sName = "STATUS_TENDER_OUT_ADD_APPROVED" and pStatus = "STATUS_KD_AGREEMENT" Then
      Check = False
    ElseIf sName = "STATUS_TENDER_OUT_IS_APPROVING" Then
      Check = False
    End If
  End If
  If Check = True Then
    Commands.Remove ThisApplication.Commands("CMD_TENDER_OUT_GO_WORK_APPROVE")
  End If
  
  'Передать в работу
  RoleName = "ROLE_PURCHASE_RESPONSIBLE"
  Check = True
  If cR.Has(RoleName) Then
    If sName = "STATUS_TENDER_OUT_APPROVED" and AttrStatus = False Then
      Check = False
    ElseIf sName = "STATUS_TENDER_OUT_IS_APPROVING" and AttrStatus = True Then
      Check = False
    End If
  End If
End Sub


'=============================================================================================================
' Процедуры для закрытия закупки
'=============================================================================================================

'Часть основной процедуры после выбора причины закрытия
Sub PurchaseCloseBySelect(Obj,CU,u0,u1,u2,u3,StatusName,Clf,Val)
ThisApplication.DebugPrint "PurchaseCloseBySelect " & Time
Set Doc = Nothing
  Set Clfs = ThisApplication.Classifiers("NODE_TENDER_ORDER_STATUS").Classifiers.Find("Внешняя закупка")
  AttrName = "ATTR_TENDER_FINISH_PROTOCOL"
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      If not Obj.Attributes(AttrName).Object is Nothing Then
        Set Doc = Obj.Attributes(AttrName).Object
      End If
    End If
  End If
  'Проверка атрибутов
  Str = PurchaseCloseAttrsCheck(Obj,u0,u1,u2)
  If Str <> "" Then
    Msgbox "Обязательные атрибуты " & Str & " не заполнены", vbExclamation
    Result = False
    Exit Sub
  End If
  
  Select Case Val
    'Не выбрано
    Case "FALSE"
      Exit Sub
    'Выиграна
    Case "ATTR_TENDER_STATUS_WIN"
      StatusName = "STATUS_TENDER_WIN"
      If not Clfs is Nothing Then Set Clf = Clfs.Classifiers.Find("4")
    'Проиграна
    Case "ATTR_TENDER_STATUS_LOST"
      StatusName = "STATUS_TENDER_LOST"
      If not Clfs is Nothing Then Set Clf = Clfs.Classifiers.Find("5")
    'Отменена
    Case "ATTR_TENDER_STATUS_CLOSE"
      StatusName = "STATUS_TENDER_CLOSE"
      If not Clfs is Nothing Then Set Clf = Clfs.Classifiers.Find("3")
  End Select
   If Val = "ATTR_TENDER_STATUS_CLOSE" Then
   ans = msgbox("Закрыть закупку как отмененную?",vbQuestion+vbYesNo,"Закрытие закупки")
  If ans <> vbYes Then
  Set Clf = Nothing
  exit Sub
  End If
   Msgbox "Закупка закрыта как отмененная." ,vbInformation
   End If
  If Val = "ATTR_TENDER_STATUS_WIN" or Val = "ATTR_TENDER_STATUS_LOST" Then
    If Doc is Nothing Then
      Msgbox "Заполните поле Протокол подведения итогов", vbExclamation
      StatusName = ""
      Set Clf = Nothing
      Exit Sub
    Else
    If Val = "ATTR_TENDER_STATUS_WIN" Then
     ans = msgbox("Закрыть закупку как выигранную?",vbQuestion+vbYesNo,"Закрытие закупки")
     If ans <> vbYes Then
      Set Clf = Nothing
      exit Sub
     End If
      flagWin = True
'      Msgbox "Закупка закрыта как выигранная." ,vbInformation
    End If
    If Val = "ATTR_TENDER_STATUS_LOST" Then
'    ThisApplication.DebugPrint "ATTR_TENDER_STATUS_LOST" & Time
      ans = msgbox("Закрыть закупку как проигранную?",vbQuestion+vbYesNo,"Закрытие закупки")
      If ans <> vbYes Then
        Set Clf = Nothing
        exit Sub
      End If
'      Msgbox "Закупка закрыта как проигранная." ,vbInformation
      flagWin = False
    End If
     
      'Создание поручений
      ThisApplication.Utility.WaitCursor = True
'      If not Doc is Nothing Then
  '      OrgName = "Отдел по договорной работе и закупочным процедурам"
  '      Set u3 = ThisApplication.ExecuteScript("CMD_DLL", "OrgUserGet", OrgName)
  '      Resol = "NODE_CORR_REZOL_INF"
  '      ObjType = "OBJECT_KD_ORDER_NOTICE"
  '      Txt = "Прошу ознакомиться с результатами участия в закупке"
  '      Str = ""
  '      PlanDate = Date + 2
'        Call PurchaseCloseOrderNotice(Doc,Resol,ObjType,Txt,PlanDate,Str,CU,u0)
'        Call PurchaseCloseOrderNotice(Doc,Resol,ObjType,Txt,PlanDate,Str,CU,u1)
'        Call PurchaseCloseOrderNotice(Doc,Resol,ObjType,Txt,PlanDate,Str,CU,u2)
'        'Call PurchaseCloseOrderNotice(Doc,Resol,ObjType,Txt,PlanDate,Str,CU,u3)
        str = SendOrder(Obj,u0,u1,u2,flagWin)
        ThisApplication.Dictionary("CMD_TENDER_OUT_CLOSE").RemoveAll
'      End If
      ThisApplication.Utility.WaitCursor = False
      
      If Str <> "" Then
        Msgbox "Закупка закрыта." & chr(10) & chr(10) & "Пользователям: " & chr(10) & chr(10) & Str & chr(10) & chr(10) & "выдано поручение для ознакомления с результатами.",vbInformation
      End If
    End If
  End If
End Sub

Function SendOrder(Obj,u0,u1,u2,FlagWin)
ThisApplication.DebugPrint "SendOrder -  " & FlagWin & "-" & Time
  Str = ""
  Set CU = ThisApplication.CurrentUser
  Set Doc = Nothing
  AttrName = "ATTR_TENDER_FINISH_PROTOCOL"
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      If not Obj.Attributes(AttrName).Object is Nothing Then
        Set Doc = Obj.Attributes(AttrName).Object
      End If
    End If
  End If

  If doc Is Nothing Then 
    Set doc = Obj
  End If
      'Создание поручений

If flagWin = True Then
    ThisApplication.DebugPrint "SendOrder1 -  " & FlagWin & "-" & Time
    ' В договорной отдел
    Set oDept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetDeptByID","ID_CONTRACT_CREATE")
    If Not oDept Is Nothing Then 
      Set uToUser = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetChiefByDept",oDept)
    End If
    ThisApplication.DebugPrint uToUser.Description
'    str = str & chr(10) & "-------------------------------------"
    Set uFromUser = CU
'    resol = "NODE_CORR_REZOL_POD"
'    ObjType = "OBJECT_KD_ORDER_REP"

    resol = "NODE_CORR_REZOL_OFO"
    ObjType = "OBJECT_KD_ORDER_NOTICE"
    
    txt = "Прошу подготовить Договор на основании закупки """ & Obj.Description & """"
    planDate = Date + 5
    Call PurchaseCloseOrderNotice(Obj,Resol,ObjType ,Txt,PlanDate,Str,CU,uToUser)
   'ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_REP",uToUser,uFromUser,resol,txt,planDate
   
  ' В центр мониторинга
    Set oDept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetDeptByID","ID_MONIT_CENTER")
    If Not oDept Is Nothing Then 
      Set uToUser = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetChiefByDept",oDept)
    End If
    ThisApplication.DebugPrint uToUser.Description
    Set uFromUser = CU
    resol = "NODE_CORR_REZOL_OFO"
    txt = "Прошу обеспечить проведение работ по заключению Договора на основании закупки """ & Obj.Description & """"
    planDate = Date + 5
    Call PurchaseCloseOrderNotice(Obj,Resol,ObjType,Txt,PlanDate,Str,CU,uToUser)
   
   ' Руководителю ПЭО
     Set uToUser = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",ThisObject,"ATTR_TENDER_PEO_CHIF")
     Set uFromUser = CU
    resol = "NODE_CORR_REZOL_OFO"
    txt = "Прошу ознакомиться с результатами участия в закупке """ & Obj.Description & """"
    planDate = Date + 5
    Call PurchaseCloseOrderNotice(Obj,Resol,ObjType,Txt,PlanDate,Str,CU,uToUser)
   
  End If
  
      OrgName = "Отдел по договорной работе и закупочным процедурам"
      Set u3 = ThisApplication.ExecuteScript("CMD_DLL", "OrgUserGet", OrgName)
      Resol = "NODE_CORR_REZOL_INF"
      ObjType = "OBJECT_KD_ORDER_NOTICE"
      Txt = "Прошу ознакомиться с результатами участия в закупке"
      
      PlanDate = Date + 2

        Call PurchaseCloseOrderNotice(Doc,Resol,ObjType,Txt,PlanDate,Str,CU,u0)
        Call PurchaseCloseOrderNotice(Doc,Resol,ObjType,Txt,PlanDate,Str,CU,u1)
        Call PurchaseCloseOrderNotice(Doc,Resol,ObjType,Txt,PlanDate,Str,CU,u2)
        'Call PurchaseCloseOrderNotice(Doc,Resol,ObjType,Txt,PlanDate,Str,CU,u3)
  

 
  ' Ответственному за  подготовку закупочной документации
  Set uToUser = Obj.Attributes("ATTR_TENDER_DOC_RESP").User
  Set uFromUser = CU
  resol = "NODE_CORR_REZOL_INF"
  txt = "Прошу ознакомиться с результатами участия в закупке """ & doc.Description & """"
  planDate = ""
  Call PurchaseCloseOrderNotice(doc,Resol,"OBJECT_KD_ORDER_NOTICE",Txt,PlanDate,Str,uFromUser,uToUser)
  'ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,planDate
  
   ' Ответственному руководителю
  Set uToUser = Obj.Attributes("ATTR_TENDER_ACC_CHIF").User
  Set uFromUser = CU
  resol = "NODE_CORR_REZOL_INF"
  txt = "Прошу ознакомиться с результатами участия в закупке """ & doc.Description & """"
  planDate = ""
  Call PurchaseCloseOrderNotice(doc,Resol,"OBJECT_KD_ORDER_NOTICE",Txt,PlanDate,Str,uFromUser,uToUser)

  

 ' Пользователям в списке 
  Set uFromUser = CU
  resol = "NODE_CORR_REZOL_INF"
  txt = "Прошу ознакомиться с результатами участия в закупке """ & doc.Description & """"
  planDate = ""
  If Obj.Attributes.Has("ATTR_TENDER_OUT_FLOW_CASTOM") = False Then
    Obj.Attributes.Create ThisApplication.AttributeDefs("ATTR_TENDER_OUT_FLOW_CASTOM")
  End If
  
  Tbl =  "ATTR_TENDER_OUT_FLOW_CASTOM"
  Atr = "ATTR_RESPONSIBLE"
  GetUnicUserList = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","GetUnicUserList",Obj, Tbl, Atr)
'  msgbox GetUnicUserList
  Users = Split(GetUnicUserList,",") 
  For n = 0 to Ubound(Users)
        UserSys = Users(n) 
        set uToUser = ThisApplication.Users(UserSys)
        If Not uToUser Is Nothing Then
         If uToUser.SysName <> uFromUser.SysName Then
          Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,"ROLE_VIEW",uToUser)
          Call PurchaseCloseOrderNotice(doc,Resol,"OBJECT_KD_ORDER_NOTICE",Txt,PlanDate,Str,uFromUser,uToUser)
         End If
        End If        
      next 
 
 
  
'  Set Table =  Obj.Attributes("ATTR_TENDER_OUT_FLOW_CASTOM")
'  If Not Table Is Nothing Then
'  set rows = Table.Rows
'  End If  
'  If Not rows Is Nothing Then
'  
''    str = str & chr(10)  & "-------------------------------------"
'    for each row in rows  
'    'Выдача поручений
'      If row.Attributes.Has("ATTR_RESPONSIBLE") Then
'        If row.Attributes("ATTR_RESPONSIBLE").Empty = False Then
'          set uToUser = row.Attributes("ATTR_RESPONSIBLE").user
'          If Not uToUser Is Nothing Then
'            If uToUser.SysName <> uFromUser.SysName Then
'              Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,"ROLE_VIEW",uToUser)
'                Call PurchaseCloseOrderNotice(doc,Resol,"OBJECT_KD_ORDER_NOTICE",Txt,PlanDate,Str,uFromUser,uToUser)
'             End If
'          End If
'        End If
'      End If
'    Next
'  End If

  SendOrder = str
End Function

'Процедура создания поручения
Sub PurchaseCloseOrderNotice(Doc,Resol,ObjType,Txt,PlanDate,Str,CU,u)
  If not u is Nothing and ThisApplication.Dictionary("CMD_TENDER_OUT_CLOSE").Exists(u.SysName) = False Then
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Doc,ObjType,u,CU,Resol,Txt,PlanDate
    ThisApplication.Dictionary("CMD_TENDER_OUT_CLOSE").Item(u.SysName) = True
    If u.SysName <> CU.SysName Then
      If Str <> "" Then
        Str = Str & ", " & chr(10) & u.Description
      Else
        Str = u.Description
      End If
    End If
  End If
End Sub

'Процедура создания поручения
Sub ContractPrepareOrderNotice(Doc,Resol,ObjType,Txt,PlanDate,Str,CU,u)
  If u is Nothing Then Exit Sub
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Doc,ObjType,u,CU,Resol,Txt,PlanDate
    ThisApplication.Dictionary("CMD_TENDER_OUT_CLOSE").Item(u.SysName) = True
    If u.SysName <> CU.SysName Then
      If Str <> "" Then
        Str = Str & ", " & chr(10) & u.Description
      Else
        Str = u.Description
      End If
    End If
End Sub

'Внесение изменений в объект
Sub PurchaseCloseRoute(Obj,StatusName,Clf)
  'Статус в атрибуте
  AttrName = "ATTR_TENDER_STATUS"
  If not Clf is Nothing and Obj.Attributes.Has(AttrName) Then
    Obj.Attributes(AttrName).Classifier = Clf
  End If
  'Маршрут
  If StatusName <> "" Then
    RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
    If RetVal = -1 Then
      Obj.Status = ThisApplication.Statuses(StatusName)
    End If
  End If
End Sub

'Проверка заполненности атрибутов
Function PurchaseCloseAttrsCheck(Obj,u0,u1,u2)
  PurchaseCloseAttrsCheck = ""
  Str = ""
  AttrName0 = "ATTR_TENDER_KP_DESI"
  AttrName1 = "ATTR_TENDER_ACC_CHIF"
  AttrName2 = "ATTR_TENDER_DOC_RESP"
  
  Check = False
  If Obj.Attributes.Has(AttrName0) Then
    If Obj.Attributes(AttrName0).Empty = False Then
      If not Obj.Attributes(AttrName0).User is Nothing Then
        Check = True
        Set u0 = Obj.Attributes(AttrName0).User
      End If
    End If
  End If
  If Check = False Then
    If Str <> "" Then
      Str = Str & ", " & ThisApplication.AttributeDefs(AttrName0).Description
    Else
      Str = ThisApplication.AttributeDefs(AttrName0).Description
    End If
  End If
  
  Check = False
  If Obj.Attributes.Has(AttrName1) Then
    If Obj.Attributes(AttrName1).Empty = False Then
      If not Obj.Attributes(AttrName1).User is Nothing Then
        Check = True
        Set u1 = Obj.Attributes(AttrName1).User
      End If
    End If
  End If
  If Check = False Then
    If Str <> "" Then
      Str = Str & ", " & ThisApplication.AttributeDefs(AttrName1).Description
    Else
      Str = ThisApplication.AttributeDefs(AttrName1).Description
    End If
  End If
  
  Check = False
  If Obj.Attributes.Has(AttrName2) Then
    If Obj.Attributes(AttrName2).Empty = False Then
      If not Obj.Attributes(AttrName2).User is Nothing Then
        Check = True
        Set u2 = Obj.Attributes(AttrName2).User
      End If
    End If
  End If
  If Check = False Then
    If Str <> "" Then
      Str = Str & ", " & ThisApplication.AttributeDefs(AttrName2).Description
    Else
      Str = ThisApplication.AttributeDefs(AttrName2).Description
    End If
  End If
  
  If Str <> "" Then PurchaseCloseAttrsCheck = Str
End Function

'=============================================================================================================
' Процедуры для выгрузки файлов из документов закупки
'=============================================================================================================

'==============================================================================
' Функция предоставляет диалог выбора папки
'------------------------------------------------------------------------------
' GetFolder:String - Полный путь к выбранной папке
'==============================================================================
Private Function GetFolder()
  GetFolder = ""
  On Error Resume Next
  Set objShellApp = CreateObject("Shell.Application")
  Set objFolder = objShellApp.BrowseForFolder(0, "Выберите папку для выгрузки файлов", 0)
  If Err.Number <> 0 Then
    MsgBox "Папка не выбрана!", vbInformation
  Else
    GetFolder = objFolder.Self.Path
  End If
End Function

'Процедура выгрузки файлов из документов закупки
'Obj:Object - Ссылка на закупку
'Count:Int - Счетчик выгруженных файлов
'Path:String - Путь выгрузки файлов
Sub PurchaseDocsFilesUpload(Obj,Count,Path)
  'Список документов
  Set Query = ThisApplication.Queries("QUERY_TENDER_OUT_UPLOAD_FILES")
  Query.Parameter("OBJ") = Obj
  Query.Parameter("PUBLIC") = True
  Set Docs = Query.Objects

  'Проверка на наличие документов
  If Docs.Count = 0 Then
    Msgbox "Нет документов для выгрузки." & chr(10) & "Действие отменено.",vbExclamation
    Exit Sub
  End If
  
  'Выбор документов
  Set Dlg = ThisApplication.Dialogs.SelectDlg
  Dlg.UseCheckBoxes = True
  Dlg.SelectFrom = Docs
  Dlg.Caption = "Выбор документов для выгрузки"
  If Dlg.Show = False Then Exit Sub
  Set Docs = Dlg.Objects
  If Docs.Count = 0 Then Exit Sub
  
  'Запрос папки для выгрузки
  Path = GetFolder
  
  'Выгрузка файлов в папку
  If Path <> "" Then
    Set FSO = CreateObject("Scripting.FileSystemObject")
    'Создание папки
    FolderName = ""
    If Obj.Attributes.Has("ATTR_TENDER_CONCURENT_NUM_EIS") Then
      FolderName = Obj.Attributes("ATTR_TENDER_CONCURENT_NUM_EIS").Value
      Str = Chr(34) & " * : < > ? / \ |"
      Arr = Split(Str, " ")
      For i = 0 to Ubound(Arr)
        If InStr(FolderName,Arr(i)) <> 0 Then
          FolderName = ""
          Msgbox "Номер конкурентной закупки содержит недопустимые символы для создания папки (" &Str& ")",vbExclamation
          Exit For
        End If
      Next
    End If
    If FolderName <> "" Then
      Path = Path & "\" & FolderName
      If Len(Path) < 256 and FSO.FolderExists(Path) = False Then
        FSO.CreateFolder Path
      End If
    End If
    
    For Each Doc in Docs
      Set Query = ThisApplication.Queries("QUERY_FILES_IN_DOC")
      Query.Parameter("OBJ") = Doc
      Set Files = Query.Files
      For Each File in Files
        If Right(Path,1) = "\" Then
          fName = Path & File.FileName
        Else
          fName = Path & "\" & File.FileName
        End If
        Ext = Right(fName,Len(fName)-InStrRev(fName,"."))
        shortName = Left(fName, InStrRev(fName, ".")-1)
        i = 1
        Do While FSO.FileExists(fName)
          fName = shortName & " (" & i & ")." & Ext
          i = i + 1
        Loop
        on Error Resume Next
        File.CheckOut fName
        If Err.Number = 0 Then Count = Count + 1
        On Error GoTo 0
      Next
    Next
    If Count = 0 Then
      Msgbox "Не найдены файлы для выгрузки. Действие отменено.", vbExclamation
      Exit Sub
    End If
  Else
    Exit Sub
  End If
End Sub

function Check_FinishStatus(stName)
  Check_FinishStatus = (stName = "STATUS_TENDER_WIN") or _
                        (stName = "STATUS_TENDER_LOST") or _
                        (stName = "STATUS_TENDER_CLOSE") or _
                        (stName = "STATUS_S_INVALIDATED")
end function


'Функция ограничения типов файлов для загрузки в объект по статусам и ролям
function GetTypeFileArr(docObj)
  Set CU = ThisApplication.CurrentUser
  isSin = isResp(ThisApplication.CurrentUser) or isChif(CU,docObj)
  isCanAppr = ThisApplication.ExecuteScript("CMD_KD_USER_PERMISSIONS","IsCanAprove",CU,docObj)
  
  st = docObj.StatusName
  select case st
    case "STATUS_TENDER_OUT_PLANING" 'Плановая
      if IsExecutor(thisApplication.CurrentUser, docObj)  then _
          GetTypeFileArr = array("Файл")  
    case "STATUS_TENDER_OUT_ADD_APPROVED" 'Одобрена
      if IsController(thisApplication.CurrentUser, docObj) then _
          GetTypeFileArr = array("Файл")  
    case "STATUS_KD_AGREEMENT" 'На согласовании
      if isCanAppr then _
          GetTypeFileArr = array("Файл")  
    case "STATUS_TENDER_OUT_AGREED" 'Согласовано
      if isCanAppr then _
          GetTypeFileArr = array("Файл")     
    case "STATUS_TENDER_OUT_IN_WORK" 'Разработка документации 
      if isCanAppr then _
          GetTypeFileArr = array("Файл") 
    case "STATUS_TENDER_OUT_IS_APPROVING" 'На утверждении 
      if isCanAppr then _
          GetTypeFileArr = array("Файл")   
    case "STATUS_TENDER_OUT_APPROVED" 'Утверждена 
      if isCanAppr then _
          GetTypeFileArr = array("Файл")          
    case "STATUS_TENDER_OUT_PUBLIC" 'Размещена на площадке
      if isCanAppr then _
          GetTypeFileArr = array("Файл")          
    case "STATUS_TENDER_WIN" 'Выиграна
      if isCanAppr then _
          GetTypeFileArr = array("Файл", "Документ")   
    case "STATUS_TENDER_LOST" 'Проиграна
      if isCanAppr then _
          GetTypeFileArr = array("Файл")   
  end select
end function

function isResp(user)
  isResp = user.Groups.Has("GROUP_TENDER")
end function


function isChif(user, docObj)
  isChif = false
  if not docObj.Attributes.has("ATTR_TENDER_GROUP_CHIF") then exit function
  set singer = docObj.Attributes("ATTR_TENDER_GROUP_CHIF").user
  if singer is nothing then exit function
  isChif = (singer.SysName = user.SysName)
end function



'Функция создания поручения при смене статуса
Sub SendOrderStatusChanged(Obj,sNameOld,sNameNew)

'При переходе в статус Разработка документации поручение Отв. за разработку, Куратору, ПЭО
  If sNameNew = "STATUS_TENDER_OUT_IN_WORK" and  sNameOld = "STATUS_TENDER_OUT_IS_APPROVING" Then
   If not Obj.Attributes("ATTR_TENDER_KP_DESI").Empty = True Then
         Set uToUser = Obj.Attributes("ATTR_TENDER_KP_DESI").User
         If uToUser Is Nothing Then Exit Sub
         Set uFromUser = ThisApplication.CurrentUser
         resol = "NODE_CORR_REZOL_POD"
         ObjType = "OBJECT_KD_ORDER_NOTICE"
         txt = "Вы назначены ответственным за подготовку материалов по закупке """ & Obj.Description & """ пользователем" & uFromUser.Description
         planDate = Date
   End If
     If not Obj.Attributes("ATTR_TENDER_CURATOR").Empty = True Then
         Set uToUser = Obj.Attributes("ATTR_TENDER_CURATOR").User
         If uToUser Is Nothing Then Exit Sub
         Set uFromUser = ThisApplication.CurrentUser
         resol = "NODE_CORR_REZOL_POD"
         ObjType = "OBJECT_KD_ORDER_NOTICE"
         txt = "Вы назначены Куратором по закупке """ & Obj.Description & """ пользователем" & uFromUser.Description
         planDate = Date
   End If
  End If    


If sNameOld = "STATUS_KD_AGREEMENT" and sNameNew = "STATUS_TENDER_OUT_IS_APPROVING" Then ' Obj.StatusName = "STATUS_TENDER_IN_PUBLIC" Then
'  Определяем состояние - Утверждение участия, размещения, уторговывания
  AttrStatus = 0
  AttrGlobalStatus = ""
  AttrName0 = "ATTR_TENDER_STATUS"
  AttrName1 = "ATTR_TENDER_GLOBAL_STATUS"
  If Obj.Attributes.Has(AttrName0) Then
    If Obj.Attributes(AttrName0).Empty = False Then
      If not Obj.Attributes(AttrName0).Classifier is Nothing Then
        AttrStatus = Obj.Attributes(AttrName0).Classifier.Code
      End If
    End If
  End If
  If Obj.Attributes.Has(AttrName1) Then
    If Obj.Attributes(AttrName1).Empty = False Then
      If not Obj.Attributes(AttrName1).Classifier is Nothing Then
        AttrGlobalStatus = Obj.Attributes(AttrName1).Classifier.SysName
      End If
    End If
  End If
'  AttrStatus - На рассмотрении, поданная, отмененная, выигранная, проигранная
'  AttrGlobalStatus - Участвуем, Не участвуем

'Если согласовано участие - поручение Ответственному группы, или Руководителю группы от Текущего пользователя для согласования участия
'Если согласовано размещение поручение Сотруднику Группы от Текущего пользователя 
'Если согласовано уторговывание - поручение Сотруднику Группы от Руководителя группы для проведения процедуры уторговывания


'   If sNameNew = "STATUS_TENDER_OUT_IS_APPROVING" Then 
   
    
     If Obj.Attributes(AttrName1).Empty = True and (Obj.Attributes(AttrName0).Empty = True or AttrStatus = 1) Then
         Set uToUser = Obj.Attributes("ATTR_TENDER_RESP_OUPPKZ").User 
         If uToUser Is Nothing Then Set uToUser = Obj.Attributes("ATTR_TENDER_GROUP_CHIF").User
         If uToUser Is Nothing Then Exit Sub
         Set uFromUser = ThisApplication.CurrentUser
'         resol = "NODE_CORR_REZOL_POD"
          resol = "NODE_CORR_REZOL_INF"
          ObjType = "OBJECT_KD_ORDER_NOTICE"
         txt = "Закупка """ & Obj.Description & """ прошла согласование участия. Прошу ознакомить с результатами Генерального директора для принятия окончательного решения."
         planDate = Date + 3
     End If 

     if AttrGlobalStatus = "NODE_MAIN_TENDER_CONSDITION_YES" and AttrStatus = 1 Then 
     
'        Set uToUser = Obj.Attributes("ATTR_TENDER_GROUP_CHIF").User
         Set uToUser = Obj.Attributes("ATTR_TENDER_RESP_OUPPKZ").User 
         If uToUser Is Nothing Then Set uToUser = Obj.Attributes("ATTR_TENDER_GROUP_CHIF").User
         If uToUser Is Nothing Then Exit Sub
         Set uFromUser = ThisApplication.CurrentUser
'        Set uFromUser = Obj.Attributes("ATTR_TENDER_CURATOR").User
         resol = "NODE_CORR_REZOL_POD"
         ObjType = "OBJECT_KD_ORDER_NOTICE"
         txt = "Прошу подготовить и разместить заявку по закупке """ & Obj.Description & """"
         planDate = Date + 1
     End If    

     if AttrGlobalStatus = "NODE_MAIN_TENDER_CONSDITION_YES" and AttrStatus = 2 Then 

         Set uToUser = Obj.Attributes("ATTR_TENDER_RESP_OUPPKZ").User
         Set uFromUser = Obj.Attributes("ATTR_TENDER_GROUP_CHIF").User
         If uToUser Is Nothing Then
         Set uToUser = Obj.Attributes("ATTR_TENDER_GROUP_CHIF").User
         Set uFromUser = ThisApplication.CurrentUser
         End If
         If uFromUser Is Nothing Then Set uFromUser = ThisApplication.CurrentUser
         If uFromUser Is Nothing Then Exit Sub
         If uToUser Is Nothing Then Exit Sub
         If uFromUser.SysName = uToUser.SysName Then Set uFromUser = ThisApplication.CurrentUser
         If uFromUser.SysName = uToUser.SysName Then Set uFromUser = Obj.Attributes("ATTR_TENDER_ACC_CHIF").User
         If uFromUser Is Nothing Then Exit Sub
         If uToUser Is Nothing Then Exit Sub
         resol = "NODE_CORR_REZOL_POD"
         ObjType = "OBJECT_KD_ORDER_NOTICE"
         txt = "Прошу провести процедуру участия в уторговывании по закупке""" & Obj.Description & """"
         planDate = Date + 1
      End If
     
       ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,uToUser,uFromUser,resol,txt,planDate
       
    
   End If 
   
      
   'Если возвращено с согласования участия в Одобрена - поручение Ответственному группы, или Руководителю группы от текущего пользователя Закупка не прошла согласование участия.
'    Прошу ознакомить с результатами Генерального директора для принятия окончательного решения.
'    Если возвращено с согласования размещения - поручение Куратору закупки и Отв КП/НКП Прошу внести изменения согласно результатам согласования
    'Если возвращено с согласования уторговывания - поручение Сотруднику Группы от Руководителя группы закрыть закупку как проигравшую
   
  If sNameOld = "STATUS_KD_AGREEMENT" and sNameNew <> "STATUS_TENDER_OUT_IS_APPROVING" Then ' Obj.StatusName = "STATUS_TENDER_IN_PUBLIC" Then
'   AttrName = "ATTR_TENDER_STATUS_EIS"
'    If Obj.Attributes.Has(AttrName) Then
'     Stat = Obj.Attributes(AttrName).Value   
'      If Obj.Attributes(AttrName).Empty = True Then 
    If sNameNew = "STATUS_TENDER_OUT_ADD_APPROVED" Then 
       Set uToUser = Obj.Attributes("ATTR_TENDER_RESP_OUPPKZ").User 
       If uToUser Is Nothing Then _
         Set uToUser = Obj.Attributes("ATTR_TENDER_GROUP_CHIF").User
       If uToUser Is Nothing Then Exit Sub 
       
       Set uFromUser = Obj.Attributes("ATTR_TENDER_ACC_CHIF").User       
       If uFromUser Is Nothing Then Set uFromUser = ThisApplication.CurrentUser
       resol = "NODE_CORR_REZOL_POD"
       ObjType = "OBJECT_KD_ORDER_NOTICE"
       txt = "Закупка """ & Obj.Description & """ не прошла согласование участия. Прошу ознакомить с результатами Генерального директора для принятия окончательного решения."
       planDate = Date + 3
    elseif sNameNew = "STATUS_TENDER_OUT_IN_WORK" Then 
       resol = "NODE_CORR_REZOL_POD"
       ObjType = "OBJECT_KD_ORDER_NOTICE"
       txt = "Прошу внести изменения согласно результатам согласования""" & Obj.Description & """"
       planDate = Date + 1
       Set uFromUser = Obj.Attributes("ATTR_TENDER_GROUP_CHIF").User
         ' Отв за КП НКП
       If Obj.Attributes("ATTR_TENDER_KP_DESI").Empty = False Then
       Set uToUser = Obj.Attributes("ATTR_TENDER_KP_DESI").User
        If not uToUser Is Nothing Then
        ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,uToUser,"ROLE_TENDER_KP_DESI,ROLE_INITIATOR" 'Роли Отв за КП НКП
        ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,uToUser,uFromUser,resol,txt,planDate
        End If
       End If
         'Роли Рук.ПЭО           
          Set Kp = Obj.Attributes("ATTR_TENDER_PEO_CHIF").User
          If not Kp Is Nothing Then ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,Kp,"ROLE_TENDER_KP_DESI,ROLE_INITIATOR," 'Роли Рук.ПЭО
          ' Куратору
         Set uToUser = Obj.Attributes("ATTR_TENDER_CURATOR").User
          'Создание роли куратору (слетает)
           If not uToUser Is Nothing Then ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,uToUser,"ROLE_TENDER_MATERIAL_RESP,ROLE_INITIATOR," 'Роли Отв
         'Отв за материалы         
          Set Mresp = Obj.Attributes("ATTR_TENDER_DOC_RESP").User
          If not Mresp Is Nothing Then ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,Mresp,"ROLE_TENDER_MATERIAL_RESP,ROLE_INITIATOR," 'Роли Отв.
     elseif sNameNew = "STATUS_TENDER_OUT_PUBLIC" Then 
         Set uToUser = Obj.Attributes("ATTR_TENDER_RESP_OUPPKZ").User
         If uToUser Is Nothing Then Exit Sub
         Set uFromUser = Obj.Attributes("ATTR_TENDER_GROUP_CHIF").User
         resol = "NODE_CORR_REZOL_POD"
         ObjType = "OBJECT_KD_ORDER_NOTICE"
         txt = "Прошу закрыть закупку как проигравшую""" & Obj.Description & """"
         planDate = Date + 1
     End If
       ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,uToUser,uFromUser,resol,txt,planDate
       
    End If 
End Sub


function CanIssueOrder(DocObj)
'  CanIssueOrder = false
'  docStat = DocObj.StatusName
'  str = ";STATUS_TENDER_OUT_PLANING;STATUS_TENDER_OUT_ADD_APPROVED;STATUS_TENDER_OUT_IS_APPROVING;" &_
'  "STATUS_TENDER_OUT_APPROVED;STATUS_TENDER_OUT_IN_WORK;STATUS_TENDER_OUT_PUBLIC;STATUS_KD_AGREEMENT;"
'  if Instr(";" & str & ";", ";" & docStat & ";") > 0 then _
      CanIssueOrder = true
end function


function CopyAttrsFromDocBase(newObj, docBase)
  CopyAttrsFromDocBase = False
  
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F",newObj, "ATTR_KD_PR_TYPEDOC", "NODE_KD_PR_DIRECT", False
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F",newObj, "ATTR_KD_WITHOUT_PROJ", True, False
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F",newObj, "ATTR_KD_TOPIC", "Текст темы распоряжения", False
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F",newObj, "ATTR_CURATOR", docBase.Attributes("ATTR_TENDER_CURATOR").User, False
  
  CopyAttrsFromDocBase = True
end function
