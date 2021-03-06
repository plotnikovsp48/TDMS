use CMD_KD_COMMON_LIB
use CMD_KD_COMMON_BUTTON_LIB
use CMD_KD_ORDER_LIB
use CMD_KD_USER_PERMISSIONS
use CMD_KD_AGREEMENT_LIB
use CMD_KD_TEMPL_LIB
use CMD_KD_CURUSER_LIB
'=============================================
Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description

'  Obj.Update ' если не сохранено надо сохранить, инначе выборки не показывают
  
  call RemoveGlobalVarrible("AgreeObj")
  call RemoveGlobalVarrible("Settings") ' EV чтобы наверняка новое значение
  set settings = GetSettings()
  if settings is nothing  then 
    SetControlNotEnable(false)
    exit sub  
  end if
  
  Set Query = ThisForm.Controls("QUERY_APROVE_LIST").ActiveX
  Query.ColumnSortEnabled = False
  Query.ColumnWidth(1) = 30

  ThisForm.Refresh 
  SetChBox()
  SetEditValue()
  SetContolEnable(settings)  
  CopyPrevIsNeeded()
  call SetGlobalVarrible("ShowForm", "FORM_ARGEE_CREATE")
End Sub

'=============================================
sub CopyPrevIsNeeded()

  set settings = GetSettings()
  if settings is nothing  then exit sub 
  if not CheckStartStatusSil(settings, true, thisObject) then exit sub ' только в начальном статусе

  set agreeObj = GetAgreeObjByObj(thisObject)
  if agreeObj is nothing then exit sub

  ver = cInt(agreeObj.Attributes("ATTR_KD_CUR_VERSION").value)
  if ver > 1 then 
    Set rows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows
    count =  GetCountInBlock(rows, ver, 1)
    if count = 0 then 
      call CopyPrevAppBlock(agreeObj, rows, ver)
      thisForm.Refresh
    end if   
  end if
end sub
'=============================================
sub SetEditValue ()
  set agreeObj = GetAgreeObjByObj(thisObject)
  if agreeObj is nothing then exit sub

  set edit = thisForm.Controls("TDMSEDIT_CANCEL").ActiveX
  edit.buttontype = 4

'---Поле дата без атрибута с использованием TDMSEditCtrl -------
  Set field = thisForm.Controls("TDMSEDIT_Date").ActiveX ' TDMSEditCtrl
  set def = ThisApplication.AttributeDefs("ATTR_DATA") ' тип атрибута Дата\Время
  field.AttributeDef = def

  thisForm.Controls("TDMSEDIT_APPR").ActiveX.ComboItems = thisApplication.Users
  thisForm.Controls("TDMSEDIT_APPR").Value = ""
  thisForm.Controls("TDMSEDIT_APPR").ActiveX.buttontype = 2
  thisForm.Controls("TDMSEDIT_Date").Value = DateAdd ("d", 3, Date) 
  thisForm.Controls("TDMSEDIT_BLOCK").Enabled = false

  mBl = GetMaxBl(agreeObj, agreeObj.Attributes("ATTR_KD_CUR_VERSION").value)

  thisForm.Controls("TDMSEDIT_BLOCK").Value = mBl + 1
'  thisForm.Controls("ATTR_KD_APRV").Enabled = true
'  thisForm.Controls("ATTR_KD_APRV").Value = ""
'  thisForm.Controls("ATTR_KD_APRV").ActiveX.ComboItems = thisApplication.Users
'  thisForm.Controls("ATTR_KD_ARGEE_TIME").Enabled = true
'  thisForm.Controls("ATTR_KD_ARGEE_TIME").Value = DateAdd ("d", 3, Date) 
end sub
'=============================================
sub SetChBox()
  set agreeObj = GetAgreeObjByObj(thisObject)
  if agreeObj is nothing then exit sub

  set checkbox = thisForm.Controls("TDMSEDIT_CANCEL").ActiveX
  If agreeObj.Attributes("ATTR_KD_FIRST_REJECT").Value = true Then 
       checkbox.value = true
  else 
       checkbox.value = false
  End if  

end sub


'=============================================
sub SetContolEnable(settings)
  set curUs = GetCurUser() 

  isAproving = thisObject.StatusName = "STATUS_KD_AGREEMENT"
  isODO = thisObject.IsKindOf("OBJECT_KD_BASE_DOC")
  if isODO then 
    isExec = IsExecutor(curUs, thisObject)
  else
    isExec = isInic(curUs, thisObject)
  end if
  isContr = IsController(curUs, thisObject)
  isApr = IsCanAprove(curUs, thisObject)'IsAprover(thisApplication.CurrentUser, thisObject)
  isCanEd =  CheckStartStatusSil(settings, true,thisObject)'isCanEdit()
