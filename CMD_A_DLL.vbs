'Получаем родительский объект заданного типа
Function GetParentOfExactType(Obj, ParentDef)
Set GetParentOfExactType = Nothing
Set oParent = Obj
If oParent Is Nothing Then Exit Function
If oParent.ObjectDefName <> ParentDef Then
  Do While oParent.ObjectDefName <> ParentDef
    If oParent.Parent Is Nothing Then Exit Function
    Set oParent = oParent.Parent
    'If oParent.ObjectDefName = "ROOT_DEF" Then Exit Function
  Loop
End If
Set GetParentOfExactType = oParent
End Function

'Пишем содержимое атрибутов типа "Текст" в файл для передачи в приложение
Function HtmlToFile(sHTML, Obj)
Set FSO = CreateObject("Scripting.FileSystemObject")
If Not FSO.FolderExists(Obj.WorkFolder) Then FSO.CreateFolder(Obj.WorkFolder)
sFileName = Obj.WorkFolder + "\temp.html"
Set HFile = FSO.CreateTextFile(sFileName, True)
HFile.Write(sHTML)
HFile.Close
HtmlToFile = sFileName
End Function

Function FindChangedFiles(Obj, dDate)
Set cFiles = ThisApplication.CreateCollection(1)
For Each f_ In Obj.Files
  If f_.ModifyTime => dDate Then
    If Not cFiles.Has(f_) Then cFiles.Add f_
  End If
Next
Set FindChangedFiles = cFiles
End Function


