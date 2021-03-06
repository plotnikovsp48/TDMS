use CMD_KD_USER_PERMISSIONS
use CMD_KD_GLOBAL_VAR_LIB
'==============================================================================
function CheckDocUserApr( docObj, user)
    CheckDocUserApr = false
    if IsExecutor(User, docObj) then
        msgbox "Невозможно добавить согласующего " & user.Description & ", т.к. он является исполнителем документа", _
            VbCritical, "Согласующий не добавлен"
        Cancel = true    
        exit function
    end if
    ' EV стал первым согласующим
'    if IsController(User, docObj) then 
'        msgbox "Невозможно добавить согласующего " &  user.Description & ", т.к. он является руководителем исполнителя", _
'            VbCritical, "Согласующий не добавлен"
'        exit function
'    end if
    if IsSigner(user, docObj) then 
        msgbox "Невозможно добавить согласующего " &  user.Description & ", т.к. он является подписантом", _
            VbCritical, "Согласующий не добавлен"
        exit function
    end if
    if IsApprover(user, docObj) then 
        msgbox "Невозможно добавить согласующего " &  user.Description & ", т.к. он является утверждающим", _
            VbCritical, "Согласующий не добавлен"
        exit function
    end if
     
    CheckDocUserApr = true
end function
'==============================================================================
function CheckDocStatusApr(docObj)
  CheckDocStatusApr = false
    ' проверка обязательных полей
  txt = ""
'  'тема
'  if trim(docObj.Attributes("ATTR_KD_TOPIC").Value) = "" then 
'      txt = txt & "Не указана тема протокола." & vbNewLine
'  end if
  txt = CheckProtFileds(docObj)

  if docObj.Attributes("ATTR_KD_PROT_TYPE").Value <> "" then 
    if docObj.Attributes("ATTR_KD_PROT_TYPE").Classifier.SysName = "NODE_KD_PROT_IN" then 
      str = checkDocFile(docObj)
      if str > "" then _
          txt = txt & str & vbNewLine
    end if
  end if 
      
  if txt>"" then 
    msgbox txt, vbCritical, "Не заданы обязательные поля"
    exit function
  end if
  CheckDocStatusApr = true
end function
'==============================================================================
function CheckProtFileds(docObj)
  CheckProtFileds = ""
    ' проверка обязательных полей
  txt = ""
  if docObj.Attributes("ATTR_KD_PROT_TYPE").Value = "" then 
      txt = txt & "Не указан тип протокола." & vbNewLine
  else
    if docObj.Attributes("ATTR_KD_PROT_TYPE").Classifier.SysName = "NODE_KD_PROT_IN" then 
        if docObj.Attributes("ATTR_KD_EXEC").Value = "" then _ 
            txt = txt & "Не указан автор." & vbNewLine
    else
        'txt = txt & CheckReciep(docObj)
        if docObj.Attributes("ATTR_KD_VD_INСNUM").Value = "" then _ 
            txt = txt & "Не указан внешний номер протокола." & vbNewLine
    end if
  end if 
  'тема
  if trim(docObj.Attributes("ATTR_KD_TOPIC").Value) = "" then 
      txt = txt & "Не указана тема протокола." & vbNewLine
  end if
  if docObj.Attributes("ATTR_KD_MEETING_DATE").Value = "" then _ 
            txt = txt & "Не указана дата протокола." & vbNewLine
  txt = txt & CheckDogProj(docObj)
      
  CheckProtFileds = txt
end function

'==============================================================================
function CheckReciep(docObj)
  CheckReciep = ""
  if docObj is nothing then 
    CheckReciep = CheckReciep & "Ошибка ссылки на документ. Документ пустой" & vbNewLine
    exit function
  end if

  if not  docObj.Attributes.Has("ATTR_KD_TCP") then 
    CheckReciep = CheckReciep & "Не найден атрибут получатели у документа" & vbNewLine
    exit function
  end if
  'получатели
  set rows = docObj.Attributes("ATTR_KD_TCP").Rows
  if rows.Count = 0 then 
      CheckReciep = CheckReciep & "Не задан ни один получатель." & vbNewLine
  end if
  for each row in rows
    if row.Attributes("ATTR_KD_CPNAME").value = "" or row.Attributes("ATTR_KD_CPADRS").value = "" then 
      CheckReciep = CheckReciep & "Не все организации  или контактные лица указаны." & vbNewLine
      exit for
    end if
  next
end function
'==============================================================================
function CheckDocOutAprStatus(docObj)
  CheckDocOutAprStatus = false
  ' проверяем обязательные поля
  
  txt = checkOutDoc(docObj)
  txtF = checkDocFile(docObj)
  if txt > "" or txtF >"" then 
      txt = txt & txtf & vbNewLine
      msgbox "Невозможно отправить документ, т.к. не все обязательные поля заполнены :" & vbNewLine & txt, _
        vbCritical, "Отправка отменена!"
    exit function    
  end if 
  CheckDocOutAprStatus = true
end function

'==============================================================================
function checkOutDoc(docObj)  
  checkOutDoc = ""
  'ответ на
  if docObj.Attributes("ATTR_KD_ID_LINKCHKBX").Value <> 0 then 
    Set ReplyRows = docObj.Attributes("ATTR_KD_VD_REPGAZ").Rows
    if replyRows.Count = 0 then 
      checkOutDoc = checkOutDoc & "Не указано входящее письмо, на которое Вы отвечаете." & vbNewLine
    end if
  end if
  'получатели
  checkOutDoc = checkOutDoc & CheckReciep(docObj)
'  set rows = docObj.Attributes("ATTR_KD_TCP").Rows
'  if rows.Count = 0 then 
'      checkOutDoc = checkOutDoc & "Не задан ни один получатель." & vbNewLine
'  end if
  'тема
  if trim(docObj.Attributes("ATTR_KD_TOPIC").Value) = "" then 
      checkOutDoc = checkOutDoc & "Не указана тема письма." & vbNewLine
  end if
  if docObj.Attributes("ATTR_KD_SIGNER").Value = "" then 
      checkOutDoc = checkOutDoc & "Не указан подписант письма." & vbNewLine
  end if

  checkOutDoc = checkOutDoc & CheckDogProj(docObj)
      

'  txt = checkDocFile(docObj)
'  if txt > "" then _
'      checkOutDoc = checkOutDoc & txt & vbNewLine
'  'TODO добавить остальные проверки
end function

'==============================================================================
function checkDocFile(docObj)
  checkDocFile = ""
  set docFile = nothing
  Set files = docObj.Files.FilesByDef("FILE_KD_WORD")
  if files.Count > 0 Then _
  set docFile = files(0)

  if docFile is nothing then
      checkDocFile = "Не приложен оригинал." 
  end if
end function
'==============================================================================
function CheckMemoAprStatus(docObj)
  CheckMemoAprStatus = false
  ' проверяем, что отправляет руководитель
  isContr = thisApplication.ExecuteScript("CMD_KD_USER_PERMISSIONS","IsController", GetCurUser(), docObj)
  if not isContr then 
    msgbox "Только пользователь, указанный в поле Руководитель, может отправить СЗ на согласование", vbCritical,  "Отправка  отменена!"
    exit function  
  end if
  'проверяем обязательные поля
  txt = checkMemo(docObj)
  if txt > ""  then 
    msgbox "Невозможно отправить документ, т.к. не все обязательные поля заполнены :" & vbNewLine & txt, _
        vbCritical, "Отправка  отменена!"
    exit function    
  end if 
  
  'проверяем, что зарегистрирована
   if not  thisApplication.ExecuteScript("CMD_KD_MEMO_LIB","Reg_Memo",DocObj) then 
      msgbox "Не удалось подписать СЗ" & vbNewLine & txt, vbCritical, "Отправка  отменена!"
      exit function    
   end if

  CheckMemoAprStatus = true
end function

'==============================================================================
function CheckORDAprStatus(docObj) 
  CheckORDAprStatus = false
  'txt = ThisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "checkPR", docObj)
  txt = checkPR(docObj)
  if txt > ""  then 
    msgbox "Невозможно отправить на согласование, т.к. не все обязательные поля заполнены :" & vbNewLine & txt, _
        vbCritical, "Отправка отменена!"
    exit function    
  end if
  CheckORDAprStatus = true
