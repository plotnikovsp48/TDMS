' $Workfile: COMMAND.SCRIPT.CMD_PROJECT_TO_WORK.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Вернуть проект в работу
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.


Dim o
Set o = ThisObject
Call Main(o)

Sub Main(o_)
  Dim result
  o_.Permissions = sysadminpermissions
 
  'Проверка возможности создать версию объекта
  if Not o_.ObjectDef.VersionsEnabled then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1256, o_.ObjectDef.Description  
  Else
  
    ' Подтверждение
    result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbYesNo, 1160, o_.Description)    
    If result <> vbYes Then
      Exit Sub
    End If  
    
    'Запрос причины
    result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину возврата проекта:")
    If IsEmpty(result) Then
      Exit Sub 
    ElseIf trim(result) = "" Then
      msgbox "Невозможно вернуть проект не указав причину." & vbNewLine & _
          "Пожалуйста, введите причину возврата.", vbCritical, "Не задана причина возврата!"
      Exit Sub
    End If      
                             
    ' Создание версии
    o_.Versions.Create ,result
  End If
  
  ' Смена статуса проекта, проектной структуры и проектных документов
  Call ChangeProjectStatus(o_)
  
  ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1161, o_.Description      
End Sub


' Смена статуса проекта, проектной структуры и проектных документов
Private Sub ChangeProjectStatus(o_)
  ' Смена статуса разрабатываемых документов
  Call ChangeStatus_DOC_DEV(o_)
  ' Смена статуса чертежей
  Call ChangeStatus_DRAWING(o_)
  ' Смена статуса документов исходных данных
  Call ChangeStatus_BOD_DOC(o_)
  ' Смена статуса папки исходных данных
  Call ChangeStatus_BOD(o_)
  ' Смена статуса комплектов
  Call ChangeStatus_WORK_DOCS_SET(o_)
  ' Смена статуса подразделов проектной документации
  Call ChangeStatus_PROJECT_DOCS_SECTION_SUB(o_)
  ' Смена статуса разделов проектной документации
  Call ChangeStatus_PROJECT_DOCS_SECTION(o_)
  ' Смена статуса томов
  Call ChangeStatus_VOLUME(o_)
  ' Смена статуса полных комплектов
  Call ChangeStatus_WORK_DOCS_FOR_BUILDING(o_)
  ' Смена статуса папки "Проектная документация"
  Call ChangeStatus_PROJECT_DOCS_P(o_)
  ' Смена статуса папки "Рабочая документация"
  Call ChangeStatus_PROJECT_DOCS_W(o_)
  ' Смена статуса папки "Результаты инженерных изысканий"
  Call ChangeStatus_PROJECT_DOCS_I(o_)
  ' Смена статуса папки "Работа"
  Call ChangeStatus_S_SURV(o_)
  '' Смена статуса папок "Специальность"
  'Call ChangeStatus_WORK_DOCS_FOR_SPECIALTY(o_)
  ' Смена статуса папки "Документация передаваемая заказчику"
  Call ChangeStatus_DOCS_FOR_CUSTOMER(o_) 
  ' Смена статуса Папок
  Call ChangeStatus_FOLDER(o_) 
  ' Смена статуса Заданий
  Call ChangeStatus_TASK(o_) 
  ' Смена статуса Комплексных заданий
  Call ChangeStatus_UTASK(o_) 
  ' Смена статуса Папки Заданий
  Call ChangeStatus_TASK_DIR(o_) 
  ' Смена статуса ПапкиКомплексных заданий
  Call ChangeStatus_UTASK_DIR(o_) 
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o_,o_.Status,o_,o_.ObjectDef.InitialStatus)
End Sub

' Смена статуса разрабатываемых документов
Private Sub ChangeStatus_DOC_DEV(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_DOC_DEV"
  q.AddCondition tdmQueryConditionStatus, "='STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_DOCUMENT_FIXED")
  Next
End Sub

  ' Смена статуса Чертежей
Private Sub ChangeStatus_DRAWING(o_)
  Dim q,o
  ' Утвержденные и добавленные
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_DRAWING"
  q.AddCondition tdmQueryConditionStatus, "='STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_DOCUMENT_FIXED")
  Next
End Sub

  ' Смена статуса документов исходных данных
Private Sub ChangeStatus_BOD_DOC(o_)
  Dim q,o
  ' Утвержденные и добавленные
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_BOD_DOC"
  q.AddCondition tdmQueryConditionStatus, "='STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_DOCUMENT_FIXED")
  Next
End Sub

' Смена статуса папки исходных данных
Private Sub ChangeStatus_BOD(o_)
  Dim q,o
  ' Утвержденные и добавленные
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_BOD"
  'q.AddCondition tdmQueryConditionStatus, "='STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,o.ObjectDef.InitialStatus)
  Next
