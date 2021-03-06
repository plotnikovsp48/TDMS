
'=============================================
Sub BTN_ADD_COR_OnClick()

  frmName = thisForm.SysName
  call thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","RemoveGlobalVarrible", "ShowForm")
  set cordent =  thisApplication.ExecuteScript("FORM_KD_CORDENTS","CreateOrg")
  call thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","SetGlobalVarrible", "ShowForm",frmName)
'  if not cordent is nothing then 
'    SetAutoComp()
'    'SetPersAutoComp()
'    ThisForm.Attributes("ATTR_KD_CPNAME") = cordent
'    call ATTR_KD_CPNAME_Modified()
'  end if
End Sub
'=============================================

Sub BTN_ADD_PERS_OnClick()
  frmName = thisForm.SysName
  call thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","RemoveGlobalVarrible", "ShowForm")

  set pers =  thisApplication.ExecuteScript("FORM_KD_CORDENTS","CreatePerson")  
  
  call thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","SetGlobalVarrible", "ShowForm",frmName)

'  if not pers is nothing then
'     ThisForm.Attributes("ATTR_KD_CPNAME") = ""
'     ThisForm.Attributes("ATTR_KD_CPADRS") = pers
'     call ATTR_KD_CPADRS_Modified()
'  end if
End Sub

'=============================================
Sub ATTR_KD_TCP_CellInitEditCtrl(nRow, nCol, pEditCtrl, bCancelEdit)
  if nCol = 0  then 
    pEditCtrl.comboitems = SetAutoComp
  elseif nCol = 1 then
     set rows = thisObject.Attributes("ATTR_KD_TCP").Rows
     set cord = nothing
     if nRow < Rows.Count then 
       set cord = rows(nRow).Attributes(0).Object
     end if
     pEditCtrl.comboitems = SetPersAutoComp(cord, true)
'    set contr = thisObject.Attributes("ATTR_KD_CPNAME").Object
'    if not contr is nothing then exit sub ' если контрагент задан, что не меняем
'   
'    set user = thisObject.Attributes("ATTR_KD_CPADRS").Object
'    if user is nothing then exit sub
'    set userContr = user.Attributes("ATTR_COR_USER_CORDENT").object
'    if userContr is nothing then exit sub
'    thisObject.Attributes("ATTR_KD_CPNAME").object = userContr
'    SetPersAutoComp()
'    thisForm.Refresh
  end if  
  thisForm.Refresh

End Sub
'=============================================
function SetAutoComp()
  set SetAutoComp =  nothing 
  if  not IsExistsGlobalVarrible("CompAuto") then 
    Set query = ThisApplication.Queries("QUERY_KD_CORDENT")
    set res = query.Objects
    call SetObjectGlobalVarrible("CompAuto", res)
  end if 
  set SetAutoComp = GetObjectGlobalVarrible("CompAuto")
end function
'=============================================
function SetPersAutoComp(cordent, reRead)
  set SetPersAutoComp = nothing
  if  not IsExistsGlobalVarrible("PersAuto") or  reRead then 
    set result = thisApplication.ExecuteScript("CMD_KD_OUT_LIB", "GetPersQuery", cordent)
    call SetObjectGlobalVarrible("PersAuto", result)
  end if
  set SetPersAutoComp = GetObjectGlobalVarrible("PersAuto")
end function

'=============================================
Sub ATTR_KD_TCP_CellEditButtonClick(nRow, nCol, bCancel)
  if nCol = 0 or nCol=1 then bCancel = true  
End Sub
'=============================================
Sub Form_TableAttributeChange(Form, Object, TableAttribute, TableRow, ColumnAttributeDefName, OldTableRow, Cancel)
  if ColumnAttributeDefName = "ATTR_KD_CPNAME" then 
    set contr =  TableRow.Attributes(ColumnAttributeDefName).Object
    set users = SetPersAutoComp(contr, true)
