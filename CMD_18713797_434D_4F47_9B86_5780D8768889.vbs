
msgbox "2"
for each user in thisApplication.Users
  if not user.SysName = "SYSADMIN" then 
  '  set user = thisApplication.Users("Антоненко Роман Андреевич")
    thisApplication.AddNotify user.description
    'user.Desktop.user.Desktop.
    set desk = user.Desktop
    for each obj in desk.Objects
        if obj.IsKindOf("OBJECT_ARM_FOLDER") then 
          if inStr(obj.description,"ПОРУЧЕНИЯ") > 0 or inStr(obj.description,"ДЕЛОПРОИЗВОДСТВО") > 0 then _
            desk.Objects.Remove obj
            thisApplication.AddNotify obj.description
        end if
    next 
    desk.Update
  end if
next  
