
Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  
  ThisObject.Attributes("ATTR_ORIGINAL_STATUS_NAME").Value = ThisObject.StatusName
  
  'Смена статуса
  StatusName = "STATUS_STAGE_EDIT"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",ThisObject,ThisObject.Status,ThisObject,StatusName)
  If RetVal = -1 Then
    ThisObject.Status = ThisApplication.Statuses(StatusName)
  End If
  
   'Создание роли "Редактирование структуры"
  Set CU = ThisApplication.CurrentUser
  Set Roles = ThisObject.RolesForUser(CU)
  RoleName = "ROLE_PROJECT_STRUCTURE_EDIT"
  If Roles.Has(RoleName) = False Then
    Call ThisApplication.ExecuteScript("CMD_DLL", "SetRole",ThisObject,RoleName,CU)
  End If
  
  'Создание версии
  ThisObject.Versions.Create ,"Редактирование структуры"
  
  ThisObject.Update
  ThisScript.SysAdminModeOff
  
End Sub
