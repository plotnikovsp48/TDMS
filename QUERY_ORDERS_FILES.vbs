
Sub Query_BeforeExecute(Query, Obj, Cancel)
    If Obj is nothing then 
        set curObj = thisApplication.GetObjectByGUID("{BB7C7BEB-1926-4A6B-8FCE-B1A3769EA3FF}") ' EV для тестирования
        if curObj is nothing then
          cancel = true
          exit sub
        end if
    else 
        set curObj = Obj
    end if
    Query.Parameter("PARAM0") = curObj.Handle
End Sub
