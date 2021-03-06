' $Workfile: OBJECTDEF.SCRIPT.OBJECT_WORK_DOCS_SET.scr $ 
' $Date: 30.01.07 19:38 $ 
' $Revision: 1 $ 
' $Author: Oreshkin $ 
'
' Комплект
'------------------------------------------------------------------------------
' Авторское право c ЗАО <НАНОСОФТ>, 2008 г.

USE CMD_SS_SYSADMINMODE

Sub Object_BeforeCreate(Obj, p_, cn_)
  '  Проверяем выполнение входных условий
  Dim result
  result=Not StartCondCheck (Obj,p_)
  If result Then 
    cn_= result
    Exit Sub
  End If
   
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",p_,p_.Status,Obj,Obj.ObjectDef.InitialStatus)  
  Call SetStartAttrs(Obj, Parent) 
End Sub

Sub Object_BeforeErase(o_, cn_)
  Dim result1,result2
  result1 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckContent", o_)
  result2 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckReferencedBy", o_) 
  cn_=result1 Or result2
  Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", o_) 
End Sub
 

Sub Object_BeforeContentRemove(Obj, RemoveCollection, Cancel)
  Cancel = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckEraseFlag", RemoveCollection)
End Sub

Sub Object_Created(Obj, p_)
  Obj.Permissions = SysAdminPermissions 
  ' Добавление выборки на задания
  If Obj.Queries.Has("QUERY_T_TASK_IN_PROJ") = False Then
    Obj.Queries.AddCopy ThisApplication.Queries("QUERY_T_TASK_IN_PROJ") 
  End If
  ' создание плановой задачи
  Call ThisApplication.ExecuteScript("CMD_ADD_TO_PLATAN", "Main", Obj)
End Sub

'==============================================================================
' Проверка входных условий
'------------------------------------------------------------------------------
' o_:TDMSObject - Основной комплект
' p_:TDMSObject - Полный комплект
' StartCondCheck: Boolean   True - входные условия выполнены
'                           False - входные условия не выполнены
'==============================================================================
Private Function StartCondCheck(o_,p_)
  StartCondCheck = False
  ' Проверяем статус полного комплекта
  If p_.Status.SysName <> "STATUS_WORK_DOCS_FOR_BUILDING_IS_DEVELOPING" Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1265
    Exit Function
  End If
  ' Проверяем принадлежность пользователя к группе Ответственных проектировщиков
  If (Not ThisApplication.Groups("GROUP_LEAD_DEVELOPERS").Users.Has(ThisApplication.CurrentUser)) and (Not ThisApplication.Groups("GROUP_GIP").Users.Has(ThisApplication.CurrentUser)) Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1265
    Exit Function
  End If
  StartCondCheck = True
End Function

Sub Object_PropertiesDlgInit(Dialog, Obj, Forms)
  If Obj.Attributes.Has("ATTR_SUBCONTRACTOR_WORK") Then
    If Obj.Attributes("ATTR_SUBCONTRACTOR_WORK").Value = False Then
      If Dialog.InputForms.Has("FORM_SUBCONTRACTOR") Then
        Dialog.InputForms.Remove Dialog.InputForms("FORM_SUBCONTRACTOR")
      End If
    Else
      If Obj.Dictionary.Exists("FormActive") Then
        If Dialog.InputForms.Has("FORM_SUBCONTRACTOR") and Obj.Dictionary.Item("FormActive") = True Then
          Dialog.ActiveForm = Dialog.InputForms("FORM_SUBCONTRACTOR")
          Obj.Dictionary.Remove("FormActive")
        End If
      End If
    End If
  End If
  ' отмечаем все поручения по комплекту прочитанными
  'if obj.StatusName <> "STATUS_DOCUMENT_CREATED" And obj.StatusName <> "STATUS_DOC_IS_ADDED" then _
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","Set_OrdersReaded",Obj
  ' Закрываем информационные поручения 
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_CORR_REZOL_INF")
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_STAT_MAIN")
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_DEL_MAIN")
End Sub

