use CMD_KD_COMMON_LIB
use CMD_KD_USER_PERMISSIONS
use CMD_KD_TEMPL_LIB
use CMD_KD_CURUSER_LIB
USE LIB_TEMPLATE_UTILITY
'==============================================================================
Sub Form_BeforeShow(Form, Obj)

   set docObj = Form.Attributes("ATTR_KD_DOCBASE").Object
   call SetObjectGlobalVarrible("DOCBASE", docObj)
   
   if not isSecretary(GetCurUser()) then 
     if  Form.Attributes("ATTR_KD_CONTR").Value = "" then Form.Attributes("ATTR_KD_CONTR").User = thisApplication.CurrentUser ' для секретаря контролера не ставим
     if Form.Attributes("ATTR_KD_AUTH").Value = "" then Form.Attributes("ATTR_KD_AUTH").User = thisApplication.CurrentUser
   else
     if Form.Attributes("ATTR_KD_AUTH").Value = "" then Form.Attributes("ATTR_KD_AUTH").User = GetFirstChief(thisApplication.CurrentUser)
     thisForm.Controls("ATTR_KD_AUTH").ReadOnly = false
   end if 
   'ShowUsers()
   form.Refresh
   SetControlEnable() 
   set cls = thisForm.Attributes("ATTR_KD_RESOL").Classifier
   if not cls is nothing then  'EV Делаем для всех
'   if thisForm.Attributes("ATTR_KD_RESOL").Value = "Ознакомиться" then _ 
       thisForm.Attributes("ATTR_KD_TEXT").Value = cls. Code'"Для ознакомления"
   end if    
   Set ctrl = thisForm.Controls("ATTR_KD_AUTH").ActiveX
   ctrl.ComboItems = thisApplication.Users
   Set ctrl = thisForm.Controls("ATTR_KD_CONTR").ActiveX
   ctrl.ComboItems = thisApplication.Users
   SetUser()   
   SetDocAttrs()
   OnAttrWithTemplatesRefreshComboItems("ATTR_KD_TEXT")

  'Открытие транзакции
'   If not ThisApplication.IsActiveTransaction Then  ThisApplication.StartTransaction

End Sub
'==============================================================================
sub SetDocAttrs()
    set docObj = GetObjectGlobalVarrible("DOCBASE")
    if docObj is nothing then exit sub
    if docObj.Attributes.has("ATTR_KD_WITHOUT_PROJ") then _
      thisForm.Attributes("ATTR_KD_WITHOUT_PROJ").value = docObj.Attributes("ATTR_KD_WITHOUT_PROJ").value 

    if docObj.Attributes.has("ATTR_KD_AGREENUM") then 
      set cont = docObj.Attributes("ATTR_KD_AGREENUM").object 
      if cont is nothing then 
        thisForm.Attributes("ATTR_KD_AGREENUM").value = ""
      else
        thisForm.Attributes("ATTR_KD_AGREENUM").object  = cont
      end if
    end if

    if docObj.Attributes.has("ATTR_KD_TLINKPROJ") then 
  '    thisForm.Attributes("ATTR_KD_TLINKPROJ").Rows = docObj.Attributes("ATTR_KD_TLINKPROJ").rows
      thisForm.Attributes("ATTR_KD_TLINKPROJ").Rows.RemoveAll
      for each row in docObj.Attributes("ATTR_KD_TLINKPROJ").rows
        set newRow = thisForm.Attributes("ATTR_KD_TLINKPROJ").Rows.Create
        for each nAttr in row.Attributes
          def = nAttr.AttributeDefName
          set DefType = thisApplication.AttributeDefs(def)
          call SetAttr(DefType, newRow, Row)
        next
      next
    end if
    thisform.Refresh
'    thisForm.Attributes("ATTR_KD_WITHOUT_PROJ").value = docObj.Attributes("ATTR_KD_WITHOUT_PROJ").value 
end sub

'==============================================================================
function GetFirstChief(user)
  set GetFirstChief = nothing
  set rows = user.Attributes("ATTR_KD_T_SERC_OF").rows
  if rows.count > 0 then _
    set GetFirstChief = rows(0).Attributes("ATTR_KD_CHIEF").User
end function

