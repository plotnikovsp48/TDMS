' Команда - Вернуть в разработку (Внутренняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  
  'Маршрут
  StatusName = "STATUS_TENDER_IN_WORK"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  'Оповещение пользователей
  Call SendMessage(Obj)
  ThisScript.SysAdminModeOff
End Sub

Sub SendMessage(Obj)
  For Each role In Obj.RolesByDef("ROLE_TENDER_DOCS_RESP_DEVELOPER")
    If Not role.User Is Nothing Then
      Set u = role.User
    End If
    If Not role.Group Is Nothing Then
      Set u = role.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 6005, u, Obj, Nothing, Obj.Description, ThisApplication.CurrentUser.Description, Date
  Next
End Sub