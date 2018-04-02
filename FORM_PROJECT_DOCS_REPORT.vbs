

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  If Not Obj.Attributes("ATTR_PROJECT_STAGE").Classifier Is Nothing Then
    If Obj.Attributes("ATTR_PROJECT_STAGE").Classifier.SysName = "NODE_PROJECT_STAGE_W" Then
      Form.Controls("QUERY_REPORT_PROJECT_DOCS_W_STATUS").Visible = true
      Form.Controls("QUERY_REPORT_PROJECT_STATUS").Visible = False
    Else
      Form.Controls("QUERY_REPORT_PROJECT_DOCS_W_STATUS").Visible = False
      Form.Controls("QUERY_REPORT_PROJECT_STATUS").Visible = True    
    End If
  End If
End Sub
