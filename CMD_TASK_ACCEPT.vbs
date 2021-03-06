' Автор: Чернышов Д.С.
' Редактировал: Стромков С.А. 03/03/2017
' 
' Команда - Принять задание
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

USE "CMD_DLL"

Call TaskAccept(ThisObject)

Public Function TaskAccept(Obj)
  TaskAccept = False
  Obj.Permissions = SysAdminPermissions
    
  'Подтверждение принятия
  Result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion+vbYesNo, 3124, Obj.Description)
  If Result = vbNo Then Exit Function

  Call SetRoles (Obj)
  'Смена статуса
  res = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,"STATUS_T_TASK_APPROVED") 
  
  If Res <0 Then
    Exit Function
  End If
  ThisApplication.Utility.WaitCursor = True
  ' Заполняется в плановой задаче
'  'Установка фактической даты выдачи Задания
  Call ThisApplication.ExecuteScript("CMD_DLL","SetAttr_F",Obj,"ATTR_ENDDATE_FACT",Obj.StatusModifyTime,True)
  
  'Оповещение 
  Call SendMessage(Obj)
  
  ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_KD_APROVER")
  ' отменяем остальные поручения на утверждение
'  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","RejectAllOrderByResol",Obj,"NODE_KD_APROVER")
  
  Call SendOrders(Obj)
  
  TaskAccept = True
  ThisApplication.Utility.WaitCursor = False
  If TaskAccept Then ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 3506, Obj.Description
End Function

'==============================================================================
' Отправка оповещения о возвращении задания в разработку всем разработчикам
' и соавторам
'------------------------------------------------------------------------------
' o_:TDMSObject - возвращенный в разработку документ
'==============================================================================
Sub SendMessage(o_)
  Set Rows = o_.Attributes("ATTR_T_TASK_TDEPTS_TBL").Rows
  Set Roles = o_.RolesByDef(ThisApplication.RoleDefs("ROLE_T_TASK_OUT_CHECKER"))
  Set CU = ThisApplication.CurrentUser
  
  'Оповещение пользователей
  'Ответственный за подготовку задания
  For Each Role in Roles
    If not Role.User is Nothing Then
      Set u = Role.User
    Else
      Set u = Role.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 3506, u, o_, Nothing, o_.Description, CU.Description, ThisApplication.CurrentTime
    Exit For
  Next
  'Отделы-адресаты
  For Each Row in Rows
    If Row.Attributes("ATTR_T_TASK_DEPT_PERSON").Empty = False Then
      If Row.Attributes("ATTR_T_TASK_DEPT_PERSON").User.SysName <> CU.SysName Then
        Set u = Row.Attributes("ATTR_T_TASK_DEPT_PERSON").User
        ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 3506, u, o_, Nothing, o_.Description, CU.Description, ThisApplication.CurrentTime
        resol = "NODE_CORR_REZOL_INF"
        txt = "Утверждено задание """ & o_.Description & """"
        ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",o_,"OBJECT_KD_ORDER_NOTICE",u,CU,resol,txt,""
      End If
    End If
  Next
End Sub

Sub SetRoles (o_)
  Set Users = ThisApplication.CreateCollection(tdmUsers)
  Set TableRows = o_.Attributes("ATTR_T_TASK_TDEPTS_TBL").Rows
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
' Отправка поручение на подписание задания
' подписанту 
'------------------------------------------------------------------------------
' Obj:TDMSObject - разработанное задание
'==============================================================================
Sub SendOrders(Obj)
  List = "ATTR_T_TASK_DEVELOPED,ATTR_RESPONSIBLE"
  arr = Split(List,",")
  
  For i = 0 To Ubound(arr)
    Set us = Obj.Attributes(arr(i)).User
    If Not us Is Nothing Then
      If i = 0 Then
        lst = us.Sysname
        Call SendOrder(Obj,us)
      Else
        If Instr(lst,us.Sysname) = 0 Then
          Call SendOrder(Obj,us)
          lst = lst & "#" & us.Sysname
        End If
      End If
    End If
  Next
  
  Set Disp = ThisApplication.ExecuteScript("CMD_DLL_ROLES","GetProjectDispatcher",Obj)
  If Not Disp Is Nothing Then
    Call SendOrder2(Obj,Disp)
  End If
End Sub


Sub SendOrder(Obj,uToUser)
  If Obj Is Nothing Or uToUser Is Nothing Then Exit Sub

  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_CORR_REZOL_INF"
  txt = "Утверждено задание """ & Obj.Description & """"
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,""
End Sub

Sub SendOrder2(Obj,uToUser)
  If Obj Is Nothing Or uToUser Is Nothing Then Exit Sub

  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_KD_EXECUTE"
  txt = "Задание " & Obj.Description & " выдано. Произведите корректировку графика проекта. Дата выдачи: " & Obj.StatusModifyTime
  planDate = DateAdd ("d", 1, Date)
  ' Изменени тип поручения по требованию Тюмени 17.01.2018
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,planDate
'  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
End Sub
