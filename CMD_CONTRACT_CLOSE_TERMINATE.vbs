' Команда - Расторгнуть (Договор)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  
 
    'Запрос причины
    result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину расторжения договора:")
    If IsEmpty(result) Then
      Exit Sub 
    ElseIf trim(result) = "" Then
      msgbox "Невозможно расторгнуть договор не указав причину." & vbNewLine & _
          "Пожалуйста, введите причину расторжения.", vbCritical, "Не задана причина расторжения!"
      Exit Sub
    End If
    
  
  ThisApplication.Utility.WaitCursor = True
  
  'Создание рабочей версии
  Obj.Versions.Create ,Result
  
  'Маршрут
  StatusName = "STATUS_CONTRACT_CLOSED"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  'Заполнение атрибутов
  Call AttrFill(Obj)
  
  'Оповещение пользователей
  Call SendMesages(Obj,Result)
  ThisApplication.Utility.WaitCursor = False
End Sub

'Процедура заполнения атрибутов
Sub AttrFill(Obj)
  If Obj.Attributes.Has("ATTR_CONTRACT_CLOSE_TYPE") Then
    Set Clf = ThisApplication.Classifiers("NODE_CONTRACT_CLOSE_TYPE").Classifiers.Find("NODE_CONTRACT_CLOSE_CANCEL")
    If not Clf is Nothing Then Obj.Attributes("ATTR_CONTRACT_CLOSE_TYPE").Classifier = Clf
  End If
  'If Obj.Attributes.Has("ATTR_ENDDATE_FACT") Then
  '  Obj.Attributes("ATTR_ENDDATE_FACT").Value = Date
  'End If
End Sub

Sub SendMesages(Obj,Result)
  Str = ""
  'Куратор договора
  Set Roles = Obj.RolesByDef("ROLE_CONTRACT_RESPONSIBLE")
  For Each Role in Roles
    If not Role.User is Nothing Then
      Set User = Role.User
    Else
      Set User = Role.Group
    End If
    If User.SysName <> ThisApplication.CurrentUser.SysName Then
      Str = User.SysName
    End If
  Next
  'ГИП проекта
  Set Query = ThisApplication.Queries("QUERY_PROJECTS_FOR_CONTRACT")
  Query.Parameter("CONTRACT") = Obj
  Set Objects = Query.Objects
  If Objects.Count <> 0 Then
    For Each Project in Objects
      Set Roles = Project.RolesByDef("ROLE_GIP")
      For Each Role in Roles
        If not Role.User is Nothing Then
          Set User = Role.User
        Else
          Set User = Role.Group
        End If
        If Str <> "" Then
          If InStr(Str,User.SysName) = 0 Then
            Str = Str & "," & User.SysName
          End If
        Else
          Str = User.SysName
        End If
      Next
    Next
  End If
  'группа Управление договорной
  If ThisApplication.Groups.Has("GROUP_CONTRACTS") Then
    For Each User in ThisApplication.Groups("GROUP_CONTRACTS").Users
      If Str <> "" Then
        If InStr(Str,User.SysName) = 0 Then
          Str = Str & "," & User.SysName
        End If
      Else
        Str = User.SysName
      End If
    Next
  End If
  'группа Управление тендерной документацией
  If ThisApplication.Groups.Has("GROUP_TENDER") Then
    For Each User in ThisApplication.Groups("GROUP_TENDER").Users
      If Str <> "" Then
        If InStr(Str,User.SysName) = 0 Then
          Str = Str & "," & User.SysName
        End If
      Else
        Str = User.SysName
      End If
    Next
  End If
  'группа Руководители отделов
  If ThisApplication.Groups.Has("GROUP_LEAD_DEPT") Then
    For Each User in ThisApplication.Groups("GROUP_LEAD_DEPT").Users
      If Str <> "" Then
        If InStr(Str,User.SysName) = 0 Then
          Str = Str & "," & User.SysName
        End If
      Else
        Str = User.SysName
      End If
    Next
  End If
  'Руководителю бухгалтерии
  If ThisApplication.ObjectDefs.Has("OBJECT_STRU_OBJ") Then
    For Each Child in ThisApplication.ObjectDefs("OBJECT_STRU_OBJ").Objects
      If Child.Attributes.Has("ATTR_NAME") and Child.Attributes.Has("ATTR_KD_CHIEF") Then
        If Child.Attributes("ATTR_NAME").Empty = False and Child.Attributes("ATTR_KD_CHIEF").Empty = False Then
          If StrComp(Child.Attributes("ATTR_NAME").Value, "Бухгалтерия", vbTextCompare) = 0 Then
            If not Child.Attributes("ATTR_KD_CHIEF").User is Nothing Then
              Set User = Child.Attributes("ATTR_KD_CHIEF").User
              If Str <> "" Then
                If InStr(Str,User.SysName) = 0 Then
                  Str = Str & "," & User.SysName
                End If
              Else
                Str = User.SysName
              End If
            End If
          End If
        End If
      End If
    Next
  End If
  'Руководителю ПЭО
  If ThisApplication.ObjectDefs.Has("OBJECT_STRU_OBJ") Then
    For Each Child in ThisApplication.ObjectDefs("OBJECT_STRU_OBJ").Objects
      If Child.Attributes.Has("ATTR_NAME") and Child.Attributes.Has("ATTR_KD_CHIEF") Then
        If Child.Attributes("ATTR_NAME").Empty = False and Child.Attributes("ATTR_KD_CHIEF").Empty = False Then
          If StrComp(Child.Attributes("ATTR_NAME").Value, "Планово-экономический отдел", vbTextCompare) = 0 Then
            If not Child.Attributes("ATTR_KD_CHIEF").User is Nothing Then
              Set User = Child.Attributes("ATTR_KD_CHIEF").User
              If Str <> "" Then
                If InStr(Str,User.SysName) = 0 Then
                  Str = Str & "," & User.SysName
                End If
              Else
                Str = User.SysName
              End If
            End If
          End If
        End If
      End If
    Next
  End If
  
  'Отправка оповещений
  If Str <> "" Then
    Arr = Split(Str,",")
    Count = UBound(Arr)
    If Count >=0 Then
      For i = 0 to Count
        If ThisApplication.Users.Has(Arr(i)) Then
          Set u = ThisApplication.Users(Arr(i))
          ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1534, u, Obj, Nothing, Obj.Description, Result, Date
        End If
      Next
    End If
  End If
End Sub

'Процедура заполнения строки пользователей для уведомления
Sub UserStackFill(Obj,RoleName,str)
  Set Roles = Obj.RolesByDef(RoleName)
  For Each Role in Roles
    If not Role.User is Nothing Then
      Set User = Role.User
    Else
      Set User = Role.Group
    End If
    If Str <> "" Then
      If InStr(Str,User.SysName) = 0 Then
        Str = Str & "," & User.SysName
      End If
    Else
      Str = User.SysName
    End If
  Next
End Sub

