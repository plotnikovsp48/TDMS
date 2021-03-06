
USE CMD_SS_PROGRESS
USE CMD_SS_SYSADMINMODE

Call Go(ThisObject)

Private Sub Go(obj)
  ThisScript.SysAdminModeOn
  
  Set Progress = New CProgress
  Progress.SetRange 0, 6
  progress.Text = "Проверка начальных условий"
  
  'Определение объекта-контейнера для файла
  Set Target = LocateTarget(obj)
  If Target Is Nothing Then
    Msgbox "Отсутствует том #0.",vbCritical
    Exit Sub
  End If
  
  'Проверка наличия уже созданного файла
  AttrName = "ATTR_DOC_CODE"
  Fname = ""
  If Target.Attributes.Has(AttrName) Then
    If Target.Attributes(AttrName).Empty = False Then
      Fname = Target.Attributes(AttrName).Value & ".docx"
      Fname = ThisApplication.ExecuteScript("CMD_FILES_LIBRARY","CharsChange",Fname,"_")
    End If
  End If
  'If Target.Files.Has(Fname) Then
  '  Key = Msgbox("Заменить уже имеющийся файл?",vbQuestion+vbYesNo)
  '  If Key = vbYes Then
  '    Target.Files.Remove Target.Files(Fname)
  '    Target.SaveChanges
  '  Else
  '    Exit Sub
  '  End If
  'End If
  
  ThisApplication.Utility.WaitCursor = True
  
  Progress.Step
  Progress.Text = "Выгрузка шаблона"
  
  Path = DownloadTemplate(Target,Fname,"FILE_DOC_DOC")
  If Path = "" Then Exit Sub
  
  Progress.Step
  Progress.Text = "Подготовка шаблона"
    
  Set WordDoc = GetObject(Path)
  Set Bookmarks = WordDoc.Bookmarks
  
  'Проверка наличия закладок в шаблоне
  If Bookmarks.Exists("MainSection") = False or Bookmarks.Exists("Section2") = False Then
    Key = Msgbox("Невозможно обновить состав проекта в приложенном файле документа." & chr(10) & chr(10) &_
    "Состав проекта будет сгенерирован в отдельный файл. Продолжить?",vbQuestion+vbYesNo)
    If Key = vbNo Then
      Exit Sub
    Else
      Fname0 = GetFileName(Target,Fname)
      Path = DownloadTemplate(Target,Fname0,"FILE_DOC_DOC")
      If Path = "" Then Exit Sub
      Set WordDoc = GetObject(Path)
      Set Bookmarks = WordDoc.Bookmarks
    End If
  End If
  
  Set MainTable = Bookmarks("MainSection").Range.Tables(1)
  Set Table2 = Bookmarks("Section2").Range.Tables(1)
  
  CleanExistingData MainTable
  CleanExistingData Table2
  
  Progress.Step
  Progress.Text = "Подготовка данных"
  
  Data1 = PrepareData(Obj)
  Data2 = PrepareData2(Obj)
  If Ubound(Data1) < 0 and Ubound(Data2) < 0 Then
    Msgbox "Ничего не найдено.",vbExclamation
    Exit Sub
  End If
  
  Progress.Step
  Progress.Text = "Создание отчета"
  
  If Ubound(Data1) Then FillData MainTable, Data1, Progress
  If Ubound(Data2) Then FillData Table2, Data2, Progress
  
  Progress.Text = "Загрузка файла в базу данных"
  WordDoc.Save
  If Not WordDoc.Application.Visible Then WordDoc.Application.Visible = True
  ThisApplication.Utility.WaitCursor = False
  
  Target.CheckIn
End Sub

'Функция заполнения таблицы
Private Sub FillData(table, data, progress)
  Lb = LBound(data)
  Ub = UBound(data)
  If Ub > 0 Then
    progress.SetRange Lb, Ub
    For i = Lb To Ub
      FillRow data(i), table.Rows.Add(table.Rows.Last)
      progress.Step
    Next
  End If
End Sub

'Функция заполнения строки таблицы
Private Sub FillRow(data, Row)
  Set cells = Row.Cells
  For i = 1 To UBound(data)
    If vbNullString <> data(i) Then cells(i).Range.InsertBefore data(i)
  Next
  Row.Range.Font.Bold = data(0)