end function
'==============================================================================
function CheckZAAprStatus(docObj) 
  CheckZAAprStatus = false

  set docFile =  thisApplication.ExecuteScript("CMD_KD_FILE_LIB","GetFileByTypeByObj","FILE_KD_SCAN_DOC",docObj)
  if docFile is nothing then
      msgbox "Не приложен скан счета.", vbCritical, "Отправка отменена!"
    exit function    
  end if
  'txt = thisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB","checkPayment" , docObj) 
  txt = checkPayment(docObj)
  if txt > ""  then 
    msgbox "Невозможно отправить на согласование, т.к. не все обязательные поля заполнены :" & vbNewLine & txt, _
        vbCritical, "Отправка отменена!"
    exit function    
  end if

  CheckZAAprStatus = true
end function

'=============================================
function GetAgreeObjByObj(Obj)
  set GetAgreeObjByObj = nothing
  
  if IsExistsGlobalVarrible("AgreeObj") then 
    set GetAgreeObjByObj =  GetObjectGlobalVarrible("AgreeObj")
    if not GetAgreeObjByObj is nothing then exit function
  end if
  
  set query = ThisApplication.Queries("QUERY_GET_ARGEEMENT")
  query.Parameter("PARAM0") = obj.handle
  set objs = query.Objects
  if objs.Count>0 then _
    set GetAgreeObjByObj = objs(0)

  if GetAgreeObjByObj is nothing then _
     set  GetAgreeObjByObj = CreateAgreeObj(Obj, false)
  call SetObjectGlobalVarrible("AgreeObj", GetAgreeObjByObj)
end function

'=============================================
function CreateAgree()
  set CreateAgree = CreateAgreeObj(thisObject, false)
end function
'=============================================
function CreateAgreeObj(obj, silent)
    set CreateAgreeObj = nothing
    set objType = thisApplication.ObjectDefs("OBJECT_KD_AGREEMENT")
    Set ObjRoots = ThisApplication.ExecuteScript("CMD_KD_FOLDER", "GET_FOLDER", "",objType)
    rej = false
    set settings = GetSettingsByObjS(obj, silent)
    if not settings is nothing  then 
      rej = settings.attributes("ATTR_KD_FIRST_REJECT").value
    else
      exit function
    end if

    if  ObjRoots is nothing then  
      if not silent then _
          msgBox "Не удалось создать папку", vbCritical, "Объект не был создан"
      exit function
    end if
    CreateObj = true
    ObjRoots.Permissions = SysAdminPermissions
    Set CreatedObject = ObjRoots.Objects.Create(objType)
    CreatedObject.attributes("ATTR_KD_HIST_OBJECT").value = obj
    CreatedObject.attributes("ATTR_KD_FIRST_REJECT").value = rej
    CreatedObject.update
    
    call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", CreatedObject)
    if not execSettingsFun1("ATTR_AFTER_FUNCTION", Obj) then 
      CreatedObject.erase
      exit function
    end if
    set CreateAgreeObj = CreatedObject
end function

'=============================================
function GetSettings()
  set GetSettings = GetSettingsByObj(thisObject)
end function

'=============================================
function GetSettingsByObj(docObj)
  set GetSettingsByObj = GetSettingsByObjS(docObj, false)
end function
'=============================================
function GetSettingsByObjS(docObj, silent)
  set GetSettingsByObjS = nothing
  
  if IsEmpty(docObj) then 
      set docObj = thisForm.Attributes("ATTR_KD_DOCBASE").Object
  elseif docObj is nothing then 
      if isEmpty(thisForm) then 
          exit function
      else 
          set docObj = thisForm.Attributes("ATTR_KD_DOCBASE").Object
      end if
'  else  
'      set docObj = thisObject   
  end if
  
  if docObj is nothing then   exit function

  if IsExistsGlobalVarrible("Settings") then 
    set GetSettingsByObjS =  GetObjectGlobalVarrible("Settings")
    exit function
  else 
    'set Obj =  thisApplication.GetObjectByGUID("{36BBEB3C-26BB-4603-A9ED-15C107B53A7A}")
    if not thisApplication.Attributes.Has("ATTR_AGREENENT_SETTINGS") then exit function
    set rows = thisApplication.Attributes("ATTR_AGREENENT_SETTINGS").Rows
    for each row in rows
      if row.Attributes(0).value = docObj.ObjectDefName then 
        set GetSettingsByObjS = row
        call SetObjectGlobalVarrible("Settings", row)
        exit function
      end if
    next
  end if  
  if not silent then 
     msgbox "Для типа объекта [" & docObj.ObjectDef.Description & "] неопределено согласование" 
  end if  
end function

'==============================================================================
sub Aprove_Doc(docObj)
'ищем строку и поручение человека
  set curUser = GetCurUser()
  set aprRow = Get_AproveRow(curUser, docObj)
  if aprRow is nothing  then exit sub
  set aprOrder = aprRow.Attributes("ATTR_KD_LINK_ORDER").object
  if aprOrder is nothing then 
    msgbox "Согласование невозможно, т.к. не выдано поручение"
    exit sub
  end if

'  спрашиваем комментарий
    txt = GetComment("Введите комментарий к согласованию")
    if IsEmpty(txt) then exit sub
    if thisApplication.CurrentUser.Handle <> curUser.handle then txt = txt & " (Согласовал зам. " & _
              thisApplication.CurrentUser.Attributes("ATTR_KD_FIO").value & ")"
' закрываем поручение 
    call ThisApplication.ExecuteScript("CMD_KD_ORDER_LIB","SetOrderDone",aprOrder,txt, "Согласовано") 

  set agreeObj = GetAgreeObjByObj(docObj)
  if agreeObj is nothing then exit sub
   
  ' проверяем все ли закрыто  в блоке
  if CheckBlockFinished(agreeObj, aprRow.Attributes("ATTR_KD_APRV_NO_BLOCK").value) then 
    ' создаем если нужно следующее поручений
      if not CreateAproveOrders(agreeObj) then
        call Set_DocAprDone(docObj) ' если не создали ни одного, то закрываем документ
      end if
  end if

  thisForm.Close false
end sub

'==============================================================================
sub Reject_Doc(docObj)
  'ищем строку и поручение человека
  set agreeObj = GetAgreeObjByObj(docObj)
  if agreeObj is nothing then exit sub
  set curUser = GetCurUser()
  set aprRow = Get_AproveRow(curUser, docObj)
  if aprRow is nothing  then exit sub
  set aprOrder = aprRow.Attributes("ATTR_KD_LINK_ORDER").object
  if aprOrder is nothing then 
    msgbox "Согласование невозможно, т.к. не выдано поручение"
    exit sub
  end if
'  спрашиваем комментарий 
  txt = GetComment("Введите причину отказа") 
  
  if trim(txt) = "" then 
      msgbox "Невозможно отклонить документ не указав причину." & vbNewLine & _
        "Пожалуйста, введите причину отклонения", vbCritical, "Не задана причина отклонения!"
      exit sub  
    end if
' закрываем поручение 
  if thisApplication.CurrentUser.Handle <> curUser.handle then txt = txt & " (Отклонил зам. " & _
          thisApplication.CurrentUser.Attributes("ATTR_KD_FIO").value & ")"
  call ThisApplication.ExecuteScript("CMD_KD_ORDER_LIB","SetOrderDone",aprOrder,txt, "Отклонено") 
   
  if agreeObj.Attributes("ATTR_KD_FIRST_REJECT").Value = true then 
    '  если возвращаем сразу, отменяем документ
    call Set_DocReject(docObj,agreeObj, txt)
  else  
   ' проверяем все ли закрыто  в блоке
    if CheckBlockFinished(agreeObj, aprRow.Attributes("ATTR_KD_APRV_NO_BLOCK").value) then 
      ' создаем если нужно следующее поручений
        if not CreateAproveOrders(agreeObj) then
          call Set_DocAprDone(docObj) ' если не создали ни одного, то закрываем документ
        end if
    end if
  end if 
  thisForm.Close false
end sub

'==============================================================================
function Set_DocAprDone(docObj)
  Set_DocAprDone = false
  txt = ""
  
  set agreeObj = GetAgreeObjByObj(docObj)
  if agreeObj is nothing then exit function

  ' создаем если нужно следующее поручений
  if CreateAproveOrders(agreeObj) then
    exit function 'если только создали, то не все закончили
  end if

 ' проверяем все строки текущей ревизии       
