use CMD_KD_COMMON_LIB
use CMD_KD_COMMON_BUTTON_LIB
use CMD_KD_ORDER_LIB
use CMD_KD_USER_PERMISSIONS

'=============================================
Sub Form_BeforeShow(Form, Obj)
    SetContolEnable()  
    'ShowFile()
End Sub

'=============================================
sub ShowFile()
  set file = thisObject.Files.Main
  if File is nothing then exit sub
  fileName =  file.WorkFileName
  thisApplication.AddNotify "fileName = " &fileName
  Set FSO = CreateObject("Scripting.FileSystemObject")
  if not FSO.FileExists(fileName) then 
    thisApplication.AddNotify "file.CheckOut(fileName)"
    file.CheckOut(fileName)
  end if
  set pdfCntr = ThisForm.Controls("ACTIVEXPDF").ActiveX
  pdfCntr.LoadFile(fileName)
end sub

'=============================================
sub SetContolEnable()
  isAproving = thisObject.StatusName = "STATUS_KD_AGREEMENT"
  isExec = IsExecutor(thisApplication.CurrentUser, thisObject)
  isContr = IsController(thisApplication.CurrentUser, thisObject)
  isApr = IsAprover(thisApplication.CurrentUser, thisObject)
  isCanEd = isCanEdit()
  thisForm.Controls("BTN_SEND").Enabled = ((isExec or isContr) and isCanEd)
  thisForm.Controls("BTN_ADD_APRV").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
  thisForm.Controls("BTN_DEL_APR").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
  thisForm.Controls("BTN_APROVE").Enabled = (isApr and isAproving) 
  thisForm.Controls("BTN_REJECT").Enabled = (isApr and isAproving) 
  thisForm.Controls("BTN_APR_CHANGE").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
  thisForm.Controls("BTN_LOAD_FILE").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
  thisForm.Controls("BTN_DEL_APP").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
  thisForm.Controls("BTN_CHECKOUT").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
  thisForm.Controls("BTN_CHECKIN").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
  
  thisForm.Controls("BTN_SEND_TO_CHECK").Enabled = isExec and thisObject.StatusName = "STATUS_KD_DRAFT"
  ifSt = (thisObject.StatusName = "STATUS_KD_CHECK") or (thisObject.StatusName = "STATUS_SIGNING") _
      or(thisObject.StatusName = "STATUS_KD_AGREEMENT")
  thisForm.Controls("BTN_RETURN").Enabled = (isExec or isContr) and ifSt
  
'  thisForm.Controls("").Enabled = isApr
  
end sub

'=============================================
Sub BTN_ADD_APRV_OnClick()
  AddAprover()
end sub   

'=============================================
Sub BTN_SEND_OnClick()
    Send_to_Aprove()
End Sub

'=============================================
Sub BTN_APROVE_OnClick()
  call Aprove_Doc(thisObject)
End Sub

'=============================================
Sub BTN_REJECT_OnClick()
  call Reject_Doc(thisObject)
End Sub


'=============================================
Sub BTN_DEL_APR_OnClick()
  Set control = thisForm.Controls("QUERY_APROVE_LIST")
  DellAprovers(control)
 End Sub

'=============================================
Sub BTN_APR_CHANGE_OnClick()
  Set control = thisForm.Controls("QUERY_APROVE_LIST")
  ChangeAprover(control)
End Sub

'=============================================
Sub QUERY_APROVE_LIST_DblClick(iItem, bCancelDefault)
    call BTN_APR_CHANGE_OnClick
    
    bCancelDefault = true
    
    thisForm.Refresh() ' EV иначе не обновляемся атрибуты
End Sub

'=============================================
Sub BTN_CHECKOUT_OnClick()
  Word_Check_Out()
End Sub

'=============================================
Sub BTN_CHECKIN_OnClick()
  Word_Check_IN()
End Sub

'=============================================
Sub BTN_SEND_TO_CHECK_OnClick()
  send_To_Check()
End Sub

'=============================================
Sub BTN_RETURN_OnClick()
  return_To_Work()
End Sub
