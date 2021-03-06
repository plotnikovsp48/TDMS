Use "CMD_A_DLL"

Call Main()

Sub Main()
'Проверяем права
If Not ThisApplication.Attributes("ATTR_A_ARM_AN").Value Then
  If Not ThisApplication.Groups("GROUP_A_AN_ADMIN").Users.Has(ThisApplication.CurrentUser) Then
    If ThisApplication.CurrentUser.SysName <> ThisObject.Parent.Attributes("ATTR_A_PROJECT_GIP").User.SysName Then
      MsgBox "Операцию может проводить только пользователь входящий в группу ""Администраторы АН"" или ГИП данного проекта!", _
        vbInformation, "Операция отменена!"
      Exit Sub
    End If
  End If
End If
iFilesCount = 0
ThisScript.SysAdminModeOn

'Если есть - разворачиваем архив
Set ZIPFileDlg = ThisApplication.Dialogs.FileDlg
ZIPFileDlg.Filter = "Файлы ZIP|*.zip|All Files (*.*)|*.*||"
On Error Resume Next
If ThisObject.Attributes("ATTR_A_PROJECT_DLFOLDER").Value <> "" Then ZIPFileDlg.InitialDirectory = ThisObject.Attributes("ATTR_A_PROJECT_DLFOLDER").Value
On Error GoTo 0
If Not ZIPFileDlg.Show Then Exit Sub
sPassw = NULL
On Error Resume Next
sPassw = ThisObject.Attributes("ATTR_A_ENCRIPTED_TEXT").Value
On Error GoTo 0
If IsNull(sPassw) Then sPassw = InputBox("Введите пароль для распаковки архива:", "Ввод пароля")
Call Decompress(ZIPFileDlg.FileName, sPassw, True)

