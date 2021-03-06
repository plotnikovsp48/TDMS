use CMD_KD_SET_PERMISSIONS
use CMD_KD_REGNO_KIB
use CMD_KD_FOLDER
use CMD_KD_USER_PERMISSIONS
use CMD_KD_FILE_LIB
use CMD_LIBRARY
use CMD_KD_CURUSER_LIB

'==============================================================================
function CreateOrders( orderObj, docObj )
  CreateOrders = false
  ThisScript.SysAdminModeOn
  set objType = ChoiceType()
  if objType is nothing then exit function
  CreateOrders = CreateTypeOrder( orderObj, docObj, objType)
  
end function

'==============================================================================
' заполняем атрибуты формы значениями из поручения
sub SetFormAttr(frmOrder,orderObj)
 for each attr in orderObj.Attributes
    attrName = attr.AttributeDefName
    if frmOrder.Attributes.Has(attrName) then 
      if attrName <> "ATTR_KD_RESOL" and attrName <>"ATTR_KD_TEXT" and attrName <> "ATTR_KD_CONTR" and sttrName <> "ATTR_KD_AUTH" then _
        frmOrder.Attributes(attrName) = orderObj.Attributes(attrName)
    end if    
  next
end sub

'==============================================================================
function CreateTypeOrder(orderObj, docObj, objType)
  CreateTypeOrder = CreateTypeOrderToUser(orderObj, docObj, objType, nothing)
end function
'==============================================================================
function CreateTypeOrderToUser(orderObj, docObj, objType, ToUser)
    CreateTypeOrderToUser = CreateTypeOrderToUserResol(orderObj, docObj, objType, ToUser,"")
end function
'==============================================================================
function CreateTypeOrderToUserResol(orderObj, docObj, objType, ToUser, resTxt)
    ThisScript.SysAdminModeOn
    CreateTypeOrderToUserResol = false
    Set frmOrder = ThisApplication.InputForms("FORM_KD_ORDER_CREATE")

   
    if not orderObj is nothing then  
        call SetFormAttr(frmOrder,orderObj)
        frmOrder.Attributes("ATTR_KD_ORDER_BASE").Object = orderObj
        frmOrder.Attributes("ATTR_KD_CONTR").Value = ""
        frmOrder.Attributes("ATTR_KD_AUTH").Value = "" 
    end if     
    if resTxt = "" then 
      frmOrder.Attributes("ATTR_KD_RESOL").Value = objType.AttributeDefs("ATTR_KD_RESOL").Value 
    else 
      frmOrder.Attributes("ATTR_KD_RESOL").Value = resTxt
    end if
    if not docObj is nothing then  
        frmOrder.Attributes("ATTR_KD_DOCBASE").Object = docObj
        if docObj.Attributes.has("ATTR_KD_ZA_DATEPAYMENT") and not ToUser is nothing then 
            frmOrder.Attributes("ATTR_KD_RESOL").Value = thisApplication.Classifiers("NODE_CORR_REZOL").Classifiers.FindBySysId("NODE_TO_PAID")
            dat = docObj.Attributes("ATTR_KD_ZA_DATEPAYMENT").value
            if dat <> "" then frmOrder.Attributes("ATTR_KD_POR_PLANDATE").Value = dat
            set exec = docObj.Attributes("ATTR_KD_EXEC").user
            if not exec is nothing then 
              frmOrder.Attributes("ATTR_KD_AUTH").Value = exec
              frmOrder.Attributes("ATTR_KD_CONTR").Value = exec
            end if
        end if
    end if    
    if not toUser is nothing then 
       frmOrder.Attributes("ATTR_KD_OP_DELIVERY").Value = toUser 
    else
       frmOrder.Attributes("ATTR_KD_OP_DELIVERY").Value = ""    
    end if
    'Открытие транзакции
    If not ThisApplication.IsActiveTransaction Then  ThisApplication.StartTransaction
    If not frmOrder.Show Then
        'msgbox "Создание поручения отменено"
        exit function
    end if
    
    if orderObj is nothing  then ' EV если не задано поручение, то создаем в папке года
      Set parentObj = GET_FOLDER_OFFER("")  
      if parentObj is nothing then 
        msgbox "Не удалось создать папку для года!"
        exit function
      end if  
    else
      set parentObj = orderObj
    end if

    set rows = frmOrder.Attributes("ATTR_KD_ORDER_RECIPIEND").Rows
    for each row in rows
      set user = row.Attributes("ATTR_KD_OP_DELIVERY").user
      if not user is nothing then call CreateOrder(parentObj, frmOrder, user,objType)
    next
  CreateTypeOrderToUserResol = true
  ThisScript.SysAdminModeOff
end function

'==============================================================================
sub CreateOrder(parentObj, frmOrder, userTo,objType)

  'if userTo.SysName = thisApplication.CurrentUser.SysName then exit sub' самому себе не делаем 
'thisApplication.AddNotify "CreateOrder - " & cstr(timer)
  parentObj.Permissions = SysAdminPermissions
  Set CreatedObject = parentObj.Objects.Create(objType)
'thisApplication.AddNotify " parentObj.Objects.Create - " & cstr(timer)
'  Set_Permission CreatedObject' зачем дадавать права два раза
  for each attr in frmOrder.Attributes
    attrName = attr.AttributeDefName
    if CreatedObject.Attributes.Has(attrName) then 
        CreatedObject.Attributes(attrName) = frmOrder.Attributes(attrName)
    end if    
  next
  CreatedObject.Attributes("ATTR_KD_OP_DELIVERY").user = userTo
'thisApplication.AddNotify "setAttr - " & cstr(timer)
  
  CreatedObject.Status = thisApplication.Statuses("STATUS_KD_ORDER_SENT") 'Выдано
'thisApplication.AddNotify "Status - " & cstr(timer)
 thisApplication.DebugPrint  "Status - " & cstr(timer)
  CreatedObject.update
 thisApplication.DebugPrint  "update - " & cstr(timer)
  'CreatedObject.saveChanges 4096'61440'16384
'thisApplication.AddNotify "update - " & cstr(timer)
  Set_Permission CreatedObject
'thisApplication.AddNotify "end create - " & cstr(timer)
end sub

'==============================================================================
function ChoiceType()
    set ChoiceType = nothing
        dim OrderTypesArray(2)  
    OrderTypesArray(1)= thisApplication.ObjectDefs("OBJECT_KD_ORDER_REP").Description '"Поручение Оповещение"
    OrderTypesArray(0)= thisApplication.ObjectDefs("OBJECT_KD_ORDER_NOTICE").Description'"Поручение Исполнение"

    Set SelDlg = ThisApplication.Dialogs.SelectDlg
    SelDlg.SelectFrom = OrderTypesArray
    SelDlg.Caption = "Выбор типа поручения"
    SelDlg.Prompt = "Выберите тип поручения:"
    
    RetVal = SelDlg.Show
      
    'Если пользователь отменил диалог или ничего не выбрал, закончить работу.
    If ( (RetVal <> TRUE) or (UBound(SelDlg.Objects)<0) ) Then  
      exit function
    end if
   
    SelectedArray = SelDlg.Objects  
    if SelectedArray(0) = "" then exit function

    set ChoiceType = thisApplication.ObjectDefs(SelectedArray(0))

end function

'==============================================================================
function CreateSystemOrder( docObj, objType, userTo, userFrom, resol, txt,planDate)
set CreateSystemOrder = CreateOrderadnShow( docObj, objType, userTo, userFrom, resol, txt,planDate, false)
'  set CreateSystemOrder = CreateSystemOrderTxt( docObj, objType, userTo, userFrom, resol, "")
'end function
'' создать системное поручение с комментарием
''==============================================================================
'function CreateSystemOrderTxt( docObj, objType, userTo, userFrom, resol, txt)
'thisApplication.AddNotify "CreateSystemOrder " & cStr(timer())
end function

function CreateOrderAdnShow( docObj, objType, userTo, userFrom, resol, txt,planDate, NeedToShow)
  ThisScript.SysAdminModeOn
  set CreateOrderAdnShow = nothing
  set resCl = thisApplication.Classifiers.FindBySysId(resol)
  if resCl  is nothing then exit function

  if userTo is nothing or userFrom is nothing then exit function ' если не задан кто-то
  
  if userTo.SysName = userFrom.SysName then exit function' самому себе не делаем

  
  Set parentObj = GET_FOLDER_OFFER("")  
  if parentObj is nothing then 
    msgbox "Не удалось создать папку для года!"
    exit function
  end if  
'thisApplication.AddNotify "parentObj " & cStr(timer())

  
  parentObj.Permissions = SysAdminPermissions
  Set CreatedObject = parentObj.Objects.Create(objType)
'thisApplication.AddNotify "parentObj.Objects.Create " & cStr(timer())
  Set_Permission CreatedObject
'thisApplication.AddNotify "Permission " & cStr(timer())


  CreatedObject.Attributes("ATTR_KD_OP_DELIVERY").user = userTo
  CreatedObject.Attributes("ATTR_KD_AUTH").user = userFrom
  CreatedObject.Attributes("ATTR_KD_DOCBASE").Object = docObj
  CreatedObject.Attributes("ATTR_KD_TEXT").value = resCl.Code & ": " & txt
  CreatedObject.Attributes("ATTR_KD_RESOL").classifier = resCl
  CreatedObject.Attributes("ATTR_KD_POR_PLANDATE").value = planDate
  attrName = "ATTR_KD_CONTR"
  if CreatedObject.Attributes.has(attrName) then 
      CreatedObject.Attributes(attrName).user = userFrom
  end if

