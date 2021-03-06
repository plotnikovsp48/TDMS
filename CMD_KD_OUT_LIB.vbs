'use CMD_KD_GLOBAL_VAR_LIB
'use CMD_KD_COMMON_LIB
'=============================================
Sub ATTR_KD_TCP_CellInitEditCtrl(nRow, nCol, pEditCtrl, bCancelEdit)
  if nCol = 0  then 
    pEditCtrl.comboitems = SetAutoComp
  elseif nCol = 1 then
     set rows = thisObject.Attributes("ATTR_KD_TCP").Rows
     set cord = nothing
     if nRow < Rows.Count then 
       set cord = rows(nRow).Attributes(0).Object
     end if
     pEditCtrl.comboitems = SetPersAutoComp(cord, true)
'    set contr = thisObject.Attributes("ATTR_KD_CPNAME").Object
'    if not contr is nothing then exit sub ' если контрагент задан, что не меняем
'   
'    set user = thisObject.Attributes("ATTR_KD_CPADRS").Object
'    if user is nothing then exit sub
'    set userContr = user.Attributes("ATTR_COR_USER_CORDENT").object
'    if userContr is nothing then exit sub
'    thisObject.Attributes("ATTR_KD_CPNAME").object = userContr
'    SetPersAutoComp()
'    thisForm.Refresh
  end if  
  thisForm.Refresh

End Sub
'=============================================
function SetAutoComp()
  set SetAutoComp =  nothing 
  if  not IsExistsGlobalVarrible("CompAuto") then 
    Set query = ThisApplication.Queries("QUERY_KD_CORDENT")
    set res = query.Objects
    call SetObjectGlobalVarrible("CompAuto", res)
  end if 
  set SetAutoComp = GetObjectGlobalVarrible("CompAuto")
end function
'=============================================
function SetPersAutoComp(cordent, reRead)
  set SetPersAutoComp = nothing
  if  not IsExistsGlobalVarrible("PersAuto") or  reRead then 
    set result = GetPersQuery(cordent)
    call SetObjectGlobalVarrible("PersAuto", result)
  end if
  set SetPersAutoComp = GetObjectGlobalVarrible("PersAuto")
end function
'=============================================
function GetPersQuery(cordent)
    set GetPersQuery = nothing
    Set query = nothing 
    if cordent is nothing then 
      Set query = ThisApplication.Queries("QUERY_ALL_PERSON")
    else  
      Set query = ThisApplication.Queries("QUERY_GET_USER_BY_CONTRAGENT")
      query.Parameter("PARAM0") = "= "& cordent.handle
    end if
    if not query is nothing then _
        set GetPersQuery = query.Objects
end function
'=============================================
Sub ATTR_KD_TCP_CellEditButtonClick(nRow, nCol, bCancel)
  if nCol = 0 or nCol=1 then bCancel = true  
End Sub
'=============================================
Sub Form_TableAttributeChange(Form, Object, TableAttribute, TableRow, ColumnAttributeDefName, OldTableRow, Cancel)
  if ColumnAttributeDefName = "ATTR_KD_CPNAME" then 
    set contr =  TableRow.Attributes(ColumnAttributeDefName).Object
    set users = SetPersAutoComp(contr, true)
