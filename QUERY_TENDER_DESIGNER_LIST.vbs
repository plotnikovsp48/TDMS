' Команда - Разработчики
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Sub Query_AfterExecute(Sheet, Query, Obj)
  For i = 0 to Sheet.ColumnsCount-1
    Sheet.RemoveColumn Sheet.ColumnsCount-1
  Next
  Sheet.AddColumn 3
  Sheet.ColumnName(0) = "ФИО"
  Sheet.ColumnName(1) = "Должность"
  Sheet.ColumnName(2) = "Элемент оргструктуры"
  
  For i = 0 To Sheet.RowsCount-1
    Set User = Sheet.RowValue(i)
    AttrName = "ATTR_KD_FIO"
    If User.Attributes.Has(AttrName) Then
      Val = User.Attributes(AttrName).Value
      If Val <> "" Then
        Sheet.CellValue(i,0) = Val
      Else
        Sheet.CellValue(i,0) = User.Description
      End If
    End If
    AttrName = "ATTR_POST"
    If User.Attributes.Has(AttrName) Then
      Sheet.CellValue(i,1) = User.Attributes(AttrName).Value
    ElseIf User.Position <> "" Then
      Sheet.CellValue(i,1) = User.Position
    End If
    AttrName = "ATTR_KD_USER_DEPT"
    If User.Attributes.Has(AttrName) Then
      If User.Attributes(AttrName).Empty = False Then
        If not User.Attributes(AttrName).Object is Nothing Then
          Sheet.CellValue(i,2) = User.Attributes(AttrName).Object.Description
        End If
      End If
    End If
  Next
End Sub