'==============================================================================
' Добавляем пользователя, если передали
sub SetUser()
 set user =  thisForm.Attributes("ATTR_KD_OP_DELIVERY").User
   if not user is nothing then 
     set rows = thisForm.Attributes("ATTR_KD_ORDER_RECIPIEND").Rows
     set newRow = rows.Create
     newRow.Attributes("ATTR_KD_OP_DELIVERY").value = user
     call setUserAttr(user, newRow)
'     call Form_TableAttributeChange(Form, Obj, thisForm.Attributes("ATTR_KD_ORDER_RECIPIEND"), _
'         newRow, "ATTR_KD_OP_DELIVERY", nothing, nothing)
     thisform.Refresh
   end if
end sub

'==============================================================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
'  if form.Controls.Has("TXT_" & Attribute.AttributeDefName) then call ShowUser(Attribute.AttributeDefName)
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
'==============================================================================
sub SetControlEnable()
  isMemo = (thisForm.Attributes("ATTR_KD_RESOL").Value = "Ознакомиться")
  hasCotr = (thisForm.Attributes("ATTR_KD_RESOL").Value = "Подготовить рецензию")

  thisForm.Controls("T_ATTR_KD_POR_PLANDATE").Visible = not isMemo
  thisForm.Controls("ATTR_KD_POR_PLANDATE").Visible = not isMemo

  thisForm.Controls("T_ATTR_KD_URGENTLY").Visible = not isMemo
  thisForm.Controls("ATTR_KD_URGENTLY").Visible = not isMemo
  thisForm.Controls("T_ATTR_KD_IMPORTANT").Visible = not isMemo
  thisForm.Controls("ATTR_KD_IMPORTANT").Visible = not isMemo

  thisForm.Controls("T_ATTR_KD_CONTR").Visible = not isMemo and not hasCotr
  thisForm.Controls("ATTR_KD_CONTR").Visible = not isMemo and not hasCotr
  thisForm.Controls("BTN_ADD_SELF").Visible = not isMemo and not hasCotr
  thisForm.Controls("BTN_DEL_CNT").Visible = not isMemo and not hasCotr
  
  SetAttrControlEnable()

end sub
'==============================================================================
sub SetAttrControlEnable()
  set docObj = GetObjectGlobalVarrible("DOCBASE")
  if docObj is nothing then exit sub

  thisForm.Controls("ATTR_KD_WITHOUT_PROJ").Enabled = docObj.Attributes.has("ATTR_KD_WITHOUT_PROJ")
  if not docObj.Attributes.has("ATTR_KD_AGREENUM") then 
    thisForm.Controls("ATTR_KD_WITHOUT_PROJ").Enabled = false 
    thisForm.Controls("BTN_KD_ADD_CONTR").Enabled = false 
    thisForm.Controls("BTN_KD_DEL_CONTR").Enabled = false 
  end if

  if not docObj.Attributes.has("ATTR_KD_TLINKPROJ") then 
    thisForm.Controls("ATTR_KD_TLINKPROJ").Enabled = false 
    thisForm.Controls("BTN_KD_ADD_PROJ").Enabled = false 
    thisForm.Controls("BTN_DEL_PRO").Enabled = false 
  end if
  
  if not DocObj.Attributes.Has("ATTR_KD_POR_RESDOC") and not DocObj.Attributes.Has("ATTR_KD_T_LINKS") then 
    thisForm.Controls("BTN_ADD_DOC").Enabled = false 
    thisForm.Controls("BTN_ADD_FILE").Enabled = false 
    thisForm.Controls("BTN_DEL_DOC").Enabled = false 
  end if

