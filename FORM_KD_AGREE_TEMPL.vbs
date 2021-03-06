use CMD_KD_TEMPL_LIB
use CMD_KD_AGREEMENT_LIB


'=================================
Sub Form_BeforeShow(Form, Obj)
  SetCntrEnable()
  SetCntrValue() 
End Sub

'=================================
sub SetCntrValue() 
  thisForm.Controls("TDMSEDIT_APPR").ActiveX.ComboItems = thisApplication.Users
  thisForm.Controls("TDMSEDIT_APPR").Value = ""
  thisForm.Controls("TDMSEDIT_APPR").ActiveX.buttontype = 2
  thisForm.Controls("TDMSEDIT_BLOCK").Enabled = false
  mBl = GetMaxBl(thisObject, 0)
  thisForm.Controls("TDMSEDIT_BLOCK").Value = mBl + 1
end sub
'=================================
sub  setCntrEnable()
  if thisApplication.CurrentUser.Groups.Has("Администраторы шаблонов") then 
      thisForm.Controls("ATTR_KD_T_REGIONS").Enabled = true
      thisForm.Controls("ATTR_KD_T_REGIONS").ReadOnly = false
      thisForm.Controls("BTN_ALL_REG").Enabled = true
'      thisForm.Controls("BTN_ALL_DOC").Enabled = true
      thisForm.Controls("ATTR_KD_PERS_TEMPL").Enabled = true
      thisForm.Controls("ATTR_KD_REQUIRE").Enabled = true
  end if
end sub
'=================================
Sub ATTR_NAME_BeforeModify(Text,Cancel)
  if not checkTmplName(text, thisObject.ObjectDefName) then 
    msgbox "Шаблон с таким наименование существует. " & vbNewLine & "Введите другое наименование"
    cancel = true
  end if  
End Sub

'=================================
Sub BTN_ADD_USER_OnClick()
    Add_User_Click()
End Sub
'=================================
Sub BTN_ADD_GROUP_OnClick()
    set selObj = thisApplication.Dialogs.SelectDlg '.SelectObjectDlg
    selObj.Prompt = "Выберите пользователей"
    SelObj.SelectFrom = thisApplication.Groups
    RetVal = selObj.Show 
    Set projObjs = selObj.Objects
    If (RetVal<>TRUE) Or (projObjs.count = 0) Then Exit Sub
    for each user in projObjs
       call Add_User(user, false,thisForm)  
    next
End Sub
'=================================
Sub BTN_ALL_REG_OnClick()
  set q = thisApplication.Queries("QUERY_KD_ALL_REGION")
  set objs = q.Objects
  for each obj in objs
    call addReg(obj,true)
  next 
End Sub
'=================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  if attribute.AttributeDefName = "ATTR_KD_PERS_TEMPL" then _
         call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", Obj)
End Sub
'=================================
Sub Form_BeforeClose(Form, Obj, Cancel)
  txt =  checkTeml(obj)
  if txt <> "" then
    msgbox "Не все обязательные поля заданы - " & vbNewLine & txt, vbCritical, "Ошибка"
    cancel = true
    exit sub
  end if
End Sub
'=================================
Sub BTN_DEL_USER_OnClick()
    call Del_FromTable("ATTR_KD_ORDER_RECIPIEND", 0 )      
End Sub
'=============================================
Sub BTN_ADD_APRV_OnClick()
  nBl = thisform.Controls("TDMSEDIT_BLOCK").Value
  if not CheckUser() then exit sub
  set newUser = thisApplication.Users(thisform.Controls("TDMSEDIT_APPR").Value)

  call addAppRow(nBl, newUser)
  thisForm.Controls("TDMSEDIT_APPR").Value = ""
  thisObject.Update
  thisForm.Refresh
End Sub
'=============================================
Sub TDMSEDIT_APPR_Modified()
  CheckUser()
End Sub
'=============================================
function CheckUser()
  CheckUser = false
   
  val = thisForm.Controls("TDMSEDIT_APPR").Value 
  if val = "" then exit function
  set user = nothing
  if thisApplication.Users.Has(val) then _
      set user = thisApplication.Users(val)
  if user is nothing then
    msgbox "Пользователь " & val & " не существует. Введите другого пользователя", vbCritical, "Ошибка ввода"
    thisForm.Controls("TDMSEDIT_APPR").Value = ""
    exit function
  end if
  CheckUser = true
