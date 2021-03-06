USE CMD_KD_LIB_DOC_IN
use CMD_KD_COMMON_BUTTON_LIB 
use CMD_KD_GLOBAL_VAR_LIB  
use CMD_MARK_LIB
use CMD_KD_ORDER_LIB
use CMD_KD_CURUSER_LIB

'=============================================
Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  call RemoveGlobalVarrible("AgreeObj")
  call RemoveGlobalVarrible("Settings") ' EV чтобы наверняка новое значение
   
'  on error resume next   
'  thisapplication.AddNotify CStr(Timer()) & " - SetChBox"
    SetChBox()
'  thisapplication.AddNotify CStr(Timer()) & " - ShowUsers"
'    ShowUsers()
'  thisapplication.AddNotify CStr(Timer()) & " - ShowKTNo"
'    ShowKTNo()
'  thisapplication.AddNotify CStr(Timer()) & " - SetAutoComp"
'    SetAutoComp()
'  thisapplication.AddNotify CStr(Timer()) & " - SetPersAutoComp"
'    SetPersAutoComp()
'  thisapplication.AddNotify CStr(Timer()) & " - CreateTree"

    ClearOrderAttr()
    CreateTree(nothing)
    ShowSysID()
    ShowBtnIcon()
    'EV 2018-01-31 показываем файлы только если не стоит галка показывать по кнопке
    if thisApplication.CurrentUser.Attributes.Has("ATTR_SHOW_FILE_BY_BUTTON") then _
      if thisApplication.CurrentUser.Attributes("ATTR_SHOW_FILE_BY_BUTTON").Value <> true then _
          ShowFile(0)'(-1)'(0)
    SetShowOldFailFlag()
    
    set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX  
    if not ax_Tee is nothing then 
      if ax_Tee.Count = 0 then
        if thisObject.IsKindOf("OBJECT_KD_DOC") then call BTN_TO_EXEC_OnClick() 
      end if
   end if   
'    set curOrder = GetCurUserOrder()
'    if not curOrder is nothing then _
'        thisForm.Controls("ATTR_KD_ORDER_BASE").Value =  curOrder
''  thisapplication.AddNotify CStr(Timer()) & " - EnabledCtrl"
    EnabledCtrl()    
'  thisapplication.AddNotify CStr(Timer()) & " - end "
'  thisForm.Controls("EDIT_ATTR_KD_HIST_NOTE").Enabled = false 
'  set hist = thisForm.Controls("EDIT_ATTR_KD_HIST_NOTE").ActiveX
'  'hist.ScrollBars = true  
'  hist.WordWrap = true
  if err.Number <> 0 then   msgbox err.Description, vbCritical
  on error goto 0  
End Sub
'=============================================
Function EnabledCtrl()
  
  docStat = ThisObject.StatusName
  isSec = isSecretary(GetCurUser())  
  
  thisForm.Controls("ATTR_KD_HIST_NOTE").Enabled = true
'  thisForm.Controls("ATTR_KD_HIST_NOTE").ReadOnly = true
  thisForm.Controls("ATTR_KD_TEXT").Enabled = true
    
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
  if not thisObject.IsKindOf("OBJECT_KD_BASE_DOC") then 
    thisform.Controls("BTN_CARD").Enabled = false
    thisform.Controls("BTN_RELATIONS").Enabled = false
    thisform.Controls("BTN_AGREE").Enabled = false
    thisform.Controls("BTN_HIST").Enabled = false
  end if
  if thisObject.IsKindOf("OBJECT_KD_DOC_IN") then _
    thisform.Controls("BTN_AGREE").Enabled = false

'  thisform.Controls("BTN_TO_EXEC").Enabled = docStat = "STATUS_KD_VIEWED_RUK"
'  thisform.Controls("BTN_TO_NOTE").Enabled = docStat = "STATUS_KD_VIEWED_RUK"
'  thisform.Controls("BTN_REG").Enabled = isSec and docStat = "STATUS_KD_DRAFT"
'  thisform.Controls("BTN_ADD_CONTR").Enabled = isSec and docStat = "STATUS_KD_DRAFT"
'  thisform.Controls("BTN_DEL_CONTRDENT").Enabled = isSec and docStat = "STATUS_KD_DRAFT"
'  thisform.Controls("BTN_ADD_SCAN").Enabled = isSec and docStat = "STATUS_KD_REGISTERED"
''  thisform.Controls("BTN_ADD_ORDER").Enabled = isSec and docStat = "STATUS_KD_VIEWED_RUK"
  canAddF = CanAddFile() 
  thisform.Controls("BUT_ADD_FILE").Enabled =  canAddF 'isSec 'and (docStat = "STATUS_KD_DRAFT" )
  thisform.Controls("BUT_DEL_FILE").Enabled =  canAddF 'isSec 'and (docStat = "STATUS_KD_DRAFT")  
