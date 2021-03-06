' Команда - Заключено (Соглашение)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  ThisScript.SysAdminModeOn
  
  ' Проверка подписания соглашения с двух сторон
  Res = ThisApplication.ExecuteScript("CMD_DLL_CONTRACTS", "IsSignedBothSides",Obj)
  If Res = False Then Exit Function
  
'  'Запрос
'  Key = Msgbox("""" & Obj.Description & """ будет отмечено как заключенное. Продолжить?",vbQuestion+vbYesNo)
'  If Key = vbNo Then
'    Exit Function
'  End If
  
  Call ThisApplication.ExecuteScript("CMD_DLL_CONTRACTS", "SetRegistrationDate",Obj)
  
  RetVal = Run(Obj)
  If RetVal = False Then Exit Function
  
  'Оповещение пользователей
  Call SendMesages(Obj)
  Call SendOrder(Obj)
  Main = True
End Function

Function Run(Obj)
  Run = False
  If Obj Is Nothing Then Exit Function
  'Маршрут
  StatusName = "STATUS_AGREEMENT_FORCED"
  If Obj.StatusName <> StatusName Then
    RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
    If RetVal = -1 Then
      Exit Function
      'Obj.Status = ThisApplication.Statuses(StatusName)
    End If
  End If
  Run = True
End Function

Sub SendMesages(Obj)

End Sub


Sub SendOrder(Obj)
'msgbox "В разработке!"
End Sub
