' $Workfile: COMMAND.SCRIPT.CMD_COMMENT_EDIT.scr $ 
' $Date: 29.09.08 12:37 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Команда "Редактировать комментарий"
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

Call EditComment (ThisObject)

Sub EditComment(Obj)
  Select Case Obj.Files.Main.FileDefName
  ' Здесь определяются все команда по редактированию комментариев
  ' отличные от обычной команды редактирования определённой для данного типа файла.
  Case Else
  ' Поиск команды класса редактирование и открытие на редактирование объекта.
    If EditWithSupportedCommand(Obj) = False Then
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1013
    End If
  End Select
End Sub

' Функция ищет команду класса редактирования определённую для главного файла объекта
' и открывает объект на редактирование. Если соответствующая команда не найдена - возвращает False
Function EditWithSupportedCommand(Obj)
  EditWithSupportedCommand = False
  For Each tCommand In Obj.Commands
    If tCommand.Class = tdmEdit Then
      ThisApplication.Commands(tCommand.SysName).Execute Obj
      EditWithSupportedCommand = True
      Exit Function
    End If
  Next
End Function

