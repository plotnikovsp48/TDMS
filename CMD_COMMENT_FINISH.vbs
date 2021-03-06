' $Workfile: COMMAND.SCRIPT.CMD_COMMENT_FINISH.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 5 $ 
' $Author: Oreshkin $ 
'
' Команда "Завершить комментирование"
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

Use "COMMENT_FUNCTION_LIBRARY"

If ThisObject.Status.SysName = "STATUS_COMMENT_CREATED" Or ThisObject.ReferencedBy.count>0 Then
  ' Проверяет блокировки на комментарии и переводит комментарий в конечный статус
  Select Case ThisObject.ObjectDef.SysName
  Case "OBJECT_COMMENT"
    Set tComment = ThisObject
  Case Else
    ' Найти комментарий
    Set tComment = GetUserComment(ThisObject)
  End Select
  If Not tComment Is Nothing Then
    ' Проверить блокировки комментария
    If CheckLock(tComment) = False Then
    ' Переводит комментарий в конечный статус
      tComment.Permissions = SysAdminPermissions
      Call SetRoles(tComment)
      tComment.Status = ThisApplication.Statuses("STATUS_COMMENT_FINISHED")
      tComment.Update
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1014
      Call SendMessage(tComment,tComment.Attributes("ATTR_REFFERENCED_DOCUMENT").Object)
    Else
      With tComment.Permissions
        ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1021, .LockUser.Description, eNumLockType(.LockType - 1)
      End With
    End If
  End If
End If


Private Sub SetRoles(tComment_)
  Dim u, Obj
  Set Obj = tComment_.Attributes("ATTR_REFFERENCED_DOCUMENT").Object 
  Obj.Permissions = SysAdminPermissions
  ' Копируем роли
  For Each tRole In Obj.Roles
    If tRole.RoleDef.Permissions.ViewFiles = 1 Then
      If Not tRole.User Is Nothing Then
        Set u = tRole.User
      End If
      If Not tRole.Group Is Nothing Then
        Set u = tRole.Group
      End If      
      tComment_.Roles.Create "ROLE_VIEW", u
    End If
  Next
End Sub

'==============================================================================
' Отправка оповещения о создание комментария для документа всем разработчикам
' и соавторам
'------------------------------------------------------------------------------
' o_:TDMSObject - комментируемый документ
' oComment_:TDMSObject - комментарий
'==============================================================================
Private Sub SendMessage(oComment_,o_)
  Dim u
  For Each r In o_.RolesByDef("ROLE_RESPONSIBLE")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1012, u, oComment_.Handle&chr(1)&o_.Handle, Nothing, o_.Description, ThisApplication.CurrentUser.Description
  Next
  For Each r In o_.RolesByDef("ROLE_CO_AUTHOR")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1012, u, oComment_.Handle&chr(1)&o_.Handle, Nothing, o_.Description, ThisApplication.CurrentUser.Description
  Next  
End Sub

