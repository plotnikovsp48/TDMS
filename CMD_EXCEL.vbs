' Автор: Орешкин А.В.
'
' Модуль функций работы с EXCEL
'------------------------------------------------------------------------------
' Авторское право © ЗАО «СИСОФТ», 2016 г.

'------------------------------------------------------------------------------
' Функция получает или создает объект "Excel.Application"
' Open:Variant - объект "Excel.Application"
'------------------------------------------------------------------------------
Function Open()
  Dim app ':Excel.Application - ссылка на приложение 
  Set app = Nothing
  Set Open = Nothing
  Err.Clear
  On Error Resume Next
    Set app = CreateObject("Excel.Application")
    'Если ошибка открытия приложения, пишем лог
    If Err <> 0 Then 
      ThisApplication.ExecuteScript "CMD_MESSAGE", "WriteToNotify", 173
      Exit Function
    End If
    app.Visible = True
    Dim dic
    Set dic = ThisApplication.Dictionary("Excel")
    dic.Add "Excel",app  
  On Error GoTo 0
  Set Open = app
End Function


'------------------------------------------------------------------------------
' Функция открывает файл в EXCEL
' OpenFile:Variant - Ссылка на Document
' app_:Variant - объект "Excel.Application"
'------------------------------------------------------------------------------
Function OpenTextFile(app_,fname_) 
  Set OpenTextFile = Nothing
  On Error Resume Next
    app_.Workbooks.OpenText fname_, , ,1,,False, False, True, False, False
    Set wb = app_.ActiveWorkbook
  On Error GoTo 0
  Set OpenTextFile = wb
End Function


