' Автор: Стромков С.А.
'
' Библиотека функций стандартной версии
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016 г.


Dim o
Set o = ThisObject
Call Run(o)

Sub Run(o_)
  Dim vUsers
  Dim sRole
  sRole = "ROLE_CO_AUTHOR"
  ' Выбор пользователя или группы
  vUsers = SelectUsersAssignedToRole(o_,sRole)
  If VarType(vUsers)=0 Then Exit Sub
  If UBound(vUsers)=-1  Then Exit Sub
  ' Запретить доступ ко всем входящим документам информационного объекта включая состав
  Call DelUsersFromRole(o_,vUsers,sRole)
End Sub

Function SelectUsersAssignedToRole(o_,sRole_)
  Dim Users
  Users = CreateUsersArray(o_,sRole_)
  SelectUsersAssignedToRole = SelectDialog(Users)
End Function

Function CreateUsersArray(o_,sRole_)
  Dim u
  count = 0
  For Each r In o_.RolesByDef(sRole_)
    count = count + 1
    ReDim Preserve Users(count)
    If Not r.User Is Nothing Then Set Users(count-1) = r.User 
    If Not r.Group Is Nothing Then Set Users(count-1) = r.Group 
  Next
  CreateUsersArray = Users
End Function

Function SelectDialog(arr_)
  Dim SelDlg
  Set SelDlg = ThisApplication.Dialogs.SelectDlg
  SelDlg.SelectFrom = arr_
  If SelDlg.Show Then 
    SelectDialog = SelDlg.Objects
  End If  
End Function

Sub DelUsersFromRole(o_,vUsers_,sRole_)
  Dim o,u,r
  For Each u In vUsers_
    Set r = FindRole(o_,u,sRole_)
    If Not r Is Nothing Then
      o_.Permissions = SysAdminPermissions
      o_.Roles.Remove r
      Call SendOrder(o_,u)
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
  Set FindRole = Nothing
  For Each r In o_.RolesByDef(sRole_)
    If Not r.User Is Nothing Then
      If u_.SysName = r.User.SysName Then
        Set FindRole = r
        Exit Function
      End If
    End If
    If Not r.Group Is Nothing Then
      If u_.SysName = r.Group.SysName Then
        Set FindRole = r
        Exit Function
      End If    
    End If
  Next
End Function

'==============================================================================
' Отправка информационное поручение о удалении соразработчика
'------------------------------------------------------------------------------
' Obj:TDMSObject - документ
' u:TDMSUser - пользователь, назначенный соразработчиком
'==============================================================================
Private Sub SendOrder(Obj,u)
  Set uToUser = u
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_CORR_REZOL_INF"
  txt = "Вы больше не являетесь соразработчиком """ & Obj.Description & """" 
  planDate = ""
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,planDate
End Sub