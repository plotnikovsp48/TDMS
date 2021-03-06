use CMD_KD_FOLDER

'=================================
function Reg_Doc(obj)
  Reg_Doc = false

  'получить новый номер
  'RegNo = GetNewNO(obj)
  set ObjRoots = GET_FOLDER("",obj.ObjectDef) 

  RegNo = GetNewNOW(ObjRoots.Handle, obj.ObjectDefName)
  'Показать новый номер и дату
  Set frmSetShelve = ThisApplication.InputForms("FORM_KD_REG_DOC")
  call SetGlobalVarrible("DOC_DEF", obj.ObjectDefName)
  frmSetShelve.Attributes("ATTR_KD_NUM").Value = RegNo
  frmSetShelve.Attributes("ATTR_KD_ISSUEDATE").Value = Date
  frmSetShelve.Attributes("ATTR_KD_DOCBASE").Value = obj
  if obj.ObjectDefName = "OBJECT_KD_DOC_OUT" then _
    frmSetShelve.Attributes("ATTR_KD_DOC_PREFIX").Value = obj.Attributes("ATTR_KD_DOC_PREFIX").value
  frmSetShelve.Attributes("ATTR_KD_SUFFIX").Value = obj.Attributes("ATTR_KD_SUFFIX").value
    
  If frmSetShelve.Show Then
    ' сначала надо проверить, что номер верный
    if frmSetShelve.Attributes("ATTR_KD_NUM").Value = "" or frmSetShelve.Attributes("ATTR_KD_NUM").Value = 0 then 
      Msgbox "Регистрационный номер не задан. Введите номер. Регистрация документа отменена.", _
          VbCritical, "Регистрация документа отменена."
      exit function 
    end if
    RegNo = frmSetShelve.Attributes("ATTR_KD_NUM").Value
    RegDate = frmSetShelve.Attributes("ATTR_KD_ISSUEDATE").Value
    LetNo = CheckRegNo(obj, RegNo)
    if LetNo >"" then
      Msgbox "Регистрационный номер " & RegNo & " присвоен другому документу ["& LetNo &"]."& vbNewLine & _
          "Введите другой номер. Регистрация документа отменена.", VbCritical, "Регистрация документа отменена."
      exit function 
    end if
    obj.Attributes("ATTR_KD_NUM").Value = RegNo
    obj.Attributes("ATTR_KD_ISSUEDATE").Value = RegDate
   'Записaть зарегистрировавшего
    obj.Attributes("ATTR_KD_REG").Value = thisApplication.CurrentUser
   'поменять статус
    if obj.ObjectDefName = "OBJECT_KD_DIRECTION" then 
      obj.Status = ThisApplication.Statuses("STATUS_KD_IN_FORCE")  
      call thisApplication.ExecuteScript("CMD_KD_ORDER_LIB", "clouseAllOrderByRes", obj, "NODE_TO_PREPARE")
     else
      obj.Status = ThisApplication.Statuses("STATUS_SIGNED")
      call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", thisObject)
    end if
    obj.Update
    Reg_Doc = true
    msgbox "Документ зарегистрирован"
  end if  
end function
'=================================
sub Set_RegNo(obj)

    'перенести в другой год, если нужно 
    if not MoveToYear(obj, nothing) then 
      msgbox "Не удалось переместить документ в папку года", vbExclamation
      'exit sub
    end if
    'получить новый номер
    RegNo = GetNewNO(obj)
    RegDate = now
      'TODO добавить проверку на повтор и выдачу нового номера 3 раза
  '    LetNo = CheckRegNo(obj, RegNo)
  '    if LetNo >"" then
  '      Msgbox "Регистрационный номер " & RegNo & " привоен другому документу ["& LetNo &"]."& vbNewLine & _
  '          "Веедите другой номер. Регистрация документа отменена.", VbCritical, "Регистрация документа отменена."
  '      exit function 
  '    end if 
    obj.Attributes("ATTR_KD_NUM").Value = RegNo
    obj.Attributes("ATTR_KD_ISSUEDATE").Value = RegDate
   'Записaть зарегистрировавшего
    obj.Attributes("ATTR_KD_REG").Value = thisApplication.CurrentUser

    obj.Update

