' Тип объекта - Внутренняя закупка
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.
USE "CMD_FILES_LIBRARY"
USE "CMD_KD_USER_PERMISSIONS"
Sub Object_BeforeCreate(Obj, Parent, Cancel)
  ThisScript.SysAdminModeOn
  
  If ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsGroupMember",ThisApplication.CurrentUser,"GROUP_TENDER_INICIATORS") = False Then
    msgbox "У вас не достаточно прав на создание внутренней закупки.",vbCritical,"Создание внутренней закупки"
    Cancel = True
    Exit Sub
  End If
  sysID = ThisApplication.ExecuteScript ("CMD_KD_REGNO_KIB","Get_Sys_Id",Obj)
  if sysID = 0 then 
      Cancel = true
      exit sub
  else  
    Obj.Attributes("ATTR_KD_IDNUMBER").value = sysID
  end if
  
  'Создание 1 строки в табличных атрибутах цены
  Call OneRowCreate(Obj,"ATTR_TENDER_ITEM_PRICE_MAX_VALUE")
  Call OneRowCreate(Obj,"ATTR_TENDER_INVITATION_PRICE_EIS")
  Call OneRowCreate(Obj,"ATTR_TENDER_WINER_PRICE")
  
  Call SetAttrs(Obj)

   
  'Маршрут
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Parent,Parent.Status,Obj,Obj.ObjectDef.InitialStatus)
End Sub

Sub Object_Modified(Obj)
  Call AttrsSync(Obj)
  'Модификация роли "Инициатор согласования"
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","InitiatorModified",Obj,"")
  'Заполнение текстового атрибута "Код ОБД НСИ победителя"
  Call ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","SetOBDNC",Obj)
End Sub

'Процедура синхронизации атрибутов с информационной картой
Sub AttrsSync(Obj)
  ThisScript.SysAdminModeOn
  For Each Child in Obj.Content
    If Child.ObjectDefName = "OBJECT_PURCHASE_DOC" Then
      If Child.Attributes.Has("ATTR_PURCHASE_DOC_TYPE") Then
        If StrComp(Child.Attributes("ATTR_PURCHASE_DOC_TYPE").Value,"Информационная карта",vbTextCompare) = 0 Then
          AttrStr = "ATTR_TENDER_FACT_MATERIAL_TAKE_OFF_DATA,ATTR_TENDER_ITEM_PRICE_MAX_VALUE," &_
          "ATTR_NDS_VALUE,ATTR_LOT_NDS_VALUE,ATTR_TENDER_START_END_WORK_DATA,ATTR_TENDER_INVOCE_PUBLIC_DATA," &_
          "ATTR_TENDER_ADVANCE_PLAN_PAY,ATTR_TENDER_ADDITIONAL_REQUIREMENTS,ATTR_TENDER_BID_REQUIREMENTS," &_
          "ATTR_TENDER_GUARANTEE_REQUIREMENTS,ATTR_TENDER_RF_CONF_REQUIREMENTS_DOC_LIST," &_
          "ATTR_TENDER_EXPERIENCE_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_PERSONAL_CONF_REQUIREMENTS_DOC_LIST," &_
          "ATTR_TENDER_RIG_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_ISO9001_REQUIREMENTS,ATTR_TENDER_ADDITIONAL_INFORMATION"
          ThisApplication.ExecuteScript "CMD_DLL","AttrsSyncBetweenObjs", Obj, Child, AttrStr
        End If
      End If
    End If
  Next
