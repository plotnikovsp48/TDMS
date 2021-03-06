' Форма ввода - Документация
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

USE CMD_SS_SYSADMINMODE
USE CMD_SS_PROGRESS

Sub Form_BeforeShow(Form, Obj)
  Form.Caption = Form.Description
  
  With Form.Controls
    .Item("BUTTON_ADD").Enabled = DraftOrAssemblingAndAuthor(Obj)
    .Item("BUTTON_DEL").Enabled = EnableDelete(Form, Obj)
  End With
End Sub

'Кнопка - Добавить
Sub BUTTON_ADD_OnClick()
  ThisScript.SysAdminModeOn
  Set Dlg = ThisApplication.Dialogs.SelectObjectDlg
  Set Query = ThisApplication.Queries("QUERY_INVOICE_DOCS_ADD")
  Query.Parameter("INVOICE") = ThisObject
'  Set Objects = Query.Objects
  Set Objects = Query.Sheet
  
  'Проверка доступной документации
  If Objects.RowsCount = 0 Then
'  If Objects.Count = 0 Then
    'Сохраняем объект, чтобы выборка выдала результат
    ThisObject.SaveChanges
'  Set Objects = Query.Objects
  Set Objects = Query.Sheet
  If Objects.RowsCount = 0 Then
'  If Objects.Count = 0 Then
      Msgbox "Нет документации, доступной для добавления"
      Exit Sub
    End If
  End If
  
  Dim dict, row, o
  Set dict = CreateObject("Scripting.Dictionary")
  For Each row In ThisObject.Attributes("ATTR_INVOICE_TDOCS").Rows
    Set o = row.Attributes("ATTR_INVOICE_DOCS_OBJ").Object
    If Not o Is Nothing Then
      If Not dict.Exists(o.Handle) Then dict.Add o.Handle, 1
    End If
  Next
  
  Dim selectForm
  Set selectFrom = ThisApplication.CreateCollection(tdmObjects)
'  For Each o In Objects
  For Each o In Query.Sheet.Objects
    If Not dict.Exists(o.Handle) Then selectFrom.Add o
  Next
  
  If 0 = selectFrom.Count Then
    MsgBox "Нет документации, доступной для добавления", _
      vbInformation, ThisApplication.DatabaseName
    Exit Sub
  End If
  
  Dlg.SelectFromObjects = selectFrom
  If Not Dlg.Show() Then Exit Sub
  
  If "STATUS_INVOICE_DRAFT" = ThisObject.StatusName Then _
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",ThisObject,ThisObject.Status,ThisObject,"STATUS_INVOICE_FORTHEPICKING")
    
  Set TableRows = ThisObject.Attributes("ATTR_INVOICE_TDOCS").Rows
  For Each Obj in Dlg.Objects
    'Проверка документации в таблице
    GUID = Obj.Guid
    Check = True
    For Each Row in TableRows
      If Not Row.Attributes("ATTR_INVOICE_DOCS_OBJ").Empty Then
        If Not Row.Attributes("ATTR_INVOICE_DOCS_OBJ").Object is Nothing Then
          If Row.Attributes("ATTR_INVOICE_DOCS_OBJ").Object.Guid = Guid Then
            Check = False
            Exit For
          End If
        End If
      End If
    Next
      
    If Check = True Then
      Set NewRow = TableRows.Create
      'Ссылка на документацию
      NewRow.Attributes("ATTR_INVOICE_DOCS_OBJ").Object = Obj
      'Наименование документации
      oName = ""
      If Obj.Attributes.Has("ATTR_WORK_DOCS_SET_NAME") Then
        oName = Obj.Attributes("ATTR_WORK_DOCS_SET_NAME").Value
      ElseIf Obj.Attributes.Has("ATTR_VOLUME_NAME") Then
        oName = Obj.Attributes("ATTR_VOLUME_NAME").Value
      ElseIf Obj.Attributes.Has("ATTR_SUBCONTRACTOR_DOC_NAME") Then
        oName = Obj.Attributes("ATTR_SUBCONTRACTOR_DOC_NAME").Value
      End If
      NewRow.Attributes("ATTR_INVOICE_DOCS_NAME").Value = oName
      'Обозначение документации
      oNum = ""
      If Obj.Attributes.Has("ATTR_WORK_DOCS_SET_CODE") Then
        oNum = Obj.Attributes("ATTR_WORK_DOCS_SET_CODE").Value
      ElseIf Obj.Attributes.Has("ATTR_VOLUME_CODE") Then
        oNum = Obj.Attributes("ATTR_VOLUME_CODE").Value
      End If
      NewRow.Attributes("ATTR_INVOICE_DOCS_NUMBER").Value = oNum
      '№ Изм
      If Obj.Attributes.Has("ATTR_CHANGE_NUM") Then
        NewRow.Attributes("ATTR_INVOICE_DOCS_CHANGE").Value = Obj.Attributes("ATTR_CHANGE_NUM").Value
      End If
      'Число копий на бумаге
      NewRow.Attributes("ATTR_INVOICE_DOCS_PAPER_COUNT").Value = 1
      'Число копий электронных носителей
      NewRow.Attributes("ATTR_INVOICE_DOCS_EL_COUNT").Value = 1
    End If
  Next

