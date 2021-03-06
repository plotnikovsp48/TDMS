USE "CMD_DLL_ROLES"
USE "CMD_FILES_LIBRARY"


'Sub SaveLinkNK(Obj_)
'  ThisApplication.DebugPrint "SaveLinkNK "&time()
'  dim q
'  
'  guid = Obj_.GUID
'  Set nk = ThisApplication.Dictionary("NK")
'  if nk.Exists(guid) Then Exit Sub
'  
'  set q = ThisApplication.Queries("QUERY_LINK_NK")
'  q.Parameter("PARAM0") = Obj_.Handle
'  set o = Nothing
'  on error resume next
'  Set o = q.Objects(0)
'  on error goto 0
'  
'  If o is nothing Then Exit Sub

'  nk.Add guid, o  
'    
'End Sub


Sub Form_BeforeShow(Form, Obj)
  

  '---------------Сохраняем ссылку на объект НК

'  call SaveLinkNK(Obj)
  Call ThisApplication.ExecuteScript("CMD_SS_LIB", "SaveLinkNK", Obj)

  '---------------
  

  

  ThisApplication.DebugPrint "Form_BeforeShow1 "&time()
  form.Caption = form.Description
  Call ClearOrderAttr()
  ThisApplication.DebugPrint "Form_BeforeShow12 "&time()
  Call SetControlsEnabled(Form,Obj)
  ThisApplication.DebugPrint "Form_BeforeShow13 "&time()



  Call ThisApplication.ExecuteScript("CMD_DLL", "ShowBtnIcon",Form,Obj)
  ThisApplication.DebugPrint "Form_BeforeShow14 "&time()
  ShowFile(0)'(-1)'(0)
  ThisApplication.DebugPrint "Form_BeforeShow15 "&time()
  'SetBtnName() 
  ShowSysID() 
  ThisApplication.DebugPrint "Form_BeforeShow16 "&time()
  'SetEmptyAttr()
  'SetContolEnable(settings)  
   
  
  If Obj.ObjectDefName <> "OBJECT_NK" Then 
    Set oNKObj = GetNKObj(Obj)
    If oNKObj Is Nothing Then Exit Sub
    Call FormRefresh(Form, oNKObj)
  '--------------- 
  
  
  ThisApplication.DebugPrint "Form_BeforeShow2 "&time()
  set ico = oNKObj.ObjectDef.Icon
    
  Dim qryCtrl, src
  Set qryCtrl = Form.Controls("QUERY_NK_ISSUES").ActiveX
  
  qryCtrl.DeleteColumn(7)
  qryCtrl.DeleteColumn(7)
  
  count = qryCtrl.Count
  For iItem=0 to count-1
    Set scr = qryCtrl.ItemObject(iItem).Attributes
    ThisApplication.DebugPrint iItem&"Form_BeforeShow3 "&time()
    If scr("ATTR_NK_RESULTS_CORRECTED").Value Then
      qryCtrl.ItemIcon(iItem,0)=thisApplication.Icons("IMG_OK")
      ThisApplication.DebugPrint iItem&"Form_BeforeShow4 "&time()
    Else
      qryCtrl.ItemIcon(iItem,0)=ico
      ThisApplication.DebugPrint iItem&"Form_BeforeShow5 "&time()
    End If 
  Next
'---------------  
 End If
  
  
End Sub

'=============================================
Function GetNKObj(Obj)
  ThisApplication.DebugPrint "GetNKObj "&time()
  Set GetNKObj = ThisApplication.ExecuteScript("CMD_SS_LIB", "GetInspectionObject", Obj)
End Function
'=============================================
'function GetNKObjByObj(Obj)
'  set GetNKObjByObj = nothing
'  
'  set query = ThisApplication.Queries("QUERY_GET_NK")
'  query.Parameter("PARAM0") = obj.handle
'  set objs = query.Objects
'  if objs.Count>0 then _
'    set GetNKObjByObj = objs(0)

'  if GetNKObjByObj is nothing then _
'     set  GetNKObjByObj = CreateNK()  
'end function

''=============================================
'function CreateNK()
'  set CreateNK = CreateNKObj(thisObject, false)
'end function

