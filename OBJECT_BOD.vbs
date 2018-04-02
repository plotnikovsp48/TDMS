Sub Object_BeforeCreate(o_, p_, Cancel)
  set o=p_.Objects.ObjectsByDef(o_.ObjectDefName)
  if o.Count>1 then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation,1203,o_.Description, p_.Description
    Cancel=true
  end if
  Dim vOInitialStatus
  Dim vPInitialStatus
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",p_,p_.Status,o_,o_.ObjectDef.InitialStatus)    
End Sub


Sub Object_BeforeErase(o_, cn_)
  cn_= ThisApplication.ExecuteScript("CMD_S_DLL", "CheckBeforeErase", o_) 
  Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", o_) 
End Sub
 

 Sub Object_BeforeContentRemove(Obj, RemoveCollection, Cancel)
  Cancel = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckEraseFlag", RemoveCollection)
End Sub


Sub ContextMenu_BeforeShow(Commands, Obj, Cancel)
End Sub