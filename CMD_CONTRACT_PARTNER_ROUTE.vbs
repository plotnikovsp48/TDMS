' Команда - Отправить контрагенту (Договор)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  
  'Подтверждение
  Key = Msgbox("Договор будет помечен, как отправленный контрагенту. Продолжить?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
  
  'Маршрут
  StatusName = "STATUS_CONTRACT_PARTNER_ROUTED"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  'Запрос создания исходящего документа
  Key = Msgbox("Создать исходящий документ?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
  
  'Создание исходчщего документа
  Msgbox "Подготовка исходящего документа в разработке", vbInformation
  
End Sub