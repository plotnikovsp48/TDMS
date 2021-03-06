' $Workfile: FORM.SCRIPT.FORM_DOCUMENT_PROPERTIES.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Форма "Свойства документа"
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

'USE "CMD_KD_COMMON_BUTTON_LIB"
USE "CMD_DLL_COMMON_BUTTON"
USE "CMD_FILES_LIBRARY"
USE "CMD_PROJECT_DOCS_LIBRARY"
USE "CMD_DLL"

Sub Form_BeforeShow(Form, Obj)
  Call SetLabels(Form, Obj)
  If Obj.ObjectDefName <> "OBJECT_DRAWING" And Obj.ObjectDefName <> "OBJECT_DOC_DEV" Then
    Call ShowFile(0)
  End If

  Call ThisApplication.ExecuteScript("CMD_DLL", "ShowBtnIcon",Form,Obj)
  Call SetControls(Form,Obj)
  Call SetFilesActionButtonLocked(Form,False)
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  Set cCtrl = Form.Controls
  If Attribute.AttributeDefName = "ATTR_PROJECT_DOC_TYPE" or Attribute.AttributeDefName = "ATTR_DOCUMENT_AN_TYPE" _
          or Attribute.AttributeDefName = "ATTR_DOCUMENT_TYPE"  Then
    'Call CodeGen (Obj)
    ' Сбрасываем значение поля тип отчета, если выбран тип документа не Отчет
    If Attribute.AttributeDefName = "ATTR_DOCUMENT_AN_TYPE" And cCtrl.Has("ATTR_REPORT_AN_TYPE") And cCtrl.Has("ATTR_DOCUMENT_AN_TYPE") Then
      Set cls = Attribute.Classifier
      If Not cls Is Nothing Then
        If Attribute.Classifier.SysName <> "NODE_DOCUMENT_AN_TYPE_REPORT" Then
          Obj.Attributes("ATTR_REPORT_AN_TYPE").Classifier = Nothing
        End If
      End If
      Call Set_ATTR_REPORT_AN_TYPE(Form,Obj)
    End If
    
    ' Заменяем наименование
    cName = Obj.Attributes("ATTR_DOCUMENT_NAME")
    If Trim(cName)<> "" Then
      Set cls = Attribute.Classifier
      txt = ""
      If Not cls Is Nothing Then 
        txt = Attribute.Classifier.Description
        ans=ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion+vbYesNo, 1032, Attribute.Classifier.Description)
        If ans = vbYes Then 
          Obj.Attributes("ATTR_DOCUMENT_NAME") = Attribute.Classifier.Description
        End If
      End If
    Else
      Obj.Attributes("ATTR_DOCUMENT_NAME") = Attribute.Classifier.Description
    End If
    'Call SetControls(Form,Obj)
  End If
End Sub

Sub Set_ATTR_REPORT_AN_TYPE(Form,Obj)
  Set cCtrl = Form.Controls
  If cCtrl.Has("ATTR_REPORT_AN_TYPE") And cCtrl.Has("ATTR_DOCUMENT_AN_TYPE") Then
    chk1 = Obj.Attributes("ATTR_DOCUMENT_AN_TYPE").Empty = False
      If chk1 Then
        Check = (Obj.Attributes("ATTR_DOCUMENT_AN_TYPE").Classifier.SysName = "NODE_DOCUMENT_AN_TYPE_REPORT")
      End If
      Call SetControlVisible(Form,"ATTR_REPORT_AN_TYPE",Check)
  End if
End Sub

Sub SetControls(Form,Obj)
  Set cCtrl = Form.Controls
  
  If not Obj.Status is Nothing Then
    cCtrl("lbStatus").Value = Obj.Status.Description
  End If
  
  Call Set_ATTR_REPORT_AN_TYPE(Form,Obj)
  If cCtrl.Has("ATTR_DOCUMENT_AN_TYPE") Then
    cCtrl("ATTR_DOCUMENT_AN_TYPE").Readonly = (Obj.Attributes("ATTR_DOCUMENT_AN_TYPE").Empty = False)
  End If

  ' Установка статуса контролов ReadOnly
  Dim sListAttrs ' Список системных идентификаторов контролов, которые на форме должны быть скрыты
  If Not Obj.Parent Is Nothing Then
  ' Заменил - Стромков 28.02.2017
  ' If Obj.Parent.ObjectDefName <> "OBJECT_FOLDER" Then
