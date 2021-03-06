' $Workfile: COMMAND.SCRIPT.CMD_FOLDER_IMPORT.scr $ 
' $Date: 29.09.08 12:37 $ 
' $Revision: 4 $ 
' $Author: Oreshkin $ 
'
' Импорт папки Windows
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

Dim sReport
Dim sPath
Dim fso
Dim vForm
Dim vRows
Dim Size
Dim ImportedSize
Dim Progress
Dim dicParentPath

Call Main

Sub Main()
  Dim sPath_
  
  ' Установка курсора ожидания
  ThisApplication.Utility.WaitCursor = True
  
  ImportedSize = 0
  sPath = ThisApplication.ExecuteScript("CMD_DIALOGS","GetFolder")
  If sPath = " " Then Exit Sub

  ' Создание формы
  Set vForm = ThisApplication.InputForms("FORM_FOLDER_IMPORT")
  ' Получаем ссылку на таблицу
  Set vRows = vForm.Attributes("ATTR_FOLDER_IMPORT_TABLE").Rows
  
  ' получение корневой папки
  Set fso = CreateObject("Scripting.FileSystemObject")
  Set f = fso.GetFolder(sPath)
  If f Is Nothing Then Exit Sub
  
  Set Progress = ThisApplication.Dialogs.ProgressDlg
  Progress.Start
  Progress.SetLocalRanges 0,100  

  ' Получение размера папки
  Progress.Position = 0
  Progress.Text = "Анализ папки импорта"
  WriteReport "Анализ папки импорта"
  
  Size = f.Size
  If Size=0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1027
    Exit Sub
  End If
  
  Set dicParentPath = CreateObject("Scripting.Dictionary")
  
  ' экспорт
  Progress.Position = 50
  Progress.Text = "Формирование таблицы импорта"
  WriteReport "Формирование таблицы импорта"
  
  Call CreateExportTable(f)
  
  Progress.Position = 100
  Progress.Text = "Формирование таблицы завершено"
  WriteReport "Формирование таблицы завершено" 
  Progress.Stop
  
  ' Установка курсора ожидания
  ThisApplication.Utility.WaitCursor = False
  
  If Not vForm.Show Then Exit Sub
  
  ' Установка курсора ожидания
  ThisApplication.Utility.WaitCursor = True  
  
  ImportedSize = 0
  Progress.Start
  Progress.SetLocalRanges 0,100
  
  Progress.Position = 0
  Progress.Text = "Импорт в Систему"
  WriteReport "Импорт в Систему"
  
  Set vRows = vForm.Attributes("ATTR_FOLDER_IMPORT_TABLE").Rows
  
  Call CreateObjects(ThisObject)
  
  Progress.Position = 100
  Progress.Text = "Импорт в Систему завершен"
  WriteReport "Импорт в Систему завершен"
  Progress.Stop
  
  ThisApplication.AddNotify sReport
  
  ' Установка курсора ожидания
  ThisApplication.Utility.WaitCursor = False  
End Sub

Private Sub WriteReport(str)
  ' Формирование шапки отчета
  If sReport=Empty Then
    sReport = "Дата загрузки: "&ThisApplication.CurrentTime&Chr(10)
    sReport = sReport&"Пользователь: "&ThisApplication.CurrentUser.Description&Chr(10)
    sReport = sReport&"Папка загрузки: "&sPath&Chr(10)
  End If
  sReport = sReport&ThisApplication.CurrentTime&":  "&str&Chr(10)
End Sub

