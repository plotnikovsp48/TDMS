use CMD_KD_COMMON_LIB
'use CMD_KD_ORDER_LIB
use CMD_KD_FILE_LIB
'=============================================
Sub Form_BeforeShow(Form, Obj)

  SetControlEnable(thisObject)
  
End Sub

'=============================================
sub SetControlEnable(order)
  set curUser = thisApplication.CurrentUser
  'thisApplication.DebugPrint thisObject.Attributes("ATTR_KD_OP_DELIVERY").Value  
  isExec = fIsExec(thisObject)
  lisAutor = fIsAutor(thisObject)
  inWork = thisObject.StatusName = "STATUS_KD_ORDER_IN_WORK"
  inRep = thisObject.StatusName = "STATUS_KD_REPORT_READY"
    
  thisForm.Controls("BTN_SEND_RETORT").Enabled = isExec and inWork
  thisForm.Controls("BTN_REJECT").Enabled = isExec and inWork
  thisForm.Controls("BTN_APPLY_REP").Enabled = lisAutor and inRep
  thisForm.Controls("BTN_REJECT_REP").Enabled = lisAutor and inRep
  thisForm.Controls("BTN_RETURN").Enabled = isExec and inRep
  thisForm.Controls("BTN_EDIT").Enabled = (isExec or lisAutor) and (inRep or inWork)

  thisForm.Controls("BTN_SEND_TIME_REQ").Enabled = isExec and inWork
  thisForm.Controls("BTN_APP_TIME_REQ").Enabled = lisAutor  and inWork
  thisForm.Controls("BTN_REJECT_TIME_REQ").Enabled = lisAutor and inWork

  thisForm.Controls("BTN_LOAD_FILE").Enabled = isExec and inWork
  thisForm.Controls("BTN_DEL_APP").Enabled = isExec and inWork
  thisForm.Controls("BTN_FROM_ORDERS").Enabled = isExec and inWork
  

  thisForm.Controls("BTN_CREATE_DOC").Enabled = isExec and inWork
  thisForm.Controls("BTN_ADD_DOC").Enabled = isExec and inWork
  thisForm.Controls("BTN_DEL_DOC").Enabled = isExec and inWork
  thisForm.Controls("BTN_ORDERS_DOC").Enabled = isExec and inWork
  thisForm.Controls("BTN_CHECKIN").Enabled = isExec and inWork
  thisForm.Controls("BTN_CHECKOUT").Enabled = isExec and inWork
     
  thisForm.Controls("BTN_DEL_REL").Enabled = isExec and inWork
  thisForm.Controls("BTNADD_REL").Enabled = isExec and inWork

end sub

'=============================================
Sub BTN_SEND_RETORT_OnClick()
    ThisScript.SysAdminModeOn
'    Set reasonDlg = ThisApplication.Dialogs.SimpleEditDlg
'    reasonDlg.Caption = "Введите текст отчета"
'    reasonDlg.Prompt = "Содержание отчета"
'    If reasonDlg.Show AND reasonDlg.Text <> "" Then _
    txt = thisApplication.ExecuteScript("FORM_KD_AGREE", "GetComment","Введите cодержание отчета")
    if IsEmpty (txt) then exit sub
    if trim(txt) <> "" then _
       call SendReport(ThisObject,txt)
End Sub

'=============================================
sub SendReport(orderObj,repText)
  call AddComment(orderObj,"ATTR_KB_POR_RESULT",repText)
  call AddCommenttxt(orderObj,"ATTR_KD_HIST_NOTE", "Отправлен отчет: " & repText)
  ' EV сюда прописываем изменения статусов
  set contr = thisObject.Attributes("ATTR_KD_CONTR").User
  if contr is nothing then 
    call SetOrderDone(thisObject,"", "Выполнено") 
    msgbox "Поручение " & thisObject.Description & " выполнено"
    thisForm.Close false
  else
    thisObject.Status = thisApplication.Statuses("STATUS_KD_REPORT_READY")
    thisObject.Update
    ' A.O. 
    'msgbox "Отчет по поручению " & thisObject.Description & " передан контролеру"
    thisForm.Close false
  end if
