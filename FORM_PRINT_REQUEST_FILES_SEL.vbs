' Форма ввода - Выбор файлов
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2016 г.


'Кнопка - Выбрать все
Sub BUTTON1_OnClick()
  Set TableRows = ThisForm.Attributes("ATTR_FILES_TBL").Rows
  For Each Row in TableRows
    Row.Attributes("ATTR_FILES_TBL_CHECK").Value = True
  Next
  ThisForm.Refresh
End Sub

'Кнопка - Снять выделения
Sub BUTTON2_OnClick()
  Set TableRows = ThisForm.Attributes("ATTR_FILES_TBL").Rows
  For Each Row in TableRows
    Row.Attributes("ATTR_FILES_TBL_CHECK").Value = False
  Next
  ThisForm.Refresh
End Sub