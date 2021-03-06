' Форма ввода - Том
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

'USE "CMD_KD_COMMON_LIB"
USE "CMD_DLL_COMMON_BUTTON"
USE "CMD_S_DLL"
USE "CMD_SS_TRANSACTION"
USE "CMD_PROJECT_DOCS_LIBRARY"

USE "CMD_DLL"

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Call ThisApplication.ExecuteScript("CMD_DLL", "ShowBtnIcon",Form,Obj)
  Call SetControls(Form, Obj)
  Call SetLabels(Form, Obj)
  Call BtnTaskOpenChange(Form,Obj)
  'Доступность кнопок блока маршрутизации
  Call BlockRouteButtonLockedVol(Form,Obj)
End Sub

'Кнопка - Сгенерировать обозначение тома
Sub BUTTON_CODE_GEN_OnClick()
  ThisObject.Attributes("ATTR_VOLUME_CODE").Value = _
    ThisApplication.ExecuteScript("CMD_S_NUMBERING", "VolumeCodeGen",ThisObject)
  ThisObject.Attributes("ATTR_VOLUME_NUM").Value = _
    ThisApplication.ExecuteScript("CMD_S_NUMBERING", "VolumeNumCodeGen",ThisObject)
End Sub

'Кнопка - Сгенерировать наименование тома
Sub BUTTON_NAME_GEN_OnClick()
  val = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "VolumeNameGen",ThisObject)
  If val <> ThisObject.Attributes("ATTR_VOLUME_NAME").Value Then
    ThisObject.Attributes("ATTR_VOLUME_NAME").Value = val
  End If
End Sub


Sub SetControls(Form, Obj)
  Set CU = ThisApplication.CurrentUser
  isGrMem = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsGroupMember",CU,"GROUP_COMPL")
  'Доступность редактирования номера, наименования, обозначения
  Check = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "VolumeCodeCheck",Obj)
  chk1 = ThisApplication.ExecuteScript("CMD_DLL_ROLES","isGipOrDep",Obj,CU)
  
  With Form.Controls
    .Item("ATTR_VOLUME_NUM").ReadOnly = Check Or Obj.Attributes("ATTR_VOLUME_NUM").Empty = False
    .Item("ATTR_VOLUME_CODE").ReadOnly = Check Or Obj.Attributes("ATTR_VOLUME_CODE").Empty = False
    .Item("BUTTON_CODE_GEN").Enabled = Check
    '.Item("ATTR_VOLUME_NAME").ReadOnly = Check
    .Item("BUTTON_NAME_GEN").Enabled = Check
    .Item("ATTR_BOOK_NUM").Readonly = (Obj.Attributes("ATTR_VOLUME_PART_NUM").Empty = True)
    
    .Item("ATTR_BOOK_NAME").Readonly = (Obj.Attributes("ATTR_VOLUME_PART_NUM").Empty = True or _
                                        Obj.Attributes("ATTR_BOOK_NUM").Empty = True)
    .Item("BTN_VBN_TYPICAL").Enabled = not .Item("ATTR_BOOK_NAME").Readonly
                                        
    .Item("ATTR_VOLUME_PART_NUM").Readonly = (Obj.Attributes("ATTR_BOOK_NUM").Empty = False)
    
    
    .Item("ATTR_VOLUME_PART_NAME").Readonly = ((Obj.Attributes("ATTR_VOLUME_PART_NUM").Empty = True)) 'or _
                                              ' Obj.Attributes("ATTR_VOLUME_PART_NAME").Empty = False
    .Item("BTN_VPN_TYPICAL").Enabled = not .Item("ATTR_VOLUME_PART_NAME").Readonly
    
    
    .Item("BTN_READY_TO_ISSUE").Visible = ("STATUS_VOLUME_IS_APPROVED" = Obj.StatusName) _
                                            And (Not Obj.Attributes("ATTR_READY_TO_SEND").Value) _
                                            And isGrMem
    
    .Item("ATTR_NK_PERSON").ActiveX.ComboItems = ThisApplication.Groups("GROUP_NK").Users
    
    .Item("CMD_PROJECT_STAGE_SEL").Visible = chk1 And ThisApplication.ExecuteScript("CMD_SS_LIB", "EnableContractStageEdit", Obj)
    .Item("CMD_PROJECT_STAGE_SEL").Enabled = chk1 And ThisApplication.ExecuteScript("CMD_SS_LIB", "EnableContractStageEdit", Obj)
    .Item("CMD_PROJECT_STAGE_DEL").Visible = chk1 And (Obj.Attributes("ATTR_CONTRACT_STAGE").Empty = False) And .Item("CMD_PROJECT_STAGE_SEL").Enabled
    .Item("CMD_PROJECT_STAGE_DEL").Enabled = chk1 And (Obj.Attributes("ATTR_CONTRACT_STAGE").Empty = False) And .Item("CMD_PROJECT_STAGE_SEL").Enabled
    .Item("ATTR_RESPONSIBLE").ReadOnly = not chk1
    .Item("ATTR_S_DEPARTMENT").ReadOnly = not chk1
    
  End With
