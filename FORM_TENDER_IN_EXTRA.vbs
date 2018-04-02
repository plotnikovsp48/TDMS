


Sub Form_BeforeShow(Form, Obj)
 Call SetChBox(Obj)
End Sub

'Кнопка - Черновик
'-----------------------------------------------------------------------
Sub BUTTON_DRAFT_OnClick()

 Answer = MsgBox("Перевести закупку в статус ""Черновик""?", vbQuestion + vbYesNo,"")
  if Answer <> vbYes then exit sub
  ThisApplication.Utility.WaitCursor = True
'  Маршрут
  StatusName = "STATUS_TENDER_DRAFT"
   ThisObject.Status = ThisApplication.Statuses("STATUS_FULLACCESS")
   ThisObject.Status = ThisApplication.Statuses(StatusName)
   Call GoRoles(ThisObject)
'  End If
  ThisObject.Dictionary.Item("FormActive") = "FORM_TENDER_IN_EXTRA"
  ThisObject.SaveChanges ' Сохраняем 
  ThisApplication.Utility.WaitCursor = False
  ThisScript.SysAdminModeOff
    Msgbox "Закупка переведена в статус ""Черновик""",vbInformation
End Sub


'Кнопка - Согласовано
'-----------------------------------------------------------------------
Sub BUTTON_AGREED_OnClick()
' ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnAgreedOnclic",ThisForm, ThisObject
Call BtnAgreedOnclic(ThisForm, ThisObject)
End Sub

'Кнопка - Запланировать
'-----------------------------------------------------------------------
Sub BUTTON_PLAN_OnClick()
'If ThisApplication.ExecuteScript("CMD_TENDER_IN_GO_PLAN", "Main", ThisForm, ThisObject) = False Then
Call Goplan(ThisForm, ThisObject)
  ThisObject.Dictionary.Item("FormActive") = "FORM_TENDER_IN_EXTRA"
'    Thisform.close False
'  End if
End Sub

'Кнопка - В разработку документации
'-----------------------------------------------------------------------
Sub BUTTON_TO_DEVELOP_OnClick()
'  ThisApplication.ExecuteScript "CMD_TENDER_IN_GO_WORK", "Main", ThisObject
Call GoWork(ThisObject)
  ThisObject.Dictionary.Item("FormActive") = "FORM_TENDER_IN_EXTRA"
'  ThisObject.SaveChanges
End Sub

'Кнопка - Подготовка к публикации
'------------------------------------------------------------------------
Sub BUTTON_APPROVE_OnClick()
'   Res = ThisApplication.ExecuteScript("CMD_TENDER_IN_APPROV","Main",ThisForm, ThisObject)
Call GoApprov(ThisForm, ThisObject)
   ThisObject.Dictionary.Item("FormActive") = "FORM_TENDER_IN_EXTRA"
End Sub

'Кнопка - Опубликовать
'------------------------------------------------------------------------
Sub BUTTON_PUBLIC_OnClick()
'  ThisApplication.ExecuteScript "CMD_TENDER_IN_UPLOAD", "Main", ThisObject 'Obj.Attributes("ATTR_TENDER_BARGAIN_FLAG") = True
Call GoPablick(ThisObject)
ThisObject.Dictionary.Item("FormActive") = "FORM_TENDER_IN_EXTRA"
'  Obj.SaveChanges ' Сохраняем
End Sub

'Кнопка - На рассмотрение
'------------------------------------------------------------------------
Sub BUTTON_GO_EXPERT_OnClick()
'  ThisApplication.ExecuteScript "CMD_TENDER_IN_GO_EXPERT", "Main", ThisObject
Call GoExpert(ThisObject)
  ThisObject.Dictionary.Item("FormActive") = "FORM_TENDER_IN_EXTRA"
End Sub

'Кнопка - Завершить
'------------------------------------------------------------------------
Sub BUTTON_FINISH_OnClick()
'  ThisApplication.ExecuteScript "CMD_TENDER_IN_GO_END", "Main", ThisObject, Thisform
  ThisObject.Dictionary.Item("FormActive") = "FORM_TENDER_IN_EXTRA"
 Call GoClose(ThisForm, ThisObject)
End Sub
'Кнопка - Аннулировано
'------------------------------------------------------------------------
Sub BUTTON_NULL_OnClick()
 Answer = MsgBox("Перевести закупку в статус ""Аннулирована""?", vbQuestion + vbYesNo,"")
  if Answer <> vbYes then exit sub
  ThisApplication.Utility.WaitCursor = True
'  Маршрут
   StatusName = "STATUS_S_INVALIDATED"
   ThisObject.Status = ThisApplication.Statuses("STATUS_FULLACCESS")
   ThisObject.Status = ThisApplication.Statuses(StatusName)
   Call GoRoles(ThisObject)
