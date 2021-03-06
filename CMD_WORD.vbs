' Автор: Стромков С.А.
'
' Создание подразделов для выбранного раздела
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016


Function Open(visible_)
  Dim app ':Word.Application - ссылка на приложение 
  Set app = Nothing
  Set Open = Nothing
  Err.Clear
  On Error Resume Next
    Set app = CreateObject("Word.Application")
    'Set app = CreateObject("Excel.Application")
    'Если ошибка открытия приложения, пишем лог
    If Err <> 0 Then 
      ThisApplication.ExecuteScript "CMD_MESSAGE", "WriteToNotify", 173
      Exit Function
    End If
    app.Visible = visible_
    Dim dic
    Set dic = ThisApplication.Dictionary("Word")
    dic.Add "Word",app  
  On Error GoTo 0
  Set Open = app
End Function


'------------------------------------------------------------------------------
' Функция открывает файл в Word
' OpenFile:Variant - Ссылка на Document
' app_:Variant - объект "Word.Application"
'------------------------------------------------------------------------------
Function OpenFile(app_,fname_) 
  Set OpenFile = Nothing
  On Error Resume Next
    app_.Workbooks.OpenText fname_, , ,1,,False, False, True, False, False
    Set wb = app_.ActiveWorkbook
  On Error GoTo 0
  Set OpenFile = wb
End Function


