' Автор: Стромков С.А.
'
' Создание разделов
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016





Call Main(ThisObject)

Sub Main(Obj)
  
  '  Подтверждение действия пользователя
  Dim result
  result=ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbQuestion+VbYesNo, 1275,Obj.Description)
  If result <> vbYes Then
    Exit Sub
  End If 
  
  ' Изменение статуса разрабатываемых документов
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOC_DEV")
    If oDoc.StatusName = "STATUS_DOCUMENT_IS_SENT_TO_NK" Then
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,oDoc.Status,oDoc,"STATUS_DOCUMENT_IS_TAKEN_NK") 
    End If
  Next  
  ' Изменение статуса разрабатываемых чертежей  
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DRAWING")
    If oDoc.StatusName = "STATUS_DOCUMENT_IS_SENT_TO_NK" Then
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,oDoc.Status,oDoc,"STATUS_DOCUMENT_IS_TAKEN_NK")  
    End If
  Next
  
  'Статус, устанавливаемый в результате выполнения команды
  Dim NextStatus
  NextStatus ="STATUS_WORK_DOCS_SET_IS_TAKEN_NK"

  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,"STATUS_WORK_DOCS_SET_IS_SENT_TO_NK",Obj,NextStatus)   
  ' рассылка оповещения ответственным
  Call SendMessage(Obj)
  ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1129, Obj.Description    
End Sub

'==============================================================================
' Отправка оповещения ответственному проектировщику о взятии комплекта на нормоконтроль
'------------------------------------------------------------------------------
' o_:TDMSObject - взятый комплект на нормоконтроль
'==============================================================================
Private Sub SendMessage(o_)
  Dim u
  For Each r In o_.RolesByDef("ROLE_LEAD_DEVELOPER")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1129, u, o_, Nothing, o_.Description, ThisApplication.CurrentUser.Description, ThisApplication.CurrentTime
  Next
End Sub