'Открываем XML файл
sXMLFilePath = ""
Set FSO = CreateObject("Scripting.FileSystemObject")
sDir = Left(ZIPFileDlg.FileName, InStrRev(ZIPFileDlg.FileName, "\"))
Set oDir = FSO.GetFolder(sDir)
For Each f_ In oDir.Files
  If InStr(f_.Name, ".xml") <> 0 Then
    If InStr(f_.Name, "_") = 0 Then sXMLFilePath = f_.path : Exit For
  End If
Next
If sXMLFilePath = "" Then
  MsgBox "Файл импорта не найден!", vbExclamation
  Exit Sub
End If
'Set XMLFileDlg = THisApplication.Dialogs.FileDlg
'XMLFileDlg.Filter = "Файлы XML|*.xml||"
'If Not XMLFileDlg.Show Then Exit Sub
'sXMLFilePath = XMLFileDlg.FileName
StartTime = Now
Dim XMLFileNames()
Redim XMLFileNames(0)
XMLFileNames(0) = sXMLFilePath
'sMainFNamePart = sXMLFilePath
sXMLFilePath = Left(sXMLFilePath, Len(sXMLFilePath) - 4)
'sCurDir = Left(sXMLFilePath, InStrRev(sXMLFilePath, "/"))
i = 1
'Set FSO = CreateObject("Scripting.FileSystemObject")
Do While FSO.FileExists(sXMLFilePath + "_" + CStr(i) + ".xml")
  Redim Preserve XMLFileNames(UBound(XMLFileNames) + 1)
  XMLFileNames(i) = sXMLFilePath + "_" + CStr(i) + ".xml"
  i = i + 1
Loop
'Параметры загрузки объектов
Set params = ThisApplication.CreateDictionary
Set params("RootForImport") = ThisApplication.Desktop
params("Mode") = 0
If FSO.FolderExists(sXMLFilePath + ".files") Then
  params("ImportWithBodies") = True
Else
  params("ImportWithBodies") = False
End If
'If MsgBox("Загружать файлы с содержимым?", vbQuestion + vbYesNo) = vbNo Then
'  params("ImportWithBodies") = False
'Else
'  params("ImportWithBodies") = True
'End If
'Загружаем недостающих пользователей и классификаторы
'If MsgBox("Хотите загрузить пользователей и классификаторы?", vbQuestion + vbYesNo) = vbYes Then
  iAllUsers = 0
  iAllClassifs = 0
  Dim sXMLBindFiles()
  Redim sXMLBindFiles(UBound(XMLFileNames))
  iBindFilesCount = 0
  For Each sXMLFilePath In XMLFileNames
    'Пользователи
    sUserFileName = Left(sXMLFilePath, Len(sXMLFilePath) - 4) + "_user.xml"
'    Set cUsers = ThisApplication.CreateCollection(2)
'    ThisApplication.ImportUsers sUserFileName, cUsers, False
'    iUserCount = cUsers.Count
    iUserCount = ThisApplication.ExecuteScript(ThisApplication.Commands("CMD_A_IMPORT_USERS"), "Main", sUserFileName)
    iAllUsers = iAllUsers + iUserCount
    'Классификаторы
    sClsFileName = Left(sXMLFilePath, Len(sXMLFilePath) - 4) + "_cls.xml"
    iClsCount = ThisApplication.ExecuteScript(ThisApplication.Commands("CMD_A_IMPORT_CLASSIFIERS"), "Main", sClsFileName, Nothing)
    iAllClassifs = iAllClassifs + iClsCount
  Next
  
'End If
iXMLFilesNum = UBound(XMLFileNames) + 1
'Обрабатываемый файл
'j = 1
'Обрабатываем все файлы загрузки
iObjNum = 0
iObjNumSysFunc = 0

For Each sXMLFilePath In XMLFileNames
'Открытие транзакции
ThisApplication.StartTransaction
'Обрабатываем файл связей
  Set xmlParser = CreateObject("Msxml2.DOMDocument")
  xmlParser.async = False
  sBindFileName = Left(sXMLFilePath, Len(sXMLFilePath) - 4) + "_bind.xml"
  sXMLBindFiles(iBindFilesCount) = sBindFileName
  iBindFilesCount = iBindFilesCount + 1
  If Not FSO.FileExists(sBindFileName) Then
    MsgBox "Не найден файл связей! Операция импорта отменена!", VbCritical
    Exit Sub
  End If


  xmlParser.load(sBindFileName)
  If xmlParser.parseError.errorCode Then
    MsgBox(xmlParser.parseError.Reason)
    Exit Sub
  End If
  Set ObjNodes = xmlParser.selectNodes("//TDMSObject")
  If ObjNodes.length = 0 Then
    MsgBox "Неверный формат файла связей объектов! Операция импорта отменена!", vbCritical
    Exit Sub
  End If
'Находим корневой проект
Set nProjNode = xmlParser.selectSingleNode("//RootProject")
Set oParentProj = Nothing
On Error Resume Next
Set oParentProj = ThisApplication.GetObjectByGUID(nProjNode.getAttribute("ProjectGUID"))
On Error GoTo 0
'Создаем отчет
'If ThisApplication.ObjectDefs("OBJECT_A_SYNCH_LIST").Objects.Count = 0 Then
If Not oParentProj Is Nothing Then
  If oParentProj.ContentAll.ObjectsByDef("OBJECT_A_SYNCH_LIST").Count = 0 Then
    MsgBox "Не найден журнал синхронизации! Операция экспорта выполнена не будет!", vbExclamation
    Exit Sub
  End If
End If
Set oRep = Nothing
If ThisObject.ObjectDefName = "OBJECT_A_SYNCH" Then
  Set oRepPar = oParentProj.ContentAll.ObjectsByDef("OBJECT_A_SYNCH_LIST")(0)
  Set oRep = oRepPar.Objects.Create("OBJECT_A_SYNCH_LIST_ROW")
End If
If Not oRep Is Nothing Then
  oRep.Attributes("ATTR_A_SYNCH_LIST_TYPE").Classifier = ThisApplication.Classifiers("CLS_A_SYNCH_TYPE").Classifiers.Find("CLS_A_SYNCH_TYPE_REGIM")
  oRep.Attributes("ATTR_A_SYNCH_LIST_ROW_USERS").Value = iAllUsers
  oRep.Attributes("ATTR_A_SYNCH_LIST_ROW_CLASS").Value = iAllClassifs
  oRep.Update
End If
'Импортируем объекты после открытия файла связей
  'Set oImportedObjs = ThisApplication.ImportObjectsXML(sXMLFilePath, ThisApplication.Desktop, 0)
  
  Set oImportedObjs = ThisApplication.ImportObjectsXML2(sXMLFilePath, params)
  iObjNumSysFunc = iObjNumSysFunc + oImportedObjs.Count
'Пишем лог
If Not oRep Is Nothing Then
  oRep.CheckOut
  oRep.CheckIn
  Set FSO = CreateObject("Scripting.FileSystemObject")
'sLogDir = ThisApplication.ApplicationFolder + "Logs"
  sLogDir = oRep.WorkFolder
  sLogShortFName = CStr(Now)
  sLogShortFName = Replace(sLogShortFName, ".", "_")
  sLogShortFName = Replace(sLogShortFName, ":", "_")
  sLogShortFName = Replace(sLogShortFName, " ", "_")
  sLogShortFName = sLogShortFName + "_log.txt"
  sLogFileName = sLogDir + "\" + sLogShortFName
  Set oLogFile = FSO.OpenTextFile(sLogFileName, 8, true)
  oLogFile.WriteLine("Загрузка" + vbTab + CStr(Now))
  For Each o_ In oImportedObjs
    oLogFile.WriteLine(o_.Description + vbTab + o_.GUID)
  Next
  oLogFile.Close
  Set oTDMLogFile = oRep.Files.Create("FILE_TXT", sLogFileName)
  oTDMLogFile.FileName = sLogShortFName
End If
' PostProcPrg.Position = Round((100 / ObjNodes.Length) *  i)
' PostProcPrg.Text = "Обрабатывается файл " + CStr(j) + " из " + Cstr(iXMLFilesNum) + ". Обработано " + CStr(i) + " объектов из " + CStr(ObjNodes.Length) + " в файле."
' i = i + 1
' j = j + 1

  iObjNum = iObjNum + ObjNodes.Length
 If ThisApplication.IsActiveTransaction Then ThisApplication.CommitTransaction 
Next


'Обрабатываем файлы связей
  j = 1
  For Each sBindFileName In sXMLBindFiles
    Set xmlParser = CreateObject("Msxml2.DOMDocument")
    xmlParser.async = False
    xmlParser.load(sBindFileName)
    If xmlParser.parseError.errorCode Then
      MsgBox(xmlParser.parseError.Reason)
      Exit Sub
    End If
    Set ObjNodes = xmlParser.selectNodes("//TDMSObject")
    Set nProjNode = xmlParser.selectSingleNode("//RootProject")
    Set oParentProj = Nothing
    Set oParentProj = ThisApplication.GetObjectByGUID(nProjNode.getAttribute("ProjectGUID"))
    'Восстанавливаем связи!
  ThisApplication.Utility.WaitCursor = True
'ThisApplication.Shell.SetStatusBarText "Пожалуйста подождите!"
  Set PostProcPrg = ThisApplication.Dialogs.ProgressDlg
  PostProcPrg.Text = "Пожалуйста подождите!"
  PostProcPrg.Start
  i = 1
  
  For Each oNode In ObjNodes
    Set oObj = Nothing
    On Error Resume Next
    Set oObj = ThisApplication.GetObjectByGUID(oNode.getAttribute("ObjectGUID"))
    On Error GoTo 0
    If Not oObj Is Nothing Then
     iFilesCount = iFilesCount + oObj.Files.Count
  'Удаляем с раб. стола если у объекта был парент и он найден или если его не было
      If oNode.getAttribute("ParentGUID") <> "" Then
        Set oParent = ThisApplication.GetObjectByGUID(oNode.getAttribute("ParentGUID"))
        If Not oParent Is Nothing Then
          On Error Resume Next
          If Not oParent.Objects.Has(oObj) Then oParent.Objects.Add oObj
          oObj.Parent = oParent
          On Error GoTo 0
          If ThisApplication.Desktop.Objects.Has(oObj) Then ThisApplication.Desktop.Objects.Remove oObj
        End If
      Else
          If ThisApplication.Desktop.Objects.Has(oObj) Then ThisApplication.Desktop.Objects.Remove oObj
      End If
      Set nUplinks = oNode.SelectNodes("//TDMSObject[(@ObjectGUID='" + oObj.GUID + "')]/Uplinks/Uplink")
      For Each nUpl In nUplinks
        Set oUplink = ThisApplication.GetObjectByGUID(nUpl.getAttribute("UplinkGUID"))
        If Not oUplink Is Nothing Then
          On Error Resume Next
          If Not oUplink.Objects.Has(oObj) Then oUplink.Objects.Add oObj
          On Error GoTo 0
          If ThisApplication.Desktop.Objects.Has(oObj) Then ThisApplication.Desktop.Objects.Remove oObj
        End If
      Next
      PostProcPrg.Position = Round((100 / ObjNodes.Length) *  i)
      PostProcPrg.Text = "Обрабатывается файл " + CStr(j) + " из " + Cstr(iXMLFilesNum) + ". Обработано " + CStr(i) + " объектов из " + CStr(ObjNodes.Length) + " в файле."
      i = i + 1
    End If
  Next
  j = j + 1
  Next
  PostProcPrg.Stop

'Проверяем связи решений с комплектами
If Not oParentProj Is Nothing Then
  If oParentProj.Objects.ObjectsByDef("OBJECT_A_SYNCH").Count > 0 Then
    If oParentProj.Objects.ObjectsByDef("OBJECT_A_SYNCH")(0).Attributes("ATTR_A_LINK_DECISION_PSD").Value Then Call CheckPSDLinks(oParentProj)
  End If
End If
If Not ThisApplication.Groups.Has("GROUP_A_AN_ADMIN") Then 
  Set oAdminsANGrp = ThisApplication.Groups.Create
  oAdminsANGrp.SysName = "GROUP_A_AN_ADMIN"
  oAdminsANGrp.Description  = "Администраторы АН"
End If
'Постобработчики
If ThisObject.ObjectDefName = "OBJECT_A_SYNCH" Then
  If ThisObject.Attributes("ATTR_A_EXECUTE_OUTSIDE_HANDLERS").Value Then
      Set CommsTbl = ThisObject.Attributes("ATTR_A_OUTSIDE_HANDLERS_IMPORT").Rows
      If CommsTbl.Count > 0 Then
        Set shl = CreateObject("WScript.Shell")
        For Each r_ In CommsTbl
          shl.run r_.Attributes("ATTR_A_COMMAND_LINE").Value, 1, True
        Next
      End If
  End If
  ThisObject.Attributes("ATTR_A_PROJECT_DL_DATE").Value = Now
End If
If Not oRep Is Nothing Then
  oRep.Attributes("ATTR_A_SYNCH_LIST_ROW_OBJ").Value = iObjNum
  oRep.Attributes("ATTR_A_SYNCH_LIST_ROW_OBJ_COMPL").Value = iObjNumSysFunc
  oRep.Attributes("ATTR_A_SYNCH_LIST_ROW_FILES").Value = iFilesCount
  oRep.Attributes("ATTR_A_SYNCH_LIST_ROW_STATUS").Classifier = ThisApplication.Classifiers("CLS_A_SYNCH_STATUS").Classifiers.Find("CLS_A_SYNCH_STATUS_OK")
End If

ElapsedTime = DateDiff("s", StartTime, Now)
If ElapsedTime > 60 Then
  sTimeStr = Cstr(ElapsedTime / 60) + " мин."
Else
  sTimeStr = Cstr(ElapsedTime) + " сек."
End If

ThisScript.SysAdminModeOff
' Удаление файлов и папки после распаковки
Call ClearFolder(sDir)
MsgBox "Выполнено! Обработано " + CStr(iObjNum) + " объектов за " + sTimeStr, vbInformation
End Sub

Sub OnScriptError(ScriptDescription, Object, Line, Char, ErrorDescription, Cancel)
If ErrorDescription = "Разрешение отклонено" Then
  ThisApplication.AddNotify("Не могу создать лог файл - " + ErrorDescription)
  Cancel = True
  Exit Sub
End If
If ThisApplication.IsActiveTransaction Then ThisApplication.AbortTransaction
End Sub

Sub Command_Completed(Command, Obj)
'На случай выхода по условию
If ThisApplication.IsActiveTransaction Then ThisApplication.CommitTransaction
End Sub
