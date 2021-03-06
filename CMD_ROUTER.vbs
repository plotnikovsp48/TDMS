' Автор: Орешкин А.В. 
'
' Обработчик маршрута
'------------------------------------------------------------------------------
' Авторское право c ЗАО <СиСофт>, 2016 г.


'==============================================================================
' Переход по статусам
'------------------------------------------------------------------------------
' oObjCur_:TDMSObject - ИО с которого берутся роли
' vStCur_:(TDMSStatus|String) Статус или системный идентификатор статуса 
'         ИО с которого берутся роли
' oObjNext_:TDMSObject - ИО на который назначаются роли
' vStNext_:(TDMSStatus|String) Статус или системный идентификатор статуса 
'         ИО на который назначаются роли
' Run:Integer - Результат выполнения функции 
'              (0 - без ошибок, N - ошибка при выполнении) 
'==============================================================================
Private Function Run(oObjCur_,vStCur_,oObjNext_,vStNext_)
  Dim dicStatusTransition ' :TDMSDictionary - Словарь переходов по статусам
  Dim sObjCur ' Системный идентификатор ИО с которого берутся роли
  Dim sObjNext ' Системный идентификатор ИО на который назначаются роли
  Dim sStCur ' Статус ИО с которого берутся роли
  Dim sStNext ' Статус ИО на который назначаются роли
  Dim dicRoleTransitions ' :TDMSDictionary - Словарь преобразования ролей
  Dim sStatusTransition ' Переход по статусам образующий уникальный ключ словоря
  
  ThisScript.SysAdminModeOn
  
  Run = -1
  ' Проверка параметров 
  ' ------------------------------------
  sObjCur = CheckObj(oObjCur_)
  If sObjCur = -1 Then Exit Function
  sObjNext = CheckObj(oObjNext_)
  If sObjNext = -1 Then Exit Function
  sStCur = CheckStatus(vStCur_,oObjCur_)
  If sStCur = -1 Then Exit Function
  sStNext = CheckStatus(vStNext_,oObjNext_)
  If sStNext = -1 Then Exit Function  
  ' ------------------------------------
  
  sStatusTransition = sObjCur&"."&sStCur&"."&sObjNext&"."&sStNext
  set aRoadmap = ThisApplication.Attributes("ATTR_ROADMAP")
  If aRoadmap = "" Then
    Msgbox "Маршрутная карта не указана.", vbExclamation
    Exit Function
  End If
  Set oRoadmap = aRoadmap.Object
  Set Query = ThisApplication.Queries("QUERY_TABLE_ROUTE_SEARCH")
  Query.Parameter("ROUTE") = oRoadmap
  Query.Parameter("Obj0id") = sObjCur
  Query.Parameter("Status0id") = sStCur
  Query.Parameter("Obj1id") = sObjNext
  Query.Parameter("Status1id") = sStNext
  Set Sheet = Query.Sheet
  
  If Sheet.RowsCount = 0 Then
    MsgBox "Маршрут"&Chr(10)&sStatusTransition&Chr(10)&"не найден", vbExclamation
    Exit Function
  ElseIf Sheet.RowsCount > 1 Then
    MsgBox "Маршрут"&Chr(10)&sStatusTransition&Chr(10)&"не уникален", vbExclamation
    Exit Function
  End If
  
  'Создание временного словаря, чтобы не менять конструкцию
  Set dicRoleTransitions = CreateObject("Scripting.Dictionary")
  arrRoleTransitions = Split(Sheet.CellValue(0,8))
  For i = 0 To UBound(arrRoleTransitions) Step 2
    sSysID = arrRoleTransitions(i)
    If sSysID <> "" Then
      sRoleSet = arrRoleTransitions(i+1)
      ' проверка наличия значения в словаре
      If dicRoleTransitions.Exists(sSysID) Then
        sCurentRoleTr = dicRoleTransitions.Item(sSysID)
        dicRoleTransitions.Item(sSysID) = sCurentRoleTr&";"&sRoleSet
      Else
        dicRoleTransitions.Add sSysID,sRoleSet
      End If
    End If
  Next
    
  'Set dicStatusTransition = ThisApplication.Dictionary("ROUTE")
    
  'sStatusTransition = sObjCur&"."&sStCur&"."&sObjNext&"."&sStNext
  '' Находим переход по статусам в словаре
  '' ???? если статус не меняется
  'If sObjCur <> sObjNext And sStCur <> sStNext Then 
  '  If Not dicStatusTransition.Exists(sStatusTransition) Then 
  '    MsgBox "Маршрут"&Chr(10)&sStatusTransition&Chr(10)&"не найден"
  '    Exit Function
  '  End If
  'Else
  '  ' выйте если маршрут не найден 
  '  If Not dicStatusTransition.Exists(sStatusTransition) Then Exit Function 
  '  If sObjCur = sObjNext And sStCur = sStNext Then 
  '    If oObjCur_.GUID = oObjNext_.GUID Then Exit Function
  '  End If
  'End If
  'Set dicRoleTransitions = dicStatusTransition.Item(sStatusTransition)
  Run = RouteProcessing(oObjCur_,oObjNext_,dicRoleTransitions)
