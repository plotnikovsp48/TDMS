

call Run()

Sub Run()
ThisScript.SysAdminModeOn
  For Each proj in ThisApplication.ObjectDefs("OBJECT_CONTRACT").Objects
  
    If proj.Queries.Has("Переписка") Then
      Set Query = proj.Queries("Переписка")
      Query.Queries.RemoveAll
    End If
    proj.Queries.RemoveAll
  Call AddSubQ(proj)
  Next
End Sub

Sub AddSubQ(proj)
' Добавление выборки "Этапы"
  proj.Queries.AddCopy ThisApplication.Queries("QUERY_CONTRACT_STAGES")
  
  ' Добавление выборки "Акты"
  proj.Queries.AddCopy ThisApplication.Queries("QUERY_CONTRACT_COMPL_REPS")
  
  ' Добавление выборки "Соглашения"
  proj.Queries.AddCopy ThisApplication.Queries("QUERY_AGREEMENTS_BY_CONTRACT")
  
  ' Добавление выборки "Протоколы"
  proj.Queries.AddCopy ThisApplication.Queries("QUERY_PROTOCOLS_BY_CONTRACT")
  
  ' Добавление выборки "Переписка"
  proj.Queries.AddCopy ThisApplication.Queries("QUERY_MAILS_BY_CONTRACT")
  
  on error resume next
  If proj.Queries.Has("Переписка") Then
    Set Query = proj.Queries("Переписка")
    ThisScript.SysAdminModeOn
    ' Добавление выборки "Входящая корреспонденция"
    Query.Queries.AddCopy ThisApplication.Queries("QUERY_IN_MAILS_BY_CONTRACT")
    ' Добавление выборки "Исходящая корреспонденция"
    Query.Queries.AddCopy ThisApplication.Queries("QUERY_OUT_MAILS_BY_CONTRACT")
  End If
  on error goto 0
End Sub
