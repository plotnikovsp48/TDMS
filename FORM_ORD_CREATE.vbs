use CMD_KD_COMMON_LIB
'use CMD_KD_FILE_LIB
use CMD_KD_COMMON_BUTTON_LIB  
use CMD_KD_REGNO_KIB
'use CMD_KD_SET_PERMISSIONS
'use CMD_KD_GLOBAL_VAR_LIB
'use CMD_KD_OUT_LIB  
'=============================================
Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description

  SetChBox()
  ShowKTNo()
  ShowSysID()
  ShowBtnIcon()
  SetFieldAutoComp()
  call  SetGlobalVarrible("ShowForm", "FORM_ORD_CREATE")  
End Sub
'=============================================
sub SetFieldAutoComp
      Set ctrl = thisForm.Controls("ATTR_KD_SIGNER").ActiveX
'      Set query = ThisApplication.Queries("QUERY_KD_SINGERS")
'      set result = query.Sheet.Users
      set result =  thisApplication.Groups("GROUP_MEMO_CHIEFS").Users
      ctrl.ComboItems = result
end sub
'=============================================
sub SetChBox()
  set chk = thisForm.Controls("TDMSED_IMP").ActiveX
  chk.buttontype = 4
  Chk.value = thisObject.Attributes("ATTR_KD_IMPORTANT").Value

  set chk = thisForm.Controls("TDMSED_URG").ActiveX
  chk.buttontype = 4
  Chk.value = thisObject.Attributes("ATTR_KD_URGENTLY").Value
end sub
'=============================================
Sub BTN_DEL_SINGER_OnClick()
   Del_User("ATTR_KD_SIGNER")
End Sub
''=============================================
'Sub ATTR_KD_WITHOUT_PROJ_Modified()
'  SetProjEnable()
'End Sub
'=============================================
'sub SetProjEnable()
'  isEnabled = not thisObject.Attributes("ATTR_KD_WITHOUT_PROJ").Value
'  thisForm.Controls("CMD_KD_ADD_CONTR").Enabled = isEnabled
'  thisForm.Controls("CMD_KD_DEL_CONTR").Enabled = isEnabled
'  thisForm.Controls("CMD_KD_ADD_PROJ").Enabled = isEnabled
'  thisForm.Controls("BTN_DEL_PRO").Enabled = isEnabled
'end sub
'=============================================
Sub BTN_SEND_TO_CHECK_OnClick()
  txt = ThisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "CheckOPDField", thisObject)
  if txt > ""  then 
    ans = msgbox( "Не все обязательные поля заполнены :" & vbNewLine & txt & vbNewLine & _
        "Хотите создать документ в любом случае?" & vbNewLine & "Нажмите Да, чтобы создать документ," & _
        " нажмите Нет, чтобы продолжить редактирование", _
        VbYesNo + vbExclamation, "Cоздать документ?")
    if ans = vbNo then exit sub    
  end if 
  thisObject.Update
  thisObject.SaveChanges()   
'  call CreateMark("на контроле",thisObject, false)
  
  thisForm.Close true
  call  SetGlobalVarrible("ShowForm", "FORM_KD_DOC_AGREE")  
  Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
  CreateObjDlg.Object = thisObject
  ans = CreateObjDlg.Show
End Sub    
'=============================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  if Attribute.AttributeDef.SysName = "ATTR_KD_SIGNER" then 
    if attribute.Value <> "" then 
      'отдел
      set dept = Get_Dept(Attribute.User)
      if dept is nothing then 
          msgbox "Для " & Attribute.User.Description & " не задан отдел. ", VbCritical, "Не возможно создать документ!"
          Cancel = true
          exit sub
      end if
      if thisObject.Attributes("ATTR_KD_DEPART").Value <> dept.Description then 
        thisObject.Attributes("ATTR_KD_DEPART").Value = dept
        thisForm.Attributes("ATTR_KD_DOC_PREFIX").Value = Get_Prifix(thisObject) 
        thisForm.Refresh
      end if 
    end if
  end if
End Sub
'=============================================
Sub ATTR_KD_PR_TYPEDOC_Modified()
'   thisForm.Attributes("ATTR_KD_DOC_PREFIX").Value = Get_Prifix(thisObject) 
   thisForm.Attributes("ATTR_KD_SUFFIX").Value = Get_Suffix(thisObject) 
   thisForm.Refresh
End Sub

'=============================================
Sub Form_BeforeClose(Form, Obj, Cancel)
  txt = ThisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "CheckOPDField", thisObject)
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

 ' thisForm.Close true
  call  SetGlobalVarrible("ShowForm", "FORM_KD_DOC_AGREE")  
  Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
  CreateObjDlg.Object = thisObject
  ans = CreateObjDlg.Show


End Sub
