

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  
End Sub


Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  Select case Attribute.AttributeDefName
    Case "ATTR_NDS_VALUE","ATTR_PRICE"
      val = Obj.Attributes("ATTR_PRICE")
      call Update_ATTR_PRICE_W_VAT(Obj,val)
    Case "ATTR_PRICE_W_VAT"
      val = Attribute
      Call UpdateRawPrice(Obj,val)
  End Select
End Sub



Sub Update_ATTR_PRICE_W_VAT(Obj,val)
  Set nds = Obj.Attributes("ATTR_NDS_VALUE").Classifier
  If nds Is Nothing Then Exit Sub
  nds_rate = nds.code
  If IsNumeric(nds_rate) = True Then
    NewVal = val * (1 + nds_rate/100)
  Else
    NewVal = val
  End If
  Obj.Permissions = SysAdminPermissions
  Obj.Attributes("ATTR_PRICE_W_VAT") = NewVal
End Sub

Sub UpdateRawPrice(Obj,val)
  Set nds = Obj.Attributes("ATTR_NDS_VALUE").Classifier
  If nds Is Nothing Then Exit Sub
  nds_rate = nds.code
  If IsNumeric(nds_rate) = True Then
    NewVal = val / (1 + nds_rate/100)
  Else
    NewVal = val
  End If
  Obj.Permissions = SysAdminPermissions
  Obj.Attributes("ATTR_PRICE") = NewVal
End Sub
