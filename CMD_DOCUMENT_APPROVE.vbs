' Автор: Стромков С.А.
'
' Библиотека функций стандартной версии
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016 г.



Call Main(ThisObject)

Public Function Main(Obj)
  Main = False
  Dim result
  Select Case Obj.ObjectDefName
    Case "OBJECT_DOCUMENT_AN"
      StatusName ="STATUS_DOCUMENT_FIXED"
    Case  Else
      StatusName ="STATUS_DOC_IS_FIXED"
  End Select
  ' Подтверждение
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, 1008, Obj.Description)    
  If result <> vbYes Then
    Exit Function
  End If   
  
  'Изменение статуса
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    msgbox "Маршрут не найден. Обратитесь к администратору", vbCritical,"Ошибка маршрута"
    Exit Function
  End If
  ThisApplication.Utility.WaitCursor = True
  Call SendOrder(Obj)
  ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_KD_APROVER")
  'Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrders",Obj,"NODE_KD_APROVER")
  Main = True
  scr = ""
  Select Case Obj.Parent.ObjectDefName
    Case "OBJECT_VOLUME"
      Scr = "CMD_VOLUME_APPROVE"
    Case "OBJECT_WORK_DOCS_SET"
      Scr = "CMD_VOLUME_APPROVE"
  End Select
  If scr = "" Then Exit Function
  ' Если все документы утверждены - предлагаем утвердить комплект или Том
  RetVal = ThisApplication.ExecuteScript(Scr,"CheckStatusTransition",Obj)
  
  ThisApplication.Utility.WaitCursor = False
  If RetVal = True Then
    ans = msgbox("Все документы в составе основного комплекта утверждены. Утвердить комплект?" & Obj.Description,vbQuestion+vbYesNo)
    If ans <> vbYes Then Exit Function
    ' переводим комплект в утвержденное состояние
    Call ThisApplication.ExecuteScript(Scr,"Run",Obj)
  End If  
  
End Function

'==============================================================================
' Отправка информационного поручения об утверждении документа
' разработчику
'------------------------------------------------------------------------------
' Obj:TDMSObject - разработанное задание
'==============================================================================
Sub SendOrder(Obj)
  Set uToUser = Obj.Attributes("ATTR_RESPONSIBLE").User
  If uToUser Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_CORR_REZOL_INF"
  txt = "Документ утвержден: """ & Obj.Description & """"
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,""
End Sub

