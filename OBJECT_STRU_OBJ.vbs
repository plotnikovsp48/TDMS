

Sub Object_Created(Obj, Parent)
 call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", Obj)
End Sub