End Sub

Private Function ComposeKey(str)
  ComposeKey = vbNullString
  
  a = Array(): l = Len(str)
  Set rexp = New RegExp
  rexp.Pattern = "^(\d{1,2})"
  While (l > 0)
    test = Right(str, l)
    Set match = rexp.Execute(test)
    If 0 = match.Count Then
      l = l - 1
    Else
      ReDim Preserve a(Ubound(a) + 1)
      a(UBound(a)) = CLng(match(0).Value)
      l = l - match(0).Length
    End If
  WEnd
  
  For i = LBound(a) To Ubound(a)
    If a(i) < 10 Then a(i) = "0" & a(i) Else a(i) = CStr(a(i))
  Next
  ComposeKey = Join(a, ".")
End Function

'Функция формирования комментария
Private Function ComposeComment(obj)
  ComposeComment = vbNullString
  Set att = obj.Attributes
  If Not att("ATTR_CHANGE_NUM").Empty Then
    ComposeComment = "Изм. " & att("ATTR_CHANGE_NUM").Value
  End If
  If Not att("ATTR_SUBCONTRACTOR_CLS").Empty Then
    If Len(ComposeComment) > 0 Then ComposeComment = ComposeComment & vbCrLf
    ComposeComment = ComposeComment & att("ATTR_SUBCONTRACTOR_CLS").Value
  End If
End Function

'Функция для составления списка проектных разделов
Private Function PrepareData(obj)
  PrepareData = Array()
  
  Set parent = obj.Parent
  If parent Is Nothing Then Exit Function
  
  ' collect sections/subsections
  Set clsRoot = ThisApplication.Classifiers.FindBySysId("NODE_PROJECT_STRUCT").Classifiers
  Set cls = ThisApplication.ExecuteScript("CMD_PROJECT_SECTION_ADD","GetStageStructureRoot",parent)
  If cls Is Nothing Then
    Msgbox "Структура проекта не найдена!",vbCritical,"Ошибка"
    Exit Function
  End If
  Set Prepare = clsRoot.FindBySysId(cls.SysName)
  
  Set list = CreateObject("System.Collections.SortedList")
  Set Query = ThisApplication.Queries("QUERY_REPORT_PROJECT_SECTIONS_SUMMARY")
  For Each cls In Prepare.Classifiers
    Query.Parameter("OBJ") = parent
    Query.Parameter("CLS") = cls
    If Query.Objects.Count > 0 Then
      Set section = Query.Objects(0)
      tag = ComposeKey(section.Attributes("ATTR_SECTION_NUM").Value)
    Else
      Set Section = parent
      SysName = cls.SysName
      Num = Right(SysName, Len(SysName)-InStrRev(SysName, "_"))
      If Len(Num) < 2 Then Num = "0" & Num
      tag = Num & " " & SysName
    End If
    If "_NO" <> Right(cls.SysName, 3) Then
      list.Add tag, Array(section, CreateObject("System.Collections.SortedList"))
      If Section.Guid <> Parent.Guid Then
        For Each subsection In section.ContentAll.ObjectsByDef("OBJECT_PROJECT_SECTION_SUBSECTION")
          tag = ComposeKey(subsection.Attributes("ATTR_SECTION_NUM").Value)
          list.Add tag, Array(subsection, CreateObject("System.Collections.SortedList"))
        Next
      End If
    End If
  Next
  
  ' collect volumes
  For i = 0 To list.Count - 1
    data = list.GetByIndex(i)
    For Each vol In data(0).Content.ObjectsByDef("OBJECT_VOLUME")
      tag = ComposeKey(vol.Attributes("ATTR_VOLUME_NUM").Value)
      data(1).Add tag, vol
    Next
  Next
  
  a = Array()
  For i = 0 To list.Count - 1
    
    Set Section = list.GetByIndex(i)(0)
    If Section.ObjectDefName = "OBJECT_PROJECT_SECTION" Then
      ReDim Preserve a(UBound(a) + 1)
      If Section.Guid <> Parent.Guid Then
        a(UBound(a)) = Array(True, _
          vbNullString, vbNullString, Section.Attributes("ATTR_NAME").Value, vbNullString)
      Else
        SysName = List.GetKey(i)
        SysName = Right(SysName, Len(SysName)-InStr(SysName, " "))
        Set Cls = ThisApplication.Classifiers.FindBySysId(SysName)
        If not Cls is Nothing Then
          a(UBound(a)) = Array(True, "-", "-", Cls.Description, "не разрабатывается")
        End If
      End If
    End If
    Set volumes = list.GetByIndex(i)(1)
    For j = 0 To volumes.Count - 1
      VolName = ""
      Set vol = volumes.GetByIndex(j)
      If not Vol.Parent is Nothing and not Section is Nothing Then
        Set SubSection = Vol.Parent
        If SubSection.ObjectDefName = "OBJECT_PROJECT_SECTION_SUBSECTION" Then
          VolName = SubSection.Attributes("ATTR_NAME").Value
        End If
      End If
      If VolName <> "" Then
        VolName = VolName & chr(10) & vol.Attributes("ATTR_VOLUME_NAME").Value
      Else
        VolName = vol.Attributes("ATTR_VOLUME_NAME").Value
      End If
      ReDim Preserve a(UBound(a) + 1)
      a(UBound(a)) = Array(False, _
        vol.Attributes("ATTR_VOLUME_NUM").Value, _
        vol.Attributes("ATTR_VOLUME_CODE").Value, _
        VolName, _
        ComposeComment(vol))
    Next
  Next
  PrepareData = a
