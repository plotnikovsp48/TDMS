' Форма ввода - Этап
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.
USE "CMD_S_DLL"
USE "CMD_SS_TRANSACTION"
USE "CMD_DLL_COMMON_BUTTON"

Sub Form_BeforeShow(Form, Obj)
  Call SetLabels(Form, Obj)
  Call SetControls(Form,Obj)
'  Call AttrEnable(Form,Obj)
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  Set oProj = Obj.Attributes("ATTR_PROJECT").Object
  
  If Attribute.AttributeDefName = "ATTR_CONTRACT_STAGE_CLOSE_TYPE" Then
    If Obj.Attributes.Has("ATTR_CONTRACT_STAGE_CLOSE_TYPE") and Obj.Attributes.Has("ATTR_DATA") Then
      If Obj.Attributes("ATTR_CONTRACT_STAGE_CLOSE_TYPE").Empty = False Then
        Val = Obj.Attributes("ATTR_CONTRACT_STAGE_CLOSE_TYPE").Value
        If StrComp(Val,"требуется заключение договора",vbTextCompare) = 0 or _
          StrComp(Val,"требуется проведение конкурентной закупки",vbTextCompare) = 0 Then
          Flag1 = False
        Else
          Obj.Permissions = SysAdminPermissions
          Obj.Attributes("ATTR_DATA").Value = ""
        End If
      End If
    End If
    Call AttrEnable(Form,Obj)
  ElseIf Attribute.AttributeDefName = "ATTR_STARTDATE_PLAN" Then
    ' Проверяем дату начала этапа с датой начала договора
    If Not oProj Is Nothing Then
      If oProj.Attributes("ATTR_STARTDATE_PLAN") > Attribute Then
        msgbox "Дата начала этапа не может быть раньше даты начала работ по договору", vbExclamation,"Ошибка даты"
        Cancel = True
      End If
    End If
    
    
    ' Проверяем, что дата начала не позднее даты окончания
    If Attribute.Empty = False Then
      If Obj.Attributes("ATTR_ENDDATE_PLAN").Empty = False Then
        If Attribute.Value > Obj.Attributes("ATTR_ENDDATE_PLAN") Then
          msgbox "Дата начала работ не может быть позднее даты окончания" , vbExclamation,"Ошибка даты"
          Cancel = True
        End If
      End If
    End If
    Obj.Attributes("ATTR_STARTDATE_ESTIMATED") = Attribute
  ElseIf Attribute.AttributeDefName = "ATTR_ENDDATE_PLAN" Then
    ' Проверяем дату окончания этапа с датой окончания договора
    If Not oProj Is Nothing Then
      If oProj.Attributes("ATTR_ENDDATE_PLAN") < Attribute Then
        msgbox "Дата окончания этапа не может быть позднее даты окончания работ по договору", vbExclamation,"Ошибка даты"
        Cancel = True
      End If
    End If
    ' Проверяем, что дата окончания не ранее даты начала
    If Attribute.Empty = False Then
      If Obj.Attributes("ATTR_STARTDATE_PLAN").Empty = False Then
        If Attribute.Value < Obj.Attributes("ATTR_STARTDATE_PLAN") Then
          msgbox "Дата окончания работ не может быть ранее даты начала" , vbExclamation,"Ошибка даты"
          Cancel = True
        End If
      End If
    End If
    Obj.Attributes("ATTR_ENDDATE_ESTIMATED") = Attribute
  End If
End Sub

'Процедура управления доступностью атрибутов
Sub AttrEnable(Form,Obj)
  ThisScript.SysAdminModeOff
  Flag0 = True
  Flag1 = True
  Set cu = ThisApplication.CurrentUser
  isCur = ThisApplication.ExecuteScript("CMD_DLL_CONTRACTS","IsCurator",Obj,cu)
  isResp = IsResponsible(Obj,cu)
  
  If Obj.RolesForUser(cu).Has("ROLE_CONTRACT_RESPONSIBLE") Or isCur Then
    Flag0 = False