End Sub

'Кнопка - Удалить
Sub BUTTON_DEL_OnClick()
  ThisScript.SysAdminModeOn

  Dim ctrl, i, att, selected
  Set att = ThisObject.Attributes("ATTR_INVOICE_TDOCS")
  Set ctrl = ThisForm.Controls("ATTR_INVOICE_TDOCS")
  selected = ctrl.SelectedItems
  For i = UBound(selected) To LBound(selected) Step -1
    Dim row
    Set row = att.Rows(selected(i))
    If Not row.Attributes("ATTR_INVOICE_DOCS_OBJ").Empty Then _
      RemoveFiles ThisObject, row.Attributes("ATTR_INVOICE_DOCS_OBJ").Object
    row.Erase
  Next
End Sub

Private Sub RemoveFiles(obj, remove)

  Dim dict, o
  Set dict = CreateObject("Scripting.Dictionary")
  For Each o In remove.ContentAll
    dict.Add o.GUID, 1
  Next
  dict.Add remove.GUID, 1
  
  Dim table, row, att, files
  Set table = obj.Attributes("ATTR_INVOICE_TFILES")
  Set files = obj.Files
  For Each row In table.Rows
    Set att = row.Attributes
    If dict.Exists(att("ATTR_INVOICE_OBJ_GUID").Value) Then
      If files.Has(att("ATTR_FILE_NAME").Value) Then
        files(att("ATTR_FILE_NAME").Value).Erase
      End If
      row.Erase
    End If
  Next
End Sub

Sub ATTR_INVOICE_TDOCS_SelChanged()
  ThisForm.Controls("BUTTON_DEL").Enabled = EnableDelete(ThisForm, ThisObject)
End Sub

Sub BUTTON_UPDATE_TRANSFER_DOC_OnClick()

  Dim sam
  Set sam = New SysAdminMode
  
  Dim progress
  Set progress = New CProgress
  
  progress.Text = "Подготовка шаблона"
  
  Dim transferDoc
  Set transferDoc = GetTransferDoc(ThisObject)
  If transferDoc Is Nothing Then
    Set transferDoc = CopyTransferDocFromTemplate(ThisObject)
  End If
  
  If FileIsOpened(transferDoc.WorkFileName) Then
    MsgBox "Файл " & transferDoc.FileName & " открыт в другой программе." & vbCrLf & _
      "Закройте открытые файлы перед запуском команды.", vbExclamation, ThisApplication.DatabaseName
    Exit Sub
  End If
  
  progress.Text = "Выгрузка документа"
  transferDoc.CheckOut transferDoc.WorkFileName
  
  progress.Text = "Обновление документа"
  UpdateTransferDocContent transferDoc, ThisObject, progress
  
  progress.Text = "Загрузка документа"
  transferDoc.CheckIn transferDoc.WorkFileName
End Sub

Private Function FileIsOpened(path)
  FileIsOpened = ThisApplication.ExecuteScript("CMD_SS_LIB", "FileIsOpened", path)
End Function

Private Function GetTransferDoc(obj)
  Set GetTransferDoc = Nothing
  
  Dim files, f, fname
  Set files = obj.Files.FilesByDef("FILE_TRANSFER_DOCUMENT")
  For Each f In files
    fname = LCase(f.FileName)
    If 0 = InStr(1, fname, "эвкд") Then
      Set GetTransferDoc = f: Exit Function
    End If
  Next
End Function

