' Форма ввода - Проектный документ
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

'USE "CMD_KD_COMMON_BUTTON_LIB"
'USE "CMD_KD_COMMON_LIB"
USE "CMD_DLL_COMMON_BUTTON"
USE "CMD_FILES_LIBRARY"
USE "CMD_PROJECT_DOCS_LIBRARY"
USE "CMD_DLL"
'USE "CMD_DLL_ROLES"

Sub Form_BeforeShow(Form, Obj)
  Call SetLabels(Form, Obj)
'  Call ThisApplication.ExecuteScript("CMD_DLL", "ShowBtnIcon",Form,Obj)

  Call SetControls(Form, Obj)

  Call SetFilesActionButtonLocked(Form,False)

'  If Obj.Permissions.ViewFiles=tdmAllow then
'    If Obj.Permissions.EditFiles=tdmallow then
      Call setEnabledButtonLocked (Form, Obj)
'    End If
'  End If
  
  'Доступность кнопок блока проверки
  Call SetCheckListControls(Form,Obj)
  
  '  Call CheckerRowsBtnEnabled(Form,Obj)
  
  'Доступность кнопок блока маршрутизации
  Call BlockRouteButtonLocked(Form,Obj)
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  If Attribute.AttributeDefName = "ATTR_G_PAGE_NUM" Then
    Call CodeGen (Obj)
  End If
  If Attribute.AttributeDefName = "ATTR_UNIT" Then
    Call CodeGen (Obj)
  End If
  
  If Attribute.AttributeDefName = "ATTR_NEED_AGREE" Then
    Obj.Update
'    Obj.SaveChanges 
'    Form.Refresh
  End If
  If Attribute.AttributeDefName = "ATTR_RESPONSIBLE" Then
    Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","ChangeResponsible",Obj,Attribute.User,OldAttribute.User)
    Call ThisApplication.ExecuteScript("CMD_DOC_DEVELOPER_APPOINT","SetRoles",Obj)
'    Set Dict = ThisApplication.Dictionary(Obj.GUID)
'    If Dict.Exists(Attribute.AttributeDefName) Then Dict.Remove(Attribute.AttributeDefName)
'    ThisApplication.Dictionary(ThisObject.GUID).Item(Attribute.AttributeDefName) = True
  End If
  
  If Attribute.AttributeDefName = "ATTR_PROJECT_DOC_TYPE" Then
    If Not Attribute.Classifier Is Nothing Then
      Call CodeGen (Obj)
      ' Заменяем наименование
      cName = Obj.Attributes("ATTR_DOCUMENT_NAME")
      If Trim(cName)<> "" Then
        ans=ThisApplication.ExecuteScript( "CMD_MESSAGE", "ShowWarning", vbQuestion+vbYesNo, 1032, Attribute.Classifier.Description)
        If ans = vbYes Then 
          Obj.Attributes("ATTR_DOCUMENT_NAME") = Attribute.Classifier.Description
        End If
      Else
        Obj.Attributes("ATTR_DOCUMENT_NAME") = Attribute.Classifier.Description
      End If
    End If
  End If
End Sub

'Кнопка - Сгенерировать обозначение документа
Sub BUTTON_CODE_GEN_OnClick()
  Call CodeGen (ThisObject)
End Sub

'======================================================================================
'
'    Блок работы с проверяющими
'
'======================================================================================

' Добавить проверяющего
Sub BTN_CHECKER_ADD_OnClick()
  Call ChekerRowAdd(ThisForm,ThisObject)
  Call SetCheckListControls(ThisForm,ThisObject)
'  Call CheckerRowsBtnEnabled(ThisForm,ThisObject)
End Sub

' Редактировать проверяющего
Sub BTN_CHECKER_EDIT_OnClick()
  Call ChekerRowEdit(ThisForm,ThisObject)
  Call SetCheckListControls(ThisForm,ThisObject)
End Sub