end sub

'=============================================
Sub BTN_REJECT_REP_OnClick()
 call RejectOrderReport(thisObject, thisForm)
'    ThisScript.SysAdminModeOn
'    txt = thisApplication.ExecuteScript("FORM_KD_AGREE", "GetComment","Введите причину отклонения отчета")
'    if IsEmpty (txt) then exit sub
'    if trim(txt) <> "" then 
'        call AddComment(thisObject,"ATTR_KB_POR_RESULT",txt)
'        thisObject.Status = thisApplication.Statuses("STATUS_KD_ORDER_SENT")'thisApplication.Statuses("STATUS_KD_ORDER_IN_WORK")
'          ' новая концепция, чтобы было новое, если отклонили
'        thisObject.Attributes("ATTR_KD_POR_REASONCLOSE").Value = "" '"Отказ от выполнения"
'        thisObject.Update
'        msgbox "Отчет по поручению " & thisObject.Description & " возвращен на доработку"
'        thisForm.Close false
'    else
'        msgbox "Введите причину отклонения отчета!", vbCritical, "Отклонение не выполнено" 
'    end if  
End Sub


'=============================================
Sub BTN_SEND_TIME_REQ_OnClick()
'  ThisScript.SysAdminModeOn
'  Set frmSetShelve = ThisApplication.InputForms("FORM_KD_QUES")
'  If frmSetShelve.Show Then
'    newDate = frmSetShelve.Attributes("ATTR_KB_POR_DATEBRAKE").Value
'    if  newDate <= Now then 
'      call MsgBox("Введеная дата " & newDate & " меньше текущей. "& vbNewLine & _
'        "Запрос отменен. Введите новую дату. ", _
'        VbCritical + vbOKOnly,"Запрос отменен!")
'      exit sub
'    end if 
'    thisObject.Attributes("ATTR_KB_POR_DATEBRAKE").Value = newDate

'    call AddCommentTxt(thisObject,"ATTR_KB_POR_DATEBRAKECOM", _
'        frmSetShelve.Attributes("ATTR_KB_POR_DATEBRAKECOM").Value)
'    call AddCommentTxt(thisObject,"ATTR_KD_HIST_NOTE", "Отправлен запрос на изменение сроков: " & _ 
'        frmSetShelve.Attributes("ATTR_KB_POR_DATEBRAKECOM").Value)
'    
'    thisObject.Update
'    thisForm.Close false
'  end if
End Sub
'=============================================
Sub BTN_APP_TIME_REQ_OnClick()
  ThisScript.SysAdminModeOn
  thisObject.Attributes("ATTR_KD_POR_PLANDATE").Value = thisObject.Attributes("ATTR_KB_POR_DATEBRAKE").Value
  thisObject.Attributes("ATTR_KB_POR_DATEBRAKE").Value = ""
  thisObject.Update
  thisForm.Close false
End Sub

'=============================================
Sub BTN_REJECT_TIME_REQ_OnClick()
    ThisScript.SysAdminModeOn
    Set reasonDlg = ThisApplication.Dialogs.SimpleEditDlg
    reasonDlg.Caption = "Введите причину отказа"
    reasonDlg.Prompt = "Причина отказа"
    If reasonDlg.Show AND reasonDlg.Text <> "" Then 
        call AddCommentTxt(thisObject,"ATTR_KB_POR_DATEBRAKECOM",reasonDlg.Text)
        call AddCommentTxt(thisObject,"ATTR_KD_HIST_NOTE", "Отклонен запрос на изменение сроков: " & reasonDlg.Text) 
        thisObject.Attributes("ATTR_KB_POR_DATEBRAKE").Value = ""
        thisObject.Update
        thisForm.Close false
    end if    