'  End If
  ThisObject.Dictionary.Item("FormActive") = "FORM_TENDER_IN_EXTRA"
  ThisObject.SaveChanges ' Сохраняем 
  ThisApplication.Utility.WaitCursor = False
  ThisScript.SysAdminModeOff
    Msgbox "Закупка переведена в статус ""Аннулирована""",vbInformation
End Sub


'Кнопка - Согласовано. Функция
'-----------------------------------------------------------------------
Sub BtnAgreedOnclic(Form, Obj) 'BUTTON_AGREED_OnClick()
'If Thisform.Controls("ACTIVEX_ATTR_CHECK_FLAG").activex = True Then
If Thisform.Controls("ACTIVEX_ATTR_CHECK_FLAG").activex.value = True Then
'If Obj.StatusName = "STATUS_TENDER_DRAFT" Then
'call MainControlsBackColorOff (Form, Obj, Str)
   ' Красим желтым, или серым контролы проверяемых атрибутов
 str = ThisApplication.ExecuteScript("OBJECT_TENDER_INSIDE","TenderInsideCheck",Obj)
 If str = False Then Exit Sub
  If str <> true then
'  Call MainControlsBackColorAlarm(Form,Obj,Str)
  Exit Sub
  End if 
 End if 

'Запрос подтверждения
   Key = Msgbox("Перевести закупку в статус ""Согласовано""?", vbQuestion+vbYesNo)
  If Key = vbNo Then
    Exit Sub
  End If
  'Обнуляем статус в ЕИС, что бы кнопка Запланировать была доступна
   Obj.Attributes("ATTR_TENDER_STATUS_EIS").Empty = True
  'Маршрут
  StatusName = "STATUS_TENDER_IN_AGREED"
'  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
'  If RetVal = -1 Then
'  Obj.Status = ThisApplication.Statuses("STATUS_KD_AGREEMENT")
'  If Thisform.Controls("ACTIVEX_ORDER_FLAG").activex <> True Then Obj.Status = ThisApplication.Statuses("STATUS_FULLACCESS")
  If Thisform.Controls("ACTIVEX_ORDER_FLAG").activex.value <> True Then Obj.Status = ThisApplication.Statuses("STATUS_TENDER_END")
  Obj.Status = ThisApplication.Statuses(StatusName)
  Call GoRoles(ThisObject)
'  End If
  Main = False
  Obj.SaveChanges ' Сохраняем
   Msgbox  "Закупка переведена в статус ""Согласовано"" """,vbInformation
  ThisScript.SysAdminModeOff

End Sub


'---------------------------------------------
Function Goplan(Form, Obj)
'---------------------------------------------
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  Main = True
'  If Thisform.Controls("ACTIVEX_ATTR_CHECK_FLAG").activex = True Then
If Thisform.Controls("ACTIVEX_ATTR_CHECK_FLAG").activex.value = True Then
' Проверка перед запланированием
CheckBeforeClose = False
  str = CheckRequedFieldsBeforeClose(Form, Obj)
  If str <> "" Then
    Msgbox "Не заполнены обязательные атрибуты: " & str,vbExclamation
    
    Exit Function
  End If
 
 If Obj.Attributes("ATTR_TENDER_ASEZ_STATUS").Classifier.Description <> "Утвержден" Then
   Msgbox "Поле Статус закупки в АСЭЗ должно быть в значении Утвержден",vbInformation
   Exit Function
 End If
End If
  'Запрос подтверждения
  AttrName0 = "ATTR_TENDER_RESP"
  Set u = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName0)
  Key = Msgbox("Перевести закупку в статус ""Запланировано""?", vbQuestion+vbYesNo)
'  Key = Msgbox("Пользователю " & u.Description & " будет выдано поручение. Перевести закупку в запланированные?", vbQuestion+vbYesNo)
  If Key = vbNo Then
    Exit Function
  End If
  
  'Маршрут
  StatusName = "STATUS_TENDER_IN_PLAN"
'  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
'  If RetVal = -1 Then
    If Thisform.Controls("ACTIVEX_ORDER_FLAG").activex.value <> True Then Obj.Status = ThisApplication.Statuses("STATUS_FULLACCESS")
    Obj.Status = ThisApplication.Statuses(StatusName)
    Call GoRoles(ThisObject)
'  End If
  Main = False
  Obj.SaveChanges ' Сохраняем
   If Thisform.Controls("ACTIVEX_ORDER_FLAG").activex.value = True Then
  'Создание поручения
  AttrName0 = "ATTR_TENDER_RESP"
  AttrName1 = "ATTR_TENDER_PLAN_ZD_PRESENT"
  Set u = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName0)
  resol = "NODE_CORR_REZOL_POD"
  ObjType = "OBJECT_KD_ORDER_REP"
  txt = "Прошу предоставить материалы в группу для размещения в установленные сроки"
  PlanDate = ""
  If Obj.Attributes.Has(AttrName1) Then
    If Obj.Attributes(AttrName1).Empty = False Then
      PlanDate = Obj.Attributes(AttrName1).Value
    End If
  End If
  If PlanDate = "" Then PlanDate = Date + 1
  
  If not u is Nothing Then
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,u,CU,resol,txt,PlanDate
    Msgbox "Закупка переведена в статус ""Запланировано"". Пользователю """ & u.Description & """ выдано поручение",vbInformation
  End If
  Else
    Msgbox  "Закупка переведена в статус ""Запланировано"" """,vbInformation
  
 End If  
  ThisScript.SysAdminModeOff
