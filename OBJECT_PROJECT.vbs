' Автор: Стромков С.А.
'
' Создание разделов
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

USE "CMD_DLL_ROLES"
USE "CMD_DLL"
USE "CMD_S_DLL"
USE "CMD_SS_TRANSACTION"
USE "CMD_SS_LIB"

Sub Object_BeforeCreate(o_, p_, Cancel)
  ' Запоминаем, если новый проект
  Set Dict = ThisObject.Dictionary
  Dict.Item("newproject") = True
  
  If Not IsGroupMemberMessage(ThisApplication.CurrentUser,"GROUP_GIP") Then 
    Cancel = True
    Exit Sub
  End If
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",p_,p_.Status,o_,o_.ObjectDef.InitialStatus)  
  
  ' Установка атрибутов
  Call SetAttrs(p_,o_)
  
  'Назначение кода проекта
  'on Error Resume Next
  Code = ProjectCodeGet(o_,"")
  o_.Attributes("ATTR_PROJECT_CODE").Value = Code
  On Error GoTo 0
End Sub

Sub Object_Created(o_, p_)
  Dim o, sProjectStage, Er
  ThisApplication.Utility.WaitCursor = True
  aFolderName = "ATTR_FOLDER_NAME"
  aFolderSystem = "ATTR_SYSTEM_FOLDER"
  sProjectType = o_.Attributes("ATTR_PROJECT_WORK_TYPE").classifier.SysName
  ThisScript.SysAdminModeOn
  
  ' Установка ролей
  Call SetRoles(o_)
  
  Er = False 
      
  'Создание папки Исходных данных
  set o = ThisApplication.ExecuteScript("CMD_S_DLL", "CreateObj", "OBJECT_BOD",o_,False)
  if Not IsObject(o) then Er=True
    
  ' Планирование
  set o = ThisApplication.ExecuteScript("CMD_S_DLL", "CreateObj", "OBJECT_P_ROOT",o_,False)
  if Not IsObject(o) then Er=True
  

'  ' Добавление выборок в проект
  
  Call ThisApplication.ExecuteScript("CMD_Update_Project_Q","AddSubQ",o_)
  
  Select Case sProjectType
    Case "NODE_WORK_TYPE_AUTH-SUPERVISION"
      Set clsFolderType = ThisApplication.Classifiers.FindBySysId("NODE_FOLDER_AUTH-SUPERVISION")
    ' Добавление папки Авторский надзор
      set o = ThisApplication.ExecuteScript("CMD_S_DLL", "CreateObj", "OBJECT_FOLDER",o_,False)
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", o, aFolderName, "Авторский надзор", True
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", o, aFolderSystem, True, True
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", o, "ATTR_FOLDER_TYPE", clsFolderType, True
      
      ' Документы АН
      Set otmp = ThisApplication.ExecuteScript("CMD_S_DLL", "CreateObj", "OBJECT_FOLDER",o,False)
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", otmp, aFolderName, "Документы АН", True
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", otmp, aFolderSystem, True, True
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", otmp, "ATTR_FOLDER_TYPE", clsFolderType, True
      
      ' Журналы АН
      Set otmp = ThisApplication.ExecuteScript("CMD_S_DLL", "CreateObj", "OBJECT_FOLDER",o,False)
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", otmp, aFolderName, "Журналы АН", True
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", otmp, aFolderSystem, True, True
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", otmp, "ATTR_FOLDER_TYPE", clsFolderType,True

