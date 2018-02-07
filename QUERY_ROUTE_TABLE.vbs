

Sub Query_AfterExecute(Query, Obj, Cancel)
  Set Dict = ThisApplication.Dictionary("QueryRoute")
  If Dict.Exists("ID") = True and Dict.Exists("DESCR") = True Then
    ID = Dict.Item("ID")
    Descr = Dict.Item("DESCR")
    Call QueryChangeShow(Query,ID,Descr)
  End If
End Sub

'Процедура изменения отображения выборки
Sub QueryChangeShow(Table,ID,Descr)
  If ID = True and Descr = False Then
    For i = 7 to 1 Step -2
      Table.RemoveColumn(i)
    Next
  ElseIf ID = False and Descr = True Then
    For i = 8 to 2 Step -2
      Table.RemoveColumn(i)
    Next
  ElseIf ID = False and Descr = False Then
    For i = 8 to 1 Step -1
      Table.RemoveColumn(i)
    Next
  End If
End Sub
