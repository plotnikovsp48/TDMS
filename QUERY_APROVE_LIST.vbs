

Sub Query_AfterExecute(Sheet, Query, Obj)
    RCount = Sheet.RowsCount
    if obj is nothing then exit sub
    thisApplication.DebugPrint Rcount
    if Rcount <= 0 then  exit sub
    if rCount = 1 and sheet.CellValue(0,0) = 0 then exit sub
    
    set agreeObj = thisApplication.ExecuteScript("FORM_KD_AGREE","GetAgreeObjByObj", Obj)
    if agreeObj is nothing then exit sub
    rev = agreeObj.Attributes("ATTR_KD_CUR_VERSION").value
    rang = 0 
    bl = sheet.CellValue(0,0) 
    For i=0 To RCount-1 
      Set f = Sheet.RowFormat(i)
      curBl = sheet.CellValue(i,1) 
      if bl<> curBl then 
        if rang = 0 then
          rang = 30
        else
          rang = 0
        end if
        bl = curBl
      end if
      if rev > sheet.CellValue(i,"Версия") then   
        f.BackColor = RGB(215 + rang,215 + rang, 215 + rang)
        f.Color = RGB(90,90,90)
        if Sheet.CellValue(i,"Статус") = "" then Sheet.CellValue(i,"Статус") = "Отменено автором" '"Не согласовывалось"
      else
        f.BackColor = RGB(200 + rang,240 + rang, 250 + rang)    
      end if  
      icoName = "IMG_OBJECT_KD_ORDER_NOTICE_SENT"
      select case Sheet.CellValue(i,"Статус")
        case "Согласовано"  icoName = "IMG_OK"
        case "Отклонено" icoName = "IMG_CANCEL" 
        case "Отменено" icoName = "IMG_COMMAND_DELETE"
              Sheet.CellValue(i,"Статус") = "Отменено автором"
        case else  icoName = "IMG_OBJECT_KD_ORDER_NOTICE_SENT"
                  if rev = sheet.CellValue(i,"Версия") then   f.Bold = TRUE 
      end select  
'      set icon = Sheet.RowIcon(i)
'      if not icon is null then _
          if Sheet.RowIcon(i).SysName <> icoName then _
                Sheet.RowIcon(i) = thisApplication.Icons(icoName)         

      sDate = sheet.CellValue(i, 2)'"Cрок согласования")  
      if Sheet.CellValue(i,"Статус") = "" then 
        if  isDate(sdate) then 
          dDate = CDate(sDate)
          if dDate <= Date then 
              f.Bold = TRUE 
              f.Color = RGB(255,0, 0)
          end if  
        end if  
      end if

    Next  
End Sub