' Удалить проверяющего
Sub BTN_CHECKER_DEL_OnClick()
  Call ChekerRowDel(ThisForm,ThisObject)
  Call SetCheckListControls(ThisForm,ThisObject)
'  Call CheckerRowsBtnEnabled(ThisForm,ThisObject)
End Sub

' Переместить вверх
Sub BTN_CHECKER_UP_OnClick()
  Call ChekerRowUp(ThisForm,ThisObject)
End Sub

' Переместить вниз
Sub BTN_CHECKER_DOWN_OnClick()
  Call ChekerRowDown(ThisForm,ThisObject)
End Sub

'Событие - Смена выделения в таблице проверяющих
Sub ATTR_CHECK_LIST_SelChanged()
  Call SetCheckListControls(ThisForm,ThisObject)
  'Call CheckerRowsBtnEnabled(ThisForm,ThisObject)
End Sub
'======================================================================================


'======================================================================================
'
'    Блок маршрутизации
'
'======================================================================================

' Передать на проверку
Sub BTN_TO_CHECK_OnClick()
  Res = ThisApplication.ExecuteScript ("CMD_DOC_DEVELOPED", "Run", ThisObject)
  If Res = True Then
    ThisObject.SaveChanges
    ThisForm.Close True
  End If
End Sub

' Подписать
Sub BTN_SIGN_OnClick()
  Res = ThisApplication.ExecuteScript ("CMD_DOC_SIGN", "Run", ThisObject)
  If Res = True Then
    ThisObject.SaveChanges
    ThisForm.Close True
  End If
End Sub

' Передать на согласование
Sub BTN_TO_AGREE_OnClick()
  ThisForm.Close False
  
  ' Запоминаем, какую форму нужно активировать при переоткрытии диалога свойств
  Set dict = ThisObject.Dictionary
  If Not dict.Exists("FormActive") Then 
    dict.Add "FormActive", "FORM_KD_DOC_AGREE"
  End If
  
  Call ThisApplication.ExecuteScript ("CMD_DOC_SENT_TO_AGREED", "Run", ThisObject)
End Sub

' Передать на нормоконтроль
Sub BTN_TO_NK_OnClick()
  Res = ThisApplication.ExecuteScript ("CMD_DOC_SENT_TO_NK", "Run", ThisObject)
  If Res = True Then
    ThisObject.SaveChanges
    ThisForm.Close True
  End If
End Sub

' Передать на утверждение
Sub BTN_TO_APPROVAL_OnClick()
  Res = ThisApplication.ExecuteScript ("CMD_DOC_SENT_TO_APPROVE", "Main", ThisObject)
  If Res = True Then
    ThisObject.SaveChanges
    ThisForm.Close True
  End If
End Sub

' Утвердить документ
Sub BTN_APPROVE_OnClick()
  Res = ThisApplication.ExecuteScript ("CMD_DOC_APPROVE", "Run", ThisObject)
  If Res = True Then
    ThisObject.SaveChanges
    ThisForm.Close True
  End If
End Sub

' Вернуть на доработку  
Sub BTN_REJECT_OnClick()
  If ThisObject.StatusName = "STATUS_DOCUMENT_FIXED" Then
    Res = ThisApplication.ExecuteScript ("CMD_DOC_DEV_CHANGE", "Main", ThisObject)
  Else
    Res = ThisApplication.ExecuteScript ("CMD_DOC_BACK_TO_WORK", "Main", ThisObject)
  End If
  
  If Res = True Then
    ThisObject.SaveChanges
    ThisForm.Close True
  End If
End Sub

' Создать документ по образцу
Sub BTN_COPY_DOC_OnClick()
  Call BlockRouteDocCopy(ThisForm,ThisObject)
End Sub

' Аннулировать документ
Sub BTN_CANCEL_OnClick()
  Res = ThisApplication.ExecuteScript ("CMD_DOC_INVALIDATED", "Run", ThisObject)
  If Res = True Then
    ThisObject.SaveChanges
    ThisForm.Close True
  End If
