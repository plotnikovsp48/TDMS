

Sub Form_BeforeClose(Form, Obj, Cancel)

  if trim(Form.Attributes("ATTR_NAME").Value) = "" then  
      msgbox "Не задано значение свойста Наименование", vbCritical, "Ошибка"
      cancel = true
      exit sub
  end if

''  Set Dict = ThisApplication.Dictionary("Close")
''  If dict.Exists("OK") Then
''    If dict("OK") Then 
'        str = ""
'        for each attr in Form.Attributes
'          if trim(attr.value) = "" then 
'            str = str & "Не задано значение свойста " & Attr.Description & vbNewLine
'          end if
'        next
'        if str>"" then 
'          msgbox str, vbCritical, "Ошибка"
'          Cancel = true
'        end if
''    end if
''  end if    
''  if dict.Exists("OK") then dict.remove("OK")
End Sub

Sub OK_OnClick()
  Set dict = ThisApplication.Dictionary("Close")
  if dict.Exists("OK") then dict.remove("OK")
  dict.Add "OK", True
End Sub

Sub CANCEL_OnClick()
  Set Dict = ThisApplication.Dictionary("Close")
  if dict.Exists("OK") then dict.remove("OK")
  dict.Add "OK", False
End Sub