End Sub

Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
  ThisScript.SysAdminModeOn
  'Выключение режима редактора
  If not Obj.Status is Nothing Then
    If Obj.StatusName = "STATUS_FULLACCESS" Then
      If Obj.Attributes.Has("ATTR_ORIGINAL_STATUS_NAME") Then
        If Obj.Attributes("ATTR_ORIGINAL_STATUS_NAME").Empty = False Then
          If ThisApplication.Statuses.Has(Obj.Attributes("ATTR_ORIGINAL_STATUS_NAME").Value) Then
            Obj.Status = ThisApplication.Statuses(Obj.Attributes("ATTR_ORIGINAL_STATUS_NAME").Value)
          End If
        End If
      End If
    End If
  End If
  Set Roles = Obj.RolesByDef("ROLE_FULLACCESS")
  For Each Role in Roles
    Roles.Remove Role
  Next
  
  If OkBtnPressed = True Then
    'Проверка цены
    'If Obj.Dictionary.Exists("CheckNdsPrice") Then
    '  Obj.Dictionary.Remove "CheckNdsPrice"
    '  Check = PriceWithNDScheck(Obj)
    '  If Check = False Then
    '    Key = Msgbox("Превышен предел отклонения цены от запланированной. Запустить согласование?", vbQuestion+vbYesNo)
    '    If Key = vbYes Then
    '      Call ThisApplication.ExecuteScript("CMD_TENDER_IN_GO_MATCHING", "Main", Obj)
    '    Else
    '      Cancel = True
    '      Exit Sub
    '    End If
    '  End If
    'End If
    
    'Проверка значения атрибута Номер ППЗ
     Set CU = ThisApplication.CurrentUser
   If not CU.Groups.Has("GROUP_TENDER_INSIDE") = False Then
    AttrName = "ATTR_TENDER_PPZ_NUM"
    If Obj.Attributes.Has(AttrName) and OkBtnPressed = True Then
      Num = Trim(Replace(Obj.Attributes(AttrName).Value," ",""))
      If Len(Num) <> 10 And Len(Num)<>0 Then
        msgbox "Неверно заполнен атрибут """ & ThisApplication.AttributeDefs(AttrName).Description & """" _
                & chr(10) & "Должно быть 10 символов.",vbExclamation
        Cancel = True
        Exit Sub
      ElseIf Len(Num)<>0 Then
        If IsNumeric(Num) <> True Then
          msgbox "Неверно заполнен атрибут """ & ThisApplication.AttributeDefs(AttrName).Description & """" _
                & chr(10) & "Должно быть 10 символов.",vbExclamation
          Cancel = True
          Exit Sub
        End If
      End If
    End If
   End If 
    'Проверка значения атрибута Номер извещения в ЕИС
    AttrName = "ATTR_TENDER_NUM_EIS"
    If Obj.Attributes.Has(AttrName) Then
     If not Obj.Attributes(AttrName).Empty then
      Num = Obj.Attributes(AttrName).Value
      If Len(Num) <> 11 and Num <> 0 Then
        msgbox "Неверно заполнен атрибут """ & ThisApplication.AttributeDefs(AttrName).Description & """" _
                & chr(10) & "Должно быть 11 символов.",vbExclamation
         Cancel = True
        Exit Sub
      End If
    End If
   End If
    'Проверка атрибута "Раздел Плана"
    AttrName = "ATTR_TENDER_PLAN_PART_NAME"
    If Obj.Attributes.Has(AttrName) Then
      If Obj.Attributes(AttrName).Empty Then
        Msgbox "Не заполнен обязательный атрибут """ & ThisApplication.AttributeDefs(AttrName).Description & """", VbCritical
        Cancel = True
        Exit Sub
      End If
    End If
  End If
  
  
   'Заполнение текстового атрибута "Коды ОБД НСИ поставщиков"
    TablToStr = ""
    TablToStr = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","TablToStr",ThisObject, "ATTR_TENDER_POSSIBLE_CLIENT", "ATTR_COR_USER_CORDENT", "ATTR_OBDNSI")
    AttrName = "ATTR_TENDER_IN_CLIENT_OBDNC_LIST"
    If Obj.Attributes.Has(AttrName) Then Obj.Attributes(AttrName) = TablToStr
    
     
   ' разблокируем Инф карту, если заблокирована
  Set Doc = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","InfoDocGet",ThisObject)
  Set CU = ThisApplication.CurrentUser
   If not Doc is Nothing Then
    If Doc.Permissions.Locked = True Then
     If not Doc.Permissions.LockUser is nothing Then
      If Doc.Permissions.LockUser.SysName = CU.SysName Then
      do while Doc.Permissions.Locked <> false
      Doc.Unlock Doc.Permissions.LockType 
      loop
' msgbox "С объекта" & Doc.Permissions.LockType
      End If 
     End If 
    End If
   End If
 
  ThisScript.SysAdminModeOff
End Sub

'Редактирование меню КМ
'----------------------------------------------------
Sub ContextMenu_BeforeShow(Commands, Obj, Cancel)
  Set CU = ThisApplication.CurrentUser
  ConcurentNum = ""
  If Obj.Attributes.Has("ATTR_TENDER_CONCURENT_NUM_EIS") Then
    ConcurentNum = Obj.Attributes("ATTR_TENDER_CONCURENT_NUM_EIS").Value
  End If
  
  'Удаление команды Редактировать
  If CU.Groups.Has("GROUP_TENDER_INSIDE") = False or Obj.StatusName = "STATUS_TENDER_DRAFT" or _
  Obj.StatusName = "STATUS_TENDER_IS_MATCHING" Then
    Commands.Remove ThisApplication.Commands("CMD_PURCHASE_INSIDE_FULLEDIT")
  End If
  
  'Удаление команды Добавить лот
  Set User = ThisApplication.ExecuteScript("CMD_DLL", "OrgUserGet", "Группа планирования и проведения конкурентных закупок")
  Set Roles = Obj.RolesForUser(CU)
  Check = False
  If Obj.StatusName <> "STATUS_TENDER_DRAFT" and Obj.StatusName <> "STATUS_TENDER_IN_WORK" Then
    Check = True
  ElseIf Obj.StatusName = "STATUS_TENDER_DRAFT" Then
    If Roles.Has("ROLE_TENDER_INICIATOR") = False and Roles.Has("ROLE_PURCHASE_RESPONSIBLE") = True Then
      If Not User Is Nothing Then
        If CU.SysName <> User.SysName Then
          Check = True
        End If
      End If
    End If
  ElseIf Obj.StatusName = "STATUS_TENDER_IN_WORK" Then
    If Not User Is Nothing Then
      If CU.SysName <> User.SysName or Roles.Has("ROLE_PURCHASE_RESPONSIBLE") = False Then
        Check = True
      End If
    Else
      If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") = False Then
        Check = True
      End If
    End If
  End If
  If Check = True Then Commands.Remove ThisApplication.Commands("CMD_TENDER_LOT_NEW")
  
  'Удаление команды Создать документ закупки
  Check = False
  If Obj.StatusName <> "STATUS_TENDER_DRAFT" and Obj.StatusName <> "STATUS_TENDER_IN_WORK" and _
  Obj.StatusName <> "STATUS_TENDER_IN_PUBLIC" Then
    Check = True
  ElseIf Obj.StatusName = "STATUS_TENDER_DRAFT" Then
    If Roles.Has("ROLE_TENDER_INICIATOR") = False Then Check = True
  ElseIf Obj.StatusName = "STATUS_TENDER_IN_PUBLIC" Then
    If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") = False Then Check = True
  End If
  If Check = True Then Commands.Remove ThisApplication.Commands("CMD_TENDER_DOC_NEW")
  
  'Удаление команды Взять в разработку
  'Check = True
  'If Obj.StatusName = "STATUS_TENDER_IN_PLAN" Then
  '  If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
  '    Check = False
  '  Else
  '    Set Dept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetDept", CU)
  '    If not Dept is Nothing Then
  '      If StrComp(Dept.Attributes("ATTR_NAME").Value,"Группа планирования и проведения конкурентных закупок",vbTextCompare) = 0 Then
  '        Check = False
  '      End If
  '    End If
  '  End If
  'End If
  'If Check = True Then Commands.Remove ThisApplication.Commands("CMD_TENDER_IN_GO_WORK")
  
  'Удаление команды Выгрузить файлы
  Check = False
  If Not User Is Nothing Then
    If CU.SysName <> User.SysName or Roles.Has("ROLE_PURCHASE_RESPONSIBLE") = False Then
      Check = True
    End If
  Else
    If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") = False Then
      Check = True
    End If
  End If
  If Check = True Then Commands.Remove ThisApplication.Commands("CMD_TENDER_IN_UPLOAD")
  
  'Удаление команды Загрузить протокол комиссии
  Check = False
  If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") = False or ConcurentNum = "" Then
    Check = True
  End If
  If Check = True Then Commands.Remove ThisApplication.Commands("CMD_TENDER_IN_PROTOCOL_LOAD")
  
  'Удаление команды Аннулировать
  Check = False
  If Obj.StatusName <> "STATUS_TENDER_IN_AGREED" and Obj.StatusName <> "STATUS_TENDER_IN_WORK" and _
    Obj.StatusName <> "STATUS_TENDER_IN_IS_APPROVING" Then
      Check = True
  Else
    If Not User Is Nothing Then
      If CU.SysName <> User.SysName and Obj.StatusName = "STATUS_TENDER_IN_AGREED" Then
        Check = True
      ElseIf CU.SysName <> User.SysName and Obj.StatusName = "STATUS_TENDER_IN_IS_APPROVING" Then
        Check = True
      End If
    End If
  End If
  If Check = True Then Commands.Remove ThisApplication.Commands("CMD_TENDER_IN_GO_INVALIDATED")
  
  'Удаление команды Утвердить размещение на площадке
  Check = False
  If Not User Is Nothing Then
    If CU.SysName <> User.SysName or Obj.StatusName <> "STATUS_TENDER_IN_IS_APPROVING" Then
      Check = True
    End If
  Else
    If Obj.StatusName <> "STATUS_TENDER_IN_IS_APPROVING" Then
      Check = True
    End If
  End If
  If Check = True Then Commands.Remove ThisApplication.Commands("CMD_TENDER_IN_APPROV")
  
  'Удаление команды Запланировать
  AttrName = "ATTR_TENDER_STATUS_EIS"
  'If CU.SysName <> User.SysName or Obj.StatusName <> "STATUS_TENDER_IN_AGREED" Then
  Check = True
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      Check = False
    End If
  End If
  If Check = False Then
    Commands.Remove ThisApplication.Commands("CMD_TENDER_IN_GO_PLAN")
  End If
  
  'Удаление команды Указать себя Ответственным по закупке
  Check = False
  If Obj.StatusName <> "STATUS_TENDER_IN_WORK" and Obj.StatusName <> "STATUS_TENDER_IN_PLAN" Then
    Check = True
  Else
    If Not User Is Nothing Then
      If CU.SysName <> User.SysName Then
        Check = True
      End If
    End If
  End If
  If Check = True Then Commands.Remove ThisApplication.Commands("CMD_TENDER_IN_TAKE_RESP")
  
  'Удаление команды На рассмотрение результатов
  Check = False
  Set u = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,"ATTR_TENDER_GROUP_CHIF")
  If Obj.StatusName = "STATUS_TENDER_IN_PUBLIC" Then
    If Obj.RolesForUser(CU).Has("ROLE_PURCHASE_RESPONSIBLE") Then
      Check = True
    ElseIf not u is Nothing Then
      If u.SysName = CU.SysName Then Check = True
    End If
  ElseIf Obj.StatusName = "STATUS_TENDER_IN_AGREED" and ConcurentNum <> "" Then
    If Obj.RolesForUser(CU).Has("ROLE_PURCHASE_RESPONSIBLE") Then
      Check = True
    ElseIf not u is Nothing Then
      If u.SysName = CU.SysName Then Check = True
    End If
  End If
  If Check = False Then Commands.Remove ThisApplication.Commands("CMD_TENDER_IN_GO_EXPERT")
  
  'Удаление команды Назначить ответственных
  'Check = False
  'If Obj.StatusName <> "STATUS_TENDER_IN_WORK" and Obj.StatusName <> "STATUS_TENDER_IN_PLAN" Then
  '  Check = True
  'ElseIf CU.SysName <> User.SysName Then
  '  Check = True
  'ElseIf Obj.StatusName = "STATUS_TENDER_IN_WORK" and Obj.RolesForUser(CU).Has("ROLE_PURCHASE_RESPONSIBLE") = False Then
  '  Check = True
  'End If
  'If Check = True Then Commands.Remove ThisApplication.Commands("CMD_TENDER_IN_NEW_RESP")
End Sub

 'Событие До удаления
Sub Object_BeforeErase(Obj, Cancel)
ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  If Obj.RolesForUser(CU).Has("ROLE_TENDER_INICIATOR") = False  and CU.SysName <> "SYSADMIN" Then
   If ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsGroupMember",CU,"GROUP_TENDER_INSIDE") = False Then
    Msgbox "Удалить объект может только ""Инициатор закупки""", VbCritical
    Cancel = True
    Exit Sub
  End If
 End If
  'Добавляем проверку наличествования состава (Лоты, Документы закупки)
