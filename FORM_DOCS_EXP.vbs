Public Path

Sub Form_BeforeShow(Form, Obj)
  Form.Controls("ATTR_DOCS_EXP_PATH").Enabled = False
Set tDict = ThisApplication.Dictionary
  If tDict.Exists("CMD_EXPORT") Then ReadAttrs ' Считываем атрибуты
  InitTables ' Инициализируем таблицы
  ' Если включена выгрузка всего - то таблицы недоступны для редактирвания
  FormChangeEnable Form.Attributes("ATTR_DOCS_EXP_ALL").Value
End Sub

Sub OnClick_BUTTON_BROWSE()
  ThisForm.Attributes("ATTR_DOCS_EXP_PATH") = SelectFolder()
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  Select Case Attribute.AttributeDefName
    Case "ATTR_DOCS_EXP_ALL"
      FormChangeEnable Attribute.Value
  End Select
End Sub

Sub Form_TableAttributeChange(Form, Object, TableAttribute, TableRow, ColumnAttributeDefName, OldTableRow, Cancel)
' Таблицы позволяют изменять только флаги
If TableRow.Attributes(ColumnAttributeDefName).Type <> 3 Then
  Cancel = True
  InitTables
End If
End Sub

Sub Form_BeforeClose(Form, Obj, Cancel)
Dim arrayLog(), errorCounter
errorCounter = -1

' Обрабатываем таблицу типов документов
sAttrDefName = "ATTR_DOCS_EXP_DOC_TYPE_NAME"
Set sTableAttr = Form.Attributes("ATTR_DOCS_EXP_DOC_TYPE")
For Each tRow In sTableAttr.Rows
  ' Получаем массив ссылок на одинаковые строки
  ' "Пустые" строки (удалён узел классификатора) удаляются сразу
  If Not tRow.Attributes(sAttrDefName).Classifier Is Nothing Then
    tRows = SearchRows(sTableAttr, sAttrDefName, tRow.Attributes(sAttrDefName).Classifier.Description)
    ' Складываем строки и выводим лог удалений
    i = 0
    For Each fRow In tRows
      If i > 0 Then
        firstRow.Attributes("ATTR_DOCS_EXP_DOC_TYPE_FLAG") = firstRow.Attributes("ATTR_DOCS_EXP_DOC_TYPE_FLAG") + fRow.Attributes("ATTR_DOCS_EXP_DOC_TYPE_FLAG")
        errorCounter = errorCounter + 1
        Redim Preserve arrayLog(errorCounter)
        arrayLog(errorCounter) = "Удаление: дублирующийся тип документа " & tRow.Attributes(sAttrDefName).Classifier.Description
        sTableAttr.Rows.Remove fRow
      Else
        Set firstRow = fRow
      End If
      i = i + 1
    Next
    i = 0
  Else
    errorCounter = errorCounter + 1
    Redim Preserve arrayLog(errorCounter)
    arrayLog(errorCounter) = "Удаление: пустой тип документа"
    sTableAttr.Rows.Remove tRow
  End If
Next