Private Sub CreateExportTable(f)
  Dim vRow
  
  Progress.Position = Int(ImportedSize/(Size/100))
  Progress.Text = "Обработка папки: "&f.Name
  WriteReport "Обработка папки: "&f.Name
  
   
  ' Проверяем дублирование пути и дополняем словарь
  If Not dicParentPath.Exists(f.Path) Then
    If f.Path <> sPath Then
      dicParentPath.Add f.Path, f.ParentFolder.Path
    Else
      dicParentPath.Add f.Path, "Root"
    End If  
  End If
  
  ' Дбавление в таблицу папки
  Set vRow = vRows.Create
  vRow.Attributes("ATTR_FOLDER_IMPORT_TABLE_OBJECT_TYPE")="ПАПКА"
  vRow.Attributes("ATTR_FOLDER_IMPORT_TABLE_NAME")=f.Name
  vRow.Attributes("ATTR_FOLDER_IMPORT_TABLE_PATH")=f.Path

  For Each vFile In f.Files
    On Error Resume Next
    ' Проверяем дублирование пути и дополняем словарь
    dicParentPath.Add vFile.Path, vFile.ParentFolder.Path
    ' Дбавление в таблицу документа
    Set vRow = vRows.Create
    vRow.Attributes("ATTR_FOLDER_IMPORT_TABLE_OBJECT_TYPE")="Документ"
    vRow.Attributes("ATTR_FOLDER_IMPORT_TABLE_NAME")=vFile.Name
    vRow.Attributes("ATTR_FOLDER_IMPORT_TABLE_PATH")=vFile.Path
    ' Проверяем дублирование пути и дополняем словарь
    vRow.Attributes("ATTR_FOLDER_IMPORT_TABLE_SIZE")=vFile.Size
    ImportedSize = ImportedSize + vFile.Size
    On Error GoTo 0
  Next
    
  For Each vFolder In f.SubFolders
    Call CreateExportTable(vFolder)
  Next
End Sub

Private Sub CreateObjects(o_)
  Dim vRow
  Dim dicObj
  Dim oFolder,oDoc
  On Error Resume Next
  Set dicObj = CreateObject("Scripting.Dictionary")
  dicObj.Add "Root",o_
  For Each vRow In vRows
    If vRow.Attributes("ATTR_FOLDER_IMPORT_TABLE_OBJECT_TYPE")="ПАПКА" Then
      Set oFolder = CreateFolder(vRow,dicObj)
      dicObj.Add vRow.Attributes("ATTR_FOLDER_IMPORT_TABLE_PATH").Value,oFolder
    End If
    If vRow.Attributes("ATTR_FOLDER_IMPORT_TABLE_OBJECT_TYPE")="Документ" Then
      Set oDoc = CreateDoc(vRow,dicObj)
    End If
  Next
End Sub

Private Function CreateFolder(vRow_,dicObj_)
  Dim oNew,oParent
  Dim sPathParent
  Dim sFolderPath
  
  'On Error Resume Next
  Set CreateFolder = Nothing
  
  Progress.Position = Int(ImportedSize/(Size/100))
  Progress.Text = "Импорт папки: "&vRow_.Attributes("ATTR_FOLDER_IMPORT_TABLE_NAME").Value  
  WriteReport "Импорт папки: "&vRow_.Attributes("ATTR_FOLDER_IMPORT_TABLE_NAME").Value  
  
  sFolderPath = vRow_.Attributes("ATTR_FOLDER_IMPORT_TABLE_PATH").Value
  If Not dicParentPath.Exists(sFolderPath) Then 
    WriteReport "ОШИБКА создания папки "&vRow_.Attributes("ATTR_FOLDER_IMPORT_TABLE_NAME").Value  
    Exit Function 
  End If
  sPathParent = dicParentPath.Item(sFolderPath)
  If Not dicObj_.Exists(sPathParent) Then 
    WriteReport "ОШИБКА создания папки "&vRow_.Attributes("ATTR_FOLDER_IMPORT_TABLE_NAME").Value  
    Exit Function 
  End If  
  Set oParent = dicObj_.Item(sPathParent)
  Set oNew =  oParent.Objects.Create("OBJECT_FOLDER")
  If vRow_.Attributes("ATTR_FOLDER_IMPORT_TABLE_NAME")<> "" Then
    oNew.Attributes("ATTR_FOLDER_NAME") = vRow_.Attributes("ATTR_FOLDER_IMPORT_TABLE_NAME").Value
  End If
  
  WriteReport "Создан раздел в системе: "&oNew.Attributes("ATTR_FOLDER_NAME")
  Set CreateFolder = oNew
