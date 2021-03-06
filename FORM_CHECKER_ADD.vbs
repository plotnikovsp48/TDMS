' Форма ввода - Добавить проверяющего
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Sub Form_BeforeShow(Form, Obj)
  Str = Form.Attributes("ATTR_ATTR").Value
  If Str <> "" Then
    Form.Controls("BTN_ADD_CHECK_TYPE").Enabled = True
  End If
  If Form.Attributes("ATTR_CHECK_TYPE").Empty = False Then
'    Form.Controls("BTN_ADD_CHECK_TYPE").Enabled = False
    Form.Controls("ATTR_CHECK_TYPE").readonly = True
  End If
End Sub

'Кнопка - Выбрать вид контроля
Sub BTN_ADD_CHECK_TYPE_OnClick()
  Str = ThisForm.Attributes("ATTR_ATTR").Value
  Arr0 = Split(Str,",")
  Start = True
  Check0 = False
  Dim Arr()
  For y = 0 to Ubound(Arr0)
    Set Clf = ThisApplication.Classifiers.FindBySysId(Arr0(y))
    If not Clf is Nothing Then
      If Start = True Then
        i = -1
        Start = False
      Else
        i = Ubound(Arr)
      End If
      ReDim Preserve Arr(i+1)
      Set Arr(Ubound(Arr)) = Clf
      Check0 = True
    End If
  Next
  If Check0 = False Then Exit Sub
  
  Set Dlg = ThisApplication.Dialogs.SelectDlg
  Dlg.Caption = "Выбор вида контроля"
  Dlg.SelectFrom = Arr
  If Dlg.Show Then
    If Ubound(Dlg.Objects) > -1 Then
      Arr1 = Dlg.Objects
      Set Clf = Arr1(0)
      ThisForm.Controls("ATTR_CHECK_TYPE").Value = Clf.Description
      ThisForm.Attributes("ATTR_ATTR").Value = Clf.SysName
    End If
  End If
End Sub

Sub Ok_OnClick()
  ThisForm.Dictionary.Item("FORM_KEY_PRESSED") = True
End Sub

Sub Form_BeforeClose(Form, Obj, Cancel)
  If ThisForm.Dictionary.Item("FORM_KEY_PRESSED") = True Then
'    If ThisForm.Controls("TXT_ATTR_CHECK_TYPE").Value = "" Then
    If ThisForm.Controls("ATTR_CHECK_TYPE").Value = "" Then
      qmess = MsgBox("Внимание! Вы не указали вид контроля " & vbCrLf & _
      "Вернуться и указать вид контроля?",vbQuestion+vbYesNo)
      If qmess = vbYes Then 
        Cancel = True
      Else
        ThisForm.Dictionary.Item("FORM_KEY_PRESSED") = False
      End If
    ElseIf ThisForm.Attributes("ATTR_USER").Empty = True Then
      qmess = MsgBox("Внимание! Вы не указали сотрудника " & vbCrLf & _
      "Вернуться и указать сотрудника?",vbQuestion+vbYesNo)
      If qmess = vbYes Then 
        Cancel = True
      Else
        ThisForm.Dictionary.Item("FORM_KEY_PRESSED") = False
      End If
    End If 
  End If
End Sub

Sub ATTR_USER_BeforeAutoComplete(Text)
  if Len(text)>0 then
    Set source = GetUserSource()
    ThisForm.Controls("ATTR_USER").ActiveX.ComboItems = source
  End If
End Sub

Sub ATTR_USER_ButtonClick(Cancel)
  Set source = GetUserSource()
    set dlg = ThisApplication.Dialogs.SelectUserDlg
    dlg.SelectFromUsers = source
    RetVal = dlg.Show
   
    If (RetVal<>TRUE) Or (dlg.Users.Count=0) Then 
      Cancel = True 
      Exit Sub
    End If
    
    ThisForm.Controls("ATTR_USER").Value = dlg.Users(0)
   
    cancel = True
End Sub

Function GetUserSource()
  Set GetUserSource = Nothing
  check = ThisForm.Controls("ATTR_CHECK_TYPE")
  Set source = Nothing
  Set cls = ThisApplication.Classifiers("NODE_CHECK_TYPE").Classifiers.Find(check)
  If Not cls Is Nothing Then
    If cls.code = "nk" Then
      Set source = ThisApplication.Groups("GROUP_NK").Users
    ElseIf cls.code = "approve" Then
      Set source = ThisApplication.Groups("GROUP_GIP").Users
    ElseIf cls.code = "deptchief" Then
      Set source = ThisApplication.Groups("GROUP_LEAD_DEPT").Users
    End If
  End If
  
  If Source Is Nothing Then Set source = ThisApplication.Groups("ALL_USERS").Users
  Set GetUserSource = source
End Function

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  If Attribute.AttributeDefName = "ATTR_CHECK_TYPE" Then
    checkcode = vbNullString
    Set cls = Attribute.Classifier
    If Not cls Is Nothing Then
      Form.Attributes("ATTR_ATTR").Value = cls.SysName
      checkcode = cls.Code
    End If
    Set BaseObj = Form.Attributes("ATTR_OBJECT").Object
    Form.Attributes("ATTR_USER").User = _
          ThisApplication.ExecuteScript("CMD_PROJECT_DOCS_LIBRARY","GetDefaultCheckUser",BaseObj,checkcode)
    Form.Refresh
  End If
End Sub

