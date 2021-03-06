' Форма ввода - Этап
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  If not Obj.Status is Nothing Then
    Form.Controls("lbStatus").Value = Obj.Status.Description
  End If
  
  Call AttrEnable(Form,Obj)
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  Set oContr = Obj.Attributes("ATTR_CONTRACT").Object
  
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
    
  ElseIf Attribute.AttributeDefName = "ATTR_RESPONSIBLE" Then
    
  ElseIf Attribute.AttributeDefName = "ATTR_STARTDATE_PLAN" Then
    ' Проверяем дату начала этапа с датой начала договора
    If Not oContr Is Nothing Then
      If oContr.Attributes("ATTR_STARTDATE_PLAN") > Attribute Then
        msgbox "Дата начала этапа не может быть раньше даты начала работ по договору: " & oContr.Attributes("ATTR_STARTDATE_PLAN"), vbExclamation,"Ошибка даты"
        Cancel = True
      End If
    End If
    
    ' Проверяем, что дата начала не позднее даты окончания
    If Attribute.Empty = False Then
      If Obj.Attributes("ATTR_ENDDATE_PLAN").Empty = False Then
        If Attribute.Value > Obj.Attributes("ATTR_ENDDATE_PLAN") Then
          msgbox "Дата начала работ не может быть позднее даты окончания: " & Obj.Attributes("ATTR_ENDDATE_PLAN"), vbExclamation,"Ошибка даты"
          Cancel = True
        End If
      End If
    End If
  ElseIf Attribute.AttributeDefName = "ATTR_ENDDATE_PLAN" Then
    ' Проверяем дату окончания этапа с датой окончания договора
    If Not oContr Is Nothing Then
      If oContr.Attributes("ATTR_ENDDATE_PLAN") < Attribute Then
        msgbox "Дата окончания этапа не может быть позднее даты окончания работ по договору: " & oContr.Attributes("ATTR_ENDDATE_PLAN"), vbExclamation,"Ошибка даты"
        Cancel = True
      End If
    End If
    ' Проверяем, что дата окончания не ранее даты начала
    If Attribute.Empty = False Then
      If Obj.Attributes("ATTR_STARTDATE_PLAN").Empty = False Then
        If Attribute.Value < Obj.Attributes("ATTR_STARTDATE_PLAN") Then
          msgbox "Дата окончания работ не может быть ранее даты начала: " & Obj.Attributes("ATTR_STARTDATE_PLAN"), vbExclamation,"Ошибка даты"
          Cancel = True
        End If
      End If
    End If
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
'    Set oContr = ThisObject.Attributes("ATTR_CONTRACT").Object
'    If Not oContr Is Nothing Then
'      If oContr.Attributes.Has("ATTR_CURATOR") Then
'        Set u = oContr.Attributes("ATTR_CURATOR").User
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
