' Автор: Стромков С.А.
'
' Библиотека функций стандартной версии
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

Call TaskToSign(ThisObject)

Public Function TaskToSign(Obj)
  TaskToSign = False
  Dim result
    
  ' Проверка наличия файла
  If Not ThisApplication.ExecuteScript("CMD_DLL", "CheckDoc",Obj) Then Exit Function
  
  Obj.Permissions = SysAdminPermissions 
'  Set CU = ThisApplication.CurrentUser
'  ' Проверка заполнения второго проверяющего
'  
'  Set chck1 = Obj.Attributes("ATTR_T_TASK_CHECKED").User
'  Set chck2 = Obj.Attributes("ATTR_USER_CHECKED").User

'  ' Проверяем задан ли второй проверяющий
'  If chck2 Is Nothing Then
'    ' Второй проверяющий не указан, сразу переходим к изменению статуса
'    changeStatus = True
'  Else
'    ' Второй проверяющий указан
'    If chck2.Handle = cu.Handle Then
'      ' Если второй проверяющий - текущий пользователь, то меняем статус
'      changeStatus = True
'    Else
'      If chck1.handle = cu.Handle Then
'        ' Если второй проверяющий - не текущий и не первый, а такущий - первый, то статус не меняем
'        changeStatus = False
'      End If
'    End If
'  End If
  
  changeStatus = needToChangeStatus(Obj)
  
  
  retVal1 = False
  retVal2 = False
  If changeStatus = True Then
    retVal1 = Run1(Obj)
  Else
    retVal2 = Run2(Obj)
  End If

  TaskToSign = RetVal1 Or RetVal2
  ThisApplication.Utility.WaitCursor = False
End Function

Function Run1(Obj)
  Obj.Permissions = SysAdminPermissions 
  Run1 = False
  ' Проверка заполнения подписанта
  If Obj.Attributes("ATTR_SIGNER").User Is Nothing Then 
    msgbox "Поле Подписант не заполнено!"
    Exit Function
  End If
  
  'Статус, устанавливаемый в результате выполнения команды
  NextStatus = "STATUS_T_TASK_IS_SIGNING"
  
  ' Подтверждение
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, 3109, Obj.Description)    
  If result = vbNo Then Exit Function  
  ThisApplication.Utility.WaitCursor = True
  ' Изменение статуса
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,NextStatus)    
  
    ' Создаем роль Подписант
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole",Obj,"ATTR_SIGNER","ROLE_SIGNER")
  
  ' Создам роль Инициатор согласования
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole",Obj,"ATTR_SIGNER","ROLE_INITIATOR")
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetAttr_F", Obj, "ATTR_KD_EXEC", Obj.Attributes("ATTR_SIGNER").User, True)
  Call Close_order(Obj)
  
  ' Оповещение
  Call SendMessage(Obj)
  Call SendOrder(Obj)

  Run1 = True
End Function

Function Run2(Obj)
  Obj.Permissions = SysAdminPermissions
  Run2 = False
  Set chck2 = Obj.Attributes("ATTR_USER_CHECKED").User
  Call Close_order(Obj)
  ' Создам роль Проверяющий
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole",Obj,"ATTR_USER_CHECKED","ROLE_CHECKER")
  ' Создам роль Инициатор согласования
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole",Obj,"ATTR_USER_CHECKED","ROLE_INITIATOR")
  ' Оповещение
  Call ThisApplication.ExecuteScript("CMD_TASK_TO_CHECK","SendMessage",Obj)
  Call ThisApplication.ExecuteScript("CMD_TASK_TO_CHECK","SendOrderToUserByResol",Obj,chck2,"NODE_KD_CHECK")
  Run2 = True
End Function
'==============================================================================
' Отправка оповещения о завершении разработки задания 
' ответственному за подготовку задания 
'------------------------------------------------------------------------------
' o_:TDMSObject - разработанное задание
'==============================================================================
Private Sub SendMessage(o_)
  Dim u
  For Each r In o_.RolesByDef("ROLE_SIGNER")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 3507, u, o_, Nothing, o_.Description, ThisApplication.CurrentUser.Description, o_.StatusModifyTime
  Next
End Sub

Sub Close_order(Obj)
  ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_KD_CHECK")
End Sub
'==============================================================================
' Отправка поручение на подписание задания
' подписанту 
'------------------------------------------------------------------------------
' o_:TDMSObject - разработанное задание
'==============================================================================
Sub SendOrder(Obj)
  Set uToUser = Obj.Attributes("ATTR_SIGNER").User
  If uToUser Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_KD_SING"
  txt = "задание """ & Obj.Description & """"
  planDate = DateAdd ("d", 1, Date) 'Date + 1
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
End Sub

Function needToChangeStatus(Obj)
  needToChangeStatus = False
  Set CU = ThisApplication.CurrentUser
  ' Проверка заполнения второго проверяющего
  
  Set chck1 = Obj.Attributes("ATTR_T_TASK_CHECKED").User
  Set chck2 = Obj.Attributes("ATTR_USER_CHECKED").User

  ' Проверяем задан ли второй проверяющий
  If chck2 Is Nothing Then
    ' Второй проверяющий не указан, сразу переходим к изменению статуса
    needToChangeStatus = True
  Else
    ' Второй проверяющий указан
    If chck2.Handle = cu.Handle Then
      ' Если второй проверяющий - текущий пользователь, то меняем статус
      needToChangeStatus = True
    Else
      If chck1.handle = cu.Handle Then
        ' Если второй проверяющий - не текущий и не первый, а такущий - первый, то статус не меняем
        needToChangeStatus = False
      End If
    End If
  End If
End Function
