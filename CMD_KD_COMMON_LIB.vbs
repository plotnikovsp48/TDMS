use CMD_CORR_CHECK_EMAIL_CLASS
use CMD_KD_FOLDER
'use CMD_KD_USER_PERMISSIONS
use CMD_KD_GLOBAL_VAR_LIB 
'use CMD_KD_CURUSER_LIB
'=============================================
'EV добавляем в начала поля указанный текс с указание кто и когда добавил
sub AddCommentTxt(obj, AttrName, newText)
 obj.Permissions = SysAdminPermissions
 if not obj.Attributes.Has(AttrName) then exit sub

 str =  newText & Chr(13) & Chr(10)& _
      "   " & thisApplication.CurrentUser.Description & " - " & cStr(Now) & Chr(13) & Chr(10)& Chr(13) & Chr(10)        
 obj.Attributes(AttrName).value =  str & obj.Attributes(AttrName).value 

end sub

'=============================================
'EV добавляем в начала поля указанный текс с указание кто и когда добавил
sub AddComment(obj, AttrName, newText)

' EV TODO добавить проверку на блокировку и поставить блокировку
' подумать когда лучше ее ставить, после ввода текста или до
' может копировать текст в память?

 obj.Permissions = SysAdminPermissions
 if not obj.Attributes.Has(AttrName) or not obj.Attributes.Has(AttrName & "_T") then exit sub
 
 set rows = obj.Attributes(AttrName & "_T").Rows
 if rows is nothing then exit sub
 
 Set NewRow = rows.Create 
         
 NewRow.Attributes("ATTR_KD_LINKS_USER").Value = thisApplication.CurrentUser
 NewRow.Attributes("ATTR_KD_ISSUEDATE").Value = Now
 NewRow.Attributes("ATTR_KD_TEXT").Value = newText

 rows.Update
 obj.Attributes(AttrName).value = GetCommemt(Rows)

end sub

'=============================================
function GetCommemt(Rows)
  GetCommemt = ""
  for each row in Rows
    GetCommemt = Row.Attributes("ATTR_KD_TEXT").Value & Chr(13) & Chr(10)& Row.Attributes("ATTR_KD_LINKS_USER").Value _
      & " - " & Row.Attributes("ATTR_KD_ISSUEDATE").Value & Chr(13) & Chr(10)& Chr(13) & Chr(10) & GetCommemt 
  next
end function
'=============================================
function ShowComment(Caption, txt)
  ShowComment = ""
  Set frmSetShelve = ThisApplication.InputForms("FORM_COMMENT")
  frmSetShelve.Controls("STATIC1").Value = Caption'"Введите комментарий к согласованию"
  frmSetShelve.Controls("ATTR_KD_TEXT").ReadOnly =  true
  frmSetShelve.Attributes("ATTR_KD_TEXT").Value = txt
  If frmSetShelve.Show  then 
'    GetComment = trim(frmSetShelve.Attributes("ATTR_KD_TEXT").Value)
'  else
'    GetComment = Empty 
  end if
end function
'==============================================================================
function GetComment(Caption)
  GetComment = ""
  Set frmSetShelve = ThisApplication.InputForms("FORM_COMMENT")
  frmSetShelve.Controls("STATIC1").Value = Caption'"Введите комментарий к согласованию"
  If frmSetShelve.Show  then 
    GetComment = trim(frmSetShelve.Attributes("ATTR_KD_TEXT").Value)
  else
    GetComment = Empty 
  end if
end function
'==============================================================================
function GetEditComment(Caption,txt)
  GetEditComment = ""
  Set frmSetShelve = ThisApplication.InputForms("FORM_COMMENT")
  frmSetShelve.Controls("STATIC1").Value = Caption'"Введите комментарий к согласованию"
  frmSetShelve.Attributes("ATTR_KD_TEXT").Value = txt
  If frmSetShelve.Show  then 
    GetEditComment = trim(frmSetShelve.Attributes("ATTR_KD_TEXT").Value)
  else
    GetEditComment = Empty 
  end if
end function
'=============================================
'EV редактируем последнее примечание пользователя
sub EidtComment(AttrName)
    ThisScript.SysAdminModeOn
    set obj = thisObject
    if not obj.Attributes.Has(AttrName) and not obj.Attributes.Has(AttrName & "_T") then exit sub
    set rows = obj.Attributes(AttrName & "_T").Rows
    set row = GetUserComment (rows)
    if row is nothing then 
      msgbox "Ваш комментарий не найден"
      exit sub
    end if
    Set frmSetShelve = ThisApplication.InputForms("FORM_COMMENT")
    frmSetShelve.Attributes("ATTR_KD_TEXT").Value =  Row.Attributes("ATTR_KD_TEXT").Value
    If frmSetShelve.Show  then 
      txt = trim(frmSetShelve.Attributes("ATTR_KD_TEXT").Value)
      if txt <> "" Then 
        Row.Attributes("ATTR_KD_TEXT").Value = txt
        obj.Attributes(AttrName).value = GetCommemt(Rows)
        obj.Update
      end if  
    end if  

'    Set reasonDlg = ThisApplication.Dialogs.SimpleEditDlg
'    reasonDlg.Caption = "Введите комментарий"
'    reasonDlg.Prompt = "Комментарий"
'    reasonDlg.Text = Row.Attributes("ATTR_KD_TEXT").Value
'    If reasonDlg.Show AND reasonDlg.Text <> "" Then 
'        Row.Attributes("ATTR_KD_TEXT").Value = reasonDlg.Text
'        obj.Attributes(AttrName).value = GetCommemt(Rows)
'        obj.Update
'    end if  

end sub

'=============================================
function GetUserComment (rows)

  set GetUserComment = nothing
  
  rCount = rows.count
  if rCount < 1 then exit function
  for i = rCount-1 to 0 step -1
      if Rows(i).Attributes("ATTR_KD_LINKS_USER").Value =  thisApplication.CurrentUser.Description then 
          set GetUserComment = Rows(i)
          exit function
      end if
  next
  
  
end function

'=============================================
' EV к текущему объекту добавить комментарий
sub AskAddComment(AttrName)
    ThisScript.SysAdminModeOn
    ' EV TODO добавить проверку на блокировку 
    'frmSetShelve.Controls("ATTR_KD_TEXT").Value = ""
'    Set reasonDlg = ThisApplication.Dialogs.SimpleEditDlg
'    reasonDlg.Caption = "Введите комментарий"
'    reasonDlg.Prompt = "Комментарий"
'    If reasonDlg.Show AND reasonDlg.Text <> "" Then 
    Set frmSetShelve = ThisApplication.InputForms("FORM_COMMENT")
    If frmSetShelve.Show  then 
      txt = trim(frmSetShelve.Attributes("ATTR_KD_TEXT").Value)
      if txt <> "" Then 
        call AddComment(thisObject,AttrName,txt)
        thisObject.Update
      end if  
    end if  
end sub


'=============================================
sub ShowUsers()
  for each control in thisForm.Controls
    txt = "TXT_" & control.Name
    if thisForm.Controls.Has(txt) then ShowUser(control.Name)
  next
end sub

'=============================================
sub ShowUser(attrName)
    set obj = nothing 