end sub
'==============================================================================
Sub Form_BeforeClose(Form, Obj, Cancel)
  Set Dict = ThisApplication.Dictionary("Packages")
  If dict.Exists("OK") Then
    If dict("OK") Then 
      txt =""
      if Form.Attributes("ATTR_KD_ORDER_RECIPIEND").Rows.Count = 0 then 
        'msgbox "Не задан ни один получатель!"
        txt = txt & "Не задан ни один получатель!" & vbNewLine
        cancel = true
      end if
      if trim(Form.Attributes("ATTR_KD_TEXT").value) = "" then 
        'msgbox "Не задан текст поручения!"
        txt = txt &  "Не задан текст поручения!" & vbNewLine
        cancel = true
      end if
      if not thisForm.Controls("ATTR_KD_POR_PLANDATE").Visible then 
        thisForm.attributes("ATTR_KD_POR_PLANDATE").value = ""
      else 
        Text = Form.Attributes("ATTR_KD_POR_PLANDATE").Value
        if isDate(Text) then
          newDate = CDate(Text)
          If newDate < Date then
            'msgbox "Невозможно задать контрольную дату меньше текущей даты"
             txt = txt &  "Невозможно задать контрольную дату меньше текущей даты!" & vbNewLine
            cancel = true
          end if
        end if
      end if  
      if txt>"" then
          msgbox "Невозможно создать поручение: " & vbNewLine & txt, vbCritical, "Невозможно создать поручение!"
      else
        on error resume next
        If ThisApplication.IsActiveTransaction Then ThisApplication.CommitTransaction 
        if err.Number <> 0 then
          err.Clear
        end if
        on error goto 0  
      end if
    end if

  dict.remove("OK")
  end if    
  if not cancel then 
    call RemoveGlobalVarrible("DOCBASE")
    If ThisApplication.IsActiveTransaction Then ThisApplication.AbortTransaction
  end if
End Sub

'==============================================================================
Sub OK_OnClick()
  Set dict = ThisApplication.Dictionary("Packages")
  if dict.Exists("OK") then dict.remove("OK")
  dict.Add "OK", True
End Sub

'==============================================================================
Sub CANCEL_OnClick()
  Set Dict = ThisApplication.Dictionary("Packages")
  if dict.Exists("OK") then dict.remove("OK")
  dict.Add "OK", False
End Sub

'==============================================================================
Sub BTN_ADD_TEMPL_OnClick()
  set fld = GetTmplFolder()
  if fld is nothing then exit sub
  thisScript.SysAdminModeOn
 
  call SetObjectGlobalVarrible("OrderForm", thisForm)
  Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
  CreateObjDlg.Object = fld
  CreateObjDlg.ActiveForm = thisApplication.InputForms("FORM_KD_ORDER_TEMPLS")
  ans = CreateObjDlg.Show

End Sub

'==============================================================================
Sub BTN_DEL_CNT_OnClick()
    Del_User("ATTR_KD_CONTR")
End Sub

'==============================================================================
Sub BTN_ADD_SELF_OnClick()
    Add_self_Control("ATTR_KD_CONTR")
End Sub

'==============================================================================
Sub ATTR_KD_ORDER_RECIPIEND_CellInitEditCtrl(nRow, nCol, pEditCtrl, bCancelEdit)
  if nCol = 0 then
      pEditCtrl.comboitems = thisApplication.Users
  end if

End Sub
'==============================================================================
Sub Form_TableAttributeChange(Form, Object, TableAttribute, TableRow, ColumnAttributeDefName, OldTableRow, Cancel)
  thisScript.SysAdminModeOn
  if ColumnAttributeDefName = "ATTR_KD_OP_DELIVERY" then 
    set user = TableRow.Attributes("ATTR_KD_OP_DELIVERY").User
    call setUserAttr(user, TableRow)
  end if
' msgbox "1"  
End Sub
'==============================================================================
Sub BTN_ADD_USER_OnClick()
    Add_User_Click()
End Sub

'==============================================================================
Sub BTN_ADD_GROUP_OnClick()
    Add_Group_Click()
End Sub

'==============================================================================
Sub BTN_DEL_USER_OnClick()
    set docObj = GetObjectGlobalVarrible("DOCBASE")
    if not docObj is nothing then call RemoveGlobalVarrible("DOCBASE")
    'EV т.к. здесь надо удалить из формы
    call Del_FromTable("ATTR_KD_ORDER_RECIPIEND", 0 )  
    if not docObj is nothing then call SetObjectGlobalVarrible("DOCBASE", docObj)
    
End Sub
'==============================================================================
Sub ATTR_KD_POR_PLANDATE_BeforeModify(Text,Cancel)
'msgbox "1"
  if isDate(Text) then
    newDate = CDate(Text)
    If newDate < Date then
      msgbox "Невозможно задать контрольную дату меньше текущей даты"
      cancel = true
    end if
  end if
End Sub