'   Call ChangeStatus(oObjCur_,vStCur_,oObjNext_,vStNext_)
  Call ChangeStatus(oObjCur_,sStCur,oObjNext_,sStNext)
  'Модификация роли "Инициатор согласования"
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","InitiatorModified",oObjCur_,sStNext) 
End Function

'==============================================================================
' Смена ролей без смены статусов (для механизма согласования)
'------------------------------------------------------------------------------
' oObjCur_:TDMSObject - ИО с которого берутся роли
' vStCur_:(TDMSStatus|String) Статус или системный идентификатор статуса 
'         ИО с которого берутся роли
' oObjNext_:TDMSObject - ИО на который назначаются роли
' vStNext_:(TDMSStatus|String) Статус или системный идентификатор статуса 
'         ИО на который назначаются роли
' Run:Integer - Результат выполнения функции 
'              (0 - без ошибок, N - ошибка при выполнении) 
'==============================================================================
Private Function RunNonStatusChange(oObjCur_,vStCur_,oObjNext_,vStNext_)
  Dim dicStatusTransition ' :TDMSDictionary - Словарь переходов по статусам
  Dim sObjCur ' Системный идентификатор ИО с которого берутся роли
  Dim sObjNext ' Системный идентификатор ИО на который назначаются роли
  Dim sStCur ' Статус ИО с которого берутся роли
  Dim sStNext ' Статус ИО на который назначаются роли
  Dim dicRoleTransitions ' :TDMSDictionary - Словарь преобразования ролей
  Dim sStatusTransition ' Переход по статусам образующий уникальный ключ словоря
  
  ThisScript.SysAdminModeOn
  
  RunNonStatusChange = -1
  ' Проверка параметров
  ' ------------------------------------
  sObjCur = CheckObj(oObjCur_)
  If sObjCur = -1 Then Exit Function
  sObjNext = CheckObj(oObjNext_)
  If sObjNext = -1 Then Exit Function
  sStCur = CheckStatus(vStCur_,oObjCur_)
  If sStCur = -1 Then Exit Function
  sStNext = CheckStatus(vStNext_,oObjNext_)
  If sStNext = -1 Then Exit Function  
  ' ------------------------------------
  
  sStatusTransition = sObjCur&"."&sStCur&"."&sObjNext&"."&sStNext
  set aRoadmap = ThisApplication.Attributes("ATTR_ROADMAP")
  If aRoadmap = "" Then
    Msgbox "Маршрутная карта не указана.", vbExclamation
    Exit Function
  End If
  Set oRoadmap = aRoadmap.Object
  Set Query = ThisApplication.Queries("QUERY_TABLE_ROUTE_SEARCH")
  Query.Parameter("ROUTE") = oRoadmap
  Query.Parameter("Obj0id") = sObjCur
  Query.Parameter("Status0id") = sStCur
  Query.Parameter("Obj1id") = sObjNext
  Query.Parameter("Status1id") = sStNext
  Set Sheet = Query.Sheet
  
  If Sheet.RowsCount = 0 Then
    MsgBox "Маршрут"&Chr(10)&sStatusTransition&Chr(10)&"не найден", vbExclamation
    Exit Function
  ElseIf Sheet.RowsCount > 1 Then
    MsgBox "Маршрут"&Chr(10)&sStatusTransition&Chr(10)&"не уникален", vbExclamation
    Exit Function
  End If
  
  'Создание временного словаря, чтобы не менять конструкцию
  Set dicRoleTransitions = CreateObject("Scripting.Dictionary")
  arrRoleTransitions = Split(Sheet.CellValue(0,8))
  For i = 0 To UBound(arrRoleTransitions) Step 2
    sSysID = arrRoleTransitions(i)
    If sSysID <> "" Then
      sRoleSet = arrRoleTransitions(i+1)
      ' проверка наличия значения в словаре
      If dicRoleTransitions.Exists(sSysID) Then
        sCurentRoleTr = dicRoleTransitions.Item(sSysID)
        dicRoleTransitions.Item(sSysID) = sCurentRoleTr&";"&sRoleSet
      Else
        dicRoleTransitions.Add sSysID,sRoleSet
      End If
    End If
  Next

  RunNonStatusChange = RouteProcessing(oObjCur_,oObjNext_,dicRoleTransitions)
  'Модификация роли "Инициатор согласования"
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","InitiatorModified",oObjCur_,sStNext)
End Function

