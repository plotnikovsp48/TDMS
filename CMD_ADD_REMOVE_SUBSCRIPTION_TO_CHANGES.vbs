'sub AddSubscription(Obj, Role, User)
'  Obj.Roles.Create Role, User
'  msgbox "Подписка добавлена"
'end sub

'sub RemoveSubscription(Group, Role)
'  while Group.Has(Role)
'    Group.Remove Group.Item(Role)
'  wend
'  msgbox "Подписка снята"
'end sub

''Set Q = ThisApplication.Queries("QUERY_SUBSCRIBES_IN_OBJECT")
''Q.Parameter("PARAM0") = thisobject

'curRole = "ROLE_SUBSCRIPTION_TO_CHANGE"
'set curUser = thisapplication.CurrentUser
'set group = thisobject.RolesForUser(curUser)

''распредлелить по ролям и добавить в общесистемный скрипт
'if not group.Has(curRole) then
'  AddSubscription thisobject, curRole, curUser
'else
'  RemoveSubscription group, curRole
'end if

use CMD_MARK_LIB
Thisscript.SysAdminModeOn
if HasMark(thisobject, "на контроле") then
  dellMark thisobject, "на контроле"
  msgbox "Подписка снята"
else
  CreateMark "на контроле", thisobject, false
  msgbox "Подписка добавлена"
end if
Thisscript.SysAdminModeOff 