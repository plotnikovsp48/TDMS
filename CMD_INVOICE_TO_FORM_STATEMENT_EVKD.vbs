

USE "CMD_SS_PROGRESS"

Run ThisObject

'Основная функция
Public Function Run(Obj)
  Run = False
  Set Table = Nothing
  ThisScript.SysAdminModeOn
  Set Progress = New CProgress
  
  'Progress.Text = "Выбор папки"
  Folder = ThisApplication.WorkFolder
  'Folder = GetFolder()
  If Folder = "" Then Exit Function
  
  ThisApplication.Utility.WaitCursor = True
  Progress.Text = "Загрузка шаблона"
  FileName = "ЭВКД.docx"
  FileDefName = "FILE_" & Obj.ObjectDefName
  Path = DownloadTemplate(Folder,Obj,FileDefName,FileName)
  If Path = "" Then Exit Function
  
  Progress.Text = "Открытие шаблона"
  Set WordDoc = GetObject(Path)
  If WordDoc is Nothing Then Exit Function
  If WordDoc.Application.Visible = False Then WordDoc.Application.Visible = True
  If WordDoc.Tables.Count <> 0 Then
    Set Table = WordDoc.Tables.Item(1)
  End If
  
  'FillData Obj.Attributes("ATTR_INVOICE_TFILES"), WordDoc.Tables(1), Progress
  Obj.SaveChanges
  Call DocFill(Obj,Table,Progress)
  
  Progress.Text = "Сохранение файла"
  WordDoc.Save
  
  Progress.Text = "Загрузка в TDMS"
  If Obj.Files.Has(FileName) Then
    Obj.Files(FileName).CheckIn Path
  End If
  'Call UploadToObject(Path,Obj,FileDefName,FileName)
  
  Run = True
  ThisApplication.Utility.WaitCursor = False
End Function

'Функция создания рабочего файла
Private Function DownloadTemplate(Folder,Obj,FileDefName,FileName)
  ThisScript.SysAdminModeOn
  DownloadTemplate = vbNullString
  Set FSO = CreateObject("Scripting.FileSystemObject")
  
  'Определение шаблона
  If ThisApplication.FileDefs.Has(FileDefName) = False Then Exit Function
  Set FileDef = ThisApplication.FileDefs(FileDefName)
  If FileDef.Templates.Has(FileName) = False Then Exit Function
  Set Template = FileDef.Templates(FileName)
  
  'Проверка наличия файла в накладной
  If Obj.Files.Has(FileName) Then
    Key = Msgbox("Заменить ведомость ЭВКД в накладной?",vbQuestion+vbYesNo)
    If Key = vbNo Then
      Exit Function
    Else
      Obj.Files.Remove Obj.Files(FileName)
    End If
  End If
  
  'Копирование шаблона в накладную
  Set NewFile = Obj.Files.AddCopy(Template, FileName)
  
  'Выгружаем файл в рабочую папку
  Path = FSO.BuildPath(Folder, NewFile.FileName)
  If FSO.FileExists(path) Then FSO.DeleteFile Path
  NewFile.CheckOut Path
  
  DownloadTemplate = Path
End Function

'Процедура заполнения таблицы
Sub DocFill(Obj,Table,Progress)
  RowStart = 19
  ColCount = 1
  nColStart = 0
  nColEnd = 6
  
  'Запрос данных выборкой
  Set Query = ThisApplication.Queries("QUERY_INVOICE_TO_FORM_STATEMENT_EVKD")
  Query.Parameter("OBJ") = Obj
  Set Sheet = Query.Sheet
  ColCount = Sheet.ColumnsCount
  If Sheet.RowsCount = 0 Then Exit Sub
    
  'Заполнение таблицы
  Call TableFill(Table,Sheet,RowStart,nColStart,nColEnd,Progress)
End Sub

'Процедура заполнения таблицы WORD
'Table:Object - ссылка на таблицу WORD
'Sheet:Object - ссылка на таблицу выборки
'RowStart:Integer - номер первой строки для заполнения
'nColStart:Integer - номер столбца, с которого начинается заполнение
'nColEnd:Integer - номер столбца, до которого заполняем
Sub TableFill(Table,Sheet,RowStart,nColStart,nColEnd,Progress)
  Count = 0 'Счетчик строк
  Progress.SetRange 0, Sheet.RowsCount
  
  For i = 0 to Sheet.RowsCount-1
    k = 0 'счетчик столбцов
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
    Progress.Step
  Next
End Sub

Public Function EnableCommand(obj)
  EnableCommand = False
  If obj.Attributes.Has("ATTR_INVOICE_TFILES") Then
    EnableCommand = obj.Attributes("ATTR_INVOICE_TFILES").Rows.Count > 0
  End If
End Function

'Private Function GetFolder()
'  GetFolder = vbNullString
'  GetFolder = ThisApplication.ExecuteScript("CMD_DLL_REPORTS", "GetPathSave")
'End Function
