'use CMD_KD_FILE_LIB  
use CMD_KD_REGNO_KIB
use CMD_KD_ORDER_LIB
use CMD_KD_GLOBAL_VAR_LIB
use CMD_KD_COMMON_LIB
use CMD_KD_CURUSER_LIB

'=================================
Sub Object_BeforeCreate(Obj, Parent, Cancel)
  
  sysID = Get_Sys_Id(obj)
  if sysID = 0 then 
      Cancel = true
      exit sub
  else  
    Obj.Attributes("ATTR_KD_IDNUMBER").value = sysID
  end if
  
  'отдел
  set dept = Get_Dept(thisApplication.CurrentUser)
  if dept is nothing then 
      msgbox "Для вас не задан отдел. ", VbCritical, "Не возможно создать документ!"
      Cancel = true
      exit sub
  end if

  Obj.Attributes("ATTR_KD_DEPART").Value = dept
  
  if obj.Attributes.Has("ATTR_KD_CHIEF") then
    set execu = thisApplication.CurrentUser
    if not execu is nothing then 
     set chief = thisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetChiefForUserByGroup", execu, "GROUP_LEAD_DEPT")
     if not chief is nothing then 
        if chief.handle = execu.Handle and not chief.Groups.Has("GROUP_LEAD_DEPT") then set chief = nothing
     end if
     if not chief is nothing then
       obj.Attributes("ATTR_KD_CHIEF").Value = chief
     end if
    end if  
  end if   
  'префикс-номер 
  Obj.Attributes("ATTR_KD_DOC_PREFIX").Value = Get_Prifix(obj) 
  ' заявка на оплату
  if Obj.ObjectDefName = "OBJECT_KD_ZA_PAYMENT" or Obj.ObjectDefName = "OBJECT_KD_PROTOCOL" then 
      Set_RegNo(obj)
  end if
  
End Sub

''=================================
Sub Object_PropertiesDlgShow(Obj, Cancel, Forms)
'thisApplication.AddNotify "Object_PropertiesDlgShow - " & CStr(Timer)
'  ' отмечаем все поручения по документу прочитанными
'  'Set_OrdersReaded(Obj)
'      FormName = ""
  Set WshShell = CreateObject("WScript.Shell")
  key = "HKEY_CURRENT_USER\Software\CSoft\TDMS\5.0\ObjectPropertiesDlg\Dialog" & obj.ObjectDefName
  On Error Resume Next ' отключим сообщение об ошибке, т.к. ключа может и не быть.
  If IsExistsGlobalVarrible("ShowForm") Then 
      FormName = GetGlobalVarrible("ShowForm") 
      ' Удалим ключ реестра в котором содержатся сохраненные параметры диалога, т.к. размер у нас всё равно автоматически подстраивается.
      ' Через модификацию данного ключа реестра можно задавать размер и положение диалога, а также распахнутость в зависимости от условий
      ' (Последний параметр в этом ключе реестра содержит значение - распахнуто на весь экран или нет(1/3), можно менять только его).
      FormList =  ";" & thisApplication.Attributes("ATTR_KD_FORMS_LIST").Value & ";"
      
      if InStr(FormList,";" & FormName & ";") > 0 then 
        WshShell.RegDelete(key)
      else
        WshShell.RegWrite key, "330,184,1100,838,-1,-1,-1,-1,3", "REG_SZ"
      end if
      On Error GoTo 0
  else 
    WshShell.RegWrite key, "330,184,1100,838,-1,-1,-1,-1,3", "REG_SZ"
  end if  
   
'  lev = GetGlobalVarrible("WinLev")
'  if lev = "" then lev = 0
'  if lev = 0 then   call SetObjectGlobalVarrible("WinObject", thisObject)

'  lev = lev + 1
''  if lev > 2 then 
''    msgbox "Достигнут предел количества открытых окон. Закройте текущее окно", vbExclamation, "Невозможно открыть еще одно окно!"
''    Cancel = true
''    exit sub
''  end if
'  call SetGlobalVarrible("WinLev", lev)

'  
  'thisApplication.AddNotify "Object_PropertiesDlgShow finish - " & CStr(Timer)
