
ans = MsgBox("Удалть метку из всех документов?", vbQuestion + vbYesNo)
If ans = vbYes then
'Set objShell = CreateObject("Shell.Application")
'For Each obj in thisApplication.Shell.SelObjects
    call delallmarks( ThisObject)
'next    
end if


sub delallmarks( Object)


set q= Thisapplication.Queries("QUERY_MARKS_UNIQ")
q.Parameter("PARAM0")=Object.Description
set marks=q.Objects
For each mark in marks

     If  mark.Roles.Has("ROLE_EDIT_ATTR") Then
         If ThisApplication.CurrentUser.Handle= mark.Roles("ROLE_EDIT_ATTR").User.handle _
            or (ThisApplication.CurrentUser.Sysname="SYSADMIN") then
             mark.Permissions = SysAdminPermissions
             mark.erase
         end if    
     end if   
   
Next
end sub