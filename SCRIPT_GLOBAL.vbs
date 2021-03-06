
'USE "COMMENT_FUNCTION_LIBRARY"
Dim dict
Set dict = ThisApplication.Dictionary("EraseObjects")

'=============================================
Sub Startup()
    ThisApplication.ApplicationName = "РСУПД ДП " & ThisApplication.DatabaseName _
          & " ( " & ThisApplication.CurrentUser.Description & " )"
    
    SetUserDeleg()
'    call thisApplication.ExecuteScript("FORM_PANEL","GoToQuery","QUERY_ARM_1_DCP")  
'    SetTreeBrVisible()
 
'    ' Включена опция "Конфигурация системы"
'  If ThisApplication.Attributes("ATTR_SYSTEM_CONFIG") Or ThisApplication.Attributes("ATTR_SYSTEM_VER") = "" Then
'    If ThisApplication.CurrentUser.SysName <> "SYSADMIN" Then
'      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1170
'      ThisApplication.Quit
'    Else
'      ' Создание и установка атрибута "Показывать справку при входе в систему"
'      Call SetUserAttrs()
'      ' Установка версии
'      ThisApplication.Attributes("ATTR_SYSTEM_VER") = "5.0"
'      ' Сброс флага "Конфигурация системы"
'      ThisApplication.Attributes("ATTR_SYSTEM_CONFIG") = False
'    End If
'  End If
  SetTextColour()  
  ' Старт Tips&Tricks
'  Call NanoRun()
End Sub

'=============================================
sub SetUserDeleg()
  set qry = thisApplication.Queries("QUERY_KD_DELEGS_BY_ATTR")
  set sh = qry.Sheet
  set users = sh.Users
' EV удаляем лишних
  set us = thisApplication.CurrentUser.GetDelegatedRightsFromUsers()
  for each user in us
    find = false
    for i = 0 to sh.RowsCount - 1
      if users(i).sysName = user.sysname then
        dBeg = CheckDate(sh.CellValue(i,1), "01.01.2000")
        dEnd = CheckDate(sh.CellValue(i,2), "01.01.2100")
        if dbeg <= Date and dEnd >= Date then find = true
        exit for
      end if
    next
    if find then 
      exit for
    else
      thisApplication.CurrentUser.WithdrawDelegatedRightsFrom(user)
    end if
  next
'EV добавляем новых  
  if sh.RowsCount = 0 then exit sub
  for i = 0 to sh.RowsCount - 1
    set user = users(i) 'row.Attributes("ATTR_KD_OP_DELIVERY").user
    if not user is nothing then 
      dBeg = CheckDate(sh.CellValue(i,1), "01.01.2000")
      dEnd = CheckDate(sh.CellValue(i,2), "01.01.2100")
      if dbeg <= Date then
        if dEnd >= Date then
           if not us.Has(user) then 
             thisApplication.CurrentUser.DelegateRightsFrom(user)
             user.RedirectMailForDelegateRightsTo()
             msgbox "Вы назначены замещающим пользователя " & vbNewLine & user.Description  & vbNewLine & _
                "Примечание: " & sh.CellValue(i,3), _
                vbInformation,"Вы назначены замещающим."
'             RedirectMailForDelegateRightsFrom()
           end if
        else
          call DelDelegete(user)
        end if
      end if
    end if
  next
end sub
'=============================================
sub DelDelegete(FromUser)
  thisScript.SysAdminModeOn
  set rows = FromUser.Attributes("ATTR_KD_DELEG_TABLE").Rows
  if rows.count = 0 then exit sub
  for each row in rows 
    set user = row.Attributes("ATTR_KD_OP_DELIVERY").user
    if user is nothing then 
        row.Erase      
    else
      if user.SysName = thisApplication.CurrentUser.SysName then 
        thisApplication.CurrentUser.WithdrawDelegatedRightsFrom(FromUser)
        row.Erase
        exit sub
      end if
    end if
  next
