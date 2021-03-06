' Автор: Стромков С.А.
'
' Создание разделов
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

USE "CMD_PROJECT_DOCS_LIBRARY"

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  Select Case Obj.ObjectDefName
    Case "OBJECT_VOLUME"
      Main = ThisApplication.ExecuteScript("CMD_VOLUME_PASS_NK","Main",Obj)
    Case "OBJECT_WORK_DOCS_SET"
      Main = ThisApplication.ExecuteScript("CMD_WORK_DOCS_SET_PASS_NK","Main",Obj)
    Case Else
      Main = DocumentApproveNK(Obj)
  End Select
End Function

Function DocumentApproveNK(Obj)
  DocumentApproveNK = False
  
  '  Подтверждение действия пользователя
  Dim result
  ans = ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbQuestion+VbYesNo, 1278,Obj.Description)
  If ans <> vbYes Then
    Exit Function
  End If 
  Set CU = ThisApplication.CurrentUser
  'Заполнение строки проверяющего
  Set Row = GetRowCheckList(Obj,"nk",CU,Nothing,Nothing)
  If not Row is Nothing Then
    Row.Attributes("ATTR_RESOLUTION").Classifier = ThisApplication.Classifiers.FindBySysId("NODE_ACCEPT")
    Row.Attributes("ATTR_DATA").Value = Date
  End If
  
  StatusName = "STATUS_DOCUMENT_IS_CHECKED_BY_NK"
  Res = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
    
  ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_CORR_INSPECTION")
'  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrders",Obj,"NODE_CORR_INSPECTION")
  
  Call SendOrder(Obj)
  Call SendMessage(Obj)
  DocumentApproveNK = True
End Function


'==============================================================================
' Отправка оповещения ответственному о визировании комплекта нормоконтролером
'------------------------------------------------------------------------------
' Obj:TDMSObject - завизированный комплект
'==============================================================================
Private Sub SendMessage(Obj)
  Dim u
  For Each r In Obj.RolesByDef("ROLE_DOC_DEVELOPER")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1543, u, Obj, Nothing, Obj.Description, ThisApplication.CurrentUser.Description, ThisApplication.CurrentTime
  Next
End Sub

'==============================================================================
' Отправка поручение на ознакомление о прохождении документом нормоконтроля
'------------------------------------------------------------------------------
' Obj:TDMSObject - документ
'==============================================================================
Private Sub SendOrder(Obj)
  Set uToUser = Obj.Attributes("ATTR_RESPONSIBLE").User
  If uToUser Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_CORR_REZOL_INF"
  txt = "Документ """ & Obj.Description & """ прошел нормоконтроль"
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,""
End Sub
