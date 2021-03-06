' Команда - Пометить как опубликованную (Внутренняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  'Список файлов
'  Set Query = ThisApplication.Queries("QUERY_TENDER_IN_UPLOAD_FILES")
'  Query.Parameter("OBJ") = Obj
'  Query.Parameter("STATUS") = ThisApplication.Statuses("STATUS_DOC_IS_END")
'  Set Files = Query.Files

'  'Проверка на наличие файлов
'  If Files.Count = 0 Then
'    Msgbox "Объект не содержит файлов." & chr(10) & "Действие отменено.",vbExclamation
'    Exit Sub
'  End If
'  
'  'Выбор файлов
'  Set Dlg = ThisApplication.Dialogs.SelectDlg
'  Dlg.UseCheckBoxes = True
'  Dlg.SelectFrom = Files
'  Dlg.Caption = "Выбор файлов для выгрузки"
'  If Dlg.Show = False Then Exit Sub
'  Set Files = Dlg.Objects
'  If Files.Count = 0 Then Exit Sub
'  
'  'Запрос папки для выгрузки
'  Path = GetFolder
'  
'  'Выгрузка файлов в папку
'  If Path <> "" Then
'    Set FSO = CreateObject("Scripting.FileSystemObject")
'    'Создание папки
'    FolderName = ""
'    If Obj.Attributes.Has("ATTR_TENDER_CONCURENT_NUM_EIS") Then
'      FolderName = Obj.Attributes("ATTR_TENDER_CONCURENT_NUM_EIS").Value
'      Str = Chr(34) & " * : < > ? / \ |"
'      Arr = Split(Str, " ")
'      For i = 0 to Ubound(Arr)
'        If InStr(FolderName,Arr(i)) <> 0 Then
'          FolderName = ""
''          Msgbox "Номер конкурентной закупки содержит недопустимые символы для создания папки (" &Str& ")",vbExclamation
'          Exit For
'        End If
'      Next
'    End If
'    If FolderName <> "" Then
'      Path = Path & "\" & FolderName
'      If Len(Path) < 256 and FSO.FolderExists(Path) = False Then
'        FSO.CreateFolder Path
'      End If
'    End If
'    
'    Count = 0
'    For Each File in Files
'      fName = Path & "\" & File.FileName
'      Ext = Right(fName,Len(fName)-InStrRev(fName,"."))
'      shortName = Left(fName, InStrRev(fName, ".")-1)
'      i = 1
'      Do While FSO.FileExists(fName)
'        fName = shortName & " (" & i & ")." & Ext
'        i = i + 1
'      Loop
'      on Error Resume Next
'      File.CheckOut fName
'      If Err.Number = 0 Then Count = Count + 1
'      On Error GoTo 0
'    Next  
'    'Msgbox "В папку """ & Path & """ выгружено " & Count & " файлов."
'  Else
'    Exit Sub
'  End If
  
  'Запрос о смене статуса
    Key = Msgbox("Пометить закупку как опубликованную?",vbYesNo+vbQuestion)
    If Key = vbNo Then 
    Exit Sub
    Else
    ThisScript.SysAdminModeOn
 
'  Result = ThisApplication.ExecuteScript("CMD_MESSAGE","ShowWarning",vbQuestion+VbYesNo,6002,Obj.Description)
'  If Result = vbNo Then Exit Sub
  
  'Маршрут
  StatusName = "STATUS_TENDER_IN_PUBLIC"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  Obj.Attributes("ATTR_TENDER_BARGAIN_FLAG") = False
  AttrName = "ATTR_TENDER_STATUS_EIS"
   If Obj.Attributes.Has(AttrName) Then
    Obj.Attributes(AttrName) =  "В работе"
   End If
  ThisScript.SysAdminModeOff
 End If
End Sub

'==============================================================================
' Функция предоставляет диалог выбора папки
'------------------------------------------------------------------------------
' GetFolder:String - Полный путь к выбранной папке
'==============================================================================
Private Function GetFolder()
  GetFolder = ""
  On Error Resume Next
  Set objShellApp = CreateObject("Shell.Application")
  Set objFolder = objShellApp.BrowseForFolder(0, "Выберите папку для выгрузки файлов", 0)
  If Err.Number <> 0 Then
    MsgBox "Папка не выбрана!", vbInformation
  Else
    GetFolder = objFolder.Self.Path
  End If
End Function
