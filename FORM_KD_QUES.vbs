use CMD_KD_ORDER_LIB
use CMD_KD_COMMON_LIB

'=============================================
Sub Form_BeforeShow(Form, Obj)
    set order = thisForm.Attributes("ATTR_KD_HIST_OBJECT").Object
    if order is nothing then 
      thisForm.Close
      exit sub
    end if
    Form.Attributes("ATTR_KB_POR_DATEBRAKE").Value = order.Attributes("ATTR_KB_POR_DATEBRAKE").value
    Form.Attributes("ATTR_KB_POR_DATEBRAKECOM").Value = order.Attributes("ATTR_KB_POR_DATEBRAKECOM").value
    Form.Attributes("ATTR_KD_POR_PLANDATE").Value = order.Attributes("ATTR_KD_POR_PLANDATE").value
    au = fIsAutor(order)
    ex = fIsExec(order)
    if au then 
      thisForm.Controls("BTN_REJECT_TIME_REQ").Enabled = true
      thisForm.Controls("BTN_APP_TIME_REQ").Enabled = true
    elseif ex then 
      thisForm.Controls("BTN_SEND_TIME_REQ").Enabled = true
      thisForm.Controls("ATTR_KB_POR_DATEBRAKECOM").Value = ""
      thisForm.Controls("ATTR_KB_POR_DATEBRAKECOM").ReadOnly = false
    end if
    form.Refresh
End Sub
'=============================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  if attribute.AttributeDefName = "ATTR_KB_POR_DATEBRAKE" then 
    if  Attribute.Value <= Now then 
      call MsgBox("Введеная дата " & newDate & " меньше текущей. "& vbNewLine & _
        "Запрос отменен. Введите новую дату. ", VbCritical + vbOKOnly,"Запрос отменен!")
        cancel = true
      exit sub
    end if 
  end if
End Sub
'=============================================
Sub BTN_APP_TIME_REQ_OnClick()
    set order = thisForm.Attributes("ATTR_KD_HIST_OBJECT").Object
    if order is nothing then exit sub
    ThisScript.SysAdminModeOn
    order.Attributes("ATTR_KD_POR_PLANDATE").Value = thisForm.Attributes("ATTR_KB_POR_DATEBRAKE").Value
    order.Attributes("ATTR_KB_POR_DATEBRAKE").Value = ""
    order.Update
    call AddCommentTxt(order,"ATTR_KB_POR_DATEBRAKECOM", "Запрос на изменение сроков принят")
    call AddCommentTxt(order,"ATTR_KD_HIST_NOTE", "Запрос на изменение сроков принят")
    thisForm.Close true
End Sub
'=============================================
Sub BTN_SEND_TIME_REQ_OnClick()
    set order = thisForm.Attributes("ATTR_KD_HIST_OBJECT").Object
    if order is nothing then exit sub

    if trim(thisForm.Attributes("ATTR_KB_POR_DATEBRAKE").Value) = "" then 
      call msgbox("Невозможно отправить запрос, т.к. не указанна дата переноса", vbCritical, "Невозможно отправить запрос")
      exit sub
    end if
    if trim(thisForm.Attributes("ATTR_KB_POR_DATEBRAKECOM").Value) = "" then 
      call msgbox("Невозможно отправить запрос, т.к. не указанна причина переноса", vbCritical, "Невозможно отправить запрос")
      exit sub
    end if
    ThisScript.SysAdminModeOn
    newDate = thisForm.Attributes("ATTR_KB_POR_DATEBRAKE").Value
    order.Attributes("ATTR_KB_POR_DATEBRAKE").Value = newDate
    call AddCommentTxt(order,"ATTR_KB_POR_DATEBRAKECOM", thisForm.Attributes("ATTR_KB_POR_DATEBRAKECOM").Value)
    call AddCommentTxt(order,"ATTR_KD_HIST_NOTE", "Отправлен запрос на изменение сроков: " & _ 
        thisForm.Attributes("ATTR_KB_POR_DATEBRAKECOM").Value)
    order.Update
    thisForm.Close true

End Sub
'=============================================
Sub BTN_REJECT_TIME_REQ_OnClick()
    set order = thisForm.Attributes("ATTR_KD_HIST_OBJECT").Object
    if order is nothing then exit sub
    ThisScript.SysAdminModeOn
    txt = thisApplication.ExecuteScript("CMD_KD_COMMON_LIB", "GetComment","Введите причину отказа")
    if IsEmpty (txt) then exit sub
    if trim(txt) <> "" then 
        call AddCommentTxt(order,"ATTR_KB_POR_DATEBRAKECOM",txt)
        call AddCommentTxt(order,"ATTR_KD_HIST_NOTE", "Отклонен запрос на изменение сроков: " & txt) 
        order.Attributes("ATTR_KB_POR_DATEBRAKE").Value = ""
        order.Update
        thisForm.Close true
    else
      msgbox "Введите причину отказа!"
    end if    

End Sub
