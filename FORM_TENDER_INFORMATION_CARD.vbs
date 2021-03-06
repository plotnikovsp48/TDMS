' Форма ввода - Информационная карта
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "OBJECT_TENDER_INSIDE"
USE "CMD_DLL_COMMON_BUTTON"

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  'Доступность контролов

    Call StartWorkDataCheck(Form,Obj)
    Call EndWorkDataCheck(Form,Obj)
    Call CheckBtn(Form,Obj)
    Call BttnAddDocEnable()
    ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnEnable0",Form, Obj 
    Form.Controls("BUTTON_DEL").Enabled = False
    Form.Controls("BUTTON_DOC_DEL").Enabled = False
    Form.Controls("BUTTON_DOC_EDIT").Enabled = False 
    Form.Controls("BUTTON_UNRED").Visible = False
    ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","InfoDocFrmCtrlLockAll",Form, Obj ' блокируем все
    ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","InfoDocFrmCtrlLock",Form, Obj 
  'Окраска цены с НДС при отклонении
  'Set Txt = Form.Controls("T_ATTR_TENDER_ITEM_PRICE_MAX_VALUE").ActiveX
  'Check = PriceWithNDScheck(Obj)
  'If Check = False Then Txt.ForeColor = RGB(255,0,0)
  'Окраска дат начала и окончания работ
  Call TuApproveBtnEnable(Form,Obj) 

End Sub

'Событие закрытия формы
Sub Form_BeforeClose(Form, Obj, Cancel)
 'Проверка и анлок
  Set Doc = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","InfoDocGet",ThisObject)
  Set CU = ThisApplication.CurrentUser
  If not Doc is Nothing Then
   If Doc.Permissions.Locked = True Then
    If Doc.Permissions.LockUser.SysName = CU.SysName Then
    Doc.Unlock Doc.Permissions.LockType 
'   Doc.UnlockCheckIn  tdmCancelEdit  
'   msgbox "С формы" & Doc.Permissions.LockType
    End If 
   End If 
  End If
End Sub


'Кнопка - Создать
Sub BUTTON_INFO_DOC_CREATE_OnClick()
  ThisScript.SysAdminModeOn
  AttrStr = "ATTR_TENDER_FACT_MATERIAL_TAKE_OFF_DATA,ATTR_TENDER_ITEM_PRICE_MAX_VALUE," &_
  "ATTR_NDS_VALUE,ATTR_LOT_NDS_VALUE,ATTR_TENDER_START_END_WORK_DATA,ATTR_TENDER_INVOCE_PUBLIC_DATA," &_
  "ATTR_TENDER_ADVANCE_PLAN_PAY,ATTR_TENDER_ADDITIONAL_REQUIREMENTS,ATTR_TENDER_BID_REQUIREMENTS," &_
  "ATTR_TENDER_GUARANTEE_REQUIREMENTS,ATTR_TENDER_RF_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_SMALL_BUSINESS_FLAG," &_
  "ATTR_TENDER_EXPERIENCE_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_PERSONAL_CONF_REQUIREMENTS_DOC_LIST," &_
  "ATTR_TENDER_RIG_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_ISO9001_REQUIREMENTS,ATTR_TENDER_ADDITIONAL_INFORMATION"

  Set NewObj = ThisObject.Objects.Create("OBJECT_PURCHASE_DOC")
  NewObj.Attributes("ATTR_PURCHASE_DOC_TYPE").Classifier = _
    ThisApplication.Classifiers.Find("Вид документа закупки").Classifiers.Find("Информационная карта")
  ThisApplication.ExecuteScript "CMD_DLL","AttrsSyncBetweenObjs", ThisObject, NewObj, AttrStr
  ThisApplication.ExecuteScript "OBJECT_PURCHASE_DOC","Pricesync", NewObj
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = NewObj
  If Dlg.Show Then
'    Call CheckAttrs(ThisForm,ThisObject)
  End If
End Sub

