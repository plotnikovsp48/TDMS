USE "FORM_KD_DOC_LINKS"
USE "CMD_S_DLL"

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Call SetContolEnable(Form, Obj)
End Sub

Sub SetContolEnable(Form, Obj)
  Set cCtrl = Form.Controls
  cCtrl("ATTR_PROJECT").ReadOnly = Not AttrIsEmpty(Obj,"ATTR_PROJECT")
End Sub
