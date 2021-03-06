
'Статус, устанавливаемый в результате выполнения команды
Dim NextStatus
NextStatus ="STATUS_PROJECT_SECTION_IS_APPROVED"

Dim o
Set o = ThisObject
Call Main(o)

Sub Main(o_)
  Dim oDoc
  Dim result
  result = CheckStatusTransition(o_)
  If result <> 0 Then Exit Sub
  
  'If o_.Objects.Count = 0 Then 
  ' Exit Sub
  'End If
  
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o_,"STATUS_PROJECT_SECTION_IS_DEVELOPED",o_,NextStatus)  
  ' Изменение статуса подразделов
  For Each oDoc In o_.Objects.ObjectsByDef("OBJECT_PROJECT_SECTION_SUBSECTION")
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_PROJECT_SECTION_IS_DEVELOPED",oDoc,"STATUS_PROJECT_SECTION_IS_APPROVED") 
  Next
  ' Изменение статуса прилагаемых документов 
  For Each oDoc In o_.Objects.ObjectsByDef("OBJECT_DOC_DEV")
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOCUMENT_DEVELOPED",oDoc,"STATUS_DOCUMENT_FIXED") 
  Next
  For Each oDoc In o_.Objects.ObjectsByDef("OBJECT_DRAWING")
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOCUMENT_DEVELOPED",oDoc,"STATUS_DOCUMENT_FIXED") 
  Next
End Sub


'==============================================================================
' Функция проверяет условие перехода по статусам
'------------------------------------------------------------------------------
' o_:TDMSObject - Системный идентификатор обрабатываемого ИО
' CheckStatusTransition:Integer - Результат проверки 
'      (0:Проверка успешна,№ - номер ошибки (сообщения))
'==============================================================================
Private Function CheckStatusTransition(o_)
  CheckStatusTransition = -1
  ' Проверка статуса документов в составе комплекта
  For Each oDoc In o_.Objects.ObjectsByDef("OBJECT_PROJECT_SECTION_SUBSECTION")
      If oDoc.Status.SysName = "STATUS_PROJECT_SECTION_IS_DEVELOPING" Then
        CheckStatusTransition = 1257
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

