
USE "LIB_TEMPLATE_UTILITY"

Sub ShowMoveBtn_OnClick()
  isVisible = ThisForm.Controls("MoveRightBtn").Visible
  ' используем единую переменную для дальнейшего присвоения всем участвующим контролам,
  ' чтобы вдруг не сложилось так, что из-за корявого выполнения часть контролов
  ' не оказалась "не в том" состоянии

  isVisible = Not isVisible
  
  ThisForm.Controls("MoveRightBtn").Visible = isVisible
  ThisForm.Controls("MoveLeftBtn").Visible = isVisible
  ThisForm.Controls("NewListGrid").Visible = isVisible
  ThisForm.Controls("NewNameEdit").Visible = isVisible
  
  ' если объект был изменён, делаем видимой кнопку "применить"
  isModified = ThisForm.Dictionary("IsModified")
  If isModified And isVisible Then
    ThisForm.Controls("ApplyBtn").Visible = True
  Else
    ThisForm.Controls("ApplyBtn").Visible = False
  End If
  
  Set targetGrid = ThisForm.Controls("NewListGrid").ActiveX
  targetGrid.InsertMode = False

End Sub

' - - - - - - - - - - - - - - - -
Sub Form_BeforeShow(Form, Obj)

  ' подгружаем в комбоитемс названия всех объектов шаблонов
  entryCollection = GetAttributeValuesFromQuery("OBJECT_TEMPLATE_LIST", "ATTR_TEMPLATE_LIST_NAME")
  
  Set ctrl = ThisForm.Controls("NewNameEdit").ActiveX
  ctrl.Text = "Название нового списка шаблонов"
  ctrl.ComboItems = entryCollection

  ' добавляем столбец к таблице
  Set newGrid = ThisForm.Controls("NewListGrid").ActiveX
  newGrid.InsertColumn 0, "Текстовый шаблон", 100
  newGrid.ColumnEditable(0) = True
  
  'newGrid.ColumnEditable(0) = False ' по умолчанию столбец не редактируемый
    ' хаха, НЕ РАБОТАЕТ, он так и остаётся нередактируемый
  
End Sub

' - - - - - - - - - - - - - - - -
' применяем изменения в списке шаблонов
Sub ApplyBtn_OnClick()
  Set targetGrid = ThisForm.Controls("NewListGrid").ActiveX
  Set targetNameEdit = ThisForm.Controls("NewNameEdit").ActiveX
  
  ' FIXME: проверка на InsertMode? - плюс одна строка
  If targetGrid.RowCount <= 0 Then Exit Sub
   
  ' если список уже существует, то дозаписываем к нему
  Set found = FindObjectByAttrValue("OBJECT_TEMPLATE_LIST", "ATTR_TEMPLATE_LIST_NAME", targetNameEdit.Text)
  
  If found Is Nothing Then 
'    ' создаём новый объект в коллекции объектов, принадлежащих описанию типа
'    Set objects = ThisApplication.ObjectDefs("OBJECT_TEMPLATE_LIST").Objects
'  
'    Set newObj = objects.Create("OBJECT_TEMPLATE_LIST")
'    newObj.Attributes("ATTR_TEMPLATE_LIST_NAME").Value = targetNameEdit.Text
    Call CreateTemplateList(targetNameEdit.Text, "")
  'Else
  '  start = found.Attributes("ATTR_TEMPLATE_LIST").Rows.RowCount
  End If
  
  Set list = found.Attributes("ATTR_TEMPLATE_LIST")
  Set rows = list.Rows
  start = rows.Count
  max = targetGrid.RowCount
  If targetGrid.InsertMode Then max = max - 1
    
  ' Переносим туда все значения из правой таблицы
  For i = start To max - 1   
    Set row = rows.Create
    row.Attributes("ATTR_TEMPLATE_ENTRY").Value = targetGrid.CellText(i, 0)
  Next
  
  ' скрываем кнопку
  ThisForm.Dictionary("IsModified") = False
  ThisForm.Controls("ApplyBtn").Visible = False
End Sub

Sub MoveRightBtn_OnClick()
  ' если в "левой" таблице ничего не выделено, выходим
  Set originalGrid = ThisForm.Controls("ATTR_TEMPLATE_LIST").ActiveX
  Set targetGrid = ThisForm.Controls("NewListGrid").ActiveX
 
  selection = originalGrid.SelectedRows
  'If selection Is Nothing Then Exit Sub
  
  ' переносим выделенное из левой таблицы в правую
  For Each row in selection
    ' row - это индекс строки
    
    ' создаём аналогичную строку в правой таблице
    pos = targetGrid.RowCount
    If targetGrid.InsertMode Then pos = pos - 1 'insertMode добавляет ещё одну, пустую строку
    
    targetGrid.InsertRow(pos)
    
    ' переносим значения атрибутов
    targetGrid.CellText(pos, 0) = originalGrid.CellText(row,0)
    
    ' удаляем из левой
    originalGrid.RemoveRow(row)
  Next
    
  ' делаем кнопку "применить" видимой
  ThisForm.Dictionary("IsModified") = True
  ThisForm.Controls("ApplyBtn").Visible = True
  
End Sub