'==============================================================================
' Создание словаря маршрутов
'------------------------------------------------------------------------------
' route_:String - Системный идентификатор маршрута (на будущее, когда надо будет грузить разные маршруты)
' CreateRouteDic:TDMSDictionary - Словарь маршрутов
'==============================================================================
Private Function CreateRouteDic(route_)
  Dim sRouteStr ' Текстовое описание маршрута
  Dim arrStatusTransitions ' :Array - Массив строк = количеству переходов по статусам
  Dim arrRoleTransitions ' :Array - Массив преобразования ролей
  Dim dicStatusTransition ' :TDMSDictionary - Словарь переходов по статусам
  
  ThisScript.SysAdminModeOn
  ' Инициализация словоря маршрутов
  Set dicStatusTransition = ThisApplication.Dictionary("ROUTE")
  ThisApplication.Dictionary("ROUTE").RemoveAll
  ' Получение текстового описания маршрутов из скрипта команды 
  set aRoadmap = ThisApplication.Attributes("ATTR_ROADMAP")
  ' Проверяем, указан ли объект с описанием маршрута
  If  aRoadmap = "" Then
    set CreateRouteDic = Nothing
    Exit Function
  End If
  
  Set oRoadmap = aRoadmap.Object
  oRoadmap.Permissions = SysAdminPermissions 
  sRouteStr = oRoadmap.Attributes("ATTR_ROADMAP_ROUTE").Value
  
  ' Создание массива строк = количеству переходов по статусам
  arrStatusTransitions = Split(sRouteStr, chr(10))

  ' Обработка каждой строки перехода по статусу
  For Each sStatusTransition In arrStatusTransitions
    arrRoleTransitions = Split(Trim(sStatusTransition), chr(32))
    ' Для описания перехода требуется 4 значения (объект1+статус > объект2+статус)
    If UBound(arrRoleTransitions)>=3 Then
      ' Добавление перехода между статусами в словарь маршрутов
      Set dicStatusTransition = AddStatusTransition(dicStatusTransition,arrRoleTransitions)
    End If
  Next
  Set CreateRouteDic = dicStatusTransition
End Function 

