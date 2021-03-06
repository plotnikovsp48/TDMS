' Форма ввода - Сроки (внутренняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Arr = Split("ATTR_TENDER_PRESENT_PLAN_DATA,ATTR_TENDER_STOP_TIME,ATTR_TENDER_CHECK_TIME,"&_
  "ATTR_TENDER_CHECK_END_TIME,ATTR_TENDER_DIAL_START_DATA,ATTR_TENDER_DIAL_END_DATA,ATTR_TENDER_EXECUT_DATA",",")
  Set CU = ThisApplication.CurrentUser
  If CU.Groups.Has("GROUP_TENDER_INSIDE") = False Then
    For i = 0 to Ubound(Arr)
      Form.Controls(Arr(i)).ReadOnly = True
    Next
  End If
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","AutoDateCalcVSCheck",Form, Obj, Attribute, Cancel, OldAttribute
'  'Срок представления ЗД (план)
'  If Attribute.AttributeDefName = "ATTR_TENDER_PLAN_ZD_PRESENT" Then
'    Call DatesCalculateA(Obj)
'    Call DatesCalculateA_1(Obj)
'    Call DatesCalculateB(Obj)
'    Call DatesCalculateC(Obj)
'    Call DatesCalculateC_1(Obj)
'    Call DatesAutoCheck(Obj)
'    Call DatesNul(Obj)
'  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_PRESENT_PLAN_DATA" Then
'    Data1 = Obj.Attributes("ATTR_TENDER_PLAN_ZD_PRESENT")
'    Data2 = Attribute.Value
'    Call SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
'    Cancel = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Attr1)

'    Call DatesCalculateA_1(Obj) 
'    Call DatesCalculateB(Obj)
'    Call DatesCalculateC(Obj) 
'    Call DatesCalculateC_1(Obj)  
'  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_STOP_TIME" Then
'    Data1 = Obj.Attributes("ATTR_TENDER_PRESENT_PLAN_DATA")
'    Data2 = Attribute.Value
'    Call SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
'    Cancel = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Attr2)

'    Call DatesCalculateB(Obj)
'    Call DatesCalculateC(Obj)
'    Call DatesCalculateC_1(Obj)
'  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_CHECK_TIME" Then
'    Data1 = Obj.Attributes("ATTR_TENDER_STOP_TIME")
'    Data2 = Attribute.Value
'    Delta = 0
'    Cancel = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Delta)
'    Call DatesCalculateC(Obj)
'    Call DatesCalculateC_1(Obj)
'  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_CHECK_END_TIME" Then
'    Data1 = Obj.Attributes("ATTR_TENDER_STOP_TIME")
'    Data2 = Attribute.Value
'    Call SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
'    Cancel = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Attr3)
'    Call DatesCalculateC(Obj)
'    Call DatesCalculateC_1(Obj)
'  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_DIAL_START_DATA" Then
'    Data1 = Obj.Attributes("ATTR_TENDER_CHECK_END_TIME")
'    Data2 = Attribute.Value
'    Delta = 0
'    Cancel = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Delta)
'    Call DatesCalculateC_1(Obj)  
'  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_DIAL_END_DATA" Then
'    Data1 = Obj.Attributes("ATTR_TENDER_DIAL_START_DATA")
'    Data2 = Attribute.Value
'    Call SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
'    Cancel = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Attr4)
'    If Cancel Then Exit Sub
'      If Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA").Empty = False Then
'      Data1 = Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA")
'      If Data2 > Data1 Then
'        msgbox "Дата начала работ по предмету закупки [" & Data1 & _
'                "] наступает раньше даты заключения договора [" & Data2 & "]!",_
'                        vbExclamation,"Внимание"
'      End If
'    End If
'    
'   ElseIf Attribute.AttributeDefName = "ATTR_TENDER_WORK_START_PLAN_DATA" Then 
'   If Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA").Empty = False Then 
'    If Obj.Attributes("ATTR_TENDER_DIAL_END_DATA").Empty = False Then
'     If Obj.Attributes("ATTR_TENDER_WORK_END_PLAN_DATA").Empty = False Then
'      If Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA") > Obj.Attributes("ATTR_TENDER_WORK_END_PLAN_DATA") Then
'      Obj.Attributes("ATTR_TENDER_WORK_END_PLAN_DATA") = Empty
'      End If
'     End If
'    Data1 = Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA")
'    Data2 = Obj.Attributes("ATTR_TENDER_DIAL_END_DATA")
'    If Data2 > Data1 Then
'        msgbox "Дата начала работ по предмету закупки [" & Data1 & _
'                "] наступает раньше даты заключения договора [" & Data2 & "]!",_
'                        vbExclamation,"Внимание"
'      End If
'    End If
'    End If
'  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_WORK_END_PLAN_DATA" Then 
'    Data1 = Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA")
'    Data2 = Attribute.Value
'    Delta = 0
'    Cancel = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Delta)