''=============================================
'function CreateNKObj(obj, silent)

'    set CreateNKObj = nothing
'    set objType = thisApplication.ObjectDefs("OBJECT_NK")
'    Set ObjRoots = ThisApplication.ExecuteScript("CMD_KD_FOLDER", "GET_FOLDER", "",objType)

'    if  ObjRoots is nothing then  
'      if not silent then _
'          msgBox "Не удалось создать папку", vbCritical, "Объект не был создан"
'      exit function
'    end if
'    ObjRoots.Permissions = SysAdminPermissions
'    Set NewObj = ObjRoots.Objects.Create(objType)
'    NewObj.attributes("ATTR_OBJECT").value = obj
'    NewObj.update

'    set CreateNKObj = NewObj
'end function

Private Sub SetControlsEnabled(Form,Obj)
  ThisApplication.DebugPrint "SetControlsEnabled "&time()
  Set cCtrl = Form.Controls
  For Each ctl In cCtrl
    ctl.Enabled = True
    ctl.Readonly = True
  Next
  Set CU = ThisApplication.CurrentUser
  isExec = isNCUser(Obj,CU)
  isApr = isCanAprove(Obj)
  isGrMem = IsGroupMember(CU,"GROUP_NK")
  canViewFiles = Obj.Permissions.ViewFiles = 1
  
  cCtrl("CMD_ADD_REMARK").Enabled = SetButtonEnable And isExec And isApr
  cCtrl("CMD_DEL_REMARK").Enabled = SetButtonEnable And isExec And isApr
  cCtrl("CMD_EDIT_REMARK").Enabled = SetButtonEnable
  cCtrl("BTN_ADD_FILE").Enabled = SetButtonEnable And isExec And isApr
  cCtrl("CMD_CLOSE_REMARK").Enabled = SetButtonEnable  And isExec And isApr
  cCtrl("CMD_CLOSE_ALLREMARK").Enabled = SetButtonEnable And isExec And isApr
  cCtrl("BTN_NK_APPROVE").Enabled = SetButtonEnable And isApr And isExec
  cCtrl("BTN_NK_REJECT").Enabled = SetButtonEnable And isApr And isExec
'  cCtrl("ATTR_NK_RESULTS_DESC").Enabled = True
  cCtrl("EDIT_ATTR_NK_RESULTS_DESC").Enabled = True
 ' cCtrl("ATTR_NK_NOTES_ALL").Enabled = SetButtonEnable
 ' cCtrl("ATTR_NK_NOTES_FOR_CORRECT").Enabled = SetButtonEnable
  cCtrl("CMD_DOCUMENT_TAKE_FOR_NK").Visible = isGrMem And (Obj.StatusName = "STATUS_DOCUMENT_IS_SENT_TO_NK")
  cCtrl("CMD_DOCUMENT_TAKE_FOR_NK").Enabled = isGrMem And (Obj.StatusName = "STATUS_DOCUMENT_IS_SENT_TO_NK")
  If cCtrl.Has("BTN_UnLoad") Then cCtrl("BTN_UnLoad").Enabled = canViewFiles And isExec
End Sub

Sub FormRefresh(Form, Obj)
  ThisApplication.DebugPrint "FormRefresh "&time()
  If Obj Is Nothing Then Exit Sub
    Set cCtrl = Form.Controls
 '   cCtrl("ATTR_OBJECT").Value = ThisObject.Description
 '   cCtrl("ATTR_NK_RESULTS_TBL").Value = Obj.Attributes("ATTR_NK_RESULTS_TBL").Value
  '  cCtrl("ATTR_NK_NOTES_ALL").Value = Obj.Attributes("ATTR_NK_NOTES_ALL").Value
    cCtrl("EDIT_ATTR_NK_NOTES_ALL").Value = Obj.Attributes("ATTR_NK_NOTES_ALL").Value
    
  '  cCtrl("ATTR_NK_NOTES_FOR_CORRECT").Value = Obj.Attributes("ATTR_NK_NOTES_FOR_CORRECT").Value
    cCtrl("EDIT_ATTR_NK_NOTES_FOR_CORRECT").Value = Obj.Attributes("ATTR_NK_NOTES_FOR_CORRECT").Value
