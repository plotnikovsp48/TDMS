use CMD_KD_COMMON_LIB
use CMD_KD_FILE_LIB

'=============================================
Sub Form_BeforeShow(Form, Obj)
   ShowUsers()
   SetContolEnable()
End Sub
'=============================================
sub SetContolEnable()

 isCanEd = isCanEdit()

  isExec = IsExecutor(thisApplication.CurrentUser, thisObject)
  isContr = IsController(thisApplication.CurrentUser, thisObject)
  isApr = IsAprover(thisApplication.CurrentUser, thisObject)

'  thisForm.Controls("BTN_RETURN").Enabled = (isExec or isContr) and isCanEd

  isExec = IsExecutor(thisApplication.CurrentUser, thisObject)
  isSecr = isSecretary(thisApplication.CurrentUser)
  isSign = IsApprover(thisApplication.CurrentUser, thisObject)

  stSinged = thisObject.StatusName = "STATUS_KD_APPROVED"
  stSigning = thisObject.StatusName = "STATUS_KD_APPROVAL"
  stDraft = thisObject.StatusName = "STATUS_KD_DRAFT"

  thisForm.Controls("BTN_SING_DOC").Enabled = (isSecr or isSign) and stSigning
  thisForm.Controls("CMD_KD_APP_SCAN").Enabled = ((isSecr or isSign) and (stSigning or stSinged))
  thisForm.Controls("BTN_RETURN").Enabled = ((isSecr or isSign) and stSigning) or ((isExec or isContr) and not stDraft)
  thisForm.Controls("BTN_CANCEL_DOC").Enabled = (isSecr or isSign) and stSigning 
  'thisForm.Controls("BTN_CANC").Enabled = (isSecr or isSign) and stSinged 
  thisForm.Controls("BTNADD").Enabled = stSinged
  thisForm.Controls("BTNDEL").Enabled = stSinged
  thisForm.Controls("BTNEDIT").Enabled = stSinged
  thisForm.Controls("BTN_REORDER").Enabled = stSinged
  thisForm.Controls("BTN_CANCEL").Enabled = stSinged
  thisForm.Controls("BTN_EXC").Enabled = stSinged
  thisForm.Controls("BTN_COPY").Enabled = stSinged  
  
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
Sub BTNPackUnLoad_OnClick()
    call UnloadFilesFromDoc
End Sub

'=============================================
Sub BTN_RETURN_OnClick()
    return_To_Work()
End Sub

'=============================================
Sub BTN_CANCEL_DOC_OnClick()
    set_Doc_Cancel
End Sub
'=============================================
Sub BTN_SING_DOC_OnClick()
    thisObject.Status = ThisApplication.Statuses("STATUS_KD_APPROVED")  
    thisObject.Update
'    msgbox "Документ утвержден"
    if isSecretary(thisApplication.CurrentUser) then
      msgBox "Приложите резолюцию", vbInformation
      LoadFileToDoc("FILE_KD_RESOLUTION")
    end if
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
Sub ATTR_KD_CONF_Modified()
    thisForm.Attributes("ATTR_KD_DOC_PREFIX").Value = Get_Prifix(thisObject) 
    thisForm.Refresh
End Sub
