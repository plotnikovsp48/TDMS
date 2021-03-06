' Команда  - Опубликовать структуру
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  'Проверка выполнения
  Check = CheckObjects(Obj)
  If Check <> "" Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1180, Check
    Exit Sub
  End If
  
  ' Подтверждение
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion + vbYesNo, 1188, Obj.Description)   
  If result <> vbYes Then
    Exit Sub
  End If 

  ThisApplication.Utility.WaitCursor = True
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,"STATUS_STAGE_DEVELOPING") 
  
 
  'Уведомления
  Call MessagesSend(Obj)
  ThisApplication.Utility.WaitCursor = False
End Sub

'Функция проверки заполненности атрибута "Ответственный" в составе Стадии
Function CheckObjects(Obj)
  str = ""
  Count = 0
  For Each Child in Obj.ContentAll
    If Child.ObjectDefName = "OBJECT_WORK_DOCS_SET" or Child.ObjectDefName = "OBJECT_PROJECT_SECTION" or _
    Child.ObjectDefName = "OBJECT_PROJECT_SECTION_SUBSECTION" Then
      If Child.Attributes.Has("ATTR_RESPONSIBLE") Then
        If Child.Attributes("ATTR_RESPONSIBLE").Empty Then
          Count = Count + 1
          If Count <= 5 Then
            str = str & chr(10) & Child.Description
          End If
        End If
      End If
    End If
  Next
  If Count <= 5 Then
    CheckObjects = str
  Else
    CheckObjects = str & chr(10) & "и другие (всего " & Count & ")"
  End If
End Function

'Процедура отправки уведомлений
Sub MessagesSend(Obj)
  str = ""
  StageName = Obj.Attributes("ATTR_PROJECT_STAGE").Value
  ProjectName = ""
  If Obj.Attributes.Has("ATTR_PROJECT") Then
    If Obj.Attributes("ATTR_PROJECT").Empty = False Then
      If not Obj.Attributes("ATTR_PROJECT").Object is Nothing Then
        Set Project = Obj.Attributes("ATTR_PROJECT").Object
        ProjectName = Project.Attributes("ATTR_PROJECT_CODE")
        If Project.Attributes("ATTR_NAME_SHORT").Empty = False Then
          ProjectName = ProjectName & " - " & Project.Attributes("ATTR_NAME_SHORT").Value
        End If
      End If
    End If
  End If
  Set CurU = ThisApplication.CurrentUser
  
  'Составление списка пользователей - ответственных
  For Each Child in Obj.ContentAll
    If Child.ObjectDefName = "OBJECT_WORK_DOCS_SET" or Child.ObjectDefName = "OBJECT_PROJECT_SECTION" or _
    Child.ObjectDefName = "OBJECT_PROJECT_SECTION_SUBSECTION" Then
      
      Set Roles = Child.RolesByDef("ROLE_LEAD_DEVELOPER")
      If Roles.Count = 0 Then
        If Child.Attributes.Has("ATTR_RESPONSIBLE") Then
          If Child.Attributes("ATTR_RESPONSIBLE").Empty = False Then
            If not Child.Attributes("ATTR_RESPONSIBLE").User is Nothing Then
              Set u = Child.Attributes("ATTR_RESPONSIBLE").User
              Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Child,"ROLE_LEAD_DEVELOPER",u.SysName)
            End If
          End If
        End If
      End If
      
      Set Roles = Child.RolesByDef("ROLE_LEAD_DEVELOPER")
      If Roles.Count > 0 Then
        For Each Role in Roles
          Set user = Nothing
          Set user = Role.User
          If ThisApplication.Users.Has(user) Then
'          If not Role.User is Nothing Then
            Set u = User
          Else
'            Set user = Role.Group
'            If ThisApplication.Groups.Has(user) Then
'              Set u = User
'            End If
          End If
          If Not u Is Nothing Then
            If u.SysName <> CurU.SysName Then
              If str <> "" Then
                If InStr(str,u.SysName) = 0 Then
                  str = str & ";" & u.SysName
                End If
              Else
                str = str & u.SysName
              End If
            End If
          End If
          'Создание поручения
          resol = "NODE_COR_STAT_MAIN"
          Str1 = Child.ObjectDef.Description
          Str2 = Child.Description
          txt = ThisApplication.ExecuteScript("CMD_MESSAGE", "Message",1501,Str1,Str2,Date,"",0,msgType,False)
          ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Child,"OBJECT_KD_ORDER_SYS",u,CurU,resol,txt,""
          ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1501, u, Child, Nothing, Str1, Str2, CurU.Description, Date
        Next
      End If
    End If
  Next
  
  'Отправка уведомлений
  If str <> "" Then
    Arr = Split(str,";")
    For i = 0 to Ubound(Arr)
      Set u = Nothing
      If ThisApplication.Users.Has(Arr(i)) Then
        Set u = ThisApplication.Users(Arr(i))
      ElseIf ThisApplication.Groups.Has(Arr(i)) Then
        Set u = ThisApplication.Groups(Arr(i))
      End If
      If not u is Nothing Then
        ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1513, u, Obj, Nothing, StageName, ProjectName, CurU.Description, Date
      End If
    Next
  End If
  
End Sub