end sub
'=============================================
function CheckDate(Value, defValue)
  if  IsDate(defValue) then 
    CheckDate = CDate(defValue)
  else 
    CheckDate = CDate("01.01.2000")
  end if
  
  if Value <> "" then
    if IsDate(Value) then CheckDate = CDate(Value)
  end if
  
end function
'=============================================
sub SetTextColour()
  Set WshShell = CreateObject("WScript.Shell")
'  key = "HKEY_CURRENT_USER\Software\CSoft\TDMS\5.0\Settings\List_SelectionColor" 
'  WshShell.RegWrite key, 255,"REG_DWORD" 
  key = "HKEY_CURRENT_USER\Software\CSoft\TDMS\5.0\Settings\List_SelectionInactiveColor" 
  WshShell.RegWrite key, 16752768,"REG_DWORD" '220-238-247 =R[2]C*65536+R[3]C*256+R[4]C
'  key = "HKEY_CURRENT_USER\Software\CSoft\TDMS\5.0\Settings\List_SelectionTextColor" 
'  WshShell.RegWrite key, 12,"REG_DWORD"
end sub
'=============================================
' Старт Tips&Tricks
Private Sub NanoRun()
  Dim FileName
  FileName = ThisApplication.ApplicationFolder & "help\nanorun.exe"
 
  if ThisApplication.CurrentUser.Attributes.Has("ATTR_USER_SHOW_TIPS") Then
    If ThisApplication.CurrentUser.Attributes("ATTR_USER_SHOW_TIPS").Value Then
      Set shl = CreateObject("WScript.Shell")
      Set FSO = CreateObject("Scripting.FileSystemObject")
      if FSO.FileExists(FileName) Then
         FileName = chr(34) & FileName & chr(34)
         shl.run FileName, 0, 0
         Set shl = Nothing
      end If
      Set FSO = Nothing
    End If
  End If
End Sub

'=============================================
sub SetTreeBrVisible()
  if thisApplication.CurrentUser.SysName <> "SYSADMIN" then 
    Set WshShell = CreateObject("WScript.Shell")
    res = WshShell.RegWrite("HKEY_CURRENT_USER\SOFTWARE\CSoft\TDMS\5.0\Settings\Layout_TreeClassifiers", _
        0, "REG_DWORD")
    res = WshShell.RegWrite("HKEY_CURRENT_USER\SOFTWARE\CSoft\TDMS\5.0\Settings\Layout_TreeMail", _
        0, "REG_DWORD")
    res = WshShell.RegWrite("HKEY_CURRENT_USER\SOFTWARE\CSoft\TDMS\5.0\Settings\Layout_TreeUsers", _
        0, "REG_DWORD")
'    res = WshShell.RegWrite("HKEY_CURRENT_USER\SOFTWARE\CSoft\TDMS\5.0\Settings\Layout_TreeClassifiers", _
'        0, "REG_DWORD")
'   ' if res = 0 then msgbox  err.Number
  end if

end sub
'=============================================
Sub Timer() 
  dim curTime,m,dic,d,c1
  curTime = Time  

  set dic = ThisApplication.Dictionary("P1")
  if not dic.Exists("curTime") then 
    call dic.Add("curTime",curTime)
    exit sub
  end if

  tic = 0
  if dic.Exists("ATTR_PANEL_TIME") then
    tic = dic.Item("ATTR_PANEL_TIME")
  else
    if thisApplication.CurrentUser.Attributes.Has("ATTR_PANEL_TIME") then 'EV 2018-01-17 переносим в атрибуты пользователя
      tic = thisApplication.CurrentUser.Attributes("ATTR_PANEL_TIME").Value
    else
      if not ThisApplication.Attributes.Has("ATTR_PANEL_TIME") then exit sub
      tic = ThisApplication.Attributes("ATTR_PANEL_TIME").Value
    end if
    dic.Item("ATTR_PANEL_TIME") =  tic
  end if
  
  if tic <> 0 then 
    oldTime = dic.Item("curTime")
