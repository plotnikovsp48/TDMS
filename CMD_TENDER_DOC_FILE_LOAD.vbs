' Команда - Загрузить файл (Документ закупки)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "CMD_FILES_LIBRARY"

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  
  Call FileAdd(Obj)
  
  ThisScript.SysAdminModeOff
End Sub