End Sub

Function isCanAprove(Obj)
  ThisApplication.DebugPrint "isCanAprove "&time()
  isCanAprove = False
  sName = Obj.StatusName
  If (sName <> "STATUS_DOCUMENT_IS_TAKEN_NK" And _
      sName <> "STATUS_VOLUME_IS_TAKEN_NK" And _
        sName <> "STATUS_WORK_DOCS_SET_IS_TAKEN_NK") Then Exit Function
  Set oNKObj = GetNKObj(Obj)
  If oNKObj Is Nothing Then Exit Function
    if oNKObj.StatusName = "STATUS_NK" then _
      isCanAprove = true
End Function

' Добавляет замечание
Sub CMD_ADD_REMARK_OnClick()
  ThisApplication.DebugPrint "CMD_ADD_REMARK_OnClick "&time()
  Call AddComment()
  Call SetControlsEnabled(ThisForm,ThisObject)
'  ThisForm.Refresh
End Sub

' Редактирует замечание
Sub CMD_EDIT_REMARK_OnClick()
  ThisApplication.DebugPrint "CMD_EDIT_REMARK_OnClick "&time()
  Call EditComment()
End Sub

' Помечает замечание как исправленное
Sub CMD_CLOSE_REMARK_OnClick()
  ThisApplication.DebugPrint "CMD_CLOSE_REMARK_OnClick "&time()
  Call CloseComment()
End Sub

' Помечает все замечания как исправленное
Sub CMD_CLOSE_ALLREMARK_OnClick()
  ThisApplication.DebugPrint "CMD_CLOSE_ALLREMARK_OnClick "&time()
  Call CloseALLComment()
End Sub

' Удаляет замечание
Sub CMD_DEL_REMARK_OnClick()
  ThisApplication.DebugPrint "CMD_DEL_REMARK_OnClick "&time()
  Call DelComment()
End Sub

Sub AddComment()
  ThisApplication.DebugPrint "AddComment "&time()
  Set oNKObj = GetNKObj(ThisObject)
  If oNKObj Is Nothing Then Exit Sub
  ThisScript.SysAdminModeOn
  Set Table = oNKObj.Attributes("ATTR_NK_RESULTS_TBL")
  Set Rows = Table.Rows
  Set vForm = ThisApplication.InputForms("FORM_NK_REMARK")
  
  vForm.Attributes("ATTR_OBJECT").Value = oNKObj.Attributes("ATTR_OBJECT").Object
  vForm.Attributes("ATTR_USER").Value = ThisApplication.CurrentUser
  vForm.Attributes("ATTR_DATA").Value = ThisApplication.CurrentTime
  
  If vForm.Show Then 
    Set NewRow = Rows.Create
    NewRow.Attributes("ATTR_NK_VERSION") = oNKObj.Attributes("ATTR_NK_VERSION")
    Call RowUpdate (vForm,NewRow)
  End If
  
  Call GetTotalEr(ThisObject)
  Call GetOpenEr(ThisObject)
End Sub

'=============================================
sub EditComment()
  ThisApplication.DebugPrint "EditComment "&time()
  ThisScript.SysAdminModeOn
  Set oNKObj = GetNKObj(ThisObject)
  if oNKObj is nothing then exit sub

  Set control = thisForm.Controls("QUERY_NK_ISSUES")
  iSel = control.ActiveX.SelectedItem
  If iSel < 0 Then 
     msgbox "Не выбрано замечание!"
     Exit Sub 
  end if  

  Arr = thisapplication.Utility.ArrayToVariant(control.SelectedItems)
  If Ubound(Arr) = -1 Then Exit Sub
  Set Row = control.Value.RowValue(Arr(0))
    
  Set vForm = ThisApplication.InputForms("FORM_NK_REMARK")
    vForm.Attributes("ATTR_NK_RESULTS_CODE").Classifier = row.Attributes("ATTR_NK_RESULTS_CODE").Classifier
    vForm.Attributes("ATTR_NK_RESULTS_DESC") = row.Attributes("ATTR_NK_RESULTS_DESC").Value 
    vForm.Attributes("ATTR_NK_RESULTS_QUANTITY").Value = row.Attributes("ATTR_NK_RESULTS_QUANTITY").Value
    vForm.Attributes("ATTR_NK_RESULTS_CRITICAL").Value = row.Attributes("ATTR_NK_RESULTS_CRITICAL").Value 
    vForm.Attributes("ATTR_NK_RESULTS_CORRECTED").Value = row.Attributes("ATTR_NK_RESULTS_CORRECTED").Value
    vForm.Attributes("ATTR_DATA") = row.Attributes("ATTR_DATA").Value
    vForm.Attributes("ATTR_USER") = row.Attributes("ATTR_USER").Value
    vForm.Attributes("ATTR_OBJECT").Object = oNKObj.Attributes("ATTR_OBJECT").Object