'  ver = aprRow.attributes("ATTR_KD_CUR_VERSION").value
  ver = agreeObj.Attributes("ATTR_KD_CUR_VERSION").value

  isAlldone = true
  isRejected = false
  Set TAttrRows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows
  for each row in TAttrRows
    if  ver = row.attributes("ATTR_KD_CUR_VERSION").value then 
      set aprOrder = row.Attributes("ATTR_KD_LINK_ORDER").object
      if aprOrder is nothing then ' если нет поручения - выходим, т.к. точно не все готово
        isAllDone  = false
        exit function
      end if  
      if aprOrder.StatusName <> "STATUS_KD_ORDER_DONE" then ' если есть хоть одно без решения - ждем
        isAllDone  = false
        exit function
      end if  
      if aprOrder.attributes("ATTR_KD_POR_REASONCLOSE").value <> "Согласовано" _ 
          and Instr(aprOrder.attributes("ATTR_KD_POR_REASONCLOSE").value,"Делегировано ") = 0 then ' если хоть одно не согласовано
        isRejected = true
        txt = txt & aprOrder.attributes("ATTR_KD_NOTE").value & vbNewLine
'        exit for
      end if
    end if  
  next

  if not isAllDone then exit function ' если не все сделали - ждем
  
  if isRejected then 
    ' возвращаем на доработку  
    call Set_DocReject(docObj, agreeObj, txt) 
  else
    ' переводим в следуюший статус
    call Set_DocDone(docObj, agreeObj) 
  end if
end function
'==============================================================================
sub Set_DocDone(docObj, agreeObj)
 
  'set settings = GetSettings()
  set settings = GetSettingsByObjS(docObj, true)
  if settings is nothing  then exit sub
  
  st = settings.Attributes("ATTR_KD_FINISH_STATUS").value
  set stObj = nothing
  if st > "" then 
    set stObj = thisApplication.Statuses(st)
  end if
  if stObj is nothing then
    msgbox "Невозможно согласовать документ, т.к. не задан конечный статус", vbCritical, "Согласование отменено"
  end if

  docObj.permissions = SysAdminPermissions
  docObj.status =  stObj

  docObj.update
  agreeObj.permissions = SysAdminPermissions
  agreeObj.Attributes("ATTR_KD_CUR_VERSION").value = agreeObj.Attributes("ATTR_KD_CUR_VERSION").value +1
  ' переходим на следующую версию
  ' TODO может быть добавить копирование списка
  
  agreeObj.status =  thisApplication.Statuses("STATUS_KD_AGREED")
  agreeObj.update

  if not execSettingsFun1("ATTR_AFTER_AGREE_FUNCTION", docObj) then 
'    exit function
  end if

  call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", docObj)
  msgbox "Согласование завершено. Документ Согласован. Статус документа установлен [" & stObj.Description & "]"
end sub

'==============================================================================
sub Set_DocReject(docObj, agreeObj, txt)
  ' oтменяем все остальные поручения
  Set TAttrRows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows
  for each row in TAttrRows
      set aprOrder = Row.Attributes("ATTR_KD_LINK_ORDER").object
      if not aprOrder is nothing then  _
           call ThisApplication.ExecuteScript("CMD_KD_ORDER_LIB", "Set_OrderCancel",aprOrder)
  next
 
  set settings = GetSettingsByObj(docObj)
  if settings is nothing  then exit sub
  
  st = settings.Attributes("ATTR_KD_RETURN_STATUS").value
  set stObj = nothing
  if st > "" then 
    set stObj = thisApplication.Statuses(st)
  end if
  if stObj is nothing then ' то в начальный статус
    set stObj = thisApplication.Statuses(agreeObj.Attributes("ATTR_KD_START_STATUS").value)
  end if
  if stObj is nothing then 
    msgbox "Не удалось установить начальный статус", vbCritical, "Не удалось вернуть документ"
    exit sub
  end if
  
  docObj.permissions = SysAdminPermissions
  docObj.status =  stObj
  docObj.update
  agreeObj.permissions = SysAdminPermissions
  agreeObj.Attributes("ATTR_KD_CUR_VERSION").value = agreeObj.Attributes("ATTR_KD_CUR_VERSION").value +1
  ' переходим на следующую версию
  ' TODO может быть добавить копирование списка
  agreeObj.status =  thisApplication.Statuses("STATUS_KD_DRAFT")
  agreeObj.update

  call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", docObj)

  call ThisApplication.ExecuteScript("CMD_KD_ORDER_LIB", "CreateOrderToExcuterObj",txt,docObj)

  msgbox "Согласование завершено. Документ отклонен"
end sub


'создаем следующее поручение
'==============================================================================
function CreateNextOrder(aprRow)
  CreateNextOrder = false
  ThisScript.SysAdminModeOn
  set agreeObj = GetAgreeObjByObj(thisObject)
  if agreeObj is nothing then exit function

  ver = aprRow.attributes("ATTR_KD_CUR_VERSION").value
  bl = aprRow.attributes("ATTR_KD_APRV_NO_BLOCK").value
  inBl = aprRow.attributes("ATTR_KD_APRV_NPP").value + 1
  
  Set TAttrRows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows
  set nextRow =  GetRow(TAttrRows, ver,bl,inBl) 
  if nextRow is nothing then ' если не нашли следующую - начинаем следующий блок 
    set nextRow =  GetRow(TAttrRows, ver,bl+1,1) 
    if nextRow is nothing then 
      CreateNextOrder = true
      exit function
    end if 
  end if   
  if not  ThisApplication.ExecuteScript("CMD_KD_ORDER_LIB", "CreateAproveOrderDoc",nextRow,thisObject,agreeObj) then exit function

  CreateNextOrder = true
end function

'проверки перед отправкой на согласование
'==============================================================================
function CheckBeforeSend(agreeObj)
  CheckBeforeSend =  false
  ThisScript.SysAdminModeOn
  
  if not CheckHasAgreeRow(agreeObj, false) then exit function
  
  set settings = GetSettings()
  if settings is nothing  then exit function
  
  if not CheckAllAnswer(agreeObj) then exit function
  
'  set settings = GetSettings()
'  if settings is nothing  then exit function
  if not CheckStartStatus(settings) then exit function
  
  CheckBeforeSend = execSettingsFun1("ATTR_KD_CHECK_FUNCTION", thisObject)

end function

'==============================================================================
function CheckAllAnswer(agreeObj)
  CheckAllAnswer = false
  Set TAttrRows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows
  ver = cInt(agreeObj.Attributes("ATTR_KD_CUR_VERSION").value) - 1
  sts = ""
  for each row in TAttrRows
    if row.Attributes("ATTR_KD_CUR_VERSION").value = ver then 
      set order = Row.Attributes("ATTR_KD_LINK_ORDER").object
      if not order is nothing then 
        if order.StatusName = "STATUS_KD_ORDER_DONE" and order.Attributes("ATTR_KD_POR_REASONCLOSE").value = "Отклонено" then 
          if order.Attributes("ATTR_KD_ORDER_REP_NOTE").value = "" then _
              str = "Не задан ответ на замечание " & row.Attributes("ATTR_KD_APRV").Value & " :" & vbNewLine & _
                        order.Attributes("ATTR_KD_NOTE").value
        end if
      end if
    end if
  next
  if str > "" then 
    msgbox str, vbCritical, "Невозможно отправить на согласование"
  else
    CheckAllAnswer = true
  end if
end function
'==============================================================================
function CanEditRepNote(order,aprRow)
  CanEditRepNote = false 
  
  set settings = GetSettings()
  if settings is nothing  then exit function
  if not CheckStartStatusSil(settings, true, thisObject) then exit function ' только в начальных статусах
  
  set agreeObj = GetAgreeObjByObj(thisObject)
  if agreeObj is nothing then exit function
  ver = agreeObj.Attributes("ATTR_KD_CUR_VERSION").value
  if aprRow.Attributes("ATTR_KD_CUR_VERSION").value <> ver-1 then exit function 'только текущии версии согласования
  if order.StatusName <> "STATUS_KD_ORDER_DONE" then exit function
  if order.Attributes("ATTR_KD_POR_REASONCLOSE").value <> "Отклонено" then exit function
