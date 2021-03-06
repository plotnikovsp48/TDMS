' Команда - Указать себя Ответственным по закупке (Внутренняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "CMD_DLL_ROLES"

Call Main(ThisObject)

Sub Main(Obj)
  'Подтверждение выбора пользователя
  Key = Msgbox("Назначить себя ответственным по закупке для выбранного объекта?", vbQuestion+VbYesNo)
  If Key = vbNo Then Exit Sub
  
  ' Назначение на роль
  RoleName = "ROLE_PURCHASE_RESPONSIBLE"
  Set CU = ThisApplication.CurrentUser
  Set Roles = Obj.RolesByDef(RoleName)
  If Roles.Count <> 0 Then
    For Each Role in Roles
      Role.User = CU
    Next
  Else
    Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,CU)
  End If
  
  'Модификация роли "Инициатор согласования"
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","InitiatorModified",Obj,"")
End Sub