'  call ShowUserObj(thisObject,attrName)
  if IsEmpty(thisObject) then 
      set obj = thisForm
  elseif thisObject is nothing then 
      set obj = thisForm
  else  
      set obj = thisObject   
  end if
  if obj is nothing then   exit sub
  
  if obj.Attributes(attrName).Value = "" then 
      txt = ""
  else
      set user = obj.Attributes(attrName).User
      txt = user.Description & " - " & user.Position 'user.Attributes("ATTR_USER_POSITION").value
      'user.Attributes("ATTR_USER_FIO").value & " " & user.Attributes("ATTR_USER_POSITION").value
  end if
  
  if thisForm.Controls.Has("TXT_"&attrName) then 
      thisForm.Controls("TXT_"&attrName).Value = txt
      thisForm.Controls("TXT_"&attrName).ActiveX.BackColor = RGB(240,240,240) 
  end if    

end sub

'=============================================
sub RemoveForm(varName,FromName,Dialog,Forms)
  If ThisApplication.Dictionary.Exists(varName) Then
       Dialog.SystemFormVisibility (tdmSysFormFiles) = False
       Dialog.SystemFormVisibility (tdmSysFormPreview) = False
       Dialog.SystemFormVisibility (tdmSysFormSystem) = False
       Dialog.SystemFormVisibility (tdmSysFormSigns) = False
       Dialog.SystemFormVisibility (tdmSysFormSummaryPermissions) = False
       Dialog.SystemFormVisibility (tdmSysFormRoles) = False
       Dialog.SystemFormVisibility (tdmSysFormContent) = False
       Dialog.SystemFormVisibility (tdmSysFormPartOf) = False
       Dialog.SystemFormVisibility (tdmSysFormVersions) = False
       Dialog.SystemFormVisibility (tdmSysFormHistory) = False
       Dialog.SystemFormVisibility (tdmSysFormMessages) = False
       Dialog.SystemFormVisibility (tdmSysFormReferencedBy) = False
       'ThisApplication.AddNotify "after del Object_PropertiesDlgInit " & CStr(Timer())
       For each Form in Forms
           If Form.SysName <> FromName Then Forms.Remove Form    
       Next 
  End if   
end sub
'=============================================
'EV может ли пользователь редактировать форму
function IsCanEdit()
  'TODO еще добавить проверку на блокировку
   IsCanEdit = IsCanEditObj(thisObject)
end function   
'=============================================
'EV может ли пользователь редактировать форму
function IsCanEditObj(obj)
  'TODO еще добавить проверку на блокировку
   IsCanEditObj = false
  
     select case obj.Permissions.Edit
      case 1:IsCanEditObj = true
      case 2:IsCanEditObj = false
     end select      
' зачем через все роли, когда можно через права на объект?
'   for each role in obj.RolesForUser(thisApplication.CurrentUser)
'     'thisApplication.DebugPrint role.RoleDef.Permissions.Edit
'     select case role.RoleDef.Permissions.Edit
'      case 1:IsCanEditObj = true
'          'exit function 'EV т.к. может быть запрещено
'      case 2:IsCanEditObj = false
'          exit function 
'     end select      
'   next 
   
'   if not isObject(thisForm) then 
'      IsCanEdit = false
'      exit function 
'      
'   end if
'   if not thisForm is nothing then
'      if thisForm.Controls.Has("ATTR_KD_TOPIC") then 
'        if not thisForm.Controls("ATTR_KD_TOPIC").ReadOnly then exit function 
'      end if
'   end if
'   IsCanEdit = false
end function

'=============================================
sub AddProj(obj)
    Set Q = ThisApplication.Queries("QUERY_KD_PROJ_CHOICE")
    set contr = obj.Attributes("ATTR_KD_AGREENUM").object
    if contr is nothing then
        Q.Parameter("PARAM0") = "<> UNDEFINED OR = NULL"
    else
        Q.Parameter("PARAM0") = "=" & contr.handle
    end if
    
'    Set Objs = Q.Objects
    set sh = Q.Sheet
    if sh.RowsCount = 0 then 
        msgbox "Не существует походящих  проектов",vbExclamation
        exit sub
    end if
'    set selObj = thisApplication.Dialogs.SelectObjectDlg
'    SelObj.SelectFromObjects = Objs
    set selObj = thisApplication.Dialogs.SelectDlg
    SelObj.SelectFrom = sh

    selObj.Prompt = "Выберите проект"
    RetVal = selObj.Show 
    If (RetVal<>TRUE) Then Exit Sub  
    Set projObjs = selObj.Objects.Objects
'    If (RetVal<>TRUE) Or (projObjs.Count=0) Then Exit Sub
    for each proj in projObjs
      call AddNewProj(obj, proj)
    next
    if Obj.Attributes("ATTR_KD_WITHOUT_PROJ").value then Obj.Attributes("ATTR_KD_WITHOUT_PROJ").value = false
    'EV TODO добавить блокировок и прав
    if not IsCanEditObj(obj) then 
        obj.Update
    end if
end sub

'=============================================
sub AddNewProj(obj, proj)
  call AddNewProjSilent(obj, proj,false) 
end sub

'=============================================
sub AddNewProjSilent(obj, proj,silent)
  thisScript.SysAdminModeOn
  obj.permissions = SysadminPermissions
  if proj is nothing then exit sub
  if proj.ObjectDefName <> "OBJECT_PROJECT" then exit sub
  
  set rows = obj.Attributes("ATTR_KD_TLINKPROJ").Rows
  if IsExistsObjItemCol(rows,proj,0) then 
    if not silent then _
      msgbox "Невозможно добавить проект" & proj.Description & ", т.к. связь с ним уже существует"
    exit sub
  end if
  Set NewRow = rows.Create 
         
  NewRow.Attributes("ATTR_KD_LINKPROJ").Value = proj
  if proj.Attributes("ATTR_PROJECT_GIP").value > "" then _
        NewRow.Attributes("ATTR_KD_GIP").Value = proj.Attributes("ATTR_PROJECT_GIP").User
  rows.Update
  set prContr = proj.Attributes("ATTR_CONTRACT").object
  if not prContr is nothing then 
    set contr = obj.Attributes("ATTR_KD_AGREENUM").object
    if contr is nothing then _
      obj.Attributes("ATTR_KD_AGREENUM").value = prContr
  end if  
end sub

'=============================================
function IsExistsObjItemCol(rows,obj, ColNo)
  IsExistsObjItemCol = false
  for i = 0 to rows.Count - 1
    if not Rows(i).Attributes(ColNo).Object is nothing then 
      if Rows(i).Attributes(ColNo).Object.Handle = obj.Handle then  
        IsExistsObjItemCol = true
        exit function
      end if  
    end if
  next

end function

'=============================================
function IsExistsObjItemColWithoutRow(rows, obj, ColNo,row)
  IsExistsObjItemColWithoutRow = false
  if obj is nothing then exit function
  
  for i = 0 to rows.Count - 1
    if Rows(i).handle <> row.Handle then 
      if not Rows(i).Attributes(ColNo).Object is nothing then 
        if Rows(i).Attributes(ColNo).Object.Handle = obj.Handle then  
          IsExistsObjItemColWithoutRow = true
          exit function
        end if  
      end if
    end if
  next
