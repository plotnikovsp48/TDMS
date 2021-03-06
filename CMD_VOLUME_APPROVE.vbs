' $Author: Стромков $ 
'
' Утвердить том/комплект
'------------------------------------------------------------------------------
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  '  Проверяем выполнение входных условий
  Dim result
  retval = CheckStatusTransition(Obj)
  If retval >0 Then
    Call ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbYesNo, retval, Obj.Description) 
    Exit Function
  End If

  ' Подтверждение
  If Obj.ObjectDefName = "OBJECT_VOLUME" Then
    mes = 1142
    txt = Obj.Attributes("ATTR_VOLUME_CODE").Value
  ElseIf Obj.ObjectDefName = "OBJECT_WORK_DOCS_SET" Then
    mes = 1144
    txt = Obj.Attributes("ATTR_WORK_DOCS_SET_CODE").Value
  End If
  
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbYesNo, mes, txt)    
  If result <> vbYes Then
    Exit Function
  End If
  ThisApplication.Utility.WaitCursor = True
  Call Run(Obj)
  Main = True
  ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_KD_APROVER")
'  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrders",Obj,"NODE_KD_APROVER")
  ' рассылка оповещения ответственным
  Call SendMessage(Obj)
  Call SendOrder(Obj)
  ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1504, Obj.ObjectDef.Description,Obj.Description
  If Obj.ObjectDefName = "OBJECT_VOLUME" Then
    ' Пытаемся завершить раздел
    Call CheckSectionCompleted(Obj)
  End If
  ThisApplication.Utility.WaitCursor = False
End Function

Sub Run(Obj)
  
  Call DocsStatusChange(Obj)
  Call ObjStatusChange(Obj)
  
End Sub

Sub DocsStatusChange(Obj)
'  ' Изменение статуса прилагаемых документов  
'  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOCUMENT")
'    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOC_IS_FIXED",oDoc,"STATUS_DOCUMENT_FIXED") 
'  Next
  ' Изменение статуса разрабатываемых документов
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOC_DEV")
    If oDoc.StatusName <> "STATUS_DOCUMENT_FIXED" And _
        oDoc.StatusName <> "STATUS_DOCUMENT_INVALIDATED" And _
          oDoc.StatusName <> "STATUS_ARH" Then
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,oDoc.Status,oDoc,"STATUS_DOCUMENT_FIXED") 
    End If
  Next  
  ' Изменение статуса разрабатываемых чертежей  
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DRAWING")
    If oDoc.StatusName <> "STATUS_DOCUMENT_FIXED" And _
        oDoc.StatusName <> "STATUS_DOCUMENT_INVALIDATED" And _
          oDoc.StatusName <> "STATUS_ARH" Then
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,oDoc.Status,oDoc,"STATUS_DOCUMENT_FIXED")  
    End If
  Next
End Sub

Sub ObjStatusChange(Obj)
  'Статус, устанавливаемый в результате выполнения команды
  Dim NextStatus
  If Obj.ObjectDefName = "OBJECT_VOLUME" Then
    NextStatus ="STATUS_VOLUME_IS_APPROVED"
  ElseIf Obj.ObjectDefName = "OBJECT_WORK_DOCS_SET" Then
    NextStatus ="STATUS_WORK_DOCS_SET_IS_APPROVED"
  End If
' Изменение статуса Комплекта/Тома
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,NextStatus)
End Sub
'==============================================================================
' ' Отправка оповещения ответственному об утверждении Тома/комплекта
'------------------------------------------------------------------------------
' Obj:TDMSObject - утвержденный Том/комплект
'==============================================================================
Private Sub SendMessage(Obj)
  Dim u
  If Obj.ObjectDefName = "OBJECT_VOLUME" Then
    role = "ROLE_VOLUME_COMPOSER"
  ElseIf Obj.ObjectDefName = "OBJECT_WORK_DOCS_SET" Then
    role = "ROLE_LEAD_DEVELOPER"
  End If
  
  For Each r In Obj.RolesByDef(role)
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1504, u, Obj, Nothing, Obj.ObjectDef.Description,Obj.Description, ThisApplication.CurrentUser.Description, ThisApplication.CurrentTime
  Next
  ' Отправка оповещения в группу комплектации и выпуска документации
  Set u = ThisApplication.Groups("GROUP_COMPL")
  ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1544, u, Obj, Nothing, Obj.Description, ThisApplication.CurrentUser.Description, ThisApplication.CurrentTime
