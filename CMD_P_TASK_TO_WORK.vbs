' Автор: Стромков С.А.
'
' Передает Задачу в работу
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

Dim o
Set o = ThisObject
o.Permissions = SysAdminPermissions 

Call Run(o)


Sub Run(o_)
  Dim NextStatus
  Dim Result
  
  If Not CheckTask(o_) Then Exit Sub
  
  'Статус, устанавливаемый в результате выполнения команды
  NextStatus ="STATUS_P_TASK_ASSIGNED"
  
  ' Подтверждение
  Result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbYesNo, 4151, o_.Description)    
  If Result <> vbYes Then
    Exit Sub
  End If 

  ' Изменение статуса
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o_,o_.Status,o_,NextStatus)    
  ' Оповещение
  Call SendMessage(o_)
End Sub


'==============================================================================
' Отправка оповещения о возвращении задачи в работу Ответственному по Задаче
'------------------------------------------------------------------------------
' o_:TDMSObject - Задача
'==============================================================================
Private Sub SendMessage(o_)
  Dim u
  For Each r In o_.RolesByDef("ROLE_TASK_RESPONSIBLE")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 4171, u, o_, Nothing, o_.Description, ThisApplication.CurrentUser.Description
  Next
End Sub

  
'==============================================================================
' Проверка Задачи
'------------------------------------------------------------------------------
' o_:TDMSObject - разработанный документ
' CheckTask:Boolean - Результат проверки
'==============================================================================
Private Function CheckTask(o_)
  CheckTask = False
  
  msgbox "Здесь проверка, что Задача может быть передана в работу"
  ' Проверка наличия файла
  'M(4)= "% не содержит файлы!"
'  If o_.Files.count<=0 Then
'    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1004, o_.ObjectDef.Description
'    Exit Function
'  End If  
  CheckTask = True
End Function
