
Sub Query_BeforeExecute(Query, Obj, Cancel)
  Query.Parameter("PARAM0") = ThisApplication.CurrentUser
End Sub