End Sub

'=============================================
Sub BTN_LOAD_FILE_OnClick()
    LoadFileToDoc("FILE_KD_ANNEX")
End Sub

'=============================================
Sub BTN_UnLoad_OnClick()
   call UnloadFilesFromDoc
End Sub

'=============================================
Sub BTN_DEL_APP_OnClick()
   call DelFilesFromDoc
End Sub

'=============================================
Sub BTN_CREATE_DOC_OnClick()
  set doc = thisObject.Attributes("ATTR_KD_DOCBASE").Object
  if not doc is nothing then 
    if doc.ObjectDefName <> "OBJECT_KD_DOC_IN" then set doc = nothing ' только для ВД
  end if
  set newDoc = Create_Doc(doc)
  if not newDoc is nothing then 
    AddResDoc( newDoc)
  end if
  SetAllDocs(thisObject)

End Sub

'=============================================
Sub BTN_ADD_DOC_OnClick()
    Add_Doc()
'     Set SelObjDlg = ThisApplication.Dialogs.SelectObjectDlg 
'     SelObjDlg.Prompt = "Выберите один или несколько документов:"

'     RetVal = SelObjDlg.Show 
'     Set ObjCol = SelObjDlg.Objects
'     If (RetVal<>TRUE) Or (ObjCol.Count=0) Then Exit Sub
'    
'     For Each obj In ObjCol
'         call AddResDoc(obj)   
'     Next
'     SetAllDocs(thisObject)
End Sub

''=============================================
'sub SetAllDocs(order)
'  strDoc = ""
'  Set ReplyRows = order.Attributes("ATTR_KD_POR_RESDOC").Rows
'  for each row in ReplyRows
'    strDoc = strDoc & row.Attributes(0).value & ","
'  next
'  thisScript.SysAdminModeOn
'  order.Permissions = SysAdminPermissions
'  order.Attributes("ATTR_KD_ALL_DOC").value = strDoc
'end sub

'=============================================
Sub BTN_DEL_DOC_OnClick()
  call Del_FromTable("ATTR_KD_POR_RESDOC", 0)
  SetAllDocs(thisObject)

End Sub

'=============================================
Sub BTN_DEL_REL_OnClick()
   call Del_FromTableWithPerm("ATTR_KD_T_LINKS", "ATTR_KD_LINKS_DOC", "ATTR_KD_LINKS_USER") 
End Sub

'=============================================
Sub BTNADD_REL_OnClick()
   call AskToAddRelDoc()
End Sub

'=============================================
Sub BTN_APPLY_REP_OnClick()
    call ApplayOrder(thisObject, thisForm)
'    txt = thisApplication.ExecuteScript("FORM_KD_AGREE", "GetComment","Введите комментарий к отчету")
'    if IsEmpty (txt) then exit sub
'    if trim(txt) <> "" then  call AddComment(thisObject,"ATTR_KB_POR_RESULT",txt) 'если нажал ОК, то в любом случае принимаем
'    call SetOrderDone(thisObject,"", "Выполнено") 

'  set order = thisObject.Attributes("ATTR_KD_ORDER_BASE").Object
'  if not order is nothing then 
'     Answer = MsgBox("Открыть исходное поручение?", vbQuestion + vbYesNo,"Открыть?")
'     if Answer <> vbYes then 
'       msgbox "Поручение " & thisObject.Description & "выполнено"  
'       exit sub
'     else
'      thisForm.Close false
'      Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
'      CreateObjDlg.Object = order
'   ' CreateObjDlg.ActiveForm = order.ObjectDef.InputForms(1)
'      ans = CreateObjDlg.Show
'     end if
'  end if  
End Sub

'=============================================
Sub BTN_EDIT_OnClick()
   EidtComment("ATTR_KB_POR_RESULT")