'    Case "NODE_WORK_TYPE_PEMC"
'      Set clsFolderType = ThisApplication.Classifiers.FindBySysId("NODE_FOLDER_PEMC")
'      set o = ThisApplication.ExecuteScript("CMD_S_DLL", "CreateObj", "OBJECT_FOLDER",o_,False)
'      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", o, aFolderName, "ПЭМиК", True
'      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", o, aFolderSystem, True, True
'      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", o, "ATTR_FOLDER_TYPE", clsFolderType, True
'      
'      ' ПЭК - Проект экологического контроля
'      Set otmp = ThisApplication.ExecuteScript("CMD_S_DLL", "CreateObj", "OBJECT_FOLDER",o,False)
'      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", otmp, aFolderName, "ПЭК - Проект экологического контроля", True
'      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", otmp, aFolderSystem, True, True
'      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", otmp, "ATTR_FOLDER_TYPE", clsFolderType, True
'      
'      ' ПЭМ - Проект экологического мониторинга
'      Set otmp = ThisApplication.ExecuteScript("CMD_S_DLL", "CreateObj", "OBJECT_FOLDER",o,False)
'      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", otmp, aFolderName, "ПЭМ - Проект экологического мониторинга", True
'      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", otmp, aFolderSystem, True, True
'      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", otmp, "ATTR_FOLDER_TYPE", clsFolderType, True
      
    Case "NODE_WORK_TYPE_SUPERVISING"
      set o = ThisApplication.ExecuteScript("CMD_S_DLL", "CreateObj", "OBJECT_FOLDER",o_,False)
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", o, aFolderName, "Супервайзинг", True
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", o, aFolderSystem, True, True
      
    Case Else
      ' Результаты инженерных изысканий
      set NewFolder = ThisApplication.ExecuteScript("CMD_S_DLL", "CreateObj", "OBJECT_PROJECT_DOCS_I",o_,False)
      
      'Создание папки Этапы строительства
      Set clsFolderType = ThisApplication.Classifiers.FindBySysId("NODE_OBJECT_BUILD_STAGE")
      Set NewFolder = ThisApplication.ExecuteScript("CMD_S_DLL", "CreateObj", "OBJECT_FOLDER",o_,False)
      If Not IsObject(NewFolder) then 
        Er=True
      Else
        ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", NewFolder, aFolderName, clsFolderType.Description, True
        ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", NewFolder, aFolderSystem, True, True
        ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", NewFolder, "ATTR_FOLDER_TYPE", clsFolderType, True
      End If
      
        'Создание папки Структура объекта проектирования
      Set clsFolderType = ThisApplication.Classifiers.FindBySysId("NODE_FOLDER_PROJECT_WORK")
      Set NewFolder = ThisApplication.ExecuteScript("CMD_S_DLL", "CreateObj", "OBJECT_FOLDER",o_,False)
      If Not IsObject(NewFolder) then 
        Er=True
      Else
        ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", NewFolder, aFolderName, "Структура объекта", True
        ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", NewFolder, aFolderSystem, True, True
        ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", NewFolder, "ATTR_FOLDER_TYPE", clsFolderType, True
      End If

      if Not IsObject(NewFolder) then Er=True
  End Select
  
  'Создание папки Задания
  set o = ThisApplication.ExecuteScript("CMD_S_DLL", "CreateObj", "OBJECT_T_TASKS",o_,False)
  if Not IsObject(o) then Er=True
    
  'Создание папки Замечания
  Set clsFolderType = ThisApplication.Classifiers.FindBySysId("NODE_ISSUES")
  Set o = ThisApplication.ExecuteScript("CMD_S_DLL", "CreateObj", "OBJECT_FOLDER",o_,False)
  If Not IsObject(o) then 
    Er=True
  Else
    ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", o, aFolderName, "Замечания", True
    ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", o, aFolderSystem, True, True
    ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", o, "ATTR_FOLDER_TYPE", clsFolderType, True
  End If
  
  ' внешние замечания
  Set otmp = ThisApplication.ExecuteScript("CMD_S_DLL", "CreateObj", "OBJECT_FOLDER",o,False)
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", otmp, aFolderName, "Внешние (от Заказчика)", True
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", otmp, aFolderSystem, True, True
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", otmp, "ATTR_FOLDER_TYPE", clsFolderType, True
      
  ' внешние замечания
  Set otmp = ThisApplication.ExecuteScript("CMD_S_DLL", "CreateObj", "OBJECT_FOLDER",o,False)
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", otmp, aFolderName, "Внешние (от экспертизы)", True
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", otmp, aFolderSystem, True, True
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", otmp, "ATTR_FOLDER_TYPE", clsFolderType, True
      
  ' Внутренние замечания
  Set otmp = ThisApplication.ExecuteScript("CMD_S_DLL", "CreateObj", "OBJECT_FOLDER",o,False)
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", otmp, aFolderName, "Внутренние", True
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", otmp, aFolderSystem, True, True
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", otmp, "ATTR_FOLDER_TYPE", clsFolderType, True
  
  if Er then ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", VbCritical, 1204, Obj.Description
  ThisApplication.Utility.WaitCursor = False
