'USE "CMD_KD_LIB_DOC_IN"
'use CMD_KD_COMMON_LIB
use CMD_KD_COMMON_BUTTON_LIB 
'use CMD_KD_GLOBAL_VAR_LIB  
'use CMD_MARK_LIB
'use CMD_KD_MEMO_LIB
use CMD_KD_ORDER_LIB
use CMD_KD_PROTOCOL_LIB
use CMD_KD_CURUSER_LIB
'use CMD_KD_REGNO_KIB
'=============================================
Sub Form_BeforeShow(Form, Obj) 
  on error resume next    
'  thisapplication.AddNotify CStr(Timer()) & " form.Description"
    form.Caption = form.Description
'    thisapplication.AddNotify CStr(Timer()) & " SetChBox"
    SetChBox()
'    thisapplication.AddNotify CStr(Timer()) & " ShowKTNo"
    ShowKTNo()
'    thisapplication.AddNotify CStr(Timer()) & " CreateTree"
    CreateTree(nothing)
    CreateProtTree(nothing)  
'    thisapplication.AddNotify CStr(Timer()) & " ShowSysID"
    ShowSysID()
'    thisapplication.AddNotify CStr(Timer()) & " ShowBtnIcon"
    ShowBtnIcon()
'    thisapplication.AddNotify CStr(Timer()) & " SetFieldAutoComp"
    'SetFieldAutoComp()
'    thisapplication.AddNotify CStr(Timer()) & " EnabledCtrl"
    EnabledCtrl()    
'    thisapplication.AddNotify CStr(Timer()) & " end"
   'EV 2018-01-31 показываем файлы только если не стоит галка показывать по кнопке
    if thisApplication.CurrentUser.Attributes.Has("ATTR_SHOW_FILE_BY_BUTTON") then _
      if thisApplication.CurrentUser.Attributes("ATTR_SHOW_FILE_BY_BUTTON").Value <> true then _
          ShowFile(0)'(-1)'(0)
    SetShowOldFailFlag()

    SetInNumEnabled(Obj.Attributes("ATTR_KD_PROT_TYPE"))
    call  SetGlobalVarrible("ShowForm", thisForm.SysName)  
  if err.Number <> 0 then   msgbox err.Description, vbCritical
  on error goto 0 
   
End Sub

'=============================================
Function EnabledCtrl()
  isAproving = thisObject.StatusName = "STATUS_KD_AGREEMENT"
  isExec = IsExecutor(GetCurUser(), thisObject)
  isCanEd = isCanEdit()
  isSec = isSecretary(GetCurUser())  
'  isExec = IsInCurUsers(thisObject.Attributes("ATTR_KD_EXEC").User)
  docStat = ThisObject.StatusName
  
'BTN_APP_SCAN

  thisform.Controls("BTN_RETURN").Enabled = (isExec  and ( docStat = "STATUS_SIGNING" or not isCanEd) ) 
  thisform.Controls("BTN_CANCEL_DOC").Enabled = isExec 
  thisform.Controls("BTN_SING_DOC").Enabled = isExec and docStat <> "STATUS_SIGNED"
  thisform.Controls("BTN_ADD_OUT_DOC").Enabled = isExec and docStat = "STATUS_SIGNED"

  thisForm.Controls("BTN_ADD_FILE").Enabled = CanAddFile()
  thisForm.Controls("BTN_DEL_FILE").Enabled = CanAddFile()
  
  thisForm.Controls("BTN_MOVE_ORDER").Enabled = isExec
  thisForm.Controls("BTN_REMOVEORDER").Enabled = isExec

  on error resume next  
  orderEn = false 
  orderEn = thisApplication.ExecuteScript(thisObject.ObjectDefName,"CanIssueOrder", thisObject)
  if err.Number <>0 then err.clear
  on error goto 0
  
  thisForm.Controls("BTN_CHI_ORDER").Enabled = orderEn and not isSec
  thisForm.Controls("BTN_TO_EXEC").Enabled = orderEn
  thisForm.Controls("BTN_TO_NOTE").Enabled = orderEn

'  set settings = thisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB","GetSettingsByObjS", thisObject, true)
'  if not settings is nothing then 
'    str =  settings.Attributes("ATTR_KD_STATUSES_FOR_ORDER").value
'    if str > "" then 
'      if Instr(";" & str & ";", ";" & docStat & ";") = 0 then 
'          thisForm.Controls("BTN_CHI_ORDER").Enabled = false
'          thisForm.Controls("BTN_TO_EXEC").Enabled = false
'          thisForm.Controls("BTN_TO_NOTE").Enabled = false
'      end if
'    end if  
'  end if      
End Function

