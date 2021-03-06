' Библиотека функций по работе с проектными документами
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.
USE "CMD_FILES_LIBRARY"

'Функция возвращает строку из таблицы проверяющих
'Obj:object - Ссылка на объект с таблицей
'cType:string - код классификатора, тип проверки в строке
'User:user - ссылка на пользователя в строке
'notUser:user - ссылка на пользователя в строке (исключение)
'Resol:classifier - ссылка на классификатор резолюции в строке
Private Function GetRowCheckList(Obj,cType,User,notUser,Resol)
  Set GetRowCheckList = Nothing
  Set Rows = Obj.Attributes("ATTR_CHECK_LIST").Rows
  For Each Row in Rows
    Check = True
    'Проверка типа
    If cType <> "" Then
      Check = False
      If Row.Attributes("ATTR_CHECK_TYPE").Empty = False Then
        If not Row.Attributes("ATTR_CHECK_TYPE").Classifier is Nothing Then
          If StrComp(Row.Attributes("ATTR_CHECK_TYPE").Classifier.Code,cType,vbTextComapre) = 0 Then
            Check = True
          End If
        End If
      End If
    End If
    'Проверка пользователя
    If Row.Attributes("ATTR_USER").User is Nothing Then Exit Function
    If Check = True Then
      If not User is Nothing Then
        If Row.Attributes("ATTR_USER").User.SysName <> User.SysName Then
          Check = False
        End If
      End If
    End If
    'Проверка исключающего пользователя
    If Check = True Then
      If not notUser is Nothing Then
        If Row.Attributes("ATTR_USER").User.SysName = notUser.SysName Then
          Check = False
        End If
      End If
    End If
    'Проверка резолюции
    If Check = True Then
      If not Resol is Nothing Then
        Check = False
        If Row.Attributes("ATTR_RESOLUTION").Empty = False Then
          If not Row.Attributes("ATTR_RESOLUTION").Classifier is Nothing Then
            If Row.Attributes("ATTR_RESOLUTION").Classifier.SysName = Resol.SysName Then
              Check = True
            End If
          End If
        End If
      ElseIf Row.Attributes("ATTR_RESOLUTION").Empty = False Then
        Check = False
      End If
    End If
    'Если все проверки пройдены, то нашли строку
    If Check = True Then
      Set GetRowCheckList = Row
      Exit Function
    End If
  Next
End Function

'Блок проверки - Процедура перемещения строки проверяющего вниз 
Sub ChekerRowDown(Form,Obj)
  ThisScript.SysAdminModeOn
  Set TableRows = Obj.Attributes("ATTR_CHECK_LIST").Rows
  Set Table = Form.Controls("ATTR_CHECK_LIST").ActiveX
  nRow = Table.SelectedRow
  If nRow = 0 Then Exit Sub
  If nRow = Table.RowCount-1 Then Exit Sub
  Set Row0 = Table.RowValue(nRow)
  Set Row1 = Table.RowValue(nRow+1)
  If not Row0 is Nothing and not Row1 is Nothing Then
    TableRows.Swap Row0, Row1
    Table.Refresh
    'Меняем выделение
    Arr = Table.Selection
    Arr(0) = Arr(0)+1
    Arr(2) = Arr(2)+1
    Table.Selection = Arr
  End If
  TableRows.Update
End Sub

'Блок проверки - Процедура перемещения строки проверяющего вверх 
Sub ChekerRowUp(Form,Obj)
  ThisScript.SysAdminModeOn
  Set TableRows = Obj.Attributes("ATTR_CHECK_LIST").Rows
  Set Table = Form.Controls("ATTR_CHECK_LIST").ActiveX
  nRow = Table.SelectedRow
  If nRow = 0 Then Exit Sub
  Set Row0 = Table.RowValue(nRow)
  Set Row1 = Table.RowValue(nRow-1)
  If not Row0 is Nothing and not Row1 is Nothing Then
    TableRows.Swap Row0, Row1
    Table.Refresh
    'Меняем выделение
    Arr = Table.Selection
    Arr(0) = Arr(0)-1
    Arr(2) = Arr(2)-1
    Table.Selection = Arr
  End If
End Sub

'Блок проверки - Процедура удаления строки проверяющего 
Sub ChekerRowDel(Form,Obj)
  ThisScript.SysAdminModeOn
  Set Table = Form.Controls("ATTR_CHECK_LIST")
  Arr = Table.ActiveX.SelectedRows
  If UBound(Arr)+1 = 0 Then Exit Sub
  'Подтверждение удаления
  Key = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion + vbYesNo, 1607, UBound(Arr)+1)
  If Key = vbNo Then Exit Sub
  
  'Удаление строк
  For i = 0 to UBound(Arr)
    Set Row = Table.ActiveX.RowValue(Arr(i))
    Row.Erase
  Next
  Form.Refresh
End Sub