'==============================================================================
' Добавление перехода между статусами
'------------------------------------------------------------------------------
' arrRoleTransitions_:Array - Массив преобразования ролей
' dicStatusTransition_:TDMSDictionary - Словарь переходов по статусам
' AddStatusTransition:Dictionary - Словарь переходов по статусам
'==============================================================================
Private Function AddStatusTransition(dicStatusTransition_,arrRoleTransitions_)
  Dim sObjCur ' Системный идентификатор ИО с которого берутся роли
  Dim sObjNext ' Системный идентификатор ИО на который назначаются роли
  Dim sStCur ' Статус ИО с которого берутся роли
  Dim sStNext ' Статус ИО на который назначаются роли
  Dim dicRoleTransitions ' :TDMSDictionary - Словарь преобразования ролей
  Dim sStatusTransition ' Переход по статусам образующий уникальный ключ словоря
  
  Set AddStatusTransition = dicStatusTransition_
  
  sObjCur = arrRoleTransitions_(0)
  sStCur = arrRoleTransitions_(1)
  sObjNext = arrRoleTransitions_(2)
  sStNext = arrRoleTransitions_(3)
  
  sStatusTransition = sObjCur&"."&sStCur&"."&sObjNext&"."&sStNext
  sStatusTransition = Replace(sStatusTransition, chr(10), "", 1, -1, vbTextCompare)  
  sStatusTransition = Replace(sStatusTransition, chr(13), "", 1, -1, vbTextCompare)  
  
  If dicStatusTransition_.Exists(sStatusTransition) Then Exit Function
  
  ' Инициализация словоря преобразования ролей
  Set dicRoleTransitions = CreateObject("Scripting.Dictionary")
  
  ' Добавление в словарь преобразование ролей для текущего перехода по статусам
  Set dicRoleTransitions = CreateRoleTransitionsDic(arrRoleTransitions_,dicRoleTransitions)
  dicStatusTransition_.Add sStatusTransition, dicRoleTransitions
  
  Set AddStatusTransition = dicStatusTransition_
End Function

'==============================================================================
' Добавление словаря преобразования ролей
'------------------------------------------------------------------------------
' arrRoleTransitions_:Array - Массив преобразования ролей
' dicRoleTransitions_:TDMSDictionary - Словарь преобразования ролей
' CreateRoleTransitionsDic:Dictionary - Словарь преобразования ролей
'==============================================================================
Private Function CreateRoleTransitionsDic(arrRoleTransitions_,dicRoleTransitions_)
  Dim i
  Dim sSysID   ' Системный идентификатор роли для преобразования или 
               ' cистемный идентификатор назначаемого пользователя или
               ' cистемный идентификатор назначаемой группы или
               ' системная переменная (CU - Curent User, RSET - роль или колекция)
  Dim sRoleSet ' Системный идентификатор назначаемой роли
  Dim sCurentRoleTr ' Текущее значение словаря преобразования ролей
  ' Считывания преобразования ролей
  For i=4 To UBound(arrRoleTransitions_) Step 2
    sSysID = arrRoleTransitions_(i)
    sSysID = Replace(sSysID, chr(13), "", 1, -1, vbTextCompare) 
    sSysID = Replace(sSysID, chr(10), "", 1, -1, vbTextCompare) 
    If sSysID <> "" Then
      sRoleSet = arrRoleTransitions_(i+1)
      sRoleSet = Replace(sRoleSet, chr(13), "", 1, -1, vbTextCompare) 
      sRoleSet = Replace(sRoleSet, chr(10), "", 1, -1, vbTextCompare)       
      ' проверка наличия значения в словаре
      If dicRoleTransitions_.Exists(sSysID) Then
        sCurentRoleTr = dicRoleTransitions_.Item(sSysID)
        dicRoleTransitions_.Item(sSysID) = sCurentRoleTr&";"&sRoleSet
      Else
        dicRoleTransitions_.Add sSysID,sRoleSet
      End If
    End If
  Next
  Set CreateRoleTransitionsDic = dicRoleTransitions_
