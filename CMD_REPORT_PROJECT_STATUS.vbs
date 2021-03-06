' Отменяем авто формирование листа
ThisScript.RetValue = True
hHeight = 8
hWidth = 5
ColumnWidth1 = 25
ColumnWidth2 = 20
ColumnWidth3 = 15
ColumnWidth4 = 12.5
ColumnWidth5 = 11
Set exApp = CreateObject("Excel.Application")
If Err <> 0 Then MsgBox "Ошибка!", vbAlert
  Set tWorkBook = exApp.WorkBooks.Add
  Set sectionsSheet = tWorkBook.Sheets(1)
    sectionsSheet.Name = "Разделы проекта"
    'MsgBox 
    Call FillSectionsList(sectionsSheet)
  Set compSheet = tWorkBook.Sheets(2)
    compSheet.Name = "Комплекты проекта"
    'MsgBox 
    Call FillCompsList(compSheet)
exApp.Visible = True

' Оформление шапки отчёта
Sub DrawCaption(tSheet)
  ' Оформление
  tSheet.Columns(1).ColumnWidth = ColumnWidth1
  tSheet.Columns(2).ColumnWidth = ColumnWidth2
  tSheet.Columns(3).ColumnWidth = ColumnWidth3
  tSheet.Columns(4).ColumnWidth = ColumnWidth4
  tSheet.Columns(5).ColumnWidth = ColumnWidth5
  ' Создаём футер
  tSheet.PageSetup.CenterFooter = "Дата формирования отчёта &D"
  tSheet.PageSetup.RightFooter = "Страница &P из &N"
  tSheet.PageSetup.PrintTitleRows = "$" & hHeight & ":$" & hHeight
  With tSheet
    .Cells(1,1) = "ОТЧЁТ ПО СОСТОЯНИЮ ПРОЕКТНОЙ ДОКУМЕНТАЦИИ " & ThisObject.Attributes("ATTR_PROJECT_CODE")
    .Range("A1:E1").MergeCells = True
    .Range("A1:E1").Font.Bold = True
    .Range("A1:E6").WrapText = True
    .Range("A1:E6").VerticalAlignment = -4160
    .Cells(2,1) = "Название проекта"
    .Range("B2:E2").MergeCells = True
    .Cells(2,2) = ThisObject.Attributes("ATTR_PROJECT_NAME")
    .Cells(3,1) = "Наименование объекта проектирования"
    .Range("B3:E3").MergeCells = True
    .Cells(3,2) = ThisObject.Attributes("ATTR_COMPLEX")
    .Cells(4,1) = "№ договора"
    .Range("B4:E4").MergeCells = True
    .Cells(4,2) = ThisObject.Attributes("ATTR_REG_NUMBER")
    .Cells(5,1) = "ГИП"
    .Range("B5:E5").MergeCells = True
    .Cells(5,2) = ThisObject.Attributes("ATTR_PROJECT_GIP")
    .Cells(6,1) = "Заказчик"
    .Range("B6:E6").MergeCells = True
    .Cells(6,2) = ThisObject.Attributes("ATTR_CUSTOMER")
  End With
End Sub

' Заполняем таблицу разделов
Function FillSectionsList(tSheet)
FillSectionsList = 0
tRow = hHeight
tCol = 1
dCount = 0
dDevCount = 0
  Set sectionsQuery = ThisApplication.Queries("QUERY_REPORT_PROJECT_SECTIONS")
  sectionsQuery.Parameter("project") = ThisObject.GUID
  DrawCaption tSheet
  With sectionsQuery.Sheet
    ' Создадим шапку таблицы
    For j=0 To .ColumnsCount -1
      tSheet.Cells(tRow, j+1) = .ColumnName(j)
    Next
    tRow = tRow +1
    For i=0 To .RowsCount -1
      For j=0 To .ColumnsCount -1
        tSheet.Cells(tRow, tCol+j) = .CellValue(i,j)
        Select Case j
          Case 3
            dDevCount = dDevCount + .CellValue(i,j)
          Case 4
            dCount = dCount + .CellValue(i,j)
        End Select
      Next
      tRow = tRow + 1
    Next
  End With
  ' Создаём итоги
  tSheet.Range("A" & tRow & ":D" & tRow).MergeCells = True
  tSheet.Range("A" & tRow & ":E" & tRow).Font.Bold = True
  tSheet.Cells(tRow, 1)= "Всего документов в разработке"
  tSheet.Cells(tRow, 5)= dDevCount
  tRow = tRow + 1
  tSheet.Range("A" & tRow & ":D" & tRow).MergeCells = True
  tSheet.Range("A" & tRow & ":E" & tRow).Font.Bold = True
  tSheet.Cells(tRow, 1)= "Всего документов"
  tSheet.Cells(tRow, 5)= dCount
  tRow = tRow + 1
  tSheet.Range("A" & tRow & ":D" & tRow).MergeCells = True
  tSheet.Range("A" & tRow & ":E" & tRow).Font.Bold = True
  tSheet.Cells(tRow, 1)= "Всего разделов"
  tSheet.Cells(tRow, 5)= i
