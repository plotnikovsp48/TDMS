' Форма ввода - Файлы
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.
USE "CMD_FILES_LIBRARY"

Sub Form_BeforeShow(Form, Obj)
  Form.Caption = Form.Description
  Call SetControls(Form,Obj)
  RefreshEDocReportAvailability form, obj
End Sub

Sub SetControls(Form,Obj)
  Dim enable 
  enable = AssemblingAndAuthor(Obj)
 ' If enable Then Exit Sub
  Set CU = ThisApplication.CurrentUser
  chk1 = check1(Form, Obj)
  isAuth = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsAuthor",Obj,CU)

  isGip = ThisApplication.ExecuteScript("CMD_DLL_ROLES","isGipOrDep",Obj,CU)
            
  With Form.Controls
    .Item("BUTTON_DEL").Enabled = enable
    .Item("BUTTON_RENAME").Enabled = enable
    .Item("BUTTON_REFRESH").Enabled = enable
    .Item("BTN_E_DOC_REPORT").Enabled = chk1
    .Item("BUTTON_SAVE").Enabled = (isAuth or isGip) and chk1
  End With
End Sub

Function check1(Form, Obj)
  check1 = False
  Set Table = Obj.Attributes("ATTR_INVOICE_TFILES")
  If Table Is Nothing Then Exit Function
  Set rows = Table.Rows
  
  If rows.Count = 0 Then exit Function
  check1 = True
End Function

'Кнопка - Добавить
' temporarily disabled
'Sub BUTTON_ADD_OnClick()
'  ThisScript.SysAdminModeOn
'  Set Dlg = ThisApplication.Dialogs.FileDlg
'  Set PDtype = ThisApplication.FileDefs("FILE_TRANSFER_DOCUMENT")
'  Set EOtype = ThisApplication.FileDefs("FILE_E-THE_ORIGINAL")
'  Dlg.Filter = "Файлы ЭО и ПД|"& PDtype.Extensions & ", " & EOtype.Extensions &"||"
'  Dlg.Filter = Replace(Dlg.Filter, ",", ";")
'  If Dlg.Show Then
'    StrMsg = ""
'    Set TableRows = ThisObject.Attributes("ATTR_INVOICE_TFILES").Rows
'    For Each Fname in Dlg.FileNames
'      Set FDef = CheckFileDef(ThisObject,Fname)
'      If not FDef is Nothing Then
'        FShortName = Right(FName, Len(Fname) - InStrRev(FName, "\"))
'        'Удаляем старый файл с таким же именем
'        If ThisObject.Files.Has(FShortName) Then
'          Set File = ThisObject.Files.Item(FShortName)
'          Fhandle = File.Handle
'          ThisObject.Files.Remove ThisObject.Files.Item(FShortName)
'          For Each Row in TableRows
'            If Row.Attributes("ATTR_INVOICE_OBJ_GUID").Value = Fhandle Then
'              TableRows.Remove Row
'              Exit For
'            End If
'          Next
'        End If
'        
'        Set NewFile = ThisObject.Files.Create(FDef.SysName)
'        On Error Resume Next
'        NewFile.CheckIn FName
'        On Error Goto 0
'        
'        'Вносим данные файла в таблицу
'        If not NewFile is Nothing Then
'          Set NewRow = TableRows.Create
'          'NewRow.Attributes("ATTR_INVOICE_OBJ_GUID").Value = NewFile.Handle
'          NewRow.Attributes("ATTR_FILE_NAME").Value = FShortName
'          NewRow.Attributes("ATTR_FILE_DISPNAME").Value = FShortName
'          NewRow.Attributes("ATTR_FILE_SIZE").Value = FileSizeDiff(NewFile.Size)
'          NewRow.Attributes("ATTR_FILE_CHDATE").Value = NewFile.ModifyTime
'        End If
'      End If
'    Next
'    
'  End If
'End Sub

'Кнопка - Удалить
Sub BUTTON_DEL_OnClick()
  ThisScript.SysAdminModeOn
  Set Dlg = ThisApplication.Dialogs.SelectDlg
  Dlg.Prompt = "Выберите файлы для удаления"
  Set TableRows = ThisObject.Attributes("ATTR_INVOICE_TFILES").Rows
  Dlg.SelectFrom = TableRows
  If Dlg.Show Then
    For Each Row in Dlg.Objects
      Row.Attributes("ATTR_FILE_EXCLUDED").Value = True
    Next
  End If
End Sub