'    Set ctrl = thisForm.Controls("ATTR_KD_CPADRS").ActiveX
    if contr is nothing then 
        'thisForm.Attributes("ATTR_KD_CPADRS").Value = ""
        TableRow.Attributes("ATTR_KD_CPADRS").Value = ""
    else
      if users.Count = 1 then 
        if  CheckCordent(thisObject, users(0), TableRow) then _
            TableRow.Attributes("ATTR_KD_CPADRS").Value = users(0)
      elseif users.Count = 0 then 
        msgbox "Невозможно добавить контрагента " & contr.Description & _
          " в текущий протокол " & thisObject.Description & ", т.к. для него не задано ни одно контактное лицо", vbExclamation
        TableRow.Attributes("ATTR_KD_CPNAME").Value = ""
        TableRow.Attributes("ATTR_KD_CPADRS").Value = ""
        cancel = true  
        form.Refresh
      else
        TableRow.Attributes("ATTR_KD_CPADRS").Value = ""
      end if
    end if
  end if
  if ColumnAttributeDefName = "ATTR_KD_CPADRS" then 
    set user =  TableRow.Attributes(ColumnAttributeDefName).Object
    if  not user is nothing then 
      if not CheckCordent(thisObject, user,TableRow) then
        TableRow.Attributes("ATTR_KD_CPNAME").Value = ""
        TableRow.Attributes("ATTR_KD_CPADRS").Value = ""
        Cancel = true
      else
        if TableRow.Attributes("ATTR_KD_CPNAME").Value = ""  then 
          set contr = user.Attributes("ATTR_COR_USER_CORDENT").object
          if not contr is nothing then  _
              TableRow.Attributes("ATTR_KD_CPNAME").Value  = contr
        end if
      end if
    end if
  end if
End Sub

'=============================================
function CheckCordent(DocObj, cordent,TableRow)
  CheckCordent = false 
    if cordent is nothing then exit function
    
    Set ReplyRows = DocObj.Attributes("ATTR_KD_TCP").Rows

    'Проверка нет ли добавляемого получателя в списке
    if not  IsExistsObjItemColWithoutRow(ReplyRows,cordent, "ATTR_KD_CPADRS",TableRow)then  
      CheckCordent = true
    else
'      msgBox "Полуатель " & CorDent.Description & " уже есть в списке. Добавление не будет произведено.", _
'              vbInformation,"Получатель не добавлен!"
    end if   

end function
'=============================================
sub SetChBox()
  set chk = thisForm.Controls("TDMSED_IMP").ActiveX
  chk.buttontype = 4
  Chk.value = thisObject.Attributes("ATTR_KD_IMPORTANT").Value

  set chk = thisForm.Controls("TDMSED_URG").ActiveX
  chk.buttontype = 4
  Chk.value = thisObject.Attributes("ATTR_KD_URGENTLY").Value
end sub

'=============================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  if Attribute.AttributeDef.SysName = "ATTR_KD_EXEC" then 
    if attribute.Value <> "" then 
      'отдел
      set dept = Get_Dept(Attribute.User)
      if dept is nothing then 
          msgbox "Для " & Attribute.User.Description & " не задан отдел. ", VbCritical, "Не возможно создать документ!"
          Cancel = true
          exit sub
      end if
      if thisObject.Attributes("ATTR_KD_DEPART").Value <> dept.Description then 
        thisObject.Attributes("ATTR_KD_DEPART").Value = dept
        thisForm.Attributes("ATTR_KD_DOC_PREFIX").Value = Get_Prifix(thisObject) 
        thisForm.Refresh
      end if 
    end if
  end if
  if Attribute.AttributeDef.SysName = "ATTR_KD_VD_INСNUM" then 
    if attribute.Value <>"" then  
      thisObject.Attributes("ATTR_KD_SUFFIX").Value = "(вх. " & attribute.Value & ")"
    else
      thisObject.Attributes("ATTR_KD_SUFFIX").Value = ""
    end if
  end if 
  if Attribute.AttributeDef.SysName = "ATTR_KD_PROT_TYPE" then 
    SetInNumEnabled(attribute)
  end if 
  
End Sub


'=============================================
sub SetInNumEnabled(attribute)
if attribute.Value <>"" then  
      if Attribute.Classifier.SysName = "NODE_KD_PROT_OUT" then 
        thisForm.Controls("ATTR_KD_VD_INСNUM").Enabled = true
        thisForm.Controls("ATTR_KD_TCP").ReadOnly = false 
        thisForm.Controls("BTN_PADD").Enabled = true
        thisForm.Controls("BTN_PDELL").Enabled = true
        thisForm.Controls("BTN_ADD_COR").Enabled = true
        thisForm.Controls("BTN_ADD_PERS").Enabled = true
      else
        thisForm.Controls("ATTR_KD_VD_INСNUM").Enabled = false
        if thisObject.Attributes("ATTR_KD_VD_INСNUM").Value <> "" then _
            thisObject.Attributes("ATTR_KD_VD_INСNUM").Value = ""
        thisForm.Controls("ATTR_KD_TCP").ReadOnly = true 
        thisForm.Controls("BTN_PADD").Enabled = false
        thisForm.Controls("BTN_PDELL").Enabled = false
        thisForm.Controls("BTN_ADD_COR").Enabled = false
        thisForm.Controls("BTN_ADD_PERS").Enabled = false
      end if
    end if
end sub