'    Set ctrl = thisForm.Controls("ATTR_KD_CPADRS").ActiveX
    if contr is nothing then 
        'thisForm.Attributes("ATTR_KD_CPADRS").Value = ""
        TableRow.Attributes("ATTR_KD_CPADRS").Value = ""
    else
      if users.Count = 1 then 
        if  CheckCordent(thisObject, users(0), TableRow) then _
            TableRow.Attributes("ATTR_KD_CPADRS").Value = users(0)
      elseif users.Count = 0 then 
       msgbox "Невозможно добавить контрагента " & contr.Description & _
          " в текущий исходящий документ " & thisObject.Description & ", т.к. для него не задано ни одно контактное лицо", vbExclamation
        TableRow.Attributes("ATTR_KD_CPNAME").Value = ""
        TableRow.Attributes("ATTR_KD_CPADRS").Value = ""
        cancel = true  
        form.Refresh
      else
        TableRow.Attributes("ATTR_KD_CPADRS").Value = ""
      end if
    end if
  end if
  if ColumnAttributeDefName = "ATTR_KD_CPADRS" then 
    set user =  TableRow.Attributes(ColumnAttributeDefName).Object
    if  not user is nothing then 
      if not CheckCordent(thisObject, user,TableRow) then
        TableRow.Attributes("ATTR_KD_CPNAME").Value = ""
        TableRow.Attributes("ATTR_KD_CPADRS").Value = ""
        Cancel = true  
      else
        if TableRow.Attributes("ATTR_KD_CPNAME").Value = ""  then 
          set contr = user.Attributes("ATTR_COR_USER_CORDENT").object
          if not contr is nothing then  _
              TableRow.Attributes("ATTR_KD_CPNAME").Value  = contr
        end if
      end if
    end if
  end if
End Sub

'=============================================
function CheckCordent(DocObj, cordent,TableRow)
  CheckCordent = false 
    if cordent is nothing then exit function
    
    Set ReplyRows = DocObj.Attributes("ATTR_KD_TCP").Rows

    'Проверка нет ли добавляемого получателя в списке
    if not  IsExistsObjItemColWithoutRow(ReplyRows,cordent, "ATTR_KD_CPADRS",TableRow)then  
      CheckCordent = true
    else
'      msgBox "Полуатель " & CorDent.Description & " уже есть в списке. Добавление не будет произведено.", _
'              vbInformation,"Получатель не добавлен!"
    end if   

end function
'=============================================
Sub BTN_CREATE_WORD_OnClick()
  thisObject.saveChanges 0
  select case  thisObject.ObjectDefName
    case "OBJECT_KD_DOC_OUT" txt = ThisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "checkOutDoc", thisObject)
    case "OBJECT_KD_MEMO"   txt = ThisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "CheckMemoField", thisObject)
'    case "OBJECT_KD_DOC_IN"   call SetGlobalVarrible("ShowForm", "FORM_ID_CARD")
    case "OBJECT_KD_DIRECTION"   txt = ThisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "CheckOPDField", thisObject)
  end select   

 ' txt = ThisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "checkOutDoc", thisObject)
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
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  if Attribute.AttributeDef.SysName = "ATTR_KD_SIGNER" then 
    if attribute.Value <> "" then 
      if not  obj.Attributes("ATTR_KD_CHIEF").User is nothing then 
        if attribute.User.SysName = obj.Attributes("ATTR_KD_CHIEF").User.SysName then 
          msgbox "Невозможно установить Подписанта, того же сотрудника, что указан в поле Руководитель", _
              vbCritical, "Невозможно установить Подписанта"
          cancel = true
          exit sub    
        end if
      end if
      'отдел
      set dept = Get_Dept(Attribute.User)
      if dept is nothing then 
          msgbox "Для " & Attribute.User.Description & " не задан отдел. ", VbCritical, "Не возможно создать документ!"
          Cancel = true
          exit sub
      end if
      if thisObject.Attributes("ATTR_KD_DEPART").Value <> dept.Description then 
        thisObject.Attributes("ATTR_KD_DEPART").Value = dept
        thisForm.Attributes("ATTR_KD_DOC_PREFIX").Value = Get_Prifix(thisObject) 
        thisForm.Refresh
      end if 
    end if
  end if
  if Attribute.AttributeDef.SysName = "ATTR_KD_CHIEF" then 
    if attribute.Value <> "" then 
      if not  obj.Attributes("ATTR_KD_SIGNER").User is nothing then 
        if attribute.User.SysName = obj.Attributes("ATTR_KD_SIGNER").User.SysName then 
          msgbox "Невозможно установить Руководителя, того же сотрудника, что указан в поле Подписант", _
              vbCritical, "Невозможно установить Руководителя"
          cancel = true
          exit sub    
        end if
      end if
      set exec = thisObject.Attributes("ATTR_KD_EXEC").User
      if not CheckChief(Attribute.User, exec) then 
        cancel = true
        exit sub
      end if  
      ' добавляем права при смене начальника
      Set_Permission (Obj)
    end if
  end if
  if Attribute.AttributeDef.SysName = "ATTR_KD_EXEC" then 
    if attribute.Value <> "" then 
      set chief  = thisObject.Attributes("ATTR_KD_CHIEF").User
      if not CheckChief(chief, Attribute.User) then 
        cancel = true
        exit sub
      end if  
      ' добавляем права при смене начальника
      Set_Permission (Obj)
    end if
  end if
