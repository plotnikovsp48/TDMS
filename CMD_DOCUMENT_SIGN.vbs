' Автор: Стромков С.А.
'
' Подписать и передать на согласование
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016


Call Main(ThisObject)

Public Function Main(Obj)
  Main = False
  Dim result
  'Статус, устанавливаемый в результате выполнения команды
  Dim StatusName
  StatusName = "STATUS_DOCUMENT_DEVELOPED"
    
  'Подтверждение
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, 1529, Obj.Description)    
  If result = vbNo or result = vbCancel Then
    Exit Function
  End If

  'Изменение статуса
'  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,NextStatus)
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    msgbox "Маршрут не найден. Обратитесь к администратору", vbCritical,"Ошибка маршрута"
    Exit Function
  End If
  
  ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_KD_SING")
'  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrders",Obj,"NODE_KD_CHECK")
  
  Call SendOrder(Obj)
  Main = True
End Function

'==============================================================================
' Отправка поручение на подписание задания
' подписанту 
'------------------------------------------------------------------------------
' o_:TDMSObject - разработанное задание
'==============================================================================
Sub SendOrder(Obj)
  Set uToUser = Obj.Attributes("ATTR_RESPONSIBLE").User
  If uToUser Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_CORR_REZOL_INF"
  txt = "Документ подписан: """ & Obj.Description & """"
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,""
End Sub