' срочность, особая важность  
  if not docObj is nothing then 
    if docObj.Attributes.has("ATTR_KD_IMPORTANT") then _
      if docObj.Attributes("ATTR_KD_IMPORTANT").value then _
          CreatedObject.Attributes("ATTR_KD_IMPORTANT").value = docObj.Attributes("ATTR_KD_IMPORTANT").value
    if docObj.Attributes.has("ATTR_KD_URGENTLY") then _
      if docObj.Attributes("ATTR_KD_URGENTLY").value then _
          CreatedObject.Attributes("ATTR_KD_URGENTLY").value = docObj.Attributes("ATTR_KD_URGENTLY").value
  end if
  
  if NeedToShow then 
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = CreatedObject
    ans = CreateObjDlg.Show
    if ans then  
      set CreateOrderAdnShow = CreatedObject
    else 
      CreatedObject.erase
    end if
  else 
    CreatedObject.Status = thisApplication.Statuses("STATUS_KD_ORDER_SENT") 'Выдано
    CreatedObject.update
  'thisApplication.AddNotify "update " & cStr(timer())
    Set_Permission CreatedObject
    set CreateOrderAdnShow = CreatedObject
    'thisApplication.AddNotify "Permission " & cStr(timer())
  end if

  ThisScript.SysAdminModeOff
end function

''==============================================================================
'sub Aprove_Doc(docObj)
''ищем строку и поручение человека
'  set aprRow = Get_AproveRow(thisApplication.CurrentUser, docObj)
'  if aprRow is nothing  then exit sub
'  set aprOrder = aprRow.Attributes("ATTR_KD_LINK_ORDER").object
'  if aprOrder is nothing then 
'    msgbox "Согласование невозможно, т.к. не выдано поручение"
'    exit sub
'  end if
''  спрашиваем комментарий
'  Set noteDlg = ThisApplication.Dialogs.SimpleEditDlg
'    noteDlg.Caption = "Введите комментарий к согласованию"
'    noteDlg.Prompt = "Комментарий к согласованию"
'    If not noteDlg.Show Then exit sub
'' закрываем поручение 
'   call SetOrderDone(aprOrder,noteDlg.Text, "Согласовано") 
'   
'' проверяем все ли закрыто
'    call Set_DocAprDone(docObj)

'   thisForm.Close false
'end sub



'==============================================================================
sub SetOrderDone(orderObj,note, reason) 
  orderObj.permissions = SysAdminPermissions
  if orderObj.StatusName  = "STATUS_KD_ORDER_DONE"  or orderObj.StatusName  = "STATUS_KD_OREDR_CANCEL"  then exit sub ' усли уже выполено, выходим
'  orderObj.permissions = SysAdminPermissions
  if note > "" then _
      orderObj.Attributes("ATTR_KD_NOTE").value = note 'Примечание
  orderObj.Attributes("ATTR_KD_POR_REASONCLOSE").value = reason 'Причина закрытия
  orderObj.Attributes("ATTR_KD_POR_ACTUALDATE").value  = now ' Фактический срок исполнения
  orderObj.status = thisApplication.Statuses("STATUS_KD_ORDER_DONE")
  repText = ""
  if orderObj.Attributes.has("ATTR_KB_POR_RESULT") then _
    repText = note & " "& orderObj.Attributes("ATTR_KB_POR_RESULT").Value
    'note = note & " "& orderObj.Attributes("ATTR_KB_POR_RESULT").Value
  call thisApplication.ExecuteScript("CMD_KD_COMMON_LIB", "AddCommentTxt",orderObj,"ATTR_KD_HIST_NOTE", "Поручение выполнено: " & repText)
  orderObj.update
end sub

'==============================================================================
'sub Set_DocAprDone(docObj)
'  isAlldone = true
'  isRejected = false
'    Set TAttrRows = docObj.Attributes("ATTR_KD_TAPRV").Rows
'    for each row in TAttrRows
'      set aprOrder = row.Attributes("ATTR_KD_LINK_ORDER").object
'      if aprOrder is nothing then ' если нет поручения - выходим
'        isAllDone  = false
'        exit sub
'      end if  
'      if aprOrder.StatusName <> "STATUS_KD_ORDER_DONE" then ' если есть хоть одно без решения - ждем
'        isAllDone  = false
'        exit sub
'      end if  
'      if aprOrder.attributes("ATTR_KD_POR_REASONCLOSE").value <> "Согласовано" then ' если хоть одно не согласовано
'        isRejected = true
'        exit for
'      end if
'    next
'' сюда можно добавить обработку если есть одно не согласование
'  if not isRejected then 
'    ' закрываем согласование    
'     docObj.permissions = SysAdminPermissions  
'     docObj.Update
'    ' TODO для универсальности сюда можно добавить автоматическое определение следующего статус
'     select case docObj.ObjectDefName
'      case "OBJECT_KD_MEMO" 
'          docObj.Status = thisApplication.Statuses("STATUS_KD_APPROVAL")
'          msgBox "Документ согласован. Документ передан на утверждение."
'      case "OBJECT_KD_PROTOCOL"
'          if docObj.Attributes("ATTR_KD_PROT_TYPE").Classifier.SysName =  "NODE_KD_PROT_IN"  then 
'              docObj.Status = thisApplication.Statuses("STATUS_KD_REGIST")
'              'docObj.Update
'          end if
'          msgBox "Документ согласован."
'      case else 
'          docObj.Status = thisApplication.Statuses("STATUS_SIGNING")
'          msgBox "Документ согласован. Документ передан на подписание."
'    end select 
'    docObj.update
'    Set_Permission docObj
'  else 
'  ' возвращаем на доработку  
'    Set_DocReject(docObj) 
'  end if  

'end sub

'==============================================================================
sub Set_OrdersReaded(docObj)
  Set QueryDoc = thisApplication.Queries("QUERY_KD_UNREAD_ORDER_BY_DOC_BY_USER")
'  set us = thisApplication.CurrentUser.GetDelegatedRightsFromUsers()
  set cUser = GetCurUser()
  call Set_OrdersReadedByUser(docObj,cUser,QueryDoc)
' EV оставляем только под кем смотрит
'  if us.Count > 0 then 
'     'для замстителей
'    for each cUser in us
'      call Set_OrdersReadedByUser(docObj,cUser,QueryDoc)
'    next
'  end if
end sub
'==============================================================================
sub Set_OrdersReadedByUser(docObj,user,QueryDoc)
  QueryDoc.Parameter("PARAM0") = docObj.handle
  QueryDoc.Parameter("PARAM1") = User
  Set objs = QueryDoc.Objects
  if not objs is nothing then 
    if objs.Count >0 then 
      for each order in objs
       call Set_OrderReaded(order)
      next 
    end if 
  end if 
end sub
'==============================================================================
sub Set_OrderReaded(order)
  order.Permissions = SysAdminPermissions
  if order.StatusName <> "STATUS_KD_ORDER_SENT" or not fIsExecs(order) then exit sub ' если поручение уже обработано, выходим

  if order.Attributes.has("ATTR_KD_POR_ACCEPTED") then _
      order.Attributes("ATTR_KD_POR_ACCEPTED").value = now ' Принято к исполнению
  'TODO возможно добавить сюда универсальный механиз определения закрытия поручения
  'if order.ObjectDefName = "OBJECT_KD_ORDER_NOTICE" then ' Оповещение сразу закрываем
  if not order.Attributes.has("ATTR_SET_DONE_AFTER_READED") then exit sub
  
  if order.Attributes("ATTR_SET_DONE_AFTER_READED").Value then 
      call  SetOrderDone(order,"", "Прочтено") 
  else
      order.Status = thisApplication.Statuses("STATUS_KD_ORDER_IN_WORK")
  end if
  Set_Permission(order)
  order.update
end sub

'==============================================================================
'sub Reject_Doc(docObj)
'  'ищем строку и поручение человека
'  set aprRow = Get_AproveRow(thisApplication.CurrentUser, docObj)
'  if aprRow is nothing  then exit sub
'  set aprOrder = aprRow.Attributes("ATTR_KD_LINK_ORDER").object
'  if aprOrder is nothing then 
'    msgbox "Согласование невозможно, т.к. не выдано поручение"
'    exit sub
'  end if
''  спрашиваем комментарий
'  Set noteDlg = ThisApplication.Dialogs.SimpleEditDlg
'    noteDlg.Caption = "Введите причину отказа"
'    noteDlg.Prompt = "Причина отказа"
'    If not noteDlg.Show Then exit sub
'    if trim(noteDlg.Text) = "" then 
'      msgbox "Невозможно отклонить документ не указав причину." & vbNewLine & _
'        "Пожалуйста, введите причину отклонения", vbCritical, "Не задана причина отклонения!"
'      exit sub  
'    end if
'' закрываем поручение 
'   call SetOrderDone(aprOrder,noteDlg.Text, "Отклонено") 
'   
'  if thisApplication.Attributes("ATTR_KD_FIRST_REJECT").Value then 
'    '  если возвращаем сразу, отменяем документ
'    call Set_DocReject(docObj)
'  else  
' ' проверяем все ли закрыто
'    call Set_DocAprDone(docObj)  
'  end if 
'  thisForm.Close false
'end sub

