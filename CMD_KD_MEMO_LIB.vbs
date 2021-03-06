use CMD_KD_REGNO_KIB
use CMD_KD_FILE_LIB
use CMD_KD_CURUSER_LIB

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
Sub BTN_DEL_SINGER_OnClick()
   Del_User("ATTR_KD_ADRS")
End Sub
'=============================================
Sub BTN_DEL_CHIEF_OnClick()
   Del_User("ATTR_KD_CHIEF")
End Sub
'=============================================
sub SetFieldAutoComp
      Set ctrl = thisForm.Controls("ATTR_KD_ADRS").ActiveX
'      Set query = ThisApplication.Queries("QUERY_KD_SINGERS")
'      set result = query.Sheet.Users
      set result =  thisApplication.Groups("GROUP_MEMO_CHIEFS").Users
      ctrl.ComboItems = result
end sub

'=============================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)

  if Attribute.AttributeDefName = "ATTR_KD_CHIEF" then
      if Attribute.Value > "" then
        typeMemo = "" 
        if thisObject.Attributes("ATTR_KD_SZ_TYPE").value > "" then _
            typeMemo = thisObject.Attributes("ATTR_KD_SZ_TYPE").Classifier.SysName
        if not CheckContrl(Attribute.User,typeMemo) then _
          cancel = true
      end if 
  end if

  if Attribute.AttributeDefName = "ATTR_KD_SZ_TYPE" then
    set contr = thisObject.Attributes("ATTR_KD_CHIEF").User
    if not contr is nothing then
       if not CheckContrl(contr,Attribute.Classifier.SysName) then _
         thisObject.Attributes("ATTR_KD_CHIEF").Value =""
    else
      thisObject.Attributes("ATTR_KD_CHIEF").Value = thisApplication.CurrentUser
    end if
  end if
  if Attribute.AttributeDef.SysName = "ATTR_KD_ADRS" then 
    if attribute.Value <> "" then 
      if not  obj.Attributes("ATTR_KD_CHIEF").User is nothing then 
        if attribute.User.SysName = obj.Attributes("ATTR_KD_CHIEF").User.SysName then 
          msgbox "Невозможно установить Утверждающего, того же сотрудника, что указан в поле Руководитель", _
              vbCritical, "Невозможно установить Утверждающего"
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
End Sub
'=============================================
function CheckContrl(controler,typeMemo)
  CheckContrl = true 
  EnabledCtrl()' чтобы заблокировать кнопку
  if controler is nothing then exit function
  set exec = thisObject.Attributes("ATTR_KD_EXEC").User
  if exec is nothing then exit function
  
  if controler.SysName <> exec.SysName then exit function
  if typeMemo = "NODE_KD_MEMO_MEMO" OR typeMemo = "NODE_KD_MEMO_ORDER" then exit function
  
  if not controler.Groups.Has("GROUP_LEAD_DEPT") and _
    not controler.Groups.Has("GROUP_CHIEFS") then 
      msgbox  "Вы не входите в группу руководства или начальников отделов и не можете подписать данную СЗ." ,_
           vbCritical, "Не возможно задать руководителя!" 
      CheckContrl = false
      exit function
  end if  
end function
'=============================================
Sub BTN_ADD_SELF_OnClick() 
  typeMemo = "" 
  if thisObject.Attributes("ATTR_KD_SZ_TYPE").value > "" then _
      typeMemo = thisObject.Attributes("ATTR_KD_SZ_TYPE").Classifier.SysName

  if CheckContrl(thisApplication.CurrentUser,typeMemo) then _
      thisObject.Attributes("ATTR_KD_CHIEF").Value = thisApplication.CurrentUser
End Sub

