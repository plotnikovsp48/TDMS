use CMD_KD_GLOBAL_VAR_LIB

'=============================================
function GetCurUser() 
  set GetCurUser = GetObjectGlobalVarrible("SelectedUserOP")
  if GetCurUser is nothing then set GetCurUser = thisApplication.CurrentUser 
end function

'=============================================
function IsInCurUsers(user)
  IsInCurUsers = false 
  set us = thisApplication.CurrentUser.GetDelegatedRightsFromUsers()
  IsInCurUsers = (user.SysName = thisApplication.CurrentUser.SysName)
  if us.Count > 0 then 
    for each cUser in us
      if user.SysName = cUser.SysName then 
        IsInCurUsers = true
        exit for
      end if
    next
  end if
end function