'==============================================================================
sub Set_DocReject(docObj)
  ' иначе oтменяем все остальные поручения
  Set TAttrRows = docObj.Attributes("ATTR_KD_TAPRV").Rows
  for each row in TAttrRows
      set aprOrder = Row.Attributes("ATTR_KD_LINK_ORDER").object
      if aprOrder is nothing then  exit sub ' если нет поручения - выходим
      call Set_OrderCancel(aprOrder)
  next
  docObj.permissions = SysAdminPermissions
  docObj.status =  thisApplication.Statuses("STATUS_KD_DRAFT")
  docObj.update
  Set_Permission docObj
  msgbox "Документ отклонен"
end sub

'==============================================================================
sub Set_OrderCancel(order)
  order.Permissions = SysAdminPermissions
  if order.StatusName = "STATUS_KD_ORDER_DONE" then exit sub ' если поручение уже выполнено, отменять нельзя

  order.Attributes("ATTR_KD_POR_REASONCLOSE").value = "Отменено"
  order.Attributes("ATTR_KD_POR_ACTUALDATE").value  = now ' Фактический срок исполнения
  call SendCancEmail(order)
  order.Status = thisApplication.Statuses("STATUS_KD_OREDR_CANCEL")
  order.update
end sub
'==============================================================================
sub SendCancEmail(order)
    if order.ObjectDefName <> "OBJECT_KD_ORDER_REP" then exit sub
    if order.StatusName <> "STATUS_KD_ORDER_IN_WORK" then exit sub
    set exec = order.Attributes("ATTR_KD_OP_DELIVERY").User
    if exec is nothing then exit sub
    if exec.sysName = thisApplication.CurrentUser.SysName then exit sub
    txt = "Ваше поручение " & order.Description & " отменено пользователем " & thisApplication.CurrentUser.Description
    call SendMail(exec, "Поручение отменено", order, false, txt, false)
end sub
'==============================================================================
sub SendEditDateEmail(order, txt)
    if order.StatusName <> "STATUS_KD_ORDER_IN_WORK" then exit sub
    set exec = order.Attributes("ATTR_KD_OP_DELIVERY").User
    if exec is nothing then exit sub
    if exec.sysName = thisApplication.CurrentUser.SysName then exit sub
    call SendMail(exec, "Поручение изменено", order, false, txt, false)
end sub

'==============================================================================
sub SendReqEmail(order)
    if order.StatusName = "STATUS_KD_OREDR_CANCEL" or order.StatusName = "STATUS_KD_ORDER_DONE" then exit sub
    set exec = order.Attributes("ATTR_KD_OP_DELIVERY").User
    if exec is nothing then exit sub
    if exec.sysName = thisApplication.CurrentUser.SysName then exit sub
    subj = "Напоминание: Поручение " & order.Description
    txt = "Прошу сообщит о ходе работ по поручению " & order.Description & ". " 
    call SendMail(exec, subj, order, false, txt, true)
end sub
'==============================================================================
sub Del_Order(order)
  order.Permissions = SysAdminPermissions
  select case order.StatusName 
      case "STATUS_KD_ORDER_DONE" exit sub ' если поручение уже выполнено, отменять нельзя
      case "STATUS_KD_ORDER_IN_WORK" 
        order.Attributes("ATTR_KD_POR_REASONCLOSE").value = "Отменено"
        order.Attributes("ATTR_KD_POR_ACTUALDATE").value  = now ' Фактический срок исполнения
        order.Status = thisApplication.Statuses("STATUS_KD_OREDR_CANCEL")
        order.update
      case "STATUS_KD_ORDER_SENT"
        order.erase  
   end select     
end sub
'==============================================================================
sub Set_From_Order_Cancel(order)
  if order.StatusName = "STATUS_KD_ORDER_SENT"  or order.StatusName = "STATUS_KD_ORDER_IN_WORK" then
    if fIsAutor(order) then 
        if order.ContentAll.Count > 0 then ' проверяем если есть дочерние
           Answer = MsgBox(  "У поручения есть дочерние поручения. " & vbNewLine & _
              "Нажмите Да, чтобы отменить дочернии поручение" & vbNewLine & _
              "Нажмите Нет, что отменить отзыв поручений", vbQuestion + vbYesNo,"Отозвать все поручения?")
           if Answer <> vbYes then 
             exit sub
           else
              for each sOrder in order.ContentAll
                  Set_OrderCancel(sOrder)
              next 
              Set_OrderCancel(order)
           end if
        else
          Set_OrderCancel(order)
        end if  
    else
        msgbox "Невозможно отозвать порученние " & order.Description & _
              ", т.к. оно выдано другим пользователем " & order.Attributes("ATTR_KD_AUTH").User.Description
        exit sub      
    end if
  else
    msgbox "Невозможно отозвать порученние " & order.Description & ", т.к. оно уже " & order.Status.Description
    exit sub
  end if
   msgbox "Поручение отозвано"
   thisForm.Close
end sub

'==============================================================================
' EV удаляем несколько согласующих
sub DellAprovers(control)
  iSel = control.ActiveX.SelectedItem
  If iSel < 0 Then 
     msgbox "Не выбран согласующий!"
     Exit Sub 
  end if  
  ar = thisapplication.Utility.ArrayToVariant(control.SelectedItems)
  for i = 0 to Ubound(ar)
     set aprRow =  control.value.RowValue(ar(i))
     call DellAprover(thisObject, aprRow)
  next
end sub

'==============================================================================
sub DellAprover(docObj,row)

  aprover = row.Attributes("ATTR_KD_APRV").value
  Answer = MsgBox(   "Вы уверены, что хотите удалить из списка согласуюих пользователя: " & aprover & "?" , vbQuestion + vbYesNo,"Удалить?")
  if Answer <> vbYes then exit sub
  
  if docObj.statusName = "STATUS_KD_AGREEMENT" then ' если на согласовании, то только то, что добавил сам
    set addUser = row.Attributes("ATTR_KD_LINKS_USER").User
    if addUser is nothing then 
       msgbox "Невозможно удалить, т.к согласующий добавлен не Вами!"
       Exit Sub 
    end if 
    'if addUser.SysName <> thisApplication.CurrentUser.SysName then 
    if not IsInCurUsers(addUser) then 
       msgbox "Невозможно удалить, т.к согласующий добавлен не Вами!"
       Exit Sub 
    end if 
  end if
  ' проверяем статус поручения
  set aprOrder = Row.Attributes("ATTR_KD_LINK_ORDER").object
  if not aprOrder is nothing then 
      if aprOrder.StatusName = "STATUS_KD_ORDER_DONE" then
          msgBox "Не возможно удалить согласующего, т.к. он уже согласовал документ", vbCritical, "Невозможно удалить!"
          exit sub
      end if
      aprOrder.Permissions = sysAdminPermissions
      aprOrder.Erase
  end if 
  'docObj.Permissions = sysAdminPermissions
  set row = ThisObject.Attributes("ATTR_KD_TAPRV").Rows(row)
  row.Erase
  thisObject.update

end sub
'==============================================================================
sub ChangeAprover(control)
  iSel = control.ActiveX.SelectedItem
  ar = thisapplication.Utility.ArrayToVariant(control.SelectedItems)

  If iSel < 0 Then 
     msgbox "Не выбран согласующий!"
     Exit Sub 
  end if  
  set row =  control.value.RowValue(ar(0))

  set aprOrder = row.Attributes("ATTR_KD_LINK_ORDER").object

  Set frmSetShelve = ThisApplication.InputForms("FORM_KD_ADD_APPROVE")
  frmSetShelve.Attributes("ATTR_KD_APRV_NO_BLOCK").Value = row.Attributes("ATTR_KD_APRV_NO_BLOCK").Value
  frmSetShelve.Attributes("ATTR_KD_APRV_NPP").Value = row.Attributes("ATTR_KD_APRV_NPP").Value
  frmSetShelve.Attributes("ATTR_KD_APRV_TYPE").Classifier = _
      row.Attributes("ATTR_KD_APRV_TYPE").Classifier
  frmSetShelve.Attributes("ATTR_KD_APRV").Value = row.Attributes("ATTR_KD_APRV").User
  frmSetShelve.Attributes("ATTR_KD_DOCBASE").value = thisObject
  if not aprOrder is nothing then _
      frmSetShelve.Controls("ATTR_KD_APRV").Enabled = false  

  If frmSetShelve.Show Then
  ' TODO добавить права
      Set TAttrRows = thisObject.Attributes("ATTR_KD_TAPRV").Rows
      set row = TAttrRows(row) 
      'thisObject.Permissions = SysadminPermissions 
      set newUser = frmSetShelve.Attributes("ATTR_KD_APRV").User
      row.Attributes("ATTR_KD_APRV_NO_BLOCK").Value = frmSetShelve.Attributes("ATTR_KD_APRV_NO_BLOCK").Value
      row.Attributes("ATTR_KD_APRV_NPP").Value = frmSetShelve.Attributes("ATTR_KD_APRV_NPP").Value
      row.Attributes("ATTR_KD_APRV_TYPE").Classifier = frmSetShelve.Attributes("ATTR_KD_APRV_TYPE").Classifier
      row.Attributes("ATTR_KD_APRV").Value = newUser
      TAttrRows.update
      thisObject.Update