'    if datediff("n",oldTime,curTime) < tic then exit sub
'    thisApplication.AddNotify datediff("s",oldTime,curTime)
    if datediff("s",oldTime,curTime)/60 < tic then exit sub ' EV т.к. изменение минту происходит в начала минуты
    lev = thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","GetGlobalVarrible","WinLev")
    if lev <> "" then 
      if IsNumeric(lev) then
        lev = CInt(lev)
        if lev > 0 then exit sub' EV если открыто окно, то обновлять не надо
      end if
    end if

    set dic = ThisApplication.Dictionary("P1")
    if IsEmpty(dic) then exit sub
    if dic is nothing then exit sub
    Set f = nothing 
    If not dic.Exists("f1") Then exit sub
    if isEmpty(dic("f1")) then exit sub
    Set f = dic("f1")
    if f is nothing then exit sub
    if not f.Controls.has("STATIC1") then exit sub
    Set c1 = f.Controls("STATIC1")
    c1.Value = "Обновлено " &  cStr(Time)
    call thisApplication.ExecuteScript("FORM_PANEL","CreateTree", f)
    f.Refresh
    dic.Item("curTime") = Time ' запоминаем время последненго обновления
  end if  
End Sub



'=============================================
Sub MainWindowShown(Shown)
 if Shown <> true then exit sub
 
  if thisApplication.Attributes.Has("ATTR_KD_SYS_VER") then 
    if thisApplication.Version <> thisApplication.Attributes("ATTR_KD_SYS_VER").Value then 
      msgbox "Неверная версия системы. Обратитесь к администраторам" & _
      thisApplication.Version &" "& thisApplication.Attributes("ATTR_KD_SYS_VER").Value , vbCritical
      If ThisApplication.CurrentUser.SysName <> "SYSADMIN" Then _
           thisApplication.Quit
    end if
  else
      msgbox "Версия системы не задана. Обратитесь к администраторам", vbCritical
      If ThisApplication.CurrentUser.SysName <> "SYSADMIN" Then _
          thisApplication.Quit
  end if
 'call thisApplication.ExecuteScript("FORM_PANEL","GoToQuery","QUERY_ARM_1_DCP")  
  on error resume next

  path = Array(thisapplication.Desktop, thisapplication.Desktop.Queries("QUERY_ARM_ORDER_IN"))
  thisapplication.Shell.SetActiveTreeItem path
      set dic = ThisApplication.Dictionary("P1")
    if IsEmpty(dic) then exit sub
    if dic is nothing then exit sub
    Set f = nothing 
    If not dic.Exists("f1") Then exit sub
    if isEmpty(dic("f1")) then exit sub
    Set f = dic("f1")
    if f is nothing then exit sub
    if not f.Controls.has("STATIC1") then exit sub
    Set c1 = f.Controls("STATIC1")
    c1.Value = "Обновлено " &  cStr(Time)
'    call thisApplication.ExecuteScript("FORM_PANEL","SelectInOrder", f)
'    f.Refresh
  call thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB", "SetGlobalVarrible", "WinQuery", "QUERY_ARM_ORDER_IN")
  call thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","SetGlobalVarrible", "WinSaveQName", "t") ' EV флаг для очистки
  call thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB", "SetGlobalVarrible", "Start", "T")

'  set objQ = thisApplication.Queries("QUERY_ARM_ORDER_IN")
'  if objQ is nothing then exit sub
'  qname_ = objQ.sysName
'  Set q = ThisApplication.Queries("QUERY_ARM_ORDER_IN")
'  Set sheet = q.Sheet
'  Thisapplication.Shell.ListInitialize q.Sheet
'  on error goto 0

End Sub

''=============================================
'Sub Quit()
' 'SetTreeBrVisible()
'End Sub

'=============================================
Sub Object_PropertiesDlgInit(Dialog, Obj, Forms)
  ThisScript.SysAdminModeOn
