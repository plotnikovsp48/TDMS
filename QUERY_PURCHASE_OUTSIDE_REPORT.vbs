'**************************************************
'*Автор: Марьин Андрей                            *
'*Дата создания(dmy): 27.12.2017                  *
'*Описание: Вычисляем сколько дней просрочено     *
'*          на согласование решения о закупке     *
'**************************************************

Sub Query_AfterExecute(Sheet, Query, Obj)
  Dim i, j, RCount, CCount, DtVal, DtVal1, Result
    RCount = Sheet.RowsCount
    CCount = Sheet.ColumnsCount 
  For j=0 to CCount-1   
    If sheet.ColumnName(j)= "Просрочка" Then c1=j 
    If sheet.ColumnName(j)= "Контрольный срок" Then c2=j 
    If sheet.ColumnName(j)= "Дата решения" Then c3=j 
  Next 
  For i = 0 to RCount-1
    '***********-"Контрольный срок" - ****************
    DtVal = Sheet.CellValue(i,c2)
    '***********-"Дата решения" - *******************
    DtVal1 = Sheet.CellValue(i,c3)
    '***********-"Просрочка" - **********************
    If DtVal1 = "" Then DtVal1 = date
    Result = DateDiff("d", DtVal, DtVal1)
    If Result > 0 Then Sheet.CellValue(i,c1) = Result
  Next
End Sub