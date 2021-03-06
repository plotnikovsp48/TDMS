'USE "CMD_KD_LIB_DOC_IN"
'use CMD_KD_COMMON_LIB
use CMD_KD_COMMON_BUTTON_LIB 
'use CMD_KD_GLOBAL_VAR_LIB  
'use CMD_MARK_LIB
'use CMD_KD_MEMO_LIB
use CMD_KD_ORDER_LIB
use CMD_KD_CURUSER_LIB
'use CMD_KD_REGNO_KIB
'=============================================
Sub Form_BeforeShow(Form, Obj) 
'  on error resume next    
'  thisapplication.AddNotify  " form.Description - " & CStr(Timer())
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
   'EV 2018-01-31 показываем файлы только если не стоит галка показывать по кнопке
    if thisApplication.CurrentUser.Attributes.Has("ATTR_SHOW_FILE_BY_BUTTON") then _
      if thisApplication.CurrentUser.Attributes("ATTR_SHOW_FILE_BY_BUTTON").Value <> true then _
          ShowFile(0)'(-1)'(0)
    SetShowOldFailFlag()
    call RemoveGlobalVarrible("AgreeObj")
    call RemoveGlobalVarrible("Settings") ' EV чтобы наверняка новое значение
 
'    thisapplication.AddNotify " end - " & CStr(Timer())
  if err.Number <> 0 then   msgbox err.Description, vbCritical
  on error goto 0  
End Sub
'=============================================
Function EnabledCtrl()

  isCanEd = isCanEdit()
  set curUs = GetCurUser() 

  isExec = IsExecutor(curUs, thisObject)
  isSecr = isSecretary(curUs)
  isSign = IsSigner(curUs, thisObject)

  isAproving = thisObject.StatusName = "STATUS_KD_AGREEMENT"
  stSinged = thisObject.StatusName = "STATUS_KD_IN_FORCE"
  stSigning = thisObject.StatusName = "STATUS_SIGNING" 'or  thisObject.StatusName = "STATUS_KD_REGIST"
  stReg = thisObject.StatusName = "STATUS_KD_REGIST"
  set cFile = GetFileByType("FILE_KD_SCAN_DOC")
  hasScan = (not cFile is nothing)

  thisForm.Controls("BTN_SING_DOC").Enabled = (isSecr or isSign) and stSigning
  thisForm.Controls("BTN_REG").Enabled = isSecr and stReg
  thisform.Controls("BTN_REG").visible = thisform.Controls("BTN_REG").Enabled 
  thisForm.Controls("BTN_ADD_SCAN").Enabled = ((isSecr or isSign) and (stSigning or stSinged or stReg)) and not hasScan
  thisForm.Controls("BTN_RETURN").Enabled = ((isSecr or isSign) and (stSigning or stReg)) or (isExec and  not isCanEd)
  thisForm.Controls("BTN_CANCEL_DOC").Enabled = (isSecr or isSign) and (stSigning or stReg)
  thisForm.Controls("BTN_CANC").Enabled = (isSecr or isSign) and stSinged 

  thisForm.Controls("BTN_ADD_FILE").Enabled = CanAddFile()
  thisForm.Controls("BTN_DEL_FILE").Enabled = CanAddFile()

End Function
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
sub SetFieldAutoComp
      Set ctrl = thisForm.Controls("ATTR_KD_SIGNER").ActiveX
'      Set query = ThisApplication.Queries("QUERY_KD_SINGERS")
'      set result = query.Sheet.Users
      set result =  thisApplication.Groups("GROUP_MEMO_CHIEFS").Users
      ctrl.ComboItems = result
end sub
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
  if Reg_Doc(thisObject) then 
    if isSecretary(GetCurUser()) then
      set cFile = GetFileByType("FILE_KD_SCAN_DOC")
      if cFile is nothing then 
        msgBox "Приложите скан", vbInformation
        LoadFileToDoc("FILE_KD_SCAN_DOC")
      end if
    end if
  end if  
End Sub

'=============================================
Sub BTN_ADD_FILE_OnClick()
    Add_application()
    'call thisApplication.ExecuteScript("CMD_KD_LIB_DOC_IN","AddFilesToDoc","")
End Sub

'=============================================
Sub BTN_ADD_SCAN_OnClick()
  LoadFileToDoc("FILE_KD_SCAN_DOC")
'  Set_Doc_Ready(thisObject)
End Sub

'=============================================
Sub BTN_CREATE_WORD_OnClick()  
  thisObject.saveChanges 0
  txt = ThisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "CheckOPDField", thisObject)
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
  call  SetGlobalVarrible("ShowForm", thisForm.SysName)  ' чтобы не меняла форма

  if IsSigner(GetCurUser(), thisObject) then
    thisObject.Status = ThisApplication.Statuses("STATUS_KD_REGIST")  
    thisObject.Update
'    msgbox "Документ подписан"
  else
      call Reg_Doc(thisObject)
      if isSecretary(GetCurUser()) then
        set cFile = GetFileByType("FILE_KD_SCAN_DOC")
        if cFile is nothing then 
          msgBox "Приложите скан", vbInformation
          LoadFileToDoc("FILE_KD_SCAN_DOC")
        end if
      end if
  end if
End Sub

'=============================================
Sub BTN_CANC_OnClick()
    thisObject.Status = ThisApplication.Statuses("STATUS_KD_INACTIVE")  
    thisObject.Update
    msgbox "Документ отмечен как недействующий"
End Sub
'=============================================
Sub BTN_DEL_SINGER_OnClick()
   Del_User("ATTR_KD_SIGNER")
End Sub
'=============================================
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

'=============================================
Sub ATTR_KD_PR_TYPEDOC_Modified()
  thisObject.Attributes("ATTR_KD_SUFFIX").Value = Get_Suffix(thisObject) 
  thisform.Refresh
End Sub
