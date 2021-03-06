USE "CMD_S_DLL"
USE "CMD_SS_TRANSACTION"
USE "CMD_SS_SYSADMINMODE"
USE "CMD_DLL_COMMON_BUTTON"

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Call BtnTaskOpenChange(Form,Obj)
  
  Dim disableSubContractor
  disableSubContractor = False
  If Not Obj.Parent Is Nothing Then
    Dim att
    Set att = Obj.Parent.Attributes
    If att.Has("ATTR_SUBCONTRACTOR_WORK") Then
      disableSubContractor = att("ATTR_SUBCONTRACTOR_WORK").Value
    End If
  End If
  Call SetControls(Form,Obj)
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)

  Select Case Attribute.AttributeDefName
    Case "ATTR_PROJECT_DOCS_SECTION"
      OnProjectDocsSectionChanged Obj
    
    'Выполняется субподрядчиком  
    Case "ATTR_SUBCONTRACTOR_WORK"
      ThisApplication.ExecuteScript "FORM_PROJECT_SECTION","OnSubContractorWorkChange", Obj, Attribute, Cancel
      
    ' Ответственный
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
    .Item("CMD_PROJECT_STAGE_SEL").Enabled = chk1 And ThisApplication.ExecuteScript("CMD_SS_LIB", "EnableContractStageEdit", Obj)
    .Item("CMD_PROJECT_STAGE_DEL").Enabled = chk1 And (Obj.Attributes("ATTR_CONTRACT_STAGE").Empty = False) And .Item("CMD_PROJECT_STAGE_SEL").Enabled
    .Item("ATTR_RESPONSIBLE").ReadOnly = not chk1
    .Item("ATTR_S_DEPARTMENT").ReadOnly = not chk1

'    .Item("CMD_PROJECT_STAGE_SEL").Enabled = _
'      ThisApplication.ExecuteScript("CMD_SS_LIB", "EnableContractStageEdit", Obj)
'    .Item("CMD_PROJECT_STAGE_DEL").Enabled = _
'      .Item("CMD_PROJECT_STAGE_SEL").Enabled
    .Item("ATTR_SUBCONTRACTOR_WORK").Enabled = Not disableSubContractor
  End With
  
  
'  With Form.Controls
'    .Item("ATTR_CODE").ReadOnly = Obj.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier.Description <> "Непроектный раздел"'(Not Obj.Attributes("ATTR_CODE").Empty) or (Obj.Attributes("ATTR_CODE") = "-")
'    .Item("ATTR_SECTION_NUM").ReadOnly = Obj.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier.Description <> "Непроектный раздел" And (Not Obj.Attributes("ATTR_SECTION_NUM").Empty)
'    .Item("ATTR_SECTION_CODE").ReadOnly = Not Check
'    .Item("BUTTON_CODE_GEN").Enabled = Check
'    .Item("CMD_PROJECT_STAGE_SEL").Enabled = chk1 And ThisApplication.ExecuteScript("CMD_SS_LIB", "EnableContractStageEdit", Obj)
'    .Item("CMD_PROJECT_STAGE_DEL").Enabled = chk1 And (Obj.Attributes("ATTR_CONTRACT_STAGE").Empty = False) And .Item("CMD_PROJECT_STAGE_SEL").Enabled
'    
'      
'    If .Item("ATTR_SECTION_CODE").Value = "-" Then
'      .Item("ATTR_PROJECT_DOCS_SECTION").Readonly = True
'    End If
'    .Item("ATTR_PROJECT_DOCS_SECTION").Tooltip = .Item("ATTR_PROJECT_DOCS_SECTION").Value
''    .Item("CMD_PROJECT_STAGE_SEL").Enabled = _
''      ThisApplication.ExecuteScript("CMD_SS_LIB", "EnableContractStageEdit", Obj)
''    .Item("CMD_PROJECT_STAGE_DEL").Enabled = _
''      .Item("CMD_PROJECT_STAGE_SEL").Enabled

'    .Item("ATTR_RESPONSIBLE").ReadOnly = not chk1
'    .Item("ATTR_S_DEPARTMENT").ReadOnly = not chk1
'    
'    .Item("ATTR_NAME").ReadOnly = not chk1
'    .Item("ATTR_SECTION_CODE").ReadOnly = not chk1

'  End With  
End Sub


' Кнопка - Выбрать этап
Sub CMD_PROJECT_STAGE_SEL_OnClick()
  Dim stage, t
  Set stage = PickContractStage(ThisObject)
  If stage Is Nothing Then Exit Sub
  
  Set t = New Transaction
  Set ThisObject.Attributes("ATTR_CONTRACT_STAGE").Object = stage
  SetAttrToContentAll ThisObject, "ATTR_CONTRACT_STAGE", stage
  t.Commit
End Sub

' Удалить этап
Sub CMD_PROJECT_STAGE_DEL_OnClick()
  Dim t
  Set t = New Transaction
  ThisObject.Attributes("ATTR_CONTRACT_STAGE").Empty = True
  SetAttrToContentAll ThisObject, "ATTR_CONTRACT_STAGE", Nothing
  t.Commit
End Sub

Private Sub OnProjectDocsSectionChanged(Obj)

  Dim att, def
  Set att = Obj.Attributes
  def = "ATTR_SECTION_CODE"
  If Not att.Has(def) Then Exit Sub
  att(def) = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "GetObjNumber", Obj)
End Sub

Private Sub OnSubcontractorChanged(Obj, Attribute, Cancel)

  Dim tr, list, sam
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
  
  list = "ATTR_SUBCONTRACTOR_CLS;ATTR_CONTRACT_SUBCONTRACTOR;ATTR_SUBCONTRACTOR_DOC_CODE;" & _
    "ATTR_SUBCONTRACTOR_DOC_NAME;ATTR_SUBCONTRACTOR_DOC_INF"
  Set tr = New Transaction
  Set sam = New SysAdminMode
  ThisApplication.ExecuteScript "CMD_SS_LIB", "ClearAttributes", Obj, list
  ThisApplication.ExecuteScript "CMD_SS_LIB", "ClearAttributes", Obj.ContentAll, list
  tr.Commit
End Sub

Sub BUTTON_CODE_GEN_OnClick()
  Call Set_ATTR_SECTION_CODE(ThisObject)
End Sub

Sub Set_ATTR_SECTION_CODE(Obj)
  Val = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "ProjectSectionCodeGen",Obj)
  If Obj.Attributes("ATTR_SECTION_CODE").Value <> Val Then
    Obj.Attributes("ATTR_SECTION_CODE").Value = Val
  End If
End Sub