End Sub

'Блок маршрутизации - Процедура копирования документа
Sub BlockRouteDocCopy(Form,Obj)
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  
  'Проверка
  If Obj.Parent is Nothing Then Exit Sub
  Set Parent = Obj.Parent
  If Parent.Permissions.EditContent <> 1 Then
    Msgbox "У вас недостаточно прав для выполнения данного действия", VbCritical
    Exit Sub
  End If
  
  'Создание копии документа
  DefName = Obj.ObjectDefName
  Set NewObj = Parent.Objects.Create(ThisApplication.ObjectDefs(DefName))
  If NewObj Is Nothing Then Exit Sub
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = NewObj
  'Копирование атрибутов
  NewObj.Attributes("ATTR_RESPONSIBLE").User = CU
  Set Rows = ThisApplication.Attributes("ATTR_KD_COPY_ATTRS").Rows
  For Each Row in Rows
    If Row.Attributes("ATTR_KD_OBJ_TYPE").Value = DefName Then
      AttrName = Row.Attributes("ATTR_KD_ATTR").Value
      If Obj.Attributes.Has(AttrName) and NewObj.Attributes.Has(AttrName) Then
        Call ThisApplication.ExecuteScript("CMD_DLL","AttrValueCopy",Obj.Attributes(AttrName),NewObj.Attributes(AttrName))
        If AttrName = "ATTR_CHECK_LIST" Then
          Set Rows0 = NewObj.Attributes(AttrName).Rows
          For Each Row0 in Rows0
            Row0.Attributes("ATTR_RESOLUTION").Classifier = Nothing
            Row0.Attributes("ATTR_T_REJECT_REASON").Value = ""
            Row0.Attributes("ATTR_DATA").Value = ""
          Next
        End If
      End If
    End If
  Next
  Dlg.Show
  
End Sub
'======================================================================================


Sub SetControls(Form, Obj)
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  'Доступность редактирования обозначения
  Check = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "DocDevCodeGenCheck",Obj)
  Form.Controls("ATTR_DOC_CODE").ReadOnly = not Check
  Form.Controls("BUTTON_CODE_GEN").Enabled = Check
  'Form.Controls("BTN_OUT_DOC_PREPARE").Enabled = 
  If Not Obj.Parent Is Nothing Then
    Call SetControlVisible(Form,"ATTR_UNIT",(Obj.Parent.ObjectDefName = "OBJECT_VOLUME"))
  End If
  Set Dept = Nothing
  Check0 = CheckObj0(Obj)
  Check1 = CheckObj1(Obj)
  Check2 = CheckObj2(Obj)
  Check3 = CheckObj3(Obj)

  AttrList = GetAttrsList(Form)
  If Not (check0 or Check1 or Check2 or Check3) Then
    Call SetControlReadonly(Form,AttrList)
  End If
  
  Obj.Permissions = SysAdminPermissions
  If Obj.Parent Is Nothing Then Exit Sub
  If Obj.Parent.Attributes.Has("ATTR_S_DEPARTMENT") Then
    Set Dept = Obj.Parent.Attributes("ATTR_S_DEPARTMENT").Object
  End If
  If Dept Is Nothing Then
    If Obj.Parent.Attributes.Has("ATTR_RESPONSIBLE") Then
      Set User = Obj.Parent.Attributes("ATTR_RESPONSIBLE").User
      Set Dept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetDeptForUserByGroup",User,"GROUP_LEAD_DEPT")
    End If
  End If  
  Set users = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetGroupsChiefsByDept",Dept)
  If Not Users Is Nothing Then _
    Form.Controls("ATTR_RESPONSIBLE").ReadOnly = not Users.Has(CU)
End Sub