'    Call DatesCalculateDE(Obj)
'  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_PAY_CONDITIONS" Then  
'    If Attribute.Value < 0 Then
'      msgbox "Введено неверное значение",vbExclamation,"Ошибка"
'      Cancel = True
'    End If
'    Call DatesCalculateDE(Obj)
'  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_EXECUT_DATA" Then 
'    Data1 = Obj.Attributes("ATTR_TENDER_WORK_END_PLAN_DATA")
'    Data2 = Attribute.Value
'    Delta = Obj.Attributes("ATTR_TENDER_PAY_CONDITIONS")
'    Cancel = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMaxData",Data1,Data2,Delta)
'  End If
End Sub

'Sub DatesCalculateA(Obj)
'  Call SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
'  A = 0
'  'Срок представления ЗД (план)
'  AttrName = "ATTR_TENDER_PLAN_ZD_PRESENT"
'  If Obj.Attributes.Has(AttrName) Then
'    If Obj.Attributes(AttrName).Empty = False Then
'      A = Obj.Attributes(AttrName).Value
'    End If
'  End If
'  'Дата объявления о закупке (план)
'  AttrName = "ATTR_TENDER_PRESENT_PLAN_DATA"
'  If Obj.Attributes.Has(AttrName) Then
'    Obj.Attributes(AttrName).Value = A + Attr1
'  End If
''  'Дата окончания приема заявок (план)
''  AttrName = "ATTR_TENDER_STOP_TIME"
''  If Obj.Attributes.Has(AttrName) Then
''    Obj.Attributes(AttrName).Value = A + Attr1 + Attr2
''  End If
'End Sub
'  
'Sub DatesCalculateA_1(Obj)
'  Call SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
'  A = 0
'  'Дата объявления о закупке (план)
'  AttrName = "ATTR_TENDER_PRESENT_PLAN_DATA"
'  If Obj.Attributes.Has(AttrName) Then
'    If Obj.Attributes(AttrName).Empty = False Then
'      A = Obj.Attributes(AttrName).Value
'    End If
'  End If
'  'Дата окончания приема заявок (план)
'  AttrName = "ATTR_TENDER_STOP_TIME"
'  If Obj.Attributes.Has(AttrName) Then
'    Obj.Attributes(AttrName).Value = A + Attr2
'  End If
'End Sub

'Sub DatesCalculateB(Obj)
'  B = 0
'  Call SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
'  'Дата окончания приема заявок (план)
'  AttrName = "ATTR_TENDER_STOP_TIME"
'  If Obj.Attributes.Has(AttrName) Then
'    B = Obj.Attributes(AttrName).Value
'  End If
'  'Дата начала подведения итогов закупки (план)
'  AttrName = "ATTR_TENDER_CHECK_TIME"
'  If Obj.Attributes.Has(AttrName) Then
'    Obj.Attributes(AttrName).Value = B
'  End If
'  'Дата окончания подведения итогов закупки (план)
'  AttrName = "ATTR_TENDER_CHECK_END_TIME"
'  If Obj.Attributes.Has(AttrName) Then
'    Obj.Attributes(AttrName).Value = B + Attr3
'  End If
'End Sub

'Sub DatesCalculateC(Obj)
'  C = 0
'  Call SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
'  'Дата окончания подведения итогов закупки (план)
'  AttrName = "ATTR_TENDER_CHECK_END_TIME"
'  If Obj.Attributes.Has(AttrName) Then
'    C = Obj.Attributes(AttrName).Value
'  End If
'  'Дата начала заключения договора по предмету закупки(план)
'  AttrName = "ATTR_TENDER_DIAL_START_DATA"
'  If Obj.Attributes.Has(AttrName) Then
'    Obj.Attributes(AttrName).Value = C
'  End If
'End Sub

'Sub DatesCalculateC_1(Obj)
'  C = 0
'  Call SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
'  'Дата начала заключения договора по предмету закупки(план)
'  AttrName = "ATTR_TENDER_DIAL_START_DATA"
'  If Obj.Attributes.Has(AttrName) Then
'    C = Obj.Attributes(AttrName).Value
'  End If
'  'Дата окончания заключения договора по предмету закупки (план)
'  AttrName = "ATTR_TENDER_DIAL_END_DATA"
'  If Obj.Attributes.Has(AttrName) Then
'    Obj.Attributes(AttrName).Value = C + Attr4
'  End If
'End Sub

