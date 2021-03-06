
'=================================


'=================================
' 
Function AutoDateCalcVSCheck(Form, Obj, Attribute, Cancel, OldAttribute)
  'Срок представления ЗД (план)
  If Attribute.AttributeDefName = "ATTR_TENDER_PLAN_ZD_PRESENT" Then
    Call DatesCalculateA(Obj)
    Call DatesCalculateA_1(Obj)
    Call DatesCalculateB(Obj)
    Call DatesCalculateC(Obj)
    Call DatesCalculateC_1(Obj)
    Call DatesAutoCheck(Obj)
    Call DatesNul(Obj)
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_PRESENT_PLAN_DATA" Then
    Data1 = Obj.Attributes("ATTR_TENDER_PLAN_ZD_PRESENT")
    Data2 = Attribute.Value
    Call SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
    AutoDateCalcVSCheck = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Attr1)

    Call DatesCalculateA_1(Obj) 
    Call DatesCalculateB(Obj)
    Call DatesCalculateC(Obj) 
    Call DatesCalculateC_1(Obj)  
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_STOP_TIME" Then
    Data1 = Obj.Attributes("ATTR_TENDER_PRESENT_PLAN_DATA")
    Data2 = Attribute.Value
    Call SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
    AutoDateCalcVSCheck = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Attr2)

    Call DatesCalculateB(Obj)
    Call DatesCalculateC(Obj)
    Call DatesCalculateC_1(Obj)
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_CHECK_TIME" Then
    Data1 = Obj.Attributes("ATTR_TENDER_STOP_TIME")
    Data2 = Attribute.Value
    Delta = 0
    AutoDateCalcVSCheck = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Delta)
    Call DatesCalculateC(Obj)
    Call DatesCalculateC_1(Obj)
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_CHECK_END_TIME" Then
    Data1 = Obj.Attributes("ATTR_TENDER_STOP_TIME")
    Data2 = Attribute.Value
    Call SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
    AutoDateCalcVSCheck = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Attr3)
    Call DatesCalculateC(Obj)
    Call DatesCalculateC_1(Obj)
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_DIAL_START_DATA" Then
    Data1 = Obj.Attributes("ATTR_TENDER_CHECK_END_TIME")
    Data2 = Attribute.Value
    Delta = 0
    AutoDateCalcVSCheck = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Delta)
    Call DatesCalculateC_1(Obj)  
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_DIAL_END_DATA" Then
    Data1 = Obj.Attributes("ATTR_TENDER_DIAL_START_DATA")
    Data2 = Attribute.Value
    Call SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
    AutoDateCalcVSCheck = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Attr4)
    If Cancel Then Exit Function
      If Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA").Empty = False Then
      Data1 = Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA")
      If Data2 > Data1 Then
        msgbox "Дата начала работ по предмету закупки [" & Data1 & _
                "] наступает раньше даты заключения договора [" & Data2 & "]!",_
                        vbExclamation,"Внимание"
     AutoDateCalcVSCheck = True                    
      End If
    End If
    
   ElseIf Attribute.AttributeDefName = "ATTR_TENDER_WORK_START_PLAN_DATA" Then 
   If Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA").Empty = False Then 
    If Obj.Attributes("ATTR_TENDER_DIAL_END_DATA").Empty = False Then
     If Obj.Attributes("ATTR_TENDER_WORK_END_PLAN_DATA").Empty = False Then
      If Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA") > Obj.Attributes("ATTR_TENDER_WORK_END_PLAN_DATA") Then
      Obj.Attributes("ATTR_TENDER_WORK_END_PLAN_DATA") = Empty
      End If
     End If
    Data1 = Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA")
    Data2 = Obj.Attributes("ATTR_TENDER_DIAL_END_DATA")
    If Data2 > Data1 Then
        msgbox "Дата начала работ по предмету закупки [" & Data1 & _
                "] наступает раньше даты заключения договора [" & Data2 & "]!",_
                        vbExclamation,"Внимание"
    AutoDateCalcVSCheck = True                    
      End If
    End If
    End If
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_WORK_END_PLAN_DATA" Then 
    Data1 = Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA")
    Data2 = Attribute.Value
    Delta = 0
    AutoDateCalcVSCheck = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Delta)
 
    Call DatesCalculateDE(Obj)
    
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_PAY_CONDITIONS" Then  
    If Attribute.Value < 0 Then
      msgbox "Введено неверное значение",vbExclamation,"Ошибка"
      Cancel = True
      AutoDateCalcVSCheck = True
    End If
    Call DatesCalculateDE(Obj)
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_EXECUT_DATA" Then 
    Data1 = Obj.Attributes("ATTR_TENDER_WORK_END_PLAN_DATA")
    Data2 = Attribute.Value
    Delta = Obj.Attributes("ATTR_TENDER_PAY_CONDITIONS")
    Data3 = Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA")
    AutoDateCalcVSCheck = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMaxData",Data1,Data2,Delta)
    if Data2 < Data3 then
    msgbox "Срок исполнения договора [" & Data2 & _
                "] не может быть раньше даты начала работ по предмету закупки [" & Data3 & "]!",_
                        vbExclamation,"Внимание"
    AutoDateCalcVSCheck = true
    End If
  End If
End Function


Sub DatesCalculateA(Obj)
  Call SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
  A = 0
  'Срок представления ЗД (план)
  AttrName = "ATTR_TENDER_PLAN_ZD_PRESENT"
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      A = Obj.Attributes(AttrName).Value
    End If
  End If
  'Дата объявления о закупке (план)
  AttrName = "ATTR_TENDER_PRESENT_PLAN_DATA"
  If Obj.Attributes.Has(AttrName) Then
    Obj.Attributes(AttrName).Value = A + Attr1
  End If
'  'Дата окончания приема заявок (план)
'  AttrName = "ATTR_TENDER_STOP_TIME"
'  If Obj.Attributes.Has(AttrName) Then
'    Obj.Attributes(AttrName).Value = A + Attr1 + Attr2
'  End If
End Sub
  
Sub DatesCalculateA_1(Obj)
  Call SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
  A = 0
  'Дата объявления о закупке (план)
  AttrName = "ATTR_TENDER_PRESENT_PLAN_DATA"
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      A = Obj.Attributes(AttrName).Value
    End If
  End If
  'Дата окончания приема заявок (план)
  AttrName = "ATTR_TENDER_STOP_TIME"
  If Obj.Attributes.Has(AttrName) Then
    Obj.Attributes(AttrName).Value = A + Attr2
  End If
End Sub

Sub DatesCalculateB(Obj)
  B = 0
  Call SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
  'Дата окончания приема заявок (план)
  AttrName = "ATTR_TENDER_STOP_TIME"
  If Obj.Attributes.Has(AttrName) Then
    B = Obj.Attributes(AttrName).Value
  End If
  'Дата начала подведения итогов закупки (план)
  AttrName = "ATTR_TENDER_CHECK_TIME"
  If Obj.Attributes.Has(AttrName) Then
    Obj.Attributes(AttrName).Value = B
  End If
  'Дата окончания подведения итогов закупки (план)
  AttrName = "ATTR_TENDER_CHECK_END_TIME"
  If Obj.Attributes.Has(AttrName) Then
    Obj.Attributes(AttrName).Value = B + Attr3
  End If
End Sub

Sub DatesCalculateC(Obj)
  C = 0
  Call SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
  'Дата окончания подведения итогов закупки (план)
  AttrName = "ATTR_TENDER_CHECK_END_TIME"
  If Obj.Attributes.Has(AttrName) Then
    C = Obj.Attributes(AttrName).Value
  End If
  'Дата начала заключения договора по предмету закупки(план)
  AttrName = "ATTR_TENDER_DIAL_START_DATA"
  If Obj.Attributes.Has(AttrName) Then
    Obj.Attributes(AttrName).Value = C
  End If
End Sub

Sub DatesCalculateC_1(Obj)
  C = 0
  Call SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
  'Дата начала заключения договора по предмету закупки(план)
  AttrName = "ATTR_TENDER_DIAL_START_DATA"
  If Obj.Attributes.Has(AttrName) Then
    C = Obj.Attributes(AttrName).Value
  End If
  'Дата окончания заключения договора по предмету закупки (план)
  AttrName = "ATTR_TENDER_DIAL_END_DATA"
  If Obj.Attributes.Has(AttrName) Then
    Obj.Attributes(AttrName).Value = C + Attr4
  End If
End Sub

'Процедура подсчета дат
Sub DatesCalculateDE(Obj)
  Call SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
  D = 0
  E = 0
  'Дата окончания работ по предмету закупки(план)
  AttrName = "ATTR_TENDER_WORK_END_PLAN_DATA"
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      D = Obj.Attributes(AttrName).Value
    End If
  End If
  'Условия оплаты по договору, срок оплаты
  AttrName = "ATTR_TENDER_PAY_CONDITIONS"
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      E = Obj.Attributes(AttrName).Value
    End If
  End If
  'Срок исполнения договора(план)
  AttrName = "ATTR_TENDER_EXECUT_DATA"
  If Obj.Attributes.Has(AttrName) Then
    If D = 0 and E = 0 Then
      Obj.Attributes(AttrName).Value = ""
    Else
      Obj.Attributes(AttrName).Value = D + E
    End If
  End If
End Sub

'Обнуляем даты, если Срок представления ЗД (план) не задан
Sub DatesNul(Obj)
  
  'Срок представления ЗД (план)
  AttrName = "ATTR_TENDER_PLAN_ZD_PRESENT"
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = True Then
     Obj.Attributes("ATTR_TENDER_PRESENT_PLAN_DATA") = Empty
     Obj.Attributes("ATTR_TENDER_STOP_TIME") = Empty
     Obj.Attributes("ATTR_TENDER_CHECK_TIME") = Empty
     Obj.Attributes("ATTR_TENDER_DIAL_START_DATA") = Empty
     Obj.Attributes("ATTR_TENDER_CHECK_END_TIME") = Empty
     Obj.Attributes("ATTR_TENDER_DIAL_END_DATA") = Empty
'     Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA") = Empty
'     Obj.Attributes("ATTR_TENDER_WORK_END_PLAN_DATA") = Empty
      Obj.Attributes("ATTR_TENDER_EXECUT_DATA") = Empty
    End If
  End If
 End Sub
 
'Проверяем даты после автозаполнения и, обнуляем Дату начала работ по предмету закупки если она меньше даты заключения договора

Sub DatesAutoCheck(Obj)
If Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA").Empty = False Then 
    If Obj.Attributes("ATTR_TENDER_DIAL_END_DATA").Empty = False Then
     If Obj.Attributes("ATTR_TENDER_WORK_END_PLAN_DATA").Empty = False Then
      If Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA") < Obj.Attributes("ATTR_TENDER_DIAL_END_DATA") Then
      Obj.Attributes("ATTR_TENDER_WORK_START_PLAN_DATA") = Empty
      Obj.Attributes("ATTR_TENDER_WORK_END_PLAN_DATA") = Empty
      End If
     End If
    End If
    End If

 End Sub


'Процедура получения системных значений дат
Sub SystemAttrsGet(Attr1,Attr2,Attr3,Attr4)
  Attr1 = 0
  Attr2 = 0
  Attr3 = 0
  Attr4 = 0
  If ThisApplication.Attributes.Has("ATTR_TENDER_ALARM1") Then
    Attr1 = ThisApplication.Attributes("ATTR_TENDER_ALARM1").Value
  End If
  If ThisApplication.Attributes.Has("ATTR_TENDER_ALARM1") Then
    Attr2 = ThisApplication.Attributes("ATTR_TENDER_ALARM2").Value
  End If
  If ThisApplication.Attributes.Has("ATTR_TENDER_ALARM1") Then
    Attr3 = ThisApplication.Attributes("ATTR_TENDER_ALARM3").Value
  End If
  If ThisApplication.Attributes.Has("ATTR_TENDER_ALARM1") Then
    Attr4 = ThisApplication.Attributes("ATTR_TENDER_ALARM4").Value
  End If
End Sub

'Функции формы Основное
'_______________________________________________________________________________


'Доступность контролов формы Основное
function MainControlsEnable (Form, Obj)
  Form.Controls("BUTTON_DOC_DEL").Enabled = False
  Form.Controls("BUTTON_LOT_DEL").Enabled = False
  Form.Controls("BUTTON_LOT_EDIT").Enabled = False
  Form.Controls("BUTTON_DOC_EDIT").Enabled = False
  Form.Controls("BUTTON_LOT_ADD").Enabled = False
  
  Call PurchaseNumChangeBtnEnable(Obj,Form)
  Call ReasonPointEnable(Obj,Form)
  Call TenderDUKZmasageEnable(Obj,Form)
  Call TenderReasonPointToolTip(Obj,Form)
  Call TenderSMSPEnable(Obj,Form)
  Call BtnEnable0(Form,Obj)
  Call AttrsEnable(Form,Obj)
  Call SetTenderSMSPExcludeCodeRO(Obj,Form)
  Call TenderACCchifEnable(Obj,Form)
  

  Set CU = ThisApplication.CurrentUser
  
'Блокируем атрибуты, доступные только Группе
Attr = "ATTR_TENDER_PRESENT_PLAN_DATA,ATTR_TENDER_STOP_TIME,ATTR_TENDER_CHECK_TIME,ATTR_TENDER_DUKZ_MASAGE_DATA,"&_
  "ATTR_TENDER_CHECK_END_TIME,ATTR_TENDER_DIAL_START_DATA,ATTR_TENDER_DIAL_END_DATA,ATTR_TENDER_EXECUT_DATA,ATTR_TENDER_DATA_CHECK_FLAG"
  
Call AttrBlockByGropeRoleStat(Form, Obj, Attr, CU, Stat, "GROUP_TENDER_INSIDE", False)

''Блокируем атрибуты после согласования размещения
 Attr = "ATTR_TENDER_PLAN_ZD_PRESENT,ATTR_TENDER_PAY_CONDITIONS,ATTR_TENDER_WORK_START_PLAN_DATA,"&_
 "ATTR_TENDER_WORK_END_PLAN_DATA,ATTR_TENDER_PLAN_PART_NAME,ATTR_TENDER_REASON,ATTR_TENDER_URGENCY_REASON,"&_
 "ATTR_TENDER_PLAN_NDS_PRICE,ATTR_TENDER_SUM_NDS,ATTR_TENDER_PLAN_PRICE,ATTR_NDS_VALUE,ATTR_TENDER_METHOD_NAME,"&_
 "ATTR_TENDER_REASON_POINT,ATTR_TENDER_WINER_EIS,ATTR_TENDER_SMALL_BUSINESS_FLAG,ATTR_TENDER_SMSP_SUBCONTRACT_FLAG,"&_
 "ATTR_TENDER_SMSP_SUBCONTRACT_SUMM,ATTR_TENDER_ONLINE,ATTR_TENDER_SMSP_EXCLUDE_CODE,ATTR_TENDER_PLAN_YEAR,BUTTON_ANALOG,"&_
  "ATTR_TENDER_URGENTLY_FLAG,ATTR_TENDER_PRIORITY,ATTR_TENDER_TIPE,ATTR_TENDER_COMPETITIVE_METHOD_NAME,ATTR_TENDER_SMOLL_PRICE_FLAG"
 Stat = "STATUS_KD_AGREEMENT,STATUS_TENDER_DRAFT"
 Call AttrBlockByGropeRoleStat(Form, Obj, Attr, CU, Stat, "GROUP_TENDER_INSIDE", False)

''Блокируем атрибуты во всех статусах по ролям
 AttrStr = "ATTR_TENDER_CLIENTS_NUM,ATTR_TENDER_REASON,ATTR_TENDER_RESP,ATTR_TENDER_MATERIAL_RESP," &_
    "ATTR_TENDER_COMPETITIVE_METHOD_NAME,ATTR_TENDER_TIPE,ATTR_TENDER_PLAN_PART_NAME,ATTR_TENDER_REASON_POINT," &_
    "ATTR_TENDER_METHOD_NAME,ATTR_TENDER_PLAN_NDS_PRICE,ATTR_TENDER_PLAN_YEAR,ATTR_TENDER_PRIORITY," &_
    "ATTR_TENDER_STARTER_NAME,ATTR_TENDER_DEPT_RESP,ATTR_TENDER_PLAN_ZD_PRESENT,ATTR_TENDER_PRESENT_PLAN_DATA," &_
    "ATTR_TENDER_STOP_TIME,ATTR_TENDER_CHECK_TIME,ATTR_TENDER_CHECK_END_TIME,ATTR_TENDER_DIAL_START_DATA," &_
    "ATTR_TENDER_PAY_CONDITIONS,ATTR_TENDER_DIAL_END_DATA,ATTR_TENDER_WORK_START_PLAN_DATA,ATTR_TENDER_SMOLL_PRICE_FLAG," &_
    "ATTR_TENDER_WORK_END_PLAN_DATA,ATTR_TENDER_EXECUT_DATA,ATTR_TENDER_PLAN_PRICE,ATTR_NDS_VALUE," &_
    "ATTR_TENDER_UNIQUE_NUM,ATTR_TENDER_PPZ_NUM,ATTR_TENDER_ASEZ_STATUS,ATTR_TENDER_FACT_ASEZ_PRUVE_DATA," &_
    "ATTR_TENDER_METHOD_NAME,ATTR_TENDER_DUKZ_LETTER,ATTR_TENDER_SMSP_EXCLUDE_CODE,ATTR_TENDER_SMALL_BUSINESS_FLAG," &_
    "ATTR_TENDER_SMSP_SUBCONTRACT_FLAG,ATTR_TENDER_SMSP_SUBCONTRACT_SUMM,ATTR_TENDER_URGENCY_REASON,ATTR_TENDER_URGENTLY_FLAG"
