' Форма ввода - Финансирование
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.
USE "CMD_DLL_COMMON_BUTTON"

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  form.Controls("BUTTON_DOC_DEL").Enabled = False
  Form.Controls("BUTTON_DOC_EDIT").Enabled = False
  Call AttrsEnable(Form,Obj)
  'Блокируем контролы
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnEnable0",Form, Obj
End Sub

'Событие закрытия формы
Sub Form_BeforeClose(Form, Obj, Cancel)
  Cancel = Not ThisApplication.ExecuteScript("OBJECT_PURCHASE_DOC","CheckBeforeClose",Obj)
End Sub

 
'Событие - Выделение в выборке Документов закупки
Sub QUERY_TENDER_DOC_FINANCE_Selected(iItem, action)
  Set Query = ThisForm.Controls("QUERY_TENDER_DOC_FINANCE")
  Set Objects = Query.SelectedObjects
  If iItem <> -1 Then
    If Objects.Count = 1 Then
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

'Событие изменения значений атрибутов
'---------------------------------------------------------------------
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
 ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = True
 ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnEnable0",Form, Obj
  If Attribute.AttributeDefName = "ATTR_TENDER_KP_DESI" Then
    Call AttrsEnable(Form,Obj)
  End If
End Sub

'Процедура управления доступностью атрибутов
Sub AttrsEnable(Form,Obj)
  Set CU = ThisApplication.CurrentUser
  Set Roles = Obj.RolesForUser(CU)
  
  'Главный бухгалтер /Перенесено на форму Основное
'  If Obj.Attributes("ATTR_TENDER_ACC_CHIF").Empty = False Then
'    Form.Controls("ATTR_TENDER_ACC_CHIF").ReadOnly = True
'  End If
  
'  /Всегда только чтение
'  If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") = False Then
'    'Руководитель ПЭО
'    Form.Controls("ATTR_TENDER_PEO_CHIF").ReadOnly = True
'  End If
  
  'Ответственный за КП/НКП. Доступен только пользователю в поле Руководитель ПЭО и Группе, в любом активном статусе.
  Check = True