Sub ContextMenu_BeforeShow(Commands, Obj, Cancel)
thisApplication.DebugPrint "ContextMenu_BeforeShow - 1 " & Time()
  If Obj.Attributes.Has("ATTR_SUBCONTRACTOR_WORK") Then
    If Obj.Attributes("ATTR_SUBCONTRACTOR_WORK").Value = False Then
      Commands.Remove ThisApplication.Commands("CMD_SECTION_CREATE")
      Commands.Remove ThisApplication.Commands("CMD_FOLDER_IMPORT")
    End If
  End If
  thisApplication.DebugPrint "ContextMenu_BeforeShow - 2 " & Time()
'   В зависимости от того найдена ли задача добавляются соответствующие команды
'   Учитывать в ПЛАТАН - Задача не найдена
  Dim cmd
  cmd = "CMD_ADD_TO_PLATAN"
  If ThisApplication.ExecuteScript(cmd, "EnableCommand", Obj) Then
    Commands.Add ThisApplication.Commands(cmd)
  End If
  thisApplication.DebugPrint "ContextMenu_BeforeShow - 3 " & Time()
End Sub

Sub Object_Modified(Obj)
  ThisApplication.DebugPrint "Object_Modified(Obj)"
  Call ThisApplication.ExecuteScript ("CMD_DLL","SetDescription",Obj)
  Call ThisApplication.ExecuteScript ("CMD_DLL_ORDERS", "SendOrderToResponsible",Obj)

  ' Обновляем плановую задачу
  Call ThisApplication.ExecuteScript("CMD_PLAN_TASK_LIB","UpdatePlanTask",Obj)
End Sub

Sub Object_StatusChanged(Obj, Status)
  If Status is Nothing Then Exit Sub
  ThisScript.SysAdminModeOn
  
  'Определение статуса после согласования
  StatusAfterAgreed = ""
  Set Rows = ThisApplication.Attributes("ATTR_AGREENENT_SETTINGS").Rows
  For Each Row in Rows
    If Row.Attributes("ATTR_KD_OBJ_TYPE").Value = Obj.ObjectDefName Then
      StatusAfterAgreed = Row.Attributes("ATTR_KD_FINISH_STATUS")
      Exit For
    End If
  Next
  'Отработка маршрутов для механизма согласования
  If Status.SysName = "STATUS_KD_AGREEMENT" or Status.SysName = StatusAfterAgreed Then
    If Obj.Dictionary.Exists("PrevStatusName") Then
      sName = Obj.Dictionary.Item("PrevStatusName")
      If ThisApplication.Statuses.Has(sName) Then
        Set PrevSt = ThisApplication.Statuses(sName)
        Call ThisApplication.ExecuteScript("CMD_ROUTER","RunNonStatusChange",Obj,PrevSt,Obj,Status.SysName) 
      End If
    End If
  End If
  
  ' Закрываем плановую задачу
  If Status.SysName = "STATUS_WORK_DOCS_SET_IS_APPROVED" or Status.SysName = "STATUS_S_INVALIDATED" Then
    Call ThisApplication.ExecuteScript("CMD_PLAN_TASK_LIB", "ClosePlanTask",Obj)
  End If
  
  If "STATUS_WORK_DOCS_SET_IS_APPROVED" <> Status.SysName Then
    Obj.Attributes("ATTR_READY_TO_SEND").Value = False
  End If
End Sub

Sub Object_StatusBeforeChange(Obj, Status, Cancel)
  ThisScript.SysAdminModeOn
  'Записываем текущий статус в словарь
  Obj.Dictionary.Item("PrevStatusName") = Obj.StatusName