' Check = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE","CheckContent",Obj)
' If Check = False Then
'    Key = Msgbox("Удалить закупку вместе с составом?",vbYesNo+vbQuestion)
'    If Key = vbNo Then
'    Cancel = true
'     Exit Sub
'     End If
'else
' call ThisApplication.ExecuteScript("CMD_DELETE_ALL","Main",ThisObject)
' 

  Obj.Permissions = SysAdminPermissions 
    For each Child in Obj.Content
      Child.Permissions = SysAdminPermissions 
      If Child.Content.Count > 0 Then Call DeleteContent(Child,Count)
      Child.Erase
      Count = Count + 1
    Next
' Msgbox "Удалено " & count & " объектов состава", vbInformation
' End If
  ThisScript.SysAdminModeOff
End Sub

'Событие Изменение статуса
Sub Object_StatusChanged(Obj, Status)
  If Status is Nothing Then Exit Sub
  ThisScript.SysAdminModeOn
  
'  If Status.SysName = "STATUS_TENDER_DRAFT" or Status.SysName = "STATUS_KD_AGREEMENT" Then
'   Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,"ATTR_TENDER_PEO_CHIF")  
'  Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,"ROLE_TENDER_KP_DESI",User.SysName)
'  Msgbox "" & RoleName & User.description ,vbExclamation
'  End If
  
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

'  call Object_StatusBeforeChange(Obj, Status, Cancel)
End Sub

Sub Object_StatusBeforeChange(Obj, Status, Cancel)
  ThisScript.SysAdminModeOn
  'Записываем текущий статус в словарь
  Obj.Dictionary.Item("PrevStatusName") = Obj.StatusName
  'Заполнение атрибута "Дата фактического предоставления материалов для подготовки закупочной документации"
  'If not Status is Nothing Then
  '  If Obj.StatusName <> Status.SysName and Status.SysName = "STATUS_TENDER_IN_AGREED" Then
  '    AttrName = "ATTR_TENDER_FACT_MATERIAL_TAKE_OFF_DATA"
  '    If Obj.Attributes.Has(AttrName) Then Obj.Attributes(AttrName).Value = Date
  '  End If
  'End If
  

'При переходе из статуса Черновик в статус На согласовании, назначается роль
  sNameOld = Obj.StatusName
  sNameNew = ""
  If not Status is Nothing Then
    sNameNew = Status.SysName
  End If
  
  If sNameOld = "STATUS_TENDER_DRAFT" Then
   If sNameNew = "STATUS_KD_AGREEMENT" Then
      AttrName = "ATTR_TENDER_PEO_CHIF"
      RoleName = "ROLE_TENDER_KP_DESI"
      Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName)
      If not User is Nothing Then
        Set Roles = Obj.RolesForUser(User)
        If Roles.Has(RoleName) = False Then
          Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,User.SysName)

'Msgbox "" & RoleName & User.description ,vbExclamation
        End If
      End If
    End If
  End If
 
 If sNameOld = "STATUS_KD_AGREEMENT" Then
  If sNameNew = "STATUS_TENDER_IN_AGREED" or sNameNew = "STATUS_TENDER_IN_PUBLIC" or sNameNew = "STATUS_TENDER_DRAFT" Then
    Call SendOrder(Obj,sNameOld,sNameNew) 'Поручения  
  End If
 End If
 
 
End Sub


 'Событие Открытие диалога свойств
Sub Object_PropertiesDlgShow(Obj, Cancel, Forms)
  'Очистка словаря
  ThisApplication.Dictionary(Obj.GUID).RemoveAll
End Sub

'Событие Открытие диалога свойств
Sub Object_PropertiesDlgInit(Dialog, Obj, Forms) 'По событию открытия свойств

