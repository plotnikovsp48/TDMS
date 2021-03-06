' Команда - Выполняется (Договор)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  ThisScript.SysAdminModeOn
  
  'flag = ThisApplication.ExecuteScript("CMD_DLL_CONTRACTS","IsSignedByContractor",Obj)
  'If Obj.StatusName <> "STATUS_CONTRACT_SIGNED" Or (Not flag = True) Then Exit Function
  If Obj.StatusName <> "STATUS_CONTRACT_SIGNED" Then Exit Function
'  'Запрос
'  Key = Msgbox("""" & Obj.Description & """ будет отмечен как Договор заключен. Продолжить?",vbQuestion+vbYesNo)
'  If Key = vbNo Then
'    Exit Function
'  End If
  
  'Маршрут
  StatusName = "STATUS_CONTRACT_COMPLETION"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  Call SendOrders(Obj)
  
  'Оповещение пользователей
  Call SendMesages(Obj)
  Main = True
End Function

Sub SendMesages(Obj)
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
  
  Set cls = Obj.attributes("ATTR_CONTRACT_CLASS").Classifier
  If cls.SysName = "NODE_CONTRACT_EXP" Then
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
          ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1533, u, Obj, Nothing, Obj.Description, ThisApplication.CurrentUser.Description, Date
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

Sub SendOrders(Obj)
  If Obj Is Nothing Then Exit Sub
  Set cls = Obj.attributes("ATTR_CONTRACT_CLASS").Classifier
  If cls Is Nothing Then Exit Sub
  If cls.SysName = "NODE_CONTRACT_EXP" Then
    ' Отправка оповещения руководителю группы закупочных процедур
    Set uToUser = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetChiefByID","ID_TENDER_IN_DEPT")
    Call SendOrder(Obj,uToUser)
  End If
End Sub
  
Sub SendOrder(Obj,uToUser)
  If uToUser Is Nothing or Obj Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_KD_NOTICE"
  txt = "Договор """ & Obj.Description & """ заключен"
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,""
End Sub