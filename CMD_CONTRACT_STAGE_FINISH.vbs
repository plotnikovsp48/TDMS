
\
' Команда - Завершение работ по этапу (Этап)
'------------------------------------------------------------------------------
' Автор: Стромков С.А.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

USE "CMD_DLL_ROLES"

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  ' Проверка
  If Not CheckConditions(Obj) Then Exit Function
  
  ' Подтверждение
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, 1517, Obj.Description)    
  If result <> vbYes Then
    Exit Function
  End If  
  
  ' Основной блок
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,"STATUS_CONTRACT_STAGE_COMPLETION")
  Call SendMessage(Obj)  
  Main = True
End Function

' Проверка входных условий
Function CheckConditions (o_)
  CheckConditions = False
  ' Проверка завершенности работ этапа
  Set q = ThisApplication.Queries("QUERY_CONTRACT_STAGE_LINKS")
  q.Parameter("OBJ") = o_
  q.Parameter("STAT") = "<>'STATUS_VOLUME_IS_APPROVED' and <> 'STATUS_WORK_DOCS_SET_IS_APPROVED' and  <> 'STATUS_S_INVALIDATED' AND <> 'STATUS_ARH'"

  If q.Objects.count > 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1518, o_.Description
    Exit Function
  End If  
  CheckConditions = True
End Function

'==============================================================================
' Отправка оповещения о завершении работ по этапу координатору и куратору договора
'------------------------------------------------------------------------------
' o_:TDMSObject - Этап
'==============================================================================
Private Sub SendMessage(o_)
  Set contract = o_.Attributes("ATTR_CONTRACT").Object
  strTime = o_.Attributes("ATTR_ENDDATE_FACT")

  Set u = ThisApplication.ExecuteScript("CMD_DLL_CONTRACTS","GetContractCurator",o_)
  If Not u Is Nothing Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1516, u, o_, Nothing, o_.Description, contract.Description, strTime
  End If
  
  For Each r In o_.RolesByDef("ROLE_COORDINATOR_2")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1516, u, o_, Nothing, o_.Description, contract.Description, strTime
  Next
End Sub