' Обрабатываем таблицу типов файлов
sAttrDefName = "ATTR_DOCS_EXP_FILE_TYPE_ID"
Set sTableAttr = Form.Attributes("ATTR_DOCS_EXP_FILE_TYPE")
For Each tRow In sTableAttr.Rows
  ' Получаем массив ссылок на одинаковые строки
  ' "Пустые" строки (удалён или изменён идентификатор) удаляются сразу
  If ThisApplication.FileDefs.Has(tRow.Attributes(sAttrDefName).Value) Then
    tRows = SearchRows(sTableAttr, sAttrDefName, tRow.Attributes(sAttrDefName).Value)
    ' Складываем строки и выводим лог удалений
    i = 0
    For Each fRow In tRows
      If i > 0 Then
        firstRow.Attributes("ATTR_DOCS_EXP_FILE_TYPE_FLAG") = firstRow.Attributes("ATTR_DOCS_EXP_FILE_TYPE_FLAG") + fRow.Attributes("ATTR_DOCS_EXP_FILE_TYPE_FLAG")
        errorCounter = errorCounter + 1
        Redim Preserve arrayLog(errorCounter)
        arrayLog(errorCounter) = "Удаление: дублирующийся тип файла " & tRow.Attributes(sAttrDefName).Value
        sTableAttr.Rows.Remove fRow
      Else
        Set firstRow = fRow
        ' Замена описания файла
        If fRow.Attributes("ATTR_DOCS_EXP_FILE_TYPE_NAME") <> ThisApplication.FileDefs(fRow.Attributes(sAttrDefName).Value).Description Then
          errorCounter = errorCounter + 1
          Redim Preserve arrayLog(errorCounter)
          arrayLog(errorCounter) = "Изменение: неверное описание типа файла " & tRow.Attributes(sAttrDefName).Value
          fRow.Attributes("ATTR_DOCS_EXP_FILE_TYPE_NAME") = ThisApplication.FileDefs(fRow.Attributes(sAttrDefName).Value).Description
        End If
      End If
      i = i + 1
    Next
    i = 0
  Else
    errorCounter = errorCounter + 1
    Redim Preserve arrayLog(errorCounter)
    arrayLog(errorCounter) = "Удаление: несуществующий тип файла " & tRow.Attributes(sAttrDefName).Value
    sTableAttr.Rows.Remove tRow
  End If
Next

Set tDict = ThisApplication.Dictionary
  If tDict.Exists("CMD_EXPORT") Then 
    tDict("CMD_EXPORT") = arrayLog ' Возвращаем лог ошибок
  Else
    For Each tError In arrayLog
      ThisApplication.AddNotify tError
    Next
  End If
End Sub

' Меняет состояние таблиц в зависимости от флага
Sub FormChangeEnable(bValue)
  ThisForm.Controls("ATTR_DOCS_EXP_FILE_TYPE").Enabled = Not (bValue)
  ThisForm.Controls("ATTR_DOCS_EXP_DOC_TYPE").Enabled = Not (bValue)
  ThisForm.Controls("ATTR_DOCS_EXP_UNDEF").Enabled = Not (bValue)
  InitTables
End Sub

' Считывает поля табличного атрибута
Sub ReadAttrs()
For Each tAttr In ThisForm.Attributes
With ThisApplication.CurrentUser.Attributes
  Select Case tAttr.Type
    Case 11 ' Table
      For Each tRow In .Item(tAttr.AttributeDefName).Rows
        Set nRow = tAttr.Rows.Create
        For Each tRowAttr In tRow.Attributes
          Select Case tRowAttr.Type
            Case 6
              nRow.Attributes(tRowAttr.AttributeDefName).Classifier = tRowAttr.Classifier
            Case Else
              nRow.Attributes(tRowAttr.AttributeDefName).Value = tRowAttr.Value
          End Select
        Next
      Next
    Case 6
      tAttr.Classifier = .Item(tAttr.AttributeDefName).Classifier
    Case 7
      tAttr.Object = .Item(tAttr.AttributeDefName).Object
    Case Else
      tAttr.Value = .Item(tAttr.AttributeDefName).Value
  End Select
End With
Next
End Sub


