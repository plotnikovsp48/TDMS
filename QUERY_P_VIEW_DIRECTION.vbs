'**************************************************
'*Автор: Марьин Андрей                            *
'*Дата создания(dmy): 11.01.2018                  *
'*Описание:                                       *
'**************************************************
Sub Query_AfterExecute(Sheet, Query, Obj)
    RCount = Sheet.RowsCount
    If Rcount <= 0 Then  exit sub
    For i = 0 to Sheet.RowsCount-1
        dtVal = Sheet.CellValue(i,"Дата 1")
        If len(dtVal) > 10  Then 
          dtVal = left(dtVal,10)
        If not IsEmpty(dtVal) Then _
          Sheet.CellValue(i,"Дата 1") =  dtVal         
        Else
          Sheet.CellValue(i,"Дата 1") =  "-"
        End If
        dtVal = Sheet.CellValue(i,"Дата 2")
        If len(dtVal) > 10  Then 
          dtVal = left(dtVal,10)
        If not IsEmpty(dtVal) Then _
          Sheet.CellValue(i,"Дата 2") =  dtVal
        Else
          Sheet.CellValue(i,"Дата 2") =  "-"
        End If          
        If Sheet.CellValue(i,"Должность") =  "" Then _
          Sheet.CellValue(i,"Должность") =  "-"
        If Sheet.CellValue(i,"Автор") =  "" Then _
          Sheet.CellValue(i,"Автор") =  "-"
        If Sheet.CellValue(i,"ФИО") =  "" Then _
          Sheet.CellValue(i,"ФИО") =  "-"
    Next  
End Sub