End Sub

'==============================================================================
' Проверка входных условий
'------------------------------------------------------------------------------
' Obj:TDMSObject - Том/Основной комплект
' StartCondCheck: Boolean   True - входные условия выполнены
'                           False - входные условия не выполнены
'==============================================================================
Private Function CheckStatusTransition(Obj)
thisApplication.DebugPrint "SCheckStatusTransition" & Time()
  CheckStatusTransition = -1
  
  If Obj.ObjectDefName = "OBJECT_VOLUME" Then
    mes = 1283
  ElseIf Obj.ObjectDefName = "OBJECT_WORK_DOCS_SET" Then
    mes = 1282
  Else
    Exit Function
  End If
  Set q = ThisApplication.Queries("QUERY_DOCS_BY_STATUS")
  q.Parameter("PARENT") = Obj.Handle
  q.Parameter("STATUS") = "<>'STATUS_DOCUMENT_FIXED' And <>'STATUS_DOCUMENT_IS_APPROVING' And " & _
          "<>'STATUS_DOCUMENT_INVALIDATED' And <>'STATUS_ARH'"
  Set oCol = q.Objects
  If oCol.Count > 0 Then 
  thisApplication.DebugPrint oCol.Count
    CheckStatusTransition = mes
    Exit Function
  End If
  
''   Проверка состояния документов в составе Тома
'  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOC_DEV")
'    If oDoc.StatusName <> "STATUS_DOCUMENT_FIXED" And _
'        oDoc.StatusName <> "STATUS_DOCUMENT_IS_APPROVING" And _
'          oDoc.StatusName <> "STATUS_DOCUMENT_INVALIDATED" And _
'            oDoc.StatusName <> "STATUS_ARH" Then 
'      CheckStatusTransition = mes
'      Exit Function
'    End If
'  Next  
'  ' Проверка состояния чертежей в составе Тома
'  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DRAWING")
'    If oDoc.StatusName <> "STATUS_DOCUMENT_FIXED" And _
'        oDoc.StatusName <> "STATUS_DOCUMENT_IS_APPROVING" And _
'          oDoc.StatusName <> "STATUS_DOCUMENT_INVALIDATED" And _
'            oDoc.StatusName <> "STATUS_ARH" Then
'      CheckStatusTransition = mes
'      Exit Function 
'    End If
'  Next
  CheckStatusTransition = 0
  thisApplication.DebugPrint "ECheckStatusTransition" & Time()
End Function

Sub SendOrder(Obj)
  Set uToUser = Obj.Attributes("ATTR_RESPONSIBLE").User
  If uToUser Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_CORR_REZOL_INF"
  
  If Obj.ObjectDefName = "OBJECT_VOLUME" Then
    txt = "Том утвержден: """ & Obj.Description & """"
  ElseIf Obj.ObjectDefName = "OBJECT_WORK_DOCS_SET" Then
    txt = "Комплект утвержден: """ & Obj.Description & """"
  End If
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,""
End Sub

Sub CheckSectionCompleted(Obj)
' Проверяем. все ли тома утверждены и предлагаем завершить раздел
  Set p = Obj.Parent
  
  For Each oVol In p.Objects.ObjectsByDef("OBJECT_VOLUME")
    If oVol.StatusName <> "STATUS_S_INVALIDATED" And oVol.StatusName <> "STATUS_VOLUME_IS_APPROVED" And oVol.StatusName <> "STATUS_ARH" Then
      Exit Sub
    End If
  Next   
  ' Подтверждение
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbYesNo, 1142, Obj.Description)    
  If result <> vbYes Then
    Exit Sub
  Else
    ' Завершаем раздел/Подраздел
    ThisApplication.ExecuteScript "CMD_SECTION_COMPLETED", "Main", p
  End If
End Sub
