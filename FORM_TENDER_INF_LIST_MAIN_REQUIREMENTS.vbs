' Форма ввода - Документ закупки. Требования к обеспечению. Информационная карта внутренней закупки.
'--------------------------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

USE "CMD_DLL_COMMON_BUTTON"

'Событие открытия формы
Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Call AttrsEnable(Form,Obj)
  Call ThisApplication.ExecuteScript("CMD_DLL", "ShowBtnIcon",Form,Obj)
  Call ShowBTN_TENDER_DOC_TO_PUBLISH_Icon()
  '  Ссылка на закупку
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","GoParentText",ThisForm, ThisObject 
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSaveCancelBlock", Form, Obj 
 End Sub
 
 
'Событие закрытия формы
Sub Form_BeforeClose(Form, Obj, Cancel)
  Cancel = Not ThisApplication.ExecuteScript("OBJECT_PURCHASE_DOC","CheckBeforeClose",Obj)
End Sub

'Доступность атрибутов
Sub AttrsEnable(Form,Obj)
  Set CU = ThisApplication.CurrentUser
  Set Roles = Obj.RolesForUser(CU)
  Form.Controls("ATTR_TENDER_ADVANCE_PLAN_PAY").ReadOnly = True
  Form.Controls("ATTR_TENDER_ADDITIONAL_REQUIREMENTS").ReadOnly = True
  Form.Controls("ATTR_TENDER_BID_REQUIREMENTS").ReadOnly = True
  
   'Исполнитель по закупке
  If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") or  Roles.Has("ROLE_TENDER_INICIATOR") Then
   Form.Controls("ATTR_TENDER_ADVANCE_PLAN_PAY").ReadOnly = False
   Form.Controls("ATTR_TENDER_ADDITIONAL_REQUIREMENTS").ReadOnly = False
   Form.Controls("ATTR_TENDER_BID_REQUIREMENTS").ReadOnly = False
   Exit sub
  End If
 AttrList = "ATTR_TENDER_KP_DESI,ATTR_TENDER_PEO_CHIF"
  Arr = Split(AttrList,",")  
    For i = 0 to Ubound(Arr)
    AttrName = Arr(i)
     If Obj.Parent.Attributes(AttrName).Empty = False Then
      If not Obj.Parent.Attributes(AttrName).User is Nothing Then
       If Obj.Parent.Attributes(AttrName).User.SysName = CU.SysName Then 
          Form.Controls("ATTR_TENDER_ADVANCE_PLAN_PAY").ReadOnly = False
          Form.Controls("ATTR_TENDER_ADDITIONAL_REQUIREMENTS").ReadOnly = False
          Form.Controls("ATTR_TENDER_BID_REQUIREMENTS").ReadOnly = False
'          Form.Controls("ATTR_TENDER_ADDITIONAL_REQUIREMENTS").ReadOnly = False
'         Form.Controls("ATTR_TENDER_ADVANCE_PLAN_PAY").Visible = False
       End If
       End If
      End If
  Next
 End Sub
 
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  If Attribute.AttributeDefName = "ATTR_TENDER_ADVANCE_PLAN_PAY" Then
    flag = not ThisApplication.ExecuteScript("CMD_DLL","CheckPrice",Obj,Attribute.AttributeDefName)
    Cancel = flag
  End If
 ThisApplication.Dictionary(Obj.GUID).Item("ObjEdit") = True
 ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSaveCancelBlock", Form, Obj 
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