End Function

'==============================================================================
' Проверка параметра (Информационного объекта)
'------------------------------------------------------------------------------
' o_:TDMSObject - Проверяемый объект
' CheckObj:String - Результат проверки (-1:не соответствие типа или не 
'                  инициализированно значение, SYSNAME:информационного объекта)
'==============================================================================
Private Function CheckObj(o_)
  CheckObj = -1
  If VarType(o_) <> 9 Then Exit Function
  If o_ Is Nothing Then Exit Function
  CheckObj = o_.ObjectDefName
End Function

'==============================================================================
' Проверка Cтатуса
'------------------------------------------------------------------------------
' o_:TDMSObject - Объект, на который назначен или назначается статус
' s_:TDMSStatus|String - Проверяемый статус (Статус или его системный иден.)
' CheckStatus:String - Результат проверки (-1:не соответствие типа или не 
'                  инициализированно значение, SYSNAME:статуса)
'==============================================================================
Private Function CheckStatus(s_,o_)
  CheckStatus = -1
  If VarType(s_) = 9 Then 
    If s_ Is Nothing Then 
      CheckStatus=""
    Else
      CheckStatus=s_.SysName
    End If
  Else
    If s_ <> "" Then
      If Not o_.ObjectDef.Statuses.Has(s_)Then Exit Function
      CheckStatus = s_
    End If
  End If
End Function


Private Function RouteProcessing(oObjCur_,oObjNext_,dicRoleTransitions_)
  Dim vObjCurRoles
  Dim sKey
  Dim dicHandledRoles
  Dim vRole
  
  Set dicHandledRoles =  CreateObject("Scripting.Dictionary")
  oObjNext_.Permissions = SysAdminPermissions 
  
  Set vObjCurRoles = oObjCur_.Roles
  For Each sKey In dicRoleTransitions_.Keys
    Call RoleProcessing(oObjCur_,oObjNext_,dicRoleTransitions_.Item(sKey),sKey,dicHandledRoles)
  Next
  
  For Each vRole In oObjNext_.Roles
    If Not dicHandledRoles.Exists(vRole.Handle) Then
      oObjNext_.Roles.Remove vRole
    End If
  Next
End Function

Private Sub RoleProcessing(oObjCur_,oObjNext_,sValue_,sKey_,dicHandledRoles_)
  Dim vUserOrGroup
  Dim sRole
  Dim vRole
  Dim arrRoles
  Dim rs
  
  arrRoles = Split(sValue_,";")
  Set rs = oObjCur_.RolesByDef(sKey_)
  If rs.Count > 1 Then
    For Each vRole In rs
      Set vUserOrGroup = GetRole(vRole,oObjCur_)
      If vUserOrGroup Is Nothing Then Exit Sub        
      For Each sRole In arrRoles
        ' Остается роль или добавляется
        If sKey_=sRole And  oObjCur_.GUID = oObjNext_.GUID Then
          dicHandledRoles_.Add vRole.Handle,vUserOrGroup.SysName    
        Else
          Set vRole = SetRoleVal(oObjNext_,vUserOrGroup,sRole)
          dicHandledRoles_.Add vRole.Handle,vUserOrGroup.SysName
        End If
      Next        
    Next
  Else
    Set vUserOrGroup = GetRoleVal(sKey_,oObjCur_)
    If vUserOrGroup Is Nothing Then Exit Sub  
    For Each sRole In arrRoles
      ' Остается роль или добавляется
      If sKey_=sRole And  oObjCur_.GUID = oObjNext_.GUID Then
        Set vRole = oObjCur_.Roles(sKey_)
        dicHandledRoles_.Add vRole.Handle,vUserOrGroup.SysName    
      Else
        Set vRole = SetRoleVal(oObjNext_,vUserOrGroup,sRole)
        dicHandledRoles_.Add vRole.Handle,vUserOrGroup.SysName
      End If
    Next  
  End If
