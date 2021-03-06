' Автор: Стромков С.А.
'
' Создание разделов
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016


Call Main(ThisObject)

Sub Main(Obj)
      
  If Not ThisApplication.Attributes("ATTR_WORK_DOCS_SET_NK_FLAG").Value = True Then
    Call ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbInformation, 1274)
    Exit Sub
  End If
  
  ' Проверяем условия перехода по статусам
  Dim result
 
  result = CheckStatusTransition(Obj)
  
  If result <> 0 Then Exit Sub 
  
  '  Подтверждение отправки на Нормоконтроль
  result = ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbQuestion+VbYesNo, 1272,Obj.Description)
  If result <> vbYes Then
    Exit Sub
  End If 
 
  Call DocProcess(Obj)
  '   ' Изменение статуса разрабатываемых документов
'  For Each oDoc In Obj.Objects
'    oDoc.Permissions = SysAdminPermissions
'    If oDoc.StatusName = "STATUS_DOCUMENT_CREATED" Then
'      oDoc.Status = ThisApplication.Statuses("STATUS_DOCUMENT_IS_SENT_TO_NK")
'    End If
'  Next 

'  ' Изменение статуса прилагаемых документов  
'  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOCUMENT")
'    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOC_IS_ADDED",oDoc,"STATUS_DOC_IS_FIXED") 
'  Next
'  
'  ' Изменение статуса разрабатываемых документов
'  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOC_DEV")
'    If oDoc.StatusName = "STATUS_DOCUMENT_AGREED" Then
'      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,oDoc.Status,oDoc,"STATUS_DOCUMENT_IS_SENT_TO_NK") 
'    End If
'  Next
'  
'  ' Изменение статуса разрабатываемых чертежей  
'  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DRAWING")
'    If oDoc.StatusName = "STATUS_DOCUMENT_AGREED" Then
'      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,oDoc.Status,oDoc,"STATUS_DOCUMENT_IS_SENT_TO_NK")  
'    End If
'  Next
  
  
  'Статус, устанавливаемый в результате выполнения команды
  Dim NextStatus
  NextStatus ="STATUS_WORK_DOCS_SET_IS_SENT_TO_NK"
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,NextStatus)

  ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1502, Obj.ObjectDef.Description,Obj.Description    

  '  Отправка сообщений в группу Нормоконтролеров
  Call SendMessage(Obj)
End Sub

Sub DocProcess(Obj)
  ' Изменение статуса прилагаемых документов  
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOCUMENT")
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOC_IS_ADDED",oDoc,"STATUS_DOC_IS_FIXED") 
  Next
  
  ' Изменение статуса разрабатываемых документов
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOC_DEV")
    If oDoc.StatusName = "STATUS_DOCUMENT_AGREED" Then
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,oDoc.Status,oDoc,"STATUS_DOCUMENT_IS_SENT_TO_NK") 
    End If
  Next
  
  ' Изменение статуса разрабатываемых чертежей  
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DRAWING")
    If oDoc.StatusName = "STATUS_DOCUMENT_AGREED" Then
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,oDoc.Status,oDoc,"STATUS_DOCUMENT_IS_SENT_TO_NK")  
    End If
  Next
End Sub
'==============================================================================
' Отправка оповещения группе нормоконтроллеров о поступлении комплекта на нормоконтроль
'------------------------------------------------------------------------------
' Obj:TDMSObject - комплект на нормоконтроль
'==============================================================================
Private Sub SendMessage(Obj)
  Dim u
  If Obj.ObjectDefName = "OBJECT_VOLUME" Then rDefName = "ROLE_VOLUME_TAKE_FOR_NK"
  If Obj.ObjectDefName = "OBJECT_WORK_DOCS_SET" Then rDefName = "ROLE_WORK_DOCS_SET_TAKE_FOR_NK"
  For Each r In Obj.RolesByDef(rDefName)
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1502, u, Obj, Nothing, Obj.ObjectDef.Description, Obj.Description, ThisApplication.CurrentUser.Description, ThisApplication.CurrentTime
  Next
End Sub

Public Function CheckStatusTransition(Obj)
 ThisApplication.DebugPrint "CheckStatusTransition "&time()
  CheckStatusTransition = -1
  check = false
  Set cu = ThisApplication.CurrentUser
  
  If Obj.ObjectDefName = "OBJECT_VOLUME" Then CheckStatusTransition = 1108
  If Obj.ObjectDefName = "OBJECT_WORK_DOCS_SET" Then CheckStatusTransition = 1064
  ' Проверка статуса документов в составе Тома

 Set q = ThisApplication.Queries("QUERY_DOCS_BY_STATUS")
  Param2 = "<> 'STATUS_DOCUMENT_CREATED' And " &_
           "<> 'STATUS_DOCUMENT_DEVELOPED' And " &_
           "<> 'STATUS_DOCUMENT_INVALIDATED' And " &_
           "<> 'STATUS_DOCUMENT_FIXED' And " &_
           "<> 'STATUS_DOCUMENT_AGREED' And " &_
           "<> 'STATUS_DOCUMENT_IS_TAKEN_NK' And " &_
           "<> 'STATUS_DOCUMENT_IS_SENT_TO_NK'"
  q.Parameter("PARENT") = Obj
  q.Parameter("STATUS") = Param2
  Set oCol = q.Objects
  If oCol.Count > 0 Then 
  ThisApplication.DebugPrint "ShowWarning "&time()
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbCritical, CheckStatusTransition
    Exit Function
  End If


'    For Each oDoc In Obj.Objects
'      If oDoc.ObjectDefName="OBJECT_DOC_DEV" or oDoc.ObjectDefName="OBJECT_DRAWING" Then
'        If oDoc.StatusName <> "STATUS_DOCUMENT_CREATED" And _
'           oDoc.StatusName <> "STATUS_DOCUMENT_DEVELOPED" And   _
'           oDoc.StatusName <> "STATUS_DOCUMENT_INVALIDATED" And _
'           oDoc.StatusName <> "STATUS_DOCUMENT_FIXED" And _
'           oDoc.StatusName <> "STATUS_DOCUMENT_AGREED" And _
'           oDoc.StatusName <> "STATUS_DOCUMENT_IS_SENT_TO_NK" Then
'           
''        If oDoc.StatusName <> "STATUS_DOCUMENT_INVALIDATED" And _
''           oDoc.StatusName <> "STATUS_DOCUMENT_FIXED" And _
''           oDoc.StatusName <> "STATUS_DOCUMENT_AGREED" And _
''           oDoc.StatusName <> "STATUS_DOCUMENT_IS_SENT_TO_NK" Then
'ThisApplication.DebugPrint "ShowWarning "&time()
'          ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbCritical, CheckStatusTransition, oDoc.Description
'          Exit Function
'        End If
'      End If
'    Next
  CheckStatusTransition = 0
End Function