'  set whom = aprRow.Attributes("ATTR_KD_APRV").User
'  if whom is nothing then exit function
'  if whom.Handle <> thisApplication.CurrentUser.Handle then exit function
  CanEditRepNote = true
end function
'==============================================================================
function CheckHasAgreeRow(agreeObj, siln)
  CheckHasAgreeRow = false
  ver = agreeObj.Attributes("ATTR_KD_CUR_VERSION").value
  Set TAttrRows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows
  count = 0
  for each row in TAttrRows
    if row.Attributes("ATTR_KD_CUR_VERSION").value = ver then count = count + 1
  next
  if count = 0 then 
      if not siln then _
          msgbox "Согласование невозможно, т.к. не добавлено ни одного согласующего!" & vbNewLine &_
            "Добавьте согласующих или отправьте на подписание, если согласование не требуется.", vbCritical,  _
            "Отправить на согласование невозможно"
      exit function    
  else
    CheckHasAgreeRow = true
  end if
end function

'==============================================================================
function CheckStartStatus(settings)
  CheckStartStatus = CheckStartStatusSil(settings, false, thisObject)
end function
'==============================================================================
function CheckStartStatusSil(settings, isSil,docObj)
  CheckStartStatusSil = false
  st = trim(settings.Attributes("ATTR_KD_START_STATUS").value)
  if st = "" then 
    CheckStartStatusSil = true
    exit function
  end if
  st = ";" & st & ";"
  curSt = ";" & docObj.StatusName & ";" 
  if Instr(st, curSt) = 0 then 
    if not isSil then _
      msgbox "Согласование документа " & thisObject.ObjectDef.Description & " невозможно из статуса " & thisObject.Status.Description, _
          vbCritical, "Отправить на согласование невозможно"
    exit function    
  end if
  CheckStartStatusSil = true
end function  
 '==============================================================================
function execSettingsFun1(AttrName, docObj)
  execSettingsFun1 =  false
  set settings =  GetSettingsByObjS(docObj, true)
  if settings is nothing  then  exit function
  str =  settings.Attributes(AttrName).value
  if str > "" then  
     strArr = split(str,";")
     if UBound(strArr) < 1 then 
        execSettingsFun1 = true 
        exit function
     else
        on error resume next
        execSettingsFun1 = ThisApplication.ExecuteScript(strArr(0), strArr(1), docObj)
        Err.Clear
        on error GoTo 0
     end if 
  else
     execSettingsFun1 = true   
  end if
 end function 
'==============================================================================
function CanSendToSing(stEndbled)
  CanSendToSing =  false
  Err.Clear

  on error resume next
  CanSendToSing = thisApplication.ExecuteScript(thisObject.ObjectDefName,"Can_SendToSing", thisObject)
  if err.Number <> 0 then ' EV если функции нет, то стандатрным образом
    CanSendToSing = stEndbled
    err.clear
  end if
  on error goto 0

 end function 
'==============================================================================
sub  CreateAppr()
  ThisScript.SysAdminModeOn
  set agreeObj = GetAgreeObjByObj(thisObject)
  if agreeObj is nothing then exit sub
  
  set aprRow = nothing

  Set control = thisForm.Controls("QUERY_APROVE_LIST")
  iSel = control.ActiveX.SelectedItem
  If iSel >= 0 Then 
      set aprRow =  control.value.RowValue(iSel)
      if agreeObj.Attributes("ATTR_KD_CUR_VERSION").value <> aprRow.Attributes("ATTR_KD_CUR_VERSION").value then 
          set aprRow = nothing
      else    
        set curRow = Get_AproveRow(GetCurUser(), thisObject) ' чтобы нельзя было добавить в предыдущие блоки
        if not curRow is nothing then 
          if curRow.Attributes("ATTR_KD_APRV_NO_BLOCK").value <= bl then _
            set aprRow = nothing
        end if  
      end if 
  end if  

'заполняем поля по умолчанию  
  Set frmSetShelve = ThisApplication.InputForms("FORM_KD_ADD_APPROVE")
  if not aprRow is nothing then 
    frmSetShelve.Attributes("ATTR_KD_APRV_NO_BLOCK").Value = aprRow.Attributes("ATTR_KD_APRV_NO_BLOCK").Value
'    frmSetShelve.Attributes("ATTR_KD_BLOCKS").Value = Cstr(aprRow.Attributes("ATTR_KD_APRV_NO_BLOCK").Value)
'TODO потом надо будет прикрутить механизм правильной разадчи срока
    frmSetShelve.Attributes("ATTR_KD_ARGEE_TIME").Value = aprRow.Attributes("ATTR_KD_ARGEE_TIME").value
  else   
    frmSetShelve.Attributes("ATTR_KD_APRV_NO_BLOCK").Value = _
        GetMaxBl(agreeObj, agreeObj.Attributes("ATTR_KD_CUR_VERSION").value) + 1
    'frmSetShelve.Attributes("ATTR_KD_ARGEE_TIME").Value =  DateAdd ("d",3, Date)
  end if
  frmSetShelve.Attributes("ATTR_KD_DOCBASE").value = thisObject'agreeObj
  frmSetShelve.Attributes("ATTR_KD_HIST_OBJECT").value = agreeObj
'thisApplication.AddNotify "поля по умолчанию  -" & CStr(Timer())

  If frmSetShelve.Show and not FrmSetShelve.Attributes("ATTR_KD_APRV").User is nothing Then
    call createAppRow(agreeObj,frmSetShelve.Attributes("ATTR_KD_APRV_NO_BLOCK").Value, _
        frmSetShelve.Attributes("ATTR_KD_ARGEE_TIME").Value, frmSetShelve.Attributes("ATTR_KD_APRV").User)
  else 
    msgbox("Добавление отменено!")   
  end if
end sub
'==============================================================================
sub CopyPrevAppBlock(agreeObj, rows, rev)
  nrev = rev - 1
  for each row in rows
      if row.Attributes("ATTR_KD_CUR_VERSION").value = nrev then 
        call createAppRow(agreeObj,row.Attributes("ATTR_KD_APRV_NO_BLOCK").Value, row.Attributes("ATTR_KD_ARGEE_TIME").Value, _
                row.Attributes("ATTR_KD_APRV").User)  
      end if
  next
end sub
'==============================================================================
sub createAppRow(agreeObj,nBl,aTime, newUser)
    thisScript.SysAdminModeOn
  'записываем введеные данные
      Set TAttrRows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows
      set row = TAttrRows.Create
      'блокируем объект
      if not ThisApplication.ExecuteScript("CMD_KD_REGNO_KIB", "SetLock", agreeObj) then
        msgBox " Невозможно изменить список согласования, т.к. он заблокирован", VbCritical
        exit sub
      end if  

      row.Attributes("ATTR_KD_CUR_VERSION").value = agreeObj.Attributes("ATTR_KD_CUR_VERSION").value
      row.Attributes("ATTR_KD_APRV_NO_BLOCK").Value = nBl'frmSetShelve.Attributes("ATTR_KD_APRV_NO_BLOCK").Value
      row.Attributes("ATTR_KD_ARGEE_TIME").Value = aTime'frmSetShelve.Attributes("ATTR_KD_ARGEE_TIME").Value
'      row.Attributes("ATTR_KD_APRV_TYPE").Classifier = frmSetShelve.Attributes("ATTR_KD_APRV_TYPE").Classifier
      row.Attributes("ATTR_KD_APRV").Value = newUser'frmSetShelve.Attributes("ATTR_KD_APRV").User
      row.Attributes("ATTR_KD_LINKS_USER").Value = thisApplication.CurrentUser ' OP??
      TAttrRows.update
      agreeObj.Update
      call CreateOrderIsNeeded(agreeObj, row,TAttrRows)' EV если не в начальном статусе, то сразу создаем поручение
      
'      if thisObject.StatusName <> "STATUS_KD_DRAFT"  then  ' EV если не в начальном статусе, то сразу создаем поручение
'        call CreateOder(agreeObj, row,TAttrRows)
'      end if
      agreeObj.Unlock agreeObj.Permissions.LockType
      'msgbox("Добавлен согласующий " & frmSetShelve.Attributes("ATTR_KD_APRV").User.description)