'-----------------------------------------------------------------------------------------------------
' Процедура дополняет таблицы отсутствующими строками
'-----------------------------------------------------------------------------------------------------
Sub InitTables()
  ' Проверяем список типов документов
  For Each rClassif In ThisApplication.Classifiers("NODE_DOC_TYPES_ALL").Classifiers
    For Each tNode In rClassif.Classifiers
      If SearchCTable(ThisForm.Attributes("ATTR_DOCS_EXP_DOC_TYPE"), "ATTR_DOCS_EXP_DOC_TYPE_NAME", tNode.Description) = 0 Then
        Set nRow = ThisForm.Attributes("ATTR_DOCS_EXP_DOC_TYPE").Rows.Create
        nRow.Attributes("ATTR_DOCS_EXP_DOC_TYPE_NAME") = tNode
      End If
    Next
  Next
  ' Проверяем список типов файлов
  If ThisApplication.FileDefs.Count <> ThisForm.Attributes("ATTR_DOCS_EXP_FILE_TYPE").Rows.Count Then
    For Each tFile In ThisApplication.FileDefs
      If SearchFTable(ThisForm.Attributes("ATTR_DOCS_EXP_FILE_TYPE"), "ATTR_DOCS_EXP_FILE_TYPE_ID", tFile.SysName) = 0 Then
        Set nRow = ThisForm.Attributes("ATTR_DOCS_EXP_FILE_TYPE").Rows.Create
        nRow.Attributes("ATTR_DOCS_EXP_FILE_TYPE_ID") = tFile.SysName
        nRow.Attributes("ATTR_DOCS_EXP_FILE_TYPE_NAME") = tFile.Description
      End If
    Next
  End If
End Sub

'-----------------------------------------------------------------------------------------------------
' Функция вызывает диалог выбора корневой папки импорта
' Если путь был выбран - возвращает True
'-----------------------------------------------------------------------------------------------------
Function SelectFolder()
SelectFolder = ""
' Необходимо указать путь для экспорта
On Error Resume Next
  Set tShell = CreateObject("Shell.Application")
  Set objFolder = tShell.BrowseForFolder(0, "Выбор папки", 1)
  Path = objFolder.Self.Path

On Error GoTo 0
  If Err.Number <> 0 Or Path = "" Then
    MsgBox "Папка не выбрана!", vbInformation, "Действие отменено"
  Else
    ' ----------- Очистка папки -----------
    'If MsgBox("Внимание! Все файлы в составе выбранной папки будут удалены",vbExclamation+vbYesNo,"Продолжить ?") = vbYes Then
    ' Очищаем папку
    '  Set FSO = CreateObject("Scripting.FileSystemObject")
    '  Set Folder = FSO.GetFolder(Path)
    '  For Each tFile In Folder.Files
    '    tFile.Delete True
    '  Next
    '  For Each tFolder In Folder.SubFolders
    '    tFolder.Delete True
    '  Next
    '  Set FSO = Nothing
      SelectFolder = Path
    ' ----------- Очистка папки -----------
    'End If
  End If
End Function
'-----------------------------------------------------------------------------------------------------

'-----------------------------------------------------------------------------------------------------
' Поиск узла классификатора в таблице
'-----------------------------------------------------------------------------------------------------
Function SearchCTable(sTable, sAttribute, sValue)
SearchCTable = 0
For Each tRow In sTable.Rows
  If tRow.Attributes(sAttribute).Value = sValue Then
    SearchCTable = SearchCTable + 1
  End If
Next
End Function
'-----------------------------------------------------------------------------------------------------

'-----------------------------------------------------------------------------------------------------
' Поиск типа файла в таблице
'-----------------------------------------------------------------------------------------------------
Function SearchFTable(sTable, sAttribute, sValue)
SearchFTable = 0
For Each tRow In sTable.Rows
  If tRow.Attributes(sAttribute).Value = sValue Then
    SearchFTable = SearchFTable + 1
  End If
Next
End Function
'-----------------------------------------------------------------------------------------------------

'-----------------------------------------------------------------------------------------------------
' Поиск похожих строк в таблице
'-----------------------------------------------------------------------------------------------------
Function SearchRows(sTable, sAttributeDef, sValue)
Dim rowsFound()
i = 0
For Each tRow In sTable.Rows
  If tRow.Attributes(sAttributeDef).Value = sValue Then
    Redim Preserve rowsFound(i)
    Set rowsFound(i) = tRow
    i = i + 1
    SearchRows = rowsFound
  End If
Next
End Function
'-----------------------------------------------------------------------------------------------------
