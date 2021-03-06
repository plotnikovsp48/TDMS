' $Workfile: COMMAND.SCRIPT.CMD_DIVISION_DIRECTOR_APPOINT.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Назначить ответственного по специальности
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.


Dim o
Set o = ThisObject
Call Main(o)

Sub Main(o_)
	Dim u
	' Выбор пользователя
	Set u = ThisApplication.ExecuteScript("CMD_DIALOGS","SelectUsersDlg")
	If u Is Nothing Or VarType(u)<>9 Then Exit Sub
	' Назначение на роль
	Call ChangeRoles(o_,u)
End Sub


Private Sub ChangeRoles(o_,u_)
	Call ChangeRole(o_,u_,"ROLE_STRUCT_DEVELOPER")
	Call ChangeRole(o_,u_,"ROLE_CHANGE_PERMIT_CREATE")
	For Each oSet In o_.Objects.ObjectsByDef("OBJECT_WORK_DOCS_SET")
		Call ChangeRole(oSet,u_,"ROLE_RESPONSIBLE")		
		Call ChangeRole(oSet,u_,"ROLE_WORK_DOCS_SET_DEVELOPER_APPOINT")	
	Next	
End Sub

Private Sub ChangeRole(o_,u_,sRole_)
	o_.Permissions = SysAdminPermissions
	For Each r In o_.RolesByDef(sRole_)
		r.User = u_
	Next
End Sub