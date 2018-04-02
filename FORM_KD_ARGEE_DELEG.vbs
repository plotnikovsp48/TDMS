use CMD_KD_AGREEMENT_LIB

Sub Form_BeforeClose(Form, Obj, Cancel)
  Set Dict = ThisApplication.Dictionary("Packages")
  If dict.Exists("OK") Then
    If dict("OK") Then 
      set docObj = thisForm.Attributes("ATTR_KD_DOCBASE").Object
      if docObj is nothing then exit sub
      if not CheckUserByObj(docObj, "ATTR_KD_EXEC") then Cancel = true
      if thisForm.Attributes("ATTR_KD_NOTE").value = "" then 
        msgbox "Невозможно делегировать, не указав причину", vbExclamation
        Cancel = true
      end if
    end if
  end if    
  if dict.Exists("OK") then dict.remove("OK")      
End Sub
'==============================================================================
Sub OK_OnClick()
  Set dict = ThisApplication.Dictionary("Packages")
  if dict.Exists("OK") then dict.remove("OK")
  dict.Add "OK", True
End Sub

'==============================================================================
Sub CANCEL_OnClick()
  Set Dict = ThisApplication.Dictionary("Packages")
  if dict.Exists("OK") then dict.remove("OK")
  dict.Add "OK", False
End Sub