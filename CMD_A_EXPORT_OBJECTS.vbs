USE "CMD_A_DLL"

Set oRep = Nothing
iFilesCount = 0

Call StartExport()

Sub StartExport()
ThisScript.SysAdminModeOn
'MsgBox 2
'Параметры экспорта
Set ExportParams = ThisApplication.Dictionary("ExportParams")
ExportParams("ExportWithContent") = False
ExportParams("ExportWithRoles") = ThisObject.Parent.Attributes("ATTR_A_EXPORT_ROLES").Value
ExportParams("ExportWithFiles") = ThisObject.Parent.Attributes("ATTR_A_EXPORT_FILES").Value
ExportParams("ExportFilesWithBodies") = ThisObject.Parent.Attributes("ATTR_A_EXPORT_FILE_BODIES").Value
Set ExportParams("Objects") = Nothing
Set FSO = CreateObject("Scripting.FileSystemObject")
Set SelectedObjects = ThisApplication.CreateCollection(tdmObjects)
Set ObjsTbl = ThisObject.Attributes("ATTR_A_EXPORT_QUEUE").Rows
For Each r_ In ObjsTbl
  If r_.Attributes("ATTR_A_TO_EXPORT").Value Then SelectedObjects.Add r_.Attributes("ATTR_A_EXPORT_OBJECT").Object
Next
sPassw = ThisObject.Parent.Attributes("ATTR_A_ENCRIPTED_TEXT").Value

'Создаем отчет
If ThisObject.Parent.Objects.ObjectsByDef("OBJECT_A_SYNCH_LIST").Count = 0 Then
  'MsgBox "Не найден журнал синхронизации! Операция экспорта выполнена не будет!", vbExclamation
  ThisApplication.AddNotify "Не найден журнал синхронизации! Операция экспорта выполнена не будет!"
  Exit Sub
End If
Set oRepPar = ThisObject.Parent.Objects.ObjectsByDef("OBJECT_A_SYNCH_LIST")(0)
Set oRep = oRepPar.Objects.Create("OBJECT_A_SYNCH_LIST_ROW")
oRep.Attributes("ATTR_A_SYNCH_LIST_ROW_OBJ").Value = SelectedObjects.Count
oRep.Update
'Путь к каталогу из формы
sDirPath = ""
sDirPath = Thisobject.Parent.Attributes("ATTR_A_PROJECT_UPFOLDER").Value
If sDirPath <> "" Then
  If FSO.FolderExists(sDirPath) Then
    sXMLFileName = sDirPath + "\export.xml"
     sMainFNamePart = sXMLFileName
    'sDirPath = sDirPath + "\" + sXMLFileName
  Else
    FSO.CreateFolder(sDirPath)
    sXMLFileName = sDirPath + "\export.xml"
    sMainFNamePart = sXMLFileName
  End If