'Процедура управления доступностью элементов на форме
Sub CheckAttrs(Form,Obj)
  ThisScript.SysAdminModeOn
 Form.Controls("ATTR_TENDER_ITEM_PRICE_MAX_VALUE").ReadOnly = True
  AttrStr = "ATTR_NDS_VALUE,ATTR_LOT_NDS_VALUE,ATTR_TENDER_START_END_WORK_DATA,ATTR_TENDER_INVOCE_PUBLIC_DATA," &_
  "ATTR_TENDER_ADVANCE_PLAN_PAY,ATTR_TENDER_ADDITIONAL_REQUIREMENTS,ATTR_TENDER_BID_REQUIREMENTS," &_
  "ATTR_TENDER_GUARANTEE_REQUIREMENTS,ATTR_TENDER_RF_CONF_REQUIREMENTS_DOC_LIST," &_
  "ATTR_TENDER_EXPERIENCE_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_PERSONAL_CONF_REQUIREMENTS_DOC_LIST," &_
  "ATTR_TENDER_RIG_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_ISO9001_REQUIREMENTS,ATTR_TENDER_ADDITIONAL_INFORMATION,ATTR_TENDER_ITEM_PRICE_MAX_VALUE"
  
'  "ATTR_TENDER_ITEM_PRICE_MAX_VALUE," &_
  Arr = Split(AttrStr,",")
  Check = True
  Set Doc = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","InfoDocGet",ThisObject)
  If not Doc is Nothing Then Check = False
  
  For i = 0 to Ubound(Arr)
    AttrName = Arr(i)
    If Form.Controls.Has(AttrName) Then
      Form.Controls(AttrName).ReadOnly = Check
    End If
  Next
 Call CheckBtn(Form,Obj)
End Sub

'Процедура управления доступностью элементов на форме
Sub CheckBtn(Form,Obj)
  ThisScript.SysAdminModeOn
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSaveCancelBlock", Form, Obj 
  Check = True
  Set Doc = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","InfoDocGet",ThisObject)
  If not Doc is Nothing Then Check = False
   If Check = True Then
    If Obj.StatusName = "STATUS_TENDER_IN_WORK" and _
    Obj.RolesForUser(ThisApplication.CurrentUser).Has("ROLE_PURCHASE_RESPONSIBLE") Then
    Form.Controls("BUTTON_INFO_DOC_CREATE").Enabled = True
    End If
    Else
    Form.Controls("BUTTON_INFO_DOC_CREATE").Enabled = Check
    
'  msgbox Check
  Form.Controls("BUTTON_EDIT").Enabled = not Check
'  Form.Controls("BUTTON_EDIT").ReadOnly = Check
  Form.Controls("BUTTON_REFRESH").Enabled = not Check
  End If
  ThisScript.SysAdminModeOff
End Sub


'Событие - изменение атрибутов
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
 ThisApplication.Dictionary(Obj.GUID).Item("ObjEdit") = True
 ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSaveCancelBlock", Form, Obj 
  If Attribute.AttributeDefName = "ATTR_TENDER_ITEM_PRICE_MAX_VALUE" Then
'    Call Pricesync(Obj)
      ThisApplication.ExecuteScript "OBJECT_PURCHASE_DOC","Pricesync", Obj  
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
    
' AttrStr = "ATTR_NDS_VALUE,ATTR_LOT_NDS_VALUE,ATTR_TENDER_START_END_WORK_DATA,ATTR_TENDER_INVOCE_PUBLIC_DATA," &_
'  "ATTR_TENDER_ADVANCE_PLAN_PAY,ATTR_TENDER_ADDITIONAL_REQUIREMENTS,ATTR_TENDER_BID_REQUIREMENTS," &_
'  "ATTR_TENDER_GUARANTEE_REQUIREMENTS,ATTR_TENDER_RF_CONF_REQUIREMENTS_DOC_LIST," &_
'  "ATTR_TENDER_EXPERIENCE_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_PERSONAL_CONF_REQUIREMENTS_DOC_LIST," &_
'  "ATTR_TENDER_RIG_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_ISO9001_REQUIREMENTS,ATTR_TENDER_ADDITIONAL_INFORMATION,ATTR_TENDER_ITEM_PRICE_MAX_VALUE"  
    
'  Call AttrsSyncCard(Obj)
  End If
End Sub

