' Команда - Подписать (Акт)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  
  ' Проверка регистрации договора
  If Obj.Attributes("ATTR_REGISTERED").Value <> True Then
    msgbox "Невозможно подписать договор, т.к. договор не зарегистрирован!",vbCritical,"Подписать"
    Exit Function
  End If
  
  
  'Запрос подтверждения
  Key = Msgbox("Вы хотите подписать """ & Obj.Description & """?", vbQuestion+vbYesNo)
  If Key = vbNo Then
    Exit Function
  End If

  'Маршрут
  StatusName = "STATUS_CONTRACT_SIGNED"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER","Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  ' Закрываем поручение
    Call ThisApplication.ExecuteScript("CMD_KD_ORDER_LIB","clouseAllOrderByRes",Obj,"NODE_KD_SING")
'  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_KD_SING")
  
  ' Закрыто по требованию Скрипальщиковой 21.01.2018
  ' Кейс 6434
'  Call SendOrder(Obj)
  Main = True
End Function


' Отправка поручения подписанту
Sub SendOrder(Obj)
  Set uToUser = Obj.Attributes("ATTR_AUTOR").User
  If uToUser Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_4E1FB947_3927_4101_9C25_D52838C999F6"
  txt = Obj.Description
  planDate = DateAdd ("d", 1, Date) 'Date + 1
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
End Sub
