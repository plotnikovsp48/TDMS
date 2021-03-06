'**************************************************
'*Автор: Марьин Андрей                            *
'*Дата создания(dmy): 08.12.2017                  *
'*Описание:                                       *
'**************************************************

Sub Query_AfterExecute(Sheet, Query, Obj)
  Dim c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, RCount, CCount, DtVal
  Dim ElemVal1, ElemVal2, ElemVal3, ElemVal4, ElemVal5, ElemVal6, ElemVal7, ElemVal8
  DtVal = ""
  RCount = Sheet.RowsCount
  CCount = Sheet.ColumnsCount 
  'Присваиваем переменным номера столбцов 
  for j=0 to CCount-1   
    if sheet.ColumnName(j)= "Срок согласования" then c1=j 
    if sheet.ColumnName(j)= "Пользователь.Элемент оргструктуры" then c2=j 
    if sheet.ColumnName(j)= "Пользователь.Подразделение" then c3=j 
'    if sheet.ColumnName(j)= "Блок" then c4=j 
    if sheet.ColumnName(j)= "Согласующий" then c5=j 
    if sheet.ColumnName(j)= "Комментарий согласующего" then c6=j 
    if sheet.ColumnName(j)= "Дата поступления" then c7=j 
    if sheet.ColumnName(j)= "Дата согласования" then c8=j 
    if sheet.ColumnName(j)= "Резолюция" then c9=j 

  Next  

    if RCount <= 0 then  exit sub
    if RCount = 1 and sheet.CellValue(0,0) = 0 then exit sub
    
  For i = 0 to RCount-1
    If sheet.CellValue(i,"Статус") = "" or sheet.CellValue(i,"Статус") = "Отменено" then 
      sheet.CellValue(i,"Статус") = "Не согласовывалось"
    end if  
        
'-----------------------"Срок согласования" - обрезаем время----------------
    If DtVal = "" Then DtVal = Sheet.CellValue(i,c1)
    If DtVal < Sheet.CellValue(i,c1) Then DtVal = Sheet.CellValue(i,c1)
    If len(DtVal) <> 10  then DtVal = left(DtVal,10)    
    Sheet.CellValue(0,c1) = "Контрольный срок согласования: " & DtVal 
    
'-----------------------закончили "Срок согласования" - обрезаем время------
'-----------------------"Пользователь.Элемент оргструктуры"----------------
    ElemVal1 = Sheet.CellValue(i,c2)
    if len(ElemVal1) = 0  then ElemVal1 = "-"
    Sheet.CellValue(i,c2) = ElemVal1
'-----------------------закончили "Пользователь.Элемент оргструктуры"------ 
'-----------------------"Пользователь.Подразделение"---------------------------------------------
    ElemVal2 = Sheet.CellValue(i,c3)
    if len(ElemVal2) = 0  then ElemVal2 = "-"
    Sheet.CellValue(i,c3) = ElemVal2
'-----------------------закончили "Пользователь.Подразделение"----------------------------------- 
''-----------------------"Блок"---------------------------------------------
'    ElemVal3 = Sheet.CellValue(i,c4)
'    if len(ElemVal3) = 0  then ElemVal3 = "-"
'    Sheet.CellValue(i,c4) = ElemVal3
''-----------------------закончили "Блок"-----------------------------------  
'-----------------------"Согласующий"---------------------------------------------
    ElemVal4 = Sheet.CellValue(i,c5)
    if len(ElemVal4) = 0  then ElemVal4 = "-"
    Sheet.CellValue(i,c5) = ElemVal4
'-----------------------закончили "Согласующий"-----------------------------------   
'-----------------------"Комментарий согласующего"-------------------------
    ElemVal5 = Sheet.CellValue(i,c6)
    if len(ElemVal5) = 0  then ElemVal5 = "-"
    Sheet.CellValue(i,c6) = ElemVal5
'-----------------------закончили "Комментарий согласующего"---------------   
'-----------------------"Дата поступления"---------------------------------
    ElemVal6 = Sheet.CellValue(i,c7)
    if len(ElemVal6) = 0  then ElemVal6 = "-"
    Sheet.CellValue(i,c7) = ElemVal6
'-----------------------закончили "Дата поступления"-----------------------   
'-----------------------"Дата согласования"--------------------------------
    ElemVal7 = Sheet.CellValue(i,c8)
    if len(ElemVal7) = 0  then ElemVal7 = "-"
    Sheet.CellValue(i,c8) = ElemVal7
'-----------------------закончили "Дата согласования"----------------------   
'-----------------------"Резолюция"----------------------------------------
    ElemVal8 = Sheet.CellValue(i,c9)
    if len(ElemVal8) = 0  then ElemVal8 = "-"
    Sheet.CellValue(i,c9) = ElemVal8
'-----------------------закончили "Резолюция"------------------------------  
  Next  
End Sub