end function
'=============================================
function IsExistsValItemColWithoutRow(rows, val, ColNo, row)
  IsExistsValItemColWithoutRow = false
  if row is nothing then 
    hdl = 0
  else 
    hdl = row.Handle
  end if
  for i = 0 to rows.Count - 1
    if Rows(i).handle <> hdl then 
        if Rows(i).Attributes(ColNo).value  = val then  
          IsExistsValItemColWithoutRow = true
          exit function
        end if  
    end if
  next
end function

'=============================================
function IsExistsUserItemCol(rows,user, ColNo)
  IsExistsUserItemCol = IsExistsUserItemColWithoutRow(rows,user, ColNo, nothing)
end function

'=============================================
function IsExistsUserItemColWithoutRow(rows,user, ColNo,row)
  IsExistsUserItemColWithoutRow = false
  if row is nothing then 
    hdl = 0
  else 
    hdl = row.Handle
  end if
  for i = 0 to rows.Count - 1
   if Rows(i).handle <> hdl then 
    if not Rows(i).Attributes(ColNo).User is nothing then 
      if Rows(i).Attributes(ColNo).User.Handle = User.Handle then  
        IsExistsUserItemColWithoutRow = true
        exit function
      end if  
    end if
   end if 
  next
end function
'=============================================
function IsExistsGroupItemCol(rows,user, ColNo)
  IsExistsGroupItemCol = false
  for i = 0 to rows.Count - 1
    if not Rows(i).Attributes(ColNo).Group is nothing then 
      if Rows(i).Attributes(ColNo).Group.Handle = User.Handle then  
        IsExistsGroupItemCol = true
        exit function
      end if  
    end if
  next
end function
'=============================================
function IsExistsUserAndVal(rows,user, ColNo, val, colNo2 )

  IsExistsUserAndVal = false

  for i = 0 to rows.Count - 1
    if not Rows(i).Attributes(ColNo).User is nothing then 
      if Rows(i).Attributes(ColNo).User.Handle = User.Handle and Rows(i).Attributes(ColNo2).value = val then  
        IsExistsUserAndVal = true
        exit function
      end if  
    end if
  next

end function
'=============================================
function CheckEmptyRow(obj)

  CheckEmptyRow = false
  Set rows = thisObject.Attributes("ATTR_KD_TCP").Rows
  hasChange = false
  ans = ""
  for each row in rows
    if row.Attributes(0).value = "" and Row.Attributes(1).value = "" then 
      row.Erase
      hasChange = true
    elseif row.Attributes(0).value = "" or Row.Attributes(1).value = "" then 
      if ans = "" then _
        ans = msgbox( "Не все поля получателей заполнены. Удалить незаполненые строки?" & _
          vbNewLine & "Нажмите Нет, чтобы вернуться к редактированию", vbCritical + VbYesNo, _
          "Удалить не польностью заполненые строки?") 
      if ans = vbNo then 
          exit function
      else
        row.Erase
        hasChange = true
      end if    
    end if
  next
  if hasChange = true then thisObject.SaveChanges(0)
  CheckEmptyRow = true 
end function

'=================================
sub Del_FromTable(AttrName, ColNo )   
  thisScript.SysAdminModeOn   
    if not isObject(thisForm) then exit sub ' если вызывается не с формы
  
    set s = thisForm.Controls(AttrName).ActiveX
    ColNo = GetColNo(ColNo, s)
    ar = thisApplication.Utility.ArrayToVariant(s.SelectedRows)  
    selCount = Ubound(ar)
    if selCount < 0 then ' EV не может быть т.к. всегда выделена хотябы одна строка
      msgbox "Не выбрана ни одна строка!", VbOKOnly+vbExclamation, "Выберите строку!"
      exit sub
    end if
'    if s.DataSource.Rows.Count >= s.SelectedRow then 
'      msgbox "Выбрана пустая строка!", VbOKOnly+vbExclamation, "Выберите другую строку!"
'      exit sub
'    end if
    str = "Вы уверены, что хотите удалить " & vbNewLine & _
                      s.CellText(s.SelectedRow,ColNo)
                      's.RowValue(s.SelectedRow).Attributes(ColNo).Value
    if selCount >= 1 then _
        str = str & " и еще " & selCount & " строк(и)"
    str = str & "?"    
    Answer = MsgBox(  str, vbQuestion + vbYesNo,"Удалить?")
    if Answer <> vbYes then exit sub
    
    if isEmpty(thisObject) then 
      set docObj = GetObjectGlobalVarrible("DOCBASE")
      if docObj is nothing then 
        Set ReplyRows = ThisForm.Attributes(AttrName).Rows
      else
        Set ReplyRows = docObj.Attributes(AttrName).Rows
      end if
    else
      Set ReplyRows = ThisObject.Attributes(AttrName).Rows
    end if
    ' EV запоминаем выделеные проекты  
    for i = 0 to selCount
      if ar(i) < ReplyRows.Count then  
  '      set ar(i) = ReplyRows(ar(i)).Attributes(ColNo).object  
        set obj = ReplyRows(ar(i)).Attributes(ColNo).object
        if obj is nothing then 
          set obj = ReplyRows(ar(i)).Attributes(ColNo).user
          if obj is nothing then set obj = ReplyRows(ar(i)).Attributes(ColNo).Group
        end if
        set ar(i) = obj
      else
        set ar(i) = nothing
      end if
    next
   'EV удаляем запомненые проекты
    for i = 0 to Ubound(ar) '
      for j = 0 to ReplyRows.Count-1
        set val = ReplyRows(j).Attributes(ColNo).Object
        if val is nothing then 
          set val = ReplyRows(j).Attributes(ColNo).user
          if val is nothing then _
            set val = ReplyRows(j).Attributes(ColNo).group
        end if
        if not val is nothing then 
          if not ar(i) is nothing then 
            if val.Handle  = ar(i).Handle then 'проверяем, что проект = выделенному 
                ReplyRows(j).Erase
                Exit For
             end if
          end if   
        else
          if ar(i) is nothing then 
              ReplyRows(j).Erase
              Exit For
          end if
        end if    
      next
    next
        
    if not isEmpty(thisObject) then 
      if not isCanEdit() then 
        ReplyRows.Update  
        thisObject.Update
      end if
    else
      set docObj = GetObjectGlobalVarrible("DOCBASE")
      if not docObj is nothing then 
        if not isCanEditObj(docObj) then 
          ReplyRows.Update  
          docObj.Update
        end if
      end if
    end if  
end sub

'=================================
function GetColNo(ColName, grid)
  GetColNo = ColName
  if IsNumeric(GetColNo) then exit function
  for i = 0 to grid.ColumnCount-1
    if grid.ColumnValue(i).SysName = ColName then
      GetColNo = i
      exit function
    end if
  next
  GetColNo = 0
end function
'=================================
sub Del_FromTableWithPerm(AttrName, ColNo ,UserColNo)
  call Del_FromTableWithPermObj(AttrName, ColNo ,UserColNo,thisObject) 
