' Автор: Стромков С.А.
'
' Библиотека функций стандартной версии
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

USE "CMD_PLAN_TASK_LIB"

Call TaskToCheck(ThisObject)

Public Function TaskToCheck(Obj)
  TaskToCheck = False
  Dim result
  'Статус, устанавливаемый в результате выполнения команды
  NextStatus ="STATUS_T_TASK_IS_CHECKING"

  Obj.Permissions = SysAdminPermissions 
  ' Проверка наличия файла
  If Not ThisApplication.ExecuteScript("CMD_DLL", "CheckDoc",Obj) Then Exit Function
  
  If CheckBeforeSend(Obj)= False Then Exit Function

  
  ' Проверка заполнения Плановой даты
  Set oPT = GetPlanTaskLink(Obj)
  If Not oPT Is Nothing Then
    If oPT.Attributes("ATTR_STARTDATE_ESTIMATED").Empty = True Then 
      
      ans = msgbox("Плановая дата выдачи задания не задана. Будет установлена текущая дата: " & Date() & ". Продолжить?",_
                    vbQuestion+vbYesNo,"Плановая дата")
      If Ans <> vbYes Then Exit Function
      Call ThisApplication.ExecuteScript("OBJECT_P_TASK","SetEstStart",Obj)
      Call ThisApplication.ExecuteScript("OBJECT_P_TASK","SetEstEnd",Obj)
    End If
  End If
  
  ' Подтверждение
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, 3103, Obj.Description)    
  If result = vbNo Then Exit Function
  
  'Если объект еще не создан, сохраняем его
  If ThisApplication.ObjectDefs("OBJECT_T_TASK").Objects.Has(Obj) = False Then Obj.Update
  
  ' Изменение статуса
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,NextStatus)   
  
  ' Создам роль Проверяющий
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole",Obj,"ATTR_T_TASK_CHECKED","ROLE_CHECKER")
  
  ' Создам роль Инициатор согласования
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole",Obj,"ATTR_T_TASK_CHECKED","ROLE_INITIATOR")
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetAttr_F", Obj, "ATTR_KD_EXEC", Obj.Attributes("ATTR_T_TASK_CHECKED").User, True)
    
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","Close_Return_order",Obj)
  
  ' Оповещение
  Call SendMessage(Obj)
  CAll SendOrder(Obj)
  TaskToCheck = True
End Function

'==============================================================================
' Отправка оповещения о завершении разработки задания 
' ответственному за подготовку задания 
'------------------------------------------------------------------------------
' Obj:TDMSObject - разработанное задание
'==============================================================================
Private Sub SendMessage(Obj)
  Dim u
  For Each r In Obj.RolesByDef("ROLE_CHECKER")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 3503, u, Obj, Nothing, _
        Obj.Description, ThisApplication.CurrentUser.Description, Obj.StatusModifyTime
  Next
End Sub

'==============================================================================
' Отправка поручение на проверку задания
' проверяющему 
'------------------------------------------------------------------------------
' Obj:TDMSObject - разработанное задание
'==============================================================================
Sub SendOrder(Obj)
  Set uToUser = Obj.Attributes("ATTR_T_TASK_CHECKED").User
  If uToUser Is Nothing Then Exit Sub
  resol = "NODE_KD_CHECK"
  Call SendOrderToUserByResol(Obj,uToUser,Resol)
End Sub

Sub SendOrderToUserByResol(Obj,uToUser,Resol)
  If uToUser Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  txt = "задание """ & Obj.Description & """"
  planDate = DateAdd ("d", 1, Date) 'Date + 1
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
End Sub

' Проверка перед отправкой на согласование
Function CheckBeforeSend(Obj)
  CheckBeforeSend = False
  str = CheckRequedFieldsBeforeSend(Obj)
  If str <> "" Then
    Msgbox "Не заполнены обязательные атрибуты: " & str,vbExclamation
    Exit Function
  End If
  CheckBeforeSend = True
End Function

' Функция проверки заполнения обязательных полей
Function CheckRequedFieldsBeforeSend(Obj)
  CheckRequedFieldsBeforeSend = ""
  str = ""
  'Тема
  If Obj.Attributes("ATTR_NAME_SHORT").Empty = True Then
    CheckRequedFieldsBeforeSend = "Тема"
    str = str & chr(10) & "- " & CheckRequedFieldsBeforeSend
  End If
  'Проверил1
  If Obj.Attributes("ATTR_T_TASK_CHECKED").User Is Nothing Then
    CheckRequedFieldsBeforeSend = "Проверил1"
    str = str & chr(10) & "- " & CheckRequedFieldsBeforeSend
  End If
  CheckRequedFieldsBeforeSend = str
End Function

