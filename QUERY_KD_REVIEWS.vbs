use CMD_KD_GLOBAL_VAR_LIB

Sub Query_BeforeExecute(Query, Obj, Cancel)
  Query.Parameter("PARAM0") = GetObjectGlobalVarrible("ParDocBase")
End Sub