'Блок проверки - Процедура добавления строки проверяющего 
Sub ChekerRowAdd(Form,Obj)
  'Формирование списка классификаторов
  Set TableRows = Obj.Attributes("ATTR_CHECK_LIST").Rows
  Str = ""
  AttrName = "ATTR_CHECK_TYPE"
  For Each Clf in ThisApplication.Classifiers("NODE_CHECK_TYPE").Classifiers
    Check = True
    For Each Row in TableRows
      If Row.Attributes(AttrName).Empty = False Then
        If not Row.Attributes(AttrName).Classifier is Nothing Then
          If Clf.SysName = Row.Attributes(AttrName).Classifier.SysName Then
            Check = False
            Exit For
          End If
        End If
      End If
    Next
    If Check = True Then
      If Str <> "" Then
        Str = Str & "," & Clf.SysName
      Else
        Str = Clf.SysName
      End If
    End If
  Next
  
  If Str = "" Then
    Msgbox "Все проверяющие выбраны.",vbInformation
    Exit Sub
  End If
  
  'Отображение окна
  Set Form0 = ThisApplication.InputForms("FORM_CHECKER_ADD")
  Form0.Attributes("ATTR_ATTR").Value = Str
  Form0.Attributes("ATTR_OBJECT").Object  = Obj
  If Form0.Show Then
    Set User = Nothing
    If Form0.Attributes("ATTR_USER").Empty = False Then
      Set User = Form0.Attributes("ATTR_USER").User
    End If
    If not User is Nothing Then
      Set Clf = Form0.Attributes("ATTR_CHECK_TYPE").Classifier
      If not Clf is Nothing Then
        'Создание новой строки проверяющих
        Set NewRow = TableRows.Create
        NewRow.Attributes("ATTR_CHECK_TYPE").Classifier = Clf
        NewRow.Attributes("ATTR_USER").User = User
        If User.Attributes("ATTR_KD_USER_DEPT").Empty = False Then
          If not User.Attributes("ATTR_KD_USER_DEPT").Object is Nothing Then
            NewRow.Attributes("ATTR_T_TASK_DEPT").Object = User.Attributes("ATTR_KD_USER_DEPT").Object
          End If
        End If
        AttrName = "ATTR_POST"
        If User.Attributes.Has(AttrName) Then
          If User.Attributes(AttrName).Empty = False Then
            If not User.Attributes(AttrName).Classifier is Nothing Then
              NewRow.Attributes(AttrName).Classifier = User.Attributes("ATTR_POST").Classifier
            End If
          End If
        End If
        Form.Refresh
      End If
    End If
  End If
  
End Sub

'Блок проверки - Процедура редактирования строки проверяющего 
Sub ChekerRowEdit(Form,Obj)
  'Формирование списка классификаторов
  Set TableRows = Obj.Attributes("ATTR_CHECK_LIST").Rows
  Set Table = Form.Controls("ATTR_CHECK_LIST").ActiveX
  sRow = Table.SelectedRow
  If sRow = -1 or Table.RowCount = 0 Then Exit Sub' -1  Then
  Set SelRow = Table.RowValue(Table.SelectedRow)
  Str = ""
  AttrName = "ATTR_CHECK_TYPE"
  
  
  For Each Clf in ThisApplication.Classifiers("NODE_CHECK_TYPE").Classifiers
    Check = True
    For Each Row in TableRows
      If Row.Attributes(AttrName).Empty = False and Row.Handle <> SelRow.Handle Then
        If not Row.Attributes(AttrName).Classifier is Nothing Then
          If Clf.SysName = Row.Attributes(AttrName).Classifier.SysName Then
            Check = False
            Exit For
          End If
        End If
      End If
    Next
    If Check = True Then
      If Str <> "" Then
        Str = Str & "," & Clf.SysName
      Else
        Str = Clf.SysName
      End If
    End If
  Next
  
  'If Str = "" Then
  '  Msgbox "Все проверяющие выбраны.",vbInformation
  '  Exit Sub
  'End If
  
  'Отображение окна
  Set Form0 = ThisApplication.InputForms("FORM_CHECKER_ADD")
  Set cls = SelRow.Attributes("ATTR_CHECK_TYPE").Classifier
  
  Form0.Attributes("ATTR_ATTR").Value = Str
  Form0.Attributes("ATTR_OBJECT").Object  = Obj
  
  If SelRow.Attributes("ATTR_USER").Empty = False Then
    If not SelRow.Attributes("ATTR_USER").User is Nothing Then
      Form0.Attributes("ATTR_USER").User = SelRow.Attributes("ATTR_USER").User
    End If
  End If
  If SelRow.Attributes("ATTR_CHECK_TYPE").Empty = False Then
    If not cls is Nothing Then
      Form0.Attributes("ATTR_CHECK_TYPE").Classifier = cls
      Form0.Controls("ATTR_CHECK_TYPE").ReadOnly = True
    End If
  End If
  
  If Form0.Show Then
    Set Clf = Form0.Attributes("ATTR_CHECK_TYPE").Classifier
    Set User = Nothing
    If Form0.Attributes("ATTR_USER").Empty = False Then
      Set User = Form0.Attributes("ATTR_USER").User
    End If
    If not User is Nothing Then
        'Создание новой строки проверяющих
        SelRow.Attributes("ATTR_CHECK_TYPE").Classifier = Clf
        SelRow.Attributes("ATTR_USER").User = User
        If User.Attributes("ATTR_KD_USER_DEPT").Empty = False Then
          If not User.Attributes("ATTR_KD_USER_DEPT").Object is Nothing Then
            SelRow.Attributes("ATTR_T_TASK_DEPT").Object = User.Attributes("ATTR_KD_USER_DEPT").Object
          End If
        End If
        AttrName = "ATTR_POST"
        If User.Attributes.Has(AttrName) Then
          If User.Attributes(AttrName).Empty = False Then
            If not User.Attributes(AttrName).Classifier is Nothing Then
              SelRow.Attributes(AttrName).Classifier = User.Attributes("ATTR_POST").Classifier
            End If
          End If
        End If
      'End If
    End If
  End If