'      row.Attributes("ATTR_KD_LINKS_USER").Value = thisApplication.CurrentUser
   end if

 end sub
 
'==============================================================================
 sub AddAprover()
  Set frmSetShelve = ThisApplication.InputForms("FORM_KD_ADD_APPROVE")
  frmSetShelve.Attributes("ATTR_KD_APRV_NO_BLOCK").Value = 1
  frmSetShelve.Attributes("ATTR_KD_APRV_NPP").Value = 1
  frmSetShelve.Attributes("ATTR_KD_APRV_TYPE").Classifier = thisApplication.Classifiers("NODE_KD_APRV_TYPE").Classifiers.Item("NODE_KD_APRV_TYPE_PARAL")
  frmSetShelve.Attributes("ATTR_KD_DOCBASE").value = thisObject
  
  If frmSetShelve.Show Then
      set newUser = frmSetShelve.Attributes("ATTR_KD_APRV").User
      if newUser is nothing then 
        msgbox "Согласующий не задан!", VbCritical
        exit sub
      end if' TODO при изменении исполнителя или руководителя проверять, что их нет в согласующих.
 
      Set TAttrRows = thisObject.Attributes("ATTR_KD_TAPRV").Rows
      if IsExistsUserItemCol(TAttrRows, newUser, "ATTR_KD_APRV") then 
        msgbox "Невозможно добавить согласующего " & newUser.Description & ", т.к. он уже есть в списке", VbCritical
        exit sub
      end if
      Set row = TAttrRows.Create'thisObject.Attributes("ATTR_KD_TAPRV").Rows.Create 'TAttrRows.Create
      row.Attributes("ATTR_KD_APRV_NO_BLOCK").Value = frmSetShelve.Attributes("ATTR_KD_APRV_NO_BLOCK").Value
      row.Attributes("ATTR_KD_APRV_NPP").Value = frmSetShelve.Attributes("ATTR_KD_APRV_NPP").Value
      row.Attributes("ATTR_KD_APRV_TYPE").Classifier = frmSetShelve.Attributes("ATTR_KD_APRV_TYPE").Classifier
      row.Attributes("ATTR_KD_APRV").Value = newUser
      row.Attributes("ATTR_KD_LINKS_USER").Value = thisApplication.CurrentUser
      TAttrRows.Update
      thisObject.Update
      if thisObject.StatusName <> "STATUS_KD_DRAFT" then
        ' EV если не в статусе черновик, то сразу отправляем поручение
        if CreateAproveOrder(row) then 
          thisObject.Update 
          Set_Permission thisObject
'          msgbox "Согласующий добавлен"
        end if 
      end if
   end if
 end sub
 
'==============================================================================
' отправить на проверку
sub send_to_Check()
  'проверяем статус
  if thisObject.StatusName <> "STATUS_KD_DRAFT" then  exit sub
  'проверяем котролера
  set controller =  thisObject.Attributes("ATTR_KD_CHIEF").User
  if controller is nothing then 
    msgbox "Не возможно отправить на проверку, т.к. не задан руководитель.", vbCritical, "Действие отменено"
    exit sub
  end if
  ' проверяем обязательные поля
  txt = checkOutDoc() 
  if txt > ""  then 
    msgbox "Невозможно отправить на проверку, т.к. не все обязательные поля заполнены :" & vbNewLine & txt, _
        vbCritical, "Отправка на проверку отменена!"
    exit sub    
  end if 
  'создаем поручение
  set newOrder = CreateSystemOrder( thisObject, "OBJECT_KD_ORDER_SYS", _
          controller, thisApplication.CurrentUser, "NODE_KD_CHECK","","")
  'меняем статус
  thisObject.Status = thisApplication.Statuses("STATUS_KD_CHECK") 
  ThisObject.Update
  Set_Permission thisObject
  ' A.O. 
  'msgbox "Документ передан на проверку"
  thisForm.Close isCanEdit()
end sub

'==============================================================================
' проверка обязательных полей
'function checkOutDoc()  
'  checkOutDoc = ""
'  'ответ на
'  if thisObject.Attributes("ATTR_KD_ID_LINKCHKBX").Value <> 0 then 
'    Set ReplyRows = thisObject.Attributes("ATTR_KD_VD_REPGAZ").Rows
'    if replyRows.Count = 0 then 
'      checkOutDoc = checkOutDoc & "Не указано входящее письмо, на которое Вы отвечаете." & vbNewLine
'    end if
'  end if
'  'получатели
'  set rows = thisObject.Attributes("ATTR_KD_TCP").Rows
'  if rows.Count = 0 then 
'      checkOutDoc = checkOutDoc & "Не задан ни один получатель." & vbNewLine
'  end if
'  'тема
'  if trim(thisObject.Attributes("ATTR_KD_TOPIC").Value) = "" then 
'      checkOutDoc = checkOutDoc & "Не указана тема письма." & vbNewLine
'  end if
'  set docFile = GetWordFile()
'  if docFile is nothing then
'      checkOutDoc = checkOutDoc & "Не приложен оригинал письма." & vbNewLine
'  end if
'  'TODO добавить остальные проверки
'end function

'==============================================================================
' вернуть в работу
sub return_To_Work()
  set curUser = GetCurUser()
  if thisObject.StatusName = "STATUS_KD_AGREEMENT" then ' если на согласовании прерываем согласование
    call thisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB","ReturnToWork",thisObject)
    exit sub
  end if
'  if isSecretary(curUser) and not IsExecutor(curUser, thisObject) then ' если секретарь, приложить резолюцию
'    msgBox "Приложите резолюцию", vbInformation
'    call LoadFileToDoc("FILE_KD_RESOLUTION")
'    set file =  GetFileByType("FILE_KD_RESOLUTION")
'    'TODO подумать как проверить что резолюция приложен. Могла ведь и передумать
'    if file is nothing then exit sub
'  end if  
  txt = ""
'   спросить причину
  if not IsExecutor(curUser, thisObject) then
    txt = thisApplication.ExecuteScript("CMD_KD_COMMON_LIB", "GetComment","Введите причину возврата")
    if trim(txt) = "" then 
      msgbox "Невозможно вернуть документ не указав причину." & vbNewLine & _
        "Пожалуйста, введите причину возврата", vbCritical, "Не задана причина возврата!"
      exit sub  
    end if
  end if 
'  end if  
  'удалить, если возможно поручения
  call delNotReadedOrder(thisObject)
  set_AllOrderCancel(thisObject)
  ' TODO прочитанные отменять надо?
  'TODO создать, если нужно версию

   'создать, есть нужно поручение исполнителю
  if txt > "" then     call CreateOrderToExcuter(txt)


'  call AddComment(thisObject,"ATTR_KD_NOTE","Возвращено исполнителю: " & txt)

'  'поменять статус
  thisObject.Status = thisApplication.Statuses("STATUS_KD_DRAFT")
  thisObject.SaveChanges
  thisObject.Update
  Set_Permission thisObject
  msgBox "Документ возвращен в работу"
  if not isEmpty(thisForm) then 
    if not IsExecutor(curUser, thisObject) then 
       thisForm.Close isCanEdit
    else
        fName = thisForm.SysName
        thisForm.close isCanEdit
        call SetGlobalVarrible("ShowForm", fName)
        Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
        CreateObjDlg.Object = thisObject
        ans = CreateObjDlg.Show
    end if
  end if
end sub

'==============================================================================
'создать, есть нужно поручение исполнителю
sub  CreateOrderToExcuter(txt)
  call CreateOrderToExcuterObj(txt, thisObject)
end sub
'==============================================================================
'создать, есть нужно поручение исполнителю
sub  CreateOrderToExcuterObj(txt, docObj)
'если испольнитель не надо ничего посылать
  if not IsExecutor(GetCurUser(), docObj) then
  
    if not docObj.Attributes.Has("ATTR_KD_EXEC") then exit sub
  
    set excuter =  docObj.Attributes("ATTR_KD_EXEC").User
    if excuter is nothing then exit sub
'    set newOrder = CreateSystemOrder( docObj, "OBJECT_KD_ORDER_SYS", _' EV 2018-01-17 выбаем поручение на ознакомление
    set newOrder = CreateSystemOrder( docObj, "OBJECT_KD_ORDER_NOTICE", _
          excuter, thisApplication.CurrentUser, "NODE_KD_RETUN_USER",txt,"")      'создаем поручение
' EV 2018-01-17 руководителю совсем  не выдаем
'    if docObj.Attributes.Has("ATTR_KD_CHIEF") then 
'    set controller =  docObj.Attributes("ATTR_KD_CHIEF").User
'        if controller is nothing then exit sub ' если есть контролер и не равен исполнителю, то информируем и его
'        if controller.SysName <> excuter.SysName then 
'            set newOrder = CreateSystemOrder( docObj, "OBJECT_KD_ORDER_SYS", _
'              controller, thisApplication.CurrentUser, "NODE_KD_RETUN_USER",txt,"")      
'        end if
'    end if
  end if
