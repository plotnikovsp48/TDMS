' $Workfile: OBJECTDEF.SCRIPT.OBJECT_DOCUMENT.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 6 $ 
' $Author: Oreshkin $ 
'
' Документ
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

USE "OBJECT_DOC"

Sub Object_BeforeCreate(Obj, Parent, Cancel)
  ' Назначение администратора
  Obj.Permissions = SysAdminPermissions 
  
  If Parent.ObjectDefName = "OBJECT_FOLDER" Then
    Set folderType = Parent.Attributes("ATTR_FOLDER_TYPE").Classifier
    If folderType.SysName <> "NODE_FOLDER_AUTH-SUPERVISION" Then
       msgbox "Невозможно создать документ на этом уровне",vbCritical,"Создать документ"
       Cancel = True   
       Exit Sub 
    End If
  End If
  
  sysID = ThisApplication.ExecuteScript ("CMD_KD_REGNO_KIB","Get_Sys_Id",Obj)
  if sysID = 0 then 
      Cancel = true
      exit sub
  else  
    Obj.Attributes("ATTR_KD_IDNUMBER").value = sysID
  end if  
  If Parent.ObjectDefName = "OBJECT_FOLDER" Or Parent.ObjectDefName = "ROOT_DEF" Then
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Parent,Parent.Status,Obj,Obj.ObjectDef.InitialStatus)
  Else
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Parent,Parent.Status,Obj,"STATUS_DOC_IS_ADDED")     
  End If 
End Sub

Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
  If OkBtnPressed = False Then Exit Sub
  Obj.Permissions = SysAdminPermissions 
  If Obj.Files.Count = 0 Then
    If Obj.Status.SysName = "STATUS_DOC_IS_ADDED" Then
      Cancel = True
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 117        
    End If
  End If
End Sub


' Sub File_Erased(f_, o_)
'   ThisApplication.ExecuteScript "CMD_DLL","SetIcon",o_
' End Sub
' 
' Sub File_Added(f_, o_)
'   ThisApplication.ExecuteScript "CMD_DLL","SetIcon",o_
' End Sub

'Sub Object_Modified(o_)
'  ThisApplication.ExecuteScript "CMD_DLL","SetIcon",o_
'End Sub

Sub Object_Created(o_, p_)
  ' Проверяем и назначаем утверждающего
  Call SetConf(o_)
  'Просим добавить файл
'  If o_.Files.Count = 0 Then
'    Call ThisApplication.ExecuteScript("CMD_S_DLL", "AddFileToObj", o_,False)
'  End If
End Sub

' Проверяем и назначаем утверждающего
Private Sub SetConf(o_)
  Dim uConf
  ' Проверяем статус объекта
  If o_.Status.SysName = "STATUS_DOC_IS_ADDED" Then Exit Sub
  o_.Permissions = SysAdminPermissions 
  ' Проверяем заполение атрибута "Утверждаеющий"
  ' Незаполнен атрибута "Утверждаеющий"
  If o_.Attributes("ATTR_DOCUMENT_CONF") = "" Then
    ' Проверка наличия роли
    If o_.RolesByDef("ROLE_CONFIRMATORY").Count > 0 Then
      ' Удаляем роль
      o_.Roles.Remove o_.RolesByDef("ROLE_CONFIRMATORY")(0)
    End If
    Exit Sub
  End If
  ' Заполнен атрибута "Утверждаеющий"
  Set uConf = o_.Attributes("ATTR_DOCUMENT_CONF").User
  ' Проверка наличия роли
  If o_.RolesByDef("ROLE_CONFIRMATORY").Count > 0 Then
    ' Удаляем роль
    o_.RolesByDef("ROLE_CONFIRMATORY")(0).User = uConf
  Else
    Set rConf = o_.Roles.Create(ThisApplication.RoleDefs("ROLE_CONFIRMATORY"),uConf)
    rConf.Inheritable = False
  End If  
End Sub


function Check_FinishStatus(stName)
  Check_FinishStatus = (stName = "STATUS_DOCUMENT_INVALIDATED")
end function