
' Форма ввода - Основное (Внутренняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "CMD_DLL_COMMON_BUTTON"
'События
'-----------------------------------------------------------------------
'-----------------------------------------------------------------------

'Событие Открытие формы
'-----------------------------------------------------------------------
Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Set CU = ThisApplication.CurrentUser
 isLock = false
      If ThisObject.Permissions.Locked = True Then
        If ThisObject.Permissions.LockUser.Handle <> thisApplication.CurrentUser.Handle  Then
          msgbox "В настоящий момент документ редактируется пользователем " & ThisObject.Permissions.LockUser.Description & _
      ". Некоторые действия с объектом могут быть недоступны или отклонены.", vbExclamation 
          isLock = true
        end if
      end if  
      isApr = false 
      isApr = ThisApplication.ExecuteScript("CMD_KD_USER_PERMISSIONS","IsCanAprove",thisApplication.CurrentUser, Obj)   
   
'Блокируем контролы
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","MainControlsEnable",ThisForm, ThisObject
  sListAttrs = "ATTR_TENDER_PPZ_NUM"
  ThisApplication.ExecuteScript "CMD_DLL","SetControlVisible",ThisForm,sListAttrs,_
  ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsGroupMember",ThisApplication.CurrentUser,"GROUP_TENDER_INSIDE") = True
  
 End Sub

'Событие Изменение значения в контролах атрибутов формы
'-----------------------------------------------------------------------
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)

 'По датам 
'msgbox Form.Controls("ATTR_TENDER_DATA_CHECK_FLAG")
 If Form.Controls("ATTR_TENDER_DATA_CHECK_FLAG") = "True" Then
'  msgbox Form.Controls("ATTR_TENDER_DATA_CHECK_FLAG")
 Cancel = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","AutoDateCalcVSCheck",Form, Obj, Attribute, Cancel, OldAttribute)
 End If
 
'По основным атрибутам
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","MainAttributeChange",Form, Obj, Attribute, Cancel, OldAttribute

 If Attribute.AttributeDefName = "ATTR_TENDER_PLAN_YEAR" Then  
  Call RegNumCalc(Obj)
 End If

End Sub 
  
'Событие - Изменение значений табличных атрибутов
'-----------------------------------------------------------------------
Sub Form_TableAttributeChange(Form, Object, TableAttribute, TableRow, ColumnAttributeDefName, OldTableRow, Cancel)
 ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = True
 ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnEnable0",ThisForm, ThisObject  'Call BtnEnable0(Form,Obj)
End Sub

'Событие - Выделение в выборке Документов закупки
'-----------------------------------------------------------------------
Sub QUERY_TENDER_DOCS_Selected(iItem, action)
  Set Query = ThisForm.Controls("QUERY_TENDER_DOCS")
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

'Событие - Выделение в выборке лотов
'-----------------------------------------------------------------------
Sub QUERY_LOT_LIST_Selected(iItem, action)
  Set CU = ThisApplication.CurrentUser
  Set Query = ThisForm.Controls("QUERY_LOT_LIST")
  Set Objects = Query.SelectedObjects
  If iItem <> -1 Then
    ThisForm.Controls("BUTTON_LOT_DEL").Enabled = CanDeleteLot(ThisObject,CU)
    If Objects.Count = 1 Then
      ThisForm.Controls("BUTTON_LOT_EDIT").Enabled = True
    Else
      ThisForm.Controls("BUTTON_LOT_EDIT").Enabled = False
    End If
  Else
    ThisForm.Controls("BUTTON_LOT_DEL").Enabled = False
    ThisForm.Controls("BUTTON_LOT_EDIT").Enabled = False
  End If
End Sub


'Кнопки
'-----------------------------------------------------------------------
'-----------------------------------------------------------------------

'Кнопка - Добавить Лот
'-----------------------------------------------------------------------
Sub BUTTON_LOT_ADD_OnClick()
  Set NewObj = ThisObject.Objects.Create("OBJECT_PURCHASE_LOT")
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = NewObj
  Dlg.Show
End Sub

'Кнопка - Удалить Лот
Sub BUTTON_LOT_DEL_OnClick()
 ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnLotDelOnclic",ThisForm, ThisObject
End Sub

'Кнопка - Редактировать Лот
'-----------------------------------------------------------------------
Sub BUTTON_LOT_EDIT_OnClick()
  Set Query = ThisForm.Controls("QUERY_LOT_LIST")
  Set Objects = Query.SelectedObjects
  If Objects.Count = 1 Then
    Set Dlg = ThisApplication.Dialogs.EditObjectDlg
    Dlg.Object = Objects(0)
    Dlg.Show
  End If
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
  Set Query = ThisForm.Controls("QUERY_TENDER_DOCS")
  Set Objects = Query.SelectedObjects
  If Objects.Count = 1 Then
    Set Dlg = ThisApplication.Dialogs.EditObjectDlg
    Dlg.Object = Objects(0)
    Dlg.Show
  End If
