

Sub Query_AfterExecute(Sheet, Query, Obj)
  if sheet.RowsCount = 0 then exit sub
  set curUser = sheet.Users(0)
  set us = curUser.GetDelegatedRightsToUsers()
  sheet.RemoveRow(0)
'  sheet.Users.Remove(curUser)
  i = 0
  for each user in us
    sheet.Add(user)
    sheet.CellValue(i,0) = user.Description
    sheet.CellValue(i,1) = user.Position
    sheet.CellValue(i,2) = user.Attributes("ATTR_KD_USER_DEPT").value
    sheet.CellValue(i,3) = user.Attributes("ATTR_KD_DEPART").value        
    i = i+1
  next
End Sub