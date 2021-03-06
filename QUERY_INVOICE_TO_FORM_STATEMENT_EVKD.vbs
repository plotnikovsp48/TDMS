' Выборка - Формирование ведомости ЭВКД
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.


Sub Query_AfterExecute(Sheet, Query, Obj)
  'Изменение столбцов
  Sheet.AddColumn 2
  nColDate = Sheet.ColumnsCount-2
  nColTime = Sheet.ColumnsCount-1
  nColCode = 0
  nColName = 1
  nColGrif = 2
  Sheet.ColumnName(nColCode) = "Обозначение"
  Sheet.ColumnName(nColGrif) = "Гриф"
  Sheet.ColumnName(nColDate) = "Дата"
  Sheet.ColumnName(nColTime) = "Время"
  
  'Изменение значений строк
  For i = 0 to Sheet.RowsCount-1
    'Обозначение и наименование
    Guid = Sheet.CellValue(i,0)
    If Guid <> "" Then
      Set Obj0 = ThisApplication.GetObjectByGUID(Guid)
      If not Obj0 is Nothing Then
        AttrName0 = ""
        AttrName1 = ""
        If Obj0.ObjectDefName = "OBJECT_VOLUME" Then
          AttrName0 = "ATTR_VOLUME_CODE"
          AttrName1 = "ATTR_VOLUME_NAME"
        ElseIf Obj0.ObjectDefName = "OBJECT_WORK_DOCS_SET" Then
          AttrName0 = "ATTR_WORK_DOCS_SET_CODE"
          AttrName1 = "ATTR_WORK_DOCS_SET_NAME"
        Else
          AttrName0 = "ATTR_DOC_CODE"
          AttrName1 = "ATTR_DOCUMENT_NAME"
        End If
        If Obj0.Attributes.Has(AttrName0) Then
          Sheet.CellValue(i,nColCode) = Obj0.Attributes(AttrName0).Value
        End If
        If Obj0.Attributes.Has(AttrName1) Then
          Sheet.CellValue(i,nColName) = Obj0.Attributes(AttrName1).Value
        End If
      End If 
    End If
    
    DateTime = Sheet.CellValue(i,nColGrif)
    
    'Дата
    Sheet.CellValue(i,nColDate) = FormatDateTime(DateTime, vbShortDate)
    'Время
    Sheet.CellValue(i,nColTime) = FormatDateTime(DateTime, vbLongTime)
    'Гриф
    Sheet.CellValue(i,nColGrif) = ""
  Next
End Sub