' Выборка - Согласованные
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Sub Query_AfterExecute(Sheet, Query, Obj)
  AttrName = "ATTR_TENDER_ITEM_PRICE_MAX_VALUE"
  If ThisApplication.AttributeDefs.Has(AttrName) = False Then Exit Sub
  ColNum1 = 1
  Sheet.InsertColumn ColNum1, 1
  Sheet.ColumnName(ColNum1) = ThisApplication.AttributeDefs(AttrName).Description
  For i = 0 to Sheet.RowsCount-1
    Set Obj0 = Sheet.RowValue(i)
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
End Sub


