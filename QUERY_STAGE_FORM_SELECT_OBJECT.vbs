

Sub Query_AfterExecute(Sheet, Query, Obj)
  Count = Sheet.RowsCount
  ThisApplication.Utility.WaitCursor = True
  For i = Count-1 to 0 Step -1
    Set o_ = Sheet.RowValue(i)
    If o_.Attributes.Has("ATTR_CONTRACT_STAGE") = False Then
      Sheet.RemoveRow i
    End If
  Next
  ThisApplication.Utility.WaitCursor = False
End Sub