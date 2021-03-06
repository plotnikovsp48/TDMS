' $Workfile: COMMAND.SCRIPT.CMD_SECTION_COMPLETED.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Завершить разработку раздела
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.



Call Main(ThisObject)

Function Main(Obj)
  Main = False
  Dim oDoc, osDevDoc, osDrawing, osSections
  Dim result, count

  '  Проверяем наличие Чертежей, Проектных документов, Подразделов, Томов в составе,
  
  oDefNames = "OBJECT_DOC_DEV;OBJECT_DRAWING;OBJECT_PROJECT_SECTION_SUBSECTION;OBJECT_VOLUME"
  Dim Arr
  arr = Split(oDefNames,";")

  For Each ar In Arr
      Set os = Obj.Objects.ObjectsByDef(ar)
    count = count + os.count
  Next
  
  For i = 0 To Ubound(arr)
    Set os = Obj.Objects.ObjectsByDef(arr(i))
    count = count + os.count
  Next
  
  If Count = 0 Then 
    If Obj.ObjectDefName = "OBJECT_PROJECT_SECTION" Then 
      str=1027
    End If
    If Obj.ObjectDefName = "OBJECT_PROJECT_SECTION_SUBSECTION" Then 
      str=1028
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, str    
    Exit Function
  End If
  
  ' Проверяем возможность перехода по статусам
  result = CheckStatusTransition(Obj)
  If result <> 0 Then Exit Function
    
  ' Подтверждение
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, 1273, Obj.ObjectDef.Description, Obj.Description)    
  If result <> vbYes Then
    Exit Function
  End If  
  
  ' Изменение статуса прилагаемых документов  
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_PROJECT_SECTION_SUBSECTION")
    If oDoc.StatusName <> "STATUS_PROJECT_SECTION_FIXED" And oDoc.StatusName <> "STATUS_S_INVALIDATED" Then
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,oDoc.Status,oDoc,NextStatus) 
    End If
  Next
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOC_DEV")
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOCUMENT_DEVELOPED",oDoc,"STATUS_DOCUMENT_FIXED") 
  Next
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DRAWING")
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOCUMENT_DEVELOPED",oDoc,"STATUS_DOCUMENT_FIXED") 
  Next
  
  Call Run(Obj)
  Main = True
  
  ' Оповещение 
  Call SendMessage(Obj)
End Function

Sub Run(Obj)
  'Статус, устанавливаемый в результате выполнения команды
  Dim NextStatus
  NextStatus ="STATUS_PROJECT_SECTION_FIXED"
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,NextStatus)  
End Sub
'==============================================================================
' Отправка оповещения о возвращении документа в разработку всем ответственным проектировщикам
' и соавторам
'------------------------------------------------------------------------------
' o_:TDMSObject - возвращенный в разработку документ
'==============================================================================
Private Sub SendMessage(o_)
  Dim u
  Set u = o_.Attributes("ATTR_RESPONSIBLE").User
  If Not u Is Nothing Then 
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1511, u, o_, Nothing, o_.ObjectDef.Description,o_.Description, ThisApplication.CurrentUser.Description
  Else
    For Each r In o_.RolesByDef("ROLE_LEAD_DEVELOPER")
      If Not r.User Is Nothing Then
        Set u = r.User
      End If
      If Not r.Group Is Nothing Then
        Set u = r.Group
      End If
      ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1511, u, o_, Nothing, o_.ObjectDef.Description,o_.Description, ThisApplication.CurrentUser.Description
    Next
  End If
End Sub


'==============================================================================
' Функция проверяет условие перехода по статусам
'------------------------------------------------------------------------------
' o_:TDMSObject - Системный идентификатор обрабатываемого ИО
' CheckStatusTransition:Integer - Результат проверки 
'       (0:Проверка успешна,№ - номер ошибки (сообщения))
'==============================================================================
Private Function CheckStatusTransition(o_)
  CheckStatusTransition = -1
  ' Проверка статуса подразделов
  For Each oDoc In o_.Objects.ObjectsByDef("OBJECT_PROJECT_SECTION_SUBSECTION")
      If oDoc.StatusName = "STATUS_PROJECT_SECTION_IS_DEVELOPING" Then
        CheckStatusTransition = 1257
        ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, CheckStatusTransition, oDoc.Description    
        Exit Function
      End If
  Next
  
  ' Проверка статуса Томов
  For Each oDoc In o_.Objects.ObjectsByDef("OBJECT_VOLUME")
      If oDoc.StatusName <> "STATUS_VOLUME_IS_APPROVED" And oDoc.StatusName <> "STATUS_ARH" And oDoc.StatusName <> "STATUS_S_INVALIDATED" Then
        CheckStatusTransition = 1223
        ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, CheckStatusTransition, oDoc.Description    
        Exit Function
      End If
  Next
  
  For Each oDoc In o_.Objects
    If oDoc.ObjectDefName="OBJECT_DOC_DEV" or oDoc.ObjectDefName="OBJECT_DRAWING" Then
      If oDoc.Status.SysName = "STATUS_DOCUMENT_CREATED" Then
        CheckStatusTransition = 1105
        ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, CheckStatusTransition, oDoc.Description    
        Exit Function
      End If
    End If
  Next
  CheckStatusTransition = 0
End Function