End Function

' Функция проверки заполнения обязательных полей
Function CheckRequedFieldsBeforeClose(Form, Obj)
  CheckRequedFieldsBeforeClose = ""
  str = ""
  '1. Уникальный номер закупки 
  If Obj.Attributes("ATTR_TENDER_UNIQUE_NUM").Empty = True Then
    CheckRequedFieldsBeforeClose = "Уникальный номер закупки"
    str = str & chr(10) & "- " & CheckRequedFieldsBeforeClose
    Atr = "ATTR_TENDER_UNIQUE_NUM"
    str1 = str1 & "," & Atr
    'Exit Function
  End If
  '2. Номер ППЗ 
  If Obj.Attributes("ATTR_TENDER_PPZ_NUM").Empty = True Then
    CheckRequedFieldsBeforeClose = "Номер ППЗ"
    str = str & chr(10) & "- " & CheckRequedFieldsBeforeClose
    Atr = "ATTR_TENDER_PPZ_NUM"
    str1 = str1 & "," & Atr
    'Exit Function
  End If
    '3. Фактическая дата утверждения в АСЭЗ  
  If Obj.Attributes("ATTR_TENDER_FACT_ASEZ_PRUVE_DATA").Empty = True Then
    CheckRequedFieldsBeforeClose = "Фактическая дата утверждения в АСЭЗ"
    str = str & chr(10) & "- " & CheckRequedFieldsBeforeClose
    Atr = "ATTR_TENDER_FACT_ASEZ_PRUVE_DATA"
    str1 = str1 & "," & Atr
    'Exit Function
  End If
     '4.  Статус закупки в АСЭЗ
  If Obj.Attributes("ATTR_TENDER_ASEZ_STATUS").Empty = True Then
    CheckRequedFieldsBeforeClose = "Статус закупки в АСЭЗ"
    str = str & chr(10) & "- " & CheckRequedFieldsBeforeClose
    Atr = "ATTR_TENDER_ASEZ_STATUS"
    str1 = str1 & "," & Atr
    'Exit Function
  End If
  CheckRequedFieldsBeforeClose = str
  If IsEmpty(Form) = False and str1 <> "" Then
     ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","MainControlsBackColorAlarm",Form, Obj, Str1
  End If
End Function


Sub GoWork(Obj)
  ThisScript.SysAdminModeOn
  
  'Запрос подтверждения
  Key = Msgbox("Перевести закупку в статус ""Разработка документации""?", vbQuestion+vbYesNo)
  If Key = vbNo Then
    Exit Sub
  End If
  
  'Маршрут
  StatusName = "STATUS_TENDER_IN_WORK"
'  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
'  If RetVal = -1 Then
    If Thisform.Controls("ACTIVEX_ORDER_FLAG").activex.value <> True Then Obj.Status = ThisApplication.Statuses("STATUS_FULLACCESS")
    Obj.Status = ThisApplication.Statuses(StatusName)
    Call GoRoles(ThisObject)
'  End If
  
  'Создание роли
  Set CU = ThisApplication.CurrentUser
  RoleName = "ROLE_PURCHASE_RESPONSIBLE"
  If Obj.RolesForUser(CU).Has(RoleName) = False Then
    Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,CU)
  End If
  
  'Создание документа закупки
