use CMD_KD_COMMON_LIB
use CMD_KD_COMMON_BUTTON_LIB
use CMD_KD_ORDER_LIB
use CMD_KD_USER_PERMISSIONS
use CMD_KD_OUT_LIB
use CMD_KD_AGREEMENT_LIB
use CMD_KD_CURUSER_LIB



'=============================================
Sub Form_BeforeShow(Form, Obj)
  call RemoveGlobalVarrible("AgreeObj")
  call RemoveGlobalVarrible("Settings") ' EV чтобы наверняка новое значение
  set settings = GetSettings()
  if settings is nothing  then 
    SetControlNotEnable(false)
    exit sub  
  end if

  form.Caption = form.Description
'  ShowUsers()
  SetChBox()
  ShowBtnIcon()
  'EV 2018-01-31 показываем файлы только если не стоит галка показывать по кнопке
  if thisApplication.CurrentUser.Attributes.Has("ATTR_SHOW_FILE_BY_BUTTON") then _
    if thisApplication.CurrentUser.Attributes("ATTR_SHOW_FILE_BY_BUTTON").Value <> true then _
        ShowFile(0)'(-1)'(0)
  SetBtnName() 
  ShowSysID() 
  SetEmptyAttr()
  SetShowOldFailFlag()
  SetContolEnable(settings)  
''  call SetGlobalVarrible("ShowForm", "FORM_KD_DOC_AGREE")

End Sub
'=============================================
sub SetChBox()
  set chk = thisForm.Controls("TDMSEDITCHECKSHOW").ActiveX
  chk.buttontype = 4
  Chk.value = false
end sub

'=============================================
sub SetBtnName()
  set settings = GetSettings()
  if settings is nothing  then exit sub

  st = settings.Attributes("ATTR_KD_FINISH_STATUS").value
  if st = "" then exit sub
  if thisApplication.Statuses.Has(st) then set stObj = thisApplication.Statuses(st)
  str = stObj.Description
  str = left(str, len(str)-1) & "е"
  thisForm.Controls("BTN_TO_SINGING").Value = str
end sub
'=============================================
sub SetContolEnable(settings)

  set curUs = GetCurUser() 
  isLock = false
  If thisObject.Permissions.Locked = True Then
    If thisObject.Permissions.LockUser.Handle <> thisApplication.CurrentUser.Handle  Then
      msgbox "В настоящий момент документ редактируется пользователем " & thisObject.Permissions.LockUser.Description & _
      ". Некоторые действия с объектом могут быть недоступны или отклонены.", vbExclamation 
      isLock = true
    end if
  end if  
  thisForm.Controls("ATTR_KD_OP_DELIVERY").Enabled = true
  thisForm.Controls("ATTR_KD_POR_REASONCLOSE").Enabled = true
  thisForm.Controls("ATTR_KD_ORDER_REP_NOTE").Enabled = true
  thisForm.Controls("ATTR_KD_APRV_COMMENT").Enabled = true

  isODO = thisObject.IsKindOf("OBJECT_KD_BASE_DOC")
  if isODO then 
    isExec = IsExecutor(curUs, thisObject)
  else
    isExec = isInic(curUs, thisObject)
    thisForm.Controls("BTN_CREATE_WORD").Enabled = false
  end if
  
  isContr = IsController(curUs, thisObject)
  isApr = false 
  if thisObject.StatusName = "STATUS_KD_AGREEMENT" then _
     isApr = IsCanAprove(curUs, thisObject)'IsAprover(thisApplication.CurrentUser, thisObject)
  isSecr = isSecretary(curUs)
  isSign = IsSigner(curUs, thisObject)
  isGrChiefs =  curUs.Groups.Has("GROUP_CHIEFS")

  isCanEd =  CheckStartStatusSil(settings, true,thisObject)'isCanEdit()'проверяем начальный статус
  isAproving = thisObject.StatusName = "STATUS_KD_AGREEMENT"
  stSinged = thisObject.StatusName = "STATUS_SIGNED"
  stSigning = thisObject.StatusName = "STATUS_SIGNING"

  on error resume next  ' проверяем статусы в которых нельзя  возвращать в работу
  ifFinStatus = false
  ifFinStatus = thisApplication.ExecuteScript(thisObject.ObjectDefName,"Check_FinishStatus", thisObject.StatusName)
  if err.Number <> 0 then err.clear
  on error goto 0
  
  stEndbled = ((isExec or isContr) and isCanEd and (isGrChiefs or (isExec and isContr)))
  isAbleToSend = CanSendToSing(stEndbled)
  thisForm.Controls("BTN_REVIEWS").Enabled = not isCanEd
  thisForm.Controls("BTN_REVIEWS").Visible = not isCanEd

  thisForm.Controls("BTN_SEND").Enabled = ((isExec or isContr) and isCanEd)
  thisForm.Controls("BTN_SEND").Visible = ((isExec or isContr) and isCanEd)
  
  thisForm.Controls("BTN_TO_SINGING").Enabled = isAbleToSend
  thisForm.Controls("BTN_TO_SINGING").Visible = isAbleToSend And isODO ' добавил isODO str 24/01/2018
  
