' $Workfile: COMMAND.SCRIPT.CMD_AN_SEND.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Отправить предварительное извещение
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.


Dim o
Set o = ThisObject
Call Main(o)

Sub Main(o_)
  Dim result

  o_.Permissions = SysAdminPermissions 
  ' Подтверждение
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbYesNo, 1146, o_.Description)    
  If result <> vbYes Then
    Exit Sub
  End If    
  
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o_,o_.Status,o_,"STATUS_AN_SENT")
  
  Call SendMessage(o_)
End Sub

Private Sub SendMessage(o_)
  Dim oProject,sText,q,sh
  Set oProject = o_.Attributes("ATTR_PROJECT").Object
  sText = o_.Attributes("ATTR_ADVANCE_NOTIFICATION_INF").Value
  Set q = ThisApplication.Queries("QUERY_PROJECT_RESPS")
  q.Parameter("PROJECT") = o_.Attributes("ATTR_PROJECT").Object
  Set sh = q.Sheet
  For i = 0 To (sh.RowsCount-1)
    Set u = ThisApplication.Users(sh.CellValue(i,0))
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1147, u, o_, Nothing, oProject.Description,sText, ThisApplication.CurrentUser.Description, ThisApplication.CurrentTime
  Next
  
End Sub
