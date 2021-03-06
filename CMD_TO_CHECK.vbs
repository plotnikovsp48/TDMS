' Автор: Стромков С.А.
'
' Отправка на проверку
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2017


Call SendToCheck(ThisObject)

' Отправка на подписание/проверку
Public Function SendToCheck(Obj)
  SendToCheck = False
  Select Case Obj.ObjectDefName
    Case "OBJECT_DOCUMENT_AN"
      SendToCheck = ThisApplication.ExecuteScript("CMD_DOC_AN_TO_CHECK","Main",Obj)
    Case Else
      SendToCheck = ThisApplication.ExecuteScript("CMD_DOC_AN_TO_CHECK","Main",Obj)
  End Select
End Function

' Подписание
Public Function ToSign(Obj)
  ToSign = False
  Select Case Obj.ObjectDefName
    Case "OBJECT_DOCUMENT_AN"
      ToSign = ThisApplication.ExecuteScript("CMD_DOCUMENT_SIGN","Main",Obj)
    Case Else
      ToSign = ThisApplication.ExecuteScript("CMD_DOCUMENT_SIGN","Main",Obj)
  End Select
End Function

' Отправка на Утверждение
Public Function SendToAproove(Obj)
  SendToAproove = False
  Select Case Obj.ObjectDefName
    Case "OBJECT_DOCUMENT_AN"
      SendToAproove = ThisApplication.ExecuteScript("CMD_DOCUMENT_SENT_TO_APPROVE","Main",Obj)
    Case Else
      SendToAproove = ThisApplication.ExecuteScript("CMD_DOCUMENT_SENT_TO_APPROVE","Main",Obj)
  End Select
End Function

' Утверждение
Public Function ToAproove(Obj)
  ToAproove = False
  Select Case Obj.ObjectDefName
    Case "OBJECT_DOCUMENT_AN"
      ToAproove = ThisApplication.ExecuteScript("CMD_DOCUMENT_APPROVE","Main",Obj)
    Case Else
      ToAproove = ThisApplication.ExecuteScript("CMD_DOCUMENT_APPROVE","Main",Obj)
  End Select
End Function

' Отклонение
Public Function ToReject(Obj)
  ToReject = False
  Select Case Obj.ObjectDefName
    Case "OBJECT_DOCUMENT_AN","OBJECT_LIST_AN","OBJECT_DOCUMENT"
      ToReject = ThisApplication.ExecuteScript("CMD_DOCUMENT_BACK_TO_WORK","Main",Obj)
    Case Else
      ToReject = ThisApplication.ExecuteScript("CMD_DOC_BACK_TO_WORK","Main",Obj)
  End Select
End Function

' Аннулирование
Public Function ToInvalidate(Obj)
  ToInvalidate = False
  Select Case Obj.ObjectDefName
    Case "OBJECT_DOCUMENT_AN"
      ToInvalidate = ThisApplication.ExecuteScript("CMD_DOC_INVALIDATED","Run",Obj)
    Case Else
      ToInvalidate = ThisApplication.ExecuteScript("CMD_DOC_INVALIDATED","Run",Obj)
  End Select
End Function

' Готово к отправке
Public Function ReadyToIssue(Obj)
  ReadyToIssue = ThisApplication.ExecuteScript("CMD_READY_TO_ISSUE","Main",Obj)
End Function

