' Выборка - Поиск маршрута согласования
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2016 г.

Sub Query_BeforeExecute(Query, Obj, Cancel)
  Set Dict = ThisApplication.Dictionary("MatchingRoutes")
  ItemName = ThisApplication.CurrentUser.SysName
  If Dict.Exists(ItemName) Then
    ObjType = Dict.Item(ItemName)
    Dict.RemoveAll
    Query.Parameter("TYPE") = "= '" & ObjType & "'"
  End If
End Sub