End If
'Открываем XML
If sDirPath = "" Then
  Set OpenFileDlg = ThisApplication.Dialogs.FileDlg
  OpenFileDlg.Filter = "Файлы XML|*.xml"
  OpenFileDlg.DefaultExt = ".xml"
  OpenFileDlg.Flags = 882204
  If Not OpenFileDlg.Show Then Exit Sub
  sXMLFileName = OpenFileDlg.FileName
  sMainFNamePart = sXMLFileName
  'Путь к каталогу
  sDirPath = Left(sXMLFileName, InStrRev(sXMLFileName, "\") - 1)
End If
If FSO.FileExists(sXMLFileName) Then
  If MsgBox("Файл " + sXMLFileName + " будет перезаписан, все его содержимое утрачено! Хотите продолжить?", vbQuestion + vbYesNo, ThisApplication.DatabaseName) = vbNo Then Exit Sub
End If
StartTime = Now
'Количество выгружаемых объектов на один XML файл
iObjNumPerFile = 1000

On Error Resume Next
Set ControlDict = ThisApplication.Dictionary("ControlDict")
On Error GoTo 0
If SelectedObjects.Count < iObjNumPerFile Then
  On Error Resume Next
  ControlDict.Item("InfoStrCtrl").Value = "Идет экспорт " + CStr(SelectedObjects.Count) + " объектов! Пожалуйста подождите..."
  ControlDict.Item("PrgControl").SetCtrlPos(10)
  On Error GoTo 0
  Call Main(SelectedObjects, sXMLFileName)
Else
  iPrgStep = SelectedObjects.Count \ iObjNumPerFile
  i = 0
  j = 0
  Do While i < SelectedObjects.Count
    Set CurrentCol = ThisApplication.CreateCollection(0)
    Do 
      CurrentCol.Add SelectedObjects(i)
      i = i + 1
      If (i / iObjNumPerFile) = (i \ iObjNumPerFile) Then Exit Do
      If i = SelectedObjects.Count Then Exit Do
    Loop
'    If j = 0 Then
'      sXMLFileName = sXMLFileName
    If j <> 0 Then
      'MsgBox(sMainFNamePart)
      sXMLFileName = Left(sMainFNamePart, Len(sMainFNamePart) - 4) + "_" + CStr(j) + ".xml"
    End If
    On Error Resume Next
    ControlDict.Item("PrgControl").SetCtrlPos(iPrgStep * j)
    ControlDict.Item("InfoStrCtrl").Value = "Обрабатываются объекты с " + CStr(iObjNumPerFile * j) + " по " + CStr(iObjNumPerFile * (j + 1)) + " из " + CStr(SelectedObjects.Count) + "! Пожалуйста подождите..."
    On Error GoTo 0
    Call Main(CurrentCol, sXMLFileName)
    j = j + 1
  Loop
End If
On Error Resume Next
ControlDict.Item("InfoStrCtrl").Value = "Обработка завершена!"
ControlDict.Item("PrgControl").SetCtrlPos(100)
ControlDict.Item("PrgControlPos") = 100
On Error GoTo 0
'Пишем выгруженные объекты в log
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
oLogFile.WriteLine("Выгрузка" + vbTab + CStr(Now))
For Each o_ In SelectedObjects
  'If Not o_ Is Nothing Then
  On Error Resume Next
  oLogFile.WriteLine(o_.Description + vbTab + o_.GUID)
  On Error GoTo 0
  'End If
Next
oLogFile.Close
Set oTDMLogFile = oRep.Files.Create("FILE_TXT", sLogFileName)
oTDMLogFile.FileName = sLogShortFName
'Время ушедшее на операцию
ElapsedTime = DateDiff("s", StartTime, Now)
If ElapsedTime > 60 Then
  sTimeStr = Cstr(ElapsedTime / 60) + " мин."
Else
  sTimeStr = Cstr(ElapsedTime) + " сек."
End If
oRep.Attributes("ATTR_A_SYNCH_LIST_ROW_FILES").Value = iFilesCount
oRep.Attributes("ATTR_A_SYNCH_LIST_ROW_STATUS").Classifier = ThisApplication.Classifiers("CLS_A_SYNCH_STATUS").Classifiers.Find("CLS_A_SYNCH_STATUS_OK")
'Находим и если есть сохраняем log файл.
'sLogDir = ThisApplication.ApplicationFolder + "\Logs"
'Set FSO = CreateObject("Scripting.FileSystemObject")
'If FSO.FolderExists(sLogDir) Then
'  Set oLogDir = FSO.GetFolder(sLogDir)
'  MsgBox(oLogDir.Files.Item(0).Name)
'End If
'Запуск внешних обработчиков
'Находим менеджер
'If ThisApplication.ObjectDefs("OBJECT_A_EXPORT_MANAGER").Objects.Count > 0 Then
'  Set oExpManag = ThisApplication.ObjectDefs("OBJECT_A_EXPORT_MANAGER").Objects(0)
  If ThisObject.Parent.Attributes("ATTR_A_EXECUTE_OUTSIDE_HANDLERS").Value Then
    Set CommsTbl = ThisObject.Parent.Attributes("ATTR_A_OUTSIDE_HANDLERS").Rows
    If CommsTbl.Count > 0 Then
      Set shl = CreateObject("WScript.Shell")
      For Each r_ In CommsTbl
        shl.run r_.Attributes("ATTR_A_COMMAND_LINE").Value, 1, True
      Next
    End If
  End If
'End If
'Архивация
Call Compress(sDirPath, sPassw)
'Удаляем экспортированные строки из таблицы
For Each r_ In ObjsTbl
  If r_.Attributes("ATTR_A_TO_EXPORT").Value Then ObjsTbl.Remove r_
Next
ThisObject.Parent.Attributes("ATTR_A_PROJECT_UD_DATE").Value = Now
ThisObject.Attributes("ATTR_A_CHANGED_AFTER").Value = Now
'Подсчет выгруженных объектов
lExportedObjsCount = SelectedObjects.Count
'If ExportWithContent Then
'  For Each eo_ In ExportObjs
'    lExportedObjsCount = lExportedObjsCount + eo_.ContentAll.Count
'  Next
'End If
'MsgBox "Выполнено! Обработано " + CStr(lExportedObjsCount) + " объектов за " + sTimeStr, vbInformation
ThisApplication.AddNotify "Выполнено!"
End Sub

Sub Main(ExportObjs, sXMLFileName)
'''''Новая функция
'set params = ThisApplication.CreateDictionary
'params("ExportWithContent") = true
'params("ExportWithRoles") = true
'params("ExportWithFiles") = true
'params("ExportFilesWithBodies") = False

Set ExportParams = ThisApplication.Dictionary("ExportParams")
'MsgBox(ExportParams("ExportWithRoles"))
'MsgBox(ExportParams("ExportWithFiles"))
'MsgBox(ExportParams("ExportFilesWithBodies"))
Set ExportParams("Objects") = ExportObjs
ThisApplication.ExportObjectsXML2 sXMLFileName, ExportParams
'''''''
'ThisApplication.ExportObjectsXML sXMLFileName, ExportObjs, False, True
'Создаем файл связей
sBindFileName = sXMLFileName
sBindFileName = Left(sBindFileName, Len(sBindFileName) - 4) + "_bind.xml"
Set xmlParser = CreateObject("Msxml2.DOMDocument")
xmlParser.async = False
xmlParser.loadXML("<tdms/>")
If xmlParser.parseError.errorCode Then
  'MsgBox(xmlParser.parseError.Reason)
  ThisApplication.AddNotify xmlParser.parseError.Reason
  Exit Sub
End If
Set rootNode = xmlParser.documentElement
'Классификаторы
Set Classifs = ThisApplication.CreateCollection(4)
'Пользователи
If ThisObject.Attributes("ATTR_A_FIRST_EXPORT").Value Then
  Set cUsers = ThisApplication.Users
Else
  Set cUsers = ThisApplication.CreateCollection(2)
End If
'Проект
Set nProj = RootNode.appendChild(xmlParser.createNode(1, "RootProject", ""))
Set newAttr = xmlParser.createAttribute("ProjectGUID")
newAttr.value = ThisObject.Parent.Parent.GUID
nProj.setAttributeNode(newAttr)
For Each o_ In ExportObjs
'Счетчик файлов
  If ExportParams("ExportWithFiles") Then iFilesCount = iFilesCount + o_.Files.Count
  Set nObj = rootNode.appendChild(xmlParser.createNode(1, "TDMSObject", ""))
  Set newAttr = xmlParser.createAttribute("ObjectGUID")
  newAttr.value = o_.GUID
  nObj.setAttributeNode(newAttr)
  If Not o_.Parent Is Nothing Then
    Set newAttr = xmlParser.createAttribute("ParentGUID")
    newAttr.value = o_.Parent.GUID
    nObj.setAttributeNode(newAttr)
  End If
  If o_.Uplinks.Count > 0 Then
    Set nUplinks = nObj.appendChild(xmlParser.createNode(1, "Uplinks", ""))
    For Each u_ In o_.Uplinks
      Set nUplink = nUplinks.appendChild(xmlParser.createNode(1, "Uplink", ""))
      Set newAttr = xmlParser.createAttribute("UplinkGUID")
      newAttr.value = u_.GUID
      nUplink.setAttributeNode(newAttr)
    Next
  End If
'Собираем используемые классификаторы
  For Each a_ In o_.Attributes
    If a_.AttributeDef.Type = tdmClassifier Or a_.AttributeDef.Type = tdmList Then
      If Not Classifs.Has(a_.AttributeDef.Classifier) Then Classifs.Add a_.AttributeDef.Classifier
      If Not a_.Classifier Is Nothing Then
        If Not Classifs.Has(a_.Classifier) Then Classifs.Add a_.Classifier
      End If
  'Собираем используемых пользователей по атрибутам
    ElseIf a_.AttributeDef.Type = tdmUserLink Then
      If Not ThisObject.Attributes("ATTR_A_FIRST_EXPORT").Value Then
        If Not a_.User Is Nothing Then
          If Not cUsers.Has(a_.User) Then cUsers.Add a_.User
        End If
      End If
    End If
  Next
  'Собираем используемых пользователей по ролям
  If Not ThisObject.Attributes("ATTR_A_FIRST_EXPORT").Value Then
    For Each r_ In o_.Roles
      If Not r_.User Is Nothing Then
        If Not cUsers.Has(r_.User) Then cUsers.Add r_.User
      End If
    Next
  End If
Next
xmlParser.save(sBindFileName)
'Передаем классификаторы для записи
sClsFileName = Left(sBindFileName, Len(sBindFileName) - 9) + "_cls.xml"
ThisApplication.ExecuteScript ThisApplication.Commands("CMD_A_EXPORT_CLASSIFIERS"), "Main", Classifs, sClsFileName
oRep.Attributes("ATTR_A_SYNCH_LIST_ROW_CLASS").Value = Classifs.Count
'Передаем пользователей для записи
sUserFileName = Left(sBindFileName, Len(sBindFileName) - 9) + "_user.xml"
'ThisApplication.ExportUsers sUserFileName, cUsers
ThisApplication.ExecuteScript ThisApplication.Commands("CMD_A_EXPORT_USERS"), "Main", cUsers, sUserFileName
oRep.Attributes("ATTR_A_SYNCH_LIST_ROW_USERS").Value = cUsers.Count
End Sub
