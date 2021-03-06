' $Workfile: COMMAND.SCRIPT.CMD_DOC_DEVELOPED.scr $ 
' $Date: 29.09.08 12:37 $ 
' $Revision: 18 $ 
' $Author: Oreshkin $ 
'
' Команда: "Документ разработан"
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.


Dim o
Set o = ThisObject

'Статус, устанавливаемый в результате выполнения команды
Dim NextStatus
NextStatus ="STATUS_DOC_IS_FIXED"

Call Run(o)

Sub Run(Obj)
  Dim result

  Obj.Permissions = SysAdminPermissions 
  ' Проверка наличия файла
  If Not ThisApplication.ExecuteScript("CMD_DLL", "CheckDoc",Obj) Then Exit Sub
  
  ' Подтверждение
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, 1267, Obj.ObjectDef.Description, Obj.Description)    
  If result <> vbYes Then
    Exit Sub
  End If    
    
  ' Изменение статуса
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,NextStatus)    
  ' Оповещение
  Call SendMessage(Obj)
End Sub


'==============================================================================
' Отправка оповещения о завершении разработки документа всем руководителям
' утверждающим документ
'------------------------------------------------------------------------------
' o_:TDMSObject - разработанный документ
'==============================================================================
Private Sub SendMessage(o_)
  Dim u
  For Each r In o_.RolesByDef("ROLE_RESPONSIBLE")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1005, u, o_, Nothing, o_.Description, ThisApplication.CurrentUser.Description
  Next
End Sub


