

Sub Query_BeforeExecute(Query, Obj, Cancel)
    Query.Parameter("PARAM0") = thisApplication.CurrentUser 
End Sub
