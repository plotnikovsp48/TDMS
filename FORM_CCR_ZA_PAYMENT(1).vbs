USE "CMD_DLL"

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Set oContract = Obj.Attributes("ATTR_CONTRACT").Object
'  If Not oContract Is Nothing Then
'    Set oContractor = oContract.Attributes("ATTR_CONTRACTOR").Object
'  End If
  
 ' If Not oContractor Is Nothing Then
 '   Form.Controls("ATTR_KD_CPNAME").Value = oContractor.Description
' End If
  'Call SetControlsReadOnly(Form)
  Call SetButtons(Form,Obj)
End Sub


Sub BTN_ZO_CREATE_OnClick()
  ThisApplication.AddNotify "BTN_ZO_CREATE_OnClick - 1 " & Time
  Set ZODoc = CreateZO(ThisObject)
  ThisApplication.AddNotify "BTN_ZO_CREATE_OnClick - 2 " & Time
  Call AddZo(ThisObject,ZODoc)
  ThisApplication.AddNotify "BTN_ZO_CREATE_OnClick - 3 " & Time
End Sub

Function CreateZO(Obj)
ThisApplication.AddNotify "CreateZO - 1 " & Time
  Set CreateZO = Nothing
  set NewObj =  Create_Doc_by_Type(ThisApplication.ObjectDefs("OBJECT_KD_ZA_PAYMENT"), Obj)
  ThisApplication.AddNotify "CreateZO - 2 " & Time
  If NewObj Is Nothing Then 
    msgbox "Не удалось создать заявку на оплату"
    Exit Function
  End If
  Set CreateZO = NewObj
End Function
 
Sub AddZo(Obj,ZODoc)
  If (Obj Is Nothing) Or (ZODoc Is Nothing) Then Exit Sub
  If Obj.Attributes.Has("ATTR_CCR_ZA") = False Then Exit Sub
  ' Добавление ссылки на сформированную заявку в таблицу
  Set Table = ThisForm.Controls("ATTR_CCR_ZA").ActiveX
  Set SelRow = Table.RowValue(Table.SelectedRow)
  SelRow.Attributes("ATTR_DOC_REF").Object = ZODoc
  Obj.SaveChanges 16384
End Sub

Sub SetControlsReadOnly(Form)
  Form.Controls("ATTR_KD_ZA_MAINDOC").ReadOnly = (Not ThisObject.Attributes("ATTR_CONTRACT").Object Is Nothing)
End Sub


'Взято из CMD_KD_COMMON_LIB
'=============================================
function Create_Doc_by_Type(objType, docBase)
ThisApplication.AddNotify "Create_Doc_by_Type - 1 " & Time
    ThisScript.SysAdminModeOn
    set Create_Doc_by_Type = nothing
    Set ObjRoots = thisApplication.ExecuteScript("CMD_KD_FOLDER","GET_FOLDER","",objType) 
    if  ObjRoots is nothing then  
      msgBox "Не удалось создать папку", vbCritical, "Объект не был создан"
      exit function
    end if
    ThisApplication.AddNotify "Create_Doc_by_Type - 2 " & Time
    CreateObj = true
    ObjRoots.Permissions = SysAdminPermissions
    Set CreateDocObject = ObjRoots.Objects.Create(objType)
    ThisApplication.AddNotify "Create_Doc_by_Type - 3 " & Time
'    if objType.SysName = "OBJECT_KD_DOC_OUT" and not docBase is nothing then 
'      ' если ИД, то записываем ответ на
'      call thisApplication.ExecuteScript("CMD_KD_COMMON_BUTTON_LIB","AddReplDoc",CreateDocObject, docBase) 
'    end if
    call thisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS","Set_Permission",CreateDocObject)
    ThisApplication.AddNotify "Create_Doc_by_Type - 4 " & Time
    ' CreateDocObject.Update   
    ' Инициализация свойств диалога создания объекта
