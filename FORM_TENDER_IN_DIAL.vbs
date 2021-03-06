' Форма ввода - Договор (Внутреняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "CMD_DLL"
USE "CMD_DLL_COMMON_BUTTON"


Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Set CU = ThisApplication.CurrentUser
  If ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsGroupMember",CU,"GROUP_CONTRACTS") = True Then 
  ThisForm.Controls("BUTTON_ADD").Enabled = True
  End If
End Sub


'Кнопка - Создать договор
Sub BUTTON_ADD_OnClick()
  'Создание договора
  
  If ThisObject.ObjectDefName = "OBJECT_TENDER_INSIDE" Then
    Set cClass = ThisApplication.Classifiers.FindBySysId("NODE_CONTRACT_EXP")
  ElseIf ThisObject.ObjectDefName = "OBJECT_PURCHASE_OUTSIDE" Then
    Set cClass = ThisApplication.Classifiers.FindBySysId("NODE_CONTRACT_PRO")
  End If
  
  If Not cClass Is Nothing Then 
    Set Contract = ThisApplication.ExecuteScript("CMD_DLL_CONTRACTS","CreateContractByClass",ThisObject,cClass)
  Else
    Set Contract = ThisApplication.ExecuteScript("CMD_DLL_CONTRACTS","CreateContract",ThisObject)
  End If
'  If ThisApplication.ObjectDefs("OBJECT_CONTRACTS").Objects.Count > 0 Then
'    Set Parent = ThisApplication.ObjectDefs("OBJECT_CONTRACTS").Objects(0)
'  Else
'    Exit Sub
'  End If
'  Set Contract = Parent.Objects.Create(ThisApplication.ObjectDefs("OBJECT_CONTRACT"))
'  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
'  Dlg.Object = Contract
  
  If Contract Is Nothing Then Exit Sub
  'Заполнение атрибутов
  AttrName0 = "ATTR_TENDER_SMOLL_PRICE_FLAG"
  AttrName1 = "ATTR_CONTRACT_LOWCOST"
  If ThisObject.Attributes.Has(AttrName0) and Contract.Attributes.Has(AttrName1) Then
    Call AttrValueCopy(ThisObject.Attributes(AttrName0),Contract.Attributes(AttrName1))
  End If
  
'  AttrName0 = "ATTR_TENDER_METHOD_NAME"
'  AttrName1 = "ATTR_PURCHASE_FROM_EI"
'  If ThisObject.Attributes.Has(AttrName0) and Contract.Attributes.Has(AttrName1) Then
'    Val = ThisObject.Attributes(AttrName0).Value
'    If StrComp(Val,"Закупка у единственного поставщика",vbTextCompare) = 0 Then
'      Contract.Attributes(AttrName1).Value = True
'    End If
'  End If
'  
'  AttrName0 = "ATTR_TENDER_REASON_POINT"
'  AttrName1 = "ATTR_PURCHASE_BASIS"
'  If ThisObject.Attributes.Has(AttrName0) and Contract.Attributes.Has(AttrName1) Then
'    Call AttrValueCopy(ThisObject.Attributes(AttrName0),Contract.Attributes(AttrName1))
'  End If
  
'  AttrName0 = "ATTR_TENDER_NUM_EIS"
'  AttrName1 = "ATTR_EIS_NUM"
'  If ThisObject.Attributes.Has(AttrName0) and Contract.Attributes.Has(AttrName1) Then
'    Call AttrValueCopy(ThisObject.Attributes(AttrName0),Contract.Attributes(AttrName1))
'  End If
  
  AttrName0 = "ATTR_TENDER_INVITATION_DATA_EIS"
  AttrName1 = "ATTR_EIS_PUBLISH"
  If ThisObject.Attributes.Has(AttrName0) and Contract.Attributes.Has(AttrName1) Then
    Call AttrValueCopy(ThisObject.Attributes(AttrName0),Contract.Attributes(AttrName1))
  End If
  
  AttrName0 = "ATTR_TENDER_EXECUT_DATA"
  AttrName1 = "ATTR_FULFILLDATE_PLAN"
  If ThisObject.Attributes.Has(AttrName0) and Contract.Attributes.Has(AttrName1) Then
    Call AttrValueCopy(ThisObject.Attributes(AttrName0),Contract.Attributes(AttrName1))
  End If
  
'  AttrName0 = "ATTR_TENDER_SMSP_EXCLUDE_CODE"
'  AttrName1 = "ATTR_SMSP_EXCLUDE_CODE"
'  If ThisObject.Attributes.Has(AttrName0) and Contract.Attributes.Has(AttrName1) Then
'    Call AttrValueCopy(ThisObject.Attributes(AttrName0),Contract.Attributes(AttrName1))
'  End If
  
'  AttrName0 = "ATTR_TENDER_WINER_SMOLL_FLAG_EIS"
'  AttrName1 = "ATTR_KD_COREDENT_TYPE"
'  If ThisObject.Attributes.Has(AttrName0) and Contract.Attributes.Has(AttrName1) Then
'    Call AttrValueCopy(ThisObject.Attributes(AttrName0),Contract.Attributes(AttrName1))
'  End If
  
'  AttrName1 = "ATTR_AUTOR"
'  If Contract.Attributes.Has(AttrName1) Then
'    Contract.Attributes(AttrName1).User = ThisApplication.CurrentUser
'  End If
  
'  AttrName1 = "ATTR_TENDER"
'  If Contract.Attributes.Has(AttrName1) Then
'    Contract.Attributes(AttrName1).Object = ThisObject
'  End If
  
'  Dlg.Show
End Sub

'Кнопка - Редактировать договор
Sub BUTTON_EDIT_OnClick()
  Set Query = ThisForm.Controls("QUERY_TENDER_CONTRACT")
  Set Objects = Query.SelectedObjects
  If Objects.Count = 1 Then
    Set Dlg = ThisApplication.Dialogs.EditObjectDlg
    Dlg.Object = Objects(0)
    Dlg.Show
  End If
End Sub

'Событие - Выделение в выборке лотов
Sub QUERY_TENDER_CONTRACT_Selected(iItem, action)
  Set Query = ThisForm.Controls("QUERY_TENDER_CONTRACT")
  Set Objects = Query.SelectedObjects
  If iItem <> -1 Then
    If Objects.Count = 1 Then
      ThisForm.Controls("BUTTON_EDIT").Enabled = True
    Else
      ThisForm.Controls("BUTTON_EDIT").Enabled = False
    End If
  Else
    ThisForm.Controls("BUTTON_EDIT").Enabled = False
  End If
End Sub

