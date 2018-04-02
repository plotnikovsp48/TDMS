

Sub Form_BeforeShow(Form, Obj)
  if form.Attributes("ATTR_KD_FIO").Value = "" then _
    form.Attributes("ATTR_KD_FIO").Value = GetFIO(form)
End Sub

function GetFIO(Obj)
  GetFIO = ""
end function

Sub Form_BeforeClose(Form, Obj, Cancel)

  txt = ""
  if trim(Form.Attributes("ATTR_KD_DEPART").Value) = "" then  
      txt = txt & "Не задано значение свойства Площадка"
  end if
  if trim(Form.Attributes("ATTR_KD_USER_DEPT").Value) = "" then  
       txt = txt & "Не задано значение свойства Элемент оргструктуры"
      'cancel = true
      'exit sub
  end if
  
  if txt<>"" then msgbox "Не задано значение свойства Площадка", vbCritical, "Ошибка"

'  str = ""
'  for each attr in Form.Attributes
'    if attr.AttributeDef.Type <> 11 then 
'      if attr.AttributeDef.Type = 1 then 
'        val = "0"
'      else
'        val = "" 
'      end if   
'      if trim(attr.value) = val then 
'        str = str & "Не задано значение свойства " & Attr.Description & vbNewLine
'  '      cancel = true
'  '      exit sub
'      end if
'    end if  
'  next
'  if str >"" then 
'    msgbox str, vbCritical, "Ошибка"
'    cancel = true
'  end if  
End Sub

Sub ATTR_KD_USER_DEPT_ButtonClick(Cancel)
  bCancelDefaultOperation = true
  set root = thisApplication.GetObjectByGUID("{4E01EB03-F956-4D48-A221-1C3ADB8C1EA4}")
  if root is nothing then 
    msgbox "Не найдена оргструктура", vbCritical
    Cancel = true
    exit sub
  end if
  set dlg = thisApplication.Dialogs.SelectObjectDlg
  dlg.Root = root
  if dlg.Show then 
    thisform.Controls("ATTR_KD_USER_DEPT").Value = dlg.Objects(0)
  else
    cancel =  true
  end if

  bCancelDefaultOperation = true

End Sub
