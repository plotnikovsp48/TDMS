' Команда - Добавить ссылку на чертеж
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  
  'Запрос файла DWG
  Fname = ThisApplication.ExecuteScript("CMD_DIALOGS","SelectFileDlg","FILE_AUTOCAD_DWG")
  If Fname = " " Then
    'Msgbox "Вы не выбрали ни одного файла.", vbExclamation
    Exit Sub
  End If
  ThisApplication.Utility.WaitCursor = True
  FolderPath = ThisApplication.WorkFolder
  FShortName = Right(FName, Len(Fname) - InStrRev(FName, "\"))
  FShortName0 = Left(FShortName,InStrRev(FShortName,".")-1)
  ShortcutName = FolderPath & "\" & FShortName0 & ".lnk"
  
  'Создание ярлыка
  Set WshShell = CreateObject("WScript.Shell")
  Set WshShortcut = WshShell.CreateShortcut(ShortcutName)
  WshShortcut.Description = FShortName0
  WshShortcut.IconLocation = "shell32.dll, 5"
  WshShortcut.TargetPath = Fname
  WshShortcut.WindowStyle = 1
  WshShortcut.WorkingDirectory = FolderPath
  WshShortcut.Save
  Set WshShell = Nothing
  
  'Загрузка ярлыка в объект
  Set FSO = CreateObject("Scripting.FileSystemObject")
  If FSO.FileExists(ShortcutName) Then
    Call ThisApplication.ExecuteScript("CMD_FILES_LIBRARY","LoadFile",Obj,"FILE_SHORTCUT",ShortcutName)
  End If
  Set FSO = Nothing
  
  ThisApplication.Utility.WaitCursor = False
End Sub