End Sub

'=============================================
Sub BTN_RETURN_OnClick()
        thisObject.Status = thisApplication.Statuses("STATUS_KD_ORDER_IN_WORK")
        thisObject.Update
        msgbox "Поручение " & thisObject.Description & " возвращено на доработку"

End Sub

'=============================================
Sub BTN_REJECT_OnClick()
    ThisScript.SysAdminModeOn
    txt = thisApplication.ExecuteScript("FORM_KD_AGREE", "GetComment","Введите причину отказа от выполнения")
    if IsEmpty (txt) then exit sub
    if trim(txt) <> "" then  
       call SendReject(ThisObject,txt)
    else  
      msgbox "Введите причину отказа!", vbCritical, "Отправка отменена"
    end if   
End Sub


'=============================================
Sub BTN_FROM_ORDERS_OnClick()
  call AddFiles("QUERY_ORDERS_FILES", thisObject)
End Sub

'=============================================
sub AddFiles(queryName, obj)
  thisScript.SysAdminModeOn
  set selDlg = ThisApplication.Dialogs.SelectDlg
  set Qr = ThisApplication.Queries(queryName)
  qr.Parameter("PARAM0") = obj.Handle
  selDlg.SelectFrom = Qr.Sheet
  if selDlg.Show = true then
    set ObjFiles = Obj.Files
    obj.Permissions = SysadminPermissions
    for each file in selDlg.Objects.Files
        If not ObjFiles.Has(file.FileName) then 
          Set NewObjFile = ObjFiles.AddCopy(file, file.FileName)
        End If
    next
    obj.Update
    'MsgBox selDlg.Objects.CellValue(0,0) ' Sheet
  end if
end sub  
'=============================================
Sub BTN_ORDERS_DOC_OnClick()
     Set SelObjDlg = ThisApplication.Dialogs.SelectDlg'SelectObjectDlg 
     SelObjDlg.Prompt = "Выберите один или несколько документов:"
      set Qr = ThisApplication.Queries("QUERY_ORDERS_DOC")
      qr.Parameter("PARAM0") = thisObject.Handle
      SelObjDlg.SelectFrom = Qr.Sheet
    
     RetVal = SelObjDlg.Show 
     Set ObjCol = SelObjDlg.Objects.Objects
     If (RetVal<>TRUE) Or (ObjCol.Count=0) Then Exit Sub
    
     For Each obj In ObjCol
         call AddResDoc(obj)   
     Next
     SetAllDocs(thisObject)
End Sub
'=============================================
Sub BTN_CHECKOUT_OnClick()
  Set s = thisForm.Controls("QUERY_KD_FILES_IN_DOC").ActiveX
  If s.SelectedItem < 0 Then 
     msgbox "Не выбран файл!"
     Exit Sub 
  end if  
  for i = 0 to s.Count-1 ' для всех выделенных файлов
      if s.IsItemSelected(i) then
        set File = s.ItemObject(i) 
          File_CheckOutAndLock(file)
      end if  
  next
End Sub
'=============================================
Sub BTN_CHECKIN_OnClick()
  Set s = thisForm.Controls("QUERY_KD_FILES_IN_DOC").ActiveX
  If s.SelectedItem < 0 Then 
     msgbox "Не выбран файл!"
     Exit Sub 
  end if  
  for i = 0 to s.Count-1 ' для всех выделенных файлов
      if s.IsItemSelected(i) then
        set File = s.ItemObject(i) 
        call File_CheckIN(file, "FILE_KD_ANNEX")  
      end if  
  next
End Sub

'=============================================
Sub QUERY_KD_FILES_IN_DOC_DblClick(iItem, bCancelDefault)
  Set s = thisForm.Controls("QUERY_KD_FILES_IN_DOC").ActiveX
  set File = s.ItemObject(iItem) 
  File_CheckOut(file)
  bCancelDefault = true
End Sub
