' $Workfile: COMMAND.SCRIPT.CMD_CHANGE_DOC_ICONS.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 5 $ 
' $Author: Oreshkin $ 
'
' Команда: "Изменить значки документов"
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.


Call Main()

Sub Main()
  Dim oDocs
  
  Set oDocs = ThisApplication.Queries("QUERY_ALL_DOCS").Objects
  For Each o In oDocs
    ThisApplication.ExecuteScript "CMD_DLL","SetIcon",o
  Next
  ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1023

End Sub
