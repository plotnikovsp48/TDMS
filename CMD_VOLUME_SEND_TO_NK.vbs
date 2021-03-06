' Автор: Стромков С.А.
'
' Передача Тома на нормоконтроль
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016


Call Main(ThisObject)

Sub Main(Obj)
  
  ' Проверяем условия перехода по статусам
  Dim result
  result = Call ThisApplication.ExecuteScript("CMD_WORK_DOCS_SET_SEND_TO_NK","CheckStatusTransition",Obj)
  If result <> 0 Then Exit Sub 
  
  '  Подтверждение отправки на Нормоконтроль
  result = ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbQuestion+VbYesNo, 1272,Obj.Description)
  If result <> vbYes Then
    Exit Sub
  End If 
   
  Call ThisApplication.ExecuteScript("CMD_WORK_DOCS_SET_SEND_TO_NK","DocProcess",Obj)
  
  'Статус, устанавливаемый в результате выполнения команды
  Dim NextStatus
  NextStatus ="STATUS_VOLUME_IS_SENT_TO_NK"
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,NextStatus)

  ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1502, Obj.ObjectDef.Description,Obj.Description    

  '  Отправка сообщений в группу Нормоконтролеров
  Call ThisApplication.ExecuteScript("CMD_WORK_DOCS_SET_SEND_TO_NK","SendMessage",Obj)
End Sub