'    formName = thisApplication.ExecuteScript("OBJECT_KD_BASE_DOC", "GetCreateFroms", CreateDocObject)
'    if formName <> "" then  call thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","SetGlobalVarrible","ShowForm", formName)  
     Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
     CreateObjDlg.Object = CreateDocObject
     
     Call SetAttrs(CreateDocObject,docBase)
     ThisApplication.AddNotify "Create_Doc_by_Type - 5 " & Time
     Call CopyFiles(CreateDocObject,docBase)
     ThisApplication.AddNotify "Create_Doc_by_Type - 6 " & Time
     CreateDocObject.Update
     ans = CreateObjDlg.Show
    
     if CreateDocObject.StatusName = "STATUS_KD_DRAFT" then   
       If not ans then
          If CreateObj Then 
             CreateDocObject.Erase  ' EV все-таки подумать как удалять
             exit function
          end if   
       End if
     end if
  
     'Set_Permition CreateDocObject EV т.к. перенесли в изменение статуса
      set Create_Doc_by_Type = CreateDocObject
end function

' Заполнение атрибутов с Акта в ЗнО
Sub SetAttrs(Obj,docBase)
  ThisScript.SysAdminModeOn
  If docBase Is Nothing Then Exit Sub
  AttrStr = "ATTR_KD_ZA_MAINDOC,ATTR_KD_ZA_TYPEDOC,ATTR_KD_ZA_SUMM"

  Set Form = ThisForm
  Set Table = Form.Controls("ATTR_CCR_ZA").ActiveX
  Set Row = Table.RowValue(Table.SelectedRow)
  Call AttrsSyncBetweenObjs(Row,Obj,AttrStr)
  
  Set oContr = docBase.Attributes("ATTR_CONTRACT").Object
  ' Тема
  If Obj.Attributes.Has("ATTR_KD_TOPIC") Then
    Obj.Attributes("ATTR_KD_TOPIC") = "Оплата по акту " & docBase.Description
  End If
  ' Автор
  If Obj.Attributes.Has("ATTR_KD_EXEC") Then
    Obj.Attributes("ATTR_KD_EXEC").User = ThisApplication.CurrentUser
  End if
  ' Подписант
  If Obj.Attributes.Has("ATTR_KD_SIGNER") Then
    Set uCur = oContr.Attributes("ATTR_CURATOR").User
    If Not uCur Is Nothing Then
      Set signer = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetChiefForUserByGroup",uCur,"GROUP_CCR_SIGNERS")
      Obj.Attributes("ATTR_KD_SIGNER").User = signer
    End If
  End If
  ' Контрагент
  If Obj.Attributes.Has("ATTR_KD_CPNAME") Then
    Obj.Attributes("ATTR_KD_CPNAME").Object = docBase.Attributes("ATTR_CONTRACTOR").Object
  End If
  ' Договор
  If Obj.Attributes.Has("ATTR_KD_AGREENUM") Then
    Obj.Attributes("ATTR_KD_AGREENUM").Object = docBase.Attributes("ATTR_CONTRACT").Object
  End If
  ' Проекты
  Set proj = docBase.Attributes("ATTR_PROJECT").Object
  If Not proj Is Nothing Then
    Set Table = Obj.Attributes("ATTR_KD_TLINKPROJ")
    Set row = Table.Rows.Create
    row.Attributes("ATTR_KD_LINKPROJ") = proj
    Set uGIP = proj.Attributes("ATTR_PROJECT_GIP").User
    row.Attributes("ATTR_KD_GIP") = uGIP
  End If
  ' Срок оплаты
  If Obj.Attributes.Has("ATTR_KD_ZA_DATEPAYMENT") Then
    Obj.Attributes("ATTR_KD_ZA_DATEPAYMENT") = ThisApplication.CurrentTime
  End if
  ' Связанные документы
  If Obj.Attributes.Has("ATTR_KD_T_LINKS") Then
    Set Table = Obj.Attributes("ATTR_KD_T_LINKS")
    Set row = Table.Rows.Create
    row.Attributes("ATTR_KD_LINKS_DOC").Object = docBase
    row.Attributes("ATTR_KD_LINKS_USER").User = ThisApplication.CurrentUser  
  End If
  