'  thisform.Controls("BTNCHECK_DOUBLE").Enabled = isSec and docStat = "STATUS_KD_DRAFT" 
 thisform.Controls("CMD_COPY_DOC").Enabled = isSec or thisObject.ObjectDefName <> "OBJECT_KD_DOC_IN"
End Function
''=============================================
'sub ShowBtnIcon()
'  set btnfav = thisForm.Controls("BTN_TO_FAV").ActiveX
'  if HasMark(thisObject, "избранное") then
'      btnfav.Image = thisApplication.Icons("IMG_IMPORTANT_ACTIVE")
'  else
'      btnfav.Image = thisApplication.Icons("IMG_IMPORTANT_PASSIVE")
'  end if
'  set btnfav = thisForm.Controls("BTN_TO_CONTROL").ActiveX
'  if HasMark(thisObject, "на контроле") then
'      btnfav.Image = thisApplication.Icons("IMG_ONCONTROL_ACTIVE")
'  else
'      btnfav.Image = thisApplication.Icons("IMG_ONCONTROL_PASSIVE")
'  end if
'  set btnfav = thisForm.Controls("BTN_SAVE_TEMPLATE").ActiveX
'  if HasMark(thisObject, "шаблон") then
'      btnfav.Image = thisApplication.Icons("IMG_SAVE")
'  else
'      btnfav.Image = thisApplication.Icons("IMG_SAVE_ENABLED")
'  end if
'end sub
'=============================================
sub ShowSysID()
  thisForm.Controls("STSYSID").Value = "ID "& thisObject.Attributes("ATTR_KD_IDNUMBER").value
end sub
'=============================================
sub SetChBox()
  set chk = thisForm.Controls("TDMSEDITCHECKSHOW").ActiveX
  chk.buttontype = 4
  Chk.value = false
'  
'  set chk = thisForm.Controls("TDMSED_IMP").ActiveX
'  chk.buttontype = 4
'  Chk.value = thisObject.Attributes("ATTR_KD_IMPORTANT").Value

'  set chk = thisForm.Controls("TDMSED_URG").ActiveX
'  chk.buttontype = 4
'  Chk.value = thisObject.Attributes("ATTR_KD_URGENTLY").Value

end sub

'=============================================
sub CreateTree(curOrder)
'thisApplication.AddNotify "create tree - " & CStr(timer)
    dim dict,odict,curItem
    curItem = 0
    set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX  
    if ax_Tee is nothing then exit sub
    ax_Tee.DeleteAllItems
    ax_Tee.Font.Size = 10
    ax_Tee.HotTracking = true
    if curOrder is nothing then 
      set curOrder = GetOrderToApplay()
      if curOrder is nothing then  set curOrder = GetCurUserRealOrder()
    end if     
'thisApplication.AddNotify "ger cur order - " & CStr(timer)
    Set dict = ThisApplication.Dictionary("tree")
    Set odict = ThisApplication.Dictionary("tobject")

    dict.RemoveAll
'thisApplication.AddNotify "remove dic - " & CStr(timer)
    ' Получаем все поручения по документу
    Set q = ThisApplication.Queries("QUERY_TREE_ORDER")
    q.Parameter("PARAM0") = thisObject
    Set sheet = q.Sheet