end sub
'=============================================
' EV проверяем нужно ли создавать поручение
sub CreateOrderIsNeeded(agreeObj, row,TAttrRows)
  set docObj = agreeObj.Attributes("ATTR_KD_HIST_OBJECT").Object
  set settings = GetSettingsByObj(docObj)
  if settings is nothing  then  exit sub

  if not CheckStartStatusSil(settings, true,docObj) then 
'    rev = agreeObj.Attributes("ATTR_KD_CUR_VERSION").value
'    curBl = GetNextBlock(agreeObj) - 1 ' определяем по выданным поручениям
'    nBl = row.Attributes("ATTR_KD_APRV_NO_BLOCK").Value 
'    if curBl = -1 then  curBl = GetMaxBl(agreeObj, rev)
'      ' создаем если нужно следующее поручений
'    if nBl = curBl then  call CreateOder(agreeObj, row,TAttrRows)
    call CreateOder(agreeObj, row,TAttrRows)
  end if
end sub
'Максимальный блок в версии
'=============================================
function GetMaxBl(agreeObj, ver)
  GetMaxBl = 0
  if ver<0 then exit function
  Set TAttrRows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows
  for each row in TAttrRows
    if row.Attributes("ATTR_KD_CUR_VERSION").value = ver then 
        if GetMaxBl< row.Attributes("ATTR_KD_APRV_NO_BLOCK").value then _
           GetMaxBl = row.Attributes("ATTR_KD_APRV_NO_BLOCK").value
    end if 
  next
end function
'==============================================================================
sub CreateOder(agreeObj, row,TAttrRows)
    ' EV если не в статусе черновик, то сразу создаем поручение
    bl = row.attributes("ATTR_KD_APRV_NO_BLOCK").value
    rev = agreeObj.Attributes("ATTR_KD_CUR_VERSION").value
    set docObj = agreeObj.Attributes("ATTR_KD_HIST_OBJECT").Object
    isNeed = false
    for each tRow in TAttrRows
      if tRow.attributes("ATTR_KD_APRV_NO_BLOCK").value = bl and tRow.attributes("ATTR_KD_CUR_VERSION").value = rev then
        set order = tRow.attributes("ATTR_KD_LINK_ORDER").object
        if not order is nothing then 
          isNeed = true 
          exit for
        end if
      end if
    next
    if isNeed = true then 
      if ThisApplication.ExecuteScript("CMD_KD_ORDER_LIB", "CreateAproveOrderDoc",row,docObj,agreeObj)  then 
        agreeObj.Update 
        call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", docObj) ' чтобы добавить парава согласующему
      end if 
    end if  

end sub
'==============================================================================
function DellAprov(agreeObj,row)
  thisScript.SysAdminModeOn
  DellAprov = false
  set row = agreeObj.Attributes("ATTR_KD_TAPRV").Rows(row)
  aprover = row.Attributes("ATTR_KD_APRV").value
  ver = row.Attributes("ATTR_KD_CUR_VERSION").value
  if  ver <> agreeObj.Attributes("ATTR_KD_CUR_VERSION").value then 
      msgbox "Невозможно удалить согласующего из предыдущих циклов согласования", vbCritical, "Удаление отменено"
      exit function
  end if 
  if agreeObj.statusName = "STATUS_KD_AGREEMENT" then ' если на согласовании, то только то, что добавил сам
    set addUser = row.Attributes("ATTR_KD_LINKS_USER").User
    if addUser is nothing then 
       msgbox "Невозможно удалить, т.к согласующий добавлен не Вами!"
       Exit function 
    end if 
    set curUs = GetCurUser() 
    if not thisObject.RolesForUser(curUs).Has("ROLE_INITIATOR") then 
      if addUser.SysName <> curUs.SysName then 
         msgbox "Невозможно удалить, т.к согласующий добавлен не Вами!"
         Exit function 
      end if 
    end if  
  end if
  ' проверяем статус поручения
  set aprOrder = Row.Attributes("ATTR_KD_LINK_ORDER").object
  if not aprOrder is nothing then 
      if aprOrder.StatusName = "STATUS_KD_ORDER_DONE" then
          msgBox "Не возможно удалить согласующего, т.к. он уже согласовал документ", vbCritical, "Невозможно удалить!"
          exit function
      end if
      aprOrder.Permissions = sysAdminPermissions
      aprOrder.Erase
  end if 
  set rows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows
  bl = row.Attributes("ATTR_KD_APRV_NO_BLOCK").value
  rowCount = GetCountInBlock(rows, ver, bl)
  agreeObj.Permissions = sysAdminPermissions
  row.Erase
  if rowCount = 1 then 
    call ReNumBlock(rows,ver, bl, -1)
    ' и выдать поручение
    agreeObj.update
    'call CreateAproveOrders(agreeObj)
  end if
  agreeObj.update
  DellAprov = true
end function
'==============================================================================
sub ReNumBlock(rows,ver, bl, counter)
  'thisApplication.DebugPrint ver &" - "& bl
  for each row in rows
     if row.Attributes("ATTR_KD_CUR_VERSION").value = ver and row.Attributes("ATTR_KD_APRV_NO_BLOCK").value > bl then _
         row.Attributes("ATTR_KD_APRV_NO_BLOCK").value = row.Attributes("ATTR_KD_APRV_NO_BLOCK").value + counter
  next
  rows.Update
end sub

'==============================================================================
function GetCountInBlock(rows, ver, bl)
  GetCountInBlock = 0
  for each row in rows
    if row.Attributes("ATTR_KD_CUR_VERSION").value = ver and row.Attributes("ATTR_KD_APRV_NO_BLOCK").value = bl then _
        GetCountInBlock = GetCountInBlock + 1
  next
  
end function
'==============================================================================
function CheckRow(agreeObj, rows)
  set CheckRow = nothing
  ThisScript.SysAdminModeOn

  Set control = thisForm.Controls("QUERY_APROVE_LIST")
  iSel = control.ActiveX.SelectedItem
  If iSel < 0 Then 
     msgbox "Не выбран согласующий!"
     Exit function 
  end if
  
  set aprRow =  control.value.RowValue(iSel)
  
  bl = aprRow.Attributes("ATTR_KD_APRV_NO_BLOCK").value
  rev = agreeObj.Attributes("ATTR_KD_CUR_VERSION").value
  if rev <> aprRow.Attributes("ATTR_KD_CUR_VERSION").value then 
    msgbox "Невозможно изменить согласующего предыдущих циклов"
    exit function
  end if
  
  set order = aprRow.Attributes("ATTR_KD_LINK_ORDER").object
  if not order is nothing then   
    msgbox "Невозможно изменить согласующего, т.к. согласование для него начато", vbCritical, "Отменено"
    exit function
  end if
  
  set CheckRow = aprRow
end function
'изменение статусов
'==============================================================================
function SetStatuses(agreeObj)
    ThisScript.SysAdminModeOn
    SetStatuses = false
    'запоминаем начальный статус
    agreeObj.attributes("ATTR_KD_START_STATUS").value = thisObject.StatusName
    agreeObj.status = thisApplication.Statuses("STATUS_KD_AGREEMENT")
    agreeObj.update
    thisObject.status = thisApplication.Statuses("STATUS_KD_AGREEMENT")
    thisObject.Update
    call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", thisObject)

    SetStatuses = true
end function
'==============================================================================
'TODO подумать что делать с поручениями, которые уже выдали, но остальные не удалось?
function CreateAproveOrders(agreeObj)
  CreateAproveOrders =  false
  ThisScript.SysAdminModeOn
  if agreeObj.StatusName <> "STATUS_KD_AGREEMENT" then exit function
  ver = agreeObj.attributes("ATTR_KD_CUR_VERSION").value
  
  Set TAttrRows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows
  
  Set Progress = ThisApplication.Dialogs.ProgressDlg
  Progress.Start
  
  nextBl = GetNextBlock(agreeObj)
  if nextBl = 0 then 
    'msgbox "Не найдены блоки", vbCritical, "Ошибка" 'нечего создавать
    exit function
  end if

  i = 0  
  for each row in  TAttrRows
    i = i + 1
    Str = "Создание поручния : " & i & "; процент выполнения " 
    q = ( i + 1 ) *100 / ( TAttrRows.count + 1 )
    Progress.Position = q ' Установка текущего процента выполнения
    Progress.Text = Str & q & "%"

    if ver = row.attributes("ATTR_KD_CUR_VERSION").value then ' всегда текущаю версия
      'начинаем всегда с блока nextBl
      if row.attributes("ATTR_KD_APRV_NO_BLOCK").value = nextBl then 
        if not  ThisApplication.ExecuteScript("CMD_KD_ORDER_LIB", "CreateAproveOrderDoc",row,thisObject,agreeObj) then exit function
      end if  
    end if  
  next 
  Progress.Stop
  CreateAproveOrders = true  
