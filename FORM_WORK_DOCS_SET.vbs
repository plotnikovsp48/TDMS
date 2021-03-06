'USE "CMD_KD_COMMON_LIB"
USE "CMD_DLL_COMMON_BUTTON"
USE "CMD_S_DLL"
USE "CMD_SS_TRANSACTION"
USE "CMD_PROJECT_DOCS_LIBRARY"

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description

  Call SetLabels(Form, Obj)
  Call SetControls(Form,Obj)
  Call SetButtons(Form,Obj)
  Call BtnTaskOpenChange(Form,Obj)
  'Доступность кнопок блока маршрутизации
  Call BlockRouteButtonLockedWSet(Form,Obj)
End Sub

' Кнопка - Выбрать этап
Sub CMD_PROJECT_STAGE_SEL_OnClick()
  Dim stage, t
  Set stage = PickBuildingStage(ThisObject)
  If stage Is Nothing Then Exit Sub
  
  Set t = New Transaction
  ThisObject.Attributes("ATTR_BUILDING_STAGE").Object = stage
  SetAttrToContentAll ThisObject, "ATTR_BUILDING_STAGE", stage
  t.Commit
End Sub

' Удалить этап
Sub CMD_PROJECT_STAGE_DEL_OnClick()
  Dim t
  Set t = New Transaction
  ThisObject.Attributes("ATTR_BUILDING_STAGE").Empty = True
  SetAttrToContentAll ThisObject, "ATTR_BUILDING_STAGE", Nothing
  t.Commit
End Sub

'Кнопка - Сгенерировать шифр
Sub BUTTON_CODE_GEN_OnClick()
  Val = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "WorkDocsSetCodeGen",ThisObject)
  If ThisObject.Attributes("ATTR_WORK_DOCS_SET_CODE").Value <> Val Then
    ThisObject.Attributes("ATTR_WORK_DOCS_SET_CODE").Value = Val
  End If
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
'  ThisApplication.AddNotify "Form_AttributeChange" & Attribute.Description
  Set CU = ThisApplication.CurrentUser
  Select Case Attribute.AttributeDefName
    ' Марка
    Case "ATTR_WORK_DOCS_SET_MARK"
      Obj.Attributes("ATTR_WORK_DOCS_SET_NUMBER").Empty = True
      If Obj.Attributes("ATTR_WORK_DOCS_SET_NAME").Empty = True Then
         Obj.Attributes("ATTR_WORK_DOCS_SET_NAME") = Attribute.Value
      Else
          '  Подтверждение замены наименования
          result = ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbQuestion+VbYesNo, 1032,Attribute.Value)
          If result = vbYes Then
            Obj.Attributes("ATTR_WORK_DOCS_SET_NAME") = Attribute.Value
          End If 
      End If
      Call BUTTON_CODE_GEN_OnClick()
      
    ' Номер комплекта
    Case "ATTR_WORK_DOCS_SET_NUMBER"
'      Call BUTTON_CODE_GEN_OnClick()
      'Обозначение Полного комплекта
      If not Obj.Parent is Nothing Then
        Code = Obj.Parent.Attributes("ATTR_PROJECT_BASIC_CODE").Value
      End If
      'Код марки Основного комплекта по классификатору
      If Obj.Attributes("ATTR_WORK_DOCS_SET_MARK").Empty = False Then
        Num = Obj.Attributes("ATTR_WORK_DOCS_SET_MARK").Classifier.Code
        If Num <> "" Then
          If Code <> "" Then
            Code = Code & "-" & Num
          Else
            Code = Num
          End If
        End If
      End If
      Num = cStr(Attribute.Value)
      If Num = "0" Then Num = ""
      Code = Code & Num
      Set Query = ThisApplication.Queries("QUERY_WORKDOCSET_SEARCH_ON_CODE")
      Query.Parameter("PROJECT") = Obj.Attributes("ATTR_PROJECT").Object
      Query.Parameter("NOTOBJ") = "<> '" & Obj.Description & "'"
      Query.Parameter("CODE2") = Code
      Set Objects = Query.Objects
      If Objects.Count = 0 Then
        If Obj.Attributes("ATTR_WORK_DOCS_SET_CODE").Value <> Code Then
          Obj.Attributes("ATTR_WORK_DOCS_SET_CODE").Value = Code
        End If
      Else
        Msgbox "Комплект с таким шифром уже существует!", vbExclamation
        Cancel = True
        Exit Sub
      End If
        
    'Выполняется субподрядчиком
    Case "ATTR_SUBCONTRACTOR_WORK"
      If Obj.Attributes("ATTR_WORK_DOCS_SET_CODE").Empty or Obj.Attributes("ATTR_WORK_DOCS_SET_MARK").Empty or _
      Obj.Attributes("ATTR_WORK_DOCS_SET_NAME").Empty Then
        Msgbox "Заполните обязательные поля!",vbExclamation
        Cancel = True
        Exit Sub
      End If
      Call ThisApplication.ExecuteScript("FORM_PROJECT_SECTION","OnSubContractorWorkChange",Obj, Attribute, Cancel)

    ' Атрибут Ответственный
    Case "ATTR_RESPONSIBLE"
      Call ThisApplication.ExecuteScript("CMD_DEVELOPER_APPOINT","SetDept",Obj,Attribute.User)
      Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","ChangeResponsible",Obj,Attribute.User,OldAttribute.User)

    ' Атрибут Отдел
    Case "ATTR_S_DEPARTMENT"
      Call ThisApplication.ExecuteScript("CMD_DEVELOPER_APPOINT","DeptChange",Obj, Attribute, OldAttribute)
  End Select
End Sub

