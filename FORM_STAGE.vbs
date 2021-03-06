USE "CMD_S_NUMBERING"
USE "CMD_DLL"

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  set cCtl=Form.controls 
  If not Obj.Status is Nothing Then
    cCtl("lbStatus").Value = Obj.Status.Description
  End If 
  
  hasCont = HasContent(Obj, "OBJECT_PROJECT_SECTION")
  
  Form.Controls("BUTTON_STAGE_SEL").Visible = (Not hasCont)
  
  If Not Obj.Attributes("ATTR_PROJECT_STAGE").Empty Then
    If Not Obj.Attributes("ATTR_PROJECT_STAGE") Is Nothing Then
      Select Case Obj.Attributes("ATTR_PROJECT_STAGE").Classifier.SysName
        Case "NODE_PROJECT_STAGE_OTR", "NODE_PROJECT_STAGE_P"
          Form.Controls("ATTR_SITE_TYPE_CLS").ReadOnly = hasCont'(Obj.Attributes("ATTR_PROJECT_STAGE").Empty = False)
          Call SetControlVisible(Form,"ATTR_SITE_TYPE_CLS",Obj.Attributes("ATTR_PROJECT_STAGE").Empty = False)
        Case Else
          Call SetControlVisible(Form,"ATTR_SITE_TYPE_CLS",False)
      End Select
    End If
  Else
    Call SetControlVisible(Form,"ATTR_SITE_TYPE_CLS",Obj.Attributes("ATTR_PROJECT_STAGE").Empty = False)
  End If
  
  Form.Controls("ATTR_STARTDATE_PLAN").ReadOnly = Obj.Attributes("ATTR_STARTDATE_PLAN").Empty = False
  Form.Controls("ATTR_ENDDATE_PLAN").ReadOnly = Obj.Attributes("ATTR_ENDDATE_PLAN").Empty = False
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  If Attribute.AttributeDefName = "ATTR_ENDDATE_PLAN" Then 
    Obj.Attributes("ATTR_ENDDATE_ESTIMATED") = Attribute
  End If


  If Attribute.AttributeDefName = "ATTR_PROJECT_STAGE" Then 
    Call ThisApplication.ExecuteScript("CMD_CREATE_OBJECT_STAGE","Set_PROJECT_STAGE_CODE",Obj)
    
    Select Case Attribute.Classifier.SysName
      Case "NODE_PROJECT_STAGE_OTR", "NODE_PROJECT_STAGE_P"
        Form.Controls("ATTR_SITE_TYPE_CLS").Visible = True      
      Case Else
        Obj.Attributes("ATTR_SITE_TYPE_CLS").Empty = True
        Form.Controls("ATTR_SITE_TYPE_CLS").Visible = False
    End Select
  End If
End Sub


'Кнопка - Выбор стадии
Sub BUTTON_STAGE_SEL_OnClick()
  ThisScript.SysAdminModeOn
  Set Project = Nothing
  If ThisObject.Attributes("ATTR_PROJECT").Empty = False Then
    If not ThisObject.Attributes("ATTR_PROJECT").Object is Nothing Then
      Set Project = ThisObject.Attributes("ATTR_PROJECT").Object
    End If
  End If
  If Project is Nothing Then Exit Sub

  Set Clf = ThisApplication.ExecuteScript("CMD_CREATE_OBJECT_STAGE","SelectStage",Project)
  If Clf is Nothing Then Exit Sub
  
  ThisObject.Attributes("ATTR_PROJECT_STAGE").Classifier = Clf
  Select Case Clf.SysName
    Case "NODE_PROJECT_STAGE_OTR", "NODE_PROJECT_STAGE_P"
      ThisForm.Controls("ATTR_SITE_TYPE_CLS").Visible = True     
      ThisForm.Controls("T_ATTR_SITE_TYPE_CLS").Visible = True 
    Case Else
      ThisObject.Attributes("ATTR_SITE_TYPE_CLS").Empty = True
      ThisForm.Controls("ATTR_SITE_TYPE_CLS").Visible = False
      ThisForm.Controls("T_ATTR_SITE_TYPE_CLS").Visible = False
  End Select
  Call ThisApplication.ExecuteScript("CMD_CREATE_OBJECT_STAGE","Set_PROJECT_STAGE_CODE",ThisObject)  
End Sub

Sub CMD_PROJECT_STAGE_NUM_SET_OnClick()
  Set o = ThisObject
  If o.Attributes("ATTR_PROJECT_STAGE_NUM").Empty = False AND o.Attributes("ATTR_PROJECT_STAGE_NUM").Value <> "" Then
    ' Подтверждение
    result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, 1050, o.Description)    
    If result <> vbYes Then 
      Exit Sub
    End If  
  End If
  Call SetAttr (o,"ATTR_PROJECT_STAGE_NUM",GetObjNumber(o))
End Sub

'=============================================================
' Проверяет наличие объектов указанного типа в составе объекта
'-------------------------------------------------------------
' Obj: TDMSObject - Объект, в составе которого ищем
' oDefName: SysID искомого типа объекта
' HasContent:     True - В составе есть объекты указанного типа
'                 False - В составе нет объектов указанного типа 
'=============================================================
Function HasContent(Obj, oDefName)
  HasContent = True
  If Not ThisApplication.ObjectDefs.Has(oDefName) Then Exit Function
  Set o = Obj.Content.ObjectsByDef(oDefName)
  If o.count = 0 Then HasContent = False
End Function