End Sub

'Sub Object_ContentAdded(Obj, AddCollection)
'  ThisApplication.ExecuteCommand "CMD_SORT",Obj
'End Sub

Sub Object_BeforeContentRemove(Obj, RemoveCollection, Cancel)
  Cancel = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckEraseFlag", RemoveCollection)
End Sub

Sub Object_BeforeModify(Obj, Cancel)
  ' Установка ролей
  Set Dict = ThisApplication.Dictionary(Obj.GUID)
    If Dict.Exists("UpdateGipDeptRoles") Then
      If Dict.Item("UpdateGipDeptRoles") = True Then
        ' wrap in transaction
        Dim t
        Set t = New Transaction
'        Obj.Update
        Call SetRoleGipDep (Obj)
        Call DelRoleGipDep (Obj)
        t.Commit
      End If
      Dict.Remove("UpdateGipDeptRoles")
    End If
End Sub

Sub Object_PropertiesDlgInit(Dialog, Obj, Forms)
  ' Закрываем информационные поручения 
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_CORR_REZOL_INF")
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_STAT_MAIN")
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_DEL_MAIN")
  ' отмечаем все поручения по документу прочитанными
  'if obj.StatusName <> "STATUS_T_TASK_IN_WORK" then _
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","Set_OrdersReaded",Obj
End Sub

Sub Object_PropertiesDlgShow(Obj, Cancel, Forms)
  Set Obj.Dictionary("CurrentProjectGIP") = Obj.Attributes("ATTR_PROJECT_GIP").User
End Sub

Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
  If ThisApplication.ObjectDefs("OBJECT_PROJECT").Objects.Has(Obj) = False Then
    Code = ProjectCodeGet(Obj, "")
    If Obj.Attributes("ATTR_PROJECT_CODE").Value <> Code Then
      Obj.Attributes("ATTR_PROJECT_CODE").Value = Code
    End If
  End If
  
  If OkBtnPressed And ChiefChanged(Obj) Then
    Dim tr
    Set tr = New Transaction
    UpdateRolesAndAttributes Obj
    tr.Commit
  End If
  
  ' Удаляем метку нового проекта, чтобы при последующем открытии поля были толко для чтения
  Set Dict = Obj.Dictionary
  If Dict.Exists("newproject") Then Dict.Remove("newproject")
End Sub

Sub Object_BeforeErase(o_, cn_)
  Dim result
  result = CheckProjectContent(o_)
'   result2 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckReferencedBy", o_) 
  cn_=result
  If cn_ Then Exit Sub
  Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", o_) 
  ' Удаление папок из состава проекта
'  For Each o In o_.ContentAll
'    o.Permissions = SysAdminPermissions 
'    Call ThisApplication.ExecuteScript("CMD_S_DLL", "RemoveObjQuery", o)
'    o.Erase
'  Next
End Sub

'==============================================================================
' Функция проверяет наличие контента в составе удаляемого объекта. При этом 
' проверяется вся ветвь и игнорируются объекты типа:
' "OBJECT_DOCS_FOR_CUSTOMER"
' "OBJECT_PROJECT_DOCS_P"
' "OBJECT_PROJECT_DOCS_W"
' "OBJECT_BOD"
' "OBJECT_T_TASKS"
'------------------------------------------------------------------------------
' ПРИНИМАЕТ:
'   O_:TDMSObject - Удаляемый объект
'==============================================================================
Function CheckProjectContent(o_)
  Dim sObjDef
  CheckProjectContent = True
  For Each o In o_.Content
    sObjDef = o.ObjectDefName
    If sObjDef <>"OBJECT_P_ROOT" And sObjDef <> "OBJECT_T_TASKS"  And  sObjDef <> "OBJECT_PROJECT_DOCS_P" And sObjDef <> "OBJECT_PROJECT_DOCS_W" And sObjDef <> "OBJECT_PROJECT_DOCS_I" And sObjDef <> "OBJECT_BOD" Then
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1102, o_.Description
      Exit Function 'And sObjDef <>"OBJECT_DOCS_FOR_CUSTOMER"
    End If
    If o.Objects.Count > 0 Then
      if CheckProjectContent(o) then
        Exit Function 
      end if
    End If
  Next
  CheckProjectContent = False