End Sub

'Блок проверки - Процедура управления доступностью кнопок
Sub CheckerRowsBtnEnabled(Form,Obj)
  Set CU = ThisApplication.CurrentUser
  isDevlp = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsDeveloper",Obj,CU)
  Form.Controls("BTN_CHECKER_ADD").Enabled = isDevlp And _
                (Obj.StatusName = "STATUS_DOC_IS_ADDED" Or _
                 Obj.StatusName = "STATUS_DOCUMENT_CREATED" Or _
                 Obj.StatusName = "STATUS_DOCUMENT_DEVELOPED" Or _
                 Obj.StatusName = "STATUS_DOCUMENT_AGREED" Or _
                 Obj.StatusName = "STATUS_DOCUMENT_IS_CHECKED_BY_NK")
  Set Table = Form.Controls("ATTR_CHECK_LIST").ActiveX
  sRow = Table.SelectedRow
  If sRow <> -1 and Table.RowCount <> 0 Then
    Form.Controls("BTN_CHECKER_EDIT").Enabled = True
    Form.Controls("BTN_CHECKER_DEL").Enabled = True
    If sRow = Table.RowCount-1 Then
      Form.Controls("BTN_CHECKER_DOWN").Enabled = False
    Else
      Form.Controls("BTN_CHECKER_DOWN").Enabled = True
    End If
    If sRow = 0 Then
      Form.Controls("BTN_CHECKER_UP").Enabled = False
    Else
      Form.Controls("BTN_CHECKER_UP").Enabled = True
    End If
  Else
    Form.Controls("BTN_CHECKER_EDIT").Enabled = False
    Form.Controls("BTN_CHECKER_DEL").Enabled = False
    Form.Controls("BTN_CHECKER_UP").Enabled = False
    Form.Controls("BTN_CHECKER_DOWN").Enabled = False
  End If
End Sub

'Блок файлов - Процедура открытия файла в окне просмотра
Sub BlockFilesOpenInside(Form,Obj)
  ThisScript.SysAdminModeOn
  Set Query = Form.Controls("QUERY_FILES_IN_DOC")
  If Query.SelectedObjects.Count > 0 Then
    Set File = Query.SelectedObjects(0)
    FileName = File.WorkFileName
    Set FSO = CreateObject("Scripting.FileSystemObject")
    If FSO.FileExists(FileName) = False Then
      File.CheckOut FileName
    End If
    Set Form0 = ThisApplication.InputForms("FORM_FILE_VIEW")
    Set View = Form0.Controls("VIEW").ActiveX
    Form0.Attributes("ATTR_FILE_NAME").Value = FileName
    Form0.Show
  End If
End Sub

'Блок файлов - Процедура конвертирования выбранного файла в PDF
Function BlockFilesConvertPDF(Form,Obj)
Set BlockFilesConvertPDF = Nothing
  ThisScript.SysAdminModeOn
  Set Query = Form.Controls("QUERY_FILES_IN_DOC")
  If Query.SelectedObjects.Count > 0 Then
    Set File = Query.SelectedObjects(0)
    'Проверка файла на возможность открыть в Word
    fName = File.FileName
    Ext = Right(fName,Len(fName)-InStrRev(fName,"."))
    Check = False
    If StrComp(Ext,"txt",vbTextCompare) = 0 or StrComp(Ext,"doc",vbTextCompare) = 0 or _
    StrComp(Ext,"docx",vbTextCompare) = 0 or StrComp(Ext,"docm",vbTextCompare) = 0 or _
    StrComp(Ext,"rtf",vbTextCompare) = 0 Then
      Check = True
    End If
    If Check = False Then
      Msgbox "Файл не может быть сконвертирован в PDF", vbExclamation
      Exit Function
    End If
    
    'Конвертирование в PDF
    PDFname = CreatePDF(Obj,File.WorkFileName,nothing)
    newName = Left(File.FileName, InStrRev(File.FileName, ".")) & "PDF"
    If Obj.Files.Has(newName) Then
      Obj.Files.Remove Obj.Files.Item(newName)
      Obj.SaveChanges
    End If
    
    If Obj.ObjectDefName = "OBJECT_T_TASK" Then
      fDefName = "FILE_KD_SCAN_DOC"
    Else
      fDefName = "FILE_DOC_PDF"
    End If
    
    On Error Resume Next
    Set NewFile = Obj.Files.Create(fDefName)
    NewFile.CheckIn PDFname
    NewFile.FileName = newName
    'On Error GoTo 0
    'Obj.SaveChanges 16384
    Obj.Update
    Set BlockFilesConvertPDF = NewFile
  End If