'if thisApplication.CurrentUser.SysName <> "SYSADMIN"  and _
'          (obj.IsKindOf("OBJECT_KD_BASE_DOC") or obj.IsKindOf("OBJECT_KD_ORDER") or _
'            obj.IsKindOf("OBJECT_CORRESPONDENT") or obj.IsKindOf("OBJECT_CORR_ADDRESS_PERCON"))then 
''  Dialog.SystemFormVisibility(tdmSysFormProperties) = false 'Свойства  
  if thisApplication.CurrentUser.SysName <> "SYSADMIN" then
    Dialog.SystemFormVisibility(tdmSysFormSigns) = false 'Подписи
    Dialog.SystemFormVisibility(tdmSysFormPreview) = false 'Просмотр
    Dialog.SystemFormVisibility(tdmSysFormFiles) = false 'Файлы
    Dialog.SystemFormVisibility(tdmSysFormSystem) = false 'Системные  
    ' Связи
    Dialog.SystemFormVisibility(tdmSysFormContent) = false 'Содержит
    Dialog.SystemFormVisibility(tdmSysFormPartOf) = false 'Входит в состав
    Dialog.SystemFormVisibility(tdmSysFormReferencedBy) = false 'Используется в
    ' История
    Dialog.SystemFormVisibility(tdmSysFormHistory) = false 'История
    Dialog.SystemFormVisibility(tdmSysFormMessages) = false 'Сообщения
    Dialog.SystemFormVisibility(tdmSysFormVersions) = false 'Версии
    ' Права доступа
    Dialog.SystemFormVisibility(tdmSysFormRoles) = false ' Роли
    Dialog.SystemFormVisibility(tdmSysFormSummaryPermissions) = false ' Суммарные
    
    Dialog.SystemFormVisibility(tdmSysFormDefault) = false '?
  end if  
  if not Obj.IsKindOf("OBJECT_KD_BASE_DOC") then 
      Set dict = ThisApplication.Dictionary(thisapplication.CurrentUser.SysName)
      if dict.Exists("ShowForm") then
        frmName =  dict.Item("ShowForm") 
        if frmName = "FORM_ARGEE_CREATE" or inStr(frmName, "AGREE")> 0 then ' EV оставляем только для согласования 2017-11-14
          For each Form in Forms
              If InStr(";" & frmName & ";", ";" & form.SysName & ";") = 0 Then Forms.Remove Form   
          next
          on error resume next
          Forms.Add(frmName)
          if err.Number <> 0 then err.Clear 
          on error goto 0 
        end if
      end if
  end if 
  ThisScript.SysAdminModeOff
End Sub

''=============================================
'Sub Files_DragAndDropped(FilesPathArray, Object, Cancel)
'    For i = 0 to Ubound(FilesPathArray)
'      call thisApplication.ExecuteScript("CMD_KD_FILE_LIB", "AddFile_application",FilesPathArray(i),Object)
'    Next 
'   ' Чтобы не отработал обработчик по умолчанию
'    Cancel = true

'''получаем форму и объект
''  set dic = ThisApplication.Dictionary("CanAddFile")
''  if IsEmpty(dic) then exit sub
''  if dic is nothing then exit sub
''  Set obj = nothing 
''  If not dic.Exists("obj") Then exit sub
''  if isEmpty(dic("obj")) then exit sub
''  Set obj = dic("obj")

''  if obj is nothing then exit sub
''    'if not obj.IsKindOf("OBJECT_KD_BASE_DOC") then exit sub
''    For i=0 to Ubound(FilesPathArray)
''      'msgbox FilesPathArray(i)
''      call thisApplication.ExecuteScript("CMD_KD_FILE_LIB","LoadFileByObj","FILE_KD_ANNEX", _
''          FilesPathArray(i), true, Obj)
''    Next 
''    obj.Permissions = SysAdminPermissions
''    obj.upDate
'End Sub

'=============================================
Sub Form_BeforeShow(Form, Obj)
if Form.Caption = "StartChat" then
set ie = Form.Controls("ACTIVEX1").ActiveX
 set curDicPars = thisapplication.Dictionary("writeHTMLPars")
 pathAndPars = "D:\Dropbox\IdeaProjects\TDMS_Chat\build\web\index.html" & "?guid=" & curDicPars("guid") & "&user=" & curDicPars("user") & "&sysuser=" & curDicPars("sysuser")
 
 ie.navigate pathAndPars
 
 'ie.theaterMode = true
' ie.visible = true
 
  'ie.silent = true
  'ie.automationSecurity = 1
 ' ie.navigate2 pathAndPars, &h0400
'  Do While ie.busy
'        Loop
'        Do While ie.Document.readyState <> "complete"
'        Loop
'  'ThisApplication.Utility.Sleep(5000)

  '
  'dim t: t=1
 ' ie.Document.All.Item("Button1").Click
  'ie.document.forms | 
   'Select -First 1 | 
   '% { $_.submit() }


'  set ie = Form.Controls("ACTIVEX1").ActiveX
'  set curDicPars = thisapplication.Dictionary("writeHTMLPars")
'  pathAndPars = "D:\Dropbox\IdeaProjects\TDMS_Chat\build\web\index.html" & "?guid=" & curDicPars("guid") & "&user=" & curDicPars("user") & "&sysuser=" & curDicPars("sysuser")
' ' ie.navigate2 pathAndPars, 1024
' 
'  call ie.navigate(pathAndPars)', 1024)
   ''''call thisApplication.ExecuteScript("CMD_START_CHAT", "startEvent", Form)'PlotnikovSP
