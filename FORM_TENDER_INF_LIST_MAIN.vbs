' Форма ввода - Документ закупки
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

USE "CMD_DLL_COMMON_BUTTON"


Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Form.Controls("BUTTON_DOC_DEL").Enabled = False
  Form.Controls("BUTTON_DOC_EDIT").Enabled = False
  Call AttrsEnable(Form,Obj)
  Call PriceCheckBtnEnable(Form,Obj)
  Call ThisApplication.ExecuteScript("CMD_DLL", "ShowBtnIcon",Form,Obj)
  Call ShowBTN_TENDER_DOC_TO_PUBLISH_Icon()
  Call BttnAddDocEnable()
  '  Ссылка на закупку
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","GoParentText",ThisForm, ThisObject 
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSaveCancelBlock", Form, Obj 

End Sub

'Событие закрытия формы
Sub Form_BeforeClose(Form, Obj, Cancel)
  Cancel = Not ThisApplication.ExecuteScript("OBJECT_PURCHASE_DOC","CheckBeforeClose",Obj)
End Sub

'Событие изменения атрибутов формы
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)

 ThisApplication.Dictionary(Obj.GUID).Item("ObjEdit") = True
 ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSaveCancelBlock", ThisForm, ThisObject 
 
  If Attribute.AttributeDefName = "ATTR_TENDER_ITEM_PRICE_MAX_VALUE" Then
    ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","TablePricesync",Form, Obj, Obj.Parent, Attr1, Attr2
    Call PriceCheckBtnEnable(Form,Obj)
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_START_WORK_DATA" Then
    Data1 = Obj.Attributes("ATTR_TENDER_FACT_MATERIAL_TAKE_OFF_DATA")
    Data2 = Attribute.Value
    Data3 = Obj.Attributes("ATTR_TENDER_END_WORK_DATA")
    Delta = 0
    flag = (Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Delta)) Or _
           Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMaxData",Data3,Data2,Delta)
    If Flag Then
        Cancel = flag
        Exit Sub
    End If
    Call StartWorkDataCheck(Form,Obj)
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_END_WORK_DATA" Then
    Data1 = Obj.Attributes("ATTR_TENDER_START_WORK_DATA")
    Data2 = Attribute.Value
    Delta = 0
    flag = (Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Delta))
    If Flag Then
        Cancel = flag
        Exit Sub
    End If
    Call EndWorkDataCheck(Form,Obj)
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_ADVANCE_PLAN_PAY" Then
    flag = not ThisApplication.ExecuteScript("CMD_DLL","CheckPrice",Obj,Attribute.AttributeDefName)
    Cancel = flag
    ThisApplication.ExecuteScript "CMD_DLL","AttrsSyncBetweenObjs", Obj, Child, AttrStr
  End If
End Sub

'Событие - Выделение в выборке Документов закупки
'-----------------------------------------------------------------------
Sub QUERY_TENDER_DOCS_Selected(iItem, action)
  Set Query = ThisForm.Controls("QUERY_TENDER_DOCKS_IN_DOC")
  Set Objects = Query.SelectedObjects
  If iItem <> -1 Then
    If Objects.Count => 1 Then
      ThisForm.Controls("BUTTON_DOC_EDIT").Enabled = True
      flag = ThisApplication.ExecuteScript("OBJECT_PURCHASE_DOC","UserCanDelete",ThisApplication.CurrentUser,Objects(0))
      ThisForm.Controls("BUTTON_DOC_DEL").Enabled = True And flag
    Else
      ThisForm.Controls("BUTTON_DOC_EDIT").Enabled = False
      ThisForm.Controls("BUTTON_DOC_DEL").Enabled = False
    End If
  Else
    ThisForm.Controls("BUTTON_DOC_DEL").Enabled = False
    ThisForm.Controls("BUTTON_DOC_EDIT").Enabled = False
  End If
End Sub

'Доступность атрибутов
Sub AttrsEnable(Form,Obj)
  Set CU = ThisApplication.CurrentUser
  Set Roles = Obj.RolesForUser(CU)
   
' Группа, инициатор и пользователи в атрибутах ИО Внутренняя закупка:
'«Руководитель ПЭО» (ATTR_TENDER_PEO_CHIF)
'«Ответственный за КП/НКП» (ATTR_TENDER_KP_DESI)
'Группа – «Управление тендерной документацией» (GROUP_TENDER)
'Инициатор – пользователь с ролью «Инициатор закупки» (ROLE_TENDER_INICIATOR)

  'Расчетная (максимальная) цена предмета закупки (договора), цена с НДС, сумма НДС и цена без НДС. Таблица заполняется ПЭО по работам/услугам, МТР – инициатором закупки)

