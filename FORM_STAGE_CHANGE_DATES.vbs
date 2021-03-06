' Форма ввода - Изменение сроков этапа
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.


Sub Form_BeforeClose(Form, Obj, Cancel)
  Set Dict = Form.Dictionary
  If Dict.Item("FORM_KEY_PRESSED") = True Then
    'Сравнение дат с предыдущими значениями
    Check = False
    If Dict.Item("Val1") <> Form.Attributes("ATTR_STARTDATE_PLAN").Value Then Check = True
    If Dict.Item("Val2") <> Form.Attributes("ATTR_ENDDATE_PLAN").Value Then Check = True
    If Dict.Item("Val3") <> Form.Attributes("ATTR_ENDDATE_ESTIMATED").Value Then Check = True
    If Dict.Item("Val4") <> Form.Attributes("ATTR_STARTDATE_FACT").Value Then Check = True
    If Dict.Item("Val5") <> Form.Attributes("ATTR_ENDDATE_FACT").Value Then Check = True
    If Dict.Item("Val6") <> Form.Attributes("ATTR_STARTDATE_ESTIMATED").Value Then Check = True
    If Check = False Then
      Msgbox "Указанные даты совпадают с исходными значениями. Изменения не будут произведены.", vbExclamation
      Cancel = True
      Exit Sub
    End If
    
    'Причина изменения
    If ThisForm.Attributes("ATTR_INF").Empty = True Then
      Msgbox "Укажите причину изменения сроков", vbExclamation
      Cancel = True
      Exit Sub
    End If
  End If
End Sub

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

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  If Attribute.AttributeDefName = "ATTR_STARTDATE_ESTIMATED" Then
    If Form.Attributes("ATTR_ENDDATE_ESTIMATED").Empty = False Then
      Date0 = Form.Attributes("ATTR_ENDDATE_ESTIMATED").Value
      If Attribute.Value > Date0 Then
        Msgbox "Дата не должна быть позже " & Date0, vbExclamation
        Cancel = True
        Exit Sub
      End If
    End If
  End If
  If Attribute.AttributeDefName = "ATTR_ENDDATE_ESTIMATED" Then
    If Form.Attributes("ATTR_STARTDATE_ESTIMATED").Empty = False Then
      Date0 = Form.Attributes("ATTR_STARTDATE_ESTIMATED").Value
      If Attribute.Value < Date0 Then
        Msgbox "Дата не должна быть раньше " & Date0, vbExclamation
        Cancel = True
        Exit Sub
      End If
    End If
  End If
End Sub

Sub Form_BeforeShow(Form, Obj)
  If Form.Attributes("ATTR_STARTDATE_FACT").Empty = False Then
    Form.Controls("ATTR_STARTDATE_ESTIMATED").ReadOnly = True
  End If
  Form.Controls("BTN_DOC_REF_ADD").Enabled = True
End Sub


Sub BTN_DOC_REF_ADD_OnClick()
  Set Obj = ThisForm.Attributes("ATTR_OBJECT").Object

  If Obj.ObjectDefName = "OBJECT_CONTRACT_STAGE" Then
    Set q = ThisApplication.Queries("QUERY_IN_MAILS_BY_CONTRACT")
    Set contr = Obj.Attributes("ATTR_CONTRACT").Object
    q.Parameter("THISOBJ") = contr
    str = "Переписка по договору " & contr.Description & " не найдена!"
  Else
    Set q = ThisApplication.Queries("QUERY_IN_MAILS_BY_PROJECT")
    Set proj = Obj.Attributes("ATTR_PROJECT").Object
    q.Parameter("THISOBJ") = proj
    str = "Переписка по проекту " & proj.Description & " не найдена!"
  End if
  
  If q.Objects.Count = 0 Then 
    msgbox str,vbExclamation,"Документы не найдены"
    Exit Sub
  End If
  
  Set dlg = ThisApplication.Dialogs.SelectObjectDlg
  dlg.SelectFromObjects = q.Objects
  If dlg.Show Then
     ThisForm.Attributes("ATTR_DOC_REF") = dlg.Objects(0)
  End If
End Sub
