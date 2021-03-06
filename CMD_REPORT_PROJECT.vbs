ThisScript.RetValue = True
hHeight = 8
hWidth = 5
Set exApp = CreateObject("Excel.Application")
If Err <> 0 Then MsgBox "Ошибка!", vbAlert
  Set tWorkBook = exApp.WorkBooks.Add
  Set docSheet = tWorkBook.Sheets.Add
    docSheet.Name = "Документы"
    DrawCaption docSheet
    Set tQuery = ThisApplication.Queries("QUERY_REPORT_PROJECT_DOCS_STATUS")
    tQuery.Parameter("project") = ThisObject.GUID    
    Call fillTable(docSheet, tQuery.Sheet)
  Set compSheet = tWorkBook.Sheets.Add
    compSheet.Name = "Комплекты"
    DrawCaption compSheet
    Set tQuery = ThisApplication.Queries("QUERY_REPORT_PROJECT_COMP_STATUS")
    tQuery.Parameter("project") = ThisObject.GUID    
    Call fillTable(compSheet, tQuery.Sheet)
  Set sectionSheet = tWorkBook.Sheets.Add
    sectionSheet.Name = "Разделы"
    DrawCaption sectionSheet
    Set tQuery = ThisApplication.Queries("QUERY_REPORT_PROJECT_SECTION_STATUS")
    tQuery.Parameter("project") = ThisObject.GUID    
    Call fillTable(sectionSheet, tQuery.Sheet)
  Set fCompSheet = tWorkBook.Sheets.Add
    fCompSheet.Name = "Полные комплекты"
    DrawCaption fCompSheet
    Set tQuery = ThisApplication.Queries("QUERY_REPORT_PROJECT_fCOMP_TYPE")
    tQuery.Parameter("project") = ThisObject.GUID
    Call fillTable(fCompSheet, tQuery.Sheet)
exApp.Visible = True

' Заполняем страницу документов
Function fillTable(tSheet, tQSheet)
tRow = hHeight
tCol = 1
fillTable = 0
resCount = 0
  With tQSheet
    ' Создадим шапку таблицы
    For j=0 To .ColumnsCount -1
      tSheet.Cells(tRow, j+1) = .ColumnName(j)
    Next
    tRow = tRow + 1
    For i = 0 To .RowsCount -1
      For j = 0 To .ColumnsCount -1
        tSheet.Cells(tRow, tCol+j) = .CellValue(i,j)
        if j = 1 Then resCount = resCount  + .CellValue(i,j)
      Next
      tRow = tRow + 1
    Next 
  End With
  ' Создаём итоги
  'tRow = tRow + 1
  tSheet.Cells(tRow,1) = "Всего "
  tSheet.Cells(tRow,2) = resCount
Call UseStyle(tSheet, tRow)
End Function

' Оформление шапки отчёта
Sub DrawCaption(tSheet)
  ' Оформление
  tSheet.Columns(1).ColumnWidth = 43
  tSheet.Columns(2).ColumnWidth = 43
  ' Создаём футер
  ' Создаём футер
  tSheet.PageSetup.CenterFooter = "Дата формирования отчёта &D"
  tSheet.PageSetup.RightFooter = "Страница &P из &N"
  tSheet.PageSetup.PrintTitleRows = "$" & hHeight & ":$" & hHeight
  With tSheet
    .Cells(1,1) = "СТАТИСТИКА ПО ПРОЕКТУ " & ThisObject.Attributes("ATTR_PROJECT_CODE")
    .Range("A1:B1").MergeCells = True
    .Range("A1:B1").Font.Bold = True
    .Range("A1:B6").WrapText = True
    .Range("A1:B6").VerticalAlignment = -4160
    .Cells(2,1) = "Название проекта"
    .Cells(2,2) = ThisObject.Attributes("ATTR_PROJECT_NAME")
'    .Cells(3,1) = "Наименование объекта проектирования"
'    .Cells(3,2) = ThisObject.Attributes("ATTR_COMPLEX")
'    .Cells(4,1) = "№ договора"
'    .Cells(4,2) = ThisObject.Attributes("ATTR_REG_NUMBER")
    .Cells(5,1) = "ГИП"
    .Cells(5,2) = ThisObject.Attributes("ATTR_PROJECT_GIP")
'    .Cells(6,1) = "Заказчик"
'    .Cells(6,2) = ThisObject.Attributes("ATTR_CUSTOMER")
  End With
End Sub

Sub UseStyle(tSheet, tRow)  
  ' Рисуем границы
  With tSheet.Range("A" & hHeight & ":B"& tRow)
    'xlRight
    .Borders(10).LineStyle = 1
    .Borders(10).Weight = 3
    'xlLeft
    .Borders(7).LineStyle = 1
    .Borders(7).Weight = 3
    'xlBottom
    .Borders(9).LineStyle = 1
    .Borders(9).Weight = 3
    'xlTop
    .Borders(8).LineStyle = 1
    .Borders(8).Weight = 3
    'xlInsideVertical
    .Borders(11).LineStyle = 1 
    'xlInsideHorizontal
    .Borders(12).LineStyle = 1 
    .WrapText = True
    .VerticalAlignment = -4160
  End With
  'Form Heading
  With tSheet.Range("A" & hHeight & ":B"& hHeight)
    'xlBottom
    .Borders(9).LineStyle = 1
    .Borders(9).Weight = 3
    .Interior.ColorIndex = 15
    .Font.Bold = True
  End With
  ' Form Counts
  With tSheet.Range("A" & tRow & ":B"& tRow)
    .Borders(8).LineStyle = 1
    .Borders(8).Weight = 3
    .Borders(11).LineStyle = -4142
    .Borders(12).LineStyle = -4142
    .Interior.ColorIndex = 15
  End With
  ' Create Chart
  Set nChart = tWorkBook.Charts.Add
  nChart.ChartType = -4102
  nChart.SetSourceData tSheet.Range("A" & hHeight & ":B" & tRow-1), 2
  Set nSheet = nChart.Location (1, "Диаграмма " & tSheet.Name)
    nSheet.Move tSheet
End Sub