end sub
'=================================
function GetNewNO(Obj)
  GetNewNO = GetNewNOW(obj.parent.handle,obj.ObjectDefName)
end function  
'=================================
function GetNewNOW(parentHandle, ObjDefName)

  GetNewNOW = 0
  Set QueryDoc = thisApplication.Queries("QUERY_GET_MAX_NO")
  QueryDoc.Parameter("PARAM0") = parentHandle
  QueryDoc.Parameter("PARAM1") = ObjDefName
  Set sh = QueryDoc.Sheet
  if not sh is nothing then 
    if sh.RowsCount >0 then 
       IntValue = IntTryParse(sh.CellValue(0,0))
       GetNewNOW = IntValue
    end if 
  end if 
  GetNewNOW = GetNewNOW + 1
end function

'=================================
function CheckRegNo(obj, RegNo)
  CheckRegNo = CheckRegNoW(obj.parent.handle, obj.ObjectDefName, RegNo,obj.Handle, false )
end function
'=================================
function CheckRegNoW(parentHandle, ObjDefName, RegNo, ObjHandle, isReserve)
  CheckRegNoW = ""
  Set QueryDoc = thisApplication.Queries("QUERY_KD_CHECK_NO")
  QueryDoc.Parameter("PARAM0") = parentHandle
  QueryDoc.Parameter("PARAM1") = ObjDefName
  QueryDoc.Parameter("PARAM2") = RegNo
  QueryDoc.Parameter("PARAM3") = ObjHandle
  
  Set sh = QueryDoc.Sheet
  if not sh is nothing then 
    if sh.RowsCount >0 then 
      CheckRegNoW = sh.CellValue(0,0)
      if sh.CellValue(0,1) then CheckRegNoW = "(Зарезервирован) " & CheckRegNoW
'      if not sh.Objects is nothing then
'         set otherObj = sh.Objects(0)
'         if not otherObj is nothing then _
'           if obj.Handle <> otherObj.Handle then CheckRegNo = otherObj.Desciption
'      end if    
    end if     
  end if 

end function
'=================================
' EV безопастно преобразует в число
function IntTryParse (value)
  IntTryParse=0
  On Error Resume Next ' Включаем собственный обработчик ошибок выполнения
  if VarType(value) = vbInteger or VarType(value) = VbLong then 
    IntTryParse = CLng(value)
  else
    IntTryParse = CLng(value)
    If Err<>0 Then 
      ind=InStr(value,".")
'    msgbox value&" - "& ind
      if  ind>0 then
        value=left(value,ind-1)
'      msgbox value
        IntTryParse= CLng(value)
      end if
    end if
  end if  
  if IntTryParse > 2147483646 then 
    IntTryParse = 0 
    msgbox "Превышен размер допустимого значения номера. " & vbNewLine & "Следующий номер начнется с 1.", vbCritical
  end if
  Err.Clear         ' Метод Clear сбрасывает состояние обработчика ошибки
  On Error GoTo 0   ' Отключаем собственный обработчик ошибок выполнения
end function

'=================================
function Get_Dept (user)
  set Get_Dept = user.Attributes("ATTR_KD_DEPART").Object
end function
'=================================
function Get_Suffix(obj)
  Get_Suffix = ""
  if obj.attributes.has("ATTR_KD_SUFFIX") then
    if obj.attributes.has("ATTR_KD_PR_TYPEDOC") then 
      if obj.Attributes("ATTR_KD_PR_TYPEDOC").value > "" then 
       td = obj.Attributes("ATTR_KD_PR_TYPEDOC").Classifier.Code
       if td <> "" then 
          if td = "К" then
             Get_Suffix = Get_Suffix & "/" & td
          else 
             Get_Suffix = Get_Suffix & "-" & td
          end if   
       end if
      end if
    end if 
  end if
  if obj.attributes.has("ATTR_KD_KT") then 
    if obj.attributes("ATTR_KD_KT").value then Get_Suffix = Get_Suffix & "/КТ" 
  end if
end function
'=================================
function Get_Prifix(obj)
  Get_Prifix = ""
  if not Obj.Attributes.has("ATTR_KD_DEPART") then exit function
  