End Sub

'=================================
Sub Object_StatusChanged(Obj, Status)
  SetIcon(Obj)
  if CheckRegStatus(Obj, Status) then
    if not isSecretary(GetCurUser()) then 
      call SendOrderToSecr(obj)
    end if
  end if

  if status.SysName = "STATUS_SIGNED" then call clouseAllOrderByRes(Obj, "NODE_KD_SING")
  if status.SysName = "STATUS_KD_APPROVED" then call clouseAllOrderByRes(Obj, "NODE_KD_APROVER")
  if status.SysName = "STATUS_KD_REGIST" then 
    call clouseAllOrderByRes(Obj, "NODE_KD_APROVER")
    call clouseAllOrderByRes(Obj, "NODE_KD_SING")
  end if

  call SetGlobalVarrible("WinNeedToOpen", "t") ' EV флаг необходиомсти обновлять выборку

End Sub
'=================================
function CheckRegStatus(Obj, Status)
  CheckRegStatus = false
  stName = status.SysName
  on error resume next
  CheckRegStatus = thisApplication.ExecuteScript(Obj.ObjectDefName,"Check_RegStatus", stName)
  if err.Number <> 0 then err.clear
  on error goto 0 
end function 
'=================================
sub SendOrderToSecr(DocObj)
  set qry = thisApplication.Queries("QUERY_GET_SECR_BY_CHIEF")
  qry.Parameter("PARAM0") = GetCurUser()
  set users = qry.Users
  if not users is nothing then 
    for each user in users 
      set newOrder = CreateSystemOrder( DocObj, "OBJECT_KD_ORDER_SYS", _
         user, ThisApplication.CurrentUser, "NODE_TO_PREPARE","","")
    next 
  end if      
end sub
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

'=================================
Sub Object_PropertiesDlgInit(Dialog, Obj, Forms)
  dim DelReg
  if obj.Permissions.View = 0 then exit sub
  DelReg = false
'  thisapplication.AddNotify " Object_PropertiesDlgInit -"  &  CStr(Timer()) 
  ' отмечаем все поручения по документу прочитанными
 'if obj.StatusName <> "STATUS_KD_DRAFT" then _ ' EV надо и в статусе черновик, например при возврате на доработку
    Set_OrdersReaded(Obj)
'  thisapplication.AddNotify "Set_OrdersReaded - " & CStr(Timer())
    
    FormName = ""
    If IsExistsGlobalVarrible("ShowForm") Then 
      FormName = GetGlobalVarrible("ShowForm")
      'RemoveForm "SetRecip", "FORM_KD_CORDENTS",Dialog,Forms
    end if   
' thisapplication.AddNotify CStr(Timer()) & " - IsExistsGlobalVarrible"
    if FormName = "" then 
      FormName = GetObjFroms(obj)
    else
      DelReg = true
    end if
' thisapplication.AddNotify CStr(Timer()) & " - GetObjFroms"
    if FormName <>"" then 
      call SetSysFromFisible(Dialog,false)
' thisApplication.AddNotify "SetSysFromFisible - " & CStr(timer)
'      if thisApplication.InputForms.Has(FormName) then 
' thisApplication.AddNotify "InputForms - " & CStr(timer)
          call ShowForms(FormName, Forms)
' thisApplication.AddNotify "ShowForms - " & CStr(timer)
          'If not Forms.Has(FormName) then 
          on error resume next
          Forms.Add(FormName)
' thisApplication.AddNotify "Forms.Add - " & CStr(timer)
          if err.Number <> 0 then err.Clear 
          on error goto 0
'      else
      ' TODO подумать, что делать, если нет такой формы 
'      end if
      if FormName = "FORM_KD_DOC_AGREE" then 
        call RemoveGlobalVarrible("AgreeObj") ' EV чтобы наверняка новое значение
        set agreeObj = thisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "GetAgreeObjByObj", obj)
        ' EV чтобы создать список до открытия формы
      end if
    end if

