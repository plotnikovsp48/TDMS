' $Workfile: COMMAND.SCRIPT.CMD_COMMENT_RESUME.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Команда "Продолжить комментирование"
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

USE "COMMENT_FUNCTION_LIBRARY"

Dim o
Set o=ThisObject

If (o.ObjectDefName = "OBJECT_DOC_DEV" Or o.ObjectDefName = "OBJECT_DOCUMENT") And o.ReferencedBy.count>0 Then
  Set tComment = GetUserComment(o)
  If Not tComment Is Nothing Then
    With tComment.Permissions
    If CheckLock(tComment) Then _
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1016, .LockUser.Description, eNumLockType(.LockType - 1)
    End With
    OpenComment tComment, False
  End If
End If