'  if obj.Attributes.Has("ATTR_KD_CONF") then 
'    if obj.Attributes("ATTR_KD_CONF").value>"" then  
'        Get_Prifix =  obj.Attributes("ATTR_KD_CONF").Classifier.Code
'    end if    
'    if Get_Prifix > "" then Get_Prifix = Get_Prifix & "_"
'  end if
'  
  set dept = Obj.Attributes("ATTR_KD_DEPART").object
  if dept is nothing then exit function
  Get_Prifix = Get_Prifix & dept.Attributes("ATTR_CODE").value

' переехало в суфикс
'  if obj.Attributes.Has("ATTR_KD_PR_TYPEDOC") then 
'    if obj.Attributes("ATTR_KD_PR_TYPEDOC").value > "" then 
'       td = obj.Attributes("ATTR_KD_PR_TYPEDOC").Classifier.Code
'       Get_Prifix = Get_Prifix & "-" & td
'    end if 
'  end if
  
end function 

'=================================
function Get_Order_Prifix(obj)
  Get_Order_Prifix = ""
  
  set autUser = obj.Attributes("ATTR_KD_AUTH").user
  if autUser is nothing then exit function
  set dept = Get_Dept (autUser)
  if dept is nothing then exit function
  Get_Order_Prifix = dept.Attributes("ATTR_CODE").value
end function 
'=================================
function Get_Obj_Sys_ID(objType)
  set Get_Obj_Sys_ID = nothing
  Set QueryDoc = thisApplication.Queries("QUERY_GET_OBJECT_SYSTEM_ID")
  QueryDoc.Parameter("PARAM0") = objType
  Set objs = QueryDoc.Objects
  if not objs is nothing then 
    if objs.Count >0 then _
      set Get_Obj_Sys_ID = objs(0)
  end if 
end function

'=================================
function Get_Sys_ID(docObj)
  Get_Sys_ID = 0
'  thisApplication.AddNotify "Get_Sys_ID - " & cstr(timer)
  thisScript.SysAdminModeOn
  set objType = docObj.ObjectDef
  if docObj.IsKindOf("OBJECT_KD_ORDER") then set  objType =  docObj.ObjectDef.SuperObjectDefs(0)(0)

  attrName = "ATTR_" & objType.SysName
  if not thisApplication.Attributes.Has(attrName) then 
    Get_Sys_ID = Get_Sys_ID_Old(docObj)
  else
    set attr = thisApplication.Attributes(attrName)   ' обязательно сделать присвоение переменной атрибута (set attr=)
    attr.Increment
    Get_Sys_ID = attr.Value 'thisApplication.Attributes(attrName).Value
  end if
'  thisApplication.AddNotify "end Get_Sys_ID - " & cstr(timer)
end function
'=================================
function Get_Sys_ID_Old(docObj)
  
  Get_Sys_ID_Old = 0
  
  set objType = docObj.ObjectDef
  if docObj.IsKindOf("OBJECT_KD_ORDER") then set  objType =  docObj.ObjectDef.SuperObjectDefs(0)(0)
  
  set SysIDObj = Get_Obj_Sys_ID(objType.SysName)
  if SysIDObj is nothing then 
    msgBox " Невозможно создать документ, т.к. не найден объект хранения ID", VbCritical
    exit function
  end if
  if not SetLock(SysIDObj) then
    msgBox " Невозможно создать документ, т.к. объект хранения ID заблокирован", VbCritical
    exit function
  end if  
  SysIDObj.update
  if docObj.IsKindOf("OBJECT_KD_ORDER") then  ' EV для проучений с учетом года
    orderYear = Get_Year()
    if SysIDObj.attributes("ATTR_KD_YEAR").value < orderYear then ' EV если год поменялся, то обнуляем номер
        SysIDObj.attributes("ATTR_KD_IDNUMBER").value = 0
        SysIDObj.attributes("ATTR_KD_YEAR").value = orderYear
    end if  
  end if
  Get_Sys_ID_Old = SysIDObj.attributes("ATTR_KD_IDNUMBER").value + 1
  'docObj.Attributes("ATTR_KD_IDNUMBER").value = Get_Sys_ID
  SysIDObj.attributes("ATTR_KD_IDNUMBER").value = Get_Sys_ID_Old
  SysIDObj.update
  SysIDObj.Unlock SysIDObj.Permissions.LockType