End Sub



Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
  If OkBtnPressed = True Then
    Cancel = Not CheckBeforeClose(Obj)
    If Cancel Then Exit Sub
  Else
    If Obj.ReferencedBy.count > 0 Then
      'Obj.SaveChanges
      Cancel = Not CheckBeforeClose(Obj)
    End If
  End If 
End Sub

' Проверка перед отправкой на согласование
Function CheckBeforeClose(Obj)
  CheckBeforeClose = False
  str = CheckRequedFieldsBeforeClose(Obj)
  If str <> "" Then
    Msgbox "Не заполнены обязательные атрибуты: " & str,vbExclamation
    Exit Function
  End If
  CheckBeforeClose = True
End Function

' Функция проверки заполнения обязательных полей
Function CheckRequedFieldsBeforeClose(Obj)
  CheckRequedFieldsBeforeClose = ""
  str = ""
  'Требуется конкурентная закупка
  If Obj.Attributes.Has("ATTR_SUBCONTRACTOR_WORK") Then
      If Obj.Attributes("ATTR_SUBCONTRACTOR_WORK").Value = True Then
        If Obj.Attributes.Has("ATTR_TENDER_OUT_REQUIRED") = False Then
          If Obj.Attributes("ATTR_TENDER_OUT_REQUIRED").Value = False Then
            CheckRequedFieldsBeforeClose = "Требуется конкурентная закупка"
            str = str & chr(10) & "- " & CheckRequedFieldsBeforeClose
            'Exit Function
          End If
        End If
      End If
  End If
  'Шифр комплекта
  If Obj.Attributes("ATTR_WORK_DOCS_SET_CODE").Empty = True Then
    CheckRequedFieldsBeforeClose = "Шифр комплекта"
    str = str & chr(10) & "- " & CheckRequedFieldsBeforeClose
    'Exit Function
  End If
  'Марка комплекта
  If Obj.Attributes("ATTR_WORK_DOCS_SET_MARK").Empty = True Then
    CheckRequedFieldsBeforeClose = "Марка комплекта"
    str = str & chr(10) & "- " & CheckRequedFieldsBeforeClose
    'Exit Function
  End If
  'Ответственный
  If Obj.Attributes("ATTR_RESPONSIBLE").Empty = True Then
    CheckRequedFieldsBeforeClose = "Ответственный"
    str = str & chr(10) & "- " & CheckRequedFieldsBeforeClose
    'Exit Function
  End If
  'Наименование комплекта
  If Obj.Attributes("ATTR_WORK_DOCS_SET_NAME").Empty = True Then
    CheckRequedFieldsBeforeClose = "Наименование комплекта"
    str = str & chr(10) & "- " & CheckRequedFieldsBeforeClose
    'Exit Function
  End If
  CheckRequedFieldsBeforeClose = str
End Function


Sub SetStartAttrs(Obj,Parent)
  'Формируем обозначение
  If ThisApplication.ExecuteScript("CMD_S_NUMBERING", "WorkDocsSetCodeGenCheck",Obj) = True Then
    Obj.Attributes("ATTR_WORK_DOCS_SET_CODE") = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "WorkDocsSetCodeGen",Obj)
  End If    
 
  ' Заполняем ссылку на стадию
  If Obj.Attributes.Has("ATTR_STAGE") Then
    Set stage = ThisApplication.ExecuteScript("CMD_S_DLL","GetStage",Obj)
    If Not stage Is Nothing Then
      Obj.Attributes("ATTR_STAGE").Object= stage
    End If
  End If
  ' Заполняем отдел
  Call ThisApplication.ExecuteScript("CMD_DEVELOPER_APPOINT","SetDept",Obj,Obj.Attributes("ATTR_RESPONSIBLE").User)
End Sub

Sub Object_ContentAdded(Obj, AddCollection)
  If Obj.Objects.Count > 0 Then
    Call ThisApplication.ExecuteScript("OBJECT_P_TASK", "SetFactStart",Obj)
  End If
End Sub


