use CMD_KD_COMMON_LIB
use CMD_KD_ORDER_LIB

'=============================================
Sub Form_BeforeShow(Form, Obj)
  set thisapplication.Dictionary("CMD_TWO_MODAL_DIALOGS_DICT")("LAST_FORM_KD_ORDER_CARD") = Form'CheckTwoDialogs

  form.Caption = form.Description
  set docObj = Form.Attributes("ATTR_KD_DOCBASE").Object
  call SetObjectGlobalVarrible("DOCBASE", docObj)

  SetContolEnable()
  ShowUsers()
  CreateTree(thisObject)
  thisForm.Controls("STSYSID").Value = "ID "& thisObject.Attributes("ATTR_KD_NUM").value
  setEditParam()
  setEditValue()  
End Sub
'=============================================
sub setEditParam()
'---Поле дата без атрибута с использованием TDMSEditCtrl -------
  Set field = thisForm.Controls("TDMSEDIT_Date").ActiveX ' TDMSEditCtrl
  set def = ThisApplication.AttributeDefs("ATTR_DATA") ' тип атрибута Дата\Время
  field.AttributeDef = def
end sub
'=============================================
sub setEditValue()
  val = thisObject.Attributes("ATTR_KD_POR_PLANDATE").value
  if val > "" then 
      thisForm.Controls("TDMSEDIT_Date").Value = val
  else
      thisForm.Controls("TDMSEDIT_Date").ActiveX.Value = ""
  end if    
end sub
'=============================================
sub SetAutoCompl
   Set ctrl = thisForm.Controls("ATTR_KD_AUTH").ActiveX
   ctrl.ComboItems = thisApplication.Users
   Set ctrl = thisForm.Controls("ATTR_KD_CONTR").ActiveX
   ctrl.ComboItems = thisApplication.Users
   Set ctrl = thisForm.Controls("ATTR_KD_OP_DELIVERY").ActiveX
   ctrl.ComboItems = thisApplication.Users

end sub
'=============================================
sub SetContolEnable()
  SetBtnEnable()
  set curUser = thisApplication.CurrentUser
  isExec = fIsExec(thisObject)
  lisAutor = fIsAutor(thisObject)
  inWork = thisObject.StatusName = "STATUS_KD_ORDER_IN_WORK"
  inRep = thisObject.StatusName = "STATUS_KD_REPORT_READY"
  canHasDoc = thisObject.Attributes.Has("ATTR_KD_POR_RESDOC") 

  thisForm.Controls("BUT_ADD_FILE").Enabled = isExec and inWork 
  thisForm.Controls("BUT_DEL_FILE").Enabled = isExec and inWork
  thisForm.Controls("BTN_CREATE_DOC").Enabled = isExec and inWork and canHasDoc
  thisForm.Controls("BTN_ADD_DOC").Enabled = isExec and inWork and canHasDoc
  thisForm.Controls("BTN_DEL_DOC").Enabled = isExec and inWork and canHasDoc

    thisForm.Controls("TDMSEDIT_Date").Enabled = lisAutor
  
    thisForm.Controls("BTN_REJECT_ORDER").Enabled = false
    thisForm.Controls("BTN_APPLAY").Enabled = false
    thisForm.Controls("BTN_REJCT_REP").Enabled = false
    thisForm.Controls("BTN_DONE").Enabled = false
    thisForm.Controls("BTN_RETURN").Enabled = false
    
'    au = fIsAutor(thisObject)
'    ex = fIsExec(thisObject)
    if lisAutor then
      if thisObject.StatusName = "STATUS_KD_REPORT_READY" then 
        thisForm.Controls("BTN_APPLAY").Enabled = true
        thisForm.Controls("BTN_REJCT_REP").Enabled = true
      elseif thisObject.StatusName ="STATUS_KD_ORDER_IN_WORK" then 
        if thisObject.Attributes.has("ATTR_KB_POR_DATEBRAKE") then _
          if thisObject.Attributes("ATTR_KB_POR_DATEBRAKE").Value <> "" then _
              thisForm.Controls("BTN_CHANGE_TIME").Enabled = true
      end if  
    else
      if isExec then 
          if thisObject.StatusName = "STATUS_KD_ORDER_IN_WORK" then 
            thisForm.Controls("BTN_DONE").Enabled = true
            thisForm.Controls("BTN_REJECT_ORDER").Enabled = true
            thisForm.Controls("BTN_CHANGE_TIME").Enabled = true
            thisForm.Controls("BTN_CHI_ORDER").Enabled = true
          end if
            thisForm.Controls("BTN_RETURN").Enabled = thisObject.StatusName = "STATUS_KD_REPORT_READY"
      end if
    end if

