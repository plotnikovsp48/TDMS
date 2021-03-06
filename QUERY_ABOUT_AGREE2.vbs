'**************************************************
'*Автор: Марьин Андрей                            *
'*Дата создания(dmy): 11.01.2018                  *
'*Описание:                                       *
'**************************************************
Sub Query_AfterExecute(Sheet, Query, Obj)
Dim RCount,i
  RCount = Sheet.RowsCount
  For i = 0 to RCount-1  
    Sheet.CellValue(i,"Описание") = TitleAll(Sheet, i)
  Next  
End Sub
'**************************************************
'* Функция формирует заголовок                    *
'*                                                *
'*                                                *
'**************************************************
Function TitleAll (Sheet_, i_)
  TitleAll = ""
  Dim NewVal, DateVal, StrVal, MonthN
  Select Case Sheet_.CellValue(i_,"Тип объекта")
    Case "Протокол"
     NewVal = "Протокол № "
    Case "Входящий документ"
     NewVal = "к Входящему документу № "
    Case "Исходящий документ"
     NewVal = "к Исходящему документу № "
    Case "Служебная записка"
     NewVal = "к Служебной записке № "  
    Case "Заявка на оплату"
     NewVal = "к Заявке на оплату № " 
    Case "ОРД" 
      NewVal = Sheet_.CellValue(i_,"Тип документа")
        Select Case NewVal
          Case "Регламент"
            NewVal = "к Регламенту №"
          Case "Приказ"
            NewVal = "к Приказу №"
          Case "Распоряжение"
            NewVal = "к Распоряжению №"
          Case "Инструкция "
            NewVal = "к Инструкции №"
          Case "Положение"
            NewVal = "к Положению №"
          Case "Кадровый приказ "
            NewVal = "к Кадровому приказу №"
          Case "Программа"
            NewVal = "к Программе №"    
        End Select                  
  End Select      
    If NewVal <> "" Then StrVal = StrVal & NewVal & " "
      NewVal = Sheet_.CellValue(i_,"Регистрационный №")
    If NewVal <> "" Then StrVal = StrVal & NewVal & " "
      DateVal = Sheet_.CellValue(i_,"Дата создания")
    If DateVal <> "" Then 
      NewVal = "от «" & Day(DateVal) & "» "
      MonthN = MonthNameBow(MonthName(Month(DateVal),false))  
      NewVal = NewVal & MonthN & " " & Year(DateVal) & "г."
    End If             
    If NewVal <> "" Then StrVal = StrVal & NewVal & vbNewLine
      NewVal = Sheet_.CellValue(i_,"Тема")
    If NewVal <> "" Then StrVal = StrVal & "«Тема: " & NewVal & "» " 
    TitleAll = StrVal
End Function
'**************************************************
'* Функция склоняет месяц                         *
'*                                                *
'*                                                *
'**************************************************
Function MonthNameBow (MonthName_)
  MonthNameBow = MonthName_
      Select Case MonthName_ 
        Case "Январь"
          MonthNameBow = "Января"
        Case "Февраль"
          MonthNameBow = "Февраля"
        Case "Март"
          MonthNameBow = "Марта"
        Case "Апрель"
          MonthNameBow = "Апреля"
        Case "Май"
          MonthNameBow = "Майя"
        Case "Июнь"
          MonthNameBow = "Июня"
        Case "Июль"
          MonthNameBow = "Июля"
        Case "Август"
          MonthNameBow = "Августа"
        Case "Сентябрь"
          MonthNameBow = "Сентября"
        Case "Октябрь"
          MonthNameBow = "Октября"
        Case "Ноябрь"
          MonthNameBow = "Ноября"
        Case "Декабрь"
          MonthNameBow = "Декабря"
      End Select 
End Function
