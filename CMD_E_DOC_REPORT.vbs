Option Explicit

Run ThisObject

Public Function Run(obj)
  Run = False
  
  Dim progress
  Set progress = New CProgress
  
  progress.Text = "Выбор папки"
  Dim folder, path
  folder = GetFolder()
  If vbNullString = folder Then Exit Function
  
  progress.Text = "Загрузка шаблона"
  path = DownloadTemplate(folder)
  
  progress.Text = "Открытие шаблона"
  
  Dim wordDoc
  Set wordDoc = GetObject(path)
  If Not wordDoc.Application.Visible Then wordDoc.Application.Visible = True
  
  FillData obj.Attributes("ATTR_INVOICE_TFILES"), wordDoc.Tables(1), progress
  
  Run = True
End Function

Class CProgress
  Private mDlg, mPosition
  
  Public Sub Class_Initialize()
    Set mDlg = ThisApplication.Dialogs.ProgressDlg
    mDlg.Start
  End Sub
  
  Public Sub Class_Terminate()
    mDlg.Stop
    Set mDlg = Nothing
  End Sub
  
  Public Sub SetLocalRanges(left, right)
    mDlg.SetLocalRanges left, right
  End Sub
  
  Public Sub Step()
    mPosition = mPosition + 1
    mDlg.Position = mPosition
  End Sub
  
  Public Property Let Text(newVal)
    mDlg.Text = newVal
  End Property
End Class

Private Function GetFolder()
  GetFolder = vbNullString
  GetFolder = ThisApplication.ExecuteScript("CMD_DLL_REPORTS", "GetPathSave")
End Function

Private Function DownloadTemplate(where)
  DownloadTemplate = vbNullString
  
  Dim fso
  Set fso = CreateObject("Scripting.FileSystemObject")
  
  Dim fileDef, template
  Set fileDef = ThisApplication.FileDefs("FILE_TRANSFER_DOCUMENT")
  Set template = fileDef.Templates("ЭВКД.docx")
  
  DownloadTemplate = fso.BuildPath(where, template.FileName)
  template.CheckOut DownloadTemplate
End Function

Private Sub FillData(source, target, progress)

  progress.SetLocalRanges 0, source.Rows.Count
  
  Dim row, att
  For Each row In source.Rows
    Set att = row.Attributes
    progress.Text = att("ATTR_FILE_DISPNAME").Value
    
    If Not att("ATTR_FILE_EXCLUDED").Empty Then
      FillRow row, target.Rows.Add(target.Rows.Last)
    End If
    
    progress.Step
  Next
  
End Sub

Private Sub FillRow(source, target)

  If source("ATTR_INVOICE_OBJ_GUID").Empty Then Exit Sub
  
  Dim doc
  Set doc = ThisApplication.GetObjectByGUID(source("ATTR_INVOICE_OBJ_GUID").Value)
  If doc Is Nothing Then Exit Sub
  
  With target.Cells
    If source.Has("ATTR_DOC_CODE") Then 
      If Not source("ATTR_DOC_CODE").Empty Then _
        .Item(1).Range.InsertBefore source("ATTR_DOC_CODE").Value
    End If
    If source.Has("ATTR_DOCUMENT_NAME") Then
      If Not source("ATTR_DOCUMENT_NAME").Empty Then _
        .Item(2).Range.InsertBefore source("ATTR_DOCUMENT_NAME").Value
    End If
    If Not source("ATTR_FILE_DISPNAME").Empty Then _
      .Item(4).Range.InsertBefore source("ATTR_FILE_DISPNAME").Value
    If Not source("ATTR_FILE_SIZE").Empty Then _
      .Item(5).Range.InserBefore source("ATTR_FILE_SIZE").Value
    If Not source("ATTR_FILE_CHDATE").Empty Then _
      .Item(6).Range.InsertBefore FormatDateTime(source("ATTR_FILE_CHDATE").Value, vbShortDate)
      .Item(7).Range.InsertBefore FormatDateTime(source("ATTR_FILE_CHDATE").Value, vbLongTime)
  End With
End Sub
