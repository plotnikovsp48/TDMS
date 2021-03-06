' $Workfile: COMMAND.SCRIPT.CMD_FOLDER_DEVELOPER_APPOINT.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Назначить ответственного за папку
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
  ' Переназначение ролей
  Call ChangeRoles(o_,u)
End Sub


Private Sub ChangeRoles(o_,u_)
  Call ChangeRole(o_,u_,"ROLE_STRUCT_DEVELOPER")
  ' Изменить роли на документах раздела
  For Each oDoc In o_.Objects.ObjectsByDef("OBJECT_DOC_DEV")
    Call ChangeRole(oDoc,u_,"ROLE_DOC_DEVELOPER_APPOINT")   
  Next
  For Each oDoc In o_.Objects.ObjectsByDef("OBJECT_DOCUMENT")
    Call ChangeRole(oDoc,u_,"ROLE_DOC_DEVELOPER_APPOINT")
  Next  
  For Each oFolder In o_.Objects.ObjectsByDef("OBJECT_FOLDER")
    Call ChangeRole(oFolder,u_,"ROLE_RESPONSIBLE")
    Call ChangeRole(oFolder,u_,"ROLE_FOLDER_DEVELOPER_APPOINT")
  Next    
End Sub


Private Sub ChangeRole(o_,u_,sRole_)
  o_.Permissions = SysAdminPermissions
  For Each r In o_.RolesByDef(sRole_)
    r.User = u_
  Next
End Sub
