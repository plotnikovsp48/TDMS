
'Option Explicit
On Error Resume Next

' - - - - - - - - - - -
' Скрипт парсит заданный rtf-файл в специальном формате, для каждой секции (в данном случае страницы)
' выделяет номер платёжного документа и отправляет страницу на печать.
' 
' 1) originalPath - директория, в которой находится исходный rtf-документ. 
' 2) originalName - название исходного rtf-документа
' 3) targetPath - директория, в которую будут выводиться экспортированные .pdf.
' 4) (опционально) debugName - имя файла, в который будет писаться лог. По умолчанию лог писаться не будет 
'
' Исходный файл выбирается через диалог. В качестве конечной папки создаётся папка внутри исходной
' с именем выбранного файла (без расширения). В неё пишутся .pdf и, если указано имя для него, лог
' - - - - - - - - - - - 

Const ParamObjectType = "OBJECT_KD_ZA_PAYMENT"
Const ParamAttributeType = "ATTR_KD_AP_PAYMENT_ORDER"
Const ParamSecondAttribute = "ATTR_KD_NUM"
Const ParamFileType = "FILE_KD_ANNEX"
Const ParamStatus = "STATUS_SIGNED"

Call Main()
If Err.Number <> 0 then
  errorInfo =  "Функция ParseAndPrint завершилась аварийно: " & Err.Description & vbCrlf _
      & "Контекст:  " & Err.HelpContext & vbCrlf _
      & "Файл справки: " & Err.HelpFile & vbCrlf _
      & "Номер ошибки: " & Err.Number & vbCrlf _
      & "Источник ошибки: " & Err.Source
  Call PrintDebugInfo(debugFile, "ОШИБКА: " &errorInfo)
  MsgBox(errorInfo)
End If

