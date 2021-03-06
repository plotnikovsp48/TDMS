' Команда - Передать на утверждение
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "CMD_PROJECT_DOCS_LIBRARY"

Res = Main(ThisObject)

Function Main(Obj)
  Main = False
  
  'Проверка состояния
  Set Row = GetRowCheckList(Obj,"approve",Nothing,Nothing,Nothing)
  If Row is Nothing Then
    Msgbox "Укажите утверждающего",vbExclamation
    Exit Function
  End If
  If Obj.Status is Nothing Then Exit Function
  
  'Подтверждение
  result = Msgbox("Передать """& Obj.Description &""" на утверждение?",vbQuestion+vbYesNo) 
  If result = vbNo Then Exit Function
  
  Call Run(Obj)
  Main = True
  
  Call SendToApprove(Obj.Parent)
End Function

Sub Run(Obj)

  Set Row = GetRowCheckList(Obj,"approve",Nothing,Nothing,Nothing)
  If Row Is Nothing Then Exit Sub
  Set User = Row.Attributes("ATTR_USER").User
  If User Is Nothing Then Exit Sub
  
  'Изменение статуса
  StatusName = "STATUS_DOCUMENT_IS_APPROVING"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If

  Call SetApproveUser(Obj,User)
End Sub

Sub SendToApprove(Obj)
  ' проверяем, можно ли перевести комплект или том в состояние на утверждении
  Select Case Obj.ObjectDefName
    Case "OBJECT_VOLUME"
      'Scr = "CMD_VOLUME_TO_APPROVING"
      Scr = "CMD_SEND_TO_APPROVE"
      txt = "Все документы в составе тома переданы на утверждение. Передать на утверждение том "
    Case "OBJECT_WORK_DOCS_SET"
      Scr = "CMD_SEND_TO_APPROVE"
      txt = "Все документы в составе основного комплекта переданы на утверждение. " &_
            "Передать на утверждение комплект "
  End Select
  If Scr = "" Then Exit Sub
  ' Если все документы переданы на утверждение - предлагаем передать комплект или Том
  RetVal = ThisApplication.ExecuteScript(Scr,"GetStatusTransition2",Obj)
  If RetVal = 0 Then
    ans = msgbox(txt & """" & Obj.Description & """?",vbQuestion+vbYesNo)
    If ans <> vbYes Then Exit Sub
    ' переводим комплект в утвержденное состояние
    Call ThisApplication.ExecuteScript(Scr,"Run",Obj)
  End If 
End Sub

'Назначение утверждающего
Sub SetApproveUser(Obj,User)
  'Если найден следующий утверждающий, то меняем роль
  RoleName = "ROLE_DOCUMENT_APPROVE"
  Set Roles = Obj.RolesbyDef(RoleName)
  If Roles.Count <> 0 Then
    For Each Role in Roles
      Role.User = User
    Next
  Else
    Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,User)
  End If
  
  'Создание поручения
  Set CU = ThisApplication.CurrentUser
  resol = "NODE_KD_APROVER"
  ObjType = "OBJECT_KD_ORDER_SYS"
  txt = "Прошу утвердить документ """ & Obj.Description & """"
  planDate = DateAdd ("d", 1, Date) 'Date + 1
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,User,CU,resol,txt,PlanDate
  
  'Оповещение
  ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1005, User, Obj, Nothing, Obj.Description, CU.Description
End Sub


