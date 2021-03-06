' Команда - Завизировать (Акт)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  ThisScript.SysAdminModeOn
  
  'Запрос подтверждения
  Key = Msgbox ("Вы хотите завизировать """ & Obj.Description & """?",vbYesNo+vbQuestion)
  If Key = vbNo Then Exit Function
  
  
  
  'Маршрут
  StatusName = "STATUS_COCOREPORT_CHECKED"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER","Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If

  ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_KD_CHECK")
'  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrders",Obj,"NODE_KD_CHECK")
  
  'Оповещение 
'  Call MessageSend(Obj)
  Call SendOrder(Obj)
  Main = True
End Function



'==============================================================================
' Отправка информационного поручения
' 
'------------------------------------------------------------------------------
' o_:TDMSObject - разработанное задание
'==============================================================================
Sub SendOrder(Obj)
  Set uToUser = Obj.Attributes("ATTR_AUTOR").User
  If uToUser Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_CORR_REZOL_INF"
  txt = "Проверен акт """ & Obj.Description & """"
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,""
End Sub
