' Форма ввода - Регистрация
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
'  Form.Attributes("ATTR_DATA").Value = Date
  Set Dict = Form.Dictionary
  Dict.Item("DATA") = FormatDateTime(Date, vbShortDate)
  Form.Attributes("ATTR_DATA").Value = Dict.Item("DATA")
  Form.Controls("TXT_ATTR_REG").Value = ThisApplication.CurrentUser.Description
End Sub

Sub Form_BeforeClose(Form, Obj, Cancel)
  Set ObjToReg = ThisForm.Attributes("ATTR_OBJECT").Object
  Set Dict = Form.Dictionary
  If Dict.Item("BUTTON") = True Then
    Key = ThisApplication.ExecuteScript("CMD_MESSAGE","ShowWarning",vbQuestion+vbYesNo,1051,ObjToReg.ObjectDef.Description, ObjToReg.Description, Form.Attributes("ATTR_REG_NUMBER"))
    If Key = vbYes Then
      If Dict.Item("BUTTON") = True Then
        If Form.Attributes("ATTR_REG_NUMBER").Empty = False Then 'and Form.Attributes("ATTR_DATA").Empty = False Then
          'Dict.Item("DATA") = Form.Attributes("ATTR_DATA").Value
          'Dict.Item("NUM") = ""
          Dict.Item("REGNUM") = Form.Attributes("ATTR_REG_NUMBER").Value
        Else
          Key = MsgBox("Внимание! Должны быть заполнены ""Дата"", ""Регистрационный №""" & _
          chr(10) & "Вернуться и заполнить поля?",vbQuestion+vbYesNo)
          If Key = vbYes Then 
            Cancel = True
            Exit Sub
          End If
        End If
      End If
    End If
  End If
End Sub

'Кнопка - Автоматически
Sub BUTTON_AUTO_OnClick()
  Set Obj = ThisForm.Attributes("ATTR_OBJECT").Object
'  Key = ThisApplication.ExecuteScript("CMD_MESSAGE","ShowWarning",vbQuestion+vbYesNo,1051,Obj.Description)
'  If Key = vbYes Then
    RegNum = ""
    If Obj.ObjectDefName = "OBJECT_CONTRACT" Then
      RegNum = ThisApplication.ExecuteScript("CMD_S_NUMBERING","ContractRegNumGet",Obj,ThisForm.Attributes("ATTR_DATA").Value)
      If RegNum <> "" Then
        Arr = Split(RegNum,"#")
        Num = cLng(Arr(1))
        RegNum = Join(Arr,"")
      End If
    ElseIf Obj.ObjectDefName = "OBJECT_INVOICE" Then
      RegNum = ThisApplication.ExecuteScript("CMD_S_NUMBERING","InvoiceRegNumGet",Obj,ThisForm.Attributes("ATTR_DATA").Value)
      Num = RegNum
    ElseIf Obj.ObjectDefName = "OBJECT_AGREEMENT" Then
      RegNum = ThisApplication.ExecuteScript("CMD_S_NUMBERING","AgreementRegNumGet",Obj,ThisForm.Attributes("ATTR_DATA").Value)
      Num = RegNum
    ElseIf Obj.ObjectDefName = "OBJECT_CONTRACT_COMPL_REPORT" Then
      RegNum = ThisApplication.ExecuteScript("CMD_S_NUMBERING","CCRRegNumGet",Obj,ThisForm.Attributes("ATTR_DATA").Value)
      Num = RegNum
    End If
    If RegNum <> "" Then
      ThisForm.Attributes("ATTR_REG_NUMBER").Value = RegNum
      Set Dict = ThisForm.Dictionary
'      Dict.Item("DATA") = FormatDateTime(ThisForm.Attributes("ATTR_DATA").Value, vbShortDate)
      Dict.Item("REGNUM") = RegNum
      Dict.Item("NUM") = Num
      Dict.Item("BUTTON") = True
      'ThisForm.Close
      'Exit Sub
    End If
'  End If
End Sub

Sub Ok_OnClick()
  ThisForm.Dictionary.Item("BUTTON") = True
End Sub

Sub Cancel_OnClick()
  ThisForm.Dictionary.Item("BUTTON") = False
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  If Attribute.AttributeDefName = "ATTR_DATA" Then
    Set Dict = ThisForm.Dictionary
    Dict.Item("DATA") = FormatDateTime(ThisForm.Attributes("ATTR_DATA").Value, vbShortDate)
  End If
End Sub
