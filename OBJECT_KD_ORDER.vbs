'use CMD_KD_COMMON_LIB
'use CMD_KD_REGNO_KIB
'use CMD_KD_GLOBAL_VAR_LIB

use CMD_KD_COMMON_LIB
use CMD_KD_ORDER_LIB
'=============================================
Sub Object_StatusChanged(Obj, Status)
    if isEmpty(Status) then exit sub
    if status is nothing then exit sub
    SetIcon(Obj)
    if status.SysName = "STATUS_KD_ORDER_DONE" then 
      res = Obj.Attributes("ATTR_KD_RESOL").Classifier.SysName
      set docObj = obj.Attributes("ATTR_KD_DOCBASE").Object
      if not docObj is nothing then 
        if res = "NODE_KD_SING" or res = "NODE_KD_APROVER" then call clouseAllOrderByRes(docObj, res)
        if obj.ObjectDefName = "OBJECT_KD_ORDER_REP" then 
          ' функция постобработки подписания
            on error resume next
            Call thisApplication.ExecuteScript(docObj.ObjectDefName,"AfterOrderDone", docObj, obj)
            on error goto 0 
        end if
      end if  
    end if
    call SetGlobalVarrible("WinNeedToOpen", "t") ' EV флаг необходиомсти обновлять выборку
'    thisApplication.AddNotify "Object_StatusChanged OBJECT_KD_ORDER"
End Sub
  
'=============================================
Sub Object_BeforeCreate(Obj, Parent, Cancel)
'thisApplication.AddNotify "BeforeCreate -" & cStr(timer())

  if not parent is nothing then 
'    if parent.ObjectDef.IsKindOf. SuperObjectDefs.Has("OBJECT_KD_ORDER") then _
    if parent.ObjectDef.IsKindOf("OBJECT_KD_ORDER") then _
      obj.Attributes("ATTR_KD_ORDER_BASE").Object = Parent
  end if
'thisApplication.AddNotify "Before Get_Sys_ID -" & cStr(timer())

  'получить новый номер
  RegNo = Get_Sys_ID(Obj)
'thisApplication.AddNotify "Get_Sys_ID -" & cStr(timer())

  if RegNo = 0 then 
      Cancel = true
      msgbox "Не удалось создать регистрационный номер поручения!", vbCritical
      exit sub
  end if  
  
  obj.Attributes("ATTR_KD_NUM").Value = RegNo
  obj.Attributes("ATTR_KD_DOC_PREFIX").Value = Get_Order_Prifix(obj)
  obj.Attributes("ATTR_KD_ISSUEDATE").Value = now

'thisApplication.AddNotify "After  BeforeCreate -" & cStr(timer())
  
 
End Sub

''_________________________________
'Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
''    Set_OrderReaded(Obj)
'  lev = GetGlobalVarrible("WinOrderLevel")
'  if lev <> "" then  
'    lev = lev - 1
'    call SetGlobalVarrible("WinOrderLevel", lev) 
'  end if
'End Sub

''_________________________________
'Sub Object_BeforeErase(Obj, Cancel)
'  if thisApplication.CurrentUser.SysName <> "sysadmin" then 
'    if obj.Status.SysName <> "STATUS_KD_ORDER_SENT" then 
'      msgBox  "Невозможно удалить поручение, которое уже обработано", vbCritical
'      cancel = true
'    end if
'  end if  
'End Sub
''=================================
Sub Object_PropertiesDlgShow(Obj, Cancel, Forms)
'thisApplication.AddNotify "  Object_PropertiesDlgShow -" & cStr(timer())
  Set WshShell = CreateObject("WScript.Shell")
  key = "HKEY_CURRENT_USER\Software\CSoft\TDMS\5.0\ObjectPropertiesDlg\Dialog" & obj.ObjectDefName
  On Error Resume Next ' отключим сообщение об ошибке, т.к. ключа может и не быть.
  WshShell.RegWrite key, "330,184,1100,838,-1,-1,-1,-1,3", "REG_SZ"
  on error goto 0 
'thisApplication.AddNotify "After  Object_PropertiesDlgShow -" & cStr(timer())
'  lev = GetGlobalVarrible("WinOrderLevel")
'  if lev = "" then lev = 0
'  lev = lev + 1
'  if lev > 2 then 
'    msgbox "Достигнут предел количества открытых окон. Закройте текущее окно", vbExclamation, "Невозможно открыть еще одно окно!"
'    Cancel = true
'    exit sub
'  end if
'  call SetGlobalVarrible("WinOrderLevel", lev)
End Sub