End Sub

' Копирование файлов из Акта в ЗнО
Sub CopyFiles(Obj,docBase)
 ThisApplication.AddNotify "CopyFiles - 1 " & Time
  ThisScript.SysAdminModeOn
  For Each file In docBase.Files
    If file.FileDefName <> "FILE_KD_EL_SCAN_DOC" And file.FileDefName <> "FILE_E-THE_ORIGINAL" Then
      Set fDef = file.FileDef
      NewFDefName = "FILE_KD_ANNEX"
      If Obj.ObjectDef.FileDefs.Has(NewFDefName) Then
      
      Set NewFile = Obj.Files.AddCopy (file, file.filename)
      NewFile.FileDef = ThisApplication.FileDefs(NewFDefName)
'        file.checkOut(file.WorkFileName)
'        Set NewFile = Obj.Files.Create(NewFDefName)
'        NewFile.CheckIn file.WorkFileName
      End If
    End If
  Next
  ThisScript.SysAdminModeOff
End Sub

Sub BTN_ZO_PLAN_OnClick()
  Call zo_plan(ThisObject)
End Sub

Sub zo_plan(Obj)
  ThisScript.SysAdminModeOn
  If Obj.Attributes.Has("ATTR_CCR_ZA") = False Then
    Obj.Attributes.Create("ATTR_CCR_ZA")
    Obj.Update
  End If
  Set Table = Obj.Attributes("ATTR_CCR_ZA")
  Set Rows = Table.Rows
  Set vForm = ThisApplication.InputForms("FORM_ZO_PLAN")

  If vForm.Show Then 
    Set NewRow = Rows.Create
    
    Call RowUpdate (vForm,NewRow)
  End If
End Sub

Sub RowUpdate (form,row)
  For each attr In row.Attributes
    If form.Attributes.Has(attr.AttributeDefName) Then 
      Select Case attr.AttributeDef.Type
        Case 8
          row.Attributes(attr.AttributeDefName).Classifier = form.Attributes(attr.AttributeDefName).Classifier
        Case 9
          row.Attributes(attr.AttributeDefName).User = form.Attributes(attr.AttributeDefName).User
        Case 7
          row.Attributes(attr.AttributeDefName).Object = form.Attributes(attr.AttributeDefName).Object
        Case Else
          row.Attributes(attr.AttributeDefName).Value = form.Attributes(attr.AttributeDefName).Value   
      End Select
    End If
  Next
End Sub

Sub ATTR_CCR_ZA_DblClick(nRow,nCol)
  Call CMD_EDIT_ZO(nRow,nCol)
End Sub

sub CMD_EDIT_ZO(nRow,nCol)
  ThisScript.SysAdminModeOn
  
  Set Table = ThisForm.Controls("ATTR_CCR_ZA").ActiveX
  Set Row = Table.RowValue(Table.SelectedRow)

  Set vForm = ThisApplication.InputForms("FORM_ZO_PLAN")
    vForm.Attributes("ATTR_KD_ZA_MAINDOC").Classifier = row.Attributes("ATTR_KD_ZA_MAINDOC").Classifier
    vForm.Attributes("ATTR_KD_ZA_TYPEDOC").Classifier = row.Attributes("ATTR_KD_ZA_TYPEDOC").Classifier
    vForm.Attributes("ATTR_KD_ZA_DATEPAYMENT") = row.Attributes("ATTR_KD_ZA_DATEPAYMENT").Value
    vForm.Attributes("ATTR_KD_ZA_SUMM").Value = row.Attributes("ATTR_KD_ZA_SUMM").Value
    vForm.Attributes("ATTR_DOC_REF").Object = row.Attributes("ATTR_DOC_REF").Object
    
   
  If vForm.Show Then 
    Call RowUpdate (vForm,row)
  End If
  ThisObject.Update
