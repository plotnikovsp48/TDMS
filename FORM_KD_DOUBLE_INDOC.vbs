

'=============================================
Sub Form_BeforeShow(Form, Obj)
  set tb =  thisForm.Controls("QUERY_DOUBLE_CHECK").ActiveX
  if tb.Count = 0 then
    msgbox "Дубликаты не найдены", vbInformation
    thisForm.Close true
  end if
End Sub

'=============================================
Sub BTN_RETURN_OnClick()
    thisForm.Close true
End Sub
'=============================================
Sub BTN_DEL_OnClick()
    thisForm.Close false
End Sub