' отмечаем все поручения по документу прочитанными
  if obj.StatusName <> "STATUS_TENDER_DRAFT" then _
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","Set_OrdersReaded",Obj
 'Проверка однострочности
'ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CheckOne",Obj,"ATTR_TENDER_WINER_PRICE" 
  'Создание 1 строки в табличных атрибутах цены / *перенес в создание
'  Call OneRowCreate(Obj,"ATTR_TENDER_ITEM_PRICE_MAX_VALUE")
'  Call OneRowCreate(Obj,"ATTR_TENDER_INVITATION_PRICE_EIS")
'  Call OneRowCreate(Obj,"ATTR_TENDER_WINER_PRICE")
  
  'Скрываем прочитанные поручения
     Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_CORR_REZOL_INF")
     Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_STAT_MAIN")
    Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_DEL_MAIN")
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","Set_OrdersReaded",Obj
        
  'Определение активной формы
  Set CU = ThisApplication.CurrentUser
  If Obj.Dictionary.Exists("FormActive") Then
    FormName = Obj.Dictionary.Item("FormActive")
    If Dialog.InputForms.Has(FormName) Then
      Dialog.ActiveForm = Dialog.InputForms(FormName)
    End If
    Obj.Dictionary.Remove("FormActive")
  '  Для всех в статусе "На согласовании" активная форма Документ.Согласование    
  ElseIf Obj.StatusName = "STATUS_KD_AGREEMENT" or (Obj.StatusName = "STATUS_TENDER_IN_PUBLIC" and Obj.Attributes("ATTR_TENDER_BARGAIN_FLAG") = True) Then
    Dialog.ActiveForm = Dialog.InputForms("FORM_KD_DOC_AGREE")
     '  Для группы, после передачи закупки на подготовку, делаем форму Материалы ЕИС по умолчанию
  ElseIf CU.Groups.Has("GROUP_TENDER_INSIDE") = True then
     If Obj.StatusName = "STATUS_TENDER_IN_IS_APPROVING" or Obj.StatusName = "STATUS_TENDER_IN_APPROVED" or _
     Obj.StatusName = "STATUS_TENDER_IN_PUBLIC" or Obj.StatusName = "STATUS_TENDER_CHECK_RESULT" Then
     Dialog.ActiveForm = Dialog.InputForms("FORM_TENDER_MATERIAL_EIS")
     End If
  ElseIf CU.Groups.Has("GROUP_TENDER_INSIDE") = True and Obj.StatusName = "STATUS_TENDER_IN_AGREED" and Obj.Attributes("ATTR_TENDER_BARGAIN_FLAG") = True Then
    Dialog.ActiveForm = Dialog.InputForms("FORM_TENDER_MATERIAL_EIS")
  ElseIf Obj.StatusName = "STATUS_TENDER_IN_AGREED" then 
      Dialog.ActiveForm = Dialog.InputForms("FORM_TENDER_INSIDE_MAIN")
  ElseIf Obj.StatusName = "STATUS_TENDER_IN_WORK" then 
      Dialog.ActiveForm = Dialog.InputForms("FORM_TENDER_INFORMATION_CARD")
  ElseIf Obj.StatusName = "STATUS_TENDER_DRAFT" then 
   Dialog.ActiveForm = Dialog.InputForms("FORM_TENDER_INSIDE_MAIN")   
  End If
   'Доступность формы Договор
  Set CU = ThisApplication.CurrentUser
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","FormAccessOffGropeInStr","FORM_TENDER_IN_DIAL", Obj, Dialog, "GROUP_CONTRACTS", CU ' По группам
  
  ' Доступность формы Материалы ЕИС 
'  StatusStr = "STATUS_TENDER_IN_IS_APPROVING,STATUS_TENDER_IN_AGREED,STATUS_TENDER_IN_APPROVED,STATUS_TENDER_IN_PUBLIC,STATUS_TENDER_CHECK_RESULT,STATUS_TENDER_END" 
'  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","FormAccessOffStatInStr","FORM_TENDER_MATERIAL_EIS", Obj, Dialog, StatusStr 'По статусам
  If not Obj.RolesForUser(CU).Has("ROLE_VIEW") Then 
'  Set Roles = Obj.RolesForUser(User)
'  If Roles.Has(RoleName) Then

  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","FormAccessOffGropeInStr","FORM_TENDER_MATERIAL_EIS", Obj, Dialog, "GROUP_TENDER_INSIDE", CU ' По группам
  End If
   ' Доступность формы Дополнительно 
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","FormAccessOffGropeInStr","FORM_TENDER_IN_EXTRA", Obj, Dialog, "GROUP_TENDER_INSIDE", CU 
 
  
   ' Доступность формы Информационная карта. Отключено скрытие для срочных закупок по требованию Протасова от 24.11
   If Obj.Attributes.Has("ATTR_TENDER_URGENTLY_FLAG") then
    If Obj.Attributes("ATTR_TENDER_URGENTLY_FLAG") <> True then
    ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","FormAccessOffGropeStatStr","FORM_TENDER_INFORMATION_CARD", Obj, Dialog,,"STATUS_TENDER_DRAFT", CU
    End If
   End If
 ' Доступность формы Материалы ЕИС. Отключено скрытие для срочных закупок по требованию Протасова от 24.11 
   If Obj.Attributes.Has("ATTR_TENDER_URGENTLY_FLAG") then
    If Obj.Attributes("ATTR_TENDER_URGENTLY_FLAG") <> True then
    ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","FormAccessOffGropeStatStr","FORM_TENDER_MATERIAL_EIS", Obj, Dialog,,"STATUS_TENDER_DRAFT", CU
    End If
   End If 
   
  End Sub
'---------------------------------------------------
'Создание 1 строки в табличном атрибуте
'---------------------------------------------------
Sub OneRowCreate(Obj,AttrName)
  ThisScript.SysAdminModeOn
  If Obj.Attributes.Has(AttrName) Then
    Set TableRows = Obj.Attributes(AttrName).Rows
    If TableRows.Count = 0 Then TableRows.Create
  End If
End Sub

'Функция проверки цены с НДС 
Function PriceWithNDScheck (Obj)
  PriceWithNDScheck = True
  If Obj.Attributes.Has("ATTR_TENDER_PLAN_NDS_PRICE") and Obj.Attributes.Has("ATTR_TENDER_ITEM_PRICE_MAX_VALUE") Then
    Set TableRows = Obj.Attributes("ATTR_TENDER_ITEM_PRICE_MAX_VALUE").Rows
    If TableRows.Count = 0 Then Exit Function
    Set Row = TableRows(0)
    Val0 = Row.Attributes("ATTR_TENDER_NDS_PRICE").Value
    Val1 = Obj.Attributes("ATTR_TENDER_PLAN_NDS_PRICE").Value
    If Val0 = 0 or Val1 = 0 Then Exit Function
    Res = Val0 / Val1
    If Res < 0.9 or Res > 1.1 Then PriceWithNDScheck = False
  End If