' thisApplication.AddNotify "Object_PropertiesDlgInit finish - " & CStr(timer)
' thisapplication.AddNotify CStr(Timer()) & " - ShowForms"
'    RemoveGlobalVarrible("ShowForm")
' thisapplication.AddNotify CStr(Timer()) & " - RemoveGlobalVarrible"
'thisApplication.AddNotify "Object_PropertiesDlgInit"
End Sub

''=================================
Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
  if obj.permissions.view <> 0 then 
    if OkBtnPressed = false then
  '    if obj.ObjectDefName = "OBJECT_KD_DOC_OUT"  then 
  '    if OkBtnPressed = false then
        FormName = GetGlobalVarrible("ShowForm") 
       if inStr(thisApplication.Attributes("ATTR_KD_DEL_FORMS").Value,";" & formName & ";") > 0 then   
          ans = msgbox( "Вы уверены, что хотите удалить документ?",  VbYesNo + vbExclamation, "Удалить документ?")
          if ans = vbNo then 
            Cancel = true
            exit sub
          end if  
        end if  
   '   end if  
    end if
    if thisObject.Permissions.LockOwner then 
      if ThisObject.Permissions.Locked = true Then 
        ThisObject.Unlock ThisObject.Permissions.LockType
        'ThisObject.Update
      end if
    end if
  end if
  RemoveGlobalVarrible("ShowForm") 
End Sub

'=============================================
Sub File_Added(File, Object)
   thisScript.SysAdminModeOn
   dim rows, i, ColNo, newRow
  
   if file.FileDefName  = "FILE_KD_EL_SCAN_DOC" then exit sub

   if file.FileName <> "" then call AddToFileList(file, object)
'    
'   set rows = object.Attributes("ATTR_KD_FILE_LIST").Rows
'   ColNo = 1
'   Set NewRow = nothing 
'   for i = 0 to rows.Count - 1
'      if Rows(i).Attributes(ColNo).Value = File.FileName then  
'          set newRow = Rows(i)
'          exit for
'      end if  
'   next
'   if newRow is nothing then  Set NewRow = rows.Create 
'   
'   NewRow.Attributes("ATTR_FILE_DISPNAME").Value = File.FileName
'   NewRow.Attributes("ATTR_FILE_NAME").Value = File.FileName
''  NewRow.Attributes("ATTR_KD_CUR_VERSION").Value = 0
''  NewRow.Attributes("ATTR_KD_CUR_VERSION").Value = 0
'   rows.Update
''   object.Update
End Sub
'=============================================
Sub File_Erased(File, Object)
   dim rows, i, ColNo
 
   thisScript.SysAdminModeOn
   set rows = object.Attributes("ATTR_KD_FILE_LIST").Rows
   ColNo = 1  
   for i = 0 to rows.Count - 1
      if Rows(i).Attributes(ColNo).Value = File.FileName then  
          Rows(i).Erase
          exit for
      end if  
   next
   rows.Update
   pdfFileName = getFileName(File.FileName) & "###.pdf"
   if object.Files.Has(pdfFileName) then 
      on error resume next
      object.Files(pdfFileName).Erase
      if err.Number<> 0 then err.Clear
      on error goto 0
    end if
'   object.Update   
End Sub

'=============================================
Sub File_CheckedIn(File, Object)
  dim FileDef
'  if IsExistsGlobalVarrible("FileTpRename") then call ReNameFiles(file,Object)
  FileDef =  File.FileDefName
  call AddToFileList(file,object)
    select case FileDef
      case "FILE_KD_SCAN_DOC","FILE_KD_EL_SCAN_DOC"  Object.Files.Main = File 'если скан документ
      case "FILE_KD_WORD","FILE_KD_ANNEX" 
          call delElScan(file,Object)
          if file.Size < 3145728 then 
            'EV 3*1024*1024
            call CreatePDFFromFile(File.WorkFileName, Object, nothing) ' .WorkFileName .FileName
            Object.SaveChanges 16384 ' 0
          end if
      case "FILE_KD_RESOLUTION" IsNeedCreateOrder(Object)'создание поручения по резолюции
    end select    
End Sub
'=============================================
'создание поручения по резолюции
sub IsNeedCreateOrder(docObj)
   msg = msgbox("Хотите добавить поручения по резолюции?", vbExclamation + vbYesNo)
   If msg = vbNo Then exit sub
   call CreateOrders(nothing, docObj)

