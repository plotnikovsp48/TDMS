Sub Object_BeforeCreate(o_, p_, Cancel)
  
  Dim vOInitialStatus
  Dim vPInitialStatus
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",p_,p_.Status,o_,o_.ObjectDef.InitialStatus)    

End Sub

Sub Object_BeforeErase(o_, cn_)
  cn_= ThisApplication.ExecuteScript("CMD_S_DLL", "CheckBeforeErase", o_) 
  If cn_ Then Exit Sub
  Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", o_) 
End Sub
