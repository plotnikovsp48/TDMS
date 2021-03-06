use CMD_KD_GLOBAL_VAR_LIB
use CMD_KD_COMMON_LIB
use CMD_KD_AGREEMENT_LIB

'=============================================
Sub Form_BeforeShow(Form, Obj)
  
  Obj.Update ' если не сохранено надо сохранить, инначе выборки не показывают
  set edit = thisForm.Controls("TDMSEDIT1").ActiveX
  edit.buttontype = 4
'   set checkbox = thisForm.Controls("TDMSEDIT1").ActiveX
'  checkbox.AttributeDef = thisApplication.AttributeDefs("ATTR_TO_SEND")'"ATTR_CHECKBOX ")      '  ATTR_CHECKBOX - какой нибудь атрибут типа bool (флаг)
'  checkbox.Value = true


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
  SetContolEnable() 'доступность кнопок
  call ThisApplication.ExecuteScript("CMD_KD_ORDER_LIB", "Set_OrdersReaded", Obj)
  'Set_OrdersReaded(Obj) 'отметить поручение как принятое в работу
  

End Sub

'=============================================
Sub Form_BeforeClose(Form, Obj, Cancel)
  call RemoveGlobalVarrible("AgreeObj")
  call RemoveGlobalVarrible("Settings")
End Sub

'=============================================
sub  SetContolEnable()
  set settings = GetSettings()
  if settings is nothing  then 
    SetControlNotEnable(false)
    exit sub
  else   
    isExec = isInic(thisApplication.CurrentUser, thisObject)
    isApr = IsCanAprove(thisApplication.CurrentUser, thisObject)
    isCanEd = isCanEdit()
    thisForm.Controls("BTN_SEND").Enabled = (isExec and isCanEd)
    thisForm.Controls("BTN_ADD_APRV").Enabled = isApr  or (isExec  and isCanEd)
    thisForm.Controls("BTN_APR_CHANGE").Enabled = isApr  or (isExec  and isCanEd)
    thisForm.Controls("BTN_DEL_APR").Enabled = isApr  or (isExec and isCanEd)
    thisForm.Controls("BTN_APROVE").Enabled = isApr
    thisForm.Controls("BTN_REJECT").Enabled = isApr
    thisForm.Controls("BTN_SAVE").Enabled = isExec
    thisForm.Controls("BTN_LOAD").Enabled = isExec and isCanEd 
    thisForm.Controls("BTN_TO_WORK").Enabled = (isExec and not isCanEd)   
    thisForm.Controls("BTN_UP").Enabled = isApr  or (isExec  and isCanEd)
    thisForm.Controls("BTN_DOWN").Enabled = isApr  or (isExec  and isCanEd)
    thisForm.Controls("BTN_FROM_ORDER").Enabled = isExec  and isCanEd
  end if
end sub

'=============================================
function SetControlNotEnable(enable)
  for each control in thisForm.Controls 
    control.Enabled = enable
  next
end function  

'=============================================
function GetAgreeObj()
  set GetAgreeObj = GetAgreeObjByObj(thisObject)
'  
'  if IsExistsGlobalVarrible("AgreeObj") then 
'    set GetAgreeObj =  GetObjectGlobalVarrible("AgreeObj")
'    exit function
'  end if
'  
'  set query = ThisApplication.Queries("QUERY_GET_ARGEEMENT")
'  query.Parameter("PARAM0") = thisObject.handle
'  set objs = query.Objects
'  if objs.Count>0 then _
'    set GetAgreeObj = objs(0)

'  if GetAgreeObj is nothing then _
'     set  GetAgreeObj = CreateAgree()  
'  call SetObjectGlobalVarrible("AgreeObj", GetAgreeObj)
end function

function Test(docObj)
  msgbox docObj.Description
  Test = true
end function 
'==============================================================================
Sub BTN_ADD_APRV_OnClick()
  CreateAppr()
End Sub

'==============================================================================
Sub BTN_DEL_APR_OnClick()
  ApprsDel()
End Sub

'==============================================================================
Sub BTN_APR_CHANGE_OnClick()
  ThisScript.SysAdminModeOn

  set agreeObj = GetAgreeObj()
  if agreeObj is nothing then exit sub
  
  Set control = thisForm.Controls("QUERY_APROVE_LIST")
  iSel = control.ActiveX.SelectedItem
  If iSel < 0 Then 
     msgbox "Не выбран согласующий!"
     Exit Sub 
  end if  
  set aprRow =  control.value.RowValue(iSel)
  
  if agreeObj.Attributes("ATTR_KD_CUR_VERSION").value <> aprRow.Attributes("ATTR_KD_CUR_VERSION").value then 
    msgbox "Невозможно изменить согласующего предыдущих циклов"
    exit sub
  end if

  set aprOrder = aprRow.Attributes("ATTR_KD_LINK_ORDER").object
  if not aprOrder is nothing then 
    msgbox "Невозможно изменить согласующего, т.к. согласование уже началось"
    exit sub
  end if

  Set frmSetShelve = ThisApplication.InputForms("FORM_KD_ADD_APPROVE")
  'frmSetShelve.Attributes("ATTR_KD_APRV_NO_BLOCK").Value = aprRow.Attributes("ATTR_KD_APRV_NO_BLOCK").Value
  'frmSetShelve.Attributes("ATTR_KD_BLOCKS").Value = Cstr(aprRow.Attributes("ATTR_KD_APRV_NO_BLOCK").Value)
  'frmSetShelve.Attributes("ATTR_KD_APRV_TYPE").Classifier = aprRow.Attributes("ATTR_KD_APRV_TYPE").Classifier
  frmSetShelve.Attributes("ATTR_KD_APRV").Value = aprRow.Attributes("ATTR_KD_APRV").User
  frmSetShelve.Attributes("ATTR_KD_ARGEE_TIME").Value = aprRow.Attributes("ATTR_KD_ARGEE_TIME").value

  frmSetShelve.Attributes("ATTR_KD_DOCBASE").value = thisObject'agreeObj
  frmSetShelve.Attributes("ATTR_KD_HIST_OBJECT").value = agreeObj

  If frmSetShelve.Show Then
      'блокируем объект
      if not ThisApplication.ExecuteScript("CMD_KD_REGNO_KIB", "SetLock", agreeObj) then
        msgBox " Невозможно изменить список согласования, т.к. он заблокирован", VbCritical
        exit sub
      end if    
      Set TAttrRows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows
      set row = TAttrRows(aprRow) 

      'row.Attributes("ATTR_KD_APRV_NO_BLOCK").Value = frmSetShelve.Attributes("ATTR_KD_APRV_NO_BLOCK").Value
      row.Attributes("ATTR_KD_ARGEE_TIME").Value = frmSetShelve.Attributes("ATTR_KD_ARGEE_TIME").Value
