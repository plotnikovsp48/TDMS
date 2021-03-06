use CMD_KD_GLOBAL_VAR_LIB 
use CMD_KD_TEMPL_LIB

'=============================================
Sub QUERY_ORDER_TEMPL_Selected(iItem, action)
  if iItem = -1 then exit sub
  Set Query = ThisForm.Controls("QUERY_ORDER_TEMPL")
  Set templ = Query.Value.RowValue(iItem)
  hndl = GetGlobalVarrible("templ")
  if hndl = templ.handle then exit sub

  call SetGlobalVarrible("templ", templ.handle)
  
  thisForm.Controls("BTN_DEL").Enabled = fCanDel(templ)
  thisForm.Refresh
End Sub
'=============================================
Sub BTN_CREATE_OnClick()
  set fld = GetTmplFolder()
  if fld is nothing then exit sub
  thisScript.SysAdminModeOn
  fld.Permissions = sysAdminPermissions
  set newObj = fld.Objects.Create("OBJECT_KD_ORDER_TEMPLATE")
  
   Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
   CreateObjDlg.Object = newObj
   ans = CreateObjDlg.Show
  
   If not ans then
     newObj.Erase  ' EV все-таки подумать как удалять
     exit sub
   End if
End Sub
'=============================================
Sub BTN_COPY_OnClick()
  set templ = nothing
  Set Query = ThisForm.Controls("QUERY_ORDER_TEMPL")
  if Query.SelectedObjects.Count = 0 then 
    msgbox "Не выбран ни один шаблон", vbCritical, "Ошибка"
    exit sub
  end if
  if Query.SelectedObjects.Count > 1 then 
    msgbox "Для копирования можно выделять только один шаблон", vbCritical, "Ошибка"
    exit sub
  end if
  
  Set templ = Query.selectedObjects(0)
  if templ is nothing then exit sub
  
  set fld = GetTmplFolder()
  if fld is nothing then exit sub
  thisScript.SysAdminModeOn
  fld.Permissions = sysAdminPermissions
  set newObj = templ.Duplicate(fld)
  
   Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
   CreateObjDlg.Object = newObj
   ans = CreateObjDlg.Show
  
   If not ans then
     newObj.Erase  ' EV все-таки подумать как удалять
     exit sub
   End if
End Sub
'=============================================
Sub BTN_ADD_TO_DOC_OnClick()
  set frm = GetObjectGlobalVarrible("OrderForm")
  if frm is nothing then exit sub
  
  set cnt = thisForm.Controls("QUERY_ORDER_TEMPL")
  if cnt.SelectedObjects.Count = 0 then exit sub
  
  for each tmpl in  cnt.SelectedObjects
    call add_Tmpl_inForm(tmpl, frm)
  next
'  msgbox "Добавление завершено"
  thisForm.Close false

End Sub
'=============================================
Sub Form_BeforeClose(Form, Obj, Cancel)
  call RemoveGlobalVarrible("OrderForm")
End Sub
'=============================================
Sub BTN_DEL_OnClick()
  set templ = nothing
  Set Query = ThisForm.Controls("QUERY_ORDER_TEMPL")
  if Query.SelectedObjects.Count = 0 then 
    msgbox "Не выбран ни один шаблон", vbCritical, "Ошибка"
    exit sub
  end if
  Answer = MsgBox( "Вы уверены, что хотите удалить из списка " & Query.SelectedObjects.Count  _
         & " шаблон(ов)?" , vbQuestion + vbYesNo,"Удалить?")
  if Answer <> vbYes then exit sub

  thisScript.SysAdminModeOn
  for each tmpl in Query.SelectedObjects
      if fCanDel(tmpl) then tmpl.erase
  next
End Sub
