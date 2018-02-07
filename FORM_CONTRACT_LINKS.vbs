USE "FORM_KD_DOC_LINKS"

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Set ContrClass = Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier
  Call SetClassDependentControls (ContrClass)
End Sub


Sub SetClassDependentControls (cls)
  If cls Is Nothing Then Exit Sub
  Set cCtrl = ThisForm.Controls
  Select Case cls.SysName
    Case "NODE_CONTRACT_EXP" ' Расходный

    Case "NODE_CONTRACT_PRO" ' Доходный

          sListAttrs = "ATTR_CONTRACT_MAIN"
          
          ThisApplication.ExecuteScript "CMD_DLL","SetControlVisible",ThisForm,sListAttrs,False
          
          'Call SetControlVisible(ThisForm,sListAttrs,False)
  End Select
End Sub

