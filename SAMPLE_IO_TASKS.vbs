
'**************************************************
'*Автор: Марьин Андрей                            *
'*Дата создания(d/m/yyyy): 04.12.2007             *
'*Описание: Раскраска "Выборки ИО Задание"        *
'**************************************************
Sub SetNewOrder(Sheet, Query, Obj)
Dim c1, c2, RCount, CCount, j, i, f
  RCount = Sheet.RowsCount
  CCount = Sheet.ColumnsCount 
  'Запоминаем в переменную номер столбца 
  for j=0 to CCount-1    
    if sheet.ColumnName(j)= "Ожидаемый срок окончания, части проекта." then c1=j 
    if sheet.ColumnName(j)= "Ожидаемая дата начала, задания." then c2=j       
  Next
  'Задаем условия выделения цветом
  for i=0 to RCount-1    
    Set f = Sheet.RowFormat(i)  
      'красный, Дата начала задания ожидается после ожидаемой даты завершения проекта         
      if Sheet.CellValue(i,c1) < Sheet.CellValue(i,c2) then
        f.BackColor = RGB(255, 182, 193)   
      end if  
  Next
End Sub  

Sub Query_AfterExecute(Sheet, Query, Obj)
  call SetNewOrder(Sheet, Query, Obj)  
End Sub