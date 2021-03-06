' $Workfile: COMMAND.SCRIPT.COMMENT_FUNCTION_LIBRARY.scr $ 
' $Date: 29.09.08 12:37 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Библиотека функция для комментирования
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

eNumLockType = Array("просмотр атрибутов", "редактирование атрибутов", "редактирование файлов")

'---------------------------------------------------------------------------------------------
' Функция возвращает незакрытый коментарий текущего пользователя
Function GetUserComment (Obj)
  Set GetUserComment = Nothing ' Возвращает Nothing если коментария несуществует
  For Each tObj In Obj.ReferencedBy.ObjectsByDef("OBJECT_COMMENT")
    If (tObj.CreateUser.SysName = ThisApplication.CurrentUser.SysName) And _
      (tObj.Status.SysName <> "STATUS_COMMENT_FINISHED") Then
      Set GetUserComment = tObj
      Exit Function
    End If
  Next
End Function
'---------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------
' Создание нового коментария для объекта
Function CreateComment(Obj)
Set CreateComment = Nothing

if not ThisApplication.AttributeDefs("ATTR_REFFERENCED_DOCUMENT").ObjectDefs.Has(Obj.ObjectDef) then
  Call ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbExclamation, 1264, Obj.ObjectDef.Description)
  Exit Function
End If

  Set NewComment = ThisApplication.ObjectDefs("OBJECT_COMMENT").CreateObject
  NewComment.Permissions = SysAdminPermissions
  ' Заполняем атрибуты и роли созданного комментария
  
  NewComment.Attributes("ATTR_REFFERENCED_DOCUMENT").Object = Obj
  Obj.Permissions = SysAdminPermissions
'   ' Копируем роли
'   For Each tRole In Obj.Roles
'     If tRole.RoleDef.Permissions.ViewFiles = 1 Then
'       Dim u
'       If Not tRole.User Is Nothing Then
'         Set u = tRole.User
'       End If
'       If Not tRole.Group Is Nothing Then
'         Set u = tRole.Group
'       End If      
'       NewComment.Roles.Create "ROLE_VIEW", u
'     End If
'   Next
  Set CreateComment = NewComment
End Function
'---------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------
' Проверяет блокировку объекта типа комментарий
' Если объект заблокирован - возвращает True
Function CheckLock(Obj)
  CheckLock = False
  With Obj.Permissions
    If .Locked = True Then
      If .LockType = 3 Then
        CheckLock = True
      End If
    End If
  End With
End Function
'---------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------
' Открывет форму для редактирования свойств комментария.
' Если это новый коментарий, то нажатие кнопки Cancel может привести к удалению комментария.
Function OpenComment(tComment, newComment)
OpenComment = True
Set EditDlg = ThisApplication.Dialogs.EditObjectDlg
  EditDlg.Object = tComment
  If EditDlg.Show = False And newComment = True Then
    If ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbInformation + vbYesNo, 1017)= vbYes Then
      tComment.Erase
      OpenComment = False
    End If
  End If
End Function
'---------------------------------------------------------------------------------------------

'---------------------------------------------------------------------------------------------
' Проверяет наличие файлов у комментируемого документа.
Function CheckDocFiles(tComment)
CheckDocFiles = True
Set tDoc = tComment.Attributes("ATTR_REFFERENCED_DOCUMENT").Object
If tDoc.Files.Count > 0 Then CheckDocFiles = False
End Function
'---------------------------------------------------------------------------------------------

'==============================================================================
' Удаляет комментарии, связанные с объектом
'------------------------------------------------------------------------------
' o_:TDMSObject - Обрабатываемый информационный объект
'==============================================================================
Public Sub DeleteComments (o_)
  Dim oComment
  ' Удаление комментария
  o_.Permissions = SysAdminPermissions 
  For Each oComment In o_.ReferencedBy.ObjectsByDef("OBJECT_COMMENT")
    oComment.Permissions = SysAdminPermissions 
    oComment.Erase
  Next
End Sub
