USE "CMD_KD_LIB_DOC_IN"
use CMD_KD_COMMON_LIB
'use CMD_KD_REGNO_KIB

Sub Form_BeforeShow(Form, Obj)
    ShowUsers()
    SetContolEnable()
End Sub

'=============================================
sub SetContolEnable()
  isCanEd = isCanEdit()

  isExec = IsExecutor(thisApplication.CurrentUser, thisObject)
  isApr = IsAprover(thisApplication.CurrentUser, thisObject)
  isSecr = isSecretary(thisApplication.CurrentUser)
  isSign = IsSigner(thisApplication.CurrentUser, thisObject)

  isAproving = thisObject.StatusName = "STATUS_KD_AGREEMENT"
  stSinged = thisObject.StatusName = "STATUS_KD_IN_FORCE"
  stSigning = thisObject.StatusName = "STATUS_SIGNING"
  stReg = thisObject.StatusName = "STATUS_KD_REGIST"

  thisForm.Controls("BTN_SING_DOC").Enabled = (isSecr or isSign) and stSigning
  thisForm.Controls("BTN_REG_DOC").Enabled = isSecr and stReg
  thisForm.Controls("CMD_KD_APP_SCAN").Enabled = ((isSecr or isSign) and (stSigning or stSinged))
  thisForm.Controls("BTN_RETURN_TO_WORK").Enabled = ((isSecr or isSign) and stSigning) or isExec
  thisForm.Controls("BTN_CANCEL_DOC").Enabled = (isSecr or isSign) and stSigning 
  thisForm.Controls("BTN_CANC").Enabled = (isSecr or isSign) and stSinged 
  thisForm.Controls("BTNADD").Enabled = stSinged
  thisForm.Controls("BTNDEL").Enabled = stSinged
  thisForm.Controls("BTNEDIT").Enabled = stSinged
  thisForm.Controls("BTN_REORDER").Enabled = stSinged
  thisForm.Controls("BTN_CANCEL").Enabled = stSinged
  thisForm.Controls("BTN_EXC").Enabled = stSinged
  thisForm.Controls("BTN_COPY").Enabled = stSinged

  'thisForm.Controls("BTN_SEND").Enabled = ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_ADD_APRV").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_DEL_APR").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_APROVE").Enabled = (isApr and isAproving) 
'  thisForm.Controls("BTN_REJECT").Enabled = (isApr and isAproving) 
'  thisForm.Controls("BTN_APR_CHANGE").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_LOAD_FILE").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_DEL_APP").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_CHECKOUT").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_CHECKIN").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_RETURN").Enabled = (isExec or isContr) and ifSt
  
end sub

'=============================================
Sub BTN_DEL_PRO_OnClick()
  call Del_FromTable("ATTR_KD_TLINKPROJ", "ATTR_KD_LINKPROJ" ) 
End Sub

'=============================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
 if form.Controls.Has("TXT_" & Attribute.AttributeDefName) then ShowUser(Attribute.AttributeDefName)
End Sub

'=============================================
Sub BTNPackUnLoad_OnClick()
    call UnloadFilesFromDoc
End Sub

'=============================================
Sub BTN_PRINT_MEMO_OnClick()
  msgbox "Раздел находится в разработке"
End Sub

'=============================================
Sub BTNADD_OnClick()
  if CreateOrders( nothing, thisObject ) then _
     msgbox "Добавление завершено"
End Sub
'=============================================
Sub BTNDEL_OnClick()
  call delSelectedOrder()
End Sub

'=============================================
Sub BTNEDIT_OnClick()
  set order =  GetOrderFromForm()
  if order is nothing then exit sub
  call edit_Order(order)
End Sub

'=============================================
Sub BTN_EXC_OnClick()
  set order =  GetOrderFromForm()
  if order is nothing then exit sub
  call Set_order_Done(order)
End Sub
'=============================================
Sub BTN_REORDER_OnClick()
  set order =  GetOrderFromForm()
  if order is nothing then exit sub
  CreateSubOrder(order)
End Sub

'=============================================
Sub BTN_CANCEL_OnClick()
  set order =  GetOrderFromForm()
  if order is nothing then exit sub
  call Set_From_Order_Cancel(order) 
End Sub

'=============================================
Sub BTN_SING_DOC_OnClick()
  if IsSigner(thisApplication.CurrentUser, thisObject) then
    thisObject.Status = ThisApplication.Statuses("STATUS_KD_REGIST")  
    thisObject.Update
    msgbox "Документ подписан"
  else
      call Reg_Doc(thisObject)
  end if
End Sub

'=============================================
Sub BTN_REG_DOC_OnClick()
  call Reg_Doc(thisObject)
End Sub

'=============================================
Sub BTN_CANCEL_DOC_OnClick()
  set_Doc_Cancel
End Sub
'=============================================
Sub BTN_RETURN_TO_WORK_OnClick()
  return_To_Work()
End Sub

'=============================================
Sub BTN_CANC_OnClick()
    thisObject.Status = ThisApplication.Statuses("STATUS_KD_INACTIVE")  
    thisObject.Update
    msgbox "Документ отмечен как недействующий"
End Sub


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
Sub BTN_CHECKOUT_OnClick()
    Word_Check_Out()
End Sub

'=============================================
Sub BTN_CHECKIN_OnClick()
    Word_Check_IN()
End Sub