End Sub

Private Function GetRoleVal(sKey_,oObjCur_)
  Dim vRole
  Dim sKeyID ' Идентификатор ключа (чем является ключ - роль,группа,пользователь,сис.переменная )
  Dim arrAttr
  Dim oAttrLink
  ' несколько одинаковых ролей, системные идентификаторы,группа, пользователь ???
  Set GetRoleVal = Nothing
  sKeyID = Split(sKey_,"_")(0)

  Select Case sKeyID
    Case "ROLE"     '-----------------------------------------
      Set GetRoleVal = GetRole(sKey_,oObjCur_)
    Case "ATTR"     '-----------------------------------------
      arrAttr = Split(sKey_,".")
      If UBound(arrAttr)=0 Then
        Set GetRoleVal = oObjCur_.Attributes(arrAttr(0)).User
      Else
        Set oAttrLink = oObjCur_.Attributes(arrAttr(0)).Object
        Set GetRoleVal = GetRole(arrAttr(1),oAttrLink)
      End If
    Case "USER"     '-----------------------------------------
      Set GetRoleVal = ThisApplication.Users(sKey_)   
    Case "GROUP"    '-----------------------------------------
      Set GetRoleVal = ThisApplication.Groups(sKey_)  
    Case "ALL"      '-----------------------------------------
      Set GetRoleVal = ThisApplication.Groups(sKey_)  
    Case "CU"       '-----------------------------------------
      Set GetRoleVal = ThisApplication.CurrentUser      
    Case "RSET"     '-----------------------------------------
      ' ???               
  End Select
End Function

Private Function SetRoleVal(oObjNext_,vUserOrGroup_,sRole_)
  Dim rd,r
  Set SetRoleVal = Nothing

  If Not ThisApplication.RoleDefs.Has(sRole_) Then Exit Function
  Set rd = ThisApplication.RoleDefs(sRole_)
  
  oObjNext_.Permissions = SysAdminPermissions 
  Set r = oObjNext_.Roles.Create(rd,vUserOrGroup_)
  r.Inheritable=False
  
  Set SetRoleVal = r
End Function

Private Sub ChangeStatus(oObjCur_,vStCur_,oObjNext_,vStNext_)
  If oObjCur_.GUID <> oObjNext_.GUID Then 
    If Not oObjNext_.ObjectDef.InitialStatus Is Nothing Then
      If oObjNext_.ObjectDef.InitialStatus.SysName = vStNext_ Then Exit Sub
    Else
      If vStNext_ = "" Then Exit Sub
    End If
  End if
  oObjNext_.Permissions = SysAdminPermissions 
  oObjNext_.Status = ThisApplication.Statuses(vStNext_)
End Sub

Private Function GetRole(sRoleSysName_,oObjCur_)
  Dim vRole
  Set GetRole = Nothing
  If VarType(sRoleSysName_) = 9 Then
    Set vRole = sRoleSysName_
  Else
    If oObjCur_.Roles.Has(sRoleSysName_) Then
      Set vRole = oObjCur_.Roles(sRoleSysName_)
    Else
      Exit Function
    End If
  End If
  If Not vRole.User Is Nothing Then
    Set GetRole = vRole.User
  End If
  If Not vRole.Group Is Nothing Then
    Set GetRole = vRole.Group
  End If
End Function


