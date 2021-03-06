' Команда  - принять заявку на печать
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2016 г.

Set o = ThisObject
Dim Res
Call PrintRequestAccept(o,Res)

Sub PrintRequestAccept(o,Res)
  Res = False
  Set CU = ThisApplication.CurrentUser
  
  'Проверка состояния
  If o.StatusName <> "STATUS_PRINT_REQUEST_SENT" or CU.Groups.Has("GROUP_PRINT_OPERATORS") = False Then
    If CU.Groups.Has("GROUP_PRINT_OPERATORS") = False Then
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", ,1194
    End If
    Exit Sub
  End If
  
  'Подтверждение
  result = ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", , 1193)
  If result <> vbYes Then
    Exit Sub
  End If
  
  'Смена статуса
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_PRINT_REQUEST_IN_WORK")
  
  Res = True
End Sub
