' Команда - Аннулировать документ
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Res = Run(ThisObject)

Function Run(Obj)
  Run = False
  Obj.Permissions = SysAdminPermissions 
  'Проверка
  res = CheckStatusTransition(Obj)
  If res <> 0 Then Exit Function  
 
  'Запрос причины аннулирования
  result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину аннулирования документа:")
  If IsEmpty(result) Then
    Exit Function 
  ElseIf trim(result) = "" Then
    msgbox "Невозможно аннулировать документ не указав причину." & vbNewLine & _
        "Пожалуйста, введите причину аннулирования.", vbCritical, "Не задана причина аннулирования!"
    Exit Function
  End If  
  
'  result = ThisApplication.ExecuteScript("CMD_DIALOGS","EditDlg","Укажите причину аннулирования документа.","Причина:")
'  If result = Chr(1) Then Exit Function 
  
  ' Отметка об аннулировании
  Obj.Versions.Create "Аннулирован", result 
                    
  'Изменение статуса
  StatusName = "STATUS_DOCUMENT_INVALIDATED"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  Run = True
End Function

'==============================================================================
' Функция проверяет условие перехода по статусам
'------------------------------------------------------------------------------
' o_:TDMSObject - Системный идентификатор обрабатываемого ИО
' CheckStatusTransition:Integer - Результат проверки 
'       (0:Проверка успешна,№ - номер ошибки (сообщения))
'==============================================================================
Private Function CheckStatusTransition(o_)
  CheckStatusTransition = -1
  If o_.Parent is Nothing Then Exit Function
  ' Проверка статуса раздела
  Set p = o_.Parent
  If p.ObjectDefName = "OBJECT_PROJECT_SECTION" And p.StatusName <> "STATUS_PROJECT_SECTION_IS_DEVELOPING" Then
    CheckStatusTransition = 1174
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, CheckStatusTransition, o_.ObjectDef.Description,o_.Description    
    Exit Function
  End If
  If p.ObjectDefName = "OBJECT_PROJECT_SECTION_SUBSECTION" And p.StatusName <> "STATUS_PROJECT_SECTION_IS_DEVELOPING" Then
    CheckStatusTransition = 1175
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, CheckStatusTransition, o_.ObjectDef.Description,o_.Description    
    Exit Function
  End If
  If p.ObjectDefName = "OBJECT_WORK_DOCS_SET" And p.StatusName <> "STATUS_WORK_DOCS_SET_IS_DEVELOPING" Then
    CheckStatusTransition = 1176
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, CheckStatusTransition, o_.ObjectDef.Description,o_.Description    
    Exit Function
  End If  
  If p.ObjectDefName = "OBJECT_VOLUME" And p.StatusName <> "STATUS_VOLUME_IS_BUNDLING" Then
    CheckStatusTransition = 1190
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, CheckStatusTransition, o_.ObjectDef.Description,o_.Description    
    Exit Function
  End If  
  CheckStatusTransition = 0
End Function