End Function

' Установка атрибутов
Private Sub SetAttrs(p_,o_)
  'Устанавливаем ссылку проекта на себя
  Call ThisApplication.ExecuteScript("CMD_S_DLL", "SetProjLink", o_,o_)
  ' Установка атрибута "Раздел(Комплект)"
  o_.Attributes("ATTR_PROJECT_GIP").User = ThisApplication.CurrentUser
End Sub

' Установка ролей
Private Sub SetRoles(o_)
  'Устанавливаем роль Гип в соответствии с формой
  Set u=o_.attributes("ATTR_PROJECT_GIP").User 

  Call SetCascadeRoles (o_,"ROLE_GIP",u,"ATTR_PROJECT_GIP","object")
        Set cu = ThisApplication.CurrentUser
        Set oProj = GetProject(o_)
        
        If Not IsTheSameObj(u,cu) Then
          'function CreateSystemOrder( docObj, objType, userTo, userFrom, resol, txt,planDate)
          objType = "OBJECT_KD_ORDER_SYS"
          resol = "NODE_COR_STAT_MAIN"
          txt = "Вы назначены на роль ГИПа по проекту " & oProj.Description 
          planDate = ""
          ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB", "CreateSystemOrder", o_, objType, u, cu, resol, txt,planDate
        End If

  Call SetCascadeRoles (o_,"ROLE_GIP",u,"","contentall")
  
  Call SetCascadeRoles (o_,"ROLE_STRUCT_DEVELOPER",u,"ATTR_PROJECT_GIP","object")
  Call SetCascadeRoles (o_,"ROLE_RESPONSIBLE",u,"ATTR_PROJECT_GIP","object") 
'  Call SetCascadeRoles (o_,"ROLE_RESPONSIBLE",u,"","content") 
  Call SetCascadeRoles (o_,"ROLE_STRUCT_DEVELOPER",u,"","content")   
  
'  Call SetCascadeRoles (o_,"ROLE_FULLACCESS",u_,"ATTR_PROJECT_GIP","object")
'  Call SetCascadeRoles (o_,"ROLE_FULLACCESS",u,"","contentall")
'  Call UpdateAttrRole(o_,"ATTR_PROJECT_GIP","ROLE_FULLACCESS")
End Sub


'==============================================================================
' Процедура устанавливает роль на объект и его состав
' o_: TDMSObject - корневой объект
' r_: - роль
' u_: - пользователь или группа
' content_: флаг - 
' object - только объект
' content - объект и первый уровень
' contentall - 
'==============================================================================
Sub SetCascadeRoles (o_,r_,u_,attr_,content_)
  Select case content_
    Case "object"
      If Not attr_="" Then
        Call UpdateAttrRole(o_,attr_,r_)
      End If
      Exit Sub
    Case "content"
      Set os = o_.Objects
    Case "contentall"
      Set os = o_.ContentAll
  End Select

  For Each o In os
    o.Permissions = SysAdminPermissions
    If o.Roles.Has(r_) Then
      For each role in o.RolesByDef(r_)
        If Not role.User Is Nothing Then
          If role.User.Handle <> u_.Handle Then
            Call ChangeRole(o,u_,role)
          End If
        End If
      Next
    End If
  Next
End Sub

'Функция получения автоматического кода проекта
'Obj:Object - ссылка на проект
'DateCreate:Date - дата создания проекта (не задано, если текущая)
Function ProjectCodeGet(Obj,DateCreate)
  ThisScript.SysAdminModeOn
  ProjectCodeGet = 0
  If DateCreate = "" Then DateCreate = Date
  'Определяем текущий год
  YearStr = CStr(Year(DateCreate))
  Stol = Mid(YearStr, 2, 1)
  If Stol = 0 Then
    YearStr = Right(YearStr,2)
  Else
    YearStr = Right(YearStr,3)
  End If
  'Поиск максимального номера в текущем году
  Set Query = ThisApplication.Queries("QUERY_PROJECT_CODE_GET")
  Par = ">= 01.01." & YearStr & " AND <= 31.12." & YearStr
  Query.Parameter("PROJECT") = "<> '" & Obj.Description & "'" 
  ' Счетчик сквозной без учета года по требованию Артюшина. Кейс 6258