End Function

''Блок файлов - Процедура конвертирования выбранного файла в PDF
'Sub BlockFilesConvertPDF(Form,Obj)
'  ThisScript.SysAdminModeOn
'  Set Query = Form.Controls("QUERY_FILES_IN_DOC")
'  If Query.SelectedObjects.Count > 0 Then
'    Set File = Query.SelectedObjects(0)
'    'Проверка файла на возможность открыть в Word
'    fName = File.FileName
'    Ext = Right(fName,Len(fName)-InStrRev(fName,"."))
'    Check = False
'    If StrComp(Ext,"txt",vbTextCompare) = 0 or StrComp(Ext,"doc",vbTextCompare) = 0 or _
'    StrComp(Ext,"docx",vbTextCompare) = 0 or StrComp(Ext,"docm",vbTextCompare) = 0 or _
'    StrComp(Ext,"rtf",vbTextCompare) = 0 Then
'      Check = True
'    End If
'    If Check = False Then
'      Msgbox "Файл не может быть сконвертирован в PDF", vbExclamation
'      Exit Sub
'    End If
'    
'    'Конвертирование в PDF
'    PDFname = CreatePDF(Obj,File.WorkFileName,nothing)
'    newName = Left(File.FileName, InStrRev(File.FileName, ".")) & "PDF"
'    If Obj.Files.Has(newName) Then
'      Obj.Files.Remove Obj.Files.Item(newName)
'      Obj.SaveChanges
'    End If
'    On Error Resume Next
'    Set NewFile = Obj.Files.Create("FILE_DOC_PDF")
'    NewFile.CheckIn PDFname
'    NewFile.FileName = newName
'    'On Error GoTo 0
'    'Obj.SaveChanges 16384
'    Obj.Update
'  End If
'End Sub

'Блок файлов - Процедура открытия файла на просмотр или редактирование
'Sub BlockFilesOpenFile(Form,Obj,Edit)
'  ThisScript.SysAdminModeOn
'  Set Query = Form.Controls("QUERY_FILES_IN_DOC")
'  If Query.SelectedObjects.Count > 0 Then
'    Set File = Query.SelectedObjects(0)
'    FileName = File.WorkFileName
'    Set FSO = CreateObject("Scripting.FileSystemObject")
'    If FSO.FileExists(FileName) = False Then
'      File.CheckOut FileName
'    End If
'    Call ClosePreviewOnForm(Form)
'    Call ThisApplication.ExecuteScript("CMD_KD_FILE_LIB","DelPDFFormDisk",file)
'    Set objShellApp = CreateObject("Shell.Application")
'    objShellApp.Open(FileName)
'    If Obj.Permissions.Locked = True Then 
'      If Obj.Permissions.LockOwner = False Then
'        Edit = False
'      End If
'    End If
'    If Edit = True Then
'      Obj.Lock tdmLockFiles
'      'Call setEnabledButtonLocked (Form, Obj)
'    End If
'  End If
'End Sub

Sub BlockFilesOpenFile(Form,Obj,Edit)
  ThisScript.SysAdminModeOn
  Set Query = Form.Controls("QUERY_FILES_IN_DOC")
  If Query.SelectedObjects.Count > 0 Then
    Set File = Query.SelectedObjects(0)
    FileName = File.WorkFileName
    Set FSO = CreateObject("Scripting.FileSystemObject")
    If FSO.FileExists(FileName) = False Then
      File.CheckOut FileName
    End If
    
    If Obj.Permissions.Locked = True Then
      If Obj.Permissions.LockOwner = False Then
        Edit = False
      Else
        If obj.Permissions.EditFiles <> 1 Then
          Edit = False
        End If
      End If
    Else
      If obj.Permissions.EditFiles = 1 Then
      'str закрыл блокировку
'        If Edit = True or Edit = 1 Then Obj.Lock tdmLockFiles
      End If
    End If
    
    If Edit = True or Edit = 1 Then
      Call ClosePreviewOnForm(Form)
    
      thisApplication.ExecuteCommand "CMD_EDIT_FILE", obj
      Call ThisApplication.ExecuteScript("CMD_KD_FILE_LIB","DelPDFFormDisk",file)
    Else
      thisApplication.ExecuteCommand "CMD_VIEW_FILES", obj
      'file.CheckOut file.WorkFileName ' извлекаем
    End If
  
    'Call ClosePreviewOnForm(Form)
    'Call ThisApplication.ExecuteScript("CMD_KD_FILE_LIB","DelPDFFormDisk",file)
    Set objShellApp = CreateObject("Shell.Application")
    objShellApp.Open(FileName)
'    If Edit = True Then
'      Obj.Lock tdmLockFiles
'      'Call setEnabledButtonLocked (Form, Obj)
'    End If
  End If
End Sub
  