'  thisForm.Controls("CMD_KD_REG_DOC").Enabled = (isSecr or isSign) and stSigning
'  thisForm.Controls("CMD_KD_REG_DOC").Visible = (isSecr or isSign) and stSigning
  thisForm.Controls("BTN_SINGED").Enabled = (isSign or isSecr) and stSigning
  thisForm.Controls("BTN_SINGED").Visible = (isSign or isSecr) and stSigning and isODO
  
  thisForm.Controls("BTN_EDIT_ARGEE").Enabled = (isApr and isAproving) or ((isExec or isContr) and (isCanEd or isAproving)) _
  '    or thisApplication.CurrentUser.SysName = "SYSADMIN"
  
  thisForm.Controls("BTN_APROVE").Enabled = (isApr and isAproving) and not isLock
  thisForm.Controls("BTN_APROVE").Visible = (isApr and isAproving) 
  thisForm.Controls("BTN_REJECT").Enabled = (isApr and isAproving) and not isLock
  thisForm.Controls("BTN_REJECT").Visible = (isApr and isAproving) 
  thisForm.Controls("BTN_DELEG").Enabled = (isApr and isAproving) and not isLock
  thisForm.Controls("BTN_DELEG").Visible = (isApr and isAproving) 

  thisForm.Controls("BTN_TO_WORK").Enabled = ((isSecr or isSign) and stSigning) or ((isExec or isContr) and not isCanEd)  
  thisForm.Controls("BTN_TO_WORK").Visible = thisForm.Controls("BTN_TO_WORK").Enabled and not ifFinStatus
  
  thisForm.Controls("BTN_CANCEL_DOC").Enabled = ((isSecr or isSign) and stSigning) _
      or ((isExec or isContr) and isCanEd)
  thisForm.Controls("BTN_CANCEL_DOC").Visible = thisForm.Controls("BTN_CANCEL_DOC").Enabled

  canAddF = CanAddFile()
  thisForm.Controls("BUT_ADD_FILE").Enabled = canAddF'(isApr and isAproving) or ((isExec or isContr) and isCanEd)
  thisForm.Controls("BUT_DEL_FILE").Enabled = canAddF'(isApr and isAproving) or ((isExec or isContr) and isCanEd)

  thisForm.Controls("BTN_FROM_ORDERS").Enabled =(ThisObject.ObjectDefName = "OBJECT_KD_DOC_OUT")
 
  if not thisObject.IsKindOf("OBJECT_KD_BASE_DOC") then 
    thisform.Controls("BTN_CARD").Enabled = false
    thisform.Controls("BTN_RELATIONS").Enabled = false
    thisform.Controls("BTN_ORDERS").Enabled = false
    thisform.Controls("BTN_AGREE").Enabled = false
    thisform.Controls("BTN_HIST").Enabled = false
  end if  

  thisform.Controls("CMD_COPY_DOC").Enabled = isSec or thisObject.ObjectDefName <> "OBJECT_KD_DOC_IN"