'  Query.Parameter("YEAR") = Par 
  If Query.Sheet.RowsCount > 0 Then
    Num = Query.Sheet.CellValue(0,0)
  Else
    Num = 1
  End If
  
  'Определяем порядковый номер проекта
  Num = Num + 1
  If Obj.Attributes.Has("ATTR_PROJECT_ORDINAL_NUM") Then
    Obj.Attributes("ATTR_PROJECT_ORDINAL_NUM").Value = Num
    Set Query = ThisApplication.Queries("QUERY_PROJECTS_EDIT")
    Set Objects = Query.Objects
    If Objects.Has(Obj) Then Obj.Update
  End If
  'Код проекта
  NumStr = CStr(Num)
  If Len(NumStr) < 2 Then
    NumStr = "00" & NumStr
  ElseIf Len(NumStr) < 3 Then
    NumStr = "0" & NumStr
  End If
  ProjectCodeGet = NumStr & "." & YearStr
End Function


'==============================================================================
' Добавление роли Зам.Гипа для пользователей в таблице зам. ГИПОВ
'------------------------------------------------------------------------------
' o_:TDMSObject - Обрабатываемый информационный объект
'==============================================================================
Sub SetRoleGipDep (o_)
  'Удаляем роль
  sRoleDef = "ROLE_GIP_DEP"
  If Not ThisApplication.RoleDefs.Has(sRoleDef) Then Exit Sub
  If Not o_.Attributes.Has("ATTR_GIP_DEPUTIES") Then Exit Sub
  Set Table = ThisObject.Attributes("ATTR_GIP_DEPUTIES")
  Set Rows = Table.Rows
  
  For Each row In Rows
    Check = False
    Set UG = Row.Attributes("ATTR_USER").User
    If Not UG Is Nothing Then
      o_.Permissions = SysAdminPermissions
      If Not o_.RolesForUser(UG).Has(sRoleDef) Then 
        o_.Roles.Create sRoleDef, UG.SysName
        ' Отправка сообщений зам Гипа
        Call SendOrder(o_,sRoleDef,UG)
        Call SendMessage(o_,sRoleDef,UG)
      End If

      ' Пробегаемся по составу
      For Each o In o_.ContentAll
        o.Permissions = SysAdminPermissions
        If Not o.RolesForUser(UG).Has(sRoleDef) Then 
          o.Roles.Create sRoleDef, UG.SysName
        End If
      Next
    End If
  Next
End Sub

'==============================================================================
' Отправка поручений Зам ГИПа
'------------------------------------------------------------------------------
' o_:TDMSObject - Проект
'==============================================================================
Private Sub SendOrder(o_,sRoleDef_,u_)
  Set cu = ThisApplication.CurrentUser
  Set oProj = GetProject(o_)
  
  For Each role In ThisObject.RolesForUser(u_)
    If role.RoleDefName = sRoleDef_ Then
        If Not IsTheSameObj(u_,cu) Then
          'function CreateSystemOrder( docObj, objType, userTo, userFrom, resol, txt,planDate)
          objType = "OBJECT_KD_ORDER_SYS"
          resol = "NODE_COR_STAT_MAIN"
          txt = "Вы назначены на роль заместителя ГИПа по проекту " & oProj.Description 
          planDate = ""
          ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB", "CreateSystemOrder", o_, objType, u_, cu, resol, txt,planDate
        End If
    End If
  Next
End Sub

