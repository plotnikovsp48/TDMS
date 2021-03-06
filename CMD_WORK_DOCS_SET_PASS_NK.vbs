' Автор: Стромков С.А.
'
' Создание разделов
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016


Call Main(ThisObject)

Function Main(Obj)
  Main = False
  '  Подтверждение действия пользователя
  result=ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbQuestion+VbYesNo, 1277,Obj.Description)
  If result <> vbYes Then
    Exit Function
  End If 
  
  ' Изменение статуса разрабатываемых документов
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOC_DEV")
    If oDoc.StatusName = "STATUS_DOCUMENT_IS_TAKEN_NK" Then
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,oDoc.Status,oDoc,"STATUS_DOCUMENT_IS_CHECKED_BY_NK") 
      ' Закрываем поручение
      Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_CORR_INSPECTION")
    End If
  Next  
  ' Изменение статуса разрабатываемых чертежей  
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DRAWING")
    If oDoc.StatusName = "STATUS_DOCUMENT_IS_TAKEN_NK" Then
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,oDoc.Status,oDoc,"STATUS_DOCUMENT_IS_CHECKED_BY_NK")  
      ' Закрываем поручение
      Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_CORR_INSPECTION")
      'Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrders",Obj,"NODE_CORR_INSPECTION")
    End If
  Next
    
  'Статус, устанавливаемый в результате выполнения команды
  Dim NextStatus
  NextStatus ="STATUS_WORK_DOCS_SET_IS_CHECKED_BY_NK"
  
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,"STATUS_WORK_DOCS_SET_IS_TAKEN_NK",Obj,NextStatus)    

  ' Отправка уведомления
  Call SendMessage(Obj)
  
  'ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1131, Obj.Description    
  Main = True
End Function

'==============================================================================
' Отправка оповещения ответственному о визировании комплекта нормоконтролером
'------------------------------------------------------------------------------
' o_:TDMSObject - завизированный комплект
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
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1131, u, o_, Nothing, o_.Description, ThisApplication.CurrentUser.Description, ThisApplication.CurrentTime
  Next
End Sub
