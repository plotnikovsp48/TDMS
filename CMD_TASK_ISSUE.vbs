' Автор: Стромков С.А.
'
' Подписать и передать на согласование
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016


Call TaskIssue(ThisObject)

Public Function TaskIssue(Obj)
  TaskIssue = False
  Dim result
  'Статус, устанавливаемый в результате выполнения команды
  Dim NextStatus
  NextStatus = "STATUS_T_TASK_IS_SIGNED"
  
  ' Проверка наличия файла
  If Not ThisApplication.ExecuteScript("CMD_DLL", "CheckDoc",Obj) Then Exit Function
  
  'Проверяем выполнение входных условий
  result = StartCondCheck (Obj)
  If result <> 0 Then Exit Function 
  
  result = CheckStatusTransition(Obj)
  If result <> 0 Then Exit Function  
    
  'Подтверждение
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, 3129, Obj.Description)    
  If result = vbNo or result = vbCancel Then
    Exit Function
  End If
  
  ThisApplication.Utility.WaitCursor = True
    
  'Call SetRoles (Obj)
  Obj.Permissions = SysAdminPermissions 
  
  'Изменение статуса
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,NextStatus)
  
  ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_KD_SING")

  'Оповещение 
  Call SendMessage(Obj)
  Call SendOrder(Obj)
  TaskIssue = True
  ThisApplication.Utility.WaitCursor = False
End Function

Sub SetRoles (o_)
  Set Users = ThisApplication.CreateCollection(tdmUsers)
  Set TableRows = ThisObject.Attributes("ATTR_T_TASK_TDEPTS_TBL").Rows
  ThisApplication.ExecuteScript "CMD_DLL", "DelDefRole",o_,"ROLE_T_TASK_IN_CHECKER"
  For Each Row in TableRows
    If Row.Attributes("ATTR_T_TASK_DEPT_PERSON").Empty = False Then
      Set User = Row.Attributes("ATTR_T_TASK_DEPT_PERSON").User
      If Users.Has(User) = False Then
        Users.Add User
        Set Role = o_.Roles.Create(ThisApplication.RoleDefs("ROLE_T_TASK_IN_CHECKER"),User)
        Role.Inheritable = False
      End If
    End If
  Next
End Sub

'==============================================================================
' Отправка оповещения о возвращении задания в разработку всем разработчикам
' и соавторам
'------------------------------------------------------------------------------
' o_:TDMSObject - возвращенный в разработку документ
'==============================================================================
Private Sub SendMessage(o_)
  Dim u
  Set CU = ThisApplication.CurrentUser
  For Each r In o_.RolesByDef("ROLE_INITIATOR")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 3504, u, o_, Nothing, o_.Description, CU.Description,ThisApplication.CurrentTime,o_.VersionDescription
  Next
End Sub

'==============================================================================
' Отправка поручение на подписание задания
' подписанту 
'------------------------------------------------------------------------------
' o_:TDMSObject - разработанное задание
'==============================================================================
Sub SendOrder(Obj)
  Set uToUser = Obj.Attributes("ATTR_T_TASK_DEVELOPED").User
  If uToUser Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_CORR_REZOL_INF"
  txt = "Задание """ & Obj.Description & """ подписано и готово к передаче на согласование"
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,""
End Sub


'==============================================================================
' Проверка входных условий
'------------------------------------------------------------------------------
' o_:TDMSObject - Задание
' StartCondCheck: Boolean   True - входные условия выполнены
'                           False - входные условия не выполнены
'==============================================================================
Private Function StartCondCheck(o_)
  StartCondCheck = -1
  ' Проверяем, что отделы - получатели выбраны
  If o_.Attributes("ATTR_T_TASK_TDEPTS_TBL").Rows.count = 0 Then
    StartCondCheck = 3120
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, StartCondCheck, o_.Description
    Exit Function
  End If
  StartCondCheck = 0
End Function

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
  Set p = o_.Parent
  If p.ObjectDefName = "OBJECT_T_TASK" And p.Status.SysName <> "STATUS_T_TASK_IS_CHECKING"  Then
      CheckStatusTransition = 3106
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, CheckStatusTransition, o_.Description    
      Exit Function
  End If
  CheckStatusTransition = 0
End Function