'  Set Doc = InfoDocGet(Obj)
  Set Doc = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","InfoDocGet",ThisObject)
  If not Doc is Nothing Then
    Msgbox "Закупка переведена в статус ""Разработка документации"".", vbInformation
  Else
  AttrStr = "ATTR_TENDER_FACT_MATERIAL_TAKE_OFF_DATA,ATTR_TENDER_ITEM_PRICE_MAX_VALUE," &_
      "ATTR_NDS_VALUE,ATTR_LOT_NDS_VALUE,ATTR_TENDER_START_WORK_DATA,ATTR_TENDER_INVOCE_PUBLIC_DATA," &_
      "ATTR_TENDER_ADVANCE_PLAN_PAY,ATTR_TENDER_ADDITIONAL_REQUIREMENTS,ATTR_TENDER_BID_REQUIREMENTS," &_
      "ATTR_TENDER_GUARANTEE_REQUIREMENTS,ATTR_TENDER_RF_CONF_REQUIREMENTS_DOC_LIST," &_
      "ATTR_TENDER_EXPERIENCE_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_PERSONAL_CONF_REQUIREMENTS_DOC_LIST," &_
      "ATTR_TENDER_RIG_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_ISO9001_REQUIREMENTS,ATTR_TENDER_SUM_NDS," &_
      "ATTR_TENDER_ADDITIONAL_INFORMATION,ATTR_TENDER_END_WORK_DATA,ATTR_TENDER_POSSIBLE_CLIENT"
 
    Set NewObj = Obj.Objects.Create("OBJECT_PURCHASE_DOC")
    NewObj.Status = ThisApplication.Statuses("STATUS_DOC_IN_WORK")
    NewObj.Attributes("ATTR_RESPONSIBLE").User = CU
    NewObj.Attributes("ATTR_DOCUMENT_NAME").Value = "Информационная карта"
    AttrName = "ATTR_KD_USER_DEPT"
    If CU.Attributes.Has(AttrName) Then
      If CU.Attributes(AttrName).Empty = False Then
        If not CU.Attributes(AttrName).Object is Nothing Then
          NewObj.Attributes("ATTR_T_TASK_DEPARTMENT").Object = CU.Attributes(AttrName).Object
        End If
      End If
    End If
    
    NewObj.Attributes("ATTR_PURCHASE_DOC_TYPE").Classifier = _
      ThisApplication.Classifiers.Find("Вид документа закупки").Classifiers.Find("Информационная карта")
    ThisApplication.ExecuteScript "CMD_DLL","AttrsSyncBetweenObjs", Obj, NewObj, AttrStr
    ThisApplication.ExecuteScript "OBJECT_PURCHASE_DOC","Pricesync", NewObj
    Msgbox "Закупка переведена в статус ""Разработка документации"". Информационная карта создана", vbInformation
  End If
    Obj.SaveChanges ' Сохраняем
  ThisScript.SysAdminModeOff
End Sub

'--------------------------------------------------------
Sub GoPablick(Obj)
'--------------------------------------------------------
  ThisScript.SysAdminModeOn
  'Запрос о смене статуса
    Key = Msgbox("Перевести закупку в статус ""Размещена на площадке"" (Опубликована)?",vbYesNo+vbQuestion)
    If Key = vbNo Then 
    Exit Sub
    Else
    ThisScript.SysAdminModeOn
  'Маршрут
  StatusName = "STATUS_TENDER_IN_PUBLIC"
'  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
'  If RetVal = -1 Then
    If Thisform.Controls("ACTIVEX_ORDER_FLAG").activex.value <> True Then Obj.Status = ThisApplication.Statuses("STATUS_FULLACCESS")
    Obj.Status = ThisApplication.Statuses(StatusName)
    Call GoRoles(ThisObject)
'  End If
  Obj.Attributes("ATTR_TENDER_BARGAIN_FLAG") = False
  AttrName = "ATTR_TENDER_STATUS_EIS"
   If Obj.Attributes.Has(AttrName) Then
    Obj.Attributes(AttrName) =  "В работе"
   End If
    ThisObject.Dictionary.Item("FormActive") = "FORM_TENDER_IN_EXTRA"
     Obj.SaveChanges ' Сохраняем
    Msgbox "Закупка переведена в статус ""Размещена на площадке"" (опубликована).",vbInformation
  ThisScript.SysAdminModeOff
 End If
End Sub

'--------------------------------------------------------------
Function GoApprov(Form,Obj)
'--------------------------------------------------------------
  ThisScript.SysAdminModeOn
 Set CU = ThisApplication.CurrentUser 
  
'  If Thisform.Controls("ACTIVEX_ATTR_CHECK_FLAG").activex = True Then
If Thisform.Controls("ACTIVEX_ATTR_CHECK_FLAG").activex.value = True Then
  ' Проверка атрибутов
   Attr = "ATTR_TENDER_INVITATION_PRICE_EIS,ATTR_TENDER_INVITATION_DATA_EIS,ATTR_TENDER_GROUP_CHIF" 
  Check = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","AttrCheckAttr",Form, Obj, Attr)
  If Check <> "" then
   ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","MainControlsBackColorAlarm",Form, Obj, Check
   Check = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","AttrCheckAttr",Form, Obj, Attr, True)
   ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","AttrControlsBackColorOff",Form, Obj, Check
  Exit Function
   End If
 
   'Выбор пользователя
  AttrName = "ATTR_TENDER_RESPONSIBLE_EIS"
  If Obj.Attributes.Has(AttrName) Then
    Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName)
    If User is Nothing Then
      Set Dlg = ThisApplication.Dialogs.SelectUserDlg
      Dlg.Caption = "Выберите пользователя, ответственного за подготовку и размещение закупки"
      If Dlg.Show Then
        If Dlg.Users.Count > 0 Then
          Set User = Dlg.Users(0)
       Obj.Attributes(AttrName) = User
        End If
      End If
    End If
  End If
  If User is Nothing Then
    Msgbox "Пользователь не выбран. Действие отменено.", vbExclamation
    Exit Function
  End If
  End if
  AttrName = "ATTR_TENDER_RESPONSIBLE_EIS"
  Set u0 = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName)
  Result = Msgbox("Перевести закупку в статус ""Утверждена""(для подготовки к публикации)?",vbYesNo+vbQuestion)
  If Result = vbNo Then Exit Function

    'Маршрут
  StatusName = "STATUS_TENDER_IN_APPROVED"
  
