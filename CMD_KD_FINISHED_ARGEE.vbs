

if not thisObject is nothing then 
  set docObj = thisObject
  set agreeObj = thisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "GetAgreeObjByObj", docObj)
  if not agreeObj is nothing then 
    call thisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "Set_DocDone", docObj, agreeObj)
  end if
end if  