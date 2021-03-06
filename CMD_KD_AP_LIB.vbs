use CMD_KD_COMMON_LIB

'=============================================
sub SetFieldAutoComp
      Set ctrl = thisForm.Controls("ATTR_KD_SIGNER").ActiveX
      Set query = ThisApplication.Queries("QUERY_KD_SINGERS")
      set result = query.Sheet.Users
'      set result =  thisApplication.Groups("GROUP_MEMO_CHIEFS").Users
      ctrl.ComboItems = result
      
      Set ctrl = thisForm.Controls("ATTR_KD_CPNAME").ActiveX 
      Set query = ThisApplication.Queries("QUERY_KD_CORDENT")
      set result = query.Objects
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
'=============================================
Sub BTN_DEL_EXEC_OnClick()
   Del_User("ATTR_AP_EXEC")
End Sub
'=============================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
 if Attribute.AttributeDefName = "ATTR_KD_ZA_DATEPAYMENT" then
    Text = Attribute.Value
    if isDate(Text) then
      newDate = CDate(Text)
      If newDate < Date then
        msgbox "Невозможно задать контрольную дату меньше текущей даты"
        cancel = true
      end if
    end if
  end if
End Sub

'=============================================
Sub BTN_ADD_COR_OnClick()
  frmName = thisForm.SysName
  call RemoveGlobalVarrible("ShowForm")

  set cordent =  thisApplication.ExecuteScript("FORM_KD_CORDENTS","CreateOrg")
  call SetGlobalVarrible("ShowForm",frmName)

  if not cordent is nothing then 
    SetFieldAutoComp()
    ThisForm.Attributes("ATTR_KD_CPNAME") = cordent
  end if
End Sub

'=============================================
Sub BTN_EDIT_COR_OnClick()
  set cor = thisForm.Attributes("ATTR_KD_CPNAME").Object
  if cor is nothing then exit sub
  
  frmName = thisForm.SysName
  RemoveGlobalVarrible("ShowForm")

  Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
  EditObjDlg.Object = cor
  EditObjDlg.Show  
  call SetGlobalVarrible("ShowForm",frmName)

End Sub
