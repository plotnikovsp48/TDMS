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

  stDraft = thisObject.StatusName = "STATUS_KD_DRAFT"
  isCanEd = isCanEdit()
  
  isExec = IsExecutor(thisApplication.CurrentUser, thisObject)

  stSinged = thisObject.StatusName = "STATUS_SIGNED"
  stSigning = thisObject.StatusName = "STATUS_KD_REGIST"

  thisForm.Controls("BTN_SING_DOC").Enabled = isExec and stSigning
  thisForm.Controls("CMD_KD_APP_SCAN").Enabled = isExec and (stSigning or stSinged)
  thisForm.Controls("BTN_RETURN_TO_WORK").Enabled = isExec and not stDraft and not stSinged
  thisForm.Controls("BTN_CANCEL_DOC").Enabled = isExec and stSigning 
  thisForm.Controls("BTNADD").Enabled = stSinged
  thisForm.Controls("BTNDEL").Enabled = stSinged
  thisForm.Controls("BTNEDIT").Enabled = stSinged
  thisForm.Controls("BTN_REORDER").Enabled = stSinged
  thisForm.Controls("BTN_CANCEL").Enabled = stSinged
  thisForm.Controls("BTN_EXC").Enabled = stSinged
  thisForm.Controls("BTN_COPY").Enabled = stSinged
  thisForm.Controls("BTN_ADD_OUT_DOC").Enabled = isExec and not stSinged
  
  

end sub
'=============================================
Sub ATTR_KD_CONF_Modified()
    thisForm.Attributes("ATTR_KD_DOC_PREFIX").Value = Get_Prifix(thisObject) 
    thisForm.Refresh
End Sub

'=============================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  if form.Controls.Has("TXT_" & Attribute.AttributeDefName) then ShowUser(Attribute.AttributeDefName)
  if Attribute.AttributeDefName = "ATTR_KD_MEETING_DATE" then
      if Attribute.Value > date then
          msgbox "Дата совещания не может быть больше текущей даты", vbCritical, "Изменение отменено"
          cancel = true
      end if 
  end if
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

''=============================================
'Sub BTN_TO_SING_OnClick()
'    thisObject.Status = ThisApplication.Statuses("STATUS_KD_REGIST")  
'    thisObject.Update
'    msgbox "Документ передан на подписание"
'End Sub
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
Sub BTN_ADD_DOC_OnClick()
   AskToAddRelDoc ()
End Sub
'=============================================
Sub BTN_DEL_DOC_OnClick()
  call  Del_FromTableWithPerm("ATTR_KD_T_LINKS", "ATTR_KD_LINKS_DOC", "ATTR_KD_LINKS_USER") 
End Sub

'=============================================
Sub BTN_ADD_OUT_DOC_OnClick()
   set objType = thisApplication.ObjectDefs("OBJECT_KD_DOC_OUT")
   set newDoc = Create_Doc_by_Type(objType, nothing)
   If newDoc is nothing then exit sub
   AddResDoc( newDoc)
End Sub
