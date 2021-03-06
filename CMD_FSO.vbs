' Автор: Орешкин А.В.
'
' Модуль функций работы с фаловой системой
'------------------------------------------------------------------------------
' Авторское право © ЗАО «СИСОФТ», 2016 г.


' Функция создает FileSystemObject
' CreateFSO:Variant - объект "Scripting.FileSystemObject"
'------------------------------------------------------------------------------
Function CreateFSO()
  Set CreateFSO = CreateObject("Scripting.FileSystemObject")
End Function


' Функция создает текстовый файл на основе строки
' CreateTextFileFromStr:Variant - TextStream 
' str_:String - Текстовая строка на основе которой создаем текстовый файл
' fname_:String - Полное имя файла
'------------------------------------------------------------------------------
Function CreateTextFileFromStr(str_,fname_)
  dim FSO
  dim TextStream
  CreateTextFileFromStr = False
  Err.Clear
  On Error Resume Next
    Set FSO = CreateFSO()
    Set TextStream = FSO.CreateTextFile(fname_)
    If Err <> 0 Then 
      ThisApplication.ExecuteScript "CMD_MESSAGE", "WriteToNotify", 173
      Exit Function
    End If    
  On Error GoTo 0
  TextStream.Write(str_)
  If TextStream Is Nothing Then Exit Function
  TextStream.Close  
  CreateTextFileFromStr = True
End Function

' Функция создает строку на основе текстового файла
' CreateStrFromTextFile:String - Сформированная строка на основе текстового файла
' fname_:String - Полное имя файла
'------------------------------------------------------------------------------
Function CreateStrFromTextFile(fname_)
  dim FSO
  dim File
  dim TextStream
  CreateStrFromTextFile = Empty
  Err.Clear
  On Error Resume Next
    Set FSO = CreateFSO()
    Set File = FSO.GetFile(fname_)
    Set TextStream = File.OpenAsTextStream(1)
    CreateStrFromTextFile = TextStream.ReadAll()
    TextStream.Close    
  On error goto 0
End Function