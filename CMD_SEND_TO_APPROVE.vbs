' Автор: Стромков С.А.
'
' Передача на утверждение Основного комплекта
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016


Call Main(ThisObject)

Function Main(Obj)
  Main = False
  
  If Obj.ObjectDefName = "OBJECT_WORK_DOCS_SET" Then
    If ThisApplication.Attributes("ATTR_WORK_DOCS_SET_NK_FLAG").Value = True and Obj.StatusName<>"STATUS_WORK_DOCS_SET_IS_CHECKED_BY_NK" Then
'      msgbox "Основной комплект должен сначала пройти нормоконтроль!"
'      Exit Function
    End If
  ElseIf Obj.ObjectDefName = "OBJECT_VOLUME" Then
    If ThisApplication.Attributes("ATTR_VOLUME_NK_FLAG").Value = True and Obj.StatusName<>"STATUS_VOLUME_IS_CHECKED_BY_NK" Then
'      msgbox "Том должен сначала пройти нормоконтроль!"
'      Exit Function
    End If
  Else
    Exit Function
  End If
  
  Dim result
  result = CheckStatusTransition(Obj)
  If result <> 0 Then Exit Function 
    Exit Function
  ' Подтверждение
  result = ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbYesNo, 1214, Obj.Description)
  If result <> vbYes Then
    Exit Function
  End If 
  
  Call Run(Obj)
  Main = True
  '  Отправка сообщений и поручений
  Call SendMessage(Obj)
  Call SendOrder(Obj)
  ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1503, Obj.ObjectDef.Description,Obj.Description
End Function

Sub Run(Obj)
  Call ChangeDocsStatus(Obj)
  Call ChangeObjStatus(Obj)
'  'Статус, устанавливаемый в результате выполнения команды
'  Dim NextStatus
'  NextStatus ="STATUS_WORK_DOCS_SET_IS_APPROVING"
'  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,NextStatus)
'  If RetVal = -1 Then
'    Obj.Status = ThisApplication.Statuses(NextStatus)
'  End If
  
End Sub

'==============================================================================
' Отправка оповещения ГИПу
'------------------------------------------------------------------------------
' Obj:TDMSObject - комплект на утверждение
'==============================================================================
Private Sub SendMessage(Obj)
  Dim u
  For Each r In Obj.RolesByDef("ROLE_GIP")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1503, u, Obj, Nothing, Obj.ObjectDef.Description, Obj.Description, ThisApplication.CurrentUser.Description, ThisApplication.CurrentTime
  Next
End Sub


'==============================================================================
' Функция проверяет условие перехода по статусам
'------------------------------------------------------------------------------
' Obj:TDMSObject - Системный идентификатор обрабатываемого ИО
' CheckStatusTransition:Integer - Результат проверки 
'       (0:Проверка успешна,№ - номер ошибки (сообщения))
'==============================================================================
Public Function CheckStatusTransition(Obj)
  CheckStatusTransition = -1
  
    RetVal = GetStatusTransition(Obj)
  If RetVal > 0 Then
    Set Dict = ThisApplication.Dictionary(Obj.GUID)
    If Dict.Exists("DOC") Then
      Set oDoc = ThisApplication.GetObjectByGUID(Dict.Item("DOC"))
      'Dict.Remove("DOC")
    End If
    CheckStatusTransition = RetVal
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbCritical, CheckStatusTransition, oDoc.Description
    Exit Function
  ElseIf RetVal < 0 Then
    Exit Function
  End If
'  ' Проверка статуса документов в составе комплекта

'    For Each oDoc In Obj.Objects
'      If oDoc.ObjectDefName="OBJECT_DOC_DEV" or oDoc.ObjectDefName="OBJECT_DRAWING" Then
'        If oDoc.StatusName <> "STATUS_DOCUMENT_INVALIDATED" And oDoc.StatusName <> "STATUS_DOCUMENT_FIXED" And oDoc.StatusName <> "STATUS_DOCUMENT_IS_CHECKED_BY_NK" Then
'          CheckStatusTransition = 1224
'          ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbCritical, CheckStatusTransition, oDoc.Description
'          Exit Function
'        End If
'      End If
'    Next
  CheckStatusTransition = 0
End Function

Function GetStatusTransition(Obj)
ThisApplication.DebugPrint "GetStatusTransition "&time()
  GetStatusTransition = -1
  Select Case Obj.ObjectDefName
    Case "OBJECT_WORK_DOCS_SET"
      mes =1224
    Case "OBJECT_VOLUME"
      mes =1225
  End Select
  
  Set q = ThisApplication.Queries("QUERY_DOCS_BY_STATUS")
  q.Parameter("PARENT") = Obj
  q.Parameter("STATUS") = "<> 'STATUS_DOCUMENT_INVALIDATED' And <>'STATUS_DOCUMENT_FIXED' And <>'STATUS_DOCUMENT_IS_APPROVING' And " & _
          "<>'STATUS_DOCUMENT_IS_CHECKED_BY_NK' And <>'STATUS_ARH'"
  Set oCol = q.Objects
  If oCol.Count > 0 Then 
    GetStatusTransition = mes
    ThisApplication.DebugPrint "GetStatusTransition -end"&time()
    Exit Function
  End If
