' $Workfile: COMMAND.SCRIPT.CMD_VIEW_ALLOW.scr $ 
' $Date: 30.01.07 19:38 $ 
' $Revision: 1 $ 
' $Author: Oreshkin $ 
'
' Разрешить просмотр
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

Dim o
Set o = ThisObject
Call Run(o)

Sub Run(o_)
  Dim vUsers
  ' Выбор пользователя или группы
  Set vUsers = SelectUsersDlg()
  If vUsers Is Nothing Then Exit Sub
  ' Разрешить доступ ко всем входящим документам информационного объекта включая состав
  Call SetUsersToRole(o_,vUsers,"ROLE_VIEW")
End Sub

'==============================================================================
' Функция предоставляет диалог выбора пользователя или группы
'------------------------------------------------------------------------------
' ВОЗВРАЩАЕТ:
'   SelectUsersDlg:TDMSUsers - Выбранные пользователи
'==============================================================================
Function SelectUsersDlg()
  Set SelectUsersDlg = Nothing
  Set SelUser = ThisApplication.Dialogs.SelectUserDlg
  While SelUser.Show 
    If SelUser.Users.Count = 0 And SelUser.Groups.Count = 0 Then
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1171
      Exit Function
    End If 
    
    If  SelUser.Users.Count <> 0 Then
      Set SelectUsersDlg = SelUser.Users
      Exit Function
    End If  
    
    If  SelUser.Groups.Count <> 0 Then
      Set SelectUsersDlg = SelUser.Groups
      Exit Function
    End If  
  Wend
End Function


'==============================================================================
' Метод рекурсивно назначает пользователя или группу на роль
'------------------------------------------------------------------------------
' o_:TDMSObject - Узел дерева навигации
' vUsers_:TDMSUsers - Коллекция пользователей или групп пользователей
' sRole_:String - Системный идентификатор роли
'==============================================================================
Sub SetUsersToRole(o_,vUsers_,sRole_)
  Dim o,u
  For Each o In o_.Objects
    Call SetUsersToRole(o,vUsers_,sRole_)
  Next
  For Each u In vUsers_
    If Not FindRole(o_,u,sRole_) Then
      Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",o_,"ROLE_VIEW",u.SysName)
    End If  
  Next
End Sub

'==============================================================================
' Функция ищет пользователя назначенного на роль
'------------------------------------------------------------------------------
' o_:TDMSObject - Информационный объект на котором ищется роль
' u_:TDMSUser - Искомый пользователь или группа
' sRole_:String - Системный идентификатор искомой роли
'==============================================================================
Function FindRole(o_,u_,sRole_)
  Dim r
  FindRole = False
  For Each r In o_.RolesByDef(sRole_)
    If Not r.User Is Nothing Then
      If u_.SysName = r.User.SysName Then
        FindRole = True
        Exit Function
      End If
    End If
    If Not r.Group Is Nothing Then
      If u_.SysName = r.Group.SysName Then
        FindRole = True
        Exit Function
      End If    
    End If
  Next
End Function
