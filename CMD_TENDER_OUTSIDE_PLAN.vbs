' Команда - Планируемая потребность форма 2.2 (МТР)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  'Инициализация выборки
  Set Query = ThisApplication.Queries("QUERY_TENDER_OUTSIDE_PLAN")
  Set Sheet = Query.Sheet
  If Sheet.RowsCount = 0 Then
    Msgbox "Нет объектов для формы.", vbExclamation
    Exit Sub
  End If
  
  'Запрос места сохранения файла
  Path = ThisApplication.ExecuteScript("CMD_FILES_LIBRARY","GetFolder")
  If Path = "" Then Exit Sub
  
  'Поиск и выгрузка шаблона
  FileDefName = "FILE_DOC_XLS"
  FileName = "Реестр внешних закупок.xlsx"
  Set File = Nothing
  If ThisApplication.FileDefs.Has(FileDefName) Then
    If ThisApplication.FileDefs(FileDefName).Templates.Has(FileName) Then
      Set File = ThisApplication.FileDefs(FileDefName).Templates(FileName)
    End If
  End If
  If File is Nothing Then
    Msgbox "Шаблон таблицы не найден.", vbExclamation
    Exit Sub
  End If
  FilePath = Path & "\" & FileName
  File.CheckOut FilePath
  
  'Запуск Excel
  Set ExcelApp = CreateObject("Excel.Application")
  Set WrkBook = ExcelApp.Workbooks.Open(FilePath)
  Set List = WrkBook.ActiveSheet
  ExcelApp.Application.Visible = True
  If ExcelApp is Nothing or WrkBook is Nothing or List is Nothing Then
    Call ParamsClear(ExcelApp,WrkBook,List)
  End If
  
  'Заполнение таблицы
  RowStart = 4
  For i = 0 to Sheet.RowsCount-1
    Set Obj0 = Sheet.RowValue(i)
    For j = 1 to Sheet.ColumnsCount-1
      'Отработка ошибок обращения к ячейке с денежным значением
        If j = 1 Then
        Val = i + 1
        ElseIf j = 14 Then
        Val = Obj0.Attributes("ATTR_TENDER_FIRST_PRICE").Value 
        Elseif j = 21 Then
         Val = Obj0.Attributes("ATTR_TENDER_OFFERS_PRICE").Value 
         Elseif j = 22 Then
         Val = Obj0.Attributes("ATTR_TENDER_OFFERS_SECOND_PRICE").Value 
         Elseif j = 23 Then
         Val = Obj0.Attributes("ATTR_TENDER_COST_PRICE").Value
         Elseif j = 26 Then
         Val = Obj0.Attributes("ATTR_TENDER_DIAL_PRICE").Value
         
        Else
        Val = Sheet.CellValue(i,j)
      End If
      If StrComp(Val,"ложь",vbTextCompare) = 0 Then Val = ""
      If StrComp(Val,"истина",vbTextCompare) = 0 Then Val = "Х"
      List.Cells(RowStart+i,j).Value = Val
    Next
  Next
  
  Call ParamsClear(ExcelApp,WrkBook,List)
End Sub

'Процедура очистки переменных
Sub ParamsClear(ExcelApp,WrkBook,List)
  Set ExcelApp = Nothing
  Set WrkBook = Nothing
  Set List = Nothing
End Sub
