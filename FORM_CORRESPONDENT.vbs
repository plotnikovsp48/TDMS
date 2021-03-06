use CMD_KD_COMMON_LIB
use CMD_KD_COMMON_BUTTON_LIB
'=================================
Sub Form_BeforeClose(Form, Obj,Cancel)
 if obj is nothing then exit sub
 if not CheckFormComplete then
    'MsgBox "Поля формы содержат ошибки",vbExclamation,"Сохранение невозможно"  
    Cancel = true
    exit sub
 end if
 if thisForm.Controls("QUERY_USER_BY_CORDENT").ActiveX.count = 0 then 
    ans = msgbox("Для корреспондента " & obj.Description & "  не создано ни одного контактного лица. " & _ 
      "Вы уверены, что хотите сохранить корреспондента в любом случае?", vbQuestion + vbYesNo, "Сохранить корреспондента?")
    if ans = vbNo then cancel = true
'    msgbox "Невозможно сохранить Корреспондента, т.к. не добавлено ни одно контактное лицо", vbCritical, _
'      "Сохранение отменено"
'    cancel = true
 end if
end sub

'=================================
'Проверка правильности заполнения полей формы
function CheckFormComplete 
  if IsEmpty(ThisObject) then exit function

  CheckFormComplete = false
  txt = ""
  if ThisObject.Attributes("ATTR_CORDENT_NAME").Value = "" then _
      txt = txt & "Не задано наименование организации" & vbNewLine
  if ThisObject.Attributes("ATTR_S_JPERSON_ORG_TYPE").Value = "" then _
      txt = txt & "Не задана организационно-правовая форма " & vbNewLine
'  if ThisObject.Attributes("ATTR_S_JPERSON_TIN").Value = "" then _
'      txt = txt & "Не задан ИНН" & vbNewLine
  if txt = "" then   
    CheckFormComplete = true
  else
    msgbox "Не все обязательные поля заданы:" & vbNewLine & txt, vbCritical, "Сохранение невозможно"
  end if  

end function

'=================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  call ClearAttribute(Attribute.AttributeDefName)
  select case Attribute.AttributeDefName 
    case "ATTR_CORDENT_FAX","ATTR_CORDENT_TELEPHONE" 
        call CheckPhoneNumber(thisObject.Attributes(Attribute.AttributeDefName).Value) 
        'cancel = true
    case "ATTR_CORDENT_EMAIL"   
        call CheckEMail(ThisObject.Attributes(Attribute.AttributeDefName).Value,false)
        'cancel = true
    case "ATTR_S_JPERSON_TIN"
      if Attribute.Value<> "" then 
        if not CheckINN(Attribute) then 
            'cancel = true
            'thisObject.Attributes("ATTR_S_JPERSON_TIN").Value = Attribute.Value
        end if   
      end if   
  end select       
End Sub 


'=================================
'Sub ATTR_S_JPERSON_TIN_BeforeModify(Text,Cancel)
function  CheckINN(Attribute) 
  CheckINN = false
  text = Attribute.Value 
  if Text = "" then exit function
  l = len(Text)
  if not(l = 10 or l = 12) then  
      msgbox "Длина ИНН может быть 10 или 12 символов", vbCritical, "Неверно задан ИНН"
'      thisObject.Attributes("ATTR_S_JPERSON_TIN").Value = text  
      exit function
  end if
    Set Q = thisApplication.Queries("QUERY_CHECK_INN")
    Q.Parameter("PARAM0") = thisObject.Handle
    Q.Parameter("PARAM1") = text
    
    Set Objs = Q.Objects
    if Objs.Count > 0 then 
      set selObj = thisApplication.Dialogs.SelectObjectDlg
      selObj.Prompt = "Корреспондент с указанным номер уже существует"
      SelObj.SelectFromObjects = Objs
      RetVal = selObj.Show 
      exit function
    end if
   CheckINN = true 
End function

'=================================
Sub BTN_ADD_NAME_OnClick()
  if not CheckFormComplete then exit sub
  thisScript.SysAdminModeOn
  thisObject.Permissions = SysAdminPermissions

    ThisObject.Update
    call thisApplication.ExecuteScript("OBJECT_CORRESPONDENT","CreateCopyPerson", thisObject)
End Sub

'=================================
Sub Form_BeforeShow(Form, Obj)
  ShowBtnIcon()
  Set ctrl = thisForm.Controls("ATTR_CORDENT_NAME").ActiveX
  Set query = ThisApplication.Queries("QUERY_KD_CORDENT")
  set result = query.Objects
  ctrl.ComboItems = result

End Sub

'=================================
Sub BTN_ADD_USER_OnClick()
  if not CheckFormComplete then exit sub
  thisScript.SysAdminModeOn
  thisObject.Permissions = SysAdminPermissions
  ThisObject.Update
  set objType = thisApplication.ObjectDefs("OBJECT_CORR_ADDRESS_PERCON")
  Set persObj = thisObject.Objects.Create(objType)
  if persObj is nothing then 
    msgbox "Неудалось создать пользователя!", vbCritical, "Ошибка!"
    exit sub
  end if
 Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
 CreateObjDlg.Object = persObj
 ans = CreateObjDlg.Show
 
End Sub
'=================================
Sub ATTR_CORDENT_NAME_Modified()
'  val = thisForm.Controls("ATTR_CORDENT_NAME").Value 
''  thisObject.Attributes("ATTR_KB_POR_RESULT").Value = val
'  Set ctrl = thisForm.Controls("ATTR_CORDENT_NAME").ActiveX
'  res = ctrl.ComboItems
  if CheckCorName() then 
     ans =  msgbox("Контрагент с таким наименование уже существует." & vbNewLine & _
        "Вы уверенны, что хотите создать еще одного контагента с таким же наименование?" & vbNewLine & _
        "Продолжить редактирование?" & vbNewLine & _
        "Нажмите да, чтобы продолжить редактирование"& vbNewLine & _
        "Нажмите нет, чтобы отменить введенные данные", vbYesNo, "Продолжить редактирование?")
     if ans <> vbYes then 
 '       thisObject.saveChanges(32)' Update
        thisForm.Close false
'        thisObject.Erase
     end if
  end if
End Sub
'=================================
function CheckCorName()
  CheckCorName = false
  set qry = thisApplication.Queries("QUERY_KD_CHECK_COR_NAME")
  qry.Parameter("PARAM0") = thisForm.Controls("ATTR_CORDENT_NAME").Value 
  qry.Parameter("PARAM1") = thisObject.Handle
  set sh = qry.Sheet
  if sh.RowsCount > 0 then CheckCorName = true
end function
'=================================
Sub BTN_DEL_PERS_OnClick()
    set s = thisForm.Controls("QUERY_USER_BY_CORDENT").SelectedObjects
    selCount = s.Count
    if s.Count = 0 then 
      msgbox "Не выбрана ни одна строка!", VbOKOnly+vbExclamation, "Выберите строку!"
      exit sub
    end if
    
    str = "Вы уверены, что хотите удалить " & vbNewLine & s(0).Description
    if selCount > 1 then _
        str = str & " и еще " & CStr(selCount - 1) & " строк(и)"
    str = str & "?"    
    Answer = MsgBox(  str, vbQuestion + vbYesNo,"Удалить?")
    if Answer <> vbYes then exit sub
    
    on error resume next
    for i = 0 to selCount - 1
        s(0).Erase
    next
    if err.Number <> 0 then err.Clear
    on error goto 0

End Sub