End Function

'Функция для составления списка непроектных разделов
Private Function PrepareData2(obj)
  PrepareData2 = Array()
  
  Set parent = obj.Parent
  If parent Is Nothing Then Exit Function
  
  ' collect sections/subsections
  Set list = CreateObject("System.Collections.SortedList")
  k = 0
  For Each section In parent.ContentAll.ObjectsByDef("OBJECT_PROJECT_SECTION")
    Set classifier = section.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier
    If Not classifier Is Nothing Then
      If "_NO" = Right(classifier.SysName, 3) Then
        Dim tag, subsection
        'tag = ComposeKey(section.Attributes("ATTR_SECTION_NUM").Value)
        tag = k
        k = k + 1
        list.Add tag, Array(section, CreateObject("System.Collections.SortedList"))
        For Each subsection In section.ContentAll.ObjectsByDef("OBJECT_PROJECT_SECTION_SUBSECTION")
          tag = ComposeKey(subsection.Attributes("ATTR_SECTION_NUM").Value)
          list.Add tag, Array(subsection, CreateObject("System.Collections.SortedList"))
        Next
      End If
    End If
  Next
  
  ' collect volumes
  For i = 0 To list.Count - 1
    data = list.GetByIndex(i)
    For Each vol In data(0).Content.ObjectsByDef("OBJECT_VOLUME")
      tag = ComposeKey(vol.Attributes("ATTR_VOLUME_NUM").Value)
      data(1).Add tag, vol
    Next
  Next
  
  ' prepare data
  a = Array()
  For i = 0 To list.Count - 1
    ReDim Preserve a(UBound(a) + 1)
    Set Section = list.GetByIndex(i)(0)
    If not Section is Nothing Then
      sName = Section.Attributes("ATTR_NAME").Value
      If InStr(1,sName,"раздел",vbTextCompare) <> 1 Then
        sName = "Раздел " & sName
      End If
    End If
    a(UBound(a)) = Array(True, vbNullString, vbNullString, sName, vbNullString)
    
    Dim volumes
    Set volumes = list.GetByIndex(i)(1)
    For j = 0 To volumes.Count - 1
      Set vol = volumes.GetByIndex(j)
      ReDim Preserve a(UBound(a) + 1)
      a(UBound(a)) = Array(False, _
        vol.Attributes("ATTR_VOLUME_NUM").Value, _
        vol.Attributes("ATTR_VOLUME_CODE").Value, _
        vol.Attributes("ATTR_VOLUME_NAME").Value, _
        ComposeComment(vol))
    Next
  Next
  PrepareData2 = a
End Function

'Функция очищения таблицы Word
Private Sub CleanExistingData(Table)
  If Table.Rows.Count > 2 Then
    For i = Table.Rows.Count To 3 Step -1
      Table.Rows(i).Delete
    Next
  End If
  Table.Rows(2).Range.Delete