'  ' Проверка статуса документов в составе Тома
'    For Each oDoc In Obj.Objects
'      If oDoc.ObjectDefName="OBJECT_DOC_DEV" or oDoc.ObjectDefName="OBJECT_DRAWING" Then
'        If oDoc.StatusName <> "STATUS_DOCUMENT_INVALIDATED" _
'          And oDoc.StatusName <> "STATUS_DOCUMENT_FIXED" _
'          And oDoc.StatusName <> "STATUS_DOCUMENT_IS_CHECKED_BY_NK" _
'          And oDoc.StatusName <> "STATUS_DOCUMENT_IS_APPROVING"  Then
'          GetStatusTransition = mes
'          ThisApplication.Dictionary(Obj.Guid).Item("DOC") = oDoc.Guid
'          ThisApplication.DebugPrint "GetStatusTransition -end"&time()
'          Exit Function
'        End If
'      End If
'    Next
  GetStatusTransition = 0
End Function

Sub ChangeDocsStatus(Obj)
'  ' Изменение статуса прилагаемых документов  
'  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOCUMENT")
'    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOC_IS_ADDED",oDoc,"STATUS_DOC_IS_FIXED") 
'  Next
  
  ' Изменение статуса разрабатываемых документов
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOC_DEV")
    If oDoc.StatusName <> "STATUS_DOCUMENT_FIXED" And oDoc.StatusName <> "STATUS_DOCUMENT_IS_APPROVING" And oDoc.StatusName <> "STATUS_DOCUMENT_INVALIDATED" Then
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,oDoc.Status,oDoc,"STATUS_DOCUMENT_IS_APPROVING") 
    End If
  Next  
  ' Изменение статуса разрабатываемых чертежей  
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DRAWING")
    If oDoc.StatusName <> "STATUS_DOCUMENT_FIXED" And oDoc.StatusName <> "STATUS_DOCUMENT_IS_APPROVING" And oDoc.StatusName <> "STATUS_DOCUMENT_INVALIDATED" Then
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,oDoc.Status,oDoc,"STATUS_DOCUMENT_IS_APPROVING")  
    End If
  Next
End Sub
'==============================================================================
' Отправка поручения ГИПу
'------------------------------------------------------------------------------
' Obj:TDMSObject - Том на утверждение
'==============================================================================
Sub SendOrder(Obj)
  Set docObj = Obj
  objType = "OBJECT_KD_ORDER_SYS"
  Set userFrom = ThisApplication.CurrentUser
  Set usersTo = docObj.RolesByDef("ROLE_GIP")
  If usersTo Is Nothing Then Exit Sub
  If usersTo.count=0 Then Exit Sub
  Set userTo = usersTo(0).User
  If userTo Is Nothing Then Exit Sub
  
  resol = "NODE_KD_APROVER"
  txt = "Прошу утвердить документ " &  docObj.Description
  planDate = DateAdd ("d", 1, Date) 'Date + 1
  Set order = ThisApplication.ExecuteScript ("CMD_KD_ORDER_LIB", "CreateSystemOrder", docObj, objType, userTo, userFrom, resol, txt,planDate)
End Sub


Sub ChangeObjStatus(Obj)
  'Статус, устанавливаемый в результате выполнения команды
  Dim NextStatus
  Select Case Obj.ObjectDefName
    Case "OBJECT_WORK_DOCS_SET"
      NextStatus ="STATUS_WORK_DOCS_SET_IS_APPROVING"
    Case "OBJECT_VOLUME"
      NextStatus ="STATUS_VOLUME_IS_APPROVING"
  End Select
    
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,NextStatus)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(NextStatus)
  End If
End Sub

' Функция проверки возможности перевода тома и комплекта на утверждение
' В отличие от GetStatusTransition проверяет, 
' чтобы в составе не было документов, которые могут быть переданы на утверждение
' Используется в команде по передаче на утверждение пакета документов
Function GetStatusTransition2(Obj)
  GetStatusTransition2 = -1
  ' Проверка статуса документов в составе Тома
    For Each oDoc In Obj.Objects
      If oDoc.ObjectDefName="OBJECT_DOC_DEV" or oDoc.ObjectDefName="OBJECT_DRAWING" Then
        If oDoc.StatusName <> "STATUS_DOCUMENT_IS_CHECKED_BY_NK" _
          And oDoc.StatusName <> "STATUS_DOCUMENT_INVALIDATED" _
          And oDoc.StatusName <> "STATUS_DOCUMENT_FIXED" _
          And oDoc.StatusName <> "STATUS_DOCUMENT_IS_APPROVING" _
          And oDoc.StatusName <> "STATUS_ARH" Then
          GetStatusTransition2 = 1224
          ThisApplication.Dictionary(Obj.Guid).Item("DOC") = oDoc.Guid
          Exit Function
        End If
      End If
    Next
  GetStatusTransition2 = 0
End Function
