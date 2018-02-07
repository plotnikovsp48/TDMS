Sub Query_BeforeExecute(Query, Obj, Cancel)
    If not Obj is Nothing Then
       Query.Parameter("PARAM0") = Obj 
    Else
       Set Dict = ThisApplication.Dictionary(ThisApplication.CurrentUser.SysName)
       If Dict.Exists("LETTERIN") Then 
          Set O = Dict.Item("LETTERIN")
          Query.Parameter("PARAM0") = O
       End if   
    End if   
End Sub
