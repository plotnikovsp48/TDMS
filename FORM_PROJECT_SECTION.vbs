USE "CMD_S_DLL"
USE "CMD_SS_TRANSACTION"
USE "CMD_SS_SYSADMINMODE"
USE "CMD_DLL_COMMON_BUTTON"

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Call SetLabels(Form, Obj)
  Call BtnTaskOpenChange(Form,Obj)
  Call SetControls(Form,Obj)
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  Select Case Attribute.AttributeDefName
    Case "ATTR_SECTION_NUM","ATTR_CODE"
      Call Set_ATTR_SECTION_CODE(Obj)
    Case "ATTR_PROJECT_DOCS_SECTION"
      OnProjectDocsSectionChange Obj
    Case "ATTR_CONTRACT_STAGE"
      OnContractStageChange Obj, Attribute
      Call Set_ATTR_SECTION_CODE(Obj)

    'Выполняется субподрядчиком
    Case "ATTR_SUBCONTRACTOR_WORK"
      OnSubContractorWorkChange Obj, Attribute, Cancel

    ' Атрибут Ответственный
    Case "ATTR_RESPONSIBLE"
      Call ThisApplication.ExecuteScript("CMD_DEVELOPER_APPOINT","SetDept",Obj,Attribute.User)
      Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","ChangeResponsible",Obj,Attribute.User,OldAttribute.User)
    ' Атрибут Отдел  
    Case "ATTR_S_DEPARTMENT"
      Call ThisApplication.ExecuteScript("CMD_DEVELOPER_APPOINT","DeptChange",Obj, Attribute, OldAttribute)
  End Select
End Sub

Sub SetControls(Form,Obj)
  Set CU = ThisApplication.CurrentUser
'Доступность редактирования обозначения
  Check = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "ProjectSectionCodeGenCheck",Obj)
  chk1 = ThisApplication.ExecuteScript("CMD_DLL_ROLES","isGipOrDep",Obj,CU) 
  With Form.Controls
    .Item("ATTR_CODE").ReadOnly = Obj.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier.Description <> "Непроектный раздел"'(Not Obj.Attributes("ATTR_CODE").Empty) or (Obj.Attributes("ATTR_CODE") = "-")
    .Item("ATTR_SECTION_NUM").ReadOnly = Obj.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier.Description <> "Непроектный раздел" And (Not Obj.Attributes("ATTR_SECTION_NUM").Empty)
    .Item("ATTR_SECTION_CODE").ReadOnly = Not Check
    .Item("BUTTON_CODE_GEN").Enabled = Check
    .Item("CMD_PROJECT_STAGE_SEL").Enabled = chk1 And ThisApplication.ExecuteScript("CMD_SS_LIB", "EnableContractStageEdit", Obj)
    .Item("CMD_PROJECT_STAGE_DEL").Enabled = chk1 And (Obj.Attributes("ATTR_CONTRACT_STAGE").Empty = False) And .Item("CMD_PROJECT_STAGE_SEL").Enabled
    
      
    If .Item("ATTR_SECTION_CODE").Value = "-" Then
      .Item("ATTR_PROJECT_DOCS_SECTION").Readonly = True
    End If
    .Item("ATTR_PROJECT_DOCS_SECTION").Tooltip = .Item("ATTR_PROJECT_DOCS_SECTION").Value
'    .Item("CMD_PROJECT_STAGE_SEL").Enabled = _
'      ThisApplication.ExecuteScript("CMD_SS_LIB", "EnableContractStageEdit", Obj)
'    .Item("CMD_PROJECT_STAGE_DEL").Enabled = _
'      .Item("CMD_PROJECT_STAGE_SEL").Enabled

    .Item("ATTR_RESPONSIBLE").ReadOnly = not chk1
    .Item("ATTR_S_DEPARTMENT").ReadOnly = not chk1
    
    .Item("ATTR_NAME").ReadOnly = not chk1
    .Item("ATTR_SECTION_CODE").ReadOnly = not chk1

  End With  
End Sub

