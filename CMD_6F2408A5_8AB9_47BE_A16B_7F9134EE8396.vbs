


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
              if user.Position="" then 
                arr = Split(user.Description,chr(32))  
                
                List.Cells(i, 1) = user.Description 'Краткое описание
                List.Cells(i, 2) = user.LastName & " " & user.FirstName & " " & user.MiddleName 'ФИО
                List.Cells(i, 3) = user.Position 'Должность
                List.Cells(i, 4) = user.Department 'Отдел
              
             
                  Set q = ThisApplication.Queries("QUERY_16EFF847_B3A0_479B_A705_100237AF842A")    
                  q.Parameter("Param0") =  user.Description
              '    msgbox "Param0"& q.Parameter("Param0")
                  Set sh = q.Sheet
               '    msgbox  sh.RowsCount
                  For j = 0 To (sh.RowsCount-1)
                 '   msgbox sh.CellValue( j,1)
                    user.Position = sh.CellValue( j,2)
                    List.Cells( i, 5) = sh.CellValue( j,2)      'Телефон
                  Next
                     
                
                If user.Position  =""  Then 
                  'msgbox  user.Attributes("ATTR_KD_DEPART").value
                  
                
                End If
                
                 ' List.Cells(i, 7) =  user.Attributes("ATTR_KD_DEPART").value
               
                List.Cells(i, 8) =arr(0) 'фам
                List.Cells(i, 9) = arr(1) 'и
                List.Cells(i, 10) = arr(2) 'о
                
                
               
                i = i + 1
                str = ""
              end if  
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

