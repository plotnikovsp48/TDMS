use CMD_KD_QUERY_LIB

Sub Query_BeforeExecute(Query, Obj, Cancel)
    Query.Parameter("PARAM0") = thisApplication.CurrentUser 
End Sub

Sub Query_AfterExecute(Sheet, Query, Obj)
  call SetNewOrder(Sheet, Query, Obj)
end sub

'Sub Query_AfterExecute(Sheet, Query, Obj)
'    isRuk = thisApplication.CurrentUser.Groups.Has("GROUP_CHIEFS")
''    RCount = Sheet.RowsCount
'    For i=0 To Sheet.RowsCount-1 
'      if Sheet.RowsCount = i then exit for
'      set doc = sheet.Objects(i)
'      if doc.ObjectDefName = "OBJECT_KD_DOC_IN" and doc.StatusName = "STATUS_KD_REGISTERED" and not isRuk then
'        sheet.RemoveRow(i)
'        i = i-1
'      else 
'        if sheet.CellValue(i, "Статус") = "Выдано" then 
'            Set f = Sheet.RowFormat(i)
'            f.Bold = TRUE 
'        end if  
'      end if  
'    Next  
'End Sub
