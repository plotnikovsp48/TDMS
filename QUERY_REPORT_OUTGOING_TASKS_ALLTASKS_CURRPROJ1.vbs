Sub Query_AfterExecute(Sheet, Query, Obj)
 ColName1 = "CODE_SENDER"
 ColName2 = "NAME_SENDER"
 ColName3 = "CODE_RECEIVER"
 ColName4 = "NAME_RECEIVER"
 For i = 0 To Sheet.RowsCount-1
  If Sheet.CellValue(i,ColName1) = "" Then Sheet.CellValue(i,ColName1) = Sheet.CellValue(i,ColName2)
  If Sheet.CellValue(i,ColName3) = "" Then Sheet.CellValue(i,ColName3) = Sheet.CellValue(i,ColName4)
 Next
End Sub
