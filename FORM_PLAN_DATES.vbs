USE "CMD_ADD_TO_PLATAN"

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  'Доступность плановых дат в статусе "Черновик"
  If Obj.StatusName = "STATUS_CONTRACT_STAGE_DRAFT" or Obj.StatusName = "STATUS_WORK_DOCS_FOR_BUILDING_IS_DEVELOPING" Then
    Form.Controls("ATTR_STARTDATE_PLAN").ReadOnly = False
    Form.Controls("ATTR_ENDDATE_PLAN").ReadOnly = False
  End If
  Call SetControlsEnabled (Form)
  Call GetFromTask (Form,Obj)
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  '"Ожидаемая дата начала работ" = "Дата начала по плану"
  If Attribute.AttributeDefName = "ATTR_STARTDATE_PLAN" Then
    Obj.Attributes("ATTR_STARTDATE_ESTIMATED").Value = Attribute.Value
  End If
  '"Ожидаемая дата окончания работ" = "Дата окончания по плану"
  If Attribute.AttributeDefName = "ATTR_ENDDATE_PLAN" Then
    Obj.Attributes("ATTR_ENDDATE_ESTIMATED").Value = Attribute.Value
    If Obj.ObjectDefName = "OBJECT_CONTRACT" Then
      Call ThisApplication.ExecuteScript("FORM_CONTRACT", "FullFillDatePlan", Obj)
    End If
  End If
End Sub

'==============================================================================
' Процедура отображает значения атрибутов связанной плановой задачи на вкладку Сроки
'------------------------------------------------------------------------------
' Form:TDMSForm - Вкладка сроки
' Obj:TDMSObject - Объект, на котором вкладка Сроки
'==============================================================================
Sub GetFromTask (Form,Obj)
  Set oTask = GetObjectTask(Obj)
  set cCtl=Form.controls
  If oTask Is Nothing Then 
    cList = "CMD_TASK_OPEN,ATTR_OBJECT"
    Call ThisApplication.ExecuteScript("CMD_DLL","HideControls",Form,cList)
    Exit Sub
  End If

  cCtl("ATTR_OBJECT").Value=oTask.Description
  
  ' Копируем значения атрибутов типа "Дата" из плановой задачи на карточку Сроки.
  For Each ctl in cCtl
    aAttrDefName = ctl.Name
    If oTask.Attributes.Has(aAttrDefName) Then
      If oTask.Attributes(aAttrDefName).Empty = False Then
        If ThisApplication.AttributeDefs(aAttrDefName).Type = tdmDate Then
          ctl.Value = oTask.Attributes(aAttrDefName).Value
        End If
      End If
    End If
  Next
End Sub

Sub CMD_TASK_OPEN_OnClick()
  Set oTask = GetObjectTask(ThisObject)  
  Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
  oTask.Permissions = SysAdminPermissions 
  EditObjDlg.object = oTask
  EditObjDlg.ParentWindow = ThisApplication.hWnd
  If Not EditObjDlg.Show Then 
    oTask.Unlock
  End If
  ThisForm.Refresh
End Sub

Sub SetControlsEnabled (Form)
  set cCtl=Form.controls
  For each cCtl In Form.controls
    cCtl.Enabled = True
  Next
End Sub