'thisApplication.AddNotify "get query - " & CStr(timer)
    ' строим дерево
    ' сначала только корни
    For i = 0 to sheet.RowsCount - 1
      if i > sheet.RowsCount - 1 then exit for
      ' берем GUID родительского поручения
      pGuid = sheet.CellValue(i,2)
      ' берем GUID поручения
      hParent = 0
      guid = sheet.CellValue(i,1)
      if pGuid = "" then 
          call AddBranch(ax_Tee,sheet, curOrder,dict,hParent,i,guid,curItem)
          sheet.RemoveRow(i)
          i = i - 1
      end if  
    next
    do while sheet.RowsCount >= 0 'EV крутим выборку, пока не кончатся все записи
      if sheet.RowsCount = 0 then exit do
      For i = 0 to sheet.RowsCount-1
        if i > sheet.RowsCount - 1 then exit for
        ' берем GUID родительского поручения
        pGuid = sheet.CellValue(i,2)
        ' берем GUID поручения
        guid = sheet.CellValue(i,1)
        if pGuid <> "" then 
         If dict.Exists(pGuid) Then 
          ' Если есть родительский узел, то создаем дочернее в нем
            hParent = dict.Item(pGuid)
            call AddBranch(ax_Tee,sheet, curOrder,dict,hParent,i,guid,curItem)
            sheet.RemoveRow(i)
            i = i-1
          end if
        end if  
      Next
    loop

    ax_Tee.SelectedItem curItem
    ax_Tee.Expand(curItem)
end sub
'=============================================
sub AddBranch(ax_Tee,sheet, curOrder,dict,hParent,i,guid, curItem)
'thisApplication.AddNotify "dict.Exists(pGuid) - " & CStr(timer)
      txt = GetOrderDescFromSheet(sheet,i)
'thisApplication.AddNotify "GetOrderDescFromSheet - " & CStr(timer)
      ' создаем дочерний узел
      ch = ax_Tee.InsertItem(txt,hParent,0)  
      call ax_Tee.SetItemData(ch,sheet.Objects(i))
      call ax_Tee.SetItemIcon(ch, sheet.RowIcon(i))
'thisApplication.AddNotify "ax_Tee.InsertItem - " & CStr(timer)
      if not curOrder is nothing then 
        if curOrder.GUID = guid then 
          'ax_Tee.SelectedItem = ch  
          curItem = ch
        end if
        ax_Tee.Expand(ch)
      end if
      ' сохраняем связку описания и номера узла в дереве
      dict.Add guid, ch      
end sub
'=============================================
sub CreateTree_old(curOrder)
     set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX  
     if ax_Tee is nothing then exit sub
     ax_Tee.DeleteAllItems
'     ax_Tee.Font.Bold = true
     ax_Tee.Font.Size = 10
     if curOrder is nothing then 
        set curOrder = GetOrderToApplay()
        if curOrder is nothing then  set curOrder = GetCurUserRealOrder()
     end if     
     set query = thisApplication.Queries("QUERY_KD_FIRST_ORDER")
     query.Parameter("PARAM0") = thisObject.Handle
     set objs = query.Objects
     for each order in objs
        call CreateChild(ax_Tee,0,order, curOrder)
     next
end sub
'=============================================
sub updateTreeNode(cOrder,hItem,ax_Tee)
  txt = GetOrderDesc(cOrder)
  call ax_Tee.SetItemText(hItem, txt)
  call ax_Tee.SetItemIcon(hItem, cOrder.Icon)
end sub  
'=============================================
Sub TDMSTREEOrder_DblClick(hItem,bCancelDefault)
    ShowOrder(hItem)
End Sub
'=============================================
Sub ShowOrder(hItem)
    set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX 
    if ax_Tee is nothing then exit sub
    set cOrder = ax_Tee.GetItemData(hItem)
    if cOrder is nothing then exit sub
    fName = thisForm.SysName
    call  RemoveGlobalVarrible("ShowForm")
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = cOrder
    ans = CreateObjDlg.Show
    if ans then call updateTreeNode(cOrder,hItem,ax_Tee)
    'CreateTree(cOrder)
    call  SetGlobalVarrible("ShowForm", fName)  
End Sub
'=============================================
Sub BUT_ADD_FILE_OnClick()
    'AddFilesToDoc("")
     Add_application()
End Sub

'=============================================
Sub BUT_DEL_FILE_OnClick()
    DelFilesFromDoc()
    ThisObject.Update