End Function

'Процедура задания значений атрибутам
Sub SetAttrs(Obj)
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  
  RegNum = ThisApplication.ExecuteScript("CMD_S_NUMBERING","PurchaseInsideNumGet",Obj,"")
  If RegNum <> "" Then
    Arr = Split(RegNum,"#")
    Num = cLng(Arr(1))
    RegNum = Replace(RegNum,"#","")
    On Error Resume Next
    Obj.Attributes("ATTR_TENDER_CLIENTS_NUM").Value = RegNum
    Obj.Attributes("ATTR_PROJECT_ORDINAL_NUM").Value = Num
    Obj.Attributes("ATTR_SYSTEM_DATE_NUM_GEN").Value = Date
    'If Err.Number <> 0 Then
    '  Msgbox "Номер закупки заказчика должен быть уникальным!", VbCritical
    'End If
    On Error GoTo 0
  End If
  
    'Атрибут Инициатор закупки и Контакты исполнителя закупки
  If Obj.Attributes.Has("ATTR_TENDER_INICIATOR") Then
  Obj.Attributes("ATTR_TENDER_INICIATOR").User = CU
  End If
  If  Obj.Attributes.Has("ATTR_TENDER_IN_RESP_CONTACT_INF") Then
  Obj.Attributes("ATTR_TENDER_IN_RESP_CONTACT_INF").Value =  CU.Description & ", газ.: (721) 4-" & CU.Phone & " "& CU.Mail
  End If
  
  'Атрибут Разработчик технической части
  If ThisApplication.Attributes.Has("ATTR_MY_COMPANY") Then
    If ThisApplication.Attributes("ATTR_MY_COMPANY").Empty = False Then
      If not ThisApplication.Attributes("ATTR_MY_COMPANY").Object is Nothing Then
        If Obj.Attributes.Has("ATTR_TENDER_TECH_PART_RESP") Then
          Obj.Attributes("ATTR_TENDER_TECH_PART_RESP").Object = ThisApplication.Attributes("ATTR_MY_COMPANY").Object
        End If
      End If
    End If
  End If
  
  'Атрибут Ответственный за предоставление материалов для проведения закупки
  AttrName = "ATTR_TENDER_MATERIAL_RESP"
  If Obj.Attributes.Has(AttrName) Then
    Set User = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetChiefForUser", CU)
    If not User is Nothing Then Obj.Attributes(AttrName).User = User
  End If
  
  'Ответственное структурное подразделение за подготовку заявки
  AttrName = "ATTR_TENDER_DEPT_RESP"
  If Obj.Attributes.Has(AttrName) Then
    Set Dept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetDept", CU)
    If not Dept is Nothing Then Obj.Attributes(AttrName).Object = Dept
  End If
  
  'Руководитель группы
  AttrName = "ATTR_TENDER_GROUP_CHIF"
  If Obj.Attributes.Has(AttrName) Then
  Set Dept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetDeptByID","ID_TENDER_IN_DEPT")
   If not Dept is Nothing Then
   Set User = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetChiefByDept",Dept)
    If not User is Nothing Then Obj.Attributes(AttrName).User = User
   End If
  End If
'    OrgName = "Группа планирования и проведения конкурентных закупок"
'    Set User = ThisApplication.ExecuteScript("CMD_DLL", "OrgUserGet", OrgName)
'    If not User is Nothing Then Obj.Attributes(AttrName).User = User
'  End If
  
  'Руководитель ПЭО
  AttrName = "ATTR_TENDER_PEO_CHIF"
  If Obj.Attributes.Has(AttrName) Then
    OrgName = "Планово-экономический отдел"
    Set User = ThisApplication.ExecuteScript("CMD_DLL", "OrgUserGet", OrgName)
    If not User is Nothing Then Obj.Attributes(AttrName).User = User
  End If
  
  'Год планирования
  AttrName = "ATTR_TENDER_PLAN_YEAR"
  If Obj.Attributes.Has(AttrName) Then
    Y = cStr(Year(Date))
    Set Clf = ThisApplication.Classifiers("NODE_YEAR_XXXX").Classifiers.Find(Y)
    If not Clf is Nothing Then
      Obj.Attributes(AttrName).Classifier = Clf
    End If
  End If
  
  'Ответственный руководитель (бывший Главный бухгалтер)
  AttrName = "ATTR_TENDER_ACC_CHIF"
  Set Dept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetDeptByID","ID_TENDER_INSIDE_DISTR_STRU_OBJ")
  If not Dept is Nothing Then
    Set User = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetChiefByDept",Dept)
    If not User is Nothing Then Obj.Attributes(AttrName).User = User
  End If
  
 'Добавляем пользователй по умолчанию в списки поручений 
  Set p = Obj.Parent
  If Not p Is Nothing Then  
    Call ThisApplication.ExecuteScript("CMD_DLL","AttrsSyncBetweenObjs",p,Obj,"ATTR_TENDER_EXPERT_LIST")
  End If
  
  'Расставляем флаги по умолчанию
   Obj.Attributes("ATTR_TENDER_ONLINE") = True 
   Obj.Attributes("ATTR_TENDER_DATA_CHECK_FLAG") = True 
End Sub 
  
  


' Проверка перед отправкой на согласование
Function CheckBeforeAgree(Obj)
'ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CheckNeedPeo",Obj 
'  call GetAggrList(Obj)
'  CheckBeforeAgree = GetAggrList(Obj) ' Закоментил для переноса проверки на инф карту
'  Exit Function
  CheckBeforeAgree = TenderInsideCheck(Obj)
