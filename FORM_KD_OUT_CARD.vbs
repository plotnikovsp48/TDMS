use CMD_KD_COMMON_LIB
use CMD_KD_FILE_LIB
use CMD_KD_COMMON_BUTTON_LIB  
use CMD_KD_REGNO_KIB
use CMD_KD_SET_PERMISSIONS
use CMD_KD_OUT_LIB
use CMD_KD_CURUSER_LIB

'=============================================
Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description

  ShowUsers()
  SetChBox()
  ShowBtnIcon()
  ShowKTNo()
  SetControlsEnable() 
 'EV 2018-01-31 показываем файлы только если не стоит галка показывать по кнопке
  if thisApplication.CurrentUser.Attributes.Has("ATTR_SHOW_FILE_BY_BUTTON") then _
    if thisApplication.CurrentUser.Attributes("ATTR_SHOW_FILE_BY_BUTTON").Value <> true then _
        ShowFile(0)'(-1)'(0)
  ShowSysID()
  SetShowOldFailFlag()

  call RemoveGlobalVarrible("AgreeObj")
  call RemoveGlobalVarrible("Settings") ' EV чтобы наверняка новое значение
  call RemoveGlobalVarrible("CompAuto")' чтобы перечитался список

  call SetGlobalVarrible("ShowForm", "FORM_KD_OUT_CARD")
'  msgbox GetRecipiend
End Sub

'=============================================
sub SetChBox()
  
  set chk = thisForm.Controls("TDMSEDITCHECKSHOW").ActiveX
  chk.buttontype = 4
  Chk.value = false
  
  set chk = thisForm.Controls("TDMSED_IMP").ActiveX
  chk.buttontype = 4
  Chk.value = thisObject.Attributes("ATTR_KD_IMPORTANT").Value

  set chk = thisForm.Controls("TDMSED_URG").ActiveX
  chk.buttontype = 4
  Chk.value = thisObject.Attributes("ATTR_KD_URGENTLY").Value

      Set ctrl = thisForm.Controls("ATTR_KD_SIGNER").ActiveX
      Set query = ThisApplication.Queries("QUERY_KD_SINGERS")
      set result = query.Sheet.Users
      ctrl.ComboItems = result

end sub


'=============================================
sub SetControlsEnable()
  set curUs = GetCurUser() 

  isSecr = isSecretary(curUs)
  isSign = IsSigner(curUs, thisObject)
  stSinged = thisObject.StatusName = "STATUS_SIGNED"
  stSigning = thisObject.StatusName = "STATUS_SIGNING"
  isReg = thisObject.Attributes("ATTR_KD_NUM").Value <> "" and thisObject.Attributes("ATTR_KD_ISSUEDATE").Value <> ""

  thisForm.Controls("BTN_REG").Enabled = (isSecr or isSign) and (stSigning or stSinged) and not isReg
  thisForm.Controls("BTN_KD_APP_SCAN").Enabled = ((isSecr or isSign) and (stSigning or stSinged or thisObject.StatusName = "STATUS_SENT"))
  thisForm.Controls("BTN_OUTLOOK").Enabled = ((isSecr or isSign) and _ 
        (stSinged or stSinged or thisObject.StatusName = "STATUS_SENT"))
  thisForm.Controls("CMD_SEND_DOC").Enabled = ((isSecr or isSign) and stSinged)
  thisForm.Controls("BTN_SEND_INFO").Enabled = ((isSecr or isSign) and _ 
        (stSinged or stSinged or thisObject.StatusName = "STATUS_SENT"))
  thisForm.Controls("BUT_ADD_FILE").Enabled = CanAddFile()
  thisForm.Controls("BUT_DEL_FILE").Enabled = CanAddFile()
  thisForm.Controls("BTN_SINGED").Enabled = (isSign or isSecr) and stSigning
'  thisForm.Controls("BTN_SINGED").Visible = (isSign or isSecr) and stSigning 

  rukEnb = thisForm.Controls("ATTR_KD_EXEC").Enabled and isSecr
  thisForm.Controls("ATTR_KD_EXEC").Enabled = rukEnb
'  thisForm.Controls("ATTR_KD_CHIEF").Enabled = rukEnb
'  thisForm.Controls("BTN_DEL_CHIEF").Enabled = rukEnb



