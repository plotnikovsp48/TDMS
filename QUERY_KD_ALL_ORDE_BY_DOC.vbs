Sub Query_AfterExecute(Sheet, Query, Obj)
'  thisapplication.AddNotify Cstr(Timer()) & " 1"
  RCount = Sheet.RowsCount
  Sheet.InsertColumn 0
  Sheet.ColumnName(0) = "№пп"
  Sheet.InsertColumn 1
  Sheet.ColumnName(1) = "Int"
  
  ind = 1
  For i=0 To Sheet.RowsCount-1
    if Sheet.CellValue(i, "Guid") = "" then 
      Sheet.CellValue(i, "№пп") = ind
      Sheet.CellValue(i, "Int") = right("0"&ind & "0000000" ,9)'left("0"&ind & "0000000" ,9)
      set ord = sheet.Objects(i)
      ord.permissions = SysAdminPermissions
'      thisApplication.DebugPrint Sheet.CellValue(i, "От кого")
'      Sheet.CellValue(i, "От кого") = ord.Attributes("ATTR_CORR_ORDER_FROM").User.Attributes("ATTR_USER_FIO").value
'      Sheet.CellValue(i, "Кому") = ord.Attributes("ATTR_CORR_ORDER_TO").User.Attributes("ATTR_USER_FIO").value
      Set f = Sheet.RowFormat(i)
'      If InStr(ord.Attributes("ATTR_SUMMARY_RESOLUTION").Value,"Отменить назначение ответственным") <> 0 or _
'         InStr(ord.Attributes("ATTR_SUMMARY_RESOLUTION").Value,"Отказ от участия в рассылке") <> 0 Then        
'         f.Color = RGB(255,0, 0)
'      End if  
      If ord.status.sysname = "STATUS_CORR_ORDER_NEW" Then f.Bold = True 
      SetChidNo ind, sheet.Objects(i), Sheet 
      ind = ind + 1
    end if
  next
  Sheet.Sort "Int"
  Sheet.RemoveColumn "Guid"
  Sheet.RemoveColumn "Int"

 ' thisapplication.AddNotify Cstr(Timer()) & " 2"
End Sub

sub SetChidNo (No, parent,Sheet )
  ind = 1
  parent.permissions = SysAdminPermissions
  For i = 0 To Sheet.RowsCount-1
    if Sheet.CellValue(i, "Guid") = parent.GUID then 
      Sheet.CellValue(i, "№пп") = No & "." & ind
      Sheet.CellValue(i, "Int") = GetIntNo(Sheet.CellValue(i, "№пп"))

      set ord = sheet.Objects(i)
      ord.permissions = SysAdminPermissions
'      Sheet.CellValue(i, "От кого") = ord.Attributes("ATTR_CORR_ORDER_FROM").User.Attributes("ATTR_USER_FIO").value
'      Sheet.CellValue(i, "Кому") = ord.Attributes("ATTR_CORR_ORDER_TO").User.Attributes("ATTR_USER_FIO").value
      Set f = Sheet.RowFormat(i)
'      If InStr(ord.Attributes("ATTR_SUMMARY_RESOLUTION").Value,"Отменить назначение ответственным") <> 0 or _
'         InStr(ord.Attributes("ATTR_SUMMARY_RESOLUTION").Value,"Отказ от участия в рассылке") <> 0 Then        
'         f.Color = RGB(255,0, 0)
'      End if  
      If ord.status.sysname = "STATUS_CORR_ORDER_NEW" Then f.Bold = True 
      SetChidNo Sheet.CellValue(i, "№пп"), sheet.Objects(i),Sheet 
      ind = ind + 1
    end if
  next
end sub

function GetIntNo (oldNo)
    arr = Split(oldNo,".")
    GetIntNo = right("0"&arr(0),2)
    for i = 1  to Ubound(Arr)
      GetIntNo = GetIntNo & right("0"&arr(i),2)
    next
    GetIntNo = left(GetIntNo  & "0000000",9)
end function

Sub Query_BeforeExecute(Query, Obj, Cancel)
    ThisScript.SysAdminModeOn
    If Obj is nothing then 
        set curObj = thisApplication.GetObjectByGUID("{DC5BA722-A75A-4B1C-8028-C99B287E37F3}") ' EV для тестирования
        if curObj is nothing then
          cancel = true
          exit sub
        end if
    else 
        set curObj = Obj
    end if
    if curObj.ObjectDef.SuperObjectDefs(TRUE).Has("OBJECT_KD_ORDER") then ' EV если поручение
      set doc = curObj.Attributes("ATTR_KD_DOCBASE").Object
      if doc is nothing then
        Cancel = true
        exit sub
      else      
        Query.Parameter("PARAM0") = doc 
      end if
    else ' EV если в формы документа
      if curObj.ObjectDef.SuperObjectDefs(TRUE).Has("OBJECT_KD_BASE_DOC") then
        Query.Parameter("PARAM0") = curObj
      else
        Cancel = true
      end if
    end if
End Sub