'=============================================
sub CreateProtTree(curOrder)
    thisscript.SysAdminModeOn
     set ax_Tee = thisForm.Controls("TDMSTREE_PROTS").ActiveX  
     if ax_Tee is nothing then exit sub
     ax_Tee.DeleteAllItems
'     ax_Tee.Font.Bold = true
     ax_Tee.Font.Size = 10
     set rows = thisObject.Attributes("ATTR_KD_T_LINKS").Rows    
     for each row in rows
        set Prot = row.Attributes("ATTR_KD_LINKS_DOC").object
        if not prot is nothing then 
          if prot.ObjectDefName = "OBJECT_KD_PROTOCOL" then 
            ch = ax_Tee.InsertItem(prot.description & " от " & prot.Attributes("ATTR_KD_MEETING_DATE").value _
                & " - " & prot.Attributes("ATTR_KD_TOPIC").value , 0,0)  
            call ax_Tee.SetItemData(ch,prot)
            call ax_Tee.SetItemIcon(ch, prot.Icon)
             set query = thisApplication.Queries("QUERY_KD_FIRST_ORDER")
             query.Parameter("PARAM0") = prot.Handle
             set objs = query.Objects
             for each order in objs
                call CreateChild(ax_Tee,ch,order, nothing)
             next
          end if
        end if
      
     next
''     if curOrder is nothing then set curOrder = GetCurUserRealOrder()'thisApplication.GetObjectByGUID("{CD59008D-BB2D-4B0D-ADFE-E6EC6D447B3F}")  
'     set query = thisApplication.Queries("QUERY_KD_FIRST_ORDER")
'     query.Parameter("PARAM0") = thisObject.Handle
'     set objs = query.Objects
'     for each order in objs
'        call CreateChild(ax_Tee,0,order, curOrder)
'     next
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
    fName = thisForm.SysName
    set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX 
    if ax_Tee is nothing then exit sub
    set cOrder = ax_Tee.GetItemData(hItem)
    if cOrder is nothing then exit sub
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = cOrder
    call  RemoveGlobalVarrible("ShowForm")
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
    fName = thisForm.SysName
    thisScript.SysAdminModeOn
    thisObject.Permissions = sysAdminPermissions
    thisObject.Status = ThisApplication.Statuses("STATUS_SIGNED")  
    call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", thisObject)
'     thisObject.saveChanges '(16384)
    thisObject.Update
    msgbox "Документ подписан"

    thisForm.close true 'isCanEdit
    call SetGlobalVarrible("ShowForm", fName)
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = thisObject
    ans = CreateObjDlg.Show

End Sub

'=============================================
Sub BTN_ADD_OUT_DOC_OnClick()
   set objType = thisApplication.ObjectDefs("OBJECT_KD_DOC_OUT")
   set newDoc = Create_Doc_by_Type(objType, thisObject)
   If newDoc is nothing then exit sub
End Sub

'=============================================
Sub BTN_APP_SCAN_OnClick()
  LoadFileToDoc("FILE_KD_SCAN_DOC")
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
Sub BTN_TO_EXEC_OnClick()
  set curOrder = GetCurUserRealOrder()
  if not curOrder is nothing then
    set parOrder = curOrder.parent
    if parOrder is nothing then
      set curOrder = nothing
    else
      if parOrder.IsKindOf("OBJECT_KD_ORDER") then 
        set curOrder = parOrder
      else
        set curOrder = nothing
      end if
    end if
  end if
  set cType = thisApplication.ObjectDefs(thisApplication.ObjectDefs("OBJECT_KD_ORDER_REP").Description)
  call CreateTypeOrder(curOrder, thisObject, cType)
  CreateTree(nothing)
End Sub
'=============================================
Sub BTN_TO_NOTE_OnClick()
'    set cOrder = GetOrderFromTree()
'    if not cOrder is nothing then 
'      if  not fIsExec(cOrder) then set cOrder =  nothing
'    end if
'    if cOrder is nothing then _
'       set cOrder = GetCurUserRealOrder()
'    if cOrder is nothing then
'      msgbox "Поручение не найдено", vbCritical
'      exit sub
'    end if
  set cType = thisApplication.ObjectDefs(thisApplication.ObjectDefs("OBJECT_KD_ORDER_NOTICE").Description)
  call CreateTypeOrder(nothing, thisObject, cType) ' EV всегда в корне
  CreateTree(nothing)
