' Форма ввода - Состав работ Этапа
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.
USE "CMD_S_DLL"

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Call SetButtonsEnable(Form, Obj)
End Sub

'Кнопка - Добавить
Sub BUTTON_ADD_OnClick()
  ThisScript.SysAdminModeOn
  Set Query = ThisApplication.Queries("QUERY_STAGE_FORM_SELECT_OBJECT")
  Query.Parameter("STAGE") = ThisObject
  Set Objects = Query.Objects
  If Objects.Count = 0 Then
    Msgbox "Нет доступных объектов для добавления.", vbExclamation
    Exit Sub
  End If
  
  'Показываем диалог выбора
  Set Dlg = ThisApplication.Dialogs.SelectObjectDlg
  Dlg.Prompt = "Выберите объекты для добавления"
  Dlg.SelectFromObjects = Objects
  If Dlg.Show Then
    If Dlg.Objects.Count <> 0 Then
      'Связываем выбранные объекты с этапом
      For Each Obj in Dlg.Objects
        If Obj.Attributes.Has("ATTR_CONTRACT_STAGE") Then
          Obj.Attributes("ATTR_CONTRACT_STAGE").Object = ThisObject
          ' на всю ветку вглубь
          Call ThisApplication.ExecuteScript("CMD_S_DLL", "SetAttrToContentAll", Obj,"ATTR_CONTRACT_STAGE",ThisObject)
        End If
      Next
      ThisForm.Refresh
    Else
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 1605
    End If
  End If
End Sub


'Кнопка - Удалить
Sub BUTTON_DEL_OnClick()
  ThisScript.SysAdminModeOn
  Set Query = ThisForm.Controls("QUERY_CONTRACT_STAGE_LINKS")
  Set Objects = Query.SelectedObjects
  
  'Подтверждение удаления
  If Objects.Count <> 0 Then
    Key = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion + vbYesNo, 1607, Objects.Count)
    If Key = vbNo Then Exit Sub
  End If
  
  'Удаление связи объектов с этапом
  For Each Obj in Objects
    Call ContractStageDelete(Obj)
    ' на всю ветку вглубь
    Call ThisApplication.ExecuteScript("CMD_S_DLL", "SetAttrToContentAll", Obj,"ATTR_CONTRACT_STAGE",Nothing)
  Next
  ThisForm.Refresh
End Sub

Sub QUERY_CONTRACT_STAGE_LINKS_Selected(iItem, action)
  If iItem <> -1 Then
    ThisForm.Controls("BUTTON_DEL").Enabled = True
  Else
    ThisForm.Controls("BUTTON_DEL").Enabled = False
  End If
End Sub


Sub SetButtonsEnable(Form, Obj)
  'Права доступа
  
  
  Form.Controls("BTN_FORM_REFRESH").Enabled = True
'  Set CU = ThisApplication.CurrentUser
'  If CU.Groups.Has("GROUP_GIP") and Obj.StatusName = "STATUS_CONTRACT_STAGE_IN_WORK" Then
'    Form.Controls("BUTTON_ADD").Enabled = True
'    Form.Controls("BUTTON_DEL").Enabled = False
'  Else
'    Form.Controls("BUTTON_ADD").Enabled = False
'    Form.Controls("BUTTON_DEL").Enabled = False
'  End If
End Sub

Sub BTN_FORM_REFRESH_OnClick()
  ThisForm.Refresh
End Sub
