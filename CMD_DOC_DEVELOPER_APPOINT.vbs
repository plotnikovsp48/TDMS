' Автор: Стромков С.А.
'
' Назначение разработчика документа/Задания
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

USE "CMD_DLL_ROLES"

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  Dim NewUser
  Dim result
  
  ' Проверить принадлежность пользователя к руководителям групп
  result = CheckUserPermissions(Obj)
  If result <> 0 Then Exit Sub
  ' Проверить статус родительского обыекта
  result = CheckStatusTransition(Obj)
  If result <> 0 Then Exit Sub  
  ' Выбор пользователя
  Set CU = ThisApplication.CurrentUser
  ' Для Чертежей или Проектных документов разработчик назначается из числа сотрудников отдела
  ' Протокол Тюмени.
  If Obj.ObjectDefName = "OBJECT_DOC_DEV" or Obj.ObjectDefName = "OBJECT_DRAWING" Then
    Set dept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetDeptForUserByGroup",CU,"GROUP_LEAD_DEPT")
    Set users = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetAllUsersByDept",dept)
    If users Is Nothing Then
      msgbox "В отделе """ & dept.Description & """ нет сотрудников",vbExclamation,"Назначить разработчика"
      Exit Sub
    End If
    Set NewUser = ThisApplication.ExecuteScript("CMD_DIALOGS","SelectUserFromCollDlg",users)
  Else
    Set NewUser = ThisApplication.ExecuteScript("CMD_DIALOGS","SelectUsersDlg")
  End If
  If NewUser Is Nothing Or VarType(NewUser)<>9 Then Exit Sub
  
  ' по результатам показа в Тюмени 10.09.2017
'  ' Подтверждение выбора пользователя
'  result = ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbQuestion+VbYesNo, 1270,u.Description,Obj.ObjectDef.Description,Obj.Description)
'  If result <> vbYes Then
'    Exit Sub
'  End If 
  
  Select Case Obj.ObjectDefName
    Case "OBJECT_T_TASK"
      attrName = "ATTR_T_TASK_DEVELOPED"
    Case "OBJECT_DRAWING","OBJECT_DOC_DEV"
      attrName = "ATTR_RESPONSIBLE"
  End Select
  
  Set OldUser = Obj.Attributes(attrName).User
  If OldUser.handle = NewUser.Handle Then Exit Sub
  
  ' Заполнение атрибута
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetAttr" ,Obj,attrName, NewUser)
  
  Call ChangeResponsible(Obj,NewUser,OldUser)
    
  ' Назначение ролей
  Call SetRoles (Obj)
  
  ' Оповещение
  Call SendMessage(Obj)
End Sub




'==============================================================================
' Функция проверяет права пользователя на выполнение команды
'------------------------------------------------------------------------------
' o_:TDMSObject - Системный идентификатор обрабатываемого ИО
' CheckUserPermissions:Integer - Результат проверки 
'       (0:Проверка успешна,№ - номер ошибки (сообщения))
'==============================================================================
Private Function CheckUserPermissions(Obj)
  Dim p
  CheckUserPermissions = -1

  ' Проверка статуса раздела
  Set p = Obj.Parent

  If p.ObjectDefName = "OBJECT_WORK_DOCS_SET" or p.ObjectDefName = "OBJECT_VOLUME" Then
    Set dept = p.Attributes("ATTR_S_DEPARTMENT").Object
    Set us = ThisApplication.ExecuteScript ("CMD_STRU_OBJ_DLL", "GetGroupsChiefsByDept", dept)
    Set CU = ThisApplication.CurrentUser
    If us.Has(CU) = False Then
      CheckUserPermissions = 1124
      msgbox "Недостаточно прав на выполнение данного действия",vbCritical,"Назначить разработчика"
      Exit Function
    End If
  End If  
  CheckUserPermissions = 0
End Function


'==============================================================================
' Функция проверяет условие смены ответственного
'------------------------------------------------------------------------------
' o_:TDMSObject - Системный идентификатор обрабатываемого ИО
' CheckStatusTransition:Integer - Результат проверки 
'       (0:Проверка успешна,№ - номер ошибки (сообщения))
'==============================================================================
Private Function CheckStatusTransition(o_)
  Dim p
  CheckStatusTransition = -1
  ' Проверка статуса раздела
  Set p = o_.Parent
  If p.ObjectDefName = "OBJECT_PROJECT_SECTION" And p.Status.SysName <> "STATUS_PROJECT_SECTION_IS_DEVELOPING" Then
      CheckStatusTransition = 1123
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, CheckStatusTransition, o_.Description    
      Exit Function
  End If
  If p.ObjectDefName = "OBJECT_WORK_DOCS_SET" And p.Status.SysName <> "STATUS_WORK_DOCS_SET_IS_DEVELOPING" Then
      CheckStatusTransition = 1124
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, CheckStatusTransition, o_.Description    
      Exit Function
  End If  
  CheckStatusTransition = 0
End Function
'==============================================================================
' Отправка оповещения о назначении ответственного 
' ответственному за подготовку задания 
'------------------------------------------------------------------------------
' o_:TDMSObject - разработанное задание
'==============================================================================
Private Sub SendMessage(o_)
  Dim u
  Set cu = ThisApplication.CurrentUser
  For Each r In o_.RolesByDef("ROLE_DOC_DEVELOPER")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1501, u, o_, Nothing, _
        o_.ObjectDef.Description, o_.Description, CU.Description, ThisApplication.CurrentTime
  Next
  For Each r In o_.RolesByDef("ROLE_T_TASK_DEVELOPER")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    
    If Not u.Handle = cu.Handle Then
      ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 3501, u, o_, Nothing, _
          o_.Description, cu.Description
    End If
  Next
End Sub

' Установка ролей
Sub SetRoles (Obj)
  If Obj.ObjectDefName = "OBJECT_T_TASK" Then
    'Устанавливаем роль Разработчика и Ответственного в соответствии с формой
    Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole", Obj,"ATTR_T_TASK_DEVELOPED","ROLE_T_TASK_DEVELOPER")
    Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole", Obj,"ATTR_T_TASK_DEVELOPED","ROLE_INITIATOR")
  Else
    If Obj.Attributes.Has("ATTR_RESPONSIBLE") Then
      If Obj.Attributes("ATTR_RESPONSIBLE").Empty = False Then
        If Not Obj.Attributes("ATTR_RESPONSIBLE").User Is Nothing Then
          Select Case Obj.ObjectDefName
            Case "OBJECT_DOC_DEV", "OBJECT_DRAWING"
              ' Назначение на роль
              Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole", Obj,"ATTR_RESPONSIBLE","ROLE_DOC_DEV_CHANGE")
              Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole", Obj,"ATTR_RESPONSIBLE","ROLE_DOC_DEVELOPED")
              Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole", Obj,"ATTR_RESPONSIBLE","ROLE_DOC_BACK_TO_WORK")
              Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole", Obj,"ATTR_RESPONSIBLE","ROLE_DOC_DEVELOPER")
              Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole", Obj,"ATTR_RESPONSIBLE","ROLE_RESPONSIBLE")
              Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole", Obj,"ATTR_RESPONSIBLE","ROLE_STRUCT_DEVELOPER")
              Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole", Obj,"ATTR_RESPONSIBLE","ROLE_INITIATOR")
            Case "OBJECT_DOCUMENT"
              ' Назначение на роль
              Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole", Obj,"ATTR_RESPONSIBLE","ROLE_DOC_DEVELOPED")
              Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole", Obj,"ATTR_RESPONSIBLE","ROLE_DOCUMENT_DEVELOPER")
          End Select
        End If
      End If
    End If
  End If
End Sub