End Sub
''=============================================
'Sub BTN_NEWDOC_OnClick()
'  call Create_Doc(nothing)
'End Sub
'=============================================
Sub BTN_TO_EXEC_OnClick()
' EV всегда создаем в корне
'  set curOrder = GetCurUserRealOrder()
'  if not curOrder is nothing then
'    set parOrder = curOrder.parent
'    if parOrder is nothing then
'      set curOrder = nothing
'    else
'      if parOrder.IsKindOf("OBJECT_KD_ORDER") then 
'        set curOrder = parOrder
'      else
'        set curOrder = nothing
'      end if
'    end if
'  end if
  set cType = thisApplication.ObjectDefs(thisApplication.ObjectDefs("OBJECT_KD_ORDER_REP").Description)
  if  not CreateTypeOrder(nothing, thisObject, cType) then 
    set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX  
    if not ax_Tee is nothing then 
      if ax_Tee.Count = 0 then
        if thisObject.IsKindOf("OBJECT_KD_DOC") then 
          thisform.Close false 
          thisObject.Erase
        end if
      end if
    end if   
  else
    CreateTree(nothing)
  end if
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
  call CreateTypeOrder(nothing, thisObject, cType)' EV всегда в корне
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
    CreateTree(cOrder)
End Sub

''=============================================
'Sub BTN_TO_CONTROL_OnClick()
'  set btnfav = thisForm.Controls("BTN_TO_CONTROL").ActiveX
'  if HasMark(thisObject, "на контроле") then 
'      call dellMark(thisObject, "на контроле")
'      btnfav.Image = thisApplication.Icons("IMG_ONCONTROL_PASSIVE")
'      msgbox "Снято с контроля"
'      thisForm.Close true
'  else    
'      call CreateMark("на контроле",thisObject, false)
'      btnfav.Image = thisApplication.Icons("IMG_ONCONTROL_ACTIVE")
'     msgbox "Поставлено на контроль"
'  end if
'  thisForm.Refresh
'End Sub


''=============================================
'Sub BTN_TO_FAV_OnClick()
'  set btnfav = thisForm.Controls("BTN_TO_FAV").ActiveX
'  if HasMark(thisObject, "избранное") then 
'      call dellMark(thisObject, "избранное")
'      btnfav.Image = thisApplication.Icons("IMG_IMPORTANT_PASSIVE")
'      msgbox "Удалено из избранного"
'  else    
'      call CreateMark("избранное",thisObject, false)
'      btnfav.Image = thisApplication.Icons("IMG_IMPORTANT_ACTIVE")
'     msgbox "Добавлено в избранное"
'  end if
'  thisForm.Refresh

'End Sub

'=============================================
Sub BTN_RELATIONS_OnClick()

    call SetGlobalVarrible("ShowForm", "FORM_KD_DOC_LINKS")
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = thisObject
    ans = CreateObjDlg.Show

End Sub
'=============================================
Sub BTN_HIST_OnClick()
    call SetGlobalVarrible("ShowForm", "FORM_KD_HIST")
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = thisObject
    ans = CreateObjDlg.Show

End Sub
''=============================================
'Sub BTN_ORDERS_OnClick()
'    call SetGlobalVarrible("ShowForm", "FORM_KD_DOC_ORDERS")
'    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
'    CreateObjDlg.Object = thisObject
'    ans = CreateObjDlg.Show
'End Sub

'=============================================
Sub BTN_EDIT_ORDER_OnClick()
    set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX 
    if ax_Tee is nothing then exit sub
    hItem = ax_Tee.SelectedItem 
    if hItem = 0 then exit sub
    ShowOrder(hItem)
End Sub
'=============================================
Sub BTN_DEL_ORDER_OnClick()
   DEL_ORDER_FromTree()
End Sub
'=============================================
Sub BTN_REJECT_ORDER_OnClick()
    set curOrder = GetOrderFromTree()
    if not curOrder is nothing then 
      if  not fIsExec(curOrder) then set curOrder =  nothing
    else
      set curOrder = GetCurUserRealOrder()
    end if
  
    if curOrder is nothing then
        msgbox "Поручение, от которого Вы можете отказаться, не найдено"
        exit sub
    end if
    RejectOrder(curOrder)
