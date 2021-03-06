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

' Sub File_Erased(f_, Obj)
'   ThisApplication.ExecuteScript "CMD_DLL","SetIcon",Obj
' End Sub
' 
' Sub File_Added(f_, Obj)
'   ThisApplication.ExecuteScript "CMD_DLL","SetIcon",Obj
' End Sub

'Sub Object_Modified(Obj)
'  ThisApplication.ExecuteScript "CMD_DLL","SetIcon",Obj
'End Sub

Sub Object_Created(Obj, Parent)
  ' Проверяем и назначаем утверждающего
  Call SetConf(Obj)
'  'Просим добавить файл
'  If Obj.Files.Count = 0 Then
'    Call ThisApplication.ExecuteScript("CMD_S_DLL", "AddFileToObj", Obj,False)
'  End If
End Sub

' Проверяем и назначаем утверждающего
Private Sub SetConf(Obj)
  Dim uConf
  ' Проверяем статус объекта
  If Obj.StatusName = "STATUS_DOC_IS_ADDED" Then Exit Sub
  Obj.Permissions = SysAdminPermissions 
  ' Проверяем заполение атрибута "Утверждаеющий"
  ' Незаполнен атрибута "Утверждаеющий"
  If Obj.Attributes("ATTR_DOCUMENT_CONF") = "" Then
    ' Проверка наличия роли
    If Obj.RolesByDef("ROLE_CONFIRMATORY").Count > 0 Then
      ' Удаляем роль
      Obj.Roles.Remove Obj.RolesByDef("ROLE_CONFIRMATORY")(0)
    End If
    Exit Sub
  End If
  ' Заполнен атрибута "Утверждаеющий"
  Set uConf = Obj.Attributes("ATTR_DOCUMENT_CONF").User
  ' Проверка наличия роли
  If Obj.RolesByDef("ROLE_CONFIRMATORY").Count > 0 Then
    ' Удаляем роль
    Obj.RolesByDef("ROLE_CONFIRMATORY")(0).User = uConf
  Else
    Set rConf = Obj.Roles.Create(ThisApplication.RoleDefs("ROLE_CONFIRMATORY"),uConf)
    rConf.Inheritable = False
  End If  
End Sub

function Check_FinishStatus(stName)
  Check_FinishStatus = (stName = "STATUS_DOCUMENT_INVALIDATED")
end function