'  Else
'    Set oProj = ThisObject.Attributes("ATTR_CONTRACT").Object
'    If Not oProj Is Nothing Then
'      If oProj.Attributes.Has("ATTR_CURATOR") Then
'        Set u = oProj.Attributes("ATTR_CURATOR").User
'        If Not u Is Nothing Then
'          If u.Handle = cu.Handle Then
'            Flag0 = False
'          End If
'        End If
'      End If
'    End If
  End If

  
  Form.Controls("BTN_CONTRACT_STAGE_RUN").Enabled = isResp And Obj.StatusName = "STATUS_CONTRACT_STAGE_DRAFT"
  Form.Controls("BTN_CONTRACT_STAGE_FINISH").Enabled = isResp And Obj.StatusName = "STATUS_CONTRACT_STAGE_IN_WORK"
  Form.Controls("ATTR_DATA").Visible = not Flag1
  Form.Controls("T_ATTR_DATA").Visible = not Flag1
  Form.Controls("ATTR_CONTRACT_STAGE_CLOSE_TYPE").ReadOnly = Flag0
  Form.Controls("ATTR_DATA").ReadOnly = Flag0
End Sub

Sub SetControls(Form,Obj)
  Set CU = ThisApplication.CurrentUser
  isGip = ThisApplication.ExecuteScript("CMD_DLL_ROLES","isGipOrDep",Obj,CU)

  List = "ATTR_CODE,ATTR_NAME,ATTR_STARTDATE_PLAN,ATTR_ENDDATE_PLAN,ATTR_STARTDATE_FACT,ATTR_ENDDATE_FACT," & _
          "ATTR_STARTDATE_ESTIMATED,ATTR_ENDDATE_ESTIMATED"
  arr = Split(List,",")
  check1 = CheckObj
  With Form.Controls

    For i = 0 to Ubound(arr)
      .Item(arr(i)).Readonly = ((not isGip) And (not check1)) 
    Next

    .Item("CMD_PROJECT_STAGE_SEL").Enabled = _
      ThisApplication.ExecuteScript("CMD_SS_LIB", "EnableContractStageEdit", Obj) And CheckObj
    .Item("CMD_PROJECT_STAGE_DEL").Enabled = _
      .Item("CMD_PROJECT_STAGE_SEL").Enabled 

      .Item("ATTR_STARTDATE_PLAN").Readonly = Not(isGip And check1 And (not CheckObj2(Obj,"ATTR_STARTDATE_PLAN")))
      .Item("ATTR_ENDDATE_PLAN").Readonly = Not(isGip And check1 And (not CheckObj2(Obj,"ATTR_ENDDATE_PLAN")))
      .Item("ATTR_STARTDATE_ESTIMATED").Readonly = Not(isGip And check1 And (CheckObj2(Obj,"ATTR_STARTDATE_PLAN")))
      .Item("ATTR_ENDDATE_ESTIMATED").Readonly = Not(isGip And check1 And (CheckObj2(Obj,"ATTR_ENDDATE_PLAN")))
  End With
  
  
End Sub

Sub BTN_CONTRACT_STAGE_RUN_OnClick()
  Res = ThisApplication.ExecuteScript("CMD_CONTRACT_STAGE_RUN","Main",ThisObject)
  If Res Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

Sub BTN_CONTRACT_STAGE_FINISH_OnClick()
  Res = ThisApplication.ExecuteScript("CMD_CONTRACT_STAGE_FINISH","Main",ThisObject)
  If Res Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

Function IsResponsible(Obj,user)
  IsResponsible = False
  If Obj.Attributes.Has("ATTR_RESPONSIBLE") Then
    Set u = Obj.Attributes("ATTR_RESPONSIBLE").User
    If u Is Nothing Then Exit Function
    IsResponsible = (u.Handle = user.Handle)
  End If
End Function

' Кнопка - Выбрать этап
Sub CMD_PROJECT_STAGE_SEL_OnClick()
  Dim t
  Set t = New Transaction
  Set Stage = SelStage(ThisObject)
  ThisObject.Attributes("ATTR_CONTRACT_STAGE").Object = stage
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

'Функция проверки доступности формирования обозначения
Function CheckObj()
  CheckObj = True
  'Статус
  If ThisObject.StatusName = "STATUS_BUILDING_STAGE_DRAFT" Then
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
     Roles.Has("ROLE_STRUCT_DEVELOPER") = False and _
     Roles.Has("ROLE_PROJECT_STRUCTURE_EDIT") = False And _
     Roles.Has("ROLE_PART_RESP") = False Then
    CheckObj = False
  End If
End Function

'Функция проверки заполнения поля
Function CheckObj2(Obj,attrDefName)
  CheckObj2 = False
  If Obj Is Nothing Then Exit Function
  If Obj.Attributes.Has(attrDefName) = False Then Exit Function
  
  CheckObj2 = (Obj.Attributes(attrDefName).Empty = False)

End Function
