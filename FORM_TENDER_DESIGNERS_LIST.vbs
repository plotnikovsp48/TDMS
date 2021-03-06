' Форма ввода - Разработчики
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.
USE "CMD_DLL_COMMON_BUTTON"
Sub Form_BeforeShow(Form, Obj)
  Set Dict = ThisApplication.Dictionary(Obj.GUID)
  If Obj.ObjectDefName = "OBJECT_PURCHASE_DOC" Then
    If not Obj.Parent is Nothing Then
      Dict.Item("QueryObjGuid") = Obj.Parent.Guid
    Else
      Dict.Item("QueryObjGuid") = Obj.Guid
    End If
  Else
    Dict.Item("QueryObjGuid") = Obj.Guid
  End If
  Call ThisApplication.ExecuteScript("CMD_DLL", "ShowBtnIcon",Form,Obj)
  Call ShowBTN_TENDER_DOC_TO_PUBLISH_Icon()
    '  Ссылка на закупку
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","GoParentText",ThisForm, ThisObject 
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSaveCancelBlock", Form, Obj 
End Sub

'Событие изменения атрибутов формы
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
 ThisApplication.Dictionary(Obj.GUID).Item("ObjEdit") = True
 ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSaveCancelBlock", Form, Obj 
End Sub

'Кнопка - Добавить
Sub BUTTON_ADD_OnClick()
 ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnDesignerAddOnClick",ThisForm, ThisObject
'  ThisScript.SysAdminModeOn
'  Set Dlg = ThisApplication.Dialogs.SelectUserDlg
'  Dlg.Caption = "Выбор пользователей"
'  If Dlg.Show Then
'    For Each User in Dlg.Users
'      Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",ThisObject,"ROLE_TENDER_DOCS_RESP_DEVELOPER",User)
'    Next
'    If Dlg.Users.Count > 0 Then ThisObject.Update
'  End If
End Sub

'Кнопка - Удалить
Sub BUTTON_DEL_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnDesignerDellOnClick",ThisForm, ThisObject
'  ThisScript.SysAdminModeOn
'  Set Query = ThisForm.Controls("QUERY_TENDER_DESIGNER_LIST")
'  Arr = Query.SelectedItems
'  Count = UBound(Arr)
'  'Если выделено несколько строк
'  If Count > 0 and Query.Value.RowsCount = Query.ActiveX.Count Then
'    Key = Msgbox("Удалить выбранных пользователей из состава разработчиков?",vbYesNo+vbQuestions)
'    If Key = vbYes Then
'      For i = 0 to Count
'        Set User = Query.Value.RowValue(Arr(i))
'        If not User is Nothing Then
'          Call RoleUserDel(ThisObject,User)
'        End If
'      Next
'      ThisObject.Update
'    End If
'  'Если выделена одна строка - глючит ActiveX
'  Else
'    Set Dict = ThisForm.Dictionary
'    If Dict.Exists("SelectedUser") Then
'      sRow = Dict.Item("SelectedUser")
'      If sRow <> -1 Then
'        Set User = Query.Value.RowValue(sRow)
'        If not User is Nothing Then
'          Key = Msgbox("Удалить выбранных пользователей из состава разработчиков?",vbYesNo+vbQuestions)
'          If Key = vbYes Then
'            Call RoleUserDel(ThisObject,User)
'            ThisObject.Update
'          End If
'        End If
'      End If
'    End If
'  End If
'  ThisScript.SysAdminModeOff
End Sub

'Процедура удаления роли пользователя
Sub RoleUserDel(Obj,User)
  Set Roles = Obj.RolesForUser(User)
  RoleName = "ROLE_TENDER_DOCS_RESP_DEVELOPER"
  If Roles.Has(RoleName) Then
    Obj.Roles.Remove Roles(RoleName)
    If Obj.ObjectDefName = "OBJECT_PURCHASE_DOC" Then
      If not Obj.Parent is Nothing Then
        Set Obj0 = Obj.Parent
      Else
        Set Obj0 = Obj
      End If
    Else
      Set Obj0 = Obj
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 6006, User, Obj0, Nothing, Obj0.Description
  End If
