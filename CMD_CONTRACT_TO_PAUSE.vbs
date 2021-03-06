' Команда - Приостановить договор
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False

  ThisScript.SysAdminModeOn

    'Запрос причины
    result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину приостановки договора:")
    If IsEmpty(result) Then
      Exit Function 
    ElseIf trim(result) = "" Then
      msgbox "Невозможно приостановить договор не указав причину." & vbNewLine & _
          "Пожалуйста, введите причину приостановки.", vbCritical, "Не задана причина приостановки!"
      Exit Function
    End If
   
  ThisApplication.Utility.WaitCursor = True
  'Создание рабочей версии
  Obj.Versions.Create ,Result
  
  'Маршрут
  StatusName = "STATUS_CONTRACT_PAUSED"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  'Оповещение пользователя
  Set Query = ThisApplication.Queries("QUERY_PROJECTS_FOR_CONTRACT")
  Query.Parameter("CONTRACT") = Obj
  Set Objects = Query.Objects
  If Objects.Count <> 0 Then
    Set Project = Objects(0)
    Set Roles = Project.RolesByDef("ROLE_GIP")
    For Each Role in Roles
      If not Role.User is Nothing Then
        Set u = Role.User
      Else
        Set u = Role.Group
      End If
      ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1520, u, Obj, Nothing, Obj.Description, Result, ThisApplication.CurrentUser.Description, Date
    Next
  End If
  ThisScript.SysAdminModeOff
  Main = True
  Call SetProjectToPause(Obj)
  ThisApplication.Utility.WaitCursor = False
End Function

' Делаем пометку в связанных проектах о приостановке работ по проекту
Sub SetProjectToPause(Obj)
  If Obj Is Nothing Then exit Sub
  Set Progress = ThisApplication.Dialogs.ProgressDlg
  Progress.Start
  progress.SetLocalRanges 0,100
  
  progress.Position = 0
  
  Set osProj = Obj.ReferencedBy.ObjectsByDef("OBJECT_PROJECT")
  count = osProj.Count
  For each oProj In osProj
    oProj.Permissions = SysAdminpermissions
    Set pStatus = oProj.Status
    If Not pStatus Is Nothing Then
    Progress.Text = "Приостановка проекта: " & oProj.Attributes("ATTR_PROJECT_CODE")
    pStatusName = pStatus.Sysname
      If pStatusName = "STATUS_PROJECT_IS_DEVELOPING" Then
        
        oProj.Status = ThisApplication.Statuses("STATUS_PROJECT_PAUSED")
        Call SendOrder(oProj)
        progress.Position = 100/Count * (osProj.Index(oProj)+1)
      End If
    End If
  Next
  Progress.Stop
End Sub

Sub SendOrder(Obj)
msgbox "В разработке"
End Sub