End Sub

  ' Смена статуса комплектов
Private Sub ChangeStatus_WORK_DOCS_SET(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_WORK_DOCS_SET"
'   q.AddCondition tdmQueryConditionStatus, "='STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_WORK_DOCS_SET_IS_APPROVED")
  Next
End Sub

' Смена статуса подразделов проектной документации
Private Sub ChangeStatus_PROJECT_DOCS_SECTION_SUB(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_PROJECT_SECTION_SUBSECTION"
  'q.AddCondition tdmQueryConditionStatus, "='STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_PROJECT_SECTION_IS_APPROVED")
  Next
End Sub

  ' Смена статуса разделов проектной документации
Private Sub ChangeStatus_PROJECT_DOCS_SECTION(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_PROJECT_SECTION"
'   q.AddCondition tdmQueryConditionStatus, "='STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_PROJECT_SECTION_IS_APPROVED")
  Next
End Sub

  ' Смена статуса томов
Private Sub ChangeStatus_VOLUME(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_VOLUME"
'   q.AddCondition tdmQueryConditionStatus, "='STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_VOLUME_IS_APPROVED")
  Next
End Sub

  ' Смена статуса папок
Private Sub ChangeStatus_FOLDER(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_FOLDER"
'   q.AddCondition tdmQueryConditionStatus, "='STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,o.ObjectDef.InitialStatus)
  Next
End Sub

  ' Смена статуса полных комплектов
Private Sub ChangeStatus_WORK_DOCS_FOR_BUILDING(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_WORK_DOCS_FOR_BUILDING"
'   q.AddCondition tdmQueryConditionStatus, "='STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,o.ObjectDef.InitialStatus)
  Next
End Sub

  ' Смена статуса папки "Проектная документация"
Private Sub ChangeStatus_PROJECT_DOCS_P(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_PROJECT_DOCS_P"
'   q.AddCondition tdmQueryConditionStatus, "='STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,o.ObjectDef.InitialStatus)
  Next
End Sub
  
  ' Смена статуса папки "Рабочая документация"
Private Sub ChangeStatus_PROJECT_DOCS_W(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_PROJECT_DOCS_W"
'   q.AddCondition tdmQueryConditionStatus, "='STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,o.ObjectDef.InitialStatus)
  Next
End Sub

' Смена статуса папки "Рабочая документация"
Private Sub ChangeStatus_PROJECT_DOCS_I(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_PROJECT_DOCS_I"
'   q.AddCondition tdmQueryConditionStatus, "='STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,o.ObjectDef.InitialStatus)
  Next
End Sub
 
' Смена статуса папки "Работа" 
Private Sub ChangeStatus_S_SURV(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_SURV"
'   q.AddCondition tdmQueryConditionStatus, "='STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,o.ObjectDef.InitialStatus)
  Next
End Sub
  
'  ' Смена статуса папок "Специальность"
'Private Sub ChangeStatus_WORK_DOCS_FOR_SPECIALTY(o_)
'  Dim q,o
'  Set q = ThisApplication.CreateQuery
'  q.Permissions = sysadminpermissions
'  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_WORK_DOCS_FOR_SPECIALTY"
''   q.AddCondition tdmQueryConditionStatus, "='STATUS_ARH'"
'  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
'  For Each o In q.Objects
'      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,o.ObjectDef.InitialStatus)
'  Next
'End Sub
  
  ' Смена статуса папки "Документация передаваемая заказчику"
Private Sub ChangeStatus_DOCS_FOR_CUSTOMER(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  'q.AddCondition tdmQueryConditionObjectDef, "OBJECT_DOCS_FOR_CUSTOMER"
'   q.AddCondition tdmQueryConditionStatus, "='STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,o.ObjectDef.InitialStatus)
  Next
End Sub

' Смена статуса Заданий
Private Sub ChangeStatus_TASK(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_T_TASK"
  q.AddCondition tdmQueryConditionStatus, "='STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_TASK_APPROVED")
  Next
End Sub 

  ' Смена статуса Комплексных заданий
Private Sub ChangeStatus_UTASK(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_UTASK"
  q.AddCondition tdmQueryConditionStatus, "='STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_TASK_APPROVED")
  Next
End Sub   

  ' Смена статуса Папки Заданий
Private Sub ChangeStatus_TASK_DIR(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_T_TASKS"
'  q.AddCondition tdmQueryConditionStatus, "='STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,o.ObjectDef.InitialStatus)
  Next
End Sub 

  ' Смена статуса Папки Комплексных заданий
Private Sub ChangeStatus_UTASK_DIR(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_UTASK_DIR"
'  q.AddCondition tdmQueryConditionStatus, "='STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,o.ObjectDef.InitialStatus)
  Next
End Sub 
  
