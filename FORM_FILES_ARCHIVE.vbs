' Форма ввода - Архив
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

'=============================================================================================================
Sub Form_BeforeShow(Form, Obj)
  Call ButtonsEnable(Form,Obj)
  Call SetQueryVersions(Form,Obj)
End Sub

'=============================================================================================================
'Событие - Изменен атрибут
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  Select Case  Attribute.AttributeDefName
    Case "ATTR_A_ARCHIVE_PAPER_EXIST"
      If Attribute = True Then
        Cancel = Not FixPaperDoc(Obj)
      Else
        Cancel = Not UnFixPaperDoc(Obj)
      End If
  End Select
  If Cancel Then Exit Sub
End Sub

'=============================================================================================================
'Событие - Выделен объект в выборке версий архива
Sub QUERY_VERSIONS_ARCHIVE_Selected(iItem, action)
  Set Query = ThisForm.Controls("QUERY_VERSIONS_ARCHIVE")
  sRow = Query.ActiveX.SelectedItem
  If sRow <> -1 Then
    If Query.Value.RowsCount = Query.ActiveX.Count Then
      Set VerObj = Query.Value.RowValue(sRow)
      Set Table = ThisForm.Controls("GRIDFILES").ActiveX
      If VerObj.ActiveVersion = False Then
        Table.DataSource = VerObj.Attributes("ATTR_FILES_ARCHIVE_TABLE").Rows
      Else
        Table.DataSource = ThisObject.Attributes("ATTR_FILES_ARCHIVE_TABLE").Rows
      End If
      Table.Refresh
      Table.ColumnAutosize = True
      Table.ReadOnly = True
      Call ButtonsEnable(ThisForm,ThisObject)
    End If
  End If
End Sub

'=============================================================================================================
'Событие - двойной клик мыши
Sub GRIDFILES_DblClick(nRow,nCol)
  If nRow > -1 Then Call BUTTON_LIST_OnClick
End Sub

'=============================================================================================================
'Процедура управления выборкой архивных версий
Sub SetQueryVersions(Form,Obj)
  Set Query = Form.Controls("QUERY_VERSIONS_ARCHIVE")
  VisCheck = True
  'Выделение версии открытой карточки
  If not Obj is Nothing Then
    Handle = Obj.Handle
    For i = 0 to Query.Value.RowsCount-1
      Set VerObj = Query.Value.RowValue(i)
      If not VerObj is Nothing Then
        If VerObj.Handle = Handle Then
          Query.ActiveX.SelectItems i, i, False
          Exit For
        End If
      End If
    Next
  Else
    VisCheck = False
  End If
  
  If Query.Value.RowsCount = 0 Then
    VisCheck = False
  End If
  
  'Видимость выборки
  Query.Visible = VisCheck
End Sub

