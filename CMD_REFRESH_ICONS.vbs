USE "CMD_DLL"

Call Run(ThisObject)

Sub Run(Root)
  For each Obj In Root.Objects
    Obj.Permissions = SysAdminPermissions
    Call SetIcon(Obj)
  Next
End Sub