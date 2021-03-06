' Команда - Добавить скан
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  Set CU = ThisApplication.CurrentUser
  IsLocked = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsLocked",Obj,CU)
  If IsLocked = True Then 
    Set u = Obj.Permissions.LockUser
    msgbox "Данная операция недоступна, т.к. объект заблокирован другим пользователем:" & _
            chr(10) & u.Description,vbCritical,"Добавить скан"
    Exit Sub
  End If
  
  Set Dlg = ThisApplication.Dialogs.FileDlg
  Dlg.Filter = "Растровый образ (*.PDF)|*.PDF||"
  If Obj.IsKindOf("OBJECT_DOC") Then
    Select Case Obj.ObjectDefName
      Case "OBJECT_DRAWING", "OBJECT_DOC_DEV"
        fileType = "FILE_DOC_PDF"
      Case Else
        fileType = "FILE_KD_SCAN_DOC"
    End Select
  Else
    Select Case Obj.ObjectDefName
      Case "OBJECT_CONTRACT", "OBJECT_CONTRACT_COMPL_REPORT","OBJECT_AGREEMENT"
        fileType = "FILE_KD_SCAN_DOC"
      Case "OBJECT_T_TASK"
        fileType = "FILE_KD_SCAN_DOC"
      Case "OBJECT_INVOICE"
        fileType = "FILE_KD_SCAN_DOC"
      Case Else
        fileType = "FILE_KD_SCAN_DOC"
    End Select
  End If
  
  If ThisApplication.FileDefs.Has(fileType) = False Then
    msgbox "Невозможно приложить скан к документу, т.к. в системе отсутствует требуемый тип файла." & chr(10) & _
              "Обратитесь к системному администратору",vbCritical,"Ошибка добавления скана"
    Exit Sub
  End If

  Set FDef = ThisApplication.FileDefs(fileType)
  
  If Obj.ObjectDef.FileDefs.Has(fileType) = False Then
          ext = ThisApplication.FileDefs(fileType).Extensions
          desc = ThisApplication.FileDefs(fileType).Description
          Dlg.Filter = desc & " |" & ext & "||"
  End If
  
  If Dlg.Show Then
    StrMsg = ""
    For Each Fname in Dlg.FileNames
      'Set FDef = CheckFileDef(Obj,Fname)
      If Not FDef is Nothing Then
        Dim tdmsName, NewFile
        Set NewFile = Nothing
        tdmsName = Right(Fname, Len(Fname) - InStrRev(Fname, "\"))
        If Obj.Files.Has(tdmsName) Then
          Dim existentDef
          Set existentDef = Obj.Files(tdmsName).FileDef
          If existentDef.SysName <> FDef.SysName Then
            tdmsName = MangleIfCollision(tdmsName, BuildFilesList(Obj))
          Else
            ' ask for replace/rename/cancel
            Dim selDlg
            Set selDlg = ThisApplication.InputForms("FORM_FILE_ACTION")
            selDlg.Controls("CTRL_ACTION").Value = "Файл " & tdmsName & _
              " уже существует в составе объекта."
            If Not selDlg.Show() Then Exit Sub
            If selDlg.Attributes("ATTR_REPLACE_FILE").Value Then
              Set NewFile = Obj.Files(tdmsName)
            ElseIf selDlg.Attributes("ATTR_RENAME_FILE").Value Then
              tdmsName = MangleIfCollision(tdmsName, BuildFilesList(Obj))
            End If
          End If
        End If
        If NewFile Is Nothing Then Set NewFile = Obj.Files.Create(FDef.SysName)
        If tdmsName <> Fname Then NewFile.FileName = tdmsName
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
      Else
        MsgBox "Файл не может быть добавлен."&chr(10)&"Проверьте настройки типа объекта.", vbExclamation
        Exit Sub
      End If
      Obj.Files.Main = NewFile
    Next
    
    'Результат импорта
    If StrMsg <> "" Then 
      
      Obj.SaveChanges(0)
'      Obj.Update
      MsgBox "К объекту было добавлено " & count & " файлов:" & StrMsg, vbInformation
      ' Ставим пометку, что подписано контрагентом
      If Obj.IsKindOf("OBJECT_CONTRACT_COMPL_REPORT") And Obj.Attributes("ATTR_CCR_INCOMING") = True Then
        If Not Obj.Attributes("ATTR_IS_SIGNED_BY_CORRESPONDENT") Then _
          Obj.Attributes("ATTR_IS_SIGNED_BY_CORRESPONDENT") = True
      End If
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

Private Function BuildFilesList(Obj)
  BuildFilesList = Array()
  
  Dim f, a
  a = Array()
  For Each f In Obj.Files
    Redim Preserve a(UBound(a) + 1)
    a(UBound(a)) = f.FileName
  Next
  BuildFilesList = a
End Function

Public Function MangleIfCollision(pattern, list)
  MangleIfCollision = pattern
  
  Dim i
  For i = LBound(list) To UBound(list)
    If vbString = VarType(list(i)) Then
      Dim str1, str2
      str1 = LCase(pattern): str2 = LCase(list(i))
      If (0 = StrComp(str1, str2)) Then
        MangleIfCollision = MangleIfCollision(GetMangledName(list(i)), list)
        Exit For
      End If
    End If
  Next
End Function

Private Function GetMangledName(pattern)
  GetMangledName = pattern
  
  Dim rx, matches
  Set rx = New RegExp

  ' split into name and extension
  rx.Pattern = "\.(.+)$"
  Set matches = rx.Execute(pattern)

    Dim name, extension
    If 1 = matches.Count Then
        name = Left(pattern, matches(0).FirstIndex)
        extension = matches(0).Value
    Else
        name = pattern: extension = vbNullString
    End If

    rx.Pattern = "\((\d{1,2})\)$"
    Set matches = rx.Execute(name)
    If 0 = matches.Count Then
        GetMangledName = name & "(1)" & extension
    Else
        name = Left(name, matches(0).FirstIndex)
        GetMangledName = name & "(" & _
            ((CLng(matches(0).SubMatches(0)) + 1) Mod 100) & ")" & extension
    End If
End Function