'    cCtrl("ATTR_OBJECT") = Obj.Attributes("ATTR_OBJECT").Object
  
  If Not IsUserComment (Row) Then
    For Each c In vForm.Controls
        c.ReadOnly = True
    Next
  End If
  
  If vForm.Show Then 
    Call RowUpdate (vForm,row)
  End If
  oNKObj.Update
  Call GetTotalEr(ThisObject)
  Call GetOpenEr(ThisObject)
end sub

Sub DelComment()
  count = 0
  Set oNKObj = GetNKObj(ThisObject)
  if oNKObj is nothing then exit sub

  Set control = thisForm.Controls("QUERY_NK_ISSUES")
  iSel = control.ActiveX.SelectedItem
  If iSel < 0 Then 
     msgbox "Не выбрано замечание!"
     Exit Sub 
  end if  

  Arr = thisapplication.Utility.ArrayToVariant(control.SelectedItems)
  If Ubound(Arr) = -1 Then Exit Sub
  If Ubound(Arr) > 0 Then
    txt = "(" & Ubound(Arr) + 1 & ")"
    Mes = 1063
  Else
    txt = ""
    Mes = 1062
  End If
  Answer = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, Mes, txt)
  
  if Answer <> vbYes then exit sub

  for i = 0 to Ubound(Arr)
     set aprRow =  control.value.RowValue(Arr(i))
     if DellRow(oNKObj, aprRow) then count = count + 1
  next
  if count>0 then 
       msgbox "Удалено " & count & " замечаний"
  end if
  Call GetTotalEr(ThisObject)
  Call GetOpenEr(ThisObject)
End Sub

function DellRow(NKObj,row)
  ThisApplication.DebugPrint "DellRow "&time()
  thisScript.SysAdminModeOn
  DellRow = false
  set row = NKObj.Attributes("ATTR_NK_RESULTS_TBL").Rows(row)
  ver = row.Attributes("ATTR_NK_VERSION").value
  isClosed = row.Attributes("ATTR_NK_RESULTS_CORRECTED").Value
  if  ver <> NKObj.Attributes("ATTR_NK_VERSION").value then 
      msgbox "Невозможно удалить замечание из предыдущих циклов нормоконтроля", vbCritical, "Удаление отменено"
      exit function
  end if 
  if NKObj.statusName = "STATUS_NK" then ' если на согласовании, то только то, что добавил сам
    set addUser = row.Attributes("ATTR_USER").User
    if addUser is nothing then 
       msgbox "Невозможно удалить, т.к замечание добавлено не Вами!"
       Exit function 
    end if 
    if addUser.SysName <> thisApplication.CurrentUser.SysName then 
       msgbox "Невозможно удалить, т.к замечание добавлено не Вами!"
       Exit function 
    end if 
  end if
  If  isClosed then 
      msgbox "Невозможно удалить закрытое замечание", vbCritical, "Удаление отменено"
      exit function
  end if 

  NKObj.Permissions = sysAdminPermissions
  row.Erase
  NKObj.update
  DellRow = true
end function

