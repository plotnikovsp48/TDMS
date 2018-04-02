
Sub Query_AfterExecute(Sheet, Query, Obj)
  For i = 0 to Sheet.RowsCount-1
    newVal = Sheet.CellValue(i,"Размер, КБ")
    newval = round(cDbl(newval)/1024,1)
    Sheet.CellValue(i,"Размер, КБ") = newval
    if Sheet.CellValue(i,0) = "Скан документа" then Sheet.CellValue(i,0) = " Скан документа"
  next
  sheet.Sort 0
End Sub

Sub Query_BeforeExecute(Query, Obj, Cancel)
  If Obj Is Nothing Then Exit Sub
  if Obj.Permissions.ViewFiles <> 1 then 
'    if Obj.Permissions.EditFiles=tdmallow then
'      Query.Sheet(0,0) = "Не достаточно прав для просмотра файлов"
      Cancel = True
'    End If
  End If
End Sub
