
'=================================
Sub Form_BeforeClose(Form, Obj, Cancel)
Set Dict = ThisApplication.Dictionary("Users")
  If dict.Exists("OK") Then
    If dict("OK") Then 

        if Form.Attributes("ATTR_KD_ID_SENDDATE").Value = "" then
          MsgBox "Не задана дата отправки",vbExclamation,"Сохранение невозможно"
          Cancel = true
       else
          Cancel = false
       end if
    End If
  End If
  if dict.Exists("OK") then dict.remove("OK")   
End Sub
'=================================
Sub OK_OnClick()
  Set dict = ThisApplication.Dictionary("Users")
  if dict.Exists("OK") then dict.remove("OK")
  dict.Add "OK", True
End Sub

'=================================
Sub CANCEL_OnClick()
  Set Dict = ThisApplication.Dictionary("Users")
  if dict.Exists("OK") then dict.remove("OK")
  dict.Add "OK", False
End Sub