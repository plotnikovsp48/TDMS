Sub Query_AfterExecute(Sheet, Query, Obj)
    RCount = Sheet.RowsCount
    if Rcount <= 0 then  exit sub
    if rCount = 1 and sheet.CellValue(0,0) = "" then exit sub
    
    rang = 0 
    bl = sheet.CellValue(0,0) 
    For i=0 To RCount-1 
      Set f = Sheet.RowFormat(i)
      curBl = sheet.CellValue(i,0) 
      if bl<> curBl then 
        if rang = 0 then
          rang = 30
        else
          rang = 0
        end if
        bl = curBl
      end if
'        f.BackColor = RGB(215 + rang,215 + rang, 215 + rang)
      f.BackColor = RGB(200 + rang,240 + rang, 250 + rang)    
    Next  
End Sub