Sub CloseComment()
  ThisApplication.DebugPrint "CloseComment "&time()
  ThisScript.SysAdminModeOn
  Set oNKObj = GetNKObj(ThisObject)
  if oNKObj is nothing then exit sub

  Set control = thisForm.Controls("QUERY_NK_ISSUES")
  iSel = control.ActiveX.SelectedItem
  If iSel < 0 Then 
     msgbox "Не выбрано замечание!"
     Exit Sub 
  end if  

  Arr = thisapplication.Utility.ArrayToVariant(control.SelectedItems)
  If Ubound(Arr) = -1 Then Exit Sub
  Set Row = control.Value.RowValue(Arr(0))
  If Not IsUserComment(Row) Then Exit Sub
   
    ' Подтверждение
    result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion+vbYesNo, 1060)    
    If result <> vbYes Then
      Exit Sub
    End If 
  
  Row.Attributes("ATTR_NK_RESULTS_CORRECTED") = True
  oNKObj.Update
  Call GetTotalEr(ThisObject)
  Call GetOpenEr(ThisObject)
end sub

Sub ATTR_NK_RESULTS_TBL_SelChanged()
  ThisApplication.DebugPrint "ATTR_NK_RESULTS_TBL_SelChanged "&time()
  ThisForm.Controls("CMD_DEL_REMARK").Enabled = CheckObj4
  ThisForm.Controls("CMD_CLOSE_REMARK").Enabled = CheckObj4  
    AttrName = "ATTR_NK_RESULTS_TBL"
    Set Form = ThisForm
    if not Form.Attributes.Has(AttrName) then exit sub
    set Table = Form.Controls(AttrName)
    Arr = Table.ActiveX.SelectedRows
    'ThisForm.Controls("CMD_EDIT_REMARK").Enabled = ((Not (Ubound (Arr) >0)) And CheckObj4)
    ThisForm.Controls("CMD_EDIT_REMARK").Enabled = ((Not (Ubound (Arr) >0)))
End Sub

'Функция проверки формы на удаление отдела-адресата
Function CheckObj4()
  ThisApplication.DebugPrint "CheckObj4 "&time()
  CheckObj4 = False
  Set CU = ThisApplication.CurrentUser
  IsGroupMem = IsGroupMember(CU,"GROUP_NK")
  
  If Not IsGroupMem Then Exit Function
  Set Roles = ThisObject.RolesForUser(CU)
  Set Table = ThisForm.Controls("ATTR_NK_RESULTS_TBL")
  If Table.SelectedObjects.Count <> 0 Then
    If (ThisObject.StatusName = "STATUS_DOCUMENT_IS_TAKEN_NK" Or _
        ThisObject.StatusName = "STATUS_WORK_DOCS_SET_IS_TAKEN_NK" or _
        ThisObject.StatusName = "STATUS_VOLUME_IS_TAKEN_NK") Then
   '   If Roles.Has("ROLE_VOLUME_PASS_NK") or Roles.Has("ROLE_WORK_DOCS_SET_PASS_NK") Then
        CheckObj4 = True
    '  End If
    End If
  End If
End Function

'Функция проверки доступности кнопок перед отображением формы
Function SetButtonEnable()
  ThisApplication.DebugPrint "SetButtonEnable "&time()
  SetButtonEnable = False
  Set CU = ThisApplication.CurrentUser
  IsGroupMem = IsGroupMember(CU,"GROUP_NK")
  
  If Not IsGroupMem Then Exit Function
  Set Roles = ThisObject.RolesForUser(CU)
  Set Table = ThisForm.Controls("ATTR_NK_RESULTS_TBL")
  
  If (ThisObject.StatusName = "STATUS_DOCUMENT_IS_TAKEN_NK" Or _
      ThisObject.StatusName = "STATUS_WORK_DOCS_SET_IS_TAKEN_NK" or _
      ThisObject.StatusName = "STATUS_VOLUME_IS_TAKEN_NK") Then
'     If Roles.Has("ROLE_VOLUME_PASS_NK") or Roles.Has("ROLE_WORK_DOCS_SET_PASS_NK") Then
       SetButtonEnable = True
'     End If
   End If
End Function

Function GetUserComment (row)
  ThisApplication.DebugPrint "GetUserComment "&time()
  set GetUserComment = nothing
  Set CU = thisApplication.CurrentUser
  If Not row.Attributes("ATTR_USER").User.Sysname = CU.SysName Then
   ''msgbox "Вы не можете редактировать замечание другого пользователя."
    'Exit Function
  End If
  set GetUserComment = row