'    If Obj.Attributes.Has("ATTR_DOCUMENT_CONF") = True Then
'      If Obj.Parent.ObjectDefName = "OBJECT_FOLDER" And Obj.Attributes("ATTR_DOCUMENT_CONF").Empty = False Then
'        sListAttrs = "ATTR_DOCUMENT_CONF," & sListAttrs
'      End If
'    End If
    If Obj.Attributes.Has("ATTR_CHECKER") = True Then
      If Obj.Parent.ObjectDefName = "OBJECT_FOLDER" And Obj.Attributes("ATTR_CHECKER").Empty = False Then
        sListAttrs = "ATTR_CHECKER," & sListAttrs
      End If
    End If
  End If
  
  If cCtrl.Has("ATTR_DOCUMENT_TYPE") And Obj.Attributes.Has("ATTR_DOCUMENT_TYPE") Then
    cCtrl("ATTR_DOCUMENT_TYPE").Readonly = (Obj.Attributes("ATTR_DOCUMENT_TYPE").Empty = False)
  End if
  
  Call ThisApplication.ExecuteScript("CMD_DLL","SetControlReadOnly",Form,sListAttrs)
  
  Call SetBTNEnabled(Form,Obj)
End Sub

Sub SetBTNEnabled(Form,Obj)
  With Form.Controls
    Set CU = ThisApplication.CurrentUser
    isAuth = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsAuthor",Obj,CU)
    isDevl = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsDeveloper",Obj,CU)
    isChck = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsChecker",Obj,CU)
    isInit = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsInitiator",Obj,CU)
    isAprv = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsAprover",Obj,CU)
    candelfile = (Obj.Permissions.EditFiles=tdmallow)
    
    flag = (Obj.StatusName = "STATUS_DOCUMENT_CREATED")
    .Item("BTN_TO_CHECK").Enabled = flag And (isAuth or isDevl)
    
    flag = (Obj.StatusName = "STATUS_DOCUMENT_CHECK")
    .Item("BTN_SIGN").Enabled = flag And isChck
    
    flag1 = (Obj.StatusName = "STATUS_DOCUMENT_CHECK") 
    flag2 = (Obj.StatusName = "STATUS_DOCUMENT_IS_APPROVING")
    .Item("BTN_REJECT").Enabled = (flag1 And isChck) Or (flag2 And isAprv)
            
    flag = (Obj.StatusName = "STATUS_DOCUMENT_DEVELOPED")
    .Item("BTN_TO_AGREE").Enabled = flag And isInit
    
    flag = (Obj.StatusName = "STATUS_DOCUMENT_AGREED")
    .Item("BTN_TO_APPROVAL").Enabled = flag And (isAuth or isDevl)
    
    flag = (Obj.StatusName = "STATUS_DOCUMENT_IS_APPROVING")
    .Item("BTN_APPROVE").Enabled = flag And (isAprv)
    
    flag = (Obj.StatusName = "STATUS_DOCUMENT_FIXED")
    .Item("BTN_CANCEL").Enabled = flag And (isAuth or isDevl)
  End With
End Sub



'=======================================================================

' Кнопка - На проверку
Sub BTN_TO_CHECK_OnClick()
  ThisObject.Permissions = SysAdminPermissions 
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_TO_CHECK", "SendToCheck", ThisObject)
  If Res = True Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

Sub BTN_SIGN_OnClick()
  ThisObject.Permissions = SysAdminPermissions 
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_TO_CHECK", "ToSign", ThisObject)
  If Res = True Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

Sub BTN_TO_APPROVAL_OnClick()
  ThisObject.Permissions = SysAdminPermissions 
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_TO_CHECK", "SendToAproove", ThisObject)
  If Res = True Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

Sub BTN_APPROVE_OnClick()
  ThisObject.Permissions = SysAdminPermissions 
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_TO_CHECK", "ToAproove", ThisObject)
  If Res = True Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

Sub BTN_REJECT_OnClick()
  ThisObject.Permissions = SysAdminPermissions 
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_TO_CHECK", "ToReject", ThisObject)
  If Res = True Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

Sub BTN_CANCEL_OnClick()
  ThisObject.Permissions = SysAdminPermissions 
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_TO_CHECK", "ToInvalidate", ThisObject)
  If Res = True Then
    ThisObject.Update
    ThisForm.Close True
  End If
End Sub

Sub BTN_TO_AGREE_OnClick()
  ThisScript.SysAdminModeOn
  ThisObject.SaveChanges
  
  ' Запоминаем, какую форму нужно активировать при переоткрытии диалога свойств
  Set dict = ThisObject.Dictionary
  If Not dict.Exists("FormActive") Then 
    dict.Add "FormActive", "FORM_KD_DOC_AGREE"
  End If
  
'  ThisObject.Dictionary.Item("FormActive") = "FORM_KD_DOC_AGREE"
  ThisForm.Close True
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = ThisObject
  Dlg.Show
End Sub