End Function


Private Function CreateDoc(vRow_,dicObj_)
  Dim oNew,oParent
  Dim sPathParent
  Dim sDocPath
  Dim vDocFile
  Dim sFileType
  
 '  On Error Resume Next
  Set CreateDoc = Nothing
  ' Путь родительской папки не указан

  ' Путь к файлу не указан
  If vRow_.Attributes("ATTR_FOLDER_IMPORT_TABLE_PATH") = "" Then
    WriteReport "ОШИБКА создания документа "&vRow_.Attributes("ATTR_FOLDER_IMPORT_TABLE_NAME").Value  
    Exit Function   
  End If  
  sDocPath = vRow_.Attributes("ATTR_FOLDER_IMPORT_TABLE_PATH").Value
  If Not dicParentPath.Exists(sDocPath) Then
    WriteReport "ОШИБКА создания документа "&vRow_.Attributes("ATTR_FOLDER_IMPORT_TABLE_NAME").Value  
    Exit Function   
  End If
  sPathParent = dicParentPath.Item(sDocPath)
  If Not dicObj_.Exists(sPathParent) Then
    WriteReport "ОШИБКА создания документа "&vRow_.Attributes("ATTR_FOLDER_IMPORT_TABLE_NAME").Value  
    Exit Function   
  End If  
  
  Set oParent = dicObj_.Item(sPathParent)
  If oParent Is Nothing Then
    WriteReport "ОШИБКА создания документа "&vRow_.Attributes("ATTR_FOLDER_IMPORT_TABLE_NAME").Value  
    Exit Function   
  End If
  
  Progress.Position = Int(ImportedSize/(Size/100))
  Progress.Text = "Импорт файла: "&sDocPath
  WriteReport "Импорт файла: "&sDocPath 
    
  Set oNew =  oParent.Objects.Create("OBJECT_DOCUMENT")
  If vRow_.Attributes("ATTR_FOLDER_IMPORT_TABLE_NAME")<> "" Then
    oNew.Attributes("ATTR_DOCUMENT_NAME") = vRow_.Attributes("ATTR_FOLDER_IMPORT_TABLE_NAME").Value
  End If
    
  If vRow_.Attributes("ATTR_FOLDER_IMPORT_TABLE_DOC_TYPE") <> "" Then
    oNew.Attributes("ATTR_DOCUMENT_TYPE").Classifier = vRow_.Attributes("ATTR_FOLDER_IMPORT_TABLE_DOC_TYPE").Classifier
  End If
  
  WriteReport "Создан документ в системе: "&oNew.Attributes("ATTR_DOCUMENT_NAME")
  
  sFileType = GetFileType(sDocPath,oNew)
  
  Set vDocFile = oNew.Files.Create(sFileType,sDocPath)
  vDocFile.CheckIn sDocPath
  If Err.Number <> 0 Then
    WriteReport "ОШИБКА импорта файла: "&sDocPath
  Else
    WriteReport "Импортирован файл: "&sDocPath
  End If
  
  ImportedSize = ImportedSize+vDocFile.Size
  Set CreateDoc = oNew
End Function


Private Function GetFileType(sDocPath_,o_)
  Dim sExtensions,sFileExt,arrTemp
  GetFileType = "FILE_ANY"
  arrTemp = Split(sDocPath_,".")
  If UBound(arrTemp)<= 0 Then Exit Function
  sFileExt = arrTemp(UBound(arrTemp))
  For Each vFileDef In o_.ObjectDef.FileDefs
    sExtensions = vFileDef.Extensions
    If InStr(sExtensions,sFileExt)>0 Then
      GetFileType = vFileDef.SysName
      Exit Function
    End If
  Next
End Function
