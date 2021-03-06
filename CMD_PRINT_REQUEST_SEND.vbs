' Команда  - Выдать заявку на печать
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2016 г.

Set o = ThisObject
Dim Res
Call PrintRequestSend(o,Res)

Sub PrintRequestSend(o,Res)
  Res = False
  Set CU = ThisApplication.CurrentUser
  Set Roles = o.RolesForUser(CU)
  
  'Проверка состояния
  If o.StatusName <> "STATUS_PRINT_REQUEST_CREATED" or o.Files.Count = 0 or _
  Roles.Has("ROLE_PRINT_STARTER") = False Then
    If o.Files.Count = 0 Then
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", ,1195
    End If
    Exit Sub
  End If
  
  'Подтверждение
  result = ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", , 1191, o.Description)
  If result <> vbYes Then
    Exit Sub
  End If
  
  'Смена статуса
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_PRINT_REQUEST_SENT")
  
  'Оповещение операторов печати
  If o.Roles.Has("ROLE_PRINT_OPERATOR") Then
    If not o.Roles("ROLE_PRINT_OPERATOR").User is Nothing Then
      Set u = o.Roles("ROLE_PRINT_OPERATOR").User
    Else
      Set u = o.Roles("ROLE_PRINT_OPERATOR").Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1192, u, o, Nothing, o.Description
  End If
  
  Res = True
End Sub