'Блок файлов - Процедура печати файла через внешний редактор
Sub BlockFilesPrint(Form,Obj)
  ThisScript.SysAdminModeOn
  Set Query = Form.Controls("QUERY_FILES_IN_DOC")
  If Query.SelectedObjects.Count > 0 Then
    Set OldFile = Obj.Files.Main
    Set File = Query.SelectedObjects(0)
    If File.Handle <> OldFile.Handle Then
      Obj.Files.Main = File
    End If
    
    Call ThisApplication.ExecuteCommand ("CMD_PRINT",Obj)
    
    If OldFile.Handle <> Obj.Files.Main.Handle Then
      Obj.Files.Main = OldFile
    End If
  End If
End Sub

'Блок файлов - Процедура переименования файла
Sub BlockFilesRename(Form,Obj)
  ThisScript.SysAdminModeOn
  Set Query = Form.Controls("QUERY_FILES_IN_DOC")
  If Query.SelectedObjects.Count > 0 Then
    Set File = Query.SelectedObjects(0)
    If checkRenameEnabled(file) = False Then Exit Sub
    fName = File.FileName
    shortName = Left(fName, InStrRev(fName, ".")-1)
        
    Ext = Right(fName,Len(fName)-InStrRev(fName,".")+1)
    Set Dlg = ThisApplication.Dialogs.SimpleEditDlg
    Dlg.Text = shortName
    Dlg.Caption = "Переименование файла"
    Dlg.Prompt = "Введите новое имя файла"
    If Dlg.Show Then
      If Dlg.Text <> fName Then
        fNameNew = CharsChange(Dlg.Text," ") & Ext
        Call FileChkInProcessing(File, Obj)
        File.FileName = fNameNew
        
        Obj.Update
      End If
    End If
  End If
End Sub

'Блок файлов - Процедура управления доступностью кнопок
Private sub setEnabledButtonLocked (Form, Obj)
  set Ctrls = Form.Controls

  If obj.Permissions.LockType = tdmLockFiles Then
'    If Ctrls("BTN_EDIT_FILE").Enabled Then
'      Ctrls("BTN_SaveFiles").Enabled = True
'      Ctrls("BTN_SaveAndCloseFiles").Enabled = True
'      Ctrls("BTN_CloseWithoutSave").Enabled = True    
'    End if
  Else
'    Ctrls("BTN_SaveFiles").Enabled = False
'    Ctrls("BTN_SaveAndCloseFiles").Enabled = False
'    Ctrls("BTN_CloseWithoutSave").Enabled = False
  End if
End Sub

'Блок файлов - Процедура управления доступностью кнопок 2
Private Sub SetFilesActionButtonLocked(Form,Lock)
  List = "BTN_DELETE_FILES,BTN_RENAME_FILE,BTN_PrintFiles,BTN_ConvertToPDF,bViewFile,b_ShowFilePreview" ',BTN_UnLoad
  arr = Split(List,",")
  
'  With Form.Controls
'    For i = 0 to Ubound(arr)
'      If .Has(arr(i)) Then
'        .Item(arr(i)).Enabled = Lock
'      End If
'    Next
'  End With

  Set CU = ThisApplication.CurrentUser 
  Set Obj = ThisObject
  isLckd = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsLockedByUser",Obj,CU)
  
  isApproved = (Obj.StatusName = "STATUS_DOCUMENT_FIXED") or (Obj.StatusName = "STATUS_COCOREPORT_CLOSED") or _
                  (Obj.StatusName = "STATUS_CONTRACT_CLOSED") or (Obj.StatusName = "STATUS_INVOICE_CLOSED")
  isCanceled = (Obj.StatusName = "STATUS_DOCUMENT_INVALIDATED") or (Obj.StatusName = "STATUS_COCOREPORT_INVALIDATED") or _
                  (Obj.StatusName = "STATUS_CONTRACT_CLOSED") or (Obj.StatusName = "STATUS_AGREEMENT_INVALIDATED") or _
                  (Obj.StatusName = "STATUS_INVOICE_INVALIDATED")
  canAddFile = CanAddFileToObject(Obj)
  candelfile = (Obj.Permissions.EditFiles=tdmallow)
  
  canViewFiles = Obj.Permissions.ViewFiles = 1
  
  
  With Form.Controls
  If Form.Controls.Has("BTN_ADDFROMTEMPLATE") Then .Item("BTN_ADDFROMTEMPLATE").Enabled = canAddFile 'And (isLckd = 1) And (Not (isApproved or isCanceled))
  If Form.Controls.Has("BTN_LOAD_FILE_TO_DOC") Then .Item("BTN_LOAD_FILE_TO_DOC").Enabled = canAddFile 'And (isLckd = 1) And (Not (isApproved or isCanceled))
  If Form.Controls.Has("BTN_ConvertToPDF") Then .Item("BTN_ConvertToPDF").Enabled = canAddFile And (isLckd = 1) And (Not (isApproved or isCanceled))
  If Form.Controls.Has("bAddFromScaner") Then .Item("bAddFromScaner").Enabled = canAddFile And (isLckd = 1) And (Not (isApproved or isCanceled))
  If Form.Controls.Has("BTN_ADD_SCAN") Then .Item("BTN_ADD_SCAN").Enabled = canAddFile 'And (isLckd = 1) And (Not (isApproved or isCanceled))
  
  If Form.Controls.Has("BTN_DELETE_FILES") Then .Item("BTN_DELETE_FILES").Enabled = canAddFile 'candelfile And Lock And (isLckd = 1) And (Not (isApproved or isCanceled))
  If Form.Controls.Has("BTN_RENAME_FILE") Then .Item("BTN_RENAME_FILE").Enabled = candelfile  And Lock And (isLckd = 1) And  (Not (isApproved or isCanceled))
    
  If Form.Controls.Has("BTN_UnLoad") Then .Item("BTN_UnLoad").Enabled = canViewFiles
  