end sub
'=============================================
sub delElScan(file, obj)
  thisScript.SysAdminModeOn
  if not isCanHasPdf(File.FileName) then exit sub
  
  pdfName = getFileName(File.FileName) & "###.pdf"
  if obj.Files.Has(pdfName) then 
    on error resume next
    obj.Files(pdfName).Erase
    if err.Number<> 0 then 
      err.Clear
      thisApplication.AddNotify err.Description
    else
       Obj.SaveChanges 16384  
    end if  
  end if
  pdfName = getFileName(File.WorkFileName) & "###.pdf"

  Set FSO = CreateObject("Scripting.FileSystemObject") 
  if FSO.FileExists(pdfName) then _
        FSO.DeleteFile pdfName, true 
  if err.Number <> 0 then err.Clear
  on error goto 0
end sub
'=============================================
sub AddToFileList(file, object)
thisScript.SysAdminModeOn
   dim rows, i, ColNo, newRow
  
   if file.FileDefName  = "FILE_KD_EL_SCAN_DOC" then exit sub
    
   set rows = object.Attributes("ATTR_KD_FILE_LIST").Rows
   ColNo = 1
   Set NewRow = nothing 
   for i = 0 to rows.Count - 1
      if Rows(i).Attributes(ColNo).Value = File.FileName then  
          'set newRow = Rows(i)
          exit sub
      end if  
   next
   if newRow is nothing then  Set NewRow = rows.Create 
   
   NewRow.Attributes("ATTR_FILE_DISPNAME").Value = File.FileName
   NewRow.Attributes("ATTR_FILE_NAME").Value = File.FileName
'  NewRow.Attributes("ATTR_KD_CUR_VERSION").Value = 0
'  NewRow.Attributes("ATTR_KD_CUR_VERSION").Value = 0
   rows.Update
'   object.Update
end sub


'=============================================
Sub File_BeforeCheckIn(File, Object, Cancel)
  thisScript.SysAdminModeOn
  dim newFileName,pdfFile,newDpfFileName
  if file.FileDefName = "FILE_KD_EL_SCAN_DOC" then exit sub
  if object.StatusName = "STATUS_KD_DRAFT" then exit sub ' EV чтобы не копировала шаблон, т.к. он создается по сисадмином
  
  if file.UploadUser.Handle <> thisApplication.CurrentUser.Handle then 
      newFileName = GetNewUserFileName(file)
      call Object.Files.AddCopy(file,newFileName)
      if isCanHasPdf(File.FileName) then 
        olFileName = File.FileName
        oldDpfFileName = getFileName(olFileName) & "###.pdf"
        if object.Files.Has(oldDpfFileName) then 
          set pdfFile = object.Files(oldDpfFileName)
          newDpfFileName = getFileName(newFileName) & "###.pdf"
          call Object.Files.AddCopy(pdfFile,newDpfFileName)
'          pdfFile.FileName = newDpfFileName
        end if  
      end if
  end if
End Sub
'=============================================
function GetNewUserFileName(file)
  GetNewUserFileName = ""
  if inStr(File.FileName,"[_")>0 and inStr(File.FileName,"_]")>0 then 
    call SetObjectGlobalVarrible("FileTpRename", file)
  else
    call RemoveGlobalVarrible("FileTpRename")
  end if
  GetNewUserFileName = CheckFileName(getFileName(File.FileName) & "[_" & CStr(file.UploadTime) & "_]" & "." & getFileExt(File.FileName))
end function

'=============================================
sub ReNameFiles(file,Object)
  ind = inStr(file.FileName,"[_")
  newName = left(file.FileName, ind)& "[_" & CStr(file.UploadTime) & "_]" & "." & getFileExt(File.FileName)
  file.FileName = newName
  set oldFile = GetObjectGlobalVarrible("FileTpRename")
  if not oldfile is nothing then
    ind = inStr(file.FileName,"_][_")
    newName = left(oldfile.FileName, ind)& "_]" & "." & getFileExt(oldfile.FileName)
    olfFile.FileName = newName
  end if
end sub