Sub MoveLeftBtn_OnClick()
  ' перемещаем строку из правой таблицы в левую
  Set originalGrid = ThisForm.Controls("ATTR_TEMPLATE_LIST").ActiveX
  Set targetGrid = ThisForm.Controls("NewListGrid").ActiveX
  
  selection = targetGrid.SelectedRows
  'If selection Is Nothing Then Exit Sub
  
  ' переносим выделенное из правой таблицы в левую
  For Each row in selection
    ' row - это индекс строки
    
    ' создаём аналогичную строку в левой таблице
    pos = originalGrid.RowCount
    If originalGrid.InsertMode Then pos = pos - 1
    
    originalGrid.InsertRow(pos)
    
    ' переносим значения атрибутов
    originalGrid.CellText(pos, 0) = targetGrid.CellText(row,0)
    
    ' удаляем из правой
    targetGrid.RemoveRow(row)
  Next
    
  ' делаем кнопку "применить" видимой
  ThisForm.Dictionary("IsModified") = True
  ThisForm.Controls("ApplyBtn").Visible = True
End Sub

' Событие отрабатывает, когда происходит "окончательное изменение" содержимого
' - например, мы выбираем элемент в комбоитемс или переводим фокус на другой контрол 
' не работает, если мы побуквенно вводим текст
Sub NewNameEdit_Modified()
  'MsgBox "modified"
  
  ' - если такой элемент есть в ComboItems - надо заполнить таблицу его значениями
  ' - если в таблице уже есть пользовательские значения, их надо перенести
  ' вариант - для нововведённых и уже существующих элементов использовать две разных таблицы
  ' - неудобно, хоть и наглядно.
  ' было бы неплохо для добавляемых, но ещё не добавленных строк выделять содержимое курсивом,
  ' но судя по всему, сейчас это недоступно
  
  ' получаем текущее значение "оригинальных строк"
  ' используем невидимый CurrentTableRCnt для запоминания, на какой строке заканчиваются исходные метки
  Set rcntCtrl = ThisForm.Controls("CurrentTableRCnt").ActiveX
  Set targetGrid = ThisForm.Controls("NewListGrid").ActiveX
  
  rcnt = rcntCtrl.Text
  If rcnt = "" Then rcnt = 0
  
  If rcnt <> 0 Then
    ' удаляем все "оригинальные" строки из таблицы
    For i = 0 To rcnt - 1
      targetGrid.RemoveRow(0)
    Next
    
    rcnt = 0
  End If
  
  ' если введённое имя соответствет существующему списку, добавляем его содержимое в таблицу
  ' сверяем введённое имя списка с набором в ComboItems - считаем, что туда подгружено всё, что нужно
  Set targetNameEdit = ThisForm.Controls("NewNameEdit").ActiveX
  Dim isObjExist: isObjExist = False
  
  For Each line In targetNameEdit.ComboItems
    If line = targetNameEdit.Text Then
      'MsgBox "Нашли совпадение"
      isObjExist = True
      Exit For
    End If
  Next
  
  ' если не найден - можем смело выходить, всё равно уже все строки удалили
  If isObjExist = False Then Exit Sub
  
  ' заполняем таблицу
  ' находим объект
  Set found = FindObjectByAttrValue("OBJECT_TEMPLATE_LIST", "ATTR_TEMPLATE_LIST_NAME", targetNameEdit.Text)
  
  ' берём его табличный атрибут
  Set list = found.Attributes("ATTR_TEMPLATE_LIST")
  ' проходимся по строкам и каждую добавляем в таблицу
  i = 0
  For each row in list.Rows
    Dim entry
    
    'msgbox "i = " & i
     
    ' получаем отдельный шаблон
    targetGrid.InsertRow(i)
    targetGrid.CellText(i, 0) = row.Attributes("ATTR_TEMPLATE_ENTRY").Value
    
    i = i + 1
    rcntCtrl.Text = i   
  Next
End Sub


Sub SelectAttrTypes_OnClick()
  Set dlg = ThisApplication.Dialogs.SelectDlg
  dlg.SelectFrom = ThisApplication.AttributeDefs
  
  ' коллекция типов атрибутов, которые будут переданы как "выбранные"
  Set attrCollection = ThisApplication.CreateCollection(tdmAttributeDefs)
  
  Set table = ThisObject.Attributes("ATTR_TEMPLATE_TYPES")
  For Each row in table.Rows
    attrCollection.Add(ThisApplication.AttributeDefs(row.Attributes("ATTR_TEMPLATE_ENTRY_TYPE").Value))
  Next
    
  dlg.UseCheckBoxes = True
  dlg.SetSelection = attrCollection
  result = dlg.Show
  
  If result = False then Exit Sub ' отменили диалог
  
  Set list = dlg.Objects
  isModified = IsModifiedCollection(list,attrCollection)
  
  If isModified = False Then Exit Sub
  
  ' сохраняем выбранные значения  
  table.Rows.RemoveAll ' очищаем таблицу и создаём заново 
  
  ' ! FIXME: можно проходиться по списку и добавлять только отсутствующие значения
  i = 0
  For Each def In list
    ' сохраняем тип в таблице
    Set row = table.Rows.Create
    row.Attributes("ATTR_TEMPLATE_ENTRY_TYPE").Value = def.SysName
    i = i + 1
  Next
  
  'Set ThisForm.Dictionary("selectedAttrTypes") = list
End Sub

