'use CMD_KD_COMMON_LIB
'use CMD_KD_FILE_LIB
use CMD_KD_COMMON_BUTTON_LIB  
'use CMD_KD_REGNO_KIB
'use CMD_KD_SET_PERMISSIONS
'use CMD_KD_GLOBAL_VAR_LIB
'use CMD_KD_OUT_LIB
use CMD_KD_MEMO_LIB
'=============================================
Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description

  SetChBox()
  ShowKTNo()
  ShowSysID()
'  SetProjEnable()
  EnabledCtrl()
  SetFieldAutoComp() 
  ShowBtnIcon()
'  thisForm.Controls("BTN_SEND_TO_CHECK").Visible = (thisObject.StatusName = "STATUS_KD_DRAFT")
  call  SetGlobalVarrible("ShowForm", "FORM_KD_MEMO_CREATE")  
End Sub

'=============================================
Sub BTN_SEND_TO_CHECK_OnClick()
  txt = ThisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "CheckMemoField", thisObject)
  if txt > ""  then 
    ans = msgbox( "Не все обязательные поля заполнены :" & vbNewLine & txt & vbNewLine  _
        , vbCritical, "Невозможно создать документ")
    exit sub    
  end if 
  thisObject.Update
  thisObject.SaveChanges()   
'  call CreateMark("на контроле",thisObject, false)
  
  thisForm.Close true
  call  SetGlobalVarrible("ShowForm", "FORM_KD_MEMO_CARD")  
  Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
  CreateObjDlg.Object = thisObject
  ans = CreateObjDlg.Show
End Sub                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   

'=============================================
Sub Form_BeforeClose(Form, Obj, Cancel)
  txt = ThisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "CheckMemoField", thisObject)
  if txt > ""  then 
    ans = msgbox( "Не все обязательные поля заполнены :" & vbNewLine & txt & vbNewLine  _
        , vbCritical, "Невозможно создать документ")
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
  call  SetGlobalVarrible("ShowForm", "FORM_KD_MEMO_CARD")  
  Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
  CreateObjDlg.Object = thisObject
  ans = CreateObjDlg.Show


End Sub
'=============================================
sub EnabledCtrl()
  set curUs = GetCurUser() 

  isSec = isSecretary(curUs)
  thisform.Controls("ATTR_KD_EXEC").ReadOnly = not isSec
end sub
