' Автор: Стромков С.А.
'
' Библиотека функций стандартной версии
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016 г.

USE "CMD_D_DLL"

Dim o
Set o=ThisObject

Call Main (o)

Sub Main(o_)
  ' Меняем статус организации на "Проверен" и убираем разработчика
  o_.Permissions = SysAdminPermissions
  o_.Status = o_.ObjectDef.Statuses("STATUS_D_ENTERPRIZE_CHEKED")
  Call RemoveRoles(o_, "ROLE_DEVELOPER")
  'o_.Roles("ROLE_DEVELOPER").Erase
  ' ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 5203
End Sub
