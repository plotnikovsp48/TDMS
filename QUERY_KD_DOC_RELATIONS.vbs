use CMD_KD_GLOBAL_VAR_LIB

Sub Query_BeforeExecute(Query, Obj, Cancel)
  if obj is nothing then 
    set obj = GetObjectGlobalVarrible("DOCBASE")
    if obj is nothing then _
      set obj = thisApplication.GetObjectByGUID("{F9D4D530-EC20-456F-BC04-9A5C67ADF6A0}")
  end if
  Query.Parameter("PARAM0") = obj
End Sub
