' $Workfile: COMMAND.SCRIPT.CMD_WORK_DOCS_SET_DEVELOPER_APPOINT.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Назначить ответственного за разработку комплекта, Раздела
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

USE "CMD_DLL_ROLES"
USE "CMD_S_DLL"

Call Main(ThisObject)

Sub Main(Obj)
  ThisApplication.DebugPrint "Main "
 ThisScript.SysAdminModeOn
  '  Проверяем условия запуска команды
  Set cu=ThisApplication.CurrentUser
  'Set uGip = GetProjectGip(Obj)
'  If (Not uGip Is Nothing) And uGip.Handle = cu.Handle Then 
'    if (Obj.status.SysName<>"STATUS_PROJECT_SECTION_IS_DEVELOPING" And Obj.status.SysName<>"STATUS_WORK_DOCS_SET_IS_DEVELOPING" And Obj.status.SysName<>"STATUS_VOLUME_CREATED") Then 
'      Call ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbExclamation+VbOKOnly, 1271,Obj.ObjectDef.Description)
'      Exit Sub
'    End If
'  Else
'    Call ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbExclamation+VbOKOnly, 1271,Obj.ObjectDef.Description)
'    Exit Sub
'  End If
  
  ' Выбор пользователя
  Dim NewUser
  Set Source = GetUserSource(Obj)
  If Source Is Nothing Then 
    Set NewUser = ThisApplication.ExecuteScript("CMD_DIALOGS","SelectUsersDlg")
  Else
    Set NewUser = ThisApplication.ExecuteScript("CMD_DIALOGS","SelectUserFromCollDlg",Source) 
  End If
  
'  Set NewUser = SelectUserByGroup("GROUP_LEAD_DEPT")
  If NewUser Is Nothing Or VarType(NewUser)<>9 Then Exit Sub
  
  ' по результатам показа в Тюмени 10.09.2017
'  ' Подтверждение выбора пользователя
'  result=ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbQuestion+VbYesNo, 1270,u.Description,Obj.ObjectDef.Description,Obj.Description)
'  If result <> vbYes Then
'    Exit Sub
'  End If 
  

    
  ThisApplication.Utility.WaitCursor = True
  Set OldUser = Obj.Attributes("ATTR_RESPONSIBLE").User
  
  If Not OldUser Is Nothing Then
    If OldUser.handle = NewUser.Handle Then
      Exit Sub
    End If
  End If
  
  Call SetResponsible (Obj,NewUser)
  Call SetDept(Obj,NewUser)
  
  Call ChangeResponsible(Obj,NewUser,OldUser)
  Obj.SaveChanges(0)
'  Call SetRolesForContent(Obj,NewUser)
      
  Call Run(Obj,NewUser)
  ThisApplication.Utility.WaitCursor = False
End Sub

Sub Run(Obj,u)
ThisApplication.DebugPrint "Run "
' Назначение на роль
  'Call ChangeRoles(Obj,u)
  ' рассылка оповещения ответственным
  Set Stage = GetStage (Obj)
  
  If Not Stage Is Nothing Then
    If Stage.StatusName <> "STATUS_STAGE_DEVELOPING" Then
      Exit Sub
    End If
  End If
  
  Call SendMessage(Obj)

End Sub


Private Sub ChangeRoles(Obj,u_)
ThisApplication.DebugPrint "ChangeRoles "
  Obj.Permissions = SysAdminPermissions
  If u_ Is Nothing Then Exit Sub
  If Obj Is Nothing Then Exit Sub

  Select Case Obj.ObjectDefName
    Case "OBJECT_PROJECT_SECTION","OBJECT_PROJECT_SECTION_SUBSECTION"
      lstRoles = "ROLE_SECTION_COMPLETED,ROLE_LEAD_DEVELOPER"
      attrName = "ATTR_RESPONSIBLE"
    Case "OBJECT_WORK_DOCS_SET"
      lstRoles = "ROLE_WORK_DOCS_SET_COMPLETED,ROLE_WORK_DOCS_SET_BACK_IN_WORK,ROLE_LEAD_DEVELOPER"
      attrName = "ATTR_RESPONSIBLE"
    Case "OBJECT_VOLUME"
      ' Список ролей, которые должны переназначиться у Тома при назначении ответственного
      lstRoles = "ROLE_VOLUME_SET_TO_WORK,ROLE_VOLUME_COMPOSER,ROLE_VOLUME_COMPLETED,ROLE_INITIATOR"
      attrName = "ATTR_RESPONSIBLE"
  End Select
  Call UpdateAttrRoles(Obj,attrName,lstRoles)
