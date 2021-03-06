' Команда - На оплату (Акт)
'------------------------------------------------------------------------------
' Автор: Стромков С.А.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  ThisScript.SysAdminModeOn
  
  ' Проверка подписания акта с двух сторон
  Res = ThisApplication.ExecuteScript("CMD_DLL_CONTRACTS", "IsSignedBothSides",Obj)
  If Res = False Then Exit Function
  
  If Obj.Attributes("ATTR_CCR_INCOMING") = True Then
    'Запрос
    Key = Msgbox("""" & Obj.Description & """ будет передан на оплату. Продолжить?",vbQuestion+vbYesNo)
    If Key = vbNo Then
      Exit Function
    End If
    needZO = True
  Else
    needZO = False
  End If
  
  Call ThisApplication.ExecuteScript("CMD_DLL_CONTRACTS", "SetRegistrationDate",Obj)
 
  RetVal = Run(Obj)
  If RetVal = False Then Exit Function
  
  ' Для акта подрядчика создаем заявку на оплату
  If needZO = True And RetVal = True Then
    Set oZO = ThisApplication.ExecuteScript("FORM_CCR_ZA_PAYMENT(1)","CreateZO",Obj)
    If oZO Is Nothing Then Exit Function
  End If
  Main = True
End Function

Function Run(Obj)
  Run = False
  If Obj Is Nothing Then Exit Function
  'Маршрут
  
  If Obj.Attributes("ATTR_CCR_INCOMING") = True Then
    StatusName = "STATUS_COCOREPORT_PAYMENT"
  Else
    StatusName = "STATUS_COCOREPORT_CLOSED"
  End If
   
  If Obj.StatusName <> StatusName Then
    RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
    If RetVal = -1 Then
      Exit Function
    End If
  End If
  Run = True
End Function


