USE "_Colors"

Sub Query_BeforeExecute(Query, Obj, Cancel)
  ' -- > Case 5808 --
  sKurator = GetSubUsers()
  Query.Parameter("pKurator") = sKurator
  ' -- Case 5808 < --
End Sub

Sub Query_AfterExecute(Sheet, Query, Obj)
  ' -- > Case 5808 --
  If Sheet.RowsCount = 0 Then Exit Sub
  With Sheet
    For i = 0 To .RowsCount -1
      ' диапазон плановая дата - 7 дней
      iEnd = DateToLong(.CellValue(i, "C_DateEnd"))
      iNow = DateToLong(ThisApplication.CurrentTime)
      .RowFormat(i).BackColor = ColorScaleRYG (iNow,iEnd-7,iEnd)
    Next
  End With
  ' -- Case 5808 < --
End Sub

Function GetSubUsers()
GetSubUsers = "=UNDEFINED"
  Set qORGStruct = ThisApplication.Queries("QUERY_USERS_SUBORDINATE")
    qORGStruct.Parameter("pChief") = ThisApplication.CurrentUser.SysName
  Set oResult = qORGStruct.Users
  If oResult.Count = 0 Then Exit Function
  Dim aUsers () : Redim aUsers(oResult.Count-1) : iCounter = 0
  For Each uSubOrdinate In oResult
    aUsers(iCounter) = "="""+uSubOrdinate.SysName+""""
    iCounter = iCounter + 1
  Next
GetSubUsers = Join (aUsers, " Or ")
End Function
