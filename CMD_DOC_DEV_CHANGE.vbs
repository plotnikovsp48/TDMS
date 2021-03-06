' $Workfile: COMMAND.SCRIPT.CMD_DOC_DEV_CHANGE.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Внести изменение в документ
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.


Call Main(ThisObject)

Sub Main(Obj)
  ' Проверка
  Dim result
'  result = CheckStatusTransition(Obj)
'  If result <> 0 Then Exit Sub  
'  ' Подтверждение
'  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbYesNo, 1122, Obj.Description)    
'  If result <> vbYes Then
'    Exit Sub
'  End If
    'Запрос причины
    result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину внесения изменения:")
    If IsEmpty(result) Then
      Exit Sub 
    ElseIf trim(result) = "" Then
      msgbox "Невозможно вернуть документ не указав причину." & vbNewLine & _
          "Пожалуйста, введите причину возврата.", vbCritical, "Не задана причина возврата!"
      Exit Sub
    End If     
        
    Set p = Obj.Parent
    If p.ObjectDefName = "OBJECT_VOLUME" Then
      NextStatus = "STATUS_VOLUME_IS_BUNDLING"
      Scr = "CMD_VOLUME_BACK_TO_COR"
    ElseIf p.ObjectDefName = "OBJECT_WORK_DOCS_SET" Then
      NextStatus = "STATUS_WORK_DOCS_SET_IS_DEVELOPING"
      Scr = "CMD_WORK_DOCS_SET_BACK_TO_COR"
    End If
    If p.StatusName <> NextStatus Then
      p.Permissions = SysAdminPermissions
      p.Versions.Create ,result
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",p,p.Status,p,NextStatus)
    End If      
    
    ' Создание версии
    Obj.Permissions = SysAdminPermissions
    Obj.Versions.Create ,result
    Call ThisApplication.ExecuteScript("CMD_DOC_BACK_TO_WORK", "Run",Obj)

    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1154, Obj.Description  
End Sub

'==============================================================================
' Функция проверяет условие перехода по статусам
'------------------------------------------------------------------------------
' Obj:TDMSObject - Системный идентификатор обрабатываемого ИО
' CheckStatusTransition:Integer - Результат проверки 
'       (0:Проверка успешна,№ - номер ошибки (сообщения))
'==============================================================================
Private Function CheckStatusTransition(Obj)
  Dim p
  CheckStatusTransition = -1
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
  If p.ObjectDefName = "OBJECT_WORK_DOCS_SET" And p.Status.SysName <> "STATUS_WORK_DOCS_SET_IS_DEVELOPING" Then
      CheckStatusTransition = 1162
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, CheckStatusTransition, Obj.Description    
      Exit Function
  End If  
  CheckStatusTransition = 0
End Function