''Процедура подсчета дат
'Sub DatesCalculateDE(Obj)
'  Call SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
'  D = 0
'  E = 0
'  'Дата окончания работ по предмету закупки(план)
'  AttrName = "ATTR_TENDER_WORK_END_PLAN_DATA"
'  If Obj.Attributes.Has(AttrName) Then
'    If Obj.Attributes(AttrName).Empty = False Then
'      D = Obj.Attributes(AttrName).Value
'    End If
'  End If
'  'Условия оплаты по договору, срок оплаты
'  AttrName = "ATTR_TENDER_PAY_CONDITIONS"
'  If Obj.Attributes.Has(AttrName) Then
'    If Obj.Attributes(AttrName).Empty = False Then
'      E = Obj.Attributes(AttrName).Value
'    End If
'  End If
'  'Срок исполнения договора(план)
'  AttrName = "ATTR_TENDER_EXECUT_DATA"
'  If Obj.Attributes.Has(AttrName) Then
'    If D = 0 and E = 0 Then
'      Obj.Attributes(AttrName).Value = ""
'    Else
'      Obj.Attributes(AttrName).Value = D + E
'    End If
'  End If
'End Sub

''Обнуляем даты, если Срок представления ЗД (план) не задан
'Sub DatesNul(Obj)
'  
'  'Срок представления ЗД (план)
'  AttrName = "ATTR_TENDER_PLAN_ZD_PRESENT"
'  If Obj.Attributes.Has(AttrName) Then
'    If Obj.Attributes(AttrName).Empty = True Then
'     Obj.Attributes("ATTR_TENDER_PRESENT_PLAN_DATA") = Empty
'     Obj.Attributes("ATTR_TENDER_STOP_TIME") = Empty
'     Obj.Attributes("ATTR_TENDER_CHECK_TIME") = Empty
'     Obj.Attributes("ATTR_TENDER_DIAL_START_DATA") = Empty
'     Obj.Attributes("ATTR_TENDER_CHECK_END_TIME") = Empty
'     Obj.Attributes("ATTR_TENDER_DIAL_END_DATA") = Empty
''     Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA") = Empty
''     Obj.Attributes("ATTR_TENDER_WORK_END_PLAN_DATA") = Empty
'      Obj.Attributes("ATTR_TENDER_EXECUT_DATA") = Empty
'    End If
'  End If
' End Sub
' 
''Проверяем даты после автозаполнения и, обнуляем Дату начала работ по предмету закупки если она меньше даты заключения договора

'Sub DatesAutoCheck(Obj)
'If Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA").Empty = False Then 
'    If Obj.Attributes("ATTR_TENDER_DIAL_END_DATA").Empty = False Then
'     If Obj.Attributes("ATTR_TENDER_WORK_END_PLAN_DATA").Empty = False Then
'      If Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA") > Obj.Attributes("ATTR_TENDER_WORK_END_PLAN_DATA") Then
'      Obj.Attributes("ATTR_TENDER_WORK_END_PLAN_DATA") = Empty
'      End If
'     End If
'    Data1 = Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA")
'    Data2 = Obj.Attributes("ATTR_TENDER_DIAL_END_DATA")
'    If Data2 > Data1 Then
'        msgbox "Дата начала работ по предмету закупки [" & Data1 & _
'                "] наступает раньше даты заключения договора [" & Data2 & "]!",_
'                        vbExclamation,"Внимание"
'      End If
'    End If
'    End If

' End Sub


''Процедура получения системных значений дат
'Sub SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
'  Attr1 = 0
'  Attr2 = 0
'  Attr3 = 0
'  Attr4 = 0
'  If ThisApplication.Attributes.Has("ATTR_TENDER_ALARM1") Then
'    Attr1 = ThisApplication.Attributes("ATTR_TENDER_ALARM1").Value
'  End If
'  If ThisApplication.Attributes.Has("ATTR_TENDER_ALARM1") Then
'    Attr2 = ThisApplication.Attributes("ATTR_TENDER_ALARM2").Value
'  End If
'  If ThisApplication.Attributes.Has("ATTR_TENDER_ALARM1") Then
'    Attr3 = ThisApplication.Attributes("ATTR_TENDER_ALARM3").Value
'  End If
'  If ThisApplication.Attributes.Has("ATTR_TENDER_ALARM1") Then
'    Attr4 = ThisApplication.Attributes("ATTR_TENDER_ALARM4").Value
'  End If
'End Sub

