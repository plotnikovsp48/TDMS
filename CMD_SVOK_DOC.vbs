' Команда  - СВОК
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2016 г.

USE "CMD_DLL_REPORTS"

Call Main (ThisObject)

Sub Main(Obj)
  Set CU = ThisApplication.CurrentUser
  Set ObjWord = Nothing
  Set ObjFile = Nothing
  Set Table = Nothing
  Set Templ = Nothing
  ProjectCode = ""
  RowStart = 1
  ColCount = 1
  nColStart = 0
  nColEnd = 0
  StrDate = Cstr(Date)
  StrDate = Left(StrDate,6) & Right(StrDate,2)
  TemplName = "SVOK"
  
  'Получаем шифр Проекта
  If ThisObject.Attributes("ATTR_PROJECT").Empty = False Then
    If not ThisObject.Attributes("ATTR_PROJECT").Object is Nothing Then
      Set Project = ThisObject.Attributes("ATTR_PROJECT").Object
      ProjectCode = Project.Attributes("ATTR_PROJECT_CODE").Value
    End If
  End If
  
  'Получаем результат выборки
  Set Query = ThisApplication.Queries("QUERY_SVOK_DOC")
  Query.Parameter("OBJ") = ThisObject
  Set Sheet = Query.Sheet

  If Sheet.RowsCount = 0 Then
    Msgbox "Нет данных для выгрузки.",vbExclamation
    Exit Sub
  End If
  
  ColCount = Sheet.ColumnsCount
  nColEnd = ColCount-1
  
  '"Ведомость основного комплекта рабочих чертежей"
  Set docType = ThisApplication.Classifiers("NODE_DOC_TYPES_ALL").Classifiers.Find("СВОК")

  fName = Obj.Attributes("ATTR_PROJECT_STAGE_NUM") 
  If Not docType Is Nothing Then _
    fName = fName & "-" & docType.Code
  
  fName = ThisApplication.ExecuteScript("CMD_FILES_LIBRARY","CharsChange",fName,"_")
  fName = fName & ".docx"
  
  'Запрос папки выгрузки
