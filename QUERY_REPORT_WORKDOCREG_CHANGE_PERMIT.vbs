
Sub Query_AfterExecute(Sheet, Query, Obj)
 ColName1 = "CH_PERM_NUM"
 ColName2 = "CH_PERM_DATA"
 ColName3 = "USER_FIO"
 ColName4 = "USER_NAME" 
 For i = 0 To Sheet.RowsCount-1
  If Sheet.CellValue(i,ColName3) = "" Then Sheet.CellValue(i,ColName3) = Sheet.CellValue(i,ColName4)
 Next
End Sub