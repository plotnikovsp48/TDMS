use CMD_KD_QUERY_LIB

Sub Query_BeforeExecute(Query, Obj, Cancel)
    setCurUser(Query)
    'thisApplication.Users("Сенютин Александр Анатольевич")' 
End Sub

Sub Query_AfterExecute(Sheet, Query, Obj)
    RCount = Sheet.RowsCount
    hasImp = HasStColumn(sheet,"Срочно") and HasStColumn(sheet,"Особая важность")
    For i=0 To RCount-1 
      Set f = Sheet.RowFormat(i)
      sDate = sheet.CellValue(i, "План. срок")
      if  isDate(sdate) then 
        dDate = CDate(sDate)
        if dDate < Date then 
'            f.Bold = TRUE 
            f.Color = RGB(255,0, 0)
        end if  
      end if  
      if (sheet.CellValue(i, "Статус") = "Подготовлен отчет" or sheet.CellValue(i, "Запрошенный срок") > "") then 
        contr = sheet.CellValue(i, "Контролер")
        if contr = "" or thisApplication.CurrentUser.Description = contr then _
          f.Bold = TRUE 
      end if  
      if hasImp then   
        if sheet.CellValue(i, "Срочно") = true or sheet.CellValue(i, "Особая важность") = true then 
          f.BackColor = RGB(255,255, 155)  
        end if  
      end if  
    Next  
End Sub
