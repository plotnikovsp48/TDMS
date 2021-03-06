USE "CMD_S_DLL"
USE "CMD_SS_TRANSACTION"
USE "CMD_DLL_COMMON_BUTTON"

Sub Form_BeforeShow(Form, Obj)
  Call SetLabels(Form, Obj)
  form.Caption = form.Description
  Call SetButtonsEnabled(Form, Obj)
'  Call Set_ATTR_LAND_USE_CATEGORY(Form,Obj)
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  Select Case Attribute.AttributeDefName
    Case "ATTR_UNIT_TYPE"  
      If Not Obj.Attributes.Has("ATTR_UNIT_NAME") Then Exit Sub
      name = Obj.Attributes("ATTR_UNIT_TYPE").Classifier.Description
      If Obj.Attributes("ATTR_UNIT_NAME").Empty = False Then 
        ' Подтверждение
        result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion+vbYesNo, 1032, name)   
        If result <> vbYes Then
          Exit Sub
        End If  
      End If
      Obj.Attributes("ATTR_UNIT_NAME") = name
    Case "ATTR_WORK_DOCS_FOR_BUILDING_TYPE"
      Call Set_ATTR_LAND_USE_CATEGORY(Form,Obj)

  End Select
End Sub

Sub Set_ATTR_LAND_USE_CATEGORY(Form,Obj)
  aDefName = "ATTR_LAND_USE_CATEGORY"
  If InStr(Obj.Attributes("ATTR_WORK_DOCS_FOR_BUILDING_TYPE").Value, "Участок") <> 0 Then
    flag = True
    Obj.Attributes("ATTR_UNIT_TYPE").Classifier = Nothing
    Form.Controls("T_ATTR_UNIT_CODE").Value = "Номер участка"
  Else
    flag = False
    Obj.Attributes(aDefName).Classifier = Nothing
    Form.Controls("T_ATTR_UNIT_CODE").Value = "Поз. по ГП"
  End If
  Call SetControlVisible(Form,aDefName,flag)
  Call SetControlVisible(Form,"ATTR_UNIT_TYPE",Not flag)
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

Sub SetButtonsEnabled(Form, Obj)
  Set CU = ThisApplication.CurrentUser
  isGip = ThisApplication.ExecuteScript("CMD_DLL_ROLES","isGipOrDep",Obj,CU)

  With form.controls
    .Item("ATTR_UNIT_CODE").Readonly = Not isGip
    .Item("ATTR_UNIT_TYPE").Readonly = Not isGip
    .Item("ATTR_UNIT_NAME").Readonly = Not isGip
    .Item("CMD_PROJECT_STAGE_SEL").Enabled = isGip
    .Item("CMD_PROJECT_STAGE_DEL").Enabled = isGip
    .Item("ATTR_LAND_USE_CATEGORY").Readonly = Not isGip
    .Item("ATTR_WORK_DOCS_FOR_BUILDING_TYPE").Readonly = Not isGip
    .Item("ATTR_STARTDATE_PLAN").Readonly = Not isGip
    .Item("ATTR_ENDDATE_PLAN").Readonly = Not isGip
  End With
  
  
  aDefName = "ATTR_LAND_USE_CATEGORY"
  If InStr(Obj.Attributes("ATTR_WORK_DOCS_FOR_BUILDING_TYPE").Value, "Участок") <> 0 Then
    flag = True
    Form.Controls("T_ATTR_UNIT_CODE").Value = "Номер участка"
  Else
    flag = False
    Form.Controls("T_ATTR_UNIT_CODE").Value = "Поз. по ГП"
  End If
  Call SetControlVisible(Form,aDefName,flag)
  Call SetControlVisible(Form,"ATTR_UNIT_TYPE",Not flag)
End Sub
