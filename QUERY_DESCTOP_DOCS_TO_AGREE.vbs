
Sub Query_BeforeExecute(Query, Obj, Cancel)
    Query.Parameter("PARAM0") = thisApplication.CurrentUser 
    'thisApplication.Users("Сенютин Александр Анатольевич")' 
End Sub

Sub Query_AfterExecute(Sheet, Query, Obj)
    RCount = Sheet.RowsCount
    For i=0 To RCount-1 
      if sheet.CellValue(i, "Статус") = "Выдано" then 
          Set f = Sheet.RowFormat(i)
          f.Bold = TRUE 
      end if  

    Next  
End Sub