End Sub


Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
'ThisApplication.AddNotify "Form_AttributeChange" & Attribute.Description
  Select Case Attribute.AttributeDefName
    'Выполняется субподрядчиком
    Case "ATTR_SUBCONTRACTOR_WORK"
  
      If Obj.Attributes("ATTR_VOLUME_SECTION").Empty or Obj.Attributes("ATTR_VOLUME_NUM").Empty or _
      Obj.Attributes("ATTR_VOLUME_CODE").Empty or Obj.Attributes("ATTR_VOLUME_NAME").Empty Then
        Msgbox "Заполните обязательные поля!",vbExclamation
        Cancel = True
        Exit Sub
      End If
      Call ThisApplication.ExecuteScript("FORM_PROJECT_SECTION","OnSubContractorWorkChange",Obj, Attribute, Cancel)
    
    'Номер части
    Case "ATTR_VOLUME_PART_NUM"
      Obj.Attributes("ATTR_VOLUME_PART_NAME").Empty = (Attribute.Empty = True)
      Check = ThisApplication.ExecuteScript("OBJECT_VOLUME","CheckPartNum",Attribute.Value)
      If Check = False Then
        Msgbox "Некорректный номер части!",vbExclamation
        Cancel = True
        Exit Sub
      End If
      Call BUTTON_CODE_GEN_OnClick()
      Call BUTTON_NAME_GEN_OnClick()
      Call SetControls(Form, Obj)
      
    'Номер книги
    Case "ATTR_BOOK_NUM"
      Obj.Attributes("ATTR_BOOK_NAME").Empty = (Attribute.Empty = True)
      Check = ThisApplication.ExecuteScript("OBJECT_VOLUME","CheckBookNum",Attribute.Value)
      If Check = False Then
        Msgbox "Некорректный номер книги!",vbExclamation
        Cancel = True
        Exit Sub
      End If
      Call BUTTON_CODE_GEN_OnClick()
      Call BUTTON_NAME_GEN_OnClick()
      Call SetControls(Form, Obj)
      
    'Наименование части
    Case "ATTR_VOLUME_PART_NAME"
      Call BUTTON_NAME_GEN_OnClick()
      Call SetControls(Form, Obj)
      
    'Наименование книги
    Case "ATTR_BOOK_NAME"
      Call BUTTON_NAME_GEN_OnClick()
      Call SetControls(Form, Obj)
  
    ' Ответственный
    Case "ATTR_RESPONSIBLE"
      Call ThisApplication.ExecuteScript("CMD_DEVELOPER_APPOINT","SetDept",Obj,Attribute.User)
      Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","ChangeResponsible",Obj,Attribute.User,OldAttribute.User)
      
    ' Атрибут Отдел  
    Case "ATTR_S_DEPARTMENT"
      Call ThisApplication.ExecuteScript("CMD_DEVELOPER_APPOINT","DeptChange",Obj, Attribute, OldAttribute)
    ' Тип тома
    Case "ATTR_VOLUME_TYPE"
      Call BUTTON_NAME_GEN_OnClick()
  End Select
