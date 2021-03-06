'use CMD_KD_COMMON_LIB
'use CMD_KD_FILE_LIB
use CMD_KD_COMMON_BUTTON_LIB  
'use CMD_KD_REGNO_KIB
'use CMD_KD_SET_PERMISSIONS
'use CMD_KD_GLOBAL_VAR_LIB
'use CMD_KD_OUT_LIB  
use CMD_KD_AP_LIB
'=============================================
Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description

  SetChBox()
  ShowKTNo()
  ShowSysID()
  ShowBtnIcon()
  SetFieldAutoComp()
  call  SetGlobalVarrible("ShowForm", "FORM_KD_AP_CREATE")  
End Sub
''=============================================
'Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
'  if Attribute.AttributeDef.SysName = "ATTR_KD_SIGNER" then 
'    if attribute.Value <> "" then 
'      'отдел
'      set dept = Get_Dept(Attribute.User)
'      if dept is nothing then 
'          msgbox "Для " & Attribute.User.Description & " не задан отдел. ", VbCritical, "Не возможно создать документ!"
'          Cancel = true
'          exit sub
'      end if
'      if thisObject.Attributes("ATTR_KD_DEPART").Value <> dept.Description then 
'        thisObject.Attributes("ATTR_KD_DEPART").Value = dept
'        thisForm.Attributes("ATTR_KD_DOC_PREFIX").Value = Get_Prifix(thisObject) 
'        thisForm.Refresh
'      end if 
'    end if
'  end if
'End Sub

'=============================================
Sub Form_BeforeClose(Form, Obj, Cancel)
  txt = ThisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "checkPayment", thisObject)
  if txt > ""  then 
    ans = msgbox( "Не все обязательные поля заполнены :" & vbNewLine & txt & vbNewLine , _
        vbCritical, "Создать документ невозможно!")
    Cancel = true    
    exit sub    
  end if 
' thisObject.Update
  thisObject.SaveChanges()   

'  call CreateMark("на контроле",thisObject, false)  

  lev = GetGlobalVarrible("WinLevel") ' т.к. форма еще не закрылась и счетчик не пересчитался
  if lev <> "" then  
    lev = lev - 1
    'call SetGlobalVarrible("WinLevel", lev) 
  end if

  call  SetGlobalVarrible("ShowForm", "FORM_KD_DOC_AGREE")  
  Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
  CreateObjDlg.Object = thisObject
  ans = CreateObjDlg.Show
End Sub