Sub BTN_APPROVE_OnClick()
  ThisObject.Permissions = SysAdminPermissions 
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_VOLUME_APPROVE", "Main", ThisObject)
  If Res = True Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub
Sub BTN_TO_APPROVAL_OnClick()
  ThisObject.Permissions = SysAdminPermissions 
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_SEND_TO_APPROVE", "Main", ThisObject)
  If Res = True Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub
Sub BTN_REJECT_OnClick()
  ThisObject.Permissions = SysAdminPermissions 
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_WORK_DOCS_SET_BACK_TO_COR", "Main", ThisObject)
  If Res = True Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub
Sub BTN_CANCEL_OnClick()
  ThisObject.Permissions = SysAdminPermissions 
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_PROJECT_STRUCTURE_INVALIDATED", "Main", ThisObject)
  If Res = True Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

'Блок маршрутизации - Процедура управления доступностью кнопок
Sub BlockRouteButtonLockedWSet(Form,Obj)
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  Set Roles = Obj.RolesForUser(CU)
  Set Dict = ThisApplication.Dictionary(Obj.Guid & " - BlockRoute")
  Dict.RemoveAll
  BtnList = "BTN_TO_APPROVAL,BTN_APPROVE,BTN_REJECT,BTN_CANCEL,CMD_TASK_OPEN"
  Arr = Split(BtnList,",")
  
  'Скопировать документ
  If not Obj.Parent is Nothing Then
    If Obj.Parent.Permissions.EditContent = 1 Then Dict.Item("BTN_COPY") = True
  End If
  
  Select Case Obj.StatusName
    'Комплект в разработке
    Case "STATUS_WORK_DOCS_SET_IS_DEVELOPING"
      Dict.Item("BTN_CANCEL") = True
      Dict.Item("CMD_TASK_OPEN") = True
      
'      If Roles.Has("ROLE_LEAD_DEVELOPER") Then
'        Dict.Item("BTN_TO_APPROVAL") = True
'      End If
      
    'Комплект прошел нормоконтроль
    Case "STATUS_WORK_DOCS_SET_IS_CHECKED_BY_NK"
      Dict.Item("BTN_CANCEL") = True
      Dict.Item("CMD_TASK_OPEN") = True
      If Roles.Has("ROLE_LEAD_DEVELOPER") Then
        Dict.Item("BTN_TO_APPROVAL") = True
      End If
      
    'Комплект на утверждении
    Case "STATUS_WORK_DOCS_SET_IS_APPROVING"
      Dict.Item("BTN_REJECT") = True
      Dict.Item("BTN_CANCEL") = True
      Dict.Item("CMD_TASK_OPEN") = True
      If Roles.Has("ROLE_GIP") Then
        Dict.Item("BTN_APPROVE") = True
      End If
      
    'Комплект утвержден
    Case "STATUS_WORK_DOCS_SET_IS_APPROVED"
      Dict.Item("BTN_CANCEL") = True
      Dict.Item("CMD_TASK_OPEN") = True
      If Check_CMD_DOC_DEV_CHANGE(Obj) Then
        Dict.Item("BTN_REJECT") = True
      End If
      
'      If Roles.Has("ROLE_INITIATOR") Then
'        Dict.Item("BTN_TO_AGREE") = True
'      End If
      
    'Документ аннулирован
    Case "STATUS_DOCUMENT_INVALIDATED"
      Dict.Item("CMD_TASK_OPEN") = True
      
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
      Form.Controls(BtnName).Visible = Check
      Form.Controls(BtnName).Enabled = Check
    End If
  Next
End Sub

Sub BTN_READY_TO_ISSUE_OnClick()
  If ThisApplication.ExecuteScript( _
    "CMD_TO_CHECK", "ReadyToIssue", ThisObject) Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

Sub SetControls(Form,Obj)
  Set CU = ThisApplication.CurrentUser
'Доступность редактирования обозначения
'  Check = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "ProjectSectionCodeGenCheck",Obj)
  chk1 = ThisApplication.ExecuteScript("CMD_DLL_ROLES","isGipOrDep",Obj,CU)
  With Form.Controls
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

    .Item("ATTR_RESPONSIBLE").ReadOnly = not chk1
    .Item("ATTR_S_DEPARTMENT").ReadOnly = not chk1
    
'    .Item("ATTR_NAME").ReadOnly = not chk1
'    .Item("ATTR_SECTION_CODE").ReadOnly = not chk1

    .Item("ATTR_NK_PERSON").ActiveX.ComboItems = ThisApplication.Groups("GROUP_NK").Users
  End With  
End Sub

Sub SetButtons(Form,Obj)
  Set CU = ThisApplication.CurrentUser
  isGrMem = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsGroupMember",CU,"GROUP_COMPL")
  'Доступность редактирования обозначения
  Check = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "WorkDocsSetCodeGenCheck",Obj)
  Call ThisApplication.ExecuteScript("CMD_DLL", "ShowBtnIcon",Form,Obj)
  With Form.Controls
    .Item("ATTR_WORK_DOCS_SET_CODE").ReadOnly = not Check
    .Item("BUTTON_CODE_GEN").Enabled = Check
    .Item("CMD_PROJECT_STAGE_SEL").Enabled = _
      ThisApplication.ExecuteScript("CMD_SS_LIB", "EnableContractStageEdit", Obj)
    .Item("CMD_PROJECT_STAGE_DEL").Enabled = _
      .Item("CMD_PROJECT_STAGE_SEL").Enabled
    .Item("BTN_READY_TO_ISSUE").Visible = ("STATUS_WORK_DOCS_SET_IS_APPROVED" = Obj.StatusName) _
                                            And (Not Obj.Attributes("ATTR_READY_TO_SEND").Value) _
                                            And isGrMem
  End With
End Sub
