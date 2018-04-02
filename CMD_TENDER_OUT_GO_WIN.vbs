' Команда - Закрыть как выигравшую (Внешняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "OBJECT_PURCHASE_OUTSIDE"

Call TenderGoWin(ThisObject)

Sub TenderGoWin(Obj)
  ThisScript.SysAdminModeOn
  Set u0 = Nothing
  Set u1 = Nothing
  Set u2 = Nothing
  Set u3 = Nothing
  Set CU = ThisApplication.CurrentUser
  Set Clf = Nothing
  StatusName = "STATUS_TENDER_WIN"
  
  Call PurchaseCloseBySelect(Obj,CU,u0,u1,u2,u3,StatusName,Clf,"ATTR_TENDER_STATUS_WIN")
   if Clf is nothing then 
        Result = False
        Exit Sub  
   End if
  Call PurchaseCloseRoute(Obj,StatusName,Clf)
  
  ThisScript.SysAdminModeOff
End Sub

