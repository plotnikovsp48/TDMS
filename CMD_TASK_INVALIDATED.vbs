' Автор: Чернышов Д.С.
'
' Команда - Аннулировать задание
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016
USE "CMD_S_DLL"

Call TaskInvalidated(ThisObject)

Function TaskInvalidated(Obj)
  TaskInvalidated = False
  Set Roles = Obj.RolesForUser(ThisApplication.CurrentUser)
  
  '  'Проверка состояния
  result = CheckStatusTransition(Obj)
  If result <> 0 Then Exit Function  
  
  'Запрос причины аннулирования
  result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину аннулирования задания:")
  If IsEmpty(result) Then
    Exit Function 
  ElseIf trim(result) = "" Then
    msgbox "Невозможно аннулировать задание не указав причину." & vbNewLine & _
        "Пожалуйста, введите причину аннулирования.", vbCritical, "Не задана причина аннулирования!"
    Exit Function
  End If  
  
  'Создание рабочей версии
'  Obj.Versions.Create ,result
  Call VersionCreate(Obj, result)

  Set oldStatus = Obj.Status
  
  'Смена статуса
  res = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,"STATUS_T_TASK_INVALIDATED")    
  If Res <0 Then
    Exit Function
  End If
  
  'Установка фактической даты завершения Задания
  If Obj.Attributes("ATTR_ENDDATE_FACT").Empty = True Then
    Call ThisApplication.ExecuteScript("CMD_DLL", "SetAttr", Obj,"ATTR_ENDDATE_FACT",Obj.StatusModifyTime)
  End If
  
  ' Закрываем все поручения
  Call ThisApplication.ExecuteScript("CMD_KD_ORDER_LIB","clouseAllOrderByRes",Obj, "NODE_KD_CHECK")
  Call ThisApplication.ExecuteScript("CMD_KD_ORDER_LIB","clouseAllOrderByRes",Obj, "NODE_KD_SING")
  Call ThisApplication.ExecuteScript("CMD_KD_ORDER_LIB","clouseAllOrderByRes",Obj, "NODE_KD_APROVER")
  Call ThisApplication.ExecuteScript("CMD_KD_ORDER_LIB","clouseAllOrderByRes",Obj, "NODE_KD_RETUN_USER")
  
  
  If Not oldStatus Is Nothing Then
    If oldStatus.SysName = "STATUS_T_TASK_APPROVED" Then 
      Call SendMessage (Obj,Result)
    End If
  End If
  
  Set Disp = ThisApplication.ExecuteScript("CMD_DLL_ROLES","GetProjectDispatcher",Obj)
  If Not Disp Is Nothing Then
    Call SendOrder(Obj,Disp)
  End If
  
  TaskInvalidated = True
End Function

'==============================================================================
' Отправка оповещения об аннулировании задания 
' получателям задания 
'------------------------------------------------------------------------------
' o_:TDMSObject - разработанное задание
' txt_:String - причина аннулирования
'==============================================================================
Private Sub SendMessage(o_,txt_)
  Set CU = ThisApplication.CurrentUser
  Set Roles = o_.RolesForUser(CU)
  Set Rows = o_.Attributes("ATTR_T_TASK_TDEPTS_TBL").Rows
  'Оповещение пользователей
  'Отделы-адресаты
  For Each Row in Rows
    If Row.Attributes("ATTR_T_TASK_DEPT_PERSON").Empty = False Then
      If Row.Attributes("ATTR_T_TASK_DEPT_PERSON").User.SysName <> CU.SysName Then
        Set u = Row.Attributes("ATTR_T_TASK_DEPT_PERSON").User
        ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 3509, u, o_, Nothing, o_.Description, CU.Description, ThisApplication.CurrentTime, txt_
      End If
    End If
  Next
End Sub

'==============================================================================
' Функция проверяет условие перехода по статусам
'------------------------------------------------------------------------------
' o_:TDMSObject - Системный идентификатор обрабатываемого ИО
' CheckStatusTransition:Integer - Результат проверки 
'       (0:Проверка успешна,№ - номер ошибки (сообщения))
'==============================================================================
Private Function CheckStatusTransition(o_)
  CheckStatusTransition = -1
  ' Проверка статуса задания
  sName = o_.StatusName
  If sName = "STATUS_KD_AGREEMENT" OR  sName = "STATUS_T_TASK_INVALIDATED" Then
      CheckStatusTransition = 3115
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, CheckStatusTransition, o_.Description    
      Exit Function
  End If
  CheckStatusTransition = 0
End Function


Sub SendOrder(Obj,uToUser)
  If Obj Is Nothing Or uToUser Is Nothing Then Exit Sub

  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_KD_EXECUTE"
  
  txt = "Задание " & Obj.Description & " аннулировано пользователем " & ThisApplication.CurrentUser.Description & _
                                  ". Произведите корректировку графика проекта. Дата аннулирования: " & Obj.StatusModifyTime
  planDate = DateAdd ("d", 1, Date)
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
End Sub
