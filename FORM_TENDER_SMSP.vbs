' Форма ввода - СМСП
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.


Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Call TenderSMSPEnable(Obj,Form)
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  If Attribute.AttributeDefName = "ATTR_TENDER_SMSP_SUBCONTRACT_SUMM" Then
    Call TenderSMSPEnable(Obj,Form)
  End If
End Sub

'Процедура управления доступностью атрибута Сумма субподряда СМСП
Sub TenderSMSPEnable(Obj,Form)
  Form.Controls("ATTR_TENDER_SMSP_SUBCONTRACT_SUMM").ReadOnly = not Obj.Attributes("ATTR_TENDER_SMSP_SUBCONTRACT_FLAG").Value
End Sub

