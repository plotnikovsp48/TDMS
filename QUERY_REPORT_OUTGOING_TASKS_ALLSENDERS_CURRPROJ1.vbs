

Sub Query_AfterExecute(Sheet, Query, Obj)
 ColName1 = "CODE_SENDER"
 ColName2 = "NAME_SENDER"
 For i = 0 To Sheet.RowsCount-1
  If Sheet.CellValue(i,ColName1) = "" Then Sheet.CellValue(i,ColName1) = Sheet.CellValue(i,ColName2)
 Next
End Sub