RoleStr = "ROLE_TENDER_INICIATOR,ROLE_PURCHASE_RESPONSIBLE,ROLE_TENDER_DOCS_RESP_DEVELOPER" 
     
Call AttrControlsAccessOff (Form, Obj, AttrStr, RoleStr)
 
End function 



'Доступность контролов формы Разработчики
'_______________________________________________________________________________________________________________

function DesignerControlsEnable (Form, Obj)
    

  Call BtnEnable0(Form,Obj)
  
 Set CU = ThisApplication.CurrentUser
  
'Блокируем атрибуты, доступные только Группе
Attr = "ATTR_TENDER_MATERIAL_RESP,ATTR_TENDER_GROUP_CHIF,ATTR_TENDER_RESPONSIBLE_EIS"
Call AttrBlockByGropeRoleStat(Form, Obj, Attr, CU, Stat, "GROUP_TENDER_INSIDE", False)

'Блокируем атрибуты по статусам
 Attr = "ATTR_TENDER_DEPT_RESP,ATTR_TENDER_MATERIAL_RESP,ATTR_TENDER_RESP,ATTR_TENDER_KP_DESI"
 Stat = "STATUS_KD_AGREEMENT,STATUS_TENDER_DRAFT,STATUS_TENDER_IN_AGREED,STATUS_TENDER_IN_PLAN,STATUS_TENDER_IN_WORK"
 Call AttrBlockByGropeRoleStat(Form, Obj, Attr, CU, Stat, "GROUP_TENDER_INSIDE", False)

'Блокируем атрибуты по пользователям в атрибутах

 Call AttrBlockByUserInAttr(Form, Obj, "ATTR_TENDER_KP_DESI", "ATTR_TENDER_PEO_CHIF")
 Call AttrBlockByUserInAttr(Form, Obj, "ATTR_TENDER_RESPONSIBLE_EIS,ATTR_TENDER_MATERIAL_RESP", "ATTR_TENDER_GROUP_CHIF")
 Call AttrBlockByUserInAttr(Form, Obj, "ATTR_TENDER_RESP", "ATTR_TENDER_MATERIAL_RESP")
End function 


'Делаем все проверяемые контролы светлосерыми. Внутренняя закупка
function MainControlsBackColorOff (Form, Obj, Str)

If IsEmpty(Str) = True Then
   Str = "ATTR_TENDER_CLIENTS_NUM,ATTR_TENDER_REASON,ATTR_TENDER_RESP,ATTR_TENDER_MATERIAL_RESP," &_
    "ATTR_TENDER_COMPETITIVE_METHOD_NAME,ATTR_TENDER_TIPE,ATTR_TENDER_PLAN_PART_NAME,ATTR_TENDER_URGENCY_REASON," &_
    "ATTR_TENDER_METHOD_NAME,ATTR_TENDER_PLAN_NDS_PRICE,ATTR_TENDER_PLAN_YEAR,ATTR_TENDER_PRIORITY," &_
    "ATTR_TENDER_STARTER_NAME,ATTR_TENDER_DEPT_RESP,ATTR_TENDER_PLAN_ZD_PRESENT,ATTR_TENDER_PRESENT_PLAN_DATA," &_
    "ATTR_TENDER_STOP_TIME,ATTR_TENDER_CHECK_TIME,ATTR_TENDER_CHECK_END_TIME,ATTR_TENDER_DIAL_START_DATA," &_
    "ATTR_TENDER_PAY_CONDITIONS,ATTR_TENDER_DIAL_END_DATA,ATTR_TENDER_WORK_START_PLAN_DATA," &_
    "ATTR_TENDER_WORK_END_PLAN_DATA,ATTR_TENDER_EXECUT_DATA,ATTR_TENDER_PLAN_PRICE,ATTR_NDS_VALUE," &_
    "ATTR_TENDER_UNIQUE_NUM,ATTR_TENDER_PPZ_NUM,ATTR_TENDER_ASEZ_STATUS,ATTR_TENDER_FACT_ASEZ_PRUVE_DATA"
  End if
  
    Arr = Split(Str,",")
    For i = 0 to Ubound(Arr)
'      AttrName = Arr(i)
      AttrName =   "T_" & Arr(i)
     If AttrName <> "" then 
'     Msgbox  AttrName,vbExclamation
      If Form.controls.Has(AttrName) = true Then
 Form.Controls(AttrName).ActiveX.BackColor = RGB(230,230,230)
      End if
     End if
    next
End function 

function MainControlsBackColorAlarm (Form, Obj, Str)
call MainControlsBackColorOff (Form, Obj, Str)
Arr = Split(Str,",")
    For i = 0 to Ubound(Arr)
      AttrName = Arr(i)
     If AttrName <> "" then
     AttrName =   "T_" & Arr(i) 
'     Msgbox  AttrName,vbExclamation
      If Form.controls.Has(AttrName) = true Then
       Form.Controls(AttrName).ActiveX.BackColor = RGB(255,255,0)
        End if
      End if
  next
End function 

'Событие - изменение основных атрибутов
function MainAttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)

 ThisApplication.Dictionary(Obj.GUID).Item("ObjEdit") = True
 Call BtnEnable0(Form,Obj)
  If Attribute.AttributeDefName = "ATTR_TENDER_METHOD_NAME" Then
    Call ReasonPointEnable(Obj,Form)
    Call TenderDUKZmasageEnable(Obj,Form)
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_REASON_POINT" Then
    Call TenderReasonPointToolTip(Obj,Form)
  'Ставка НДС
  ElseIf Attribute.AttributeDefName = "ATTR_NDS_VALUE" Then
     Call NDSsync(Obj)
   'Номер и дата письма
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_DUKZ_LETTER" Then
   Call Numsync(Obj, Form)
    'Проверка на малую стоимость
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_PLAN_NDS_PRICE" Then
    Call Slowpricesync(Form, Obj)
 if not Attribute is Nothing Then Attribute.value = Round(Attribute.value,2)
   'Ответственное структурное подразделение за подготовку заявки
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_DEPT_RESP" Then
    Set User = Nothing
    If Attribute.Empty = False Then
      Set Dept = Attribute.Object
      If Dept.Attributes("ATTR_KD_CHIEF").Empty = False Then
        If not Dept.Attributes("ATTR_KD_CHIEF").User is Nothing Then
          Set User = Dept.Attributes("ATTR_KD_CHIEF").User
        End If
      End If
    End If
    Obj.Attributes("ATTR_TENDER_MATERIAL_RESP").User = User
  'Ответственный за предоставление материалов для проведения закупки
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_MATERIAL_RESP" Then
  Call AttrsEnable(Form,Obj)
  'Раздел плана
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_PLAN_PART_NAME" Then
    RegNum = ThisApplication.ExecuteScript("CMD_S_NUMBERING","PurchaseInsideNumGet",Obj,"")
    If RegNum <> "" Then
      Arr = Split(RegNum,"#")
      Num = cLng(Arr(1))
      RegNum = Replace(RegNum,"#","")
      Obj.Attributes("ATTR_TENDER_CLIENTS_NUM").Value = RegNum
    End If
    'Закупка у субъектов малого и среднего предпринимательства
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_SMALL_BUSINESS_FLAG" Then
    If OldAttribute.Value = False And Attribute.Value = True Then
      Obj.Attributes("ATTR_TENDER_SMSP_SUBCONTRACT_SUMM").Empty = True
      Obj.Attributes("ATTR_TENDER_SMSP_SUBCONTRACT_FLAG").Value= False      
    End If
   Call AttrsEnable(Form,Obj)
    Call TenderSMSPEnable(Obj,Form)
   Call ClearTenderSMSPExcludeCode(Obj,Form)
   Call SetTenderSMSPExcludeCodeRO(Obj,Form)
    
    'Признак «Субподряд СМСП»
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_SMSP_SUBCONTRACT_FLAG" Then
    If OldAttribute.Value = False And Attribute.Value = True Then
      Obj.Attributes("ATTR_TENDER_SMALL_BUSINESS_FLAG").Value= False  
    ElseIf OldAttribute.Value = True And Attribute.Value = False Then
      Obj.Attributes("ATTR_TENDER_SMSP_SUBCONTRACT_SUMM").Empty = True
    End If
     Call AttrsEnable(Form,Obj)
     Call TenderSMSPEnable(Obj,Form)
     Call ClearTenderSMSPExcludeCode(Obj,Form)
     Call SetTenderSMSPExcludeCodeRO(Obj,Form)
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_SMSP_SUBCONTRACT_SUMM" Then
     Call TenderSMSPEnable(Obj,Form)
  if not Attribute is Nothing Then Attribute.value = Round(Attribute.value,2)
  
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_PLAN_PRICE" Then
    Call Slowpricesync(Form, Obj)
  if not Attribute is Nothing Then Attribute.value = Round(Attribute.value,2)
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_SUM_NDS" Then
    Call Slowpricesync(Form, Obj)
  if not Attribute is Nothing Then Attribute.value = Round(Attribute.value,2)
 
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_URGENTLY_FLAG" Then  
    If Attribute.Value = False Then 
      Obj.Attributes("ATTR_TENDER_URGENCY_REASON") = vbNullString
    End If
    Form.Controls("ATTR_TENDER_URGENCY_REASON").Enabled = Attribute.Value
  End If
End function

'Процедура управления доступностью атрибута Обоснование закупки у ЕП
function ReasonPointEnable(Obj,Form)
  ThisScript.SysAdminModeOn
  Check = ThisApplication.ExecuteScript("OBJECT_TENDER_INSIDE","CheckReasonPoint",Obj)
  If Form.Controls.Has("ATTR_TENDER_REASON_POINT") Then
  Form.Controls("ATTR_TENDER_REASON_POINT").ReadOnly = Check
  if Check = true Then 
   If Obj.Attributes.has("ATTR_TENDER_REASON_POINT") = True Then
    If Obj.Attributes("ATTR_TENDER_REASON_POINT") <> "" Then
    Obj.Attributes("ATTR_TENDER_REASON_POINT") = "" ' Обнулим есле неактивно
    End If
   End If 
  End If
  End If
  If Form.Controls.Has("ATTR_TENDER_WINER_EIS") Then
    Form.Controls("ATTR_TENDER_WINER_EIS").Visible = not Check
  End If
End function

'Процедура управления доступностью атрибута Реквизиты письма, согласования ДУКЗ
Sub TenderDUKZmasageEnable(Obj,Form)
  ThisScript.SysAdminModeOn
  AttrName = "ATTR_TENDER_METHOD_NAME"
  Check = True
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      If StrComp(Obj.Attributes(AttrName).Value, "Закупка у единственного поставщика",vbTextCompare) = 0 Then
        Check = False
      End If
    End If
  End If
'  Form.Controls("ATTR_TENDER_DUKZ_MASAGE_ATTR").ReadOnly = Check
  Form.Controls("BTN_OUT_DOC_PREPARE").Enabled = Not Check
  Form.Controls("ATTR_TENDER_DUKZ_LETTER").ReadOnly = Check
End Sub


'Процедура управления доступностью атрибута Сумма субподряда СМСП
Sub TenderSMSPEnable(Obj,Form)
  Form.Controls("ATTR_TENDER_SMSP_SUBCONTRACT_SUMM").ReadOnly = not Obj.Attributes("ATTR_TENDER_SMSP_SUBCONTRACT_FLAG").Value
End Sub

Sub SetTenderSMSPExcludeCodeRO(Obj,Form)
  Form.Controls("ATTR_TENDER_SMSP_EXCLUDE_CODE").ReadOnly = (Obj.Attributes("ATTR_TENDER_SMSP_SUBCONTRACT_FLAG").Value) Or _
                                                            (Obj.Attributes("ATTR_TENDER_SMALL_BUSINESS_FLAG").Value)
End Sub

Sub ClearTenderSMSPExcludeCode(Obj,Form)
  Obj.Attributes("ATTR_TENDER_SMSP_EXCLUDE_CODE").Empty = (Obj.Attributes("ATTR_TENDER_SMSP_SUBCONTRACT_FLAG").Value) Or _
                                                            (Obj.Attributes("ATTR_TENDER_SMALL_BUSINESS_FLAG").Value)
End Sub

'Процедура управления доступностью кнопок Сохранить, Отменить, Согласовать, Запланировать
'В разработку документации, Разработчики, На утверждение, Вернуть в работу, Утверждено
Sub BtnEnable0(Form,Obj)
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  Set Roles = Obj.RolesForUser(CU)
  Set Dict = ThisApplication.Dictionary(Obj.Guid & " - BlockRoute")
  Dict.RemoveAll
  BtnList = "BUTTON_ADD_CONTRACT,BUTTON_CUSTOM_SAVE,BUTTON_CUSTOM_CANCEL,BUTTON_APPROVE,BUTTON_BACK_TO_WORK," &_
  "BUTTON_TO_APPROVE,BUTTON_DEVELOPERS,BUTTON_TO_DEVELOP,BUTTON_PLAN,BUTTON_AGREED,BUTTON_LOT_ADD,BUTTON_CHIF_ORDER"
  Arr = Split(BtnList,",")
  
  If ThisApplication.Dictionary(Obj.GUID).Exists("ObjEdit") Then
    If ThisApplication.Dictionary(Obj.GUID).Item("ObjEdit") = True Then
      Dict.Item("BUTTON_CUSTOM_SAVE") = True
      Dict.Item("BUTTON_CUSTOM_CANCEL") = True
    End If
  End If
  
  Select Case Obj.StatusName
    'Черновик
    Case "STATUS_TENDER_DRAFT"
      If Roles.Has("ROLE_TENDER_INICIATOR") or Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
        Dict.Item("BUTTON_AGREED") = True
        Dict.Item("BUTTON_LOT_ADD") = True
      End If
      
       'На согласовании
    Case "STATUS_KD_AGREEMENT"
      isLock = false
      If Obj.Permissions.Locked = True Then
        If Obj.Permissions.LockUser.Handle <> thisApplication.CurrentUser.Handle  Then
          msgbox "В настоящий момент документ редактируется пользователем " & Obj.Permissions.LockUser.Description & _
      ". Некоторые действия с объектом могут быть недоступны или отклонены.", vbExclamation 
          isLock = true
        end if
      end if  
      isApr = false 
      isApr = ThisApplication.ExecuteScript("CMD_KD_USER_PERMISSIONS","IsCanAprove",thisApplication.CurrentUser, Obj)'IsAprover(thisApplication.CurrentUser, thisObject)
     
      If Roles.Has("ROLE_TENDER_INICIATOR") or _
          Roles.Has("ROLE_PURCHASE_RESPONSIBLE") or _
            Roles.Has("ROLE_TENDER_DOCS_RESP_DEVELOPER") Then
        Dict.Item("BUTTON_LOT_ADD") = True
      End If
      If Roles.Has("ROLE_TENDER_INICIATOR") or _
          Roles.Has("ROLE_PURCHASE_RESPONSIBLE") or _
            Roles.Has("ROLE_TENDER_DOCS_RESP_DEVELOPER") or _
              ((isApr) and not isLock) Then
        Dict.Item("BUTTON_AGREED") = True
      End If
      
    'Согласовано
    Case "STATUS_TENDER_IN_AGREED"
       If Roles.Has("ROLE_TENDER_INICIATOR") or Roles.Has("ROLE_TENDER_MATERIAL_RESP") or  Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
        Dict.Item("BUTTON_CHIF_ORDER") = True
       End If 
'      If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
      If CU.Groups.Has("GROUP_TENDER_INSIDE") Then
        If Obj.Attributes("ATTR_TENDER_STATUS_EIS").Empty Then
          Dict.Item("BUTTON_PLAN") = True
        End If
      End If
      
    'Запланирована
    Case "STATUS_TENDER_IN_PLAN"
'      If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
       If Roles.Has("ROLE_TENDER_INICIATOR") or Roles.Has("ROLE_TENDER_MATERIAL_RESP") or  Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
        Dict.Item("BUTTON_CHIF_ORDER") = True
        Dict.Item("BUTTON_TO_DEVELOP") = True
'        Dict.Item("BUTTON_TO_DEVELOP") = True
      End If
      
    'Разработка документации
    Case "STATUS_TENDER_IN_WORK"
       If Roles.Has("ROLE_TENDER_INICIATOR") or Roles.Has("ROLE_TENDER_MATERIAL_RESP") or  Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
        Dict.Item("BUTTON_CHIF_ORDER") = True
       End If   
    
      If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
        Dict.Item("BUTTON_DEVELOPERS") = True
        'Dict.Item("BUTTON_TO_APPROVE") = True
        Dict.Item("ATTR_TENDER_MATERIAL_RESP") = True
      End If
      If ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsGroupMember",CU,"GROUP_CONTRACTS") = True Then
        Dict.Item("BUTTON_ADD_CONTRACT") = True
      End If
    'На утверждении
    Case "STATUS_TENDER_IN_IS_APPROVING"
       If Roles.Has("ROLE_TENDER_INICIATOR") or Roles.Has("ROLE_TENDER_MATERIAL_RESP") or  Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
        Dict.Item("BUTTON_CHIF_ORDER") = True
       End If       
      If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
        Dict.Item("BUTTON_BACK_TO_WORK") = True
        Dict.Item("BUTTON_APPROVE") = True
      End If
    'Утверждена
    Case "STATUS_TENDER_IN_APPROVED"
       If Roles.Has("ROLE_TENDER_INICIATOR") or Roles.Has("ROLE_TENDER_MATERIAL_RESP") or  Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
        Dict.Item("BUTTON_CHIF_ORDER") = True
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
      If BtnName = "BUTTON_CHIF_ORDER" Then Form.Controls(BtnName).Visible = Check
    End If
  Next