end sub
  
'==============================================================================
'создать, есть нужно поручение исполнителю
sub  CreateOrderToAutor(txt)
'если испольнитель не надо ничего посылать
  if not IsAutor(GetCurUser(), thisObject) then

    set excuter =  thisObject.Attributes("ATTR_KD_AUTH").User
    if excuter is nothing then exit sub
    set newOrder = CreateSystemOrder( thisObject, "OBJECT_KD_ORDER_SYS", _
          excuter, thisApplication.CurrentUser, "NODE_KD_RETUN_USER",txt,"")      'создаем поручение
    if thisObject.Attributes.Has("ATTR_KD_CHIEF") then 
    set controller =  thisObject.Attributes("ATTR_KD_CHIEF").User
        if controller is nothing then exit sub ' если есть контролер и не равен исполнителю, то информируем и его
        if controller.SysName <> excuter.SysName then 
            set newOrder = CreateSystemOrder( thisObject, "OBJECT_KD_ORDER_SYS", _
              controller, thisApplication.CurrentUser, "NODE_KD_RETUN_USER",txt,"")      
        end if
    end if

  end if
end sub
  
'==============================================================================
' удаляем все непрочитанные поручения
sub delNotReadedOrder (docObj)
  Set QueryDoc = thisApplication.Queries("QUERY_NOT_READED_ORDER_BY_DOC")
  QueryDoc.Parameter("PARAM0") = docObj.handle
  Set objs = QueryDoc.Objects
  
  if not objs is nothing then 
    if objs.Count >0 then 
      for each order in objs
        if order.StatusName <> "STATUS_KD_ORDER_DONE" then
          order.Permissions = sysAdminPermissions
          order.Erase
        end if
      next
    end if  
  end if 
end sub

'==============================================================================
sub set_Doc_Cancel

  thisscript.SysAdminModeOn 
   
  if thisObject.StatusName = "STATUS_KD_DRAFT" or  thisObject.StatusName = "STATUS_KD_CHECK" then 'удалить совсем
      Answer = MsgBox("Вы действительно хотите удалить документ?", vbCritical + vbYesNo,"Удалить документ?")
      If answer <> vbYes Then exit sub 

      del_AllOrders(thisObject)
      thisObject.Erase
      msgbox "Документ удален!"
      if not isEmpty(thisForm) then _
         thisForm.Close false
      exit sub   
  else
    Answer = MsgBox("Вы действительно хотите Отменить подготовку документа?" & vbNewLine & _
        "После отмены, документ перестанет быть доступным", VbCritical + vbYesNo, "Отменить подготовку документа?")
    If answer <> vbYes Then exit sub 
'  спрашиваем комментарий 
  txt = thisApplication.ExecuteScript("CMD_KD_COMMON_LIB", "GetComment","Введите причину отмены документа")
  if IsEmpty(txt) then exit sub
  if trim(txt) = "" then 
      msgbox "Невозможно отменить документ не указав причину." & vbNewLine & _
        "Пожалуйста, введите причину отклонения", vbCritical, "Не задана причина отклонения!"
      exit sub  
  end if

  'отменить все невыполненые поручения
    delNotReadedOrder (thisObject)
    set_AllOrderCancel(thisObject)
  'изменить статус
    thisObject.Status = thisApplication.Statuses("STATUS_KD_CANCEL")
    thisObject.Update
    call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", thisObject)
  end if
  msgbox "Документ отменен!"
  if not isEmpty(thisForm) then _
       thisForm.Close false
end sub

'==============================================================================
sub set_AllOrderCancel(docObj)
  Set QueryDoc = thisApplication.Queries("QUERY_NOT_DONE_ORDER_BY_DOC")
  QueryDoc.Parameter("PARAM0") = docObj.handle
  Set objs = QueryDoc.Objects
  
  if not objs is nothing then 
    if objs.Count >0 then 
      for each order in objs
        if order.StatusName <> "STATUS_KD_ORDER_DONE" then
          call Set_OrderCancel(order)
        end if
      next
    end if  
  end if 

end sub
'==============================================================================
' удаляем все  поручения
sub del_AllOrders (docObj)
  Set QueryDoc = thisApplication.Queries("QUERY_ALL_ORDERS_BY_DOC")
  QueryDoc.Parameter("PARAM0") = docObj.handle
  Set objs = QueryDoc.Objects
  
  if not objs is nothing then 
    if objs.Count >0 then 
      for each order in objs
          order.Permissions = sysAdminPermissions
          order.Erase
      next
    end if  
  end if 
end sub

'==============================================================================
' отпрвить на согласование
sub Send_to_Aprove()
'thisApplication.AddNotify "send " & cStr(timer())
Set TAttr = thisObject.Attributes("ATTR_KD_TAPRV")
    Set TAttrRows = TAttr.Rows
    if TAttrRows.Count = 0 then 
        msgbox "Согласование невозможно, т.к. не добавлено ни одного согласующего!" & vbNewLine &_
            "Добавьте согласующих или отправьте на подписание, если согласование не требуется.", vbCritical,  _
            "Отправить на согласование невозможно"
        exit sub    
    end if
    for each row in TAttrRows
      if not CreateAproveOrder (row) then exit sub
    next

    thisObject.Status = thisApplication.Statuses("STATUS_KD_AGREEMENT")
    thisObject.Update
   
    Set_Permission thisObject
    ' A.O. 
    'msgBox "Документ передан на согласование"
'thisApplication.AddNotify "msgBox " & cStr(timer())
    thisForm.close isCanEdit()
end sub

'==============================================================================
function CreateAproveOrder (row)
  CreateAproveOrder = false
  if row.Attributes("ATTR_KD_LINK_ORDER").Value <>"" then 
        'EV аннулируем предыдущие поручения
        set oldOrder = row.Attributes("ATTR_KD_LINK_ORDER").object
        if not oldOrder is nothing then 
          if oldOrder.statusName <>"STATUS_KD_OREDR_CANCEL" then _
            Set_OrderCancel(oldOrder)
        end if
        row.Attributes("ATTR_KD_LINK_ORDER").Value = ""
  end if
'thisApplication.AddNotify "Value= " & cStr(timer())
  on error resume next
  set newOrder = CreateSystemOrder( thisObject, "OBJECT_KD_ORDER_SYS", _
    row.Attributes("ATTR_KD_APRV").User, row.Attributes("ATTR_KD_LINKS_USER").User, "NODE_KD_APROVE","","")
'thisApplication.AddNotify "CreateSystemOrder " & cStr(timer())
  if newOrder is nothing  or  Err.Number<>0 then
    msgbox "Не удалось создать поручение для " & row.Attributes("ATTR_KD_APRV").Value, vbCritical,_
      "Отправка на согласование отменена"
    Err.Clear
    on error GoTo 0
    exit function
  else
    on error GoTo 0 
    row.Attributes("ATTR_KD_LINK_ORDER").Value = newOrder
  end if  
  CreateAproveOrder = true
end function
'==============================================================================
function CreateAproveOrderDoc (row, docObj, agreeObj)
  Thisscript.SysAdminModeOn
  CreateAproveOrderDoc = false
  if row.Attributes("ATTR_KD_LINK_ORDER").Value <>"" then 
        'EV аннулируем предыдущие поручения
        set oldOrder = row.Attributes("ATTR_KD_LINK_ORDER").object
        if not oldOrder is nothing then 
          if oldOrder.statusName <>"STATUS_KD_OREDR_CANCEL" then _
            Del_Order(oldOrder)
        end if
        row.Attributes("ATTR_KD_LINK_ORDER").Value = ""
  end if
'thisApplication.AddNotify "Value= " & cStr(timer())
  on error resume next
  set userFrom = row.Attributes("ATTR_KD_LINKS_USER").User
  if docObj.ObjectDefName = "OBJECT_T_TASK" then set userFrom = docObj.Attributes("ATTR_RESPONSIBLE").User
  set newOrder = CreateSystemOrder( docObj, "OBJECT_KD_ORDER_SYS", _
    row.Attributes("ATTR_KD_APRV").User, userFrom, "NODE_KD_APROVE" _
        ,"",row.Attributes("ATTR_KD_ARGEE_TIME").value)
'thisApplication.AddNotify "CreateSystemOrder " & cStr(timer())
  if newOrder is nothing  or  Err.Number<>0 then
    msgbox "Не удалось создать поручение для " & row.Attributes("ATTR_KD_APRV").Value, vbCritical,_
      "Отправка на согласование отменена"
    Err.Clear
    on error GoTo 0
    exit function
  else
    on error GoTo 0 
    agreeObj.Permissions = sysAdminPermissions
    set row = agreeObj.Attributes("ATTR_KD_TAPRV").Rows(row)
    row.Attributes("ATTR_KD_LINK_ORDER").Value = newOrder
    agreeObj.update
  end if  
  CreateAproveOrderDoc = true
