

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Set oProj = Obj.Attributes("ATTR_PROJECT").Object
  If Obj.Attributes("ATTR_PROJECT_WORK_TYPE").Classifier.Sysname = "NODE_WORK_TYPE_AUTH-SUPERVISION" Then
    Form.Controls("QUERY_PROJECTS_AN").Visible = False
  Else
    Set cCtrl = Form.Controls
    cCtrl("ATTR_PROJECTS_LINKED").Visible = False
    cCtrl("T_ATTR_PROJECTS_LINKED").Visible = False
    cCtrl("BUTTON1").Visible = False
    cCtrl("BUTTON2").Visible = False
  End If
End Sub


Sub BUTTON1_OnClick()
  ThisScript.SysAdminModeOn
  ' Отбираем объекты
  Dim q
  Set q = ThisApplication.Queries("QUERY_AN_LINKED_PROJ")
  Set Objects = q.Objects
  If Objects.Count = 0 Then
    Msgbox "Нет доступных объектов для добавления.", vbExclamation
    Exit Sub
  End If
  
  Set Rows = ThisObject.Attributes("ATTR_PROJECTS_LINKED").Rows
  Set Dlg = ThisApplication.Dialogs.SelectObjectDlg
  Dlg.SelectFromObjects = q.Objects
  If Dlg.Show Then
    If Dlg.Objects.Count <> 0 Then
      For Each o in Dlg.Objects
        Check = True
        For Each Row in Rows
          If Not Row.Attributes("ATTR_PROJECT").Object Is Nothing Then 
              If Row.Attributes("ATTR_PROJECT").Object.handle = o.handle Then
                Check = False
                Exit For
              End If
            Exit For
          End If
        Next
        If Check = True Then
          Set NewRow = Rows.Create
          NewRow.Attributes("ATTR_PROJECT").Object = o
          NewRow.Attributes("ATTR_PROJECT_GIP").User = o.Attributes("ATTR_PROJECT_GIP").User
          NewRow.Attributes("ATTR_STATUS") = o.Status.Description
        End If
      Next
    End If
  End If
 ' ThisForm.Controls("ISSUE_TASK").Enabled = CheckObj2
'  ThisForm.Controls("BUTTON_TDEPT_DEL").Enabled = CheckObj4

End Sub

Sub BUTTON2_OnClick()
  ThisScript.SysAdminModeOn
  Set Table = ThisForm.Controls("ATTR_PROJECTS_LINKED")
  Arr = Table.ActiveX.SelectedRows
  If UBound(Arr)+1 = 0 Then Exit Sub
  'Подтверждение удаления
  Key = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion + vbYesNo, 1607, UBound(Arr)+1)
  If Key = vbNo Then Exit Sub
  
  'Удаление строк
  For i = 0 to UBound(Arr)
    Set Row = Table.ActiveX.RowValue(Arr(i))    
    Row.Erase
  Next
  ThisForm.Refresh
End Sub