end sub
'=================================
sub Del_FromTableWithPermObj(AttrName, ColNo ,UserColNo,docObj)
    
  Set control = thisForm.Controls("QUERY_KD_DOC_RELATIONS")
  iSel = control.ActiveX.SelectedItem
  If iSel < 0 Then 
      msgbox "Не выбрана ни одна строка!", VbOKOnly+vbExclamation, "Выберите строку!"
      Exit Sub 
  end if  

  ar = thisapplication.Utility.ArrayToVariant(control.SelectedItems)
  Answer = MsgBox( "Вы уверены, что хотите удалить из списка " & Cstr(Ubound(ar)+1) _
         & " строк?" , vbQuestion + vbYesNo,"Удалить?")
  if Answer <> vbYes then exit sub


'    set s = thisForm.Controls(AttrName).ActiveX

'    ar = thisapplication.Utility.ArrayToVariant(s.SelectedRows)  
'    selCount = Ubound(ar)
'    if selCount < 0 then ' EV не может быть т.к. всегда выделена хотябы одна строка
'      msgbox "Не выбрана ни одна строка!", VbOKOnly+vbExclamation, "Выберите строку!"
'      exit sub
'    end if
'    
'    str = "Вы уверены, что хотите удалить " & vbNewLine & _
'                      s.RowValue(s.SelectedRow).Attributes(ColNo).Value
'    if selCount >= 1 then _
'        str = str & " и еще " & selCount & " строк(и)"
'    str = str & "?"    
'    Answer = MsgBox(  str, vbQuestion + vbYesNo,"Удалить?")
'    if Answer <> vbYes then exit sub
  
    Set ReplyRows = docObj.Attributes(AttrName).Rows
    ' EV запоминаем выделеные   
    for i = 0 to Ubound(ar)
      set aprRow =  control.value.RowValue(ar(i))
      set ar(i) = aprRow 'ReplyRows(ar(i)).Attributes(ColNo).object
    next
   'EV удаляем запомненые 
    docObj.permissions = sysAdminPermissions
    for i = 0 to Ubound(ar) '
      if not  Del_Row (ReplyRows, ColNo, ar(i).Handle,UserColNo) then  ' EV если не удалилось из текущего, то пытаемся удалить из связанного
        set obj = thisApplication.Utility.GetObjectByHandle(ar(i).Handle)
        if not obj is nothing then
          obj.permissions = sysAdminPermissions
          if obj.Attributes.has(AttrName) then 
            Set objRows = obj.Attributes(AttrName).Rows
            if Del_Row (objRows, ColNo, docObj.Handle,UserColNo) then ' надо сохранить объект
              obj.permissions = sysAdminPermissions
              obj.update
            end if
          end if
        end if
      end if
    next 
'    if not isCanEditObj(docObj) then ' иначе выборка не обновляется
'      ReplyRows.Update  
      docObj.SaveChanges 16384
'    end if

end sub

'=============================================
function Del_Row (ReplyRows, ColNo, handle,UserColNo)'ar(i).Handle
    thisScript.SysAdminModeOn
    Del_Row = false
'    set curUser = thisApplication.CurrentUser
    for j = 0 to ReplyRows.Count-1
        set rowObj = ReplyRows(j).Attributes(ColNo).Object
        if not rowObj is nothing then 
            rowObj.Permissions = SysAdminPermissions
            if rowObj.Handle  = Handle then 'проверяем, что проект = выделенному 
              Del_Row = true
              if UserColNo = "" then  ' без проверки прав
                  ReplyRows(j).Erase
                  if rowObj.IsKindOf("OBJECT_KD_FILE") then rowObj.erase
                  Exit For
              end if
              set rowUser = ReplyRows(j).Attributes(UserColNo).User
              if not rowUser is nothing then ' если пользователь на задан ничего не делаем
'                if rowUser.SysName = curUser.SysName then 
                if IsInCurUsers(rowUser) then 
                  ReplyRows(j).Erase
                  if rowObj.IsKindOf("OBJECT_KD_FILE") then rowObj.erase
                  Exit For
                else
                  msgbox "Не возможно удалить [" & rowObj.Description & _
                      "], т.к. он был довален другим пользователем", vbCritical, "Ошибка удаления"
                  Exit For    
                end if
              end if  
            end if
       end if    
     next
end function
'=============================================
'sub Del_Projects(obj)      
'    if not isObject(thisForm) then exit sub 
'  
'    set s = thisForm.Controls("ATTR_KD_TLINKPROJ").ActiveX

'    ar = thisapplication.Utility.ArrayToVariant(s.SelectedRows)  
'    selCount = Ubound(ar)
'    if selCount < 0 then ' EV не может быть т.к. всегда выделена хотябы одна строка
'      msgbox "Не выбран ни один проект!", VbOKOnly+vbExclamation, "Выберите проект!"
'      exit sub
'    end if
'    
'    str = "Вы уверены, что хотите удалить связь с проектом  " & vbNewLine & _
'                      s.RowValue(s.SelectedRow).Attributes(0).Value
'    if selCount >= 1 then _
'        str = str & " и еще " & selCount & " проект(ов)"
'    str = str & "?"    
'    Answer = MsgBox(  str, vbQuestion + vbYesNo,"Удалить проект?")
'    if Answer <> vbYes then exit sub
'  
'    Set ReplyRows = ThisObject.Attributes("ATTR_KD_TLINKPROJ").Rows
'    ' EV запоминаем выделеные проекты  
'    for i = 0 to selCount
'      set ar(i) = ReplyRows(ar(i)).Attributes("ATTR_KD_LINKPROJ").object
'    next
'   'EV удаляем запомненые проекты
'    for i = 0 to Ubound(ar) '
'      for j = 0 to ReplyRows.Count-1
'        if ReplyRows(j).Attributes("ATTR_KD_LINKPROJ").Object.Handle  = ar(i).Handle then 'проверяем, что проект = выделенному 
'            ReplyRows(j).Erase
'            Exit For
'        end if    
'      next
'    next 
'end sub
'=============================================
Sub ClearAttribute(AttrName)
  'Удаление лишних пробелов из атрибута
  if ThisObject.Attributes(AttrName).AttributeDef.type = 0 then _
      ThisObject.Attributes(AttrName).Value = Replace(Replace(Trim(ThisObject.Attributes(AttrName).Value),"  "," "),"  "," ")
  
end sub

'=================================
function CheckEMail(EMail,silient)
    'Если электронный адрес просто не задан
    EMail = Trim(EMail) 
    if EMail = "" then
      CheckEMail=true 
      exit function
    end if
    
    CheckEMail = isValidEmail(EMail)
    
    if (not CheckEMail) and (not silient) then
      MsgBox "Неправильный адрес электронной почты!",vbCritical,"Ошибка!"
    end if

end function
'=================================
function CheckPhoneNumber(Phone)
CheckPhoneNumber = true

if Phone = "" then
   exit function
end if

  PhoneNumber = Replace(Replace(Replace(Replace(Replace(Replace(Replace(Trim(Phone),"-",""),"(",""),")",""),"-",""),"+",""),"*","")," ","")
  if not IsNumeric(PhoneNumber) then
    MsgBox "Номер телефона может состоять только из следующих символов 0123456789()-+*",VbCritical,"Ошибка"
    CheckPhoneNumber=false
  end if
end function

