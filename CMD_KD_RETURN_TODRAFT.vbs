'thisApplication.AddNotify thisApplication.CurrentUser

  thisObject.Status = thisApplication.Statuses("STATUS_KD_DRAFT")
  call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", thisObject)
  thisObject.Update
