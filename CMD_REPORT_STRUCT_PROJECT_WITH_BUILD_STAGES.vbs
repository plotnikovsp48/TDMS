' Команда  - Структура объекта с учетом этапов строительства
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "CMD_DLL_REPORTS"
USE "CMD_EXCEL"
USE "CMD_SS_PROGRESS"

Call Main(ThisObject)

Sub Main(Obj)
  Set CU = ThisApplication.CurrentUser
  Set ObjExcel = Nothing
  Set ObjFile = Nothing
  Set Templ = Nothing
  Set Parent = Nothing
  StartRow = 3
  nRow = StartRow
  ColorGray = RGB(166,166,166)
  ColorOrange = RGB(255,217,102)
  ColorWhite = RGB(255,255,255)
  TemplName = "Структура объекта с учетом этапов строительства.xlsx"
  FileDef = "FILE_REPORT_TEMPLATE"
  
  'Поиск корневой папки "Этапы строительства"
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_FOLDER"
  q.AddCondition tdmQueryConditionAttribute, Obj, "ATTR_PROJECT"
  q.AddCondition tdmQueryConditionAttribute, "NODE_OBJECT_BUILD_STAGE", "ATTR_FOLDER_TYPE"
  Set Objects = q.Objects
  If Objects.Count > 0 Then
    Set Parent = Objects(0)
    RootGuid = Parent.Guid
  End If
  If Parent is Nothing Then
    Msgbox "Этапы строительства не найдены",vbExclamation
    Exit Sub
  End If
  
  'Запрос папки выгрузки
  Fpath = GetPathSave
  If Fpath = "" Then Exit Sub
  
  'Проверка файла
  FileIsOpened = ThisApplication.ExecuteScript("CMD_SS_LIB", "FileIsOpened", Fpath&"\"&TemplName)
  If FileIsOpened Then
    Msgbox "Невозможно структуру объекта с учетом этапов строительства, т.к. файл открыт в редакторе",vbExclamation
    Exit Sub
  End If
  
  ThisApplication.Utility.WaitCursor = True
  
  'Выгрузка шаблона
  If ThisApplication.FileDefs.Has(FileDef) Then
    Set Fdef = ThisApplication.FileDefs(FileDef)
    If Fdef.Templates.Has(TemplName) Then
      Set Templ = Fdef.Templates(TemplName)
      Fpath = Fpath & "\" & Templ.FileName
      Templ.CheckOut(Fpath)
    End If
  End If
  If Templ is Nothing Then Exit Sub
  
  Set Progress = New CProgress
  Progress.SetRange 0, Parent.ContentAll.Count
  Progress.Text = "Формирование отчета..."
  
  'Запуск Excel
  Set ObjExcel = CreateObject("Excel.Application")
  Set Book = OpenTextFile(ObjExcel,Fpath)
  Set List = Book.ActiveSheet
    
  If not Book Is Nothing Then  
    'Заполнение таблицы
    Call TableLoopFill(ObjExcel,List,Parent,nRow,RootGuid,ColorGray,ColorOrange,ColorWhite,Progress)
    
    List.Range("A"&StartRow&":D"&nRow-1).Select
    ObjExcel.Selection.Borders.LineStyle = True
    List.Range("A"&StartRow).Select
    List.PageSetup.PrintArea = List.Range("A1","D"&nRow)
    Book.Save
    ObjExcel.Visible = True
    Set ObjExcel = Nothing
  End If
  
  ThisApplication.Utility.WaitCursor = False
End Sub

'Процедура циклического заполнения таблицы
Private Sub TableLoopFill(ObjExcel,List,Parent,nRow,RootGuid,ColorGray,ColorOrange,ColorWhite,Progress)
  For Each Child in Parent.Objects
    List.Cells(nRow,1).Value = Child.Attributes("ATTR_CODE").Value
    List.Cells(nRow,1).Font.Bold = True
    List.Cells(nRow,3).Value = Child.Attributes("ATTR_NAME").Value
    List.Cells(nRow,3).Font.Bold = True
    List.Range("A"&nRow&":D"&nRow).Select
    If Parent.Guid = RootGuid Then
      ObjExcel.Selection.Interior.Color = ColorGray
    Else
      ObjExcel.Selection.Interior.Color = ColorOrange
    End If
    
    nGroupStart = nRow
    nRow = nRow + 1
    Call TableLoopFill(ObjExcel,List,Child,nRow,RootGuid,ColorGray,ColorOrange,ColorWhite,Progress)
    
    'Полные комплекты этапа строительства
    Set Query = ThisApplication.Queries("QUERY_REPORT_STRUCT_PROJECT_WITH_BUILD_STAGES")
    Query.Parameter("OBJ") = Child
    Set Sheet = Query.Sheet
    If Sheet.RowsCount > 0 Then
      For i = 0 to Sheet.RowsCount-1
        List.Cells(nRow,2).Value = Sheet.CellValue(i,0)
        List.Cells(nRow,2).Font.Bold = False
        List.Cells(nRow,3).Value = Sheet.CellValue(i,1)
        List.Cells(nRow,3).Font.Bold = False
        List.Range("A"&nRow&":D"&nRow).Select
        ObjExcel.Selection.Interior.Color = ColorWhite
        nRow = nRow + 1
      Next
    End If
    
    'Группировка строк
    If nGroupStart+1 < nRow Then
      List.Range(nGroupStart+1 & ":" & nRow-1).Group
    End If
    
    Progress.Step
  Next
End Sub