'  thisForm.Controls("BTN_SEND").Visible = isDraft
'  thisForm.Controls("BTN_DEL").Visible = isDraft
'  
'  thisForm.Controls("BTN_REORDER").Enabled = not isDraft and isExec
'  thisForm.Controls("BTN_RECALL").Enabled = not isDraft and lisAutor
end sub

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
Sub BTN_CHI_ORDER_OnClick()
  set doc = thisObject.Attributes("ATTR_KD_DOCBASE").object
  set cType = thisApplication.ObjectDefs(thisApplication.ObjectDefs("OBJECT_KD_ORDER_REP").Description)
  call CreateTypeOrder(thisObject, doc, cType)
  CreateTree(thisObject)
End Sub
'=============================================
Sub BTN_TO_EXEC_OnClick()
'  set parOrder = thisObject.parent
'  if not parOrder is nothing then
'      if not parOrder.IsKindOf("OBJECT_KD_ORDER") then set parOrder = nothing
'  end if
  set doc = thisObject.Attributes("ATTR_KD_DOCBASE").object
  set cType = thisApplication.ObjectDefs(thisApplication.ObjectDefs("OBJECT_KD_ORDER_REP").Description)
'  call CreateTypeOrder(parOrder, doc, cType) ' EV всегда создаем в корне
  call CreateTypeOrder(nothing, doc, cType)
  CreateTree(thisObject)
End Sub
'=============================================
Sub BTN_TO_NOTE_OnClick()
  set doc = thisObject.Attributes("ATTR_KD_DOCBASE").object
  set cType = thisApplication.ObjectDefs(thisApplication.ObjectDefs("OBJECT_KD_ORDER_NOTICE").Description)
  call CreateTypeOrder(nothing,doc, cType) ' EV всегда в корне
  CreateTree(thisObject)
End Sub
'=============================================
sub CreateTree(cOrder)
    set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX  
    if ax_Tee is nothing then exit sub
    ax_Tee.DeleteAllItems
'     ax_Tee.Font.Bold = true
    ax_Tee.Font.Size = 10
    set parOrder = thisObject.parent
    if not parOrder is nothing then
        if not parOrder.IsKindOf("OBJECT_KD_ORDER") then set parOrder = nothing
    end if
    if parOrder is nothing then set parOrder = thisObject
    if cOrder is nothing then set cOrder = thisObject
    call CreateChild(ax_Tee,0,parOrder, cOrder)
end sub
'=============================================
Sub BTN_APPLAY_OnClick()
    call ApplayOrder(thisObject, thisForm)
    CreateTree(thisObject)
    thisObject.Update
    thisForm.Close
End Sub
'=============================================
Sub BTN_REJCT_REP_OnClick()
    call  RejectOrderReport(thisObject, thisForm)
    CreateTree(thisObject)
End Sub
'=============================================
Sub BTN_DONE_OnClick()
  call Set_order_Done(thisObject)
  CreateTree(thisObject)
End Sub
'=============================================
Sub BTN_REJECT_ORDER_OnClick()
    RejectOrder(thisObject)
End Sub
'=============================================
sub SetBtnEnable()
    thisForm.Controls("BTN_REJECT_ORDER").Enabled = false
    thisForm.Controls("BTN_CHANGE_TIME").Enabled = false
    thisForm.Controls("BTN_APPLAY").Enabled = false
    thisForm.Controls("BTN_REJCT_REP").Enabled = false
    thisForm.Controls("BTN_DONE").Enabled = false
    
    au = fIsAutor(thisObject)
    ex = fIsExec(thisObject)
    if au then
      if thisObject.StatusName = "STATUS_KD_REPORT_READY" then 
        thisForm.Controls("BTN_APPLAY").Enabled = true
        thisForm.Controls("BTN_REJCT_REP").Enabled = true
      elseif thisObject.StatusName ="STATUS_KD_ORDER_IN_WORK" then 
        if thisObject.Attributes.Has("ATTR_KB_POR_DATEBRAKE") then _
          if thisObject.Attributes("ATTR_KB_POR_DATEBRAKE").Value <> "" then _
              thisForm.Controls("BTN_CHANGE_TIME").Enabled = true
      end if  
    else
      if ex then 
          if thisObject.StatusName ="STATUS_KD_ORDER_IN_WORK" then 
            thisForm.Controls("BTN_DONE").Enabled = true
            thisForm.Controls("BTN_REJECT_ORDER").Enabled = true
            thisForm.Controls("BTN_CHANGE_TIME").Enabled = true
          end if
      end if
    end if
end sub

'=============================================
Sub BTN_COMMENT_OnClick()
  call ShowComment("История", thisObject.Attributes("ATTR_KD_HIST_NOTE").value)
End Sub
'=============================================
Sub BUT_ADD_FILE_OnClick()
  LoadFileToDoc("FILE_KD_ANNEX")
End Sub
'=============================================
Sub BTNPackUnLoad_OnClick()
     call UnloadFilesFromDoc
End Sub
'=============================================
Sub BUT_DEL_FILE_OnClick()
    call DelFilesFromDoc
