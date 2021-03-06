' $Workfile: CMD_WORK_DOCS_SET_COMPLETED $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Завершить разработку комплекта
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.
  
Dim o
Set o = ThisObject
Call Main(o)

Sub Main(o_)
  
  Dim result
  result = CheckStatusTransition(o_)
  If result <> 0 Then Exit Sub  
  
  'Статус, устанавливаемый в результате выполнения команды
  Dim NextStatus
  NextStatus ="STATUS_WORK_DOCS_SET_IS_CHECKING"
  
'  If ThisApplication.Attributes("ATTR_WORK_DOCS_SET_NK_FLAG").Value = True Then
'    NextStatus ="STATUS_WORK_DOCS_SET_IS_SENT_TO_NK"
'  Else
'    NextStatus ="STATUS_WORK_DOCS_SET_IS_CHECKING"
'  End If
  
  ' Изменение статуса прилагаемых документов  
'  For Each oDoc In o_.Objects.ObjectsByDef("OBJECT_DOCUMENT")
'    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOC_IS_ADDED",oDoc,"STATUS_DOC_IS_FIXED") 
'  Next  
  
  ' Подтверждение
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, 1267, o_.ObjectDef.Description, o_.Description)    
  If result <> vbYes Then
    Exit Sub
  End If    
  
  ' Чертежи
  For Each oDoc In o_.Objects.ObjectsByDef("OBJECT_DRAWING")
    If oDoc.StatusName = "STATUS_DOCUMENT_CREATED"
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOCUMENT_CREATED",oDoc,"STATUS_DOCUMENT_CHECK") 
    End If
  Next  
  
  ' Прилагаемые документы
  For Each oDoc In o_.Objects.ObjectsByDef("OBJECT_DOC_DEV")
    If oDoc.StatusName = "STATUS_DOCUMENT_CREATED"
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOCUMENT_CREATED",oDoc,"STATUS_DOCUMENT_CHECK") 
    End If
  Next  
  ' Комплект
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o_,"STATUS_WORK_DOCS_SET_IS_DEVELOPING",o_,NextStatus)
  
  ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1127, o_.Description    
End Sub

'==============================================================================
' Функция проверяет условие перехода по статусам
'------------------------------------------------------------------------------
' o_:TDMSObject - Системный идентификатор обрабатываемого ИО
' CheckStatusTransition:Integer - Результат проверки 
'       (0:Проверка успешна,№ - номер ошибки (сообщения))
'==============================================================================
Public Function CheckStatusTransition(o_)
  CheckStatusTransition = -1
  check = false
  Set cu = ThisApplication.CurrentUser
  ' Проверка статуса документов в составе комплекта
  If o_.Objects.Count > 0 Then
    For Each oDoc In o_.Objects
      If oDoc.ObjectDefName="OBJECT_DOC_DEV" or oDoc.ObjectDefName="OBJECT_DRAWING" Then
        If oDoc.StatusName = "STATUS_DOCUMENT_CREATED" Or oDoc.StatusName = "STATUS_DOCUMENT_CHECK" Then
          If oDoc.Files.Count = 0 Then
            ' Документ не содержит файлы
            CheckStatusTransition = 1019
            ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, CheckStatusTransition, oDoc.Description
            Exit Function
          End If
          If oDoc.Permissions.Locked = True Then
            If oDoc.Permissions.LockUser.Handle <> cu.Handle  Then
              CheckStatusTransition = 1121
              ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, CheckStatusTransition, o_.Description    
              Exit Function
            Else
              oDoc.UnlockCheckIn
            End If
            check = check Or True
          Else
            check = check Or True
    '      If oDoc.Status.SysName = "STATUS_DOCUMENT_CREATED" Then
    '        CheckStatusTransition = 1121
    '        ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, CheckStatusTransition, o_.Description    
    '        Exit Function
          End If
        Else
          check = check Or False
        End If
      End If
    Next
  Else
    ' нет докумментов в составе комплекта
    CheckStatusTransition = 1029
  End If
  
  If check = False Then
    CheckStatusTransition = 1019
  End If
  If CheckStatusTransition > 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbCritical, CheckStatusTransition, o_.Description    
    Exit Function
  End If
  CheckStatusTransition = 0
End Function