'  thisForm.Controls("BTN_CHECKOUT").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_CHECKIN").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  
'  thisForm.Controls("BTN_SEND_TO_CHECK").Enabled = isExec and thisObject.StatusName = "STATUS_KD_DRAFT"
'  ifSt = (thisObject.StatusName = "STATUS_KD_CHECK") or (thisObject.StatusName = "STATUS_SIGNING") _
'      or(thisObject.StatusName = "STATUS_KD_AGREEMENT")
'  thisForm.Controls("BTN_RETURN").Enabled = (isExec or isContr) and ifSt
'  
''  thisForm.Controls("").Enabled = isApr
  
end sub
'=============================================
Sub BTN_SEND_OnClick()
  thisObject.saveChanges()
  
  set agreeObj = GetAgreeObjByObj(thisObject)
  if agreeObj is nothing then exit sub

  ' если нет еще ни одной строки, открыть маршрут
  if not CheckHasAgreeRow(agreeObj, true) then
    'BTN_EDIT_ARGEE_OnClick()
    if not  EDIT_ARGEE() then exit sub
    set agreeObj = GetAgreeObjByObj(thisObject) ' перезачитываем согласование
  end if
  ThisApplication.Utility.Waitcursor = TRUE

  'произвести проверки
  if not CheckBeforeSend(agreeObj) then exit sub
  'Закрыть все свои поручения
  call clouseAllOrderByRes(thisObject, "NODE_KD_RETUN_USER")
  'поменять стутусы и раздать права
  if not SetStatuses(agreeObj) then exit sub
  'создать поручения
  if not CreateAproveOrders(agreeObj) then exit sub
  ' A.O. 
  'msgbox "Документ передан на согласование"
  thisForm.Close false
  ThisApplication.Utility.Waitcursor = false

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
Sub BTN_APR_CHANGE_OnClick()
  Set control = thisForm.Controls("QUERY_APROVE_LIST")
  ChangeAprover(control)
End Sub

'=============================================
Sub BTN_RETURN_OnClick()
  return_To_Work()
End Sub
'=============================================
Sub BUT_ADD_FILE_OnClick()
'   ClosePreview()
   Add_application()
End Sub
'=============================================
Sub BUT_DEL_FILE_OnClick()
   DelFilesFromDoc()
   ThisObject.Update
End Sub
'=============================================
Sub QUERY_APROVE_LIST_Selected(iItem, action)
    if iItem < 0 then 
      SetEmptyAttr()
      exit sub
    end if
    Set control = thisForm.Controls("QUERY_APROVE_LIST")
    set aprRow =  control.value.RowValue(iItem) 

    set aprOrder = aprRow.Attributes("ATTR_KD_LINK_ORDER").object
 
    if aprOrder is nothing then 
      SetRowAttr(aprRow)
    else
      call SetOrderAttr(aprOrder,aprRow)
    end if  
End Sub
'=============================================
sub SetOrderAttr(order,aprRow)
  thisForm.Controls("ATTR_KD_OP_DELIVERY").Value = order.Attributes("ATTR_KD_OP_DELIVERY").value
  thisForm.Controls("ATTR_KD_POR_REASONCLOSE").Value = order.Attributes("ATTR_KD_POR_REASONCLOSE").value
  thisForm.Controls("ATTR_KD_ORDER_REP_NOTE").Value = order.Attributes("ATTR_KD_ORDER_REP_NOTE").value
  thisForm.Controls("ATTR_KD_APRV_COMMENT").Value = order.Attributes("ATTR_KD_NOTE").value
  ThisForm.Controls("BTN_EDIT_REP").Enabled = CanEditRepNote(order, aprRow)