End Sub

'Функция оповещения
Private Sub Warning(msg)
  MsgBox msg, vbExclamation, ThisApplication.DatabaseName
End Sub

'Функция выгрузки файла для заполнения
Private Function DownloadTemplate(Obj,Fname,TemplName)
  DownloadTemplate = ""
  If Fname = "" Then Exit Function
  
  TemplFileName = "Состав проекта.docx"
  TemplName0 = "FILE_OBJECT_DOC_DEV"
  If ThisApplication.FileDefs(TemplName0).Templates.Has(TemplFileName) = True Then
    If Obj.Files.Has(Fname) = False Then
      Obj.Files.AddCopy ThisApplication.FileDefs(TemplName0).Templates(TemplFileName), Fname
    End If
  Else
    Exit Function
  End If
  
  Set File = Obj.Files(Fname)
  If ThisApplication.FileDefs.Has(TemplName) and File.FileDef.SysName <> TemplName Then
    File.FileDef = ThisApplication.FileDefs(TemplName)
  End If
  
  FileIsOpened = ThisApplication.ExecuteScript("CMD_SS_LIB", "FileIsOpened", Path)
  If FileIsOpened Then
    Warning "Невозможно сформировать состав проекта, т.к. файл открыт в редакторе"
    Exit Function
  End If
  
  File.CheckOut File.WorkFileName
  DownloadTemplate = File.WorkFileName
End Function

'Функция поиска или создания проектного документа для хранения файла
Private Function LocateTarget(obj)
  Set LocateTarget = Nothing
  AttrName = "ATTR_PROJECT_DOC_TYPE"
  AttrName1 = "ATTR_DOCUMENT_NAME"
  DocType = "NODE_8F259D0B_1603_499C_B4CC_DA16B1C4C9DE"
  
  'Поиск тома
  Set Query = ThisApplication.CreateQuery()
  Query.AddCondition tdmQueryConditionObjectDef, "OBJECT_VOLUME"
  Query.AddCondition tdmQueryConditionAttribute, "0", "ATTR_VOLUME_NUM"
  Query.AddCondition tdmQueryConditionParent,    obj
  Set Objects = Query.Objects
  If Objects.Count = 0 Then Exit Function
  Set Volume = Objects(0)
  
  'Поиск проектного документа
  Set Query0 = ThisApplication.CreateQuery()
  Query0.AddCondition tdmQueryConditionObjectDef, "OBJECT_DOC_DEV"
  Query0.AddCondition tdmQueryConditionAttribute, DocType, AttrName
  Query0.AddCondition tdmQueryConditionParent,    Volume
  Set Objects = Query0.Objects
  'Если проектный документ не найден - создаем
  If Objects.Count = 0 Then
    Set Doc = Volume.Objects.Create("OBJECT_DOC_DEV")
    Set Clf = ThisApplication.Classifiers.FindBySysId(DocType)
    If Doc.Attributes.Has(AttrName) Then
      Doc.Attributes(AttrName).Classifier = Clf
    End If
    If Doc.Attributes.Has(AttrName1) and not Clf is Nothing Then
      Doc.Attributes(AttrName1).Value = Clf.Description
    End If
  Else
    Set Doc = Objects(0)
  End If
  
  Set LocateTarget = Doc
End Function

Public Function EnableCommand(obj)
  EnableCommand = False
  
  If "OBJECT_PROJECT_SECTION" <> obj.ObjectDefName Then Exit Function
  
  Set section = obj.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier
  If section Is Nothing Then Exit Function
  
  EnableCommand = "_0" = Right(section.SysName, 2)
End Function

'Функция получения имени файла
Private Function GetFileName(Obj,FileName)
  GetFileName = FileName
  Set Files = Obj.Files
  i = 0
  Check = False
  TempName = FileName
  ShortName = Left(FileName, InStrRev(FileName, ".")-1)
  Ext = Right(FileName,Len(FileName)-InStrRev(FileName,".")+1)
  Do While Check = False and i < 1000000
    If Files.Has(TempName) Then
      i = i + 1
      TempName = ShortName & " (" & i & ")" & Ext
    Else
      Check = True
      Exit Do
    End If
  Loop
  If TempName <> FileName Then GetFileName = TempName
End Function