'= = = = = = = = = = = = = = =
Sub Main()
  Const ForReading = 1, ForWriting = 2, ForAppending = 8
  
  Dim originalPath, originalName, targetPath, debugName
  Dim Simple
  
  ' вызвать диалог, чтобы определить имя исходного файла и путь к нему
  originalFileName = GetFileNameFromDlg()
  If originalFileName = "" Then
    MsgBox "Не выбран исходный файл!"
    Exit Sub
  End If ' originalFileName <> ""
    
    ' находим крайний обратный слэш с конца
    div = InStrRev(originalFileName, "\")

    originalName = Right(originalFileName, Len(originalFileName) - div)
    originalPath = Left(originalFileName, div -1)
    
    ' в качестве выходной папки пытаемся создать вложенную папку с именем файла
    ext = InStrRev(originalName, ".") ' обрезаем по самое расширение
    targetPath = originalPath & "\" & Left(originalName, ext-1)
        
    ' пытаемся создать указанную целевую директорию, если таковой нет
    Set fso = CreateObject("Scripting.FileSystemObject")
    pathExists = fso.FolderExists(targetPath)
    If Not pathExists Then
      ' если targetPath не существует, создаём
      'MsgBox "создаём директорию " & targetPath
      
      fso.CreateFolder(targetPath)
      If Err.Number <> 0 then
        errorInfo =  "Не удалось открыть или создать файл для ведения лога: " & Err.Description & vbCrlf _
            & "Контекст:  " & Err.HelpContext & vbCrlf _
            & "Файл справки: " & Err.HelpFile & vbCrlf _
            & "Номер ошибки: " & Err.Number & vbCrlf _
            & "Источник ошибки: " & Err.Source
        MsgBox(errorInfo) 
      End If 'err.number <> 0
    Else
      ' если существует - верный признак, что мы уже экспортировали выбранный файл
      result = MsgBox("Папка для вывода файлов уже существует. Скорее всего, данный файл " _
        & originalName & " уже был экспортирован." & chr(13) & chr(10) & "Хотите продолжить?", 1)
      
      If result = 2 Then
        ' отмена - выходим из скрипта
        Call PrintDebugInfo(debugFile, "Отмена разбора файла")
        Exit Sub
        
      End If 'result = 2
              
      ' повторно проверяем - надо убедиться, что мы можем таковую директорию создать
      ' Впрочем, если мы не можем создать директорию, а можем ли мы создавать файлы?
      pathExists = fso.FolderExists(targetPath)
      If Not pathExists Then
        ' или попробовать писать в ту же папку, или предложить выбрать папку через диалог.
        ' в случае диалога ответственность за возможность писать оставляем на пользователя
        targetPath = originalPath
      End If
    End If 'else not pathExists
    
  ' проверяем наличие файла - на случай, если вдруг за время выполнения предыдущих операций файл "ушёл". 
  ' поскольку сейчас файл выбирается через диалог, инфа 99%, 
  ' что к этому моменту таковой будет и с ним всё хорошо
  If Not fso.FileExists(originalPath & "\" & originalName) Then
    Call PrintDebugInfo(debugFile, "Файл не найден: " & originalPath & "\" & originalName)
    debugFile.Close
    WScript.Quit ' если исходный файл отсутствует - выходим
  End If
  
  Call ParseAndPrint(originalPath, originalName, targetPath, debugFile, fso)
  If Err.Number <> 0 then
    errorInfo =  "Функция ParseAndPrint завершилась аварийно: " & Err.Description & vbCrlf _
        & "Контекст:  " & Err.HelpContext & vbCrlf _
        & "Файл справки: " & Err.HelpFile & vbCrlf _
        & "Номер ошибки: " & Err.Number & vbCrlf _
        & "Источник ошибки: " & Err.Source
    Call PrintDebugInfo(debugFile, "ОШИБКА: " &errorInfo)
    MsgBox(errorInfo)
  End If
  
  ' закрываем открытые файлы и объекты  
  If Not IsEmpty(debugFile) Then
    debugFile.Close
    Set debugFile = Nothing
  End If
  
  Set fso = Nothing
  
End Sub 'ParseRtf

' = = = = = = = = = = = = = = 
' ОБЪЯВЛЕНИЯ ПРОЦЕДУР
' - - - - - - - - - - - -
Function SearchWithQuery(ObjectType, AttributeName, StringInAttribute, ObjectStatus, debugFile)  
  Dim query
  ' создаём динамическую выборку
  Set query = ThisApplication.CreateQuery
  
  ' выбираем тип объекта для поиска - платёжное поручение?
  query.AddCondition tdmQueryConditionObjectDef, ObjectType
  
  ' чтобы удостовериться, что мы нашли актуальный объект, а не прошлогодний,
  ' ориентируемся на статус "подписано". Старые объекты должны быть в статусе
  ' "оплачено", "отменено" или ещё что-то такое.
  ' теоретически, есть возможность, что целевой объект будет переведён в "оплачено"
  ' до того, как к нему будет подгружены пдф-ки. Ориентироваться на 
  ' наибольшую дату создания объекта?
  query.AddCondition tdmQueryConditionStatus, ParamStatus
  
  ' добавить условие - аттрибут "Наименование документа"
  query.AddCondition tdmQueryConditionAttribute, _
      "= '" & StringInAttribute & "' OR = '" & StringInAttribute _
      & ",*' OR = '*, " & StringInAttribute & "' OR = '*, " & StringInAttribute & ",*'", _
      AttributeName
  
  query.Permissions = SysAdminPermissions
  
  Set objects = query.Objects
  If Not objects Is Nothing And objects.Count > 0 Then
      Dim obj
      
      Set SearchWithQuery = objects(0) ' возвращаем объект
      Exit Function    
  Else
      
  End If
  
  Set SearchWithQuery = Nothing
End Function

Function GetFileNameFromDlg

  Dim SelFileDlg, FName, RetVal

  ' Открыть диалог выбора файла
  Set SelFileDlg = ThisApplication.Dialogs.FileDlg
  SelFileDlg.Filter = "RTF файлы (*.rtf)|*.rtf||"
  RetVal = SelFileDlg.Show
  
  'Если пользователь отменил диалог, выйти из подпрограммы
  If RetVal <> TRUE Then Exit Function
  
  GetFileNameFromDlg = SelFileDlg.FileName
End Function

' - - - - - - - - - - - -
' вспомогательная функция для записи отладочных сообщений в лог
Sub PrintDebugInfo(debugFile, message)
  ' даже если файла нет, выводить в некое отладочное окно - поищи *Notify
  ThisApplication.AddNotify(message)
  If Not IsEmpty(debugFile) Then
    debugFile.WriteLine Now() & " : " & message
  End If
End Sub
' - - - - - - - - - - - - 
' вспомогательная функция для взятия значения из параметров, если таковой имеется
' value - переменная, в которую будет записано значение параметра, если таковой есть
' parameters - список параметров
' paramNo - номер интересующего параметра
Sub CopyIfHasParameter(ByRef value, parameters, paramNo)
  If (parameters.Count >= paramNo) Then ' есть по меньшей мере один параметр
    value = parameters(paramNo - 1)
  End If
End Sub

' - - - - - - - - - - - - 
' открываем файл в ворде, отправляем на печать
Sub ParseAndPrint(originalPath, originalName, targetPath, debugFile, fso)
  Const wdActiveEndPageNumber = 3
  
  ' открываем ворд
  Set objWord = CreateObject("Word.Application")
  With objWord
    .Visible = false
    .DisplayAlerts = False
  End With
    
  ' открываем целевой файл, получаем доступ к документу
  Set oWrdFil = objWord.Documents.Open(originalPath & "\" & originalName, False, True)
    ' 3-й параметр True = открываем файл ReadOnly, чтобы избежать некоторых проблем с открытием

  If Err.Number <> 0 then
    errorInfo =  "Не удалось открыть файл: " & Err.Description & vbCrlf _
        & "Контекст:  " & Err.HelpContext & vbCrlf _
        & "Файл справки: " & Err.HelpFile & vbCrlf _
        & "Номер ошибки: " & Err.Number & vbCrlf _
        & "Источник ошибки: " & Err.Source
    Call PrintDebugInfo(debugFile, "ОШИБКА: " &errorInfo)
    MsgBox(errorInfo)
  Else
    'Call PrintDebugInfo(debugFile, "Получилось")
  End If

  Set objDoc = objWord.ActiveDocument

  cTables = objDoc.Tables.Count

  Call PrintDebugInfo(debugFile, "Разбор файла " & originalPath & "\" & originalName)
  
  ' если в файле вообще таблиц нет, вероятно, это не наш файл
  ppCnt = cTables - 2
  If ppCnt < 1  Then
    Call PrintDebugInfo(debugFile, "Формат файла не подходит для разбора.")
    
    objWord.Quit
    Set objWord = Nothing
    Exit Sub
  End If
  
  ' если первая ячейка в третьей строк
  If InStr(objDoc.Tables(3).Cell(5, 1).Range.Text, "ПЛАТЕЖНОЕ") = 0 Then
    Call PrintDebugInfo(debugFile, "На разбор передан некорректный файл")
    
    objWord.Quit
    Set objWord = Nothing
    Exit Sub
  End If
    
  Call PrintDebugInfo(debugFile, "Количество платёжных поручений: " & ppCnt)

  ' проходимся по каждой таблице, кроме первых
  For i = 3 To cTables
    ' получаем номер страницы, на которой находится данная таблица
    ' исходим из предположения, что целевая таблица занимает не более одной страницы
    nPage = objDoc.Tables(i).Cell(1,1).Range.Information(wdActiveEndPageNumber)
    
    Set curTable = objDoc.Tables(i)
    
    ' используем значение ячейки (5,2) - номер платёжки - как название для будущего pdf-файла
    If InStr(curTable.Cell(5, 1).Range.Text, "ПОРУЧЕНИЕ") > 0 Then                         
        Num = curTable.Cell(5, 2).Range.Text  'это если поручение
        Num = Left(Num, Len(Num) - 2)
     else
        Num = "банк ордер(не грузим)"  'это если банковский ордер (таблицы маленько отличаются)     
       ' Num = Left(Num, Len(Num) - 2)
    End If


    FileName = targetPath & "\" & Num & ".pdf"
    
    ' отправляем страницу на печать
    Call printToPdf(objDoc, nPage, FileName, debugFile, fso) 
    
    ' связываем созданный файл с объектом
    Set targetObj = SearchWithQuery(ParamObjectType, ParamAttributeType, Num, ParamStatus, debugFile)
    
    ' если файл не был обнаружен, пропускаем
    If Not targetObj Is Nothing Then      
      ' наделяем пользователя правами администратора
      targetObj.Permissions = SysAdminPermissions
      
      reqNo = targetObj.Attributes(ParamSecondAttribute) ' номер заявки
      
      ' если файл с таким именем у объекта уже есть
      If Not targetObj.Files.Has(Num & ".pdf") Then
        ' если нету    
        targetObj.Files.Create ParamFileType, FileName
        Call PrintDebugInfo(debugFile, Num & chr(9) & " добавлен к заявке " & chr(9) & reqNo)
      Else
        ' оповещаем, что такой файл уже есть
        Call PrintDebugInfo(debugFile, Num & chr(9) & " уже привязан к заявке " & chr(9) & reqNo)
      End If
    Else
      Call PrintDebugInfo(debugFile, Num & chr(9) & " не найдена заявка")
    End If
    
  Next

  ' закрываем
  Call PrintDebugInfo(debugFile, "Разбор файла " & originalPath & "\" & originalName & " корректно завершён")
  
  objWord.Quit
  Set objWord = Nothing
End Sub

' - - - - - - - - - - - - - - 
' печатаем выбранную секцию
Sub printToPdf(objDoc, sectNo, targetFileName, debugFile, fso)

  Const wdExportFormatPDF = 17
  Const wdExportOptimizeForPrint = 0
  Const wdExportFromTo = 3
  Const wdExportDocumentContent = 0
  Const wdExportCreateNoBookmarks = 0
  
  If Len(targetFileName) > 255 Then
    ' ограничение на длину файлов windows
    Call PrintDebugInfo(debugFile, "Имя конечного файла слишком длинное, не могу экспортировать: " & targetFileName)
    Exit Sub
  End If
    
  ' проверяем на случай, если файл под таким именем уже существует
  If fso.FileExists(targetFileName) Then
    ' если существует - удаляем, будем экспортировать заново     
    Call fso.DeleteFile(targetFileName)
  End If
  
  ' отправляем на печать
  objDoc.ExportAsFixedFormat _
  targetFileName, _
  wdExportFormatPDF, False, _
  wdExportOptimizeForPrint, _
  wdExportFromTo, sectNo, sectNo, _
  wdExportDocumentContent, True, True, _
  wdExportCreateNoBookmarks, True, _
  True, False

  If Err.Number <> 0 then
    errorInfo =  "Не удалось экспортировать страницу: " & Err.Description & vbCrlf _
        & "Контекст:  " & Err.HelpContext & vbCrlf _
        & "Файл справки: " & Err.HelpFile & vbCrlf _
        & "Номер ошибки: " & Err.Number & vbCrlf _
        & "Источник ошибки: " & Err.Source
    Call PrintDebugInfo(debugFile, "ОШИБКА: " & errorInfo)
    MsgBox(errorInfo)
  Else
    'Call PrintDebugInfo(debugFile, "Получилось")
  End If
End Sub
