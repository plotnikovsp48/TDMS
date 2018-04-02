use CMD_KD_QUERY_LIB

Sub Query_BeforeExecute(Query, Obj, Cancel)
    setCurUser(Query)
End Sub

Sub Query_AfterExecute(Sheet, Query, Obj)
'thisApplication.AddNotify "befor " & Cstr(Timer) 
    RCount = Sheet.RowsCount
    hasImp = HasStColumn(sheet,"Срочно") and HasStColumn(sheet,"Особая важность")
    For i=0 To RCount-1 
      Set f = Sheet.RowFormat(i)
      sDate = sheet.CellValue(i, "Плановый срок исполнения")
      if  isDate(sdate) then 
        dDate = CDate(sDate)
        if dDate < Date then 
            'f.Bold = TRUE 
            f.Color = RGB(255,0, 0)
        end if  
      end if  
      if sheet.CellValue(i, "Статус") = "Выдано" then 
          Set f = Sheet.RowFormat(i)
          f.Bold = TRUE 
      end if  
      if hasImp then   
        if sheet.CellValue(i, "Срочно") = true or sheet.CellValue(i, "Особая важность") = true then 
          f.BackColor = RGB(255,255, 155)  
        end if  
      end if  
    Next  
'thisApplication.AddNotify "after " & Cstr(Timer)
End Sub
