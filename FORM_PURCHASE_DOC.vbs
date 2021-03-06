' Форма ввода - Документ закупки
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

'USE "CMD_KD_COMMON_LIB"
USE "CMD_DLL_COMMON_BUTTON"
USE "CMD_FILES_LIBRARY"
USE "CMD_PROJECT_DOCS_LIBRARY"


Sub Form_BeforeShow(Form, Obj)
  Call SetLabels(Form, Obj)
  set cCtl=Form.controls
'  Ссылка на закупку
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","GoParentText",ThisForm, ThisObject 
  'Доступность атрибута Тип документа
  If Obj.ObjectDef.Objects.Has(Obj.GUID) Then
   If Obj.Attributes.has("ATTR_PURCHASE_DOC_TYPE") then
    If Obj.Attributes.Has("ATTR_TENDER_DOC_TIPE_LOC") Then    
    Form.Controls("ATTR_PURCHASE_DOC_TYPE").ReadOnly = Obj.Attributes("ATTR_TENDER_DOC_TIPE_LOC")
    End If
    Form.Controls("ATTR_PURCHASE_DOC_TYPE").ReadOnly = not Obj.Attributes("ATTR_PURCHASE_DOC_TYPE").Empty '= False
   End If
  End If
  Call ThisApplication.ExecuteScript("CMD_DLL", "ShowBtnIcon",Form,Obj)
  Call ShowBTN_TENDER_DOC_TO_PUBLISH_Icon()
  'Доступность атрибута Участник
  Call TenderCountEISEnable(Form,Obj)
  Call SetControls(Form,Obj)
  Call ShowFile(0)
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSaveCancelBlock", ThisForm, ThisObject 
     
 '     Делаем не доступным для чтения Заявки на запрос предложений для всех кроме группы и экспертов
'    ----------------------------------------------------------------------------------------------
Set CU = ThisApplication.CurrentUser
If Obj.Attributes.Has("ATTR_PURCHASE_DOC_TYPE") Then
Val = Obj.Attributes("ATTR_PURCHASE_DOC_TYPE").Value
  If StrComp(Val,"Заявка на запрос предложений",vbTextCompare) = 0 Then
   If Obj.RolesForUser(CU).Has("ROLE_TENDER_DOCS_RESP_DEVELOPER") = False Then
    If CU.Groups.Has("GROUP_TENDER_INSIDE") = false and CU.Groups.Has("GROPE_TENDER_EXPERT") = false and CU.Groups.Has("GROUP_TENDER") = false Then
     Form.Controls("QUERY_FILES_IN_DOC").Visible = False
     Form.Controls("STATIC_ACC_DEN").Visible = True
     Form.Controls("BUTTON_REQ_ACC").Visible = True
    End If
   End If
  End If  