end function
'==============================================================================
' удалить все выбранные поручения, если они еще не рассмотрены
Sub delSelectedOrder()

  Thisscript.SysAdminModeOn
  Set s = thisForm.Controls("QUERY_KD_ALL_ORDE_BY_DOC").ActiveX
  If s.SelectedItem < 0 Then 
     msgbox "Не выбрано поручение!"
     Exit Sub 
  end if  
  Sels = ThisForm.Controls("QUERY_KD_ALL_ORDE_BY_DOC").SelectedItems
  selcount = Ubound(Sels,1)+1
  Answer = MsgBox("Вы уверены, что хотите удалить "& selcount & " поручения(e)?", vbQuestion + vbYesNo,"Удалить?")
  if Answer <> vbYes then exit sub

  for i = 0 to s.Count-1 ' для всех выделенных файлов
      if s.IsItemSelected(i) then
      set order = s.ItemObject(i)
        if order.StatusName = "STATUS_KD_ORDER_SENT" then
          if fIsAutor(order) then 
              order.Permissions = sysAdminPermissions
              order.Erase
          else
            msgbox "Невозможно удалить порученние " & order.Description & _
                  ", т.к. оно выдано другим пользователем " & order.Attributes("ATTR_KD_AUTH").User.Description
          end if
        else
          msgbox "Невозможно удалить порученние " & order.Description & ", т.к. оно уже " & order.Status.Description
        end if
      end if  
  next
  msgbox "Удаление завершено"
end sub

'==============================================================================
sub edit_Order(order)
  if order.Permissions.Edit <> 1 then 
    msgBox "Невозможно редактирование поручение, т.к. оно уже просмотрено или выдано не Вами!", vbCritical
    exit sub
  end if
  Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
  CreateObjDlg.Object = order
  ans = CreateObjDlg.Show

end sub

'==============================================================================
function GetOrderFromForm()
  set GetOrderFromForm = nothing
  Set s = thisForm.Controls("QUERY_KD_ALL_ORDE_BY_DOC").ActiveX
  If s.SelectedItem < 0 Then 
     msgbox "Не выбрано поручение!"
     Exit function 
  end if  
  set GetOrderFromForm = s.ItemObject(s.SelectedItem )
end function

'==============================================================================
function GetCurUserRealOrder()
  set GetCurUserRealOrder = nothing
  set query = thisAppLication.Queries("QUERY_KD_ALL_USER_REAL_ODER")
  query.Parameter("PARAM0") = thisObject.handle
  query.Parameter("PARAM1") = GetCurUser()'thisApplication.CurrentUser
  set objs = query.Objects
  if objs.Count = 0 then exit function
  if objs.Count = 1 then 
    set GetCurUserRealOrder = objs(0)
    exit function
  end if
  'если не выполненое получение
  for each order in objs
    if order.StatusName = "STATUS_KD_ORDER_IN_WORK" then set GetCurUserRealOrder = order
  next
  'если нет то 
  if GetCurUserRealOrder is nothing then _
      set GetCurUserRealOrder = objs(0)
  
end function
'==============================================================================
function GetCurUserOrder()
  set GetCurUserOrder = nothing
  set query = thisAppLication.Queries("QUERY_KD_ALL_USER_ODER")
  query.Parameter("PARAM0") = thisObject.handle
  query.Parameter("PARAM1") = GetCurUser()'thisApplication.CurrentUser
  set objs = query.Objects
  if objs.Count = 0 then exit function
  if objs.Count = 1 then 
    set GetCurUserOrder = objs(0)
    exit function
  end if
  'если не выполненое получение
  for each order in objs
    if order.StatusName = "STATUS_KD_ORDER_IN_WORK" then set GetCurUserOrder = order
  next
  'если нет то 
  if GetCurUserOrder is nothing then _
      set GetCurUserOrder = objs(0)
  
end function
'=============================================
function GetOrderToApplay() 
  set GetOrderToApplay =  nothing
  set query = thisAppLication.Queries("QUERY_GET_ORDER_TO_APPLAY")
  query.Parameter("PARAM0") = thisObject.handle
  query.Parameter("PARAM1") = GetCurUser()'thisApplication.CurrentUser
  set objs = query.Objects
  if objs.Count = 0 then exit function
  if objs.Count = 1 then 
    set GetOrderToApplay = objs(0)
    exit function
  end if
  'если не принятое получение
  for each order in objs
    if order.StatusName = "STATUS_KD_REPORT_READY" then set GetOrderToApplay = order
  next
  'если нет то 
  set GetOrderToApplay = objs(0)
end function

'==============================================================================
sub copyFilesIn(selectedItem)'файлы и ссылки PlotnikovSP
  thisscript.SysAdminModeOn
  for each i in selectedItem.Content'бежим по всем прикрепленным поручениям
  if i.ObjectDefName = "OBJECT_KD_ORDER_REP" then
     
  
    for each j in i.files
      if not selectedItem.Files.Has(j.FileName) then
        selectedItem.Files.AddCopy j, j.FileName
      end if
    next
    
    for each j in i.attributes("ATTR_KD_POR_RESDOC").Rows'ссылки 
      AddResDocFiles selectedItem, j.attributes("ATTR_KD_D_REFGAZNUM").Object, "", false
    next
    
  end if
  next
  thisscript.SysAdminModeOff
end sub

sub checkOrders(selItem)'PlotnikovSP копирование из дочерних поручений информации в родительские
  thisScript.SysAdminModeOn
  if thisapplication.IsActiveTransaction then
    thisapplication.CommitTransaction
  end if
  err.clear
  
  if selItem.content.count = 0 then
    exit sub
  end if
  
  dim MyOptions(2)
  MyOptions(0) = "- Без результатов"
  MyOptions(1) = "- С результатами"
  Set SelDlg = ThisApplication.Dialogs.SelectDlg
  SelDlg.SelectFrom = MyOptions
  SelDlg.Caption = "Выберите действие"
  SelDlg.Prompt = "Перенести дочерние отчеты с результатами или без?"
  RetVal = SelDlg.Show
  If RetVal = FALSE then 'возможность отказаться от опций
    exit sub
  end if
  thisapplication.StartTransaction
  str = selItem.attributes("ATTR_KB_POR_RESULT").value'Содержание
 
  for each i in selItem.content'бежим по всем прикрепленным поручениям
    if i.ObjectDefName = "OBJECT_KD_ORDER_REP" then
      str  = str & vbnewline  & i.attributes("ATTR_KB_POR_RESULT").value' "ATTR_KB_POR_RESULT" = 15
    end if
  next'25,28,29 атрибуты - рез док-ты - таблица "ATTR_KB_POR_RESULT"
  selItem.attributes("ATTR_KB_POR_RESULT").value = str
  
  SelectedArray = SelDlg.Objects
  dim countOfSelect
  countOfSelect = UBound(SelectedArray)
  if countOfSelect>-1 then
    If ((countOfSelect=0 and SelectedArray(0) = MyOptions(1)) or countOfSelect=1) Then
      copyFilesIn selItem
    end if
  end if
   
  if err.Number <> 0 then
    thisapplication.AbortTransaction
  else
    thisapplication.CommitTransaction
  end if
  
  err.clear
  thisScript.SysAdminModeOff
  
end sub

sub Set_order_Done(order)
  checkOrders order
  if not fIsExec(order) then 
    msgBox "Невозможно отметить готовность поручения, т.к. оно адресовано не Вам!", vbCritical
    exit sub
  end if
  if order.StatusName = "STATUS_KD_ORDER_DONE" or order.StatusName = "STATUS_KD_OREDR_CANCEL" then 
    msgbox "Поручение уже выполнено или отменено", vbInformation, "Невозможно отметить готовность"
    exit sub
  end if
 
  if order.Attributes("ATTR_SET_DONE_AFTER_READED").value or not order.attributes.has("ATTR_KD_CONTR") then 
    call SetOrderDone(order,"", "Прочтено") 
'    msgbox "Поручение выполнено"
    thisForm.Close
    exit sub
  end if
  call SetGlobalVarrible("ShowForm", "FORM_ORDER_DONE")
  Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
  CreateObjDlg.Object = order
  ans = CreateObjDlg.Show
  if ans = true then thisForm.Close
end sub

'==============================================================================
sub CreateSubOrder(order)
  set parentOrder = order
  if parentOrder is nothing then exit sub
  set docObj = nothing 
  if thisObject.IsKindOf("OBJECT_KD_ORDER") then 
    set docObj = thisObject.Attributes("ATTR_KD_DOCBASE").Object
  else
    set docObj = thisObject
  end if
  call CreateOrders( parentOrder, docObj )
'  parentOrder.Permissions = SysAdminPermissions
'  set newOrder = parentOrder.Objects.Create("OBJECT_KD_ORDER_REP") 
'  'set newOrder = thisObject.Duplicate(thisObject.Parent)
'  for each attr in frmOrder.Attributes
'    attrName = attr.AttributeDefName
'    if CreatedObject.Attributes.Has(attrName) then 
'        CreatedObject.Attributes(attrName) = frmOrder.Attributes(attrName)
'    end if    
'  next