'  '.Item("BTN_EDIT_FILE").Enabled = Lock
  
'  .Item("BTN_PrintFiles").Enabled = canViewFiles
'  
'  .Item("bViewFile").Enabled = Lock
'  .Item("b_ShowFilePreview").Enabled = Lock
  End With
End Sub

'Блок маршрутизации - Процедура управления доступностью кнопок
Sub BlockRouteButtonLocked(Form,Obj)

  Obj.Permissions = SysAdminPermissions
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  Set Roles = Obj.RolesForUser(CU)
  isDevl = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsDeveloper",Obj,CU)
  isGip = ThisApplication.ExecuteScript("CMD_DLL_ROLES","isGipOrDep",Obj,CU)
  isCompl = ThisApplication.ExecuteScript("CMD_DLL_ROLES","isgroupmember",CU,"GROUP_COMPL")
  needAgree = False
  If Obj.Attributes.Has("ATTR_NEED_AGREE") Then
    needAgree = Obj.Attributes("ATTR_NEED_AGREE")
  End If
  Set Dict = ThisApplication.Dictionary(Obj.Guid & " - BlockRoute")
  Dict.RemoveAll
  BtnList = "BTN_TO_CHECK,BTN_SIGN,BTN_TO_AGREE,BTN_TO_NK,BTN_TO_APPROVAL,BTN_APPROVE,BTN_REJECT,BTN_COPY,BTN_CANCEL"
  Arr = Split(BtnList,",")
  
  'Скопировать документ
  If not Obj.Parent is Nothing Then
    If Obj.Parent.Permissions.EditContent = 1 Then Dict.Item("BTN_COPY") = True
  End If

  Select Case Obj.StatusName
    'Документ в разработке
    Case "STATUS_DOCUMENT_CREATED"
      If Roles.Has("ROLE_DOC_INVALIDATED") Then
        Dict.Item("BTN_CANCEL") = True
      End If
      If (isGip And isDevl) And needAgree Then 
        Dict.Item("BTN_TO_AGREE") = True
      ElseIf isDevl And (not isGip) Then
        Dict.Item("BTN_TO_CHECK") = True
      End If
      If (isGip And isDevl) And not needAgree Then 
        Dict.Item("BTN_TO_NK") = True
      End If
      
    'Документ на проверке
    Case "STATUS_DOCUMENT_CHECK"
      
      If Roles.Has("ROLE_DOC_INVALIDATED") Then
        Dict.Item("BTN_CANCEL") = True
      End If
      If Roles.Has("ROLE_DOC_CHECKER") Then
        Dict.Item("BTN_SIGN") = True
        Dict.Item("BTN_REJECT") = True
      End If
      
    'Документ разработан
    Case "STATUS_DOCUMENT_DEVELOPED"
      If Roles.Has("ROLE_DOC_INVALIDATED") Then
        Dict.Item("BTN_CANCEL") = True
      End If
      
      If Roles.Has("ROLE_INITIATOR") Then
        If Obj.Attributes.Has ("ATTR_NEED_AGREE") = True Then
          If Obj.Attributes("ATTR_NEED_AGREE") = True Then
            Dict.Item("BTN_TO_AGREE") = True
          Else
            If isDevl Then'Roles.Has("ROLE_DOC_DEVELOPER") Then
              Dict.Item("BTN_TO_NK") = True
            End If
          End If
        Else
          Dict.Item("BTN_TO_AGREE") = True
        End If
      End If
      
      If SetRejectButtonForDeveloper(Obj) Then
        Dict.Item("BTN_REJECT") = True
      End If
    'На согласовании
    Case "STATUS_KD_AGREEMENT"
      
    'Документ согласован
    Case "STATUS_DOCUMENT_AGREED"
      If Roles.Has("ROLE_DOC_INVALIDATED") Then
        Dict.Item("BTN_CANCEL") = True
      End If
      If isDevl Then'Roles.Has("ROLE_DOC_DEVELOPER") Then
        Dict.Item("BTN_TO_NK") = True
      End If
      
      If SetRejectButtonForDeveloper(Obj) Then
        Dict.Item("BTN_REJECT") = True
      End If
    'Передан на нормоконтроль
    Case "STATUS_DOCUMENT_IS_SENT_TO_NK"
      If Roles.Has("ROLE_DOC_INVALIDATED") Then
        Dict.Item("BTN_CANCEL") = True
      End If
      
    'Взят на нормоконтроль
    Case "STATUS_DOCUMENT_IS_TAKEN_NK"
      If Roles.Has("ROLE_NK") Then
        Dict.Item("BTN_REJECT") = True
      End If

    'Прошел нормоконтроль
    Case "STATUS_DOCUMENT_IS_CHECKED_BY_NK"
      If Roles.Has("ROLE_DOC_INVALIDATED") Then
        Dict.Item("BTN_CANCEL") = True
      End If
      If isDevl Then'Roles.Has("ROLE_DOC_DEVELOPER") Then
        Dict.Item("BTN_TO_APPROVAL") = True
      End If
      
      If SetRejectButtonForDeveloper(Obj) Then
        Dict.Item("BTN_REJECT") = True
      End If
      
    'Документ на утверждении
    Case "STATUS_DOCUMENT_IS_APPROVING"
      If Roles.Has("ROLE_DOCUMENT_APPROVE") Then
        Dict.Item("BTN_APPROVE") = True
        Dict.Item("BTN_REJECT") = True
      End If
      If SetRejectButtonForDeveloper(Obj) Then
        Dict.Item("BTN_REJECT") = True
      End If
    'Документ утвержден
    Case "STATUS_DOCUMENT_FIXED"
      If Roles.Has("ROLE_DOC_INVALIDATED") Then
        Dict.Item("BTN_CANCEL") = True
      End If
      
      If Check_CMD_DOC_DEV_CHANGE(Obj) Then
        Dict.Item("BTN_REJECT") = True
      End If
    'Документ аннулирован
    Case "STATUS_DOCUMENT_INVALIDATED"
      
  End Select
  
  'Блокировка кнопок
  For i = 0 to Ubound(Arr)
    BtnName = Arr(i)
    If Dict.Exists(BtnName) Then
      Check = True
    Else
      Check = False
    End If
    If Form.Controls.Has(BtnName) Then
      Form.Controls(BtnName).Visible = Check
      Form.Controls(BtnName).Enabled = Check
    End If
  Next
