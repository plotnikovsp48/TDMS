' Выборка - Исходящие задания
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2016 г.

USE "CMD_OBJECTS_STYLE_DLL"

Sub Query_AfterExecute(Sheet, Query, Obj)
  Sheet.AddColumn 2
  nCol0 = Sheet.ColumnsCount-2
  nCol1 = Sheet.ColumnsCount-1
  Sheet.ColumnName(nCol0) = "Ответственный за принятие задания"
  Sheet.ColumnName(nCol1) = "Разработчик Задания"
  
  For i = 0 to Sheet.RowsCount-1
    Set Task = Sheet.RowValue(i)
    Set Roles0 = Task.RolesByDef(ThisApplication.RoleDefs("ROLE_T_TASK_IN_CHECKER"))
    Set Roles1 = Task.RolesByDef(ThisApplication.RoleDefs("ROLE_T_TASK_DEVELOPER"))
    Sheet.CellValue(i,nCol0) = GetRoleStr(Roles0)
    Sheet.CellValue(i,nCol1) = GetRoleStr(Roles1)
    
    'Форматирование строк
    Set RowFormat = Sheet.RowFormat(i)
    'Статус "Задание на проверке"
    HLtype = "auto;auto;true;false;false;false"
    Res = QueryStatusStyle(Task, RowFormat, "STATUS_T_TASK_IS_CHECKING", HLtype)
    'Статус "Задание выдано"
    HLtype = "auto;auto;false;true;false;false"
    Res = QueryStatusStyle(Task, RowFormat, "STATUS_T_TASK_APPROVED", HLtype)
    'Статус "Задание отклонено"
    HLtype = "auto;auto;true;false;false;false"
    Res = QueryStatusStyle(Task, RowFormat, "STATUS_T_TASK_IN_WORK", HLtype)
    
    'Завершающиеся и просроченные задания
    aName = "ATTR_ENDDATE_ESTIMATED"
    Set oPlanTask = ThisApplication.ExecuteScript("CMD_PLAN_TASK_LIB","GetPlanTaskLink",Task)
    If Not oPlanTask Is Nothing Then
      If oPlanTask.Attributes.Has(aName) Then
        If ThisApplication.Attributes.Has("ATTR_T_TASK_ALARM1") Then 'and Task.Attributes.Has(aName)
          aInt = ThisApplication.Attributes("ATTR_T_TASK_ALARM1").Value
          MaxValue = oPlanTask.Attributes(aName).Value
          MinValue = MaxValue - aInt
            HLtype1 = "auto;8454143;false;false;false;false"
            HLtype2 = "auto;9803263;false;false;false;false"
          Res = QueryRangeStyle(Task,RowFormat,Date,MinValue,MaxValue,"",HLtype1,HLtype2)
        End If
      End If
    End If
  Next
  
  Sheet.MoveColumn nCol0, 4, 2
End Sub

'Функция получения строки с пользователями/группами
Function GetRoleStr(Roles)
  GetRoleStr = ""
  For Each Role in Roles
    If not Role.User is Nothing Then
      If GetRoleStr <> "" Then
        GetRoleStr = GetRoleStr & ";" & Role.User.Description
      Else
        GetRoleStr = Role.User.Description
      End If
    Else
      If GetRoleStr <> "" Then
        GetRoleStr = GetRoleStr & ";" & Role.Group.Description
      Else
        GetRoleStr = Role.Group.Description
      End If
    End If
  Next
End Function

Sub Query_BeforeExecute(Query, Obj, Cancel)
  GroupName = "GROUP_LEAD_DEPT"
  Set CU = ThisApplication.CurrentUser
  Set Dept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetDeptForUserByGroup",CU,GroupName)
  
  Query.Parameter("CU") = CU
  Query.Parameter("PARAM0") = Dept
End Sub
