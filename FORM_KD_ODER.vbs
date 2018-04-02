use CMD_KD_COMMON_LIB
use CMD_KD_ORDER_LIB

Sub Form_BeforeShow(Form, Obj)
'  SetControlEnable(Obj)
  ShowUsers()
End Sub

sub SetControlEnable(Obj)
'' EV в статусе черновик
'if obj is nothing then 
'    isDraf = true
'else
'    isDraf = (Obj.StatusName = "STATUS_KD_DRAFT")
'end if     
' thisForm.Controls("T_ATTR_KD_OP_DELIVERY").Visible = not isDraf
' thisForm.Controls("ATTR_KD_OP_DELIVERY").Visible = not isDraf
' thisForm.Controls("QUERY_KD_ALL_ORDE_BY_DOC").Visible = not isDraf

' 'thisForm.Controls("BTN_SEND").Visible = (Obj.StatusName = "STATUS_KD_DRAFT") 
 end sub 


Sub BTNADD_REL_OnClick()
    call AskToAddRelDoc()
End Sub


Sub BTN_DEL_REL_OnClick()
    call Del_FromTableWithPerm("ATTR_KD_T_LINKS", "ATTR_KD_LINKS_DOC", "ATTR_KD_LINKS_USER") 
End Sub

Sub BTN_REORDER_OnClick()
  CreateSubOrder(thisObject)
End Sub

Sub ATTR_KD_ISSUEDATE_BeforeModify(Text,Cancel)
msgbox "1"

End Sub
Sub ATTR_KD_ISSUEDATE_ButtonClick(Cancel)
msgbox "2"
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