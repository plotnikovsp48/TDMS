'USE "CMD_KD_LIB_DOC_IN"
'use CMD_KD_COMMON_LIB
use CMD_KD_COMMON_BUTTON_LIB 
'use CMD_KD_GLOBAL_VAR_LIB  
'use CMD_MARK_LIB
'use CMD_KD_MEMO_LIB
use CMD_KD_ORDER_LIB
use CMD_KD_CURUSER_LIB
use CMD_KD_AP_LIB
'use CMD_KD_REGNO_KIB
'=============================================
Sub Form_BeforeShow(Form, Obj) 
'  on error resume next    
'  thisapplication.AddNotify CStr(Timer()) & " form.Description"
    form.Caption = form.Description
'    thisapplication.AddNotify CStr(Timer()) & " SetChBox"
    SetChBox()
'    thisapplication.AddNotify CStr(Timer()) & " ShowKTNo"
    ShowKTNo()
'    thisapplication.AddNotify CStr(Timer()) & " CreateTree"
    CreateTree(nothing)  
'    thisapplication.AddNotify CStr(Timer()) & " ShowSysID"
    ShowSysID()
'    thisapplication.AddNotify CStr(Timer()) & " ShowBtnIcon"
    ShowBtnIcon()
'    thisapplication.AddNotify CStr(Timer()) & " SetFieldAutoComp"
    SetFieldAutoComp()
'    thisapplication.AddNotify CStr(Timer()) & " EnabledCtrl"
    EnabledCtrl()    
'    thisapplication.AddNotify CStr(Timer()) & " end"
    'EV 2018-01-31 показываем файлы только если не стоит галка показывать по кнопке
    if thisApplication.CurrentUser.Attributes.Has("ATTR_SHOW_FILE_BY_BUTTON") then _
      if thisApplication.CurrentUser.Attributes("ATTR_SHOW_FILE_BY_BUTTON").Value <> true then _
          ShowFile(0)'(-1)'(0)
  SetShowOldFailFlag()

  if err.Number <> 0 then   msgbox err.Description, vbCritical
  call  SetGlobalVarrible("ShowForm", "FORM_AP_CARD")  
  on error goto 0  
End Sub
'=============================================
Function EnabledCtrl()
  set curUs = GetCurUser() 
  isAproving = thisObject.StatusName = "STATUS_KD_AGREEMENT"
  isExec = IsExecutor(curUs, thisObject)
  isContr = IsController(curUs, thisObject)
  isSecr = isSecretary(curUs)
  isApper = IsSigner(curUs, thisObject)
  isCanEd = isCanEdit()

  docStat = ThisObject.StatusName
'  isSec = isSecretary(ThisApplication.CurrentUser)
  
  thisform.Controls("ATTR_KD_EXEC").ReadOnly = not isSec
  
  thisform.Controls("BTN_RETURN").Enabled = ((isExec or isContr) and ( docStat = "STATUS_SIGNING" or not isCanEd) ) _ 
      or (((isSec or isApper) and docStat = "STATUS_KD_APPROVAL"))
  thisform.Controls("BTN_CANCEL_DOC").Enabled = ((isExec or isContr) and isCanEd) _ 
      or (((isSec or isApper) and docStat = "STATUS_KD_APPROVAL"))
  thisform.Controls("BTN_SING_DOC").Enabled = ((isSec or isApper) and docStat = "STATUS_SIGNING")
      
  thisForm.Controls("BTN_ADD_FILE").Enabled = CanAddFile()
  thisForm.Controls("BTN_DEL_FILE").Enabled = CanAddFile()
End Function

'=============================================
sub CreateTree(curOrder)
     set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX  
     if ax_Tee is nothing then exit sub
     ax_Tee.DeleteAllItems
'     ax_Tee.Font.Bold = true
     ax_Tee.Font.Size = 10
     if curOrder is nothing then set curOrder = GetCurUserRealOrder()'thisApplication.GetObjectByGUID("{CD59008D-BB2D-4B0D-ADFE-E6EC6D447B3F}")  
     set query = thisApplication.Queries("QUERY_KD_FIRST_ORDER")
     query.Parameter("PARAM0") = thisObject.Handle
     set objs = query.Objects
     for each order in objs
        call CreateChild(ax_Tee,0,order, curOrder)
     next
end sub
'=============================================
Sub TDMSTREEOrder_DblClick(hItem,bCancelDefault)
    set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX 
    if ax_Tee is nothing then exit sub
    set cOrder = ax_Tee.GetItemData(hItem)
    if cOrder is nothing then exit sub
    fName = thisForm.SysName
    call  RemoveGlobalVarrible("ShowForm")
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = cOrder
    ans = CreateObjDlg.Show
    CreateTree(cOrder)
    call  SetGlobalVarrible("ShowForm", fName)  

End Sub

'=============================================
Sub BTN_ADD_FILE_OnClick()
    Add_application()
End Sub

'=============================================
Sub BTN_CREATE_WORD_OnClick()  
  thisObject.saveChanges 0
  txt = ThisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "checkPayment", thisObject)
  if txt > ""  then 
    ans = msgbox( "Не все обязательные поля заполнены :" & vbNewLine & txt & vbNewLine & _
        "Хотите создать документ в любом случае?" & vbNewLine & "Нажмите Да, чтобы создавть документ," & _
        " нажмите Нет, чтобы продолжить редактирование", _
        VbYesNo + vbExclamation, "создать документ?")
    if ans = vbNo then exit sub    
  end if 
  ans = createWord()
End Sub
'=============================================
Sub BTN_DEL_FILE_OnClick()
   DelFilesFromDoc()
   ThisObject.SaveChanges()
End Sub
'=============================================
Sub BTN_RETURN_OnClick()
    return_To_Work()
End Sub
'=============================================
Sub BTN_CANCEL_DOC_OnClick()
  call set_Doc_Cancel()
End Sub
'=============================================
Sub BTN_SING_DOC_OnClick()
    thisScript.SysAdminModeOn
    thisObject.Permissions = sysAdminPermissions
    thisObject.Status = ThisApplication.Statuses("STATUS_SIGNED")  
    thisObject.saveChanges()
    thisObject.Update
    thisForm.Refresh
'    msgbox "Документ подписан"
    on error resume next
    Call thisApplication.ExecuteScript(thisObject.ObjectDefName,"AfterSinging", thisObject)
    if err.Number <>0 then err.clear
    on error goto 0 
End Sub