end function
'=================================
function SetLock(obj)
  SetLock = false
  for i = 0 to 10  
    If obj.Permissions.Locked  = FALSE Then 
      obj.Permissions = SysAdminPermissions
      obj.Lock
      SetLock = true
      Exit function 
    else  
      if obj.Permissions.LockOwner = true then
        SetLock = true
        Exit function ' Объект заблокирован тек. пользователем
      end if
      ThisApplication.Utility.Sleep 500
    end if
  next  
end function

'==============================================================================
function Get_Year()
  Get_Year = Date
  Get_Year = Year(Get_Year) 
end function

'=================================
Sub SetIcon(Obj)
  Obj.Permissions = SysAdminPermissions ' задаем права 
  status = Obj.StatusName
  stArr =  Split(status,"_") 
  ind = Ubound(stArr)
  if ind < 0 then exit sub
   
  objDef = obj.ObjectDefName
  imgName = "IMG_" & objDef & "_" & stArr(ind)
  'thisApplication.AddNotify imgName  
  if ThisApplication.Icons.Has(imgName) then
    if not imgName = Obj.Icon.SysName then
      Obj.Icon = ThisApplication.Icons(imgName)
    end if
  else ' EV если не нашли ставим от объекта
    if not obj.ObjectDef.Icon.SysName = Obj.Icon.SysName then
      Obj.Icon = obj.ObjectDef.Icon
    end if
     
  end if
end sub
'==============================================================================
function GetNewYear(numObj)
  GetNewYear = Year(Date)

  if numObj is nothing then exit function
  rDate = numObj.Attributes("ATTR_KD_ISSUEDATE").Value
  if rDate <> "" then 
     rDate = cDate(rDate)
  else
    rDate = numObj.CreateTime
  end if 
  GetNewYear = Year(rDate)
end function
'==============================================================================
function Check_Date(sDate)
  thisScript.SysAdminModeOn
  Check_Date = ""
'  sDate = thisObject.Attributes("ATTR_KD_ISSUEDATE").Value
  if sDate = "" then 
    Check_Date = Check_Date & "Незадана дата регистрации" & NewLine
    exit function
  end if
  if not isDate(sDate) then 
    Check_Date = Check_Date & "Неверная дата регистрации" & NewLine
    exit function
  end if
  dDate = cDate(sDate)

  set numRow = thisForm.Attributes("ATTR_KD_HIST_OBJECT").object
  nDate = GetNewYear(numRow)
  if Year(dDate) <> nDate then 
'    if thisForm.Controls("ATTR_KD_NUM").ReadOnly then  ' EV значит из выбранных номеров
    if not numRow is nothing then  ' EV значит из выбранных номеров
      Check_Date = Check_Date & "Зарегистрировать письмо можно только в тот год, когда был зарезервирован номер" & NewLine
    else
      Check_Date = Check_Date & "Нельзя зарегистировать письмо предыдущим или следующим годом" & NewLine
    end if
  end if
end function
'==============================================================================
'перенести в другой год, если нужно
function MoveToYear(docObj,numObj)
  thisScript.SysAdminModeOn
'  if not thisForm.Controls("ATTR_KD_NUM").ReadOnly then 
'    MoveToYear = true
'    exit function
'  end if
  MoveToYear = false
  ' текущий год
  set loYear = docObj.Parent
  if loYear is nothing then exit function
  lYear = cInt(loYear.description)
  rDate = GetNewYear(numObj)  
  if lYear <> rDate then 
      set fold = loYear.parent
      if fold.Content.has(cStr(rDate)) then
        set newYear = fold.Content(cStr(rDate))
      else
        set newYear = thisApplication.ExecuteScript("CMD_KD_FOLDER", "CreateFolderYear", fold, rDate)
        if newYear is nothing then exit function
      end if
      docObj.Parent = newYear
      newYear.Objects.Add docObj
      loYear.Objects.Remove docObj
      docObj.update
  end if
  MoveToYear = true
 
end function
