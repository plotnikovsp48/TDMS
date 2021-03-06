'**************************************************
'*Автор: Марьин Андрей                            *
'*Дата создания(dmy): 07.11.2007                  *
'*Описание: Раскраска "Плановых задач"            *
'*   -желтым, если наступление работ по плану     *
'*   ожидается в текущем месяце                   *
'*   -красным, если дата начала работ по плану    *
'*   просрочена                                   *
'**************************************************
Sub SetNewOrder(Sheet, Query, Obj)
Dim c, c1, c2, RCount, CCount, j, i, f
  RCount = Sheet.RowsCount
  CCount = Sheet.ColumnsCount 
  'Присваиваем переменным номера столбцов 
  for j=0 to CCount-1    
    if sheet.ColumnName(j)= "Ожидаемая дата окончания работ" then c=j
    if sheet.ColumnName(j)= "Тип закрытия задачи" then c1=j 
    if sheet.ColumnName(j)= "Дата окончания работ по факту" then c2=j       
  Next
  'Выделение результата выборки цветом
  for i=0 to RCount-1    
    Set f = Sheet.RowFormat(i) 
      'Выделяется красным при выполнении условий
      '"Дата начала работ по плану" наступила
      '"Тип закрытия задачи" не "Завершена" и не "Аннулирована"
      '"Дата окончания работ по факту" не наступила
      if (Sheet.CellValue(i,c) <= date) and _
        (not((Sheet.CellValue(i,c1)="Завершена") or (Sheet.CellValue(i,c1)="Аннулирована"))) _
        and ((Sheet.CellValue(i,c2)="") or (Sheet.CellValue(i,c2)>date)) then
          f.BackColor = RGB(255, 182, 193)
      'Выделяется желтым при выполнении условий
      '"Дата начала работ по плану" ожидается в текущем месяце
      '"Тип закрытия задачи" не "Завершена" и не "Аннулирована"
      '"Дата окончания работ по факту" не наступила    
      elseif Sheet.CellValue(i,c) < DateAdd( "ww", 2, date) and _
        (not((Sheet.CellValue(i,c1)="Завершена") or (Sheet.CellValue(i,c1)="Аннулирована"))) _
        and ((Sheet.CellValue(i,c2)="") or (Sheet.CellValue(i,c2)>date)) then
          f.BackColor = RGB(255, 255, 192)    
      end if   
  Next
End Sub  

Sub Query_AfterExecute(Sheet, Query, Obj)
  call SetNewOrder(Sheet, Query, Obj)  
End Sub
