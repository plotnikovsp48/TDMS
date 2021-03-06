USE "CMD_DLL_COMMON_BUTTON"
USE "CMD_S_DLL"
USE CMD_SS_TRANSACTION

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Call ThisApplication.ExecuteScript("CMD_DLL", "ShowBtnIcon",Form,Obj)
  Call SetControls(Form,Obj)
End Sub

'Событие - Изменение атрибута
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  Dim oNum
  Select Case Attribute.AttributeDefName
    'Титульный номер
    Case "ATTR_BUILDING_CODE"
      aDefName = "ATTR_PROJECT_BASIC_CODE"
      oNum = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "WorkDocsBuildCodeGen",ThisObject)
      
      If ThisApplication.ExecuteScript("CMD_S_DLL", "IsObjectByAttrExist",Obj,aDefName,oNum) Then 
        ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1202,Obj.ObjectDef.Description,oNum
        Cancel = True
        Exit Sub
      Else
        Call BUTTON_CODE_GEN_OnClick()
      End If
      
    Case "ATTR_BUILDING_TYPE"  
      aDefName = "ATTR_PROJECT_BASIC_CODE"
      oNum = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "WorkDocsBuildCodeGen",ThisObject)
      
      If ThisApplication.ExecuteScript("CMD_S_DLL", "IsObjectByAttrExist",Obj,aDefName,oNum) Then 
        ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1202,Obj.ObjectDef.Description,oNum
        Cancel = True
        Exit Sub
      Else
        Call BUTTON_CODE_GEN_OnClick()
      End If
      
      If Attribute.Empty = False Then
        Obj.Attributes("ATTR_WORK_DOCS_FOR_BUILDING_NAME") = Attribute.Value
      End If
      
    Case "ATTR_BUILDING_STAGE"
      aDefName = "ATTR_PROJECT_BASIC_CODE"
      oNum = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "WorkDocsBuildCodeGen",ThisObject)
      
      If IsObjectByAttrExist(Obj, aDefName, oNum) Then 
        ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1202,Obj.ObjectDef.Description,oNum
        Cancel = True
        Exit Sub
      Else
        Call BUTTON_CODE_GEN_OnClick()
      End If
      
      ' Наследование этапа
      ' this code is never executed since attribute value is changed by btn press
      If vbNo = ThisApplication.ExecuteScript(_ 
        "CMD_MESSAGE", "ShowWarning", vbQuestion+VbYesNo, _
        1702, Attribute.Object.Description, Obj.Description) Then Exit Sub
        
      ' wrap in transaction
      Dim t
      Set t = New Transaction
      Obj.Update
      SetAttrToContentAll Obj, "ATTR_BUILDING_STAGE", Attribute.Object
      t.Commit
  End Select
End Sub

'Кнопка - Сформировать обозначение
Sub BUTTON_CODE_GEN_OnClick()
  ThisObject.Attributes("ATTR_PROJECT_BASIC_CODE").Value = _
    ThisApplication.ExecuteScript("CMD_S_NUMBERING", "WorkDocsBuildCodeGen",ThisObject)
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
  Call BUTTON_CODE_GEN_OnClick()
End Sub

' Удалить этап
Sub CMD_PROJECT_STAGE_DEL_OnClick()
  Dim t
  Set t = New Transaction
  ThisObject.Attributes("ATTR_BUILDING_STAGE").Empty = True
  SetAttrToContentAll ThisObject, "ATTR_BUILDING_STAGE", Nothing
  t.Commit
End Sub

Sub SetControls(Form,Obj)
  Set CU = ThisApplication.CurrentUser
  isGip = ThisApplication.ExecuteScript("CMD_DLL_ROLES","isGipOrDep",Obj,CU)

  List = "ATTR_PROJECT_BASIC_CODE,ATTR_BUILDING_CODE,ATTR_WORK_DOCS_FOR_BUILDING_NAME," & _
        "ATTR_INF,ATTR_BUILDING_TYPE,ATTR_WORK_DOCS_FOR_BUILDING_TYPE"
  arr = Split(List,",")
  check1 = CheckObj
  check2 = CheckObj2(Obj)
  With Form.Controls

    For i = 0 to Ubound(arr)
      .Item(arr(i)).Readonly = ((not isGip) And (not check1)) Or (Not check2)
    Next

    .Item("BUTTON_CODE_GEN").Enabled = CheckObj And check2
    .Item("CMD_PROJECT_STAGE_SEL").Enabled = _
      ThisApplication.ExecuteScript("CMD_SS_LIB", "EnableContractStageEdit", Obj) And CheckObj And check2
    .Item("CMD_PROJECT_STAGE_DEL").Enabled = _
      .Item("CMD_PROJECT_STAGE_SEL").Enabled 
  End With
End Sub

'Функция проверки доступности формирования обозначения
Function CheckObj()
  CheckObj = True
  'Статус
  If ThisObject.StatusName = "STATUS_WORK_DOCS_FOR_BUILDING_IS_DEVELOPING" Then
    'True
  Else
    CheckObj = False
    Exit Function
  End If
  'Роль
  Set Roles = ThisObject.RolesForUser(ThisApplication.CurrentUser)
  If Roles.Has("ROLE_GIP") = False and _
     Roles.Has("ROLE_GIP_DEP") = False and _
     Roles.Has("ROLE_LEAD_DEVELOPER") = False and _
     Roles.Has("ROLE_PROJECT_STRUCTURE_EDIT") = False And _
     Roles.Has("ROLE_PART_RESP") = False Then
    CheckObj = False
  End If
End Function

Function checkObj2(Obj)
  checkObj2 = False
  If Obj Is Nothing Then exit Function
  
  Set Stage = GetStage(Obj)
  If Not Stage Is Nothing Then
    If Stage.StatusName = "STATUS_STAGE_DRAFT" Or Stage.StatusName = "STATUS_STAGE_EDIT" Then
      checkobj2 = True  
    End If
  End If
End Function

Sub BTN_CMD_VOK_DOC_OnClick()
  ThisApplication.ExecuteCommand "CMD_VOK_DOC",ThisObject
End Sub
