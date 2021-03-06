' $Workfile: COMMAND.SCRIPT.CMD_DOC_DEV_CHANGE.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Внести изменение в документ
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

USE CMD_SS_SYSADMINMODE
USE CMD_SS_TRANSACTION

Set dict = CreateObject("Scripting.Dictionary")
dict.Add "OBJECT_DOC_DEV",       "RouteDrawingOrDocDev"
dict.Add "OBJECT_DRAWING",       "RouteDrawingOrDocDev"
dict.Add "OBJECT_VOLUME",        "RouteVolume"
dict.Add "OBJECT_WORK_DOCS_SET", "RouteWorkDocSet"
Call Main(ThisObject, dict)

'Основная процедура
Sub Main(Obj, dict)
  If dict.Exists(Obj.ObjectDefName) Then
    If vbNo = MsgBox("Вернуть """ & Obj.Description & """ в разработку ?", vbQuestion + vbYesNo) Then
      Exit Sub
    End If
    Set sam = New SysAdminMode
    Set tr = New Transaction
    Execute dict(Obj.ObjectDefName) & " Obj "
    tr.Commit
    Exit Sub
  End If
    
  ' Проверка
  result = CheckStatusTransition(Obj)
  If result <> 0 Then Exit Sub  
  ' Подтверждение
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbYesNo, 1122, Obj.Description)    
  If result <> vbYes Then
    Exit Sub
  End If
  'Запрос причины
  result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину внесения изменений:")
  If IsEmpty(result) Then
    Exit Sub 
  ElseIf trim(result) = "" Then
    MsgBox "Невозможно вернуть документ не указав причину." & vbNewLine & _
      "Пожалуйста, введите причину возврата.", vbCritical, "Не задана причина возврата!"
    Exit Sub
  End If
                               
  ' Создание версии
  Obj.Versions.Create ,result
  ' Вернуть в начальный статус
  
  'Статус, устанавливаемый в результате выполнения команды
  NextStatus = Obj.ObjectDef.InitialStatus.SysName
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,NextStatus) 

  ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1154, Obj.Description  
End Sub

Private Sub IncrementChangeNum(obj)
  Set a = obj.Attributes("ATTR_CHANGE_NUM")
  If a.Empty Then a.Value = 1: Exit Sub
  a.Value = CLng(a.Value) + 1
End Sub

Private Sub CreateChangePermit(target, affected)
  ObjDefName = "OBJECT_CHANGE_PERMIT"
  Set ObjRoots = thisApplication.ExecuteScript("CMD_KD_FOLDER","GET_FOLDER","",thisApplication.ObjectDefs(ObjDefName))
  If  ObjRoots is Nothing Then  
    MsgBox "Не удалось создать папку", vbCritical, "Объект не был создан"
    Exit Sub
  End if
  ObjRoots.Permissions = SysAdminPermissions
  
  'Создаем объект
  Set newChange = ObjRoots.Objects.Create(ObjDefName)
  'Set newChange = ThisApplication.ObjectDefs("OBJECT_CHANGE_PERMIT").CreateObject()
  
  newChange.StatusName = "STATUS_CHANGE_PERMIT_CREATED"
  newChange.Permissions = SysAdminPermissions
  With newChange.Attributes
    .Item("ATTR_CHANGE_PERMIT_CHANGE_OBJ").Object = target
    .Item("ATTR_PROJECT").Object                  = target.Attributes("ATTR_PROJECT").Object
    .Item("ATTR_KD_ISSUEDATE").Value              = ThisApplication.CurrentTime
    .Item("ATTR_CHANGE_PERMIT_NUM").Value         = ThisApplication.ExecuteScript( _
      "CMD_S_NUMBERING", "GetNewId", "OBJECT_CHANGE_PERMIT", Empty)
    Set table = .Item("ATTR_CHANGE_PERMIT_DOCS")
  End With
  
  For i = LBound(affected) To UBound(affected)
    Set row = table.Rows.Create()
    With row.Attributes
      .Item("ATTR_DOC_REF").Object = affected(i)
      .Item("ATTR_USER").User      = ThisApplication.CurrentUser
      .Item("ATTR_DATA").Value     = ThisApplication.CurrentTime
    End With
  Next 
End Sub

Private Sub RouteDrawingOrDocDev(Obj)
  Set Parent = Obj.Parent
  
  If Parent Is Nothing Then
    Err.Raise vbObjectError, "CMD_INVOICE_SIGN.RouteDrawingOrDocDev", "Объект не входит в состав"
  End If
  
  If Obj.Permissions.Locked = True Then Obj.Unlock
  
  Obj.Versions.Create
  Parent.Versions.Create

  Obj.StatusName = "STATUS_DOCUMENT_CREATED"
  IncrementChangeNum Parent
  
  ' Очищаем таблицу проверки
  Call ThisApplication.ExecuteScript("CMD_PROJECT_DOCS_LIBRARY","ClearCheckList",Obj)
  
  If "OBJECT_VOLUME" = Parent.ObjectDefName Then
    parent.StatusName = "STATUS_VOLUME_IS_BUNDLING"
    Obj.Attributes("ATTR_CHANGE_NUM").Value = Parent.Attributes("ATTR_CHANGE_NUM").Value
  ElseIf "OBJECT_WORK_DOCS_SET" = Parent.ObjectDefName Then
    Parent.StatusName = "STATUS_WORK_DOCS_SET_IS_DEVELOPING"
    IncrementChangeNum Obj
  Else
    Err.Raise vbObjectError, "CMD_INVOICE_SIGN.RouteDrawingOrDocDev", _
      "Недопустимый тип объекта - " & Parent.ObjectDefName
  End If
  
  CreateChangePermit Parent, Array(Obj)  
End Sub

Private Function PickDocuments(collection)
  PickDocuments = Array()
  If collection.Count = 0 Then Exit Function
  
  Set dlg = ThisApplication.Dialogs.SelectObjectDlg
  dlg.SelectFromObjects = collection
  If Not dlg.Show() Then Exit Function
  If dlg.Objects.Count = 0 Then Exit Function
  
  'Dim a, o, i
  i = 0: a = Array()
  ReDim a(dlg.Objects.Count - 1)
  For Each o In dlg.Objects
    a(i) = o: i = i + 1
  Next
  PickDocuments = a
End Function

Private Sub RouteVolumeOrWorkDocSet(Obj, stName, expr)
  Children = PickDocuments(Obj.ContentAll.ObjectsByDef("OBJECT_DOC"))
  Obj.Versions.Create
  IncrementChangeNum Obj
  Obj.StatusName = stName
  If UBound(Children) < 0 Then Exit Sub
  
  For i = LBound(Children) To UBound(Children)
    Child = Children(i)
    Child.Versions.Create
    Execute expr
    Child.StatusName = "STATUS_DOCUMENT_CREATED"
    ' Очищаем таблицу проверки
    Call ThisApplication.ExecuteScript("CMD_PROJECT_DOCS_LIBRARY","ClearCheckList",Child)
    If Child.Permissions.Locked = True Then
      Child.Unlock
    End If
  Next

  CreateChangePermit Obj, children
End Sub

Private Sub RouteVolume(Obj)
  RouteVolumeOrWorkDocSet Obj, "STATUS_VOLUME_ON_CHANGE", _
    "child.Attributes(""ATTR_CHANGE_NUM"").Value = obj.Attributes(""ATTR_CHANGE_NUM"").Value"
End Sub

Private Sub RouteWorkDocSet(Obj)
  RouteVolumeOrWorkDocSet Obj, "STATUS_WORK_DOCS_SET_ON_CHANGE", "IncrementChangeNum child"
End Sub


'==============================================================================
' Функция проверяет условие перехода по статусам
'------------------------------------------------------------------------------
' o_:TDMSObject - Системный идентификатор обрабатываемого ИО
' CheckStatusTransition:Integer - Результат проверки 
'       (0:Проверка успешна,№ - номер ошибки (сообщения))
'==============================================================================
Private Function CheckStatusTransition(Obj)
  CheckStatusTransition = -1
  If Obj.Parent is Nothing Then Exit Function
  ' Проверка статуса раздела
  Set p = Obj.Parent
  If p.ObjectDefName = "OBJECT_PROJECT_SECTION" And p.Status.SysName <> "STATUS_PROJECT_SECTION_IS_DEVELOPING" Then
      CheckStatusTransition = 1163
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, CheckStatusTransition, Obj.Description    
      Exit Function
  End If
  If p.ObjectDefName = "OBJECT_PROJECT_SECTION_SUBSECTION" And p.Status.SysName <> "STATUS_PROJECT_SECTION_IS_DEVELOPING" Then
      CheckStatusTransition = 1173
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, CheckStatusTransition, Obj.Description    
      Exit Function
  End If
  If p.ObjectDefName = "OBJECT_WORK_DOCS_SET" And p.Status.SysName <> "STATUS_WORK_DOCS_SET_IS_DEVELOPING" And _
  p.Status.SysName <> "STATUS_WORK_DOCS_SET_ON_CHANGE" Then
      CheckStatusTransition = 1162
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, CheckStatusTransition, Obj.Description    
      Exit Function
  End If  
  CheckStatusTransition = 0
End Function
