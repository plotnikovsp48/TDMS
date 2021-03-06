use CMD_KD_GLOBAL_VAR_LIB
use CMD_KD_CURUSER_LIB

Sub setCurUser(Query)
    set user = GetCurUser()
    Query.Parameter("PARAM0") = user
    'Query.Parameter("PARAM0") = thisApplication.Users("Теликова Раиса Сергеевна")
    'thisApplication.CurrentUser 
    'thisApplication.Users("Секретарь Москва")
    'thisApplication.CurrentUser 
    'thisApplication.Users("Смагина Юлия Германовна")
    'thisApplication.Users("Червякова Татьяна Николаевна")
    'thisApplication.CurrentUser 
    'thisApplication.Users("Сенютин Александр Анатольевич")' selObject
End Sub

'=============================================
Sub SetNewOrder(Sheet, Query, Obj)
    RCount = Sheet.RowsCount
    hasST = HasStColumn(sheet,"Статус поручения")
    hasImp = HasStColumn(sheet,"Срочно") and HasStColumn(sheet,"Особая важность")
    For i=0 To RCount-1 
      Set f = Sheet.RowFormat(i)
      if hasST then 
        if sheet.CellValue(i, "Статус поручения") = "Выдано" then 
          f.Bold = TRUE 
        end if  
      end if  
      if hasImp then 
        if sheet.CellValue(i, "Срочно") = true or sheet.CellValue(i, "Особая важность") = true then 
          f.BackColor = RGB(255,255, 155)  
        end if  
      end if  
'      set obj = sheet.Objects(i)
'      if not obj is nothing then
'        isImp = false
'        if Obj.Attributes.has("ATTR_KD_URGENTLY") then
'          if Obj.Attributes("ATTR_KD_URGENTLY").value then isImp = sImp or true
'        end if
'        if Obj.Attributes.has("T_ATTR_KD_IMPORTANT") then
'          if Obj.Attributes("T_ATTR_KD_IMPORTANT").value then isImp = isImp or true
'        end if
'        if isImp then f.BackColor = RGB(255,255, 155)  
'      end if
    Next  
End Sub

'=============================================
function HasStColumn(sheet, colName)
  HasStColumn = false
  for i = 0 to sheet.ColumnsCount -1
    if sheet.ColumnName(i) = colName then 
      HasStColumn = true
      exit function
    end if  
  next
end function
