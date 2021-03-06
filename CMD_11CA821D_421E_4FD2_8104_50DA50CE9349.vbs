
Option Explicit
Call ExportUsersInfo()


'==============================================================================
' Вывести в MSExcel информацию обо всех пользователях, созданных в настройке
'==============================================================================
Sub ExportUsersInfo()

        On Error Resume Next
        Err = 0    
        
        Dim ExcelApp, WrkBook, AllUsers, user, List, str, i, j, q, sh


        'Если нет информации о пользователях, выйти из процедуры
        If ThisApplication.Users.Count = 0 Then 
                MsgBox "Пользователи в системе отсутствуют.", _
                        vbInformation, "Информация о текущей настройке"
        End If

        'Открыть приложение Excel
        Set ExcelApp = CreateObject("Excel.Application")
        If Err <> 0 Then 'Ошибка открытия ...
                MsgBox "Невозможно открыть приложение MS Excel.",  vbInformation, "ошибка MS Excel" 
                Exit Sub
        End If
                            
        ' Добавить рабочую книгу
        Set WrkBook = ExcelApp.Workbooks.Add
        Set List = WrkBook.ActiveSheet
    
        'Вывести на текущий лист информацию о пользователях
         
        
        i = 2
        Set AllUsers = ThisApplication.Users ' Получить коллекцию пользователей
        dim ObjRoots
      'Показать окно Excel
        ExcelApp.Application.Visible = TRUE
        
        For Each user In AllUsers
                Dim arr
                arr = Split(user.Description,chr(32))  
                
                List.Cells(i, 1) = user.Description 'Краткое описание
                List.Cells(i, 2) = user.LastName & " " & user.FirstName & " " & user.MiddleName 'ФИО
                List.Cells(i, 3) = user.Position 'Должность
                List.Cells(i, 4) = user.Department 'Отдел
              
              
               ' заполняем ФИО - фамилия и. о.
                  user.LastName= arr(0)
                  user.FirstName= arr(1)
                  user.MiddleName=  arr(2)
                  user.Attributes("ATTR_KD_FIO").value = arr(0) & " " & Left (arr(1),1 ) & ". "& Left (arr(2),1 )  & "."
             '   End If
                
                'Телефон  
   '               Set q = ThisApplication.Queries("QUERY_USER_FIO")   
    
                 
    '              q.Parameter("Param0") =  user.Description
              '    msgbox "Param0"& q.Parameter("Param0")
     '             Set sh = q.Sheet
               '    msgbox  sh.RowsCount
      '            For j = 0 To (sh.RowsCount-1)
       '          '   msgbox sh.CellValue( j,1)
        '            user.Phone = sh.CellValue( j,1)
         '           List.Cells( i, 5) = sh.CellValue( j,1)      'Телефон
          '        Next
                     
                
 '               If user.Attributes("ATTR_KD_DEPART").value =""  Then 
                  'msgbox  user.Attributes("ATTR_KD_DEPART").value
  '                Select Case Left (user.Phone, 1)
                    
   '                 Case "1"   List.Cells(i, 7) = "тут будет крск"' 
    '                user.Attributes("ATTR_KD_DEPART").value =    ThisApplication.GetObjectByGUID("{2906C772-FBFF-45AB-A6D6-C777715F037F}")'     "Красноярск"        
     '            
      '              Case "2"   List.Cells(i, 7) = "тут будет мск" 
       '              user.Attributes("ATTR_KD_DEPART").value =   ThisApplication.GetObjectByGUID("{F2641A9F-02EE-47B1-B2B3-708947205D2D}") '"Москва"                 
                     
        '            Case "3"   List.Cells(i, 7) = "тут будет тюмень"
         '           user.Attributes("ATTR_KD_DEPART").value =ThisApplication.GetObjectByGUID("{670225A7-FD07-4F87-9DC4-A508E28B9F33}") '"Тюмень"                    
                    
     '               Case "4"   List.Cells(i, 7) = "тут будет самара"
     '               user.Attributes("ATTR_KD_DEPART").value = ThisApplication.GetObjectByGUID("{266FE8C1-5289-4EA6-95BA-8F5CE987CC71}") ' "Самара"                   
       
     '             End Select
                
       '         End If
                
                 ' List.Cells(i, 7) =  user.Attributes("ATTR_KD_DEPART").value
               
                List.Cells(i, 8) =arr(0) 'фам
                List.Cells(i, 9) = arr(1) 'и
                List.Cells(i, 10) = arr(2) 'о
                
                
                If user.AllowLogin Then str = "Да" 'Пользователь TDMS?
                List.Cells(i, 6) = str
                i = i + 1
                str = ""
        Next
        
        'Отформатировать шапку таблицы
        List.Cells(1,1) = "Краткое описание"            
        List.Cells(1,2) =     "ФИО"
        List.Cells(1,3) = "Должность"            
        List.Cells(1,4) =     "Отдел"
        List.Cells(1,5) = "Телефон"            
        List.Cells(1,6) =     "Пользователь TDMS?"
        List.Rows(1).Font.Size = 12
        List.Rows(1).Font.Bold = TRUE
        List.Columns.AutoFit
        
   
End Sub 
'==============================================================================