end function
'==============================================================================
sub addAppRow(nBl, newUser)
    thisScript.SysAdminModeOn
  'записываем введеные данные
      Set TAttrRows = thisObject.Attributes("ATTR_KD_TAPRV").Rows
      set row = TAttrRows.Create

      row.Attributes("ATTR_KD_APRV_NO_BLOCK").Value = nBl
      row.Attributes("ATTR_KD_APRV").Value = newUser
      row.Attributes("ATTR_KD_LINKS_USER").Value = thisApplication.CurrentUser
'      TAttrRows.update
end sub
'==============================================================================
sub DelUsers()
  count = 0

  Set control = thisForm.Controls("QUERY_APROVE_LIST_TEMPL")
  iSel = control.ActiveX.SelectedItem
  If iSel < 0 Then 
     msgbox "Не выбран согласующий!"
     Exit Sub 
  end if  

  ar = thisapplication.Utility.ArrayToVariant(control.SelectedItems)
  Answer = MsgBox( "Вы уверены, что хотите удалить из списка согласующих " & Cstr(Ubound(ar)+1) _
         & " пользователя(ей)?" , vbQuestion + vbYesNo,"Удалить?")
  if Answer <> vbYes then exit sub

  for i = 0 to Ubound(ar)
     set aprRow =  control.value.RowValue(ar(i))
     if DelUser(aprRow) then count = count + 1
  next
  if count>0 then 
      ' A.O.
       'msgbox "Удалено " & count & " пользователей"
  end if
end sub 
'==============================================================================
function DelUser(row)
  thisScript.SysAdminModeOn
  DelUser = false
  set row = thisObject.Attributes("ATTR_KD_TAPRV").Rows(row)
  aprover = row.Attributes("ATTR_KD_APRV").value
  ver = row.Attributes("ATTR_KD_CUR_VERSION").value
  
  set rows = thisobject.Attributes("ATTR_KD_TAPRV").Rows
  bl = row.Attributes("ATTR_KD_APRV_NO_BLOCK").value
  rowCount = GetCountInBlock(rows, ver, bl)
  thisObject.Permissions = sysAdminPermissions
  row.Erase
  if rowCount = 1 then call ReNumBlock(rows,ver, bl, -1)
  thisObject.update
  DelUser = true
end function
'==============================================================================
Sub BTN_DEL_APR_OnClick()
  DelUsers()
End Sub
'==============================================================================
Sub BTN_PLUS_OnClick()
  mBl = GetMaxBl(thisObject, 0)
  cnt = thisForm.Controls("TDMSEDIT_BLOCK").Value
  if not IsNumeric(cnt) then exit sub
  cnt = cInt(cnt)
  if cnt <= mBl then thisForm.Controls("TDMSEDIT_BLOCK").ActiveX.Text = cnt + 1 
End Sub
'=============================================
Sub BTN__OnClick()
  cnt = thisForm.Controls("TDMSEDIT_BLOCK").Value
  if not IsNumeric(cnt) then exit sub
  cnt = cInt(cnt)
  if cnt > 1 then thisForm.Controls("TDMSEDIT_BLOCK").Value = cnt-1 
