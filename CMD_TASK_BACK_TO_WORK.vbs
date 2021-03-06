' Автор: Стромков С.А.
'
' Возврат задания на доработку от Ответственного за подготовку задания Разработчику задания
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

Call TaskReturn(ThisObject)

Public Function TaskReturn(Obj)
  TaskReturn = False
  Dim result
  result = CheckStatusTransition(Obj)
  If result <> 0 Then Exit Function  

  Select Case Obj.StatusName
    Case "STATUS_T_TASK_IS_CHECKING", "STATUS_T_TASK_IS_SIGNING"
      check =  TaskBackToWork(Obj)
    Case "STATUS_T_TASK_IS_APPROVING"
      check =  ThisApplication.ExecuteScript("CMD_TASK_REJECT","TaskReject",Obj)
    Case Else
      Exit Function
  End Select

  TaskReturn = check
End Function

' Возврат с проверки
Public Function TaskBackToWork(Obj)
  TaskBackToWork = False
  Obj.Permissions = SysAdminPermissions 

    'Запрос причины
    result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину возврата задания:")
    If IsEmpty(result) Then
      Exit Function 
    ElseIf trim(result) = "" Then
      msgbox "Невозможно вернуть задание не указав причину." & vbNewLine & _
          "Пожалуйста, введите причину возврата.", vbCritical, "Не задана причина возврата!"
      Exit Function
    End If
                     
  ' Создание версии
  Obj.Versions.Create ,result
  
  If Obj.StatusName = "STATUS_T_TASK_IS_CHECKING" Then
    resol = "NODE_KD_CHECK"
  ElseIf Obj.StatusName = "STATUS_T_TASK_IS_SIGNING" Then
    resol = "NODE_KD_SING"
  End If   
  
  'Маршрут
  StatusName = "STATUS_T_TASK_IN_WORK"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    'Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,resol)
  
  ' Оповещение 
  Call SendMessage(Obj)
  ThisApplication.ExecuteScript "CMD_DLL_ORDERS", "SendOrder_NODE_KD_RETUN_USER",Obj
  'Call SendOrder(Obj)

  TaskBackToWork = True
End Function

'==============================================================================
' Отправка оповещения о возвращении задания в разработку всем разработчикам
' и соавторам
'------------------------------------------------------------------------------
' o_:TDMSObject - возвращенный в разработку документ
'==============================================================================
Sub SendMessage(o_)
  Dim u
  For Each r In o_.RolesByDef("ROLE_T_TASK_DEVELOPER")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 3508, u, o_, Nothing, o_.Description, ThisApplication.CurrentUser.Description,ThisApplication.CurrentTime,o_.VersionDescription
  Next
  For Each r In o_.RolesByDef("ROLE_CO_AUTHOR")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 3508, u, o_, Nothing, o_.Description, ThisApplication.CurrentUser.Description,ThisApplication.CurrentTime,o_.VersionDescription
  Next  
End Sub

'==============================================================================
' Отправка поручение на доработку задания
' разработчику задания 
'------------------------------------------------------------------------------
' o_:TDMSObject - разработанное задание
'==============================================================================
Sub SendOrder(Obj)
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","SendOrder_NODE_KD_RETUN_USER",Obj)
  
'  Set uToUser = Obj.Attributes("ATTR_T_TASK_DEVELOPED").User
'  If uToUser Is Nothing Then Exit Sub
'  Set uFromUser = ThisApplication.CurrentUser
'  resol = "NODE_KD_RETUN_USER"
'  txt = "задание """ & Obj.Description & """ Причина: " & Obj.VersionDescription
'  planDate = DateAdd ("d", 1, Date) 'Date + 1
'  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
End Sub

'==============================================================================
' Функция проверяет условие перехода по статусам
'------------------------------------------------------------------------------
' o_:TDMSObject - Системный идентификатор обрабатываемого ИО
' CheckStatusTransition:Integer - Результат проверки 
'       (0:Проверка успешна,№ - номер ошибки (сообщения))
'==============================================================================
Private Function CheckStatusTransition(o_)
  Dim p
  CheckStatusTransition = -1
  ' Проверка статуса задания
  If o_.Parent is Nothing Then Exit Function
  Set p = o_.Parent
  If p.ObjectDefName = "OBJECT_T_TASK" And (p.Status.SysName <> "STATUS_T_TASK_IS_SIGNING" OR p.Status.SysName <> "STATUS_T_TASK_IS_CHECKING" OR p.Status.SysName <> "STATUS_T_TASK_IS_APPROVING") Then
      CheckStatusTransition = 3116
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, CheckStatusTransition, o_.Description    
      Exit Function
  End If
  CheckStatusTransition = 0
End Function