end function

'==============================================================================
function GetNextBlock(agreeObj)
' слeдующий не расписанный блок
  GetNextBlock = 0
  set query = thisApplication.Queries("QUERY_KD_NEXT_BLOCK")
  query.Parameter("PARAM0") = agreeObj.handle
  set sh = query.Sheet
  if not sh is nothing then 
    if sh.RowsCount >0 then 
       GetNextBlock = sh.CellValue(0,0)
    end if 
  end if 

'  GetNextBlock = 1000
'  for each row in TAttrRows
'    curBl = row.attributes("ATTR_KD_APRV_NO_BLOCK").value 
'    if ver = row.attributes("ATTR_KD_CUR_VERSION").value then 
'      if curBl > bl then 
'        if GetNextBlock > curBl then GetNextBlock = curBl
'      end if
'    end if
'  next
'  if GetNextBlock = 1000 then GetNextBlock = 0
end function
 
'==============================================================================
sub ReturnToWork(docObj)
  txt = ""
  if docObj.StatusName <> "STATUS_KD_AGREEMENT" then 
    msgbox "документ не находиться на согласовании"
    exit sub
  end if
  Answer = MsgBox("Вы уверены, что хотите отменить текущий цикл согласования?", vbQuestion + vbYesNo,"Отменить согласование?")
  if Answer <> vbYes then exit sub

  ' спросить причину
'  txt = GetComment("Введите причину возврата")
'  if trim(txt) = "" then 
'    msgbox "Невозможно вернуть документ не указав причину." & vbNewLine & _
'      "Пожалуйста, введите причину возврата", vbCritical, "Не задана причина возврата!"
'    exit sub  
'  end if
'  TODO подумать куда созранить причину возврата

  set agreeObj = GetAgreeObjByObj(docObj)
  if agreeObj is nothing then exit sub

  call Set_DocReject(docObj, agreeObj, txt)

'  'создать, есть нужно поручение исполнителю
'  if thisObject.ObjectDefName = "OBJECT_KD_ZA_PAYMENT" then 
'    call CreateOrderToAutor(noteDlg.Text)
'  else
'    call CreateOrderToExcuter(noteDlg.Text)
'  end if
'  msgBox "Документ возвращен в работу"
  if not isEmpty(thisForm) then _
       thisForm.Close false
end sub
'==============================================================================
sub ApprsDel()
  count = 0
  set agreeObj = GetAgreeObjByObj(thisObject)
  if agreeObj is nothing then exit sub

  Set control = thisForm.Controls("QUERY_APROVE_LIST")
  iSel = control.ActiveX.SelectedItem
  If iSel < 0 Then 
     msgbox "Не выбран согласующий!"
     Exit Sub 
  end if  

  ar = thisapplication.Utility.ArrayToVariant(control.SelectedItems)
  Answer = MsgBox( "Вы уверены, что хотите удалить из списка согласующих " & Cstr(Ubound(ar)+1) _
         & " пользователя(ей)?" , vbQuestion + vbYesNo,"Удалить?")
  if Answer <> vbYes then exit sub

  for i = 0 to Ubound(ar)
     set aprRow =  control.value.RowValue(ar(i))
     if DellAprov(agreeObj, aprRow) then count = count + 1
  next
  
  if count>0 then 
    ' A.O.
    'msgbox "Удалено " & count & " пользователей"

    mBl = GetMaxBl(agreeObj, agreeObj.Attributes("ATTR_KD_CUR_VERSION").value)
    thisForm.Controls("TDMSEDIT_BLOCK").Value = mBl + 1
    
    set settings = GetSettings()
    if settings is nothing  then exit sub
'    if not CheckStartStatusSil(settings,true,thisObject) then  ' если не начальный статус - проверяем блок
     if thisObject.StatusName = "STATUS_KD_AGREEMENT" then  ' если не начальный статус - проверяем блок
      ' проверяем все ли закрыто  в блоке
      rev = agreeObj.Attributes("ATTR_KD_CUR_VERSION").value
      curBl = GetNextBlock(agreeObj) - 1 ' определяем по выданным поручениям
      if curBl = -1 then  curBl = GetMaxBl(agreeObj, rev)
      if CheckBlockFinished(agreeObj, curBl) then 
        ' создаем если нужно следующее поручений
          if not CreateAproveOrders(agreeObj) then
            call Set_DocAprDone(thisObject) ' если не создали ни одного, то закрываем документ
            if thisForm.SysName = "FORM_ARGEE_CREATE" then  thisForm.Close
          end if
      end if
    end if  
  end if
end sub 

'==============================================================================
function CheckAprUser(User,silent,agreeObj, docObj)
  CheckAprUser = false

  if user is nothing then exit function

  if agreeObj is nothing then exit function
  Set TAttrRows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows

  if User.Handle = thisApplication.CurrentUser.Handle then ' OP??
    if not silent then msgbox "Нельзя добавлять себя в согласующие", vbCritical
    exit function
  end if
  ver = agreeObj.Attributes("ATTR_KD_CUR_VERSION").value
  if IsExistsUserAndVal(TAttrRows, User, "ATTR_KD_APRV",ver,"ATTR_KD_CUR_VERSION") then 
    if not silent then _
          msgbox "Невозможно добавить согласующего " & User.Description & ", т.к. он уже есть в списке", VbCritical
    exit function
  end if
  CheckAprUser = execSettingsFun2("ATTR_KD_CHECK_APRV", docObj, user)
  
end function
'==============================================================================
function execSettingsFun2(AttrName, docObj, user)
  execSettingsFun2 =  false
  set settings = GetSettingsByObj(docObj)'GetSettings()
  if settings is nothing  then  exit function
  str =  settings.Attributes(AttrName).value
  if str > "" then  
     strArr = split(str,";")
     if UBound(strArr) < 1 then 
        execSettingsFun2 = true 
        exit function
     else
        on error resume next
        execSettingsFun2 = ThisApplication.ExecuteScript(strArr(0), strArr(1), docObj, user)
        Err.Clear
        on error GoTo 0
     end if 
  else
     execSettingsFun2 = true   
  end if
 end function 

'==============================================================================
sub UserUP()
   ThisScript.SysAdminModeOn
  set agreeObj = GetAgreeObjByObj(thisObject)
  if agreeObj is nothing then exit sub
  
  Set TAttrRows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows
  
  set aprRow = CheckRow(agreeObj, TAttrRows)'control.value.RowValue(iSel)' получение строки и проверки
  if aprRow is nothing then exit sub
  set aprRow = agreeObj.Attributes("ATTR_KD_TAPRV").Rows(aprRow)

  bl = aprRow.Attributes("ATTR_KD_APRV_NO_BLOCK").value
  rev = agreeObj.Attributes("ATTR_KD_CUR_VERSION").value
  
  set curRow = Get_AproveRow(GetCurUser(), thisObject)
  curBl = -1
  if not curRow is nothing then 
    curBl = curRow.Attributes("ATTR_KD_APRV_NO_BLOCK").value
    if curBl > bl-1 then 
      msgbox "Невозможно переместить согласующего в уже согласванные блоки", vbCritical,"Отменено"
      exit sub
    end if
  else 
    curBl = GetNextBlock(agreeObj) - 1 ' для автора документа определяем по выданным поручениям
    if curBl = -1 then  curBl = GetMaxBl(agreeObj, rev)
  end if  

  appCount =  GetCountInBlock(TAttrRows, rev, bl)
  if bl = 1 then 
    if appCount = 1 then 
      msgbox "Это минимальный номер блока в текущем цикле согласования", vbInformation
      exit sub
    end if
    Answer = msgbox ("Это минимальный номер блока в текущем цикле согласования." & vbNewLine & _
          "Вы уверены, что хотите переместить согласующего в новый блок?",  vbQuestion + vbYesNo, "Создать новый блок?")
    if Answer <> vbYes then exit sub
    call ReNumBlock(TAttrRows,rev, bl-1, +1)
  else ' чтобы не было дырок в блоках
     if appCount = 1 then _ 
         call ReNumBlock(TAttrRows,rev, bl, -1)
  end if
  
  'блокируем объект
  if not ThisApplication.ExecuteScript("CMD_KD_REGNO_KIB", "SetLock", agreeObj) then
    msgBox " Невозможно изменить список согласования, т.к. он заблокирован", VbCritical
    exit sub
  end if  

  If not aprRow is Nothing  Then
    if bl >1 then newBl = bl - 1 else newBl = 1
    aprRow.Attributes("ATTR_KD_APRV_NO_BLOCK").Value = newBl
    TAttrRows.Update
    agreeObj.Update
    if curBl = newBl then _
          call CreateOrderIsNeeded(agreeObj, aprRow,TAttrRows)' EV если не в начальном статусе, то сразу создаем поручение
    agreeObj.Unlock agreeObj.Permissions.LockType
  End If    


