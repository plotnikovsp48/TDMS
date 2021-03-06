' Автор: Чернышов Д.С.
'
' Библиотека для работы с файлами
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2017

'====================================================================================================
'Окно просмотра и выборка файлов на основной форме объекта
'----------------------------------------------------------------------------------------------------
'Процедура добавления файла к ИО Акт, ИО Соглашение, ИО Документ, ИО Документ АН, ИО Журнал АН,
'ИО Документ закупки
'Obj:Object - Ссылка на объект, в который добавляется файл
Sub FileAdd(Obj,Form) '

  Obj.Permissions = SysAdminPermissions
  ClosePreviewOnForm(Form)
  
  mas = GetTypeFileArrayByObjType(Obj.ObjectDefName)
  if not isArray(mas) then exit sub
  ' фильтр по типам файлов
  check = true
  For each fDef In Obj.ObjectDef.FileDefs
    For i = 0 to Ubound(mas)
      If fDef.SysName = mas(i) And ThisApplication.FileDefs.Has(mas(i)) Then
        If check = true Then
          x=0
          ReDim arr(x)
          Check = False
        Else
          x = Ubound(arr) +1
          ReDim Preserve arr(x)
        End If
        Set arr(x) = fDef
      End If
    Next
  Next  
  
  ThisScript.SysAdminModeOn
  If Ubound(arr) > 0 Then
    Set SelDlg = ThisApplication.Dialogs.SelectDlg
    SelDlg.Caption = "Выбор типа файла:"
    SelDlg.SelectFrom = arr   
    RetVal = SelDlg.Show
    Selected = SelDlg.Objects
    
    If Ubound(Selected) < 0 or not RetVal Then Exit Sub
    fDefName = Selected(0).Sysname
  Else
    fDefName = arr(0).Sysname
  End If
  
  if thisApplication.FileDefs.Has(fDefName) = False Then
    msgbox "Тип файла " & fDefName & " не зарегистрирован в системе.",vbCritical,"Ошибка"
    Exit Sub
  End If
    
  Set SelFileDlg = Thisapplication.Dialogs.FileDlg
  Set FDef = Thisapplication.FileDefs(fDefName)
  If FDef is Nothing Then Exit Sub
  SelFileDlg.Filter = FDef.Description & "|" &  FDef.Extensions & "||"
  SelFileDlg.Filter = Replace(SelFileDlg.Filter, ",", ";")

  If SelFileDlg.Show Then
    FileNames = SelFileDlg.FileNames
'    If Ubound(SelFileDlg.FileNames) > 0 then
'      Msgbox "Можно приложить только ОДИН файл!", vbOKOnly+vbExclamation
'      Exit Sub
'    End If
    For i = 0 to Ubound(SelFileDlg.FileNames)
      Call LoadFiles(Obj,fDefName,FileNames(i),False)
    Next
    Obj.SaveChanges 0
  End If
  ThisScript.SysAdminModeOff
End Sub

Function GetTypeFileArrayByObjType(oDefName)
  Select Case oDefName
    Case "OBJECT_CONTRACT_COMPL_REPORT","OBJECT_CONTRACT","OBJECT_AGREEMENT"
      List = "FILE_CONTRACT_DOC,FILE_KD_ANNEX"
    Case "OBJECT_DOCUMENT","OBJECT_PURCHASE_DOC","OBJECT_DOCUMENT_AN","OBJECT_LIST_AN"
      List = "FILE_DOC_DOC,FILE_ANY"
    Case "OBJECT_T_TASK"
      List = "FILE_T_TEMPLATE,FILE_KD_ANNEX" ',
    Case "OBJECT_DRAWING"
      List = "FILE_AUTOCAD_DWG,FILE_SHORTCUT"
    Case "OBJECT_DOC_DEV"
      List = "FILE_DOC_DOC,FILE_DOC_XLS,FILE_ANY"
    Case "OBJECT_INVOICE"
      List = "FILE_TRANSFER_DOCUMENT"
    Case Else
      List = "FILE_DOC_DOC,FILE_KD_ANNEX"
  End Select
  
'  set settings = thisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB","GetSettingsByObjS", thisObject, true)
'  if not settings is nothing then 
'    AttrName = "ATTR_KD_FILE_LIST_ARR"
'    str =  settings.Attributes(AttrName).value
'    if str > "" then  
'     strArr = split(str,";")
'     if UBound(strArr) >0 then 
'        on error resume next
'        GetTypeFileArray = ThisApplication.ExecuteScript(strArr(0), strArr(1), thisObject)
'        exit function
'        Err.Clear
'        on error GoTo 0
'     end if 
'    end if
'  end if
  GetTypeFileArrayByObjType = Split(List,",")
