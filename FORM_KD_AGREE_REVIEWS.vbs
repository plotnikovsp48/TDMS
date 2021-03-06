use CMD_KD_ORDER_LIB
use CMD_KD_GLOBAL_VAR_LIB

'=============================================
Sub BTN_SEND_OnClick()
  ThisScript.SysAdminModeOn
  set docObj =  thisForm.Attributes("ATTR_KD_DOCBASE").Object
  if docObj is nothing then exit sub
  
  set parOrder = nothing
  Set contr = thisForm.Controls("QUERY_KD_REVIEWS").value
  if contr.RowsCount > 0 then
    if thisForm.Controls("QUERY_KD_REVIEWS").SelectedObjects.count > 0 then 
      set order = thisForm.Controls("QUERY_KD_REVIEWS").SelectedObjects(0)
      if not order is nothing then 
    '    if rows.cellValue(i, 1) = GetCurUser().Description then set parOrder = order
        if order.Attributes("ATTR_KD_OP_DELIVERY").user.sysName = GetCurUser().SysName then _
          set parOrder = order
      end if
    end if  
  end if  

  set cType = thisApplication.ObjectDefs(thisApplication.ObjectDefs("OBJECT_KD_ORDER_SYS").Description)
  call CreateTypeOrderToUserResol(parOrder, docObj, cType, nothing, "Подготовить рецензию" ) 
End Sub

'=============================================
Sub Form_BeforeShow(Form, Obj)
  ApplyMyReview()

  set docObj =  thisForm.Attributes("ATTR_KD_DOCBASE").Object
  if docObj is nothing then exit sub
  isApr = false 
  if docObj.StatusName = "STATUS_KD_AGREEMENT" then _
     isApr = IsCanAprove(GetCurUser(), docObj)'IsAprover(thisApplication.CurrentUser, thisObject)
  
  thisForm.Controls("BTN_SEND").Enabled = isApr
'  thisForm.Controls("BTN_SEND").Visible = isApr
  
  RemoveGlobalVarrible("ApplyReview")
'  set docObj =  thisForm.Attributes("ATTR_KD_DOCBASE").Object
'  if docObj is nothing then exit sub

'  call SetObjectGlobalVarrible("ParDocBase",docObj)
End Sub
'=============================================
Sub BTN_EXEC_OnClick()
    ThisScript.SysAdminModeOn
    Set contr = thisForm.Controls("QUERY_KD_REVIEWS").value
    if contr.RowsCount = 0 then exit sub
    
    set order = thisForm.Controls("QUERY_KD_REVIEWS").SelectedObjects(0)
'    set order = GetCurOrder()
    if order is nothing then 
      msgbox "У Вас нет выданных рецензий"
      exit sub
    end if
    txt = thisApplication.ExecuteScript("CMD_KD_COMMON_LIB", "GetComment","Введите текст рецензии")
    if IsEmpty (txt) then exit sub
    if trim(txt) <> "" then 
      order.Permissions  = SysAdminPermissions 
      order.Attributes("ATTR_KD_ORDER_REP_NOTE").Value = txt
      order.Status = thisApplication.Statuses("STATUS_KD_REPORT_READY")
      order.Attributes("ATTR_KD_POR_REASONCLOSE").Value = "Рецензия подготовлена"
      order.Update
      call SetGlobalVarrible("ApplyReview","T")
      call sendReviewMail(order, txt)
      thisForm.Close true
    else  
      msgbox "Введите текст рецензии!", vbCritical, "Отправка отменена"
    end if   

End Sub
'=============================================
sub sendReviewMail(order, txt)
    set exec = order.Attributes("ATTR_KD_AUTH").User
    if exec is nothing then exit sub
    if exec.sysName = GetCurUser().SysName then exit sub
    set docObj =  thisForm.Attributes("ATTR_KD_DOCBASE").Object
    if docObj is nothing then exit sub
 
    subj = "Рецензия по документу " & docObj.Description & " подготовлена " 
    body = txt
    call SendMail(exec, subj, order, false, body, false)

end sub
'=============================================
function GetCurOrder()
  set GetCurOrder = nothing
  set rows = thisForm.Controls("QUERY_KD_REVIEWS").Value
  for i = 0 to rows.RowsCount - 1
    if rows.cellValue(i, 1) = GetCurUser().Description then 
     set GetCurOrder = rows.Objects(i)
'     thisForm.Controls("QUERY_KD_REVIEWS").SelectedObjects.add(GetCurOrder)
     exit function
    end if
  next
end function
'=============================================
Sub QUERY_KD_REVIEWS_Selected(iItem, action)
  def = false
  if iItem < 0 then   def = true
  Set contr = thisForm.Controls("QUERY_KD_REVIEWS").value
  if contr.RowsCount = 0 then   def = true

  if not def then 
    'Set order = s.ItemObject(iItem) 
    thisForm.Controls("ATTR_KD_TEXT").Value = contr.cellValue(iItem, 3)
    thisForm.Controls("ATTR_KD_ORDER_REP_NOTE").Value = contr.cellValue(iItem, 4)
  
    thisForm.Controls("BTN_EXEC").Enabled = false
    user = GetCurUser().Description
    if contr.cellValue(iItem, 1) = GetCurUser().Description then 
      thisForm.Controls("BTN_SEND").Enabled = true
      if contr.cellValue(iItem, 4) = "" then _
        thisForm.Controls("BTN_EXEC").Enabled = true
    else
      SetDefPerm()
    end if    
  else
    SetDefPerm()
  end if  
End Sub

'=============================================
sub SetDefPerm()
  isApr = false 
  set docObj =  thisForm.Attributes("ATTR_KD_DOCBASE").Object
  if not docObj is nothing then _
    if docObj.StatusName = "STATUS_KD_AGREEMENT" then _
       isApr = IsCanAprove(GetCurUser(), docObj)'IsAprover(thisApplication.CurrentUser, thisObject)

  thisForm.Controls("BTN_SEND").Enabled = isApr
  thisForm.Controls("BTN_EXEC").Enabled = false
end sub
'=============================================
sub  ApplyMyReview()
  set rows = thisForm.Controls("QUERY_KD_REVIEWS").Value
  for i = 0 to rows.RowsCount - 1
    if rows.cellValue(i, 0) = GetCurUser().Description and rows.cellValue(iItem, 3) <> "" then 
     set order = rows.Objects(i)
     if order.statusName = "STATUS_KD_REPORT_READY" then _
          call SetOrderDone(order,"", "Резолюция принята") 
    end if
  next
end sub    