End Sub

'Кнопка - Скорректировать номер закупки заказчика
'-----------------------------------------------------------------------
Sub BUTTON_PURCHASE_NUM_CHANGE_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnPurchaseNumChangeOnclic",ThisForm, ThisObject
End Sub

'Кнопка - Скорректировать уникальный номер закупки
'-----------------------------------------------------------------------
Sub BUTTON_PURCHASE_UNICNUM_CHANGE_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnPurchaseUnicNumChangeOnclic",ThisForm, ThisObject
End Sub

'Кнопка - Сохранить
'-----------------------------------------------------------------------
Sub BUTTON_CUSTOM_SAVE_OnClick()
  ThisScript.SysAdminModeOn
  Key = Msgbox("Сохранить внесенные изменения?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
  ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = False
  ThisObject.SaveChanges
End Sub

'Кнопка - Отменить
'-----------------------------------------------------------------------
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

'Кнопка - Редактировать список аналогов
'-----------------------------------------------------------------------
Sub BUTTON_ANALOG_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnAnalogOnclic",ThisForm, ThisObject
End Sub

'Кнопка - Согласовать
'-----------------------------------------------------------------------
Sub BUTTON_AGREED_OnClick()
 ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnAgreedOnclic",ThisForm, ThisObject
End Sub

'Кнопка - Запланировать
'-----------------------------------------------------------------------
Sub BUTTON_PLAN_OnClick()
If ThisApplication.ExecuteScript("CMD_TENDER_IN_GO_PLAN", "Main", ThisForm, ThisObject) = False Then
'  ThisApplication.ExecuteScript "CMD_TENDER_IN_GO_PLAN", "Main", ThisObject
  ThisObject.Dictionary.Item("FormActive") = "FORM_TENDER_INSIDE_MAIN"
'  Msgbox "" & Main,vbExclamation
    Thisform.close False
  End if
'  ThisObject.SaveChanges
End Sub

'Кнопка - В разработку документации
'-----------------------------------------------------------------------
Sub BUTTON_TO_DEVELOP_OnClick()
  ThisApplication.ExecuteScript "CMD_TENDER_IN_GO_WORK", "Main", ThisObject
  ThisObject.SaveChanges
  
 ' Set Doc = InfoDocGet(ThisObject)
 ' If Doc is Nothing Then
  '  Call ThisApplication.ExecuteScript("FORM_TENDER_INFORMATION_CARD","BUTTON_INFO_DOC_CREATE_OnClick")
 ' End If
End Sub

'Кнопка - Разработчики
'-----------------------------------------------------------------------
Sub BUTTON_DEVELOPERS_OnClick()
  ThisScript.SysAdminModeOn
'  ThisObject.SaveChanges
  ThisObject.Dictionary.Item("FormActive") = "FORM_TENDER_IN_DESIGNERS_LIST"
  ThisForm.Close 
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = ThisObject
  Dlg.Show
End Sub

'Кнопка - На утверждение
'-----------------------------------------------------------------------
Sub BUTTON_TO_APPROVE_OnClick()
  ThisApplication.ExecuteScript "CMD_TENDER_IN_GO_IS_APPROVING", "Main", ThisObject
  ThisObject.SaveChanges
End Sub

'Кнопка - Вернуть в работу
'-----------------------------------------------------------------------
Sub BUTTON_BACK_TO_WORK_OnClick()
  ThisApplication.ExecuteScript "CMD_TENDER_IN_BACK_TO_WORK", "Main", ThisObject
  ThisObject.SaveChanges
End Sub

'Кнопка - Утверждаю
'-----------------------------------------------------------------------
Sub BUTTON_APPROVE_OnClick()
  ThisApplication.ExecuteScript "CMD_TENDER_IN_APPROV", "Main", ThisObject
  ThisObject.SaveChanges
End Sub

'Кнопка - Вычислить планируемую цену закупки
'-----------------------------------------------------------------------
Sub BUTTON_PLAN_PRICE_CALC_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","ButtonPriceCalc",ThisForm, ThisObject, True
End Sub

'Кнопка - Создать договор
'-----------------------------------------------------------------------
Sub BUTTON_ADD_CONTRACT_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnAddContract",ThisForm, ThisObject

End Sub

'Кнопка - Письмо согласования ДУКЗ
'-----------------------------------------------------------------------
Sub BTN_OUT_DOC_PREPARE_OnClick()
  Set ATTR_TENDER_DUKZ_LETTER = ThisObject.Attributes("ATTR_TENDER_DUKZ_LETTER").Object
  If Not ATTR_TENDER_DUKZ_LETTER Is Nothing Then 
    ans = msgbox("На закупке указано сопроводительное письмо " & ATTR_TENDER_DUKZ_LETTER.Description & ". " &_
                  "Вы хотите создать новое?", vbQuestion+vbYesNo, "Сопроводительное письмо")
    If ans <> vbYes Then Exit Sub
  End If
  Set docOut = ThisApplication.ExecuteScript("CMD_DLL","CreareDocOut",ThisObject)
  If Not docOut Is Nothing Then
    ThisObject.Attributes("ATTR_TENDER_DUKZ_LETTER").Object = DocOut
   ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","Numsync",Obj, Form ' Call Numsync(Obj)
  End If
End Sub

'-----------------------------------------------------------------------
Function CanDeleteLot(Obj,User)
  CanDeleteLot = ThisApplication.ExecuteScript("OBJECT_PURCHASE_LOT","checkBeforeErase",Obj,User,True)
End Function

Sub BUTTON_ADD_PRICE_CALC_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","NewDocByTipe",ThisObject,"Расчет стоимости",True,false,false,True
'(Obj,tp,pl,wk,pb,loc)
End Sub
Sub BUTTON_ADD_TECH_ORDER_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","NewDocByTipe",ThisObject,"Техническое задание",True,false,false,True
End Sub
Sub BUTTON_ADD_MAT_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","NewDocByTipe",ThisObject,"Исходные материалы",True,false,false,True
End Sub
'Копия
'Sub BTN_COPY_DOC_OnClick()
'  Res = ThisApplication.ExecuteScript("CMD_DLL","CopyObj",ThisObject)
'  If Not Res Then Exit Sub
'  ThisForm.Close
'End Sub

'Sub BTN_TO_CONTROL_OnClick()
'End Sub

'Событие - выбор 2.2 в Разделе плана - запрашиваем создание Расчета стоимости, если его еще нет
'"2.2 - Закупки на поставку МТР за счет собственных средств дочерних обществ ПАО "Газпром" и прочих источников финансирования"
Sub ATTR_TENDER_PLAN_PART_NAME_Modified()
Set Obj = ThisObject
 AttrName = "ATTR_TENDER_PLAN_PART_NAME"
 If Obj.Attributes.Has(AttrName) Then
   If Obj.Attributes(AttrName).Empty = False Then
   Code = Obj.Attributes(AttrName).Classifier.Code
     If Code = "2.2" Then  
  Set Query = ThisApplication.Queries("QUERY_TENDER_DOCS_SEARCH_FOR_TYPE")
  Query.Parameter("GUID") = "= '" & Obj.GUID & "'"
'        Set Clf = ThisApplication.Classifiers.FindBySysId("NODE_BCCFBE61_4066_42CA_BE49_63EF7425D689")
         Set Clf = ThisApplication.Classifiers.Find("Разделы плана закупок").Classifiers._
           Find("Закупки на поставку МТР за счет собственных средств дочерних обществ ПАО ""Газпром"" и прочих источников финансирования")
        Query.Parameter("TYPE") = "= '" & Clf.Description & "'"
         Set Objects = Query.Objects
   Codus = Objects.Count
   If Codus < 1 Then
    Key = Msgbox("Добавить Расчет стоимости?",vbYesNo+vbQuestion)
    If Key = vbYes Then 'Exit Sub
      ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","NewDocByTipe",Obj,"Расчет стоимости",True,false,false,True 
      ThisForm.Refresh
      End If
     End If
   End If
  End If
  End If
End Sub


Sub QUERY_LOT_LIST_Refreshed()
Call eshed()
End Sub

'Обновление цены после изменения в лоте
'----------------------------------------
Sub eshed()
Set CU = ThisApplication.CurrentUser
Set Obj = ThisObject
  If not Obj is Nothing Then
   If Obj.Permissions.Locked = True Then
    If Obj.Permissions.LockUser.SysName <> CU.SysName Then EXIT SUB
   End If
  End If


Set Form = ThisForm
Check = False
 For Each Child in Obj.Objects
    If Child.ObjectDefName = "OBJECT_PURCHASE_LOT" Then
     If Child.Attributes.Has("ATTR_TENDER_LOT_NAME") Then
      If Child.Attributes("ATTR_TENDER_LOT_NAME").Empty = False Then
      Check = True 
'     If Child.Attributes("ATTR_TENDER_LOT_NAME") <> "" Then Check = True 
      End If
     End If
    End If
    next
 If Check = False Then Exit Sub
'msgbox Check

AttrName1 = "ATTR_TENDER_PLAN_PRICE"
AttrName2 = "ATTR_TENDER_PLAN_NDS_PRICE"
AttrName3 = "ATTR_NDS_VALUE"
  On Error Resume Next
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","ButtonPriceCalc",ThisForm, ThisObject,false
  On Error GoTo 0
'  P1 = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","PriceTenderCalc",Form, Obj, 1)
'  P2 = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","PriceTenderCalc",Form, Obj, 2)
'  P3 = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","PriceTenderCalc",Form, Obj, 3)
''msgbox P1 &P2 &p3
'  Obj.Attributes(AttrName1).Value = P1
'  Obj.Attributes(AttrName2).Value = P2
'  If P3 <> "0" then
'  Obj.Attributes(AttrName3).Value = P3
'  else
'  Obj.Attributes(AttrName3).Value = ThisApplication.Classifiers("NODE_F7E00034_5715_45AB_8952_0860746AD1C6").Classifiers.Find("Составной")
'  End If
  
 If Obj.Attributes(AttrName1).Value <> Form.Controls(AttrName1).ActiveX.Text Then Form.Controls(AttrName1).ActiveX.Text = Obj.Attributes(AttrName1).Value
'  msgbox Form.Controls(AttrName2).ActiveX.Text
' msgbox Obj.Attributes(AttrName2).Value

 A = ""
 A = Obj.Attributes(AttrName2).Value
 B = ""
 B = Form.Controls(AttrName2).ActiveX.Text

 If Obj.Attributes(AttrName2).Empty = True Then 
 Form.Controls(AttrName2).ActiveX.Text = Obj.Attributes(AttrName2).Value

 ElseIf RTrim(A) <> RTrim(B) Then
 Form.Controls(AttrName2).ActiveX.Text = Obj.Attributes(AttrName2).Value
 End if
 If Obj.Attributes(AttrName3) <> Form.Controls(AttrName3) Then Form.Controls(AttrName3) = Obj.Attributes(AttrName3)
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","Slowpricesync",ThisForm,ThisObject 
End Sub

Sub ATTR_TENDER_ANALOG_TABLE_Refreshed()
Set Obj = ThisObject
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
End Sub


Sub ATTR_TENDER_PLAN_YEAR_Modified()
Set Obj = thisObject
' RegNum = ThisApplication.ExecuteScript("CMD_S_NUMBERING","PurchaseInsideNumGet",Obj,"")
'Call RegNumCalc(Obj)
 
'  If RegNum <> "" Then
'    Arr = Split(RegNum,"#")
'    Num = cLng(Arr(1))
'    RegNum = Replace(RegNum,"#","")
'    On Error Resume Next
'    Obj.Attributes("ATTR_TENDER_CLIENTS_NUM").Value = RegNum
'    Obj.Attributes("ATTR_PROJECT_ORDINAL_NUM").Value = Num
'    Obj.Attributes("ATTR_SYSTEM_DATE_NUM_GEN").Value = Date
    'If Err.Number <> 0 Then
    '  Msgbox "Номер закупки заказчика должен быть уникальным!", VbCritical
    'End If
'    On Error GoTo 0
'  End If

End Sub


Sub RegNumCalc(Obj)
 RegNum = ThisApplication.ExecuteScript("CMD_S_NUMBERING","PurchaseInsideNumGet",Obj,"")
   If RegNum <> "" Then
    Arr = Split(RegNum,"#")
    Num = cLng(Arr(1))
    RegNum = Replace(RegNum,"#","")
    On Error Resume Next
   Obj.Attributes("ATTR_TENDER_CLIENTS_NUM").Value = RegNum
   Obj.Attributes("ATTR_PROJECT_ORDINAL_NUM").Value = Num
   Obj.Attributes("ATTR_SYSTEM_DATE_NUM_GEN").Value = Date

    On Error GoTo 0
  End If
End Sub


Sub BUTTON_CHIF_ORDER_OnClick()
 'Создание поручения
' CreateTypeOrderToUserResol
        Set uFromUser = ThisApplication.CurrentUser
        Set uToUser = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",ThisObject,"ATTR_TENDER_GROUP_CHIF")
        resol = "NODE_CORR_REZOL_POD"
        ObjType = "OBJECT_KD_ORDER_NOTICE"
        txt = "Прошу внести изменения в свойствах плановой закупки"
        PlanDate = date + 1
'        AttrName = "ATTR_TENDER_PLAN_ZD_PRESENT"
'        If ThisObject.Attributes.Has(AttrName) Then
'          PlanDate = ThisObject.Attributes(AttrName).Value
'        End If
'        If PlanDate = "" Then PlanDate = Date + 1
        If not uToUser is Nothing Then
          If uToUser.SysName <> uFromUser.SysName Then
'          ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateOrderAdnShow",ThisObject,ObjType,uToUser,uFromUser,resol,txt,planDate, false
            ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",ThisObject,ObjType,uToUser,uFromUser,resol,txt,PlanDate
          End If
        End If
End Sub
