' Команда - Передать на проверку (Накладная)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  
  If Obj.Permissions.Locked = True Then
    If Obj.Permissions.LockOwner = False Then
      msgbox "Объект заблокирован пользователем " & Obj.Permissions.LockUser.Description & ". Отправка на подписание невозможна.",vbCritical, _
            "Отправка на подписание"
      Exit Function
    End If
  End If
    
  ' Проверка заполнения обязательных полей
  List = "ATTR_SIGNER,ATTR_REG_NUMBER,ATTR_INVOICE_RECIPIENT,ATTR_INVOICE_ADDRESS"
  res = ThisApplication.ExecuteScript("CMD_S_DLL","CheckRequedFields",Obj,List)
  
  If res <> "" Then
    Msgbox "Не заполнены обязательные атрибуты: " & chr(10) & res,vbExclamation,"Ошибка"
    Exit Function
  End If
    
  ' Подтверждение
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, 1527, Obj.Description)    
  If result = vbNo Then Exit Function
  
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,"STATUS_INVOICE_ONSIGN")
  'Назначение ролей
  Call RolesCreate(Obj)
  
  ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_KD_CHECK")
'  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrders",Obj,"NODE_KD_CHECK")
  
  Call  SendOrder(Obj)

  Main = True
End Function

Sub SendOrder(Obj)
  Set uToUser = Obj.Attributes("ATTR_SIGNER").User
  If uToUser Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_KD_SING"
  txt = "Накладная """ & Obj.Description & """"
  planDate = DateAdd ("d", 1, Date) 'Date + 1
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
End Sub


'Процедура назначения ролей
Sub RolesCreate(Obj)
  'Синхронизация роли и атрибута "Подписант"
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_SIGNER","ROLE_TO_SIGN")
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_SIGNER","ROLE_INVOICE_INVALIDATED")
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_SIGNER","ROLE_INVOICE_BACK_TO_FORTHEPICKING")
End Sub