'=============================================
function Create_Doc(docBase)
    set Create_Doc = nothing
    
    ThisScript.SysAdminModeOn
  
    if thisApplication.CurrentUser.SysName <> GetCurUser().SysName then
      msgbox "Создавать документ можно только от своего имени. "& vbNewLine _
        & "Выберите себя в оперативной панели, чтобы создать новый документ.", vbExclamation, _
        "Измените пользователя в оператичной панели"
      exit function
    end if
    set objType = thisApplication.ObjectDefs("OBJECT_KD_BASE_DOC")
    cnt = objType.SubObjectDefs.Count + 2
    dim LetterTypesArray()  
    Redim LetterTypesArray(cnt)

    set User = GetCurUser()
    IsSec = isSecretary(User)
    isCanCrContr = User.Groups.Has("GROUP_CONTRACTS")
    isCanCrAct = User.Groups.Has("GROUP_CCR")
    i = 0
    if isSec then 
      LetterTypesArray(i) = "Входящий документ"
      i = 1
    end if
'EV TODO    убрать потом после разработки всех документов
    LetterTypesArray(i) = "Исходящий документ"
    i = i+1
    LetterTypesArray(i) = "Служебная записка"
    i = i+1
    LetterTypesArray(i) = "ОРД"
    i = i+1
    LetterTypesArray(i) = "Заявка на оплату"
    i = i+1
    LetterTypesArray(i) = "Протокол"
    if isCanCrContr then 
      i = i+1
      LetterTypesArray(i) = "Договор"
      i = i+1
      LetterTypesArray(i) = "Соглашение"    
    end if
    if isCanCrAct then 
      i = i+1
      LetterTypesArray(i) = "Акт"
    end if
'    i = i+1
'    LetterTypesArray(i) = "Без документа-основания" 
'    
'    for each chObjType in objType.SubObjectDefs
'      if chObjType.SysName <>"OBJECT_KD_DOC_IN" then 
'         LetterTypesArray(i)= chObjType.Description
'         i=i+1
'      end if   
'    next

    Set SelDlg = ThisApplication.Dialogs.SelectDlg
    SelDlg.SelectFrom = LetterTypesArray
    SelDlg.Caption = "Выбор типа документа"
    SelDlg.Prompt = "Выберите тип документа:"
    
    RetVal = SelDlg.Show
      
    'Если пользователь отменил диалог или ничего не выбрал, закончить работу.
    If ( (RetVal <> TRUE) or (UBound(SelDlg.Objects)<0) ) Then  
      exit function
    end if
   
    SelectedArray = SelDlg.Objects  
    if SelectedArray(0) = "" then exit function
    
    set objType = thisApplication.ObjectDefs(SelectedArray(0))
    select case objType.SysName
      case "OBJECT_CONTRACT"  set Create_Doc = thisApplication.ExecuteScript("CMD_DLL_CONTRACTS", "CreateContract", docBase)
      case "OBJECT_AGREEMENT" set Create_Doc = thisApplication.ExecuteScript("CMD_AGREEMENT_CREATE", "Create_Agreement", docBase)
      case  "OBJECT_CONTRACT_COMPL_REPORT" set Create_Doc = ThisApplication.ExecuteScript("CMD_CONTRACT_COMPL_REPORT_CREATE","CreateCCR",docBase)
      Case Else set Create_Doc =  Create_Doc_by_Type(objType, docBase)
    end select
'    if objType.SysName = "OBJECT_CONTRACT" then ' EV для договора отдельная функция
'      set Create_Doc = thisApplication.ExecuteScript("CMD_DLL_CONTRACTS", "CreateContract", docBase)
''      if not Create_Doc is nothing then 
''        call AddResDocFiles(docBase, Create_Doc, "Является документом основанием для договора", false)
''        docBase.Permissions = SysadminPermissions
''        docBase.SaveChanges(16384)
''      end if
'    Elseif objType.SysName = "OBJECT_AGREEMENT" then ' EV для Соглашения отдельная функция
'      set Create_Doc = thisApplication.ExecuteScript("CMD_AGREEMENT_CREATE", "Create_Agreement", docBase)
'    else
'      set Create_Doc =  Create_Doc_by_Type(objType, docBase)
'    end if
    
end function

'=============================================
function Create_Doc_by_Type(objType, docBase)
    ThisScript.SysAdminModeOn
    set Create_Doc_by_Type = nothing
    Set ObjRoots = GET_FOLDER("",objType) 
    if  ObjRoots is nothing then  
      msgBox "Не удалось создать папку", vbCritical, "Объект не был создан"
      exit function
    end if
    CreateObj = true
    ObjRoots.Permissions = SysAdminPermissions
    Set CreateDocObject = ObjRoots.Objects.Create(objType)
'    if objType.SysName = "OBJECT_KD_DOC_OUT" and not docBase is nothing then 
    if not docBase is nothing then 
      if docBase.ObjectDefName = "OBJECT_KD_DOC_IN" and objType.SysName = "OBJECT_KD_DOC_OUT" then 
      ' если ИД, то записываем ответ на
          call thisApplication.ExecuteScript("CMD_KD_COMMON_BUTTON_LIB","AddReplDoc",CreateDocObject, docBase) 
      else
          'прикладываем как связанный
          withFile = false
          if CreateDocObject.IsKindOf("OBJECT_KD_ORDER") then withFile = true
          call AddResDocFiles(CreateDocObject, docBase, "", withFile)
          'копируем что можем
          call CopyDocProj(CreateDocObject, docBase)
      end if
    end if
    ' код копирования нужных атрибутов объекта
    on error resume next
    Call thisApplication.ExecuteScript(docBase.ObjectDefName,"CopyAttrsFromDocBase", CreateDocObject,docBase)
    if err.Number <>0 then err.clear
    on error goto 0 

    call Set_Permission (CreateDocObject)
    if not CreateDocObject.IsKindOf("OBJECT_KD_BASE_DOC") then CreateDocObject.Update   
    ' Инициализация свойств диалога создания объекта
    formName = thisApplication.ExecuteScript("OBJECT_KD_BASE_DOC", "GetCreateFroms", CreateDocObject)
    if formName <> "" then 
       call SetGlobalVarrible("ShowForm", formName)  
    else 
      call RemoveGlobalVarrible("ShowForm")
    end if   
     Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
     CreateObjDlg.Object = CreateDocObject
     CreateObjDlg.OkButtonText = "Создать"
     CreateObjDlg.WarnModifiedOnCancel = false
     ans = CreateObjDlg.Show
    
     if CreateDocObject.StatusName = "STATUS_KD_DRAFT" then   
       If not ans then
          If CreateObj Then 
             CreateDocObject.Erase  ' EV все-таки подумать как удалять
             exit function
          end if   
       End if
     end if
  
     'Set_Permition CreateDocObject EV т.к. перенесли в изменение статуса
      set Create_Doc_by_Type = CreateDocObject
end function

