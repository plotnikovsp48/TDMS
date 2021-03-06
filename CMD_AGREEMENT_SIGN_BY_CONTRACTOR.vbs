' Команда - Подписать (Соглашение)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

USE "CMD_DLL_CONTRACTS"

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  ThisScript.SysAdminModeOn
    
  ' Помечаем как подписанный
  If SignedByContractor(Obj) = False Then Exit Function

  ' Проверка подписания с двух сторон
  ' Пытаемся перевести в состояние Заключено.
  Select Case Obj.ObjectDefName
    Case "OBJECT_CONTRACT_COMPL_REPORT"
      cmd = "CMD_CCR_TO_PAY"
    Case "OBJECT_CONTRACT"
      cmd = "CMD_CONTRACT_TO_COMPLETION"
    Case "OBJECT_AGREEMENT"
      cmd = "CMD_AGREEMENT_TO_COMPLETION"
  End Select
  
  Res = ThisApplication.ExecuteScript(cmd,"Main",Obj)
  If Res = False Then 
    Exit Function
  End If
    
  ThisScript.SysAdminModeOff
  Main = True
End Function
