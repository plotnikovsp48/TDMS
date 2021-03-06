use CMD_KD_USER_PERMISSIONS
use CMD_KD_CURUSER_LIB

'use CMD_KD_ORDER_LIB

'Set FSO = CreateObject("Scripting.FileSystemObject") 
'Set objShell = CreateObject("Shell.Application")

'=============================================
Sub UnloadFilesFromDoc()
   dim FSO,objShell,Sheet,Sels,objFolder,path,File
   ThisScript.SysAdminModeOn
   Set FSO = CreateObject("Scripting.FileSystemObject")
   Set objShell = CreateObject("Shell.Application")

   Set Sheet = Thisform.Controls("QUERY_KD_FILES_IN_DOC").Value
   If Sheet.RowsCount = 0 Then
      msgbox("Нет файлов документа для выгрузки!")
      Exit sub
   End if
   
   Sels = ThisForm.Controls("QUERY_KD_FILES_IN_DOC").SelectedItems
   If Ubound(Sels,1)<0 Then 'если не выбран файл, выгружаем все
      Redim Sels(Sheet.RowsCount - 1)
      For i = 0 to Sheet.RowsCount - 1
         Sels(i) = i
      Next
   End if   
   
   Set objFolder = objShell.BrowseForFolder (0, "Выберите папку:", 0, 0)

   If Not objFolder Is Nothing Then
      if thisObject.Attributes.Has("ATTR_KD_IDNUMBER") then
        num  = thisObject.Attributes("ATTR_KD_IDNUMBER").Value
      else
        num =  thisObject.Attributes("ATTR_KD_NUM").Value
      end if
      
      forbiddenSymbols = Array("\","/",":","*","?","""","<",">","|")'PlotnikovSP
      predescription = thisObject.ObjectDef.Description & " - " & thisObject.Description'PlotnikovSP
      for each sym in forbiddenSymbols'PlotnikovSP
        predescription = Replace(predescription, sym, "_")'PlotnikovSP''''''
      next'PlotnikovSP
      
      path = ObjFolder.Self.Path & "\" & left(predescription, 100) '& num    'PlotnikovSP
      
  
      If not FSO.FolderExists(Path) then FSO.CreateFolder( Path )
      For each Sel in Sels
         Set File = Sheet.RowValue(Sel)
         File.CheckOut Path & "\" & File.FileName 
      Next
      
      objShell.Explore(Path)
   End if 
End Sub   

' спрашиваем у пользователя файл, который он хочет загрузить
'=============================================
Function LoadFileToDoc(FileDef)
  LoadFileToDoc = LoadFileToDocByObj(FileDef,thisObject)
end function

'=============================================
function LoadOneFile(FileDef, Obj, FilePath)
  ThisScript.SysAdminModeOn
  ClosePreview()
  call LoadFileByObj(FileDef, FilePath, false,Obj)
  Obj.SaveChanges 16384 
end function
' спрашиваем у пользователя файл, который он хочет загрузить
'=============================================
Function LoadFileToDocByObj(FileDef,Obj)'PlotnikovSP select
  dim SelFileDlg,FDef,FileNames
  ThisScript.SysAdminModeOn
  ClosePreview()
  
  Dim curdict: set curdict = ThisApplication.Dictionary("OLD_FILE_PATH_TO_LOAD_TO_TDMS")
  'curdict.RemoveAll
  
  Dim oldpath: oldpath = curdict("path")

  Set SelFileDlg = ThisApplication.Dialogs.FileDlg
  SelFileDlg.InitialDirectory = oldpath
  SelFileDlg.FileName = oldpath
  set FDef = thisApplication.FileDefs(FileDef)
  if FDef is nothing then exit function
  SelFileDlg.Filter = FDef.Description & "|" &  FDef.Extensions & "||"

  retVal = SelFileDlg.Show
  If retVal <> TRUE Then Exit Function
  FileNames = SelFileDlg.FileNames
  if Ubound(SelFileDlg.FileNames)>0 and FileDef <> "FILE_KD_ANNEX" then
    msgbox "Можно приложить только ОДИН файл!", vbOKOnly + vbExclamation
    exit Function
  end if
  
  Dim newpath: newpath = SelFileDlg.FileName
  
'  if Ubound(SelFileDlg.FileNames) = 0 then
'    newpath = SelFileDlg.FileName
'  end if
  
  if Ubound(SelFileDlg.FileNames) > 0 then
    Set FSO = CreateObject("Scripting.FileSystemObject")
   ' Set F = FSO.GetFile(Wscript.ScriptFullName)
    newpath = FSO.GetParentFolderName(newpath)
  end if
  curdict("path") = newpath
  ' msgbox newpath
   
  Dim Progress: Set Progress = ThisApplication.Dialogs.ProgressDlg
  Dim Str
  
  Progress.Start
  Progress.Position = 0
  Progress.Text = "Вступление..."
  
  Dim countOf: countOf = Ubound(SelFileDlg.FileNames)+1
  
   For i = 1 To 3
                Str = "Этап № " & i & "; процент выполнения " ' Выводим номер этапа
                Progress.SetLocalRanges ((i - 1) * 100 / 3), (i * 100 / 3) ' Установка локальных границ прогресса
                For q = 0 To 100
                        t = Timer + 0.02
                        Progress.Position = q ' Установка текущего процента выполнения
                        Progress.Text = Str & q & "%"
                        'Смоделировать задержку (0.02 секунды)
                        While Timer < t 
                        Wend
                Next
        Next
        

  
  for i = 0 to countOf-1
    Str = "Этап № " & i & "; процент выполнения " ' Выводим номер этапа
    Progress.SetLocalRanges (i * 100 / countOf), ((i+1) * 100 / countOf) ' Установка локальных границ прогресса
    Progress.Position = 0
    Progress.Text = Str & "0%"
    call LoadFileByObj(FileDef, FileNames(i), false, Obj)
    Progress.Position = 100
    Progress.Text = Str & "100%"
  next
  Progress.Stop
'  Obj.Update
  Obj.SaveChanges 16384 ' А.О. Заменил Update т.к. он вызывал события открытия формы 16384 = tdmSaveOptDontCallActions 
End Function

'загружаем выбранный файл, без вопросов если silent
'=============================================
sub LoadFile(FileDef, FileName, silent)
  call LoadFileByObj(FileDef, FileName, silent, thisObject)
end sub
'загружаем выбранный файл, без вопросов если silent
'=============================================
sub LoadFileByObj(FileDef, FileName, silent, obj)
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
        msg = msgbox("Файл [" & FileNm & "] уже загружен в документ " & obj.Description _
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
    If (FileDef = "FILE_KD_SCAN_DOC") Then
      set oldFile = GetFileByTypeByObj("FILE_KD_SCAN_DOC", Obj)
      if not oldFile is nothing then 
        resVal = vbYes
        if not silent then resVal = msgbox("Документ " & obj.Description & " уже содержит файл скан-файл. Перезаписать скан-файл?", _
              vbExclamation + vbYesNo, "Перезаписать скан-файл?") 
        if resVal = vbYes then 
          For each fFile in  Files
             If fFile.FileDefName = "FILE_KD_SCAN_DOC" Then 
                   fFile.Erase   
                   Obj.SaveChanges 16384
             End if   
          Next 
        else
          exit sub
        end if 
      End if
    end if
    If (FileDef = "FILE_KD_WORD") then 
      set oldFile = GetFileByTypeByObj("FILE_KD_WORD", Obj)
      if not oldFile is nothing then ' EV переименовываем стаpый
        if obj.StatusName <> "STATUS_KD_DRAFT" Then
          newFileName = ThisApplication.ExecuteScript("OBJECT_KD_BASE_DOC","GetNewUserFileName",oldFile)
          call RenameFileWithPdf(obj, oldFile, newFileName)
        else
          oldFile.erase
        end if
      end if  
    end if
    Set NewFile = obj.Files.Create(FileDef)       
  end if      
  if isNeedToLoad then 
    NewFile.CheckIn FileName
  end if
  If (FileDef = "FILE_KD_WORD") Then
    fName = GetDocFileName(Obj)
    if NewFile.FileName <> fName and not obj.Files.has(fName) then _
            call RenameFileWithPdf(obj, NewFile, fName)
  end if
end sub
'=============================================
function RenameFileWithPdf(obj, file, newName)
  RenameFileWithPdf = true
  thisScript.SysAdminModeOn
  If not Obj.Files.Has(newName) then 
    'Set CopyFileWithPdf = Obj.Files.AddCopy(file, file.FileName)
    oldDpfFileName = getFileName(file.FileName) & "###.pdf"
    if isCanHasPdf(File.FileName) then 
      if Obj.Files.Has(oldDpfFileName) then 
        set pdfFile = obj.Files(oldDpfFileName)
        newDpfFileName = getFileName(newName) & "###.pdf"
        if not obj.Files.has(newDpfFileName) then _
            pdfFile.FileName = newDpfFileName
      end if
    end if
    file.FileName = newName
    Obj.SaveChanges 16384
  End If
end function
'=================================
function GetDocFileName(Obj)
  fName = CheckFileName(Obj.Attributes("ATTR_KD_TOPIC").Value)
  if fName <> "" then 
    fName = fName & ".docx"
  else
    fName = Obj.ObjectDef.Description & ".docx"
  end if
  GetDocFileName = fName
end function
''=============================================
'function GetNewUserFileName(file)
'  GetNewUserFileName = ""
'  if inStr(File.FileName,"[_")>0 and inStr(File.FileName,"_]")>0 then 
'    call SetObjectGlobalVarrible("FileTpRename", file)
'  else
'    call RemoveGlobalVarrible("FileTpRename")
'  end if
'  GetNewUserFileName = CheckFileName(getFileName(File.FileName) & "[_" & CStr(file.UploadTime) & "_]" & "." & getFileExt(File.FileName))
'end function

'=============================================
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
        if CanDelFile(delFile.FileDef.Description) then 
          if thisObject.StatusName = "STATUS_KD_AGREEMENT" and IsAprover(GetCurUser(), thisObject) then ' для согласующих
  ' EV продумать как лучше сделать
  '            def = delFile.FileDefName
  '            if def <>"FILE_KD_ANNEX" then ' только приложения
  '                msgBox "На стадии Согласование можно удалять только приложения!", vbCritical, "Удаление отклонено!"
  '                exit sub
  '            end if
              if not IsInCurUsers(delFile.UploadUser) then 'и только добавленне им самим
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
        else
          msgbox "Невозможно удалить тип файла " & delFile.FileDef.Description & " в статусе " & thisObject.Status.Description, vbCritical, "Удаление отменено"
        end if
      end if
  next  
  ThisObject.Update
End Sub  

''=============================================
'sub DelFileByType(fileDef)
'  Set FColByDef = thisObject.Files.FilesByDef(fileDef)
'  if FColByDef.Count>0 Then 
'    thisObject.Files.Remove FColByDef(0)
'    thisObject.Update
'    filePath = FColByDef(0).WorkFileName
'    Set FSO = CreateObject("Scripting.FileSystemObject")
'    if FSO.FileExists(filePath) then 
'        FSO.DeleteFile filePath, true 
'    end if
'  end if  
'end sub

'=============================================
sub CreatePDF(FileName)
  dim fso,Wrd,DocumentDestPath,wdExportFormatPDF
  Set fso = CreateObject("Scripting.FileSystemObject")
  Set Wrd = CreateObject("Word.Application")

  DocumentDestPath = "c:\temp\tdms"
  sysID = thisObject.Attributes("ATTR_KD_IDNUMBER").Value
  
  'Если папка для хранения файлов не существует, создаем ее
  if not FSO.FolderExists(DocumentDestPath) then
    if not CreateForldersHierachy(DocumentDestPath) then exit sub
  end if
  
  Wrd.Documents.Open (FileName)
  wrd.visible = false'true
'  Wrd.ActiveDocument.Activate
'  Wrd.ActiveDocument.save
  wdExportFormatPDF = 17
  Wrd.ActiveDocument.ExportAsFixedFormat DocumentDestPath & "\scan" & sysID , wdExportFormatPDF, False  

  if err.Number<>0 then _
    msgbox err.Description
  on error GoTo 0  
  Wrd.ActiveDocument.Close
  Wrd.quit   
  Set Wrd = Nothing
  
  ClosePreview()' закрываем просмотр скан файла
  
  call LoadFile( "FILE_KD_EL_SCAN_DOC", DocumentDestPath & "\scan" & sysID & ".pdf", true)
  
  if thisForm.Controls.Has("PREVIEW1") then  ' октрываем главный файл
     ThisForm.Controls("PREVIEW1").Value = thisObject.Files.Main
     ThisForm.Refresh()
  end if   

  if Err.Number =0 then 
    Set FSO = Nothing  
   else
    msgBox err.Description
   end if 

end sub

'=============================================
sub ClosePreview()
  if IsEmpty(thisForm) then exit sub
  if thisForm.Controls.Has("PREVIEW1") then  ' закрываем просмотр скан файла
     ThisForm.Controls("PREVIEW1").Value = "1"
     ThisForm.Refresh()
  end if
end sub
'=============================================
sub CreatePDFFromFile(FileName, obj, cForm)
  dim extName'fso,DocumentDestPath
'  Set fso = CreateObject("Scripting.FileSystemObject")
'  fso.GetExtensionName(FileName)
  extName = getFileExt(FileName)
'  if InStr(FileName,".")>0 then 
'    nPart = Split(FileName,".")
'    extName = nPart(Ubound(nPart))
'  end if
  select case extName'PlotnikovSP Files
    case "doc","docx","docm" call CreatePDFFromWord(FileName, obj, cForm)
    case "xls","xlsx","xlsm" call thisApplication.ExecuteScript("CMD_FILES_LIBRARY", "CreatePDFFromExcelFile",FileName,Obj,cForm)
    'msgbox "В разработке"
  end select
end sub
'=============================================
function isCanHasPdf(fileName)
  isCanHasPdf = false
  FileList = ",doc,docx,docm,xls,xlsx,xlsm,"'PlotnikovSP Files
  ext = getFileExt(fileName)
  if ext ="" then exit function
  if InStr(FileList, "," & ext &",")>0 then isCanHasPdf = true
end function
'=============================================
sub CreatePDFFromWord(FileName, obj, cForm)
  dim fso,Wrd,DocumentDestPath,wdExportFormatPDF,fName,foName,sysID
  Set fso = CreateObject("Scripting.FileSystemObject")
  on error resume next
  err.Clear
    Set Wrd = CreateObject("Word.Application")
  if err.Number <> 0 then 
    txt = "Произошла ошибка при Word" - err.Description
    txt = "Пожалуйста, сообщите о ней разработчикам. " 
    msgbox txt, VbCritical, "Ощибка при Word"
    on error goto 0
    Err.Raise 6
    err.clear
    exit sub
  end if
  on error goto 0

  if obj.Attributes.has("ATTR_KD_IDNUMBER") then 
    sysID = obj.Attributes("ATTR_KD_IDNUMBER").Value
  else
    if obj.Attributes.has("ATTR_KD_NUM") then 
      sysID = obj.Attributes("ATTR_KD_NUM").Value
    end if
  end if
  
  if sysID = "" then  sysID = "0"
  DocumentDestPath = ThisApplication.WorkFolder & "\" & sysID
  
  'Если папка для хранения файлов не существует, создаем ее
  if not FSO.FolderExists(DocumentDestPath) then
    if not CreateForldersHierachy(DocumentDestPath) then exit sub
  end if
  fName = fso.GetFileName(FileName)
  foName = getFileName(fname) 
  pdfName = foName & "###"
'EV если файл еще не выгружен на диск
  if not fso.FileExists(FileName) then 
    set FileObj = obj.Files(FileName)
    obj.Files(fName).CheckOut FileName
  end if
'  if InStr(fName,".")>0 then 
'    foName = Split(fName,".")(0)
'  else
'    foName = fName
'  end if

  on error resume next
  copyFile = DocumentDestPath& "\" & fName '& "." & fso.GetExtensionName(FileName)
  call fso.CopyFile(FileName, copyFile, true)
  if err.Number <> 0 then 
    msgbox err.Description, vbCritical, "Ошибка копировани файла для создания pdf"
  else
    Wrd.Documents.Open(copyFile)
'    set sel = Wrd.ActiveDocument.Sections(1).Range.Find("А. Ю. Грозный")
'    'Wrd.Selection.InlineShapes.AddPicture "D:\ftv2folderclosed.gif",False,True
'    sel.InlineShapes.AddPicture "D:\ftv2folderclosed.gif",False,True
'    Wrd.ActiveDocument.save
    if err.Number = 0 then 
      wrd.visible = false'true
      wdExportFormatPDF = 17
'      Wrd.ActiveDocument.ExportAsFixedFormat DocumentDestPath & "\" & foName &".pdf", wdExportFormatPDF, False  
      Wrd.ActiveDocument.ExportAsFixedFormat DocumentDestPath & "\" & pdfName &".pdf", wdExportFormatPDF, False  
'      pdfName
    end if
    if err.Number <> 0 then _
      msgbox err.Description, vbCritical, "Ошибка преобразования файла в pdf"
  end if   
  
  Wrd.ActiveDocument.Close
  Wrd.quit   
  Set Wrd = Nothing
 if err.Number <> 0 then 
    err.Clear
    on error GoTo 0  
    fso.DeleteFolder(DocumentDestPath)
    exit sub
  end if
  err.Clear
  on error GoTo 0  
  
  if not cForm is nothing  then 
    if cForm.Controls.Has("PREVIEW1") then  ' закрываем просмотр скан файла
       cForm.Controls("PREVIEW1").Value = "1"
       cForm.Refresh()
    end if   
  end if
  
  'call LoadFile( "FILE_KD_EL_SCAN_DOC", DocumentDestPath & "\" & foName & ".pdf", true)
'  call LoadFileByObj( "FILE_KD_EL_SCAN_DOC", DocumentDestPath & "\" & foName & ".pdf", true,obj)
  call LoadFileByObj( "FILE_KD_EL_SCAN_DOC", DocumentDestPath & "\" & pdfName & ".pdf", true,obj)
'  thisApplication.Utility.Sleep 500 'чтобы успел выложиться
  if not cForm is nothing  then   
    if cForm.Controls.Has("PREVIEW1") then  ' октрываем главный файл
       cForm.Controls("PREVIEW1").Value = thisObject.Files.Main
       cForm.Refresh()
    end if   
  end if

  on error resume next
  err.Clear
'  fso.DeleteFolder(DocumentDestPath)

  if Err.Number =0 then 
    Set FSO = Nothing 
  else
    msgBox err.Description
  end if 

  err.Clear
  on error GoTo 0  

end sub

'=============================================
function GetWordFile
  set GetWordFile = GetFileByType("FILE_KD_WORD")
'  dim FColByDef
'  set GetWordFile = nothing
'  Set FColByDef = thisObject.Files.FilesByDef(ThisApplication.FileDefs("FILE_KD_WORD"))
'  if FColByDef.Count>0 Then _
'    set GetWordFile = FColByDef(0)
end function

'=============================================
function GetFileByType(fType)
  set GetFileByType = nothing
  Set FColByDef = thisObject.Files.FilesByDef(ThisApplication.FileDefs(fType))
  if FColByDef.Count>0 Then _
    set GetFileByType = FColByDef(0)
end function
'=============================================
function GetFileByTypeByObj(fType, Obj)
  set GetFileByTypeByObj = nothing
  Set FColByDef = Obj.Files.FilesByDef(ThisApplication.FileDefs(fType))
  if FColByDef.Count>0 Then 
    for each file in FColByDef
      if inStr(File.FileName,"[_")=0 and inStr(File.FileName,"_]")=0 then 
        set GetFileByTypeByObj = file
        exit function
      end if
    next  
    set GetFileByTypeByObj = FColByDef(0)
  end if
end function

'=============================================
sub OpenWordFile()
  dim file, objShellApp
  set file = GetWordFile()
  if file is nothing then
    msgbox "Оригинальный файл еще не приложен!", vbOKOnly+ vbExclamation
    exit sub
  end if
  'file.CheckOut "c:\temp\tdms\" & file.FileName
  file.CheckOut file.WorkFileName
  Set objShellApp = CreateObject("Shell.Application")
  objShellApp.ShellExecute "explorer.exe", file.WorkFileName, "", "", 1
  Set objShellApp = Nothing  
end sub

'=============================================
'Создание иерархии папок, указанных в пути
function CreateForldersHierachy(FolderPath)
  dim FSO, SplitArr, CurPath,i
  CreateForldersHierachy = false 
  
  if err.Number <> 0 then err.Clear

  Set FSO = CreateObject("Scripting.FileSystemObject")
  on error resume next
       SplitArr = Split(FolderPath,"\")
       CurPath = SplitArr(0)
                     
       for i=LBound(SplitArr)+1 to UBound(SplitArr)
           CurPath = CurPath & "\" & SplitArr(i)
              if not FSO.FolderExists(CurPath) then
                 FSO.CreateFolder(CurPath)
              end if
       Next
  if err.Number <> 0 then 
      msgbox "Не удалось создать путь " & FolderPath & " - " & err.Description, vbCritical, "Ошибка создания пути"
      err.Clear
  else  
      CreateForldersHierachy  = true
  end if
  on error goto 0
end function
'=============================================
sub ShowFileName ()
  if thisForm.Controls.Has("TXT_ORIGINAL") then 
      set file = GetWordFile()
      if file is nothing and  thisForm.Controls.Has("TXT_ORIGINAL") then
        thisForm.Controls("TXT_ORIGINAL").Value = "Оригинал не приложен"
      else
        thisForm.Controls("TXT_ORIGINAL").Value = "Оригинал - " & file.FileName
      end if
  end if
end sub

'=============================================
sub Word_Check_Out()
  set file = GetWordFile()
  if file is nothing then
    msgbox "Оригинальный файл еще не приложен!", vbOKOnly + vbExclamation
    exit sub
  end if
  'File_CheckOutAndLock(file)  
  File_CheckOut(file)
end sub

'=============================================
sub File_CheckOutAndLock(file)  
' проверяем заблокирован?
  ThisObject.Update ' Свойства объекта перезачитаны из базы
  if not thisObject.Permissions.LockOwner then 
    If ThisObject.Permissions.Locked <> FALSE Then 
        msgbox "Невозможно редактировать документ, т.к. " & thisObject.Permissions.LockUser.Description & _
          " уже заблокировал документ.", vbCritical, "Редактирование не возможно!"
        exit sub ' Объект кем-то заблокирован
     end if
     ThisObject.Lock
  end if
  call File_CheckOut(file) 
end sub
'=============================================
sub File_CheckOut(file) 
  on Error resume next
  err.clear

  set obj = file.Owner
  Obj.update
  if obj.Permissions.EditFiles = 1 then 
    ClosePreview()
    thisApplication.ExecuteCommand "CMD_EDIT_FILE", obj
    DelPDFFormDisk(file)
  else
    'thisApplication.ExecuteCommand "CMD_VIEW_FILES", obj
    file.CheckOut file.WorkFileName ' извлекаем
  end if  
  
  'file.CheckOut file.WorkFileName ' извлекаем
  if Err.Number = 0 then 
    Set FSO = CreateObject("Scripting.FileSystemObject")
    if not FSO.FileExists(file.WorkFileName) then
      file.CheckOut file.WorkFileName ' извлекаем
      if not FSO.FileExists(file.WorkFileName) then
        msgbox "Файл не выложен на диск. Попробуйте выложить на диск еще раз.", vbCritical, "Невозможно открыть файл"
        exit sub
      end if 
    end if
    Set objShellApp = CreateObject("Shell.Application") 'открываем
'    objShellApp.ShellExecute "explorer.exe", file.WorkFileName, "", "", 1
    objShellApp.ShellExecute file.WorkFileName, "", "", "open", 3
    Set objShellApp = Nothing  
  else 
    msgbox err.Description, vbCritical,"Ошибка"
  end if
  err.clear
  on Error goto 0
end sub 
''=============================================
'sub Word_Check_IN()
'  if not thisObject.Permissions.LockOwner then 
'     msgbox "Невозможно вернуть документ, т.к. вы не извлекали документ.", vbCritical, "Возврат отменен!"
'     exit sub 
'  end if
'  set file = GetWordFile()
'  if file is nothing then
'    msgbox "Оригинальный файл еще не приложен!", vbOKOnly + vbExclamation
'    exit sub
'  end if
'  call File_CheckIN(file,"FILE_KD_WORD")  
'end sub
''=============================================
'sub File_CheckIN(file, typeName)  
'  call LoadFile( typeName, file.WorkFileName, true)
'  
'  ThisObject.Unlock ThisObject.Permissions.LockType
'  ThisObject.Update
'  msgbox "Документ возвращен.", vbExclamation, "Документ возвращен."
'end sub
'=============================================
function CanAddFile()
  CanAddFile = false 
  on error resume next  
  mas = thisApplication.ExecuteScript(thisObject.ObjectDefName,"GetTypeFileArr", thisObject)
  if err.Number <> 0 then err.clear
  on error goto 0
  if not isArray(mas) then exit function
  CanAddFile = true
end function 
'=============================================
function CanDelFile(fTipe)
  CanDelFile = false 
  on error resume next  
  mas = thisApplication.ExecuteScript(thisObject.ObjectDefName,"GetTypeFileArr", thisObject)
  if err.Number <> 0 then err.clear
  on error goto 0
  if not isArray(mas) then exit function
  for i = 0 to Ubound(mas)
    if mas(i) = fTipe then 
      CanDelFile = true
      exit function
    end if  
  next

end function 
'=============================================
sub Add_application()
  call AddFile_application("", thisObject)
end sub
'=============================================
sub AddFile_application(FilePath,docObj)

   ClosePreview()
   
   mas = GetTypeFileArrayByObj(docObj)'array("Документ","Приложение")  
   if not isArray(mas) then 
      if FilePath <> "" then msgbox "Добавление файлов к документу невозможно", vbExclamation
      exit sub
   end if
   if Ubound(mas) = 0 then 
     set clTypeFl = thisApplication.Classifiers("NODE_KD_TYPE_FILES_DOC").Classifiers.Find(mas(0))
   else
     Set SelDlg = ThisApplication.Dialogs.SelectDlg
     SelDlg.Caption = "Выбор типа файла:"
     SelDlg.SelectFrom = mas
     RetVal = SelDlg.Show
     SelectedArray = SelDlg.Objects
     if Ubound(SelectedArray)<0 or not RetVal then exit sub
     
'     if Ubound(SelectedArray) = 0 then 'Если объект один
'      
'     else                     'Если их много
'      
'     end if
'     
     
     set clTypeFl = thisApplication.Classifiers("NODE_KD_TYPE_FILES_DOC").Classifiers.Find(SelectedArray(0))
     ' т.к. могут быть одинаковые названия типов файлов
   end if
   if clTypeFl is nothing then 'exit sub
      if FilePath <> "" then exit sub
    ' если не смогли определить тип грузим их дочерних
      call thisApplication.ExecuteScript("FORM_KD_EXCUTION","AddFiles","QUERY_DOC_ORDER_FILES", docObj)
      exit sub
   end if
   TypeFl = clTypeFl.SysName
   TypeFl = Replace(TypeFl,"NODE","FILE")
   if thisApplication.FileDefs.Has(TypeFl) then 
      if FilePath <> "" then 
        call LoadOneFile(TypeFl, docObj, FilePath)
      else
        call LoadFileToDocByObj(TypeFl,docObj)
      end if 
   end if      
end sub
'=============================================
function GetTypeFileArray()
  GetTypeFileArray = GetTypeFileArrayByObj(thisObject)
end function 
'=============================================
function GetTypeFileArrayByObj(obj)
  on error resume next  
  GetTypeFileArrayByObj = thisApplication.ExecuteScript(obj.ObjectDefName,"GetTypeFileArr", obj)
  if err.Number <> 0 then err.clear
  on error goto 0

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

'  GetTypeFileArray = array("Документ","Приложение")  
end function

'=============================================
function GetAPTypeFileArray(docObj)
  GetAPTypeFileArray = array("Приложение")  
end function
'=============================================
function GetOUTTypeFileArray(docObj)
  GetOUTTypeFileArray = array("Документ","Приложение","Загрузить приложение из дочерних поручений")
end function
'=============================================
' заменяем символы
function CheckFileName(fName)
  CheckFileName = ""
  fName = Replace(fName,chr(10)," ") ' перенос строки
  fName = Replace(fName,chr(13)," ") ' перевод каретки
  fName = Replace(fName,chr(42)," ") '*
  fName = Replace(fName,chr(124)," ") '|
  fName = Replace(fName,chr(92)," ") '\
  fName = Replace(fName,chr(47)," ") '/
  fName = Replace(fName,chr(58)," ") ':
  fName = Replace(fName,chr(34),"") '"
  fName = Replace(fName,chr(60)," ") '<
  fName = Replace(fName,chr(62)," ") '>
  fName = Replace(fName,chr(63)," ") '?
  fName = Replace(fName,"  "," ") 
  CheckFileName = trim(fName)
end function
'=============================================
'EV получам только имя файла
function getFileName(fName)
  getFileName = fName
  pos = InStrRev(fName,".")
  if pos > 0 then 
    getFileName = left(fName,pos-1)
  end if
end function
'=============================================
' EV получаем расширение файла
function getFileExt(fName)
  getFileExt = ""
  pos = InStrRev(fName,".")
  if pos > 0 then 
    getFileExt = Right(fName, len(fName) - pos)
  end if
end function
'=============================================
sub ShowFile(iItem)
    ThisForm.Controls("PREVIEW1").Value = "1" ' чтобы наверняка перечитал
    ' чтобы не показывала при первом создании
    if IsExistsGlobalVarrible("ShowFile") then  
      RemoveGlobalVarrible("ShowFile")
      exit sub
    end if

    if iItem < 0 then exit sub
    
    Set s = thisForm.Controls("QUERY_KD_FILES_IN_DOC").ActiveX
    if s.Count = 0 then exit sub

    thisObject.SaveChanges(16384) 'т.к. могли поменять файл за это время

    Set FileS = s.ItemObject(iItem) 
    ext = getFileExt(FileS.FileName)

    if not isCanHasPdf(FileS.FileName) and ext <> "pdf" then 
       ' msgbox "Невозможно просмотреть данный файл", vbInformation
        ThisForm.Controls("PREVIEW1").Value = FileS.FileName '"1"
        ThisForm.Refresh()
        exit sub
    end if

    if ext = "pdf" then 
      fileName = FileS.FileName
    else
'      fileName = getFileName(FileS.FileName) & ".pdf"
      fileName = getFileName(FileS.FileName) & "###.pdf"
      
      if not thisObject.Files.Has(fileName) then 
        ' добавить проверку на существование файла и вопрос о создании
        ans = msgbox ("Отображение еще не сформировано. Хотите создать изображение файла?", _
            vbQuestion + vbYesNo,"Создать изображение?")
        if ans <> vbYes then exit sub              
        call CreatePDFFromFile(FileS.WorkFileName, thisObject, nothing)
        thisObject.SaveChanges 16384 ' 0
      end if
      ' добавить проверку на существование файла и вопрос о создании
    end if
    ThisForm.Controls("PREVIEW1").Value = fileName
    ThisForm.Refresh()
'    thisObject.Update
end sub
'=============================================
function CopyFileWithPdf(obj, file)
  set CopyFileWithPdf = nothing
    thisScript.SysAdminModeOn
    If not Obj.Files.Has(file.FileName) then 
      Set CopyFileWithPdf = Obj.Files.AddCopy(file, file.FileName)
      if isCanHasPdf(File.FileName) then 
        pdfName =  getFileName(file.FileName) & "###.pdf"
        set oldObj = file.Owner 
        if oldObj.Files.Has(pdfName) then 
          set pdfFile = oldObj.Files(pdfName)
          if not obj.Files.has(pdfName) then _
              call obj.Files.AddCopy(pdfFile,pdfName)
        end if
      end if
    End If

end function
'=============================================
sub DelPDFFormDisk(file)
    dim FSO,pdfName
    thisScript.SysAdminModeOn
    if not isCanHasPdf(file.FileName) then exit sub
    pdfName = getFileName(File.WorkFileName) & "###.pdf"
    Set FSO = CreateObject("Scripting.FileSystemObject")
    if FSO.FileExists(pdfName) then 
        on error resume next
        FSO.DeleteFile pdfName, true 
        on error goto 0
    end if
end sub

