' $Workfile: COMMAND.SCRIPT.CMD_COMMENT.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 5 $ 
' $Author: Oreshkin $ 
'
' Команда "Комментировать"
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

Use "COMMENT_FUNCTION_LIBRARY"

' If ThisObject.ObjectDefName = "OBJECT_DOCUMENT" Then
  ' Создаём новый комментарий для текущего пользователя
  Set tComment = CreateComment (ThisObject)
  ' Открываем комментарий на редактирование
  If Not tComment Is Nothing Then
    tComment.Update
    OpenComment tComment, True
  End If
' End If