' Кнопка - Выбрать этап
Sub CMD_PROJECT_STAGE_SEL_OnClick()
  Dim stage, t
  Set stage = PickContractStage(ThisObject)
  If stage Is Nothing Then Exit Sub
  
  Set t = New Transaction
  ThisObject.Attributes("ATTR_CONTRACT_STAGE").Object = stage
  Call Set_ATTR_SECTION_CODE(ThisObject)
  SetAttrToContentAll ThisObject, "ATTR_CONTRACT_STAGE", stage
  t.Commit
End Sub

' Удалить этап
Sub CMD_PROJECT_STAGE_DEL_OnClick()
  Dim t
  Set t = New Transaction
  ThisObject.Attributes("ATTR_CONTRACT_STAGE").Empty = True
  Call Set_ATTR_SECTION_CODE(ThisObject)
  SetAttrToContentAll ThisObject, "ATTR_CONTRACT_STAGE", Nothing
  t.Commit
End Sub

'Кнопка - Сгенерировать шифр
Sub BUTTON_CODE_GEN_OnClick()
  Call Set_ATTR_SECTION_CODE(ThisObject)
End Sub

Sub OnProjectDocsSectionChange(Obj)
  Dim att
  Set att = Obj.Attributes
  If Not att.Has("ATTR_SECTION_CODE") Then Exit Sub
  att("ATTR_SECTION_CODE").Value = _
    ThisApplication.ExecuteScript("CMD_S_NUMBERING", "GetObjNumber", Obj)
End Sub

Sub OnContractStageChange(Obj, Attribute)

  If vbNo = ThisApplication.ExecuteScript(_
    "CMD_MESSAGE", "ShowWarning", vbQuestion+VbYesNo, _
    1702, Attribute.Object.Description, Obj.Description) Then Exit Sub
      
  ' wrap in transaction
  Dim tr
  Set tr = New Transaction
  Obj.Update
  SetAttrToContentAll Obj, "ATTR_CONTRACT_STAGE", Attribute.Object
  tr.Commit
End Sub

Sub OnSubContractorWorkChange(Obj, Attribute, Cancel)

  Dim tr, sam
  If Attribute.Value Then
    If vbYes = MsgBox( _
      "Хотите заполнить данные по субподрядчику ?", vbQuestion + vbYesNo) Then
      Obj.Dictionary.Item("FormActive") = True
    End If
    Obj.Update

    Set tr = New Transaction
    Set sam = New SysAdminMode
    ThisApplication.ExecuteScript "CMD_SS_LIB", "PropagateAttribute", _
      Obj.ContentAll, Attribute
    tr.Commit
    Exit Sub
  End If
  
  If vbNo = MsgBox("Это действие приведет к потере данных," &_
    " указанных на вкладке Субподрядчик. Продолжить?", _
    vbQuestion + vbYesNo) Then Cancel = True: Exit Sub
  
  Dim list
  list = "ATTR_SUBCONTRACTOR_CLS;ATTR_CONTRACT_SUBCONTRACTOR;ATTR_TENDER_OUT_REQUIRED;ATTR_SUBCONTRACTOR_DOC_CODE;" & _
    "ATTR_SUBCONTRACTOR_DOC_NAME;ATTR_SUBCONTRACTOR_DOC_INF"
  Set tr = New Transaction
  Set sam = New SysAdminMode
  ThisApplication.ExecuteScript "CMD_SS_LIB", "ClearAttributes", Obj, list
  ThisApplication.ExecuteScript "CMD_SS_LIB", "ClearAttributes", Obj.ContentAll, list
  tr.Commit
End Sub

Sub Set_ATTR_SECTION_CODE(Obj)
  Val = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "ProjectSectionCodeGen",Obj)
  If Obj.Attributes("ATTR_SECTION_CODE").Value <> Val Then
    Obj.Attributes("ATTR_SECTION_CODE").Value = Val
  End If
End Sub



'Sub ATTR_RESPONSIBLE_BeforeAutoComplete(Text)
'  If len(Text) > 0 then
'    Set source = ThisApplication.ExecuteScript("CMD_DEVELOPER_APPOINT","GetUserSource",ThisObject)
'    If Not source Is Nothing Then
'      ThisForm.Controls("ATTR_RESPONSIBLE").ActiveX.ComboItems = source
'    End If
'  End If
'End Sub