'  Exit Function
''  CheckBeforeAgree = False
'''  str = CheckRequedFieldsBeforeAgree(Obj)
'''  If str <> "" Then
'''    Msgbox "Не заполнены обязательные атрибуты: " & str,vbExclamation
'''    Exit Function
'''  End If
'  CheckBeforeAgree = True
End Function


'Функция проверки закупки перед отправкой на согласование
Function TenderInsideCheck(Obj)
  TenderInsideCheck = False
  Check = False
  ThisApplication.Utility.WaitCursor = True
  
  'Проверка атрибутов
  
     'Обоснование закупки
    AttrName = "ATTR_TENDER_URGENCY_REASON"
    Set Attr = ThisApplication.AttributeDefs(AttrName)
    If Obj.Attributes("ATTR_TENDER_URGENTLY_FLAG") = True Then 
      If Obj.Attributes(AttrName).Empty = True Then
'            Str = Str & ", " & Attr.Description
            Str1 = Str1 & chr(10) & "-       " & Attr.Description
            Str3 = Str3 & "," &  "T_" & AttrName
      End If
    End If
      
    'Основание закупки у ЕИ
     AttrName = "ATTR_TENDER_REASON_POINT"
    Set Attr = ThisApplication.AttributeDefs(AttrName)
    If CheckReasonPoint(Obj) = False Then
      If Obj.Attributes(AttrName).Empty = True Then
'            Str = Str & ", " & Attr.Description
            Str1 = Str1 & chr(10) & "-       "  & Attr.Description
            Str3 = Str3 & "," &  "T_" & AttrName
      End If
    End If
  
  If Check = False Then
    Str = ""
    AttrStr1 = "ATTR_TENDER_CLIENTS_NUM,ATTR_TENDER_REASON,ATTR_TENDER_RESP,ATTR_TENDER_MATERIAL_RESP," &_
    "ATTR_TENDER_COMPETITIVE_METHOD_NAME,ATTR_TENDER_TIPE,ATTR_TENDER_PLAN_PART_NAME," &_
    "ATTR_TENDER_METHOD_NAME,ATTR_TENDER_PLAN_NDS_PRICE,ATTR_TENDER_PLAN_YEAR,ATTR_TENDER_PRIORITY," &_
    "ATTR_TENDER_STARTER_NAME,ATTR_TENDER_DEPT_RESP,ATTR_TENDER_EXECUT_DATA,ATTR_TENDER_PLAN_PRICE,ATTR_NDS_VALUE," '&_
'    "ATTR_TENDER_STOP_TIME,ATTR_TENDER_CHECK_TIME,ATTR_TENDER_CHECK_END_TIME,ATTR_TENDER_DIAL_START_DATA," &_
'    "ATTR_TENDER_DIAL_END_DATA,ATTR_TENDER_WORK_START_PLAN_DATA,ATTR_TENDER_WORK_END_PLAN_DATA,ATTR_TENDER_EXECUT_DATA"

 AttrStr2 = "ATTR_TENDER_PLAN_ZD_PRESENT,ATTR_TENDER_PRESENT_PLAN_DATA,ATTR_TENDER_STOP_TIME,ATTR_TENDER_CHECK_TIME,ATTR_TENDER_CHECK_END_TIME,ATTR_TENDER_DIAL_START_DATA," &_
    "ATTR_TENDER_PAY_CONDITIONS,ATTR_TENDER_DIAL_END_DATA,ATTR_TENDER_WORK_START_PLAN_DATA,ATTR_TENDER_WORK_END_PLAN_DATA,ATTR_TENDER_EXECUT_DATA"
        
    Arr = Split(AttrStr1,",")
    For i = 0 to Ubound(Arr)
      AttrName = Arr(i)
      If ThisApplication.AttributeDefs.Has(AttrName) and Obj.Attributes.Has(AttrName) Then
        Set Attr = ThisApplication.AttributeDefs(AttrName)
        Check = True
        If Obj.Attributes(AttrName).Empty Then
        Str3 = Str3 & "," & AttrName 
            Check = False
        End If
        If Check = False Then
          If Str1 = "" Then
            Str1 = "-       " & Attr.Description
          Else
'            Str = Str & ", " & Attr.Description
            Str1 = Str1 & chr(10) & "-       " & Attr.Description
          End If
        End If
      End If
    Next
    Arr = Split(AttrStr2,",")
    For i = 0 to Ubound(Arr)
    AttrName = Arr(i)
      If ThisApplication.AttributeDefs.Has(AttrName) and Obj.Attributes.Has(AttrName) Then
        Set Attr = ThisApplication.AttributeDefs(AttrName)
        Check = True
        If Obj.Attributes(AttrName).Empty Then
           Str3 = Str3 & "," & AttrName 
          Check = False
        End If
        If Check = False Then
          If Str2 = "" Then
            Str2 = "-       " & Attr.Description
          Else
'            Str = Str & ", " & Attr.Description
            Str2 = Str2 & chr(10) & "-       " & Attr.Description
          End If
        End If
      End If
    Next
     If Str1 <> "" and Str2 <> "" Then
      ThisApplication.Utility.WaitCursor = False
      Msgbox "Обязательные атрибуты не заполнены:" & chr(10) & chr(10) & "Основное______________________" & chr(10) & chr(10) & Str1 & chr(10) & chr(10) & "Сроки_________________________" & chr(10) & chr(10) & Str2 & chr(10) , vbExclamation
      TenderInsideCheck = Str3
     Exit Function
      else 
      if Str1 <> "" Then 
      Msgbox "Обязательные атрибуты не заполнены:" & chr(10) & chr(10) & "Основное______________________" & chr(10) & chr(10) & Str1, vbExclamation
      TenderInsideCheck = Str3
      Exit Function
       else 
      if Str2 <> "" Then 
       Msgbox "Обязательные атрибуты не заполнены:" & chr(10) & chr(10) & "Сроки_________________________" & chr(10) & chr(10) & Str2, vbExclamation
       TenderInsideCheck = Str3
     Exit Function
       End If
       End If
       End If
       End If 
      
  'Проверка атрибута Планируемая цена закупки (с НДС в рублях) c Код по ОКПД2
  CheckPrice = False
  AttrName = "ATTR_TENDER_PLAN_NDS_PRICE"
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Value < 200000000 Then CheckPrice = True
  End If
  
  'Проверка Лотов
   Check = False
  Str = ""
  
  For Each Child in Obj.Objects
    If Child.ObjectDefName = "OBJECT_PURCHASE_LOT" Then
  AttrName = "ATTR_TENDER_LOT_POS_TYPE"
  If ThisApplication.AttributeDefs.Has(AttrName) and Child.Attributes.Has(AttrName) Then
    Set posType = Child.Attributes(AttrName).Classifier
    If Not posType Is Nothing Then
      If posType.Description = "Работа" or posType.Description = "Услуга" Then
       
       AttrStr = "ATTR_LOT_NUM,ATTR_TENDER_LOT_POS_TYPE,ATTR_TENDER_OKVED2,ATTR_TENDER_OKPD2," &_
       "ATTR_TENDER_CURRENCY,ATTR_TENDER_OKATO,ATTR_TENDER_OBJECT_TYPE"
      Else
        AttrStr = "ATTR_LOT_NUM,ATTR_TENDER_LOT_POS_TYPE,ATTR_TENDER_OKVED2,ATTR_TENDER_OKPD2," &_
       "ATTR_TENDER_CURRENCY,ATTR_TENDER_OKATO,ATTR_TENDER_OBJECT_TYPE," &_
       "ATTR_TENDER_NOMENCLATUR_GROPE_MTR,ATTR_TENDER_FINANS_PAR"
      End If
    End If
   End If
' 
'  AttrStr = "ATTR_LOT_NUM,ATTR_TENDER_LOT_POS_TYPE,ATTR_TENDER_OKVED2,ATTR_TENDER_OKPD2," &_
'  "ATTR_TENDER_CURRENCY,ATTR_TENDER_OKATO,ATTR_TENDER_OBJECT_TYPE,"' &_
''  "ATTR_TENDER_NOMENCLATUR_GROPE_MTR,ATTR_TENDER_FINANS_PAR"
      Arr = Split(AttrStr,",")
      If Check = False Then Check = True
      Str0 = ""
      For i = 0 to Ubound(Arr)
        AttrName = Arr(i)
        If ThisApplication.AttributeDefs.Has(AttrName) and Child.Attributes.Has(AttrName) Then
          Set Attr = ThisApplication.AttributeDefs(AttrName)
          If Child.Attributes(AttrName).Empty Then
            If Str0 = "" Then
              Str0 = ""& "-       " & Attr.Description
            Else
              Str0 = Str0 & chr(10) & "-       "  & Attr.Description
            End If
          'Проверка атрибута Планируемая цена закупки (с НДС в рублях) c Код по ОКПД2
          ElseIf AttrName = "ATTR_TENDER_OKPD2" and CheckPrice = True  and obj.attributes("ATTR_TENDER_SMALL_BUSINESS_FLAG") <> true Then
            Set Attr = Child.Attributes(AttrName)
            If Attr.Empty = False Then
              If not Attr.Classifier is Nothing Then
                If Attr.Classifier.Comments.count>0 Then
                  Val = Attr.Classifier.Comments(0).Text
                  If InStr(1,Val,"СМСП",vbTextCompare) <> 0 Then
                    ThisApplication.Utility.WaitCursor = False
                    Msgbox "Согласно Постановления Правительства РФ от 11.12.2014 № 1352, в случае если " &_
                    "начальная (максимальная) цена договора (цена лота) на поставку товаров, выполнение работ, " &_
                    "оказание услуг не превышает 200 миллионов рублей и указанные товары, работы, услуги включены " &_
                    "в перечень, заказчик обязан осуществить закупки таких товаров, работ, услуг у субъектов " &_
                    "малого и среднего предпринимательства.", vbExclamation
                    Exit Function
                  End If
                End If
              End If
            End If
          End If
        End If
      Next
      
      If Str0 <> "" Then
     
        If Str <> "" Then
          Str = Str &chr(10)&chr(10)&"Не заполнены обязательные атрибуты лота:" & chr(10)& chr(10)&  Child.Description & ":" & chr(10)& chr(10)& Str0 &chr(10)
        Else
          Str = "Не заполнены обязательные атрибуты лота:" & chr(10)& chr(10)&  Child.Description & ":" & chr(10)& chr(10)&Str0
        End If
      End If
    End If
  Next
  
       'Отсутствие Лотов
  If Check = False Then
    ThisApplication.Utility.WaitCursor = False
    Msgbox "Отсутствуют лоты для согласования", vbExclamation
    Exit Function
  End If
  
  'Атрибуты Лотов
  If Str <> "" Then
    ThisApplication.Utility.WaitCursor = False
    ThisApplication.AddNotify Str
    Exit Function
  End If
  
'  'Уникальный номер закупки
'  AttrName = "ATTR_TENDER_UNIQUE_NUM"
'  If Obj.Attributes.Has(AttrName) Then
'    If Obj.Attributes(AttrName).Empty Then
'      Key = Msgbox("Выдать поручение в ПЭО на расчет стоимости?",vbQuestion+vbYesNo)
'      If Key = vbYes Then
'        'Создание поручения
'        Set CU = ThisApplication.CurrentUser
'        resol = "NODE_CORR_REZOL_POD"
'        ObjType = "OBJECT_KD_ORDER_NOTICE"
'        Set u = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,"ATTR_TENDER_PEO_CHIF")
'        txt = "Прошу назначить исполнителя для расчета стоимости закупки"
'        PlanDate = ""
'        AttrName = "ATTR_TENDER_PLAN_ZD_PRESENT"
'        If Obj.Attributes.Has(AttrName) Then
'          PlanDate = Obj.Attributes(AttrName).Value
'        End If
'        If PlanDate = "" Then PlanDate = Date + 1
'        If not u is Nothing Then
'          If u.SysName <> CU.SysName Then
'            ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,u,CU,resol,txt,PlanDate
'          End If
'        End If
'      End If
'    End If
'  End If
  
  ThisApplication.Utility.WaitCursor = False
  TenderInsideCheck = True
End Function

Function CheckReasonPoint (Obj)
  AttrName = "ATTR_TENDER_METHOD_NAME"
  CheckReasonPoint = True
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      If StrComp(Obj.Attributes(AttrName).Value, "Закупка у единственного поставщика",vbTextCompare) = 0 Then
        CheckReasonPoint = False
      End If
    End If
  End If
End Function

'Функция исключения статусов из имеющих возврат в разработку
function Check_FinishStatus(stName)
  Check_FinishStatus = (stName = "STATUS_TENDER_END") or _
                       (stName = "STATUS_S_INVALIDATED")
end function
''Функция ограничения типов файлов для загрузки в объект по статусам и ролям
'function GetTypeFileArr(docObj)
'  isSin = isResp(ThisApplication.CurrentUser) or isChif(ThisApplication.CurrentUser, docObj)

'  st = docObj.StatusName
'  select case st
'    case "STATUS_TENDER_DRAFT" 'Черновик
'      if IsExecutor(thisApplication.CurrentUser, docObj)  then _
'          GetTypeFileArr = array("Файл")  
'    case "STATUS_KD_AGREEMENT" 'На согласовании
'      if IsController(thisApplication.CurrentUser, docObj) then _
'          GetTypeFileArr = array("Файл")  
'    case "STATUS_TENDER_IN_AGREED" 'Согласовано
'      if IsCanAprove(thisApplication.CurrentUser, docObj) then _
'          GetTypeFileArr = array("Файл")  
'    case "STATUS_TENDER_IN_PLAN" 'Запланирована ... Не кому по идее какие либо файлы добавлять, только поручкения.
'      if IsCanAprove(thisApplication.CurrentUser, docObj) then _
'          GetTypeFileArr = array("Файл")     
'    case "STATUS_TENDER_IN_WORK" 'Разработка документации 
'      if IsCanAprove(thisApplication.CurrentUser, docObj) then _
'          GetTypeFileArr = array("Файл") 
'    case "STATUS_TENDER_IN_IS_APPROVING" 'На утверждении 
'      if IsCanAprove(thisApplication.CurrentUser, docObj) then _
'          GetTypeFileArr = array("Файл")   
'    case "STATUS_TENDER_IN_APPROVED" 'Утверждена 
'      if IsCanAprove(thisApplication.CurrentUser, docObj) then _
'          GetTypeFileArr = array("Файл")          
'    case "STATUS_TENDER_IN_PUBLIC" 'Размещена на площадке
'      if IsCanAprove(thisApplication.CurrentUser, docObj) then _
'          GetTypeFileArr = array("Файл")          
'    case "STATUS_TENDER_CHECK_RESULT" 'Рассмотрение результатов
'      if IsCanAprove(thisApplication.CurrentUser, docObj) then _
'          GetTypeFileArr = array("Файл")   
'  end select
'end function

function isResp(user)
  isSecretary = user.Groups.Has("GROUP_TENDER_INSIDE")
end function

function isIniciators(user, docObj)
  isIniciators = false
  if not docObj.Attributes.has("ATTR_TENDER_RESPONSIBLE_EIS") then exit function
  set singer = docObj.Attributes("ATTR_TENDER_RESPONSIBLE_EIS").user
  if singer is nothing then exit function
  isIniciators = (singer.SysName = user.SysName)
end function

'Функция проверки листа согласования
function GetAggrList(Obj)
 GetAggrList = False
  Check = False
  ThisApplication.Utility.WaitCursor = True


 User = Obj.Attributes("ATTR_TENDER_ACC_CHIF").value
set agreeObj = ThisApplication.ExecuteScript ("CMD_KD_AGREEMENT_LIB","GetAgreeObjByObj",Obj)
  ver = agreeObj.Attributes("ATTR_KD_CUR_VERSION").value
  Set TAttrRows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows
  count = 0
  for each row in TAttrRows
    if row.Attributes("ATTR_KD_APRV").value = User then count = count + 1
'    aprover = row.Attributes("ATTR_KD_APRV").value
  next
  if count = 0 then 
      msgbox "Согласование невозможно, т.к. последним в листе согласования должен быть пользователь " & User &_
          " Добавьте согласующего", vbCritical,  _
          "Отправить на согласование невозможно"
      exit function    
  end if
   ThisApplication.Utility.WaitCursor = False
  GetAggrList = True
end function

'Функция создания поручения после согласования
Sub SendOrder(Obj,sNameOld,sNameNew) 'Поручения  Msgbox sNameOld & sNameNew
'Если согласовано размещение - поручение Руководителю группы от Руководителя для согласования в АСЭЗ  и Инициатору для информации
'Если согласовано уторговывание - поручение Сотруднику Группы от Руководителя группы для проведения процедуры уторговывания
  If sNameNew = "STATUS_TENDER_IN_AGREED" Then
    AttrName = "ATTR_TENDER_STATUS_EIS"
    If Obj.Attributes.Has(AttrName) Then
     Stat = Obj.Attributes(AttrName).Value   
    If Obj.Attributes(AttrName).Empty = True Then 
     Set uToUser = Obj.Attributes("ATTR_TENDER_GROUP_CHIF").User
     If uToUser Is Nothing Then Exit Sub
     Set uFromUser = Obj.Attributes("ATTR_TENDER_ACC_CHIF").User
     resol = "NODE_CORR_REZOL_POD"
     txt = "Прошу включить закупку """ & Obj.Description & """в сводную заявку по Обществу для направления ее на согласование в Департамент"
     planDate = Date + 3
     ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
    
     Set uToUser = Obj.Attributes("ATTR_TENDER_RESP").User
     If uToUser Is Nothing Then Exit Sub
     resol = "NODE_CORR_REZOL_INF"
     txt = "Закупка """ & Obj.Description & """согласована для добавления в сводную заявку по Обществу и направления ее на согласование в Департамент"
     planDate = Date
     ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
     
    elseif StrComp(Stat,"В работе",vbTextCompare) = 0 Then 
       Set uToUser = Obj.Attributes("ATTR_TENDER_RESPONSIBLE_EIS").User
        If uToUser Is Nothing Then Exit Sub
         Set uFromUser = Obj.Attributes("ATTR_TENDER_GROUP_CHIF").User
         resol = "NODE_CORR_REZOL_POD"
         txt = "Прошу провести процедуру уторговывания по закупке""" & Obj.Description & """"
         planDate = Date + 1
         ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
        end if
       end if
    End If 
   'Если возвращено с согласования размещения - поручение Инициатору от Руководителя (бывшего главбуха)
   'Если возвращено с согласования уторговывания - поручение Сотруднику Группы от Руководителя группы закрыть закупку как проигравшую
   
  If sNameNew = "STATUS_TENDER_DRAFT" or sNameNew = "STATUS_TENDER_IN_PUBLIC" Then
   AttrName = "ATTR_TENDER_STATUS_EIS"
    If Obj.Attributes.Has(AttrName) Then
     Stat = Obj.Attributes(AttrName).Value   
      If Obj.Attributes(AttrName).Empty = True Then 
       Set uToUser = Obj.Attributes("ATTR_TENDER_RESP").User
       If uToUser Is Nothing Then Exit Sub
        Set uFromUser = Obj.Attributes("ATTR_TENDER_ACC_CHIF").User
        resol = "NODE_CORR_REZOL_POD"
        If sNameNew = "STATUS_TENDER_DRAFT" Then
         txt = "Прошу внести изменения закупку """ & Obj.Description & """согласно результатов согласования"
         planDate = Date + 3
        end if
     elseif StrComp(Stat,"В работе",vbTextCompare) = 0 Then 
        If sNameNew = "STATUS_TENDER_IN_PUBLIC" Then
         Set uToUser = Obj.Attributes("ATTR_TENDER_RESPONSIBLE_EIS").User
         If uToUser Is Nothing Then Exit Sub
         Set uFromUser = Obj.Attributes("ATTR_TENDER_GROUP_CHIF").User
         resol = "NODE_CORR_REZOL_POD"
         txt = "Прошу закрыть закупку""" & Obj.Description & """"
         planDate = Date + 1
        end if
       end if
       ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
      End If 
    End If 
End Sub

function CanIssueOrder(DocObj)
'  CanIssueOrder = false
'  docStat = DocObj.StatusName
'  str = ";STATUS_TENDER_DRAFT;STATUS_TENDER_IN_PUBLIC;STATUS_TENDER_IN_AGREED;STATUS_TENDER_CHECK_RESULT;" &_
'  "STATUS_TENDER_IN_WORK;STATUS_TENDER_IN_IS_APPROVING;STATUS_TENDER_IN_APPROVED;STATUS_TENDER_IN_PUBLIC;"
'  if Instr(";" & str & ";", ";" & docStat & ";") > 0 then _
      CanIssueOrder = true
end function

 'Запланирована ... Не кому по идее какие либо файлы добавлять, только поручения.
 
'   If not StrComp(Obj.Attributes("ATTR_TENDER_STATUS_EIS").Classifier.Description,"В работе",vbTextCompare) = 0 Then
   
'   If Attribute.Classifier.Description = "Информационная карта" Then
  
' If StrComp(Obj.Attributes(ATTR_TENDER_STATUS_EIS).Classifiers, "В работе",vbTextCompare) = 0 Then
'  Exit Sub
'  End If
