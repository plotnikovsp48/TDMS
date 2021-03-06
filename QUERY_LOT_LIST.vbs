'**************************************************
'*Автор: Марьин Андрей                            *
'*Дата создания(dmy): 11.01.2018                  *
'*Описание:                                       *
'**************************************************
Sub Query_AfterExecute(Sheet, Query, Obj)
  'on error resume next
  Dim RCount, CCount, AttrCount, i, j, c
  RCount = Sheet.RowsCount 
  CCount = Sheet.ColumnsCount  
  For i=0 to RCount-1    
    AttrCount = Sheet.objects(0).Attributes.Count
    For j=0 to AttrCount-1
      If Sheet.objects(i).attributes(j).AttributeDefName = "ATTR_TENDER_LOT_PRICE" Then 'Цена лота без НДС
        Val = Sheet.objects(i).attributes(j).value
        For c = 0 to CCount-1
          If Sheet.ColumnName(c) = "Цена лота без НДС" Then Sheet.CellValue(i,c) = FormatCurrency(Val,2,-1,-1) 
        Next
      End If
      If Sheet.objects(i).attributes(j).AttributeDefName = "ATTR_TENDER_LOT_NDS_PRICE" Then 'Цена лота c НДС
        Val = Sheet.objects(i).attributes(j).value 
        For c = 0 to CCount-1  
          If Sheet.ColumnName(c) = "Цена лота с НДС" Then Sheet.CellValue(i,c) = FormatCurrency(Val,2,-1,-1)
        Next  
      End If
      If Sheet.objects(i).attributes(j).AttributeDefName = "ATTR_TENDER_SUM_NDS" Then 'Сумма НДС
        Val = Sheet.objects(i).attributes(j).value 
        For c = 0 to CCount-1  
          If Sheet.ColumnName(c) = "Сумма НДС" Then Sheet.CellValue(i,c) = FormatCurrency(Val,2,-1,-1)
        Next  
      End If     
      
    Next  
  Next
End Sub
