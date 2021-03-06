use CMD_KD_COMMON_LIB
use CMD_KD_FILE_LIB
use CMD_KD_COMMON_BUTTON_LIB  
use CMD_KD_REGNO_KIB
use CMD_KD_SET_PERMISSIONS
use CMD_KD_GLOBAL_VAR_LIB
use CMD_KD_OUT_LIB
use CMD_KD_CURUSER_LIB
'=============================================
Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  thisForm.Controls("BTN_REG").Visible = isSecretary(GetCurUser()) or thisApplication.Groups("GROUP_ID_REG").Users.has(ThisApplication.CurrentUser)

  SetChBox()
  ShowKTNo()
  ShowSysID()
  ShowBtnIcon()
'  SetProjEnable() 
      Set ctrl = thisForm.Controls("ATTR_KD_SIGNER").ActiveX
      Set query = ThisApplication.Queries("QUERY_KD_SINGERS")
      set result = query.Sheet.Users
      ctrl.ComboItems = result
  call  SetGlobalVarrible("ShowForm", thisForm.SysName)  
  RemoveGlobalVarrible("CompAuto")' чтобы перечитался список

  isSecr = isSecretary(thisApplication.CurrentUser)
'  rukEnb = thisForm.Controls("ATTR_KD_EXEC").Enabled and isSecr
  thisForm.Controls("ATTR_KD_EXEC").Enabled = isSecr
'  thisForm.Controls("ATTR_KD_CHIEF").Enabled = rukEnb
'  thisForm.Controls("BTN_DEL_CHIEF").Enabled = rukEnb

End Sub

'=============================================
sub SetChBox()
  on error resume next
  
  set chk = thisForm.Controls("TDMSED_IMP").ActiveX
  chk.buttontype = 4
  Chk.value = thisObject.Attributes("ATTR_KD_IMPORTANT").Value

  set chk = thisForm.Controls("TDMSED_URG").ActiveX
  chk.buttontype = 4
  Chk.value = thisObject.Attributes("ATTR_KD_URGENTLY").Value
  if err.Number <> 0 then 
    txt = "Произошла ошибка при сохранении документа" - err.Description
    txt = "Пожалуйста, сообщите о ней разработчикам. " & vbNewLine & "Удалите текущую карточку и создайте документ снова."
    msgbox txt, VbCritical, "Ошибка при сохранении документа"
    err.clear
  end if
  on error goto 0
end sub

'=============================================
Sub Form_BeforeClose(Form, Obj, Cancel)
  txt = ThisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "checkOutDoc", thisObject)
  if txt > ""  then 
    ans = msgbox( "Не все обязательные поля заполнены :" & vbNewLine & txt & vbNewLine , _
        vbCritical, "Создать документ невозможно!")
    Cancel = true    
    exit sub    
  end if 
  
  thisObject.Update
  thisObject.SaveChanges()   
'  call CreateMark("на контроле",thisObject, false)
  ans = msgbox("Создать документ из шаблона Word?", vbQuestion + VbYesNo, "Создать word файл?")
  if ans = vbYes then createWord() 
  
  lev = GetGlobalVarrible("WinLevel") ' т.к. форма еще не закрылась и счетчик не пересчитался
  if lev <> "" then  
    lev = lev - 1
    'call SetGlobalVarrible("WinLevel", lev) 
  end if
  if IsExistsGlobalVarrible("ToReg") then 
    RemoveGlobalVarrible("ToReg")
    Reg_Doc(obj)
    call  SetGlobalVarrible("ShowForm", "FORM_KD_OUT_CARD")  
  else
    call  SetGlobalVarrible("ShowForm", "FORM_KD_DOC_AGREE")  
  end if
 ' thisForm.Close true
  Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
  CreateObjDlg.Object = thisObject
  ans = CreateObjDlg.Show
 
  
End Sub
'=============================================
Sub BTN_SEND_TO_CHECK_OnClick()
  txt = ThisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "checkOutDoc", thisObject)
  if txt > ""  then 
    ans = msgbox( "Не все обязательные поля заполнены :" & vbNewLine & txt & vbNewLine , _
        vbCritical, "Создать документ невозможно!")
    exit sub    
  end if 
  thisObject.Update
  thisObject.SaveChanges()   
'  call CreateMark("на контроле",thisObject, false)
  
'  ans = createWord()  
'  if ans then  thisForm.Close true
  thisForm.Close true
  call  SetGlobalVarrible("ShowForm", "FORM_KD_DOC_AGREE")  
  Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
  CreateObjDlg.Object = thisObject
  ans = CreateObjDlg.Show

End Sub    
'=============================================
Sub BTN_DEL_SINGER_OnClick()
   Del_User("ATTR_KD_SIGNER")
End Sub
'=============================================
Sub BTN_DEL_CHIEF_OnClick()
   Del_User("ATTR_KD_CHIEF")
End Sub

'=============================================
Sub BTN_REG_OnClick()
  call  SetGlobalVarrible("ToReg", true)  
  thisForm.Close(true)
End Sub