End Sub
'=============================================
Sub BTN_CREATE_DOC_OnClick()
  set doc = thisObject.Attributes("ATTR_KD_DOCBASE").Object
  if not doc is nothing then 
    if doc.ObjectDefName <> "OBJECT_KD_DOC_IN" then set doc = nothing ' только для ВД
  end if
  set newDoc = Create_Doc(doc)
  if not newDoc is nothing then 
    AddResDoc( newDoc)
  end if
  SetAllDocs(thisObject)
End Sub
'=============================================
Sub BTN_ADD_DOC_OnClick()
    Add_Doc()
End Sub
'=============================================
Sub BTN_DEL_DOC_OnClick()
  call Del_FromTable("ATTR_KD_POR_RESDOC", 0)
  SetAllDocs(thisObject)
End Sub
'=============================================
Sub TDMSTREEOrder_DblClick(hItem,bCancelDefault)
    set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX 
    if ax_Tee is nothing then exit sub
    set cOrder = ax_Tee.GetItemData(hItem)
    if cOrder is nothing then exit sub
    if cOrder.handle = thisObject.Handle then exit sub  
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = cOrder
    ans = CreateObjDlg.Show
    if ans then CreateTree(cOrder)
End Sub
'=============================================
Sub BTN_CHI_ORD_OnClick()
  BTN_CHI_ORDER_OnClick()
End Sub
'=============================================
Sub BTN_TO_EXEC_ORD_OnClick()
  BTN_TO_EXEC_OnClick()
End Sub
'=============================================
Sub BTN_EDIT_ORDER_OnClick()
    set cOrder = GetOrderFromTree()
    if cOrder is nothing then exit sub
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = cOrder
    ans = CreateObjDlg.Show
    if ans then CreateTree(cOrder)
End Sub
'=============================================
Sub BTN_DEL_ORDER_OnClick()
    if DEL_ORDER_FromTree() then CreateTree(nothing)
End Sub
'=============================================
Sub BTN_CHANGE_TIME_OnClick()
  thisObject.Update
  'заполняем поля по умолчанию  
  Set frmSetShelve = ThisApplication.InputForms("FORM_KD_QUES")
  frmSetShelve.Attributes("ATTR_KB_POR_DATEBRAKE").Value = thisObject.Attributes("ATTR_KB_POR_DATEBRAKE").value
  frmSetShelve.Attributes("ATTR_KB_POR_DATEBRAKECOM").Value = thisObject.Attributes("ATTR_KB_POR_DATEBRAKECOM").value
  frmSetShelve.Attributes("ATTR_KD_HIST_OBJECT").value = thisObject

  If frmSetShelve.Show Then
    thisObject.Update
    CreateTree(nothing)
  end if

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
'=============================================
Sub TDMSEDIT_Date_Modified()

  set autor = thisObject.Attributes("ATTR_KD_AUTH").User
  if autor is nothing then 
      setEditValue()
      exit sub
  end if
  if autor.sysName <> thisApplication.CurrentUser.SysName then 
      setEditValue()
      exit sub
  end if
  val = thisForm.Controls("TDMSEDIT_Date").Value 
  if val <> "" then 
    if not IsDate(val) then 
      msgbox "Введеное значение " & val & " не является датой. Введите другую дату", vbCritical, "Ошибка ввода"
      setEditValue()
      exit sub
    end if
    dVal = CDate(val)
    if dVal < date then 
      msgbox "Срок " & val & " не может быть меньше текущей даты. Введите другую дату", vbCritical, "Ошибка ввода"
      setEditValue()
      exit sub
    end if
  end if  
  thisObject.Attributes("ATTR_KD_POR_PLANDATE").Value = val
  txt = "Срок Вашего поручение " & thisObject.Description & " изменен на " & val & " пользователем " & thisApplication.CurrentUser.Description
  call SendEditDateEmail(thisObject, txt)
  thisObject.Update
End Sub
'=============================================
Sub BTN_RETURN_OnClick()
  if thisObject.IsKindOf("OBJECT_KD_ORDER") then 
        thisObject.Status = thisApplication.Statuses("STATUS_KD_ORDER_IN_WORK")
        thisObject.Update
        call AddCommentTxt(thisObject,"ATTR_KD_HIST_NOTE", "Возвращено на доработку ")
        msgbox "Поручение " & thisObject.Description & " возвращено на доработку"
   end if     
End Sub
'=============================================
Sub BTN_REP_SH_OnClick()
  call ShowComment("Текст отчета", thisObject.Attributes("ATTR_KB_POR_RESULT").value)
End Sub

'Sub TDMSTREEOrder_Selected(hItem,action)
'     set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX 
'    set cOrder = ax_Tee.GetItemData(hItem)

'  if not cOrder.attributes("ATTR_KD_TEXT") is nothing then
'    set dict = thisapplication.Dictionary("testForm1")
'    dict("tf").attributes("ATTR_KD_TEXT") = cOrder.attributes("ATTR_KD_TEXT")
'    dict("tf").Refresh
'  end if
'End Sub
