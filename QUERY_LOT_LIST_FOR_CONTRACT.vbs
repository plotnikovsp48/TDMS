

Sub Query_BeforeExecute(Query, Obj, Cancel)
  If Not Obj Is Nothing Then
    Query.Parameter("PARAM0") = Obj.Attributes("ATTR_TENDER").Object
  End If
End Sub
