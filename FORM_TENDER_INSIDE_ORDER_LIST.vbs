' Форма ввода - Заявки
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Sub ATTR_TENDER_INSIDE_ORDER_LIST_CellInitEditCtrl(nRow, nCol, pEditCtrl, bCancelEdit)
  'Управление доступностью атрибута Цена после уторговывания
  StatusName = ThisObject.StatusName
  If nCol = 2 and StatusName <> "STATUS_TENDER_IN_PUBLIC" and StatusName <> "STATUS_TENDER_CHECK_RESULT" Then
    pEditCtrl.ReadOnly = True
  End If
End Sub