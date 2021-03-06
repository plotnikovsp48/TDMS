USE "CMD_KD_COMMON_LIB"
USE "CMD_FILES_LIBRARY"
USE "CMD_PROJECT_DOCS_LIBRARY"

' Кнопка Отправить контрагенту
Sub BTN_OUT_DOC_PREPARE_OnClick()
  Set docOut = ThisApplication.ExecuteScript("CMD_DLL","CreareDocOut",ThisObject)
End Sub

'Кнопка - Добавить комментарий
Sub CMD_ADD_COMMENT_OnClick()
  Call AskAddComment("ATTR_INF")' из библиотеки CMD_KD_COMMON_LIB
End Sub

'Кнопка - Редактировать комментарий
Sub CMD_EDIT_COMMENT_OnClick()
  Call EidtComment("ATTR_INF")
End Sub

'Кнопка - На контроль
Sub BTN_TO_CONTROL_OnClick()
  Set BtnCon = ThisForm.Controls("BTN_TO_CONTROL").ActiveX
  If ThisApplication.ExecuteScript("CMD_MARK_LIB","HasMark",ThisObject, "на контроле") Then 
    Call ThisApplication.ExecuteScript("CMD_MARK_LIB","dellMark",ThisObject, "на контроле")
    BtnCon.Image = ThisApplication.Icons("IMG_ONCONTROL_PASSIVE")
'    Msgbox "Снято с контроля"
  Else    
    Call ThisApplication.ExecuteScript("CMD_MARK_LIB","CreateMark","на контроле",ThisObject, False)
    BtnCon.Image = thisApplication.Icons("IMG_ONCONTROL_ACTIVE")
'    Msgbox "Поставлено на контроль"
  End if
  ThisForm.Refresh
End Sub

'Кнопка - Избранное
Sub BTN_TO_FAV_OnClick()
  Set btnfav = ThisForm.Controls("BTN_TO_FAV").ActiveX
  If ThisApplication.ExecuteScript("CMD_MARK_LIB","HasMark",ThisObject, "избранное") Then 
    Call ThisApplication.ExecuteScript("CMD_MARK_LIB","dellMark",ThisObject, "избранное")
    BtnFav.Image = ThisApplication.Icons("IMG_IMPORTANT_PASSIVE")
'    Msgbox "Удалено из избранного"
  Else    
    Call ThisApplication.ExecuteScript("CMD_MARK_LIB","CreateMark","избранное",ThisObject, False)
    BtnFav.Image = ThisApplication.Icons("IMG_IMPORTANT_ACTIVE")
'    Msgbox "Добавлено в избранное"
  End If
  ThisForm.Refresh
End Sub

'Sub BTN_PRINT_ARGEE_OnClick()
'  Call ThisApplication.ExecuteScript ("CMD_DLL","PrintAgreeList",ThisObject)
'End Sub