''==============================================================================
'' не работает
'Sub ATTR_KD_ORDER_RECIPIEND_KeyDown(pnChar, nShiftState)
'  if pnChar = 13 then 
'    set cnt = thisForm.Controls("ATTR_KD_ORDER_RECIPIEND").ActiveX
'    Arr0 = cnt.Selection
'    Arr0(0) = Arr0(0)+1
'    Arr0(2) = Arr0(2)+1
'    cnt.Selection = Arr0
'  end if
'End Sub
''==============================================================================
'Sub ATTR_KD_ORDER_RECIPIEND_CellAfterEdit(nRow, nCol, strLabel, bCancel)
'set cnt = thisForm.Controls("ATTR_KD_ORDER_RECIPIEND").ActiveX
'    Arr0 = cnt.Selection
'    Arr0(0) = Arr0(0)+1
'    Arr0(2) = Arr0(2)+1
'    Arr0(1) = Arr0(1)'-1
'    Arr0(3) = Arr0(3)'-1
'    cnt.Selection = Arr0
'End Sub


''==============================================================================
Sub BTN_KD_ADD_CONTR_OnClick()
    set docObj = GetObjectGlobalVarrible("DOCBASE")
    if docObj is nothing then exit sub
    call AddContr(docObj)
    docObj.update
    SetDocAttrs()
End Sub

''==============================================================================
Sub BTN_KD_DEL_CONTR_OnClick()
    set docObj = GetObjectGlobalVarrible("DOCBASE")
    if docObj is nothing then exit sub
    call DelContr(docObj)
    docObj.update
    SetDocAttrs()
End Sub
''==============================================================================
Sub BTN_KD_ADD_PROJ_OnClick()
    set docObj = GetObjectGlobalVarrible("DOCBASE")
    if docObj is nothing then exit sub
    call AddProj(docObj)
    docObj.update
    SetDocAttrs()
End Sub
''==============================================================================
Sub BTN_DEL_PRO_OnClick()
  set docObj = GetObjectGlobalVarrible("DOCBASE")
  if docObj is nothing then exit sub
  call Del_FromTable("ATTR_KD_TLINKPROJ", "ATTR_KD_LINKPROJ" ) 
  docObj.SaveChanges 16384
  SetDocAttrs()
End Sub
'==============================================================================
Sub BTN_ADD_DOC_OnClick()
    set docObj = GetObjectGlobalVarrible("DOCBASE")
    if docObj is nothing then exit sub
    call  AskToAddRelDocObj(docObj,false)
    docObj.Update
End Sub
'==============================================================================
Sub BTN_DEL_DOC_OnClick()
    set docObj = GetObjectGlobalVarrible("DOCBASE")
    if docObj is nothing then exit sub
    call  Del_FromTableWithPermObj("ATTR_KD_T_LINKS", "ATTR_KD_LINKS_DOC", "ATTR_KD_LINKS_USER", docObj) 

End Sub
'==============================================================================
Sub BTN_ADD_FILE_OnClick()
  set docObj = GetObjectGlobalVarrible("DOCBASE")
  if docObj is nothing then exit sub

  call AddObjLinkFile(docObj)
end sub

'==============================================================================
Sub ATTR_KD_WITHOUT_PROJ_Modified()
  set docObj = GetObjectGlobalVarrible("DOCBASE")
  if docObj is nothing then exit sub
  docObj.Permissions = SysAdminPermissions
  if thisForm.Attributes("ATTR_KD_WITHOUT_PROJ").Value then 
    if DelContr(docObj) then
       docObj.Attributes("ATTR_KD_WITHOUT_PROJ") = true 
    else
      thisForm.Attributes("ATTR_KD_WITHOUT_PROJ").Value = true 
      docObj.Attributes("ATTR_KD_WITHOUT_PROJ") = false 
    end if
  else 
      docObj.Attributes("ATTR_KD_WITHOUT_PROJ") = false 
  end if
  docObj.Update
  SetDocAttrs()
  thisform.Refresh
End Sub

'==============================================================================
Sub ATTR_KD_TEXT_BeforeAutoComplete(Text)
  Call OnAttrWithTemplatesBeforeAutoComplete("ATTR_KD_TEXT", Text)
End Sub
'==============================================================================
Sub ATTR_KD_TEXT_Modified()
  Call OnAttrWithTemplatesModified("ATTR_KD_TEXT")
End Sub