End Sub
'=============================================
'sub copyFilesIn(thisobject, selectedItem)'файлы и ссылки PlotnikovSP
'  thisscript.SysAdminModeOn
'  for each j in selectedItem.files'thisobject.ReferencedBy(0).files
'    'LoadFileByObj "FILE_KD_ANNEX", j.workfileName, false, thisobject
'    if not thisobject.Files.Has(j.FileName) then _
'      thisobject.Files.AddCopy j, j.FileName
'    'LoadFileByObj j.FileDefName, j.workfileName, false, thisobject
'  next
'  for each i in thisobject.ReferencedBy'бежим по всем прикрепленным поручениям
'    if i.parent.handle = selectedItem.handle then'thisobject.ReferencedBy(0).handle then
'      for each j in i.files
'        if not thisobject.Files.Has(j.FileName) then
'          thisobject.Files.AddCopy j, j.FileName
'        end if
'        if not selectedItem.Files.Has(j.FileName) then
'          selectedItem.Files.AddCopy j, j.FileName
'        end if
'        'LoadFileByObj j.FileDefName, j.workfileName, false, thisobject
'       ' LoadFileByObj "FILE_KD_ANNEX", j.workfileName, false, thisobject
'      next
'      
'      for each j in i.attributes(25).Rows'ссылки
'        if not selectedItem.Attributes(25).Rows.has(j) then
'          AddResDocFiles selectedItem, j.attributes(0).Object, "", false
'        end if
'      next
'      
'     
'    end if
'  next
'thisscript.SysAdminModeOff
'end sub


'sub checkOrders()'PlotnikovSP копирование из дочерних поручений информации в родительские
'  set selTree = thisForm.Controls("TDMSTREEOrder").ActiveX
'  set selItem = thisobject.ReferencedBy(0)
'    hItem = selTree.SelectedItem 
'    if hItem = 0 then'если ничего не выделено, то проверяем наличие хотя бы 1 дочернего поручения
'      if thisobject.ReferencedBy.Count < 2 then'если поручений в форме меньше 2
'        exit sub
'      else
'        if thisobject.ReferencedBy(0).ReferencedBy.count = 0 then'если у основного поручения нет дочернего
'          exit sub
'        end if
'      end if
'    else  
'      set selItem = selTree.GetItemData(hItem)
'      if selItem.ReferencedBy.Count = 0 then'нет дочернего у выделенного
'        exit sub
'      end if
'    end if
'    
'  thisScript.SysAdminModeOn
'  thisapplication.StartTransaction
'    dim MyOptions(2)
'    MyOptions(0) = "Текст отчета"
'    MyOptions(1) = "Текст отчета и результаты (будут перенесены как приложения в документ-основание!)"
'    Set SelDlg = ThisApplication.Dialogs.SelectDlg
'    SelDlg.SelectFrom = MyOptions
'    SelDlg.Caption = "Выберите действие"
'    SelDlg.Prompt = "Перенести из дочернего поручения:"
'    RetVal = SelDlg.Show
'    
'    
'    str = selItem.attributes(15).value'Содержание
'    'str2 = selItem.attributes(12).value'Замечания по отчёту
'   ' str3 = selItem.attributes(14).value'комментарий по переносу сроков
'    'str4 = selItem.attributes(15).value'текст отчета
'   ' str5 = selItem.attributes(16).value'табличный отчёт
'   
'    for each i in thisobject.ReferencedBy'бежим по всем прикрепленным поручениям
'      if i.parent.handle = selItem.handle then
'        str  = str & vbnewline  & i.attributes(15).value
'      end if
'    next'25,28,29 атрибуты - рез док-ты - таблица
'    selItem.attributes(15).value = str
'    
'    SelectedArray = SelDlg.Objects 
'    
'    If RetVal = TRUE then
'      If ((UBound(SelectedArray)=0) and (SelectedArray(0) = "Текст отчета и результаты (будут перенесены как приложения в документ-основание!)")) Then  
'        copyFilesIn thisobject, selItem
'      end if
'    end if
'    
'   ' CreateTree(thisObject)'для обновления главного окна (только файлы не обновляются)
'    thisObject.saveChanges
'   
'  if err.Number <> 0 then
'    thisapplication.AbortTransaction
'  else
'    thisapplication.CommitTransaction
'  end if
'  
'  err.clear
'  thisScript.SysAdminModeOff
'  
'end sub
'=============================================
Sub BTN_DONE_OnClick()
  'checkOrders
  set cOrder = GetOrderFromTree()
  if not cOrder is nothing then 
    if  not fIsExec(cOrder) then set cOrder =  nothing
  else
    set cOrder = GetCurUserRealOrder()
  end if
  if cOrder is nothing then 
    msgbox "Не найдено поручение", vbInformation
    exit sub
  end if  
  call Set_order_Done(cOrder)
  updateCurNode()
  'CreateTree(nothing)