'==============================================================================
' Мастер добавления маршрута
'------------------------------------------------------------------------------
' o_:TDMSObject - Объект -маршрутная карта
' dlg_:TDMSInputForm - Форма мастера создания маршрута
' AddRoute:String - Результат выполнения функции (""|<добавленная строка маршрута>)
'==============================================================================
Function AddRoute(o_,dlg_)
  AddRoute = ""
    ' Формируем строку
  sNewRoute = CreateRouteStr(dlg_,False)
  If sNewRoute = "   " Then Exit Function
  
  ' Проверяем наличие маршрута
  sFindRoute = FindRoute(o_,dlg_)
  
  If Not sFindRoute = "" Then
    res = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbYesNo, 2401, sFindRoute, sNewRoute)
    If Not res = vbYes Then Exit Function
    ' Удаляем маршрут
    sDelRoute = DelRouteLine(sFindRoute,o_)
  End If

  ' Добавляем маршрут
  AddRoute = AddRouteLine(sNewRoute, o_)
End Function


'==============================================================================
' Формирование строки маршрута из атрибутов диалога
'------------------------------------------------------------------------------
' dlg_:TDMSImputForm - Диалог редактирования маршрута
' flag:Boolean - True - считывать роли из таблицы
' CreateRouteStr:String - Сформированная строка маршрута
'==============================================================================
Function CreateRouteStr(dlg,flag)
  sObjCur = dlg.Attributes("ATTR_ROUT_MASTER_OBJECT1_ID").Value
  sStCur = dlg.Attributes("ATTR_ROUT_MASTER_STATUS1_ID").Value
  sObjNext = dlg.Attributes("ATTR_ROUT_MASTER_OBJECT2_ID").Value
  sStNext = dlg.Attributes("ATTR_ROUT_MASTER_STATUS2_ID").Value
  
  routeStr = sObjCur&" "&sStCur&" "&sObjNext&" "&sStNext
  CreateRouteStr = routeStr
  If routeStr = "   " Then Exit Function
  
  If flag Then Exit Function
  ' Считываем таблицу ролей и добавляем в строку маршрута
  Set rows = dlg.Attributes("ATTR_ROUT_MASTER_ROLES").Rows
  For Each row In Rows
    sRole1=row.Attributes("ATTR_ROUT_MASTER_ROLES_CUR_ID")
    sRole2=row.Attributes("ATTR_ROUT_MASTER_ROLES_NEXT_ID")
    routeStr = routeStr&" "&sRole1&" "&sRole2
  Next  
  CreateRouteStr = routeStr
End Function

'==============================================================================
' Мастер удаления маршрута
'------------------------------------------------------------------------------
' o_:TDMSObject - Объект -маршрутная карта
' DelRoute:String - Результат выполнения функции (""|<Удаленная строка маршрута>)
'==============================================================================
Function DelRoute(o_,dlg_)
  dim dlg
  dim vAttr
  DelRoute = ""
  ' Формируем строку
  line = FindRoute(o_,dlg_) 
  ' Удаляем маршрут
  sDelRoute = DelRouteLine(line,o_)
  DelRoute = line
End Function



'==============================================================================
' Удаление строки маршрута
'------------------------------------------------------------------------------
' line:String - Удаляемая строка маршрута
' sRoute:String - Текущая маршрутная карта
' DelRouteLine:String - Новая маршрутная карта
'==============================================================================
Function DelRouteLine(line, o_)
  dim sRoute
  dim sNewRoute
  ' Считываем маршрутную карту
  sRoute = o_.Attributes("ATTR_ROADMAP_ROUTE").Value    
  sNewRoute = Replace(sRoute, line, "", 1, -1, vbTextCompare)  
  o_.Attributes("ATTR_ROADMAP_ROUTE").Value = sNewRoute
  o_.SaveChanges(tdmSaveOptSerializeIntermediate)
  DelRouteLine = sNewRoute
End Function


'==============================================================================
' Добавляет строку маршрута в маршрутную карту
'------------------------------------------------------------------------------
' routeStr:String - Строка маршрута
' o_:TDMSObject - Объект -маршрутная карта
' AddRouteLine:String - Добавленная строка маршрута
'==============================================================================
Function AddRouteLine(routeStr, o_)
  dim sRoute
  dim sNewRoute
  sRoute = o_.Attributes("ATTR_ROADMAP_ROUTE").Value
  ' Добавляем новый маршрут в маршрутную карту
  sNewRoute = sRoute&chr(13)&chr(10)&routeStr
  ' Сохраняем маршрутную карту
  o_.Attributes("ATTR_ROADMAP_ROUTE").Value = sNewRoute
  o_.SaveChanges(tdmSaveOptSerializeIntermediate)
  AddRouteLine = routeStr