end sub

Sub BTN_ZO_PLAN_DEL_OnClick()
  Call ZoRowDel(ThisForm,ThisObject)
End Sub

Sub ZoRowDel(Form,Obj)
  ThisScript.SysAdminModeOn
  Set Table = Form.Controls("ATTR_CCR_ZA")
  Arr = Table.ActiveX.SelectedRows
  If UBound(Arr)+1 = 0 Then Exit Sub
  'Подтверждение удаления
  Key = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion + vbYesNo, 1607, UBound(Arr)+1)
  If Key = vbNo Then Exit Sub
  
  'Удаление строк
  For i = 0 to UBound(Arr)
    Set Row = Table.ActiveX.RowValue(Arr(i))
    Row.Erase
  Next
  Form.Refresh
End Sub

Sub ATTR_CCR_ZA_SelChanged()
  Call SetButtons(ThisForm,ThisObject)
End Sub


Sub SetButtons(Form,Obj)
  With Form.Controls
    .Item("BTN_ZO_CREATE").Enabled = BTN_ZO_CREATE_Check(Form,Obj)
    .Item("BTN_ZO_LINK").Enabled = BTN_ZO_CREATE_Check(Form,Obj)
  End With
End Sub

Function BTN_ZO_CREATE_Check(Form,Obj)
  BTN_ZO_CREATE_Check = False
  Set Table = Form.Controls("ATTR_CCR_ZA").ActiveX
  Arr = Table.SelectedRows
  If UBound(Arr)+1 = 0 Then Exit Function
  
  Set SelRow = Table.RowValue(Table.SelectedRow)
  Set ZO = SelRow.Attributes("ATTR_DOC_REF").Object
  If ZO Is Nothing Then
    BTN_ZO_CREATE_Check = True
  Else
    BTN_ZO_CREATE_Check = False
  End If
End Function

Sub BTN_ZO_LINK_OnClick()
  ThisScript.SysAdminModeOn
  Set Obj = ThisObject
  Set Form = ThisForm
  Set oContr = Obj.Attributes("ATTR_CONTRACT").Object
  If oContr Is Nothing Then Exit Sub
  
  Set q = ThisApplication.Queries("QUERY_CCR_ZO_NOT_LINKED")
  q.Parameter("PARAM0") = oContr
  If q.Objects.Count = 0 Then
    msgbox "Нет заявок на оплату, доступных для добавления",vbExclamation,"Добавить заявку на оплату"
    Exit Sub
  End If
  
  Set dlg = ThisApplication.Dialogs.SelectObjectDlg
  dlg.SelectFromObjects = q.Objects
  RetVal = dlg.Show
  If Not RetVal Or dlg.Objects.Count = 0 Then
    Exit Sub
  End If
  
  Set oZo = q.Objects(0)
  If oZo Is Nothing Then Exit Sub
  Set Table = Form.Controls("ATTR_CCR_ZA").ActiveX
  Set Row = Table.RowValue(Table.SelectedRow)
  If Not Row.Attributes("ATTR_DOC_REF").Object Is Nothing Then
    Set oldZo = Row.Attributes("ATTR_DOC_REF").Object
    If oldZo.Handle <> oZo.Handle Then
      ans = msgbox ("Выбранный платеж уже связан с заявкой на оплату " & oldZo.Description & _
            ". Вы хотите заменить ссылку на заявку " & oZo.Description  & "?",vbQuestion+vbYesNo,"Выбрать заявку на оплату")
       
      If ans <> vbYes Then Exit Sub
      Row.Attributes("ATTR_DOC_REF").Object = oZo
    End If
  Else
    Row.Attributes("ATTR_DOC_REF").Object = oZo
  End If
  Call SetButtons(Form,Obj)
End Sub