End Sub

 'Процедура управления доступностью атрибута Ответственный руководитель (бывший Главный бухгалтер)
 Sub TenderACCchifEnable(Obj,Form)
 ThisScript.SysAdminModeOn
 AttrName = "ATTR_TENDER_ACC_CHIF"
 If Obj.Attributes.Has(AttrName) Then
 If Obj.Attributes(AttrName).Empty = False Then
'    Form.Controls("ATTR_TENDER_ACC_CHIF").ReadOnly = True
  End If
 End If
End Sub

'Процедура формирования подсказки для атрибута Обоснование закупки у ЕИ
Sub TenderReasonPointToolTip(Obj,Form)
  ThisScript.SysAdminModeOn
  AttrName = "ATTR_TENDER_REASON_POINT"
  If Obj.Attributes.Has(AttrName) = True Then
   If Obj.Attributes(AttrName).Empty = False Then
    Form.Controls(AttrName).ToolTip = Form.Controls(AttrName).Value
  Else
    Form.Controls(AttrName).ToolTip = ""
  End If
  End If
End Sub

'Процедура синхронизации ставки НДС с табличными атрибутами
Sub NDSsync(Obj)
  AttrName = "ATTR_NDS_VALUE"
  AttrName1 = "ATTR_NDS_VALUE"
  If Obj.Attributes.Has("ATTR_TENDER_ITEM_PRICE_MAX_VALUE") Then
    Set TableRows = Obj.Attributes("ATTR_TENDER_ITEM_PRICE_MAX_VALUE").Rows
    If TableRows.Count = 0 Then TableRows.Create
    Set Row = TableRows(0)
    If Row.Attributes.Has(AttrName1) Then
      If Row.Attributes(AttrName1).Value <> Obj.Attributes(AttrName).Value Then
        Row.Attributes(AttrName1).Classifier = Obj.Attributes(AttrName).Classifier
      End If
    End If
  End If
End Sub

'Процедура заполнения атрибута Номер и дата письма
Sub Numsync(Obj,Form)
  Set DocOut = Obj.Attributes("ATTR_TENDER_DUKZ_LETTER").Object
    Set tbl = DocOut.Attributes("ATTR_KD_DOC_PREFIX")
    Set tb2 = DocOut.Attributes("ATTR_KD_NUM")
    Set tb3 = DocOut.Attributes("ATTR_KD_ISSUEDATE")
  regnum =  tbl & chr(32) & tb2 & chr(32) ' &  "от" & chr(32) & tb3  
  Obj.Attributes("ATTR_TENDER_DUKZ_MASAGE_NNUM") = regnum 
  Obj.Attributes("ATTR_TENDER_DUKZ_MASAGE_DATA") = tb3 'FormatDateTime(tb3, vbShortTime) 
  Form.Refresh
End Sub

'Процедура проверки на малостоимость по полю Планируемая цена
Sub Slowpricesync(Form,Obj)
 Set CU = ThisApplication.CurrentUser
  If not Obj is Nothing Then
   If Obj.Permissions.Locked = True Then
    If Obj.Permissions.LockUser.SysName = CU.SysName Then EXIT SUB
   End If
  End If
  
  Set Price = Obj.Attributes("ATTR_TENDER_PLAN_NDS_PRICE")
  If Price <= ThisApplication.Attributes("ATTR_TENDER_SMALL_PURSHASE_LIMIT") then 
    Obj.Attributes("ATTR_TENDER_SMOLL_PRICE_FLAG") = True
    Form.Controls("ATTR_TENDER_SMOLL_PRICE_FLAG") = True
  Else
    Obj.Attributes("ATTR_TENDER_SMOLL_PRICE_FLAG") = False
    Form.Controls("ATTR_TENDER_SMOLL_PRICE_FLAG") = True
'    Form.Refresh
  End If
End Sub

'Процедура управления доступностью атрибутов
Sub AttrsEnable(Form,Obj)
  Set CU = ThisApplication.CurrentUser
  Set Roles = Obj.RolesForUser(CU)
  
  'Ответственное структурное подразделение за подготовку заявки
'  If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") = False Then
'    Form.Controls("ATTR_TENDER_DEPT_RESP").ReadOnly = True
'  End If
  
  'Исполнитель по закупке
  Check = True
  If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
    Check = False
  Else
    AttrName = "ATTR_TENDER_MATERIAL_RESP"
    If Obj.Attributes(AttrName).Empty = False Then
      If not Obj.Attributes(AttrName).User is Nothing Then
        If Obj.Attributes(AttrName).User.SysName = CU.SysName Then Check = False
      End If
    End If
  End If
'  Form.Controls("ATTR_TENDER_RESP").ReadOnly = Check
  
  'Раздел Плана
  ' Условие доступности поля изменено в соответствии с кейсом https://fogbugz.csoft-msc.ru/default.asp?5372
'  AttrName = "ATTR_TENDER_PLAN_PART_NAME"
'  If Obj.Attributes.Has(AttrName) Then
'    If Obj.Attributes(AttrName).Empty = False Then
'      Form.Controls(AttrName).ReadOnly = True
'    End If
'  End If
  Form.Controls("ATTR_TENDER_PLAN_PART_NAME").ReadOnly = Not (CU.Groups.Has("GROUP_TENDER_INSIDE") Or CU.Groups.Has("GROUP_TENDER_INICIATORS"))
  
  'Номер ППЗ
  Form.Controls("ATTR_TENDER_PPZ_NUM").ReadOnly = not CU.Groups.Has("GROUP_TENDER_INSIDE")
  
  'Год планирования
'  Form.Controls("ATTR_TENDER_PLAN_YEAR").ReadOnly = not CU.Groups.Has("GROUP_TENDER_INSIDE")
  
  'Статус закупки в АСЭЗ
  Form.Controls("ATTR_TENDER_ASEZ_STATUS").ReadOnly = not CU.Groups.Has("GROUP_TENDER_INSIDE")
  
  'Фактическая дата утверждения в АСЭЗ
  Form.Controls("ATTR_TENDER_FACT_ASEZ_PRUVE_DATA").ReadOnly = not CU.Groups.Has("GROUP_TENDER_INSIDE")
  
  'Организатор закупки
  Form.Controls("ATTR_TENDER_STARTER_NAME").ReadOnly = not CU.Groups.Has("GROUP_TENDER_INSIDE")
  
  'Обоснование закупки
  Form.Controls("ATTR_TENDER_URGENCY_REASON").Enabled = Obj.Attributes("ATTR_TENDER_URGENTLY_FLAG").Value
  Form.Controls("ATTR_TENDER_URGENCY_REASON").ReadOnly = not (CU.Groups.Has("GROUP_TENDER_INSIDE") Or CU.Groups.Has("GROUP_TENDER_INICIATORS")) 
  
  'Код исключения СМСП
  Form.Controls("ATTR_TENDER_SMSP_EXCLUDE_CODE").Enabled = not (Obj.Attributes("ATTR_TENDER_SMALL_BUSINESS_FLAG").Value or Obj.Attributes("ATTR_TENDER_SMSP_SUBCONTRACT_FLAG").Value)
  Form.Controls("ATTR_TENDER_SMSP_EXCLUDE_CODE").ReadOnly = not CU.Groups.Has("GROUP_TENDER_INSIDE")
   
End Sub

'Процедура управления доступностью кнопки Скорректировать номер закупки заказчика. 
Sub PurchaseNumChangeBtnEnable(Obj,Form)
  ThisScript.SysAdminModeOn
  Set u = ThisApplication.CurrentUser
  If u.Groups.Has("GROUP_TENDER_INSIDE") Then
    Form.Controls("BUTTON_PURCHASE_NUM_CHANGE").Enabled = True
    Form.Controls("BUTTON_PURCHASE_UNICNUM_CHANGE").Enabled = True
  Else
    Form.Controls("BUTTON_PURCHASE_NUM_CHANGE").Enabled = False
    Form.Controls("BUTTON_PURCHASE_UNICNUM_CHANGE").Enabled = False
  End If
End Sub

'Процедура управления доступностью кнопки Удалить при выделении пользователя в выборке Разработчики. Форма Разработчики.
Sub DesignerSelDelBtnEnable(Form, Obj, iItem, action)'QUERY_TENDER_DESIGNER_LIST_Selected(iItem, action)
Set CU = ThisApplication.CurrentUser
Set Roles = Obj.RolesForUser(CU)
  If CU.Groups.Has("GROUP_TENDER_INSIDE") or Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
  Set Ctrl = Form.Controls("BUTTON_DEL")
  Set Dict = ThisApplication.Dictionary(Obj.GUID)
  Set Query = Form.Controls("QUERY_TENDER_DESIGNER_LIST")
  If action = 2 Then
    Form.Dictionary.Item("SelectedUser") = iItem
  End If
  If iItem <> -1 and Action = 2 Then
    Ctrl.Enabled = True
    Set User = Query.Value.RowValue(iItem)
    If not User is Nothing Then
      Dict.Item("QuerySelUser") = User.SysName
    End If
  Else
    Ctrl.Enabled = False
  End If
  Form.Refresh
 End If
End Sub

 'Текст - ссылка на родителя. Заполнение. Для форм Документа закупки
Sub GoParentText(Form, Obj) 
if not Obj.Parent is nothing then
 Form.Controls("PARENT").ActiveX.text =  "Входит в состав: " &"""" & Obj.Parent.Description &""""
 End If    
End Sub
' ThisObject

'Кнопки
'-----------------------------------------------------------------------
'-----------------------------------------------------------------------

'Кнопка - Вычислить планируемую цену закупки
'-----------------------------------------------------------------------
Function ButtonPriceCalc(Form, Obj, Btn)
  ThisScript.SysAdminModeOn
  AttrName0 = "ATTR_TENDER_LOT_NDS_PRICE" 'Цена лота с НДС  "ATTR_TENDER_NDS_PRICE" 'Цена с НДС (лота)
  AttrName3 = "ATTR_TENDER_LOT_PRICE" 'Цена лота без НДС
  AttrName4 = "ATTR_LOT_NDS_VALUE" ' Ставка НДС лота
  AttrName1 = "ATTR_TENDER_PLAN_NDS_PRICE" 'Планируемая цена закупки с НДС
  AttrName2 = "ATTR_TENDER_PLAN_PRICE" 'Планируемая цена закупки без НДС
  AttrName5 = "ATTR_NDS_VALUE" 'Ставка НДС закупки
  AttrName6 = "ATTR_TENDER_LOT_UNIT_PRICE" 'Цена за единицу
  AttrName7 = "ATTR_TENDER_SUM_NDS" 'Сумма НДС
  Sum = 0
  Sum2 = 0
  Check = False
  Check2 = False
  Check3 = False
'  bet = ThisObject.Attributes(AttrName5) 
  bet = ""

  If IsEmpty(Form) = False Then 
  If Form.Controls.Has("T_ATTR_TENDER_PLAN_PRICE") then Form.Controls("T_ATTR_TENDER_PLAN_PRICE").ActiveX.ForeColor = RGB(0,0,0)
  If Form.Controls.Has("T_ATTR_TENDER_PLAN_NDS_PRICE") then Form.Controls("T_ATTR_TENDER_PLAN_NDS_PRICE").ActiveX.ForeColor = RGB(0,0,0)
  If Form.Controls.Has("T_ATTR_TENDER_SUM_NDS") then Form.Controls("T_ATTR_TENDER_SUM_NDS").ActiveX.ForeColor = RGB(0,0,0)
  End If 
  
   For Each Child in Obj.Objects
    If Child.ObjectDefName = "OBJECT_PURCHASE_LOT" Then
      If Child.Attributes.Has(AttrName0) Then
        If Child.Attributes(AttrName0).Empty = False Then
          Sum = Sum + Child.Attributes(AttrName0).Value
          Else 
          Check2 = True
         If IsEmpty(Form) = Felse Then Form.Controls("T_ATTR_TENDER_PLAN_PRICE").ActiveX.ForeColor = RGB(255,0,0)
        End If  
          If Child.Attributes(AttrName3).Empty = False and Check2 = false Then
          Sum1 = Sum1 + Child.Attributes(AttrName3).Value
          Else 
          Check2 = True
           If Child.Attributes(AttrName3).Empty = true then
           If IsEmpty(Form) = Felse Then Form.Controls("T_ATTR_TENDER_PLAN_NDS_PRICE").ActiveX.ForeColor = RGB(255,0,0)
           End If 
        End If  
        
       If Child.Attributes.Has(AttrName7) Then
        If Child.Attributes(AttrName7).Empty = False Then
         Sum2 = Sum2 + Child.Attributes(AttrName7).Value
        Else 
        Check3 = True
        If Form.Controls.Has("T_ATTR_TENDER_SUM_NDS") then
        Form.Controls("T_ATTR_TENDER_SUM_NDS").ActiveX.ForeColor = RGB(255,0,0)
        End If 
       End If  
      End If  
        
          If Child.Attributes(AttrName4).Empty = False and Check2 = false Then 
          if bet = Empty then  bet = Child.Attributes(AttrName4)
           If bet = Child.Attributes(AttrName4) then
           Check1 = false
           else
           Check1 = True
           bet = Child.Attributes(AttrName4)
           End If
          End If
          If Check = False Then Check = True
          End If
       End If
  Next
  If Check = False Then
     If Btn = True Then
     Msgbox "В составе нет лотов с заданной ценой", vbInformation
     Exit Function
     End If 
  Else
   Set CU = ThisApplication.CurrentUser
  
    If Obj.Attributes.Has(AttrName7) Then
     If Obj.Attributes(AttrName7).Value <> Sum2 or Obj.Attributes(AttrName7).Value = 0 Then
      Obj.Attributes(AttrName7).Value = Round(Sum2,2)
      End If  
     End If 
    If Obj.Attributes(AttrName1).Value <> Sum Then
      Obj.Attributes(AttrName1).Value = Round(Sum,2)
      End If  
    If Obj.Attributes(AttrName2).Value <> Sum1 Then
      Obj.Attributes(AttrName2).Value = Round(Sum1,2)
     End If  
      If Check1 = False Then
      On Error Resume Next
       If Obj.Attributes(AttrName2).Value <> bet Then Obj.Attributes(AttrName5) = bet
'       On Error GoTo 0
       else
      Obj.Attributes(AttrName5).Classifier = ThisApplication.Classifiers("NODE_F7E00034_5715_45AB_8952_0860746AD1C6").Classifiers.Find("Составной")
    End If
   End If

 End Function

