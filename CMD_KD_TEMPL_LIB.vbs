use CMD_KD_COMMON_LIB


'==============================================================================
sub Add_User_Click()
Set Q = ThisApplication.Queries("QUERY_USER_LIST")
    Set Objs = Q.Sheet 'Users
    set selObj = thisApplication.Dialogs.SelectDlg '.SelectObjectDlg
    selObj.Prompt = "Выберите пользователей"
    SelObj.SelectFrom = Objs
    RetVal = selObj.Show 
    If (RetVal<>TRUE) Then Exit Sub
    Set projObjs = selObj.Objects
    If (projObjs.users.count = 0) Then Exit Sub
    for each user in projObjs.users
       call Add_User(user, false,thisForm)
    next
end sub
'==============================================================================
function Add_User(user, siln, frm)
   set rows = frm.Attributes("ATTR_KD_ORDER_RECIPIEND").Rows
   if not user is nothing then 
      if thisApplication.Groups.Has(user.SysName) then 
        if IsExistsGroupItemCol(rows, user, "ATTR_KD_OP_DELIVERY") then 
          if not siln then msgbox "Невозможно добавить группу " & User.Description & ", т.к. она уже есть в списке", VbCritical
          exit function
        end if
      else
        if IsExistsUserItemCol(rows, user, "ATTR_KD_OP_DELIVERY") then 
           if not siln then msgbox "Невозможно добавить пользователя " & User.Description & ", т.к. он уже есть в списке", VbCritical
          exit function
        end if
      end if
     'set rows = frm.Attributes("ATTR_KD_ORDER_RECIPIEND").Rows
     set newRow = rows.Create
     if thisApplication.Groups.Has(user.SysName) then 
         newRow.Attributes("ATTR_KD_OP_DELIVERY").group = user
     else
         newRow.Attributes("ATTR_KD_OP_DELIVERY").value = user
     end if
     call setUserAttr(user, newRow)
'     call Form_TableAttributeChange(Form, Obj, thisForm.Attributes("ATTR_KD_ORDER_RECIPIEND"), _
'         newRow, "ATTR_KD_OP_DELIVERY", nothing, nothing)
     frm.Refresh
   end if
end function

'==============================================================================
function setUserAttr(user, TableRow)
    if not user is nothing then 
      if thisApplication.Groups.Has(user.SysName) then 
          set user = nothing
      else
        if user.PositionClassifier is nothing then 
          TableRow.Attributes("ATTR_KD_USER_RANK").value =  ""
        else 
          TableRow.Attributes("ATTR_KD_USER_RANK").value = user.PositionClassifier 
        end if  
        set dept = user.Attributes("ATTR_KD_USER_DEPT").object
        if not dept is nothing  then _
            TableRow.Attributes("ATTR_KD_USER_DEPT").value = dept
        set dept = user.Attributes("ATTR_KD_DEPART").object
        if not dept is nothing then  _
            TableRow.Attributes("ATTR_KD_DEPART").value = dept
      end if    
    end if  
    if user is nothing then 
      TableRow.Attributes("ATTR_KD_USER_RANK").value = ""
      TableRow.Attributes("ATTR_KD_USER_DEPT").value = ""
      TableRow.Attributes("ATTR_KD_DEPART").value = ""
    end if
end function
'==============================================================================
sub addReg(obj,siln)
   set rows = thisForm.Attributes("ATTR_KD_T_REGIONS").Rows
   if obj is nothing then exit sub
   if IsExistsObjItemCol(rows, obj, "ATTR_KD_DEPART") then 
      if not siln then 
        msgbox "Невозможно добавить площадку " & obj.Description & ", т.к. она уже есть в списке", VbCritical
      end if
      exit sub
    end if
    set newRow = rows.Create
    newRow.Attributes("ATTR_KD_DEPART").value = obj
    if not isEmpty(thisform) then thisForm.Refresh