End Function

''==============================================================================
'' Мастер редактирования маршрута
''------------------------------------------------------------------------------
'' o_:TDMSObject - Объект -маршрутная карта
'' EditRoute:String - Результат выполнения функции (""|<добавленная строка маршрута>)
''==============================================================================
'Function EditRoute(o_)
'  dim dlg
'  dim vAttr
'  EditRoute = ""
'  ' Открыть диалог формирования маршрута
'  Set dlg = ThisApplication.InputForms("FORM_ROUT_MASTER")
'  dlg.Attributes("ATTR_ROUT_MASTER_ROADMAP") = o_
'  ' Блокируем таблицу ролей
'  Set ctrl = dlg.Controls("ATTR_ROUT_MASTER_ROLES")
'  ctrl.ReadOnly = True
'  
'  If not dlg.Show Then Exit Function
'  ' Формируем строку
'  line = FindRoute(o_,dlg) 
'  ' Удаляем существующий маршрут
'  sNewRoute = DelRouteLine(line,o_)
'  ' Формируем строку
'  routeStr = CreateRouteStr(dlg,False)
'  ' Добавляем маршрут
'  EditRoute = AddRouteLine(routeStr, o_)  
'End Function


'==============================================================================
' Мастер редактирования маршрута
'------------------------------------------------------------------------------
' dlg_:TDMSImputForm - Диалог редактирования маршрута
' o_:TDMSObject - Объект -маршрутная карта
' FindRoute:String - Результат выполнения функции (""|<найденная строка маршрута>)
'==============================================================================
Function FindRoute(o_,dlg_)
  FindRoute = ""
  
  ' Формируем строку
  routeStr = CreateRouteStr(dlg_,True)
  If routeStr = "   " Then Exit Function
  
  ' Считываем маршрутную карту
  sRoute = o_.Attributes("ATTR_ROADMAP_ROUTE").Value
  
  ' Ищем строку, которую необходимо редактировать
  posStart = InStr(sRoute, routeStr)
  If posStart=0 Then Exit Function
  
  iLen = Len(sRoute)
  endStr = Right(sRoute, iLen - posStart)
  posMid = InStr(endStr, chr(13)&chr(10))
  
  If posMid = 0 Then 
    posMid = iLen ' в последней строке нет символа перевода chr(13)&chr(10)
    posStart = posStart-2 ' Убираем перевод строки в предыдущей строке
  Else
    ' Добавляеам 2, т.к. берем символ перевода chr(13)&chr(10)
    posMid=posMid+2
  End If
  
  line = Mid(sRoute,posStart,posMid)  
  FindRoute = line
End Function



'==============================================================================
' Функция возвращает описание указанного системного элемента
'------------------------------------------------------------------------------
' sId_:String - Системный идентификатор 
' GetDes:String - Результат выполнения функции (""|<Описание системного элемента>)
'==============================================================================
Function GetDes(sId_)
  GetDes= ""  
  
  Select Case True
    Case sId_ = "CU"
      GetDes = "Текущий пользователь"
    Case ThisApplication.RoleDefs.Has(sId_) 
      GetDes = ThisApplication.RoleDefs(sId_).Description
    Case ThisApplication.Groups.Has(sId_)
      GetDes = ThisApplication.Groups(sId_).Description
    Case ThisApplication.ObjectDefs.Has(sId_)
      GetDes = ThisApplication.ObjectDefs(sId_).Description
    Case ThisApplication.Statuses.Has(sId_)
      GetDes = ThisApplication.Statuses(sId_).Description            
  End Select
End Function
