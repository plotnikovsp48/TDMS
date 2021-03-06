' Команда - Разместить растровый образ накладной
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  Set Dlg = ThisApplication.Dialogs.FileDlg
  Dlg.Filter = "Растровый образ накладной (*.PDF)|*.PDF||"
  If Dlg.Show Then
    StrMsg = ""
    For Each Fname in Dlg.FileNames
      Set FDef = CheckFileDef(Obj,Fname)
      If not FDef is Nothing Then
        Set NewFile = Obj.Files.Create(FDef.SysName)
        On Error Resume Next
        NewFile.CheckIn FName
        If Err <> 0 Then
          FShortName = Right(FName, Len(Fname) - InStrRev(FName, "\"))
          MsgBox "Файл """ & FShortName & """ уже есть в составе объекта.", vbInformation
          'удалить пустой файл
          NewFile.Erase
        Else
          StrMsg = StrMsg & Chr(13) & FName
          count = count+1
        End If
        On Error Goto 0
      End If
    Next
    
    'Результат импорта
    If StrMsg <> "" Then 
      MsgBox "К объекту было добавлено " & count & " файлов:" & StrMsg, vbInformation
    End If
  End If
End Sub

'Функция проверки типа файла на доступные для объекта
Function CheckFileDef(Obj,FName)
  Set CheckFileDef = Nothing
  FExtension = "*." & Right(FName, Len(Fname) - InStrRev(FName, "."))
  For Each FDef In Obj.ObjectDef.FileDefs
    If InStr(FDef.Extensions, FExtension) <> 0 Then
      Set CheckFileDef = FDef
      Exit Function
    End If
  Next
End Function