'  If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
  If CU.Groups.Has("GROUP_TENDER_INSIDE") Then
    Check = False
  Else
    AttrName = "ATTR_TENDER_PEO_CHIF"
    If Obj.Attributes(AttrName).Empty = False Then
      If not Obj.Attributes(AttrName).User is Nothing Then
        If Obj.Attributes(AttrName).User.SysName = CU.SysName Then Check = False
      End If
    End If
  End If
  Form.Controls("ATTR_TENDER_KP_DESI").ReadOnly = Check
  
   'Поручение ответственному за КП/НКП. Доступен только пользователю в поле Руководитель ПЭО и Группе, в любом активном статусе, если поле Ответственный заполнено .
 If CU.Groups.Has("GROUP_TENDER_INSIDE") Then
    Check = True
 End If
    AttrName = "ATTR_TENDER_PEO_CHIF"
    If Obj.Attributes(AttrName).Empty = False Then
      If not Obj.Attributes(AttrName).User is Nothing Then
        If Obj.Attributes(AttrName).User.SysName = CU.SysName Then Check = True
      End If
    End If
    If Check = True Then
      AttrName = "ATTR_TENDER_KP_DESI"
      If Obj.Attributes(AttrName).Empty = true Then 
      Check = False
      else
        If  Obj.Attributes(AttrName).User is Nothing Then
        Check = False
      else  
          If  Obj.Attributes(AttrName).User.SysName = CU.SysName Then Check = False
        End If
      End If
    End If
  
   Form.Controls("BUTTON_RESP_ORDER").Enabled = Check
  
   'Поручение Руководителю КП/НКП. Доступен только Ответственному по закупке и Группе, в любом активном статусе, если поле заполнено и не заполнен исполнитель.
    ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","AttrControlsAccessOff",Form, Obj, "BUTTON_CHIF_ORDER", "ROLE_PURCHASE_RESPONSIBLE"
 If CU.Groups.Has("GROUP_TENDER_INSIDE") Then
    Check = True
 End If
    AttrName = "ATTR_TENDER_PEO_CHIF"
    If Obj.Attributes(AttrName).Empty = False Then
      If not Obj.Attributes(AttrName).User is Nothing Then
      If Obj.Attributes(AttrName).User.SysName = CU.SysName Then Check = False
      End If
    End If
    If Check = True Then
      AttrName = "ATTR_TENDER_KP_DESI"
      If Obj.Attributes(AttrName).Empty = true Then 
      Check = True
      else
        If  Obj.Attributes(AttrName).User is Nothing Then
        Check = True
      else  
          If  Obj.Attributes(AttrName).User.SysName = CU.SysName Then 
       Check = False
      else  
          If Obj.Attributes(AttrName).Empty = False Then  Check = False
      
        End If
      End If
    End If
  End If
   Form.Controls("BUTTON_CHIF_ORDER").Enabled = Check
  
     
  'Код статьи бюджетного баланса
  Check = True
  If CU.Groups.Has("GROUP_TENDER_INSIDE") Then
    Check = False
  Else
    AttrName = "ATTR_TENDER_PEO_CHIF"
    If Obj.Attributes(AttrName).Empty = False Then
      If not Obj.Attributes(AttrName).User is Nothing Then
        If Obj.Attributes(AttrName).User.SysName = CU.SysName Then Check = False
      End If
    End If
    If Check = True Then
      AttrName = "ATTR_TENDER_KP_DESI"
      If Obj.Attributes(AttrName).Empty = False Then
        If not Obj.Attributes(AttrName).User is Nothing Then
          If Obj.Attributes(AttrName).User.SysName = CU.SysName Then Check = False
        End If
      End If
    End If
  End If
  Form.Controls("ATTR_TENDER_BALANS_CODE").ReadOnly = Check
  
  'Код статьи бюджета
  Check = True
  If CU.Groups.Has("GROUP_TENDER_INSIDE") Then
    Check = False
  Else
    AttrName = "ATTR_TENDER_PEO_CHIF"
    If Obj.Attributes(AttrName).Empty = False Then
      If not Obj.Attributes(AttrName).User is Nothing Then
        If Obj.Attributes(AttrName).User.SysName = CU.SysName Then Check = False
      End If
    End If
    If Check = True Then
      AttrName = "ATTR_TENDER_KP_DESI"
      If Obj.Attributes(AttrName).Empty = False Then
        If not Obj.Attributes(AttrName).User is Nothing Then
          If Obj.Attributes(AttrName).User.SysName = CU.SysName Then Check = False
        End If
      End If
    End If
  End If
  Form.Controls("ATTR_TENDER_BUDGET_ITEM_CODE").ReadOnly = Check
  
End Sub

'Кнопка - Приложить расчет стоимости НМЦ
Sub BUTTON_ADD_NMC_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","NewDocByTipe",ThisObject,"Расчет стоимости",True,false,false,True
'  Set NewObj = ThisObject.Objects.Create("OBJECT_PURCHASE_DOC")
'  NewObj.Attributes("ATTR_PURCHASE_DOC_TYPE").Classifier = _
'    ThisApplication.Classifiers.Find("Вид документа закупки").Classifiers.Find("Расчет стоимости")
'  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
'  Dlg.Object = NewObj
'  Dlg.Show
End Sub

'Кнопка - Добавить Документ закупки
Sub BUTTON_DOC_ADD_OnClick()
  Set NewObj = ThisObject.Objects.Create("OBJECT_PURCHASE_DOC")
  NewObj.Attributes("ATTR_PURCHASE_DOC_TYPE").Classifier = _
   ThisApplication.Classifiers.Find("Вид документа закупки").Classifiers.Find("Коммерческое предложение")
   NewObj.Attributes("ATTR_DOCUMENT_NAME").value = "Коммерческое предложение"
   NewObj.Attributes("ATTR_TENDER_PLAN_DOC") = True
   NewObj.Attributes("ATTR_TENDER_DOC_TIPE_LOC") = True
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = NewObj
  Dlg.Show
    End Sub

'Кнопка - Удалить Документ закупки
Sub BUTTON_DOC_DEL_OnClick()
  ThisScript.SysAdminModeOn
  Set Query = ThisForm.Controls("QUERY_TENDER_DOC_FINANCE")
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
  ThisForm.Refresh
End Sub

