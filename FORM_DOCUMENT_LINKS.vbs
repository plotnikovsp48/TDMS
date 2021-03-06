USE "FORM_KD_DOC_LINKS"
USE "CMD_S_DLL"

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Call SetContolEnable(Form, Obj)
  Call ClearOrderAttr()
End Sub

Sub SetContolEnable(Form, Obj)
  Set cCtrl = Form.Controls
  cCtrl("ATTR_PROJECT").ReadOnly = Not AttrIsEmpty(Obj,"ATTR_PROJECT")
  Form.Controls("ATTR_KD_TEXT").Enabled = True
  Form.Controls("ATTR_KD_HIST_NOTE").Enabled = True
End Sub

Sub QUERY_ALL_ORDERS_BY_DOCUMENT_Selected(iItem, action)
  set table = thisForm.Controls("QUERY_ALL_ORDERS_BY_DOCUMENT") 
  Set Objects = table.SelectedObjects
  Set order = Nothing
  If Objects.count <> 1 Then 
    Call ClearOrderAttr()
  Else
    Set order = Objects(0)
  End If
  Call ShowOrderDetails(order)
End Sub

sub ClearOrderAttr()
  for each contr in thisForm.Controls
    if left(contr.Name,5) = "EDIT_" then contr.value = ""  
  next 
end sub

Sub ShowOrderDetails(order)
  If order Is Nothing Then Exit Sub
  With ThisForm.Controls
      .Item("ATTR_KD_TEXT").Value = order.Attributes("ATTR_KD_TEXT").Value
      .Item("ATTR_KD_HIST_NOTE").Value = order.Attributes("ATTR_KD_HIST_NOTE").Value
      .Item("EDIT_ATTR_KD_OP_DELIVERY").Value = order.Attributes("ATTR_KD_OP_DELIVERY").Value
      .Item("EDIT_ATTR_KD_AUTH").Value = order.Attributes("ATTR_KD_AUTH").Value
  End With
End Sub