End Sub
'=============================================
function CheckChief(controler,exec)
  CheckChief = true 
  if controler is nothing or exec is nothing then exit function

  if controler.SysName <> exec.SysName then exit function
  if not controler.Groups.Has("GROUP_LEAD_DEPT") and _
    not controler.Groups.Has("GROUP_CHIEFS") then 
      msgbox  "Вы не входите в группу руководства или начальников отделов и и не можете быть и исполнителем и руководителем." ,_
           vbCritical, "Не возможно задать руководителя!" 
      CheckChief = false
      exit function
  end if  
end function

'=============================================
Sub BTN_EDIT_PERS_OnClick()
  set s = thisForm.Controls("ATTR_KD_TCP").ActiveX
  if s.SelectedRow >= thisForm.Controls("ATTR_KD_TCP").value.Count then exit sub
  if s.SelectedColumn = 1 then 
    set cor = thisForm.Controls("ATTR_KD_TCP").value(s.SelectedRow).Attributes("ATTR_KD_CPADRS").Object
  else
    set cor = thisForm.Controls("ATTR_KD_TCP").value(s.SelectedRow).Attributes("ATTR_KD_CPNAME").Object
  end if
  if cor is nothing then exit sub
'  if s.SelectedRow < 0 then exit sub   
'  ar = thisapplication.Utility.ArrayToVariant(Thisform.Controls("QUERY_COR_GET_CORDENTs").SelectedItems)
'   
'  set cor = Thisform.Controls("ATTR_KD_TCP").value.RowValue(ar(0))
  if cor.Permissions.Edit = 0 then 
    msgbox "У Вас нет прав на редактирование " & Cor.Description, vbExclamation, "Редактирование не доступно"
    exit sub
  end if
  frmName = thisForm.SysName
  RemoveGlobalVarrible("ShowForm")

  Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
  EditObjDlg.Object = cor
  EditObjDlg.Show  
  call SetGlobalVarrible("ShowForm",frmName)

End Sub
'=============================================
function CheckOutDoc()
  CheckOutDoc = false 
  str = "" 
  'проверить наличие скана
  set scan = thisApplication.ExecuteScript("CMD_KD_FILE_LIB", "GetFileByTypeByObj","FILE_KD_SCAN_DOC", thisObject)
  if scan is nothing then _
    str = str & "Скан документа не приложен" & vbNewLine

  if thisObject.Attributes("ATTR_KD_NUM").Value = "" or thisObject.Attributes("ATTR_KD_ISSUEDATE").Value = "" then _
    str = str & "Документ не зарегистрирован" & vbNewLine

  if str = "" then 
    CheckOutDoc = true
  else
      msgbox str, vbCritical,"Отправка отменена"
  end if  
end function

'=============================================
function SendToOutlook()
  SendToOutlook = false
 
 'Получение списка адресов
  Addr = GetAddrToMail(thisObject)
  if Addr="" then
      MsgBox "Ни для одного получателя не задан тип отправки по электронной почте. Письмо не будет создано", vbCritical,"Ошибка!"
      exit function
  end if
  
  tempFolder = "c:\TDMS\COR\" & thisObject.Attributes("ATTR_KD_IDNUMBER").Value
