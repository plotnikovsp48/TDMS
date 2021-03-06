' $Workfile: FORM.SCRIPT.FORM_CHANGE_PERMIT.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Форма разрешения на изменение
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.


Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  ' Установка статуса контролов ReadOnly
  Dim sListAttrs ' Список системных идентификаторов атрибутов, поля которых на форме должны быть Read Only
  sListAttrs = "ATTR_CHANGE_PERMIT_NUM"
  Call ThisApplication.ExecuteScript("CMD_DLL","SetControlReadOnly",Form,sListAttrs)
End Sub

Sub OnClick_BUTTON_ADD()
  Dim o,u,rd,rs
  Set o = ThisObject
  Set rd = ThisApplication.RoleDefs("ROLE_CHANGE_PERMIT_ACCEPT")
  o.Permissions = SysAdminPermissions 
  Set u = ThisApplication.ExecuteScript("CMD_DIALOGS","SelectUsersDlg")
  If u Is Nothing Then Exit Sub
  Set rs = o.RolesForUser(u)
  If rs.Has("ROLE_CHANGE_PERMIT_ACCEPT") Or rs.Has("ROLE_CHANGE_ACCEPTED") Or rs.Has("ROLE_CHANGE_REJECTED") Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1113
  Else
    Set r = o.Roles.Create(rd,u)
    r.Inheritable = False
  End If
End Sub

Sub OnClick_BUTTON_DEL()
  Dim us,o,dus
  Set o = ThisObject
  o.Permissions = SysAdminPermissions 
  ' Сформировать массив согласующих специалистов доступных для удаления (не установленный флаг наследования)
  us = CreateUserArray(o)
  If VarType(us)=0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1167
    Exit Sub
  End If
  dus = SelUsers(us)
  If VarType(dus)=0 Then Exit Sub
  Call DelRoles(o,dus)
End Sub


'==============================================================================
' Формирование массива согласующих специалистов доступных для удаления (не установленный флаг наследования)
'------------------------------------------------------------------------------
' Obj:TDMSObject - Объект, с которого формируется массив согласующих пользователей
' CreateUserArray:TDMSUsers - Результат выполнения. Массив пользователей
'==============================================================================
Private Function CreateUserArray(Obj)
  Dim Users()
  count = 0
  For Each TRole In Obj.RolesByDef("ROLE_CHANGE_PERMIT_ACCEPT")
    If TRole.Inheritable = False Then
      count = count + 1
      ReDim Preserve Users(count)
      Set Users(count-1) = TRole.User 
    End If
  Next  
  If count = 0 Then
    CreateUserArray = Empty
  Else
    CreateUserArray = Users
  End If
End Function

'==============================================================================
' Диалог выбора пользователей
'------------------------------------------------------------------------------
' us_:TDMSUsers - Массив пользователей
' SelUsers:TDMSUsers - Результат выполнения. Массив пользователей для удаления
'==============================================================================
Private Function SelUsers(us_)
  SelUsers = Empty
  Set SelDlg = ThisApplication.Dialogs.SelectDlg
  SelDlg.SelectFrom = us_
  If SelDlg.Show Then 
    SelUsers = SelDlg.Objects
  End If
End Function

'==============================================================================
' Удаление роли "Согласование" для выбранных пользователей
'------------------------------------------------------------------------------
' Obj:TDMSObject - Объект, с которого удаляются роли
' dus_:TDMSUsers - Массив удаляемых пользователей
'==============================================================================
Private Sub DelRoles(Obj,dus_)
  Dim vRole,vUser
  For i=0 To UBound(dus_)
    Set vUser = dus_(i)
    For Each r In Obj.RolesForUser(vUser)
      If r.RoleDefName = "ROLE_CHANGE_PERMIT_ACCEPT" Then 'Or r.RoleDefName = "ROLE_CHANGE_ACCEPTED" Or r.RoleDefName = "ROLE_CHANGE_REJECTED" Then
        If r.Inheritable = False Then
          Obj.Roles.Remove r
        End If
      End If
    Next
  Next
End Sub