End Sub
'=============================================
Sub BTN_APPLAY_OnClick()
    set cOrder = GetOrderFromTree()
    if not cOrder is nothing then 
      if  not fIsAutor(cOrder) then set cOrder =  nothing
    end if
    if cOrder is nothing then _
       set cOrder = GetOrderToApplay()
    if cOrder is nothing then
      msgbox "Поручение не найдено", vbCritical
      exit sub
    end if
    call ApplayOrder(cOrder, nothing)
    if thisObject.ObjectDefName = "OBJECT_KD_ZA_PAYMENT" then 
      ReopenForm() ' чтобы обновить форму
    else
      updateCurNode()
      updateParentNode()
'    CreateTree(nothing)
    end if
End Sub

'=============================================
sub ReopenForm()
    fName = thisForm.SysName
    thisScript.SysAdminModeOn
    thisObject.Permissions = sysAdminPermissions
 
    thisForm.close true 'isCanEdit
    call SetGlobalVarrible("ShowForm", fName)
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = thisObject
    ans = CreateObjDlg.Show

end sub
'=============================================
Sub BTN_REJCT_REP_OnClick()
    set cOrder = GetOrderFromTree()
    if not cOrder is nothing then 
      if  not fIsAutor(cOrder) then set cOrder =  nothing
    end if
    if cOrder is nothing then _
       set cOrder = GetOrderToApplay()
    if cOrder is nothing then
      msgbox "Поручение не найдено", vbCritical
      exit sub
    end if
    call  RejectOrderReport(cOrder, nothing)
    updateCurNode()
    'CreateTree(nothing)
End Sub
'=============================================
Sub TDMSTREEOrder_Selected(hItem,action)'PlotnikovSP
    set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX 
    if ax_Tee is nothing then exit sub
    set order = ax_Tee.GetItemData(hItem)
    if order is nothing then exit sub
    SetOrderAttr(order)
    SetBtnEnable(order)
   
   
'    Set q = ThisApplication.Queries("QUERY_GET_OBJECT_FOR_ID")'PlotnikovSP
'    q.Parameter("PARAM0") = order.GUID
'    set curNewOrder = q.Objects(0)'TODO++++++++++

    
    
End Sub
'=============================================
sub SetBtnEnable(order)
    thisForm.Controls("BTN_REJECT_ORDER").Enabled = false
    thisForm.Controls("BTN_CHANGE_TIME").Enabled = false
    thisForm.Controls("BTN_APPLAY").Enabled = false
    thisForm.Controls("BTN_REJCT_REP").Enabled = false
    thisForm.Controls("BTN_DONE").Enabled = false
    
    au = fIsAutor(order)
    ex = fIsExec(order)
    thisForm.Controls("BTN_REQSEND").Enabled = au and (order.StatusName = "STATUS_KD_ORDER_IN_WORK" or _
    order.StatusName = "STATUS_KD_ORDER_SENT" or order.StatusName = "STATUS_KD_REPORT_READY")
    if au then
      if order.StatusName = "STATUS_KD_REPORT_READY" then 
        thisForm.Controls("BTN_APPLAY").Enabled = true
        thisForm.Controls("BTN_REJCT_REP").Enabled = true
        thisForm.Caption = thisForm.Description & " - Принять отчет" 
      elseif order.StatusName ="STATUS_KD_ORDER_IN_WORK" then 
        if order.Attributes.has("ATTR_KB_POR_DATEBRAKE") then 
          if order.Attributes("ATTR_KB_POR_DATEBRAKE").Value <> "" then 
              thisForm.Controls("BTN_CHANGE_TIME").Enabled = true
              thisForm.Caption = thisForm.Description & " - Принять запрос на перенос сроков" 
          end if            
        end if  
      end if  
    else
      if ex then 
          if order.StatusName = "STATUS_KD_ORDER_IN_WORK" then 
            thisForm.Controls("BTN_DONE").Enabled = true
            thisForm.Controls("BTN_REJECT_ORDER").Enabled = true
            thisForm.Controls("BTN_CHANGE_TIME").Enabled = true
            thisForm.Caption = thisForm.Description & " - " & order.Attributes("ATTR_KD_RESOL").value
          end if
      else
        thisForm.Caption = thisForm.Description & " - " & order.Attributes("ATTR_KD_RESOL").value
      end if
    end if
end sub
'=============================================
sub SetOrderAttr(order)
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
'=============================================
sub ClearOrderAttr()
  for each contr in thisForm.Controls
    if left(contr.Name,5) = "EDIT_" then contr.value = ""  
  next 