end sub
'=============================================
sub SetRowAttr(row)
  thisForm.Controls("ATTR_KD_OP_DELIVERY").Value = row.Attributes("ATTR_KD_APRV").value
  thisForm.Controls("ATTR_KD_POR_REASONCLOSE").Value = ""
  thisForm.Controls("ATTR_KD_ORDER_REP_NOTE").Value = ""
  thisForm.Controls("ATTR_KD_APRV_COMMENT").Value = ""
  ThisForm.Controls("BTN_EDIT_REP").Enabled = false
end sub
'=============================================
sub SetEmptyAttr()
  thisForm.Controls("ATTR_KD_OP_DELIVERY").Value = ""
  thisForm.Controls("ATTR_KD_POR_REASONCLOSE").Value = ""
  thisForm.Controls("ATTR_KD_ORDER_REP_NOTE").Value = ""
  thisForm.Controls("ATTR_KD_APRV_COMMENT").Value = ""
  ThisForm.Controls("BTN_EDIT_REP").Enabled = false
end sub
'=============================================
Sub BTN_TO_WORK_OnClick()
  If ThisObject.IsKindOf("OBJECT_KD_BASE_DOC") Then
    'ReturnToWork(thisObject)
    return_To_Work()
  Else
    Call ThisApplication.ExecuteScript("CMD_DLL","return_To_Work_Tech",ThisObject)
  End If
End Sub
'=============================================
Sub BTN_CANCEL_DOC_OnClick()
  If ThisObject.IsKindOf("OBJECT_KD_BASE_DOC") Then
    set_Doc_Cancel
  Else
    Call ThisApplication.ExecuteScript("CMD_DLL","set_Doc_Cancel_Tech",ThisObject)
  End If
End Sub
'=============================================
Sub BTN_TO_SINGING_OnClick()
  set agreeObj = GetAgreeObjByObj(thisObject)
  if agreeObj is nothing then exit sub
  set settings = GetSettings()
  if settings is nothing  then exit sub

'  if thisObject.StatusName = "STATUS_KD_DRAFT" then
  if CheckStartStatusSil(settings, true,thisObject) then 
      ans = msgbox("Документ не согласован. Вы уверены, что хотите передать несогласованный документ?", _
                  vbQuestion + VbYesNo, "Передать " & thisForm.Controls("BTN_TO_SINGING").Value & "?")
    if ans <> vbYes then exit sub 
  else
    exit sub               
  end if

  'произвести проверки
  if not  execSettingsFun1("ATTR_KD_CHECK_FUNCTION", thisObject) then exit sub
  'Закрыть все свои поручения
  call clouseAllOrderByRes(thisObject, "NODE_KD_RETUN_USER")
  
  ' EV перевести в следующий статус
  call Set_DocDone(thisObject, agreeObj)
'  thisObject.Status = thisApplication.Statuses("STATUS_SIGNING")
'  msgBox "Документ согласован. Документ передан на подписание."
'  Set_Permission thisObject
  thisForm.Close isCanEdit()

End Sub
'=============================================
Sub BTN_EDIT_ARGEE_OnClick()   
   EDIT_ARGEE()
End Sub
'=============================================
function EDIT_ARGEE()
  EDIT_ARGEE = false
    set agreeObj = GetAgreeObjByObj(thisObject)
    if agreeObj is nothing then exit function

    call SetGlobalVarrible("ShowForm", "FORM_ARGEE_CREATE")
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = thisObject
    EDIT_ARGEE = CreateObjDlg.Show
    if thisObject.IsKindOf("OBJECT_KD_BASE_DOC") then 
      call SetGlobalVarrible("ShowForm", "FORM_KD_DOC_AGREE")
    else
      call RemoveGlobalVarrible("ShowForm")
    end if  

