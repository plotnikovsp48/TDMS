
Sub Query_AfterExecute(Sheet, Query, Obj)
  For i = 0 to Sheet.RowsCount-1
    newVal = Sheet.CellValue(i,"Размер Кб")
    newval = round(cDbl(newval)/1024,2)
    Sheet.CellValue(i,"Размер Кб") = newval
  next
End Sub
  
