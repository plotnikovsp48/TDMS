use CMD_KD_GLOBAL_VAR_LIB

Sub Query_AfterExecute(Sheet, Query, Obj)
  if IsEmpty(obj) then exit sub
  if obj is nothing then exit sub
  If Obj.IsKindOf("OBJECT_PURCHASE_OUTSIDE") or Obj.IsKindOf("OBJECT_TENDER_INSIDE") Then
      set q = thisapplication.Queries("QUERY_TENDER_FILES_IN_CHILD")
      If Not q Is Nothing Then
        q.Parameter("PARAM0") = Obj
        set sh = q.Sheet
        Sheet.Set sh
      End If
  end if
  showOld = false 'true'false
  if IsExistsGlobalVarrible("ShowOldFile") then _ 
      showOld =  GetGlobalVarrible("ShowOldFile")

  For i = 0 to Sheet.RowsCount-1
    if i > Sheet.RowsCount-1 then exit for
    fName = Sheet.CellValue(i,"Файл")
    if inStr(fName,"[_")>0 and inStr(fName,"_]")>0 and  not showOld then 
      sheet.RemoveRow i
      i = i - 1
    else
      newVal = Sheet.CellValue(i,"Размер, КБ")
      newval = round(cDbl(newval)/1024,1)
      Sheet.CellValue(i,"Размер, КБ") = newval
      if Sheet.CellValue(i,0) = "Скан документа" then Sheet.CellValue(i,0) = " Скан документа"
    end if
  next
  sheet.Sort 0
End Sub