'  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
'  If RetVal = -1 Then
    If Thisform.Controls("ACTIVEX_ORDER_FLAG").activex.value <> True Then Obj.Status = ThisApplication.Statuses("STATUS_FULLACCESS")
    Obj.Status = ThisApplication.Statuses(StatusName)
    Call GoRoles(ThisObject)
'   End If

'Заполнение атрибута
  AttrName = "ATTR_TENDER_STATUS_EIS"
  If Obj.Attributes.Has(AttrName) Then
    Obj.Attributes(AttrName).Classifier = ThisApplication.Classifiers.FindBySysId("NODE_39BDAAE0_2286_4154_96DE_E31241D7434F")
  End If
  
  If Thisform.Controls("ACTIVEX_ORDER_FLAG").activex.value = True Then
  'Создание поручения
   
  AttrName0 = "ATTR_TENDER_GROUP_CHIF"
  AttrName1 = "ATTR_TENDER_RESPONSIBLE_EIS"
  Data1 = Obj.Attributes("ATTR_TENDER_INVITATION_DATA_EIS")
  Set u0 = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName0)
  Set u1 = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName1)
  If PlanDate = "" Then PlanDate = Data1
  resol = "NODE_COR_STAT_MAIN"
  ObjType = "OBJECT_KD_ORDER_NOTICE"
  txt = "Прошу подготовить и разместить закупку в указанные сроки"
  If not u1 is Nothing Then