end sub
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
    if user is nothing then 
      TableRow.Erase 
      exit sub
    end if
    if IsExistsUserItemColWithoutRow(TableAttribute.Rows, user, "ATTR_KD_OP_DELIVERY", TableRow) then 
      msgbox "Невозможно добавить пользователя " & User.Description & ", т.к. он уже есть в списке", VbCritical  
      cancel = true
      exit sub
    end if

    call setUserAttr(user, TableRow)
  end if
  if ColumnAttributeDefName = "ATTR_KD_DEPART" then 
    set dept = TableRow.Attributes("ATTR_KD_DEPART").object
    if dept is nothing then 
      TableRow.Erase 
      exit sub
    end if
    if IsExistsObjItemColWithoutRow(TableAttribute.Rows, dept , "ATTR_KD_DEPART",TableRow ) then 
      msgbox "Невозможно добавить площадку " & dept.Description & ", т.к. она уже есть в списке", VbCritical  
      cancel = true
      exit sub
    end if
  end if
  if ColumnAttributeDefName = "ATTR_KD_DOC_TYPE" then 
    dt = TableRow.Attributes("ATTR_KD_DOC_TYPE").value 
    if dt = "" then 
      TableRow.Erase 
      exit sub
    end if
    if IsExistsValItemColWithoutRow(TableAttribute.Rows, dt , "ATTR_KD_DOC_TYPE",TableRow ) then 
      msgbox "Невозможно добавить тип документа " & dt & ", т.к. он уже есть в списке", VbCritical  
      cancel = true
      exit sub
    end if
  end if
  
end sub

'==============================================================================
function GetTmplFolder()
  set GetTmplFolder = nothing
  set qry = thisApplication.Queries("QUERY_GET_TEMPLS_FOLDER")
  set objs = qry.Objects
  if objs.Count = 0 then 
    msgbox "Не найдена папка для шаблонов", vbCritical, "Ошибка"
    exit function
  end if
  set GetTmplFolder = objs(0)
end function
'==============================================================================
sub add_Tmpl_inForm(tmpl, frm)
    set rows = tmpl.Attributes("ATTR_KD_ORDER_RECIPIEND").Rows
    for each row in rows
      set user = row.Attributes("ATTR_KD_OP_DELIVERY").user
      if not user is nothing then 
        call Add_User(user, true,frm)
      else   
        set gr = row.Attributes("ATTR_KD_OP_DELIVERY").group
        if not gr is nothing then _
          call  Add_Group(gr,frm)
      end if
    next
end sub
''==============================================================================
'sub add_Agree_Tmpl_inForm(tmpl, frm)
'    set rows = tmpl.Attributes("ATTR_KD_TAPRV").Rows
'    set frows = frm.Attributes("ATTR_KD_TAPRV").Rows
'    if frm.Controls.Has("ATTR_KD_PERS_TEMPL") then 
'      curBL = cInt(frm.Controls("TDMSEDIT_BLOCK").Value)
'      for each row in rows
'        set user = row.Attributes("ATTR_KD_APRV").user
'        
'      next
'    else
'      call add_Agree_Tmpl_toDoc(tmpl, frm)
'    end if  
''    frm.Refresh
'end sub
'==============================================================================
sub add_Agree_Tmpl_toDoc(tmpl, frm)
  set qry = thisForm.Controls("QUERY_KD_TEMPL_AGRE_PERS")
  curBL = cInt(frm.Controls("TDMSEDIT_BLOCK").Value)
  set rows = tmpl.Attributes("ATTR_KD_TAPRV").Rows
  if frm.Attributes.has("ATTR_KD_TAPRV") then set frows = frm.Attributes("ATTR_KD_TAPRV").Rows  
  
  set agreeObj = nothing
  set docObj = GetObjectGlobalVarrible("DocObj")
  if not docObj is nothing then 
    ThisScript.SysAdminModeOn
    set agreeObj =  thisApplication.ExecuteScript("FORM_KD_AGREE", "GetAgreeObjByObj",docObj)
    if agreeObj is nothing then exit sub
    agreeObj.Attributes("ATTR_KD_FIRST_REJECT").Value = tmpl.Attributes("ATTR_KD_FIRST_REJECT").Value
    agreeObj.update
  end if
   
  for i = 0 to qry.Value.RowsCount - 1
    set row = qry.value.rowValue(i)
    set user = row.Attributes("ATTR_KD_APRV").user
    nBl = cInt(row.Attributes("ATTR_KD_APRV_NO_BLOCK").value) + curBL - 1
    if checkUserToAdd(docObj, user, agreeObj,frows) then 
      if not docObj is nothing then ' добавляем в документ 
         call thisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB","createAppRow",agreeObj,nBl,"", User)
      else 'добавляем в шаблон
           set newRow = frows.Create
           newRow.Attributes("ATTR_KD_APRV").value = user
           newRow.Attributes("ATTR_KD_APRV_NO_BLOCK").value = nBl
      end if
    else
       rowCount = thisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB","GetCountInBlock",rows, 0,_
                 row.Attributes("ATTR_KD_APRV_NO_BLOCK").value) ' если один человек в блоке, то уменьшаем блок
       if rowCount = 1 then curBL = curBL - 1
    end if  
  next
