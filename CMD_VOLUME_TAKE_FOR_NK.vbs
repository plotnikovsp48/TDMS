' $Workfile: COMMAND.SCRIPT.CMD_VOLUME_TAKE_FOR_NK.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Взять том на нормоконтроль
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.


Call Main(ThisObject)

Function Main(Obj)
  Main = False
  Dim result
  '  Подтверждение взятия на Нормоконтроль
  result = ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbQuestion+VbYesNo, 1186,Obj.Description)
  If result <> vbYes Then
    Exit Function
  End If
  
  ' Изменение статуса разрабатываемых документов
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOC_DEV")
    If oDoc.StatusName = "STATUS_DOCUMENT_IS_SENT_TO_NK" Then
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,oDoc.Status,oDoc,"STATUS_DOCUMENT_IS_TAKEN_NK") 
      Call CreateNKObj (oDoc)
    End If
  Next  
  ' Изменение статуса разрабатываемых чертежей  
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DRAWING")
    If oDoc.StatusName = "STATUS_DOCUMENT_IS_SENT_TO_NK" Then
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,oDoc.Status,oDoc,"STATUS_DOCUMENT_IS_TAKEN_NK")  
      Call CreateNKObj (oDoc)
    End If
  Next
  
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,"STATUS_VOLUME_IS_SENT_TO_NK",Obj,"STATUS_VOLUME_IS_TAKEN_NK") 
  ' рассылка оповещения ответственным
  Call SendMessage(Obj)
  ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1508, Obj.Description
  
'  Call CreateNKObj (Obj)
  Main = True
End Function

Sub CreateNKObj(Obj)
  Set oNKObj = Nothing
  set query = ThisApplication.Queries("QUERY_GET_NK")
  query.Parameter("PARAM0") = obj.handle
  set objs = query.Objects
  if objs.Count>0 then _
    set oNKObj = objs(0)

  If oNKObj is nothing then _
     Set oNKObj = ThisApplication.ExecuteScript("CMD_SS_LIB", "CreateInspectionObject",Obj)
  If Not oNKObj Is Nothing Then 
    oNKObj.permissions = SysAdminPermissions
    oNKObj.Status = ThisApplication.Statuses("STATUS_NK")
  End If
End Sub
'==============================================================================
' Отправка оповещения ответственному проектировщику о взятии комплекта на нормоконтроль
'------------------------------------------------------------------------------
' o_:TDMSObject - взятый комплект на нормоконтроль
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
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1508, u, o_, Nothing, o_.Description, ThisApplication.CurrentUser.Description, ThisApplication.CurrentTime
  Next
End Sub