'      row.Attributes("ATTR_KD_APRV_TYPE").Classifier = frmSetShelve.Attributes("ATTR_KD_APRV_TYPE").Classifier
      row.Attributes("ATTR_KD_APRV").Value = frmSetShelve.Attributes("ATTR_KD_APRV").User
      TAttrRows.update
      agreeObj.Update
      agreeObj.Unlock agreeObj.Permissions.LockType
  end if

End Sub

'==============================================================================
Sub BTN_DOWN_OnClick()
  UserDown()
End Sub

'==============================================================================
Sub BTN_UP_OnClick()
   UserUP()
End Sub
'==============================================================================
Sub BTN_SAVE_OnClick()
  msgBox "Раздел находится в разработке"
End Sub
'==============================================================================
Sub BTN_LOAD_OnClick()
  msgBox "Раздел находится в разработке"
End Sub
'==============================================================================
Sub BTN_SEND_OnClick()
  set agreeObj = GetAgreeObj()
  if agreeObj is nothing then exit sub

  'произвести проверки
  if not CheckBeforeSend(agreeObj) then exit sub
  'создать поручения
  if not CreateAproveOrders(agreeObj) then exit sub
  'поменять стутусы и раздать права
  if not SetStatuses(agreeObj) then exit sub
  ' A.O. 
  'msgbox "Документ передан на согласование"
  thisForm.Close false
    
End Sub

'==============================================================================
Sub BTN_APROVE_OnClick()
  Aprove_Doc(thisObject)
End Sub

'==============================================================================
'==============================================================================
function GetRow(TRows, ver,bl,inBl)
  set GetRow =  nothing
  for each row in TRows
    if row.attributes("ATTR_KD_CUR_VERSION").value = ver and _
      row.attributes("ATTR_KD_APRV_NO_BLOCK").value = bl and _
      Row.attributes("ATTR_KD_APRV_NPP").value = inBl then 
        set GetRow = row
        exit function
    end if  
  next  
end function

'==============================================================================
Sub BTN_REJECT_OnClick()
  call Reject_Doc(thisObject)
End Sub


'=============================================
sub SetChBox()
  set agreeObj = GetAgreeObj()
  if agreeObj is nothing then exit sub

  set checkbox = thisForm.Controls("TDMSEDIT1").ActiveX
  'set chk = thisForm.Controls("CHECKBOX1").ActiveX
  If agreeObj.Attributes("ATTR_KD_FIRST_REJECT").Value = true Then 
       checkbox.value = true
  else 
       checkbox.value = false
  End if  
end sub

''=============================================
'Sub CHECKBOX1_Change()
'   if not IsCanEdit() then 
'     SetChBox()
'     exit sub
'   end if
'   set chk = thisForm.Controls("CHECKBOX1").ActiveX
'  
'   set agreeObj = GetAgreeObj()
'   if agreeObj is nothing then exit sub

'   ThisScript.SysAdminModeOn
'   agreeObj.Attributes("ATTR_KD_FIRST_REJECT").Value = chk.Value
'   agreeObj.Update
'End Sub

'=============================================
Sub BTN_PRINT_RES_OnClick()
    msgBox "Раздел находится в разработке"
End Sub
'=============================================
Sub BTN_TO_WORK_OnClick()
    ReturnToWork(thisObject)
End Sub


'==============================================================================
Sub QUERY_APROVE_LIST_DblClick(iItem, bCancelDefault)
   BTN_APR_CHANGE_OnClick()
End Sub

'==============================================================================
Sub BTN_FROM_ORDER_OnClick()
  CreateFromOrder()
end sub

'==============================================================================
' Чиним переключение checkbox по click мыши
Sub TDMSEDIT1_ButtonClick(bCancelDefaultOperation)
   if not IsCanEdit() then 
     SetChBox()
     bCancelDefaultOperation = true
     exit sub
   end if

   set agreeObj = GetAgreeObj()
   if agreeObj is nothing then 
      bCancelDefaultOperation = true 
      exit sub
   end if   
   set checkbox = thisForm.Controls("TDMSEDIT1").ActiveX
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

''==============================================================================
'' Чиним переключение чекбокс по пробелу
'Sub TDMSEDIT1_KeyDown(pnChar,nShiftState)
'  if pnChar = 32 then 
'    set checkbox = thisForm.Controls("TDMSEDIT1").ActiveX
'    if checkbox.Value = false then
'      checkbox.Value = true
'    else 
'      checkbox.Value = false
'    end if
'    pnChar = 0 ' cancel default
' end if
'End Sub
