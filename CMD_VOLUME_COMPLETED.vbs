' $Workfile: COMMAND.SCRIPT.CMD_VOLUME_COMPLETED.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Завершить комплектацию
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.


Dim o
Set o = ThisObject
Call Main(o)

Sub Main(o_)
  Dim result
  result = CheckStatusTransition(o_)
  If result <> 0 Then Exit Sub
  
  ' Подтверждение
  result = ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbYesNo, 1184, o_.Description)
  If result <> vbYes Then
    Exit Sub
  End If 
  
  ' Изменение статуса прилагаемых документов  
  For Each oDoc In o_.Objects.ObjectsByDef("OBJECT_DOCUMENT")
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOC_IS_ADDED",oDoc,"STATUS_DOC_IS_FIXED") 
  Next
  
'  If ThisApplication.Attributes("ATTR_VOLUME_NK_FLAG").Value = True Then
'    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o_,"STATUS_VOLUME_IS_BUNDLING",o_,"STATUS_VOLUME_IS_SENT_TO_NK")   
'  Else
'    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o_,"STATUS_VOLUME_IS_BUNDLING",o_,"STATUS_VOLUME_IS_APPROVING") 
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o_,"STATUS_VOLUME_IS_BUNDLING",o_,"STATUS_VOLUME_IS_APPROVED") 
       
'  End If
  
'  ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1132, o_.Description      
  
  '  Отправка оповещений
'  Call SendMessage(o_)
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
  ' Проверка статуса раздела
  For Each oSec In o_.Objects.ObjectsByDef("OBJECT_PROJECT_SECTION")
    If oSec.Status.SysName = "STATUS_PROJECT_SECTION_IS_DEVELOPING" Then
      CheckStatusTransition = 1108
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, CheckStatusTransition, o_.Description    
      Exit Function
    End If
  Next  
  CheckStatusTransition = 0
End Function

'==============================================================================
' Отправка оповещения группе нормоконтроллеров о поступлении комплекта на нормоконтроль
'------------------------------------------------------------------------------
' o_:TDMSObject - комплект на нормоконтроль
'==============================================================================
Private Sub SendMessage(o_)
  Dim u
  If ThisApplication.Attributes("ATTR_VOLUME_NK_FLAG").Value = True Then
    For Each r In o_.RolesByDef("ROLE_VOLUME_TAKE_FOR_NK")
      If Not r.User Is Nothing Then
        Set u = r.User
      End If
      If Not r.Group Is Nothing Then
        Set u = r.Group
      End If
      ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1502, u, o_, Nothing, o_.ObjectDef.Description, o_.Description, ThisApplication.CurrentUser.Description, ThisApplication.CurrentTime
    Next
  Else
    For Each r In o_.RolesByDef("ROLE_GIP")
      If Not r.User Is Nothing Then
        Set u = r.User
      End If
      If Not r.Group Is Nothing Then
        Set u = r.Group
      End If
      ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1503, u, o_, Nothing, o_.ObjectDef.Description, o_.Description, ThisApplication.CurrentUser.Description, ThisApplication.CurrentTime
    Next  
  End If
End Sub
