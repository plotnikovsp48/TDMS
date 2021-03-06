use CMD_KD_FOLDER
use CMD_KD_REGNO_KIB

'==============================================================================
Sub OK_OnClick()
  Set dict = ThisApplication.Dictionary("Packages")
  if dict.Exists("OK") then dict.remove("OK")
  dict.Add "OK", True
End Sub

'==============================================================================
Sub CANCEL_OnClick()
  Set Dict = ThisApplication.Dictionary("Packages")
  if dict.Exists("OK") then dict.remove("OK")
  dict.Add "OK", False
End Sub
'==============================================================================
Sub Form_BeforeClose(Form, Obj, Cancel)
  Set Dict = ThisApplication.Dictionary("Packages")
  If dict.Exists("OK") Then
    If dict("OK") Then 
      txt =""
      if Form.Attributes("ATTR_KD_DOCS_TYPE").value = "" then 
        txt = txt & "Не задан Тип документа" & vbNewLine
      end if
      if Form.Attributes("ATTR_KD_NUM").value = 0 then 
        txt = txt &  "Не задан номер документа!" & vbNewLine
'      else
'        if not CheckNoSil(Form.Attributes("ATTR_KD_NUM").value, false)  then  txt = txt &  "Номер документа уже используется!" & vbNewLine
      end if
'      if trim(Form.Attributes("ATTR_KD_EXEC").value) = "" then 
'        txt = txt &  "Не задан автор документа!" & vbNewLine
'      end if
      txt = txt & CheckCount(Form.Attributes("ATTR_MESSAGE_CODE").value)
      if txt > "" then 
          msgbox "Невозможно зарезервировать номер: " & vbNewLine & txt, vbCritical, "Невозможно зарезервировать номер!"
          Cancel = true
      else
        CreateReserveDoc()
      end if  
    end if
  end if    
  if dict.Exists("OK") then dict.remove("OK")
End Sub

'==============================================================================
Sub ATTR_KD_DOCS_TYPE_Modified()
'  dType = Form.Attributes("ATTR_KD_DOCS_TYPE").Classifier.SysName
'  dType = "OBJECT_" & Right(dType, len(dType) - 5 )
  DocName = thisForm.Attributes("ATTR_KD_DOCS_TYPE").value
  if docName = "" then
    msgbox "Не выбран тип документа", vbExclamation
    thisForm.Attributes("ATTR_KD_NUM").value = ""
    exit sub
  end if
  set objType = thisApplication.ObjectDefs(DocName)
  if objType  is nothing then
    msgbox "Неверный тип документа", vbExclamation
    exit sub
  end if
  set ObjRoots = GET_FOLDER("",objType) 
  if  ObjRoots is nothing then  
      msgBox "Не удалось создать папку", vbExclamation, "Объект не был создан"
      exit sub
  end if

  regNo = GetNewNOW(ObjRoots.Handle, objType.SysName)
  thisForm.Attributes("ATTR_KD_NUM").value = regNo
  call SetGlobalVarrible("DOC_DEF", objType.SysName)
  thisForm.Refresh
End Sub
'==============================================================================
Sub ATTR_KD_NUM_BeforeModify(Text,Cancel)
   if not CheckNo(Text,false) then
    Cancel = true
    exit sub 
  end if
End Sub
'==============================================================================
function CheckNo(RegNo, sil)  
  CheckNo = false 
  DocName = thisForm.Attributes("ATTR_KD_DOCS_TYPE").value
  if docName = "" then
    if not sil then  msgbox "Не выбран тип документа", vbExclamation
    exit function
  end if
  set objType = thisApplication.ObjectDefs(DocName)
  if objType  is nothing then
    if not sil then msgbox "Неверный тип документа", vbExclamation
    exit function
  end if
  set ObjRoots = GET_FOLDER("",objType) 
  if  ObjRoots is nothing then  
      if not sil then msgBox "Не удалось создать папку", vbExclamation, "Объект не был создан"
      exit function
  end if
