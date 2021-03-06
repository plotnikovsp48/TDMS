'USE "CMD_KD_LIB_DOC_IN"
use CMD_KD_COMMON_LIB
use CMD_KD_FILE_LIB

'=============================================
Sub Form_BeforeShow(Form, Obj)
    ShowUsers()
    SetContolEnable()
End Sub

'=============================================
sub SetContolEnable()

  isExec = IsAutor(thisApplication.CurrentUser, thisObject)
  isSecr = isSecretary(thisApplication.CurrentUser)
  isSign = IsSigner(thisApplication.CurrentUser, thisObject)

  isCanEd = isCanEdit()
  stDraft = thisObject.StatusName = "STATUS_KD_DRAFT"
  stSinged = thisObject.StatusName = "STATUS_SIGNED"
  stSigning = thisObject.StatusName = "STATUS_SIGNING"

  thisForm.Controls("BTN_SING_DOC").Enabled = (isSecr or isSign) and stSigning
  thisForm.Controls("BTN_RETURN_TO_WORK").Enabled = ((isSecr or isSign) and stSigning) or ((isExec) and not stDraft  and not stSinged)
  thisForm.Controls("BTN_CANCEL_DOC").Enabled = (isSecr or isSign) and stSigning 

  thisForm.Controls("BTNADD").Enabled = stSinged
  thisForm.Controls("BTNDEL").Enabled = stSinged
  thisForm.Controls("BTNEDIT").Enabled = stSinged
  thisForm.Controls("BTN_REORDER").Enabled = stSinged
  thisForm.Controls("BTN_CANCEL").Enabled = stSinged
  thisForm.Controls("BTN_EXC").Enabled = stSinged
  thisForm.Controls("BTN_COPY").Enabled = stSinged
  'thisForm.Controls("BTN_ADD_OUT_DOC").Enabled = isExec and not stSinged
  

  'thisForm.Controls("BTN_TO_SING").Enabled = isExec and (isAproving or stDraft)
'  thisForm.Controls("BTN_RETURN").Enabled = isExec and not stDraft and not stSinged
'  thisForm.Controls("BTN_SEND").Enabled = (isExec and isCanEd)
'  thisForm.Controls("BTN_ADD_APRV").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_APR_CHANGE").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_DEL_APR").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_APROVE").Enabled = (isApr and isAproving) 
'  thisForm.Controls("BTN_REJECT").Enabled = (isApr and isAproving) 
'  thisForm.Controls("BTN_LOAD_FILE").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_DEL_APP").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_CHECKOUT").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_CHECKIN").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
  
end sub
'=============================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  if form.Controls.Has("TXT_" & Attribute.AttributeDefName) then ShowUser(Attribute.AttributeDefName)
End Sub

'=============================================
Sub BTN_DEL_PRO_OnClick()
  call Del_FromTable("ATTR_KD_TLINKPROJ", "ATTR_KD_LINKPROJ" )  
End Sub
'=============================================
Sub BTN_LOAD_FILE_OnClick()
    Add_application()
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
Sub BTN_DEL_SINGER_OnClick()
    Del_User("ATTR_KD_EXEC")
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
    'call Reg_Doc(thisObject)
    thisObject.Status = ThisApplication.Statuses("STATUS_SIGNED")  
    thisObject.Update
    msgBox "Заявка подписана"
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
Sub BTN_ADD_DOC_OnClick()
   AskToAddRelDoc ()
End Sub
'=============================================
Sub BTN_DEL_DOC_OnClick()
  call  Del_FromTableWithPerm("ATTR_KD_T_LINKS", "ATTR_KD_LINKS_DOC", "ATTR_KD_LINKS_USER") 
End Sub

'=============================================
Sub BTN_CHECKOUT_OnClick()
   Word_Check_Out()
End Sub
'=============================================
Sub BTN_CHECKIN_OnClick()
    Word_Check_IN()
End Sub