'Кнопка - переименовать файл
Sub BUTTON_RENAME_OnClick()
  ThisScript.SysAdminModeOn

  Set Table = ThisForm.Controls("ATTR_INVOICE_TFILES")
  Arr = Table.ActiveX.SelectedRows
  Set Row = Table.ActiveX.RowValue(Arr(0))   
    
  FileName = Row.Attributes("ATTR_FILE_DISPNAME").Value
  Fname = getFileShortName(FileName)
  Ftype = getFileExtension(FileName)
  'Диалог ввода нового имени файла
  Set DlgName = ThisApplication.Dialogs.SimpleEditDlg

      DlgName.Prompt = "Введите новое имя файла """ & Fname & """"
      DlgName.Text = Fname
        
        If DlgName.Show Then
          If Trim(DlgName.Text) = "" Then
            msgbox "Имя файла не может быть пустым",vbExclamation,"Ошибка"
          Else            
            If DlgName.Text <> Fname Then
              FileName = DlgName.Text & "." & Ftype
              Row.Attributes("ATTR_FILE_DISPNAME").Value = CharsChange(FileName," ")
            End If
          End If
        End If
End Sub

'Кнопка - Обновить список
Sub BUTTON_REFRESH_OnClick()
  Key = Msgbox("Заменить список файлами из документации ?", vbYesNo + vbQuestion)
  If Key = vbNo Then Exit Sub
    
  Set TableFilesRows = ThisObject.Attributes("ATTR_INVOICE_TFILES").Rows
  'Удаляем все файлы в таблице
  For i = TableFilesRows.Count - 1 To 0 Step -1
    TableFilesRows(i).Erase
  Next
  
  AllowedDefs = GetAllowedFileDefs(ThisObject.Attributes("ATTR_INVOICE_EVERTYPE"))
  
  'Копируем файлы из документации в накладную
  Set TableDocsRows = ThisObject.Attributes("ATTR_INVOICE_TDOCS").Rows
  For Each Row in TableDocsRows
    If Not Row.Attributes("ATTR_INVOICE_DOCS_OBJ").Object Is Nothing Then
      Set Doc = Row.Attributes("ATTR_INVOICE_DOCS_OBJ").Object
      For Each o In Doc.ContentAll
        If o.ObjectDefName = "OBJECT_DOC_DEV" or o.ObjectDefName = "OBJECT_DRAWING" Then
          Call AddFilesFromObject(o, ThisObject, AllowedDefs)
        End If
      Next
    End If
  Next
  
  If TableFilesRows.Count = 0 Then
    MsgBox "Не найдено ни одного файла подходящего типа", vbInformation, ThisApplication.DatabaseName
  End If
  
  Call RefreshEDocReportAvailability(ThisForm, ThisObject)
End Sub

'Кнопка - Обновить список файлов (архив)
Sub BUTTON_REFRESH_ARCHIVE_OnClick()
  Key = Msgbox("Заменить список файлами из документации ?", vbYesNo + vbQuestion)
  If Key = vbNo Then Exit Sub
    
  Set TableFilesRows = ThisObject.Attributes("ATTR_INVOICE_TFILES").Rows
  'Удаляем все файлы в таблице
  For i = TableFilesRows.Count - 1 To 0 Step -1
    TableFilesRows(i).Erase
  Next
  
  AllowedDefs = GetAllowedFileDefsArchive()
  
  'Копируем файлы из документации в накладную
  Set TableDocsRows = ThisObject.Attributes("ATTR_INVOICE_TDOCS").Rows
  For Each Row in TableDocsRows
    If Not Row.Attributes("ATTR_INVOICE_DOCS_OBJ").Object Is Nothing Then
      Call AddFilesFromObject(Row.Attributes("ATTR_INVOICE_DOCS_OBJ").Object, ThisObject, AllowedDefs)
    End If
  Next
  
  If TableFilesRows.Count = 0 Then
    MsgBox "Не найдено ни одного файла подходящего типа", vbInformation, ThisApplication.DatabaseName
  End If
  
  Call RefreshEDocReportAvailability(ThisForm, ThisObject)
End Sub

'Процедура копирования файлов из связанной документации в накладную
Private Sub AddFilesFromObject(Source, Target, Allowed)
  Set TableRows = target.Attributes("ATTR_INVOICE_TFILES").Rows
  Set Files = Target.Files
  
  For Each File in Source.Files
    If InStr(1, Allowed, File.FileDefName) > 0 Then
      'Если уже есть файл с таким же именем, то удаляем его
      If Files.Has(File.FileName) Then Files.Remove Files.Item(File.FileName)
      Set NewFile = Files.AddCopy(File, File.FileName)
      NewFile.FileDef = ThisApplication.FileDefs(GetFileDefs(File))
    
      Set Row = TableRows.Create()
      Row.Attributes.Item("ATTR_INVOICE_OBJ_GUID").Value = source.GUID
      Row.Attributes.Item("ATTR_FILE_NAME").Value = NewFile.FileName
      Row.Attributes.Item("ATTR_FILE_DISPNAME").Value = NewFile.FileName
      Row.Attributes.Item("ATTR_FILE_SIZE").Value = FileSizeDiff(NewFile.Size)
      Row.Attributes.Item("ATTR_FILE_CHDATE").Value = NewFile.ModifyTime
    End If
  Next
End Sub

'Кнопка - Выгрузить на диск
' Stage -> Suite(Volume) -> Document -> File
Sub BUTTON_SAVE_OnClick()
  ThisApplication.ExecuteCommand "CMD_INVOICE_FILES_DOWNLOAD", ThisObject
End Sub

'Функция проверки типа файла на доступные для объекта
Function CheckFileDef(Obj,FName)
  Set CheckFileDef = Nothing
  FExtension = "*." & Right(FName, Len(Fname) - InStrRev(FName, "."))
  For Each FDef In Obj.ObjectDef.FileDefs
    If InStr(FDef.Extensions, FExtension) <> 0 Then
      Set CheckFileDef = FDef
      Exit Function
    End If
  Next
End Function

'Функция перевода размера файла
Function FileSizeDiff(FSize)
  FileSizeDiff = FSize '& " Б"
  If FSize > 1024 Then
    FSize = Round(FSize/1024, 1)
    If FSize > 1024 Then
      FSize = Round(FSize/1024, 1)
      If FSize > 1024 Then
        FSize = Round(FSize/1024, 1)
        FileSizeDiff = FSize & " ТБ"
      Else
        FileSizeDiff = FSize & " МБ"
      End If
    Else
      FileSizeDiff = FSize & " КБ"
    End If
  End If
End Function

'Функция выдает список типов файлов для копирования
Private Function GetAllowedFileDefs(Attribute)
  GetAllowedFileDefs = vbNullString
  If Attribute.Classifier Is Nothing Then Exit Function
  
  Select Case Attribute.Classifier.Code
    Case 1
      GetAllowedFileDefs = Join(Array("FILE_KD_SCAN_DOC","FILE_ARCHIVE_FILE", "FILE_DOC_PDF"), ";")
    Case 2
      GetAllowedFileDefs = Join(Array("FILE_DOC_DOC", "FILE_EDITABLE_FILE", "FILE_DOC_XLS", "FILE_AUTOCAD_DWG", _
        "FILE_ANY"), ";")
    Case 3
      GetAllowedFileDefs = Join(Array("FILE_KD_SCAN_DOC","FILE_ARCHIVE_FILE", "FILE_DOC_PDF", _
        "FILE_DOC_DOC", "FILE_EDITABLE_FILE", "FILE_DOC_XLS", "FILE_AUTOCAD_DWG", "FILE_ANY"), ";")
  End Select
End Function

'Функция преобразования типа файла
Private Function GetFileDefs(File)
  GetFileDefs = vbNullString
  Select Case File.fileDefName
    Case "FILE_KD_SCAN_DOC", "FILE_E-THE_ORIGINAL","FILE_ARCHIVE_FILE", "FILE_DOC_PDF"
      GetFileDefs = "FILE_ARCHIVE_FILE"
    Case "FILE_DOC_DOC", "FILE_EDITABLE_FILE", "FILE_DOC_XLS", "FILE_AUTOCAD_DWG", "FILE_ANY"
      GetFileDefs = "FILE_EDITABLE_FILE"
  End Select
End Function

'Функция выдает список типов файлов для копирования в архиве
Private Function GetAllowedFileDefsArchive()
  GetAllowedFileDefsArchive = vbNullString
  
  Set dict = CreateObject("Scripting.Dictionary")
  Defs = Array(ThisApplication.ObjectDefs("OBJECT_VOLUME"), ThisApplication.ObjectDefs("OBJECT_WORK_DOCS_SET"))
  For i = LBound(defs) To UBound(Defs)
    For Each File In Defs(i).FileDefs
      dict.Item(File.SysName) = 1
    Next
  Next
  GetAllowedFileDefsArchive = Join(dict.Keys, ";")
End Function


Private Function AssemblingAndAuthor(Obj)
  AssemblingAndAuthor = False
  If Obj.StatusName = "STATUS_INVOICE_FORTHEPICKING" Then
    If Obj.Attributes.Has("ATTR_AUTOR") Then
      If Not Obj.Attributes("ATTR_AUTOR").User Is Nothing Then
        If ThisApplication.CurrentUser.SysName = Obj.Attributes("ATTR_AUTOR").User.SysName Then
          AssemblingAndAuthor = True
        End If
      End If
    End If
  End If
End Function

'Кнопка - ЭВКД
Sub BTN_E_DOC_REPORT_OnClick()
  If ThisApplication.ExecuteScript("CMD_INVOICE_TO_FORM_STATEMENT_EVKD","Run",ThisObject) Then
    Msgbox "Ведомость ЭВКД сформирована",vbInformation,"ЭВКД"
  End If
End Sub

'Процедура управления доступностью кнопки ЭВКД
Sub RefreshEDocReportAvailability(Form, Obj)
  Form.Controls("BTN_E_DOC_REPORT").Enabled = _
    ThisApplication.ExecuteScript("CMD_INVOICE_TO_FORM_STATEMENT_EVKD", "EnableCommand", Obj)
End Sub