End Sub
'==============================================================================
sub RowUP()
  ThisScript.SysAdminModeOn
  Set TAttrRows = thisObject.Attributes("ATTR_KD_TAPRV").Rows
  Set control = thisForm.Controls("QUERY_APROVE_LIST_TEMPL")
  iSel = control.ActiveX.SelectedItem
  If iSel < 0 Then 
     msgbox "Не выбран согласующий!"
     Exit sub 
  end if
  
  set aprRow =  control.value.RowValue(iSel)
  if aprRow is nothing then exit sub
  set aprRow = thisObject.Attributes("ATTR_KD_TAPRV").Rows(aprRow)

  bl = aprRow.Attributes("ATTR_KD_APRV_NO_BLOCK").value
  rev = 0
  appCount =  GetCountInBlock(TAttrRows, rev, bl)
  if bl = 1 then 
    if appCount = 1 then 
      msgbox "Это минимальный номер блока в текущем цикле согласования", vbInformation
      exit sub
    end if
    Answer = msgbox ("Это минимальный номер блока в текущем цикле согласования." & vbNewLine & _
          "Вы уверены, что хотите переместить согласующего в новый блок?",  vbQuestion + vbYesNo, "Создать новый блок?")
    if Answer <> vbYes then exit sub
    call ReNumBlock(TAttrRows,rev, bl-1, +1)
  else ' чтобы не было дырок в блоках
     if appCount = 1 then _ 
         call ReNumBlock(TAttrRows,rev, bl, -1)
  end if

  If not aprRow is Nothing  Then
    if bl > 1 then newBl = bl - 1 else newBl = 1
    aprRow.Attributes("ATTR_KD_APRV_NO_BLOCK").Value = newBl
    TAttrRows.Update
    thisObject.Update
  End If    
  SetCntrValue() ' если изменилось кол-во блоков

end sub
'==============================================================================
sub RowDown()
  ThisScript.SysAdminModeOn
  Set TAttrRows = thisObject.Attributes("ATTR_KD_TAPRV").Rows
  
  Set control = thisForm.Controls("QUERY_APROVE_LIST_TEMPL")
  iSel = control.ActiveX.SelectedItem
  If iSel < 0 Then 
     msgbox "Не выбран согласующий!"
     Exit sub 
  end if
  set aprRow =  control.value.RowValue(iSel)
  if aprRow is nothing then exit sub
  set aprRow = thisObject.Attributes("ATTR_KD_TAPRV").Rows(aprRow)

  bl = aprRow.Attributes("ATTR_KD_APRV_NO_BLOCK").value
  rev = 0
  maxBl = GetMaxBL(thisObject, rev)  
  appCount =  GetCountInBlock(TAttrRows, rev, bl)
  if bl = maxBl then 
    if appCount = 1 then 
      msgBox "Невозможно переместить согласующего ниже - он единственный согласующий в последнем блоке.", vbCritical, "Отменено"
      exit sub
    else
      Answer = msgbox ("Это последний номер блока в текущем цикле согласования." & vbNewLine & _
          "Вы уверены, что хотите переместить согласующего в новый блок?",  vbQuestion + vbYesNo, "Создать новый блок?")
      if Answer <> vbYes then exit sub
    end if
  else  
    if appCount = 1 then 
      call ReNumBlock(TAttrRows,rev, bl, -1)
      bl = bl - 1  
    end if  
  end if

  If not aprRow is Nothing  Then
    aprRow.Attributes("ATTR_KD_APRV_NO_BLOCK").Value = bl + 1
    TAttrRows.Update
    thisObject.Update
  End If    
  SetCntrValue() ' если изменилось кол-во блоков

end sub
'==============================================================================
Sub BTN_UP_OnClick()
  RowUP()
End Sub
'==============================================================================
Sub BTN_DOWN_OnClick()
  RowDown()
End Sub
'==============================================================================
Sub BTN_ALL_DOC_OnClick()
  set rows = thisForm.Attributes("ATTR_KD_T_DOC_TYPE").Rows
  set root = thisApplication.Classifiers("NODE_KD_DOC_TYPE")

  for each cls in root.Classifiers
    if not IsExistsValItemColWithoutRow(rows, cls.Description, "ATTR_KD_DOC_TYPE", nothing) then 
        set newRow = rows.Create
        newRow.Attributes("ATTR_KD_DOC_TYPE").value = cls
    end if 
  next 
  thisForm.Refresh
End Sub
'==============================================================================
Sub BTN_FROM_TEMPL_OnClick()
  set fld = GetTmplFolder()
  if fld is nothing then exit sub
  thisScript.SysAdminModeOn
 
  call SetObjectGlobalVarrible("OrderForm", thisForm)
  Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
  CreateObjDlg.ActiveForm = thisApplication.InputForms("FORM_KD_AGREE_TEMPL")
  CreateObjDlg.Object = fld
  ans = CreateObjDlg.Show
  thisObject.Update
End Sub
