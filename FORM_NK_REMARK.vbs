USE "CMD_DLL_ROLES"

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Set cCtrl = Form.Controls
'  If cCtrl("ATTR_DATA").Value="" Then cCtrl("ATTR_DATA") = ThisApplication.CurrentTime
'  If cCtrl("ATTR_USER").Value="" Then cCtrl("ATTR_USER") = ThisApplication.CurrentUser
  If ThisForm.Controls("ATTR_NK_RESULTS_QUANTITY") = "" Then ThisForm.Controls("ATTR_NK_RESULTS_QUANTITY").Value = 0
  
  Call SetReadOnlyForControls(cCtrl)
  Form.Refresh
End Sub

Sub CMD_Q_INCREASE_OnClick()
  ThisForm.Controls("ATTR_NK_RESULTS_QUANTITY").Value = ThisForm.Controls("ATTR_NK_RESULTS_QUANTITY").Value + 1
End Sub


Sub CMD_Q_DECREASE_OnClick()
  If ThisForm.Controls("ATTR_NK_RESULTS_QUANTITY").Value > 0 Then
    ThisForm.Controls("ATTR_NK_RESULTS_QUANTITY").Value = ThisForm.Controls("ATTR_NK_RESULTS_QUANTITY").Value - 1
  End If
End Sub

Sub CMD_CLOSE_REMARK_OnClick()
  ThisForm.Controls("ATTR_NK_RESULTS_CORRECTED") = True
  Call SetReadOnlyForControls(cCtrl)
End Sub

Sub SetReadOnlyForControls(cCtrl)
  Set cCtrl = ThisForm.Controls
  Set CU = ThisApplication.CurrentUser
  
  IsGroupMem = IsGroupMember(ThisApplication.CurrentUser,"GROUP_NK")
  
  ' Блокируем контролы, если:
  ' 1. пользователь не является членом группы или
  ' 2. Замечание закрыто или
  ' 3. Замечание оставлено другим пользователем
  ro = ((Not IsGroupMem) AND (Not IsUserComment(cCtrl))) Or IsClosed(cCtrl)
  
    isEdit = ObjNKIsOnNK()
    For Each c In cCtrl
      If (c.Name <> "ATTR_OBJECT") And (c.Name <> "ATTR_DATA") And (c.Name <> "ATTR_USER") Then
        c.ReadOnly = ro Or (Not isEdit)
      End If
    Next
End Sub

Function ObjNKIsOnNK()
  ObjNKIsOnNK = False
  Set Obj = ThisForm.Attributes("ATTR_OBJECT").Object
  If Obj Is Nothing Then Exit Function
  Set NKObj = ThisApplication.ExecuteScript("CMD_SS_LIB", "GetInspectionObject", Obj)
  If NKObj Is Nothing Then Exit Function
  If NKObj.StatusName <> "STATUS_NK" Then Exit Function
  ObjNKIsOnNK = True
End Function

Function IsClosed(cCtrl)
  IsClosed = False
  If cCtrl("ATTR_NK_RESULTS_CORRECTED").Value <> "" Then
    If cCtrl("ATTR_NK_RESULTS_CORRECTED").Value  Then
      IsClosed = True
    End If
  End If
End Function

Function IsUserComment(cCtrl)
  IsUserComment = False
  If cCtrl("ATTR_USER") = ThisApplication.CurrentUser.Description Then
    IsUserComment = True
  End If
End Function

Sub Form_BeforeClose(Form, Obj, Cancel)
  Set Dict = ThisApplication.Dictionary("FORM_NK_REMARK")
  If Dict.Item("FORM_KEY_PRESSED") = True Then
    Cancel = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckBeforeClose",Obj)
  End If
End Sub

Sub CMD_ADD_FILE_OnClick()
  Call ThisApplication.ExecuteScript("OBJECT_NK","AddFile",ThisObject)
End Sub

Sub Ok_OnClick()
  ThisApplication.Dictionary("FORM_NK_REMARK").Item("FORM_KEY_PRESSED") = True
End Sub

Sub Cancel_OnClick()
  ThisApplication.Dictionary("FORM_NK_REMARK").Item("FORM_KEY_PRESSED") = False
End Sub
