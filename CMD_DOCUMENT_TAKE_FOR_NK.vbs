' $Workfile: COMMAND.SCRIPT.CMD_VOLUME_TAKE_FOR_NK.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Взять том на нормоконтроль
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

USE "CMD_SS_SYSADMINMODE"

Call Main(ThisObject)
ThisObject.Update

Sub Main(Obj)

  If vbNo = ThisApplication.ExecuteScript( "CMD_MESSAGE", "ShowWarning", _
    vbQuestion + vbYesNo, 1186, Obj.Description) Then Exit Sub
    
  Dim sam
  Set sam = New SysAdminMode
  
  Dim inspector
  Set inspector = ThisApplication.ExecuteScript("CMD_DOC_SENT_TO_NK", "CreateInspectorIfEmpty", Obj)
  
  ThisApplication.ExecuteScript "CMD_DOC_SENT_TO_NK", "RouteDocObject", _
    Obj, "STATUS_DOCUMENT_IS_TAKEN_NK"
  ThisApplication.ExecuteScript "CMD_DOC_SENT_TO_NK", "RouteInspectorObject", inspector
  
  ThisApplication.ExecuteScript "CMD_SS_LIB", "UpdateInspector", _
    Obj, ThisApplication.CurrentUser
  
  ThisApplication.ExecuteScript "CMD_SS_LIB", "SyncRoleToUser", _
    Obj, "ROLE_NK", ThisApplication.CurrentUser
End Sub
