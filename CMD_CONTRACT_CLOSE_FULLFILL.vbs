' Команда - Договор исполнен
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  
  'Блок проверки
  Check = CheckContract(Obj)
  If Check = False Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1523
    Exit Sub
  End If
  
  'Запрос подтверждения
  Key = Msgbox ("Закрыть договор?",vbYesNo+vbQuestion)
  If Key = vbNo Then Exit Sub
  
  'Заполнение атрибутов
  Call AttrFill(Obj)
  
  'Маршрут
  StatusName = "STATUS_CONTRACT_CLOSED"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  'Оповещение пользователей
  Call MessageSend(Obj)
  
  ThisScript.SysAdminModeOff
End Sub

Sub MessageSend(Obj)
  Str = ""
  'ГИП проекта
  Set Query = ThisApplication.Queries("QUERY_PROJECTS_FOR_CONTRACT")
  Query.Parameter("CONTRACT") = Obj
  Set Objects = Query.Objects
  If Objects.Count <> 0 Then
    Set Project = Objects(0)
    Set Roles = Project.RolesByDef("ROLE_GIP")
    For Each Role in Roles
      If not Role.User is Nothing Then
        u = Role.User.SysName
      Else
        u = Role.Group.SysName
      End If
      If Str <> "" Then
        If InStr(Str,u) = 0 Then
          Str = Str & "," & u
        End If
      Else
        Str = u
      End If
    Next
  End If
  'Группа Управление договорами
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
  If Str <> "" Then
    Arr = Split(Str,",")
    Count = UBound(Arr)
    If Count >=0 Then
      For i = 0 to Count
        If ThisApplication.Users.Has(Arr(i)) Then
          Set u = ThisApplication.Users(Arr(i))
          ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1522, u, Obj, Nothing, Obj.Description, ThisApplication.CurrentUser.Description, Date
        End If
      Next
    End If
  End If
End Sub

'Процедура заполнения атрибутов
Sub AttrFill(Obj)
  If Obj.Attributes.Has("ATTR_CONTRACT_CLOSE_TYPE") Then
    Set Clf = ThisApplication.Classifiers("NODE_CONTRACT_CLOSE_TYPE").Classifiers.Find("NODE_CONTRACT_CLOSE_FULLFILL")
    If not Clf is Nothing Then Obj.Attributes("ATTR_CONTRACT_CLOSE_TYPE").Classifier = Clf
  End If
  If Obj.Attributes.Has("ATTR_ENDDATE_FACT") Then
    Obj.Attributes("ATTR_ENDDATE_FACT").Value = Date
  End If
End Sub

'Функция проверки состояния договора
Function CheckContract(Obj)
  CheckContract = True
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_CONTRACT_STAGE"
  q.AddCondition tdmQueryConditionStatus, "= 'STATUS_CONTRACT_STAGE_IN_WORK' OR = 'STATUS_CONTRACT_STAGE_DRAFT'"
  q.AddCondition tdmQueryConditionAttribute, Obj, "ATTR_CONTRACT"
  Set Objects = q.Objects
  If OBjects.Count <> 0 Then CheckContract = False
End Function