'Кнопка - Сохранить
Sub BTN_SAVE_OnClick()
  ThisScript.SysAdminModeOn
  Key = Msgbox("Сохранить внесенные изменения?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
  ThisObject.SaveChanges (0)
End Sub

'Кнопка - Дублировать текущий документ
Sub BTN_COPY_DOC_OnClick()
  Set Obj = ThisObject
  Res = ThisApplication.ExecuteScript("CMD_DLL","CopyObj",Obj)
  If Not Res Then Exit Sub
  ThisForm.Close True
  
  If Not Obj.Parent Is Nothing Then
    ThisApplication.Shell.Update Obj.Parent
  End If
End Sub

'======================================================================================
'
'    Блок работы с файлами
'
'======================================================================================

'Кнопка - Добавить файл из шаблона
Sub BTN_ADDFROMTEMPLATE_OnClick()
  Select Case ThisObject.ObjectDefName
    Case "OBJECT_CONTRACT","OBJECT_CONTRACT_COMPL_REPORT","OBJECT_INVOICE","OBJECT_DRAWING", _
          "OBJECT_T_TASK","OBJECT_DOC_DEV","OBJECT_DOCUMENT","OBJECT_AGREEMENT"
      Call AddFileFromTemplate(ThisObject)
    Case Else
      Call AddFromTemplate(ThisObject)
  End Select
End Sub

'Кнопка - Добавить файлы с диска
Sub BTN_LOAD_FILE_TO_DOC_OnClick()
  Call ThisApplication.ExecuteScript("CMD_FILES_LIBRARY","FileAdd",ThisObject,ThisForm)
  'Call AddFileFromDiskForObject(ThisObject)
End Sub

'Кнопка - Добавить скан
Sub bAddFromScaner_OnClick()
  Call ThisApplication.ExecuteScript("CMD_CONTRACT_SCAN_ADD", "Main",ThisObject)
'  ThisObject.Update
End Sub

Sub BTN_ADD_SCAN_OnClick()
  Set Form = ThisForm
  If form.Controls.Has("PREVIEW1") Then
    Call ClosePreviewOnForm(Form)
  End If
  
  Call ThisApplication.ExecuteScript("CMD_CONTRACT_SCAN_ADD","Main",ThisObject)
  
'  ThisObject.Update
'  Call ThisApplication.ExecuteScript("CMD_KD_FILE_LIB","LoadFileToDocByObj", "FILE_KD_SCAN_DOC",ThisObject)
End Sub

'Событие - выделение файла в выборке файлов
Sub QUERY_FILES_IN_DOC_Selected(iItem, action)
  Call QueryFileSelect(ThisForm,iItem,Action)
  If iItem <> -1 and Action = 2 Then
    Call SetFilesActionButtonLocked(ThisForm,True)
  Else
    Call SetFilesActionButtonLocked(ThisForm,False)
  End If
  Call ShowFile(iItem)
End Sub

Sub QUERY_FILES_IN_DOC_DblClick(iItem, bCancelDefault)
  Thisscript.SysAdminModeOn
'  Set s = thisForm.Controls("QUERY_FILES_IN_DOC").ActiveX
'  set File = s.ItemObject(iItem) 
'  Call ThisApplication.ExecuteScript("CMD_KD_FILE_LIB","File_CheckOut",file)
'  bCancelDefault = true
  
  Set Obj = ThisObject
  Set cu = ThisApplication.CurrentUser
  canEdFiles = Obj.Permissions.EditFiles
  If Obj.Permissions.Locked Then
    lckOwn = Obj.Permissions.LockOwner
    Set lUser = Obj.Permissions.LockUser 
    If lckOwn = False Then msgbox "Документ заблокирован пользователем " & lUser.Description & " и будет открыт в режиме чтения!", vbExclamation, "Документ заблокирован"
    If canEdFiles = 1 Then
      flag = lckOwn 
    End If
  Else
    flag = (canEdFiles = 1)
  End If
  Call BlockFilesOpenFile(ThisForm,Obj,Flag)
  bCancelDefault = True
End Sub

'Кнопка - Редактировать файл
Sub BTN_EDIT_FILE_OnClick()
  Call BlockFilesOpenFile(ThisForm,ThisObject,True)
End Sub

'Кнопка - Открыть файл в окне просмотра
Sub b_ShowFilePreview_OnClick()
  Call BlockFilesOpenInside(ThisForm,ThisObject)
End Sub

'Кнопка - Открыть файлы на просмотр во внешнем редакторе
Sub bViewFile_OnClick()
  Call BlockFilesOpenFile(ThisForm,ThisObject,False)
  'Call ThisApplication.ExecuteCommand ("CMD_VIEW",ThisObject)
End Sub

'Кнопка - Сконвертировать в PDF
Sub BTN_ConvertToPDF_OnClick()
  Set fCreated = BlockFilesConvertPDF(ThisForm,ThisObject)
'  Call BlockFilesConvertPDF(ThisForm,ThisObject)
End Sub

'Кнопка - Печать
Sub BTN_PrintFiles_OnClick()
  Call BlockFilesPrint(ThisForm,ThisObject)
End Sub

'Кнопка - Выгрузка файлов
Sub BTN_UnLoad_OnClick()
  Call UnloadFilesFromDoc(ThisObject,ThisForm)
'  Call FilesUnload(ThisObject,1)
End Sub

'Кнопка - Удалить файл
Sub BTN_DELETE_FILES_OnClick()
  Call FilesDel(ThisObject,ThisForm)
End Sub

'Кнопка - Переименовать файл
Sub BTN_RENAME_FILE_OnClick()
  Call BlockFilesRename(ThisForm,ThisObject)
End Sub

'Кнопка - Сохранить
Sub BTN_SaveFiles_OnClick()
  ThisObject.CheckIn
  ThisObject.Refresh
  Call setEnabledButtonLocked (ThisForm, ThisObject)
End Sub

'Кнопка - Сохранить и закрыть
Sub BTN_SaveAndCloseFiles_OnClick()
  ThisObject.UnlockCheckIn  tdmSave  
  ThisObject.Refresh
  Call setEnabledButtonLocked (ThisForm, ThisObject)
End Sub

'Кнопка - Отменить редактирование
Sub BTN_CloseWithoutSave_OnClick()
  ThisObject.UnlockCheckIn  tdmCancelEdit  
  ThisObject.Refresh
  Call setEnabledButtonLocked (ThisForm, ThisObject)
End Sub

Sub SetCheckListControls(Form,Obj)
  Set CU = ThisApplication.CurrentUser
  If Obj.Attributes.Has("ATTR_CHECK_LIST") = False Then Exit Sub
  Set TableRows = Obj.Attributes("ATTR_CHECK_LIST").Rows
  Set Table = Form.Controls("ATTR_CHECK_LIST").ActiveX
  nRow = Table.SelectedRow
  rowselected = (nRow <> -1) and Table.RowCount <> 0
 
    isDevl = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsDeveloper",Obj,CU)
    isChck = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsChecker",Obj,CU)
    
    sName = Obj.StatusName
    check1 = isDevl And (sName = "STATUS_DOCUMENT_CREATED" or sName = "STATUS_DOCUMENT_IS_CHECKED_BY_NK")
    check2 = isChck And sName = "STATUS_DOCUMENT_CHECK"
    
    IsLocked = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsLockedByUser",Obj,CU)
  With Form.controls
    .Item("BTN_CHECKER_ADD").Enabled = (check1 or check2) And (Not IsLocked)
    .Item("BTN_CHECKER_EDIT").Enabled = (check1 or check2) And (Not IsLocked) And rowselected
    .Item("BTN_CHECKER_DEL").Enabled = (check1 or check2) And (Not IsLocked) And rowselected
    .Item("BTN_CHECKER_UP").Enabled = (check1 or check2) And (Not IsLocked) And rowselected
    .Item("BTN_CHECKER_DOWN").Enabled = (check1 or check2) And (Not IsLocked) And rowselected
  End With
End Sub

Sub SetLabels(Form, Obj)
ThisApplication.DebugPrint "SetLabels " & Time
  ' Отображение заголовка окна
  form.Caption = form.Description
  
  ' Отображение лэйбла статуса
  If Form.Controls.Has("lbStatus") Then
    If not Obj.Status is Nothing Then
      Form.Controls("lbStatus").Value = Obj.Status.Description
    End If
  End If

  ' Отображение лэйбла блокировки пользователем
  If Form.Controls.Has("lockUser") Then
    Set lckUser = Obj.Permissions.LockUser
    If Not lckUser Is Nothing Then
      If lckUser.SysName <> ThisApplication.CurrentUser.SysName Then
        Form.Controls("lockUser").Value = "Документ заблокирован пользователем " & lckUser.Description
      Else
        Form.Controls("lockUser").Value = ""
        Form.Controls("lockUser").ActiveX.Image = ""
      End If
    Else
      Form.Controls("lockUser").Value = ""
      Form.Controls("lockUser").ActiveX.Image = ""
    End If
  End If
  
  Call ThisApplication.ExecuteScript("CMD_DLL", "ShowBtnIcon",Form,Obj)
End Sub

'Кнопка - Открыть задачу
Sub CMD_TASK_OPEN_OnClick()
  Set Obj = ThisObject
  Set Form = ThisForm
  If Obj Is Nothing Or Form Is Nothing Then Exit Sub
  Set Task = ThisApplication.ExecuteScript("CMD_PLAN_TASK_LIB","GetPlanTaskLink",Obj)
  If not Task is Nothing Then
    Set Dlg = ThisApplication.Dialogs.EditObjectDlg
    Dlg.Object = Task
    Dlg.Show
  Else
    Key = Msgbox("Добавить в ПЛАТАН?",vbQuestion+vbYesNo)
    If Key = vbYes Then
      Obj.SaveChanges
      Call ThisApplication.ExecuteScript("CMD_ADD_TO_PLATAN", "Main", Obj)
      Call BtnTaskOpenChange(Form,Obj)
      Form.Refresh
    End If
  End If
End Sub

'Процедура изменения кнопки Открыть задачу
Sub BtnTaskOpenChange(Form,Obj)
  ThisApplication.DebugPrint "BtnTaskOpenChange" & Time 
  Set Task = ThisApplication.ExecuteScript("CMD_PLAN_TASK_LIB","GetPlanTaskLink",Obj)
  Set Btn = Form.Controls("CMD_TASK_OPEN")
  If not Task is Nothing Then
    Btn.ActiveX.Image = ThisApplication.Icons("IMG_PLATAN_ADDED")
    Btn.Value = "Открыть задачу"
  Else
    Btn.ActiveX.Image = ThisApplication.Icons("IMG_PLATAN_NOT_ADDED")
    Btn.Value = "Учитывать в ПЛАТАН"
  End If
End Sub

Sub ATTR_RESPONSIBLE_BeforeAutoComplete(Text)
  If len(Text) > 0 then
    Set source = ThisApplication.ExecuteScript("CMD_DEVELOPER_APPOINT","GetUserSource",ThisObject)
    If Not source Is Nothing Then
      ThisForm.Controls("ATTR_RESPONSIBLE").ActiveX.ComboItems = source
    End If
  End If
End Sub

Sub ATTR_RESPONSIBLE_ButtonClick(Cancel)
  If ThisForm.Controls("ATTR_RESPONSIBLE").ReadOnly = True Then 
    Cancel = True
    Exit Sub
  End If
  
  Set Obj = ThisObject
  Set source = ThisApplication.ExecuteScript("CMD_DEVELOPER_APPOINT","GetUserSource",ThisObject)
  If Source Is Nothing Then 
    Set NewUser = ThisApplication.ExecuteScript("CMD_DIALOGS","SelectUsersDlg")
  Else
    Set NewUser = ThisApplication.ExecuteScript("CMD_DIALOGS","SelectUserFromCollDlg",Source) 
  End If
  If Not NewUser Is Nothing Then 
    Set OldUser = Obj.Attributes("ATTR_RESPONSIBLE").User
  
    If Not OldUser Is Nothing Then
      If OldUser.handle = NewUser.Handle Then
        Exit Sub
      End If
    End If
  
    Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","SetResponsible",Obj,NewUser)
    Call ThisApplication.ExecuteScript("CMD_DEVELOPER_APPOINT","SetDept",Obj,NewUser)
    
    Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","ChangeResponsible",Obj,NewUser,OldUser)
    Obj.SaveChanges(0)
    Call ThisApplication.ExecuteScript("CMD_DEVELOPER_APPOINT","Run",Obj,NewUser)
 
  End If
  Cancel = True
'    If Not Source Is Nothing Then 
'      Set NewUser = ThisApplication.ExecuteScript("CMD_DIALOGS","SelectUserFromCollDlg",Source) 
'      
'    End If
End Sub

Function CheckForLock()
  CheckForLock = False
  If ThisApplication.ExecuteScript("CMD_DLL_ROLES","isLocked",ThisObject,ThisApplication.CurrentUser) = True Then
    msgbox "Операция отменена, т.к. задание заблокировано другим пользователем",vbExclamation,"Отмена операции"
    CheckForLock = True
  End If
End Function

Sub BTN_ShowInTree_OnClick()
Set Obj = ThisObject
  Call ThisApplication.ExecuteScript("CMD_DLL","LocateObjInTree",Obj)
  ans = msgbox ("Закрыть """ & Obj.Description & """? ",vbQuestion+vbYesNo,"Найти в дереве")
  If ans <> vbYes Then Exit Sub
  
  ThisForm.Close True
End Sub