'  Fpath = GetPathSave()
  SelFileName = GetFileSave(fName)
  If IsArray(SelFileName) = False Then Exit Sub
  SaveFileName = SelFileName(0)
  
  pos = InStrRev(SaveFileName,"\")
  Fpath = Left(SaveFileName,pos-1)
  fName = Right(SaveFileName,Len(SaveFileName)-pos)
  
  'Проверка файла
'  FileIsOpened = ThisApplication.ExecuteScript("CMD_SS_LIB", "FileIsOpened", Fpath&"\"&TemplName&".docx")
  FileIsOpened = ThisApplication.ExecuteScript("CMD_SS_LIB", "FileIsOpened", Fpath&"\"&fName)
  If FileIsOpened Then
    Msgbox "Невозможно документ, т.к. файл открыт в редакторе",vbExclamation,"Отчет: СВОК"
    Exit Sub
  End If
  
  ThisApplication.Utility.WaitCursor = True
  
  'Выгрузка шаблона
  Set Templ = GetTemplate("",Fpath,fName,TemplName & ".docx")
        
  'Запуск Word
  NewDoc = WordStart(Fpath,ObjWord,ObjFile,Table,ColCount,RowStart)

  RowStart = 3

  If not ObjFile Is Nothing Then  
    'Заполнение таблицы
    Call SVokTableFill(Table,Sheet,RowStart,nColStart,nColEnd)
    Call DocPropFill(Obj,ObjFile,Sheet)
    Call FieldsFill(Obj,ObjFile,Sheet)
    Call UpdateAllFields(ObjFile)
    ObjWord.Visible = True
    ObjFile.Save
    Set ObjWord = Nothing
  End If
  
  ThisApplication.Utility.WaitCursor = False
End Sub


'=================================================================================================
'Процедура заполнения таблицы WORD
'Table:Object - ссылка на таблицу WORD
'Sheet:Object - ссылка на таблицу выборки
'RowStart:Integer - номер первой строки для заполнения
'nColStart:Integer - номер столбца, с которого начинается заполнение
'nColEnd:Integer - номер столбца, до которого заполняем
Sub SVokTableFill(Table,Sheet,RowStart,nColStart,nColEnd)
  Count = 0 'Счетчик строк
'  Table.cell(RowStart-1,1).range.text = Sheet.CellValue(0,0)
'  Table.cell(RowStart,1).range.text = Sheet.CellValue(0,1)
'  For i = 1 to Sheet.RowsCount
'    If Count <> 0 Then
'      Table.Rows.Add
'    End If
'    
'    ChNum = Sheet.CellValue(i-1,"Примечание")
'    If ChNum = "0" Then 
'      ChNum = ""
'    Else
'      ChNum = "Изм." & ChNum
'    End If
'    
'    Table.cell(i+RowStart,1).range.text = Sheet.CellValue(i-1,"Обозначение")
'    Table.cell(i+RowStart,2).range.text = Sheet.CellValue(i-1,"Наименование")
'    Table.cell(i+RowStart,3).range.text = ChNum
'    Count = Count + 1
'  Next
'  
  
  
   'Заполнение таблицы
    Table.cell(2,1).range.text = Sheet.CellValue(0,"Проект")
    WorkDocsName = ""
    StageName = vbNullString
    
    For i = 0 to Sheet.RowsCount-1
      If Table.Rows.Count > 3 Then
        Table.Rows.Add
      End If
      If Sheet.CellValue(i,"Этап") <> StageName Then
        StageName = Sheet.CellValue(i,"Этап")
        Table.cell(Table.Rows.Count,1).range.text = StageName
        Table.cell(Table.Rows.Count,1).Range.Bold = 1
        Table.Rows.Add
        
        Set Doc = Table.Application.ActiveDocument
        Set Row = Doc.Range(Table.Cell(Table.Rows.Count-1,1) _ 
          .Range.Start, Table.Cell(Table.Rows.Count-1,3).Range.End) 
        Row.Cells.Merge
      End If
      
      If Sheet.CellValue(i,"Наименование полного комплекта") <> WorkDocsName Then
        WorkDocsName = Sheet.CellValue(i,"Наименование полного комплекта")
        Table.cell(Table.Rows.Count,2).range.text = WorkDocsName
        
        Table.cell(Table.Rows.Count,3).range.text = "Поз." & Sheet.CellValue(i,"Поз.")
        Table.cell(Table.Rows.Count,2).Range.Bold = 1
        Table.Rows.Add
      End If
      Table.cell(Table.Rows.Count,1).range.text = Sheet.CellValue(i,"Шифр комплекта")
      Table.cell(Table.Rows.Count,1).Range.Bold = 0
      Table.cell(Table.Rows.Count,2).range.text = Sheet.CellValue(i,"Наименование комплекта")
      Table.cell(Table.Rows.Count,2).Range.Bold = 0
    Next
End Sub


Sub DocPropFill(Obj,ObjFile,Sheet)
'  ThisApplication.AddNotify "FieldsFill"
  If ObjFile Is Nothing Then Exit Sub
  For each prop In ObjFile.CustomDocumentProperties
    Val = vbNullString
'    ThisApplication.AddNotify prop.Name
    Select Case prop.Name
      
      Case "ATTR_DOC_CODE"
      Val = Left(ObjFile.Name,Len(ObjFile.Name)-5)
      Case "ATTR_DOCUMENT_NAME"
        Val = "Сводная ведомость основных комплектов рабочих чертежей"
        prop.Value = Val
      Case "ExternFunctions.Mycompany"
        Val = ThisApplication.ExecuteScript("ExternFunctions","Mycompany",Obj)
      Case "ExternFunctions.StageCode"
        Val = ThisApplication.ExecuteScript("ExternFunctions","StageCode",Obj)
      Case "ExternFunctions.GetObjectDesc"
        Val = Obj.Attributes("ATTR_PROJECT").Object.Attributes("ATTR_PROJECT_NAME")
      Case "ExternFunctions.GetDocDevelopUser"
        Set user = ThisApplication.CurrentUser
        If Not user Is Nothing Then
          Val = user.LastName
        End If
  '      Val = ThisApplication.ExecuteScript("ExternFunctions","GetDocDevelopUser",Obj)
  '    Case "ExternFunctions.GetDocCheckUser1"
  '      Val = ThisApplication.ExecuteScript("ExternFunctions","GetDocCheckUser1",Obj)
  '    Case "ExternFunctions.GetDocNKUser"
  '      Val = ThisApplication.ExecuteScript("ExternFunctions","GetDocNKUser",Obj)
      Case "ExternFunctions.GetDocApproveUser"
        Set user = Obj.Attributes("ATTR_PROJECT").Object.Attributes("ATTR_PROJECT_GIP").User
        If Not user Is Nothing Then
          Val = user.LastName
        End If
    End Select
    prop.Value = Val
  Next
End Sub


Sub FieldsFill(Obj,ObjFile,Sheet)
'  ThisApplication.AddNotify "FieldsFill"
  If ObjFile Is Nothing Then Exit Sub
  'Заполнение шапки шаблона
  For Each Fld in ObjFile.Fields
'    ThisApplication.AddNotify "Зашло"
    FldName = LCase(Trim(Fld.Code.Text))
    Select Case FldName
      Case "project"
              Fld.Result.Text = Sheet.CellValue(0,0)
      Case "dept"
              Fld.Result.Text = Dept
      Case "datein"
              Fld.Result.Text = DateIn
      Case "dateout"
              Fld.Result.Text = DateOut
      Case "dategen"
              Fld.Result.Text = Date
      Case "user"
              Fld.Result.Text = CU.Description
    End Select
    Fld.Update
  Next
End Sub

Sub UpdateAllFields(ActiveDocument)
  Set Application = ActiveDocument.Application
  Application.ScreenUpdating = False 'Отключение обновления экрана
  ActiveDocument.PrintPreview 'Предварительный просмотр
  ActiveDocument.ClosePrintPreview 'Закрыть предварительный просмотр
  Application.ScreenUpdating = True 'Обновить экран
End Sub