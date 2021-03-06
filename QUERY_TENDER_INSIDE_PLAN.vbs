' Выборка - План внутренних закупок
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Sub Query_AfterExecute(Sheet, Query, Obj)
  'Sheet.AddColumn 1
  AttrName = "ATTR_TENDER_ITEM_PRICE_MAX_VALUE"
  ColNum = 25
  ColNum1 = 6
  Sheet.InsertColumn ColNum1, 1
  Sheet.ColumnName(ColNum1) = ThisApplication.AttributeDefs(AttrName).Description
  If Sheet.ColumnsCount >= ColNum Then
    Sheet.InsertColumn ColNum, 1
    Sheet.ColumnName(ColNum) = "Потенциальные участники"
  End If
  
  If Sheet.RowsCount <> 0 Then
    For i = 0 to Sheet.RowsCount-1
      Set Obj0 = Sheet.RowValue(i)
      str = ""
      If not Obj0 is Nothing Then
        If Obj0.Attributes.Has("ATTR_TENDER_POSSIBLE_CLIENT") Then
          Set TableRows = Obj0.Attributes("ATTR_TENDER_POSSIBLE_CLIENT").Rows
          For Each Row in TableRows
            Set Attr = Row.Attributes(0)
            If Attr.Empty = False Then
              If str <> "" Then
                str = str & ", " & Attr.Value
              Else
                str = Attr.Value
              End If
            End If
          Next
        End If
      End If
      If str <> "" Then
        Sheet.CellValue(i,ColNum) = str
      End If
      
      'Атрибут Расчетная (максимальная) цена предмета закупки (договора), цена с НДС, сумма НДС и цена без НДС
      If Obj0.Attributes.Has(AttrName) Then
        Set TableRows = Obj0.Attributes(AttrName).Rows
        If TableRows.Count > 0 Then
          Set Row = TableRows(0)
          str = ""
          For Each Attr in Row.Attributes
            Val = Attr.AttributeDef.Description & ": " & Attr.Value
            If str <> "" Then
              str = str & " " & Val
            Else
              str = Val
            End If
          Next
          Sheet.CellValue(i,ColNum1) = str
        End If
      End If
    Next
  End If
End Sub
