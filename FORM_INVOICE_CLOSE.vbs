' Форма ввода - Подтверждение получения ПСД
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Sub Ok_OnClick()
  If ThisForm.Dictionary.Exists("FORM_KEY_PRESSED") Then
    ThisForm.Dictionary.Item("FORM_KEY_PRESSED") = True
  Else
    ThisForm.Dictionary.Add "FORM_KEY_PRESSED", True
  End If
End Sub

Sub Cancel_OnClick()
  If ThisForm.Dictionary.Exists("FORM_KEY_PRESSED") Then
    ThisForm.Dictionary.Item("FORM_KEY_PRESSED") = False
  Else
    ThisForm.Dictionary.Add "FORM_KEY_PRESSED", False
  End If
End Sub

Sub Form_BeforeClose(Form, Obj, Cancel)
  If ThisForm.Dictionary.Item("FORM_KEY_PRESSED") = True Then
    If ThisForm.Attributes("ATTR_USER2_STR").Empty = True Then
      qmess = MsgBox("Внимание! Вы не заполнили ""ФИО получателя""" & vbCrLf & _
      "Вернуться и заполнить ""ФИО получателя""?" & vbCrLf & _
      "Да - заполнить поле" & vbCrLf & _
      "Нет - отменить подтверждение",vbQuestion+vbYesNo)
      If qmess = vbYes Then 
        Cancel = True
      Else
        ThisForm.Dictionary.Item("FORM_KEY_PRESSED") = False
      End If
    ElseIf ThisForm.Attributes("ATTR_INVOICE_RECEIPT_DATE").Empty = True Then
      qmess = MsgBox("Внимание! Вы не заполнили ""Дату получения накладной получателем""" & vbCrLf & _
      "Вернуться и заполнить ""Дату получения накладной получателем""?" & vbCrLf & _
      "Да - заполнить поле" & vbCrLf & _
      "Нет - отменить подтверждение",vbQuestion+vbYesNo)
      If qmess = vbYes Then 
        Cancel = True
      Else
        ThisForm.Dictionary.Item("FORM_KEY_PRESSED") = False
      End If
    ElseIf ThisForm.Attributes("ATTR_INVOICE_RECIPIENT_COMMENT").Empty = True Then
      qmess = MsgBox("Внимание! Вы не заполнили ""Комментарий""" & vbCrLf & _
      "Вернуться и заполнить ""Комментарий""?" & vbCrLf & _
      "Да - заполнить поле" & vbCrLf & _
      "Нет - отменить подтверждение",vbQuestion+vbYesNo)
      If qmess = vbYes Then 
        Cancel = True
      Else
        ThisForm.Dictionary.Item("FORM_KEY_PRESSED") = False
      End If
    End If 
  End If
End Sub

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
End Sub