''thisForm.Controls("BTN_SEND").Enabled = ((isExec or isContr) and isCanEd)
  enable = (isApr and isAproving) or ((isExec or isContr) and (isCanEd or isAproving))
  thisForm.Controls("BTN_ADD_APRV").Enabled = enable
  thisForm.Controls("BTN_DEL_APR").Enabled = enable
  thisForm.Controls("BTN_UP").Enabled = enable
  thisForm.Controls("BTN_DOWN").Enabled = enable
  
'  thisForm.Controls("BTN_APROVE").Enabled = (isApr and isAproving) 
'  thisForm.Controls("BTN_REJECT").Enabled = (isApr and isAproving) 
'  thisForm.Controls("BTN_APR_CHANGE").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_LOAD_FILE").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_DEL_APP").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_CHECKOUT").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  thisForm.Controls("BTN_CHECKIN").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
'  
'  thisForm.Controls("BTN_SEND_TO_CHECK").Enabled = isExec and thisObject.StatusName = "STATUS_KD_DRAFT"
'  ifSt = (thisObject.StatusName = "STATUS_KD_CHECK") or (thisObject.StatusName = "STATUS_SIGNING") _
'      or(thisObject.StatusName = "STATUS_KD_AGREEMENT")
'  thisForm.Controls("BTN_RETURN").Enabled = (isExec or isContr) and ifSt
'  
''  thisForm.Controls("").Enabled = isApr
'  
end sub

'=============================================
Sub BTN_ADD_APRV_OnClick()
  'AddAprover()
  set agreeObj = GetAgreeObjByObj(thisObject)
  if agreeObj is nothing then exit sub
  nBl = thisform.Controls("TDMSEDIT_BLOCK").Value
  if not CheckDate() then exit sub
  aTime = thisform.Controls("TDMSEDIT_Date").Value

  if not CheckUser() then exit sub
  set newUser = thisApplication.Users(thisform.Controls("TDMSEDIT_APPR").Value)

  call createAppRow(agreeObj,nBl,aTime, newUser)
  'thisForm.Controls("ATTR_KD_APRV").Enabled = true
  'thisForm.Controls("ATTR_KD_APRV").Value = ""
  'thisForm.Controls("ATTR_KD_ARGEE_TIME").Enabled = true
  thisForm.Controls("TDMSEDIT_APPR").Value = ""
end sub   

'=============================================
Sub BTN_SEND_OnClick()
    Send_to_Aprove()
End Sub

'=============================================
Sub BTN_DEL_APR_OnClick()
  oldName = thisForm.SysName
  call RemoveGlobalVarrible("ShowForm")

    ApprsDel()

  call SetGlobalVarrible("ShowForm", oldName)
'    SetContolEnable()
End Sub

'=============================================
Sub BTN_APR_CHANGE_OnClick()
  Set control = thisForm.Controls("QUERY_APROVE_LIST")
  ChangeAprover(control)
End Sub

''=============================================
'Sub QUERY_APROVE_LIST_DblClick(iItem, bCancelDefault)
'    call BTN_APR_CHANGE_OnClick
'    
'    bCancelDefault = true
'    
'    thisForm.Refresh() ' EV иначе не обновляемся атрибуты
'End Sub

'=============================================
Sub Form_BeforeClose(Form, Obj, Cancel)
  call RemoveGlobalVarrible("AgreeObj")
  call RemoveGlobalVarrible("Settings")
  call RemoveGlobalVarrible("ShowForm")
End Sub
'=============================================
Sub TDMSEDIT_CANCEL_ButtonClick(bCancelDefaultOperation)
   if not IsCanEdit() then 
     SetChBox()
     bCancelDefaultOperation = true
     exit sub
   end if

   set agreeObj = GetAgreeObjByObj(thisObject)
   if agreeObj is nothing then 
      bCancelDefaultOperation = true 
      exit sub
   end if   
   set checkbox = thisForm.Controls("TDMSEDIT_CANCEL").ActiveX
   if checkbox.Value = false then
    checkbox.Value = true
   else 
    checkbox.Value = false
   end if
   ThisScript.SysAdminModeOn
   agreeObj.Attributes("ATTR_KD_FIRST_REJECT").Value = checkbox.Value
   agreeObj.Update
   
   bCancelDefaultOperation = true

