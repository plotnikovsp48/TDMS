Sub Object_BeforeCreate(o_, p_, Cancel)
  Dim vOInitialStatus
  Dim vPInitialStatus
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",p_,p_.Status,o_,o_.ObjectDef.InitialStatus)    
End Sub
'Sub Object_BeforeErase(o_, cn_)
'  Dim result1,result2
'  result1 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckContent", o_)
'  result2 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckReferencedBy", o_) 
'  cn_=result1 Or result2
'  Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", o_) 
'End Sub

Sub Object_BeforeContentRemove(Obj, RemoveCollection, Cancel)
  Cancel = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckEraseFlag", RemoveCollection)
End Sub

'Sub Object_ContentAdded(Obj, AddCollection)
'  ThisApplication.ExecuteCommand "CMD_SORT",Obj
'End Sub
