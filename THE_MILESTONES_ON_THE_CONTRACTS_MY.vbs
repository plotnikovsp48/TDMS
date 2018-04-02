

Sub SetNewOrder(Sheet, Query, Obj)
  RCount = Sheet.RowsCount
  CCount = Sheet.ColumnsCount  
  for j=0 to CCount-1
    if sheet.ColumnName(j)= "Дата окончания работ по плану" then
    s=j       
  end if  
  Next
  for i=0 to RCount-1    
    Set f = Sheet.RowFormat(i)            
    if Sheet.CellValue(i,s) < date then
      f.BackColor = RGB(255, 182, 193)
    elseif Sheet.CellValue(i,s) < DateAdd( "m", 1, date) then
        f.BackColor = RGB(255, 255, 192)       
    end if  
  Next
End Sub  

Sub Query_AfterExecute(Sheet, Query, Obj)
  call SetNewOrder(Sheet, Query, Obj)  
End Sub
