

Sub Query_BeforeExecute(Query, Obj, Cancel)
if Obj Is Nothing Then Exit Sub
  If Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier Is Nothing Then
  Query.Parameter("Param0") = "='OBJECT_PURCHASE_OUTSIDE' Or (='OBJECT_TENDER_INSIDE' And <>'OBJECT_PURCHASE_DOC')"
  End If
  cClass = Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier.SysName
  If cClass = "NODE_CONTRACT_PRO" Then
    Query.Parameter("Param0") = "='OBJECT_PURCHASE_OUTSIDE'" 'ThisApplication.ObjectDefs("OBJECT_PURCHASE_OUTSIDE").handle
  ElseIf cClass = "NODE_CONTRACT_EXP" Then
    Query.Parameter("Param0") = "='OBJECT_TENDER_INSIDE' And <>'OBJECT_PURCHASE_DOC'"'ThisApplication.ObjectDefs("OBJECT_TENDER_INSIDE").handle
  End If
End Sub
