' Создание выборок новых проектов/обновление выборок существующих проектов

call Run()

Sub Run()
  ThisScript.SysAdminModeOn
  List = "Накладные,Переписка,Служебные записки"    
  arr = Split(List,",")
  
  For Each proj in ThisApplication.ObjectDefs("OBJECT_PROJECT").Objects
    For each q in arr
      If proj.Queries.Has(q) Then
        Set Query = proj.Queries(q)
          Query.Queries.RemoveAll
      End If
      proj.Queries.RemoveAll
    Next
    proj.Queries.RemoveAll
    Call AddSubQ(proj)
  Next
End Sub

Sub AddSubQ(proj)
  ThisScript.SysAdminModeOn
  ' Добавление выборки "Накладные"
  proj.Queries.AddCopy ThisApplication.Queries("QUERY_INVOICE_IN_PROJECT") 
  
  ' Добавление выборки "Переписка"
  proj.Queries.AddCopy ThisApplication.Queries("QUERY_MAILS_BY_CONTRACT")
    
  on error resume next
  If proj.Queries.Has("Переписка") Then
    Set Query = proj.Queries("Переписка")
    ' Добавление выборки "Входящая корреспонденция"
    Query.Queries.AddCopy ThisApplication.Queries("QUERY_IN_MAILS_BY_PROJECT")
    ' Добавление выборки "Исходящая корреспонденция"
    Query.Queries.AddCopy ThisApplication.Queries("QUERY_OUT_MAILS_BY_PROJECT")
  End If
  on error goto 0
      
  ' Добавление выборки "Служебные записки"
  proj.Queries.AddCopy ThisApplication.Queries("QUERY_MEMO_BY_PROJECT") 
End Sub