End Sub
'=============================================
Sub BTN__OnClick()
  cnt = thisForm.Controls("TDMSEDIT_BLOCK").Value
  if not IsNumeric(cnt) then exit sub
  cnt = cInt(cnt)
  if cnt > 1 then thisForm.Controls("TDMSEDIT_BLOCK").Value = cnt-1 
End Sub
'=============================================
Sub BTN_PLUS_OnClick()
  set agreeObj = GetAgreeObjByObj(thisObject)
  if agreeObj is nothing then exit sub

  mBl = GetMaxBl(agreeObj, agreeObj.Attributes("ATTR_KD_CUR_VERSION").value)
  cnt = thisForm.Controls("TDMSEDIT_BLOCK").Value
  if not IsNumeric(cnt) then exit sub
  cnt = cInt(cnt)
  if cnt <= mBl then thisForm.Controls("TDMSEDIT_BLOCK").ActiveX.Text = cnt + 1 
End Sub
'=============================================
Sub TDMSEDIT_APPR_Modified()
  CheckUser()
End Sub
'=============================================
Sub TDMSEDIT_Date_Modified()
  CheckDate()
End Sub
'=============================================
function CheckDate()
  CheckDate = false

  val = thisForm.Controls("TDMSEDIT_Date").Value 
  if val = "" then 
    CheckDate = true ' EV пустая дата допустима
    exit function
  end if
  if not IsDate(val) then 
    msgbox "Введеное значение " & val & " не является датой. Введите другую дату", vbCritical, "Ошибка ввода"
    exit function
  end if
  dVal = CDate(val)
  if dVal < date then 
    msgbox "Срок согласования " & val & " не может быть меньше текущей даты. Введите другую дату", vbCritical, "Ошибка ввода"
    exit function
  end if
  CheckDate = true
end function

'=============================================
Sub BTN_UP_OnClick()
    UserUP()
End Sub
'=============================================
Sub BTN_DOWN_OnClick()
    UserDown()
End Sub
'==============================================================================
Sub BTN_FROM_ORDER_OnClick()
  CreateFromOrder()
End Sub

'Sub TDMSEDIT_BLOCK_BeforeModify(strTextEntered,bCancelModify)
'  bCancelModify = true
'End Sub
'==============================================================================
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
'==============================================================================
Sub BTN_FROM_TEMPL_OnClick() 
  set fld = GetTmplFolder()
  if fld is nothing then exit sub
  thisScript.SysAdminModeOn
 
  call SetObjectGlobalVarrible("OrderForm", thisForm)
  call SetObjectGlobalVarrible("DocObj", thisObject)

  oldName = thisForm.SysName
  call RemoveGlobalVarrible("ShowForm")

  Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
  CreateObjDlg.Object = fld
  CreateObjDlg.ActiveForm = thisApplication.InputForms("FORM_KD_AGREE_TEMPLS")
  ans = CreateObjDlg.Show
  call SetGlobalVarrible("ShowForm", oldName)
  thisObject.Update ' чтобы отобразились данные в выборке
End Sub
'==============================================================================
Sub BTN_SAVE_TMPL_OnClick()
   set newObj = CreateTemplate("OBJECT_KD_AGREE_TEMPLATE")
   if newObj is nothing then exit sub
   copyAgreeUsers(newObj)
   oldName = thisForm.SysName
   call RemoveGlobalVarrible("ShowForm")
   
   Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
   CreateObjDlg.Object = newObj
   ans = CreateObjDlg.Show
 
   call SetGlobalVarrible("ShowForm", oldName)
  
   If not ans then
     newObj.Erase  ' EV все-таки подумать как удалять
     exit sub
   End if

End Sub
'==============================================================================
sub copyAgreeUsers(newObj)
  set agreeObj = GetAgreeObjByObj(thisObject)
  if agreeObj is nothing then exit sub
  set rows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows
  set nRows = newObj.Attributes("ATTR_KD_TAPRV").Rows
  ver = agreeObj.Attributes("ATTR_KD_CUR_VERSION").value
  for each row in rows
    if row.Attributes("ATTR_KD_CUR_VERSION").value = ver  then
      set user = row.Attributes("ATTR_KD_APRV").user
       'добавляем в шаблон
       set newRow = nRows.Create
       newRow.Attributes("ATTR_KD_APRV").value = user
       newRow.Attributes("ATTR_KD_APRV_NO_BLOCK").value = row.Attributes("ATTR_KD_APRV_NO_BLOCK").value 
    end if 
  next
  newObj.update
end sub
