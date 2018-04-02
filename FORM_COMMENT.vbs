USE LIB_TEMPLATE_UTILITY

Sub Form_BeforeShow(Form, Obj)
  thisScript.SysAdminModeOn
  form.Description = form.Controls("STATIC1").Value
  OnAttrWithTemplatesRefreshComboItems("ATTR_KD_TEXT")
End Sub

'подлистывание - встройка в атрибут ATTR_KD_TEXT
'==============================================================================
Sub ATTR_KD_TEXT_BeforeAutoComplete(Text)
  Call OnAttrWithTemplatesBeforeAutoComplete("ATTR_KD_TEXT", Text)
End Sub
'==============================================================================
Sub ATTR_KD_TEXT_Modified()
  Call OnAttrWithTemplatesModified("ATTR_KD_TEXT")
End Sub
