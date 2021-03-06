'***************************Word***************************************
Dim oWord, oDoc, oObj, count, oObjOrder, RCount, Guid, oSheet
Dim aNum(), aContent(), aDocInf(), ColumnCount, j
count = -1 ' Счетчик 
Set oObj = ThisObject
'********************Заполняем массив о документе*********************************
Set q = ThisApplication.Queries("QUERY_AN_INCOMING_DOCUMENT") 'Выборка Сведений о документе
    q.Parameter("Param0")=oObj
Set oSheet = q.Sheet
    ColumnCount = oSheet.ColumnsCount
    For j = 0 to ColumnCount-1
      If len(oSheet.CellValue(0,1)) <> 10 Then oSheet.CellValue(0,1) = left(oSheet.CellValue(0,1),10)'Обрезали дату Создания документа
      ReDim Preserve aDocInf(j)
      aDocInf(j) = oSheet.CellValue(0,j)
    Next  
'********************Пробегаем по всем поручениям документа***********************
Set q = ThisApplication.Queries("QUERY_ORDER_ICOMING") 'Выборка Дочерних поручений
    q.Parameter("Param0")=oObj
Set oSheet = q.Sheet
RCount = oSheet.RowsCount
For i = 0 to RCount-1
Guid = oSheet.CellValue(i,0)
Set oObjOrder = ThisApplication.GetObjectByGUID(Guid)
Call treeOrCr(oObjOrder,0)
Next
'********************Выгружаем шаблон**********************************
  Set file = ThisApplication.FileDefs("UNLOAD_CHAIN_ORDER").Templates(0)
  datetime = ThisApplication.CurrentTime
  DocNameToSave = "UNLOAD_CHAIN_ORDER" & "_" & Day(datetime) & "_" & Month(datetime) & "_" & Year(datetime) &_ 
     "_" & Hour(datetime) & "_" & Minute(datetime) & "_" & Second(datetime) & ".docx"
  DocNameToSave = ThisApplication.WorkFolder & "\" & DocNameToSave
  file.CheckOut(DocNameToSave)
'********************Создаем объект с вордом***************************
Set oWord = CreateObject("Word.Application") 'Создаем объект с вордом
With oWord
  .Visible = true 'Делаем видимым
End With
Set oDoc = oWord.Documents.Open(DocNameToSave) 'Открываем документ
Set oSel = oWord.Selection 'Получаем доступ к выделенной области

'***********************Заполняем документ************************  
For i=0 to count
  Call WriteWord (aNum(i), aContent(i))
Next
'******************************************************************
'* Заполняем вордовский документ                                  *
'*----------------------------------------------------------------*
'* oDoc_: открытый Вордовский документ                            *
'* aNum_: номер в иерархии порчений (0 - корневое поручение)      *
'* aContent_: Строка содержит значения выборки                    *
'******************************************************************
Sub WriteWord (aNum_, aContent_)
Dim oSheet, q, val, DtVal
Set q = ThisApplication.Queries("QUERY_SUMPLE_ORDER") 'Выборка поручений
  q.Parameter("Param0") = aContent_     
Set oSheet = q.Sheet 
' Обрезаем дату
  If len(oSheet.CellValue(0,1)) <> 10 Then oSheet.CellValue(0,1) = left(oSheet.CellValue(0,1),10)'Обрезали дату Создания поручения
  If len(oSheet.CellValue(0,5)) <> 10 Then oSheet.CellValue(0,5) = left(oSheet.CellValue(0,5),10)'Обрезали дату Срока выполнения
nstyle="Style"&aNum_
nstyle2="Text"&aNum_
If aNum_ = 0 Then
'***********************Заполняем шапку документа*********************************
val = "Исполнение по док. № " & aDocInf(0) & " от " 'Рег номер документа
val = val & aDocInf(1) 'Дата создания документа
If aDocInf(2) <> "" Then val = val & " от " & aDocInf(2) 'Наименование Контрагента
val = val & " Тема: " & aDocInf(3) 'Тема документа
  With oSel      
    .TypeParagraph    
  If oSheet.CellValue(0,6) = "Выполнено" Then 
    .Style = oDoc.styles("Style0")
    .Font.StrikeThrough = 1
  ElseIf oSheet.CellValue(0,5) = "" Then
    .Style = oDoc.styles("Style0")   
  ElseIf oSheet.CellValue(0,5) < date Then
    .Style = oDoc.styles("Style0")
    .Font.Color = RGB (255,0,0)