'=================================
Sub Object_PropertiesDlgInit(Dialog, Obj, Forms)
'thisApplication.AddNotify "Object_PropertiesDlgInit -" & cStr(timer())
    Set_OrderReaded(Obj)
  dim DelReg
  DelReg = false
'  thisapplication.AddNotify CStr(Timer()) & " - Object_PropertiesDlgInit"  
  ' отмечаем все поручения по документу прочитанными
'    Set_OrdersReaded(Obj)
'  thisapplication.AddNotify CStr(Timer()) & " - Set_OrdersReaded"
    
    FormName = ""
    If IsExistsGlobalVarrible("ShowForm") Then 
      FormName = GetGlobalVarrible("ShowForm")
      'RemoveForm "SetRecip", "FORM_KD_CORDENTS",Dialog,Forms
    end if   
' thisapplication.AddNotify CStr(Timer()) & " - IsExistsGlobalVarrible"
'    if FormName = "" then 
'      FormName = GetObjFroms(obj)
'    else
'      DelReg = true
'    end if
' thisapplication.AddNotify CStr(Timer()) & " - GetObjFroms"
    if FormName <>"" then 
      call SetSysFromFisible(Dialog,false)
      if thisApplication.InputForms.Has(FormName) then 
          If not Forms.Has(FormName) then Forms.Add(FormName)
          call ShowForms(FormName, Forms)
      else
      ' TODO подумать, что делать, если нет такой формы 
      end if
    end if
' thisapplication.AddNotify CStr(Timer()) & " - ShowForms"
'    RemoveGlobalVarrible("ShowForm")


' thisapplication.AddNotify CStr(Timer()) & " - RemoveGlobalVarrible"
'  if delReg then 
'            ' Удалим ключ реестра в котором содержатся сохраненные параметры диалога, т.к. размер у нас всё равно автоматически подстраивается.
'      ' Через модификацию данного ключа реестра можно задавать размер и положение диалога, а также распахнутость в зависимости от условий
'      ' (Последний параметр в этом ключе реестра содержит значение - распахнуто на весь экран или нет(1/3), можно менять только его).
'      Set WshShell = CreateObject("WScript.Shell")
'      ' !!!!!! ЗДЕСЬ ВМЕСТО OBJECT_PROJECTS_DOCS подставить SysId объекта для которого необходимо сбрасывать настройки.
'    '  key = "HKEY_CURRENT_USER\Software\CSoft\TDMS\5.0\ObjectPropertiesDlg\DialogOBJECT_PROJECTS_DOCS"
'      key = "HKEY_CURRENT_USER\Software\CSoft\TDMS\5.0\ObjectPropertiesDlg\Dialog" & obj.ObjectDefName
'      On Error Resume Next ' отключим сообщение об ошибке, т.к. ключа может и не быть.
'      WshShell.RegDelete(key)
'      On Error GoTo 0
'  end if
'thisApplication.AddNotify "After  Object_PropertiesDlgInit -" & cStr(timer())
End Sub

'=============================================
Sub File_Added(File, Object)
  thisscript.SysAdminModeOn
  if File.FileName >"" then 
    ext = getFileExt(file.WorkFileName)
    if ext  = "pdf" then 
       Object.Files.Main = File 'если скан документ
'    else 
'       Set FSO = CreateObject("Scripting.FileSystemObject") 
'       if not FSO.FileExists(File.WorkFileName) then File.CheckOut(File.WorkFileName)
'       call CreatePDFFromFile(File.WorkFileName, Object, nothing) ' .WorkFileName .FileName
    end if    
  end if
  SetAllFiles(Object)
End Sub

'=============================================
sub SetAllFiles(order)
'thisApplication.AddNotify "SetAllFiles - " & cstr(timer)
  thisScript.SysAdminModeOn
  strF = ""
  for each file in order.Files
'thisApplication.AddNotify "for each file - " & cstr(timer)
     if file.FileDefName <> "FILE_KD_EL_SCAN_DOC" then _
         strF = strF & file.FileName & ", "
  next
'thisApplication.AddNotify "next - " & cstr(timer)
  if order.Attributes("ATTR_KD_ALL_FILES").value <> strF then 
    thisScript.SysAdminModeOn
    order.Permissions = SysAdminPermissions
    order.Attributes("ATTR_KD_ALL_FILES").value = strF
