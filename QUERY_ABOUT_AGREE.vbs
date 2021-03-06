'**************************************************
'*Автор: Марьин Андрей                            *
'*Дата создания(dmy): 08.12.2017                  *
'*Описание:                                       *
'**************************************************

Sub Query_AfterExecute(Sheet, Query, Obj)
  Dim c1, c2, c3, c4, c5, Str2, RCount, CCount, NewVal, StrVal, DtVal, pr, sf, OtvVal1, OtvVal2
  DtVal = ""
  RCount = Sheet.RowsCount
  CCount = Sheet.ColumnsCount 
  'Присваиваем переменным номера столбцов 
  for j=0 to CCount-1    

    If sheet.ColumnName(j)= "Дата создания" then c1=j 
    If Sheet.ColumnName(j) = "Подписант" then c2=j
    If Sheet.ColumnName(j) = "Утверждающий" then c3=j
    If Sheet.ColumnName(j) = "Пользователь.Телефон" then c4=j
    If Sheet.ColumnName(j) = "Статус" then c5=j    
    
  Next   
  '----
  For i = 0 to RCount-1
    StrVal = Sheet.CellValue(i,"Тип объекта")&". " 
    NewVal = Sheet.CellValue(i,"Вид СЗ")
    if NewVal <> "" then StrVal = StrVal & NewVal & ". "
    newVal = Sheet.CellValue(i,"Тип документа")
    if NewVal <> "" then StrVal = StrVal & NewVal & ". "
    newVal = Sheet.CellValue(i,"Регистрационный №")
    StrVal = StrVal & "№ "
    
    If Sheet.Objects(i).IsKindOf("OBJECT_DOC") or _
       Sheet.CellValue(i,"Тип объекта") = "Внешняя закупка" or Sheet.CellValue(i,"Тип объекта") = "Внутренняя закупка" Then
       StrVal = Sheet.CellValue(i,"Описание")
    ElseIf Sheet.CellValue(i,"Тип объекта") = "Договор" or Sheet.CellValue(i,"Тип объекта") = "Акт" or Sheet.CellValue(i,"Тип объекта") = "Соглашение" or _
       Sheet.CellValue(i,"Тип объекта") = "Задание" Then
       StrVal = Sheet.CellValue(i,"Тип объекта") & " " & Sheet.CellValue(i,"Описание")
    End If
    
    if NewVal <> "" and NewVal <> 0 then 
      if Sheet.CellValue(i,"Тип объекта") = "Входящий документ" or Sheet.CellValue(i,"Тип объекта") = "Исходящий документ" then 
        pr = Sheet.CellValue(i,"Префикс")
        if pr <> "" then StrVal = StrVal & pr & "/"
        StrVal = StrVal & NewVal 
        sf =  Sheet.CellValue(i,"Суффикс")
        if sf <> "" then StrVal = StrVal & sf  
      else  
        StrVal = StrVal & NewVal 
      end if  
    end if
'-----------------------"Дата регистрации" - обрезаем время----------------
    DtVal = Sheet.CellValue(i,c1)
    If DtVal = "" or DtVal < Sheet.CellValue(i,c1) Then DtVal = Sheet.CellValue(i,c1)
    if len(DtVal) <> 10  then DtVal = left(DtVal,10)
    Sheet.CellValue(0,c1) = "Дата отправки на согласование: " & DtVal 
'-----------------------закончили "Дата регистрации" - обрезаем время------
    StrVal = StrVal & " от "
    StrVal = StrVal & DtVal & ". "
    StrVal = StrVal & "''" & Sheet.CellValue(i,"Тема") & "''"
    Sheet.CellValue(i,"Описание") = StrVal     
    NewVal = Sheet.CellValue(i,"Статус")      
'-----------------------"Подписант\Утверждающий" --------------------------
    OtvVal1 = Sheet.CellValue(i,c3)
    OtvVal2 = Sheet.CellValue(i,c2)
    If Sheet.CellValue(i,"Тип объекта") = "Служебная записка"  then 
      Sheet.CellValue(i,c3) = "Утвердил: "
      Sheet.CellValue(i,c2) = OtvVal1
    Else
      Sheet.CellValue(i,c3) = "Подписал: "  
      Sheet.CellValue(i,c2) = OtvVal2 
    End If     
'-----------------------закончили "Подписант\Утверждающий" ----------------
'-----------------------"Результат согласования" -----------
    Select Case Sheet.CellValue(i,c5)
      Case "Подписан"
        Sheet.CellValue(i,c5) = "Согласовано"
      Case "Рассмотрен руководством"
        Sheet.CellValue(i,c5) = "Согласовано"
      Case "Согласован"
        Sheet.CellValue(i,c5) = "Согласовано"
      Case "Отправлен"
        Sheet.CellValue(i,c5) = "Согласовано"
      Case "Черновик"
        Sheet.CellValue(i,c5) = "Не согласовано"
      Case "Зарегистрирован"
        Sheet.CellValue(i,c5) = "Не согласовано"
      Case "На согласовании"
        Sheet.CellValue(i,c5) = "Не согласовано" 
      Case "На проверке"
        Sheet.CellValue(i,c5) = "Не согласовано" 
      Case "На подписании"
        Sheet.CellValue(i,c5) = "Не согласовано" 
      Case "Отменен"
        Sheet.CellValue(i,c5) = "Не согласовано"            
    End Select
'-----------------------закончили "Результат согласования"------
'-----------------------закончили "Нижнй колонтитул" ----------------------
    CurUserFname = ThisApplication.CurrentUser.FirstName
    CurUserLname = ThisApplication.CurrentUser.LastName
    CurDep = ThisApplication.CurrentUser.Department
    Str="Распечатано из СЭД: " & CurUserFname & " " & CurUserLname & " " & CurDep & " " & date
     Sheet.CellValue(i,c4) = Str
'-----------------------закончили "Нижнй колонтитул" ----------------------
    
  Next
End Sub
