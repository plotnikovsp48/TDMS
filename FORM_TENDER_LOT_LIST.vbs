' Форма ввода - Лоты
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

'Кнопка - Добавить
Sub BUTTON_ADD_OnClick()
  Set NewObj = ThisObject.Objects.Create("OBJECT_PURCHASE_LOT")
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = NewObj
  Dlg.Show
End Sub

'Кнопка - Удалить
Sub BUTTON_DEL_OnClick()
  ThisScript.SysAdminModeOn
  Set Query = ThisForm.Controls("QUERY_LOT_LIST")
  Set Objects = Query.SelectedObjects
  str = ""
  
  'Подтверждение удаления
  If Objects.Count <> 0 Then
    For Each Obj in Objects
      If Obj.Attributes.Has("ATTR_TENDER_LOT_NAME") Then
        If Obj.Attributes("ATTR_TENDER_LOT_NAME").Empty = False Then
          If str <> "" Then
            str = str & ", """ & Obj.Attributes("ATTR_TENDER_LOT_NAME").Value & """"
          Else
            str = """" & Obj.Attributes("ATTR_TENDER_LOT_NAME").Value & """"
          End If
        End If
      End If
    Next
    If str = "" Then str = Objects.Count & " лотов"
    Key = Msgbox("Удалить " & str & " из системы?",vbYesNo+vbQuestion)
    If Key = vbNo Then Exit Sub
  Else
    Exit Sub
  End If
  
  'Удаление строк из таблицы
  For Each Obj in Objects
    Obj.Erase
  Next
  ThisForm.Refresh
End Sub

Sub QUERY_LOT_LIST_Selected(iItem, action)
  If iItem <> -1 Then
    ThisForm.Controls("BUTTON_DEL").Enabled = True
  Else
    ThisForm.Controls("BUTTON_DEL").Enabled = False
  End If
End Sub

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Form.Controls("BUTTON_DEL").Enabled = False
End Sub