'  set ie = Form.Controls("ACTIVEX1").ActiveX
'  set curDicPars = thisapplication.Dictionary("writeHTMLPars")
'  'curDicPars("guid") = thisobject.GUID
'  'curDicPars("user") = thisapplication.CurrentUser.description
'  'curDicPars("path") = outFile
'  pathAndPars = "D:\Dropbox\IdeaProjects\TDMS_Chat\build\web\index.html" & "?guid=" & curDicPars("guid") & "&user=" & curDicPars("user")
'  ie.navigate(pathAndPars)
  'ie.navigate("D:\Dropbox\IdeaProjects\TDMS_Chat\build\web\index.html")
  exit sub
end if



  FormList = thisApplication.Attributes("ATTR_KD_FILE_FORMS").Value
  
  if InStr(FormList,";" & form.SysName & ";")>0 then 
      set dic = ThisApplication.Dictionary("CanAddFile")
      if IsEmpty(dic) then exit sub
      if dic is nothing then exit sub
      If dic.Exists("obj") Then dic.Remove("obj")
      dic.Add "obj", Obj
      If dic.Exists("form") Then dic.Remove("form")
      dic.Add "form", Form
  end if
End Sub

'=============================================

Sub ContextMenu_BeforeShow(Commands, Obj, Cancel)
  If Commands.Has (ThisApplication.Commands("CMD_COMMENT_EDIT")) Then
    If Obj.Permissions.EditFiles = 2 Or Obj.Files.Count = 0 Then
      Commands.Remove ThisApplication.Commands("CMD_COMMENT_EDIT")
    End If
  End If  
  
  If ThisApplication.ObjectDefs.Has("OBJECT_FOLDER") Then
    ' Удаление дублирования команды "Создать папку"