'   If CU.SysName <> u1.SysName Then
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,u1,CU,resol,txt,PlanDate
    Msgbox "Закупка переведена в статус ""Подготовка к публикации"". Сотруднику " & u1.Description & """ выдано поручение.",vbInformation
'    End If
 else
    Msgbox "Закупка переведена в статус ""Утверждена"" (для подготовки к публикации).",vbInformation
  End If
  else
    Msgbox "Закупка переведена в статус ""Утверждена"" (для подготовки к публикации).",vbInformation
 End If
   Obj.SaveChanges ' Сохраняем
  ThisApplication.Utility.WaitCursor = False
  Result = True
  ThisScript.SysAdminModeOff
End Function


'---------------------------------------------------------
Sub GoExpert(Obj)
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  frm = false
  
  'Запрос о смене статуса
    Key = Msgbox("Перевести закупку в статус ""На рассмотрении"" (Опубликована)?",vbYesNo+vbQuestion)
    If Key = vbNo Then  Exit Sub
  
'If Thisform.Controls("ACTIVEX_ATTR_CHECK_FLAG").activex = True Then
If Thisform.Controls("ACTIVEX_ATTR_CHECK_FLAG").activex.value = True Then
  'Проверка атрибутов
  AttrName = "ATTR_TENDER_RES_CHECK_METOD"
   If Obj.Attributes.Has(AttrName) Then
    set Doc = Obj.Attributes(AttrName).Object
    If Obj.Attributes(AttrName).Empty = True Then
    Msgbox "Не выбран документ Методика оценки",vbExclamation
     exit sub
    end if
   end if

  If Obj.Attributes.Has("ATTR_TENDER_EXPERT_LIST") = False Then
    If Obj.ObjectDef.AttributeDefs.Has("ATTR_TENDER_EXPERT_LIST") Then
      Obj.Attributes.Create ThisApplication.AttributeDefs("ATTR_TENDER_EXPERT_LIST")
      Obj.Update
    End If
  End If
  
  If Obj.Attributes.Has("ATTR_TENDER_EXPERT_LIST") = False Then Exit Sub
  Set Table =  Obj.Attributes("ATTR_TENDER_EXPERT_LIST")
  If Not Table Is Nothing Then
    set rows = Table.Rows
  End If
 End If
 
 If Thisform.Controls("ACTIVEX_ORDER_FLAG").activex.value = True Then  
  'Выдача поручений
  str = ""
  resol = "NODE_CORR_REZOL_POD"
  ObjType = "OBJECT_KD_ORDER_REP"
' set ObjType = thisApplication.ObjectDefs(thisApplication.ObjectDefs("OBJECT_KD_ORDER_REP").Description)
  txt = "Прошу подготовить экспертное заключение по результатам проведенной закупки"
  AttrName = "ATTR_TENDER_CHECK_END_TIME"
  PlanDate = ""
  If Obj.Attributes.Has(AttrName) Then
    PlanDate = Obj.Attributes(AttrName)
  End If
  If PlanDate = "" Then PlanDate = Data1
  
  'Если поле Оценочная комиссия заполнено
   If Obj.Attributes.Has("ATTR_TENDER_EXPERT_LIST") = False Then Exit Sub
  Set Table =  Obj.Attributes("ATTR_TENDER_EXPERT_LIST")
  If Not Table Is Nothing Then
    set rows = Table.Rows
  End If
  If Not rows Is Nothing Then
    for each row in rows 
      If not row.Attributes("ATTR_TENDER_EXPERT").Empty = True then  frm = true
    next
  End If
  
  If frm = true then  
'    Answer = MsgBox("Передать закупку для рассмотрения результатов членами оценочной комиссии?", vbQuestion + vbYesNo,"")
'    if Answer <> vbYes then exit sub 
      AttrName = "ATTR_TENDER_RES_CHECK_METOD"
   If Obj.Attributes.Has(AttrName) Then
    set Doc = Obj.Attributes(AttrName).Object
    If Obj.Attributes(AttrName).Empty = True Then
    Msgbox "Для выдачи поручений необходим документ Методика оценки",vbExclamation
     exit sub
    end if
   end if
    
    
       
    for each row in rows  
    'Выдача поручений
      If row.Attributes.Has("ATTR_TENDER_EXPERT") Then
        If row.Attributes("ATTR_TENDER_EXPERT").Empty = False Then
          set user = row.Attributes("ATTR_TENDER_EXPERT").user
          If Not user Is Nothing Then
            If user.SysName <> CU.SysName Then
              Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,"ROLE_VIEW",User)
              ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Doc,ObjType,User,CU,resol,txt,PlanDate
              If str <> "" Then
                str =   str & " - " & user.Description & chr(10) 
              Else
                str = " - " & user.Description & chr(10) 
              End If
            End If
          End If
        End If
      End If
    Next
  End If

'Если поле Оценочная комиссия не заполнено    
  If frm = false then
   'Подтверждение
  Answer = MsgBox("Члены оценочной комиссии не выбраны. Выбрать членов комиссии?", vbQuestion + vbYesNo,"")
  if Answer <> vbYes then exit sub
 
  'Выбор пользователей
  Set Dlg = ThisApplication.Dialogs.SelectDlg
   GroupName = "GROUP_TENDER_EXPERT"
   If ThisApplication.Groups.Has(GroupName) Then
   Dlg.SelectFrom = ThisApplication.Groups(GroupName).Users
   else
   Dlg.SelectFrom = ThisApplication.Users
   End If
   
  Dlg.Prompt = "Выберите пользователей  - членов оценочной комиссии"
  Dlg.Caption = "Выбор пользователей"
  If Dlg.Show Then
    Set Users = Dlg.Objects
    If Users.Count = 0 Then
      Msgbox "Не выбрано ни одного пользователя",vbExclamation
      Exit Sub
    End If
  Else
    Exit Sub
  End If

  ThisApplication.Utility.WaitCursor = True

   AttrName = "ATTR_TENDER_RES_CHECK_METOD"
   If Obj.Attributes.Has(AttrName) Then
    set Doc = Obj.Attributes(AttrName).Object
     If Obj.Attributes(AttrName).Empty = True Then
     Msgbox "Для выдачи поручений необходим документ Методика оценки",vbExclamation
     exit sub
    end if
   end if
  'Выдача поручений и заполнение поля Оценочная комиссия

  If PlanDate = "" Then PlanDate = Data1
  i=0
   For Each User in Users
      If User.SysName <> CU.SysName Then
       Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,"ROLE_VIEW",User)
       ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Doc,ObjType,User,CU,resol,txt,PlanDate
      rows.Create
      rows(i).Attributes("ATTR_TENDER_EXPERT").user = User
      i=i+1
      If str <> "" Then
        str =  str & " - " & User.Description & chr(10) 
      Else
        str = " - " & User.Description & chr(10) 
      End If
    End If
  Next
 End If
  If str <> "" Then
    Msgbox "Закупка переведена в статус «На рассмотрении». Выдано поручение на экспертную оценку результатов закупки следующим пользователям:"&_ 
     chr(10)& chr(10)& str,vbInformation
  End If
  Else 
  Msgbox "Закупка переведена в статус ""На рассмотрении""."
End If
  
'  Маршрут
  StatusName = "STATUS_TENDER_CHECK_RESULT"
'  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
'  If RetVal = -1 Then
   If Thisform.Controls("ACTIVEX_ORDER_FLAG").activex.value <> True Then Obj.Status = ThisApplication.Statuses("STATUS_FULLACCESS")
   Obj.Status = ThisApplication.Statuses(StatusName)
   Call GoRoles(ThisObject)
'  End If
  Obj.SaveChanges ' Сохраняем 
  ThisApplication.Utility.WaitCursor = False
  ThisScript.SysAdminModeOff
End Sub

'---------------------------------------------------------
Sub GoClose(form,Obj)
 
  ThisScript.SysAdminModeOn
  
  Set Objects = Obj.Objects
  Answer = MsgBox("Перевести закупку в статус ""Завершена""?", vbQuestion + vbYesNo,"")
  if Answer <> vbYes then exit sub
  ThisApplication.Utility.WaitCursor = True
  
  'Смена статусов состава
  For Each Child in Objects
    If Child.ObjectDefName = "OBJECT_PURCHASE_LOT" and Child.StatusName <> "STATUS_LOT_IS_END" and _
    Child.StatusName <> "STATUS_S_INVALIDATED" Then
      StatusName = "STATUS_LOT_IS_END"
      RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Child,Child.Status,Child,StatusName)
      If RetVal = -1 Then
        Child.Status = ThisApplication.Statuses(StatusName)
      End If
    ElseIf Child.ObjectDefName = "OBJECT_PURCHASE_DOC" and Child.StatusName <> "STATUS_DOC_IS_END" and _
    Child.StatusName <> "STATUS_S_INVALIDATED" Then
      StatusName = "STATUS_DOC_IS_END"
      RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Child,Child.Status,Child,StatusName)
      If RetVal = -1 Then
        Child.Status = ThisApplication.Statuses(StatusName)
      End If
    End If
  Next

If Thisform.Controls("ACTIVEX_ORDER_FLAG").activex.value = True Then  
  'Создание поручений
  str = ""
  Set Doc = Nothing
  AttrName = "ATTR_TENDER_PROTOCOL"
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      If not Obj.Attributes(AttrName).Object is Nothing Then Set Doc = Obj.Attributes(AttrName).Object
    End If
  End If
  Set CU = ThisApplication.CurrentUser
 AttrName = "ATTR_TENDER_ACC_CHIF"

 Set Dept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetDeptByID","ID_TENDER_INSIDE_DISTR_STRU_OBJ")
  If not Dept is Nothing Then
    Set User = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetChiefByDept",Dept)
    If not User is Nothing Then 
    Set u0 = User
    End If 
  End If 
  
  Set u1 = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,"ATTR_TENDER_ACC_CHIF")
  Set u2 = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,"ATTR_TENDER_GROUP_CHIF")
  
  resol = "NODE_CORR_REZOL_INF"
  ObjType = "OBJECT_KD_ORDER_NOTICE"
  txt = "Прошу ознакомиться с результатами проведенной закупки"
  Set Roles = Obj.RolesByDef("ROLE_TENDER_INICIATOR")
  If not Doc is Nothing Then
  
    'Руководитель отдела по договорной работе и закупочным процедурам
    If not u0 is Nothing Then
      If u0.SysName <> CU.SysName Then
        ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Doc,ObjType,u0,CU,resol,txt,""
        If str = "" Then
          str = u0.Description
        Else
          str = str & ", " & u0.Description
        End If
      End If
    End If
    
    'Курирующий зам (бывший Главный бухгалтер)
    If not u1 is Nothing Then
      If u1.SysName <> CU.SysName and u1.SysName <> u0.SysName Then
        ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Doc,ObjType,u1,CU,resol,txt,""
        If str = "" Then
          str = u1.Description
        Else
          str = str & ", " & u1.Description
        End If
      End If
    End If
    
     'Руководитель группы
    If not u2 is Nothing Then
      If u2.SysName <> CU.SysName and u2.SysName <> u0.SysName and u2.SysName <> u1.SysName Then
        ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Doc,ObjType,u2,CU,resol,txt,""
        If str = "" Then
          str = u2.Description
        Else
          str = str & ", " & u2.Description
        End If
      End If
    End If
    
    'Роль Инициатор закупки
    For Each Role in Roles
      If not Role.User is Nothing Then
        Set u = Role.User
        If u.SysName <> CU.SysName Then
          ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Doc,ObjType,u,CU,resol,txt,""
          If str = "" Then
            str = u.Description
          Else
            str = str & ", " & u.Description
          End If
        End If
      End If
    Next
  End If
  
  If str <> "" Then
    Msgbox "Закупка переведена в статус ""Завершена""." & chr(10) & "Пользователям " & str &_
    " выдано поручение на ознакомление с результатами закупки",vbInformation
  Else
    Msgbox "Закупка переведена в статус ""Завершена""",vbInformation
  End If
  Else
  Msgbox "Закупка переведена в статус ""Завершена""",vbInformation
 End If 
 
    'Маршрут
  StatusName = "STATUS_TENDER_END"
