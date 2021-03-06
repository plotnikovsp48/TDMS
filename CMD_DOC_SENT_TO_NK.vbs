' Команда - Передать на нормоконтроль
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "CMD_SS_SYSADMINMODE"
USE "CMD_MESSAGE"

Run ThisObject

Function Run(Obj)
  ThisApplication.DebugPrint "Run "&time()
  Run = False
  
  ' Проверка объекта
  If Obj.Status is Nothing Then Exit Function
  
  Dim sam
  Set sam = New SysAdminMode
  
  Dim inspector
  Set inspector = ThisApplication.ExecuteScript("CMD_SS_LIB", "GetInspector", Obj)
  
  If inspector Is Nothing Then
    If vbNo = MsgBox("Нормоконтролер не задан. Отправить на нормоконтроль ?", _
      vbQuestion + vbYesNo) Then Exit Function
    
    ' only check, inspector has default status
    CreateInspectorIfEmpty Obj
    
    RouteDocObject Obj, "STATUS_DOCUMENT_IS_SENT_TO_NK"
    
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", _
      1502, ThisApplication.Groups("GROUP_NK"), Obj, Nothing, _
      Obj.ObjectDef.Description, Obj.Description, _
      ThisApplication.CurrentUser.Description, ThisApplication.CurrentTime
      
    Run = True: Exit Function
  End If
  
  
  'Подтверждение
  ans = Msgbox("Передать " & Obj.Description & " на Нормоконтроль?",vbYesNo+vbQuestion)
  If vbYes <> ans Then Exit Function
  
'  If vbNo = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", _
'    vbYesNo, 1272, Obj.Description) Then Exit Function

  'Изменение статуса
  RouteDocObject Obj, "STATUS_DOCUMENT_IS_TAKEN_NK"
  
  ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_KD_RETUN_USER")
  
  ThisApplication.ExecuteScript "CMD_SS_LIB", "SyncRoleToUser", _
    Obj, "ROLE_NK", inspector
    
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB", "CreateSystemOrder", _
    Obj, "OBJECT_KD_ORDER_SYS", inspector, ThisApplication.CurrentUser, _
    "NODE_CORR_INSPECTION", Obj.Description, _
    DateAdd("d", 1, DateValue(ThisApplication.CurrentTime))

  Dim insp
  Set insp = CreateInspectorIfEmpty(Obj)
  RouteInspectorObject insp
  Run = True
  
End Function

Private Function CreateInspectorIfEmpty(Obj)
  ThisApplication.DebugPrint "CreateInspectorIfEmpty "&time()
  Set CreateInspectorIfEmpty = Nothing
  Call ThisApplication.ExecuteScript("CMD_SS_LIB", "SaveLinkNK", Obj)
  Set CreateInspectorIfEmpty = _
    ThisApplication.ExecuteScript("CMD_SS_LIB", "GetInspectionObject", Obj)
  If CreateInspectorIfEmpty Is Nothing Then _
    Set CreateInspectorIfEmpty = _
      ThisApplication.ExecuteScript("CMD_SS_LIB", "CreateInspectionObject", Obj)
End Function

Private Sub RouteDocObject(Obj, Status)
  ThisApplication.DebugPrint "RouteDocObject "&time()
  Obj.Permissions = SysAdminPermissions
  If -1 = ThisApplication.ExecuteScript("CMD_ROUTER", "Run", _
    Obj, Obj.Status, Obj, Status) Then
    Obj.StatusName = Status
  End If
End Sub

Private Sub RouteInspectorObject(Obj)
  ThisApplication.DebugPrint "RouteInspectorObject "&time()
  Obj.Permissions = SysAdminPermissions
  Obj.StatusName = "STATUS_NK"
End Sub
