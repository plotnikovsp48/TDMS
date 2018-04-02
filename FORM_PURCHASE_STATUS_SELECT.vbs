' Форма ввода - Выбор статуса закупки
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Sub Form_BeforeShow(Form, Obj)
  ThisApplication.Dictionary("FORM_PURCHASE_STATUS_SELECT").Item("SELECTION") = "FALSE"
End Sub

Sub Form_BeforeClose(Form, Obj, Cancel)
  Set Dict = ThisApplication.Dictionary("FORM_PURCHASE_STATUS_SELECT")
  If Dict.Item("KEY") = True Then
 
    If Dict.Item("SELECTION") = "FALSE" Then
       qmess = MsgBox("Внимание! Вы не выбрали статус" & vbCrLf & _
      "Вернуться и выбрать?",vbQuestion+vbYesNo)
      If qmess = vbYes Then 
        Cancel = True
      Else
       
        Dict.Item("SELECTION") = "FALSE"
      End If
    End If
  End If
End Sub

Sub Ok_OnClick()
  
  ThisApplication.Dictionary("FORM_PURCHASE_STATUS_SELECT").Item("KEY") = True
 
End Sub

Sub Cancel_OnClick()
  ThisApplication.Dictionary("FORM_PURCHASE_STATUS_SELECT").Item("KEY") = False
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  Set Dict = ThisApplication.Dictionary("FORM_PURCHASE_STATUS_SELECT")
  If Attribute.Value = True Then
    For Each Attr in Form.Attributes
      If Attribute.AttributeDefName <> Attr.AttributeDefName Then Attr.Value = False
    Next
  Else
    Dict.Item("SELECTION") = "FALSE"
  End If
  Dict.Item("SELECTION") = Attribute.AttributeDefName
End Sub