end sub
'==============================================================================
sub UserDown()
  ThisScript.SysAdminModeOn
  set agreeObj = GetAgreeObjByObj(thisObject)
  if agreeObj is nothing then exit sub
  
  Set TAttrRows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows
  
  set aprRow = CheckRow(agreeObj, TAttrRows)'control.value.RowValue(iSel)' получение строки и проверки
  if aprRow is nothing then exit sub
  set aprRow = agreeObj.Attributes("ATTR_KD_TAPRV").Rows(aprRow)

  bl = aprRow.Attributes("ATTR_KD_APRV_NO_BLOCK").value
  rev = agreeObj.Attributes("ATTR_KD_CUR_VERSION").value

  maxBl = GetMaxBL(agreeObj, rev)  
  appCount =  GetCountInBlock(TAttrRows, rev, bl)
  if bl = maxBl then 
    if appCount = 1 then 
      msgBox "Невозможно переместить согласующего ниже - он единственный согласующий в последнем блоке.", vbCritical, "Отменено"
      exit sub
    else
      Answer = msgbox ("Это последний номер блока в текущем цикле согласования." & vbNewLine & _
          "Вы уверены, что хотите переместить согласующего в новый блок?",  vbQuestion + vbYesNo, "Создать новый блок?")
      if Answer <> vbYes then exit sub
    end if
  else  
    if appCount = 1 then 
      call ReNumBlock(TAttrRows,rev, bl, -1)
      bl = bl - 1  
    end if  
  end if
  
  'блокируем объект
  if not ThisApplication.ExecuteScript("CMD_KD_REGNO_KIB", "SetLock", agreeObj) then
    msgBox " Невозможно изменить список согласования, т.к. он заблокирован", VbCritical
    exit sub
  end if  

  If not aprRow is Nothing  Then
    aprRow.Attributes("ATTR_KD_APRV_NO_BLOCK").Value = bl + 1
    TAttrRows.Update
    agreeObj.Update
    agreeObj.Unlock agreeObj.Permissions.LockType
  End If    

end sub
'==============================================================================
Sub CreateFromOrder()
  set rows = thisObject.Attributes("ATTR_KD_VD_REPGAZ").Rows
  if rows.Count = 0 then 
    msgbox "Связанные поручения не найдены", vbCritical, "Добавление отменено"
    exit sub
  end if
  set docIn = rows(0).Attributes("ATTR_KD_D_REFGAZNUM").Object
  if docIn is nothing then exit sub

  set agreeObj = GetAgreeObjByObj(thisObject)
  if agreeObj is nothing then exit sub
  Set TAttrRows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows
  rev = agreeObj.Attributes("ATTR_KD_CUR_VERSION").value
  set Qr = ThisApplication.Queries("QUERY_TOP_ORDER")
  qr.Parameter("PARAM0") = docIn.Handle
  set objs = qr.Objects
  mBl = GetMaxBl(agreeObj, rev) 
  for each order in objs
    call AddChiOrder(order,agreeObj,TAttrRows,rev, mBl)
  next

End Sub
'==============================================================================
sub AddChiOrder(order,agreeObj,TAttrRows,rev, mBl)
  set user = order.Attributes("ATTR_KD_OP_DELIVERY").User
  if not user is nothing then 
    ' проверяем пользователя
    if  thisApplication.ExecuteScript("FORM_KD_ADD_APPROVE", "CheckAprUser",User,true,agreeObj, thisObject) then 
      call ReNumBlock(TAttrRows,rev, mBl, +1)
      call AddbyOrder(agreeObj, mBl + 1 , rev, user)
    end if
  end if    
  for each chOrder in order.Objects.ObjectsByDef("OBJECT_KD_ORDER_REP")
    call AddChiOrder(chOrder,agreeObj,TAttrRows,rev, mBl)
  next
end sub
'==============================================================================
sub AddbyOrder(agreeObj, bl,rev, user)
      thisScript.SysAdminModeOn
      Set TAttrRows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows
      set row = TAttrRows.Create
      'блокируем объект
      if not ThisApplication.ExecuteScript("CMD_KD_REGNO_KIB", "SetLock", agreeObj) then
        msgBox " Невозможно изменить список согласования, т.к. он заблокирован", VbCritical
        exit sub
      end if  

      row.Attributes("ATTR_KD_CUR_VERSION").value = rev
      row.Attributes("ATTR_KD_APRV_NO_BLOCK").Value = bl
'      row.Attributes("ATTR_KD_ARGEE_TIME").Value = frmSetShelve.Attributes("ATTR_KD_ARGEE_TIME").Value
      row.Attributes("ATTR_KD_APRV").Value = user
      row.Attributes("ATTR_KD_LINKS_USER").Value = thisApplication.CurrentUser 'OP??
      TAttrRows.update
      agreeObj.Update
      agreeObj.Unlock agreeObj.Permissions.LockType

end sub
'=============================================
function CheckBlockFinished(argeeObj, bl)
  CheckBlockFinished = true
  set query = thisApplication.Queries("QUERY_KD_CHECK_BLOCK")
  query.Parameter("PARAM0") = argeeObj.Handle
  query.Parameter("PARAM1") = bl
  
  set sh = query.Sheet
  if not sh is nothing then 
    if sh.RowsCount >0 then  _
      CheckBlockFinished = false
  end if  

end function
'==============================================================================
function AddChief(docObj)
  'msgbox docObj.Description
  AddChief = true
  if not docObj.Attributes.Has("ATTR_KD_CHIEF") then exit function
  if docObj.Attributes("ATTR_KD_CHIEF").value <> "" then 
    set chief = docObj.Attributes("ATTR_KD_CHIEF").user
    if chief is nothing then exit function
    set agreeObj = GetAgreeObjByObj(docObj)
    if agreeObj is nothing then exit function
    nBl = 1
    aTime = DateAdd ("d", 3, Date) 
    if not  CheckAprUser(chief,true,agreeObj,docObj) then   
'      AddChief = false т.к. может быть сам себе
      exit function
    end if
    call createAppRow(agreeObj,nBl,aTime, chief)
  end if
end function    
'=============================================
function IsExistsUserAndVal(rows,user, ColNo, val, colNo2 )
  IsExistsUserAndVal = false
  for i = 0 to rows.Count - 1
    if not Rows(i).Attributes(ColNo).User is nothing then 
      if Rows(i).Attributes(ColNo).User.Handle = User.Handle and Rows(i).Attributes(ColNo2).value = val then  
        IsExistsUserAndVal = true
        exit function
      end if  
    end if
  next
end function
'==============================================================================
function AddExecOrderToPrep(docObj)
  AddExecOrderToReg = true
  'создаем поручение
  if docObj.Attributes.has("ATTR_KD_EXEC")then 
    set controller =  docObj.Attributes("ATTR_KD_EXEC").User
    if controller is nothing then  exit function
    set newOrder = thisApplication.ExecuteScript("CMD_KD_ORDER_LIB","CreateSystemOrder", docObj, "OBJECT_KD_ORDER_SYS", _
          controller, GetCurUser(), "NODE_TO_PREPARE","","")
  end if        
