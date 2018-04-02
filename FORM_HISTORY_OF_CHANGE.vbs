
'Процедура добавления строки в таблицу История состояний
'Obj - ссылка на объект, статус которого меняется
Sub TEventStatusChanges(Obj)
  ThisScript.SysAdminModeOn
  If Obj.Attributes.Has("ATTR_CONTRACT_TEVENT_TYPE") Then
    Set TableRows = Obj.Attributes("ATTR_CONTRACT_TEVENT_TYPE").Rows
    Set NewRow = TableRows.Create
    If not Obj.Status is Nothing Then
      NewRow.Attributes("ATTR_CONTRACT_STATUS_PREV").Value = Obj.Status.Description
    End If
    NewRow.Attributes("ATTR_DATA").Value = Date
    NewRow.Attributes("ATTR_USER").User = ThisApplication.CurrentUser
  End If
End Sub

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
End Sub