End Sub

function CanAddFileToObject(Obj)
  CanAddFileToObject = false 
  on error resume next  
  mas = thisApplication.ExecuteScript(Obj.ObjectDefName,"GetTypeFileArr", Obj)
  if err.Number <> 0 then err.clear
  on error goto 0
  if not isArray(mas) then exit function
  CanAddFileToObject = true
end function 

Sub ClearCheckList(Obj)
  If Obj.Attributes.Has("ATTR_CHECK_LIST") = False Then Exit Sub
  Set Table = Obj.Attributes("ATTR_CHECK_LIST")
  For each row In Table.rows
    If Not row Is Nothing Then
      ThisApplication.ExecuteScript "CMD_SS_LIB", "ClearAttributes", _
        row, "ATTR_DATA;ATTR_RESOLUTION;ATTR_T_REJECT_REASON"
    End If
  Next
End Sub

' Функция обработки после согласования
Function AgreementPostProcess(Obj)
  Obj.Permissions = SysAdminPermissions
  AgreementPostProcess = True
  For each row In ThisApplication.Attributes("ATTR_AGREENENT_SETTINGS").Rows
    If row.Attributes("ATTR_KD_OBJ_TYPE").Value = Obj.ObjectDefName Then
      StatusAfterAgreed = row.Attributes("ATTR_KD_FINISH_STATUS").Value
      StatusReturnAfterAgreed = Row.Attributes("ATTR_KD_RETURN_STATUS")
      Exit For
    End If
  Next
  
  If Obj.statusName = StatusAfterAgreed Then
    ThisApplication.ExecuteScript "CMD_DLL_ORDERS", "SendOrder_Doc_AGREED",Obj
  Else
    Select Case Obj.ObjectDefName
      Case "OBJECT_DOC_DEV","OBJECT_DRAWING","OBJECT_T_TASK"
        If Obj.statusName <> StatusAfterAgreed Then
          Obj.Versions.Create,"Отклонено с согласования"
          Call ClearCheckList(Obj)
          ThisApplication.ExecuteScript "CMD_DLL_ORDERS", "SendOrder_NODE_KD_RETUN_USER",Obj
        End If
      Case "OBJECT_CONTRACT","OBJECT_AGREEMENT","OBJECT_CONTRACT_COMPL_REPORT"
        If Obj.statusName <> StatusAfterAgreed Then
          Obj.Versions.Create,"Отклонено с согласования"
          ThisApplication.ExecuteScript "CMD_DLL_ORDERS", "SendOrder_NODE_KD_RETUN_USER",Obj
        End If
    End Select
  End If
  AgreementPostProcess = True
End Function

' Проверка возможности переименования файла документа,
' название которого автоматически генерируется
Function CheckRenameEnabled(file)
  CheckRenameEnabled = False
  If file Is Nothing Then exit Function
  Set Obj = file.Owner
  If Obj Is Nothing Then exit Function
  skeeprename = False
  Select Case Obj.ObjectDefName
    Case "OBLECT_DOC_DEV","OBJECT_DRAWING","OBJECT_T_TASK"
      skeeprename = True
  End Select  
  
  If skeeprename = True Then
    fDefDefault = GetDefaultFileDef(Obj)
    If fDefDefault = file.FileDefName Then 
      msgbox "Выбранный файл не может быть переименован, т.к. наименование генерируется автоматически",vbCritical,"Переименовать файл"
      Exit Function
    End If
  End If
  CheckRenameEnabled = True
