' Выборка - Удаление объектов Технического документооборота
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.


Sub Query_AfterExecute(Sheet, Query, Obj)
  Sheet.AddColumn 1
  ColNum = Sheet.ColumnsCount-1
  Sheet.ColumnName(ColNum) = "Кол-во в составе"
  For i = 0 to Sheet.RowsCount-1
    Set Obj0 = Sheet.RowValue(i)
    Sheet.CellValue(i,ColNum) = Obj0.Content.Count
  Next
  Sheet.Sort 2
End Sub