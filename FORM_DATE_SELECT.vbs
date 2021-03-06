' Форма ввода - Выбор даты
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Sub Form_BeforeShow(Form, Obj)
  Set Dict = ThisApplication.Dictionary("FORM_DATE_SELECT")
  If Dict.Exists("description") Then
    Form.Controls("DESCR").Value = Dict.Item("description")
  End If
  If Dict.Exists("date") Then
    Form.Attributes("ATTR_DATA").Value = Dict.Item("date")
  End If
  If Dict.Exists("Cel") Then
    Form.Controls("Cel") = Dict.Item("Cel")
  End If
  Dict.RemoveAll
End Sub

Sub Form_BeforeClose(Form, Obj, Cancel)
'ThisApplication.Dictionary("FORM_DATE_SELECT").Item("FORM_KEY_PRESSED") = False
  Set Dict = ThisApplication.Dictionary("FORM_DATE_SELECT")
  If Dict.Item("FORM_KEY_PRESSED") = True Then
    If Form.Attributes("ATTR_DATA").Empty = True Then
      qmess = MsgBox("Внимание! Вы не заполнили дату" & vbCrLf & _
      "Вернуться и заполнить?",vbQuestion+vbYesNo)
      If qmess = vbYes Then 
        Cancel = True
      Else
        Dict.Item("Cel") = ""
        Dict.Item("FORM_KEY_PRESSED") = False
      End If
    Else
      Dict.Item("date") = Form.Attributes("ATTR_DATA").Value
    End If
  End If
  
End Sub

Sub Ok_OnClick()
 Set Dict = ThisApplication.Dictionary("FORM_DATE_SELECT")
  ThisApplication.Dictionary("FORM_DATE_SELECT").Item("FORM_KEY_PRESSED") = True
   Dict.Item("Cel") = "Ок"
End Sub

Sub Cancel_OnClick()
  ThisApplication.Dictionary("FORM_DATE_SELECT").Item("FORM_KEY_PRESSED") = False
End Sub
