use CMD_KD_GLOBAL_VAR_LIB 

Sub Query_BeforeExecute(Query, Obj, Cancel)
  docDef = GetGlobalVarrible("DOC_DEF")
  if docDef <> "" then query.Parameter("PARAM0") = docDef
End Sub