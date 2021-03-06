' Форма ввода - План внешних закупок
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

'USE "CMD_FILES_LIBRARY"

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
End Sub

'Событие - Выделен объект в выборке
Sub QUERY_TENDER_OUTSIDE_PLAN_Selected(iItem, action)
  Check = True
  Set CU = ThisApplication.CurrentUser
'  Set Roles = ThisObject.RolesForUser(ThisApplication.CurrentUser)
  'If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") = False Then Check = False
  If CU.Groups.Has("GROUP_TENDER") = True Then
  Set Query = ThisForm.Controls("QUERY_TENDER_OUTSIDE_PLAN")
  For Each Obj in Query.SelectedObjects
'  msgbox Obj.StatusName
    If Obj.StatusName <> "STATUS_TENDER_OUT_PLANING" Then
      Check = False
      Exit For
    End If
  Next
'  msgbox iItem & " " & Action & " " & Check
  If iItem <> -1 and Action = 2 and Check = True Then
    ThisForm.Controls("BUTTON_CLOSE").Enabled = True
    ThisForm.Controls("BUTTON_ACCEPT").Enabled = True
  Else
    ThisForm.Controls("BUTTON_CLOSE").Enabled = False
    ThisForm.Controls("BUTTON_ACCEPT").Enabled = False
  End If
 End If
End Sub

'Кнопка - Одобрить
Sub BUTTON_ACCEPT_OnClick()
  ThisScript.SysAdminModeOn
  Set Query = ThisForm.Controls("QUERY_TENDER_OUTSIDE_PLAN")
  'Если выделено несколько строк
  If Query.SelectedObjects.Count > 0 Then
    Key = Msgbox("Одобрить выбранные закупки?",vbQuestion+vbYesNo)
    If Key = vbYes Then
      For Each Obj in Query.SelectedObjects
        ThisApplication.ExecuteScript "CMD_PURCHASE_OUTSIDE_TO_ADD_APPROVED", "Main",Obj
      Next
    End If
  End If
  ThisScript.SysAdminModeOff
End Sub

'Кнопка - Закрыть
Sub BUTTON_CLOSE_OnClick()
  ThisScript.SysAdminModeOn
  Set Query = ThisForm.Controls("QUERY_TENDER_OUTSIDE_PLAN")
  'Если выделено несколько строк
  If Query.SelectedObjects.Count > 0 Then
    Key = Msgbox("Закрыть выбранные закупки?",vbQuestion+vbYesNo)
    If Key = vbYes Then
      For Each Obj in Query.SelectedObjects
        ThisApplication.ExecuteScript "CMD_PURCHASE_OUTSIDE_TO_CLOSE", "Main",Obj
      Next
    End If
  End If
  ThisScript.SysAdminModeOff
End Sub


