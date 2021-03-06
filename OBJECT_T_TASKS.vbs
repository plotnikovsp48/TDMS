

Sub Object_BeforeCreate(Obj, Parent, Cancel)
  'Исключаем повторное создание объекта, если он уже есть
  set o=Parent.Objects.ObjectsByDef(Obj.ObjectDefName)
  if o.Count>1 then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation,3203,Obj.Description, Parent.Description
    Cancel=true
  end if
  Dim vOInitialStatus
  Dim vPInitialStatus
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Parent,Parent.Status,Obj,Obj.ObjectDef.InitialStatus)    
End Sub


Sub Object_BeforeErase(o_, cn_)
  cn_= ThisApplication.ExecuteScript("CMD_S_DLL", "CheckBeforeErase", o_) 
  Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", o_) 
End Sub

Sub Object_BeforeContentRemove(Obj, RemoveCollection, Cancel)
  Cancel = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckEraseFlag", RemoveCollection)
End Sub


Sub ContextMenu_BeforeShow(Commands, Obj, Cancel)
  If Not Obj.StatusName = "STATUS_IN_WORK" Then
    Commands.Remove ThisApplication.Commands("CMD_OBJECT_TASK_CREATE")
  End If
End Sub