end function

'=============================================
Sub BTN_COM_OnClick()
  call ShowComment("Комментарий согласующего", thisForm.Controls("ATTR_KD_APRV_COMMENT").value)
End Sub
'=============================================
Sub BTN_REP_COM_OnClick()
  call ShowComment("Ответ инициатора согласования", thisForm.Controls("ATTR_KD_ORDER_REP_NOTE").value)
End Sub

''=============================================
'Sub QUERY_APROVE_LIST_DblClick(iItem, bCancelDefault)
'  Thisscript.SysAdminModeOn
'  Set s = thisForm.Controls("QUERY_APROVE_LIST").ActiveX
'  set row = s.ItemObject(iItem) 
'  set user = row.Attributes("ATTR_KD_APRV").user
'  if not user is nothing then
'    dlg = thisApplication.Dialogs.
'  end if
''  File_CheckOut(file)
'  bCancelDefault = true
'End Sub

'=============================================
Sub BTN_FROM_ORDERS_OnClick()
  call thisApplication.ExecuteScript("FORM_KD_EXCUTION","AddFiles","QUERY_DOC_ORDER_FILES", thisObject)
End Sub
'=============================================
Sub BTN_PRINT_RES_OnClick()
    set agreeObj = GetAgreeObjByObj(thisObject)
    if agreeObj is nothing then exit sub
    set file = agreeObj.Files.Main
    if File is nothing then exit sub
    file.CheckOut file.WorkFileName ' извлекаем

    Set objShellApp = CreateObject("Shell.Application") 'открываем
    objShellApp.ShellExecute "explorer.exe", file.WorkFileName, "", "", 1
    Set objShellApp = Nothing  

End Sub
'=============================================
Sub BTN_SINGED_OnClick()
  Set_Doc_Signed(thisObject)
  thisForm.Close false
end sub
'=============================================
sub Set_Doc_Signed(docObj)
  thisScript.SysAdminModeOn
  docObj.Permissions = SysAdminPermissions
 ' thisObject.Status = ThisApplication.Statuses("STATUS_SIGNED")  
  if docObj.ObjectDefName = "OBJECT_KD_DIRECTION" then 
      docObj.Status = ThisApplication.Statuses("STATUS_KD_REGIST") 
    else
      docObj.Status = ThisApplication.Statuses("STATUS_SIGNED")  
  end if
  docObj.Update
  ' функция постобработки подписания
  on error resume next
  Call thisApplication.ExecuteScript(docObj.ObjectDefName,"AfterSinging", docObj)
  on error goto 0 
  call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", docObj)
  msgbox "Документ подписан"
End Sub
'=============================================
Sub BTN_EDIT_REP_OnClick()

  set appOrder = GetAppRowOrd()
  if appOrder is nothing then 
    msgbox "Невозможно дать комментарий к этой строке!", vbExclamation, "Выберите другую строку согласования"
    exit sub
  end if
    
'  спрашиваем комментарий
  txt =  GetEditComment("Введите ответ к замечанию", appOrder.Attributes("ATTR_KD_ORDER_REP_NOTE").value)
  if IsEmpty(txt) then exit sub
  
  thisScript.SysAdminModeOn
  appOrder.permissions = SysAdminPermissions
  appOrder.Attributes("ATTR_KD_ORDER_REP_NOTE").value = txt
  appOrder.update
  thisForm.Controls("ATTR_KD_ORDER_REP_NOTE").Value = txt
'  thisForm.Refresh
End Sub
'=============================================
function GetAppRow()
    set GetAppRow = nothing 
    Set control = thisForm.Controls("QUERY_APROVE_LIST")
    ar = thisapplication.Utility.ArrayToVariant(control.SelectedItems)
    if Ubound(ar)<0 then exit function
    iItem = ar(0)
    set GetAppRow =  control.value.RowValue(iItem)
