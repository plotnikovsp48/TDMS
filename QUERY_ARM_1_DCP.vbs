use CMD_KD_QUERY_LIB

Sub Query_BeforeExecute(Query, Obj, Cancel)
  setCurUser(Query)
End Sub

Sub Query_AfterExecute(Sheet, Query, Obj)
  call SetNewOrder(Sheet, Query, Obj)
end sub