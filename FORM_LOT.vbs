' Форма ввода - Лот
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.
Use CMD_TENDER_IMPORT_LOT_VAL

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Call SetControls(Form, Obj)
  Call BtnEnable0(Form,Obj)
  Set CU = ThisApplication.CurrentUser
  Set Roles = Obj.RolesForUser(CU)
  Call TableNumFill(Obj,Form)
  If Obj.Attributes.Has("ATTR_LOT_NDS_VALUE") Then
  a = Obj.Attributes("ATTR_LOT_NDS_VALUE").Value
  Form.Controls("ATTR_LOT_NDS_VALUE_TEXT").ActiveX.Text = a
  End if
'  Call LotPriceCalc(Obj)
End Sub

' Событие изменения атрибутов
'____________________________________________________________________
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  If Attribute.AttributeDefName = "ATTR_TENDER_LOT_POS_TYPE" Then
    Call SetControls(Form, Obj)
    Call ClearControls(Form, Obj)
  
  ElseIf Attribute.AttributeDefName = "ATTR_LOT_DETAIL" Then 
  Call LotPriceCalc(Obj)
 
'  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnLotPriceCalc",ThisForm, ThisObject  
  End If
End Sub

'Событие изменения табличных атрибутов
'___________________________________________________________
Sub Form_TableAttributeChange(Form, Object, TableAttribute, TableRow, ColumnAttributeDefName, OldTableRow, Cancel)
 If TableAttribute.AttributeDefName = "ATTR_LOT_DETAIL" Then 
 Call LotPriceCalc(Obj) 
'  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnLotPriceCalc",ThisForm, ThisObject  
  End If
End Sub

