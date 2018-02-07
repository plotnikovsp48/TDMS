' Команда - Аннулировать (Внутренняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
'Запрос подтверждения
   Key = Msgbox("Перевести закупку в статус ""Аннулировано""?", vbQuestion+vbYesNo)
  If Key = vbNo Then
    Exit Sub
  End If  
  'Маршрут
  StatusName = "STATUS_S_INVALIDATED"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
   Msgbox  "Закупка переведена в статус ""Аннулировано"" """,vbInformation
  ThisScript.SysAdminModeOff
End Sub
