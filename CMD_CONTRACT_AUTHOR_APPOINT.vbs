' $Workfile: COMMAND.SCRIPT.CMD_WORK_DOCS_SET_DEVELOPER_APPOINT.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Назначить ответственного за разработку комплекта, Раздела
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

USE "CMD_DLL_ROLES"

Dim o
Set o = ThisObject
Call Main(o)

Sub Main(o_)
 
  '  Проверяем условия запуска команды
'  Set cu=ThisApplication.CurrentUser
'  if o_.status.SysName<>"STATUS_WORK_DOCS_SET_IS_DEVELOPING" Or Not ThisApplication.Groups("GROUP_GIP").Users.Has(cu) Then 
'    Call ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbExclamation+VbOKOnly, 1271,o_.ObjectDef.Description)
'    Exit Sub
'  End If
'  
  aDefName = "ATTR_AUTOR"
  If Not ThisApplication.AttributeDefs.Has(aDefName) Then Exit Sub
  Set cAuthor = Nothing
  
  If Not o_.Attributes.Has(aDefName) Then 
    o_.Attributes.Create(aDefName)
  Else
    ' Запоминаем старого автора
    Set cAuthor = o_.Attributes(aDefName).User
  End If
  
  ' Выбор пользователя
  Dim u
  Set u = SelectUserByGroup("GROUP_CONTRACTS")
  If u Is Nothing Or VarType(u)<>9 Then Exit Sub
  
  ' Подтверждение выбора пользователя
  result=ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbQuestion+VbYesNo, 1270,u.Description,o_.ObjectDef.Description,o_.Description)
  If result <> vbYes Then
    Exit Sub
  End If 
  
  o_.Attributes(aDefName).User = u
  
  ' Назначение на роль
  Call ChangeRoles(o_,u)
  ' рассылка оповещения ответственным
  Call SendMessage(o_)
End Sub

Private Sub ChangeRoles(o_,u_)
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole", o_,"ATTR_AUTOR","ROLE_CONTRACT_AUTOR")
End Sub

'==============================================================================
' Отправка оповещения ответственному проектировщику о назначении его ответственным
'------------------------------------------------------------------------------
' o_:TDMSObject - взятый комплект на нормоконтроль
'==============================================================================
Private Sub SendMessage(o_)
  Dim u
  For Each r In o_.RolesByDef("ROLE_CONTRACT_AUTOR")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1540, u, o_, Nothing, o_.Description, ThisApplication.CurrentUser.Description, ThisApplication.CurrentTime
  Next
End Sub