'  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
'  If RetVal = -1 Then
    Call GoRoles(ThisObject)
    If Thisform.Controls("ACTIVEX_ORDER_FLAG").activex.value <> True Then Obj.Status = ThisApplication.Statuses("STATUS_FULLACCESS")
    Obj.Status = ThisApplication.Statuses(StatusName)
    
'  End If
   Obj.SaveChanges ' Сохраняем 
  ThisApplication.Utility.WaitCursor = False
  ThisScript.SysAdminModeOff
End Sub


'---------------------------------------------------------
'Вместо маршрутов. Назначаем только совершенно необходимое.
'Иниц. согл.  ROLE_INITIATOR 
'1. - CU, 
'2. Исполнитель  ATTR_TENDER_RESP, 
'3. Отв. за мат. ATTR_TENDER_MATERIAL_RESP, 
'4. Рук. ПЭО     ATTR_TENDER_PEO_CHIF, 
'5. Исп. ПЭО     ATTR_TENDER_KP_DESI, 
'6. Рук. грп.    ATTR_TENDER_GROUP_CHIF, 
'7. Исп. грп.    ATTR_TENDER_RESPONSIBLE_EIS

'Отв. по закупке ROLE_PURCHASE_RESPONSIBLE
'В статусе  Черновик 
'1. группа
'2. Исполнитель  ATTR_TENDER_RESP, 
'3. Отв. за мат. ATTR_TENDER_MATERIAL_RESP,

