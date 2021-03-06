' $Workfile: COMMAND.SCRIPT.CMD_VOLUME_PASS_NK.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Том прошел нормоконтроль
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  '  Подтверждение действия пользователя
  Dim result
  result=ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbQuestion+VbYesNo, 1187,Obj.Description)
  If result <> vbYes Then
    Exit Function
  End If 
  
  Res = Run (Obj)   
  
  If Res Then ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1509, Obj.Description 
  
  Main = Res
End Function

Function Run(Obj)
  Run = False
  ' Изменение статуса разрабатываемых документов
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOC_DEV")
    If oDoc.StatusName = "STATUS_DOCUMENT_IS_TAKEN_NK" Then
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,oDoc.Status,oDoc,"STATUS_DOCUMENT_IS_CHECKED_BY_NK") 
      ' Закрываем поручение
      Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_CORR_INSPECTION")
      '  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrders",Obj,"NODE_CORR_INSPECTION")
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
    
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,"STATUS_VOLUME_IS_TAKEN_NK",Obj,"STATUS_VOLUME_IS_CHECKED_BY_NK")  
  ' Отправка уведомления
  Call SendMessage(Obj)
  Run = True
End Function
'==============================================================================
' Отправка оповещения ответственному о визировании тома нормоконтролером
'------------------------------------------------------------------------------
' o_:TDMSObject - завизированный комплект
'==============================================================================
Private Sub SendMessage(o_)
  Dim u
  For Each r In o_.RolesByDef("ROLE_VOLUME_COMPOSER")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1509, u, o_, Nothing, o_.Description, ThisApplication.CurrentUser.Description
  Next
   
  For Each r In o_.RolesByDef("ROLE_VOLUME_APPROVE")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1503, u, o_, Nothing, o_.ObjectDef.Description, o_.Description, ThisApplication.CurrentUser.Description
  Next
End Sub
