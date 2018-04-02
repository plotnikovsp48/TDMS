
Sub Object_Created(Obj, Parent)
   call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", Obj)
End Sub

Sub Object_BeforeCreate(Obj, Parent, Cancel)
  if  not thisApplication.CurrentUser.Groups.Has("Администраторы шаблонов") then 
    thisObject.Attributes("ATTR_KD_PERS_TEMPL").Value = true
    set dept = thisApplication.CurrentUser.Attributes("ATTR_KD_DEPART").Object
    if dept is nothing then
      msgbox "Для текущего пользователя не задана площадка!", vbCritical
      cancel = true
      exit sub
    else
      set rows = Obj.Attributes("ATTR_KD_T_REGIONS").Rows
      if rows.count > 0 then rows.RemoveAll()
      
      'if  thisApplication.ExecuteScript("CMD_KD_COMMON_LIB", "IsExistsObjItemCol",rows, dept, "ATTR_KD_DEPART") then 
        set newRow = rows.Create
        newRow.Attributes("ATTR_KD_DEPART").value = dept
      'end if
    end if
  end if
  obj.Attributes("ATTR_KD_AUTH").Value = thisApplication.CurrentUser
End Sub