'=============================================
sub CopyDocProj(newDoc, OldDoc)
  if oldDoc.Attributes.Has("ATTR_KD_AGREENUM") then 
    if oldDoc.Attributes("ATTR_KD_AGREENUM").value > "" then _
        newDoc.Attributes("ATTR_KD_AGREENUM").value = oldDoc.Attributes("ATTR_KD_AGREENUM").object
    for each row in OldDoc.Attributes("ATTR_KD_TLINKPROJ").rows
      set  proj = row.Attributes("ATTR_KD_LINKPROJ").Object
      if not proj is nothing then _
        call AddNewProjSilent(newDoc, proj,true) 
    next 
  elseif oldDoc.Attributes.Has("ATTR_CONTRACT") then ' для добавления из объектов ТДО
    if oldDoc.Attributes("ATTR_CONTRACT").value > "" then _
        newDoc.Attributes("ATTR_KD_AGREENUM").value = oldDoc.Attributes("ATTR_CONTRACT").object
    if oldDoc.Attributes.Has("ATTR_PROJECT") then ' для добавления из объектов ТДО
      if oldDoc.Attributes("ATTR_PROJECT").value > "" then 
        set  proj = oldDoc.Attributes("ATTR_PROJECT").Object
        if not proj is nothing then _
          call AddNewProjSilent(newDoc, proj,true) 
      end if
    end if  
  end if
  'EV для накладной
  if newDoc.Attributes.Has("ATTR_KD_TCP") and  OldDoc.Attributes.Has("ATTR_INVOICE_RECIPIENT") then 
    set cordent = OldDoc.Attributes("ATTR_INVOICE_RECIPIENT").object 
    if not cordent is nothing then
      set pers = cordent.Attributes("ATTR_CORDENT_USER").object
      if not pers is nothing then _
        call thisApplication.ExecuteScript("FORM_KD_CORDENTS", "AddCorDent", newDoc, pers, false)
    end if
  end if
end sub
'=============================================
sub AskToAddRelDoc()
  call AskToAddRelDocObj(thisObject, true)
end sub
'=============================================
sub AskToAddRelDocObj(docObj,withFiles) 'PlotnikovSP Select and save to dic this path
'  спрашиваем комментарий
     Set SelObjDlg = ThisApplication.Dialogs.SelectObjectDlg 
     SelObjDlg.Prompt = "Выберите один или несколько документов:"

     RetVal = SelObjDlg.Show 
     Set ObjCol = SelObjDlg.Objects
     If (RetVal<>TRUE) Or (ObjCol.Count=0) Then Exit Sub
     
    
     
     

     Set noteDlg = ThisApplication.Dialogs.SimpleEditDlg
     noteDlg.Caption = "Введите примечание"
     noteDlg.Prompt = "Примечание к связи с документом "
     If not noteDlg.Show Then exit sub
    
     For Each obj In ObjCol
         'call AddRelDoc(docObj, obj, noteDlg.Text) 
         call AddResDocFiles(DocObj, obj, noteTxt, withFiles)    
     Next
end sub
'=============================================
sub AddRelDoc(DocObj, CurReply, noteTxt)  
   call  AddResDocFiles(DocObj, CurReply, noteTxt, true) 
'    Set ReplyRows = DocObj.Attributes("ATTR_KD_T_LINKS").Rows

'    'Проверка нет ли добавляемого письма в списке
'    DocObj.Permissions = SysAdminPermissions
'    if not IsExistsObjItemCol(ReplyRows,CurReply,0) then
'      Set NewRow = ReplyRows.Create
'      NewRow.Attributes(0).Value = CurReply
'      NewRow.Attributes(1).Value = thisApplication.CurrentUser
'      NewRow.Attributes(2).Value = noteTxt
'      ReplyRows.Update
'    else
'      msgBox "Докумет " & CurReply.Description & " уже есть в списке. Добавление не будет произведено.",vbInformation
'    end if   
'      
end sub
'=============================================
sub AddResDoc(CurReply)  
    call  AddResDocFiles(thisObject, CurReply, "", false)   
end sub
'=============================================
sub AddResDocFiles(DocObj, CurReply, noteTxt, withFiles)   
    thisScript.SysAdminModeOn
    docObj.permissions = SysadminPermissions
    if DocObj.Attributes.Has("ATTR_KD_POR_RESDOC") then 
        Set ReplyRows = DocObj.Attributes("ATTR_KD_POR_RESDOC").Rows
    else
        Set ReplyRows = DocObj.Attributes("ATTR_KD_T_LINKS").Rows
    end if
    
    'Проверка нет ли добавляемого письма в списке
    DocObj.Permissions = SysAdminPermissions
    if IsExistsObjItemCol(ReplyRows,CurReply,0) then
      msgBox "Докумет " & CurReply.Description & " уже есть в списке. Добавление не будет произведено.",vbInformation
      exit sub
    end if   
    Set NewRow = ReplyRows.Create
    NewRow.Attributes(0).Value = CurReply
    if ReplyRows.AttributeDefs.Count > 1 then 
       NewRow.Attributes(1).Value = thisApplication.CurrentUser
       NewRow.Attributes(2).Value = noteTxt
    end if
    ReplyRows.Update
'    DocObj.Update
    if withFiles then 
      if CurReply.Files.Count > 0 then 
        ans = msgbox("К документу " & CurReply.description & " приложены файлы, хотите приложить их к текущему документу?", _
          vbQuestion + vbYesNo, "Приложить файлы?")
        if ans <> vbYes then exit sub
        hasChanges = false
        for each file in CurReply.Files
          if not DocObj.files.has(file.FileName) then 
             set newFile = DocObj.Files.AddCopy(file, file.FileName)
             newfile.FileDef = thisApplication.FileDefs("FILE_KD_ANNEX")
             hasChanges = true 
          end if
        next
        if hasChanges = true then DocObj.SaveChanges(16384)
      end if  
    end if
end sub
'=============================================
sub Del_User(attrName)
 if IsEmpty(thisObject) then 
      set obj = thisForm
  elseif thisObject is nothing then 
      set obj = thisForm
  else  
      set obj = thisObject   
  end if
  if obj is nothing then   exit sub
  if obj.Attributes(attrName).Value > "" then 
        obj.Attributes(attrName).Value = ""
'        ShowUser(attrName)
  end if   
end sub

'=============================================
sub Add_self_Control(attrName)
 if IsEmpty(thisObject) then 
      set obj = thisForm
  elseif thisObject is nothing then 
      set obj = thisForm
  else  
      set obj = thisObject   
  end if
  if obj is nothing then   exit sub

  obj.Attributes(attrName).Value = thisApplication.CurrentUser
 ' ShowUser(attrName)

end sub

'=============================================
function CopyDoc(docObj)

    CopyDoc = false 
    ThisScript.SysAdminModeOn
    Set ObjRoots = GET_FOLDER("",docObj.ObjectDef) 
    if  ObjRoots is nothing then  
      msgBox "Не удалось создать папку", vbCritical, "Объект не был создан"
      exit function
    end if
    ObjRoots.Permissions = SysAdminPermissions
    Set newdoc = ObjRoots.Objects.Create(docObj.ObjectDef)
    call Set_Permission (newdoc)

    if newdoc is nothing then 
      msgbox "Не удалось создать документ", vbCritical, "Ошибка"
      exit function
    end if
    if not CopyAttrs(docObj,newDoc) then 
      msgbox "Не удалось скопировать атрибуты документа", vbCritical, "Ошибка"
      exit function
    end if
     newDoc.Attributes("ATTR_KD_DOC_PREFIX").Value = thisApplication.ExecuteScript("CMD_KD_REGNO_KIB","Get_Prifix",newDoc) 
