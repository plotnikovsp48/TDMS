use CMD_KD_COMMON_LIB
use CMD_KD_FILE_LIB
use CMD_KD_COMMON_BUTTON_LIB  
use CMD_KD_REGNO_KIB
use CMD_KD_SET_PERMISSIONS

'=============================================
Sub Form_BeforeShow(Form, Obj)
  ShowUsers()
  ShowFileName()
  SetControlsEnable()
'  msgbox GetRecipiend
End Sub

'=============================================
sub SetControlsEnable()
  isAproving = thisObject.StatusName = "STATUS_KD_AGREEMENT"
  isExec = IsExecutor(thisApplication.CurrentUser, thisObject)
  isContr = IsController(thisApplication.CurrentUser, thisObject)
  isApr = IsAprover(thisApplication.CurrentUser, thisObject)
  isSecr = isSecretary(thisApplication.CurrentUser)
  isSign = IsSigner(thisApplication.CurrentUser, thisObject)
  isCanEd = isCanEdit()
  stSinged = thisObject.StatusName = "STATUS_SIGNED"
  stSigning = thisObject.StatusName = "STATUS_SIGNING"
  thisForm.Controls("BTN_CREATE_WORD").Enabled = ((isExec or isContr) and isCanEd)
  thisForm.Controls("BTNAPPWORD").Enabled = ((isExec or isContr) and isCanEd)
  thisForm.Controls("CMD_KD_REG_DOC").Enabled = (isSecr or isSign) and stSigning
  thisForm.Controls("CMD_RETURN_TO_WORK").Enabled = ((isSecr or isSign) and stSigning)
  thisForm.Controls("CMD_KD_APP_SCAN").Enabled = ((isSecr or isSign) and (stSigning or stSinged))
  thisForm.Controls("BTN_CANCEL_DOC").Enabled = ((isSecr or isSign) and stSigning) _
    or ((isExec or isContr) and isCanEd)
  thisForm.Controls("CMD_SEND_DOC").Enabled = ((isSecr or isSign) and stSinged)
  thisForm.Controls("BTN_OUTLOOK").Enabled = ((isSecr or isSign) and _ 
        (stSinged or stSinged or thisObject.StatusName = "STATUS_SENT"))
  thisForm.Controls("BTN_SEND_INFO").Enabled = ((isSecr or isSign) and _
        (stSinged or thisObject.StatusName = "STATUS_SENT") )
  thisForm.Controls("BTN_CHECKOUT").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
  thisForm.Controls("BTN_CHECKIN").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
  thisForm.Controls("BTN_LOAD_FILE").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
  thisForm.Controls("BTN_DEL_APP").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
  thisForm.Controls("BTN_FROM_ORDERS").Enabled = (isApr and isAproving) or ((isExec or isContr) and isCanEd)
  thisForm.Controls("BTN_SEND_TO_CHECK").Enabled = isExec and thisObject.StatusName = "STATUS_KD_DRAFT"

end sub
'=============================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  if form.Controls.Has("TXT_" & Attribute.AttributeDefName) then ShowUser(Attribute.AttributeDefName)
  
  if Attribute.AttributeDef.SysName = "ATTR_KD_CHIEF" then ' добавляем права при смене начальника
    Set_Permission (Obj)
  end if
End Sub

'=============================================
Sub BTN_DEL_SINGER_OnClick()
   Del_User("ATTR_KD_SIGNER")
End Sub
'=============================================
Sub BTN_DEL_CHIEF_OnClick()
   Del_User("ATTR_KD_CHIEF")
End Sub

'=============================================
Sub BTN_CREATE_WORD_OnClick()
  call createWord()
End Sub

'=============================================
Sub BTNAPPWORD_OnClick()
    LoadFileToDoc("FILE_KD_WORD")
    ShowFileName()
   ' msgBox "Файл приложен"
End Sub


'=============================================
Sub BTNOPEN_OnClick()
    'OpenWordFile()
    Word_Check_Out()
End Sub


'=============================================
Sub ATTR_KD_CONF_Modified()
    thisForm.Attributes("ATTR_KD_DOC_PREFIX").Value = Get_Prifix(thisObject) 
    thisForm.Refresh
End Sub

'=============================================
Sub BTN_SEND_INFO_OnClick()
  call Set_Send_Info(thisObject)
End Sub

'=============================================
Sub BTN_CANCEL_DOC_OnClick()
  set_Doc_Cancel
End Sub

'=============================================
Sub BTN_OUTLOOK_OnClick()

  if not SendToOutlook() then exit sub
  
  thisObject.Attributes("ATTR_KD_ID_SENDDATE") = Now
  thisObject.Status = thisApplication.Statuses("STATUS_SENT")
  thisObject.Update
'  msgbox "Документ отправлен!"

End Sub

'=============================================
Sub BTN_SEND_TO_CHECK_OnClick()
  send_To_Check()
End Sub

'=============================================
Sub BTN_CHECKOUT_OnClick()
  Word_Check_Out()
End Sub

'=============================================
Sub BTN_CHECKIN_OnClick()
  Word_Check_IN()
End Sub

