Set tQuery = ThisApplication.Queries("QUERY_SEARCH_COMPLECT")
Set tForm = ThisApplication.InputForms("FORM_SEARCH_COMPLECT")
If tForm.Show Then
  InitParams tQuery, tForm.Attributes
  ThisApplication.Shell.ListInitialize tQuery.Sheet
End If

Sub InitParams (tQuery, tAttrs)
  If Not tAttrs.Item("ATTR_PROJECT_CODE").Classifier Is Nothing Then _
    tQuery.Parameter("PARAM_PROJ_CODE") = tAttrs.Item("ATTR_PROJECT_CODE")
  If Not tAttrs.Item("ATTR_PROJECT_NAME").Classifier Is Nothing Then _
    tQuery.Parameter("@PARAM_PROJECT") = tAttrs.Item("ATTR_PROJECT_NAME")
  If Not tAttrs.Item("ATTR_STAGE").Classifier Is Nothing Then _
    tQuery.Parameter("PARAM_STAGE") = tAttrs.Item("ATTR_STAGE")
  If Not tAttrs.Item("ATTR_WORK_DOCS_SET_MARK").Classifier Is Nothing Then _
    tQuery.Parameter("PARAM_MARK") = tAttrs.Item("ATTR_WORK_DOCS_SET_MARK")
  If tAttrs.Item("ATTR_WORK_DOCS_SET_NAME") <> "" Then _
    tQuery.Parameter("PARAM_NAME") = tAttrs.Item("ATTR_WORK_DOCS_SET_NAME")
  If tAttrs.Item("ATTR_WORK_DOCS_SET_CODE") <> "" Then _
    tQuery.Parameter("PARAM_CODE") = tAttrs.Item("ATTR_WORK_DOCS_SET_CODE")
  If Not tAttrs.Item("ATTR_CONTRACT_STAGE").Object Is Nothing <> "" Then _
    tQuery.Parameter("PARAM_CONTRACT_STAGE") = tAttrs.Item("ATTR_CONTRACT_STAGE")
    
End Sub
