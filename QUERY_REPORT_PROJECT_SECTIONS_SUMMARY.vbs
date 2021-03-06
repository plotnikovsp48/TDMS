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
    Count0 = 0
    Count1 = 0
    For Each Obj in WorkDocsSet.ContentAll
      If Obj.ObjectDefName = "OBJECT_DOC_DEV" or Obj.ObjectDefName = "OBJECT_DRAWING" Then
        Count0 = Count0 + 1
        If Obj.StatusName = "STATUS_DOCUMENT_CREATED" Then Count1 = Count1 + 1
      End If
    Next
    Sheet.CellValue(i,nCol1) = Count0
    Sheet.CellValue(i,nCol2) = Count1
  Next
End Sub

    