' $Workfile: COMMAND.SCRIPT.CMD_PROJECT_EXPORT.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Экспорт проектной документации
'------------------------------------------------------------------------------

Option Explicit
Public Path, oTable, fTable,pFileSysObj,bExportType,Root,ExportAll

'******************************************************************************************************************
' Данная команда предназначена для выгрузки проекта или его части в HTML структуру
'******************************************************************************************************************
Const AttrIconIndex = 40
Dim ObjDict
Dim TreeFile, TreeLevel
Dim SetupIconsPath
' bitCount - 32 битные иконки (0) 24 бит (1) К сожалению с текущей версией контрола работают только 24 битные иконки
Const bitCount = 1
Dim ContentObjCount
Dim TProgress
Dim tDict
Dim fs, SrcFile
Dim StrToCheckOut
Dim Level
Dim Progress
Dim oReg
Dim arrayLog
Dim Setup
Dim Templates
Dim EditTemplate, SelOk
Dim tError
Dim fCheck

' Перечисление возможный типов атрибутов TDMS. В версии 2.0 "Таблица" отсутствует
Dim TdmTypesArray
  TdmTypesArray = Array("Строка", "Целое число", "Вещественное число", "Логическое значение", _
  "Целое 64-битное число", "Дата", "Классификатор", "Ссылка на объект", "Список значений", _
  "Ссылка на пользователя", "Ссылка на файл", "Таблица")

Set fs = CreateObject("Scripting.FileSystemObject")
Set ObjDict = CreateObject("Scripting.Dictionary")
Set Progress = ThisApplication.Dialogs.ProgressDlg
Progress.Start

SelOk = False
fCheck = ""

'-----------Old Code--------------------
'Set Templates = ThisApplication.ObjectDefs("OBJECT_DOCS_EXP").Objects.Item(0)
'Set EditTemplate = ThisApplication.Dialogs.EditObjectDlg
'  EditTemplate.Object = Templates
'  If (Not ThisObject Is Nothing) And (ThisObject.GUID <> ThisApplication.Desktop.GUID) And _
'  (ThisObject.GUID <> ThisApplication.Root.GUID) Then 
'    Templates.Attributes("ATTR_DOCS_EXP_ROOT").Object = ThisObject
'  Else
'    Templates.Attributes("ATTR_DOCS_EXP_ROOT").Object = Nothing
'  End If
'  While SelOk <> True
'    If EditTemplate.Show = False Then 
'      SelOk = True
'    Else
'      fCheck=CheckFolder(Templates.Attributes("ATTR_DOCS_EXP_PATH"))
'      If fCheck <> "" Then
'        MsgBox fCheck
'      ElseIf Templates.Attributes("ATTR_DOCS_EXP_ROOT").Object Is Nothing Then 
'        MsgBox "Не выбран корневой объект"
'      Else
'        SelOk = True
'        ' Путь
'        Path = Templates.Attributes("ATTR_DOCS_EXP_PATH")
'        ' Корневой объект
'        Set Root = Templates.Attributes("ATTR_DOCS_EXP_ROOT").Object
'        ' Таблица типов документов
'        Set oTable = Templates.Attributes("ATTR_DOCS_EXP_DOC_TYPE").Rows
'        ' Таблица типов Файлов
'        Set fTable = Templates.Attributes("ATTR_DOCS_EXP_FILE_TYPE").Rows
'        ' Проверка формата выгрузки
'        If Templates.Attributes("ATTR_DOCS_EXP_FORMAT").Classifier.SysName = "NODE_DOCS_EXP_FORMAT_HTML" Then
'          Call Main()
'        Else
'          Call FoldersExport(Root)
'        End If
'      End If
'    End If
'  Wend
'--------------------------------------------------
'----------New Code--------------------------------
Set tDict = ThisApplication.Dictionary
  If tDict.Exists("CMD_EXPORT") Then
    tDict("CMD_EXPORT") = arrayLog
  Else
    tDict.Add "CMD_EXPORT", arrayLog
  End If
Set Templates = ThisApplication.CurrentUser
 If (Not ThisObject Is Nothing) And (ThisObject.GUID <> ThisApplication.Desktop.GUID) And _
 (ThisObject.GUID <> ThisApplication.Root.GUID) Then 
   Templates.Attributes("ATTR_DOCS_EXP_ROOT").Object = ThisObject
 Else
   Templates.Attributes("ATTR_DOCS_EXP_ROOT").Object = Nothing
 End If

  While SelOk <> True
    Set EditTemplate = ThisApplication.InputForms("FORM_DOCS_EXP")
    If EditTemplate.Show = False Then 
      SelOk = True
    Else
      SaveChanges EditTemplate
      fCheck = CheckFolder(Templates.Attributes("ATTR_DOCS_EXP_PATH"))
      If fCheck <> "" Then
        MsgBox fCheck
      ElseIf Templates.Attributes("ATTR_DOCS_EXP_ROOT").Object Is Nothing Then 
        MsgBox "Не выбран корневой объект"
      Else
        If Templates.Attributes("ATTR_DOCS_EXP_FORMAT") = "" Then
          MsgBox "Не выбран формат выгрузки!"
        Else
          SelOk = True
          ' Путь
          Path = Templates.Attributes("ATTR_DOCS_EXP_PATH")
          ' Корневой объект
          Set Root = Templates.Attributes("ATTR_DOCS_EXP_ROOT").Object
          ' Если включен флаг "выгружать всё" то таблица не используются
          ' Таблица типов документов
          Set oTable = Templates.Attributes("ATTR_DOCS_EXP_DOC_TYPE").Rows
          ' Таблица типов Файлов
          Set fTable = Templates.Attributes("ATTR_DOCS_EXP_FILE_TYPE").Rows
          ' Проверка формата выгрузки
          ExportAll = Templates.Attributes("ATTR_DOCS_EXP_ALL")
          If Templates.Attributes("ATTR_DOCS_EXP_FORMAT").Classifier.SysName = "NODE_DOCS_EXP_FORMAT_HTML" Then
            Call Main()
            'MsgBox UBound(tDict("CMD_EXPORT"))
            arrayLog = tDict("CMD_EXPORT")
            For Each tError In tDict("CMD_EXPORT")
              ThisApplication.AddNotify tError
            Next
          Else
            Call FoldersExport(Root)
          End If
        End If
      End If
    End If
  Wend