End Sub
'=============================================
Sub BTN_CHI_ORDER_OnClick()
    set cOrder = GetOrderFromTree()
    if not cOrder is nothing then 
      if  not fIsExec(cOrder) then set cOrder =  nothing
    end if
    if cOrder is nothing then _
       set cOrder = GetCurUserRealOrder()
    if cOrder is nothing then
      msgbox "Поручение не найдено", vbCritical
      exit sub
    end if
    set cType = thisApplication.ObjectDefs(thisApplication.ObjectDefs("OBJECT_KD_ORDER_REP").Description)
    call CreateTypeOrder(cOrder, thisObject, cType)
    CreateTree(nothing)
End Sub
'=============================================
Sub BTN_DEL_ORDER_OnClick()
   if DEL_ORDER_FromTree() then CreateTree(nothing)
End Sub
'=============================================
Sub BTN_ADD_PROT_OnClick()
    Set Q = ThisApplication.Queries("QUERY_ARM_PR")
    Set Objs = Q.Objects

    set SelObjDlg = thisApplication.Dialogs.SelectDlg'SelectObjectDlg
    SelObjDlg.Prompt = "Выберите один или несколько протоколв:"
    SelObjDlg.SelectFrom = Q.Sheet'SelectFromObjects = Objs

    RetVal = SelObjDlg.Show 
     If (RetVal<>TRUE) Then Exit Sub  
     Set ObjCol = SelObjDlg.Objects
     if (ObjCol.RowsCount = 0) Then Exit Sub  
    
     For Each obj In ObjCol.Objects
        if obj.Handle <> thisObject.Handle then _
            call  AddResDocFiles(thisObject, obj, "", false)   
     Next
     thisObject.SaveChanges(16384)' Update
     CreateProtTree(nothing)

End Sub
'=============================================
Sub BTN_DEL_PROT_OnClick()

    set ax_Tee = thisForm.Controls("TDMSTREE_PROTS").ActiveX 
    if ax_Tee is nothing then exit sub
    hItem = ax_Tee.SelectedItem 
    if hItem = 0 then 
      exit sub
    end if
    set prot = ax_Tee.GetItemData(hItem)
    if not prot is nothing then
       if prot.ObjectDefName <> "OBJECT_KD_PROTOCOL" then
          set prot = prot.Attributes("ATTR_KD_DOCBASE").object
          if prot is nothing then exit sub
       end if
       Answer = MsgBox( "Вы уверены, что хотите удалить связь с выделенным протоколом?", vbQuestion + vbYesNo,"Удалить?")
       if Answer <> vbYes then exit sub
       ColNo = "ATTR_KD_LINKS_DOC"
       Set ReplyRows = ThisObject.Attributes("ATTR_KD_T_LINKS").Rows
       for j = 0 to ReplyRows.Count-1
        if not ReplyRows(j).Attributes(ColNo).Object is nothing then 
          if ReplyRows(j).Attributes(ColNo).Object.Handle  = prot.Handle then 'проверяем, что проект = выделенному 
              ReplyRows(j).Erase
              Exit For
           end if
         end if    
       next
       thisObject.SaveChanges(16384)' Update
    end if
    CreateProtTree(nothing)

End Sub
'=============================================
Sub TDMSTREE_PROTS_DblClick(hItem,bCancelDefault)
    fName = thisForm.SysName
    set ax_Tee = thisForm.Controls("TDMSTREE_PROTS").ActiveX 
    if ax_Tee is nothing then exit sub
    set cOrder = ax_Tee.GetItemData(hItem)
    if cOrder is nothing then exit sub
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = cOrder
    call  RemoveGlobalVarrible("ShowForm")
    ans = CreateObjDlg.Show
    CreateTree(cOrder)
    call  SetGlobalVarrible("ShowForm", fName)  