'=============================================
function GetRecipiend()
  GetRecipiend = ""
  set rows = thisObject.Attributes("ATTR_KD_TCP").Rows
  if rows.Count = 0 then exit function
  for each row in rows
    set cordent = row.Attributes("ATTR_KD_CPADRS").Object
    set org = row.Attributes("ATTR_KD_CPNAME").Object
    if not cordent is nothing  and not org is nothing then 
        if i>0 then GetRecipiend = GetRecipiend & chr(13) ' EV отделяем строки
        GetRecipiend = GetRecipiend & cordent.Attributes("ATTR_COR_USER_POS_DP").Value & chr(13)
        GetRecipiend = GetRecipiend & org.Attributes("ATTR_CORDENT_NAME").Value & chr(13)
        GetRecipiend = GetRecipiend & cordent.Attributes("ATTR_COR_USER_SHORT").Value & " "   _
                        & cordent.Attributes("ATTR_COR_USERNAME_DP").Value & chr(13) 
        if trim(cordent.Attributes("ATTR_CORR_ADD_ADDRESS").Value) <> "" then 
            GetRecipiend = GetRecipiend & "Адрес: " & trim(cordent.Attributes("ATTR_CORR_ADD_ADDRESS").Value) & chr(13) 
        end if 
        if trim(cordent.Attributes("ATTR_CORR_ADD_TELEFON").Value) <> "" or trim(cordent.Attributes("ATTR_CORR_ADD_FAX").Value) <> "" then 
            GetRecipiend = GetRecipiend & "Телефон/факс: " & trim(cordent.Attributes("ATTR_CORR_ADD_TELEFON").Value) _
            & " " & trim(cordent.Attributes("ATTR_CORR_ADD_FAX").Value) & chr(13) 
        end if
        GetRecipiend = GetRecipiend & "E-mail: " & cordent.Attributes("ATTR_CORR_ADD_EMAIL").Value & chr(13) 
    end if
  next
end function
'=============================================
function GetCall
  GetCall = ""
  set rows = thisObject.Attributes("ATTR_KD_TCP").Rows
  if rows.Count = 0 then exit function
  set UserRow = rows(0) 
  i = 0
  if rows.Count > 1 then
    for each row in rows
      if row.attributes("ATTR_TO_SEND").value = false then  
        i = i + 1
        set UserRow = row
      end if
    next
  end if
  if i > 1  then 
      GetCall = "Уважаемые господа,"
  else  
     if UserRow is nothing then exit function
     set cordent = UserRow.Attributes("ATTR_KD_CPADRS").Object
     if cordent is nothing then exit function
    
    ' if cordent.Attributes
  end if  
end function

'=============================================
Sub QUERY_KD_FILES_IN_DOC_DblClick(iItem, bCancelDefault)
  Set s = thisForm.Controls("QUERY_KD_FILES_IN_DOC").ActiveX
  set File = s.ItemObject(iItem) 
  'File_CheckOut(file)
  File_CheckOutAndLock(file)  
  bCancelDefault = true
End Sub

'=============================================
Sub BTN_FROM_ORDERS_OnClick()
  call thisApplication.ExecuteScript("FORM_KD_EXCUTION","AddFiles","QUERY_DOC_ORDER_FILES", thisObject)
End Sub

'=============================================
Sub TDMSEDIT1_BeforeAutoComplete(text)
  set dict = thisForm.Dictionary
  Set ctrl = thisForm.Controls("TDMSEDIT1").ActiveX
  
  ' Если ввели 3 буквы и более
  if Len(text)>0 then
  
    ' Перезачитывать выборку будем только, если поменялось слово с предыдущего поиска
    ' будем хранить последнюю строку поиска в "prev" элементе словаря
    
    doQuery = false
    if dict.Exists("prev") then
      prev = dict("prev")
      if not InStr(text, prev)>0 then
        doQuery = true
      end if
    else 
      doQuery = true
    end if
    
    if doQuery = true then
      Set query = ThisApplication.Queries("QUERY_USER_LIST")

      set result = query.Users 'Objects
      
      ctrl.ComboItems = result ' реализовано в 5.0.286
      dict("prev") = text      
      
      ' Отладочный вывод, в реальном приложении убрать
'      thisApplication.AddNotify ("поиск: ") & text & " (" & result.Count & "записей)"
    end if

 else 
    ' Установим пустой массив, чтобы не запустился автокомлит tdms.
    ctrl.comboItems = Array()
    ' И сбросим флаг, чтобы перезапустилась выборка
    if dict.Exists("prev") then
           dict.Remove("prev")
    end if
  end if


End Sub
'=============================================

Sub ATTR_KD_EXEC_BeforeAutoComplete(Text)
End Sub
'=============================================
Sub TDMSEDIT1_Modified()
'  thisApplication.AddNotify  "TDMSEDIT1_Modified"
  thisObject.Attributes("ATTR_KD_CHIEF").Value = thisForm.Controls("TDMSEDIT1").Value
  'ShowUser("ATTR_KD_CHIEF")
  set user = thisObject.Attributes("ATTR_KD_CHIEF").User
  thisForm.Controls("TDMSEDIT1").Value = user.Description & " - " & user.Position 
  set a = thisForm.Controls("TDMSEDIT1").ActiveX
'  .WordWrap = 1
End Sub
