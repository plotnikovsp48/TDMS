
Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
  call thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","RemoveGlobalVarrible","OrderForm")
  call thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","RemoveGlobalVarrible","templ")
  call thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","RemoveGlobalVarrible","DocObj")
End Sub