Sub Compress(sDir, sPassw)
Set FSO = CreateObject("Scripting.FileSystemObject")
sDirArr = Split(sDir, "\")
sDirConverted = ""
For Each s_ In sDirArr
  If InStr(s_, " ") <> 0 Then 
    sDirConverted = sDirConverted + """" + s_ + """\"
  Else
    sDirConverted = sDirConverted + s_ + "\"
  End If
Next
s7zPassUnquoted = ThisApplication.ApplicationFolder + "7za.exe"
s7zPass = """" + s7zPassUnquoted + """"
If Not FSO.FileExists(s7zPassUnquoted) Then
  Msgbox "Архиватор не найден!", vbExclamation
  Exit Sub
End If
'ThisApplication.AddNotify "Архивация начата!"
sFileName = "АРМ_" + CStr(Day(Now)) + "_" + CStr(Month(Now)) + "_" + CStr(Year(Now)) + "_" + CStr(Hour(Now)) + "_" + CStr(Minute(Now)) + "_" + CStr(Second(Now)) + ".zip"
If FSO.FileExists(sDir + "\" + sFileName) Then FSO.DeleteFile sDir + "\" + sFileName
If sPassw <> "" Then
  sCommLine = s7zPass + " a -p" + sPassw + " " + sDirConverted + sFileName + " " + sDirConverted + "* -x!*.zip"
Else
  sCommLine = s7zPass + " a " + sDirConverted + sFileName + " " + sDirConverted + "* -x!*.zip"
End If
'sCommLine = """cmd /K " + sCommLine + """"
Set shl = CreateObject("WScript.Shell")
'MsgBox(sCommLine)
shl.run sCommLine, 0, true
'If MsgBox("Удалить добавленные в архив файлы (все файлы и каталоги из текущего каталога)?", vbYesNo + vbQuestion) = vbYes Then
  Set oArchFolder = FSO.GetFolder(sDir)
  For Each folder_ In oArchFolder.SubFolders
    folder_.Delete True
  Next
  For Each f_ In oArchFolder.Files
    'If f_.Name <> sFileName Then f_.Delete True
    If InStr(f_.Name, ".zip") = 0 Then f_.Delete True
  Next
'End If
'ThisApplication.AddNotify "Архивация завершена!"
'ThisApplication.AddNotify "Экспорт завершен!"
End Sub

Sub Decompress(sZipFileName, sPassw, lCheckIntegr)
sDirArr = Split(sZipFileName, "\")
sZipFileNameConverted = ""
For Each s_ In sDirArr
  If InStr(s_, " ") <> 0 Then 
    sZipFileNameConverted = sZipFileNameConverted + """" + s_ + """"
  Else
    sZipFileNameConverted = sZipFileNameConverted + s_
  End If
  If InStr(sZipFileNameConverted, ".zip") = 0 Then sZipFileNameConverted = sZipFileNameConverted + "\"
Next
s7zPassUnquoted = ThisApplication.ApplicationFolder + "7za.exe"
s7zPass = """" + s7zPassUnquoted + """"
Set FSO = CreateObject("Scripting.FileSystemObject")
If Not FSO.FileExists(s7zPassUnquoted) Then
 ThisApplication.AddNotify "Архиватор не найден!"
  Exit Sub
End If
'Получаем пароль для архива
'sPassw = InputBox("Введите пароль для архива:", "Ввод пароля")
'Проверка целостности
If lCheckIntegr Then
  If Not TestArchieve(sZipFileNameConverted, sPassw) Then
    MsgBox "Ошибки при проверке файла архива! Для получения подробностей см. отчет!", vbExclamation
    Exit Sub
  End If
End If
'Каталог
sDir = Left(sZipFileNameConverted, InStrRev(sZipFileNameConverted, "\"))
If sPassw <> "" Then
  sCommLine = s7zPass + " x " + sZipFileNameConverted + " -o" + sDir + " -aoa -p" + sPassw
Else
  sCommLine = s7zPass + " x " + sZipFileNameConverted + " -o" + sDir + " -aoa"
End If
'ThisApplication.AddNotify "Извлекаются файлы из архива..."
Set shl = CreateObject("WScript.Shell")
shl.run sCommLine, 0, true
'ThisApplication.AddNotify "Файлы извлечены!"

End Sub

Sub ClearFolder(sDir)

' Удаление файлов и папки после распаковки

  Set FSO = CreateObject("Scripting.FileSystemObject")
  Set oArchFolder = FSO.GetFolder(sDir)
  For Each folder_ In oArchFolder.SubFolders
    folder_.Delete True
  Next
  For Each f_ In oArchFolder.Files
    'If f_.Name <> sFileName Then f_.Delete True
    If InStr(f_.Name, ".zip") = 0 Then f_.Delete True
  Next

End Sub

Function TestArchieve(sZipFileName, sPasswd)
'MsgBox(sZipFileName)
'ThisApplication.AddNotify "Начата проверка целостности архива!"
TestArchieve = False
s7zPassUnquoted = ThisApplication.ApplicationFolder + "7za.exe"
s7zPass = """" + s7zPassUnquoted + """"
Set FSO = CreateObject("Scripting.FileSystemObject")
If Not FSO.FileExists(s7zPassUnquoted) Then
 ThisApplication.AddNotify "Архиватор не найден!"
  Exit Function
End If
sCommandLine = s7zPass + " t " + sZipFileName + " -r"
If sPassw <> " " Then
  sCommandLine = sCommandLine + " -p" + sPasswd
End If
sOutFilePath = ThisApplication.WorkFolder + "\ziptestout.txt"
sCommandLine = sCommandLine + " > " + sOutFilePath
sCommandLine = "cmd /K """ + sCommandLine + " & echo Закройте это окно для продолжения..."""
'MsgBox(sCommandLine)
Set shl = CreateObject("WScript.Shell")
shl.run sCommandLine, 1, True
Set FSO = CreateObject("Scripting.FileSystemObject")
Set oTextStream = Nothing
'i = 0
'Do While oTextStream Is Nothing And i < 5000
' On Error Resume Next
 Set oTextStream = FSO.OpenTextFile(sOutFilePath, 1, False)
' On Error GoTo 0
' i = i + 1
'Loop
'If i = 5000 Then Exit Function
lIfCheckOk = False
Do While oTextStream.AtEndOfStream <> True
  sRetLine = oTextStream.ReadLine
  If InStr(sRetLine, "Everything is Ok") Then 
    TestArchieve = True
    oTextStream.Close
    'ThisApplication.AddNotify "Проверка целостности прошла успешно!"
    Exit Function
  End If
Loop
ThisApplication.AddNotify "Ошибки при проверки целостности архива!"
oTextStream.Close
shl.run "%windir%\notepad " & sOutFilePath, 1, False
End Function

Function GetFolder(sDialogCaption) 
  GetFolder = False
  Const MY_COMPUTER = &H11& 
  Const WINDOW_HANDLE = 0 
  Const OPTIONS = 0
  objPath = " " 
  Set objShell = CreateObject("Shell.Application")  
  Set objFolder = objShell.Namespace(MY_COMPUTER) 
  Set objFolderItem = objFolder.Self  
  strPath = objFolderItem.Path    
  Set objFolder = objShell.BrowseForFolder(WINDOW_HANDLE, sDialogCaption, OPTIONS, strPath)     
  If Not objFolder Is Nothing Then     
    Set objFolderItem = objFolder.Self     
    objPath = objFolderItem.Path    
  Else
    Exit Function
  End If  
  GetFolder = objPath
End Function

Function GetUsersByRole(Obj, sRoleTypeName)
Set UserCol = ThisApplication.CreateCollection(tdmUsers)
For Each r_ In Obj.Roles
  If r_.RoleDefName = sRoleTypeName Then
    If Not r_.User Is Nothing Then
      If Not UserCol.Has(r_.User) Then UserCol.Add r_.User
    End If
  End If
Next
Set GetUsersByRole = UserCol
End Function


Sub OnScriptError(ScriptDescription, Object, Line, Char, ErrorDescription, Cancel)
If ErrorDescription = "Разрешение отклонено" Then
  ThisApplication.AddNotify("Не могу создать лог файл - " + ErrorDescription)
  Cancel = True
End If
If ErrorDescription = "Не удается дождаться процесса." Then
  Cancel = True
  'ThisApplication.AddNotify "Ошибка во время архивирования!"
  MsgBox("Ошибка во время архивирования!")
End If
End Sub

Sub CheckPSDLinks(oProjAN)
Set QueryDecLinks = ThisApplication.Queries("QUERY_A_CHECK_DECISION_PSD")
QueryDecLinks.Parameter("PROJECTANGUID") = oProjAN.GUID
Set oUnlinkedDecs = QueryDecLinks.Objects
If oUnlinkedDecs.Count = 0 Then Exit Sub
Set fs = CreateObject("Scripting.FileSystemObject")
oProjAN.CheckOut
oProjAN.CheckIn
sComplectQueryName = fs.BuildPath(oProjAN.WorkFolder, "ComplectQuery.txt")
On Error Resume Next
If fs.FileExists(sComplectQueryName) Then fs.DeleteFile sComplectQueryName, True
On Error GoTo 0
Set oQueryFile = fs.OpenTextFile(sComplectQueryName, 8, True)
oQueryFile.WriteLine("Проект АН: " + oProjAN.Attributes("ATTR_A_PROJECT_DOG_NUM").Value)
oQueryFile.WriteLine("Отсутствующие комплекты:")
For Each o_ In oUnlinkedDecs
  Set ComplSrch = ThisApplication.Queries("QUERY_A_COMPLECT_SEARCH_FOR")
  ComplSrch.Parameter("UNUM") = o_.Attributes("ATTR_A_DECISION_PSD_TXT").Value
  Set oComplFound = ComplSrch.Objects
  If oComplFound.Count > 0 Then
    o_.Attributes("ATTR_A_DECISION_PSD").Object = oComplFound(0)
    o_.Attributes("ATTR_A_DECISION_NUM") = o_.Parent.Attributes("ATTR_A_INCIDENT_NUM") + "-" + _
      oComplFound(0).Parent.Attributes("MARK").Classifier.Code
  Else
    oQueryFile.WriteLine(o_.Attributes("ATTR_A_DECISION_PSD_TXT").Value)
  End If
Next
oQueryFile.Close
Set shl = CreateObject("WScript.Shell")
shl.run "%windir%\notepad " & sComplectQueryName, 1, False
End Sub

'Проверяем связи объектов состава перед удалением
Function CheckBeforeContentRemoval(RemoveCol)
CheckBeforeContentRemoval = False
For Each o_ In RemoveCol
  If Not o_ Is Nothing Then
    If o_.ReferencedBy.Count > 0 Then CheckBeforeContentRemoval = True : Exit Function
    If o_.Uplinks.Count > 1 Then CheckBeforeContentRemoval = True : Exit Function
  End If
Next
End Function


'Проверяем наличие пользователя на определенной роле
Function CheckUserOnRole(Obj, sRoleDef, User)
CheckUserOnRole = False
For Each r_ In Obj.Roles
  If Not r_.User Is Nothing Then
    If r_.User.SysName = User.SysName Then
      CheckUserOnRole = True
      Exit Function
    End If
  Else
    For Each u_ In r_.Group.Users
      If u_.SysName = User.SysName Then
        CheckUserOnRole = True
      Exit Function
    End If
    Next
  End If
Next
End Function
'Sub Object_BeforeContentRemove(Obj, RemoveCollection, Cancel)
'Cancel = CheckBeforeContentRemoval(RemoveCollection)
'If Cancel Then
'  MsgBox "Объекты системы содержат ссылки на один или более из удаляемых объектов! Удаление отменено!", vbExclamation
'End If
'End Sub
