'use CMD_KD_QUERY_LIB

Sub Query_BeforeExecute(Query, Obj, Cancel)
    dim q
    dim sheet
    dim coont
    dim u
    dim dlg
    Set q = ThisApplication.Queries("QUERY_KD_SDIR")
    Set users = q.users
    count = 0
    For each u in users

      count = count +1
      pname = "SIGN" & count
      Query.Parameter(pname)=u
      ' Проверка замещения
      Set dlg = ChDeligate(u)  
      If not dlg is nothing Then
        pdlgname = "DLG" & count
        Query.Parameter(pdlgname)=dlg
      End If      
    Next  
End Sub

'Sub Query_AfterExecute(Sheet, Query, Obj)
'    call SetNewOrder(Sheet, Query, Obj)
'End Sub


Function ChDeligate(u)
  Set ChDeligate = Nothing
  Set us = u.GetDelegatedRightsFromUsers
  For Each udlg in us
    Set ChDeligate = udlg
    Exit Function ' только от одного руководителя, т.к. параметры выборки DLG+№ = числу руководителей = 4
  Next
End Function
