' Команда - Вернуть на доработку (Документ)
'------------------------------------------------------------------------------
' Автор: Стромков С.А.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  ThisScript.SysAdminModeOn
  
  'Запрос причины
    result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину возврата документа:")
    If IsEmpty(result) Then
      Exit Function 
    ElseIf trim(result) = "" Then
      msgbox "Невозможно вернуть документ не указав причину." & vbNewLine & _
          "Пожалуйста, введите причину возврата.", vbCritical, "Не задана причина возврата!"
      Exit Function
    End If
  
  ThisApplication.Utility.WaitCursor = True
  
  If Obj.StatusName = "STATUS_DOCUMENT_CHECK" Then
    resol = "NODE_KD_CHECK"
  ElseIf Obj.StatusName = "STATUS_DOCUMENT_IS_APPROVING" Then
    resol = "NODE_KD_APROVER"
  End If
  
  'Создание рабочей версии
  Obj.Versions.Create ,Result
  
  'Маршрут
  StatusName = "STATUS_DOCUMENT_CREATED"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  ' Закрываем поручение
    
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","RejectOrderByResol",Obj,resol)
  
  'Оповещение пользователей
  Call SendOrder(Obj)
  
  ThisApplication.Utility.WaitCursor = False
  ThisScript.SysAdminModeOff
  Main = True
End Function


'==============================================================================
' Отправка поручение на доработку задания
' разработчику задания 
'------------------------------------------------------------------------------
' o_:TDMSObject - разработанное задание
'==============================================================================
Sub SendOrder(Obj)
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","SendOrder_NODE_KD_RETUN_USER",Obj)
End Sub