end function
'=============================================
function GetAppRowOrd()
  set GetAppRowOrd = nothing
  set aprRow  =  GetAppRow()
  if aprRow is nothing then exit function
  set GetAppRowOrd = aprRow.Attributes("ATTR_KD_LINK_ORDER").object
end function

'=============================================
Sub BTN_DELEG_OnClick()
  set agreeObj = GetAgreeObjByObj(thisObject)
  if agreeObj is nothing then exit sub

  set curUser = GetCurUser()
  set aprRow = Get_AproveRow(curUser, thisObject)
  if aprRow is nothing  then exit sub
  set aprOrder = aprRow.Attributes("ATTR_KD_LINK_ORDER").object
  if aprOrder is nothing then 
    msgbox "Делегировать невозможно, т.к. не выдано поручение"
    exit sub
  end if

  ans = msgbox("Вы уверены, что хотите делегировать свои полномочия по согласованию?" & vbNewLine _
      & "Ваше поручение будет закрыто, как согласованное", vbQuestion + VbYesNo, "Делегировать согласование?")
  if ans <> vbYes then exit sub

' открываетм форму
  Set frmOrder = ThisApplication.InputForms("FORM_KD_ARGEE_DELEG")
  frmOrder.Attributes("ATTR_KD_DOCBASE").Object = thisObject
'  frmOrder.OkButtonText = "Делегировать"
  If not frmOrder.Show Then exit sub
  set user = frmOrder.Attributes("ATTR_KD_EXEC").User
  txt = frmOrder.Attributes("ATTR_KD_NOTE").value

'создаем новое поручение
  nBl = aprRow.Attributes("ATTR_KD_APRV_NO_BLOCK").Value
  aTime = aprOrder.Attributes("ATTR_KD_POR_PLANDATE").Value

  call createAppRow(agreeObj,nBl,aTime, user)
  curTxt = ""
  if thisApplication.CurrentUser.Handle <> curUser.Handle then curTxt = " от имени замещающего " _
        & thisApplication.CurrentUser.Attributes("ATTR_KD_FIO").value
' закрываем поручение 
  call ThisApplication.ExecuteScript("CMD_KD_ORDER_LIB","SetOrderDone",aprOrder,txt, "Делегировано " _
          & user.Attributes("ATTR_KD_FIO").value & " " & curTxt)

  ' проверяем все ли закрыто  в блоке
  if CheckBlockFinished(agreeObj, aprRow.Attributes("ATTR_KD_APRV_NO_BLOCK").value) then 
    ' создаем если нужно следующее поручений
      if not CreateAproveOrders(agreeObj) then
        call Set_DocAprDone(docObj) ' если не создали ни одного, то закрываем документ
      end if
  end if

  thisForm.Close false
End Sub

'=============================================
sub BTN_REVIEWS_OnClick()
  Set frmOrder = ThisApplication.InputForms("FORM_KD_AGREE_REVIEWS")
  frmOrder.Attributes("ATTR_KD_DOCBASE").Object = thisObject
  call SetObjectGlobalVarrible("ParDocBase",thisObject)
'  frmOrder.OkButtonText = "Делегировать"
  If not frmOrder.Show Then exit sub
  res = GetGlobalVarrible("ApplyReview")
  if res = "T" then 
    RemoveGlobalVarrible("ApplyReview")
    thisForm.Close()
  end if

End Sub


'Sub Files_DragAndDropped(FilesPathArray, Object, Cancel)
'  call FilesDragAndDropped(FilesPathArray, Object, Cancel)
'End Sub


'=============================================
Sub BTN_SHOWFILE_OnClick()
  Sels = ThisForm.Controls("QUERY_KD_FILES_IN_DOC").SelectedItems
  if Ubound(Sels,1) < 0 then
      ShowFile(0)
  else
      ShowFile(sels(0))
  end if
End Sub