'    If Obj.ObjectDefName <> "OBJECT_VOLUME" and Obj.ObjectDefName <> "OBJECT_SURV" and _
'    Obj.ObjectDefName <> "OBJECT_WORK_DOCS_SET" Then
'      If Commands.Has (ThisApplication.Commands("CMD_SECTION_CREATE")) Then
'          Commands.Remove ThisApplication.Commands("CMD_SECTION_CREATE")
'      End If
'    End If
    ' Удаление дублирования команды "Создать документ"
    'If Commands.Has (ThisApplication.Commands("CMD_DOCUMENT_CREATE")) Then
    '    Commands.Remove ThisApplication.Commands("CMD_DOCUMENT_CREATE")
    'End If  
  End If
  ' Удаление команды "Удалить соразработчика"
  If Commands.Has (ThisApplication.Commands("CMD_CO_AUTHOR_DELETE")) Then
    If Obj.RolesByDef("ROLE_CO_AUTHOR").Count = 0 Then
      Commands.Remove ThisApplication.Commands("CMD_CO_AUTHOR_DELETE")
    End If
  End If  
  ' Удаление команды "Запретить просмотр"
  If Commands.Has (ThisApplication.Commands("CMD_VIEW_FORBID")) Then
    If Obj.RolesByDef("ROLE_VIEW").Count = 0 Then
      Commands.Remove ThisApplication.Commands("CMD_VIEW_FORBID")
    End If
  End If  
  ' Удаление команды "Внести изменения в документ"
  If Commands.Has (ThisApplication.Commands("CMD_DOC_DEV_CHANGE")) Then
    If not Obj.Parent is Nothing Then
      If not Obj.Parent.Status is Nothing Then
        sStatus = Obj.Parent.Status.SysName
        If Not (sStatus = "STATUS_SECTION_IS_DEVELOPING" Or sStatus = "STATUS_WORK_DOCS_SET_IS_DEVELOPING" Or sStatus = "STATUS_VOLUME_IS_BUNDLING" Or sStatus = "STATUS_FOLDER_IS_DEVELOPING") Then
            Commands.Remove ThisApplication.Commands("CMD_DOC_DEV_CHANGE")
        End If
      End If
    End If
  End If  
  
  ' Удаление команды "Аннулировать документ"
  If Commands.Has (ThisApplication.Commands("CMD_DOC_INVALIDATED")) Then
    If not Obj.Parent is Nothing Then
      If not Obj.Parent.Status is Nothing Then
        sStatus = Obj.Parent.Status.SysName
        If Not (sStatus = "STATUS_SECTION_IS_DEVELOPING" Or sStatus = "STATUS_WORK_DOCS_SET_IS_DEVELOPING" Or sStatus = "STATUS_VOLUME_IS_BUNDLING" Or sStatus = "STATUS_FOLDER_IS_DEVELOPING") Then
            Commands.Remove ThisApplication.Commands("CMD_DOC_INVALIDATED")
        End If
      End If
    End If
  End If 
  
  ' Удаление команды "Назначить администратора"
  'If ThisApplication.Commands.Has("CMD_SET_ADMIN") Then
  '  If Commands.Has (ThisApplication.Commands("CMD_SET_ADMIN")) Then
  '      Commands.Remove ThisApplication.Commands("CMD_SET_ADMIN")
  '  End If   
  'End If
  
End Sub


'=================================
Sub Form_BeforeClose(Form, Obj, Cancel)
  'FormList = thisApplication.Attributes("ATTR_KD_FILE_FORMS").Value
  'if InStr(FormList,";" & form.SysName & ";")>0 then 
      set dic = ThisApplication.Dictionary("CanAddFile")
      if not IsEmpty(dic) then 
        if not dic is nothing then 
          If dic.Exists("obj") Then dic.Remove("obj")
          If dic.Exists("form") Then dic.Remove("form")
        end if
      end if
  'end if
End Sub

'=================================
Sub Object_BeforeContentRemove(o_, RemoveCollection, Cancel)
  If o_.ObjectDefName = "ROOT_DEF" Then
    Cancel = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckEraseFlag", RemoveCollection)
  End If
End Sub

'=================================
' Обрабатываем ошибки
Sub OnScriptError(ScriptDescription, Object, Line, Char, ErrorDescription, Cancel)
  ' Ошибка при работе с MS Outlook
  ThisApplication.Utility.Waitcursor = FALSE
  If ScriptDescription = "CMD_OUTLOOK" Then
    ThisApplication.ExecuteScript "CMD_OUTLOOK","Close"
  End If

  'Если на момент ошибки транзакция была открыта, откатываем 
  If ThisApplication.IsActiveTransaction Then ThisApplication.AbortTransaction

End Sub