tDict.Remove "CMD_EXPORT"
Progress.Stop
Set fs = Nothing
Set Progress = Nothing

'******************************************************************************************************************
' Данная процедура выводит меню настроек экспорта и собирает всю информацию по заданным параметрам
'******************************************************************************************************************
Sub Main()
Dim SelObjType, TObj
Dim SelFolder
Dim i, SelOk
Dim oShell, oFolder, oFolderItem
Dim ObjDefArrayBound
SelOk = False
StrToCheckOut = Path
  Set SelObjType = ThisApplication.Dialogs.SelectObjectDlg
    SelObjType.Caption = "TDMS HTML Export"
    SelObjType.Prompt = "Выберите корневой объект для экспорта"
    SelObjType.Objects.Add Root
      If Right(StrToCheckOut,1) <> "\" Then
        StrToCheckOut=StrToCheckOut & "\"
      End If
      StrToCheckOut = StrToCheckOut & Root.Description & "\"
      On Error Resume Next
        fs.CreateFolder(StrToCheckOut)
        fs.CreateFolder(StrToCheckOut & "Icons\")
        fs.CreateFolder(StrToCheckOut & "Files\")
      On Error GoTo 0
      ThisApplication.Utility.WaitCursor = True
      Progress.Position=1
      Progress.Text="Создание структуры выгружаемых данных"
      Call TemplatesCheckOut
      Progress.Position=3
      TProgress = 3
      Progress.Text="Анализ структуры данных"
      ' Создаём основной файл экспорта tree.js
      Set TreeFile = fs.CreateTextFile(StrToCheckOut & "tree.js", True)
      WrLn TreeFile, "// You can find instructions for this file here:" & vbCrLf & _
        "// http://www.treeview.net" & vbCrLf & _
        "// Decide if the names are links or just the icons" & vbCrLf & _
        "HIGHLIGHT = 1" & vbCrLf & _
        "USETEXTLINKS = 1  //replace 0 with 1 for hyperlinks" & vbCrLf & _
        "// Decide if the tree is to start all open or just showing the root folders" & vbCrLf & _
        "STARTALLOPEN = 0 //replace 0 with 1 to show the whole tree" & vbCrLf & _
        "ICONPATH = " & chr(39) & "icons/" & chr(39) & " //change if the gifs folder is a subfolder, for example:" & chr(39) & "images/" & chr(39) & vbCrLf
      WrLn TreeFile, "foldersTree = gFld(""<i>Objects</i>"", ""javascript:parent.op()"")" & vbCrLf
      WrLn TreeFile, "foldersTree.iconSrc = ICONPATH + """ & ThisApplication.FileDefs("FILE_HTML_EXPORT").Handle & ".ico""" & vbCrLf
      WrLn TreeFile, "foldersTree.xID = ""Root"""
      TreeLevel = 0
      ContentObjCount = CountAll(SelObjType.Objects)
      ' Формирование дерева объектов для экспорта
      Call CreateTree("foldersTree", SelObjType.Objects, TreeLevel)
      Progress.Position=99
      Progress.Text="Вывод дерева"
      TreeFile.Close
      ' Завершение работы программы. Обнуление всех объектный переменных и открытие файла экспорта
      Call OutputEnd
      Progress.Position=100
      Progress.Text="Экспорт завершен"
      ThisApplication.Utility.WaitCursor = False
End Sub

'******************************************************************************************************************
' Данная функция выгружает шаблоны файлов экспорта на диск
'******************************************************************************************************************
Sub TemplatesCheckOut
Dim HTMLExport, F
  Set HTMLExport = ThisApplication.FileDefs("FILE_HTML_EXPORT").Templates
  For Each F In HTMLExport
    If (Right(F.FileName, 4) <> "html") And (Right(F.FileName, 2) <> "js") Then
      F.CheckOut StrToCheckOut & "Icons\" & F.FileName
    Else 
      F.CheckOut StrToCheckOut & F.FileName
    End If
  Next
  ThisApplication.FileDefs("FILE_HTML_EXPORT").Icon.SaveIcon StrToCheckOut & "Icons\" & ThisApplication.FileDefs("FILE_HTML_EXPORT").Handle & ".ico", bitCount
End Sub

'******************************************************************************************************************
' Процедура создаёт дерево экспорта проекта. В дереве может встречатся 5 типов записей:
' Folder : 1. Объект с составом 2. Ссылка на объект с составом 3. Объект "ступенька"
' (содержит экспортируемые типы объенктов, но сам не предназначен для экспорта)
' Node : 1. Объект без состава 2. Ссылка на объект без состава
' Теперь ещё и выборки надо зацепить
'******************************************************************************************************************
Sub CreateTree(ParentFolder, CObj, TreeLevel)
Dim tempObj, tempObjGUID, PFolder
For Each tempObj In CObj
PFolder = ParentFolder
tempObjGUID = CheckInDict(tempObj.Handle)
Select Case TypeName(tempObj)
  Case "ITDMSObject"
  If CheckObj(tempObj) = True Then ' Проверяет тип объекта
    If tempObj.Handle = tempObjGUID Then ' Проверяет на повторное вхождение в дерево (ссылка)
      If tempObj.Objects.Count <> 0 Then ' Проверка наличия состава
        PFolder = AddFolder(tempObjGUID, ParentFolder, TreeLevel, tempObj, 1)
        TreeLevel = TreeLevel + 1
        CreateTree PFolder, tempObj.Objects, TreeLevel
        If tempObj.Queries.Count <> 0 Then 
          CreateTree PFolder, tempObj.Queries, TreeLevel
        End If
      ElseIf tempObj.Queries.Count <> 0 Then 
        PFolder = AddFolder(tempObjGUID, ParentFolder, TreeLevel, tempObj, 3)
        TreeLevel = TreeLevel + 1
        CreateTree PFolder, tempObj.Queries, TreeLevel
      Else
        AddNode tempObjGUID, PFolder, tempObj, 1
      End If
    Else
      If tempObj.Objects.Count <> 0 Then
        PFolder = AddFolder(tempObjGUID, PFolder, TreeLevel, tempObj, 2)
        TreeLevel = TreeLevel + 1
        CreateTree PFolder, tempObj.Objects, TreeLevel
        If tempObj.Queries.Count <> 0 Then 
          CreateTree PFolder, tempObj.Queries, TreeLevel
        End If
      ElseIf tempObj.Queries.Count <> 0 Then 
        PFolder = AddFolder(tempObjGUID, ParentFolder, TreeLevel, tempObj, 3)
        TreeLevel = TreeLevel + 1
        CreateTree PFolder, tempObj.Queries, TreeLevel
      Else
        AddNode tempObjGUID, PFolder, tempObj, 2
      End If      
    End If
  End If
  Case "ITDMSQuery"
      If tempObj.Objects.Count <> 0 Then ' Проверка наличия состава
        PFolder = AddFolder(tempObjGUID, ParentFolder, TreeLevel, tempObj, 3)
        TreeLevel = TreeLevel + 1
        CreateTree PFolder, tempObj.Objects, TreeLevel
      End If
End Select
Next
End Sub

'******************************************************************************************************************
' Добавляет объект без состава в дерево и создаёт соответствующие файлы.
' 1. Первое вхождение объекта
' 2. Повторное вхождение (ссылка)
'******************************************************************************************************************
Sub AddNode(xID, Parent, AddObj, AddType)
Dim iconFileName, str, tempObjGUID, objDescription
iconFileName = AddObj.Icon.Handle & ".ico"
str = StrToCheckOut & "Icons\" & iconFileName
If fs.FileExists(str) = False Then AddObj.Icon.SaveIcon Str, 1
tempObjGUID = AddObj.GUID
If Right(AddObj.Description, 1) = "\" Then
  objDescription = AddObj.Description & "\"
Else
  objDescription = AddObj.Description
End If
Select Case AddType
  Case "1"
    WrLn TreeFile, "docAux = insDoc(" & Parent & ", gLnk(""S"", " & chr(39) & objDescription & chr(39) & _
    ", ""javascript:loadFrames(" & FilesCreate(AddObj) & ")""))"
    WrLn TreeFile, "docAux.iconSrc = ICONPATH + """ & iconFileName & """"
    WrLn TreeFile, "docAux.xID = """ & xID & """"
    TProgress = TProgress + 95/(ContentObjCount + 1)
    Progress.Position = CInt(TProgress)
    Progress.Text = "Выгрузка структуры данных и файлов. Завершено: " & CInt(TProgress) & "%" 
  Case "2"
    WrLn TreeFile, "docAux = insDoc(" & Parent & ", gLnk(""S"", " & chr(39) & objDescription & chr(39) & _
    ", ""javascript:loadRefPage(" & chr(39) & tempObjGUID & chr(39) & ")""))"
    WrLn TreeFile, "docAux.iconSrc = ICONPATH + """ & iconFileName & """"
    WrLn TreeFile, "docAux.xID = """ & xID & """"   
End Select
End Sub

'******************************************************************************************************************
' Добавляет объект с составом в дерево и создаёт соответствующие файлы.
' 1. Первое вхождение объекта
' 2. Повторное вхождение (ссылка)
' 3. "Ступенька"/
' 4. Выборка
' Возвращает имя последней родительской записи
'******************************************************************************************************************
Function AddFolder(xID, Parent, Level, AddObj, AddType)
Dim iconFileName, str, tempObjGUID, objDescription
iconFileName = AddObj.Icon.Handle & ".ico"
str = StrToCheckOut & "Icons\" & iconFileName
' Поправить на проверку выгруженной иконки в текущем сеансе
If fs.FileExists(str) = False Then AddObj.Icon.SaveIcon Str, 1
If Right(AddObj.Description, 1) = "\" Then
  objDescription = AddObj.Description & "\"
Else
  objDescription = AddObj.Description
End If
Select Case AddType
  Case "1"
    WrLn TreeFile, "aux" & Level & " = insFld(" & Parent & ", gFld(" & chr(39) & objDescription & chr(39) & _
      ", ""javascript:loadFrames(" & FilesCreate(AddObj) & ")""))"
    WrLn TreeFile, "aux" & Level & ".iconSrc = ICONPATH + """ & iconFileName & """"
    WrLn TreeFile, "aux" & Level & ".iconSrcClosed = ICONPATH + """ & iconFileName & """"   
    WrLn TreeFile, "aux" & Level & ".xID=""" & xID & """"
    TProgress = TProgress + 95/ContentObjCount
    Progress.Position = CInt(TProgress)
    Progress.Text = "Выгрузка структуры данных и файлов. Завершено: " & CInt(TProgress) & "%" 
  Case "2"
    WrLn TreeFile, "aux" & Level & " = insFld(" & Parent & ", gFld(" & chr(39) & objDescription & chr(39) & _
      ", ""javascript:loadRefPage(" & chr(39) & AddObj.GUID & chr(39) & ")""))"
    WrLn TreeFile, "aux" & Level & ".iconSrc = ICONPATH + """ & iconFileName & """"
    WrLn TreeFile, "aux" & Level & ".iconSrcClosed = ICONPATH + """ & iconFileName & """"   
    WrLn TreeFile, "aux" & Level & ".xID=""" & xID & """"   
  Case "3"
    WrLn TreeFile, "aux" & Level & " = insFld(" & Parent & ", gFld(" & chr(39) & objDescription & chr(39) & _
      ", ""javascript:loadFrames(" & chr(39) & "blank.html" & chr(39) & "," & chr(39)& "blank.html" _
      & chr(39) & ", "& chr(39) & "blank.html" & chr(39) & ")""))"
    WrLn TreeFile, "aux" & Level & ".iconSrc = ICONPATH + """ & iconFileName & """"
    WrLn TreeFile, "aux" & Level & ".iconSrcClosed = ICONPATH + """ & iconFileName & """"   
    WrLn TreeFile, "aux" & Level & ".xID=""" & xID & """"
End Select
AddFolder = "aux" & Level
End Function

'******************************************************************************************************************
' Создаёт файлы объекта
'******************************************************************************************************************
Function FilesCreate(AddObj)
Dim RetStr, tExportedFile, tFile
tExportedFile = ""
  RetStr = Chr(39) & CreateAttrFile(AddObj) & Chr(39)
  RetStr = RetStr & "," & Chr(39) & FilesTableCreate(AddObj) & Chr(39)
  If AddObj.Files.Count > 0 Then
    If CheckFile(AddObj.Files.Main) = True Then
      RetStr = RetStr & "," & Chr(39) & "Files/" & AddObj.GUID & "/" & AddObj.Files.Main.FileName & Chr(39)
    Else
      For Each tFile In AddObj.Files
        If CheckFile(tFile) = True Then 
          tExportedFile = tFile.FileName
          Exit For
        End If
      Next
      'MsgBox tExportedFile
      If tExportedFile = "" Then
        RetStr = RetStr & "," & Chr(39) & "blank.html" & Chr(39)
      Else
        RetStr = RetStr & "," & Chr(39) & "Files/" & AddObj.GUID & "/" & tExportedFile & Chr(39)
      End If
    End If
  Else
    RetStr = RetStr & "," & Chr(39) & "blank.html" & Chr(39)
  End If
  FilesCreate = RetStr
End Function

'******************************************************************************************************************
' Создаёт файл таблицы аттрибутов объекта CreateFile
' Функция возвращает полное имя созданного файла
'******************************************************************************************************************
Function CreateAttrFile(CreateFile)
Dim str
Dim Attr
  On Error Resume Next
    fs.CreateFolder(StrToCheckOut & "Files\" & CreateFile.GUID & "\")
  On Error GoTo 0

  str = StrToCheckOut & "Files\" & CreateFile.GUID & "\" & CreateFile.GUID & ".htm"
  Set SrcFile = fs.CreateTextFile(str, True)
  WrLn SrcFile, "<html>" & vbCrLf & _
    "<head>" & vbCrLf & _
    "<title>Attributes</title>" & vbCrLf & _
    "</head>" & vbCrLf & _
    "<style>TD {white-space:nowrap;}</style>" & vbCrLf & _
    "<body topmargin=""0"" leftmargin=""0"" bgcolor=""#FFFFFF"" text=""#000000"">" & vbCrLf
  WrLn SrcFile, "<script src=" & chr(39) & "..\..\ftiens4.js"& chr(39) & "></script>" & vbCrLf
  WrLn SrcFile, "<table border=""1"" bgcolor=""#FFFFFF"" cellspacing=""0"" cellpadding=""1"" bordercolor=""#FFFFFF"" style=""font-family: sans-serif; font-size:8pt;"">"
    WrLn SrcFile, "<tr style=""BACKGROUND: threedface"">"
    WrLn SrcFile, "<td width=""60%"" bordercolorlight=""#808080"" bordercolordark=""#FFFFFF"">Атрибут</td>"
    WrLn SrcFile, "<td width=""20%"" bordercolorlight=""#808080"" bordercolordark=""#FFFFFF"">Тип данных</td>"
    WrLn SrcFile, "<td width=""20%"" bordercolorlight=""#808080"" bordercolordark=""#FFFFFF"">Значение</td>"
  WrLn SrcFile, "</tr>" & vbCrLf
  ' Для аттрибутов типа "Ссылка на объект" и "Таблица" предусмотрен отдельный механизм
    For Each Attr In CreateFile.Attributes
        WrLn SrcFile, "<tr bgcolor=""#FFFFFF"" bordercolorlight=""#FFFFFF"" bordercolordark=""#FFFFFF"">"
          WrLn SrcFile, "<td width=""60%"">" & Attr.AttributeDef.Description & "</td>"
          Select Case Attr.AttributeDef.Type
            Case 7
            ' Если ссылка на объект не пустая, добавляет гиперлинк на соответствующий объект в дереве
              If Not Attr.Object Is Nothing Then
                WrLn SrcFile, "<td width=""20%""><a href=""javaScript:loadSynchPage(" & Chr(39) & Attr.Object.GUID & Chr(39) & ")"">"_
                  & TdmTypesArray(Attr.AttributeDef.Type) & "</td>"
                WrLn SrcFile, "<td width=""20%"">" & Attr.Value & "</td>"
              Else
                WrLn SrcFile, "<td width=""20%""><a href=""javaScript:loadSynchPage(" & Chr(39) & Chr(39) & ")"">"_
                  & TdmTypesArray(Attr.AttributeDef.Type) & "</td>"
                WrLn SrcFile, "<td width=""20%"">" & Attr.Value & "</td>"             
              End If
            Case 11
            ' Для атрибута типа "Таблица" содаётся дополнительный файл и добавлеятся ссылка на него
              WrLn SrcFile, "<td width=""20%""><a href=""javascript:popup(" & Chr(39)_
               &  CreateTFile(StrToCheckOut & "Files\" & CreateFile.GUID & "\",Attr.Rows) & Chr(39)_
                & ")"">" & TdmTypesArray(Attr.AttributeDef.Type) & "</td>"
            Case Else
              WrLn SrcFile, "<td width=""20%"">" & TdmTypesArray(Attr.AttributeDef.Type) & "</td>"
              WrLn SrcFile, "<td width=""20%"">" & Attr.Value & "</td>"
          End Select
        WrLn SrcFile, "</tr>"
    Next
  WrLn SrcFile, "</table>" & vbCrLf
  WrLn SrcFile, "</body>" & vbCrLf & "</html>"
  SrcFile.Close
  CreateAttrFile = "Files/" & CreateFile.GUID & "/" & CreateFile.GUID & ".htm"
End Function

'******************************************************************************************************************
' Функция создаёт файл с таблицей файлов объекта
' Функция возвращает полное имя созданного файла
'******************************************************************************************************************
Function FilesTableCreate(CreateFile)
Dim str
Dim InnerFile, iconFileName
  str = StrToCheckOut & "Files\" & CreateFile.GUID & "\" & "Table.htm"
  Set SrcFile = fs.CreateTextFile(str, True)
  WrLn SrcFile, "<html>" & vbCrLf & _
    "<meta http-equiv=""Content-Type"" content=""text/html; charset=windows-1251"">" & vbCrLf & _
    "<head>" & vbCrLf & _
    "</head>" & vbCrLf & _
    "<style>TD {white-space:nowrap;}</style>" & vbCrLf & _
    "<body topmargin=""0"" leftmargin=""0"" bgcolor=""#FFFFFF"" text=""#000000"">" & vbCrLf
  WrLn SrcFile, "<table border=""1"" bgcolor=""#FFFFFF"" cellspacing=""0"" cellpadding=""1"" bordercolor=""#FFFFFF"" style=""font-family: sans-serif; font-size:8pt;"">"
  WrLn SrcFile, "<tr style=""BACKGROUND: threedface"">"
    WrLn SrcFile, "<td width=""2%"" bordercolorlight=""#808080"" bordercolordark=""#FFFFFF"">&nbsp;</td>"
    WrLn SrcFile, "<td width=""48%"" bordercolorlight=""#808080"" bordercolordark=""#FFFFFF"">Имя</td>"
    WrLn SrcFile, "<td width=""10%"" bordercolorlight=""#808080"" bordercolordark=""#FFFFFF"" align=""right"">Размер</td>"
    WrLn SrcFile, "<td width=""20%"" bordercolorlight=""#808080"" bordercolordark=""#FFFFFF"">Тип</td>"
    WrLn SrcFile, "<td width=""20%"" bordercolorlight=""#808080"" bordercolordark=""#FFFFFF"">Изменён</td>"
  WrLn SrcFile, "</tr>" & vbCrLf
    For Each InnerFile In CreateFile.Files
      If CheckFile(InnerFile) = True Then
        iconFileName = InnerFile.FileDef.SysName & ".ico"
        str = StrToCheckOut & "Icons\" & iconFileName
        If fs.FileExists(str) = False Then InnerFile.FileDef.Icon.SaveIcon Str, 1
        InnerFile.CheckOut StrToCheckOut & "Files\" & CreateFile.GUID & "\" & InnerFile.FileName
        WrLn SrcFile, "<tr bgcolor=""#FFFFFF"" bordercolorlight=""#FFFFFF"" bordercolordark=""#FFFFFF"">"
        WrLn SrcFile, "<td width=""2%""><img src=" & chr(39) & "..\..\" & "Icons\" & InnerFile.FileDef.SysName & ".ico" & chr(39) & "></td>"
        WrLn SrcFile, "<td width=""48%"">" & _
              "<a href=" & chr(39) & InnerFile.FileName & chr(39) & _
              "target=" & chr(39) & "basefrm" & chr(39) & ">" & InnerFile.FileName & "</a></td>" & vbCrLf
        WrLn SrcFile, "<td width=""10%"" align=""right"">" & BytesToKb(InnerFile.Size) & "KB</td>"
        WrLn SrcFile, "<td width=""20%"">" & InnerFile.FileDef.Description & "</td>"
        WrLn SrcFile, "<td width=""20%"">" & InnerFile.ModifyTime & "</td>"
        WrLn SrcFile, "</tr>"
      End If
    Next
  WrLn SrcFile, "</table>" & vbCrLf
  WrLn SrcFile, "</body>" & vbCrLf & "</html>"
  SrcFile.Close
  FilesTableCreate = "Files/" & CreateFile.GUID & "/Table.htm"
End Function

'******************************************************************************************************************
' Завершение экспорта и открытие файла для просмотра
'******************************************************************************************************************
Sub OutputEnd()
Dim shl
  Set shl = CreateObject("WScript.Shell")
  shl.run """" & StrToCheckOut & "Export.html""" , 0, 0
  Set shl = Nothing
End Sub

'******************************************************************************************************************
' Функция записывает в файл SrcFile строку AddingString
'******************************************************************************************************************
Sub WrLn(SrcFile, AddingString)
  SrcFile.writeline (AddingString)
End Sub

'******************************************************************************************************************
'******************************************************************************************************************
Function BytesToKb(Num)
  Num=Num\1024
  BytesToKb=Num
End Function

'******************************************************************************************************************
' Проверяет есть ли данный тип документа в массиве настроек
'******************************************************************************************************************
Function CheckObj(Obj)
Dim tRow
If ExportAll = True Then
  CheckObj = True
Else
  CheckObj = False
    For Each tRow In oTable
      ' Документ КОРАДО
      If Obj.ObjectDefName = "OBJECT_DOCUMENT" Then
        If tRow.Attributes("ATTR_DOCS_EXP_DOC_TYPE_FLAG") And _
          Obj.Attributes("ATTR_DOCUMENT_TYPE") = tRow.Attributes("ATTR_DOCS_EXP_DOC_TYPE_NAME") Then
          CheckObj = True
          Exit Function
        End If
        If EditTemplate.Attributes("ATTR_DOCS_EXP_UNDEF") And Obj.Attributes("ATTR_DOCUMENT_TYPE")= "" Then ' !!! Добавлено
          CheckObj = True ' !!! Добавлено
          Exit Function ' !!! Добавлено        
        End If ' !!! Добавлено
      Else
        CheckObj = True
      End If       
    Next
End If
End Function

'******************************************************************************************************************
' Проверяет есть ли данный тип файла в массиве настроек
'******************************************************************************************************************
Function CheckFile(File)
Dim tRow
If ExportAll = True Then
  CheckFile = True
Else
  CheckFile = False
  For Each tRow In fTable
    If tRow.Attributes("ATTR_DOCS_EXP_FILE_TYPE_FLAG") And _
      tRow.Attributes("ATTR_DOCS_EXP_FILE_TYPE_ID") = File.FileDef.SysName Then
      CheckFile = True
      Exit Function
    End If
  Next
End If
End Function

'******************************************************************************************************************
' Создаёт таблицу полей и значений аттрибута типа "таблица" TableAttr
'******************************************************************************************************************
Function CreateTFile(tPath, TableAttr)
Dim TDCount, str
Dim SrcFile
Dim tRow, tAttr, AttrDef
  TDCount = TableAttr.AttributeDefs.Count
  str = tPath & "TableAttr.htm"
  Set SrcFile = fs.CreateTextFile(str, True)
  SrcFile.writeline( "<html>" & vbCrLf & _
    "<head>" & vbCrLf & _
    "<title>Attributes</title>" & vbCrLf & _
    "</head>" & vbCrLf & _
    "<style>TD {white-space:nowrap;}</style>" & vbCrLf & _
    "<body topmargin=""0"" leftmargin=""0"" bgcolor=""#FFFFFF"" text=""#000000"">" & vbCrLf)
  SrcFile.writeline("<table border=""1"" width=""500"" bgcolor=""#FFFFFF"" cellspacing=""0"" cellpadding=""1"" bordercolor=""#FFFFFF"" style=""font-family: sans-serif; font-size:8pt;"">")
    SrcFile.writeline("<tr style=""BACKGROUND: threedface"">")
    For Each AttrDef In TableAttr.AttributeDefs
      SrcFile.writeline("<td width=""" & 100/TDCount & "%"" bordercolorlight=""#808080"" bordercolordark=""#FFFFFF"">"_
       & AttrDef.Description & "</td>")
    Next
  SrcFile.writeline("</tr>" & vbCrLf)
  For Each tRow In TableAttr
    SrcFile.writeline("<tr bgcolor=""#FFFFFF"" bordercolorlight=""#FFFFFF"" bordercolordark=""#FFFFFF"">")
    For Each tAttr In tRow.Attributes
      SrcFile.writeline("<td width=""" & 100/TDCount & "%"">" & tAttr.Value & "</td>")
    Next
    SrcFile.writeline("</tr>")
  Next  
  SrcFile.writeline("</table>" & vbCrLf)
  SrcFile.writeline("</body>" & vbCrLf & "</html>")
  SrcFile.Close
  CreateTFile="TableAttr.htm"
End Function

'******************************************************************************************************************
' Проверяет первое ли вхождение объекта в дерево (ссылка)
'******************************************************************************************************************
Function CheckInDict(ObjGuid)
  If ObjDict.Exists(ObjGuid) Then
    ObjDict(ObjGuid)=ObjDict(ObjGuid)+1
    CheckInDict = ObjGuid & ObjDict(ObjGuid)
  Else
    ObjDict.Add ObjGuid, 0
    CheckInDict = ObjGuid
  End If
End Function

'******************************************************************************************************************
' Подсчитывает колличество выгружаемых экспортом объектов, для корректной работы окна Progress Dialog
'******************************************************************************************************************
Function CountAll(ColObj)
Dim Counter, TObj, i
Counter = 0
CountAll = 0
  For Each TObj In ColObj
    CountAll = CountAll + tObj.ContentAll.Count
  Next
End Function
'******************************************************************************************************************

'******************************************************************************************************************
' Проверка папки
'******************************************************************************************************************
Function CheckFolder(tPath)
Dim testFile
CheckFolder = ""
If fs.FolderExists(tPath) = False Then
  CheckFolder = "Папка не найдена"
Else
  On Error Resume Next
    Err = 0
    Set testFile = fs.CreateTextFile(tPath & "test.txt", True)
    If Err <> 0 Then       
      CheckFolder = "Отсутствуют права"
    Else       
      testFile.Delete
    End If
  On Error GoTo 0
End If
End Function




'==============================================================================
' Метод экспортирует ветку дерева в виде структуры папок
' (главный метод)
'------------------------------------------------------------------------------
' o_:TDMSObject - Выгружаемый текущий информационный объект (ИО)
'==============================================================================
Sub FoldersExport(o_)
  Dim pRootFolder ':Folder - Указатель на папку выгрузки
   Set pFileSysObj = CreateObject("Scripting.FileSystemObject")
   Set pRootFolder = pFileSysObj.GetFolder(Path)
   Call ExportRec(o_,pRootFolder)
   MsgBox "Экспорт завершен!",vbInformation, "Экспорт"
End Sub

'==============================================================================
' Функция экспортирует ветку дерева в виде структуры папок
' (рекурсивный проход по структуре)
'------------------------------------------------------------------------------
' o_:TDMSObject - Выгружаемый текущий информационный объект (ИО)
' pFolder_:Folder - Ссылка на текущую папку (папка в состав которой 
'                   экспортируется текущий ИО)
' ExportRec:TDMSObject - Выгруженный текущий информационный объект (ИО)
'==============================================================================
Private Function ExportRec(o_,pFolder_)
  Dim oCurExpObj ':TDMSObject - Выгружаемый текущий информационный объект (ИО)
  Dim pNewFolder ':Folder - Ссылка на созданную папку (результат экспорта ИО)
  Dim pSubFolders ':Folders - Колекция подпапок
  Dim sFolderName ':String - Имя создаваемой папки выгрузки текущего ИО
  Dim f,o
  ' Присвоение oCurExpObj для сохранение ссылки при рекурсивном вызове
  
  Set oCurExpObj = o_
  sFolderName = GetFolderName(o_)
  Set pSubFolders = pFolder_.SubFolders
  ' Ограничения Windows, 256 символов на полный путь
  If Len(pFolder_.path&"\"&sFolderName)>256 Then
    MsgBox "Полное имя папки превышает 256 символов"& chr(10) & pFolder_.path&"\"&sFolderName, vbExclamation, "Экспорт"
  Else 
    If Not pFileSysObj.FolderExists(pFolder_.path&"\"&sFolderName) Then
      Set pNewFolder = pSubFolders.Add(sFolderName)
    Else  
      Set pNewFolder = pFileSysObj.GetFolder(pFolder_.path&"\"&sFolderName)
    End If  
    o_.Permissions = SysAdminPermissions
    If o_.files.count > 0 Then
      For Each f In o_.Files
        ' Проверка условия выгрузки файлов
        If CheckFile(f) Then
          ' Ограничения Windows, 256 символов на полный путь
          If Len(pNewFolder.path&"\"&f.FileName)>256 Then
            MsgBox "Полное имя файла превышает 256 символов"& chr(10) & pNewFolder.path&"\"&f.FileName, vbExclamation, "Экспорт"
          Else
            ' Проверка наличия одноименного файла с в папке
            If Not pFileSysObj.FileExists(pNewFolder.path&"\"&f.FileName) Then          
              f.CheckOut pNewFolder.path&"\"&f.FileName
            Else
              MsgBox "Одноименный файл "&FileName&" уже существует. Файл не выгружен!!!"
            End If
          End If
        End If
      Next
    End If    
    For Each o In o_.Objects  
      ' Проверка условия выгрузки ИО
      If CheckObj(o) Then Set o = ExportRec(o,pNewFolder)
    Next  
'       MsgBox "Имя папки "&sFolderName&" уже существует. Объект не выгружен!!!"
  End If  
  Set ExportRec = oCurExpObj
End Function 

'==============================================================================
' Функция возвращает имя присваеваемое папке 
' (в данном варианте исполнения функции Имя папки = Описанию ИО)
'------------------------------------------------------------------------------
' o_:TDMSObject - Выгружаемый информационный объект (ИО)
' GetFolderName:String - имя присваеваемое папки
'==============================================================================
Private Function GetFolderName(o_)
  Dim str
  ' Проверка вида документа
  If o_.Attributes.Has("ATTR_DOC_TYPE") Then
    str = o_.Attributes("ATTR_DOC_TYPE")
    If str = "" Then str= "Другие"
  Else
    str = o_.Description
  End If  
  GetFolderName = CheckFolderName(str)
End Function

'==============================================================================
' Функция преобразовывает запрещенные для использования символы 
' в имени папки\файла
'------------------------------------------------------------------------------
' str_:String - проверяемое имя папки\файла
' CheckFolderName:String - преобразованное имя папки\файла
'==============================================================================
Private Function CheckFolderName(str_)
  str_ = Replace(str_,"\","_",1,-1,vbTextCompare)
  str_ = Replace(str_,"/","_",1,-1,vbTextCompare)
  str_ = Replace(str_,":","_",1,-1,vbTextCompare)
  str_ = Replace(str_,"*","_",1,-1,vbTextCompare)
  str_ = Replace(str_,"?","_",1,-1,vbTextCompare)
  str_ = Replace(str_,"""","_",1,-1,vbTextCompare)
  str_ = Replace(str_,"|","_",1,-1,vbTextCompare) 
  str_ = Left(str_, 80)
  CheckFolderName = str_
End Function

'==============================================================================
' Функция предоставляет диалог выбора папки
'------------------------------------------------------------------------------
' GetFolder:String - Полный путь к выбранной папке
'==============================================================================
Private Function GetFolder()
  Const MY_COMPUTER = &H11&
  Const WINDOW_HANDLE = 0
  Const OPTIONS = 0
  objPath = " "
  Set objShell = CreateObject("Shell.Application")
  Set objFolder = objShell.Namespace(MY_COMPUTER)
  Set objFolderItem = objFolder.Self
  strPath = objFolderItem.Path  
  Set objFolder = objShell.BrowseForFolder(WINDOW_HANDLE, "Select a folder:", OPTIONS, strPath)   
  If Not objFolder Is Nothing Then
     Set objFolderItem = objFolder.Self
      objPath = objFolderItem.Path  
  End If
  GetFolder = objPath
End Function

' ' Проверка условия выгрузки ИО
' Function CheckObject(o_)
'   Dim sDocType
'   CheckObject = True
'   If o_.ObjectDef.IsKindOf = ThisApplication.ObjectDefs("OBJECT_DOC") Then
'     sDocType = o_.Attributes("ATTR_DOCUMENT_TYPE").Classifier.Description
'     
'   End If
' End Function

' ' Проверка условия выгрузки файлов
' Function CheckFile(f_)
'   CheckFile = True
'   If f_.FileDefName = "FILE_TB_PREVIEW" Then 
'     CheckFile = False
'     Exit Function
'   End If
'   If bExportType = 7 And f_.FileDefName <> "FILE_DRW" Then CheckFile = False
' End Function

' Проверка корневого объекта выгружаемой ветки дерева
Function CheckRootObj(o_)
  Dim sObjDef
  CheckRootObj = False
  sObjDef = ""
  On Error Resume Next
    sObjDef = o_.ObjectDefName
  On Error GoTo 0
  If sObjDef = "" Or sObjDef = "ROOT_DEF" Then 
    MsgBox "Экспорт информационного объекта не возможен!"&Chr(10)&"Возможно вы пытаетесь экспортировать выборку или системный раздел", vbExclamation, "Экспорт"
    Exit Function
  End If
  CheckRootObj = True
End Function

Sub SaveChanges(tForm)
Dim tAttr, tRow, tRowAttr, nRow
For Each tAttr In tForm.Attributes
With ThisApplication.CurrentUser.Attributes
  Select Case tAttr.Type
    Case 11 ' Table
      ClearTable .Item(tAttr.AttributeDefName)
      For Each tRow In tAttr.Rows'.Item(tAttr.AttributeDefName).Rows
        Set nRow = .Item(tAttr.AttributeDefName).Rows.Create
        For Each tRowAttr In tRow.Attributes
          Select Case tRowAttr.Type
            Case 6
              nRow.Attributes(tRowAttr.AttributeDefName).Classifier = tRowAttr.Classifier
            Case Else
              nRow.Attributes(tRowAttr.AttributeDefName).Value = tRowAttr.Value
          End Select
        Next
      Next
    Case 6
      .Item(tAttr.AttributeDefName).Classifier = tAttr.Classifier
    Case 7
      .Item(tAttr.AttributeDefName).Object = tAttr.Object
    Case Else
      .Item(tAttr.AttributeDefName).Value = tAttr.Value
  End Select
End With
Next
End Sub

Sub ClearTable(tableAttr)
Dim tRow
For Each tRow In tableAttr.Rows
  tRow.Erase
Next
End Sub
