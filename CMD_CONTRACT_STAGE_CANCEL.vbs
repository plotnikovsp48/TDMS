' Команда - Отмена работ по этапу (Этап)
'------------------------------------------------------------------------------
' Автор: Стромков С.А.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

USE "CMD_DLL_ROLES"

Call Main(ThisObject)

Sub Main(Obj)
  ' Проверка
  If Not CheckConditions(Obj) Then Exit Sub
  
  ' Подтверждение
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, 1269, Obj.ObjectDef.Description, Obj.Description)    
  If result <> vbYes Then
    Exit Sub
  End If  
  
  ' Основной блок
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,"STATUS_CONTRACT_STAGE_INVALIDATED")
  Call SendMessage(Obj)  
End Sub


'==============================================================================
' Проверка входных условий
'------------------------------------------------------------------------------
' o_:TDMSObject - Этап
' CheckConditions:Boolean True - входные условия выполнены
'                         False - входные условия не выполнены
'==============================================================================
Function CheckConditions (o_)
  CheckConditions = False
  ' Проверка завершенности работ этапа
  Set os = GetUnfinishedWorks(o_)
  If os.count > 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1518
    Exit Function
  End If  
  CheckConditions = True
End Function

'==============================================================================
' Получение коллекции незавершенных Разделов и Основных комплектов
'------------------------------------------------------------------------------
' o_:TDMSObject - Этап
' GetUnfinishedWorks:TDMSObjects - Коллекция незавершенных работ по этапу
'==============================================================================
Function GetUnfinishedWorks (o_)
  Set GetUnfinishedWorks = Nothing
  Dim q
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "'OBJECT_PROJECT_SECTION' Or 'OBJECT_WORK_DOCS_SET'"
  q.AddCondition tdmQueryConditionStatus, "<>'STATUS_PROJECT_SECTION_IS_APPROVED' and <> 'STATUS_WORK_DOCS_SET_IS_APPROVED' and  <> 'STATUS_S_INVALIDATED'"
  q.AddCondition tdmQueryConditionAttribute, o_, "ATTR_CONTRACT_STAGE"
  Set GetUnfinishedWorks = q.Objects
End Function

'==============================================================================
' Отправка оповещения об отмене работ по этапу координатору и куратору договора
'------------------------------------------------------------------------------
' o_:TDMSObject - Этап
'==============================================================================
Private Sub SendMessage(o_)
  Set contract = o_.Attributes("ATTR_CONTRACT").Object
  strTime = o_.Attributes("ATTR_ENDDATE_FACT")
  Set CU = ThisApplication.CurrentUser

  Dim u
  Set u = o_.Attributes("ATTR_CONTRACT").Object.Roles("ROLE_CONTRACT_RESPONSIBLE")
  ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1519, u, o_, Nothing, o_.Description, contract.Description, CU, strTime
  
  For Each r In o_.RolesByDef("ROLE_COORDINATOR_2")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1519, u, o_, Nothing, o_.Description, contract.Description, CU, strTime
  Next
End Sub

