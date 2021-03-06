' Форма ввода  - Поиск маршрута согласования
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2016 г.

'Событие - Смена выделения в выборке
Sub QUERY_MATCHING_PATH_FIND_Selected(iItem, action)
  Set Query = ThisForm.Controls("QUERY_MATCHING_PATH_FIND")
  Set TableRows = ThisForm.Attributes("ATTR_T_MATCHING_LIST").Rows
  If TableRows.Count <> 0 Then TableRows.RemoveAll
  If Query.SelectedObjects.Count = 0 Then Exit Sub
  
  Set Route = Query.SelectedObjects(0)
  Set TableRows0 = Route.Attributes("ATTR_T_MATCHING_LIST").Rows
  ThisForm.Attributes("ATTR_ROUT_MASTER_ROADMAP").Object = Route
  
  For Each Row in TableRows0
    Set NewRow = TableRows.Create
    NewRow.Attributes("ATTR_T_STEP_NUM").Value = Row.Attributes("ATTR_T_STEP_NUM").Value
    If Row.Attributes("ATTR_T_MATCHING_PERSON").Empty = False Then
      NewRow.Attributes("ATTR_T_MATCHING_PERSON").User = Row.Attributes("ATTR_T_MATCHING_PERSON").User
    End If
    If Row.Attributes("ATTR_USER_DEPT").Empty = False Then
      If not Row.Attributes("ATTR_USER_DEPT").Object is Nothing Then
        NewRow.Attributes("ATTR_USER_DEPT").Object = Row.Attributes("ATTR_USER_DEPT").Object
      End If
    End If
    If Row.Attributes("ATTR_POST").Empty = False Then
      NewRow.Attributes("ATTR_POST").Classifier = Row.Attributes("ATTR_POST").Classifier
    End If
  Next
  Set Table = ThisForm.Controls("ATTR_T_MATCHING_LIST").ActiveX
  Table.Refresh
End Sub