End Sub
'=============================================
Sub BTN_MOVE_ORDER_OnClick()
    set ax_Tee = thisForm.Controls("TDMSTREE_PROTS").ActiveX 
    if ax_Tee is nothing then exit sub
    hItem = ax_Tee.SelectedItem 
    if hItem = 0 then  exit sub

    set obj = ax_Tee.GetItemData(hItem)
    if obj is nothing then exit sub
    if not obj.IsKindOf("OBJECT_KD_ORDER") then exit sub 

    if obj.StatusName = "STATUS_KD_ORDER_DONE" then 
      msgbox "Невозможно перенести выполненое поручение", vbExclamation
      exit sub
    end if

    set oldProt = obj.Attributes("ATTR_KD_DOCBASE").object
    if oldProt is nothing then exit sub

    Set ObjRoots = GET_FOLDER("",thisObject.ObjectDef) 
    if  ObjRoots is nothing then  
      msgBox "Не удалось создать папку", vbCritical, "Объект не был создан"
      exit sub
    end if
    
    set parentOrder = obj.Attributes("ATTR_KD_ORDER_BASE").object
    
    thisscript.SysAdminModeOn
    obj.Permissions = sysAdminPermissions
    ' Добавить в связи старого документа
    call AddResDocFiles(oldProt, obj, "Перенесено в протокол " & thisObject.Description, false)  
    'поменять документ отснование
    obj.Attributes("ATTR_KD_DOCBASE").value = thisObject
    ' перенести детей выше
    set newpar = obj.Parent
    for each chiObj in obj.Objects
       call ChangeParent(chiObj, obj,newpar) 
    next
    'перенести в корень дерева поручений
    if not parentOrder is nothing then _ 
        call ChangeParent(obj, parentOrder,ObjRoots) 
    if obj.StatusName <> "STATUS_KD_ORDER_SENT" then _
        obj.Status = thisApplication.Statuses("STATUS_KD_ORDER_SENT")
    obj.Update

    'перерисовать оба дерева
'    thisObject.Update
    ax_Tee.DeleteItem(hItem)
    CreateTree(nothing)
End Sub
'=============================================
sub ChangeParent(obj, oldPar,newPar)
    thisscript.SysAdminModeOn
    obj.Parent = newPar
    newPar.Objects.Add obj
    oldPar.Objects.Remove obj
end sub
'=============================================
Sub BTN_REMOVEORDER_OnClick()
    set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX 
    if ax_Tee is nothing then exit sub
    hItem = ax_Tee.SelectedItem 
    if hItem = 0 then  exit sub

    set obj = ax_Tee.GetItemData(hItem)
    if obj is nothing then exit sub
    if not obj.IsKindOf("OBJECT_KD_ORDER") then exit sub 
    
    if obj.StatusName = "STATUS_KD_ORDER_DONE" then 
      msgbox "Невозможно перенести выполненое поручение", vbExclamation
      exit sub
    end if

    set oldProt = nothing 
    set parentOrder = obj.Attributes("ATTR_KD_ORDER_BASE").object
    if parentOrder is nothing then 
      set oldProt =  GetOldProt()
    else
      set oldProt = parentOrder.Attributes("ATTR_KD_DOCBASE").Object
      if oldProt.handle = thisObject.Handle then 
        set oldProt =  GetOldProt()
'        obj.Attributes("ATTR_KD_ORDER_BASE").value = ""
      end if
    end if  
    if oldProt is nothing then 
      msgbox "Невыбран протокол для возврата", vbExclamation
    exit sub
    end if

    thisscript.SysAdminModeOn
    obj.Permissions = sysAdminPermissions
    ' Удалить в связи старого документа
    call RemoveRelProt(oldProt, obj)
    'поменять документ отснование
    obj.Attributes("ATTR_KD_DOCBASE").value = oldProt
    ' перенести детей выше
    set newpar = obj.Parent
    for each chiObj in obj.Objects
       call ChangeParent(chiObj, obj, newpar) 
    next

    'перенести в корень дерева поручений
    if not parentOrder is nothing then _
       call ChangeParent(obj, newpar,parentOrder) 
       'obj.Parent = parentOrder
    
    obj.Update

    'перерисовать оба дерева
'    thisObject.Update
    ax_Tee.DeleteItem(hItem)
    CreateProtTree(nothing)  
    '    thisForm.Refresh

End Sub
'=============================================
function GetOldProt()
  set GetOldProt = nothing
    set ax_Tee = thisForm.Controls("TDMSTREE_PROTS").ActiveX 
    if ax_Tee is nothing then exit function
    hItem = ax_Tee.SelectedItem 
    if hItem = 0 then  exit function

    set obj = ax_Tee.GetItemData(hItem)
    if obj is nothing then exit function

    if obj.IsKindOf("OBJECT_KD_ORDER") then 
        set GetOldProt = obj.Attributes("ATTR_KD_DOCBASE").object
    else
        set GetOldProt = obj
    end if
end function
'=============================================
Function RemoveRelProt(prot, order)
  set ReplyRows = prot.Attributes("ATTR_KD_T_LINKS").rows
  call Del_Row (ReplyRows, "ATTR_KD_LINKS_DOC", order.handle,"")
end function

