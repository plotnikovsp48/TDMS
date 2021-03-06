' Автор: Стромков С.А.
'
' Передает Проект в архив
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

Dim o
Set o = ThisObject
Call Main(o)

Sub Main(o_)
  Dim result
  o_.Permissions = sysadminpermissions
  ' Проверка утверждения всех разделов, комплектов и томов в составе проекта
  result = CheckProject(o_)
  If Not result Then Exit Sub

  ' Подтверждение
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbYesNo, 1155, o_.Description)    
  If result <> vbYes Then
    Exit Sub
  End If    
  ' Смена статуса проекта, проектной структуры и проектных документов
  Call ChangeProjectStatus(o_)
  
  ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1159, o_.Description      
End Sub

'==============================================================================
' Функция проверяет условие перехода по статусам
'------------------------------------------------------------------------------
' o_:TDMSObject - Системный идентификатор проекта
' CheckProject:Boolean - Результат проверки 
'==============================================================================
Private Function CheckProject(o_)
  Dim result
  CheckProject = False
  ' Проверка наличия неутвержденных полных комплектов
  'result = Check_WORK_DOCS_fBuilding(o_)                             ' Полные коомплекты не утверждаем
  'If Not result Then Exit Function
  ' Проверка наличия неутвержденных основных комплектов
  result = Check_WORK_DOCS_SET(o_)
  If Not result Then Exit Function
  ' Проверка наличия неутвержденных разделов проектной документации
  result = Check_PROJECT_DOCS_SECTION(o_)
  If Not result Then Exit Function
  ' Проверка наличия неутвержденных томов
  result = Check_VOLUME(o_)
  If Not result Then Exit Function
  ' Проверка наличия документов в разработке
  result = Check_DOCUMENT(o_)
  If Not result Then Exit Function  
  ' Проверка наличия чертежей в разработке
  result = Check_DRAWING(o_)
  If Not result Then Exit Function
  CheckProject = True
End Function

' Проверка наличия неутвержденных полных комплектов
Private Function Check_WORK_DOCS_fBuilding(o_)
  Dim q
  Check_WORK_DOCS_fBuilding = False
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_WORK_DOCS_FOR_BUILDING"
  q.AddCondition tdmQueryConditionStatus, "<>'STATUS_WORK_DOCS_FOR_BUILDING_IS_APPROVED' and <> 'STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  If q.Objects.count > 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1252
    Exit Function
  End If  
  Check_WORK_DOCS_fBuilding = True
End Function

' Проверка наличия неутвержденных основных комплектов
Private Function Check_WORK_DOCS_SET(o_)
  Dim q
  Check_WORK_DOCS_SET = False
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_WORK_DOCS_SET"
  q.AddCondition tdmQueryConditionStatus, "<>'STATUS_WORK_DOCS_SET_IS_APPROVED' and <> 'STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  If q.Objects.count > 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1156
    Exit Function
  End If  
  Check_WORK_DOCS_SET = True
End Function

' Проверка наличия неутвержденных разделов проектной документации
Private Function Check_PROJECT_DOCS_SECTION(o_)
  Dim q
  Check_PROJECT_DOCS_SECTION = False
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_PROJECT_SECTION"
  q.AddCondition tdmQueryConditionStatus, "<>'STATUS_PROJECT_SECTION_IS_APPROVED' and <> 'STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  If q.Objects.count > 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1157
    Exit Function
  End If  
  Check_PROJECT_DOCS_SECTION = True
End Function

' Проверка наличия неутвержденных томов
Private Function Check_VOLUME(o_)
  Dim q
  Check_VOLUME = False
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_VOLUME"
  q.AddCondition tdmQueryConditionStatus, "<>'STATUS_VOLUME_IS_APPROVED' and <> 'STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  If q.Objects.count > 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1158
    Exit Function
  End If  
  Check_VOLUME = True
End Function