'==============================================================================
' Удаление роли Зам.Гипа если пользователь отсутствует в таблице зам. ГИПОВ
'------------------------------------------------------------------------------
' o_:TDMSObject - Обрабатываемый информационный объект
'==============================================================================
Sub DelRoleGipDep (o_)
  
  'Удаляем роль
  sRoleDef = "ROLE_GIP_DEP"
  Set cu = ThisApplication.CurrentUser
  Set oProj = GetProject(o_)
  
  Set Table = ThisObject.Attributes("ATTR_GIP_DEPUTIES")
  Set Rows = Table.Rows
  ' C объекта
  For Each r In o_.RolesByDef(sRoleDef)
    Check = False
    Set RG = r.User
    For Each row In Rows
      Set UG = Row.Attributes("ATTR_USER").User
      If Not UG Is Nothing Then
        If RG.SysName = UG.SysName Then
          Check = True
        End If
      End If
    Next
    If Not Check Then 
      Call DelUserRole(o_,RG,sRoleDef)
        If Not IsTheSameObj(RG,cu) Then
          objType = "OBJECT_KD_ORDER_SYS"
          resol = "NODE_COR_DEL_MAIN"
          txt = "Вы больше не являетесь заместителем ГИПа по проекту " & oProj.Description
          planDate = ""
          ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB", "CreateSystemOrder", o_, objType, RG, cu, resol, txt,planDate
        End If
    End If
  Next
  
  ' Пробегаемся по составу
  For Each o In o_.ContentAll
    For Each r In o.RolesByDef(sRoleDef)
      Check = False
      For Each row In Rows
        Set UG = Row.Attributes("ATTR_USER").User
        If Not UG Is Nothing Then
          Set RG = r.User
          If RG.Sysname = UG.Sysname Then
            Check = True
          End If
        End If
      Next
      If Not Check Then 
        Call DelUserRole(o,RG,sRoleDef)
      End If
    Next
  Next
End Sub


'==============================================================================
' Отправка оповещения Зам ГИПа
'------------------------------------------------------------------------------
' o_:TDMSObject - Проект
'==============================================================================
Private Sub SendMessage(o_,sRoleDef_,u_)
  Set cu = ThisApplication.CurrentUser
  For Each role In ThisObject.RolesForUser(u_)
    If role.RoleDefName = sRoleDef_ Then
        If Not IsTheSameObj(u_,cu) Then
          ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1512, u_, o_, Nothing, role.Description, o_.Description, cu.Description, ThisApplication.CurrentTime
        End If
    End If
  Next
End Sub

Private Function ChiefChanged(obj)
  ChiefChanged = False
  
  Dim chief1, chief2
  Set chief1 = obj.Dictionary("CurrentProjectGIP")
  Set chief2 = obj.Attributes("ATTR_PROJECT_GIP").User
  
  If chief1 Is Nothing Then
    If chief2 Is Nothing Then
      Exit Function
    Else
      ChiefChanged = True
      Exit Function
    End If
  End If
  
  If chief2 Is Nothing Then
    ChiefChanged = True
    Exit Function
  End If
  
  ChiefChanged = chief1.SysName <> chief2.SysName
End Function

Private Sub UpdateRolesAndAttributes(Obj)

  Dim chief
  Set chief = Obj.Attributes("ATTR_PROJECT_GIP").User
  
  ThisApplication.ExecuteScript "CMD_SS_LIB", "SyncRoleToUser", _
    obj, "ROLE_GIP", chief
  
  Dim updDocs, updTasks
  Set updDocs = ThisApplication.CreateCollection(tdmObjects)
  Set updTasks = ThisApplication.CreateCollection(tdmObjects)
  
  Dim o
  For Each o In Obj.ContentAll
  
    ThisApplication.ExecuteScript "CMD_SS_LIB", "SyncRoleToUser", _
      o, "ROLE_GIP", chief
    
    If o.IsKindOf("OBJECT_DOC") Then
      If "STATUS_DOCUMENT_FIXED" <> o.StatusName _
        And "STATUS_DOCUMENT_INVALIDATED" <> o.StatusName Then
        updDocs.Add o
      End If
    ElseIf o.IsKindOf("OBJECT_T_TASK") Then
      If "STATUS_T_TASK_APPROVED" <> o.StatusName _
        And "STATUS_T_TASK_INVALIDATED" <> o.StatusName Then
        updTasks.Add o
      End If
    End If
  Next
  
  If updDocs.Count > 0 Then
    ThisApplication.ExecuteScript "CMD_SS_LIB", "PropagateValue", _
      updDocs, "ATTR_PROJECT_GIP", chief
  End If
  
  If updTasks.Count > 0 Then
    ThisApplication.ExecuteScript "CMD_SS_LIB", "PropagateValue", _
      updTasks, "ATTR_DOCUMENT_CONF", chief
  End If
End Sub

