
Sub Object_BeforeCreate(Obj, Parent, Cancel)
  Dim vOInitialStatus
  Dim vPInitialStatus
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Parent,Parent.Status,Obj,Obj.ObjectDef.InitialStatus)    
End Sub

Sub Object_Created(Obj, Parent)

'    'Добавление папки Задания
'    Set o = Obj.Objects.Create("OBJ_TASK_DIR")
'    o.Permissions = SysAdminPermissions 
'    o.Attributes("ATTR_PROJECT")=Obj.Attributes("ATTR_PROJECT")
     
End Sub

Sub Object_BeforeErase(o_, cn_)
  Dim result1,result2
  result1 = ThisApplication.ExecuteScript("CMD_S_DLL", "CheckProjectContent", o_)
  result2 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckReferencedBy", o_) 
  cn_=result1 Or result2
  Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", o_) 
'  ' Удаление папок из состава раздела
'  For Each o In o_.Objects
'    o.Permissions = SysAdminPermissions 
'    o.Erase
'  Next
End Sub
 

Sub Object_BeforeContentRemove(Obj, RemoveCollection, Cancel)
  Cancel = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckEraseFlag", RemoveCollection)
End Sub

Sub ContextMenu_BeforeShow(Commands, Obj, Cancel)
  ' В зависимости от статуса, скрываем команду "Добавить вид изысканий"
  If Obj.StatusName <> "STATUS_IN_WORK" Then
    Commands.Remove ThisApplication.Commands("CMD_SURVS_CREATE")
  End If
End Sub

