

Sub Form_BeforeShow(Form, Obj)
  'Form.Controls("OBJECT0").Value = "Объекты"
  'Form.Controls("STATUS0").Value = ""
  'Form.Controls("OBJECT1").Value = ""
  'Form.Controls("STATUS1").Value = ""
  'Form.Controls("OBJECT0_ID").Value = "ROOT_DEF"
  'Form.Controls("STATUS0_ID").Value = ""
  'Form.Controls("OBJECT1_ID").Value = ""
  'Form.Controls("STATUS1_ID").Value = ""
End Sub

'Кнопка - Найти Начальный объект
Sub BUTTON_OBJ0_ADD_OnClick()
  str = DialogShow("Выберите начальный объект","OBJ0",ThisForm)
  ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT1_ID").Value = str
  If str <> "" Then
    ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT1").Value = ThisApplication.ObjectDefs(str).Description
  End If
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS1").Value = ""
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS1_ID").Value = ""
End Sub

'Кнопка - Найти Начальный статус
Sub BUTTON_STATUS0_ADD_OnClick()
  str = DialogShow("Выберите начальный статус","STATUS0",ThisForm)
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS1_ID").Value = str
  If str <> "" Then
    ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS1").Value = ThisApplication.Statuses(str).Description
  End If
End Sub

'Кнопка - Найти Результирующий объект
Sub BUTTON_OBJ1_ADD_OnClick()
  str = DialogShow("Выберите результирующий объект","OBJ1",ThisForm)
  ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT2_ID").Value = str
  If str <> "" Then
    ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT2").Value = ThisApplication.ObjectDefs(str).Description
  End If
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS2").Value = ""
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS2_ID").Value = ""
End Sub

'Кнопка - Найти Результирующий статус
Sub BUTTON_STATUS1_ADD_OnClick()
  str = DialogShow("Выберите результирующий статус","STATUS1",ThisForm)
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS2_ID").Value = str
  If str <> "" Then
    ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS2").Value = ThisApplication.Statuses(str).Description
  End If
End Sub

'Функция диалога выбора
'Descr - Подсказка в диалоге
'TypeSel - Вариант списка
'Form - ссылка на форму
'Возврат - строка, выбранное описание
Function DialogShow(Descr,TypeSel,Form)
  DialogShow = ""
  Set Dlg = ThisApplication.Dialogs.SelectDlg
  If TypeSel = "OBJ0" or TypeSel = "OBJ1" Then
    Dlg.SelectFrom = ThisApplication.ObjectDefs
  ElseIf TypeSel = "STATUS0" Then
    Obj0id = Form.Attributes("ATTR_ROUT_MASTER_OBJECT1_ID").Value
    If Obj0id <> "" Then
      Dlg.SelectFrom = ThisApplication.ObjectDefs(Obj0id).Statuses
    Else
      Dlg.SelectFrom = ThisApplication.Statuses
    End If
  ElseIf TypeSel = "STATUS1" Then
    Obj1id = Form.Attributes("ATTR_ROUT_MASTER_OBJECT2_ID").Value
    If Obj1id <> "" Then
      Dlg.SelectFrom = ThisApplication.ObjectDefs(Obj1id).Statuses
    Else
      Dlg.SelectFrom = ThisApplication.Statuses
    End If
  End If
  
  Dlg.Prompt = Descr
  If Dlg.Show Then
    If Dlg.Objects.Count <> 0 Then
      DialogShow = Dlg.Objects(0).SysName
    End If
  End If
End Function

'Кнопка - Ок на форме
Sub Ok_OnClick()
  If ThisForm.Dictionary.Exists("FORM_KEY_PRESSED") Then
    ThisForm.Dictionary.Item("FORM_KEY_PRESSED") = "Ok"
  Else
    ThisForm.Dictionary.Add "FORM_KEY_PRESSED", "Ok"
  End If
End Sub

'Кнопка - Отмена на форме
Sub Cancel_OnClick()
  If ThisForm.Dictionary.Exists("FORM_KEY_PRESSED") Then
    ThisForm.Dictionary.Item("FORM_KEY_PRESSED") = "Cancel"
  Else
    ThisForm.Dictionary.Add "FORM_KEY_PRESSED", "Cancel"
  End If
End Sub

Sub Form_BeforeClose(Form, Obj, Cancel)
  If ThisForm.Dictionary.Item("FORM_KEY_PRESSED") = "Ok" Then
    If ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT1_ID").Value = "" or _
    ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT2_ID").Value = "" Then
      qmess = MsgBox("Вы не заполнили обязательные поля ""Начальный объект"", ""Результирующий объект""." & _
        vbCrLf & "Вернуться и заполнить поля или отменить создание маршрута?" & vbCrLf & _
        "Да - Заполнить поля" & vbCrLf & _
        "Нет - Отменить создание маршрута",vbQuestion+vbYesNo)
      If qmess = vbYes Then 
        Cancel = True
      Else
        ThisForm.Dictionary.Item("FORM_KEY_PRESSED") = "Cancel"
      End If
    End If 
  End If
End Sub

'Кнопка - Рабочий стол (начальный объект)
Sub BUTTON_DESKTOP1_OnClick()
  ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT1").Value = "Рабочие столы"
  ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT1_ID").Value = "DESKTOP_DEF"
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS1").Value = ""
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS1_ID").Value = ""
End Sub

'Кнопка - Рабочий стол (результирующий объект)
Sub BUTTON_DESKTOP2_OnClick()
  ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT2").Value = "Рабочие столы"
  ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT2_ID").Value = "DESKTOP_DEF"
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS2").Value = ""
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS2_ID").Value = ""
End Sub

'Кнопка - Объекты (начальный объект)
Sub BUTTON_ROOT1_OnClick()
  ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT1").Value = "Объекты"
  ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT1_ID").Value = "ROOT_DEF"
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS1").Value = ""
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS1_ID").Value = ""
End Sub

'Кнопка - Объекты (начальный объект)
Sub BUTTON_ROOT2_OnClick()
  ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT2").Value = "Объекты"
  ThisForm.Attributes("ATTR_ROUT_MASTER_OBJECT2_ID").Value = "ROOT_DEF"
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS2").Value = ""
  ThisForm.Attributes("ATTR_ROUT_MASTER_STATUS2_ID").Value = ""
End Sub