'  CMD_SEND_DOC
'  isAproving = thisObject.StatusName = "STATUS_KD_AGREEMENT"
'  isExec = IsExecutor(thisApplication.CurrentUser, thisObject)
'  isContr = IsController(thisApplication.CurrentUser, thisObject)
'  isApr = IsAprover(thisApplication.CurrentUser, thisObject)
'  isSecr = isSecretary(thisApplication.CurrentUser)
'  isSign = IsSigner(thisApplication.CurrentUser, thisObject)
'  isCanEd = isCanEdit()
'  stSinged = thisObject.StatusName = "STATUS_SIGNED"
'  stSigning = thisObject.StatusName = "STATUS_SIGNING"
'  thisForm.Controls("BTN_CREATE_WORD").Enabled = ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTNAPPWORD").Enabled = ((isExec or isContr) and isCanEd)
'  thisForm.Controls("CMD_KD_REG_DOC").Enabled = (isSecr or isSign) and stSigning
'  thisForm.Controls("CMD_RETURN_TO_WORK").Enabled = ((isSecr or isSign) and stSigning)
'  thisForm.Controls("CMD_KD_APP_SCAN").Enabled = ((isSecr or isSign) and (stSigning or stSinged))
'  thisForm.Controls("BTN_CANCEL_DOC").Enabled = ((isSecr or isSign) and stSigning) _
'    or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("CMD_SEND_DOC").Enabled = ((isSecr or isSign) and stSinged)
'  thisForm.Controls("BTN_OUTLOOK").Enabled = ((isSecr or isSign) and _ 
'        (stSinged or stSinged or thisObject.StatusName = "STATUS_SENT"))
'  thisForm.Controls("BTN_SEND_INFO").Enabled = ((isSecr or isSign) and _
'        (stSinged or thisObject.StatusName = "STATUS_SENT") )
'  thisForm.Controls("BTN_CHECKOUT").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_CHECKIN").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_LOAD_FILE").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_DEL_APP").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_FROM_ORDERS").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_SEND_TO_CHECK").Enabled = isExec and thisObject.StatusName = "STATUS_KD_DRAFT"

end sub
'=============================================
Sub BTN_DEL_SINGER_OnClick()
   Del_User("ATTR_KD_SIGNER")
End Sub
'=============================================
Sub BTN_DEL_CHIEF_OnClick()
   Del_User("ATTR_KD_CHIEF")
End Sub
'=============================================
Sub BTN_CANCEL_DOC_OnClick()
  set_Doc_Cancel
End Sub

'=============================================
Sub BTN_OUTLOOK_OnClick()

  if not CheckOutDoc then exit sub

  if not SendToOutlook() then exit sub
  
'  thisObject.Attributes("ATTR_KD_ID_SENDDATE") = Now
'  thisObject.Status = thisApplication.Statuses("STATUS_SENT")
'  thisObject.Update
  if Set_Doc_Send(true)  then   msgbox "Документ отправлен!"

End Sub
'=============================================
Sub BUT_ADD_FILE_OnClick()
   Add_application()
End Sub
'=============================================
Sub BUT_DEL_FILE_OnClick()
   DelFilesFromDoc()
   ThisObject.Update
End Sub 
'=============================================
Sub BTN_REG_OnClick()
  call Reg_Doc(thisObject)
End Sub
'=============================================
Sub BTN_SEND_INFO_OnClick()
     call Set_Send_Info(thisObject)
End Sub
'=============================================
Sub BTN_RELATIONS_OnClick()
    call SetGlobalVarrible("ShowForm", "FORM_KD_DOC_LINKS")
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = thisObject
    ans = CreateObjDlg.Show
End Sub
'=============================================
Sub BTN_HIST_OnClick()
    call SetGlobalVarrible("ShowForm", "FORM_KD_HIST")
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = thisObject
    ans = CreateObjDlg.Show

End Sub
''=============================================
'Sub BTN_ORDERS_OnClick()
'    call SetGlobalVarrible("ShowForm", "FORM_KD_DOC_ORDERS")
'    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
'    CreateObjDlg.Object = thisObject
'    ans = CreateObjDlg.Show
'End Sub

'=============================================
Sub BTN_PRINT_ARGEE_OnClick()
    set agreeObj =  thisApplication.ExecuteScript("FORM_KD_AGREE", "GetAgreeObjByObj",thisObject)
    if agreeObj is nothing then exit sub
    set file = agreeObj.Files.Main
    if File is nothing then exit sub
    file.CheckOut file.WorkFileName ' извлекаем

    Set objShellApp = CreateObject("Shell.Application") 'открываем
    objShellApp.ShellExecute "explorer.exe", file.WorkFileName, "", "", 1
    Set objShellApp = Nothing  

End Sub

'=============================================
Sub Form_BeforeClose(Form, Obj, Cancel)
  if not CheckEmptyRow(obj) then _
    Cancel = true
End Sub
'=============================================
Sub BTN_KD_APP_SCAN_OnClick()
  ClosePreview()
  LoadFileToDoc("FILE_KD_SCAN_DOC")
End Sub

'=============================================
Sub BTN_SINGED_OnClick()

  call thisApplication.ExecuteScript("FORM_KD_DOC_AGREE","Set_Doc_Signed", thisObject)
  if not isSecretary(GetCurUser()) then  thisForm.Close false
End Sub