end function
'====================================================================================================
'Окно просмотра и выборка файлов на основной форме объекта
'----------------------------------------------------------------------------------------------------
'Процедура загрузки файла
'Obj:Object - Ссылка на текущий объект
'FileDef:String - Системное имя типа файла
'FName:String - Путь и имя файла
'Silent:Boolean - Флаг выполнения без запросов
Sub LoadFiles(Obj,FileDef,FName,Silent)
  ThisScript.SysAdminModeOn
  FShortName = Right(FName, Len(FName) - InStrRev(FName, "\"))
  isNeedToLoad = true
  If Obj.Files.Has(FShortName) Then 
    Set NewFile = Obj.Files(FShortName)
    If NewFile.FileDefName <> "FILE_E-THE_ORIGINAL" Then
      If Silent = False Then
        Key = Msgbox("Файл """ & FShortName & """ уже загружен в документ """ & Obj.Description _
          & """." & chr(10) & "Перезаписать ?", vbExclamation+vbYesNo)
        If Key = vbNo Then 
          isNeedToLoad = false
        End If
      End if   
    Else
      msgbox "Файл """ & FShortName & """ не может быть загружен, т.к. используется для просмотра документа. Воспользуйтесь командой ""Добавить скан"".",_
                      vbExclamation,"Загрузить файл с диска"
      isNeedToLoad = false
    End If
  End If 
  
  ThisApplication.Utility.WaitCursor = True
  if isNeedToLoad then 
    Call LoadFile(Obj,FileDef,FName)
  end if
  
  Select case FileDef
    'Файл в PDF
    Case "FILE_E-THE_ORIGINAL"
      If Silent = False and not Obj.Files.Main is Nothing Then
        Key = Msgbox("Электронный оригинал уже загружен в документ """ & Obj.Description _
          & """." & chr(10) & "Перезаписать ?", vbExclamation+vbYesNo)
        If Key = vbNo Then Exit Sub
      End if 
      Call LoadFile(Obj,FileDef,FName)
  End Select
  ThisApplication.Utility.WaitCursor = False
End sub

'====================================================================================================
'Окно просмотра и выборка файлов на основной форме объекта
'----------------------------------------------------------------------------------------------------
'Процедура добавления файла к объекту
'Obj:Object - Ссылка на текущий объект
'FileDef:String - Системное имя типа файла
'FName:String - Путь и имя файла
Sub LoadFile(Obj,FileDef,Fname)
  FShortName = Right(FName, Len(FName) - InStrRev(FName, "\"))
  If Obj.Files.Has(FShortName) Then
    Obj.Files.Remove Obj.Files.Item(FShortName)
    Obj.SaveChanges
  End If
  On Error Resume Next
  Set NewFile = Obj.Files.Create(FileDef)
  NewFile.CheckIn Fname
  'Если загрузили PDF
  If FileDef = "FILE_E-THE_ORIGINAL" or _
  FileDef = "FILE_DOC_PDF" Then
    PDFname = FShortName
    If NewFile.FileName <> PDFname Then
      If Obj.Files.Has(PDFname) Then
        Obj.Files.Remove Obj.Files.Item(PDFname)
        Obj.SaveChanges
      End If
      NewFile.FileName = PDFname
    End If
    Obj.Files.Main = NewFile
  End If
  On Error GoTo 0
End Sub

'====================================================================================================
'Окно просмотра и выборка файлов на основной форме объекта
'----------------------------------------------------------------------------------------------------
'Процедура заполнения словаря формы выделенным файлом
'Form:Object - Ссылка на текущую форму
'iItem:Float - Номер выделенного элемента
'Action:Float - Номер действия
Sub QueryFileSelect(Form,iItem,Action)
  ThisScript.SysAdminModeOn
  Set Dict = Form.Dictionary
  If action = 2 Then
    Dict.Item("SelectedFile") = iItem
  End If
  ThisScript.SysAdminModeOff
End Sub

''====================================================================================================
''Окно просмотра и выборка файлов на основной форме объекта
''----------------------------------------------------------------------------------------------------
''Функция создания PDF файла из DOC
''Obj:Object - Ссылка на текущий объект
''FName:String - Путь и имя файла
''Возвращает строку - Путь и имя файла PDF
'Function CreatePDF(Obj,FileName)
'  CreatePDF = ""
'  Set Fso = CreateObject("Scripting.FileSystemObject")
'  Set Wrd = CreateObject("Word.Application")
'  SysID = Obj.GUID
'  PDFpath = ThisApplication.WorkFolder & "\"
'  PDFname = "scan" & sysID
'  
'  'WORD сохраняет документ в PDF
'  Wrd.Documents.Open (FileName)
'  Wrd.visible = False
'  wdExportFormatPDF = 17
'  Wrd.ActiveDocument.ExportAsFixedFormat PDFpath&PDFname , wdExportFormatPDF, False
'  CreatePDF = PDFpath & PDFname & ".pdf"

'  Wrd.ActiveDocument.Close '(Wrd.WdSaveOptions.wdDoNotSaveChanges)
'  Wrd.Quit   
'  Set Wrd = Nothing
'  Set FSO = Nothing
'End Function

Function CreatePDF(Obj,FileName,cForm)
ThisScript.SysAdminModeOn
  CreatePDF = ""
  dim extName'fso,DocumentDestPath
  extName = ThisApplication.ExecuteScript("CMD_KD_FILE_LIB","getFileExt",FileName) 'getFileExt(FileName)
  select case extName
    case "doc","docx","docm" CreatePDF = CreatePDFFromWordFile(Obj,FileName,cForm)
    case "xls","xlsx","xlsm" CreatePDF = CreatePDFFromExcelFile(Obj,FileName,cForm)'PlotnikovSP Files
  end select
End Function
'====================================================================================================
''Окно просмотра и выборка файлов на основной форме объекта
''----------------------------------------------------------------------------------------------------
''Функция создания PDF файла из Excel
''Obj:Object - Ссылка на текущий объект
''FName:String - Путь и имя файла
''Возвращает строку - Путь и имя файла PDF
Sub CreatePDFFromExcelFile(FileName,Obj,cForm)'PlotnikovSP
  Set Fso = CreateObject("Scripting.FileSystemObject")
  on error resume next
  err.Clear
  Set oExcel = CreateObject("Excel.Application")
  If err.Number <> 0 Then 
    txt = "Произошла ошибка при Excel" - err.Description'PlotnikovSP исправил Word -> Excel
    txt = "Пожалуйста, сообщите о ней разработчикам. " 
    msgbox txt, VbCritical, "Ошибка при Excel"'PlotnikovSP исправил Word -> Excel
    on error goto 0
    Err.Raise 6
    Err.clear
    Exit Sub
  End If
  on error goto 0
  

  
  if obj.Attributes.has("ATTR_KD_IDNUMBER") then 
    sysID = obj.Attributes("ATTR_KD_IDNUMBER").Value
  else
    if obj.Attributes.has("ATTR_KD_NUM") then 
      sysID = obj.Attributes("ATTR_KD_NUM").Value
    end if
  end if
  if sysID = "" then  sysID = "0"

  PDFpath = ThisApplication.WorkFolder & "\" & sysID
  'Если папка для хранения файлов не существует, создаем ее
  if not FSO.FolderExists(PDFpath) then
    Call ThisApplication.ExecuteScript("CMD_KD_FILE_LIB","CreateForldersHierachy",PDFpath)
  end if
  
  fName = fso.GetFileName(FileName)
  foName = ThisApplication.ExecuteScript("CMD_KD_FILE_LIB","getFileName",fname)
  pdfName = foName & "###"
  
  
  on error resume next
  copyFile = PDFpath & "\" & fName 
    
  'Если папка для хранения файлов не существует, создаем ее
  if not FSO.FileExists(FileName) then
    Obj.files(fName).checkout FileName
  end if
  
  call fso.CopyFile(FileName, copyFile, true)
  if err.Number <> 0 then 
    msgbox err.Description, vbCritical, "Ошибка копировани файла для создания pdf"
  else
    oExcel.Workbooks.Open copyFile, false'Изменение на необновление связей 'PlotnikovSP
    
   ' set wqweq = oExcel.Sheets
    if err.Number = 0 then 
'      for each i in oExcel.Worksheets
''''        i.Select False
'        i.Hyperlinks.Delete'Удаление гиперссылок
'      next
'        oExcel.visible = False
      
      oExcel.ActiveWorkbook.ExportAsFixedFormat 0, PDFpath & "\" & PDFname & ".pdf", 0, 1, 0,,,0'PlotnikovSP
    end if
    if err.Number <> 0 then _
      msgbox err.Description, vbCritical, "Ошибка преобразования файла в pdf"
  end if
  
  oExcel.Workbooks.Close 'wdDoNotSaveChanges = 0 'oExcel.WdSaveOptions.wdDoNotSaveChanges
  oExcel.Quit   
  Set oExcel = Nothing
  
  if err.Number <> 0 then   
    err.Clear
    on error GoTo 0  
    fso.DeleteFolder(PDFpath)
    exit Sub
  end if
  err.Clear
  on error GoTo 0
  
    if not cForm is nothing  then 
    if cForm.Controls.Has("PREVIEW1") then  ' закрываем просмотр скан файла
       cForm.Controls("PREVIEW1").Value = "1"
       cForm.Refresh()
    end if   
  end if
  
  call LoadFileByObj( "FILE_KD_EL_SCAN_DOC", PDFpath & "\" & PDFname & ".pdf", true,obj)
'  thisApplication.Utility.Sleep 500 'чтобы успел выложиться
  if not cForm is nothing  then 
    if cForm.Controls.Has("PREVIEW1") then  ' октрываем главный файл
       cForm.Controls("PREVIEW1").Value = thisObject.Files.Main
       cForm.Refresh()
    end if   
  end if

  on error resume next
  err.Clear
 ' fso.DeleteFolder(DocumentDestPath)

  if Err.Number =0 then 
    Set FSO = Nothing 
  else
    msgBox err.Description
  end if 

  err.Clear
  on error GoTo 0   
  
End Sub
''====================================================================================================
''Окно просмотра и выборка файлов на основной форме объекта
''----------------------------------------------------------------------------------------------------
''Функция создания PDF файла из DOC
''Obj:Object - Ссылка на текущий объект
''FName:String - Путь и имя файла
''Возвращает строку - Путь и имя файла PDF
Function CreatePDFFromWordFile(Obj,FileName,cForm)
  CreatePDFFromWordFile = ""
  Set Fso = CreateObject("Scripting.FileSystemObject")
  Set Wrd = CreateObject("Word.Application")
  
  if obj.Attributes.has("ATTR_KD_IDNUMBER") then 
    sysID = obj.Attributes("ATTR_KD_IDNUMBER").Value
  else
    if obj.Attributes.has("ATTR_KD_NUM") then 
      sysID = obj.Attributes("ATTR_KD_NUM").Value
    end if
  end if
  if sysID = "" then  sysID = "0"

  PDFpath = ThisApplication.WorkFolder & "\" & sysID
  'Если папка для хранения файлов не существует, создаем ее
  if not FSO.FolderExists(PDFpath) then
    Call ThisApplication.ExecuteScript("CMD_KD_FILE_LIB","CreateForldersHierachy",PDFpath)
  end if
  
  fName = fso.GetFileName(FileName)
  foName = ThisApplication.ExecuteScript("CMD_KD_FILE_LIB","getFileName",fname)
  pdfName = foName & "###"
  
  
  on error resume next
  copyFile = PDFpath & "\" & fName 
    
  'Если папка для хранения файлов не существует, создаем ее
  if not FSO.FileExists(FileName) then
    Obj.files(fName).checkout FileName
  end if
  
  call fso.CopyFile(FileName, copyFile, true)
  if err.Number <> 0 then 
    msgbox err.Description, vbCritical, "Ошибка копировани файла для создания pdf"
  else
    Wrd.Documents.Open (copyFile)
    if err.Number = 0 then 
      Wrd.visible = False
      wdExportFormatPDF = 17
      Wrd.ActiveDocument.ExportAsFixedFormat PDFpath & "\" & PDFname & ".pdf" , wdExportFormatPDF, False
    end if
    if err.Number <> 0 then _
      msgbox err.Description, vbCritical, "Ошибка преобразования файла в pdf"
  end if
  CreatePDFFromWordFile = PDFpath & "\" & PDFname & ".pdf"
  'Wrd.ActiveDocument.Save
  Wrd.ActiveDocument.Close -1 'wdDoNotSaveChanges = 0 'Wrd.WdSaveOptions.wdDoNotSaveChanges
  Wrd.Quit   
  Set Wrd = Nothing
  
  if err.Number <> 0 then 
    err.Clear
    on error GoTo 0  
    'fso.DeleteFolder(DocumentDestPath)
    exit Function
  end if
  err.Clear
  on error GoTo 0
  
    if not cForm is nothing  then 
    if cForm.Controls.Has("PREVIEW1") then  ' закрываем просмотр скан файла
       cForm.Controls("PREVIEW1").Value = "1"
       cForm.Refresh()
    end if   
  end if

'  thisApplication.Utility.Sleep 500 'чтобы успел выложиться
  if not cForm is nothing  then 
    if cForm.Controls.Has("PREVIEW1") then  ' октрываем главный файл
       cForm.Controls("PREVIEW1").Value = thisObject.Files.Main
       cForm.Refresh()
    end if   
  end if

  on error resume next
  err.Clear
 ' fso.DeleteFolder(DocumentDestPath)

  if Err.Number =0 then 
    Set FSO = Nothing 
  else
    msgBox err.Description
  end if 

  err.Clear
  on error GoTo 0   
  
End Function
'====================================================================================================
'Окно просмотра и выборка файлов на основной форме объекта
'----------------------------------------------------------------------------------------------------
'Процедура удаления файлов у ИО Акт, ИО Соглашение, ИО Документ, ИО Документ АН, ИО Журнал АН,
'ИО Документ закупки
'Obj:Object - Ссылка на объект, в котором удаляется файл
'Form:Object - Ссылка на текущую форму с выборкой
Sub FilesDel(Obj,Form)
  ThisScript.SysAdminModeOn
  Set Query = Form.Controls("QUERY_FILES_IN_DOC")
  Set s = Query.ActiveX
  If s.SelectedItem < 0 Then 
     msgbox "Не выбран файл!"
     Exit Sub 
  end if  
  
  Arr = Query.SelectedItems
  Count = UBound(Arr)
  'Если выделено несколько строк
  If Count > 0 and Query.Value.RowsCount = Query.ActiveX.Count Then
    Answer = MsgBox("Вы уверены, что хотите удалить файл?", vbQuestion + vbYesNo,"Удалить?")
    if Answer <> vbYes then exit sub
      For i = 0 to Count
        FileName = Query.Value.CellValue(Arr(i),0)
        Call FileDel(Obj,FileName)
      Next
  'Если выделена одна строка - глючит ActiveX
  Else
    Set Dict = Form.Dictionary
    If Dict.Exists("SelectedFile") Then
      sRow = Dict.Item("SelectedFile")
      If sRow <> -1 Then
        Answer = MsgBox("Вы уверены, что хотите удалить файл?", vbQuestion + vbYesNo,"Удалить?")
        if Answer <> vbYes then exit sub
        FileName = Query.Value.CellValue(sRow,0)
        Call FileDel(Obj,FileName)
      End If
    End If
  End If
  
  Obj.SaveChanges 0
  ThisScript.SysAdminModeOff
End Sub


Sub DelFilesFromDoc()
  dim s,iSel,File
  Thisscript.SysAdminModeOn
  Set s = thisForm.Controls("QUERY_KD_FILES_IN_DOC").ActiveX
  If s.SelectedItem < 0 Then 
     msgbox "Не выбран файл!"
     Exit Sub 
  end if  
  
  Answer = MsgBox("Вы уверены, что хотите удалить файл?", vbQuestion + vbYesNo,"Удалить?")
  if Answer <> vbYes then exit sub

  ClosePreview()
  
  for i = 0 to s.Count-1 ' для всех выделенных файлов
      if s.IsItemSelected(i) then
        set delFile = s.ItemObject(i) 'Удаляемый файл
        if thisObject.StatusName = "STATUS_KD_AGREEMENT" and IsAprover(thisApplication.CurrentUser, thisObject) then ' для согласующих
' EV продумать как лучше сделать
'            def = delFile.FileDefName
'            if def <>"FILE_KD_ANNEX" then ' только приложения
'                msgBox "На стадии Согласование можно удалять только приложения!", vbCritical, "Удаление отклонено!"
'                exit sub
'            end if
            if  delFile.UploadUser.SysName <> thisApplication.CurrentUser.SysName then 'и только добавленне им самим
                msgBox "Невозможно удалить приложение " & delFile.FileName & _
                    ", т.к его добавить другой пользователь", vbCritical, "Удаление отклонено"
                exit sub
            end if
        end if 
        on error resume next    
        delFile.Erase
         If Err.Number<>0 Then 
            msgbox "Не удалось удалить файл " & delFile.FileName & ". Ошибка :" & err.Description ,vbCritical, "Ошибка удаления файла"
            Err.Clear
            exit sub
        end if  
      end if
  next  
  ThisObject.SaveChanges 0
End Sub  


'====================================================================================================
'Процедура удаления файла у ИО Акт, ИО Соглашение, ИО Документ, ИО Документ АН, ИО Журнал АН,
'ИО Документ закупки
'Obj:Object - Ссылка на объект, в котором удаляется файл
'FileName:String - Имя удаляемого файла
Sub FileDel(Obj,FileName)
  ThisScript.SysAdminModeOn
  If Obj.Files.Has(FileName) Then
    Call ClosePreviewOnForm(ThisForm)
    'Obj.Files.Remove Obj.Files.Item(FileName)
    on error resume next
    Obj.Files(Obj.Files.Item(FileName)).Erase '.Remove Obj.Files.Item(FileName)
    If Err.Number<>0 Then 
            msgbox "Не удалось удалить файл " & FileName & ". Ошибка :" & err.Description ,vbCritical, "Ошибка удаления файла"
            Err.Clear
            exit sub
    end if  
  End If
End Sub

'====================================================================================================
'Процедура выгрузки файлов
'Obj:Object - Ссылка на текущий объект
'sType:Integer - Номер типа действия (1 - диалог выбора файлов, 2 - диалог выбора типа файлов)
Sub FilesUnload(Obj,sType)
  ThisScript.SysAdminModeOn
  Set SelDlg = ThisApplication.Dialogs.SelectDlg
  FilesNames = ""
  FileDefName = ""
  
  'Диалог выбора файлов
  If sType = 1 Then
    SelDlg.Caption = "Выбор файлов:"
    SelDlg.SelectFrom = Obj.Files
    If SelDlg.Show Then
      If SelDlg.Objects.Count <> 0 Then
        For Each File in SelDlg.Objects
          FilesNames = FilesNames & ";" & File.FileName
        Next
      Else
        Msgbox "Файлы не выбраны", vbExclamation
      Exit Sub
      End If
    End If
  
  'Диалог выбора типа файлов
  ElseIf sType = 2 Then
    SelDlg.Caption = "Выбор типа файла:"
    Set fDefs = Obj.ObjectDef.FileDefs
    For Each fDef in fDefs
      fDefName = fDef.SysName
      Check = False
      For Each File in Obj.Files
        If File.FileDefName = fDefName Then
          Check = True
          Exit For
        End If
      Next
      If Check = False Then fDefs.Remove fDef
    Next
    
       
    SelDlg.SelectFrom = fDefs
    
    RetVal = SelDlg.Show
    Set SelectedArray = SelDlg.Objects
    If SelectedArray.count = 0 or not RetVal Then Exit Sub
    FileDefName = SelectedArray.Item(0).Sysname
    'Проверка на наличие файлов выбранного типа
    Check = False
    For Each File in Obj.Files
      If File.FileDefName = FileDefName Then
        Check = True
        Exit For
      End If
    Next
    If Check = False Then
      Msgbox "Нет объектов выбранного типа", vbExclamation
      Exit Sub
    End If
  End If
  
  'Запрос пути выгрузки
  Path = GetFolder
  If Path = "" or Left(Path,2) = "::" Then
    Msgbox "Не выбрана папка для выгрузки файлов.", vbExclamation
    Exit Sub
  End If
  
  'Выгрузка файлов в папку
  Count = 0
  For Each File in Obj.Files
    If File.FileDefName = FileDefName or InStr(FilesNames,File.FileName) <> 0 Then
      FileName = Path & "\" & File.FileName
      File.CheckOut FileName
      Count = Count + 1
    End If
  Next
  If Count <> 0 Then
    Msgbox "В папку """ & Path & """" & chr(10) & "выгружено " & Count & " файлов.",vbInformation
  End If
  
  ThisScript.SysAdminModeOff
End Sub

'====================================================================================================
'Функция предоставляет диалог выбора папки
'GetFolder:String - Полный путь к выбранной папке
Private Function GetFolder()
  GetFolder = ""
  On Error Resume Next
  Set objShellApp = CreateObject("Shell.Application")
  Set objFolder = objShellApp.BrowseForFolder(0, "Выберите папку для выгрузки файлов", 0)
  If Err.Number <> 0 Then
    MsgBox "Папка не выбрана!", vbInformation
  Else
    GetFolder = objFolder.Self.Path
  End If
End Function

'====================================================================================================
'Функция для замены недопустимых символов в Windows
'Str:Sring - Строка для изменений
Function CharsChange(Str,replaceStr)
  CharsChange = Str
  List = "chr(42),chr(124),chr(92),chr(47),chr(58),chr(60),chr(62),chr(63)"
  ascii = "chr(" & ASC(replaceStr) & ")"
  If InStr(List,ascii) > 0  Then replaceStr = " "
    
  Str = Replace(Str,chr(42),replaceStr) '*
  Str = Replace(Str,chr(124),replaceStr) '|
  Str = Replace(Str,chr(92),replaceStr) '\
  Str = Replace(Str,chr(47),replaceStr) '/
  Str = Replace(Str,chr(58),replaceStr) ':
  Str = Replace(Str,chr(34),"") '"
  Str = Replace(Str,chr(60),replaceStr) '<
  Str = Replace(Str,chr(62),replaceStr) '>
  Str = Replace(Str,chr(63),replaceStr) '?
  CharsChange = Str
End Function



''========================================================================================
'' Добавляет файлы из шаблонов, связанных с объектом
''----------------------------------------------------------------------------------------
'' Obj: TDMSObject - объект, к которому прикладывается файл
''========================================================================================
Sub AddFromTemplate(Obj)
  on error resume next  
  Obj.Permissions = SysAdminPermissions      
  thisApplication.Utility.AddFilesFromTemplate Obj
  Obj.SaveChanges 0
End Sub



'========================================================================================
' Открыть для объекта окно диалога "Добавить файлы с диска"
'----------------------------------------------------------------------------------------
' Obj: TDMSObject - объект, к которому прикладывается файл
'========================================================================================

Sub addFileFromDiskForObject(Obj)
  thisscript.SysAdminModeOn
  on error resume next  
  Obj.Permissions = SysAdminPermissions      
  thisApplication.Utility.AddFilesFromDisk Obj  
  Obj.SaveChanges 0
  thisscript.SysAdminModeOff  
end sub

function GetFileByType(Obj,fType)
  set GetFileByType = nothing
  Set FColByDef = Obj.Files.FilesByDef(ThisApplication.FileDefs(fType))
  if FColByDef.Count>0 Then _
    set GetFileByType = FColByDef(0)
end function

sub ShowFile(iItem)
    
    If ThisForm.Controls.Has("PREVIEW1") Then
      ThisForm.Controls("PREVIEW1").Value = "1" ' чтобы наверняка перечитал
    Else
      Exit Sub
    End If
    ' чтобы не показывала при первом создании
    if ThisApplication.ExecuteScript("CMD_KD_GLOBAL_VAR_LIB","IsExistsGlobalVarrible","ShowFile") then  
      RemoveGlobalVarrible("ShowFile")
      exit sub
    end if
    
    if iItem < 0 then exit sub
    
    Set s = thisForm.Controls("QUERY_FILES_IN_DOC").ActiveX
    if s.Count = 0 then exit sub

    thisObject.SaveChanges(16384) 'т.к. могли поменять файл за это время
    ' Определяем тип файла, который должен быть у автогенерируемого PDF
    Select Case ThisObject.ObjectDefName
      Case "OBEJCT_CONTRACT","OBJECT_CONTRACT_COMPL_REPORT","OBJECT_AGREEMENT"
        fTypeSysName = "FILE_E-THE_ORIGINAL"
      Case Else
        fTypeSysName = "FILE_E-THE_ORIGINAL"
    End Select
    
    Set FileS = s.ItemObject(iItem) 
    ext = ThisApplication.ExecuteScript("CMD_KD_FILE_LIB","getFileExt",FileS.FileName) ' getFileExt(FileS.FileName)
      if not ThisApplication.ExecuteScript("CMD_KD_FILE_LIB","isCanHasPdf",FileS.FileName) and ext <> "pdf" then 
  '        msgbox "Невозможно просмотреть данный файл", vbInformation
          ThisForm.Controls("PREVIEW1").Value = FileS.FileName '"1"
  '        ThisForm.Refresh()
          exit sub
      end if

    if ext = "pdf" then 
      fileName = FileS.FileName
    else
      ' fileName = ThisApplication.ExecuteScript("CMD_KD_FILE_LIB","getFileName",FileS.FileName) & ".pdf" 
      fileName = ThisApplication.ExecuteScript("CMD_KD_FILE_LIB","getFileName",FileS.FileName) & "###.pdf"
      if not thisObject.Files.Has(fileName) then 
        ' добавить проверку на существование файла и вопрос о создании
        ans = msgbox ("Отображение еще не сформировано. Хотите создать изображение файла?", _
            vbQuestion + vbYesNo,"Создать изображение?")
        if ans <> vbYes then exit sub              
       'call ThisApplication.ExecuteScript("CMD_KD_FILE_LIB","CreatePDFFromFile",FileS.WorkFileName, thisObject, nothing)
        FName =  CreatePDF( thisObject, FileS.WorkFileName, nothing)
        If FName <> "" Then Call LoadFile(thisObject,fTypeSysName,FName)
        thisObject.SaveChanges 16384
      end if
      ' добавить проверку на существование файла и вопрос о создании
    end if
      ThisForm.Controls("PREVIEW1").Value = fileName
'    ThisForm.Refresh()
end sub

''========================================================================================
'' Добавляет файл из основного шаблона объекта. Основной шаблон оперделяется типом объекта
''----------------------------------------------------------------------------------------
'' Obj: TDMSObject - объект, к которому прикладывается файл
''========================================================================================
Sub AddFileFromTemplate(Obj)
  ThisScript.SysAdminModeOn
  Obj.permissions = Sysadminpermissions
  ' Проверяем, есть ли шаблон
  if not thisApplication.FileDefs.Has("File_" & Obj.ObjectDefName) then 
    msgbox "Невозможно создать файл, т.к. не задан шаблон", vbCritical 
    exit Sub
  end if
  
  FliDefName = GetDefaultFileDef(Obj)
  
  ' Определяем наименование файла шаблона
  fTemplName = GetTemplateName(Obj)
  
  if not thisApplication.FileDefs.Has("File_" & Obj.ObjectDefName) then 
    msgbox "Невозможно создать файл, т.к. не задан шаблон", vbCritical 
    exit Sub
  end if
  
  If thisApplication.FileDefs("File_" & Obj.ObjectDefName).Templates.Count = 1 Then
    Set tmlFile = GetTemplateIndx(Obj,fTemplName)
    if tmlFile is nothing then 
      msgbox "Не удалось выбрать шаблон. Создать документ невозможно", vbExlamation, "Создать документ невозможно"
      exit Sub
    end if
    
'    If ind < 0 Then fTemplName = ThisApplication.FileDefs("File_" & Obj.ObjectDefName).Templates(0).FileName
  elseIf thisApplication.FileDefs("File_" & Obj.ObjectDefName).Templates.Count > 1 Then
'    Set tmlFile = GetTemplateIndx(Obj,fTemplName)
'    If ind < 0 Then 
      Set dlg = ThisApplication.Dialogs.SelectDlg
      dlg.SelectFrom = thisApplication.FileDefs("File_" & Obj.ObjectDefName).Templates
      dlg.Caption = "Выберите шаблон"
      retval = dlg.Show
      if not retval or dlg.Objects.count = 0 Then
        Exit Sub
      End If
      fTemplName = dlg.Objects(0).FileName
      Set tmlFile = dlg.Objects(0)
'      ind = GetTemplateIndx(Obj,fTemplName)
'    End If
  else
    msgbox "Шаблон для документа не задан"
    exit Sub
  end if    
'  ind = GetTemplateIndx(Obj,fTemplName)
  Set tmlFile = GetTemplateIndx(Obj,fTemplName)
  Ftype = Right(fTemplName, Len(fTemplName)-InStrRev(fTemplName, ".")+1)
  If Ftype = ".dwt" Then Ftype = ".dwg"
  fName = CharsChange(GetDefaultFileName(Obj),"_")

  if fName <> vbNullString then 
    fName = fName & Ftype
  else
    fName = Obj.ObjectDef.Description & Ftype
  end if
  
  If Obj.files.Has(fName) Then
       Answer = MsgBox("Файл " & fName & " уже приложен к документу. " & _
          "Вы уверены, что хотите заменить существующий файл?", vbQuestion + vbYesNo,"Заменить?")
     if Answer <> vbYes then exit Sub
     on error resume next
     
     Obj.files(fName).Erase
     If Err.Number<>0 Then 
        msgbox "Не удалось удалить файл " & delFile.FileName & ". Ошибка :" & err.Description ,vbCritical, "Ошибка удаления файла"
        Err.Clear
        exit Sub
     end if  
     on error goto 0
'     Obj.Update
     Obj.SaveChanges 0
  end if  
  
  
  Set file = GetFileByType(Obj,FliDefName)
  
  
  if not file is nothing then
     Answer = MsgBox("Оригинал документа уже приложен. " & _
          "Вы уверены, что хотите удалить существующий и создать новый?", vbQuestion + vbYesNo,"Удалить?")
     if Answer <> vbYes then exit Sub
     on error resume next
     file.Erase
     If Err.Number<>0 Then 
        msgbox "Не удалось удалить файл " & delFile.FileName & ". Ошибка :" & err.Description ,vbCritical, "Ошибка удаления файла"
        Err.Clear
        exit Sub
     end if  
     on error goto 0
     '     Obj.Update
     Obj.SaveChanges 0
  end if  
  '==========================
'  tmlFile = 
  set newFile = ThisObject.Files.Create(FliDefName)
    dirName = tmlFile.WorkFileName
    tmlFile.CheckOut(dirName & "\" & fTemplName) ' выгружаем, загружаем, чтобы была новая дата и пользователь
    NewFile.CheckIn dirName & "\" & fTemplName
    Newfile.FileName = fName
    
    '=======''''''''
'  set newFile = Obj.Files.AddCopy(thisApplication.FileDefs("File_" & Obj.ObjectDefName).Templates(ind), fName)
'  newfile.FileDef =   thisApplication.FileDefs(FliDefName)
    
'  thisObject.Files.AddCopy thisApplication.FileDefs(FliDefName).Templates(fTemplName), fName
  Obj.SaveChanges(16384)
'  Obj.SaveChanges(0)

    'ShowFileName()
'    Word_Check_Out() ' открываем ворд
 '   createWord = true
    
  'ThisForm.Refresh
  'showfile(0)
  ThisScript.SysAdminModeOff
End Sub

'загружаем выбранный файл, без вопросов если silent
'=============================================
sub LoadFileByObj( FileDef, FileName, silent, obj)
  thisscript.SysAdminModeOn
  dim FSO,isNeedToLoad,FileNm,Files,msg,NewFile
  Set FSO = CreateObject("Scripting.FileSystemObject") 
  isNeedToLoad = true
  FileNm = FSO.GetFileName(FileName)
  Set Files = obj.Files
  if Files.Has(FileNm) then 
    Set NewFile = obj.Files(FileNm)
    if silent then ' если без вопросов, то перетираем всегда -  не удаляем т.к. нечего будет загружать
'      Files.Remove Files.Item(FileNm)
'      ThisObject.Update
    else
        msg = msgbox("Файл [" & FileNm & "] уже загружен в документ "&obj.Description _
            &", перезаписать ?", vbExclamation + vbYesNo)
        If msg = vbNo Then 
           isNeedToLoad = false
'        Else
'           Set NewFile = ThisObject.Files(FileNm)
           'Files.Remove Files.Item(FileNm) 
           'ThisObject.Update
        End if 
     end if 
  else 
    Set NewFile = obj.Files.Create(FileDef)       
  end if      
  if isNeedToLoad then 
'    thisObject.Permissions = sysAdminPermissions
'    thisObject.Files(NewFile).CheckIn FileName
    NewFile.CheckIn FileName
'    select case FileDef
'      case "FILE_KD_SCAN_DOC","FILE_E-THE_ORIGINAL"  obj.Files.Main = NewFile 'если скан документ
'      case "FILE_KD_WORD" CreatePDF (FileName)
'      case "FILE_KD_RESOLUTION" IsNeedCreateOrder(obj)'создание поручения по резолюции
'    end select    
  end if
end sub

sub ClosePreviewOnForm(Form)
  if Form.Controls.Has("PREVIEW1") then  ' закрываем просмотр скан файла
     Form.Controls("PREVIEW1").Value = "1"
     Form.Refresh()
  end if
end sub

' Возвращает имя файла из наименования
' fName: Имя файла в формате <файл>.<расширение>
Function getFileShortName(fName)
  getFileShortName=""
  pos = InStrRev(fName,".")
  If pos > 0 Then 
    getFileShortName = Left(fName, pos-1)
  End If
End Function

' Возвращает расширение файла из наименования
' fName: Имя файла в формате <файл>.<расширение>
Function getFileExtension(fName)
  getFileExtension=""
  pos = InStrRev(fName,".")
  If pos > 0 Then 
    getFileExtension = Right(fName, len(fName) - pos)
  End If
End Function

sub ShowSysID()
  thisForm.Controls("STSYSID").Value = "ID "& thisObject.Attributes("ATTR_KD_IDNUMBER").value
end sub

'=============================================
Sub UnloadFilesFromDoc (Obj,Form)
   dim FSO,objShell,Sheet,Sels,objFolder,path,File
   ThisScript.SysAdminModeOn
   Set FSO = CreateObject("Scripting.FileSystemObject") 
   Set objShell = CreateObject("Shell.Application")

   Set Sheet = Form.Controls("QUERY_FILES_IN_DOC").Value
   If Sheet.RowsCount = 0 Then
      msgbox("Нет файлов документа для выгрузки!")
      Exit sub
   End if
   Sels = Form.Controls("QUERY_FILES_IN_DOC").SelectedItems
   If Ubound(Sels,1)<0 Then 'если не выбран файл, выгружаем все
      Redim Sels(Sheet.RowsCount - 1)
      For i = 0 to Sheet.RowsCount - 1
         Sels(i) = i
      Next
   End if   
   
   Set objFolder = objShell.BrowseForFolder (0, "Выберите папку:", 0)

   If Not objFolder Is Nothing Then
      if Obj.Attributes.Has("ATTR_KD_IDNUMBER") then
        num  = Obj.Attributes("ATTR_KD_IDNUMBER").Value
      else
        num =  Obj.Attributes("ATTR_KD_NUM").Value
      end if
      path = ObjFolder.Self.Path '& "\" & num
  
      If not FSO.FolderExists(Path) then FSO.CreateFolder( Path )
      For each Sel in Sels
         Set File = Sheet.RowValue(Sel)
         File.CheckOut Path & "\" & File.FileName 
      Next
      
      objShell.Explore(Path)
   End if 
End Sub  

' Возвращает наименованеи файла по умолчанию
Function GetDefaultFileName(Obj)
  GetDefaultFileName = vbNullString
  If Obj Is Nothing Then Exit Function
  Select Case Obj.ObjectDefName
    Case "OBJECT_T_TASK"
      GetDefaultFileName = ThisApplication.ExecuteScript("OBJECT_T_TASK","GetTaskFileName",Obj)
    Case "OBJECT_DRAWING"
      If Obj.Attributes.Has("ATTR_DOC_CODE") Then
        If Obj.Attributes("ATTR_DOC_CODE").Empty = False Then
          GetDefaultFileName = Obj.Attributes("ATTR_DOC_CODE")
        End If
      End If
    Case "OBJECT_DOC_DEV"
      If Obj.Attributes.Has("ATTR_DOC_CODE") Then
        If Obj.Attributes("ATTR_DOC_CODE").Empty = False Then
          GetDefaultFileName = Obj.Attributes("ATTR_DOC_CODE")
        End If
      End If
    Case "OBJECT_DOCUMENT"
      If Obj.Attributes.Has("ATTR_DOCUMENT_NAME") Then
        If Obj.Attributes("ATTR_DOCUMENT_NAME").Empty = False Then
          GetDefaultFileName = Obj.Attributes("ATTR_DOCUMENT_NAME")
        End If
      End If  
    Case "OBJECT_CONTRACT_COMPL_REPORT"
      GetDefaultFileName = "Акт"
    Case "OBJECT_CONTRACT"
      GetDefaultFileName = "Договор"
    Case "OBJECT_AGREEMENT"
      GetDefaultFileName = "Соглашение"
    Case "OBJECT_INVOICE"
      GetDefaultFileName = "Передаточный документ"
    Case Else
      GetDefaultFileName = Obj.ObjectDef.Description
  End Select  
End Function
  

Function GetDefaultFileDef(Obj)
  Select Case Obj.ObjectDefName
    Case "OBJECT_CONTRACT_COMPL_REPORT"
      GetDefaultFileDef = "FILE_CONTRACT_DOC"
    Case "OBJECT_CONTRACT"
      GetDefaultFileDef = "FILE_CONTRACT_DOC"
    Case "OBJECT_AGREEMENT"
      GetDefaultFileDef = "FILE_CONTRACT_DOC"
    Case "OBJECT_INVOICE"
      GetDefaultFileDef = "FILE_TRANSFER_DOCUMENT"
    Case "OBJECT_DRAWING"
      GetDefaultFileDef = "FILE_AUTOCAD_DWG"
    Case "OBJECT_T_TASK"
      GetDefaultFileDef = "FILE_T_TEMPLATE"
    Case "OBJECT_DOC_DEV"
      GetDefaultFileDef = "FILE_DOC_DOC"
    Case Else 
      GetDefaultFileDef = "FILE_ANY"
  End Select
End Function
  
' Определяем шаблон по умолчанию для разных типов объектов 
Function GetTemplateName(Obj)
  GetTemplateName = vbNullString
  If Obj Is Nothing Then Exit Function
  Select Case Obj.ObjectDefName
    Case "OBJECT_T_TASK"
      If Obj.Attributes.Has("ATTR_T_TASK_TYPE") Then
        If Obj.Attributes("ATTR_T_TASK_TYPE").Empty = False Then
          If Not Obj.Attributes("ATTR_T_TASK_TYPE").Classifier Is Nothing Then
            txt = Obj.Attributes("ATTR_T_TASK_TYPE").Classifier.Code &".docx"
          End If
        End If
      End If
      If ThisApplication.FileDefs("FILE_" & Obj.ObjectDefName).Templates.Has(txt) = False Then
        GetTemplateName = "default.docx"
      Else 
        GetTemplateName = txt
      End If
    Case "OBJECT_CONTRACT_COMPL_REPORT"
      GetTemplateName = "Акт.docx"
    Case "OBJECT_CONTRACT"
      GetTemplateName = "Шаблон договора.docx"
    Case "OBJECT_AGREEMENT"
      GetTemplateName = "Соглашение.docx"
'    Case "OBJECT_INVOICE"
'      GetTemplateName = "Передаточный_документ_(шаблон).docx"
    Case "OBJECT_DRAWING"
      GetTemplateName = "ОЧ_Шаблон.dwt"
  End Select  
End Function

Function GetTemplateIndx(Obj,tFileName)
  Set GetTemplateIndx = Nothing
'  GetTemplateIndx = 0
  If tFileName = "" Then
    GetTemplateIndx = -1
    Exit Function
  End If
  set f = thisApplication.FileDefs("FILE_" & Obj.ObjectDefName).Templates(tFileName)
'      GetTemplateIndx = thisApplication.FileDefs("FILE_" & Obj.ObjectDefName).Templates.Index(f)
  Set GetTemplateIndx = f
End Function

Sub FileChkInProcessing(File, Object)

  Thisscript.SysAdminModeOn
  Object.Permissions = SysAdminPermissions
  dim FileDef
'  if IsExistsGlobalVarrible("FileTpRename") then call ReNameFiles(file,Object)
  FileDef =  File.FileDefName
  'call AddToFileList(file,object)   ' Пока нет такой таблицы
    select case FileDef
      case "FILE_KD_SCAN_DOC","FILE_E-THE_ORIGINAL","FILE_DOC_PDF" Object.Files.Main = File 'если скан документ
      case "FILE_ANY","FILE_KD_ANNEX","FILE_AUTOCAD_DWG","FILE_DOC_DOC","FILE_DOC_XLS","FILE_T_TEMPLATE"
        call ThisApplication.ExecuteScript("OBJECT_KD_BASE_DOC","delElScan",file,Object)' call CreatePDFFromFile(File.WorkFileName, Object, nothing) ' .WorkFileName .FileName
        call ThisApplication.ExecuteScript("CMD_FILES_LIBRARY","deldwgsupportfiles",file,Object)        
    end select  
    call ThisApplication.ExecuteScript("CMD_FILES_LIBRARY","deldwgsupportfiles",file,Object)    
End Sub

sub deldwgsupportfiles(file, obj)
  obj.Permissions = SysAdminPermissions
'  thisScript.SysAdminModeOn
  fType = getFileExtension(File.FileName)  
  
  If fType = "dwl" or fType = "dwl2" Then
    Obj.files(file).Erase
  End If
  
  
'  pdfName = getFileName(File.FileName) & ".pdf"
'  if obj.Files.Has(pdfName) then 
'    on error resume next
'    obj.Files(pdfName).Erase
'    if err.Number<> 0 then 
'      err.Clear
'      thisApplication.AddNotify err.Description
'    else
'       Obj.SaveChanges 16384  
'    end if  
'  end if
'  pdfName = getFileName(File.WorkFileName) & ".pdf"

'  Set FSO = CreateObject("Scripting.FileSystemObject") 
'  if FSO.FileExists(pdfName) then _
'        FSO.DeleteFile pdfName, true 
'  if err.Number <> 0 then err.Clear
'  on error goto 0
end sub