'     newDoc.update  
     Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
     CreateObjDlg.Object = newdoc
     ans = CreateObjDlg.Show

    CopyDoc = true
end function    
  
'=============================================
function CopyAttrs(docObj,newDoc) 
  CopyAttrs = false
  set deftype = docObj.ObjectDef
    if not thisApplication.Attributes.Has("ATTR_KD_COPY_ATTRS") then exit function
    set rows = thisApplication.Attributes("ATTR_KD_COPY_ATTRS").Rows
    for each row in rows
      if row.Attributes(0).value = deftype.SysName then 
        call copyAttr(docObj,newDoc,row.Attributes(1).value)
      end if
    next
  CopyAttrs = true
end function

'=============================================
function  copyAttr(docObj,newDoc,attrName)
   set attr = thisApplication.AttributeDefs(attrName)
   if attr is nothing then exit function
   if docObj.Attributes.Has(attrName) and newDoc.Attributes.Has(attrName) then 
'      thisApplication.DebugPrint attr.Type & " " & attrName
      if attr.Type <> 11 then 'tdmTable then
          call SetAttr(attr, newDoc, docObj)
      else ' табличный
        for each row in docObj.Attributes(attrName).rows
          set newRow = newDoc.Attributes(attrName).Rows.Create
          for each nAttr in row.Attributes
            def = nAttr.AttributeDefName
            set DefType = thisApplication.AttributeDefs(def)
            call SetAttr(DefType, newRow, Row)
          next
        next
      end if
   end if
end function

'=============================================
function  copyFiles(docObj,newDoc)
  copyFiles = false 
  if docObj.Files.Count > 0 then 
    ans = msgbox("К документу " & docObj.description & " приложены файлы, хотите приложить их к текущему документу?", _
      vbQuestion + vbYesNo, "Приложить файлы?")
    if ans <> vbYes then 
      copyFiles = true
      exit function
    end if
    hasChanges = false
    for each file in docObj.Files
      if not newDoc.files.has(file.FileName) then 
         set newFile = newDoc.Files.AddCopy(file, file.FileName)
         hasChanges = true 
      end if
    next
'    if hasChanges = true then DocObj.SaveChanges(16384)
  end if
  copyFiles = true
end function
'=============================================
function SetAttr(DefType, newObj, oldObj)
  def = DefType.SysName
    select case DefType.Type 
       case 7  
          if not oldObj.Attributes(def).object is nothing then _
            newObj.Attributes(def).object = oldObj.Attributes(def).object
       case 9   
          if not oldObj.Attributes(def).user is nothing then _
            newObj.Attributes(def).user = oldObj.Attributes(def).user
       case else
            newObj.Attributes(def).value = oldObj.Attributes(def).value
    end select

