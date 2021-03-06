' Команда - Документы разработчика
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.


Sub Query_BeforeExecute(Query, Obj, Cancel)
  Set Dict = ThisApplication.Dictionary(Obj.GUID)
  'Объект-контейнер
  If Dict.Exists("QueryObjGuid") Then
    Guid = Dict.Item("QueryObjGuid")
    Set Obj0 = ThisApplication.GetObjectByGUID(Guid)
    If not Obj0 is Nothing Then
      Query.Parameter("PARENT") = Obj0
    End If
  Else
    Query.Parameter("PARENT") = Obj
  End If
  'Выбранный пользователь
  If Dict.Exists("QuerySelUser") Then
    SysName = Dict.Item("QuerySelUser")
    Dict.Remove("QuerySelUser") 
    If ThisApplication.Users.Has(SysName) Then
      Set User = ThisApplication.Users(SysName)
      Query.Parameter("USER") = User
    End If
  Else
    Query.Parameter("USER") = Nothing
  End If
End Sub