'  If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") = False  Then
'    Form.Controls("ATTR_TENDER_DEPT_RESP").ReadOnly = True
'  End If
  
  'Исполнитель по закупке
  
  If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") or  Roles.Has("ROLE_TENDER_INICIATOR") Then
 
  Form.Controls("ATTR_TENDER_ITEM_PRICE_MAX_VALUE").ReadOnly = False
  Exit sub
  End If
  
 AttrList = "ATTR_TENDER_KP_DESI,ATTR_TENDER_PEO_CHIF"
  Arr = Split(AttrList,",")  
    For i = 0 to Ubound(Arr)
    AttrName = Arr(i)
    If Not Obj.Parent Is Nothing Then 
     If Obj.Parent.Attributes(AttrName).Empty = False Then
      If not Obj.Parent.Attributes(AttrName).User is Nothing Then
       If Obj.Parent.Attributes(AttrName).User.SysName = CU.SysName Then 
       Form.Controls("ATTR_TENDER_ITEM_PRICE_MAX_VALUE").ReadOnly = False
       End If
      End If
     End If
  '  Form.Controls("ATTR_TENDER_ADVANCE_PLAN_PAY").ReadOnly = Check 
    End If
  Next
 End Sub
 
 'Процедура проверки и окраски атрибута Срок начала выполнения работ
Sub StartWorkDataCheck(Form,Obj)
  If Obj.Attributes.Has("ATTR_TENDER_START_WORK_DATA") and Obj.parent.Attributes.Has("ATTR_TENDER_WORK_START_PLAN_DATA") Then
    Set Txt = Form.Controls("T_ATTR_TENDER_START_WORK_DATA")
    If Obj.Attributes("ATTR_TENDER_START_WORK_DATA").Value <> Obj.parent.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA").Value Then
      Txt.ActiveX.ForeColor = RGB(255,0,0)
      Txt.ToolTip = "Срок изменен и не соответствует плановому " & Obj.parent.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA").Value
    Else
      Txt.ActiveX.ForeColor = RGB(0,0,0)
      Txt.ToolTip = "Срок соответствует плановому"
    End If
  End If
End Sub

'Процедура проверки и окраски атрибута Срок окончания выполнения работ
Sub EndWorkDataCheck(Form,Obj)
  If Obj.Attributes.Has("ATTR_TENDER_END_WORK_DATA") and Obj.parent.Attributes.Has("ATTR_TENDER_WORK_END_PLAN_DATA") Then
    Set Txt = Form.Controls("T_ATTR_TENDER_END_WORK_DATA")
    If Obj.Attributes("ATTR_TENDER_END_WORK_DATA").Value <> Obj.parent.Attributes("ATTR_TENDER_WORK_END_PLAN_DATA").Value Then
      Txt.ActiveX.ForeColor = RGB(255,0,0)
      Txt.ToolTip = "Срок изменен и не соответствует плановому " & Obj.parent.Attributes("ATTR_TENDER_WORK_END_PLAN_DATA").Value
    Else
      Txt.ActiveX.ForeColor = RGB(0,0,0)
      Txt.ToolTip = "Срок соответствует плановому"
    End If
  End If
End Sub

'Процедура синхронизации табличных атрибутов цены
Sub OBJECT_PURCHASE_DOC(Obj)
  Attr1 = "ATTR_TENDER_ITEM_PRICE_MAX_VALUE"
  Attr2 = "ATTR_TENDER_INVITATION_PRICE_EIS"
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","TablePricesync",Form, Obj, Obj.Parent, Attr1, Attr2
End Sub
 

 'Процедура управления доступностью кнопки "Проверить"
Sub PriceCheckBtnEnable(Form,Obj)
  If Obj.Attributes.Has("ATTR_TENDER_ITEM_PRICE_MAX_VALUE") Then
    Set TableRows = Obj.Attributes("ATTR_TENDER_ITEM_PRICE_MAX_VALUE").Rows
    If TableRows.Count <> 1 Then Exit Sub
    Set Row = TableRows(0)
    Check = True
    For Each Attr in Row.Attributes
      If Attr.Empty = True Then
        Check = False
        Exit For
      ElseIf Attr.AttributeDefName = "ATTR_NDS_VALUE" Then
        If StrComp(Attr.Value, "Составной", vbTextCompare) = 0 Then
          Check = False
          Exit For
        End If
      End If
    Next
    Form.Controls("BUTTON_PRICE_CHECK").Enabled = Check
  End If
End Sub
 
  'Кнопка - Сохранить 
  Sub BUTTON_CUSTOM_SAVE_OnClick()
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSave", ThisForm, ThisObject
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","AttrsSyncInfCard", ThisObject
End Sub

'Кнопка - Отменить 
Sub BUTTON_CUSTOM_CANCEL_OnClick()
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomCancel", ThisForm, ThisObject 
 End Sub

'Кнопка - Опубликовать. 
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

'Кнопка - Проверить "Расчетная (максимальная) цена предмета закупки (договора)"
Sub BUTTON_PRICE_CHECK_OnClick()
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnPriceCheck",ThisForm, ThisObject 
End Sub

