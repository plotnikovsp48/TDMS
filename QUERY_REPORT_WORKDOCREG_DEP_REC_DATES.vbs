Sub Query_AfterExecute(Sheet, Query, Obj)
 ColName1 = "DEP_RECEIVERS_CODE"
 ColName2 = "DEP_RECEIVERS_NAME"
 For i = 0 To Sheet.RowsCount-1
  If Sheet.CellValue(i,ColName1) = "" Then Sheet.CellValue(i,ColName1) = Sheet.CellValue(i,ColName2)
 Next
End Sub

