' Автор: Чернышов Д.С.
'
' Команда - Отклонить задание c утверждения
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

Call TaskReject(ThisObject)

Function TaskReject(Obj)
  TaskReject = False
  
  'Проверка состояния
'  Set Row = CheckObj(o,Rows,CU)
'  If Row is Nothing Then
'    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 3108, o.Description
'    Exit Sub
'  End If

    'Запрос причины
    result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину отклонения задания:")
    If IsEmpty(result) Then
      Exit Function 
    ElseIf trim(result) = "" Then
      msgbox "Невозможно отклонить задание не указав причину." & vbNewLine & _
          "Пожалуйста, введите причину отклонения.", vbCritical, "Не задана причина отклонения!"
      Exit Function
    End If 
  
  'Создание рабочей версии
  Obj.Versions.Create ,Result
  
  'Заполнение атрабитов
'  If not Row is Nothing Then
'    Row.Attributes("ATTR_T_TASK_DEPT_DATE").Value = Date
'    Row.Attributes("ATTR_T_TASK_REJECT_REASON").Value = Result
'    Row.Attributes("ATTR_RESOLUTION").Classifier = _
'      ThisApplication.Classifiers("NODE_RESOLUTION").Classifiers("NODE_REJECT")
'  End If
  
  'Смена статуса
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,"STATUS_T_TASK_IN_WORK")    
  
  ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_KD_APROVER")
  
  Call SendMessage(Obj)
  ThisApplication.ExecuteScript "CMD_DLL_ORDERS", "SendOrder_NODE_KD_RETUN_USER",Obj
  TaskReject = True
End Function

'Функция проверки объекта и получения строки в таблице
Function CheckObj(o,Rows,CU)
  Set CheckObj = Nothing
  For Each Row in Rows
    If Row.Attributes("ATTR_T_TASK_DEPT_PERSON").User.SysName = CU.SysName Then
      Set CheckObj = Row
      Exit For
    End If
  Next
End Function

'==============================================================================
' Отправка оповещения о возвращении задания в разработку всем разработчикам
' и соавторам
'------------------------------------------------------------------------------
' o_:TDMSObject - возвращенный в разработку документ
'==============================================================================
Sub SendMessage(o_)
  Set Roles = o_.RolesByDef(ThisApplication.RoleDefs("ROLE_T_TASK_OUT_CHECKER"))
  Set Rows = o_.Attributes("ATTR_T_TASK_TDEPTS_TBL").Rows
  Set CU = ThisApplication.CurrentUser
  
'Оповещение пользователей
  'Ответственный за подготовку задания
  For Each Role in Roles
    If not Role.User is Nothing Then
      Set u = Role.User
    Else
      Set u = Role.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 3505, u, o_, Nothing, o_.Description, CU.Description, ThisApplication.CurrentTime, o_.VersionDescription
    Exit For
  Next
  'Отделы-адресаты
  For Each Row in Rows
    If Row.Attributes("ATTR_T_TASK_DEPT_PERSON").Empty = False Then
      If Row.Attributes("ATTR_T_TASK_DEPT_PERSON").User.SysName <> CU.SysName Then
        Set u = Row.Attributes("ATTR_T_TASK_DEPT_PERSON").User
        ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 3505, u, o_, Nothing, o_.Description, CU.Description, ThisApplication.CurrentTime, o_.VersionDescription
      End If
    End If
  Next
End Sub