'=================================
Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
  if not IsEmpty(Obj) then 
    if not Obj is nothing then 
      if obj.Permissions.View > 0 then 
        if not Obj.IsKindOf("OBJECT_KD_BASE_DOC")  and not Obj.IsKindOf("OBJECT_KD_ORDER") then 
          call thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","RemoveGlobalVarrible", "ShowForm")
        end if
      end if
    end if
  end if      
  lev = thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","GetGlobalVarrible","WinLev")
  if lev <> "" then  
    lev = lev - 1
    call thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","SetGlobalVarrible", "WinLev", lev) 
    if lev = 0 then ReorderQuery()
  else
    call thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","SetGlobalVarrible", "WinLev", 0) 
  end if
End Sub
' EV обновление выборки в окне состава
'=============================================
Sub ReorderQuery()
  needToOpen = thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","GetGlobalVarrible","WinNeedToOpen")
  call thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","RemoveGlobalVarrible","WinNeedToOpen")

  if needToOpen <> "t" then  exit sub

  qname = thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","GetGlobalVarrible","WinQuery")
  if qname = "" then exit sub
 
  call thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","SetGlobalVarrible", "WinSaveQName", "t") ' EV флаг для очистки

  Set q = ThisApplication.Queries(qname)
  Set sheet = q.Sheet
  Thisapplication.Shell.ListInitialize sheet
 
  set obj = thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","GetObjectGlobalVarrible","WinObject")
  if not obj is nothing then thisApplication.Shell.SetActiveListItem(obj)
  
  RefreshCount()
end sub
'=============================================
sub RefreshCount()
    dim m,dic,d,c1

    set dic = ThisApplication.Dictionary("P1")
    if IsEmpty(dic) then exit sub
    if dic is nothing then exit sub
    Set f = nothing 
    If not dic.Exists("f1") Then exit sub
'    if isEmpty(dic("f1")) then exit sub
    Set f = dic("f1")
    if f is nothing then exit sub
    call thisApplication.ExecuteScript("FORM_PANEL","RefreshSelItem", f)
    f.Refresh
end sub
'=============================================
Sub Object_PropertiesDlgShow(Obj, Cancel, Forms)
  lev = thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","GetGlobalVarrible", "WinLev")
  if lev = "" then lev = 0
  if lev = 0 then   call thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","SetObjectGlobalVarrible", "WinObject", obj)

  lev = lev + 1
  call thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","SetGlobalVarrible", "WinLev", lev)
  call thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","RemoveGlobalVarrible","WinNeedToOpen") ' EV очищаем для каждого объекта
End Sub
'=============================================
Sub List_BeforeShow(Sheet)
'   thisApplication.AddNotify "List_BeforeShow"
    saveQName = thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","GetGlobalVarrible", "WinSaveQName") ' EV флаг для очистки
    call thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","RemoveGlobalVarrible", "WinSaveQName")
    
    if saveQName <> "t" then 
      call thisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB", "RemoveGlobalVarrible", "WinQuery")
    end if
    
End Sub

Sub Query_BeforeExecute(Query, Obj, Cancel)
  ThisApplication.Utility.Waitcursor = TRUE
End Sub

Sub Query_AfterExecute(Sheet, Query, Obj)
  ThisApplication.Utility.Waitcursor = FALSE
End Sub


Sub Command_BeforeExecute(Command, Obj, Cancel)
  ThisApplication.Utility.Waitcursor = TRUE
End Sub

Sub Command_Completed(Command, Obj)
  ThisApplication.Utility.Waitcursor = FALSE
End Sub



use CMD_LIBRARY
Sub Object_StatusChanged(Obj, Status)
  Thisscript.SysAdminModeOn
  set q = Thisapplication.Queries("QUERY_FIND_USERS_FROM_OBJECT_MARK2")

  q.Parameter("PARAM0") = Obj
  set users = q.Users
  'set objs = q.Objects
  Thisscript.SysAdminModeOff       
         
'  dim collect()
'  redim collect(objs.Count - 1)
'  i=0
'  for each mark in objs
'    set collect(i) = mark.CreateUser
'    i=i+1
'  next
  
  if users.Count> 0 then
    SendMail2 users, "Изменение статуса документа """ & Obj.description & """", Obj, false, "Статус объекта """ & Obj.description & """ был изменен на """ & Status.Description & """", false, "SYSADMIN"
  end if

End Sub
