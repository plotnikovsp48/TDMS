
' Форма ввода - Внутренняя закупка. Примечания*. 
'--------------------------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

USE "CMD_DLL_COMMON_BUTTON"

'Событие открытие формы
Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
'  Блокируем кнопки
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnEnable0",Form, Obj
'  Блокируем контролы атрибутов по роли
AttrStr = "ATTR_TENDER_MATERIAL_STATUS,ATTR_TENDER_CLIENT_NOTES"
RoleStr = "ROLE_TENDER_INICIATOR,ROLE_PURCHASE_RESPONSIBLE,ROLE_TENDER_DOCS_RESP_DEVELOPER" 
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","AttrControlsAccessOff",Form, Obj, AttrStr, RoleStr
End Sub

'Событие закрытия формы
Sub Form_BeforeClose(Form, Obj, Cancel)
  Cancel = Not ThisApplication.ExecuteScript("OBJECT_PURCHASE_DOC","CheckBeforeClose",Obj)
End Sub

'Событие изменения значений атрибутов
'---------------------------------------------------------------------
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
   ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = True
   ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnEnable0",Form, Obj
 End Sub
 
  'Кнопка - Сохранить Перенести в библиотеку!
  Sub BUTTON_CUSTOM_SAVE_OnClick()
  ThisScript.SysAdminModeOn
  Key = Msgbox("Сохранить внесенные изменения?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
  ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = False
    ThisObject.Dictionary.Item("FormActive") = thisform.SysName
  ThisObject.Update
  'Call BtnEnable0(ThisForm,ThisObject)
End Sub
'Кнопка - Отменить Перенести в библиотеку!
Sub BUTTON_CUSTOM_CANCEL_OnClick()
  ThisScript.SysAdminModeOn
  Key = Msgbox("Отменить внесенные изменения?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
  ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = False
  Guid = ThisObject.GUID
  ThisForm.Close False
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Set Obj = ThisApplication.GetObjectByGUID(Guid)
  Dlg.Object = Obj
  Dlg.Show
 End Sub
 
'Кнопка - Создать договор
'-----------------------------------------------------------------------
Sub BUTTON_ADD_CONTRACT_OnClick()
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnAddContract",ThisForm, ThisObject
End Sub