End Sub

'==============================================================================
' Отправка оповещения ответственному проектировщику о назначении его ответственным
'------------------------------------------------------------------------------
' Obj:TDMSObject - взятый комплект на нормоконтроль
'==============================================================================
Private Sub SendMessage(Obj)
  Dim u
  For Each r In Obj.RolesByDef("ROLE_LEAD_DEVELOPER")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1501, u, Obj, Nothing, Obj.ObjectDef.Description, Obj.Description, ThisApplication.CurrentUser.Description
  Next
End Sub

Sub SetRolesForContent(Obj,NewUser)
ThisApplication.DebugPrint "SetRolesForContent "
 ThisScript.SysAdminModeOn
 Dim dept
  Set dept = Obj.Attributes("ATTR_S_DEPARTMENT").Object
  Set us = ThisApplication.ExecuteScript ("CMD_STRU_OBJ_DLL", "GetGroupsChiefsByDept", dept)
  For each oChild In Obj.contentAll
    oChild.Permissions = SysAdminPermissions
    If oChild.ObjectDefName = "OBJECT_FOLDER" Then
      Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","ChangeRole",oChild,NewUser,"ROLE_RESPONSIBLE")
      Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","ChangeRole",oChild,NewUser,"ROLE_STRUCT_DEVELOPER")
      Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","ChangeRole",oChild,NewUser,"ROLE_FOLDER_DEVELOPER_APPOINT")
    Else
      
      If oChild.Roles.Has("ROLE_LEAD_DEVELOPER") = False Then
        Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",oChild,"ROLE_LEAD_DEVELOPER",NewUser)
      Else
        Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","ChangeRole",oChild,NewUser,"ROLE_LEAD_DEVELOPER")
      End If
      
      ' Назначаем на роль Назначить разработчика документа руководителей групп отдела и Начальника отдела.
      ' Протокол Тюмень
      Call SetDocDevAppoint(oChild)
    End If
  Next
End Sub


Sub SetDept(Obj,User)
ThisApplication.DebugPrint "SetDept "
  Dim Dept
  ThisScript.SysAdminModeOn
  Obj.permissions = sysadminpermissions
  If Obj.Attributes.Has("ATTR_S_DEPARTMENT") = False Then
    Obj.attributes.create ("ATTR_S_DEPARTMENT")
  End If
  
  If User Is Nothing Then
    Obj.Attributes("ATTR_S_DEPARTMENT").Object = Nothing
    Exit Sub
  End If
  Set dept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetDeptForUserByGroup",User,"GROUP_LEAD_DEPT")
  If Dept Is Nothing Then Exit Sub
  Set d1 = Obj.Attributes("ATTR_S_DEPARTMENT").Object
  chk = False
  If d1 Is Nothing Then 
    chk = True
  Else
    If Obj.Attributes("ATTR_S_DEPARTMENT").Object.Handle <> Dept.Handle Then
      chk = True
    End If
  End If
  If chk Then Obj.Attributes("ATTR_S_DEPARTMENT").Object = Dept
End Sub

Function GetUserSource(Obj)
  Set GetUserSource = Nothing
  If Obj.Attributes.Has("ATTR_SUBCONTRACTOR_WORK") Then
    If Obj.Attributes("ATTR_SUBCONTRACTOR_WORK") = False Then
      Set GetUserSource = ThisApplication.Groups("GROUP_LEAD_DEPT").Users
    End If
  Else
    Set GetUserSource = ThisApplication.Groups("GROUP_LEAD_DEPT").Users
  End If
End Function


' Изменнение ответственного при изменении отдела
Sub DeptChange(Obj, Attribute, OldAttribute)
  Set oldUser = Obj.Attributes("ATTR_RESPONSIBLE").User
  Set NewUser = Nothing
  If Attribute.Empty = False Then _
        Set NewUser = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetChiefByDept",Attribute.Object)
  Obj.Attributes("ATTR_RESPONSIBLE").User = NewUser
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","ChangeResponsible",Obj,NewUser,oldUser)
'      Call ThisApplication.ExecuteScript("CMD_DEVELOPER_APPOINT","SetRolesForContent",Obj,Obj.Attributes("ATTR_RESPONSIBLE").User)
End Sub