'Кнопка - Удалить Лот
Sub BtnLotDelOnclic(Form, Obj) 'BUTTON_LOT_DEL_OnClick()
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
If ThisApplication.ExecuteScript("OBJECT_PURCHASE_LOT","checkBeforeErase",Obj,CU,False) = False Then Exit Sub
  Set Query = Form.Controls("QUERY_LOT_LIST")
  Set Objects = Query.SelectedObjects
  str = ""
   
  'Подтверждение удаления
  If Objects.Count <> 0 Then
    For Each Obj in Objects
      If Obj.Attributes.Has("ATTR_TENDER_LOT_NAME") Then
        If Obj.Attributes("ATTR_TENDER_LOT_NAME").Empty = False Then
          If str <> "" Then
            str = str & ", """ & Obj.Attributes("ATTR_TENDER_LOT_NAME").Value & """"
          Else
            str = """" & Obj.Attributes("ATTR_TENDER_LOT_NAME").Value & """"
          End If
        End If
      End If
    Next
    If str = "" Then str = Objects.Count & " лотов"
    Key = Msgbox("Удалить " & str & " из системы?",vbYesNo+vbQuestion)
    If Key = vbNo Then Exit Sub
  Else
    Exit Sub
  End If
  
  'Удаление строк из таблицы
  For Each Obj in Objects
    Obj.Erase
  Next
  Form.Refresh
End Sub


'Кнопка - Удалить Документ закупки
'-----------------------------------------------------------------------
Sub BtnDocDelOnclic(Form, Obj) ' BUTTON_DOC_DEL_OnClick()
  ThisScript.SysAdminModeOn
  If Form.Controls.has("QUERY_TENDER_DOCS") Then Set Query = Form.Controls("QUERY_TENDER_DOCS")
  If Form.Controls.has("QUERY_TENDER_DOCS_PB") Then Set Query = Form.Controls("QUERY_TENDER_DOCS_PB")
  If Form.Controls.has("QUERY_TENDER_DOCS_WK") Then Set Query = Form.Controls("QUERY_TENDER_DOCS_WK")
  If Form.Controls.has("QUERY_TENDER_DOCKS_IN_DOC") Then Set Query = Form.Controls("QUERY_TENDER_DOCKS_IN_DOC")
  If Form.Controls.has("QUERY_TENDER_ALL_DOCKS") Then Set Query = Form.Controls("QUERY_TENDER_ALL_DOCKS")
  
  Set Objects = Query.SelectedObjects
  str = ""
  
  'Подтверждение удаления
  If Objects.Count <> 0 Then
    For Each Obj in Objects
      If Obj.Attributes.Has("ATTR_DOCUMENT_NAME") Then
        If Obj.Attributes("ATTR_DOCUMENT_NAME").Empty = False Then
          If str <> "" Then
            str = str & ", """ & Obj.Attributes("ATTR_DOCUMENT_NAME").Value & """"
          Else
            str = """" & Obj.Attributes("ATTR_DOCUMENT_NAME").Value & """"
          End If
        End If
      End If
    Next
    If str = "" Then str = Objects.Count & " документов закупки"
    Key = Msgbox("Удалить " & str & " из системы?",vbYesNo+vbQuestion)
    If Key = vbNo Then Exit Sub
  Else
    Exit Sub
  End If
  
  'Удаление строк из таблицы
  For Each Obj in Objects
    Obj.Erase
  Next
  Form.Refresh
End Sub


'Кнопка - Скорректировать номер закупки заказчика
'-----------------------------------------------------------------------
Sub BtnPurchaseNumChangeOnclic(Form, Obj) 'BUTTON_PURCHASE_NUM_CHANGE_OnClick()
  ThisScript.SysAdminModeOn
  If Obj.Attributes.Has("ATTR_TENDER_CLIENTS_NUM") Then
    Temp = Obj.Attributes("ATTR_TENDER_CLIENTS_NUM").Value
    Set Dlg = ThisApplication.Dialogs.SimpleEditDlg
    Dlg.Caption = "Корректировка номера закупки заказчика"
    Dlg.Prompt = "Введите номер:"
    Dlg.Text = Temp
    If Dlg.Show Then
      On Error Resume Next
      Obj.Attributes("ATTR_TENDER_CLIENTS_NUM").Value = Dlg.Text
      If Err.Number <> 0 Then
        Msgbox "Значение поля должно быть уникальным!", VbCritical
      Else
        'Определение порядкового номера из вписанного
        Check = 0
        strNum = Right(Dlg.Text,Len(Dlg.Text)-InStrRev(Dlg.Text,"-"))
'        YearNum = Left(Dlg.Text,Len(Dlg.Text)-InStrRev(Dlg.Text,"-"))
        YearNum = 20& Left(Dlg.Text,2)
        Set Clf = ThisApplication.Classifiers("NODE_YEAR_XXXX").Classifiers.Find(YearNum) 
'        msgbox Clf.description
        If Obj.Attributes.Has("ATTR_TENDER_PLAN_YEAR") Then
          If Obj.Attributes("ATTR_TENDER_PLAN_YEAR").Empty = False Then
          If not Obj.Attributes("ATTR_TENDER_PLAN_YEAR").Classifier is Nothing Then
          OldYear = Obj.Attributes("ATTR_TENDER_PLAN_YEAR").Value
'          msgbox OldYear
          End If 
         End If 
'         Obj.Attributes("ATTR_TENDER_PLAN_YEAR").Value = Clf
       End If 
         If Obj.Attributes.Has("ATTR_TENDER_PLAN_YEAR") Then Obj.Attributes("ATTR_TENDER_PLAN_YEAR").Classifier = Clf
    
'        msgbox strNum
        
'        msgbox Clf.description
'        msgbox YearNum
        If IsNumeric(strNum) Then
          If InStr(strNum,".") = 0 and InStr(strNum,",") = 0 Then
            Num = cInt(strNum)
           
            Set q = ThisApplication.CreateQuery
            q.Permissions = sysadminpermissions
            q.AddCondition tdmQueryConditionObjectDef, "'OBJECT_TENDER_INSIDE'"
            q.AddCondition tdmQueryConditionAttribute,  Num, "ATTR_PROJECT_ORDINAL_NUM"
            q.AddCondition tdmQueryConditionAttribute, "<> '""' ", "ATTR_TENDER_CLIENTS_NUM"
            q.AddCondition tdmQueryConditionAttribute, Clf , "ATTR_TENDER_PLAN_YEAR"
            strGUID = q.Objects(0).GUID
'            msgbox Num
'            msgbox strGUID
            Set ob = ThisApplication.GetObjectByGUID(strGUID)
'            msgbox Ob.Attributes("ATTR_TENDER_CLIENTS_NUM").Value
'            msgbox   q.Objects.Count & " "& q.Objects(0).GUID & " " & q.Objects(1).GUID & " "& q.Objects(2).GUID
            If q.Objects.Count = 0 Then
             If Obj.Attributes.Has("ATTR_PROJECT_ORDINAL_NUM") Then
              Obj.Attributes("ATTR_PROJECT_ORDINAL_NUM").Value = Num
'               msgbox Num
             End If
            End If  
            If q.Objects.Count >= 1 Then
              If q.Objects(0).GUID <> Obj.GUID Then
                Check = 2
              Else
                If Obj.Attributes.Has("ATTR_PROJECT_ORDINAL_NUM") Then
                  Obj.Attributes("ATTR_PROJECT_ORDINAL_NUM").Value = Num
                
                End If
              End If
           
            ElseIf q.Objects.Count > 1 Then
              Check = 2
            End If
          Else
            Check = 1
          End If
        Else
          Check = 1
        End If
        If Check = 1 Then
          Msgbox "Номер закупки заказчика должен иметь корректный порядковый номер в конце строки.", VbCritical
          Obj.Attributes("ATTR_TENDER_PLAN_YEAR").Value = OldYear
        ElseIf Check = 2 Then
          Msgbox "Внутренняя закупка с таким порядковым номером уже существует. " & Ob.Attributes("ATTR_TENDER_CLIENTS_NUM").Value , VbCritical
          Obj.Attributes("ATTR_TENDER_PLAN_YEAR").Value = OldYear
        End If
        If Check <> 0 Then Obj.Attributes("ATTR_TENDER_CLIENTS_NUM").Value = Temp
      End If
      On Error GoTo 0
    End If
  End If
End Sub

'Кнопка - Скорректировать уникальный номер закупки
'-----------------------------------------------------------------------
Sub BtnPurchaseUnicNumChangeOnclic(Form, Obj) ' BUTTON_PURCHASE_UNICNUM_CHANGE_OnClick()
  ThisScript.SysAdminModeOn
  If Obj.Attributes.Has("ATTR_TENDER_UNIQUE_NUM") Then
    Set Dlg = ThisApplication.Dialogs.SimpleEditDlg
    Dlg.Caption = "Корректировка уникального номера закупки"
    Dlg.Prompt = "Введите номер:"
    Dlg.Text = Obj.Attributes("ATTR_TENDER_UNIQUE_NUM").Value
    If Dlg.Show Then
      On Error Resume Next
      Obj.Attributes("ATTR_TENDER_UNIQUE_NUM").Value = Dlg.Text
    txtarr = Split( Dlg.Text, "/")
    Form.Controls("T_ATTR_TENDER_UNIQUE_NUM").ActiveX.ForeColor = RGB(0,0,0)
    If not Dlg.Text = "" Then
    checkBound = UBound (txtarr)
    If checkBound <> 3 or InStr(Dlg.Text, "/") <> 3 Then 
    Form.Controls("T_ATTR_TENDER_UNIQUE_NUM").ActiveX.ForeColor = RGB(255,0,0)
    else Form.Controls("T_ATTR_TENDER_UNIQUE_NUM").ActiveX.ForeColor = RGB(0,0,0)
    End If 
    End If
'    16/2.1/0001045/КГПНГП   
      
      If Err.Number <> 0 Then
        Msgbox "Значение поля должно быть уникальным!", VbCritical
      End If
      On Error GoTo 0
    End If
  End If
End Sub


'Кнопка - Редактировать список аналогов
'-----------------------------------------------------------------------
Sub BtnAnalogOnclic(Form, Obj) 'BUTTON_ANALOG_OnClick()

  set btnfav = Form.Controls("BUTTON_ANALOG").ActiveX
  Set Obj = Obj
  If Obj.Permissions.Locked <> FALSE Then 
    If Obj.Permissions.LockUser.SysName <> ThisApplication.CurrentUser.SysName Then
      Msgbox "Документ заблокирован пользователем " & Obj.Permissions.LockUser.Description,vbInformation,"Ошибка изменения документа"
      Exit Sub
    End If
  End If
  If Obj.Attributes.Has("ATTR_TENDER_ANALOG_TABLE") Then
  Check = not Form.Controls("ATTR_TENDER_ANALOG_TABLE").Visible
  Form.Controls("ATTR_TENDER_ANALOG_TABLE").Visible = Check
  Form.Controls("ATTR_TENDER_ANALOG_LIST").Visible = not Check
  str = ""
  Set Table =  Obj.Attributes("ATTR_TENDER_ANALOG_TABLE")
  If Not Table Is Nothing Then
    set rows = Table.Rows
       for each row in rows
     If row.Attributes.Has("ATTR_TENDER") Then
        If row.Attributes("ATTR_TENDER").Empty = False Then
          set analog = row.Attributes("ATTR_TENDER").object
          If str <> "" Then
                str =   str & ", " & analog.Description & chr(10) 
              Else
                str = "" & analog.Description & chr(10) 
              End If
    Obj.Attributes("ATTR_TENDER_ANALOG_LIST")= str
             End If
         End If
       next
     end if
  end if
 Form.Refresh
End Sub

'Кнопка - Согласовать
'-----------------------------------------------------------------------
Sub BtnAgreedOnclic(Form, Obj) 'BUTTON_AGREED_OnClick()
If Obj.StatusName = "STATUS_TENDER_DRAFT" Then
call MainControlsBackColorOff (Form, Obj, Str)
   ' Красим желтым, или серым контролы проверяемых атрибутов
 str = ThisApplication.ExecuteScript("OBJECT_TENDER_INSIDE","TenderInsideCheck",Obj)
 If str = False Then Exit Sub
  If str <> true then
  Call MainControlsBackColorAlarm(Form,Obj,Str)
  Exit Sub
  End if 
 End if 
   Set Dlg = ThisApplication.Dialogs.EditObjectDlg
   Dlg.Object = Obj
   Obj.Dictionary.Item("FormActive") = "FORM_KD_DOC_AGREE"
   Obj.SaveChanges
   Form.Close True
   Dlg.Show
   
End Sub

Sub BtnAddContract(Form, Obj) 'BUTTON_ADD_CONTRACT_OnClick()
  'Создание договора
  If Obj.ObjectDefName = "OBJECT_TENDER_INSIDE" Then
    Set cClass = ThisApplication.Classifiers.FindBySysId("NODE_CONTRACT_EXP")
  ElseIf Obj.ObjectDefName = "OBJECT_PURCHASE_OUTSIDE" Then
    Set cClass = ThisApplication.Classifiers.FindBySysId("NODE_CONTRACT_PRO")
  End If
  
  If Not cClass Is Nothing Then 
    Set Contract = ThisApplication.ExecuteScript("CMD_DLL_CONTRACTS","CreateContractByClass",Obj,cClass)
  Else
    Set Contract = ThisApplication.ExecuteScript("CMD_DLL_CONTRACTS","CreateContract",Obj)
  End If
  
  If Contract Is Nothing Then Exit Sub
  'Заполнение атрибутов
  AttrName0 = "ATTR_TENDER_SMOLL_PRICE_FLAG"
  AttrName1 = "ATTR_CONTRACT_LOWCOST"
  If Obj.Attributes.Has(AttrName0) and Contract.Attributes.Has(AttrName1) Then
    Call AttrValueCopy(Obj.Attributes(AttrName0),Contract.Attributes(AttrName1))
  End If
  
  AttrName0 = "ATTR_TENDER_INVITATION_DATA_EIS"
  AttrName1 = "ATTR_EIS_PUBLISH"
  If Obj.Attributes.Has(AttrName0) and Contract.Attributes.Has(AttrName1) Then
    Call AttrValueCopy(Obj.Attributes(AttrName0),Contract.Attributes(AttrName1))
  End If
  
  AttrName0 = "ATTR_TENDER_EXECUT_DATA"
  AttrName1 = "ATTR_FULFILLDATE_PLAN"
  If Obj.Attributes.Has(AttrName0) and Contract.Attributes.Has(AttrName1) Then
    Call AttrValueCopy(Obj.Attributes(AttrName0),Contract.Attributes(AttrName1))
  End If
End Sub
 
'Кнопка - Проверить "Расчетная (максимальная) цена предмета закупки (договора)"
Sub BtnPriceCheck(Form, Obj) 'BUTTON_PRICE_CHECK_OnClick()
  Set Form = ThisApplication.InputForms("FORM_INFO_WITH_TABLE")
  Set Row = Obj.Attributes("ATTR_TENDER_ITEM_PRICE_MAX_VALUE").Rows(0)
  Set Dict = Form.Dictionary
'  AttrName = "ATTR_LOT_NDS_VALUE"
'  Dict.Item(AttrName) = Row.Attributes(AttrName).Value
  AttrName = "ATTR_NDS_VALUE"
  Dict.Item(AttrName) = Row.Attributes(AttrName).Value
  AttrName = "ATTR_TENDER_NDS_PRICE"
  Dict.Item(AttrName) = Row.Attributes(AttrName).Value
  AttrName = "ATTR_TENDER_SUM_NDS"
  Dict.Item(AttrName) = Row.Attributes(AttrName).Value
  AttrName = "ATTR_TENDER_PRICE"
  Dict.Item(AttrName) = Row.Attributes(AttrName).Value
  Form.Show
End Sub
 
 
 
 'Кнопка - Добавить разработчика. Форма Разработчики
Sub BtnDesignerAddOnClick(Form, Obj)'BUTTON_ADD_OnClick()
  ThisScript.SysAdminModeOn
  Set Dlg = ThisApplication.Dialogs.SelectUserDlg
  Dlg.Caption = "Выбор пользователей"
  If Dlg.Show Then
    For Each User in Dlg.Users
      Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,"ROLE_TENDER_DOCS_RESP_DEVELOPER",User)
    Next
    If Dlg.Users.Count > 0 Then Obj.Update
  End If
End Sub

'Кнопка - Удалить разработчика. Форма Разработчики
Sub BtnDesignerDellOnClick(Form, Obj) 'BUTTON_DEL_OnClick()
  ThisScript.SysAdminModeOn
  Set Query = Form.Controls("QUERY_TENDER_DESIGNER_LIST")
  Arr = Query.SelectedItems
  Count = UBound(Arr)
  'Если выделено несколько строк
  If Count > 0 and Query.Value.RowsCount = Query.ActiveX.Count Then
    Key = Msgbox("Удалить выбранных пользователей из состава разработчиков?",vbYesNo+vbQuestions)
    If Key = vbYes Then
      For i = 0 to Count
        Set User = Query.Value.RowValue(Arr(i))
        If not User is Nothing Then
          Call RoleUserDel(Obj,User)
        End If
      Next
      Obj.Update
    End If
  'Если выделена одна строка - глючит ActiveX
  Else
    Set Dict = Form.Dictionary
    If Dict.Exists("SelectedUser") Then
      sRow = Dict.Item("SelectedUser")
      If sRow <> -1 Then
        Set User = Query.Value.RowValue(sRow)
        If not User is Nothing Then
          Key = Msgbox("Удалить выбранных пользователей из состава разработчиков?",vbYesNo+vbQuestions)
          If Key = vbYes Then
          RoleName = "ROLE_TENDER_DOCS_RESP_DEVELOPER"
            Call RoleUserDel(Obj,User,RoleName)
            Obj.Update
          End If
        End If
      End If
    End If
  End If
  ThisScript.SysAdminModeOff
End Sub

 'Текст - ссылка на родителя. Для форм Документа закупки
Sub GoParentTextOnClick(Form, Obj) 'PARENT_LinkClick(Button, Shift, url, bCancelDefault)
if  Obj.Parent is nothing then exit sub
      Set Dlg = ThisApplication.Dialogs.EditObjectDlg 
      Dlg.Object = Obj.Parent
     Dlg.Show  'Отображаем диалог редактирования объекта
End Sub
     
     'Кнопка - Удалить Документ закупки
'-----------------------------------------------------------------------
Sub BtnDocCardDelOnclic(Form, Obj) ' BUTTON_DOC_DEL_OnClick()
  ThisScript.SysAdminModeOn
  Set Query = Form.Controls("QUERY_TENDER_DOCKS_IN_DOC")
  Set Objects = Query.SelectedObjects
  str = ""
  
  'Подтверждение удаления
  If Objects.Count <> 0 Then
    For Each Obj in Objects
      If Obj.Attributes.Has("ATTR_DOCUMENT_NAME") Then
        If Obj.Attributes("ATTR_DOCUMENT_NAME").Empty = False Then
          If str <> "" Then
            str = str & ", """ & Obj.Attributes("ATTR_DOCUMENT_NAME").Value & """"
          Else
            str = """" & Obj.Attributes("ATTR_DOCUMENT_NAME").Value & """"
          End If
        End If
      End If
    Next
    If str = "" Then str = Objects.Count & " документов закупки"
    Key = Msgbox("Удалить " & str & " из системы?",vbYesNo+vbQuestion)
    If Key = vbNo Then Exit Sub
  Else
    Exit Sub
  End If
  
  'Удаление строк из таблицы
  For Each Obj in Objects
    Obj.Erase
   Next
  Form.Refresh
End Sub
     
     
'Процедура Вычислить цену лота 
Function BtnLotPriceCalc(Form, Obj, Param) 'Sub BUTTON_PLAN_PRICE_CALC_OnClick()
  ThisScript.SysAdminModeOn
  AttrName = "ATTR_LOT_DETAIL" 'Таблица состава лота
  AttrName0 = "ATTR_TENDER_NDS_PRICE" 'Цена позиции с НДС  
  AttrName1 = "ATTR_TENDER_LOT_NDS_PRICE" 'Цена лота с НДС
  AttrName2 = "ATTR_TENDER_LOT_PRICE" 'Цена лота без НДС 
  AttrName3 = "ATTR_TENDER_PRICE" 'Цена позиции без НДС   
  AttrName4 = "ATTR_NDS_VALUE" ' Ставка НДС позиции       
  AttrName5 = "ATTR_LOT_NDS_VALUE" 'Ставка НДС лота
  AttrName6 = "ATTR_TENDER_LOT_UNIT_PRICE" 'Цена за единицу
  AttrName7 = "ATTR_TENDER_SUM_NDS" 'Сумма НДС
  
  If Not Obj.Attributes.Has(AttrName7)Then ThisApplication.ExecuteScript "CMD_DLL","SetAttr", Obj, AttrName7, 0 
  If Not Obj.Attributes.Has(AttrName6)Then ThisApplication.ExecuteScript "CMD_DLL","SetAttr", Obj, AttrName6, 0
  
  If IsEmpty(Param) = True Then Param = 1
  

Set Table =  Obj.Attributes(AttrName)
  If Not Table Is Nothing Then
    set rows = Table.Rows
  End If
    
  If Not rows Is Nothing Then
    for each row in rows 
    If not row.Attributes(AttrName0).Empty = True or not row.Attributes(AttrName3).Empty = True then  frm = true
    next
  End If
   If frm = False Then
'    Msgbox "В составе нет позиций с заданной ценой", vbInformation
'    Exit Function
   End If  
   
  Sum = 0
  Sum1 = 0
  Sum2 = 0
  Sum3 = 0
  Check2 = False
  Check3 = False
  Check4 = False
  bet = Empty
  
  Form.Controls("T_ATTR_TENDER_LOT_NDS_PRICE").ActiveX.ForeColor = RGB(0,0,0)
  Form.Controls("T_ATTR_TENDER_LOT_PRICE").ActiveX.ForeColor = RGB(0,0,0)
  Form.Controls("T_ATTR_LOT_NDS_VALUE").ActiveX.ForeColor = RGB(0,0,0) 
  Form.Controls("T_ATTR_TENDER_SUM_NDS").ActiveX.ForeColor = RGB(0,0,0)
   
   for each row in rows  
  
    If row.Attributes.Has(AttrName7) Then
        If row.Attributes(AttrName7).Empty = False Then
        row.Attributes(AttrName7).Value = Round(row.Attributes(AttrName7).Value,2)
        Sum2 = Sum2 + row.Attributes(AttrName7).Value
        Else 
        Check3 = True
        Form.Controls("T_ATTR_TENDER_SUM_NDS").ActiveX.ForeColor = RGB(255,0,0)
        End If 
       End If  
   
   If row.Attributes.Has(AttrName6) Then
        If row.Attributes(AttrName6).Empty = False Then
        row.Attributes(AttrName6).Value = Round(row.Attributes(AttrName6).Value,2)
         If Sum3 = 0 Then Sum3 = row.Attributes(AttrName6).Value
         If Sum3 <> row.Attributes(AttrName6).Value Then Check4 = True
        End If 
   End If        
  
      If row.Attributes.Has(AttrName0) Then
        If row.Attributes(AttrName0).Empty = False Then
        row.Attributes(AttrName0).Value = Round(row.Attributes(AttrName0).Value,2)
        Sum = Sum + row.Attributes(AttrName0).Value
        Else 
        Check2 = True
        Form.Controls("T_ATTR_TENDER_LOT_PRICE").ActiveX.ForeColor = RGB(255,0,0)
        End If 
       End If  
        
       If row.Attributes(AttrName3).Empty = False Then 'and Check2 = false Then
        Sum1 = Sum1 + row.Attributes(AttrName3).Value
        row.Attributes(AttrName3).Value = Round(row.Attributes(AttrName3).Value,2)
       Else 
       Check2 = True
       End If
       
       If row.Attributes(AttrName3).Empty = true then
       Form.Controls("T_ATTR_TENDER_LOT_NDS_PRICE").ActiveX.ForeColor = RGB(255,0,0)
       End If 
        
       If row.Attributes(AttrName4).Empty = False  Then 
       if bet = Empty then  bet = row.Attributes(AttrName4)
        If bet = row.Attributes(AttrName4) then
        Check1 = false
        elseif bet <> row.Attributes(AttrName4) and Check1 = false then
        Check1 = True
'        bet = row.Attributes(AttrName4)
       bet = "Составной"
        End If
       End If 
          
   Next
   
     If Obj.Attributes(AttrName1).Value <> Sum Then
     Obj.Attributes(AttrName1).Value = Round(Sum,2)
     End If  
  
     If Obj.Attributes(AttrName2).Value <> Sum1 Then
     Obj.Attributes(AttrName2).Value = Round(Sum1,2)
     End If  
     
     If Check1 = False Then
     Obj.Attributes(AttrName5) = bet
'      If Param = 3 Then BtnLotPriceCalc = bet
     else
     Obj.Attributes(AttrName5).Classifier = ThisApplication.Classifiers("NODE_F7E00034_5715_45AB_8952_0860746AD1C6").Classifiers.Find("Составной")
     bet = "Составной"
'      If Param = 3 Then  Form.Controls("ATTR_LOT_NDS_VALUE_TEXT").ActiveX.Text = "Составной"
    End If
    
    If Param = 1 Then BtnLotPriceCalc = Round(Sum1,2)
    If Param = 2 Then BtnLotPriceCalc = Round(Sum,2)
    If Param = 3 Then BtnLotPriceCalc = bet
    If Param = 4 Then BtnLotPriceCalc = Round(Sum2,2)
    If Param = 5 and Check4 = False Then BtnLotPriceCalc = Sum3
    If Param = 5 and Check4 = True Then BtnLotPriceCalc = 0
End Function     


' Проверка состава лота
'_____________________________________________________________
'Процедура Вычислить цену лота 
Sub BtnLotPriceCheck(Form, Obj) 'Sub BUTTON_PLAN_PRICE_CALC_OnClick()
  ThisScript.SysAdminModeOn
  AttrName = "ATTR_LOT_DETAIL" 'Таблица состава лота
  AttrName0 = "ATTR_TENDER_NDS_PRICE" 'Цена позиции с НДС  
  AttrName1 = "ATTR_TENDER_LOT_NDS_PRICE" 'Цена лота с НДС
  AttrName2 = "ATTR_TENDER_LOT_PRICE" 'Цена лота без НДС 
  AttrName3 = "ATTR_TENDER_PRICE" 'Цена позиции без НДС   
  AttrName4 = "ATTR_NDS_VALUE" ' Ставка НДС позиции       

  AttrName5 = "ATTR_LOT_NDS_VALUE" 'Ставка НДС лота

Set Table =  Obj.Attributes(AttrName)
  If Not Table Is Nothing Then
    set rows = Table.Rows
  End If
    
  If Not rows Is Nothing Then
    for each row in rows 
    If not row.Attributes(AttrName0).Empty = True or not row.Attributes(AttrName3).Empty = True then  frm = true
    next
  End If
   If frm = False Then
    Msgbox "В составе нет позиций с заданной ценой", vbInformation
'    Exit Sub
   End If  
   
  Sum = 0
  Check2 = False
  bet = Empty
  Form.Controls("T_ATTR_TENDER_LOT_NDS_PRICE").ActiveX.ForeColor = RGB(0,0,0)
  Form.Controls("T_ATTR_TENDER_LOT_PRICE").ActiveX.ForeColor = RGB(0,0,0)
  Form.Controls("T_ATTR_LOT_NDS_VALUE").ActiveX.ForeColor = RGB(0,0,0) 
   
   
   for each row in rows  
  
      If row.Attributes.Has(AttrName0) Then
        If row.Attributes(AttrName0).Empty = False Then
          Else 
          Check2 = True
          Form.Controls("T_ATTR_TENDER_LOT_PRICE").ActiveX.ForeColor = RGB(255,0,0)
        End If  
          If row.Attributes(AttrName3).Empty = False and Check2 = false Then
          Else 
          Check2 = True
           If row.Attributes(AttrName3).Empty = true then
          Form.Controls("T_ATTR_TENDER_LOT_NDS_PRICE").ActiveX.ForeColor = RGB(255,0,0)
          End If 
        End If  
          If row.Attributes(AttrName4).Empty = False  Then 
          if bet = Empty then  bet = row.Attributes(AttrName4)
           If bet = row.Attributes(AttrName4) then
           Check1 = false
           else
           Check1 = True
           bet = row.Attributes(AttrName4)
           End If
          End If
          End If
  Next
   
   End Sub     

     
  'Создание документа закупки   
'____________________________________________________________ 
Sub NewDocByTipe(Obj,tp,pl,wk,pb,loc)
  ThisScript.SysAdminModeOn
  
  Set Dlg = ThisApplication.Dialogs.FileDlg
  Set ObjDef = ThisApplication.ObjectDefs("OBJECT_PURCHASE_DOC")
  If ObjDef.FileDefs.Count = 0 Then
    Msgbox "Документ закупки не может иметь файлов.", vbExclamation
    Exit Sub
  End If
  str = ""
  '"Файлы ZIP|*.zip|All Files (*.*)|*.*||"
  For Each FileDef in ObjDef.FileDefs
    str0 = FileDef.Description & "|" & FileDef.Extensions & "|"
    If str <> "" Then
      str = str & str0
    Else
      str = str0
    End If
  Next
  str = Replace(str,",",";") & "|"
  
  Dlg.Filter = str
  If Dlg.Show Then
    StrMsg = ""
    If Dlg.FileName = "" Then
      Msgbox "Файлы не выбраны.", vbExclamation
      Exit Sub
    End If
    
    Set OrgObj = Nothing
'    OrgName = "Отдел по договорной работе и закупочным процедурам"
'    For Each StrObj in ThisApplication.ObjectDefs("OBJECT_STRU_OBJ").Objects
'      If StrObj.Attributes.Has("ATTR_NAME") and StrObj.Attributes.Has("ATTR_KD_CHIEF") Then
'        If StrComp(StrObj.Attributes("ATTR_NAME").Value,OrgName,vbTextCompare) = 0 Then
'          Set OrgObj = StrObj
'        End If
'      End If
'    Next
    Set Doc = Obj.Objects.Create(ObjDef)
    Set Clf = ThisApplication.Classifiers.Find("Вид документа закупки")
    If not Clf is Nothing Then Set Clf = Clf.Classifiers.Find(tp)
    Doc.Attributes("ATTR_PURCHASE_DOC_TYPE").Classifier = Clf
    Doc.Attributes("ATTR_DOCUMENT_NAME").Value = tp
    Doc.Attributes("ATTR_TENDER_DOC_TIPE_LOC") = loc ' Лочим тип
    If IsEmpty(pl) = false then Doc.Attributes("ATTR_TENDER_PLAN_DOC") = pl ' Плановый
    If IsEmpty(wk) = false then Doc.Attributes("ATTR_TENDER_INF_CARD_DOC_FLAG") = wk ' рабочий
    If IsEmpty(pb) = false then Doc.Attributes("ATTR_TENDER_DOC_TO_PUBLISH") = pb ' публикуемый
    
    Set CU = ThisApplication.CurrentUser
    Set OrgName = CU
    For Each Fname in Dlg.FileNames
      Set FDef = CheckFileDef(Doc,Fname)
      If not FDef is Nothing Then
        Set NewFile = Doc.Files.Create(FDef.SysName)
        On Error Resume Next
        NewFile.CheckIn FName
        If Err <> 0 Then
          FShortName = Right(FName, Len(Fname) - InStrRev(FName, "\"))
          MsgBox "Файл """ & FShortName & """ уже есть в составе объекта.", vbInformation
          'удалить пустой файл
          NewFile.Erase
        Else
          StrMsg = StrMsg & Chr(13) & FName
          count = count+1
        End If
        On Error Goto 0
      End If
    Next
    
    'Отображаем диалог редактирования объекта
'    Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
'    EditObjDlg.Object = Doc
'  If EditObjDlg.Show Then
'     If not Doc is Nothing Then
'  Obj.Attributes("ATTR_TENDER_ACT").Object = doc
        'Маршрут
'        StatusName = "STATUS_TENDER_CHECK_RESULT"
        RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
        If RetVal = -1 Then
 '          Obj.Status = ThisApplication.Statuses(StatusName)
        End If
'      End If
'    End If
   
   'Результат импорта
'    'If StrMsg <> "" Then 
'    '  MsgBox "К объекту было добавлено " & count & " файлов:" & StrMsg, vbInformation
'    'End If
  End If
  
  ThisScript.SysAdminModeOff
End Sub

'Функция проверки типа файла на доступные для объекта
Function CheckFileDef(Obj,FName)
  Set CheckFileDef = Nothing
  FExtension = "*." & Right(FName, Len(Fname) - InStrRev(FName, "."))
  For Each FDef In Obj.ObjectDef.FileDefs
    If InStr(FDef.Extensions, FExtension) <> 0 Then
      Set CheckFileDef = FDef
      Exit Function
    End If
  Next
End Function    

'Функция проверки типа файла на доступные для объекта
Function CheckNeedPeo(Obj)     
  'Уникальный номер закупки
  AttrName = "ATTR_TENDER_UNIQUE_NUM"
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty Then
      Key = Msgbox("Выдать поручение в ПЭО на расчет стоимости?",vbQuestion+vbYesNo)
      If Key = vbYes Then
        'Создание поручения
        Set CU = ThisApplication.CurrentUser
        resol = "NODE_CORR_REZOL_POD"
        ObjType = "OBJECT_KD_ORDER_SYS"
        Set u = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,"ATTR_TENDER_PEO_CHIF")
        txt = "Прошу назначить исполнителя для расчета стоимости закупки"
        PlanDate = ""
        AttrName = "ATTR_TENDER_PLAN_ZD_PRESENT"
        If Obj.Attributes.Has(AttrName) Then
          PlanDate = Obj.Attributes(AttrName).Value
        End If
        If PlanDate = "" Then PlanDate = Date + 1
        If not u is Nothing Then
          If u.SysName <> CU.SysName Then
            ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,u,CU,resol,txt,PlanDate
          End If
        End If
      End If
    End If
  End If  
End Function 

'Процедура синхронизации атрибутов с внутренней закупкой
Sub AttrsSyncInfCard(Obj)
  If StrComp(Obj.Attributes("ATTR_PURCHASE_DOC_TYPE").Value,"Информационная карта",vbTextCompare) = 0 Then
    If not Obj.Parent is Nothing Then
      Set Parent = Obj.Parent
      AttrStr = "ATTR_TENDER_FACT_MATERIAL_TAKE_OFF_DATA,ATTR_TENDER_ITEM_PRICE_MAX_VALUE," &_
      "ATTR_NDS_VALUE,ATTR_LOT_NDS_VALUE,ATTR_TENDER_START_WORK_DATA,ATTR_TENDER_INVOCE_PUBLIC_DATA," &_
      "ATTR_TENDER_ADVANCE_PLAN_PAY,ATTR_TENDER_ADDITIONAL_REQUIREMENTS,ATTR_TENDER_BID_REQUIREMENTS," &_
      "ATTR_TENDER_GUARANTEE_REQUIREMENTS,ATTR_TENDER_RF_CONF_REQUIREMENTS_DOC_LIST," &_
      "ATTR_TENDER_EXPERIENCE_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_PERSONAL_CONF_REQUIREMENTS_DOC_LIST," &_
      "ATTR_TENDER_RIG_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_ISO9001_REQUIREMENTS,ATTR_TENDER_SMALL_BUSINESS_FLAG," &_
      "ATTR_TENDER_ADDITIONAL_INFORMATION,ATTR_TENDER_END_WORK_DATA,ATTR_TENDER_POSSIBLE_CLIENT"
      ThisApplication.ExecuteScript "CMD_DLL","AttrsSyncBetweenObjs", Obj, Parent, AttrStr
    End If
  End If
End Sub
    
  'Кнопка - Сохранить общая
  Sub  CastomSave(Form, Obj) 'BUTTON_CUSTOM_SAVE_OnClick()
  ThisScript.SysAdminModeOn
  Key = Msgbox("Сохранить внесенные изменения?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
  ThisApplication.Dictionary(Obj.GUID).Item("ObjEdit") = False
  Obj.Dictionary.Item("FormActive") = Form.SysName
  Obj.SaveChanges(0)
  End Sub    
 'Кнопка - Отменить общая  
Sub  CastomCancel(Form, Obj) 'BUTTON_CUSTOM_CANCEL_OnClick()
  ThisScript.SysAdminModeOn
  Key = Msgbox("Отменить внесенные изменения?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
  ThisApplication.Dictionary(Obj.GUID).Item("ObjEdit") = False
  Guid = Obj.GUID
  Form.Close False
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Set Obj = ThisApplication.GetObjectByGUID(Guid)
    Dlg.Object = Obj
 Obj.Dictionary.Item("FormActive") = Form.SysName
  Dlg.Show
 ThisScript.SysAdminModeOff 
 End Sub
 
 'Блокировка кнопок - Сохранить/Отменить общая
  Sub  CastomSaveCancelBlock(Form, Obj)
  Check = False
   If ThisApplication.Dictionary(Obj.GUID).Exists("ObjEdit") Then
    If ThisApplication.Dictionary(Obj.GUID).Item("ObjEdit") = True Then
     Check = True
    End If
   End If
    Form.Controls("BUTTON_CUSTOM_SAVE").Enabled = Check
    Form.Controls("BUTTON_CUSTOM_CANCEL").Enabled = Check
 End Sub
   
   
   
   'Функция возвращает документ закупки с типом "Информационная карта"
Function InfoDocGet(Obj)
  Set InfoDocGet = Nothing
  Set Clf0 = ThisApplication.Classifiers.Find("Вид документа закупки")
  If Clf0 is Nothing Then Exit Function
  Set Clf = Clf0.Classifiers.Find("Информационная карта")
  If Clf is Nothing Then Exit Function
  AttrName = "ATTR_PURCHASE_DOC_TYPE"
  For Each Doc in Obj.Objects
    If Doc.Attributes.Has(AttrName) Then
      If Doc.Attributes(AttrName).Empty = False Then
        If not Doc.Attributes(AttrName).Classifier is Nothing Then
          If Doc.Attributes(AttrName).Classifier.SysName = Clf.SysName Then
            Set InfoDocGet = Doc
            Exit Function
          End If
        End If
      End If
    End If
  Next
End Function
   
   'Функция блокирует контролы на форме Инф карта Внутренней закупки если "Информационная карта" заблокирована
'-----------------------------------------------------------------------------------------------------------------
Function InfoDocFrmCtrlLock(Form, Obj)   
  Set Doc = InfoDocGet(Obj)
  Set CU = ThisApplication.CurrentUser
  If not Doc is Nothing Then
'  msgbox Doc.Permissions.Locked
     If Doc.Permissions.Locked = True Then
      If not Doc.Permissions.LockUser is nothing Then
       If Doc.Permissions.LockUser.SysName <> CU.SysName Then
       Call InfoDocFrmCtrlLockAll(Form, Obj)
       Call InfoDocFrmInfo(Form, Obj, Doc)
       Form.Controls("BUTTON_EDIT").Enabled = false
       Form.Controls("BUTTON_TO_APPROVE").Enabled = false
       End If 
      End If 
     End If
   End If 
End Function

  'Функция отображает блокирующие надписи и кнопки разблокировки на форме Инф карта Внутренней закупки 
  'если "Информационная карта" заблокирована
'-----------------------------------------------------------------------------------------------------------------
Function InfoDocFrmInfo(Form, Obj, Doc)   
 ' Блокируем кнопку разблокировки
  Form.Controls("BUTTON_RED").Enabled = false 
   ' Отображаем кнопку запроса разблокировки
    If Form.Controls.Has("BUTTON_ASK_UNLOCK") Then Form.Controls("BUTTON_ASK_UNLOCK").Visible = True 
 ' Отображаем надпись блокировки другим пользователем
  If Form.Controls.Has("LocText") Then
   Form.Controls("LocText").ActiveX.BackColor = RGB(255,254,213)
   Form.Controls("LocText").Visible = True
   Form.Controls("LocText").ActiveX.text = "В настоящий момент Информационная карта редактируется пользователем " _
   & Doc.Permissions.LockUser.Description & " с " & Doc.Permissions.LockTime & " ПК " & Doc.Permissions.LockComputer
  End If
End Function
   
      'Функция блокирует контролы на форме Инф карта Внутренней закупки
'-----------------------------------------------------------------------------------------------------------------
Function InfoDocFrmCtrlLockAll(Form, Obj)   
  Set pAttrs = ThisApplication.ObjectDefs("OBJECT_PURCHASE_DOC").AttributeDefs
  Set oAttrs = Obj.ObjectDef.AttributeDefs
      For Each Attr in oAttrs
        SysName = Attr.SysName
          If pAttrs.Has(SysName) and Obj.Attributes.Has(SysName) Then
           If Form.Controls.Has(SysName) Then
           Form.Controls(SysName).ReadOnly = True
           End If
          End If
      Next   
    Attrstr = "QUERY_TENDER_POSSIBLE_CLIENT,"  
      Call CtrlBlock(Form, Obj, Attrstr)
'      Отображаем блокирующие надписи и кнопки разблокировки, если заблокирована Инф карта
     Set Doc = InfoDocGet(Obj)
     Set CU = ThisApplication.CurrentUser
     If not Doc is Nothing Then
      If Doc.Permissions.Locked = True Then
       If not Doc.Permissions.LockUser is nothing Then
        If Doc.Permissions.LockUser.SysName <> CU.SysName Then   
        Call InfoDocFrmInfo(Form, Obj, Doc)
       End If 
      End If 
     End If
   End If
End Function
 
       'Функция разблокирует контролы на форме Инф карта Внутренней закупки
'-----------------------------------------------------------------------------------------------------------------
Function InfoDocFrmCtrlUnlock(Form, Obj)   
  Set pAttrs = ThisApplication.ObjectDefs("OBJECT_PURCHASE_DOC").AttributeDefs
  Set oAttrs = Obj.ObjectDef.AttributeDefs
      For Each Attr in oAttrs
        SysName = Attr.SysName
          If pAttrs.Has(SysName) and Obj.Attributes.Has(SysName) Then
           If Form.Controls.Has(SysName) Then
           Form.Controls(SysName).ReadOnly = False
           End If
          End If
      Next   
    Attrstr = "BUTTON_EDIT,QUERY_TENDER_POSSIBLE_CLIENT,BUTTON_TO_APPROVE,"  
      Call CtrlUnlock(Form, Obj, Attrstr)
End Function  
   
   
   
  'Функция проверки листа согласования на наличие обязательных пользователей в списке согласующих
  '-----------------------------------------------------------------------------------------------
function GetAggrList(Obj, Userstr)
  GetAggrList = False
  Check = False
  list = ""
  ThisApplication.Utility.WaitCursor = True
  set agreeObj = ThisApplication.ExecuteScript ("CMD_KD_AGREEMENT_LIB","GetAgreeObjByObj",Obj.parent)
  If agreeObj Is Nothing Then Exit function
  ver = agreeObj.Attributes("ATTR_KD_CUR_VERSION").value
  Set TAttrRows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows
  
 ArUser = Split(Userstr,",")
 For n = 0 to Ubound(ArUser)
 GetAggrList = False
 User = ArUser(n)
' msgbox User
  for each row in TAttrRows
'   msgbox User & " = "& row.Attributes("ATTR_KD_APRV").User.sysname
    If ver  = row.Attributes("ATTR_KD_CUR_VERSION").Value And _
      row.Attributes("ATTR_KD_APRV").User.sysname = User  Then
      GetAggrList = True
      exit for
    End If
    next
     If  GetAggrList <> True Then
     set Usr = ThisApplication.Users(user)
     list = list & chr(10) & chr(10) & Usr.description
     '      count = count + 1
'     then count = count + 1
'    aprover = row.Attributes("ATTR_KD_APRV").value
      End If
   
 Next  
  ThisApplication.Utility.WaitCursor = False
'  if count = 0 then 
' msgbox GetAggrList
  if not GetAggrList = True then 
      msgbox "Согласование невозможно, т.к. в листе согласования отсутствуют:"  & list &_
         chr(10) & chr(10) & "Для отправки на согласование добавьте недостающих, обязательных для согласования Информационной карты, пользователей", vbCritical,  _
          "Отправить на согласование невозможно"
      exit function    
  end if
'  GetAggrList = True
end function
   
'============================================================================================
'Функция получения номера лота
'Функция формирования Обозначения документа закупки
'Obj - ссылка на Задание
Function LotNumGen(Obj)
  LotNumGen = ""
  Set parent = Obj.parent
  If Parent Is Nothing Then exit Function
  Set QueryLot = ThisApplication.Queries("QUERY_GET_LOT_MAX_NO")
  QueryLot.Parameter("PARENT") = Parent
  Set Objects = QueryLot.Objects
'  msgbox Objects.Count
  LotNumGen = Objects.Count + 1
   'Проверка на повтор
  QueryLot.Parameter("CODE") = LotNumGen
  Do While QueryLot.Objects.Count > 0
    i = i + 1
    LotNumGen = i & Val
    QueryLot.Parameter("CODE") = LotNumGen
  Loop

End Function

'============================================================================================   
   
'Функция выдачи поручений пользователям из списка (табл) (только для информации)
'ATTR_RESPONSIBLE - атрибут в котором пользователь
'Obj - ссылка на объект
Function OrderGenByList(Obj, Tbl, txt)
If IsEmpty(Obj) = True or IsEmpty(Tbl) = True Then Exit Function
 ' Параметры поручения
  set CU = ThisApplication.CurrentUser
  Set uFromUser = CU
  resol = "NODE_CORR_REZOL_INF"
  ObjType = "OBJECT_KD_ORDER_NOTICE"
  If IsEmpty(txt) = True Then 
  txt = "Прошу ознакомиться """ & Obj.Description & """"
  End If
  planDate = Date
   ' Гарантируем себе наличие таблицы
  If Obj.Attributes.Has(Tbl) = False Then
    Obj.Attributes.Create ThisApplication.AttributeDefs(Tbl) ' "ATTR_TENDER_OUT_FLOW_CASTOM"
  End If
  ' Пользователи в массив  
  Set Table =  Obj.Attributes(Tbl)
  If Not Table Is Nothing Then
  set rows = Table.Rows
  End If
  If rows Is Nothing Then 
'      msgbox "Нет пользователей в списке"
      Exit Function
  End If     
  If Not rows Is Nothing Then
 
Dbl = ""
Str = ""
Emp = True
for each row in rows

If row.Attributes.Has("ATTR_RESPONSIBLE") Then
 If row.Attributes("ATTR_RESPONSIBLE").Empty = False Then
 Set uToUser = row.Attributes("ATTR_RESPONSIBLE").user
  If not uToUser is Nothing Then 
  Emp = False
   If Str = "" Then 
   Str = uToUser.sysname
   Else
   Str = Str & "," & uToUser.sysname
   End If
   Ar = Split(Str,",") 
  End If
 End If
End If
Next
If Str = "" Then 
'msgbox "Нет пользователей в списке"
Exit Function
End If  
'Выдаем поруения и роли на просмотр, исключая повторы и тещего пользователя
m = Ubound(Ar)
Str = ""
 For n = 0 to m
          UserSys = Ar(m) 
'          msgbox Join (Ar, "-")
    If Not UserSys = "" Then
    set uToUser = ThisApplication.Users(UserSys)
    If Not uToUser.sysname = CU.sysname then
    Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,"ROLE_VIEW",uToUser)
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,uToUser,CU,Resol,Txt,PlanDate
     If Str = "" Then 
     Str = uToUser.description
     Else
     Str = Str & "," & uToUser.description
     End If 
    End If
    End If
    Ar = Filter (Ar, UserSys, False, vbTextCompare)
    m = Ubound(Ar)
    If m < 0 Then Exit For
    next
    OrderGenByList = Str
End If
End Function


'============================================================================================   
   
'Функция возвращает массив пользователей из списка (табл) без повторов
'ATTR_RESPONSIBLE - атрибут в котором пользователь
'Obj - ссылка на объект
'Tbl - таблица с атрибутом Atr
'Atr - атрибут Ссылка на пользователя

Function GetUnicUserList(Obj, Tbl, Atr)
If IsEmpty(Obj) = True or IsEmpty(Tbl) = True or IsEmpty(Atr) = True Then Exit Function
'If IsEmpty(Flg) = True Then Flg = 1
  ' Пользователи в массив  
  Set Table =  Obj.Attributes(Tbl)
  If Not Table Is Nothing Then
  set rows = Table.Rows
  End If
  If rows Is Nothing Then 
'      msgbox "Нет пользователей в списке"
      Exit Function
  End If     
If Not rows Is Nothing Then
Str = ""
for each row in rows
If row.Attributes.Has(Atr) Then
 If row.Attributes(Atr).Empty = False Then
 Set uToUser = row.Attributes(Atr).user
  If not uToUser is Nothing Then 
   If Str = "" Then 
   Str = uToUser.sysname
   Else
   Str = Str & "," & uToUser.sysname
   End If
   Ar = Split(Str,",") 
  End If
 End If
End If
Next
If Str = "" Then 
'msgbox "Нет пользователей в списке"
Exit Function
End If  
'Формируем массив, исключая повторы
m = Ubound(Ar)
Str = ""
 For n = 0 to m
          UserSys = Ar(m) 
'          msgbox UserSys
'          msgbox Join (Ar, "-")
    If Not UserSys = "" Then
 
'    set uToUser = ThisApplication.Users(UserSys)
'    ArUs =  Array (ArUs, uToUser) '
     If Str = "" Then 
     Str = UserSys
     Else
     Str = Str & "," & UserSys

     End If 
    End If
    Ar = Filter (Ar, UserSys, False, vbTextCompare)
    m = Ubound(Ar)
    If m < 0 Then Exit For
    next
'   If flg = 1 then 
'     msgbox Str
   GetUnicUserList = Str
   
'   If flg = 2 then 
'   GetUnicUserList = ArUs
'    msgbox ""
'   For n = 0 to Ubound(ArUs)
'        Set  UserSys = ArUs(n) 
'      msgbox UserSys.sysname
'      next 
'  End If
End If
End Function  

'Sub PurchaseCloseOrderNotice(Doc,Resol,ObjType,Txt,PlanDate,Str,CU,u)
'  If not u is Nothing and ThisApplication.Dictionary("CMD_TENDER_OUT_CLOSE").Exists(u.SysName) = False Then
'    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Doc,ObjType,u,CU,Resol,Txt,PlanDate
'    ThisApplication.Dictionary("CMD_TENDER_OUT_CLOSE").Item(u.SysName) = True
'    If u.SysName <> CU.SysName Then
'      If Str <> "" Then
'        Str = Str & ", " & chr(10) & u.Description
'      Else
'        Str = u.Description
'      End If
'    End If
'  End If
'End function



'Вынимаем значения из даблицы по атрибутно
'    For each row In Obj.Attributes(Table).Rows
'    If row.Attributes("ATTR_KD_OBJ_TYPE").Value = Obj.ObjectDefName Then
'      StatusAfterAgreed = row.Attributes("ATTR_KD_FINISH_STATUS").Value
'      StatusReturnAfterAgreed = Row.Attributes("ATTR_KD_RETURN_STATUS")
'      Exit For
'    End If
'  Next

'Вынимаем комент из классификатора
'Set Attr = Child.Attributes(AttrName)
'            If Attr.Empty = False Then
'              If not Attr.Classifier is Nothing Then
'                If Attr.Classifier.Comments.count>0 Then
'                  Val = Attr.Classifier.Comments(0).Text
'                  If InStr(1,Val,"СМСП",vbTextCompare) <> 0 Then
   
 '============================================================================================   
   
    Function SetOBDNC(Obj)
'    ThisApplication.ExecuteScript"CMD_TENDER_OBJ_LIB","SetOBDNC",ThisObject
    If IsEmpty(Obj) = True Then Exit Function
      'Заполнение текстового атрибута "Код ОБД НСИ победителя"
   AttrName1 = "ATTR_TENDER_WINER_EIS_COD"   
   AttrName2 = "ATTR_TENDER_WINER_EIS"
   If Obj.Attributes.Has(AttrName2) Then
    If Obj.Attributes(AttrName2).Empty = False Then
    Set Iobj = Obj.Attributes(AttrName2).object
     If not Iobj is Nothing Then 
      If Iobj.Attributes.Has("ATTR_OBDNSI") Then
       If Iobj.Attributes("ATTR_OBDNSI").Empty = False Then
        Oattrv = Iobj.Attributes("ATTR_OBDNSI").value
        If Obj.Attributes.Has(AttrName1) Then Obj.Attributes(AttrName1) = Oattrv
        else 
        If Obj.Attributes.Has(AttrName1) Then Obj.Attributes(AttrName1) = ""
       End If 
      End If 
     End If
    End If
   End If 
End Function     
   
  ' Коды ОБД НСИ поставщиков 
  'Переводит табличный атрибут в строку через запятую
  
'  TablToStr = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","TablToStr",ThisObject, "ATTR_TENDER_POSSIBLE_CLIENT", "ATTR_COR_USER_CORDENT", "ATTR_OBDNSI")
  Function TablToStr(Obj, Tbl, Atr, Oattr)
  
If IsEmpty(Obj) = True or IsEmpty(Tbl) = True or IsEmpty(Atr) = True Then Exit Function
If IsEmpty(Tbl) = True Then  Set Tbl = "ATTR_TENDER_POSSIBLE_CLIENT"
  ' Объекты в массив  
  Set Table =  Obj.Attributes(Tbl)
  If Not Table Is Nothing Then
  set rows = Table.Rows
  End If
  If rows Is Nothing Then 
      msgbox "Нет пользователей в списке"
      Exit Function
  End If     
If Not rows Is Nothing Then
Str = ""
for each row in rows
If row.Attributes.Has(Atr) Then
 If row.Attributes(Atr).Empty = False Then
 Set Iobj = row.Attributes(Atr).object
  If not Iobj is Nothing Then 
   If Iobj.Attributes.Has(Oattr) Then
    If Iobj.Attributes(Oattr).Empty = False Then
    Oattrv = Iobj.Attributes(Oattr).value
     If Str = "" Then 
     Str = Oattrv
     Else
     Str = Str & "," & Oattrv
     End If
     Ar = Split(Str,",") 
    End If
   End If
  End If
 End If
End If
Next

If Str = "" Then 
'msgbox "Нет в списке"
Exit Function
End If  

'Формируем массив, исключая повторы
m = Ubound(Ar)
Str = ""
 For n = 0 to m
          Sys = Ar(m) 
    If Not Sys = "" Then
     If Str = "" Then 
     Str = Sys
     Else
     Str = Str & ", " & Sys
     End If 
    End If
    Ar = Filter (Ar, Sys, False, vbTextCompare)
    m = Ubound(Ar)
    If m < 0 Then Exit For
    next
   TablToStr = Str
End If
End Function  

'Проверка отдела 
'Dept = "Группа планирования и проведения конкурентных закупок"
function CheckDept(Dept)
  'Проверка отдела
  Set CU = ThisApplication.CurrentUser
  AttrName = "ATTR_KD_USER_DEPT"
  If CU.Attributes.Has(AttrName) Then
    If CU.Attributes(AttrName).Empty = False Then
      If not CU.Attributes(AttrName).Object is Nothing Then
        Set Dept = CU.Attributes(AttrName).Object
        Val = Dept.Attributes("ATTR_NAME").Value
        If StrComp(Val, Dept, vbTextCompare) <> 0 Then
          Check = False
        End If
      Else
        Check = False
      End If
    Else
      Check = False
    End If
  Else
    Check = False
  End If
  CheckDept = Check
 End Function    
   
'Универсальные функции
'-----------------------------------------------------------------------
'-----------------------------------------------------------------------
'Блокировка универсальная. Attrstr строковая через запятую. 
'Блокирует атрибуты Attrstr для всех

function CtrlBlock(Form, Obj, Attrstr)

If IsEmpty(Obj) = False and IsEmpty(Attrstr) = False and IsEmpty(Form) = False Then
   ArAttr = Split(Attrstr,",")
    For n = 0 to Ubound(ArAttr)
     If Form.controls.Has(ArAttr(n)) = true Then
     Form.Controls(ArAttr(n)).ReadOnly = True
'    Form.Controls(ArAttr(n)).Enabled = false
'    Form.Controls(ArAttr(n)).Visible = True
     End If 
   Next
End If 
End function

'Разблокировка универсальная. Attrstr строковая через запятую. 
'Разблокирует атрибуты Attrstr для всех

function CtrlUnlock(Form, Obj, Attrstr)

If IsEmpty(Obj) = False and IsEmpty(Attrstr) = False and IsEmpty(Form) = False Then
   ArAttr = Split(Attrstr,",")
    For n = 0 to Ubound(ArAttr)
     If Form.controls.Has(ArAttr(n)) = true Then
     Form.Controls(ArAttr(n)).ReadOnly = False
     Form.Controls(ArAttr(n)).Enabled = True
     Form.Controls(ArAttr(n)).Visible = True
     End If 
   Next
End If 
End function






'Блокировка универсальная. Attr, User, Stat, Grope - строковые, через запятую. flag - False или True Если критерий сравн. критерий = flag - проходим

function AttrBlockByGropeRoleStat(Form, Obj, Attr, User, Stat, Grope, flag)
If flag = False Then Flg = 0
If flag = True Then Flg = 1

If IsEmpty(Grope) = False and IsEmpty(Attr) = False Then
    ArGrope = Split(Grope,",")
For i = 0 to Ubound(ArGrope)
 If User.Groups.Has(ArGrope(i)) = flag Then
If IsEmpty(Stat) = False Then
  ArStat = Split(Stat,",")
  For j = 0 to Ubound(ArStat)
   If StrComp(Obj.Status.SysName,ArStat(j),vbTextCompare) = Flg Then 
'    Msgbox  StrComp(Obj.Status.SysName,ArStat(j),vbTextCompare) & Flg,vbExclamation 
     exit function
   End If
  Next
  End If
'   If StrComp(Obj.Status.SysName,ArStat(j),vbTextCompare) = 0 Then
''   If  flag Obj.Status.SysName = ArStat(i) Then
' Msgbox  StrComp(Obj.Status.SysName,ArStat(j),vbTextCompare) & Flg,vbExclamation 
'    If IsEmpty(Attr) = False Then
   ArAttr = Split(Attr,",")
    For n = 0 to Ubound(ArAttr)
    If Form.controls.Has(ArAttr(n)) = true Then
      Form.Controls(ArAttr(n)).ReadOnly = True
     End If 
      Next
  End If 
 Next
End If 

If IsEmpty(Grope) = True and IsEmpty(Attr) = False Then
If IsEmpty(Stat) = False Then
  ArStat = Split(Stat,",")
  For j = 0 to Ubound(ArStat)
   If StrComp(Obj.Status.SysName,ArStat(j),vbTextCompare) = Flg Then exit function
  Next
 End If
   ArAttr = Split(Attr,",")
    For n = 0 to Ubound(ArAttr)
      If Form.controls.Has(ArAttr(n)) = true Then
      Form.Controls(ArAttr(n)).ReadOnly = True
     End If 
    Next
End If
End function


'Блокировка универсальная. Attrstr, Userstr, - строковые, через запятую. 
'Блокирует атрибуты Attrstr для всех,кроме пользователей в атрибутах Userstr

function AttrBlockByUserInAttr(Form, Obj, Attrstr, Userstr)

If IsEmpty(Obj) = False and IsEmpty(Attrstr) = False and IsEmpty(Userstr) = False Then
 Set CU = ThisApplication.CurrentUser
 ArUser = Split(Userstr,",")
 For i = 0 to Ubound(ArUser)
  Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,ArUser(i))
    If CU.SysName = User.SysName Then exit function
   ArAttr = Split(Attrstr,",")
    For n = 0 to Ubound(ArAttr)
     If Form.controls.Has(ArAttr(n)) = true Then
     Form.Controls(ArAttr(n)).ReadOnly = True
     End If 
    Next
 Next
End If 
End function


'Проверка атрибутов универсальная. По строке Attr формирует строки ID и имен незаполненных полей. 
'Если flag - True - в строку ID идут заполненные атрибуты, а сообщение не выдается. AttrDef.Type = tdmInteger

function AttrCheckAttr(Form, Obj, AttrStr, flag)
Arr = Split(AttrStr,",")
    For i = 0 to Ubound(Arr)
    AttrName = Arr(i)
      If ThisApplication.AttributeDefs.Has(AttrName) and Obj.Attributes.Has(AttrName) Then
        Set Attr = ThisApplication.AttributeDefs(AttrName)
'       AttrType = TDMSAttributeDef.Description(Attr)
       AttrType = Attr.Type
'          AttrType = TypeName(Attr)
'         Msgbox " " & AttrType  & " - " & AttrName,vbExclamation
        Check = True
        
       If Attr.Type = 11 then 
'       Msgbox " " & AttrType  & " - " & AttrName,vbExclamation
        Set TableRows = Obj.Attributes(AttrName).Rows
'         Msgbox " " & TableRows.Count ,vbExclamation 
         If TableRows.Count = 1 Then 
          Set Row = TableRows(0)
          Check = True
          For Each Att in Row.Attributes
'           Msgbox " " & Att.Empty ,vbExclamation 
           If Att.Empty = true Then 
'             Str1 = Str1 & chr(10) & "-       " & Attr.Description & Att.Description
'              Msgbox " " & Attr.Description  & " - " & Row.Attributes(j),vbExclamation
             Check = False
            End If 
          Next
           If Check = False Then
            Str2 = Str2 & "," & AttrName 
            Str1 = Str1 & chr(10) & "-       " & Attr.Description
           ElseIf Check = true Then Str3 = Str3 & "," & AttrName
           End If
           End If
        ElseIf Attr.Type <> 11 then
         Check = True  
        If Obj.Attributes(AttrName).Empty Then
           Str2 = Str2 & "," & AttrName 
          Check = False
        elseif Obj.Attributes(AttrName).Empty = False Then Str3 = Str3 & "," & AttrName
        End If
        If Check = False Then
          If Str1 = "" Then
            Str1 = "-       " & Attr.Description
          Else
           Str1 = Str1 & chr(10) & "-       " & Attr.Description
          End If
        End If
      End If
      End If
     Next
'    End If
    
'     Msgbox " " & Str2,vbExclamation
     
      If IsEmpty(flag) = False Then
       If flag = True Then
      AttrCheckAttr = Str3
'      Msgbox " " & Str3,vbExclamation
      exit function
      End If
      End If
     If Str1 <> "" and Str2 <> "" Then
      ThisApplication.Utility.WaitCursor = False
       If IsEmpty(Form) = False Then
      Msgbox "Обязательные атрибуты не заполнены:" & chr(10) & chr(10) & Form.description & "______________________" & chr(10) & chr(10) & Str1 & chr(10) & chr(10) , vbExclamation
      Else
      Msgbox "Обязательные атрибуты не заполнены:" & chr(10) & chr(10) & Obj.description & "______________________" & chr(10) & chr(10) & Str1 & chr(10) & chr(10) , vbExclamation
      End If
      AttrCheckAttr = Str2
     End If
'     End If
  End function
  
  
  'Делаем все проверяемые контролы строки атрибутов светлосерыми. Универсальная
function AttrControlsBackColorOff (Form, Obj, AttrStr)
    Arr = Split(AttrStr,",")
    For i = 0 to Ubound(Arr)
    if Arr(i) <> "" then 
    AttrName =   "T_" & Arr(i)
'     Msgbox  AttrName,vbExclamation
      If Form.controls.Has(AttrName) = true Then
 Form.Controls(AttrName).ActiveX.BackColor = RGB(230,230,230)
      End if
     End if
    next
End function 



'Процедура синхронизации табличных однострочных атрибутов. Универсальная
Sub TablePricesync(Form, Obj1, Obj2, Attr1, Attr2 )
  If Obj1.Attributes.Has(Attr1) and Obj2.Attributes.Has(Attr2) Then
    Set TableRows0 = Obj1.Attributes(Attr1).Rows
    If TableRows0.Count = 0 Then TableRows0.Create
    Set Row0 = TableRows0(0)
    Set TableRows1 = Obj2.Attributes(Attr2).Rows
    If TableRows1.Count = 0 Then TableRows1.Create
    Set Row1 = TableRows1(0)
    For Each Attr in Row0.Attributes
      AttrName = Attr.AttributeDefName
      If Row1.Attributes.Has(AttrName) Then
        If Row1.Attributes(AttrName).Value <> Row0.Attributes(AttrName).Value Then
          Row1.Attributes(AttrName).Value = Row0.Attributes(AttrName).Value
        End If
      End If
    Next
  End If
End Sub


  'Делаем все переданные контролы из строки атрибутов только для чтения для всех кроме указанных ролей. Универсальная
function AttrControlsAccessOff (Form, Obj, AttrStr, RoleStr)
 ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  Set Roles = Obj.RolesForUser(CU)
  
  Rol = Split(RoleStr,",")
    For j = 0 to Ubound(Rol)
    if Rol(j) <> "" then 
    RoleName = Rol(j)
    If Roles.Has(RoleName) Then Exit function
    End If
    next
    Atr = Split(AttrStr,",")
    For i = 0 to Ubound(Atr)
    if Atr(i) <> "" then 
    AttrName = Atr(i)
    If Form.controls.Has(AttrName) = true Then
'    Form.Controls(AttrName).Enabled = felse
    Form.Controls(AttrName).ReadOnly = True
'     Msgbox  AttrName,vbExclamation
       End if
     End if
    next
End function 
 
' Функция скрытия форм по статусам.  Универсальная
' Если не находит текущий статус в строке StatusStr - скрывает все формы в строке FormList

function FormAccessOffStatInStr (FormList, Obj, Dialog, StatusStr)
Stat = Split(StatusStr,",")
    For i = 0 to Ubound(Stat)
    if Stat(i) <> "" then 
    StatusName = Stat(i)
     If StrComp(Obj.Status.SysName,Stat(i),vbTextCompare) = 0 Then exit function
    End If
    next
 Frm = Split(FormList,",")
    For j = 0 to Ubound(Frm)
    if Frm(j) <> "" then 
    FrmName = Frm(j)
    If Dialog.InputForms.Has(FrmName) Then
    Dialog.InputForms.Remove(FrmName)
    End If
    End If
    next  
End function 

' Функция скрытия форм по статусам.  Универсальная
' Если  находит текущий статус в строке StatusStr - скрывает все формы в строке FormList

function FormAccessOffStatOutStr (FormList, Obj, Dialog, StatusStr)
Stat = Split(StatusStr,",")
Frm = Split(FormList,",")

    For i = 0 to Ubound(Stat)
    if Stat(i) <> "" then 
    StatusName = Stat(i)
     If StrComp(Obj.Status.SysName,Stat(i),vbTextCompare) = 0 Then 
      For j = 0 to Ubound(Frm)
       if Frm(j) <> "" then 
       FrmName = Frm(j)
        If Dialog.InputForms.Has(FrmName) Then
        Dialog.InputForms.Remove(FrmName)
        End If
       End If
      next  
     end If
     End If
     next
    
End function 

' Функция скрытия форм по группам.  Универсальная
' Если не находит среди групп пользователя группу в строке GropeStr - скрывает все формы в строке FormList

function FormAccessOffGropeInStr (FormList, Obj, Dialog, GropeStr, User)
If IsEmpty(FormList) = True or IsEmpty(Obj) = True or IsEmpty(Dialog) = True or IsEmpty(GropeStr) = True or IsEmpty(User) = True Then exit function
Grp = Split(GropeStr,",")
Frm = Split(FormList,",")
    For i = 0 to Ubound(Grp)
    if Grp(i) <> "" then 
    GrpName = Grp(i)
     If User.Groups.Has(GrpName) = True Then exit function
    End If
    next
    For j = 0 to Ubound(Frm)
    if Frm(j) <> "" then 
    FrmName = Frm(j)
    If Dialog.InputForms.Has(FrmName) Then
    Dialog.InputForms.Remove(FrmName)
    End If
    End If
    next    
End function


' Функция скрытия форм по группам и статусам.  Универсальная. Для всех, кроме группы, в указанных статусах скрывает указанные формы
' Если не находит среди групп пользователя группу в строке GropeStr
' и не находит текущий статус в строке StatusStr - скрывает все формы в строке FormList
function FormAccessOffGropeStatStr (FormList, Obj, Dialog, GropeStr,StatusStr, User)
If IsEmpty(FormList) = True or IsEmpty(Obj) = True or IsEmpty(Dialog) = True or IsEmpty(StatusStr) = True or IsEmpty(User) = True Then exit function

Grp = Split(GropeStr,",")
Stat = Split(StatusStr,",")
Frm = Split(FormList,",")

If IsEmpty(GropeStr) = false then
    For i = 0 to Ubound(Grp)
    if Grp(i) <> "" then 
    GrpName = Grp(i)
     If User.Groups.Has(GrpName) = True Then exit function
    End If
    next
End If    

    For k = 0 to Ubound(Stat)
    if Stat(k) <> "" then 
    StatusName = Stat(k)
     If StrComp(Obj.Status.SysName,StatusName,vbTextCompare) = 0 Then
     For j = 0 to Ubound(Frm)
      if Frm(j) <> "" then 
      FrmName = Frm(j)
       If Dialog.InputForms.Has(FrmName) Then
       Dialog.InputForms.Remove(FrmName)
       End If
      End If
     next
     End If 
    End If
    next   
    
End function




'======================================================================================
'Функция поиска элемента оргструктуры по пользователю 
'Возвращает ссылку на элемент оргструктуры по пользователю
'======================================================================================
Function OrgGet(OrgName)
ThisScript.SysAdminModeOn
  Set OrgGet = Nothing
  If OrgName is Nothing Then Exit Function
  For Each StrObj in ThisApplication.ObjectDefs("OBJECT_STRU_OBJ").Objects
    If StrObj.Attributes.Has("ATTR_NAME") and StrObj.Attributes.Has("ATTR_KD_CHIEF") Then
     If  StrObj.Attributes("ATTR_KD_CHIEF") = OrgName Then
'      If StrComp(StrObj.Attributes("ATTR_KD_CHIEF").Value,OrgName,vbTextCompare) = 0 Then
        If StrObj.Attributes("ATTR_KD_CHIEF").Empty = False Then
          If not StrObj.Attributes("ATTR_KD_CHIEF").User is Nothing Then
            Set OrgGet = StrObj
            Exit For
          End If
        End If
      End If
    End If
  Next
  ThisScript.SysAdminModeOff
End Function

'======================================================================================
'Функция добавления роли пользователю из строки с ID ролей
'Возвращает ссылку на элемент оргструктуры по пользователю
'======================================================================================
 'Создание роли
 Function RoleStrTakeUser(Obj, User, RoleStr)

 If IsEmpty(Obj) = True or IsEmpty(User) = True or IsEmpty(RoleStr) = True Then exit function
  Set Roles = Obj.RolesForUser(User)
  RlName = Split(RoleStr,",")
    For i = 0 to Ubound(RlName)
    if RlName(i) <> "" then 
    RoleName = RlName(i)
     If Roles.Has(RoleName) = False Then
'     msgbox RoleName & " " & user.description
     Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,User)
     End If
     End If
    next
  End Function  
'======================================================================================
'Функция удаления роли пользователя
'Возвращает ссылку на элемент оргструктуры по пользователю
'======================================================================================    
    
Sub RoleUserDel(Obj,User,RoleStr)
If IsEmpty(Obj) = True or IsEmpty(User) = True or IsEmpty(RoleStr) = True Then exit Sub
ThisScript.SysAdminModeOn
'Исключаем неприкасаемых
If User is Nothing Then exit Sub
 AttrNamestr = "ATTR_TENDER_DOC_RESP,ATTR_TENDER_ACC_CHIF,ATTR_TENDER_GROUP_CHIF,ATTR_TENDER_PEO_CHIF,"
 
 AttrNm = Split(AttrNamestr,",")
  For i = 0 to Ubound(AttrNm)
   if AttrNm(i) <> "" then 
   AttrName = AttrNm(i)
   If Obj.Attributes.Has(AttrName) Then
   If Obj.Attributes(AttrName).Empty = False Then
     If not Obj.Attributes(AttrName).User is Nothing Then
       Set ExclUser = Obj.Attributes(AttrName).User
       If ExclUser.SysName = User.SysName Then Exit Sub
      End If    
    End If
  End If   
  End If
  next
 Set Roles = Obj.RolesForUser(User)
  RlName = Split(RoleStr,",")
    For i = 0 to Ubound(RlName)
    if RlName(i) <> "" then 
    RoleName = RlName(i)
  If Roles.Has(RoleName) Then
    ThisApplication.ExecuteScript "CMD_DLL_ROLES","RemoveRoleForUser",Obj,User,RoleName 
    Set uToUser = User
    If uToUser Is Nothing Then Exit Sub
    Set uFromUser = ThisApplication.CurrentUser
         resol = "NODE_COR_DEL_MAIN"
         txt = "Вы отстранены от разработки """ & Obj.Description & """ пользователем " & uFromUser.Description
         planDate = Date
       ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
   '    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 6006, User, Obj0, Nothing, Obj0.Description
  End If
  End If
  next
  ThisScript.SysAdminModeOff
End Sub
'======================================================================================
'Функция проверки, и покраски пустых атрибутов форм из передаваемой строки
'Возвращает True если есть пустые
'====================================================================================== 
Function FormAttrCheckAlarm(Form, Obj, AttrStr)
If IsEmpty(Form) = True or IsEmpty(Obj) = True or IsEmpty(AttrStr) = True Then exit Function
' Красим серым контролы проверяемых атрибутов
Call MainControlsBackColorOff(Form, Obj, AttrStr)
   ' Получаем строку не заполненных атрибутов и сообщение с их списком
 str = AttrCheckAttr(Form, Obj, AttrStr, False)
  If str <> "" then
  ' Красим желтым, контролы не заполненных атрибутов
  Call MainControlsBackColorAlarm(Form, Obj, Str)
  FormAttrCheckAlarm = True
 End If 
End Function  

'======================================================================================
'Функция запроса даты.
'Возвращает дату если дата введена по нажатию Ок и "" если Отмена
'====================================================================================== 
Function FormDataInter(Obj, Txt, Attr, Dat)
If IsEmpty(Txt) = True or IsEmpty(Obj) = True or IsEmpty(Attr) = True Then exit Function
  PlanDate = ""
  FormName = "FORM_DATE_SELECT"
  Set Form = ThisApplication.InputForms(FormName)
  Set Dict = ThisApplication.Dictionary(FormName)
  Dict.Item("description") = Txt

Dict.Item("Cel") = "No"

If not IsEmpty(Dat) = True Then
 If not Dat = "" Then 
 Dict.Item("date") = Dat
 End If
End If 

     If Obj.Attributes.Has(Attr) Then
     If Obj.Attributes(Attr).Empty = False Then
     Dict.Item("date") = Obj.Attributes(Attr).value
     End If   
    End If
   
    If Form.Show Then
 Form.Attributes("ATTR_DATA") = Dict.Item("date")
      If Dict.Exists("FORM_KEY_PRESSED") Then
        If Dict.Exists("FORM_KEY_PRESSED") = True and Dict.Exists("date") Then 
        Cel = Dict.Item("Cel")
          PlanDate = Dict.Item("date")
          FormDataInter = PlanDate
          Dict.RemoveAll
       End If   
      End If
    End If
  If Cel <> "Ок" Then FormDataInter = ""
  
End Function  


  ' Переводим в текст стоимости договоров подрядных организаций 
  'Переводит строку табличного атрибута в строку через дефис
'--------------------------------------------------------------------  

  Function TablStrToStr(Obj, Tbl, Atrstr, AttrTo, Excl)
 '  TablToStr = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","TablStrToStr",ThisObject, Tbl, Atrstr, AttrTo) 
  ' Tbl = "ATTR_TENDER_SUBCONTRACT_PRICE_TABLE" ' Таблица
  ' Atrstr = "ATTR_TENDER_ADDITIONAL_CONTRACTOR,ATTR_TENDER_CONTRACTOR_DIAL_PRICE,%" ' Графы
  ' AttrTo = ATTR_TENDER_SUBCONTRACT_PRICE_LIST ' Текстовый атрибут
  ' Excl = "ATTR_TENDER_MEMBER" ' Исключаем Организацию 
  ' ATTR_TENDER_MEMBER Участник закупки (вроде как он в общем списке должен быть)
  
If IsEmpty(Obj) = True or IsEmpty(Tbl) = True or IsEmpty(Atrstr) = True or IsEmpty(AttrTo) = True Then Exit Function

'Обрабатываем исключение
ExcSys = ""
If IsEmpty(Excl) = False Then
 If Obj.Attributes.Has(Excl) Then
  If Obj.Attributes(Excl).Empty = False Then
   Set ExcObj = Obj.Attributes(Excl).object
   If not ExcObj is Nothing Then ExcSys = ExcObj.handle
   msgbox ExcSys
  End If
 End If
End If 

'Получаем массив атрибутов таблицы
 ArrAtr = Split(Atrstr,",")
    
  ' Объекты в массив  
  Set Table =  Obj.Attributes(Tbl)
  If Not Table Is Nothing Then
  set rows = Table.Rows
  End If
  If rows Is Nothing Then 
'      msgbox "Нет пользователей в списке"
      Exit Function
  End If     
If Not rows Is Nothing Then
Str = ""
'Thisobject.GUID
for each row in rows
 Line = ""
 For i = 0 to Ubound(ArrAtr)
  Atr = ArrAtr(i)
 If row.Attributes.Has(Atr) Then
  If row.Attributes(Atr).Empty = False Then
   If row.Attributes(Atr).AttributeDef.Type = 7 Then 'Ссылка на объект
      Set Objct = row.Attributes(Atr).object
      If Objct.handle <> ExcSys Then Line = Line & " - " & Objct.description
     else 
     Line = Line & " - " & row.Attributes(Atr).Value
    End If
   End If
  End If
' msgbox Line
   Next
  Str = Str & chr(10) & Line 
Next
End If
If Obj.Attributes.Has(AttrTo) Then
Obj.Attributes(AttrTo) = Str
End If 
TablStrToStr = Str
End Function  


  ' Считаем  стоимости договоров подрядных организаций 
  '
'--------------------------------------------------------------------  

  Function TablStrValCalc(Obj, Tbl, Atrstr, AttrTo, Excl)
 '  TablToStr = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","TablStrToStr",ThisObject, Tbl, Atrstr, AttrTo) 
  ' Tbl = "ATTR_TENDER_SUBCONTRACT_PRICE_TABLE" ' Таблица
  ' Atrstr = "ATTR_TENDER_CONTRACTOR_DIAL_PRICE" ' Графы
  ' AttrTo = "ATTR_TENDER_SUBCONTRACT_SUM" ' Текстовый атрибут
  ' Excl = "ATTR_TENDER_MEMBER" ' Исключаем атрибут 

  
If IsEmpty(Obj) = True or IsEmpty(Tbl) = True or IsEmpty(Atrstr) = True or IsEmpty(AttrTo) = True Then Exit Function

'Обрабатываем исключение
ExcSys = ""
If IsEmpty(Excl) = False Then
 If Obj.Attributes.Has(Excl) Then
  If Obj.Attributes(Excl).Empty = False Then
   Set ExcObj = Obj.Attributes(Excl).Value
   If not ExcObj is Nothing Then ExcSys = ExcObj.handle
'   msgbox ExcSys
  End If
 End If
End If 

'Получаем массив атрибутов таблицы
 ArrAtr = Split(Atrstr,",")
    
  ' Объекты в массив  
  Set Table =  Obj.Attributes(Tbl)
  If Not Table Is Nothing Then
  set rows = Table.Rows
  End If
  If rows Is Nothing Then 
'      msgbox "Нет пользователей в списке"
      Exit Function
  End If  
Val = 0     
If Not rows Is Nothing Then
for each row in rows
 For i = 0 to Ubound(ArrAtr)
  Atr = ArrAtr(i)
 If row.Attributes.Has(Atr) Then
  If row.Attributes(Atr).Empty = False Then
  tipe = row.Attributes(Atr).AttributeDef.Type
  If tipe <> 6 and tipe <> 7 and tipe <> 8 and tipe <> 9 and tipe <> 11 Then 
 If tipe = 2 Then
 Val = Val + row.Attributes(Atr)
 else
' Val = Val + CDbl(row.Attributes(Atr))
 Val = Val + row.Attributes(Atr).value
 Val = CDbl(Val)
      End If
'      msgbox Val
    End If
   End If
  End If

' msgbox Line
   Next
Next
End If
If Obj.Attributes.Has(AttrTo) Then
'msgbox IsNumeric(Val)
'msgbox Val

Call ThisApplication.ExecuteScript("CMD_DLL","SETATTR_F",Obj,AttrTo,Val,True)

End If 
Obj.Update
TablStrValCalc = Val
End Function  


Sub Test
'Это вызов функции, которая собирает все файлы с поручений в объект
'------------------------------------------------------------------
call thisApplication.ExecuteScript("FORM_KD_EXCUTION","AddFiles","QUERY_DOC_ORDER_FILES", docObj)
End Sub


'====================================================================================== 
'Функция проверки корректностиввода времени   
'Возвращает True если ок    
'! Добавить проверку дат. Если  дата вскрытия больше, то время можно не проверять
' Так же добавить проверку времени при изменении дат. При выборе одинаковых дат, проверять время. 
' Если конфликт - то обнулять время

'====================================================================================== 
Function CheckTime(Form, Obj, Ch1, Mi1, Ch2, Mi2)
If IsEmpty(Form) = True or IsEmpty(Obj) = True or IsEmpty(Ch1) = True or IsEmpty(Ch2) = True or IsEmpty(Mi1) = True or IsEmpty(Mi2) = True  Then exit Function

If IsEmpty(Ch1) = True Then Ch1 = 00
If IsEmpty(Ch2) = True Then Ch2 = 00
If IsEmpty(Mi1) = True Then Mi1 = 00
If IsEmpty(Mi2) = True Then Mi2 = 00

If Ch2 = "" then 
CheckTime = True
Exit Function
End If

'msgbox Ch1  &Mi1
'msgbox Ch2 &Mi2
If Ch1 = "" then Ch1 = 00
If Mi1 = "" then Mi1 = 00
If Ch2 = "" then Ch2 = 00
If Mi2 = "" then Mi2 = 00

If CLng(Ch1) > CLng(Ch2) Then CheckTime = False
If Ch1 < Ch2 Then CheckTime = True
If Ch1 = Ch2 Then 
 If CLng(Mi1) =<  CLng(Mi2) Then CheckTime = True
 If CLng(Mi1) > CLng(Mi2) Then CheckTime = False
End If 
End Function  


'Процедура - Вычислить планируемую цену закупки
'-----------------------------------------------------------------------
Function PriceTenderCalc(Form, Obj, No)
  ThisScript.SysAdminModeOn
  AttrName0 = "ATTR_TENDER_LOT_NDS_PRICE" 'Цена лота с НДС  "ATTR_TENDER_NDS_PRICE" 'Цена с НДС (лота)
  AttrName3 = "ATTR_TENDER_LOT_PRICE" 'Цена лота без НДС
  AttrName4 = "ATTR_LOT_NDS_VALUE" ' Ставка НДС лота
  AttrName1 = "ATTR_TENDER_PLAN_NDS_PRICE" 'Планируемая цена закупки с НДС
  AttrName2 = "ATTR_TENDER_PLAN_PRICE" 'Планируемая цена закупки без НДС
  AttrName5 = "ATTR_NDS_VALUE" 'Ставка НДС закупки

If IsEmpty(No) = True Then No = 1
 If No = 1 Then 
 Attr = AttrName1
 elseif  No = 2 Then 
 Attr = AttrName2
 elseif  No = 3 Then 
 Attr = AttrName5
 End If 
 
  Sum = 0
  Check = False
  Check2 = False
'  bet = ThisObject.Attributes(AttrName5) 
  bet = ""

'  If IsEmpty(Form) = Felse Then Form.Controls("T_ATTR_TENDER_PLAN_PRICE").ActiveX.ForeColor = RGB(0,0,0)
'  If IsEmpty(Form) = Felse Then Form.Controls("T_ATTR_TENDER_PLAN_NDS_PRICE").ActiveX.ForeColor = RGB(0,0,0)
   For Each Child in Obj.Objects
    If Child.ObjectDefName = "OBJECT_PURCHASE_LOT" Then
      If Child.Attributes.Has(AttrName0) Then
        If Child.Attributes(AttrName0).Empty = False Then
          Sum = Sum + Child.Attributes(AttrName0).Value
          Else 
          Check2 = True
'         If IsEmpty(Form) = Felse Then Form.Controls("T_ATTR_TENDER_PLAN_PRICE").ActiveX.ForeColor = RGB(255,0,0)
        End If  
          If Child.Attributes(AttrName3).Empty = False and Check2 = false Then
          Sum1 = Sum1 + Child.Attributes(AttrName3).Value
          Else 
          Check2 = True
           If Child.Attributes(AttrName3).Empty = true then
'           If IsEmpty(Form) = Felse Then Form.Controls("T_ATTR_TENDER_PLAN_NDS_PRICE").ActiveX.ForeColor = RGB(255,0,0)
           End If 
        End If  
          If Child.Attributes(AttrName4).Empty = False and Check2 = false Then 
          if bet = Empty then  bet = Child.Attributes(AttrName4)
           If bet = Child.Attributes(AttrName4) then
           Check1 = false
           else
           Check1 = True
           bet = Child.Attributes(AttrName4)
           End If
          End If
          If Check = False Then Check = True
          End If
       End If
  Next
'   msgbox No
'  msgbox Sum &Sum1
  If Check <> False Then
    If No = 1 Then PriceTenderCalc = Sum1 'Obj.Attributes(AttrName1).Value = Sum
'     msgbox PriceTenderCalc
    If No = 2 Then PriceTenderCalc = Sum 'Obj.Attributes(AttrName2).Value = Sum1
    If Check1 = False and No = 3 Then PriceTenderCalc = bet
    If Check1 = True and No = 3 Then PriceTenderCalc = "0"
     ' Obj.Attributes(AttrName5) = bet
   
'      Obj.Attributes(AttrName5).Classifier = ThisApplication.Classifiers("NODE_F7E00034_5715_45AB_8952_0860746AD1C6").Classifiers.Find("Составной")
 
  End If
' msgbox PriceTenderCalc
 End Function 


'Загрузка файлов

Sub PurchaseDocsFilesUpload(Obj,Count,Path)

   
    
      ThisScript.SysAdminModeOn
  'Список файлов
  Set Query = ThisApplication.Queries("QUERY_TENDER_IN_UPLOAD_FILES")
  Query.Parameter("OBJ") = Obj
 '  Query.Parameter("STATUS") = ThisApplication.Statuses("STATUS_DOC_IS_END")
  Query.Parameter("LVL") = True 'ThisApplication.Statuses("ATTR_TENDER_INF_CARD_DOC_FLAG")

  Set Files = Query.Files
  Check = True
  'Проверка на наличие файлов
  If Files.Count = 0 Then
    Msgbox "Объект не содержит файлов для выгрузки." & chr(10) & "Действие отменено.",vbExclamation
    Check = false
  End If
 If  Check = True Then 
  'Выбор файлов
  Set Dlg = ThisApplication.Dialogs.SelectDlg
  Dlg.UseCheckBoxes = True
  Dlg.SelectFrom = Files
  Dlg.Caption = "Выбор файлов для выгрузки"
  If Dlg.Show = False Then Exit Sub
  Set Files = Dlg.Objects
  If Files.Count = 0 Then Exit Sub
  
  'Запрос папки для выгрузки
  Path = GetFolder
  
  'Выгрузка файлов в папку
  If Path <> "" Then
    Set FSO = CreateObject("Scripting.FileSystemObject")
    'Создание папки
    FolderName = ""
    If Obj.Attributes.Has("ATTR_TENDER_CONCURENT_NUM_EIS") Then
      FolderName = Obj.Attributes("ATTR_TENDER_UNIQUE_NUM").Value
      Str = Chr(34) & " * : < > ? / \ |"
      Arr = Split(Str, " ")
      For i = 0 to Ubound(Arr)
        If InStr(FolderName,Arr(i)) <> 0 Then
          FolderName = ""
'          Msgbox "Номер конкурентной закупки содержит недопустимые символы для создания папки (" &Str& ")",vbExclamation
          Exit For
        End If
      Next
    End If
    If FolderName <> "" Then
      Path = Path & "\" & FolderName
      If Len(Path) < 256 and FSO.FolderExists(Path) = False Then
        FSO.CreateFolder Path
      End If
    End If
    
    Count = 0
    For Each File in Files
      fName = Path & "\" & File.FileName
      Ext = Right(fName,Len(fName)-InStrRev(fName,"."))
      shortName = Left(fName, InStrRev(fName, ".")-1)
      i = 1
      Do While FSO.FileExists(fName)
        fName = shortName & " (" & i & ")." & Ext
        i = i + 1
      Loop
      on Error Resume Next
      File.CheckOut fName
      If Err.Number = 0 Then Count = Count + 1
      On Error GoTo 0
    Next  
    Msgbox "В папку """ & Path & """ выгружено " & Count & " файлов."
  Else
    Exit Sub
  End If
  End If
End Sub
'==============================================================================
' Функция предоставляет диалог выбора папки
'------------------------------------------------------------------------------
' GetFolder:String - Полный путь к выбранной папке
'==============================================================================
Private Function GetFolder()
  GetFolder = ""
  On Error Resume Next
  Set objShellApp = CreateObject("Shell.Application")
  Set objFolder = objShellApp.BrowseForFolder(0, "Выберите папку для выгрузки файлов", 0)
  If Err.Number <> 0 Then
    MsgBox "Папка не выбрана!", vbInformation
  Else
    GetFolder = objFolder.Self.Path
  End If
End Function
'-----------------------------------------------------------------------------
'ФУНКЦИЯ УДАЛЕНИЯ ЛИШНЕЙ СТРОКИ ИЗ ОДНОСТРОЧНОЙ ТАБЛИЦЫ
'-----------------------------------------------------------------------------
Function CheckOne(obj,atr)
If IsEmpty(atr) = True or IsEmpty(Obj) = True Then Exit Function
If Obj.Attributes.Has(atr) Then
Set TableRows = Obj.Attributes(atr).Rows
n = TableRows.Count 
 If n > 1 Then
While n <> 1
' for i = 1 to n - 1
 TableRows(n-1).Erase
n = n - 1
'Alert n
Wend
' next
 End If  
End If  
End Function
