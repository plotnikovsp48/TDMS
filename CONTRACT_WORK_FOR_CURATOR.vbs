
Sub Query_AfterExecute(Sheet, Query, Obj)
  dim count
  dim o
    count = Sheet.RowsCount
  For i = 0 to count-1
    Set f = Sheet.RowFormat(i)
    Set o = Sheet.RowValue(i)    
    Set q1 = ThisApplication.Queries.Item("THE_MILESTONES_ON_THE_CONTRACTS_EXPIRED") 'Просроченные
      q1.Parameter("PARAM0") = o
      count1 = q1.Sheet.RowsCount
    Set q2 = ThisApplication.Queries.Item("STAGES_OF_THE_CONTRACTS_WILL_COME_SOON") 'Приближающиеся
      q2.Parameter("PARAM0") = o
      count2 = q2.Sheet.RowsCount    
    If count1>0 Then 'Если есть просроченные этапы по договору, выполнит подсветку красным
      f.BackColor = RGB(255, 0, 0)        
    elseIf count2>0 Then 'Если нет просроченных, а есть приближающиеся этапы по договору, выполнит подсветку желтым
      f.BackColor = RGB(255, 255, 0)       
    End If   
  Next
End Sub
