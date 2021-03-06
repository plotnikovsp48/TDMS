' Команда - Передать на проверку (Накладная)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  ' Проверка заполнения обязательных полей
  List = "ATTR_AUTOR,ATTR_INVOICE_EVERTYPE,ATTR_CHECKER,ATTR_SIGNER,ATTR_REG_NUMBER,ATTR_INVOICE_RECIPIENT,ATTR_INVOICE_ADDRESS"
  res = ThisApplication.ExecuteScript("CMD_S_DLL","CheckRequedFields",Obj,List)
  
  If res <> "" Then
    Msgbox "Не заполнены обязательные атрибуты: " & chr(10) & res,vbExclamation,"Ошибка"
    Exit Function
  End If

  ' Подтверждение
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, 1405, Obj.Description)    
  If result = vbNo Then Exit Function
  
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,"STATUS_INVOICE_ONCHECK")
  
  ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_KD_RETUN_USER")
  
  'Назначение ролей
  Call RolesCreate(Obj)
  
  Call  SendOrder(Obj)
  Main = True
End Function

''Процедура назначения ролей
'Sub RolesCreate(Obj)
'  'ГИПу и Куратору договора даем роли Подписать, Вернуть на комплектацию, Аннулирование
'  For Each Role in Obj.Roles
'    'ГИП
'    If Role.RoleDefName = "ROLE_GIP" Then
'      If not Role.User is Nothing Then
'        Set User = Role.User
'      Else
'        Set User = Role.Group
'      End If
'      Call RoleCreate(Obj,"ROLE_TO_SIGN",User)
'      Call RoleCreate(Obj,"ROLE_INVOICE_INVALIDATED",User)
'      Call RoleCreate(Obj,"ROLE_INVOICE_BACK_TO_FORTHEPICKING",User)
'    'Куратор договора
'    ElseIf Role.RoleDefName = "ROLE_CONTRACT_RESPONSIBLE" Then
'      If not Role.User is Nothing Then
'        Set User = Role.User
'      Else
'        Set User = Role.Group
'      End If
'      Call RoleCreate(Obj,"ROLE_TO_SIGN",User)
'      Call RoleCreate(Obj,"ROLE_INVOICE_INVALIDATED",User)
'      Call RoleCreate(Obj,"ROLE_INVOICE_BACK_TO_FORTHEPICKING",User)
'    End If
'  Next
'End Sub


'Процедура назначения ролей
Sub RolesCreate(Obj)
  'Синхронизация роли и атрибута "Подписант"
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_CHECKER","ROLE_CHECKER")
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_CHECKER","ROLE_INVOICE_INVALIDATED")
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_CHECKER","ROLE_INVOICE_BACK_TO_FORTHEPICKING")
End Sub

'Процедура назначения роли
Sub RoleCreate(Obj,RoleName,User)
  Check = True
  For Each Role in Obj.Roles
    If Role.RoleDefName = RoleName Then
      If not Role.User is Nothing Then
        If Role.User.SysName = User.SysName Then
          Check = False
          Exit For
        End If
      Else
        If Role.Group.SysName = User.SysName Then
          Check = False
          Exit For
        End If
      End If
    End If
  Next
  If Check = True Then
    Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,User)
  End If
End Sub

Sub SendOrder(Obj)
  Set uToUser = Obj.Attributes("ATTR_CHECKER").User
  If uToUser Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_KD_CHECK"
  txt = "Накладная """ & Obj.Description & """"
  planDate = DateAdd ("d", 1, Date)
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
End Sub