'==============================================================================
' отправить СЗ на подписание
sub send_Memo_to_Check()

  thisObject.saveChanges 0
  ' проверяем обязательные поля
  txt = ThisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "checkMemo", thisObject)
  if txt > ""  then 
    ans = msgbox( "Не все обязательные поля заполнены :" & vbNewLine & txt & vbNewLine,  _
       vbcritical, "Отправка отменена!")
    exit sub    
  end if 
  'проверяем статус
  if thisObject.StatusName <> "STATUS_KD_DRAFT" then  
    msgbox "Невозможно отправить документ на подписании, т.к. документ не находиться в статусе Черновик", vbCritical,"Отправка отменена!"
    exit sub
  end if

  'создаем поручение
  set controller =  thisObject.Attributes("ATTR_KD_CHIEF").User
  if controller is nothing then  exit sub
  if controller.SysName = thisApplication.CurrentUser.SysName then 
    msgbox "Невозможно отправить документ на подписании, т.к. Вы являететсь подписантом документа. Нажмите кнопку подписать",_
         vbCritical,"Отправка отменена!"
    exit sub
  end if

  'создаем поручение
  set controller =  thisObject.Attributes("ATTR_KD_CHIEF").User
  if controller is nothing then  exit sub
  set newOrder = thisApplication.ExecuteScript("CMD_KD_ORDER_LIB","CreateSystemOrder", thisObject, "OBJECT_KD_ORDER_SYS", _
          controller, GetCurUser(), "NODE_KD_SING","","")
  'меняем статус
  thisObject.Status = thisApplication.Statuses("STATUS_SIGNING") 
  ThisObject.SaveChanges()
  call clouseAllOrderByRes(thisObject, "NODE_KD_RETUN_USER")
'  set orders = GetMyOrders(thisObject)
'  if not orders is nothing then 
'    for each order in orders  
'        call SetOrderDone(order,"", "Выполнено") 
'    next 
'  end if  
  call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", thisObject)
  ' A.O. 
  'msgbox "Документ передан на подписание"
  thisForm.Close isCanEdit()
end sub

'=================================
function Reg_Memo(obj)
  Reg_Memo = false
  if obj.Attributes("ATTR_KD_NUM").Value = 0 or obj.Attributes("ATTR_KD_ISSUEDATE").Value = "" then 
      Set_RegNo(obj)
  end if  

'EV 2018-01-18 убираем автоформирование скана
'  set file = thisApplication.ExecuteScript("CMD_KD_FILE_LIB","GetFileByTypeByObj","FILE_KD_SCAN_DOC",obj)
'  if file is nothing then 
''    'загрузить скан подписанной СЗ
''    msgbox "Приложите скан подписанной СЗ"
''    call thisApplication.ExecuteScript("CMD_KD_FILE_LIB","LoadFileToDocByObj","FILE_KD_SCAN_DOC", obj)
'    if not createScan(obj) then exit function
'    set file =  thisApplication.ExecuteScript("CMD_KD_FILE_LIB","GetFileByTypeByObj","FILE_KD_SCAN_DOC",obj)
'    if file is nothing then exit function
'  end if
  
  Reg_Memo = true
end function

'=================================
function createScan(obj)
  createScan = false
  set wfile = thisApplication.ExecuteScript("CMD_KD_FILE_LIB","GetFileByTypeByObj","FILE_KD_WORD",obj)
  if wfile is nothing then exit function
  cfileName = getFileName(wfile.FileName) & "###.pdf"
  if not obj.Files.Has(cfileName) then 
    call CreatePDFFromFile(wfile.WorkFileName, obj, nothing)
    obj.SaveChanges 16384 ' 0
  end if
  if not obj.Files.Has(cfileName) then exit function
  set sFile = obj.Files(cfileName)
  Set newFile = Obj.Files.AddCopy(sFile, "scan_" & getFileName(wfile.FileName) & ".pdf")
  newFile.FileDef = thisApplication.FileDefs("FILE_KD_SCAN_DOC")
  obj.Files.Main = newFile
  obj.SaveChanges 16384 
  createScan = true
end function
'=================================

use FORM_KD_DOC_AGREE
function Sing_Memo()
  Sing_Memo = false
    set orders = GetMyOrders(thisObject)
    if not orders is nothing then 
        for each order in orders'GetMyOrder(thisObject)  
            call SetOrderDone(order,"Подписано", "Выполнено") 
        next 
    end if
    thisObject.Status = thisApplication.Statuses("STATUS_SIGNED")
    ThisObject.SaveChanges()
    thisObject.Update
    call  SetGlobalVarrible("ShowForm", "FORM_KD_DOC_AGREE")  
    'call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", thisObject)
    msgbox "Документ подписан"
    Sing_Memo = true
    
    ans = msgbox("Направить на согласование?", VbYesNo, "Направить на согласование?")
    if ans = vbNo then exit function   
    
    BTN_SEND_OnClick
end function