end function

Function IsUserComment (row)
  ThisApplication.DebugPrint "IsUserComment "&time()
  IsUserComment = False
  Set CU = thisApplication.CurrentUser
  If row.Attributes("ATTR_USER").User Is Nothing Then 
    row.Attributes("ATTR_USER").User = CU
  End If
  If Not row.Attributes("ATTR_USER").User.Sysname = CU.SysName Then
    Exit Function
  End If
  IsUserComment = True
End Function

Sub RowUpdate (form,row)
  ThisApplication.DebugPrint "RowUpdate "&time()
  For each attr In row.Attributes
    If form.Attributes.Has(attr.AttributeDefName) Then 
      Select Case attr.AttributeDef.Type
        Case 8
          row.Attributes(attr.AttributeDefName).Classifier = form.Attributes(attr.AttributeDefName).Classifier
        Case 9
          row.Attributes(attr.AttributeDefName).User = form.Attributes(attr.AttributeDefName).User
        Case Else
          row.Attributes(attr.AttributeDefName).Value = form.Attributes(attr.AttributeDefName).Value   
      End Select
    End If
  Next
End Sub

Sub CloseALLComment()
  ThisApplication.DebugPrint "CloseALLComment "&time()
    ' Подтверждение
    result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion+vbYesNo, 1061)    
    If result <> vbYes Then
      Exit Sub
    End If 
    Set oNKObj = GetNKObj(ThisObject)
  Call ThisApplication.ExecuteScript("OBJECT_NK","CloseALLComments",oNKObj)
End Sub


' Подсчет числа ошибок по таблице
Sub GetTotalEr(Obj)
  ThisApplication.DebugPrint "GetTotalEr "&time()
  count = 0
  ThisScript.SysAdminModeOn
  Set oNKObj = GetNKObj(Obj)
  if oNKObj is nothing then exit sub
  
  Set Table = oNKObj.Attributes("ATTR_NK_RESULTS_TBL")
  
  For each row in table.rows
    count = count + row.attributes("ATTR_NK_RESULTS_QUANTITY")
  Next
  oNKObj.Attributes("ATTR_NK_NOTES_ALL") = count
  oNKObj.Update
  Call FormRefresh(ThisForm, oNKObj)
End Sub

' Подсчет числа не закрытых ошибок по таблице
Sub GetOpenEr(Obj)
  ThisApplication.DebugPrint "GetOpenEr "&time()
  count = 0
  ThisScript.SysAdminModeOn
  Set oNKObj = GetNKObj(Obj)
  if oNKObj is nothing then exit sub
  
  Set table = oNKObj.Attributes("ATTR_NK_RESULTS_TBL")
  
  For each row in table.rows
    If row.attributes("ATTR_NK_RESULTS_CORRECTED") = False Then
      count = count + row.attributes("ATTR_NK_RESULTS_QUANTITY")
    End If
  Next
  oNKObj.attributes("ATTR_NK_NOTES_FOR_CORRECT") = count
  oNKObj.Update
  Call FormRefresh(ThisForm, oNKObj)
End Sub

Sub BTN_NK_APPROVE_OnClick()
  ThisApplication.DebugPrint "BTN_NK_APPROVE_OnClick "&time()
  Call NKApprove(ThisObject)
End Sub

Sub NKApprove(Obj)
  ThisApplication.DebugPrint "NKApprove "&time()
  Res = ThisApplication.ExecuteScript("CMD_APPROVE_NK","Main",Obj)
  Set oNKObj = GetNKObj(Obj)
'  Call ThisApplication.ExecuteScript("OBJECT_NK","CloseALLComments",oNKObj)
  Call ThisApplication.ExecuteScript("OBJECT_NK","CloseNK",oNKObj)
  
  If Res Then
    Obj.SaveChanges
    ThisForm.Close True
  End If
End Sub

Sub BTN_NK_REJECT_OnClick()
  ThisApplication.DebugPrint "BTN_NK_REJECT_OnClick "&time()
  Call NKREJECT(ThisObject)
