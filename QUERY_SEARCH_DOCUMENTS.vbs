
Sub Query_AfterExecute(Sheet, Query, Obj)
For i=0 To Sheet.RowsCount-1
  If Sheet.CellValue(i,"D_P_TYPE")<>"" Then Sheet.CellValue(i,"Тип документа")=Sheet.CellValue(i,"D_P_TYPE")
Next
Sheet.RemoveColumn "D_P_TYPE"
End Sub