'Процедура проверки и окраски атрибута Срок начала выполнения работ
Sub StartWorkDataCheck(Form,Obj)
  If Obj.Attributes.Has("ATTR_TENDER_START_WORK_DATA") and Obj.Attributes.Has("ATTR_TENDER_WORK_START_PLAN_DATA") Then
    Set Txt = Form.Controls("T_ATTR_TENDER_START_WORK_DATA").ActiveX
    If Obj.Attributes("ATTR_TENDER_START_WORK_DATA").Value <> Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA").Value Then
      Txt.ForeColor = RGB(255,0,0)
    Else
      Txt.ForeColor = RGB(0,0,0)
    End If
  End If
End Sub

'Процедура проверки и окраски атрибута Срок окончания выполнения работ
Sub EndWorkDataCheck(Form,Obj)
  If Obj.Attributes.Has("ATTR_TENDER_END_WORK_DATA") and Obj.Attributes.Has("ATTR_TENDER_WORK_END_PLAN_DATA") Then
    Set Txt = Form.Controls("T_ATTR_TENDER_END_WORK_DATA").ActiveX
    If Obj.Attributes("ATTR_TENDER_END_WORK_DATA").Value <> Obj.Attributes("ATTR_TENDER_WORK_END_PLAN_DATA").Value Then
      Txt.ForeColor = RGB(255,0,0)
    Else
      Txt.ForeColor = RGB(0,0,0)
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
'Процедура управления доступностью кнопки "Согласовать"
Sub TuApproveBtnEnable(Form,Obj)
 Set Doc = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","InfoDocGet",Obj)
 Set Roles = Obj.RolesForUser(CU)
  If not Doc is Nothing Then
     If Doc.StatusName = "STATUS_KD_AGREEMENT" or Doc.StatusName = "STATUS_DOC_IN_WORK" Then
      If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
      Form.Controls("BUTTON_TO_APPROVE").Enabled = True
'      Form.Controls("BUTTON_TO_APPROVE").ReadOnly = False
      End If
     End If
  End If
End Sub

Sub Form_TableAttributeChange(Form, Object, TableAttribute, TableRow, ColumnAttributeDefName, OldTableRow, Cancel)
  If TableAttribute.AttributeDefName = "ATTR_TENDER_ITEM_PRICE_MAX_VALUE" Then
    If ColumnAttributeDefName = "ATTR_TENDER_NDS_PRICE" Then
      Object.Dictionary.Item("CheckNdsPrice") = True
      Set Txt = Form.Controls("T_ATTR_TENDER_ITEM_PRICE_MAX_VALUE").ActiveX
      Check = PriceWithNDScheck(Object)
      If Check = False Then
        Txt.ForeColor = RGB(255,0,0)
      Else
        Txt.ForeColor = RGB(0,0,0)
      End If
    End If
  End If
End Sub

'Кнопка - Проверить "Расчетная (максимальная) цена предмета закупки (договора)"
Sub BUTTON_PRICE_CHECK_OnClick()
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnPriceCheck",ThisForm, ThisObject 
End Sub

'Кнопка - Открыть
Sub BUTTON_EDIT_OnClick()
  Set Doc = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","InfoDocGet",ThisObject)
  If not Doc is Nothing Then
'    ThisObject.SaveChanges 
    ThisForm.close 
'     ThisObject.Refresh
Call AttrsSyncCard(ThisObject)  
'   If Dlg.Show then

