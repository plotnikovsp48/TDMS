' Команда - Планируемая потребность форма 2.2 (МТР)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  'Инициализация выборки
  Set Query = ThisApplication.Queries("QUERY_TENDER_IN_PLAN_SPC_2_2_MTR")
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
  FileName = "Специфицированная потребность - форма 2.2 (МТР).xlsx"
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
        If j = 19 Then
        Set TableRows = Obj0.Attributes("ATTR_LOT_DETAIL").Rows
        Set Row = TableRows(i)
        AttrName = "ATTR_TENDER_NDS_PRICE"
        Val = Row.Attributes(AttrName).Value
        elseIf j = 44 Then  
        Val = Obj0.Attributes("ATTR_TENDER_LOT_PRICE").Value 
      
        
'        Val = Obj0.Attributes("ATTR_LOT_DETAIL").Value
'      If j = 15 Then
'        Val = Obj0.Attributes("ATTR_TENDER_SMSP_SUBCONTRACT_SUMM").Value
'      ElseIf j = 17 Then
'        Val = Obj0.Attributes("ATTR_TENDER_PLAN_NDS_PRICE").Value
'       ElseIf j = 37 Then
'        Val = Obj0.Attributes("ATTR_TENDER_ONLINE").Value  
'        If StrComp(Val,"ложь",vbTextCompare) = 0 Then Val = "Нет"
'        If StrComp(Val,"истина",vbTextCompare) = 0 Then Val = "Да"
'         ElseIf j = 38 Then
'         Val = Sheet.CellValue(i,j)
'        If StrComp(Val,"ложь",vbTextCompare) = 0 Then Val = "Нет"
'        If StrComp(Val,"истина",vbTextCompare) = 0 Then Val = "Да"
'      ElseIf j = 65 Then
'        Val = Obj0.Attributes("ATTR_TENDER_PLAN_PRICE").Value
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