Else .Style = oDoc.styles("Style0") 
  End If       
    'Вставка текста в конец или в начало(InsertAfter("text")) выделения.
    .InsertBefore val ' Выводим
    .EndOf 'Конец абзаца
  End With  
' **********************Строка состояния  **********************
val = "Инициатор: " & oSheet.CellValue(0,3) & Chr(9) 'Инициатор
If oSheet.CellValue(0,5) <> "" Then val = val & "Срок: " & oSheet.CellValue(0,5) & Chr(9) 'Срок
val = val &"Состояние: " & oSheet.CellValue(0,6) 'Состояние
  With oSel
    .TypeParagraph    
    .Style = oDoc.styles(nstyle2)
    'Вставка текста в конец или в начало(InsertAfter("text")) выделения.
    .InsertBefore val ' Выводим
    .EndOf 'Конец абзаца
    .InlineShapes.AddHorizontalLineStandard ' Горизонтальная линия
  End With
'*********************** Основной текст**********************
  With oSel    
    .Font.Underline = 1
    .Font.Color = RGB (1,111,194) 
val = "Поручение рег.№ " & oSheet.CellValue(0,0)& " от " 'Рег номер Поручения
val = val & oSheet.CellValue(0,1) 'Дата создания поручения  
    'Вставка текста в конец или в начало(InsertAfter("text")) выделения.
    .InsertBefore val ' Выводим
    .EndOf 'Конец абзаца
  End With    
  With oSel 
    .TypeParagraph
    .Style = oDoc.styles(nstyle2)   
val = "Автор резолюции: " & oSheet.CellValue(0,2) 'Автор резолюции
    .InsertBefore val ' Выводим
    .EndOf 'Конец абзаца
    .InsertBreak 6 '6 - Перевод на новую строку.
val = "Срок: " & oSheet.CellValue(0,5) 'Срок  
    .InsertBefore val ' Выводим
    .EndOf 'Конец абзаца
    .InsertBreak 6 '6 - Перевод на новую строку.    
val = "Текст резолюции: " & oSheet.CellValue(0,7) 'Текст резолюции  
    .InsertBefore val ' Выводим
    .EndOf 'Конец абзаца   
    .InsertBreak 6 '6 - Перевод на новую строку. 
val = "На контроле: Нет"  'На контроле
If oSheet.CellValue(0,11) <> "" Then val = "На контроле: Да"  'На контроле
    .InsertBefore val ' Выводим
    .EndOf 'Конец абзаца   
    .InsertBreak 6 '6 - Перевод на новую строку.         
val = "Исполнитель: " & oSheet.CellValue(0,8) 'Исполнитель  
    .InsertBefore val ' Выводим
    .EndOf 'Конец абзаца   
    .InsertBreak 6 '6 - Перевод на новую строку. 
val = "Связан. документы: " 'Исполнитель  
    .InsertBefore val ' Выводим
    .EndOf 'Конец абзаца 
    .InsertBreak 6 '6 - Перевод на новую строку. 
  End With  
With oSel 
  .Font.Underline = 1
  .Font.Color = RGB (1,111,194)  
  val = "Вх. № " & aDocInf(0) & " от " 'Рег номер документа
  val = val & aDocInf(1) 'Дата создания документа
  If aDocInf(2) <> "" Then val = val & " от " & aDocInf(2) 'Наименование Контрагента
  val = val & " об " & aDocInf(3) 'Тема документа 
    .InsertBefore val ' Выводим
    .EndOf 'Конец абзаца  
    .InsertBreak 6 '6 - Перевод на новую строку.     
End With    
Else
'*********************** Дочернии поручения**********************
val = "Поручение рег.№ " & oSheet.CellValue(0,0)& " от " 'Рег номер Поручения
val = val & oSheet.CellValue(0,1) 'Дата создания поручения
'val = val & " '" & oSheet.CellValue(0,7) & "' " 'Текст резолюции
  With oSel  
    .TypeParagraph
    .Style = oDoc.styles(nstyle)