'  regNo = Text 'thisForm.Attributes("ATTR_KD_NUM").value
  LetNo = CheckRegNoW(ObjRoots.Handle, objType.SysName, RegNo,0, true)
  if LetNo >"" then
    if not sil then Msgbox "Регистрационный номер " & RegNo & " присвоен другому документу ["& LetNo &"]."& vbNewLine & _
        "Введите другой номер. Резервирование номера документа отменено.", vbExclamation, "Резервирование номера документа отменено."
  else
    CheckNo = true
  end if
end function

'==============================================================================
sub CreateReserveDoc
    DocName = thisForm.Attributes("ATTR_KD_DOCS_TYPE").value
    if docName = "" then
      msgbox "Не выбран тип документа", vbExclamation
      exit sub
    end if
    set objType = thisApplication.ObjectDefs(DocName)
    if objType  is nothing then
      msgbox "Неверный тип документа", vbExclamation
      exit sub
    end if
    
    Set ObjRoots = GET_FOLDER("",objType) 
    if  ObjRoots is nothing then  
      msgBox "Не удалось создать папку", vbCritical, "Объект не был создан"
      exit sub
    end if
    txt = ""
    num = thisForm.Attributes("ATTR_KD_NUM").value
    txt = CheckCount(thisForm.Attributes("ATTR_MESSAGE_CODE").value)
    if txt > "" then 
      msgbox txt, vbExclamation
      exit sub
    end if
    count = cInt(thisForm.Attributes("ATTR_MESSAGE_CODE").value)
    for i = 1 to count
      do while not CheckNo(num, true)
        num = num + 1
      Loop
      ObjRoots.Permissions = SysAdminPermissions
      Set CreateDocObject = ObjRoots.Objects.Create(objType)
      CreateDocObject.Attributes("ATTR_KD_NUM").value = num
      CreateDocObject.Attributes("ATTR_KD_EXEC").user = thisForm.Attributes("ATTR_KD_EXEC").User
      CreateDocObject.Attributes("ATTR_KD_REG").user = thisApplication.CurrentUser
      CreateDocObject.Attributes("ATTR_KD_NOTE").value = thisForm.Attributes("ATTR_KD_NOTE").value
      CreateDocObject.Attributes("ATTR_KD_FOR_RESERVE").value = true
      CreateDocObject.Attributes("ATTR_KD_ISSUEDATE").Value = Now
      CreateDocObject.Update
      CreateDocObject.Roles.RemoveAll
      txt = txt & CStr(num) & ","
      num = num + 1
    next
    if txt = "" then 
      msgbox "Ни одного номеры не зарегистрировано!", vbExclamation
    else
      txt = Left(txt, len(txt)-1)
      msgbox "Номер(a) " & txt & " зерезервирован(ы)"
    end if 
end sub

'==============================================================================
Sub Form_BeforeShow(Form, Obj)
  call SetGlobalVarrible("DOC_DEF", "1")
  Form.Attributes("ATTR_MESSAGE_CODE").Value = 1
  form.Refresh
End Sub
'==============================================================================
Sub ATTR_MESSAGE_CODE_BeforeModify(Text,Cancel)
   txt = CheckCount(Text) 
   if txt > "" then 
    msgbox txt, vbExclamation
    Cancel = true
    exit sub 
  end if
End Sub
'==============================================================================
function CheckCount(Text)
  CheckCount = ""
  if trim(text) = "" then 
    CheckCount = "Кол-во номеров не указано!"
    exit function
  end if
  if not IsNumeric(text) then 
    CheckCount = "Кол-во номеров должно быть целым!"
    exit function
  end if
end function

Sub BUT_DEL_NUM_OnClick()
  thisScript.SysAdminModeOn
  Set s = thisForm.Controls("QUERY_GET_RESRVE_NUMS")
  set objs = s.SelectedObjects
  if objs.Count > 0 then 
    for each obj in s.SelectedObjects
      set exec = obj.Attributes("ATTR_KD_REG").user
      if not exec is nothing then 
        if not IsInCurUsers(exec) then 
          msgbox "Номер " & num &" зарезервирован другим пользователем - " & exec.description & _
              ". Удалить его нельзя", vbExclamation, "Выберите другой номер"
          exit sub
        else  
          obj.erase
        end if
      end if  
    next
  end if
End Sub