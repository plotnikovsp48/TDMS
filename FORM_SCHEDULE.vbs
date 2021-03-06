' $Workfile: FORM.SCRIPT.FORM_DOCUMENT_PROPERTIES.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Форма "Свойства документа"
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

USE "CMD_DLL_COMMON_BUTTON"
USE "CMD_FILES_LIBRARY"
USE "CMD_PROJECT_DOCS_LIBRARY"
USE "CMD_DLL"

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description


  Call ThisApplication.ExecuteScript("CMD_DLL", "ShowBtnIcon",Form,Obj)
  Call SetControls(Form,Obj)
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  Set cCtrl = Form.Controls
  If Attribute.AttributeDefName = "ATTR_PROJECT_DOC_TYPE" or Attribute.AttributeDefName = "ATTR_DOCUMENT_AN_TYPE" _
          or Attribute.AttributeDefName = "ATTR_DOCUMENT_TYPE"  Then
    'Call CodeGen (Obj)
    ' Сбрасываем значение поля тип отчета, если выбран тип документа не Отчет
    If Attribute.AttributeDefName = "ATTR_DOCUMENT_AN_TYPE" And cCtrl.Has("ATTR_REPORT_AN_TYPE") And cCtrl.Has("ATTR_DOCUMENT_AN_TYPE") Then
      If Attribute.Classifier.SysName <> "NODE_DOCUMENT_AN_TYPE_REPORT" Then
        Obj.Attributes("ATTR_REPORT_AN_TYPE").Classifier = Nothing
      End If
    End If
    
    ' Заменяем наименование
    cName = Obj.Attributes("ATTR_DOCUMENT_NAME")
    If Trim(cName)<> "" Then
      ans=ThisApplication.ExecuteScript( "CMD_MESSAGE", "ShowWarning", vbQuestion+vbYesNo, 1032, Attribute.Classifier.Description)
      If ans = vbYes Then 
        Obj.Attributes("ATTR_DOCUMENT_NAME") = Attribute.Classifier.Description
      End If
    Else
      Obj.Attributes("ATTR_DOCUMENT_NAME") = Attribute.Classifier.Description
    End If
  End If
  Call SetControls(Form,Obj)
End Sub

Sub SetControls(Form,Obj)
  Set cCtrl = Form.Controls
  
  If not Obj.Status is Nothing Then
    cCtrl("lbStatus").Value = Obj.Status.Description
  End If
  
  If cCtrl.Has("ATTR_REPORT_AN_TYPE") And cCtrl.Has("ATTR_DOCUMENT_AN_TYPE") Then
      If Obj.Attributes("ATTR_DOCUMENT_AN_TYPE").Empty = False Then
        Check = (Obj.Attributes("ATTR_DOCUMENT_AN_TYPE").Classifier.SysName = "NODE_DOCUMENT_AN_TYPE_REPORT")
      Else
        Check = False
      End If
      Call SetControlVisible(Form,"ATTR_REPORT_AN_TYPE",Check)
  End if
  
  ' Установка статуса контролов ReadOnly
  Dim sListAttrs ' Список системных идентификаторов контролов, которые на форме должны быть скрыты
  If Not Obj.Parent Is Nothing Then
  ' Заменил - Стромков 28.02.2017
  ' If Obj.Parent.ObjectDefName <> "OBJECT_FOLDER" Then
    If Obj.Attributes.Has("ATTR_DOCUMENT_CONF") = True Then
      If Obj.Parent.ObjectDefName = "OBJECT_FOLDER" And Obj.Attributes("ATTR_DOCUMENT_CONF").Empty = False Then
        sListAttrs = "ATTR_DOCUMENT_CONF," & sListAttrs
      End If
    End If
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
  
End Sub


'======================================================================================
'
'    Блок работы с файлами
'
'======================================================================================

'Событие - выделение файла в выборке файлов
Sub QUERY_FILES_IN_DOC_Selected(iItem, action)
  Call QueryFileSelect(ThisForm,iItem,Action)
  If iItem <> -1 and Action = 2 Then
    Call SetFilesActionButtonLocked(ThisForm,True)
  Else
    Call SetFilesActionButtonLocked(ThisForm,False)
  End If
End Sub

'Кнопка - Добавить файлы с диска
Sub BTN_ADDFILES_OnClick()
  Dim count
  count = ThisObject.Files.Count
  ClosePreview
  Call AddFileFromDiskForObject(ThisObject)
  If count = ThisObject.Files.Count Then
    If 0 = count Then Exit Sub

  End If
End Sub

'Кнопка - Редактировать файл
Sub BTN_EDIT_FILE_OnClick()
  Call BlockFilesOpenFile(ThisForm,ThisObject,True)
End Sub

'Кнопка - Открыть файл в окне просмотра
Sub b_ShowFilePreview_OnClick()
  Call BlockFilesOpenInside(ThisForm,ThisObject)
End Sub

'Кнопка - Открыть файлы на просмотр во внешнем редакторе
Sub bViewFile_OnClick()
  Call BlockFilesOpenFile(ThisForm,ThisObject,False)
  'Call ThisApplication.ExecuteCommand ("CMD_VIEW",ThisObject)
End Sub

'Кнопка - Сконвертировать в PDF
Sub BTN_ConvertToPDF_OnClick()
  Call BlockFilesConvertPDF(ThisForm,ThisObject)
End Sub

'Кнопка - Печать
Sub BTN_PrintFiles_OnClick()
  Call BlockFilesPrint(ThisForm,ThisObject)
End Sub



'Событие - Двойной клик мыши по файлу в выборке файлов
Sub QUERY_FILES_IN_DOC_DblClick(iItem, bCancelDefault)
  Call BTN_EDIT_FILE_OnClick()
  bCancelDefault = True
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

'Sub BTN_TO_AGREE_OnClick()
'  ThisScript.SysAdminModeOn
'  ThisObject.SaveChanges
'  ThisObject.Dictionary.Item("FormActive") = "FORM_KD_DOC_AGREE"
'  ThisForm.Close True
'  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
'  Dlg.Object = ThisObject
'  Dlg.Show
'End Sub

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