

call Run()

Sub Run()
ThisScript.SysAdminModeOn
  For Each Obj in ThisApplication.ObjectDefs("OBJECT_STAGE").Objects
    Obj.Queries.RemoveAll
  Call AddSubQ(Obj)
  Next
End Sub

Sub AddSubQ(proj)
' Добавление выборки "Документация, передаваемая заказчику"
  proj.Queries.AddCopy ThisApplication.Queries("QUERY_DOCS_FOR_CUSTOMER")
End Sub