End Function

' Проверка, может ли пользователь вернуть документ в разработку из утвержденного состояния
Function Check_CMD_DOC_DEV_CHANGE(Obj)
  Check_CMD_DOC_DEV_CHANGE = False
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  
  Set uRoles = Obj.RolesForUser(CU)
  isLeadDevl = uRoles.Has("ROLE_VOLUME_COMPOSER") or uRoles.Has("ROLE_LEAD_DEVELOPER")
  
  isGip = ThisApplication.ExecuteScript("CMD_DLL_ROLES","isGipOrDep",Obj,CU)
  isDevl = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsDeveloper",Obj,CU)
  isCompl = ThisApplication.ExecuteScript("CMD_DLL_ROLES","isgroupmember",CU,"GROUP_COMPL")
  
  If Obj.ObjectDefName = "OBJECT_WORK_DOCS_SET" or Obj.ObjectDefName = "OBJECT_VOLUME" Then
    Check_CMD_DOC_DEV_CHANGE = isGip or isCompl or isLeadDevl
  ElseIf Obj.ObjectDefName = "OBJECT_DOC_DEV" or Obj.ObjectDefName = "OBJECT_DRAWING" Then
    Check_CMD_DOC_DEV_CHANGE = isDevl or isCompl or isLeadDevl
  End If
End Function


' Проверка прав на создание чертежа или проектного документа
' Пользователь имеет право на создание документов в основном комплекте или Томе, 
' если относится к тому же отделу, что и ответственный
Function DocCreatePermissionsCheck(Obj,Parent)
  DocCreatePermissionsCheck = False
  If Parent.ObjectDefName = "OBJECT_T_TASKS" or Parent.ObjectDefName = "OBJECT_UNIT" Then
    DocCreatePermissionsCheck = True
    Exit Function
  End If
  Set CU = ThisApplication.CurrentUser
  Set resp = Nothing
  If Parent.Attributes.Has("ATTR_RESPONSIBLE") Then
    Set resp = Parent.Attributes("ATTR_RESPONSIBLE").User
    
  End If
  If resp Is Nothing Then Exit Function
  If (ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","IsTheSameDeptByUsers",CU,resp) = False) And _
              (Parent.RolesForUser(CU).Has("ROLE_CO_AUTHOR") = False) Then
    msgbox "У вас недостаточно прав на создание документа на этом уровне. Обратитесь к пользователю " & resp.Description & _
      " за предоставлением доступа с правами Соразработчика",vbInformation,"Создание документа"
    Exit Function
  End If
  DocCreatePermissionsCheck = True
End Function

Function SetRejectButtonForDeveloper(Obj)
  SetRejectButtonForDeveloper = False
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  Set uRoles = Obj.RolesForUser(CU)
  isDevl = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsDeveloper",Obj,CU)
  isLeadDevl = uRoles.Has("ROLE_VOLUME_COMPOSER") or uRoles.Has("ROLE_LEAD_DEVELOPER")
  
  SetRejectButtonForDeveloper = isDevl or isLeadDevl
End Function

Sub CodeGen (Obj)
  val = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "DocDevCodeGen",Obj)
  If Obj.Attributes("ATTR_DOC_CODE").Value <> val Then
    Obj.Attributes("ATTR_DOC_CODE").Value = val
  End If
End Sub

Sub  SetCheckList(Obj, Parent)
  set table = Obj.attributes("ATTR_CHECK_LIST")  

  Dim rows()
  
  checkList = "Проверил,Нач.отд.,Н.контр.,ГИП"
  Rowlist = Split(checklist,",")
  Redim rows(Ubound(Rowlist))
  For i = 0 To Ubound(rows)
    Set row = table.rows.create
    Call checklistrowfill(Obj,row,Rowlist(i))
  Next
End Sub

Function checklistrowfill(Obj,row,checktype)
  Set checklistrowfill = Nothing
  If row Is Nothing Then Exit Function
  If checkType = vbnullString Then Exit Function
    Set cls = ThisApplication.Classifiers("NODE_CHECK_TYPE").Classifiers.Find(checktype)
    checkcode = cls.code
    row.Attributes(0).Classifier = cls
    row.Attributes(1).User = GetDefaultCheckUser(Obj,checkcode)
End Function

Function GetDefaultCheckUser(Obj,checkcode)
  Set GetDefaultCheckUser = Nothing
  Set CU = ThisApplication.CurrentUser
  Select case checkcode
      Case "approve"
        Set User = ThisApplication.ExecuteScript("CMD_DLL_ROLES","GetProjectGip",Obj)
      Case "check"
        Set User = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetChiefForUser",CU)
      Case "deptchief"
        Set User = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetDeptChiefByUser",CU)
      Case "nk"
'        Set User = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetDefaultNK",Obj.Parent.Attributes("ATTR_S_DEPARTMENT").Object)
        Set User = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetDefaultNK",Obj)
      Case Else
        Set user = Nothing
  End Select
  Set GetDefaultCheckUser = User
End Function
