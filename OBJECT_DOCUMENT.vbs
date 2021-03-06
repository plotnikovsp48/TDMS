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
    If folderType.SysName = "NODE_FOLDER_PROJECT_WORK" And _
        folderType.SysName = "NODE_OBJECT_BUILD_STAGE" Then
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
'   Obj.Administrator = ThisApplication.CurrentUser   
  If Parent.ObjectDefName = "OBJECT_P_ROOT" Or Parent.ObjectDefName = "OBJECT_CONTRACT" Or Parent.ObjectDefName = "OBJECT_FOLDER" _
    Or Parent.ObjectDefName = "OBJECT_BOD" Or Parent.ObjectDefName = "OBJECT_SURV" Or Parent.ObjectDefName = "ROOT_DEF" Then
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Parent,Parent.Status,Obj,"STATUS_DOC_IS_ADDED")  
  Else
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Parent,Parent.Status,Obj,Obj.ObjectDef.InitialStatus)  
  End If 
End Sub

' Sub File_Erased(f_, o_)
'   ThisApplication.ExecuteScript "CMD_DLL","SetIcon",o_
' End Sub
' 
' Sub File_Added(f_, o_)
'   ThisApplication.ExecuteScript "CMD_DLL","SetIcon",o_
' End Sub

Sub Object_Created(o_, Parent)
  ' Проверяем и назначаем утверждающего
  Call SetConf(o_)
'  'Просим добавить файл
'  If o_.Files.Count = 0 Then
'    Call ThisApplication.ExecuteScript("CMD_S_DLL", "AddFileToObj", o_,False)
'  End If
End Sub

' Проверяем и назначаем утверждающего
Private Sub SetConf(o_)
  Dim uConf
  ' Проверяем статус объекта
  If o_.StatusName = "STATUS_DOC_IS_ADDED" Then Exit Sub
  o_.Permissions = SysAdminPermissions 
  ' Проверяем заполение атрибута "Утверждаеющий"
  ' Незаполнен атрибута "Утверждаеющий"
  If o_.Attributes("ATTR_DOCUMENT_CONF").Empty = True Then
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

'Sub Object_CheckedIn(Obj)
'  'Запись в журнал сессиий - Загружен
'  ThisApplication.ExecuteScript "CMD_DLL", "TsessionRowCreate", Obj, True
'End Sub

'Sub Object_BeforeCheckOut(Obj, Cancel)
'  'Запись в журнал сессиий - Выгружен
'  ThisApplication.ExecuteScript "CMD_DLL", "TsessionRowCreate", Obj, False
'End Sub

Sub Object_StatusChanged(Obj, Status)
  If Status is Nothing Then Exit Sub
  ThisScript.SysAdminModeOn
  
  'Определение статуса после согласования
  StatusAfterAgreed = ""
  Set Rows = ThisApplication.Attributes("ATTR_AGREENENT_SETTINGS").Rows
  For Each Row in Rows
    If Row.Attributes("ATTR_KD_OBJ_TYPE").Value = Obj.ObjectDefName Then
      StatusAfterAgreed = Row.Attributes("ATTR_KD_FINISH_STATUS")
      Exit For
    End If
  Next
  'Отработка маршрутов для механизма согласования
  If Status.SysName = "STATUS_KD_AGREEMENT" or Status.SysName = StatusAfterAgreed Then
    If Obj.Dictionary.Exists("PrevStatusName") Then
      sName = Obj.Dictionary.Item("PrevStatusName")
      If ThisApplication.Statuses.Has(sName) Then
        Set PrevSt = ThisApplication.Statuses(sName)
        Call ThisApplication.ExecuteScript("CMD_ROUTER","RunNonStatusChange",Obj,PrevSt,Obj,Status.SysName) 
      End If
    End If
  End If
End Sub

Sub Object_StatusBeforeChange(Obj, Status, Cancel)
  ThisScript.SysAdminModeOn
  'Записываем текущий статус в словарь
  Obj.Dictionary.Item("PrevStatusName") = Obj.StatusName
End Sub

function Check_FinishStatus(stName)
  Check_FinishStatus = (stName = "STATUS_DOCUMENT_INVALIDATED")
end function