Private Function CopyTransferDocFromTemplate(obj)
  Set CopyTransferDocFromTemplate = Nothing
  
  ' no transfer documents expected 
  Dim files
  Set files = obj.Files
  
  Dim templates
  Set templates = ThisApplication.FileDefs("FILE_TRANSFER_DOCUMENT").Templates
  If Not templates.Has("Передаточный_документ_(шаблон).docx") Then
    Err.Raise vbObjectError, "FORM_INVOICE_DOCS.CopyTransferDocFromTemplate", _
      "Transfer document template missing"
  End If
  
  Set CopyTransferDocFromTemplate = files.AddCopy( _
    templates("Передаточный_документ_(шаблон).docx"), ComposeTransferDocName(obj) & ".docx")
End Function

Private Function ComposeTransferDocName(obj)
  ComposeTransferDocName = "№0 от " & FormatDateTime(ThisApplication.CurrentTime, vbShortDate)
  
  Dim att, item
  Set att = obj.Attributes
  If att.Has("ATTR_REG_NUMBER") Then
    Set item = att("ATTR_REG_NUMBER")
    If Not item.Empty Then ComposeTransferDocName = "№" & item.Value & " от "
  End If
  If att.Has("ATTR_DATA") Then
    Set item = att("ATTR_DATA")
    If Not item.Empty Then _
      ComposeTransferDocName = ComposeTransferDocName & FormatDateTime(item.Value, vbShortDate)
  End If
  If att.Has("ATTR_INVOICE_RECIPIENT") Then
    Set item = att("ATTR_INVOICE_RECIPIENT")
    If Not item.Object Is Nothing Then
      ComposeTransferDocName = ComposeTransferDocName & ", " & _
        item.Object.Description
    End If
  End If
  ComposeTransferDocName = ThisApplication.ExecuteScript( _
    "CMD_SS_LIB", "NormalizePath", ComposeTransferDocName)
End Function

Private Sub UpdateTransferDocContent(template, source, progress)
  
  progress.Text = "Открытие документа"
  
  Dim doc
  Set doc = GetObject(template.WorkFileName)
  
  If Not doc.Application.Visible Then doc.Application.Visible = True
  
  Dim table
  Set table = doc.Tables(2)
  
  PrepareTable table
  
  FillData source.Attributes("ATTR_INVOICE_TDOCS"), table, progress
  
  progress.Text = "Сохранение документа"
  doc.Save
End Sub

Private Sub FillData(source, target, progress)

  progress.SetRange 0, source.Rows.Count
  
  Dim row, att
  For Each row In source.Rows
    Set att = row.Attributes
    If Not att("ATTR_INVOICE_DOCS_OBJ").Object Is Nothing Then
      progress.Text = att("ATTR_INVOICE_DOCS_OBJ").Object.Description
    End If
    
    FillRow row, target.Rows.Add(target.Rows.Last)
    
    progress.Step
  Next
End Sub

Private Sub FillRow(source, target)

  If Not source.Attributes.Has("ATTR_INVOICE_DOCS_OBJ") Then Exit Sub
  If source.Attributes("ATTR_INVOICE_DOCS_OBJ").Empty Then Exit Sub

  Dim obj, objAtt, project, phase, stage, name, code
  Set obj = source.Attributes("ATTR_INVOICE_DOCS_OBJ").Object
  Set objAtt = obj.Attributes
  If objAtt.Has("ATTR_PROJECT") Then Set project = objAtt("ATTR_PROJECT").Object
  Set phase = Nothing
  If objAtt.Has("ATTR_CONTRACT_STAGE") Then 
    Set phase = objAtt("ATTR_CONTRACT_STAGE").Object
  Else
    If objAtt.Has("ATTR_BUILDING_STAGE") Then
      Set oBuildStage = objAtt("ATTR_BUILDING_STAGE").Object
      If Not oBuildStage Is Nothing Then
        If oBuildStage.Attributes.Has("ATTR_CONTRACT_STAGE") Then 
          Set phase = oBuildStage.Attributes("ATTR_CONTRACT_STAGE").Object
        End If
      End If
    End If
  End If
  Set stage = ThisApplication.ExecuteScript("CMD_S_DLL", "GetStage", obj)
  name = GetObjectName(obj)
  code = GetObjectCode(obj)
  
  With target.Cells
    .Item(1).Range.InsertBefore target.Index - 1
    .Item(2).Range.InsertBefore ComposeName(project, phase, stage, name)
    If vbNullString <> code Then _
      .Item(3).Range.InsertBefore code
    If Not source.Attributes("ATTR_INVOICE_DOCS_PAPER_COUNT").Empty Then
      .Item(4).Range.InsertBefore _
        source.Attributes("ATTR_INVOICE_DOCS_PAPER_COUNT").Value
    End If
  End With