' Проверка наличия документов в разработке
Private Function Check_DOCUMENT(o_)
  Dim q
  Check_DOCUMENT = False
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_DOC_DEV"
  q.AddCondition tdmQueryConditionStatus, "<>'STATUS_ARH' and <> 'STATUS_DOCUMENT_FIXED' and  <> 'STATUS_DOCUMENT_DEVELOPED' and <> 'STATUS_DOCUMENT_INVALIDATED'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  If q.Objects.count > 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1166
    Exit Function
  End If  
  Check_DOCUMENT = True
End Function

' Проверка наличия чертежей в разработке
Private Function Check_DRAWING(o_)
  Dim q
  Check_DRAWING = False
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_DRAWING"
  q.AddCondition tdmQueryConditionStatus, "<>'STATUS_ARH' and <> 'STATUS_DOCUMENT_FIXED' and <> 'STATUS_DOCUMENT_DEVELOPED' and <> 'STATUS_DOCUMENT_INVALIDATED'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  If q.Objects.count > 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1251
    Exit Function
  End If  
  Check_DRAWING = True
End Function

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
  ' Смена статуса основных комплектов
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
' ' Смена статуса папок "Специальность"
' Call ChangeStatus_WORK_DOCS_FOR_SPECIALTY(o_)                             '++++++++++++++++++++++++++++++++++++++НЕТ ТАКОГО ОБЪЕКТА У НАС 
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
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o_,o.Status,o_,"STATUS_PROJECT_ARH")
End Sub

' Смена статуса разрабатываемых документов
Private Sub ChangeStatus_DOC_DEV(o_)
 Dim q,o
 Set q = ThisApplication.CreateQuery
 q.Permissions = sysadminpermissions
 q.AddCondition tdmQueryConditionObjectDef, "OBJECT_DOC_DEV"
 q.AddCondition tdmQueryConditionStatus,  "='STATUS_DOCUMENT_FIXED' or ='STATUS_DOC_IS_ADDED'"
 q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
 For Each o In q.Objects
     Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_ARH")
 Next
End Sub

  ' Смена статуса Чертежей
Private Sub ChangeStatus_DRAWING(o_)
  Dim q,o
  ' Утвержденные и добавленные
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_DRAWING"
  q.AddCondition tdmQueryConditionStatus, "='STATUS_DOCUMENT_FIXED' or ='STATUS_DOC_IS_ADDED'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_ARH")
  Next
End Sub

  ' Смена статуса документов исходных данных
Private Sub ChangeStatus_BOD_DOC(o_)
  Dim q,o
  ' Утвержденные и добавленные
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_BOD_DOC"
  q.AddCondition tdmQueryConditionStatus, "='STATUS_DOCUMENT_FIXED' or ='STATUS_DOC_IS_ADDED'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_ARH")
  Next
End Sub

  ' Смена статуса основного комплектов
Private Sub ChangeStatus_WORK_DOCS_SET(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_WORK_DOCS_SET"
  q.AddCondition tdmQueryConditionStatus, "='STATUS_WORK_DOCS_SET_IS_APPROVED'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_ARH")
  Next
End Sub

  ' Смена статуса подразделов проектной документации
Private Sub ChangeStatus_PROJECT_DOCS_SECTION_SUB(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_PROJECT_SECTION_SUBSECTION"
  q.AddCondition tdmQueryConditionStatus, "='STATUS_PROJECT_SECTION_IS_APPROVED'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_ARH")
  Next
End Sub

  ' Смена статуса разделов проектной документации
Private Sub ChangeStatus_PROJECT_DOCS_SECTION(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_PROJECT_SECTION"
  q.AddCondition tdmQueryConditionStatus, "='STATUS_PROJECT_SECTION_IS_APPROVED'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_ARH")
  Next
End Sub

  ' Смена статуса томов
Private Sub ChangeStatus_VOLUME(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_VOLUME"
  q.AddCondition tdmQueryConditionStatus, "='STATUS_VOLUME_IS_APPROVED'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_ARH")
  Next
End Sub

  ' Смена статуса полных комплектов
