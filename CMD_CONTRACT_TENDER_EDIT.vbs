' Редактирование блока тендерной документации на договоре

Call Run()

Sub Run()
  ThisApplication.DebugPrint "BTN_EIS_EDIT_OnClick"
  Set Obj = ThisObject
  If ThisApplication.ExecuteScript("CMD_KD_REGNO_KIB","SetLock",Obj) = False Then Exit Sub
  If Obj.StatusName <> "STATUS_EDIT" Then
    Obj.Permissions = SysAdminPermissions
    Obj.Attributes("ATTR_PREVIOUS_STATUS") = Obj.StatusName
    Obj.Status = ThisApplication.Statuses("STATUS_EDIT")
    Obj.SaveChanges 16384
  End If
End Sub
