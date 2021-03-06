Option Explicit

USE "CMD_SS_SYSADMINMODE"
USE "CMD_SS_TRANSACTION"

Sub BTN_KD_DEL_CONTR_OnClick()
  If vbNo = MsgBox ("Удалить связь с договором ?", vbQuestion + vbYesNo) Then Exit Sub
  ThisApplication.ExecuteScript "CMD_SS_LIB", "ClearAttributes", _
    ThisObject, "ATTR_CONTRACT_SUBCONTRACTOR"
End Sub

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  
  Dim parent
  Set parent = Obj.Parent
  If parent Is Nothing Then Exit Sub
  
  Dim att
  Set att = parent.Attributes
  If Not att.Has("ATTR_SUBCONTRACTOR_WORK") Then Exit Sub
  If Not att("ATTR_SUBCONTRACTOR_WORK").Value Then Exit Sub
  
  DisableControls Form
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  
  Dim tr, sam
  Set tr = New Transaction
  Set sam = New SysAdminMode
  ThisApplication.ExecuteScript "CMD_SS_LIB", "PropagateAttribute", _
    Obj.ContentAll, Attribute
  tr.Commit
End Sub

Private Sub DisableControls(form)
  
  Dim c
  For Each c In form.Controls
    c.Enabled = False
  Next
End Sub

Sub Form_BeforeClose(Form, Obj, Cancel)
  
  Dim objAtt, formAtt
  Set objAtt = Obj.Attributes
  Set formAtt = Form.Attributes
  
  If Not objAtt.Has("ATTR_SUBCONTRACTOR_WORK") Then Exit Sub
  If Not objAtt("ATTR_SUBCONTRACTOR_WORK").Value Then Exit Sub
  
  If Not formAtt.Has("ATTR_TENDER_OUT_REQUIRED") Then Exit Sub
  If formAtt("ATTR_TENDER_OUT_REQUIRED").Empty Then
    ThisApplication.MsgBox "Необходимо заполнить значение атрибута <" & _
      formAtt("ATTR_TENDER_OUT_REQUIRED").AttributeDef.Description & ">"
    Cancel = True
  End If
End Sub

Sub BTN_KD_ADD_CONTR_OnClick()
  
  Dim qry
  Set qry = ThisApplication.CreateQuery()
  qry.AddCondition tdmQueryConditionObjectDef, "OBJECT_CONTRACT"
  qry.AddCondition tdmQueryConditionAttribute, "Расходный", "ATTR_CONTRACT_CLASS"
  If ThisObject.Attributes.Has("ATTR_PROJECT") Then
    Dim project
    Set project = ThisObject.Attributes("ATTR_PROJECT").Object
    If Not project Is Nothing Then
      Dim mainContract
      Set mainContract = project.Attributes("ATTR_CONTRACT").Object
      If Not mainContract Is Nothing Then
        qry.AddCondition tdmQueryConditionAttribute, mainContract, "ATTR_CONTRACT_MAIN"
      End If
    End If
  End If
  If Not ThisObject.Attributes("ATTR_SUBCONTRACTOR_CLS").Empty Then
    qry.AddCondition tdmQueryConditionAttribute, _
      ThisObject.Attributes("ATTR_SUBCONTRACTOR_CLS").Object, "ATTR_CONTRACTOR"
  End If
  
  Dim objects
  Set objects = qry.Objects
  If 0 = objects.Count Then
    ThisApplication.MsgBox "Ничего не найдено"
    Exit Sub
  End If
  If 1 = objects.Count Then
    ThisObject.Attributes("ATTR_CONTRACT_SUBCONTRACTOR").Object = objects(0)
    Exit Sub
  End If
  
  Dim dlg
  Set dlg = ThisApplication.Dialogs.SelectObjectDlg
  dlg.Caption = "Выберите договор субподрядчика"
  dlg.SelectFromObjects = objects
  If Not dlg.Show() Then Exit Sub
  ThisObject.Attributes("ATTR_CONTRACT_SUBCONTRACTOR").Object = dlg.Objects(0)
End Sub