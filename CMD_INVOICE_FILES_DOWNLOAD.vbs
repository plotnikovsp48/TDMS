' Команда - Выгрузить файлы (Накладная)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Option Explicit

Main ThisObject 

Sub Main(Obj)
  'Проверка на наличие файлов
  If Obj.Files.Count = 0 Then
    MsgBox "Накладная не содержит файлов." & vbCrLf & "Действие отменено.", vbExclamation
    Exit Sub
  End If

  Dim path  
  'Запрос папки для выгрузки
  path = GetFolder()
  If vbNullString = path Then Exit Sub
  
  Dim list, i, j, row, fso, p
  Set fso = CreateObject("Scripting.FileSystemObject")
  list = BuildFilesList(Obj)
  
  For i = LBound(list) To UBound(list)
    row = list(i): p = path
    For j = LBound(row) To UBound(row) - 2
      p = fso.BuildPath(p, row(j))
      If Not fso.FolderExists(p) Then
        fso.CreateFolder p
      End If
    Next
    
    Dim file
    Set file = Obj.Files(row(UBound(row) - 1))
    If Len(row(UBound(row))) > 0 Then
      ' checkout using display name
      p = fso.BuildPath(p, row(UBound(row)))
    Else
      ' checkout using file name
      p = fso.BuildPath(p, row(UBound(row) - 1))
    End If
    If fso.FileExists(p) Then fso.DeleteFile p
    file.CheckOut p
  Next
  
  MsgBox "Выгружено " & UBound(list) + 1 & " файлов.", _
    vbInformation, ThisApplication.DatabaseName
End Sub

Private Function BuildFilesList(obj)
  BuildFilesList = Array()
  
  Dim a, row, fileTable
  
  a = Array()
  Set fileTable = obj.Attributes("ATTR_INVOICE_TFILES")
  
  Dim target, stage, parent, att, rowData
  For Each row In fileTable.Rows
    Set att = row.Attributes
    ' likely a bug with tdmBool data type
    If att("ATTR_FILE_EXCLUDED").Empty Then
      rowData = Array()
      Set target = ThisApplication.GetObjectByGUID(att("ATTR_INVOICE_OBJ_GUID"))
      If Not target Is Nothing Then
      
        Set stage = ThisApplication.ExecuteScript("CMD_S_DLL", "GetStage", target)
        If Not stage Is Nothing Then 
          ReDim Preserve rowData(UBound(rowData) + 1)
          rowData(UBound(rowData)) = DownloadPath(stage)
        End If
        
        Set parent = ThisApplication.ExecuteScript("CMD_S_DLL", "GetUplinkObj", target, "OBJECT_VOLUME")
        If parent Is Nothing Then
          Set parent = ThisApplication.ExecuteScript("CMD_S_DLL", "GetUplinkObj", target, "OBJECT_WORK_DOCS_SET")
        End If
        If Not parent Is Nothing Then
          ReDim Preserve rowData(UBound(rowData) + 1)
          rowData(UBound(rowData)) = DownloadPath(parent)
        End If
        
        ReDim Preserve rowData(UBound(rowData) + 1)
        rowData(UBound(rowData)) = DownloadPath(target)
      End If
      
      ReDim Preserve rowData(UBound(rowData) + 1)
      rowData(UBound(rowData)) = att("ATTR_FILE_NAME")
      
      ReDim Preserve rowData(UBound(rowData) + 1)
      rowData(UBound(rowData)) = NormalizePath(att("ATTR_FILE_DISPNAME"))
      
      ReDim Preserve a(UBound(a) + 1)
      a(UBound(a)) = rowData
    End If
  Next
  BuildFilesList = a
End Function

Private Function NormalizePath(src)
  NormalizePath = src
  NormalizePath = Replace(NormalizePath, "\", "_")
  NormalizePath = Replace(NormalizePath, "/", "_")
  NormalizePath = Replace(NormalizePath, ":", "_")
  NormalizePath = Replace(NormalizePath, "*", "_")
  NormalizePath = Replace(NormalizePath, "?", "_")
  NormalizePath = Replace(NormalizePath, """", "_")
  NormalizePath = Replace(NormalizePath, "<", "_")
  NormalizePath = Replace(NormalizePath, ">", "_")
  NormalizePath = Replace(NormalizePath, "|", "_")
End Function

Private Function DownloadPath(obj)
  DownloadPath = "unknown"
  
  If obj Is Nothing Then Exit Function

  If Len(obj.Description) > 0 Then DownloadPath = obj.Description
  
  Dim att
  Set att = obj.Attributes
  If "OBJECT_VOLUME" = obj.ObjectDefName Then
    If att.Has("ATTR_VOLUME_CODE") Then
      If Not att("ATTR_VOLUME_CODE").Empty Then
        DownloadPath = att("ATTR_VOLUME_CODE").Value
      End If
    End If
  ElseIf "OBJECT_WORK_DOCS_SET" = obj.ObjectDefName Then
    If att.Has("ATTR_WORK_DOCS_SET_CODE") Then
      If Not att("ATTR_WORK_DOCS_SET_CODE").Empty Then
        DownloadPath = att("ATTR_WORK_DOCS_SET_CODE").Value
      End If
    End If
'  ElseIf "OBJECT_DRAWING" = obj.ObjectDefName _
'    Or "OBJECT_DOC_DEV" = obj.ObjectDefName Then
'    If att.Has("ATTR_DOC_CODE") Then
'      If Not att("ATTR_DOC_CODE").Empty Then
'        DownloadPath = att("ATTR_DOC_CODE").Value
'      End If
'    End If
  End If
  
  DownloadPath = NormalizePath(DownloadPath)
End Function

'==============================================================================
' Функция предоставляет диалог выбора папки
'------------------------------------------------------------------------------
' GetFolder:String - Полный путь к выбранной папке
'==============================================================================
Private Function GetFolder()
  GetFolder = vbNullString
  
  Dim shellApp, folder
  On Error Resume Next
  Set shellApp = CreateObject("Shell.Application")
  Set folder = shellApp.BrowseForFolder(0, "Выберите папку для выгрузки файлов", 0)
  If Err.Number <> 0 Then
    MsgBox "Папка не выбрана!", vbInformation
  Else
    GetFolder = folder.Self.Path
  End If
End Function