end sub
'=============================================
Sub BTN_CHANGE_TIME_OnClick()
  set order = getOrderFromTree()
  if order is nothing then exit sub
  
  'заполняем поля по умолчанию  
  Set frmSetShelve = ThisApplication.InputForms("FORM_KD_QUES")
  frmSetShelve.Attributes("ATTR_KB_POR_DATEBRAKE").Value = order.Attributes("ATTR_KB_POR_DATEBRAKE").value
  frmSetShelve.Attributes("ATTR_KB_POR_DATEBRAKECOM").Value = order.Attributes("ATTR_KB_POR_DATEBRAKECOM").value
  frmSetShelve.Attributes("ATTR_KD_HIST_OBJECT").value = order

  If frmSetShelve.Show Then
    order.Permissions = sysAdminPermissions ' т.к. делается в другой форме, то не обновляется
    order.update
    updateCurNode()
    'CreateTree(nothing)
  end if
End Sub
'=============================================
Sub BTN_ORDER_OnClick()
   'checkOrders
   BTN_EDIT_ORDER_OnClick()
End Sub
'=============================================
Sub BTN_COMMENT_OnClick()
  set order = getOrderFromTree()
  if order is nothing then exit sub
  
  call ShowComment("Статус/ комментарий", order.Attributes("ATTR_KD_HIST_NOTE").value)
End Sub
'=============================================
sub updateCurNode()
    set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX 
    if ax_Tee is nothing then exit sub
    hItem = ax_Tee.SelectedItem 
    set cOrder = ax_Tee.GetItemData(hItem)
    if cOrder is nothing then exit sub
    call updateTreeNode(cOrder,hItem,ax_Tee)
end sub  
'=============================================
sub updateParentNode()
    set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX 
    if ax_Tee is nothing then exit sub
    hItem = ax_Tee.SelectedItem 
    hItem = ax_Tee.GetParentItem(hItem)
    if hItem = 0 then exit sub
    set cOrder = ax_Tee.GetItemData(hItem)
    cOrder.Update
    if cOrder is nothing then exit sub
    call updateTreeNode(cOrder,hItem,ax_Tee)
    ax_Tee.SelectedItem = hItem
end sub  
'=============================================
sub updateTreeNode(cOrder,hItem,ax_Tee)
  txt = GetOrderDesc(cOrder)
  call ax_Tee.SetItemText(hItem, txt)
  call ax_Tee.SetItemIcon(hItem, cOrder.Icon)
  SetOrderAttr(cOrder)
  SetBtnEnable(cOrder)
end sub  
'=============================================
Sub BTN_REQSEND_OnClick()
  set order = getOrderFromTree()
  if order is nothing then exit sub
  SendReqEmail(order)
End Sub

''=============================================
'Sub BTN_SAVE_TEMPLATE_OnClick()
'  set btnfav = thisForm.Controls("BTN_SAVE_TEMPLATE").ActiveX
'  if HasMark(thisObject, "шаблон") then 
'      call dellMark(thisObject, "шаблон")
'      btnfav.Image = thisApplication.Icons("IMG_SAVE_ENABLED")
'      msgbox "Метка шаблон снята"
'      thisForm.Close true
'  else    
'      call CreateMark("шаблон",thisObject, false)
'      btnfav.Image = thisApplication.Icons("IMG_SAVE")
'     msgbox "Метка шаблон установлена"
'  end if
'  thisForm.Refresh
'End Sub

'=============================================
Sub BTN_FROM_TEMP_OnClick()

    Set Q = ThisApplication.Queries("QUERY_DOC_TEMPLS")
    Q.Parameter("PARAM0") = thisObject.ObjectDefName
'    Set Objs = Q.Objects

    set SelObjDlg = thisApplication.Dialogs.SelectDlg'SelectObjectDlg
    SelObjDlg.Prompt = "Выберите шаблон документов для копирования:"
    SelObjDlg.SelectFrom = Q.Sheet'SelectFromObjects = Objs

    RetVal = SelObjDlg.Show 
    If (RetVal<>TRUE) Then Exit Sub  
    Set ObjCol = SelObjDlg.Objects
    if (ObjCol.RowsCount = 0) Then Exit Sub  
    
    set docObj = ObjCol.Objects(0)
 
    if not CopyAttrs(docObj,thisObject) then 
      msgbox "Не удалось скопировать атрибуты документа", vbCritical, "Ошибка"
      exit sub
    end if
    thisObject.update  
    thisForm.Refresh

End Sub
