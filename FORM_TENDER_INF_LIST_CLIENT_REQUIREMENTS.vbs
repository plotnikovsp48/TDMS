' Форма ввода - Документ закупки. Требования к участникам. Информационная карта внутренней закупки.
'--------------------------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

USE "CMD_DLL_COMMON_BUTTON"

'Событие открытие формы
Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
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

  'Кнопка - Сохранить 
  Sub BUTTON_CUSTOM_SAVE_OnClick()
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSave", ThisForm, ThisObject
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","AttrsSyncInfCard",ThisObject
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