End Sub

'Событие - выделение пользователя в выборке Разработчики
Sub QUERY_TENDER_DESIGNER_LIST_Selected(iItem, action)
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","DesignerSelDelBtnEnable",ThisForm, ThisObject, iItem, action
'  Set Ctrl = ThisForm.Controls("BUTTON_DEL")
'  Set Dict = ThisApplication.Dictionary(ThisObject.GUID)
'  Set Query = ThisForm.Controls("QUERY_TENDER_DESIGNER_LIST")
'  If action = 2 Then
'    ThisForm.Dictionary.Item("SelectedUser") = iItem
'  End If
'  If iItem <> -1 and Action = 2 Then
'    Ctrl.Enabled = True
'    Set User = Query.Value.RowValue(iItem)
'    If not User is Nothing Then
'      Dict.Item("QuerySelUser") = User.SysName
'    End If
'  Else
'    Ctrl.Enabled = False
'  End If
'  ThisForm.Refresh
End Sub

'Кнопка - Опубликовать. Перенести в библиотеку!
sub ShowBTN_TENDER_DOC_TO_PUBLISH_Icon()
  AttrName = "ATTR_TENDER_DOC_TO_PUBLISH"
  BtnName = "BTN_TENDER_DOC_TO_PUBLISH"
  set btnfav = thisForm.Controls(BtnName).ActiveX
  Set Obj = ThisObject
 
  If not Obj.Attributes.Has(AttrName) Then ThisForm.Controls(BtnName).Visible = False
  If Obj.Attributes.Has(AttrName) Then
    val = Obj.Attributes(AttrName).Value
    If val = True Then
      btnfav.Image = thisApplication.Icons("IMG_DOCUMENT_POSITIVE")
    else    
      btnfav.Image = thisApplication.Icons("IMG_DOCUMENT_BASIC")
    End If
  End if
end sub

Sub BTN_TENDER_DOC_TO_PUBLISH_OnClick()
  set btnfav = thisForm.Controls("BTN_TENDER_DOC_TO_PUBLISH").ActiveX
  Set Obj = ThisObject
  If Obj.Permissions.Locked <> FALSE Then 
    If Obj.Permissions.LockUser.SysName <> ThisApplication.CurrentUser.SysName Then
      Msgbox "Документ заблокирован пользователем " & Obj.Permissions.LockUser.Description,vbInformation,"Ошибка изменения документа"
      Exit Sub
    End If
  End If
  
  If Obj.Attributes.Has("ATTR_TENDER_DOC_TO_PUBLISH") Then
    val = Obj.Attributes("ATTR_TENDER_DOC_TO_PUBLISH").Value
    If val = True Then
      Obj.Attributes("ATTR_TENDER_DOC_TO_PUBLISH") = False
      msgbox "Документ удален из заявки",vbInformation,"Документ удален"
    else    
      Obj.Attributes("ATTR_TENDER_DOC_TO_PUBLISH") = True
      msgbox "Документ добавлен в заявку",vbInformation,"Документ добавлен"
    end if
  End If
  Call ShowBTN_TENDER_DOC_TO_PUBLISH_Icon()
  thisForm.Refresh
End Sub

'Ссылка на закупку
Sub PARENT_LinkClick(Button, Shift, url, bCancelDefault)  
 ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","GoParentTextOnClick",ThisForm, ThisObject 
End Sub

Sub BUTTON_CUSTOM_SAVE_OnClick()
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSave", ThisForm, ThisObject
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","AttrsSyncInfCard",ThisObject
End Sub
Sub BUTTON_CUSTOM_CANCEL_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomCancel", ThisForm, ThisObject 
End Sub