end sub
'==============================================================================
function checkUserToAdd(docObj, user, agreeObj,frows)
  checkUserToAdd = false
    if not docObj is nothing then ' добавляем в документ 
      checkUserToAdd =  thisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB","CheckAprUser",user,true,agreeObj,docObj) 
   else 'добавляем в шаблон
      if not user is nothing then _
         checkUserToAdd = not IsExistsUserItemCol(frows, user, "ATTR_KD_APRV") 
   end if 
end function
'==============================================================================
sub Add_Group_Click()
    set selObj = thisApplication.Dialogs.SelectDlg '.SelectObjectDlg
    selObj.Prompt = "Выберите группы пользователей"
    SelObj.SelectFrom = thisApplication.Groups
    RetVal = selObj.Show 
    Set objs = selObj.Objects
    If (RetVal<>TRUE) Or (objs.count = 0) Then Exit Sub
    for each gr in objs
        call Add_Group(gr, thisForm )
    next
end sub
'==============================================================================
sub Add_Group(group, frm)
  if group.Users.Count > 10 then
    ans =  msgbox("В группу " & group.Description & " входит " & Cstr(group.Users.Count) & " человек."  _
      & vbNewLine & "Создание поручении  займет некоторое время." _
      & vbNewLine & " Вы уверены, что хотите добавить всех пользователей?", vbQuestion + VbYesNo, "Добавить всех пользователей?")
    if ans <> vbYes then exit sub 
  end if
  for each user in group.Users  
    call Add_User(user, true, frm)  
  next 
end sub
'=================================
function checkTmplName(newName, tempType)
  checkTmplName = false
  set qry = thisApplication.Queries("QUERY_CHECK_TEMPL_NAME")
  qry.Parameter("PARAM0") = thisObject.Handle
  qry.Parameter("PARAM1") = newName
  qry.Parameter("PARAM2") = tempType
  
  set objs = qry.Objects
  if objs.Count = 0 then  
    checkTmplName = true
    exit function
  end if
end function

'=================================
function checkTeml(obj)
  checkTeml = ""
  if obj.Attributes("ATTR_NAME").Value = "" then 
    checkTeml = checkTeml & "Не задано название шаблона" & vbNewLine
  else
     if not checkTmplName(obj.Attributes("ATTR_NAME").Value, thisObject.ObjectDefName) then _
         checkTeml = checkTeml & "Невозможно задать название шаблона, т.к. такое название присвоено другому шаблону" & vbNewLine
  end if  
  if obj.Attributes("ATTR_KD_T_REGIONS").Rows.count = 0 then _
    checkTeml = checkTeml & "Не задано ни одно прощадки" & vbNewLine
  if obj.ObjectDefName = "OBJECT_KD_AGREE_TEMPLATE" then 
    if obj.Attributes("ATTR_KD_TAPRV").Rows.count = 0 then _
      checkTeml = checkTeml & "Не задано ни одного согласующего" & vbNewLine
    if obj.Attributes("ATTR_KD_T_DOC_TYPE").Rows.count = 0 then _
      checkTeml = checkTeml & "Не задано ни одного типа документа" & vbNewLine
  else  
    if obj.Attributes("ATTR_KD_ORDER_RECIPIEND").Rows.count = 0 then _
      checkTeml = checkTeml & "Не задано ни одного получателя" & vbNewLine
  end if  
end function

'=============================================
function fCanDel(templ)
  fCanDel = false
  if thisApplication.CurrentUser.Groups.Has("GROUP_TEMPL_EDIT") then 
    fCanDel = true
  else
    if templ.Roles.Has("ROLE_DEVELOPER") then
      for each role in templ.Roles'("ROLE_DEVELOPER")
        if role.RoleDefName = "ROLE_DEVELOPER" then 
          if not Role.User is nothing then 
            if Role.User.SysName = thisApplication.CurrentUser.SysName then
               fCanDel = true
               exit for  
            end if
          end if  
        end if
      next
    end if
  end if  
end function  
'=============================================
function CreateTemplate(tmplType)
  set CreateTemplate = nothing
  set fld = GetTmplFolder()
  if fld is nothing then exit function
  thisScript.SysAdminModeOn
  fld.Permissions = sysAdminPermissions
  on error resume next
  set CreateTemplate = fld.Objects.Create("OBJECT_KD_AGREE_TEMPLATE")
  if err.Description <>"" then 
    msgbox err.Description, vbCritical, "Ошибка создания шаблона"
  end if
  on error goto 0
end function