Private Sub ChangeStatus_WORK_DOCS_FOR_BUILDING(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_WORK_DOCS_FOR_BUILDING"
 ' q.AddCondition tdmQueryConditionStatus, "='STATUS_WORK_DOCS_FOR_BUILDING_IS_APPROVED'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_ARH")
  Next
End Sub

  ' Смена статуса папки "Проектная документация"
Private Sub ChangeStatus_PROJECT_DOCS_P(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_PROJECT_DOCS_P"
  'q.AddCondition tdmQueryConditionStatus, "='STATUS_VOLUME_IS_APPROVED'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_ARH")
  Next
End Sub
  
  ' Смена статуса папки "Рабочая документация"
Private Sub ChangeStatus_PROJECT_DOCS_W(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_PROJECT_DOCS_W"
  'q.AddCondition tdmQueryConditionStatus, "='STATUS_VOLUME_IS_APPROVED'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_ARH")
  Next
End Sub

  ' Смена статуса папки "Результаты инженерных изысканий"
Private Sub ChangeStatus_PROJECT_DOCS_I(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_PROJECT_DOCS_I"
  'q.AddCondition tdmQueryConditionStatus, "='STATUS_VOLUME_IS_APPROVED'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_ARH")
  Next
End Sub


' Смена статуса папки "Работа" 
Private Sub ChangeStatus_S_SURV(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_SURV"
  'q.AddCondition tdmQueryConditionStatus, "='STATUS_ARH'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_ARH")
  Next
End Sub

  ' Смена статуса папок "Специальность"
Private Sub ChangeStatus_WORK_DOCS_FOR_SPECIALTY(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_WORK_DOCS_FOR_SPECIALTY"
  'q.AddCondition tdmQueryConditionStatus, "='STATUS_VOLUME_IS_APPROVED'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_ARH")
  Next
End Sub


  ' Смена статуса папки исходных данных
Private Sub ChangeStatus_BOD(o_)
  Dim q,o
  ' Утвержденные и добавленные
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_BOD"
  'q.AddCondition tdmQueryConditionStatus, "='STATUS_DOCUMENT_FIXED' or ='STATUS_DOC_IS_ADDED'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_ARH")
  Next
End Sub
  
  ' Смена статуса папки "Документация передаваемая заказчику"
Private Sub ChangeStatus_DOCS_FOR_CUSTOMER(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  'q.AddCondition tdmQueryConditionObjectDef, "OBJECT_DOCS_FOR_CUSTOMER"
  'q.AddCondition tdmQueryConditionStatus, "='STATUS_VOLUME_IS_APPROVED'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_ARH")
  Next
End Sub

  ' Смена статуса Папок
Private Sub ChangeStatus_FOLDER(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_FOLDER"
  'q.AddCondition tdmQueryConditionStatus, "='STATUS_VOLUME_IS_APPROVED'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_ARH")
  Next
End Sub 

  
  ' Смена статуса Заданий
Private Sub ChangeStatus_TASK(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_T_TASK"
  q.AddCondition tdmQueryConditionStatus, "='STATUS_TASK_APPROVED'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_ARH")
  Next
End Sub 

  ' Смена статуса Комплексных заданий
Private Sub ChangeStatus_UTASK(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_UTASK"
  q.AddCondition tdmQueryConditionStatus, "='STATUS_TASK_APPROVED'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_ARH")
  Next
End Sub  

  ' Смена статуса Папки Заданий
Private Sub ChangeStatus_TASK_DIR(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_T_TASKS"
  'q.AddCondition tdmQueryConditionStatus, "='STATUS_VOLUME_IS_APPROVED'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_ARH")
  Next
End Sub 

  ' Смена статуса Папки Комплексных заданий
Private Sub ChangeStatus_UTASK_DIR(o_)
  Dim q,o
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_UTASK_DIR"
  'q.AddCondition tdmQueryConditionStatus, "='STATUS_VOLUME_IS_APPROVED'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_PROJECT"
  For Each o In q.Objects
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o,o.Status,o,"STATUS_ARH")
  Next
End Sub    
