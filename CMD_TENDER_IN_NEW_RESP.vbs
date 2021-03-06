' Команда - Назначить Ответственных (Внутренняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "CMD_DLL_ROLES"

Call Main(ThisObject)

Sub Main(Obj)
  
  'Выбор пользователя
  Set u = SelectUserByGroup("ALL_USERS")
  If u is Nothing Or VarType(u) <> 9 Then Exit Sub
  
  'Подтверждение выбора пользователя
  'result=ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbQuestion+VbYesNo, 1270,u.Description,o_.ObjectDef.Description,o_.Description)
  'If result <> vbYes Then
  '  Exit Sub
  'End If
  
  ' Назначение на роль
  RoleName = "ROLE_PURCHASE_RESPONSIBLE"
  Set Roles = Obj.RolesByDef(RoleName)
  If Roles.Count <> 0 Then
    For Each Role in Roles
      Role.User = u
    Next
  Else
    Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,u)
  End If
  
  'Модификация роли "Инициатор согласования"
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","InitiatorModified",Obj,"")
End Sub