'    .InlineShapes.AddPicture "C:\Tdms\001.png", 0, 1 ' Вставляем иконку    
  If oSheet.CellValue(0,6) = "Выполнено" Then 
    .Font.StrikeThrough = 1
  ElseIf oSheet.CellValue(0,5) < date Then
    .Font.Color = RGB (255,0,0)
  End If      
    'Вставка текста в конец или в начало(InsertAfter("text")) выделения.
    .InsertBefore val ' Выводим
    .EndOf 'Конец абзаца
    '.InsertBreak 6 '6 - Перевод на новую строку.
  End With
' **********************Строка состояния  **********************
val = "Инициатор: " & oSheet.CellValue(0,3)& Chr(9) 'Исполнитель
If oSheet.CellValue(0,5) <> "" Then val = val & "Срок: " & oSheet.CellValue(0,5) & Chr(9) 'Срок
val = val &"Состояние: " & oSheet.CellValue(0,6) 'Состояние
  With oSel
    .TypeParagraph
    .Style = oDoc.styles(nstyle2)
    'Вставка текста в конец или в начало(InsertAfter("text")) выделения.
    .InsertBefore val ' Выводим
    .EndOf 'Конец абзаца
    .InsertBreak 6 '6 - Перевод на новую строку.  
val = "Исполнитель: " & oSheet.CellValue(0,8) 'Исполнитель  
    .InsertBefore val ' Выводим
    .EndOf 'Конец абзаца 
    .InlineShapes.AddHorizontalLineStandard ' Горизонтальная линия    
  End With
  
  val = "Резолюция: Нет"  
If oSheet.CellValue(0,7) <> "" Then val = "Резолюция: " & oSheet.CellValue(0,7) 'Примечание
  With oSel 
    'Вставка текста в конец или в начало(InsertAfter("text")) выделения.
    .InsertBefore val ' Выводим
    .EndOf 'Конец абзаца  
  If oSheet.CellValue(0,7) <> "" Then .InsertBreak 6 '6 - Перевод на новую строку.       
  End With  
  val = "Примечание: Нет"  
If oSheet.CellValue(0,9) <> "" Then val = "Примечание: " & oSheet.CellValue(0,9) 'Примечание
  With oSel 
    'Вставка текста в конец или в начало(InsertAfter("text")) выделения.
    .InsertBefore val ' Выводим
    .EndOf 'Конец абзаца         
  End With  
  val = ""  
If oSheet.CellValue(0,10) <> "" Then val = "Отчет: " & oSheet.CellValue(0,10) 'Примечание
  With oSel
  If val<> "" Then .InsertBreak 6 '6 - Перевод на новую строку.  
    'Вставка текста в конец или в начало(InsertAfter("text")) выделения.
    .InsertBefore val ' Выводим
    .EndOf 'Конец абзаца
'    .InsertBreak 6 '6 - Перевод на новую строку.     
  End With 
End If  
End Sub
'******************************************************************
'* Рекурсивная процедура, построения цепочки поручений            *
'*----------------------------------------------------------------*
'* oObj_:TDMSObject - объект для которого ищем дочернии поручения *
'* n - отображает уровень вложенности (0 - корневое поручение)    *
'******************************************************************
Sub treeOrCr(oObj_,n)
  Dim num
    num = n
    count = count + 1
  ReDim Preserve aNum(count)
    aNum(count) = num 'Номер поручения в иерархии
  ReDim Preserve aContent(count)
    aContent(count) =  oObj_.Guid  
  Set q = ThisApplication.Queries("QUERY_CHILDS_ORDERS") 'Выборка Дочерних поручений
    q.Parameter("Param0")=oObj_  
  For Each child In q.Objects
    Call treeOrCr(child, num+1)
  Next
End Sub
'******************************************************************************
' Метод записи лога
'------------------------------------------------------------------------------
' str:String - строка, которая пишется в лог
'******************************************************************************  
Sub WriteLog(str)
  If WLOG = 0 Then Exit Sub
  ThisApplication.AddNotify str
End Sub