'=============================================================================================================
'Кнопка - Выгрузить
Sub BUTTON_DOWNLOAD_OnClick()
  Count = 0
  ErrStr = ""
  Check = False
  Set Obj = Nothing
  Set Query = ThisForm.Controls("QUERY_VERSIONS_ARCHIVE")
  
  'Определение контейнера файлов
  sRow = Query.ActiveX.SelectedItem
  If sRow <> -1 Then
    If Query.Value.RowsCount = Query.ActiveX.Count Then
      Set Obj = Query.Value.RowValue(sRow)
      Set TableRows = Obj.Attributes("ATTR_FILES_ARCHIVE_TABLE").Rows
      If TableRows.Count <> 0 and Obj.Files.Count <> 0 Then
        Check = True
      End If
    End If
  End If
  
  'Отображение диалога выбора документов
  If Check = True Then
    Set Dlg = ThisApplication.Dialogs.SelectDlg
    Dlg.SelectFrom = TableRows
    Dlg.Caption = "Архивная версия: " & Obj.VersionName & " - " & Obj.VersionDescription
    Dlg.Prompt = "Выборите документы для выгрузки"
    If Dlg.Show Then
      Set Rows = Dlg.Objects
      If Rows.Count = 0 Then
        Msgbox "Документы не выбраны.", vbExclamation
        Exit Sub
      End If
    Else
      Exit Sub
    End If
  Else
    Msgbox "Архивные копии документов не найдены", vbExclamation
    Exit Sub
  End If

  ThisApplication.Utility.WaitCursor = True
  
  'Запрос папки для выгрузки
  On Error Resume Next
  Set objShellApp = CreateObject("Shell.Application")
  Set objFolder = objShellApp.BrowseForFolder(0, "Сохранить файлы в папку", 0)
  Fpath = objFolder.Self.Path & "\"
  If Err.Number <> 0 Then
    MsgBox "Папка не выбрана!", vbInformation
    Exit Sub
  End If
  Set objShellApp = Nothing
  
  'Определение наименования объекта и создание папки
  ObjName = ""
  If Obj.ObjectDefName = "OBJECT_WORK_DOCS_SET" Then
    If Obj.Attributes.Has("ATTR_SUBCONTRACTOR_DOC_CODE") Then
      ObjName = Obj.Attributes("ATTR_SUBCONTRACTOR_DOC_CODE").Value
    End If
  ElseIf Obj.ObjectDefName = "OBJECT_VOLUME" Then
    If Obj.Attributes.Has("ATTR_VOLUME_CODE") Then
      ObjName = Obj.Attributes("ATTR_VOLUME_CODE").Value
    End If
  End If
  If ObjName = "" Then ObjName = Obj.Description
  ObjName = ThisApplication.ExecuteScript("CMD_FILES_LIBRARY", "CharsChange",ObjName," ")
  Fpath = Fpath & ObjName
  
  Set FSO = CreateObject("Scripting.FileSystemObject")
  If FSO.FolderExists(Fpath) = False Then
    FSO.CreateFolder Fpath
  End If
  
  'Прогон по выделенным строкам
  For Each Row in Rows
    If Row.Attributes("ATTR_DOC_REF").Empty = False Then
      If not Row.Attributes("ATTR_DOC_REF").Object is Nothing Then
        FilePath = Fpath
        Set Doc = Row.Attributes("ATTR_DOC_REF").Object
        Key = Doc.Guid
        'Создаем папку = наименованию документа
        ObjName = ""
        If Doc.Attributes.Has("ATTR_DOC_CODE") Then
          If Doc.Attributes("ATTR_DOC_CODE").Empty = False Then
            ObjName = Doc.Attributes("ATTR_DOC_CODE").Value
          End If
        End If
        If ObjName = "" Then ObjName = Doc.Description
        ObjName = ThisApplication.ExecuteScript("CMD_FILES_LIBRARY", "CharsChange",ObjName," ")
        If ObjName <> "" Then FilePath = Fpath & "\" & ObjName
        If FSO.FolderExists(FilePath) = False Then
          FSO.CreateFolder FilePath
        End If
        'Выгружаем файлы
        For Each File in Obj.Files
          Str = File.FileName
          If InStr(Str, Key) <> 0 Then
            Fname = Right(Str,Len(Str)-InStr(Str," - ")-2)
            FilePath0 = FilePath & "\" & Fname
            If Len(FilePath0) < 254 Then
              File.CheckOut FilePath0
              Count = Count + 1
            Else
              ErrStr = ErrStr & chr(10) & "Слишком большая длина пути выгрузки файла """ & Fname & """"
            End If
          End If
        Next
      End If
    End If
  Next
  
  ThisApplication.Utility.WaitCursor = False
  Str = ""
  If Count <> 0 Then Str = "Выгружено " & Count & " файлов."
  If ErrStr <> "" Then Str = Str & "Ошибки выгрузки:" & ErrStr
  If Str <> "" Then Msgbox Str, vbInformation
End Sub

'=============================================================================================================
'Кнопка - Список файлов
Sub BUTTON_LIST_OnClick()
  Key = GetKey
  If Key = "" Then Exit Sub
  Dim Arr()
  'Dim ArrRes()
  i = 0
  
  Set Query = ThisForm.Controls("QUERY_VERSIONS_ARCHIVE")
  sRow = Query.ActiveX.SelectedItem
  If sRow <> -1 Then
    If Query.Value.RowsCount = Query.ActiveX.Count Then
      Set VerObj = Query.Value.RowValue(sRow)
      If VerObj.ActiveVersion = True Then Set VerObj = ThisObject
      Set Table = ThisForm.Controls("GRIDFILES").ActiveX
    End If
  End If
  
  Set Dlg = ThisApplication.Dialogs.SelectDlg
  Dlg.Caption = "Список архивных файлов документа"
  Set Doc = ThisApplication.GetObjectByGUID(Key)
  If not Doc is Nothing Then
    Dlg.Prompt = "Документ """ & Doc.Description & """"
  End If
  
  For Each File in VerObj.Files
    Str = File.FileName
    If InStr(Str, Key) <> 0 Then
      ReDim Preserve Arr(i)
      Arr(i) = Right(Str,Len(Str)-InStr(Str," - ")-2)
      i = i + 1
    End If
  Next
  Dlg.SelectFrom = Arr
  If Dlg.Show Then
    ArrRes = Dlg.Objects
    If Ubound(ArrRes) > -1 Then
      FileName = Key & " - " & ArrRes(0)
      If VerObj.Files.Has(FileName) Then
        Set File = VerObj.Files(FileName)
        Call ThisApplication.ExecuteScript("CMD_KD_FILE_LIB","File_CheckOut",File)
      End If
    End If
  End If
End Sub

'=============================================================================================================
'Процедура загрузки файлов и формирования списка документов
Sub LoadFiles(Obj)
  ThisScript.SysAdminModeOn
  Set Objects = Obj.Objects
  Set Files = Obj.Files
  Set TableRows = Obj.Attributes("ATTR_FILES_ARCHIVE_TABLE").Rows
  Set Table = ThisForm.Controls("GRIDFILES").ActiveX
  
  ThisApplication.Utility.WaitCursor = True
  TableRows.RemoveAll
  
  'Удаление старых файлов
  For Each File in Files
    Files.Remove File
  Next
  
  For Each Doc in Objects
    If Doc.Files.Count <> 0 Then
      Set NewRow = TableRows.Create
      NewRow.Attributes("ATTR_DOC_REF").Object = Doc
      NewRow.Attributes("ATTR_DATA").Value = Date
      AttrName = "ATTR_CHANGE_NUM"
      If Doc.Attributes.Has(AttrName) Then
        If Doc.Attributes(AttrName).Empty = False Then
          NewRow.Attributes(AttrName).Value = Doc.Attributes(AttrName).Value
        End If
      End If
      For Each File in Doc.Files
        fName = File.FileName
        If InStr(1,fName,"###",vbTextCompare) = 0 Then
          Set NewFile = Files.AddCopy(File, Doc.Guid & " - " & fName)
          'Смена типа файла
          FileDefName = ThisApplication.ExecuteScript("FORM_INVOICE_FILES","GetFileDefs",NewFile)
          If FileDefName <> "" Then 
            NewFile.FileDef = ThisApplication.FileDefs(FileDefName)
          End If
        End If
      Next
    End If
  Next
  
  Table.Refresh
  ThisApplication.Utility.WaitCursor = False
End Sub

'=============================================================================================================
'Кнопка - загрузить файлы
Sub BUTTON_LOAD_FILES_OnClick()
  Call LoadFiles(ThisObject)
  ThisForm.Refresh
  Call ButtonsEnable(ThisForm,ThisObject)
End Sub

'=============================================================================================================
'Кнопка - Удалить
Sub BUTTON_DEL_OnClick()
  Set TableRows = ThisObject.Attributes("ATTR_FILES_ARCHIVE_TABLE").Rows
  Set Grid = ThisForm.Controls("GRIDFILES").ActiveX
  If Grid.RowCount = 0 Then Exit Sub
  Arr = Grid.SelectedRows
  Count = UBound(Arr)
  Key = Msgbox("Удалить " & Count+1 & " записей из таблицы?",vbYesNo+vbQuestion)
  If Key = vbNo Then Exit Sub
  
  For i = Count To 0 Step -1
    Set Row = Grid.RowValue(Arr(i))
    If not Row is Nothing Then
      If Row.Attributes("ATTR_DOC_REF").Empty = False Then
        If not Row.Attributes("ATTR_DOC_REF").Object is Nothing Then
          Set Doc = Row.Attributes("ATTR_DOC_REF").Object
          Key = Doc.Guid
          TableRows.Remove Row
          For Each File in ThisObject.Files
            If InStr(File.FileName, Key) <> 0 Then
              ThisObject.Files.Remove File
            End If
          Next
        End If
      End If
    End If
  Next
  Grid.Refresh
  Call ButtonsEnable(ThisForm,ThisObject)
End Sub

'=============================================================================================================
'Функция получения ключа-идентификатора файлов
Function GetKey()
  GetKey = ""
  Set Table = ThisForm.Controls("GRIDFILES").ActiveX
  nRow = Table.SelectedRow
  If nRow < 0 Then Exit Function
  If Table.RowCount = 0 Then Exit Function
  On Error Resume Next
  Set Row = Table.RowValue(nRow)
  If not Row is Nothing Then
    If Row.Attributes("ATTR_DOC_REF").Empty = False Then
      If not Row.Attributes("ATTR_DOC_REF").Object is Nothing Then
        Set Doc = Row.Attributes("ATTR_DOC_REF").Object
        GetKey = Doc.Guid
      End If
    End If
  End If
  On Error GoTo 0
End Function

'=============================================================================================================
'Процедура доступности кнопкиок
Sub ButtonsEnable(Form,Obj)
  Key = GetKey
  Check = False
  Set Query = Form.Controls("QUERY_VERSIONS_ARCHIVE")
  sRow = Query.ActiveX.SelectedItem
  If sRow <> -1 Then
    If Query.Value.RowsCount = Query.ActiveX.Count Then
      Set VerObj = Query.Value.RowValue(sRow)
      If VerObj.ActiveVersion = True Then Check = True
    End If
  End If
  Form.Controls("BUTTON_LOAD_FILES").Enabled = Check
  
  If GetKey <> "" Then
    Form.Controls("BUTTON_LIST").Enabled = True
    Form.Controls("BUTTON_DEL").Enabled = Check
    Form.Controls("BUTTON_DOWNLOAD").Enabled = True
  Else
    Form.Controls("BUTTON_LIST").Enabled = False
    Form.Controls("BUTTON_DEL").Enabled = False
    Form.Controls("BUTTON_DOWNLOAD").Enabled = False
  End If
End Sub

'=============================================================================================================
Function FixPaperDoc(Obj)
  FixPaperDoc = False
  Set CU = ThisApplication.CurrentUser
  Set oDept = CU.Attributes("ATTR_KD_DEPART").Object
  
  If Not oDept Is Nothing Then
    ans = msgbox ("Зарегистрировать бумажный экземпляр на площадке " & oDept.Description & "?",vbQuestion+vbYesNo)
    If ans <> vbYes Then Exit Function
  End If
  Obj.Attributes("ATTR_A_ARCHIVE_USER").User = CU
  Obj.Attributes("ATTR_A_ARCHIVE_DEPART").Object = oDept
  Obj.Attributes("ATTR_A_ARCHIVE_DATE") = Date
  FixPaperDoc = True
End Function

'=============================================================================================================
Function UnFixPaperDoc(Obj)
  UnFixPaperDoc = False
  Set CU = ThisApplication.CurrentUser
  Set oDept = CU.Attributes("ATTR_KD_DEPART").Object
  
  If Not oDept Is Nothing Then
    ans = msgbox ("Отменить регистрацию бумажного экземпляра на площадке " & oDept.Description & "?",vbQuestion+vbYesNo)
    If ans <> vbYes Then Exit Function
  End If
  Obj.Attributes("ATTR_A_ARCHIVE_USER").User = Nothing
  Obj.Attributes("ATTR_A_ARCHIVE_DEPART").Object = Nothing
  Obj.Attributes("ATTR_A_ARCHIVE_DATE") = Empty
  UnFixPaperDoc = True
End Function