'Ссылка на закупку
Sub PARENT_LinkClick(Button, Shift, url, bCancelDefault)  
 ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","GoParentTextOnClick",ThisForm, ThisObject 
End Sub

'Кнопка - Добавить Документ закупки
'-----------------------------------------------------------------------
Sub BUTTON_DOC_ADD_OnClick()
  Set NewObj = ThisObject.Parent.Objects.Create("OBJECT_PURCHASE_DOC")
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = NewObj
  Dlg.Show
  NewObj.Attributes("ATTR_TENDER_INF_CARD_DOC_FLAG") = True
'  Dlg.Show
End Sub

'Кнопка - Удалить Документ закупки
'-----------------------------------------------------------------------
Sub BUTTON_DOC_DEL_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnDocCardDelOnclic",ThisForm, ThisObject 
End Sub

'Кнопка - Редактировать Документ закупки
'-----------------------------------------------------------------------
Sub BUTTON_DOC_EDIT_OnClick()
  Set Query = ThisForm.Controls("QUERY_TENDER_DOCKS_IN_DOC")
  Set Objects = Query.SelectedObjects
  If Objects.Count = 1 Then
    Set Dlg = ThisApplication.Dialogs.EditObjectDlg
    Dlg.Object = Objects(0)
    Dlg.Show
  End If
End Sub


'Кнопка - Создать Техническое задание
'-----------------------------------------------------------------------
Sub BUTTON_ADD_TECH_ORDER_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","NewDocByTipe",ThisObject.parent,"Техническое задание",false,True,false,True
End Sub
'Кнопка - Создать Расчет стоимости
'-----------------------------------------------------------------------
Sub BUTTON_ADD_MAT_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","NewDocByTipe",ThisObject.parent,"Расчет стоимости",false,True,false,True
End Sub
'Кнопка - Создать Коммерческое предложение
'-----------------------------------------------------------------------
Sub BUTTON_ADD_KP_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","NewDocByTipe",ThisObject.parent,"Коммерческое предложение",false,True,false,True
End Sub
'Кнопка - Создать Проект договора
'-----------------------------------------------------------------------
Sub BUTTON_ADD_ORDER_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","NewDocByTipe",ThisObject.parent,"Проект договора",false,True,false,True
End Sub
'Кнопка - Создать Спецификацию
'-----------------------------------------------------------------------
Sub BUTTON_ADD_SPEC_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","NewDocByTipe",ThisObject.parent,"Спецификация",false,True,false,True 
End Sub
'Кнопка - Создать Календарный план
'-----------------------------------------------------------------------
Sub BUTTON_ADD_PLAN_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","NewDocByTipe",ThisObject.parent,"Календарный план",false,True,false,True 
End Sub
'Кнопка - Перейти к закупке
Sub BUTTON_GOOWNER_OnClick()
  Set Obj = ThisObject
  Set Parent = ThisObject.Parent
  If not Parent is Nothing Then
    ThisForm.close 
    ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","AttrsSyncInfCard",Obj
'    Call AttrsSyncCard(ThisObject)  
'   AttrsSyncInfCard(Obj)
'    Call ThisApplication.ExecuteScript("OBJECT_TENDER_INSIDE","AttrsSync",ThisObject)
    Obj.Update
    Set Dlg = ThisApplication.Dialogs.EditObjectDlg
    Dlg.Object = Parent
    Dlg.Show
    End If
 End Sub

' Доступность кнопок создания документации
Function BttnAddDocEnable()
  Set Form = ThisForm
  Set Obj = ThisObject  
  Set CU = ThisApplication.CurrentUser
  Set Roles = Obj.RolesForUser(CU)
  Grp = "GROUP_TENDER_INSIDE"
  Rl1 = "ROLE_TENDER_INICIATOR"
  Rl2 = "ROLE_PURCHASE_RESPONSIBLE"
  
If CU.Groups.Has(Grp) = false and  Roles.Has(Rl1) = false and Roles.Has(Rl2) = false Then
BttnAddDocEnable = False
Else 
BttnAddDocEnable = True
Btnstr = "BUTTON_ADD_TECH_ORDER,BUTTON_ADD_MAT,BUTTON_ADD_KP,BUTTON_ADD_ORDER,BUTTON_ADD_SPEC,BUTTON_ADD_PLAN"
'        Form.Controls("QUERY_FILES_IN_DOC").Visible = False
        End If
 ArrBtn = Split(Btnstr,",")        
 For i = 0 to Ubound(ArrBtn)
  Btn = ArrBtn(i)       
If Form.Controls.Has(Btn) Then Form.Controls(Btn).Enabled = BttnAddDocEnable
Next
If CU.Groups.Has("GROUP_CONTRACTS") = True Then Form.Controls("BUTTON_ADD_ORDER").Enabled = True
End Function

