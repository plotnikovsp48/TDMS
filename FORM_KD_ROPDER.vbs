use CMD_KD_COMMON_LIB
use CMD_KD_ORDER_LIB

'=============================================
Sub Form_BeforeShow(Form, Obj)
  SetContolEnable()
  ShowUsers()
End Sub

'=============================================
sub SetContolEnable()
  set curUser = thisApplication.CurrentUser
  isDraft = (thisObject.StatusName = thisApplication.Statuses("STATUS_KD_DRAFT").SysName)
  isExec = fIsExec(thisObject)
  lisAutor = fIsAutor(thisObject)

  thisForm.Controls("BTN_SEND").Visible = isDraft
  thisForm.Controls("BTN_DEL").Visible = isDraft
  
  thisForm.Controls("BTN_REORDER").Enabled = not isDraft and isExec
  thisForm.Controls("BTN_RECALL").Enabled = not isDraft and lisAutor
end sub

'=============================================
' EV отправляем исполнителю
Sub BTN_SEND_OnClick()
  thisObject.Status = thisApplication.Statuses("STATUS_KD_ORDER_SENT")
  thisObject.Update
'  call SetParentOrderDone()  
  thisForm.Close true
End Sub

'=============================================
Sub BTN_REORDER_OnClick()
  CreateSubOrder(thisObject)
End Sub



'=============================================
Sub BTN_COPY_OnClick()
End Sub

'=============================================
Sub BTN_DEL_CNT_OnClick()
    Del_User("ATTR_KD_CONTR")
End Sub

'=============================================
Sub BTN_ADD_SELF_OnClick()
    Add_self_Control("ATTR_KD_CONTR")
End Sub

'=============================================
Sub BTN_RECALL_OnClick()
 call Set_From_Order_Cancel(thisObject) 
End Sub

'=============================================
Sub QUERY_KD_FILES_IN_DOC_DblClick(iItem, bCancelDefault)
  Set s = thisForm.Controls("QUERY_KD_FILES_IN_DOC").ActiveX
  set File = s.ItemObject(iItem) 
  File_CheckOut(file)
  bCancelDefault = true
End Sub

'=============================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  if form.Controls.Has("TXT_" & Attribute.AttributeDefName) then ShowUser(Attribute.AttributeDefName)
  if Attribute.AttributeDefName = "ATTR_KD_OP_DELIVERY" then 
    set docObj = obj.Attributes("ATTR_KD_DOCBASE").Object
    if not docObj is nothing then 
      if docObj.attributes.has("ATTR_KD_KI") then _
         if docObj.attributes("ATTR_KD_KI").value = true then _
            call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", docObj)
      end if
  end if
  if Attribute.AttributeDefName = "ATTR_KD_POR_PLANDATE" then
    Text = Attribute.Value'thisForm.Attributes("ATTR_KD_POR_PLANDATE").Value
    if isDate(Text) then
      newDate = CDate(Text)
      If newDate < Date then
        msgbox "Невозможно задать контрольную дату меньше текущей даты"
        cancel = true
      end if
    end if
  end if
End Sub