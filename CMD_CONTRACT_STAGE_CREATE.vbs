' Команда - Создать Этап
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

USE "CMD_DLL_CONTRACTS"

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  
  Set oStage = Create_Contract_Stage(Obj)
End Sub