End Sub

Sub NKREJECT(Obj)
  ThisApplication.DebugPrint "NKREJECT "&time()
  Set oNKObj = GetNKObj(Obj)
  If Not oNKObj is nothing then 
    oNKObj.permissions = SysAdminPermissions
    oNKObj.Attributes("ATTR_NK_VERSION").value = oNKObj.Attributes("ATTR_NK_VERSION").value +1
    
    oNKObj.Status = ThisApplication.Statuses("STATUS_NK_DRAFT")
    oNKObj.Versions.Create "Нормоконтроль не пройден", "Дата отклонения нормоконтроля: " & ThisApplication.CurrentTime
    Res = ThisApplication.ExecuteScript("CMD_VOLUME_BACK_TO_COR", "Run", Obj)
    oNKObj.Update
  End If

  Res = ThisApplication.ExecuteScript ("CMD_DOC_BACK_TO_WORK", "Main", Obj)
  If Res = True Then
    Obj.SaveChanges
    ThisForm.Close True
  End If
End Sub

Sub QUERY_NK_ISSUES_DblClick(iItem, bCancelDefault)
  ThisApplication.DebugPrint "QUERY_NK_ISSUES_DblClick "&time()
  Call CMD_EDIT_REMARK_OnClick()
End Sub

Sub BTN_ADD_FILE_OnClick()
  ThisApplication.DebugPrint "BTN_ADD_FILE_OnClick "&time()
  Call ThisApplication.ExecuteScript("OBJECT_NK","AddFile",ThisObject)
End Sub

Sub QUERY_NK_ISSUES_Selected(iItem, action)
  ThisApplication.DebugPrint "QUERY_NK_ISSUES_Selected1 "&time()
  Dim dst
  Set dst = ThisForm.Controls
  
  Dim qryCtrl, src
  Set qryCtrl = ThisForm.Controls("QUERY_NK_ISSUES").ActiveX

  Dim emptyTable
  On Error Resume Next
  Set src = qryCtrl.ItemObject(iItem).Attributes

  ThisApplication.DebugPrint "QUERY_NK_ISSUES_Selected2 "&time()
  emptyTable = Err.Number <> 0
  On Error GoTo 0
  
  If -1 = iItem Or emptyTable Then
    ClearOrderAttr()
    ThisApplication.DebugPrint "QUERY_NK_ISSUES_Selected3 "&time()
    dst("ATTR_NK_PERSON").Value = "<не задано>"
    Exit Sub
  End If
  Set oNKObj = GetNKObj(ThisObject)
  Call FormRefresh(ThisForm, oNKObj)
  If src("ATTR_USER").Empty Then
'    dst("ATTR_NK_PERSON").Value = "<не задано>"
    dst("EDIT_ATTR_NK_PERSON").Value = ""
  Else
    'dst("ATTR_NK_PERSON").Value = src("ATTR_USER").User.Description
    dst("EDIT_ATTR_NK_PERSON").Value = src("ATTR_USER").User.Description
  End If
  If src("ATTR_DATA").Empty Then
    dst("EDIT_ATTR_NK_DATE").Value = "--.--.----"
  Else
'    dst("ATTR_NK_DATE").Value = src("ATTR_DATA").Value
    dst("EDIT_ATTR_NK_DATE").Value = src("ATTR_DATA").Value
  End If
  If src("ATTR_NK_RESULTS_QUANTITY").Empty Then
    dst("EDIT_ATTR_NK_RESULTS_QUANTITY").Value = "--"
  Else