End If 
    '-----------------------------------------------------------------------------------------------  
 
   
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
'Событие изменения атрибутов формы
 ThisApplication.Dictionary(Obj.GUID).Item("ObjEdit") = True
 ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSaveCancelBlock", Form, Obj 
  If Attribute.AttributeDefName = "ATTR_PURCHASE_DOC_TYPE" Then
    If Attribute.Classifier.Description = "Информационная карта" Then
      msgbox "Информационная карта должна создаваться с карточки закупки",vbExclamation,"Создание документа"
      Cancel = True
      Exit Sub
    End If
    NeedToChangeName = False
    ' Заменяем наименование
    cName = Obj.Attributes("ATTR_DOCUMENT_NAME")
    If StrComp(Attribute.Value,"Протокол подведения итогов",vbTextCompare) = 0 Then
      oName = "Протокол рассмотрения и оценки заявок на участие в запросе котировок"
    Else
      oName = Attribute.Classifier.Description
    End if
      
    If Trim(cName)<> "" Then
      ans = msgbox ("Заменить наименование документа на """ & oName & """?",vbQuestion+vbYesNo)
      If ans = vbYes Then 
        NeedToChangeName = True
      End If
    Else
      NeedToChangeName = True
    End If
    
    If NeedToChangeName Then
      Obj.Attributes("ATTR_DOCUMENT_NAME") = oName
    End If
    
    If StrComp(Attribute.Value,"Информационная карта",vbTextCompare) = 0 Then
      Check = True
      If not Obj.Parent is Nothing Then
        For Each Child in Obj.Parent.Content
          If Child.ObjectDefName = "OBJECT_PURCHASE_DOC" and Child.GUID <> Obj.GUID Then
            If Child.Attributes.Has("ATTR_PURCHASE_DOC_TYPE") Then
              If StrComp(Child.Attributes("ATTR_PURCHASE_DOC_TYPE").Value,"Информационная карта",vbTextCompare) = 0 Then
                Check = False
                Exit For
              End If
            End If
          End If
        Next
      End If
      If Check = False Then
        Msgbox "Закупка уже содержит Информационную карту", vbExclamation
        Cancel = True
        Exit Sub
      End If
      
    ElseIf StrComp(Attribute.Value,"Протокол подведения итогов",vbTextCompare) = 0 Then
      Code = ThisApplication.ExecuteScript("CMD_S_NUMBERING","PurchaseDocCodeGen", Obj)
      If Code <> "" Then
        AttrName = "ATTR_DOC_CODE"
        If Obj.Attributes.Has(AttrName) Then Obj.Attributes(AttrName).Value = Code
      End If

      regnum = ThisApplication.ExecuteScript("CMD_S_NUMBERING","PurchaseDocRegNumGen", Obj)
      ThisApplication.ExecuteScript "CMD_TENDER_IN_PROTOCOL_LOAD","SetRegNumber", Obj,regnum 
 '      Call SetRegNumber(Obj,regnum)
    ElseIf StrComp(Attribute.Value,"Акт вскрытия заявок",vbTextCompare) = 0 Then
      regnum = ThisApplication.ExecuteScript("CMD_S_NUMBERING","PurchaseDocRegNumGen", Obj)
      Call SetActRegNumber(Obj,regnum)
    End If
    
    Call TenderCountEISEnable(Form,Obj)
  End If
  If Attribute.AttributeDefName = "ATTR_RESPONSIBLE" Then
    set u = Attribute.User
    If Not u Is Nothing Then
      Set dept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetDeptForUserByGroup",u,"GROUP_LEAD_DEPT")
      Obj.Attributes("ATTR_T_TASK_DEPARTMENT") = dept
    End If
  End If
End Sub

'''Событие - Выделен файл в выборке
'Sub QUERY_FILES_IN_DOC_Selected(iItem, action)
'  Call QueryFileSelect(ThisForm,iItem,Action)
'  If iItem <> -1 and Action = 2 Then
'    ThisForm.Controls("BTN_DELETE_FILES").Enabled = True
'  Else
'    ThisForm.Controls("BTN_DELETE_FILES").Enabled = False
'  End If
'  Call ShowFile(iItem)
'End Sub

'Процедура доступности атрибута Участник
Sub TenderCountEISEnable(Form,Obj)
if  Obj.Parent is nothing then exit sub
 If Obj.Attributes.has("ATTR_PURCHASE_DOC_TYPE") then
  Val = Obj.Attributes("ATTR_PURCHASE_DOC_TYPE").Value
  If StrComp(Val,"Заявка на запрос предложений",vbTextCompare) = 0 Then
    Check = False
  Else
    Check = True
  End If
  Flag = (Not Check) And Obj.Parent.ObjectDefName = "OBJECT_TENDER_INSIDE"
  Call ThisApplication.ExecuteScript("CMD_DLL","SetControlVisible",Form,"ATTR_TENDER_INVITATION_COUNT_EIS",Flag)
 End If
End Sub

Sub BUTTON_CUSTOM_SAVE_OnClick()
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSave", ThisForm, ThisObject
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","AttrsSyncInfCard",ThisObject 
End Sub

Sub BUTTON_CUSTOM_CANCEL_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomCancel", ThisForm, ThisObject 
End Sub

'Кнопка - Согласовать
Sub BUTTON_AGREED_OnClick()
  ThisScript.SysAdminModeOn
  ThisObject.Update
  ThisObject.Dictionary.Item("FormActive") = "FORM_KD_DOC_AGREE"
  ThisForm.Close False
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = ThisObject
  Dlg.Show
End Sub
'Кнопка - Завершить
Sub BUTTON_CLOSE_OnClick()
  Set Obj = ThisObject
   Res = ThisApplication.ExecuteScript("CMD_TENDER_DOC_GO_END","Main",Obj)' Смена статуса Документа закупки
    If Res Then
    ThisObject.Update
    ThisForm.Close True
  End If
   If StrComp(Obj.Attributes("ATTR_PURCHASE_DOC_TYPE").Value,"Информационная карта",vbTextCompare) = 0 Then
    ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = False
    ThisObject.Update
     ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","AttrsSyncInfCard",Obj 
 AttrStr = "ATTR_TENDER_ITEM_PRICE_MAX_VALUE,ATTR_TENDER_PRICE,ATTR_TENDER_NDS_PRICE," &_
      "ATTR_TENDER_SUM_NDS,ATTR_NDS_VALUE,ATTR_TENDER_INVITATION_PRICE_EIS"
      ThisApplication.ExecuteScript "CMD_DLL","AttrsSyncBetweenObjs", Obj, Obj.Parent, AttrStr
End If      
End Sub

'Кнопка - Опубликовать
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
'Кнопка - закрыть
Sub SetControls(Form,Obj)
  With Form.Controls
    If Obj.StatusName = "STATUS_KD_AGREEMENT"  or Obj.StatusName = "STATUS_DOC_IS_END" Then
      .Item("BUTTON_CLOSE").Visible = False
    End If
    If Obj.StatusName <> "STATUS_DOC_IN_WORK" Then
      .Item("BUTTON_AGREED").Visible = False
'      .Item("BUTTON_CLOSE").Visible = False
    End If
  End With
End Sub
'Событие закрытия формы
Sub Form_BeforeClose(Form, Obj, Cancel)
  Cancel = Not ThisApplication.ExecuteScript("OBJECT_PURCHASE_DOC","CheckBeforeClose",Obj)
End Sub

Sub SetActRegNumber(Obj,Num)
  Set Parent = Obj.Parent
  If Parent.Attributes.Has("ATTR_TENDER_CONCURENT_NUM_EIS") Then
   If Obj.Attributes("ATTR_TENDER_CONCURENT_NUM_EIS").Empty = False Then
   regnum = "№" & chr(32) & Num & chr(32) & Parent.Attributes("ATTR_TENDER_CONCURENT_NUM_EIS").Value & chr(32) & "от" & chr(32) & Date
    End If
     End If
   If Obj.Attributes.Has("ATTR_PROJECT_ORDINAL_NUM") = False Then
    Obj.Attributes.Create("ATTR_PROJECT_ORDINAL_NUM")
  End If
  Obj.Attributes("ATTR_PROJECT_ORDINAL_NUM") = num
  Obj.Attributes("ATTR_REG_NUMBER") = regnum
End Sub


'Ссылка на закупку
Sub PARENT_LinkClick(Button, Shift, url, bCancelDefault)  
 ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","GoParentTextOnClick",ThisForm, ThisObject 
End Sub

Sub QUERY_FILES_IN_TENDER_DOC_Selected(iItem, action)
  Call QueryFileSelect(ThisForm,iItem,Action)
  If iItem <> -1 and Action = 2 Then
    Call SetFilesActionButtonLocked(ThisForm,True)
  Else
    Call SetFilesActionButtonLocked(ThisForm,False)
  End If
  Call ShowFile(iItem)
End Sub

Sub QUERY_FILES_IN_TENDER_DOC_DblClick(iItem, bCancelDefault)
 Thisscript.SysAdminModeOn
  Set Obj = ThisObject
  Set cu = ThisApplication.CurrentUser
  canEdFiles = Obj.Permissions.EditFiles
  If Obj.Permissions.Locked Then
    lckOwn = Obj.Permissions.LockOwner
    Set lUser = Obj.Permissions.LockUser 
    If lckOwn = False Then msgbox "Документ заблокирован пользователем " & lUser.Description & " и будет открыт в режиме чтения!", vbExclamation, "Документ заблокирован"
    If canEdFiles = 1 Then
      flag = lckOwn 
    End If
  Else
    flag = (canEdFiles = 1)
  End If
  Call BlockFilesOpenFile(ThisForm,Obj,Flag)
  bCancelDefault = True
End Sub

Sub BUTTON_REQ_ACC_OnClick()
 txt = "Прошу предоставить доступ к просмотру файлов заявки на запрос предложений"
 ThisApplication.ExecuteScript "CMD_TENDER_OUT_REQUEST", "Main", ThisObject, txt
End Sub
