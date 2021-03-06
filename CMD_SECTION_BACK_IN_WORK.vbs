' Автор: Стромков С.А.
'
' Создание разделов
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

'Статус, устанавливаемый в результате выполнения команды
Dim NextStatus
NextStatus ="STATUS_PROJECT_SECTION_IS_DEVELOPING"

Dim o
Set o = ThisObject
Call Main(o)

Sub Main(o_)
  Dim oDoc
  Dim result
  o_.Permissions = SysAdminPermissions
  
  result = CheckStatusTransition(o_)
  If result <> 0 Then Exit Sub  
  
'  ' Подтверждение
'  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbYesNo, 1116, o_.Description)    
'  If result <> vbYes Then
'    Exit Sub
'  End If  
  
    'Запрос причины
    result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину возврата раздела:")
    If IsEmpty(result) Then
      Exit Sub 
    ElseIf trim(result) = "" Then
      msgbox "Невозможно вернуть раздел не указав причину." & vbNewLine & _
          "Пожалуйста, введите причину возврата.", vbCritical, "Не задана причина возврата!"
      Exit Sub
    End If  
                              
  ' Создание версии
  o_.Versions.Create ,result
  
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o_,"STATUS_PROJECT_SECTION_IS_DEVELOPED",o_,NextStatus)  
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o_,"STATUS_PROJECT_SECTION_IS_APPROVED",o_,NextStatus) 
  
  ' Изменение статуса прилагаемых документов  
  For Each oSub In o_.Objects.ObjectsByDef("OBJECT_PROJECT_SECTION_SUBSECTION")
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oSub,"STATUS_PROJECT_SECTION_IS_APPROVED",oSub,"STATUS_PROJECT_SECTION_IS_DEVELOPING") 
    For Each oDoc In oSub.Objects.ObjectsByDef("OBJECT_DOC_DEV")
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOCUMENT_FIXED",oDoc,"STATUS_DOCUMENT_CREATED") 
    Next
    For Each oDoc In oSub.Objects.ObjectsByDef("OBJECT_DRAWING")
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOCUMENT_FIXED",oDoc,"STATUS_DOCUMENT_CREATED") 
    Next
    
    
    
    
    
  Next
  
  
  
  
  
  
  For Each oDoc In o_.Objects.ObjectsByDef("OBJECT_DOC_DEV")
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOCUMENT_FIXED",oDoc,"STATUS_DOCUMENT_CREATED") 
  Next
  For Each oDoc In o_.Objects.ObjectsByDef("OBJECT_DRAWING")
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOCUMENT_FIXED",oDoc,"STATUS_DOCUMENT_CREATED") 
  Next
  
 
  
   ' Отправка уведомления
   Call SendMessage (o_, result)
End Sub

'==============================================================================
' Функция проверяет условие перехода по статусам
'------------------------------------------------------------------------------
' o_:TDMSObject - Системный идентификатор обрабатываемого ИО
' CheckStatusTransition:Integer - Результат проверки 
'       (0:Проверка успешна,№ - номер ошибки (сообщения))
'==============================================================================
Private Function CheckStatusTransition(o_)
  Dim p
  CheckStatusTransition = -1
  ' Проверка статуса раздела
  For Each p In o_.Uplinks.ObjectsByDef("OBJECT_VOLUME")
    If p.ObjectDefName = "OBJECT_VOLUME" And p.Status.SysName <> "STATUS_VOLUME_IS_BUNDLING" Then
        CheckStatusTransition = 1109
        ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, CheckStatusTransition    
        Exit Function
    End If
  Next
  CheckStatusTransition = 0
End Function


'==============================================================================
' Отправка оповещения ответственному о возврате тома утверждающим
'------------------------------------------------------------------------------
' o_:TDMSObject - завизированный комплект
' str_:Коментарий версии Тома
'==============================================================================
Private Sub SendMessage(o_,str_)
  Dim u
  For Each r In o_.RolesByDef("ROLE_LEAD_DEVELOPER")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1506, u, o_, Nothing, o_.Description, ThisApplication.CurrentUser.Description, str_
  Next
End Sub
