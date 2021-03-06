' Выборка - Основные комплекты по проекту. Отчёт
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2016 г.

Sub Query_AfterExecute(Sheet, Query, Obj)
  Sheet.AddColumn 2
  nCol0 = Sheet.ColumnsCount-3
  nCol1 = Sheet.ColumnsCount-2
  nCol2 = Sheet.ColumnsCount-1
  Sheet.ColumnName(nCol0) = "Ответственный проектировщик"
  Sheet.ColumnName(nCol1) = "Кол-во Документов/Чертежей"
  Sheet.ColumnName(nCol2) = "Кол-во Документов/Чертежей в разработке"
  Sheet.ColumnName(0) = "Проект"
  
  For i = 0 to Sheet.RowsCount-1
    Set WorkDocsSet = Sheet.RowValue(i)
    Sheet.CellValue(i,nCol1) = WorkDocsSet.ContentAll.Count
    Count = 0
    For Each Obj in WorkDocsSet.ContentAll
      If Obj.StatusName = "STATUS_DOCUMENT_CREATED" Then Count = Count + 1
    Next
    Sheet.CellValue(i,nCol2) = Count
  Next
End Sub