Call UseStyle(tSheet, tRow)
FillSectionsList = i+1
End Function

' Заполняем таблицу комплектов
Function FillCompsList(tSheet)
FillCompsList = 0
tRow = hHeight
tCol = 1
dCount = 0
dDevCount = 0
Dim curMark
  Set sectionsQuery = ThisApplication.Queries("QUERY_REPORT_PROJECT_COMPLECTS")
  sectionsQuery.Parameter("project") = ThisObject.GUID
  DrawCaption tSheet
  With sectionsQuery.Sheet
    ' Создадим шапку таблицы
    For j=0 To .ColumnsCount -2
      tSheet.Cells(tRow, j+1) = .ColumnName(j)
    Next
    tRow = tRow +1
    For i=0 To .RowsCount -1
      If curMark <> .CellValue(i,5) Then
        curMark = .CellValue(i,5)
        tSheet.Range("A" & tRow & ":E" & tRow).MergeCells = True
        tSheet.Range("A" & tRow & ":E" & tRow).HorizontalAlignment = -4108
        tSheet.Range("A" & tRow & ":E" & tRow).Font.Bold = True
        tSheet.Cells(tRow, tCol) = curMark
        tRow = tRow +1
      End If
      For j=0 To .ColumnsCount -2
        tSheet.Cells(tRow, tCol+j) = .CellValue(i,j)
        Select Case j
          Case 3
            dDevCount = dDevCount + .CellValue(i,j)
          Case 4
            dCount = dCount + .CellValue(i,j)
        End Select
      Next
      tRow = tRow + 1
    Next
  End With
  ' Создаём итоги
  tSheet.Range("A" & tRow & ":D" & tRow).MergeCells = True
  tSheet.Range("A" & tRow & ":E" & tRow).Font.Bold = True
  tSheet.Cells(tRow, 1)= "Всего документов в разработке"
  tSheet.Cells(tRow, 5)= dDevCount
  tRow = tRow + 1
  tSheet.Range("A" & tRow & ":D" & tRow).MergeCells = True
  tSheet.Range("A" & tRow & ":E" & tRow).Font.Bold = True
  tSheet.Cells(tRow, 1)= "Всего документов"
  tSheet.Cells(tRow, 5)= dCount
  tRow = tRow + 1
  tSheet.Range("A" & tRow & ":D" & tRow).MergeCells = True
  tSheet.Range("A" & tRow & ":E" & tRow).Font.Bold = True
  tSheet.Cells(tRow, 1)= "Всего комплектов"
  tSheet.Cells(tRow, 5)= i
Call UseStyle(tSheet, tRow)
FillCompsList = i+1
End Function

Sub UseStyle(tSheet, tRow)  
  ' Рисуем границы
  With tSheet.Range("A" & hHeight & ":E"& tRow)
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
  With tSheet.Range("A" & hHeight & ":E"& hHeight)
    'xlBottom
    .Borders(9).LineStyle = 1
    .Borders(9).Weight = 3
    .Interior.ColorIndex = 15
    .Font.Bold = True
  End With
  ' Form Counts
  With tSheet.Range("A" & tRow-2 & ":E"& tRow)
    .Borders(8).LineStyle = 1
    .Borders(8).Weight = 3
    .Borders(11).LineStyle = -4142
    .Borders(12).LineStyle = -4142
    .Interior.ColorIndex = 15
  End With
End Sub
