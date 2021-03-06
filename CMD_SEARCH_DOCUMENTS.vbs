Set tQuery = ThisApplication.Queries("QUERY_SEARCH_DOCUMENTS")
Set tForm = ThisApplication.InputForms("FORM_SEARCH_DOCUMENTS")
If tForm.Show Then
  InitParams tQuery, tForm.Attributes
  ' -----------------------------------
  ' Вывод в окно состава
  ' -----------------------------------
   ThisApplication.Shell.ListInitialize tQuery.Sheet
  ' -----------------------------------
End If

Sub InitParams (tQuery, tAttrs)
  If tAttrs.Item("ATTR_COMPLEX") <> "" Then _
    tQuery.Parameter("PARAM_PROJECT") = tAttrs.Item("ATTR_COMPLEX")
  If tAttrs.Item("ATTR_PROJECT_CODE") <> "" Then _
    tQuery.Parameter("PARAM_SHIFR") = tAttrs.Item("ATTR_PROJECT_CODE")
  If Not tAttrs.Item("ATTR_PROJECT_STAGE").Classifier Is Nothing Then _
    tQuery.Parameter("PARAM_STAGE") = tAttrs.Item("ATTR_PROJECT_STAGE")
  If tAttrs.Item("ATTR_DOC_CODE") <> "" Then 
    tQuery.Parameter("PARAM_OBOZ") = tAttrs.Item("ATTR_DOC_CODE")
  End If
  If tAttrs.Item("ATTR_DOCUMENT_NAME") <> "" Then 
    tQuery.Parameter("PARAM_NAME") = tAttrs.Item("ATTR_DOCUMENT_NAME")
  End If
  If Not tAttrs.Item("ATTR_DOCUMENT_TYPES").Classifier Is Nothing Then 
    tQuery.Parameter("PARAM_TYPE") = tAttrs.Item("ATTR_DOCUMENT_TYPES")
  End If
  If tAttrs.Item("ATTR_NUM") <> "" Then 
    tQuery.Parameter("PARAM_INV_NUM") = tAttrs.Item("ATTR_NUM")
  End If
  If tAttrs.Item("ATTR_INF") <> "" Then 
    tQuery.Parameter("PARAM_PRIM") = tAttrs.Item("ATTR_INF")
  End If
  If Not tAttrs.Item("ATTR_WORK_DOCS_SET_MARK").Classifier Is Nothing Then 
    tQuery.Parameter("PARAM_MARK") = tAttrs.Item("ATTR_WORK_DOCS_SET_MARK")
  End If
  If Not tAttrs.Item("ATTR_PROJECT_DOCS_SECTION").Classifier Is Nothing Then 
    tQuery.Parameter("PARAM_RAZD") = tAttrs.Item("ATTR_PROJECT_DOCS_SECTION")
  End If
End Sub