End Sub

Private Function ComposeName(project, phase, stage, objName)

  Dim a
  a = Array()
  If Not project Is Nothing Then
    ReDim Preserve a(UBound(a) + 1)
    a(UBound(a)) = project.Attributes("ATTR_PROJECT_NAME").Value
  End If
  If Not phase Is Nothing Then
    ReDim Preserve a(UBound(a) + 1)
    a(UBound(a)) = phase.Attributes("ATTR_CONTRACT_STAGE_NUM").Value
  End If
  If Not stage Is Nothing Then
    ReDim Preserve a(UBound(a) + 1)
    a(UBound(a)) = stage.Attributes("ATTR_PROJECT_STAGE").Classifier.Description
  End If
  ReDim Preserve a(UBound(a) + 1)
  a(UBound(a)) = objName
  ComposeName = Join(a, ", ")
End Function

Private Function GetObjectName(obj)
  GetObjectName = vbNullString
  
  If "OBJECT_VOLUME" = obj.ObjectDefName Then
    GetObjectName = obj.Attributes("ATTR_VOLUME_NAME").Value
  ElseIf "OBJECT_WORK_DOCS_SET" = obj.ObjectDefName Then
    GetObjectName = obj.Attributes("ATTR_WORK_DOCS_SET_NAME").Value
  Else 
    GetObjectName = obj.Description
  End If
End Function

Private Function GetObjectCode(obj)
  GetObjectCode = vbNullString
  
  Dim att, item
  Set att = obj.Attributes
  If "OBJECT_VOLUME" = obj.ObjectDefName Then
    GetObjectCode = att("ATTR_VOLUME_CODE").Value
  ElseIf "OBJECT_WORK_DOCS_SET" = obj.ObjectDefName Then
    GetObjectCode = att("ATTR_WORK_DOCS_SET_CODE").Value
  End If
  If att.Has("ATTR_CHANGE_NUM") Then
    Set item = att("ATTR_CHANGE_NUM")
    If Not item.Empty Then
      If item.Value > 0 Then
        GetObjectCode = GetObjectCode & ", Изм. " & item.Value
      End If
    End If
  End If
End Function

Private Sub PrepareTable(table)

  Dim i
  If table.Rows.Count > 2 Then
    For i = table.Rows.Count To 3 Step -1
      table.Rows(i).Delete
    Next
  End If
  
  table.Rows(2).Range.Delete
End Sub

Private Function DraftOrAssemblingAndAuthor(obj)
  DraftOrAssemblingAndAuthor = False
  
  If "STATUS_INVOICE_FORTHEPICKING" = obj.StatusName _
    Or "STATUS_INVOICE_DRAFT" = obj.StatusName Then
    If obj.Attributes.Has("ATTR_AUTOR") Then
      If Not obj.Attributes("ATTR_AUTOR").User Is Nothing Then
        DraftOrAssemblingAndAuthor = ThisApplication.CurrentUser.SysName = _
          obj.Attributes("ATTR_AUTOR").User.SysName
      End If
    End If
  End If
End Function

Private Function AssemblingAndAuthor(obj)
  AssemblingAndAuthor = False
  
  If obj.StatusName = "STATUS_INVOICE_FORTHEPICKING" Then
    If obj.Attributes.Has("ATTR_AUTOR") Then
      If Not obj.Attributes("ATTR_AUTOR").User Is Nothing Then
        AssemblingAndAuthor = ThisApplication.CurrentUser.SysName = _
          obj.Attributes("ATTR_AUTOR").User.SysName
      End If
    End If
  End If
End Function

Private Function EnableDelete(form, obj)
  EnableDelete = AssemblingAndAuthor(obj)
  
  Dim table
  If form.Controls.Has("ATTR_INVOICE_TDOCS") Then
    Set table = form.Controls("ATTR_INVOICE_TDOCS")
    EnableDelete = EnableDelete And UBound(table.SelectedItems) >= 0
  End If
End Function

Sub Form_TableAttributeChange(Form, Object, TableAttribute, TableRow, ColumnAttributeDefName, OldTableRow, Cancel)
  If Not AssemblingAndAuthor(Object) Then Cancel = True
End Sub
