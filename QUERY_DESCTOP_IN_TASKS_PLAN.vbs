'' Выборка - Входящие задания
''------------------------------------------------------------------------------
'' Автор: Чернышов Д.С.
'' Авторское право © ЗАО «СИСОФТ», 2016 г.

'USE "CMD_OBJECTS_STYLE_DLL"

'Sub Query_AfterExecute(Sheet, Query, Obj)
'  Sheet.AddColumn 2
''  nCol0 = Sheet.ColumnsCount-2
''  nCol1 = Sheet.ColumnsCount-1
''  Sheet.ColumnName(nCol0) = "Ответственный за принятие задания"
''  Sheet.ColumnName(nCol1) = "Разработчик Задания"
'  
'  For i = 0 to Sheet.RowsCount-1
'    Set Task = Sheet.RowValue(i)
''    Set Roles0 = Task.RolesByDef(ThisApplication.RoleDefs("ROLE_T_TASK_IN_CHECKER"))
''    Set Roles1 = Task.RolesByDef(ThisApplication.RoleDefs("ROLE_T_TASK_DEVELOPER"))
''    Sheet.CellValue(i,nCol0) = GetRoleStr(Roles0)
''    Sheet.CellValue(i,nCol1) = GetRoleStr(Roles1)
'    
'    'Форматирование строк
'    Set RowFormat = Sheet.RowFormat(i)
'    'Статус "Задание выдано"
'    Uline = False
'    Set TableRows = Task.Attributes("ATTR_T_TASK_TDEPTS_TBL").Rows
'    Set CU = ThisApplication.CurrentUser
'    For Each Row in TableRows
'      If Row.Attributes("ATTR_T_TASK_DEPT_PERSON").Empty = False Then
'        If not Row.Attributes("ATTR_T_TASK_DEPT_PERSON").User is Nothing Then
'          If Row.Attributes("ATTR_T_TASK_DEPT_PERSON").User.SysName = CU.SysName Then
'            If Row.Attributes("ATTR_RESOLUTION").Value = "Принять" Then
'              Uline = True
'              Exit For
'            End If
'          End If
'        End If
'      End If
'    Next
'    If Uline = True Then
'      HLtype = "auto;auto;false;false;true;false"
'    Else
'      HLtype = "auto;auto;true;false;false;false"
'    End If
'    Res = QueryStatusStyle(Task, RowFormat, "STATUS_T_TASK_APPROVED", HLtype)
'    'Статус "Задание отклонено"
'    HLtype = "auto;auto;false;true;false;false"
'    Res = QueryStatusStyle(Task, RowFormat, "STATUS_T_TASK_IN_WORK", HLtype)
'  Next
'  
'  Sheet.MoveColumn nCol0, 4, 2
'End Sub

''Функция получения строки с пользователями/группами
'Function GetRoleStr(Roles)
'  GetRoleStr = ""
'  For Each Role in Roles
'    If not Role.User is Nothing Then
'      If GetRoleStr <> "" Then
'        GetRoleStr = GetRoleStr & ";" & Role.User.Description
'      Else
'        GetRoleStr = Role.User.Description
'      End If
'    Else
'      If GetRoleStr <> "" Then
'        GetRoleStr = GetRoleStr & ";" & Role.Group.Description
'      Else
'        GetRoleStr = Role.Group.Description
'      End If
'    End If
'  Next
'End Function