'thisApplication.AddNotify ".value = strF - " & cstr(timer)
'    order.saveChanges
  end if
'thisApplication.AddNotify "finish - " & cstr(timer)
end sub

'=============================================
Sub File_Erased(File, Object)
   thisScript.SysAdminModeOn
   pdfFileName = getFileName(File.FileName) & "###.pdf"
   if object.Files.Has(pdfFileName) then 
      on error resume next
      err.Clear
      object.Files(pdfFileName).Erase
      if err.Number <> 0 then err.Clear
      on error goto 0
    end if
   SetAllFiles(Object)
End Sub
'=============================================
Sub File_CheckedIn(File, Object)
  thisScript.SysAdminModeOn
  ext = getFileExt(file.WorkFileName)
  if ext  = "pdf" then 
     Object.Files.Main = File 'если скан документ
  else 
'      call CreatePDFFromFile(File.WorkFileName, Object, nothing) ' .WorkFileName .FileName
  end if    
End Sub

'=============================================
Sub Object_Modified(Obj)
  call SetGlobalVarrible("WinNeedToOpen", "t") ' EV флаг необходиомсти обновлять выборку
  SetAllFiles(obj)
'thisApplication.AddNotify "after Object_Modified - " & cstr(timer)
'thisApplication.DebugPrint "after Object_Modified - " & cstr(timer)
End Sub

'=============================================
Sub Object_Created(Obj, Parent)
'thisApplication.DebugPrint "Object_Created - " & cstr(timer)
  set docObj = obj.Attributes("ATTR_KD_DOCBASE").Object
  if not docObj is nothing then 
    if docObj.Permissions.View = 0 then exit sub
'EV если ограниченого просмотра, то перераздаем права
    if docObj.attributes.has("ATTR_KD_KI") then 
        if docObj.attributes("ATTR_KD_KI").value = true or docObj.ObjectDefName = "OBJECT_KD_ZA_PAYMENT" _
           or docObj.StatusName = "STATUS_KD_DRAFT" then 
          set user =  obj.Attributes("ATTR_KD_OP_DELIVERY").User
          if not user is nothing then 
              if obj.RolesForUser(user).Count = 0 then _
                call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "ADD_Role", docObj,"Пользователь", user, false)
          end if     
          if obj.Attributes.Has("ATTR_KD_CONTR") then 
            set user =  obj.Attributes("ATTR_KD_CONTR").User
            if not user is nothing then 
                if obj.RolesForUser(user).Count = 0 then _
                  call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "ADD_Role", docObj,"Пользователь", user, false)
            end if     
          end if
'          call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", docObj)
        end if
    end if    
    ' если резолюиция или согласование, то добавляем всегда
    if obj.Attributes("ATTR_KD_RESOL").Value = "Подготовить рецензию"  or _
        obj.Attributes("ATTR_KD_RESOL").Value = "Cогласовать" then 
          set user =  obj.Attributes("ATTR_KD_OP_DELIVERY").User
          if not user is nothing then 
                call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "ADD_Role", docObj,"Согласующий", user, false)
          end if  
    end if       
  end if
  CopyOrderToSecr(obj)
'thisApplication.DebugPrint "after Object_Created - " & cstr(timer)
End Sub
'=================================
sub CopyOrderToSecr(Obj)
'  if   Set resol = ThisApplication.Classifiers("NODE_CORR_REZOL").Classifiers.FindBySysId(resSysName)
  res = Obj.Attributes("ATTR_KD_RESOL").Classifier.SysName
  if res = "NODE_KD_SING" or res = "NODE_KD_APROVER" then 
    set qry = thisApplication.Queries("QUERY_GET_SECR_BY_CHIEF")
    qry.Parameter("PARAM0") = obj.Attributes("ATTR_KD_OP_DELIVERY").User'thisApplication.CurrentUser
    set users = qry.Users
    if not users is nothing then 
      thisScript.SysAdminModeOn  
      obj.Permissions = sysAdminPermissions
      for each user in users 
        set newOrder = obj.Duplicate(obj.Parent)
        newOrder.Attributes("ATTR_KD_OP_DELIVERY").Value = user
        newOrder.Status = thisApplication.Statuses("STATUS_KD_ORDER_SENT")
        newOrder.Update
        call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", newOrder)
'        newOrder.Parent = obj 'EV прочему-то  не меняется родитель
'        newOrder.Update
      next 
    end if      
  end if  
end sub