Function GetAttrsList(Form)
  GetAttrsList = ""
  For Each Ctrl In Form.Controls
    If Left(Ctrl.Name,4) = "ATTR" Then
      If GetAttrsList = "" Then
        GetAttrsList = Ctrl.Name
      Else
        GetAttrsList = GetAttrsList & "," & Ctrl.Name
      End If
    End If
  Next
End Function

'Функция проверки объекта на передачу на проверку
Function CheckObj0(Obj)
  CheckObj0 = False
  Set CU = ThisApplication.CurrentUser
  If Obj.StatusName = "STATUS_DOCUMENT_CREATED" And _
    ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsDeveloper",Obj,CU) Then
    CheckObj0 = True
  End If
End Function

'Функция проверки объекта на Отклонение с проверки или передачи на подпись
Function CheckObj1(Obj)
  CheckObj1 = False
  Set CU = ThisApplication.CurrentUser
  If Obj.StatusName = "STATUS_DOCUMENT_CHECK" And _
    ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsChecker",Obj,CU) Then
    CheckObj1 = True
  End If
End Function

'Функция проверки объекта на выдачу
Function CheckObj2(Obj)
  CheckObj2 = False
  Set CU = ThisApplication.CurrentUser
  If Obj.StatusName = "STATUS_T_TASK_IS_SIGNING" And _
    ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsSigner",Obj,CU) Then
    CheckObj2 = True
  End If
End Function

'Функция проверки объекта на утверждение
Function CheckObj3(Obj)
  CheckObj3 = False
  Set CU = ThisApplication.CurrentUser
  Set Roles = Obj.RolesForUser(CU)
  If Obj.StatusName = "STATUS_DOCUMENT_IS_APPROVING" And _
    ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsAprover",Obj,CU) Then
    CheckObj3 = True
  End If
End Function

Sub ATTR_RESPONSIBLE_BeforeAutoComplete(Text)
  Set ctrl = thisForm.Controls("ATTR_RESPONSIBLE").ActiveX
  Set CU = ThisApplication.CurrentUser
  Set dept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetDeptForUserByGroup",CU,"GROUP_LEAD_DEPT")
  Set users = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetAllUsersByDept",dept)
    
  ' Если ввели 1 буквы и более
  If Len(text)>0 then
'    ctrl.ComboItems = ThisApplication.Groups(grName).Users
    ctrl.ComboItems = users
  End If
End Sub

Sub ATTR_CHECK_LIST_CellInitEditCtrl(nRow, nCol, pEditCtrl, bCancelEdit)

End Sub

Sub ATTR_PROJECT_DOC_TYPE_ButtonClick(Cancel)
  ProjType = ThisApplication.ExecuteScript("OBJECT_PROJECT","GetProjectWorkType",ThisObject)
  If ProjType = "NODE_WORK_TYPE_PEMC" Then
    Set source = ThisApplication.Classifiers.FindBySysId("NODE_DOC_TYPES_ALL").Classifiers.Find("Документы ПЭМиК")
    set dlg = ThisApplication.Dialogs.SelectClassifierDlg
    dlg.Root = source
    RetVal = dlg.Show
    If (RetVal<>TRUE) Then 
      Cancel = True 
      Exit Sub
    End If
    ThisForm.Controls("ATTR_PROJECT_DOC_TYPE").Value = dlg.Classifier
    Cancel = True
  End If
End Sub

Sub ATTR_PROJECT_DOC_TYPE_BeforeAutoComplete(Text)
  ProjType = ThisApplication.ExecuteScript("OBJECT_PROJECT","GetProjectWorkType",ThisObject)
  If ProjType = "NODE_WORK_TYPE_PEMC" Then
    If Len(Text) > 0 Then
      Set source = ThisApplication.Classifiers.FindBySysId("NODE_DOC_TYPES_ALL").Classifiers.Find("Документы ПЭМиК")
      If Not source Is Nothing Then
        ThisForm.Controls("ATTR_PROJECT_DOC_TYPE").ActiveX.comboitems = source.Classifiers
      End If
    End If
  End If
End Sub
