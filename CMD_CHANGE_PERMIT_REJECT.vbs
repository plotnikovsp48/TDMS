' $Workfile: COMMAND.SCRIPT.CMD_CHANGE_PERMIT_REJECT.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Отклонить разрешение
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

Dim o,u
Set o = ThisObject
Set u = ThisApplication.CurrentUser
Call main(o,u)

Sub main(o_,u_)
  Dim result
  
  o_.Permissions = SysAdminPermissions 
  ' Подтверждение
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbYesNo, 1151, o_.Description)    
  If result <> vbYes Then
    Exit Sub
  End If      
  
  ' Запросить причину отклонения разрешения!!!
  result = ThisApplication.ExecuteScript("CMD_DIALOGS","EditDlg","Укажите причину отклонения разрешения на изменение.","Причина:")
  If result = Chr(1) Then
    Exit Sub
  End If    
  ' Изменение роли
  Call ChangeRole(o_,"ROLE_CHANGE_PERMIT_ACCEPT","ROLE_CHANGE_REJECTED",u_)
  ' Сменить статус
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o_,o_.Status,o_,"STATUS_CHANGE_PERMIT_IS_INVALIDATED") 
  ' Отправить оповещение
  Call SendChangePermit(o_,result)
  ' Записать лог
  
  ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1152, o_.Description,result
End Sub


Private Sub ChangeRole(o_,sRoleSysNameCur,sRoleSysNameNew,u_)
  o_.Permissions = SysAdminPermissions 
  o_.RolesForUser(u_)(sRoleSysNameCur).RoleDef = ThisApplication.RoleDefs(sRoleSysNameNew)
End Sub

Private Sub SendChangePermit(o_,couse_)
  ' Отправка разрешения всем согласующим
  For Each r In o_.RolesByDef("ROLE_CHANGE_PERMIT_ACCEPT")
    Set u = r.User
    ThisApplication.ExecuteScript "CMD_MESSAGE","SendMessage",1114,u,o_,Nothing,o_.Description,u.Description,couse_
  Next
  For Each r In o_.RolesByDef("ROLE_CHANGE_ACCEPTED")
    Set u = r.User
    ThisApplication.ExecuteScript "CMD_MESSAGE","SendMessage",1114,u,o_,Nothing,o_.Description,u.Description,couse_
  Next
  For Each r In o_.RolesByDef("ROLE_CHANGE_REJECTED")
    Set u = r.User
    ThisApplication.ExecuteScript "CMD_MESSAGE","SendMessage",1114,u,o_,Nothing,o_.Description,u.Description,couse_
  Next    
End Sub
