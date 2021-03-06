Option Explicit

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  If "ATTR_REPLACE_FILE" = Attribute.AttributeDefName Then
    Form.Controls("ATTR_RENAME_FILE").Enabled = Not Attribute.Value
  ElseIf "ATTR_RENAME_FILE" = Attribute.AttributeDefName Then
    Form.Controls("ATTR_REPLACE_FILE").Enabled = Not Attribute.Value
  End If
End Sub

Sub Form_BeforeShow(Form, Obj)
  With Form.Attributes
    .Item("ATTR_REPLACE_FILE").Value = True
    .Item("ATTR_RENAME_FILE").Value = False
  End With
  With Form.Controls
    .Item("ATTR_RENAME_FILE").Enabled = False
  End With
End Sub


Sub Form_BeforeClose(Form, Obj, Cancel)
  With Form.Attributes
    If Not .Item("ATTR_RENAME_FILE").Value _
      And Not .Item("ATTR_REPLACE_FILE").Value Then Cancel = True
  End With
End Sub