' Автор: Стромков С.А.
'
' Создание разделов
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

Dim o
Set o = ThisObject
Call Main(o)

Sub Main(o_)
  Dim u, result
  '  Проверка вхождения пользователя в группу Ответственных проектировщиков
  Set u=ThisApplication.CurrentUser  
  if Not ThisApplication.Groups("GROUP_LEAD_DEVELOPERS").Users.Has(u) Then 
    Call ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbExclamation+VbOKOnly, 1222)
    Exit Sub
  End If
  '  Запрос подтверждения выполнения команды
  result = ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbQuestion+vbYesNo, 1221, o_.Description)
  If result <> vbYes Then
    Exit Sub
  End If 
  '  Добавляем роль Ответственный проектировщик, если она отсутствует на объекте
  If Not o_.Roles.Has("ROLE_LEAD_DEVELOPER") then
    result = ThisApplication.ExecuteScript ("CMD_DLL", "SetRole", o_, "ROLE_LEAD_DEVELOPER",u)
    If Not result Then Exit Sub
  End If
  '  Назначение на роль
  Call ChangeRoles(o_,u)
End Sub

Private Sub ChangeRoles(o_,u_)
  '  Изменить роли комплекта
  Call ChangeRole(o_,u_,"ROLE_LEAD_DEVELOPER")
  Call ChangeRole(o_,u_,"ROLE_STRUCT_DEVELOPER")
  Call ChangeRole(o_,u_,"ROLE_WORK_DOCS_SET_COMPLETED")
  Call ChangeRole(o_,u_,"ROLE_WORK_DOCS_SET_BACK_IN_WORK")
  Call ChangeRole(o_,u_,"ROLE_CHANGE_PERMIT_CREATE")    
  '  Изменить роли на документах комплекта
  For Each oDoc In o_.Objects.ObjectsByDef("OBJECT_DOC_DEV")
    Call ChangeRole(oDoc,u_,"ROLE_DOC_DEVELOPER_APPOINT") 
  Next
  For Each oDoc In o_.Objects.ObjectsByDef("OBJECT_DOCUMENT")
    Call ChangeRole(oDoc,u_,"ROLE_DOC_DEVELOPER_APPOINT")
  Next  
End Sub

Private Sub ChangeRole(o_,u_,sRole_)
  o_.Permissions = SysAdminPermissions
  For Each r In o_.RolesByDef(sRole_)
    r.User = u_
  Next
End Sub