'  if not CreateForldersHierachy(tempFolder) then exit function
  if not ThisApplication.ExecuteScript("CMD_KD_FILE_LIB","CreateForldersHierachy",tempFolder) then exit function


  'проверить наличие скана
'  set scan = GetFileByType("FILE_KD_SCAN_DOC")
  set scan = thisApplication.ExecuteScript("CMD_KD_FILE_LIB", "GetFileByTypeByObj","FILE_KD_SCAN_DOC", thisObject)

  if scan is nothing then
    msgbox "Скан документа не приложен", vbCritical,"Отправка отменена"
    exit function
  else
    scan.CheckOut tempFolder & "\" & scan.FileName
  end if

   'выгрузить прложения
  for each file  in thisObject.Files
    if file.FileDefName = "FILE_KD_ANNEX" then 
      File.CheckOut tempFolder & "\" & File.FileName 
    end if
  next
  'открыть аутлук
  if not openOutLook(Addr,tempFolder) then exit function
  thisObject.Attributes("ATTR_KD_ID_SENDDATE").Value = Now
  SendToOutlook = true
end function

'=============================================
function GetAddrToMail(letter)
  const Delimeter = ";" 'Разделитель адресов
     set rows = letter.Attributes("ATTR_KD_TCP").Rows
     Result = ""
     
     for i=0 to rows.Count-1 
       set corUser = rows(i).Attributes("ATTR_KD_CPADRS").Object
       if not corUser is nothing then  
         if corUser.Attributes("ATTR_CORR_ADD_EMAIL").Value <>"" then 
              Result = Result & corUser.Attributes("ATTR_CORR_ADD_EMAIL").Value & Delimeter
         end if 
       end if   
     next
     GetAddrToMail = Result
end function

'=============================================
function openOutLook(Addr,tempFolder)

  openOutLook = false
  'Получить объект Outlook, если он загружен
  On Error Resume Next
  Set oOutlookApp = nothing 
  Set oOutlookApp = GetObject(, "Outlook.Application")
  If oOutlookApp is nothing Then
    if err.Number <> 0 then err.Clear
    'Outlook не загружен, запускаем его из кода
    Set oOutlookApp = CreateObject("Outlook.Application")
    'bStarted = True
  End If
  if oOutlookApp is nothing or err.Number <> 0 then 
    msgbox "Не удалось открыть OutLook." & vbNewLine & err.Description, vbCritical, "Ошибка"
    if err.Number <> 0 then err.Clear
    exit function
  end if
  On Error goto 0
  
  Set oItem = oOutlookApp.CreateItem(olMailItem)            
  'Устанавливаем адрес для нового письма
  oItem.To = Addr
  oItem.Display
  'Устанавливаем заголовок 
  oItem.Subject = "№ " & thisObject.Attributes("ATTR_KD_DOC_PREFIX").Value & "\" & thisObject.Attributes("ATTR_KD_NUM").Value & _
      thisObject.Attributes("ATTR_KD_SUFFIX").Value & " от " & _
      left(thisObject.Attributes("ATTR_KD_ISSUEDATE").Value,10) & " - "& thisObject.Attributes("ATTR_KD_TOPIC").Value
  txt = oItem.HTMLBody
  ind = inStr(1,txt,"<body",1)
  ind2 = inStr(ind,txt,">",vbTextCompare)
  nTxt = "<body>Добрый день!" & "<br></span>" & _
      "Направляю исходящее письмо" & "<br></span>" & _
      "Просьба подтвердить получение и присвоить входящий номер" & "<br><br></span>"
  txt = left(txt, ind-1) & nTxt & Mid(txt, ind2 +1 )
  oItem.HTMLBody = txt
  'Добавить основной файл к письму
  
  Set FSO = CreateObject("Scripting.FileSystemObject")
  if FSO.FolderExists(tempFolder) then 
      ' EV прикладываем приложения
        set objFolder = FSO.GetFolder(tempFolder)
        Set objFiles = objFolder.Files
        for each CurFile in objFiles
            oItem.Attachments.Add CurFile.Path
        next

  end if
  oItem.Display
  openOutLook = true