Sub BUTTON_CUSTOM_SAVE_OnClick()
  ThisScript.SysAdminModeOn
  Key = Msgbox("Сохранить внесенные изменения?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
'  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnLotPriceCalc",ThisForm, ThisObject
'  Call LotPriceCalc(Obj)
'  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnLotPriceCheck",ThisForm, ThisObject  
  ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = False
'  ThisObject.Update
ThisObject.SaveChanges
  'Call BtnEnable0(ThisForm,ThisObject)
End Sub

Sub SetControls(Form, Obj)
  With Form.Controls
    Set posType = Obj.Attributes("ATTR_TENDER_LOT_POS_TYPE").Classifier
    If Not posType Is Nothing Then
      If posType.Description = "Работа" or posType.Description = "Услуга" Then
        Check = True
      Else
        Check = False
      End If
        .Item("ATTR_TENDER_NOMENCLATUR_GROPE_MTR").ReadOnly = Check
        .Item("ATTR_TENDER_FINANS_PAR").ReadOnly = Check
    End If
  End With
End Sub


'Событие закрытия формы
Sub Form_BeforeClose(Form, Obj, Cancel)
'Call LotPriceCalc(Obj)
'ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnLotPriceCalc",ThisForm, ThisObject
'ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnLotPriceCheck",ThisForm, ThisObject  
''  Cancel = Not ThisApplication.ExecuteScript("OBJECT_PURCHASE_DOC","CheckBeforeClose",Obj)
'ThisObject.SaveChanges
''ThisForm.Close True
'ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","ButtonPriceCalc", ,ThisObject.parent
End Sub




'Событие - Дублирование строки в таблице Состав лота
Sub ATTR_LOT_DETAIL_RowDuplicated(nNewRow, nSourceRow)
  Call TableNumFill(ThisObject,ThisForm)
  Call LotPriceCalc(Obj)
'  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnLotPriceCalc",ThisForm, ThisObject
End Sub

'Событие - Новая строка в таблице Состав лота
Sub ATTR_LOT_DETAIL_RowInserted(nRow)
  Call TableNumFill(ThisObject,ThisForm)
End Sub

'Событие - Перед удалением строки в таблице Состав лота
Sub ATTR_LOT_DETAIL_RowBeforeRemove(nRow, bCancel)
'ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnLotPriceCalc",ThisForm, ThisObject
' Key = Msgbox("Удалить позицию?",vbQuestion+vbYesNo)
'  If Key = vbNo Then Exit Sub
'  msgbox nRow
' Set Table = ThisForm.Controls("ATTR_LOT_DETAIL")
 set rows = ThisObject.Attributes("ATTR_LOT_DETAIL").Rows
 set row = rows(nRow)
 Row.Attributes("ATTR_TENDER_PRICE").Value = 0
 Row.Attributes("ATTR_NDS_VALUE").Value = ""
 Row.Attributes("ATTR_TENDER_NDS_PRICE").Value = 0
 
 Call LotPriceCalc(Obj)
 ThisForm.Dictionary.Item("ATTR_LOT_DETAIL") = True
End Sub

'Событие - Смена выделения в таблице Состав лота
Sub ATTR_LOT_DETAIL_SelChanged()
'ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnLotPriceCalc",ThisForm, ThisObject 
'  If ThisForm.Dictionary.Item("ATTR_LOT_DETAIL") = True Then
'    Call TableNumFill(ThisObject,ThisForm) 
'    ThisForm.Dictionary.Item("ATTR_LOT_DETAIL") = False
'  End If
 '   ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnLotPriceCalc",ThisForm, ThisObject 
End Sub

'Sub ATTR_LOT_DETAIL_Refreshed()
'Call LotPriceCalc(Obj)
'End Sub

'Sub ATTR_LOT_DETAIL_CellAfterEdit(nRow, nCol, strLabel, bCancel)
'' ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnLotPriceCalc",ThisForm, ThisObject 
'End Sub

' Присвоение значений ценам лота
'___________________________________________________________________________________________
Sub LotPriceCalc(Obj)
Set Obj = ThisObject
Set Form = ThisForm
  AttrName1 = "ATTR_TENDER_LOT_NDS_PRICE" 'Цена лота с НДС
  AttrName2 = "ATTR_TENDER_LOT_PRICE" 'Цена лота без НДС 
  AttrName5 = "ATTR_LOT_NDS_VALUE" 'Ставка НДС лота
  AttrName7 = "ATTR_TENDER_SUM_NDS" 'Сумма НДС
  AttrName6 = "ATTR_TENDER_LOT_UNIT_PRICE" 'Цена за единицу
  
  P1 = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","BtnLotPriceCalc",ThisForm, Obj, 1)
  P2 = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","BtnLotPriceCalc",ThisForm, Obj, 2)
  P3 = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","BtnLotPriceCalc",ThisForm, Obj, 3)
  P4 = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","BtnLotPriceCalc",ThisForm, Obj, 4)
  P5 = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","BtnLotPriceCalc",ThisForm, Obj, 5)

  Obj.Attributes(AttrName2).Value = Round(P1,2)
  Obj.Attributes(AttrName1).Value = Round(P2,2)
  Obj.Attributes(AttrName5).Value = P3
  Obj.Attributes(AttrName7).Value = Round(P4,2)
  Obj.Attributes(AttrName6).Value = Round(P5,2)
  
  Form.Controls(AttrName2).ActiveX.Text = Round(P1,2)
  Form.Controls(AttrName1).ActiveX.Text = Round(P2,2)
'  Form.Controls(AttrName5).ActiveX.Text = P3
  Form.Controls("ATTR_LOT_NDS_VALUE_TEXT").ActiveX.Text = P3
  Form.Controls(AttrName7).ActiveX.Text = Round(P4,2)
  Form.Controls(AttrName6).ActiveX.Text = Round(P5,2)
'  msgbox P3

'Obj.Attributes(AttrName5).Value = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","BtnLotPriceCalc",ThisForm, Obj, 3)
 End Sub

'Процедура формирования нумерации в таблице Состав лота
Sub TableNumFill(Obj,Form)
  AttrName = "ATTR_LOT_DETAIL"
  If Obj.Attributes.Has(AttrName) = False Then Exit Sub
  Set Rows = Obj.Attributes(AttrName).Rows
  i = 1
  For Each Row in Rows
    If Row.Attributes(0).Value <> CStr(i) Then
      Row.Attributes(0).Value = i
    End If
    i = i + 1
  Next
  If not Form is Nothing Then
    Form.Controls(AttrName).ActiveX.Refresh
  End If
End Sub

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



'Кнопка - Завершить
Sub BUTTON_CLOSE_OnClick()
Key = Msgbox("Завершить лот?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
  ThisApplication.ExecuteScript "CMD_TENDER_LOT_GO_CLOSE", "Main", ThisObject  
  ThisObject.SaveChanges
End Sub

'Кнопка - Аннулировать
Sub BUTTON_NUL_OnClick()
Key = Msgbox("Аннулировать лот?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
   ThisApplication.ExecuteScript "CMD_TENDER_LOT_GO_NUL", "Main", ThisObject
    ThisObject.SaveChanges
End Sub

'Кнопка Вычислить цену лота 
Sub BUTTON_PLAN_PRICE_CALC_OnClick()
'ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnLotPriceCalc",ThisForm, ThisObject 
Call LotPriceCalc(Obj)
End Sub


'Процедура управления доступностью кнопок Завершить и Аннулировать
Sub BtnEnable0(Form,Obj)
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  Set Roles = Obj.RolesForUser(CU)
  Set Dict = ThisApplication.Dictionary(Obj.Guid & " - BlockRoute")
  Dict.RemoveAll
  BtnList = "BUTTON_CLOSE,BUTTON_NUL"
  Arr = Split(BtnList,",")
  
  If ThisApplication.Dictionary(ThisObject.GUID).Exists("ObjEdit") Then
   If ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = True Then
     Dict.Item("BUTTON_CUSTOM_SAVE") = True
      Dict.Item("BUTTON_CUSTOM_CANCEL") = True
    End If
  End If
  
  Select Case Obj.StatusName
    'В работе
    Case "STATUS_LOT_IN_WORK"
      If Roles.Has("ROLE_TENDER_INICIATOR") or Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then      
        Dict.Item("BUTTON_CLOSE") = True
        Dict.Item("BUTTON_NUL") = True         
      End If
      
    'Завершено
    Case "STATUS_LOT_IS_END"
      If Roles.Has("ROLE_TENDER_INICIATOR") or Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then        
          Dict.Item("BUTTON_NUL") = True
      End If    
    
  End Select
  
  'Блокировка кнопок

  For i = 0 to Ubound(Arr)
    BtnName = Arr(i)
    If Dict.Exists(BtnName) Then
      Check = True
    Else
      Check = False
    End If
    If Form.Controls.Has(BtnName) Then
      'Form.Controls(BtnName).Visible = Check
      Form.Controls(BtnName).Enabled = Check
    End If
  Next
End Sub

Sub ClearControls(Form, Obj)
  With Form.Controls
    Set posType = Obj.Attributes("ATTR_TENDER_LOT_POS_TYPE").Classifier
    If Not posType Is Nothing Then
      If posType.Description = "Работа" or posType.Description = "Услуга" Then
        Set cls = Form.Attributes("ATTR_TENDER_NOMENCLATUR_GROPE_MTR").Classifier
        If Not Form.Attributes("ATTR_TENDER_NOMENCLATUR_GROPE_MTR").Classifier Is Nothing Then
          Form.Attributes("ATTR_TENDER_NOMENCLATUR_GROPE_MTR").Classifier = Nothing
        End If
        
        If Not Form.Attributes("ATTR_TENDER_FINANS_PAR").Classifier Is Nothing Then
          Form.Attributes("ATTR_TENDER_FINANS_PAR").Classifier = Nothing
        End If
      End If
    End If
  End With
End Sub

'Sub ATTR_TENDER_LOT_POS_TYPE_Modified()
'  Call SetControls(Form, Obj)
'  Call ClearControls(Form, Obj)
'End Sub

Sub BTN_VAL_LOAD_OnClick()
Call Main(ThisObject)
Call TableNumFill(ThisObject,ThisForm)
Call LotPriceCalc(ThisObject)
End Sub



Sub BUTTON_REM_VAL_OnClick()
' Удаление строк из таблицы
'------------------------------------------------------------------------------

' Set TableForm = ThisForm.Controls("ATTR_LOT_DETAIL")
' 
' ArrayBound = -1
'  With ThisObject.Attributes("ATTR_LOT_DETAIL").Rows
'    SelArr = ThisForm.Controls("ATTR_LOT_DETAIL").SelectedItems
'    On Error Resume Next
'      ArrayBound = UBound(SelArr)
'    On Error GoTo 0
'    If .Count > 0 And ArrayBound > -1 Then
'      For i = ArrayBound To 0 Step -1
'        .Remove SelArr(i)
'      Next
'    End If
'  End With

'  Set GridRoles = ThisForm.Controls("ATTR_LOT_DETAIL").ActiveX
'  ArrRows = GridRoles.SelectedRows
'  For i = Ubound(GridRoles) to 0 Step -1
'    GridRoles.RemoveRow ArrRows(i)
'  Next
'  GridRoles.Redraw




'  Set Rows = ThisForm.Controls("ATTR_LOT_DETAIL").ActiveX.Rows
    Set Rows = ThisObject.attributes("ATTR_LOT_DETAIL").Rows
    Rows.removeall
    Call LotPriceCalc(ThisObject)
'    For each row in rows
'    row.erase
'    Next
'    If Rows.Count > 0 Then
'    msgbox Rows.Count
'      For i = 0 To Rows.Count -1
'      Rows(i).Erase
'      i = i + 1
'      Next
'    End If
End Sub

Sub ATTR_TENDER_LOT_UNIT_PRICE_Modified()
AttrName = "ATTR_TENDER_LOT_UNIT_PRICE"
Set Obj = ThisObject
Obj.Attributes(AttrName).Value = Round(Obj.Attributes(Obj.Attributes(AttrName)).Value,2)
End Sub

Sub ATTR_TENDER_LOT_NDS_PRICE_Modified()
AttrName = "ATTR_TENDER_LOT_NDS_PRICE"
Set Obj = ThisObject
Obj.Attributes(AttrName).Value = Round(Obj.Attributes(Obj.Attributes(AttrName)).Value,2)
End Sub

Sub ATTR_TENDER_SUM_NDS_Modified()
AttrName = "ATTR_TENDER_SUM_NDS"
Set Obj = ThisObject
Obj.Attributes(AttrName).Value = Round(Obj.Attributes(Obj.Attributes(AttrName)).Value,2)
End Sub

Sub ATTR_TENDER_LOT_PRICE_Modified()
AttrName = "ATTR_TENDER_LOT_PRICE"
Set Obj = ThisObject
Obj.Attributes(AttrName).Value = Round(Obj.Attributes(Obj.Attributes(AttrName)).Value,2)
End Sub
