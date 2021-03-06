'USE "CMD_KD_LIB_DOC_IN"
'use CMD_KD_COMMON_LIB
use CMD_KD_COMMON_BUTTON_LIB 
'use CMD_KD_GLOBAL_VAR_LIB  
'use CMD_MARK_LIB
use CMD_KD_MEMO_LIB
use CMD_KD_ORDER_LIB
use CMD_KD_CURUSER_LIB
'use CMD_KD_REGNO_KIB
'=============================================
Sub Form_BeforeShow(Form, Obj) 
'  on error resume next    
'  thisapplication.AddNotify CStr(Timer()) & " form.Description"
  call RemoveGlobalVarrible("AgreeObj")
  call RemoveGlobalVarrible("Settings") ' EV чтобы наверняка новое значение

    form.Caption = form.Description
'    thisapplication.AddNotify CStr(Timer()) & " SetChBox"
    SetChBox()
'    thisapplication.AddNotify CStr(Timer()) & " ShowKTNo"
    ShowKTNo()
'    thisapplication.AddNotify CStr(Timer()) & " CreateTree"
  if Obj.StatusName <> "STATUS_KD_DRAFT" then _
    CreateTree(nothing)  
'    thisapplication.AddNotify CStr(Timer()) & " ShowSysID"
    ShowSysID()
'    thisapplication.AddNotify CStr(Timer()) & " ShowBtnIcon"
    ShowBtnIcon()
'    thisapplication.AddNotify CStr(Timer()) & " SetFieldAutoComp"
    SetFieldAutoComp()
'    thisapplication.AddNotify CStr(Timer()) & " EnabledCtrl"
    EnabledCtrl() 
  'EV 2018-01-31 показываем файлы только если не стоит галка показывать по кнопке
    if thisApplication.CurrentUser.Attributes.Has("ATTR_SHOW_FILE_BY_BUTTON") then _
      if thisApplication.CurrentUser.Attributes("ATTR_SHOW_FILE_BY_BUTTON").Value <> true then _
          ShowFile(0)'(-1)'(0)
    SetShowOldFailFlag()
      
'    thisapplication.AddNotify CStr(Timer()) & " end"
  if err.Number <> 0 then   msgbox err.Description, vbCritical
  on error goto 0  
End Sub
'=============================================
Function EnabledCtrl()
  set curUser = GetCurUser()
  isAproving = thisObject.StatusName = "STATUS_KD_AGREEMENT"
  isExec = IsExecutor(curUser, thisObject)
  isContr = IsController(curUser, thisObject)
'  isSecr = isSecretary(curUser)
  isApper = IsApprover(curUser, thisObject)
  isCanEd = isCanEdit()

  docStat = ThisObject.StatusName
  isSec = isSecretary(ThisApplication.CurrentUser)
  
  thisform.Controls("ATTR_KD_EXEC").ReadOnly = not isSec
  thisform.Controls("ATTR_KD_CHIEF").ReadOnly = not docStat = "STATUS_KD_DRAFT"
  
  thisform.Controls("BTN_SEND_TO_CHECK").Enabled = isExec and docStat = "STATUS_KD_DRAFT" and not (isExec and isContr)
  thisform.Controls("BTN_SEND_TO_CHECK").visible = thisform.Controls("BTN_SEND_TO_CHECK").Enabled 
  thisform.Controls("BTN_REG").Enabled =  isContr and (docStat = "STATUS_KD_DRAFT" or docStat = "STATUS_SIGNING")
  thisform.Controls("BTN_REG").visible = thisform.Controls("BTN_REG").Enabled 
  thisform.Controls("BTN_ADD_SCAN").Enabled = isCanEd or ((isSec or isApper) and docStat = "STATUS_KD_APPROVED")
  thisform.Controls("BTN_RETURN").Enabled = ((isExec or isContr) and ( docStat = "STATUS_SIGNING" or not isCanEd) ) _ 
      or (((isSec or isApper) and docStat = "STATUS_KD_APPROVAL"))
  thisform.Controls("BTN_CANCEL_DOC").Enabled = ((isExec or isContr) and isCanEd) _ 
      or (((isSec or isApper) and docStat = "STATUS_KD_APPROVAL"))
  thisform.Controls("BTN_SING_DOC").Enabled = ((isSec or isApper) and docStat = "STATUS_KD_APPROVAL")

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
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = cOrder
    ans = CreateObjDlg.Show
    CreateTree(cOrder)