''  newOrder.Attributes("ATTR_KD_OP_DELIVERY").value = ""
''  newOrder.Attributes("ATTR_KD_NUM").value = parentOrder.Attributes("ATTR_KD_NUM").value + 1
''  newOrder.Attributes("ATTR_KD_DOCBASE").object = parentOrder.Attributes("ATTR_KD_DOCBASE").object
''  newOrder.Attributes("ATTR_KD_TEXT").value = parentOrder.Attributes("ATTR_KD_TEXT").value 
''  newOrder.Attributes("ATTR_KD_URGENTLY").value = parentOrder.Attributes("ATTR_KD_URGENTLY").value
''  newOrder.Attributes("ATTR_KD_IMPORTANT").value = parentOrder.Attributes("ATTR_KD_IMPORTANT").value 
''  newOrder.Attributes("ATTR_KD_RESOL").value = parentOrder.Attributes("ATTR_KD_RESOL").value 
''  newOrder.Attributes("ATTR_KD_POR_PLANDATE").value = parentOrder.Attributes("ATTR_KD_POR_PLANDATE").value 
''  
'  Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
'  EditObjDlg.Object = newOrder
'  RetVal = EditObjDlg.Show 
end sub

'=============================================
sub SetParentOrderDone()
    if not fIsAutor(thisObject) then  exit sub
    set parOrder = thisObject.Parent
    if parOrder is nothing then exit sub
'    if parOrder.Attributes("ATTR_KD_OP_DELIVERY").User.SysName = thisApplication.CurrentUser.SysName then 
    if parOrder.Attributes("ATTR_KD_OP_DELIVERY").User.SysName = GetCurUser() then 
      if parOrder.StatusName <> thisApplication.Statuses("STATUS_KD_ORDER_DONE").SysName then 
        parOrder.Permissions = SysadminPermissions
        parOrder.Status = thisApplication.Statuses("STATUS_KD_ORDER_DONE")
        parOrder.Update
      end if  
    end if
end sub

'=============================================
' EV проверяем автора или проверяющего
function fIsAutor(obj)
  fIsAutor = false
  set curUser = GetCurUser()'thisApplication.CurrentUser
  set aut =  obj.Attributes("ATTR_KD_AUTH").User
  if aut is nothing then exit function
  fIsAutor = (obj.Attributes("ATTR_KD_AUTH").User.SysName = curUser.SysName) 
  if fIsAutor = true then exit function
  if obj.Attributes.has("ATTR_KD_CONTR") then _ 
    if obj.Attributes("ATTR_KD_CONTR").value > "" then _
      fIsAutor = (fIsAutor  or (obj.Attributes("ATTR_KD_CONTR").User.SysName = curUser.SysName))
  if fIsAutor = true then exit function
  fIsAutor = obj.CreateUser.SysName = curUser.SysName
'  if obj.Attributes.has("ATTR_KD_REG") then _ 
'    if obj.Attributes("ATTR_KD_REG").value > "" then _
'      fIsAutor = (fIsAutor  or (obj.Attributes("ATTR_KD_REG").User.SysName = curUser.SysName))
end function

'=============================================
' EV проверяем исполнителя
function fIsExec(obj)
  fIsExec = false 
  set curUser = GetCurUser()'thisApplication.CurrentUser
  set user = nothing
  if obj.Attributes.has("ATTR_KD_OP_DELIVERY") then _
      set user = obj.Attributes("ATTR_KD_OP_DELIVERY").User
  if user is nothing then exit function
  fIsExec = (user.SysName = curUser.SysName)
end function  
'=============================================
' EV проверяем исполнителей
function fIsExecs(obj)
  fIsExecs = false 
  set curUser = thisApplication.CurrentUser
  set user = nothing
  if obj.Attributes.has("ATTR_KD_OP_DELIVERY") then _
      set user = obj.Attributes("ATTR_KD_OP_DELIVERY").User
  if user is nothing then exit function
  fIsExecs = IsInCurUsers(user)
'  set us = curUser.GetDelegatedRightsFromUsers()
'  fIsExecs = (user.SysName = curUser.SysName)
'  if not fIsExecs
'  if us.Count = 0 then 
'    fIsExecs = (user.SysName = curUser.SysName)
'  else 'для заместителей
'    for each cUser in us
'      if user.SysName = cUser.SysName then 
'        fIsExecs = true
'        exit for
'      end if
'    next
'  end if
end function  

'=============================================
function GetMyOrder(docObj)
  set GetMyOrder = nothing
  Set QueryDoc = thisApplication.Queries("QUERY_KD_ALL_USER_ODER")  
  QueryDoc.Parameter("PARAM0") = docObj.handle
  QueryDoc.Parameter("PARAM1") = GetCurUser()'thisApplication.CurrentUser
  Set objs = QueryDoc.Objects
  if not objs is nothing then 
    if objs.Count >0 then _
      set GetMyOrder = objs(0)
  end if 
end function
'=============================================
function GetMyOrders(docObj)
  set GetMyOrders = nothing
  Set QueryDoc = thisApplication.Queries("QUERY_KD_ALL_USER_ODER")  
  QueryDoc.Parameter("PARAM0") = docObj.handle
  QueryDoc.Parameter("PARAM1") = GetCurUser()'thisApplication.CurrentUser
  Set objs = QueryDoc.Objects
  if not objs is nothing then 
      set GetMyOrders = objs
  end if 
end function
'=============================================
sub SendReject(orderObj,repText)
  ThisScript.SysAdminModeOn
  'call AddComment(orderObj,"ATTR_KB_POR_RESULT",repText)
  if not orderObj.Attributes.Has("ATTR_KB_POR_RESULT") then 
    msgbox "Невозможно отказаться от поручения на ознакомление", vbCritical
    exit sub
  end if 
  orderObj.Attributes("ATTR_KB_POR_RESULT").Value = repText
  call AddCommentTxt(orderObj,"ATTR_KD_HIST_NOTE", "Отказ от исполнения: " & repText)

  ' EV сюда прописываем изменения статусов
  set contr = orderObj.Attributes("ATTR_KD_CONTR").User
  if contr is nothing then 
    set contr = orderObj.Attributes("ATTR_KD_AUTH").User
  end if
  if contr is nothing then 
    msgbox "Невозможно отказаться, т.к. не задан автор поручения", vbCritical,"Отправка отменена"
  else
    orderObj.Status = thisApplication.Statuses("STATUS_KD_REPORT_READY")
    orderObj.Attributes("ATTR_KD_POR_REASONCLOSE").Value = "Отказ от выполнения"
    orderObj.Update
    ' A.O. 
    'msgbox "Отказ от исполенния " & thisObject.Description & " передан контролеру"
    thisForm.Close false
  end if
end sub
'=============================================
sub SendReport(orderObj,repText)
  
  'проверяем дочерние поручения
  if not CheckChilOrder(orderObj) then exit sub
  ' EV  прописываем изменения статусов
  set contr = thisObject.Attributes("ATTR_KD_CONTR").User
  if contr is nothing then 
    call SetOrderDone(orderObj,"", "Выполнено") 
'    msgbox "Поручение " & orderObj.Description & " выполнено"  
else
    orderObj.Permissions = SysAdminPermissions
    orderObj.Status = thisApplication.Statuses("STATUS_KD_REPORT_READY")
    orderObj.Update
    ' A.O. 
    'msgbox "Отчет по поручению " & thisObject.Description & " передан контролеру"
    call AddCommentTxt(orderObj,"ATTR_KD_HIST_NOTE", "Отправлен отчет: " & repText)
  end if
  '  call AddComment(orderObj,"ATTR_KB_POR_RESULT",repText)

  thisForm.Close true

end sub
'=============================================
function CheckChilOrder(order)
  CheckChilOrder = true
  if order.Content.Count > 0 then ' проверяем если есть дочерние
      inWork = false
      for each sOrder in order.ContentAll
        if sOrder.StatusName = "STATUS_KD_ORDER_SENT" or sOrder.StatusName = "STATUS_KD_ORDER_IN_WORK" then 
          inWork = true
          exit for
        end if
      next 
      if inWork then 
         Answer = MsgBox(  "У Вашего поручения есть незакрытые дочерние поручения. " & vbNewLine & _
            "Вы уверены, что хотите отменить все незакрытые дочерние поручения?" & vbNewLine & _
            "Нажмите Да, чтобы отменить дочернии поручение." & vbNewLine & _
            "Нажмите Нет, что отменить закрытие Вашего поручения.", vbQuestion + vbYesNo,"Отменить все незакрытые дочерние поручения?")
         if Answer <> vbYes then 
           CheckChilOrder = false
           exit function
         else
            thisapplication.Utility.WaitCursor = true
            for each sOrder in order.ContentAll
                Set_OrderCancel(sOrder)
            next 
            thisapplication.Utility.WaitCursor = false
         end if
      end if  
  end if  
end function
'=============================================
sub ApplayOrder(order, ordForm)
    ThisScript.SysAdminModeOn
    txt = thisApplication.ExecuteScript("CMD_KD_COMMON_LIB", "GetComment","Вы хотите принять отчет по поручению " &_
              GetOrderDesc(order) & "?")
    if IsEmpty (txt) then exit sub
    'if trim(txt) <> "" then  call AddComment(order,"ATTR_KB_POR_RESULT",txt) 'если нажал ОК, то в любом случае принимаем
    call AddCommentTxt(order,"ATTR_KD_HIST_NOTE", "Отчет принят: " & txt)
    call SetOrderDone(order,"", "Выполнено") 

  set parOrder = order.Attributes("ATTR_KD_ORDER_BASE").Object
  if not parOrder is nothing then 
     Answer = MsgBox("Открыть исходное поручение?", vbQuestion + vbYesNo,"Открыть?")
     if Answer <> vbYes then 
       msgbox "Поручение " & order.Description & " выполнено"
       exit sub
     else
      if not ordForm is nothing then ordForm.Close false
      oldName = thisForm.SysName
      'call RemoveGlobalVarrible("ShowForm")
      call SetGlobalVarrible("ShowForm", "FORM_ORDER_DONE")
      Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
      CreateObjDlg.Object = parOrder
   ' CreateObjDlg.ActiveForm = order.ObjectDef.InputForms(1)
      ans = CreateObjDlg.Show
      call SetGlobalVarrible("ShowForm", oldName)
     end if
  end if  
