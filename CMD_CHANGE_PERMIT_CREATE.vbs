' Автор: Стромков С.А.
'
' Возврат задания на доработку от Ответственного за подготовку задания Разработчику задания
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016 г.

Dim o
Set o = ThisObject
Call Main(o)

Sub Main(o_)
  Dim oNew
  ' Создание извещения
  Set oNew =  ThisApplication.ObjectDefs("OBJECT_CHANGE_PERMIT").CreateObject
  oNew.Permissions = SysAdminPermissions 
  ' Установка атрибутов
  Call SetAttrs(o_,oNew)
  ' Наполнение списка согласующих специалистов
  Call SetAcceprList(oNew)
  ' Вывод диалога
  Set oNew = ShowDialog(oNew)
End Sub

' Установка атрибутов
Private Sub SetAttrs(p_,o_)
  ' Установка атрибута "Проект"
  o_.Attributes("ATTR_PROJECT") = p_.Attributes("ATTR_PROJECT")
  ' Установка атрибута "Раздел(Комплект)"
  o_.Attributes("ATTR_CHANGE_PERMIT_CHANGE_OBJ") = p_
End Sub

' Вывод диалога
Private Function ShowDialog(o_)
  Dim EditObjDlg
  Set ShowDialog = Nothing
  Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
  o_.Permissions = SysAdminPermissions 
  EditObjDlg.object = o_
  EditObjDlg.ParentWindow = ThisApplication.hWnd
  If Not EditObjDlg.Show Then 
    o_.Erase 
  End If
  Set ShowDialog = o_
End Function


Private Sub SetAcceprList(o_)
  Dim vRows
  Dim vNewRow
  Dim uDev,uRes,r,rd,cu
  Set cu = ThisApplication.CurrentUser
  Set rd = ThisApplication.RoleDefs("ROLE_CHANGE_PERMIT_ACCEPT")
  o_.Permissions = SysAdminPermissions 
  
  ' Добавляем руководителя проекта
  Set uRes = o_.Attributes("ATTR_PROJECT").Object.Roles("ROLE_GIP").User
  If uRes.Handle <> cu.Handle Then
    Set r = o_.Roles.Create("ROLE_GIP",uRes)
  End If
  
  ' Добавляем руководителя проекта
  Set uRes = o_.Attributes("ATTR_PROJECT").Object.Roles("ROLE_RESPONSIBLE").User
  If uRes.Handle <> cu.Handle Then
    Set r = o_.Roles.Create(rd,uRes)
  End If
   
  ' Добавляем ответственного по специальности
  Set uDev = o_.Roles("ROLE_RESPONSIBLE").User
  If uRes.Handle <> uDev.Handle And cu.Handle <> uDev.Handle Then
    Set r = o_.Roles.Create(rd,uDev)
  End If
  
  ' Основной комплект
  If o_.Attributes("ATTR_CHANGE_PERMIT_CHANGE_OBJ").Object.Roles.Has("ROLE_LEAD_DEVELOPER") Then
    ' Добавляем ответственного проектировщика комплекта
    Set uDev = o_.Attributes("ATTR_CHANGE_PERMIT_CHANGE_OBJ").Object.Roles("ROLE_LEAD_DEVELOPER").User
    If uRes.Handle <> uDev.Handle And cu.Handle <> uDev.Handle Then
      Set r = o_.Roles.Create(rd,uDev)
    End If
  End If
  
  ' Том
  If o_.Attributes("ATTR_CHANGE_PERMIT_CHANGE_OBJ").Object.Roles.Has("ROLE_VOLUME_COMPOSER") Then
    ' Добавляем Ответственного за комплектацию тома
    Set uDev = o_.Attributes("ATTR_CHANGE_PERMIT_CHANGE_OBJ").Object.Roles("ROLE_VOLUME_COMPOSER").User
    If uRes.Handle <> uDev.Handle And cu.Handle <> uDev.Handle Then
      Set r = o_.Roles.Create(rd,uDev)
    End If
  End If
End Sub
