USE "CMD_KD_LIB_DOC_IN"
use CMD_KD_COMMON_LIB
use CMD_KD_REGNO_KIB

'=============================================
Sub Form_BeforeShow(Form, Obj)
    ShowUsers()
    SetContolEnable()
End Sub

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
'  thisForm.Controls("BTN_RETURN").Enabled = (isExec or isContr) and ifSt
  
end sub

'=============================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  if form.Controls.Has("TXT_" & Attribute.AttributeDefName) then ShowUser(Attribute.AttributeDefName)
End Sub

'=============================================
Sub BTN_PRINT_MEMO_OnClick()
  msgbox "Раздел находится в разработке"
End Sub

'=============================================
Sub BTN_LOAD_FILE_OnClick()
   Add_application()
End Sub

'=============================================
Sub BTN_CREATE_DOC_OnClick()
  msgBox "Раздел находится в разработке"
End Sub

'=============================================
Sub BTNPackUnLoad_OnClick()
    call UnloadFilesFromDoc
End Sub
'=============================================
Sub BTN_DEL_APP_OnClick()
  call DelFilesFromDoc
End Sub
'=============================================
Sub ATTR_KD_PR_TYPEDOC_Modified()
   thisForm.Attributes("ATTR_KD_DOC_PREFIX").Value = Get_Prifix(thisObject) 
   thisForm.Refresh
End Sub
'=============================================
Sub ATTR_KD_CONF_Modified()
    thisForm.Attributes("ATTR_KD_DOC_PREFIX").Value = Get_Prifix(thisObject) 
    thisForm.Refresh
End Sub
'=============================================
Sub BTN_ADD_APRV_OnClick()
 AddAprover()
End Sub
'=============================================
Sub BTN_APR_CHANGE_OnClick()
  Set control = thisForm.Controls("QUERY_APROVE_LIST")
  ChangeAprover(control)
End Sub
'=============================================
Sub BTN_DEL_APR_OnClick()
  Set control = thisForm.Controls("QUERY_APROVE_LIST")
  DellAprovers(control)
End Sub
'=============================================
Sub BTN_SEND_OnClick()
  ' проверяем обязательные поля
  txt = checkPR() 
  if txt > ""  then 
    msgbox "Невозможно отправить на согласование, т.к. не все обязательные поля заполнены :" & vbNewLine & txt, _
        vbCritical, "Отправка отменена!"
    exit sub    
  end if 

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
Sub BTN_CHECKOUT_OnClick()
    Word_Check_Out()
End Sub

'=============================================
Sub BTN_CHECKIN_OnClick()
    Word_Check_IN()
End Sub

'=============================================
Sub BTN_DEL_PRO_OnClick()
    call Del_FromTable("ATTR_KD_TLINKPROJ", "ATTR_KD_LINKPROJ" ) 
End Sub

'=============================================
Sub BTN_PRINT_RES_OnClick()
   msgBox "Раздел находится в разработке"
End Sub