end function
'==============================================================================
function AddChiefOrder(docObj)
  AddChiefOrder = true
  'создаем поручение
  if docObj.Attributes.has("ATTR_KD_SIGNER")then 
    set controller =  docObj.Attributes("ATTR_KD_SIGNER").User
    if controller is nothing then  exit function
    set newOrder = thisApplication.ExecuteScript("CMD_KD_ORDER_LIB","CreateSystemOrder", docObj, "OBJECT_KD_ORDER_SYS", _
          controller, GetCurUser(), "NODE_KD_SING","","")
  end if        
end function
'==============================================================================
function AddApproverOrder(docObj)
  AddApproverOrder = true
  'создаем поручение
  if docObj.Attributes.has("ATTR_KD_ADRS") then 
      set controller =  docObj.Attributes("ATTR_KD_ADRS").User  
      if controller is nothing then  exit function
      set newOrder = thisApplication.ExecuteScript("CMD_KD_ORDER_LIB","CreateSystemOrder", docObj, "OBJECT_KD_ORDER_SYS", _
              controller, GetCurUser(), "NODE_KD_APROVER","","") ' OP??
  end if        
end function
'==============================================================================
' проверка обязательных полей
function checkPR(docObj)  
  
  checkPR = CheckOPDField(docObj)

  set docFile =  thisApplication.ExecuteScript("CMD_KD_FILE_LIB","GetFileByTypeByObj","FILE_KD_WORD",docObj)
  if docFile is nothing then
      checkPR = checkPR & "Не приложен документ." & vbNewLine
  end if
end function
'==============================================================================
function CheckOPDField(docObj)
  CheckOPDField = CheckDogProj(docObj)
  if docObj.Attributes("ATTR_KD_SIGNER").Value ="" then 
      CheckOPDField = CheckOPDField & "Не задан подписант." & vbNewLine
  end if
  'тема
  if trim(docObj.Attributes("ATTR_KD_TOPIC").Value) = "" then 
      CheckOPDField = CheckOPDField & "Не указана тема." & vbNewLine
  end if
  if trim(docObj.Attributes("ATTR_KD_PR_TYPEDOC").Value) = "" then 
      CheckOPDField = CheckOPDField & "Не указан тип документа." & vbNewLine
  end if
end function  
'==============================================================================
function CheckDogProj(docObj)
  CheckDogProj = ""
  if docObj.Attributes("ATTR_KD_WITHOUT_PROJ").Value = true then exit function
  
  dog = trim(docObj.Attributes("ATTR_KD_AGREENUM").Value)
  set rows = docObj.Attributes("ATTR_KD_TLINKPROJ").Rows
  if rows.Count = 0 then 
    proj = ""
  else
    proj ="1"  
  end if
  if dog = "" and rows.Count = 0 then _
    CheckDogProj = "Не указан ни договор, ни один проект." & vbNewLine
end function

'==============================================================================
' проверка обязательных полей
function checkMemo(docObj)  
  checkMemo = CheckMemoField(docObj)
  set docFile =  thisApplication.ExecuteScript("CMD_KD_FILE_LIB","GetFileByTypeByObj","FILE_KD_WORD",docObj)
  if docFile is nothing then
      checkMemo = checkMemo & "Не приложен оригинал СЗ." & vbNewLine
  end if
end function
'==============================================================================
function CheckMemoField(docObj)
  CheckMemoField = ""
'проверяем котролера
  if docObj.Attributes("ATTR_KD_SZ_TYPE").value = "" then 
      CheckMemoField = CheckMemoField & "Не задан вид служебной записки." & vbNewLine
  end if
'    typeMemo = docObj.Attributes("ATTR_KD_SZ_TYPE").Classifier.SysName
'    if typeMemo <> "NODE_KD_MEMO_MEMO" then 
      set controller =  docObj.Attributes("ATTR_KD_CHIEF").User
      if controller is nothing then 
        CheckMemoField = CheckMemoField & "Не задан руководитель."& vbNewLine
      end if
'    end if  
 
  if docObj.Attributes("ATTR_KD_ADRS").Value ="" then 
      CheckMemoField = CheckMemoField & "Не задан утверждающий." & vbNewLine
  end if
  'тема
  if trim(docObj.Attributes("ATTR_KD_TOPIC").Value) = "" then 
      CheckMemoField = CheckMemoField & "Не указана тема СЗ." & vbNewLine
  end if
  CheckMemoField = CheckMemoField & CheckDogProj(docObj)
end function
'==============================================================================
function SetControlNotEnable(enable)
  for each control in thisForm.Controls 
    control.Enabled = enable
  next
end function  
''==============================================================================
'' проверка обязательных полей
'function checkPaymentField()  
'end function 
'==============================================================================
' проверка обязательных полей
function checkPayment(docObj)  
  checkPayment = ""
  if docObj.Attributes("ATTR_KD_SIGNER").Value ="" then 
      checkPayment = checkPayment & "Не задан подписант." & vbNewLine
  end if
  'тема
  if trim(docObj.Attributes("ATTR_KD_TOPIC").Value) = "" then 
      checkPayment = checkPayment & "Не указана тема." & vbNewLine
  end if
  if trim(docObj.Attributes("ATTR_KD_ZA_TYPEDOC").Value) = "" then 
      checkPayment = checkPayment & "Не указан тип оплаты." & vbNewLine
  end if
  if trim(docObj.Attributes("ATTR_KD_ZA_MAINDOC").Value) = "" then 
      checkPayment = checkPayment & "Не указано основание для оплаты." & vbNewLine
  else
    if docObj.Attributes("ATTR_KD_ZA_MAINDOC").classifier.SysName = "NODE_KD_ZA_DOGOVOR" then _
      if trim(docObj.Attributes("ATTR_KD_AGREENUM").Value) = "" then checkPayment = checkPayment & "Не указан договор." & vbNewLine
  end if
  if trim(docObj.Attributes("ATTR_KD_CPNAME").Value) = "" then 
      checkPayment = checkPayment & "Не указан контрагент." & vbNewLine
  end if
  if trim(docObj.Attributes("ATTR_KD_ZA_SUMM").Value) = "" then 
      checkPayment = checkPayment & "Не указана сумма." & vbNewLine
  else
    sum = docObj.Attributes("ATTR_KD_ZA_SUMM").Value
    if IsNumeric(sum) then 
       if CDbl(sum) <= 0 then checkPayment = checkPayment & "Сумма должна быть больше нуля." & vbNewLine
       if CDbl(sum) > 100000 then 
          if docObj.Attributes("ATTR_KD_WITHOUT_PROJ").Value then _
              checkPayment = checkPayment & "Сумма заявки больше 100 000 может быть только по договору." & vbNewLine
       end if
    else
        checkPayment = checkPayment & "Cумма должна быть числом." & vbNewLine
    end if
  end if
  checkPayment = checkPayment & CheckDogProj(docObj)
end function
'=============================================
function CheckUser()
  CheckUser = CheckUserByObj(thisObject,"TDMSEDIT_APPR")
'  CheckUser = false
'  set agreeObj = GetAgreeObjByObj(thisObject)
'  if agreeObj is nothing then exit function

'  val = thisForm.Controls("TDMSEDIT_APPR").Value 
'  if val = "" then exit function
'  set user = nothing
'  if thisApplication.Users.Has(val) then _
'      set user = thisApplication.Users(val)
'  if user is nothing then
'    msgbox "Пользователь " & val & " не существует. Введите другого пользователя", vbCritical, "Ошибка ввода"
'    thisForm.Controls("TDMSEDIT_APPR").Value = ""
'    exit function
'  end if
'  CheckUser = CheckAprUser(user,false,agreeObj,thisObject)  
end function

'=============================================
function CheckUserByObj(docObj, contrName)
  CheckUserByObj = false
  set agreeObj = GetAgreeObjByObj(docObj)
  if agreeObj is nothing then exit function

  val = thisForm.Controls(contrName).Value 
  if val = "" then exit function
  set user = nothing
  if thisApplication.Users.Has(val) then _
      set user = thisApplication.Users(val)
  if user is nothing then
    msgbox "Пользователь " & val & " не существует. Введите другого пользователя", vbCritical, "Ошибка ввода"
    thisForm.Controls(contrName).Value = ""
    exit function
  end if
  CheckUserByObj = CheckAprUser(user,false,agreeObj,docObj)  
end function
