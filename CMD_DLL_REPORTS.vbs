' Команда  - Библиотека функций выгрузки отчетов
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2016 г.


'=================================================================================================
'Функция запуска Word и получение ссылки на таблицу
'Fpath:String - Путь к файлу
'ObjWord:Object - ссылка на Word.Application
'ObjFile:Object - ссылка на открытый документ
'Table:Object - ссылка на основную таблицу
'ColCount:Integer - Количество столбцов таблицы
'RowStart:Integer - номер первой строки для заполнения
'Возвращает True или False, True - если создан новый документ
Function WordStart(Fpath,ObjWord,ObjFile,Table,ColCount,RowStart)
  set ObjWord = CreateObject("Word.Application")
  If InStrRev(Fpath,"\") <> Len(Fpath) Then
    'Открытие существующего документа
    set ObjFile = ObjWord.Documents.open(Fpath)
    WordStart = False
  Else
    'Создание нового документа
    Fpath = ThisApplication.WorkFolder & "\" & ThisObject.Description & ".Docx"
    Set ObjFile = ObjWord.Documents.Add()
    WordStart = True
  End If
  'Переменные и настройки документа
  If ObjFile.Tables.Count <> 0 Then
    Set Table = ObjFile.Tables.Item(1)
    RowStart = 9
  Else
    ObjFile.PageSetup.Orientation = 1
    ObjFile.PageSetup.LeftMargin = 20
    ObjFile.PageSetup.RightMargin = 20
    ObjFile.Paragraphs.Add
    Pnum = ObjFile.Paragraphs.Count
    Set Table = ObjFile.Tables.add(ObjFile.Paragraphs(Pnum).Range,1,ColCount+1)
    Table.AutoFormat(16)
  End If
End Function

'=================================================================================================
'Процедура заполнения шапки таблицы WORD
'Table:Object - ссылка на таблицу WORD
'Sheet:Object - ссылка на таблицу выборки
'RowStart:Integer - номер первой строки для заполнения
'ColCount:Integer - количество столбцов в выборке 
Sub TableHeaderFill(Table,Sheet,RowStart,ColCount)
  Table.Rows.Add
  Set r = Table.cell(RowStart,1).range
  r.text = "№"
  For i = 0 to ColCount-1
    ColName = Sheet.ColumnName(i)
    Set r = Table.cell(RowStart,i+2).range
    r.text = ColName
  Next
  RowStart = RowStart + 1
End Sub

'=================================================================================================
'Процедура заполнения таблицы WORD
'Table:Object - ссылка на таблицу WORD
'Sheet:Object - ссылка на таблицу выборки
'RowStart:Integer - номер первой строки для заполнения
'nColStart:Integer - номер столбца, с которого начинается заполнение
'nColEnd:Integer - номер столбца, до которого заполняем
Sub TableFill(Table,Sheet,RowStart,nColStart,nColEnd)
  Count = 0 'Счетчик строк
  For i = 0 to Sheet.RowsCount-1
    k = 1 'счетчик столбцов
    If Count <> 0 Then
      Table.Rows.Add
    End If
    For j = nColStart to nColEnd
      If k < Table.Columns.Count Then
        Table.cell(i+RowStart,k+1).range.text = Sheet.CellValue(i,j)
        k = k + 1
      End If
    Next
    Count = Count + 1
    Table.cell(i+RowStart,0).range.text = Count
  Next
End Sub

'=================================================================================================
'Функция поиска файла шаблона отчета и выгрузки его на жесткий диск
'Prefix:String - Префикс модуля
'Fpath:String - Путь выгрузки
'Fname:String - Имя файла
'Функция вовзращает ссылку на выгруженный файл
Function FindTemplate(Prefix,Fpath,Fname)
  Set FindTemplate = Nothing
  str0 = "FILE"
  str1 = "_REPORT_TEMPLATE"
  DefaultName = "default.docx"
  If Prefix <> "" Then
    TemplDescr = str0 & "_" & Prefix & str1
    FileDescr = Prefix & "_" & Fname & ".docx"
  Else
    TemplDescr = str0 & str1
    FileDescr = Fname & ".docx"
  End If
  
  'Поиск основного шаблона
  If ThisApplication.FileDefs.Has(TemplDescr) Then
    Set Fdef = ThisApplication.FileDefs(TemplDescr)
    If Fdef.Templates.Has(FileDescr) Then
      Set FindTemplate = Fdef.Templates(FileDescr)
    'Поиск Default шаблона
    ElseIf Fdef.Templates.Has(DefaultName) Then
      Set FindTemplate = Fdef.Templates(DefaultName)
    End If
  End If
  If not FindTemplate is Nothing Then 
    Fpath = Fpath & "\" & FindTemplate.FileName
    FindTemplate.CheckOut(Fpath)
  End If
End Function

'=================================================================================================
'Функция запроса пути выгрузки шаблона отчета
'Функция вовзращает строку - путь выгрузки
Function GetPathSave()
  GetPathSave = ""
  On Error Resume Next
  Set objShellApp = CreateObject("Shell.Application")
  Set objFolder = objShellApp.BrowseForFolder(0, "Сохранить файл в папку", 0, "C:\")
  If Err.Number <> 0 Then
    MsgBox "Папка не выбрана!", vbInformation
  Else
    GetPathSave = objFolder.Self.Path
  End If
  Set objShellApp = Nothing
End Function


Function GetTemplate(Prefix,Fpath,Fname,FileDescr)
  Set GetTemplate = Nothing
  DefaultName = "default.docx"
  TemplDescr = "FILE_REPORT_TEMPLATE"

  'Поиск основного шаблона
  If ThisApplication.FileDefs.Has(TemplDescr) Then
    Set Fdef = ThisApplication.FileDefs(TemplDescr)
    If Fdef.Templates.Has(FileDescr) Then
      Set GetTemplate = Fdef.Templates(FileDescr)
    'Поиск Default шаблона
    ElseIf Fdef.Templates.Has(DefaultName) Then
      Set GetTemplate = Fdef.Templates(DefaultName)
    End If
  End If
  If not GetTemplate is Nothing Then 
    Fpath = Fpath & "\" & Fname
    Set FSO = CreateObject("Scripting.FileSystemObject")
    if FSO.FileExists(Fpath) Then
      FSO.DeleteFile Fpath
    End If 
    GetTemplate.CheckOut(Fpath)
  End If
End Function

Function GetFileSave(FName)
  GetFileSave =""
    Set SelFileDlg = ThisApplication.Dialogs.FileDlg
    
    SelFileDlg.Filter = "Документ MSWord (*.docx)|*.docx||" 
    SelFileDlg.DefaultExt = "docx"
    SelFileDlg.OpenFileDialog = False
    SelFileDlg.FileName = FName
    RetVal = SelFileDlg.Show
    If RetVal <> TRUE Then Exit Function
    GetFileSave = SelFileDlg.FileNames
End Function