' Форма ввода - Документ закупки
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

'USE "CMD_KD_COMMON_LIB"
USE "CMD_DLL_COMMON_BUTTON"
USE "CMD_FILES_LIBRARY"
USE "CMD_PROJECT_DOCS_LIBRARY"


Sub Form_BeforeShow(Form, Obj)
ShowFile(0)
  form.Caption = form.Description
  set cCtl=Form.controls
'  If not Obj.Status is Nothing Then
'    cCtl("lbStatus").Value = Obj.Status.Description
'  End If
  End Sub

'Событие - Выделен файл в выборке
Sub QUERY_FILES_IN_Selected(iItem, action)
  Call QueryFileSelect(ThisForm,iItem,Action)
  If iItem <> -1 and Action = 2 Then
    ThisForm.Controls("BTN_DELETE_FILES").Enabled = True
  Else
    ThisForm.Controls("BTN_DELETE_FILES").Enabled = False
  End If
  Call ShowFile(iItem)
End Sub

Sub SetControls(Form,Obj)
  With Form.Controls
    If Obj.StatusName = "STATUS_TENDER_CLOSE"  or Obj.StatusName = "STATUS_S_INVALIDATED" Then
      .Item("BTN_DELETE_FILES").Visible = False
      .Item("BTN_LOAD_FILE_TO_DOC").Visible = False
    End If
'    If Obj.StatusName <> "STATUS_DOC_IN_WORK" Then
'      .Item("BUTTON_AGREED").Visible = False
''      .Item("BUTTON_CLOSE").Visible = False
'    End If
  End With
End Sub

  'Кнопка - Сохранить Перенести в библиотеку!
  Sub BUTTON_CUSTOM_SAVE_OnClick()
  ThisScript.SysAdminModeOn
  Key = Msgbox("Сохранить внесенные изменения?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
  ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = False
  ThisObject.Update
  'Call BtnEnable0(ThisForm,ThisObject)
End Sub
'Кнопка - Отменить Перенести в библиотеку!
Sub BUTTON_CUSTOM_CANCEL_OnClick()
  ThisScript.SysAdminModeOn
  Key = Msgbox("Отменить внесенные изменения?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
  ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = False
  Guid = ThisObject.GUID
  ThisForm.Close False
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Set Obj = ThisApplication.GetObjectByGUID(Guid)
  Dlg.Object = Obj
  Dlg.Show
  
 End Sub