'Кнопка - Редактировать Документ закупки
Sub BUTTON_DOC_EDIT_OnClick()
  Set Query = ThisForm.Controls("QUERY_TENDER_DOC_FINANCE")
  Set Objects = Query.SelectedObjects
  If Objects.Count = 1 Then
    Set Dlg = ThisApplication.Dialogs.EditObjectDlg
    Dlg.Object = Objects(0)
    Dlg.Show
  End If
End Sub

  'Кнопка - Сохранить Перенести в библиотеку!
  Sub BUTTON_CUSTOM_SAVE_OnClick()
  ThisScript.SysAdminModeOn
  Key = Msgbox("Сохранить внесенные изменения?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
  ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = False
  ThisObject.Dictionary.Item("FormActive") = thisform.SysName
  ThisObject.Update
  'Call BtnEnable0(ThisForm,ThisObject)
End Sub
'Кнопка - Отменить Перенести в библиотеку!
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

'Кнопка - Создать договор
'-----------------------------------------------------------------------
Sub BUTTON_ADD_CONTRACT_OnClick()

  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnAddContract",ThisForm, ThisObject

End Sub

'Кнопка создания поручения Сотруднику ПЭО
Sub BUTTON_RESP_ORDER_OnClick()
 ThisScript.SysAdminModeOn
'If ThisObject.StatusName = "STATUS_TENDER_IN_AGREED" Then
AttrName1 = "ATTR_TENDER_PEO_CHIF"
AttrName2 = "ATTR_TENDER_KP_DESI"
     if AttrName1 <> "" and AttrName2 <> "" then 
     If ThisObject.Attributes.Has(AttrName1) and ThisObject.Attributes.Has(AttrName2) Then
      If not ThisObject.Attributes(AttrName1).Empty and not ThisObject.Attributes(AttrName1).Empty Then 
'        msgbox   AttrName1 & " " & AttrName2 , vbInformation
'       Set uFromUser = ThisObject.Attributes(AttrName1).User
       Set uFromUser = ThisApplication.CurrentUser
       Set uToUser = ThisObject.Attributes(AttrName2).User
'      If AttrNam Is Nothing Then Exit Sub
      End If
     End If
    End If
     resol = "NODE_CORR_REZOL_POD"
     txt = "Прошу подготовить необходимые по закупке """ & ThisObject.Description & """материалы"
     planDate = Date + 3
     ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateOrderAdnShow",ThisObject,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate, True
'       msgbox "Пользователю " & ThisObject.Attributes(AttrName2).value & " выдано поручение для подготовки необходимых по закупке " & ThisObject.Description & " материалов", vbInformation 
  Set Roles = ThisObject.RolesForUser(uToUser)
  If not roles.has("ROLE_TENDER_KP_DESI") then 
'   msgbox "Пользователю " & ThisObject.Attributes(AttrName2).value & " выдано поручение для подготовки необходимых по закупке " & ThisObject.Description & " материалов", vbInformation
    Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",ThisObject,"ATTR_TENDER_KP_DESI")  
     Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",ThisObject,"ROLE_TENDER_KP_DESI",User.SysName)
    End If 
   ThisScript.SysAdminModeOff
End Sub

'Кнопка создания поручения Руководителю ПЭО
Sub BUTTON_CHIF_ORDER_OnClick()
    'Создание поручения
     If not ThisObject.Attributes.Has("ATTR_TENDER_PEO_CHIF") Then Exit sub
        Set uFromUser = ThisApplication.CurrentUser
        Set uToUser = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",ThisObject,"ATTR_TENDER_PEO_CHIF")
        resol = "NODE_CORR_REZOL_POD"
        txt = "Прошу назначить исполнителя для расчета стоимости закупки"
        PlanDate = ""
        AttrName = "ATTR_TENDER_PLAN_ZD_PRESENT"
        If ThisObject.Attributes.Has(AttrName) Then
          PlanDate = ThisObject.Attributes(AttrName).Value
        End If
        If PlanDate = "" Then PlanDate = Date + 1
        If not uToUser is Nothing Then
          If uToUser.SysName <> uFromUser.SysName Then
            ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateOrderAdnShow",ThisObject,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate, True
'            ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,u,CU,resol,txt,PlanDate
          End If
        End If
   
End Sub
