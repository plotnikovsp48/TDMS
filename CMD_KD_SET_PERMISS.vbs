use CMD_KD_SET_PERMISSIONS

call Set_Child_Perm(thisObject)

sub Set_Child_Perm (parentObj)
      thisApplication.AddNotify Cstr(timer)
    call Set_Permission (parentObj)
      thisApplication.AddNotify Cstr(timer)
    for each obj in parentObj.Content
      thisApplication.AddNotify Cstr(timer)
      Set_Child_Perm(obj)
      thisApplication.AddNotify Cstr(timer)
    next
end sub
