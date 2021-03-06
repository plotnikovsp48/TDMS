' Команда  - Закрыть заявку
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2016 г.

Set o = ThisObject
Dim Res
Call PrintRequestFinish(o,Res)

Sub PrintRequestFinish(o,Res)
  Res = False
  Set CU = ThisApplication.CurrentUser
  Set Roles = o.RolesForUser(CU)
  
  'Проверка состояния
  If o.StatusName <> "STATUS_PRINT_REQUEST_IN_WORK" or Roles.Has("ROLE_PRINT_OPERATOR") = False Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", ,1196
    Exit Sub
  End If
  
  'Подтверждение
  result = ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", , 1198, o.Description)
  If result <> vbYes Then
    Exit Sub
  End If
  
  'Смена статуса
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_PRINT_REQUEST_DONE")
  
  'Оповещение инициатора печати
  If o.Roles.Has("ROLE_PRINT_STARTER") Then
    If not o.Roles("ROLE_PRINT_STARTER").User is Nothing Then
      Set u = o.Roles("ROLE_PRINT_STARTER").User
    Else
      Set u = o.Roles("ROLE_PRINT_STARTER").Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1199, u, o, Nothing, o.Description
  End If
  
  Res = True
End Sub