''ThisForm.Refresh
'''ThisObject.Refresh
'   End If
    
    
'    Call ThisApplication.ExecuteScript("OBJECT_TENDER_INSIDE","AttrsSync",ThisObject)
    Doc.Update
    Set Dlg = ThisApplication.Dialogs.EditObjectDlg
    Dlg.Object = Doc
    Dlg.Show
    End If
 End Sub

''Функция возвращает документ закупки с типом "Информационная карта"
'Function InfoDocGet(Obj)
'  Set InfoDocGet = Nothing
'  Set Clf0 = ThisApplication.Classifiers.Find("Вид документа закупки")
'  If Clf0 is Nothing Then Exit Function
'  Set Clf = Clf0.Classifiers.Find("Информационная карта")
'  If Clf is Nothing Then Exit Function
'  AttrName = "ATTR_PURCHASE_DOC_TYPE"
'  For Each Doc in Obj.Objects
'    If Doc.Attributes.Has(AttrName) Then
'      If Doc.Attributes(AttrName).Empty = False Then
'        If not Doc.Attributes(AttrName).Classifier is Nothing Then
'          If Doc.Attributes(AttrName).Classifier.SysName = Clf.SysName Then
'            Set InfoDocGet = Doc
'            Exit Function
'          End If
'        End If
'      End If
'    End If
'  Next
'End Function

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
      ThisObject.Update
      ThisForm.Refresh
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
  
  'Удаление строк из таблицы возможных участников
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
  ThisObject.Update
  ThisForm.Refresh
End Sub
'Событие - выделение в выборке возможных участников
Sub QUERY_TENDER_POSSIBLE_CLIENT_Selected(iItem, action)
  If iItem <> -1 Then
    ThisForm.Controls("BUTTON_DEL").Enabled = True
  Else
    ThisForm.Controls("BUTTON_DEL").Enabled = False
  End If
End Sub

'Кнопка - Сохранить
Sub BUTTON_CUSTOM_SAVE_OnClick()
Set Form = ThisForm
Set Obj = ThisObject
  ThisScript.SysAdminModeOn
  Key = Msgbox("Сохранить внесенные изменения?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
  ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = False
  Obj.Dictionary.Item("FormActive") = thisform.SysName
  Call AttrsSyncCard(ThisObject)
  Call CheckAttrs(Form,Obj)
' ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnEnable0",Form, Obj 
  Obj.SaveChanges
  'Call BtnEnable0(ThisForm,ThisObject)
End Sub

'Кнопка - Отменить
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
'Кнопка На согласование 
Sub BUTTON_TO_APPROVE_OnClick()
'  Для всех в статусе "На согласовании" активная форма Документ.Согласование
   
  Set Doc = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","InfoDocGet",ThisObject)
  If not Doc is Nothing Then
  If Doc.StatusName = "STATUS_KD_AGREEMENT" or Doc.StatusName = "STATUS_DOC_IN_WORK" Then
    
    ThisObject.SaveChanges
    ThisForm.close 
    Doc.Update
    
    Set Dlg = ThisApplication.Dialogs.EditObjectDlg
    Dlg.Object = Doc
    Dlg.ActiveForm = Dlg.InputForms("FORM_KD_DOC_AGREE")
    Doc.Dictionary.Item("FormActive") = "FORM_KD_DOC_AGREE"
    Dlg.Show
  End If
  End If
End Sub

'Кнопка - Создать договор
'-----------------------------------------------------------------------
Sub BUTTON_ADD_CONTRACT_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnAddContract",ThisForm, ThisObject
End Sub

'Кнопка - Обновить
'-----------------------------------------------------------------------
Sub BUTTON_REFRESH_OnClick()
ThisObject.Dictionary.Item("FormActive") = ThisForm.SysName
ThisObject.Refresh
End Sub

'Кнопка - Создать Техническое задание
'-----------------------------------------------------------------------
Sub BUTTON_ADD_TECH_ORDER_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","NewDocByTipe",ThisObject,"Техническое задание",false,True,false,True
End Sub
'Кнопка - Создать Расчет стоимости
'-----------------------------------------------------------------------
Sub BUTTON_ADD_MAT_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","NewDocByTipe",ThisObject,"Расчет стоимости",false,True,false,True
End Sub
'Кнопка - Создать Коммерческое предложение
'-----------------------------------------------------------------------
Sub BUTTON_ADD_KP_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","NewDocByTipe",ThisObject,"Коммерческое предложение",false,True,false,True
End Sub
'Кнопка - Создать Проект договора
'-----------------------------------------------------------------------
Sub BUTTON_ADD_ORDER_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","NewDocByTipe",ThisObject,"Проект договора",false,True,false,True
End Sub
'Кнопка - Создать Спецификацию
'-----------------------------------------------------------------------
Sub BUTTON_ADD_SPEC_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","NewDocByTipe",ThisObject,"Спецификация",false,True,false,True 
End Sub
'Кнопка - Создать Календарный план
'-----------------------------------------------------------------------
Sub BUTTON_ADD_PLAN_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","NewDocByTipe",ThisObject.parent,"Календарный план",false,True,false,True 
End Sub

'Кнопка - Добавить Документ закупки
'-----------------------------------------------------------------------
Sub BUTTON_DOC_ADD_OnClick()
  Set NewObj = ThisObject.Objects.Create("OBJECT_PURCHASE_DOC")
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = NewObj
  Dlg.Show
End Sub

'Кнопка - Удалить Документ закупки
'-----------------------------------------------------------------------
Sub BUTTON_DOC_DEL_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnDocDelOnclic",ThisForm, ThisObject
End Sub

'Кнопка - Редактировать Документ закупки
'-----------------------------------------------------------------------
Sub BUTTON_DOC_EDIT_OnClick()

  Set Query = ThisForm.Controls("QUERY_TENDER_DOCS_WK")
  Set Objects = Query.SelectedObjects
  If Objects.Count = 1 Then
    Set Dlg = ThisApplication.Dialogs.EditObjectDlg
    Dlg.Object = Objects(0)
  End If
End Sub


'Событие - Выделение в выборке Документов закупки
'-----------------------------------------------------------------------
Sub QUERY_TENDER_DOCS_WK_Selected(iItem, action)
  Set Query = ThisForm.Controls("QUERY_TENDER_DOCS_WK")
  Set Objects = Query.SelectedObjects
  If iItem <> -1 Then
    If Objects.Count => 1 Then
      ThisForm.Controls("BUTTON_DOC_EDIT").Enabled = True
      flag = ThisApplication.ExecuteScript("OBJECT_PURCHASE_DOC","UserCanDelete",ThisApplication.CurrentUser,Objects(0))
      ThisForm.Controls("BUTTON_DOC_DEL").Enabled = True And flag
    Else
      ThisForm.Controls("BUTTON_DOC_EDIT").Enabled = False
      ThisForm.Controls("BUTTON_DOC_P_DEL").Enabled = False
    End If
  Else
    ThisForm.Controls("BUTTON_DOC_DEL").Enabled = False
    ThisForm.Controls("BUTTON_DOC_EDIT").Enabled = False
  End If
End Sub

'Sub Object_BeforeModify(Obj, TObj, bCancel)
'  ThisApplication.ExecuteScript "OBJECT_TENDER_INSIDE","AttrsSync", Obj
'  ThisForm.Refresh
'End Sub

'Процедура синхронизации атрибутов в информационную карту
Sub AttrsSyncCard(Obj)
  ThisScript.SysAdminModeOn
  For Each Child in Obj.Content
    If Child.ObjectDefName = "OBJECT_PURCHASE_DOC" Then
      If Child.Attributes.Has("ATTR_PURCHASE_DOC_TYPE") Then
    
      AttrStr = "ATTR_TENDER_FACT_MATERIAL_TAKE_OFF_DATA,ATTR_TENDER_ITEM_PRICE_MAX_VALUE," &_
      "ATTR_NDS_VALUE,ATTR_LOT_NDS_VALUE,ATTR_TENDER_START_WORK_DATA,ATTR_TENDER_INVOCE_PUBLIC_DATA," &_
      "ATTR_TENDER_ADVANCE_PLAN_PAY,ATTR_TENDER_ADDITIONAL_REQUIREMENTS,ATTR_TENDER_BID_REQUIREMENTS," &_
      "ATTR_TENDER_GUARANTEE_REQUIREMENTS,ATTR_TENDER_RF_CONF_REQUIREMENTS_DOC_LIST," &_
      "ATTR_TENDER_EXPERIENCE_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_PERSONAL_CONF_REQUIREMENTS_DOC_LIST," &_
      "ATTR_TENDER_RIG_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_ISO9001_REQUIREMENTS,ATTR_TENDER_SMALL_BUSINESS_FLAG," &_
      "ATTR_TENDER_ADDITIONAL_INFORMATION,ATTR_TENDER_END_WORK_DATA,ATTR_TENDER_POSSIBLE_CLIENT"
      ThisApplication.ExecuteScript "CMD_DLL","AttrsSyncBetweenObjs", Obj, Child, AttrStr

      End If
    End If
  Next
End Sub

Sub BUTTON_ASK_UNLOCK_OnClick()
 ThisScript.SysAdminModeOn
 Set Doc = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","InfoDocGet",ThisObject)
 If Doc is Nothing Then
  Msgbox "Информационная карта еще не создана, или удалена."
  Exit Sub
 End If
 Set CU = ThisApplication.CurrentUser
 If not Doc is Nothing and not Doc.Permissions.LockUser is nothing Then
  Key = Msgbox ("Послать сообщение с просьбой закрыть карточку Информационной карты пользователю " & Doc.Permissions.LockUser.Description & "?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
 ThisApplication.ExecuteScript "CMD_MESSAGE","SendMessage",6018, Doc.Permissions.LockUser,Doc, Nothing, CU.Description, Doc.Description, Date
 End If
 If not Doc.Permissions.Locked = True or Doc.Permissions.LockUser is nothing Then
   Key = Msgbox ("Объект уже разблокирован. Обновить форму?",vbQuestion+vbYesNo) 
     If Key = vbNo Then Exit Sub
     ThisForm.Close False
     Set Dlg = ThisApplication.Dialogs.EditObjectDlg
     Dlg.Object = ThisObject
'    Dlg.ActiveForm = Dlg.InputForms(ThisForm.SysName)
    ThisObject.Dictionary.Item("FormActive") = ThisForm.SysName
    Dlg.Show
 End If
End Sub

'Кнопка Редактировать на форме
Sub BUTTON_RED_OnClick()
Set Form = ThisForm
Set Obj = ThisObject
  Set Doc = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","InfoDocGet",Obj)
  Set CU = ThisApplication.CurrentUser
  If not Doc is Nothing Then
   If Doc.Permissions.Locked = True Then
    if not Doc.Permissions.LockUser is nothing Then
     If Doc.Permissions.LockUser.SysName <> CU.SysName Then  
     ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","InfoDocFrmCtrlLock",Form, Obj 
     Exit Sub
     End If
    End If
   End If
   
'   msgbox Doc.Permissions.Locked
'   If Doc.Permissions.Locked <> True Then
 
'     msgbox Doc.Permissions.Locked
     ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","InfoDocFrmCtrlUnlock",Form, Obj
     'Блокируем Инф карту, разблокируем контролы формы
      Doc.lock 2
   ' Доступность контролов
    Call StartWorkDataCheck(Form,Obj)
    Call EndWorkDataCheck(Form,Obj)
    ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnEnable0",Form, Obj 
    Form.Controls("BUTTON_DEL").Enabled = False
    Form.Controls("BUTTON_DOC_DEL").Enabled = False
    Form.Controls("BUTTON_DOC_EDIT").Enabled = False 
   Call PriceCheckBtnEnable(Form,Obj)
   Call CheckAttrs(Form,Obj)
   Call TuApproveBtnEnable(Form,Obj)
   'Блокируем кнопку для повторного нажатия
   Form.Controls("BUTTON_RED").Visible = False
   Form.Controls("BUTTON_UNRED").Visible = True
  'Окраска цены с НДС при отклонении
  'Set Txt = Form.Controls("T_ATTR_TENDER_ITEM_PRICE_MAX_VALUE").ActiveX
  'Check = PriceWithNDScheck(Obj)
  'If Check = False Then Txt.ForeColor = RGB(255,0,0)
  'Окраска дат начала и окончания работ 

  
End If
End Sub
'Кнопка завершить редактирование на форме
Sub BUTTON_UNRED_OnClick()
Set Form = ThisForm
Set Obj = ThisObject
 If ThisApplication.Dictionary(Obj.GUID).Exists("ObjEdit") Then
  If ThisApplication.Dictionary(Obj.GUID).Item("ObjEdit") = True Then
  Call BUTTON_CUSTOM_SAVE_OnClick()
  End If
 End If

 Form.Controls("BUTTON_UNRED").Visible = False 
 Form.Controls("BUTTON_RED").Visible = True
 ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","InfoDocFrmCtrlLockAll",Form, Obj 
End Sub

' Кнопка Выгрузить файлы
Sub BUTTON_EXPORT_FILES_OnClick()

'Call PurchaseFilesUpload(ThisObject,False)

  ThisScript.SysAdminModeOn
  Count = 0
  Path = ""
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","PurchaseDocsFilesUpload",ThisObject,Count,Path  'Call PurchaseDocsFilesUpload(ThisObject,Count,Path)
  If Count > 0 Then
  Msgbox "Файлы выгружены в """ & Path & """. "
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