End Sub

'=============================================
'sub CreateChild(ax_Tee, parObj,chiObj,curOrder)
'  set user = chiObj.Attributes("ATTR_KD_OP_DELIVERY").user
'  if user is nothing then exit sub
'  txt = thisApplication.ExecuteScript("OBJECT_KD_DOC_OUT", "GetUserFIO", user) & " | к "
'  toDate = chiObj.Attributes("ATTR_KD_POR_PLANDATE").value
'  if trim(toDate) = "" then 
'    toDate = "..."
'  else
'    toDate = left(toDate, 5)
'  end if
'  txt = txt & toDate & " | " & chiObj.Attributes("ATTR_KD_TEXT").value
'  ch = ax_Tee.InsertItem(txt,parObj,0)  
'  call ax_Tee.SetItemData(ch,chiObj)
'  call ax_Tee.SetItemIcon(ch, chiObj.Icon)
'  for each order in chiObj.Content
'    call CreateChild(ax_Tee,ch,order,curOrder)
'  next
'  if not curOrder is nothing then 
'    if curOrder.handle = chiObj.handle then 
'      chiNo = ch
'      ax_Tee.SelectedItem = ch
'    end if
'  end if
'  ax_Tee.Expand(ch)
'end sub

'=============================================
Sub BTN_REG_OnClick()
    'проверка на заполнение полей
  thisObject.saveChanges 0
  txt = ThisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "CheckMemo", thisObject)
  if txt > ""  then 
    ans = msgbox( "Не все обязательные поля заполнены :" & vbNewLine & txt & vbNewLine , _
       vbcritical, "Невозможно зарегистрировать документ")
    exit sub    
  end if 

  if Reg_Memo(thisObject) then   
    call Sing_Memo()
  end if  
'  thisForm.Refresh
  '      Send_to_Aprove()
End Sub

'=============================================
Sub BTN_ADD_FILE_OnClick()
    Add_application()
    'call thisApplication.ExecuteScript("CMD_KD_LIB_DOC_IN","AddFilesToDoc","")
End Sub

'=============================================
Sub BTN_ADD_SCAN_OnClick()
  if thisObject.StatusName = "STATUS_KD_DRAFT" or thisObject.StatusName = "STATUS_SIGNING" or thisObject.StatusName ="STATUS_SIGNED" then 
    LoadFileToDoc("FILE_KD_SCAN_DOC")
  else 
    if isSecretary(GetCurUser()) then 
      LoadFileToDoc("FILE_KD_RESOLUTION")
    end if
  end if  
'  Set_Doc_Ready(thisObject)
End Sub
'=============================================
Sub BTN_CREATE_WORD_OnClick()  
  thisObject.saveChanges 0
  txt = ThisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "CheckMemoField", thisObject)
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
Sub BTN_SEND_TO_CHECK_OnClick()
  send_Memo_to_Check()
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
'  call thisApplication.ExecuteScript("FORM_KD_DOC_AGREE","Set_Doc_Signed", thisObject)
'  if not isSecretary(GetCurUser()) then  thisForm.Close false

    if isSecretary(GetCurUser()) then
      msgBox "Приложите резолюцию", vbInformation
      LoadFileToDoc("FILE_KD_RESOLUTION")
    end if
    set res = GetFileByType("FILE_KD_RESOLUTION")
    thisObject.Status = ThisApplication.Statuses("STATUS_KD_APPROVED")  
    thisObject.Update

    msgbox "Документ утвержден"
End Sub

Sub BTN_PRINT_ARGEE_OnClick()
    set agreeObj =  thisApplication.ExecuteScript("FORM_KD_AGREE", "GetAgreeObjByObj",thisObject)
    if agreeObj is nothing then exit sub
    set file = agreeObj.Files.Main
    if File is nothing then exit sub
    file.CheckOut file.WorkFileName ' извлекаем

    Set objShellApp = CreateObject("Shell.Application") 'открываем
    objShellApp.ShellExecute "explorer.exe", file.WorkFileName, "", "", 1
    Set objShellApp = Nothing  

End Sub