'==========================================================
' Возвращает Заказчика проекта
'----------------------------------------------------------
' o_:TDMSObject - Объект внутри проекта
' GetProjectCustomer:TDMSUser   Ссылка на Заказчика проекта
'                     Nothing - Заказчик не задан          
'==========================================================
Function GetProjectCustomer(o_)
  Set GetProjectCustomer = Nothing
 
  ' Проверка входных параметров
  If VarType(o_) <> 9 Then Exit Function
  If o_ Is Nothing Then Exit Function
  
  attrname = "ATTR_CUSTOMER_CLS"
  aProj = "ATTR_PROJECT"
  
  Set oProj = Nothing
  If o_.Attributes.Has(aProj) Then 
    If o_.Attributes(aProj).Empty = False Then
      If Not o_.Attributes(aProj).Object Is Nothing Then
        Set oProj = o_.Attributes(aProj).Object
      End If
    End If
  End If
  
  If oProj Is Nothing Then Set oProj = GetUplinkObj(o_,"OBJECT_PROJECT")
  
  If oProj Is Nothing Then Exit Function
  
  If oProj.Attributes.Has(attrname) Then
    If oProj.Attributes(attrname).Empty = False Then
      If not oProj.Attributes(attrname).Object is Nothing Then
        Set GetProjectCustomer = oProj.Attributes(attrname).Object
      End If
    End If
  End If
End Function

Function GetProjectWorkType(Obj)
  GetProjectWorkType = vbNullString
  Set oLink = ThisApplication.ExecuteScript("CMD_S_NUMBERING","ObjectLinkGet",Obj,"ATTR_PROJECT")
  If not oLink is Nothing Then
    If oLink.Attributes("ATTR_PROJECT_WORK_TYPE").Empty = False Then
      GetProjectWorkType = oLink.Attributes("ATTR_PROJECT_WORK_TYPE").Classifier.SysName
    End If
  End If
End Function

Extern GetGIP [Alias ("ГИП"), HelpString ("ГИП")]
Function GetGIP(Obj) 
  GetGIP = " "
  Set uGip = GetProjectGIP(Obj)
  If uGip Is Nothing Then Exit Function
  GetGIP= uGip.LastName
End Function

Extern GetGIPFIO [Alias ("ГИП. ФИО"), HelpString ("ГИП ФИО")]
Function GetGIPFIO(Obj) 
  GetGIPFIO = " "
  Set uGip = GetProjectGIP(Obj)
  If uGip Is Nothing Then Exit Function
  GetGIPFIO= uGip.Attributes("ATTR_KD_FIO")
End Function

Extern GetGIPPost [Alias ("Должность ГИПа"), HelpString ("Должность ГИПа")]
Function GetGIPPost(Obj) 
  GetGIPPost = " "
  Set uGip = GetProjectGIP(Obj)
  If uGip Is Nothing Then Exit Function
  GetGIPPost= uGip.Position
End Function

' возвращает наименование контрагента в формате
' ООО "Рога и копыта"
Extern GetCustomer [Alias ("Заказчик"), HelpString ("Заказчик")]
Function GetCustomer(Obj) 
  GetCustomer = " "
  Set src = GetProjectCustomer(Obj)
  If src Is Nothing Then Exit Function
  GetCustomer = src.Description
  If src.Attributes.Has("ATTR_S_JPERSON_ORG_TYPE") Then
    If src.Attributes("ATTR_S_JPERSON_ORG_TYPE").Empty = False Then
      Set opfCls = src.Attributes("ATTR_S_JPERSON_ORG_TYPE").Classifier
      If opfCls Is Nothing Then Exit Function
    End If
  End If
  opfCode = opfCls.code
  If opfCode = vbNullString Then Exit Function
  GetCustomer = opfCode & " " & GetCustomer
End Function

Extern GetDispatcher [Alias ("Диспетчер"), HelpString ("Диспетчер")]
Function GetDispatcher(Obj) 
  GetDispatcher = " "
  Set user = GetProjectDispatcher(Obj)
  If user Is Nothing Then Exit Function
  GetDispatcher = user.Description
End Function

Extern GetDispatcherFIO [Alias ("Диспетчер. ФИО"), HelpString ("Диспетчер ФИО")]
Function GetDispatcherFIO(Obj) 
  GetDispatcherFIO = " "
  Set user = GetProjectDispatcher(Obj)
  If user Is Nothing Then Exit Function
  GetDispatcherFIO= user.Attributes("ATTR_KD_FIO")
End Function