'В статусе Разработка документации
'1. группа       GROUP_TENDER_INSIDE
'2. Исполнитель  ATTR_TENDER_RESP, 
'3. Отв. за мат. ATTR_TENDER_MATERIAL_RESP
'4. Рук. ПЭО     ATTR_TENDER_PEO_CHIF, 
'5. Исп. ПЭО     ATTR_TENDER_KP_DESI, 

'В остальных
'1. группа       GROUP_TENDER_INSIDE

'Статусы 
' StatusName = "STATUS_TENDER_DRAFT" Черновик
' StatusName = "STATUS_TENDER_IN_PLAN" Запланировано
' StatusName = "STATUS_TENDER_IN_WORK" Разработка документации
' StatusName = "STATUS_TENDER_IN_PUBLIC" Размещена на площадке
' StatusName = "STATUS_TENDER_IN_APPROVED" Утверждена
' StatusName = "STATUS_TENDER_CHECK_RESULT" На рассмотрении

'---------------------------------------------------------
Function GoRoles(Obj)
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  StName = Obj.StatusName
  
If StName = "STATUS_TENDER_IN_WORK" Then 'В статусе Разработка документации
NameStr =  "ATTR_TENDER_RESP,ATTR_TENDER_MATERIAL_RESP,ATTR_TENDER_PEO_CHIF,ATTR_TENDER_KP_DESI,ATTR_TENDER_GROUP_CHIF,ATTR_TENDER_RESPONSIBLE_EIS" 
ArrName = Split(NameStr,",")
For i = 0 to Ubound(ArrName)
AttrName = ArrName(i)
Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName)
If not User is Nothing Then
 Set Roles = Obj.RolesForUser(User)
'Иниц. согл.  
 RoleName = "ROLE_INITIATOR"
 If Roles.Has(RoleName) = False Then
 Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,User.SysName)
 End If
'Отв. по закупке 
 RoleName = "ROLE_PURCHASE_RESPONSIBLE"
 If Roles.Has(RoleName) = False Then
 Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,User.SysName)
 End If
End If
next

ElseIf StName = "STATUS_TENDER_DRAFT" Then 'В статусе  Черновик 
'Отв. по закупке 
RoleName = "ROLE_PURCHASE_RESPONSIBLE"
NameStr =  "ATTR_TENDER_RESP,ATTR_TENDER_MATERIAL_RESP" 
ArrName = Split(NameStr,",")
For i = 0 to Ubound(ArrName)
AttrName = ArrName(i)
Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName)
If not User is Nothing Then
 Set Roles = Obj.RolesForUser(User)
 If Roles.Has(RoleName) = False Then
 Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,User.SysName)
 End If
End If
next
Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,"GROUP_TENDER_INSIDE")
'Отв. за кп
RoleName = "ROLE_TENDER_KP_DESI"
NameStr =  "ATTR_TENDER_PEO_CHIF,ATTR_TENDER_KP_DESI"
ArrName = Split(NameStr,",")
For i = 0 to Ubound(ArrName)
AttrName = ArrName(i)
Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName)
If not User is Nothing Then
 Set Roles = Obj.RolesForUser(User)
 If Roles.Has(RoleName) = False Then
 Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,User.SysName)
 End If
End If
next

Elseif StName = "STATUS_TENDER_IN_PUBLIC" or StName = "STATUS_TENDER_IN_APPROVED" or StName = "STATUS_TENDER_CHECK_RESULT" or StName = "STATUS_S_INVALIDATED" Then
RoleName = "ROLE_PURCHASE_RESPONSIBLE"
Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,"GROUP_TENDER_INSIDE")

End If 
End Function


sub SetChBox(src)
  set chk = thisForm.Controls("ACTIVEX_ATTR_CHECK_FLAG").ActiveX
  chk.buttontype = 4
'  Chk.value = CBool(src.Attributes("ATTR_TENDER_ONLINE").Value)
'  Chk.value = False
  set chk = thisForm.Controls("ACTIVEX_ORDER_FLAG").ActiveX
  chk.buttontype = 4
'  Chk.value = CBool(src.Attributes("ATTR_TENDER_ONLINE").Value)

end sub