'    dst("ATTR_NK_RESULTS_QUANTITY").Value = src("ATTR_NK_RESULTS_QUANTITY").Value
    dst("EDIT_ATTR_NK_RESULTS_QUANTITY").Value = src("ATTR_NK_RESULTS_QUANTITY").Value
  End If
    'dst("ATTR_NK_RESULTS_CRITICAL").Value = CBool(src("ATTR_NK_RESULTS_CRITICAL").Value)
    'dst("ATTR_NK_RESULTS_CORRECTED").Value = CBool(src("ATTR_NK_RESULTS_CORRECTED").Value)
  
  
  SetChBox(src)
  
  
  If src("ATTR_NK_RESULTS_CODE").Empty Then
 '  dst("ATTR_NK_RESULTS_CODE").Value = "<не задано>"
    dst("EDIT_ATTR_NK_RESULTS_CODE").value = ""'"<не задано>"
  Else
  '  dst("ATTR_NK_RESULTS_CODE").Value = src("ATTR_NK_RESULTS_CODE").Value
    dst("EDIT_ATTR_NK_RESULTS_CODE").value = src("ATTR_NK_RESULTS_CODE").Value'Classifier.code
  End If
  If src("ATTR_NK_RESULTS_DESC").Empty Then
'    dst("ATTR_NK_RESULTS_DESC").Value = "<не задано>"
     dst("EDIT_ATTR_NK_RESULTS_DESC").Value = ""
  Else
'    dst("ATTR_NK_RESULTS_DESC").Value = src("ATTR_NK_RESULTS_DESC").Value
    dst("EDIT_ATTR_NK_RESULTS_DESC").Value = src("ATTR_NK_RESULTS_DESC").Value
  End If
End Sub

Sub CMD_DOCUMENT_TAKE_FOR_NK_OnClick()
  ThisApplication.DebugPrint "CMD_DOCUMENT_TAKE_FOR_NK_OnClick "&time()
  Call ThisApplication.ExecuteScript ("CMD_DOCUMENT_TAKE_FOR_NK", "Main", ThisObject)
End Sub


sub SetOrderAttr(order)
  ThisApplication.DebugPrint "SetOrderAttr "&time()
  for each contr in thisForm.Controls
    if left(contr.Name,5) = "EDIT_" then
        attrName = mid(contr.Name,6)
        if order.Attributes.Has(attrName) then  
          if contr.Type = "ACTIVEX" then 
            contr.ActiveX.value = order.Attributes(attrName).value
          else
             contr.Value = order.Attributes(attrName).value
          end if
        else
          contr.value = ""  
        end if
    end if 
  next 
  thisForm.Controls("ATTR_KD_HIST_NOTE").Value = order.Attributes("ATTR_KD_HIST_NOTE").value
  thisForm.Controls("ATTR_KD_TEXT").Value = order.Attributes("ATTR_KD_TEXT").value
  
end sub

sub ClearOrderAttr()
  ThisApplication.DebugPrint "ClearOrderAttr "&time()
  Set oNKObj = GetNKObj(ThisObject)
  for each contr in thisForm.Controls
    if left(contr.Name,5) = "EDIT_" then contr.value = ""  
  next 
  
  Call FormRefresh(thisForm, oNKObj)
end sub

sub SetChBox(src)
  ThisApplication.DebugPrint "SetChBox "&time()
  set chk = thisForm.Controls("EDIT_ATTR_NK_RESULTS_CRITICAL").ActiveX
  chk.buttontype = 4
  Chk.value = CBool(src("ATTR_NK_RESULTS_CRITICAL").Value)
  
  set chk = thisForm.Controls("EDIT_ATTR_NK_RESULTS_CORRECTED").ActiveX
  chk.buttontype = 4
  Chk.value = CBool(src("ATTR_NK_RESULTS_CORRECTED").Value)
end sub

Sub QUERY_FILES_IN_DOC_Selected(iItem, action)
  ThisApplication.DebugPrint "QUERY_FILES_IN_DOC_Selected "&time()
  Call ShowFile(iItem)
End Sub

Sub BTN_UnLoad_OnClick()
  ThisApplication.DebugPrint "BTN_UnLoad_OnClick "&time()
  Call UnloadFilesFromDoc (ThisObject,ThisForm)
End Sub


Sub QUERY_FILES_IN_DOC_DblClick(iItem, bCancelDefault)
  ThisApplication.DebugPrint "QUERY_FILES_IN_DOC_DblClick "&time()
  Call ThisApplication.ExecuteScript("CMD_PROJECT_DOCS_LIBRARY","BlockFilesOpenFile",ThisForm,ThisObject,True)
  bCancelDefault = True
End Sub