end function
'=================================
function Set_Send_Info(obj)
  Set_Send_Info = false 
  Set frmSetShelve = ThisApplication.InputForms("FORM_KD_SEND_INFO")
  for each control in frmSetShelve.Controls
    if control.Type = "EDIT" then 
      if obj.Attributes.Has(control.Name) then _
        frmSetShelve.Attributes(control.Name).Value = obj.Attributes(control.Name).value
    end if    
  next
  If frmSetShelve.Show Then
    for each control in frmSetShelve.Controls
      if control.Type = "EDIT" then 
        if obj.Attributes.Has(control.Name) then _
          obj.Attributes(control.Name).value = frmSetShelve.Attributes(control.Name).Value  
      end if    
    next

'    obj.Attributes("ATTR_KD_ID_SENDDATE").Value = frmSetShelve.Attributes("ATTR_KD_ID_SENDDATE").Value
'    obj.Attributes("ATTR_KD_SEND_NO").Value = frmSetShelve.Attributes("ATTR_KD_SEND_NO").Value
'    obj.Attributes("ATTR_KD_KONTR_NO").Value = frmSetShelve.Attributes("ATTR_KD_KONTR_NO").Value
    obj.Update
    Set_Send_Info = true
  end if  
end function  

'=================================
function Set_Doc_Send(isEmail)
  Set_Doc_Send = false 
  if not isEmail then if not Set_Send_Info(thisObject) then exit function
'    if Set_Send_Info(thisObject)  then 
      'поменять статус
        thisObject.Status = thisApplication.Statuses("STATUS_SENT")
        thisObject.Update
      ' закрыть все поручения подготовить
        call thisApplication.ExecuteScript("CMD_KD_ORDER_LIB", "clouseAllOrderByRes", thisObject, "NODE_TO_PREPARE")
        'закрыть все поручения цепочки по ВД
        CloseChainOrders()
        Set_Doc_Send = true
 '   end if 
end function

'=================================
sub CloseChainOrders
  thisApplication.Utility.WaitCursor = true
  set qry = thisApplication.Queries("QUERY_KD_EXEC_ORDER_BY_OD")
  qry.Parameter("PARAM0") = thisObject.Handle
  set Objs = qry.Objects
  for each order in objs
    CloseInDocOrder(order)
    set par = order.parent
    while not par is nothing
      if par.ObjectDefName = "OBJECT_KD_ORDER_REP" then  
        CloseInDocOrder(par)
        set par = par.parent
      else
        set par = nothing
      end if  
    Wend
  next
  thisApplication.Utility.WaitCursor = false
end sub
'=================================
sub CloseInDocOrder(order)
  order.permissions = SysAdminPermissions
  if order.StatusName = "STATUS_KD_ORDER_DONE" or order.StatusName = "STATUS_KD_OREDR_CANCEL" then exit sub

  if order.StatusName = "STATUS_KD_ORDER_SENT" or order.StatusName = "STATUS_KD_ORDER_IN_WORK" then 
      order.attributes("ATTR_KB_POR_RESULT").value =  "Отправлен ИД № " & thisObject.Description
  end if
' добавляем результитующий документ
  set ReplyRows = order.Attributes("ATTR_KD_POR_RESDOC").Rows
  if not thisApplication.ExecuteScript("CMD_KD_COMMON_LIB", "IsExistsObjItemCol",ReplyRows,thisObject,0) then
      call thisApplication.ExecuteScript("CMD_KD_COMMON_LIB", "AddResDocFiles", order, thisObject, "", false)   
  end if   
  call thisApplication.ExecuteScript("CMD_KD_ORDER_LIB", "SetAllDocs",order)
  call thisApplication.ExecuteScript("CMD_KD_ORDER_LIB", "SetOrderDone",order,"Отправлен ИД", "Выполнено") 
end sub