end sub
'=============================================
function GetOrderDescFromSheet(sheet,i)
  GetOrderDescFromSheet = ""
  user = GetUserFIOFromStr(sheet.CellValue(i,4))
  if user = "" then exit function
  toDate = sheet.CellValue(i,6)
  if trim(toDate) = "" then 
    toDate = " "
  else
    toDate =  " | срок " & left(toDate, 5)
  end if
  GetOrderDescFromSheet = user & toDate & " | " & sheet.CellValue(i,7)
end function
'=============================================
function GetOrderDesc(order)
  GetOrderDesc = ""
  set user = order.Attributes("ATTR_KD_OP_DELIVERY").user
  if user is nothing then exit function
  txt = thisApplication.ExecuteScript("OBJECT_KD_DOC_OUT", "GetUserFIO", user)
  toDate = order.Attributes("ATTR_KD_POR_PLANDATE").value
  if trim(toDate) = "" then 
    toDate = " "
  else
    toDate =  " | срок " & left(toDate, 5)
  end if
  GetOrderDesc = txt & toDate & " | " & order.Attributes("ATTR_KD_TEXT").value
end function
'=============================================
sub RejectOrderReport(order, ordForm)
    ThisScript.SysAdminModeOn
    if not fIsAutor(order) then 
      msgBox "Вы не можете отменить отчет по поручению, т.к. не являетесь автором или контролером", vbCritical, "Действие отменено"
      exit sub
    end if
    if Order.StatusName <>"STATUS_KD_REPORT_READY" then 
      msgBox "Невозможно отменить отчет, т.к. отчет по поручению неподготовлен", vbCritical, "Действие отменено"
      exit sub
    end if
    
    txt = thisApplication.ExecuteScript("CMD_KD_COMMON_LIB", "GetComment","Введите причину отклонения отчета по поручению " &_
              GetOrderDesc(order))
    if IsEmpty (txt) then exit sub
    if trim(txt) <> "" then 
        order.Attributes("ATTR_KB_POR_COMMENT").Value = txt
'        call AddComment(order,"ATTR_KB_POR_RESULT",txt)
        call AddCommentTxt(order,"ATTR_KD_HIST_NOTE", "Отчет отклонен: " & txt)
        order.Status = thisApplication.Statuses("STATUS_KD_ORDER_SENT")'thisApplication.Statuses("STATUS_KD_ORDER_IN_WORK")
          ' новая концепция, чтобы было новое, если отклонили
        order.Attributes("ATTR_KD_POR_REASONCLOSE").Value = "" '"Отказ от выполнения"
        order.Update
'        msgbox "Отчет по поручению " & order.Description & " возвращен на доработку"
        if not ordForm is nothing then ordForm.Close false
    else
        msgbox "Введите причину отклонения отчета!", vbCritical, "Отклонение не выполнено" 
    end if  
end sub    

'=============================================
sub SendRequest(order)
  ThisScript.SysAdminModeOn
    newDate = thisForm.Attributes("ATTR_KB_POR_DATEBRAKE").Value
    order.Attributes("ATTR_KB_POR_DATEBRAKE").Value = newDate
    call AddCommentTxt(order,"ATTR_KB_POR_DATEBRAKECOM", thisForm.Attributes("ATTR_KB_POR_DATEBRAKECOM").Value)
    call AddCommentTxt(order,"ATTR_KD_HIST_NOTE", "Отправлен запрос на изменение сроков: " & _ 
        thisForm.Attributes("ATTR_KB_POR_DATEBRAKECOM").Value)
    order.Update
    thisForm.Close true
end sub
'=============================================
sub CreateChild(ax_Tee, parObj,chiObj,curOrder)
  set user = chiObj.Attributes("ATTR_KD_OP_DELIVERY").user
  if user is nothing then exit sub
  txt = GetOrderDesc(chiObj)
  ch = ax_Tee.InsertItem(txt,parObj,0)  
  call ax_Tee.SetItemData(ch,chiObj)
  call ax_Tee.SetItemIcon(ch, chiObj.Icon)
  for each order in chiObj.Content
    call CreateChild(ax_Tee,ch,order,curOrder)
  next
  if not curOrder is nothing then 
    if curOrder.handle = chiObj.handle then 
      chiNo = ch
      ax_Tee.SelectedItem = ch  
    end if
  end if
  ax_Tee.Expand(ch)
end sub
'=============================================
sub RejectOrder(order)
    if order.ObjectDefName = "OBJECT_KD_ORDER_NOTICE" then 
      msgbox "Невозможно отказаться от поручения на ознакомление", vbCritical
      exit sub
    end if

    ThisScript.SysAdminModeOn
    txt = thisApplication.ExecuteScript("CMD_KD_COMMON_LIB", "GetComment","Введите причину отказа от выполнения")
    if IsEmpty (txt) then exit sub
    if trim(txt) <> "" then  
       call SendReject(order,txt)
    else  
      msgbox "Введите причину отказа!", vbCritical, "Отправка отменена"
    end if   
end sub
'=============================================
Sub Add_Doc()
     Set SelObjDlg = ThisApplication.Dialogs.SelectObjectDlg 
     SelObjDlg.Prompt = "Выберите один или несколько документов:"

     RetVal = SelObjDlg.Show 
     Set ObjCol = SelObjDlg.Objects
     If (RetVal<>TRUE) Or (ObjCol.Count=0) Then Exit Sub
    
     For Each obj In ObjCol
         call AddResDoc(obj)   
     Next
     SetAllDocs(thisObject)
End Sub
'=============================================
sub SetAllDocs(order)
  strDoc = ""
  Set ReplyRows = order.Attributes("ATTR_KD_POR_RESDOC").Rows
  for each row in ReplyRows
    strDoc = strDoc & row.Attributes(0).value & ","
  next
  thisScript.SysAdminModeOn
  order.Permissions = SysAdminPermissions
  order.Attributes("ATTR_KD_ALL_DOC").value = strDoc
end sub
'=============================================
function GetOrderFromTree()
    set GetOrderFromTree = nothing
    set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX 
    if ax_Tee is nothing then exit function
    hItem = ax_Tee.SelectedItem 
    if hItem = 0 then 
      'msgbox "Поручение не выбрано", vbInformation
      exit function
    end if
    set GetOrderFromTree = ax_Tee.GetItemData(hItem)
end function
'=============================================
function DEL_ORDER_FromTree()
    DEL_ORDER_FromTree = false
    set order = GetOrderFromTree()
    if order is nothing then exit function
    if order.StatusName = "STATUS_KD_ORDER_SENT" then
      if fIsAutor(order) then 
          order.Permissions = sysAdminPermissions
          order.Erase
          DelNodeFromFree()
          DEL_ORDER_FromTree = true
      else
        msgbox "Невозможно удалить порученние " & order.Description & _
              ", т.к. оно выдано другим пользователем " & order.Attributes("ATTR_KD_AUTH").User.Description
      end if
    else
      msgbox "Невозможно удалить порученние " & order.Description & ", т.к. оно уже " & order.Status.Description
    end if
End function
'=================================
sub DelNodeFromFree()
    set ax_Tee = thisForm.Controls("TDMSTREEOrder").ActiveX 
    if ax_Tee is nothing then exit sub
    hItem = ax_Tee.SelectedItem 
    if hItem = 0 then exit sub
    ax_Tee.DeleteItem(hItem) 
end sub
'=================================
sub clouseAllOrderByRes(DocObj, resSysName)
  Set resol = ThisApplication.Classifiers("NODE_CORR_REZOL").Classifiers.FindBySysId(resSysName)
  if resol is nothing then exit sub
  set qry = thisApplication.Queries("QUERY_GET_ORDER_BY_RES")
  qry.Parameter("PARAM0") = docObj
  qry.Parameter("PARAM1") = resol
  set objs = qry.Objects
  for each order in objs
    call SetOrderDone(order,"Подписано", "Выполнено") 
  next
end sub
'EV чтобы открывалось по двойному щелчку
'=============================================
Sub ATTR_KD_POR_RESDOC_DblClick(nRow,nCol)
  if nRow < 0 then exit sub
  Set ReplyRows = thisObject.Attributes("ATTR_KD_POR_RESDOC").Rows
  set obj = ReplyRows(nRow).Attributes(0).object
  if obj is nothing then exit sub
  fName = GetGlobalVarrible("ShowForm")'thisForm.SysName
  call RemoveGlobalVarrible("ShowForm")  
  Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
  CreateObjDlg.Object = obj
  ans = CreateObjDlg.Show
  if fName <> "" then call SetGlobalVarrible("ShowForm", fName)
End Sub