end function
'=============================================
function createWord()
  createWord = false
  dim file, Answer, fName
  'msgBox "Раздел находится в разработке"

  if ThisForm.Controls.Has("PREVIEW1") then ThisForm.Controls("PREVIEW1").Value = "1" ' чтобы наверняка перечитал
  call SetGlobalVarrible("ShowFile", -1) ' EV чтобы не показывать пдф первый раз
  set file = GetWordFile()
  if not file is nothing then
     Answer = MsgBox("Оригинал документа уже приложен. " & _
          "Вы уверены, что хотите удалить существующий и создать новый?", vbQuestion + vbYesNo,"Удалить?")
     if Answer <> vbYes then exit function
     on error resume next
     file.Erase
     If Err.Number<>0 Then 
        msgbox "Не удалось удалить файл " & delFile.FileName & ". Ошибка :" & err.Description ,vbCritical, "Ошибка удаления файла"
        Err.Clear
        exit function
     end if  
     on error goto 0
     thisObject.SaveChanges()
  end if
  
  if not thisApplication.FileDefs.Has("File_" & thisObject.ObjectDefName) then 
    msgbox "Невозможно создать файл, т.к. не задан шаблон", vbCritical 
    exit function
  end if
  If thisApplication.FileDefs("File_" & thisObject.ObjectDefName).Templates.Count <> 0 Then
    fName = thisApplication.ExecuteScript("CMD_KD_FILE_LIB","GetDocFileName",thisObject)
    set tmlFile = GetTempInd()
    if tmlFile is nothing then 
      msgbox "Не удалось выбрать шаблон. Создать документ невозможно", vbExlamation, "Создать документ невозможно"
      exit function
    end if
    set newFile = thisObject.Files.Create("FILE_KD_WORD")
    dirName = tmlFile.WorkFileName
    tmlFile.CheckOut(dirName & "\" & fName) ' выгружаем, загружаем, чтобы была новая дата и пользователь
    NewFile.CheckIn dirName & "\" & fName

'    newfile.FileDef = thisApplication.FileDefs("FILE_KD_WORD")
    thisObject.SaveChanges(16384)
    'thisObject.Update  
    'ShowFileName()
    Word_Check_Out() ' открываем ворд
    createWord = true
  else
    msgbox "Шаблон для документа не задан"
    exit function
  end if      
end function

'=================================
function GetTempInd()
    'GetTempInd = 0
    set GetTempInd = nothing
    fileDef = "File_" & thisObject.ObjectDefName
    if thisApplication.FileDefs(fileDef).Templates.Count = 0 then exit function
    
    if thisObject.Attributes.Has("ATTR_KD_PR_TYPEDOC") then 
      ord = thisObject.Attributes("ATTR_KD_PR_TYPEDOC").Classifier.SysName
      txt = ""
      select case ord
        case "NODE_KD_PR_DIRECT"  txt = "Бланк распоряжения.docx"
        case "NODE_KD_PR_ORDER"   txt = "Бланк приказа.docx"
        case "NODE_BYLAW"  txt = "Бланк регламента.docx"
        case else txt = "Общий бланк.docx"'PlotnikovSP modify
      end select   
      set GetTempInd = thisApplication.FileDefs(fileDef).Templates(txt)
      'GetTempInd = thisApplication.FileDefs("fileDef").Templates.Index(f)
    else 'EV пока без ОРД
      if thisApplication.FileDefs(fileDef).Templates.Count = 1 then 
        set GetTempInd = thisApplication.FileDefs(fileDef).Templates(0)
        exit function
      end if
      set dlg = thisApplication.Dialogs.SelectDlg
      dlg.SelectFrom = thisApplication.FileDefs(fileDef).Templates
      RetVal = dlg.Show
      
      'Если пользователь отменил диалог или ничего не выбрал, закончить работу.
      If ( (RetVal <> TRUE) or (dlg.Objects.Count = 0) ) Then  
        exit function
      end if
'      GetTempInd = thisApplication.FileDefs(fileDef).Templates .Index(dlg.objects(0))
      set GetTempInd = dlg.objects(0)
    end if
end function
'=================================
function GetObjFroms(obj)
    GetObjFroms = ""
    if not thisApplication.Attributes.Has("ATTR_KD_T_FORMS_SHOW") then exit function
    set rows = thisApplication.Attributes("ATTR_KD_T_FORMS_SHOW").Rows
    for each row in rows
      if row.Attributes(0).value = obj.ObjectDefName then 
        if row.Attributes(1).value = obj.StatusName then 
          GetObjFroms = row.Attributes(2).value
          exit function
        end if  
      end if
    next
end function
'=================================
function GetCreateFroms(obj)
    GetCreateFroms = ""
    if not thisApplication.Attributes.Has("ATTR_KD_T_FORMS_SHOW") then exit function
    set rows = thisApplication.Attributes("ATTR_KD_T_FORMS_SHOW").Rows
    for each row in rows
      if row.Attributes(0).value = obj.ObjectDefName then 
        if row.Attributes(1).value = "CREATE" then 
          GetCreateFroms = row.Attributes(2).value
          exit function
        end if  
      end if
    next
end function
'=================================
sub SetSysFromFisible(Dialog, value)
    if thisApplication.CurrentUser.SysName <> "SYSADMIN" then 
       Dialog.SystemFormVisibility (tdmSysFormFiles) = value
       Dialog.SystemFormVisibility (tdmSysFormPreview) = value
       Dialog.SystemFormVisibility (tdmSysFormSystem) = value
       Dialog.SystemFormVisibility (tdmSysFormSigns) = value
       Dialog.SystemFormVisibility (tdmSysFormSummaryPermissions) = value
       Dialog.SystemFormVisibility (tdmSysFormRoles) = value
       Dialog.SystemFormVisibility (tdmSysFormContent) = value
       Dialog.SystemFormVisibility (tdmSysFormPartOf) = value
       Dialog.SystemFormVisibility (tdmSysFormVersions) = value
       Dialog.SystemFormVisibility (tdmSysFormHistory) = value
       Dialog.SystemFormVisibility (tdmSysFormMessages) = value
       Dialog.SystemFormVisibility (tdmSysFormReferencedBy) = value
    end if   
end sub

'=================================
sub ShowForms(FormList, Forms)
    For each Form in Forms
'thisApplication.AddNotify "For each Form  - " & CStr(timer)
        If InStr(";" & FormList & ";", ";" & form.SysName & ";") = 0 Then Forms.Remove Form    
'thisApplication.AddNotify "Forms.Remove - " & CStr(timer)
    Next 
end sub

'=================================
sub AddContr(obj)
  thisscript.SysAdminModeOn
    Set Q = ThisApplication.Queries("QUERY_CONTACT_CODES")
    set sh = Q.Sheet
'    Set Objs = Q.Objects
'    set selObj = thisApplication.Dialogs.SelectObjectDlg
'    SelObj.SelectFromObjects = Objs
    set selObj = thisApplication.Dialogs.SelectDlg
    selObj.SelectFrom = sh
    'selObj.ObjectDef = "OBJECT_CONTRACT"
    selObj.Prompt = "Выберите договор"
    RetVal = selObj.Show 
    If (RetVal <> TRUE) then Exit Sub
    Set ObjCol = selObj.Objects.Objects
'    If (RetVal<>TRUE) Or (ObjCol.Count = 0) Then Exit Sub
    obj.Permissions =  SysadminPermissions
    obj.Attributes("ATTR_KD_AGREENUM").Value = ObjCol(0)
    
    obj.Attributes("ATTR_KD_TLINKPROJ").Rows.RemoveAll
    
    if Obj.Attributes("ATTR_KD_WITHOUT_PROJ").value then Obj.Attributes("ATTR_KD_WITHOUT_PROJ").value = false
    
    if Obj.Attributes.has("ATTR_CONTRACT_INCIDENTAL") then  _
            Obj.Attributes("ATTR_CONTRACT_INCIDENTAL").value = ObjCol(0).Attributes("ATTR_CONTRACT_INCIDENTAL").value

    Set Q = ThisApplication.Queries("QUERY_KD_PROJ_CHOICE")
    Q.Parameter("PARAM0") = "=" & ObjCol(0).handle
    
    Set Objs = Q.Objects
    if objs.Count then call AddNewProjSilent(obj, objs(0),true)

    'EV TODO добавить блокировок и прав
    if not IsCanEditObj(Obj) then _
        obj.Update
end sub

'=================================
function DelContr(Obj)
  DelContr = false
  RetVal = vbNo
  if obj.Attributes("ATTR_KD_AGREENUM").Value <> "" then 
      retval = MsgBox("Вы уверены, что хотите удалить связь с договором?", vbQuestion + vbYesNo)
  else  
    DelContr = true
    exit function
  end if  
      
  If (RetVal = vbYes) Then 
     obj.Permissions = SysAdminPermissions
     obj.Attributes("ATTR_KD_AGREENUM").Value = ""
     obj.Attributes("ATTR_KD_TLINKPROJ").Rows.RemoveAll
     if obj.Attributes.has("ATTR_CONTRACT_INCIDENTAL") then obj.Attributes("ATTR_CONTRACT_INCIDENTAL").value = false 
     ' EV не надо сохранять если форма в режиме редатирования
     if not IsCanEditObj(Obj) then _
          obj.Update
          'EV TODO добавить блокировок и прав
     DelContr = true
  end if  
end function
'=================================
function GetUserFIOFromStr(desc)
  GetUserFIOFromStr = desc
  UserArr = Split(desc," ")
  select case Ubound (UserArr) 
    case 1      GetUserFIOFromStr = UserArr(0) & " " & Left(UserArr(1),1) & "." 
    case 2      GetUserFIOFromStr = UserArr(0) & " " & Left(UserArr(1),1) & ". " & Left(UserArr(2),1) & "."
  end select   
'  GetUserFIO = Left(user.FirstName,1) & "." & Left(user.MiddleName,1) & ". " & user.LastName
end function
'==============================================================================
sub AddObjLinkFile(docObj)
  dim SelFileDlg,FDef,FileNames
  ThisScript.SysAdminModeOn

  Set SelFileDlg = ThisApplication.Dialogs.FileDlg
  retVal = SelFileDlg.Show
  If retVal <> TRUE Then Exit sub
  
  Set noteDlg = ThisApplication.Dialogs.SimpleEditDlg
  noteDlg.Caption = "Введите примечание"
  noteDlg.Prompt = "Примечание к связи с файлами"
  If not noteDlg.Show Then exit sub

  FileNames = SelFileDlg.FileNames
  for i = 0 to Ubound(SelFileDlg.FileNames)
      call  CreateObjFile(FileNames(i),docObj,noteDlg.Text)
  next
  thisForm.Refresh
End Sub
'==============================================================================
sub CreateObjFile(FileName,docObj,txt)
  ThisScript.SysAdminModeOn
  set obj = docObj.Objects.Create("OBJECT_KD_FILE")
  if obj is nothing then exit sub
  
  Set FSO = CreateObject("Scripting.FileSystemObject") 
  Set Files = obj.Files
  Set NewFile = obj.Files.Create("FILE_ANY")       
  NewFile.CheckIn FileName
  obj.SaveChanges 16384 
  set_permission(obj)
  call AddResDocFiles(DocObj, obj, txt, false)   
  DocObj.SaveChanges 16384
end sub
'==============================================================================
Sub Files_DragAndDropped(FilesPathArray, Object, Cancel)
    For i = 0 to Ubound(FilesPathArray)
      call thisApplication.ExecuteScript("CMD_KD_FILE_LIB", "AddFile_application",FilesPathArray(i),Object)
    Next 
   ' Чтобы не отработал обработчик по умолчанию
    Cancel = true
end sub    
