' Форма ввода - Документ закупки. Потенциальные участники. Информационная карта внутренней закупки.
'--------------------------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

USE "CMD_DLL_COMMON_BUTTON"
'Событие открытие формы
Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Form.Controls("BUTTON_DEL").Enabled = False
  Call ThisApplication.ExecuteScript("CMD_DLL", "ShowBtnIcon",Form,Obj)
  Call ShowBTN_TENDER_DOC_TO_PUBLISH_Icon()
  '  Ссылка на закупку
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","GoParentText",ThisForm, ThisObject 
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSaveCancelBlock", ThisForm, ThisObject  
End Sub

'Событие изменения атрибутов формы
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
 ThisApplication.Dictionary(Obj.GUID).Item("ObjEdit") = True
 ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSaveCancelBlock", Form, Obj 
End Sub

'Событие закрытия формы
Sub Form_BeforeClose(Form, Obj, Cancel)
  Cancel = Not ThisApplication.ExecuteScript("OBJECT_PURCHASE_DOC","CheckBeforeClose",Obj)
End Sub

'Кнопка - Добавить
Sub BUTTON_ADD_OnClick()
  ThisScript.SysAdminModeOn
  Set TableRows = ThisObject.Attributes("ATTR_TENDER_POSSIBLE_CLIENT").Rows
  Set Query = ThisApplication.CreateQuery
  Query.Permissions = sysadminpermissions
  Query.AddCondition tdmQueryConditionObjectDef, "'OBJECT_CORRESPONDENT'"
  Set Objects = Query.Objects
  If Objects.count = 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1701
    Exit Sub
  End If  
  
  'Исключаем объекты, которые уже есть в таблице
  ThisApplication.ExecuteScript "CMD_DLL", "QueryObjectsFilter", Objects, "ATTR_COR_USER_CORDENT", TableRows
  
  If Objects.Count = 0 Then
    Msgbox "В системе нет подходящих объектов.", vbExclamation
    Exit Sub
  End If
  
  Set Dlg = ThisApplication.Dialogs.SelectObjectDlg
  Dlg.SelectFromObjects = Objects
  If Dlg.Show Then
    If Dlg.Objects.Count <> 0 Then
      For Each Obj in Dlg.Objects
        'Проверка на наличие задания в таблице
        Check = True
        GUID = Obj.GUID
        For Each Row in TableRows
          If Row.Attributes("ATTR_COR_USER_CORDENT").Empty = False Then
            If not Row.Attributes("ATTR_COR_USER_CORDENT").Object is Nothing Then
              If Row.Attributes("ATTR_COR_USER_CORDENT").Object.GUID = GUID Then
                Check = False
                Exit For
              End If
            End If
          End If
        Next
        If Check = True Then
          'Создаем новую запись в таблице
          Set NewRow = TableRows.Create
          NewRow.Attributes("ATTR_COR_USER_CORDENT").Object = Obj
        End If
      Next
 ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = True
 ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSaveCancelBlock", ThisForm, ThisObject
    ThisObject.Dictionary.Item("FormActive") = "FORM_TENDER_POSSIBLE_CLIENT"

  ThisObject.SaveChanges (0)
    End If
  End If
End Sub

'Кнопка - Удалить
Sub BUTTON_DEL_OnClick()
  ThisScript.SysAdminModeOn
  Set Query = ThisForm.Controls("QUERY_TENDER_POSSIBLE_CLIENT")
  Set Objects = Query.SelectedObjects
  
  'Подтверждение удаления
  'If Objects.Count <> 0 Then
  '  Key = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion + vbYesNo, 1607, Objects.Count)
  '  If Key = vbNo Then Exit Sub
  'End If
  
  'Удаление строк из таблицы
  Set TableRows = ThisObject.Attributes("ATTR_TENDER_POSSIBLE_CLIENT").Rows
  For Each Row in TableRows
    If Row.Attributes("ATTR_COR_USER_CORDENT").Empty = False Then
      If not Row.Attributes("ATTR_COR_USER_CORDENT").Object is Nothing Then
        If Objects.Has(Row.Attributes("ATTR_COR_USER_CORDENT").Object) Then
          TableRows.Remove Row
        End If
      End If
    End If
  Next
 ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = True
 ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSaveCancelBlock", ThisForm, ThisObject
 
  ThisObject.Dictionary.Item("FormActive") = "FORM_TENDER_POSSIBLE_CLIENT"
'  ThisObject.Update
  ThisObject.SaveChanges (0)
'   ThisForm.Refresh
End Sub

Sub QUERY_TENDER_POSSIBLE_CLIENT_Selected(iItem, action)
  Set CU = ThisApplication.CurrentUser
  Set Obj = ThisObject
  Set Roles = Obj.RolesForUser(CU)
  Grp = "GROUP_TENDER_INSIDE"
  Rl1 = "ROLE_TENDER_INICIATOR"
  Rl2 = "ROLE_PURCHASE_RESPONSIBLE"

  If CU.Groups.Has(Grp) = True or  Roles.Has(Rl1) = True or Roles.Has(Rl2) = True Then
    If iItem <> -1 Then
    ThisForm.Controls("BUTTON_DEL").Enabled = True
  Else
    ThisForm.Controls("BUTTON_DEL").Enabled = False
  End If
 End If
End Sub

  'Кнопка - Сохранить 
Sub BUTTON_CUSTOM_SAVE_OnClick()
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSave", ThisForm, ThisObject
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","AttrsSyncInfCard",ThisObject
    ThisForm.Controls("BUTTON_CUSTOM_SAVE").Enabled = False
    ThisForm.Controls("BUTTON_CUSTOM_CANCEL").Enabled = False
End Sub 
'Кнопка - Отменить
Sub BUTTON_CUSTOM_CANCEL_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomCancel", ThisForm, ThisObject 
End Sub

'Кнопка - Опубликовать. Перенести в библиотеку!
sub ShowBTN_TENDER_DOC_TO_PUBLISH_Icon()
  set btnfav = thisForm.Controls("BTN_TENDER_DOC_TO_PUBLISH").ActiveX
  
  Set Obj = ThisObject
  If Obj.Attributes.Has("ATTR_TENDER_DOC_TO_PUBLISH") Then
    val = Obj.Attributes("ATTR_TENDER_DOC_TO_PUBLISH").Value
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
