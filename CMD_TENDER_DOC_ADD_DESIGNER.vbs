' Команда - Назначить разработчиков (Документ закупки)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "CMD_DLL_ROLES"

Call Main(ThisObject)

Sub Main(Obj)
  
  'Выбор пользователя
  Set Dlg = ThisApplication.Dialogs.SelectUserDlg
  Dlg.Caption = "Выбор разработчиков"
  Dlg.SelectFromUsers = ThisApplication.Groups("ALL_USERS").Users
  If Dlg.Show Then
    If Dlg.Users.Count = 0 Then Exit Sub
  Else
    Exit Sub
  End If
  
  ' Назначение на роль
  RoleName = "ROLE_TENDER_DOCS_DEVELOPER"
  Set Roles = Obj.RolesByDef(RoleName)
  For Each u in Dlg.Users
    Check = True
    For Each Role in Roles
      If not Role.User is Nothing Then
        If u.SysName = Role.User.SysName Then
          Check = False
          Exit For
        End If
      End If
    Next
    If Check = True Then
      Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,u)
      ThisApplication.ExecuteScript "CMD_MESSAGE","SendMessage",6004,u,Obj,Nothing,Obj.Description,ThisApplication.CurrentUser.Description,Date
    End If
  Next
End Sub


