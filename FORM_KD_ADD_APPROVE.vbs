use CMD_KD_COMMON_LIB
use FORM_KD_AGREE
'=============================================
Sub Form_BeforeShow(Form, Obj)
'thisApplication.AddNotify "Form_BeforeShow -" & CStr(Timer())
   ShowUsers()
  'call Set_Blocks()    
'thisApplication.AddNotify "ShowUsers -" & CStr(Timer())
End Sub

''создаем список доступных блоков
''=============================================
'sub Set_Blocks
'   set agreeObj = thisForm.Attributes("ATTR_KD_HIST_OBJECT").Object
'   if agreeObj is nothing then exit sub
'   Set TAttrRows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows
'   set edit = ThisForm.Controls("ATTR_KD_BLOCKS").ActiveX 
'   ver = agreeObj.Attributes("ATTR_KD_CUR_VERSION").value
'   prevBl = GetMaxBl(TAttrRows, ver-1)
'   bl = GetMaxBl(TAttrRows, ver)
'   if bl<prevBl then bl = prevBl 
'   
'   arrSize = bl-prevBl'4'sheet.RowsCount 
'   ReDim arr(arrSize)
'   for i = 0 to arrSize
'    arr(i)= prevBl +i+1
'   next 
'   edit.ComboItems = arr 
'   if Cstr(thisForm.Attributes("ATTR_KD_APRV_NO_BLOCK").Value)<>"0" then _
'       thisForm.Attributes("ATTR_KD_BLOCKS").Value = Cstr(thisForm.Attributes("ATTR_KD_APRV_NO_BLOCK").Value)
'end sub

''Максимальный блок в версии
''=============================================
'function GetMaxBl(TAttrRows, ver)
'  GetMaxBl = 0
'  if ver<0 then exit function
'  for each row in TAttrRows
'    if row.Attributes("ATTR_KD_CUR_VERSION").value = ver then 
'        if GetMaxBl< row.Attributes("ATTR_KD_APRV_NO_BLOCK").value then _
'           GetMaxBl = row.Attributes("ATTR_KD_APRV_NO_BLOCK").value
'    end if 
'  next
'end function

'=============================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  if form.Controls.Has("TXT_" & Attribute.AttributeDefName) then 
    set docObj = thisForm.Attributes("ATTR_KD_DOCBASE").Object
    set agreeObj = thisForm.Attributes("ATTR_KD_HIST_OBJECT").Object
    if not CheckAprUser(Attribute.User,false,agreeObj,docObj) then 
        cancel = true
        exit sub
    end if
    ShowUser(Attribute.AttributeDefName)
  end if  
'   if Attribute.AttributeDefName = "ATTR_KD_BLOCKS" then 
'      if not checkBlock(Attribute.Value) then  
'        Cancel = true
'        exit sub
'      end if
'   end if
End Sub

''=============================================
'function checkBlock(val)
'  checkBlock = flase
'   set agreeObj = thisForm.Attributes("ATTR_KD_HIST_OBJECT").Object
'   if agreeObj is nothing then exit function
'   set edit = ThisForm.Controls("ATTR_KD_BLOCKS").ActiveX 
'   
'   for each item in edit.ComboItems
'    if item = val then 
'      checkBlock = true
'      exit function
'    end if
'   next
'end function
'Проверяем согласующего
'==============================================================================
function CheckAprUser(User,silent,agreeObj, docObj)
  CheckAprUser = false
  
  'set agreeObj = thisForm.Attributes("ATTR_KD_HIST_OBJECT").Object
  if agreeObj is nothing then exit function
  Set TAttrRows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows

  if User.Handle = thisApplication.CurrentUser.Handle then 
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
Sub Form_BeforeClose(Form, Obj, Cancel)
  Set Dict = ThisApplication.Dictionary("Close")
  If dict.Exists("OK") Then
    If dict("OK") Then 
      str = ""
      if form.Attributes("ATTR_KD_APRV").User is nothing then  _
        str = str & "Не выбран согласующий" & vbNewLine
'      if form.Attributes("ATTR_KD_BLOCKS").value = "" then  _
'        str = str &  "Не выбран блок" & vbNewLine
'      if form.Attributes("ATTR_KD_ARGEE_TIME").value = "" then _
'        str = str &  "Не задан срок согласования"
      if str>"" then   
        msgbox str, vbCritical, "Не заданы обязательные поля"
        cancel = true
      end if
   end if
  end if    
  if dict.Exists("OK") then dict.remove("OK")
End Sub
'==============================================================================
Sub OK_OnClick()
  Set dict = ThisApplication.Dictionary("Close")
  if dict.Exists("OK") then dict.remove("OK")
  dict.Add "OK", True
End Sub

'==============================================================================
Sub CANCEL_OnClick()
  Set Dict = ThisApplication.Dictionary("Close")
  if dict.Exists("OK") then dict.remove("OK")
  dict.Add "OK", False
End Sub