End Sub

Sub BTN_READY_TO_ISSUE_OnClick()
  If ThisApplication.ExecuteScript( _
    "CMD_TO_CHECK", "ReadyToIssue", ThisObject) Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

Sub BlockRouteButtonLockedVol(Form,Obj)
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  Set Roles = Obj.RolesForUser(CU)
  Set Dict = ThisApplication.Dictionary(Obj.Guid & " - BlockRoute")
  Dict.RemoveAll
  BtnList = "BTN_TO_APPROVAL,BTN_APPROVE,BTN_REJECT,BTN_CANCEL"
  Arr = Split(BtnList,",")
  
  'Скопировать документ
  If not Obj.Parent is Nothing Then
    If Obj.Parent.Permissions.EditContent = 1 Then Dict.Item("BTN_COPY") = True
  End If
  
  Select Case Obj.StatusName
    'Том в разработке
    Case "STATUS_VOLUME_IS_BUNDLING"
      Dict.Item("BTN_CANCEL") = True
      
    'Том прошел нормоконтроль
    Case "STATUS_VOLUME_IS_CHECKED_BY_NK"
      Dict.Item("BTN_CANCEL") = True
      If Roles.Has("ROLE_VOLUME_COMPOSER") Then
        Dict.Item("BTN_TO_APPROVAL") = True
      End If
      
    'Том на утверждении
    Case "STATUS_VOLUME_IS_APPROVING"
      Dict.Item("BTN_REJECT") = True
      Dict.Item("BTN_CANCEL") = True
      If Roles.Has("ROLE_GIP") Then
        Dict.Item("BTN_APPROVE") = True
      End If
      
    'Том утвержден
    Case "STATUS_VOLUME_IS_APPROVED"
      Dict.Item("BTN_CANCEL") = True
      
      If Check_CMD_DOC_DEV_CHANGE(Obj) Then
        Dict.Item("BTN_REJECT") = True
      End If
      
    'Том аннулирован
    Case "STATUS_S_INVALIDATED"
      
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

Sub BTN_VPN_TYPICAL_OnClick()
  Call SetTypicalText(ThisObject,"ATTR_VOLUME_PART_NAME")
End Sub

Sub BTN_VBN_TYPICAL_OnClick()
  Call SetTypicalText(ThisObject,"ATTR_BOOK_NAME")
End Sub

Sub SetTypicalText(Obj,aDefName)
  Set txtRoot = ThisApplication.Classifiers("NODE_TYPICAL_NAME")
  if txtRoot is Nothing then exit sub
  set cForSelect=txtRoot.Classifiers
  if cForSelect.count=0 then exit sub
  
  Sel = ThisApplication.ExecuteScript("CMD_DIALOGS","SelectDialog","NODE",Obj,"NODE_TYPICAL_NAME")
  
  Selected = Split(Sel,",")
  If Selected(0) = " " Then Exit Sub
  
  val = ThisApplication.Classifiers.FindBySysId(Selected(0)).Description
  If Obj.Attributes(aDefName).Value <> val Then
    ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", Obj, aDefName, val, True
  End If
End Sub

Sub ATTR_VOLUME_PART_NAME_BeforeAutoComplete(Text)
  If len(text) > 0 Then
    Set txtRoot = ThisApplication.Classifiers("NODE_TYPICAL_NAME")
      if txtRoot is Nothing then exit sub
      Set result = txtRoot.Classifiers
    ThisForm.Controls("ATTR_VOLUME_PART_NAME").ActiveX.ComboItems = result
  End If
End Sub

Sub ATTR_BOOK_NAME_BeforeAutoComplete(Text)
  If len(text) > 0 Then
    Set txtRoot = ThisApplication.Classifiers("NODE_TYPICAL_NAME")
      if txtRoot is Nothing then exit sub
      Set result = txtRoot.Classifiers
    ThisForm.Controls("ATTR_BOOK_NAME").ActiveX.ComboItems = result
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