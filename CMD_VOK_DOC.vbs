' Команда  - ВОК
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2016 г.

USE "CMD_DLL_REPORTS"

Call Main(ThisObject)

Sub Main(Obj)
  Set CU = ThisApplication.CurrentUser
  Set ObjWord = Nothing
  Set ObjFile = Nothing
  Set Table = Nothing
  Set Templ = Nothing
  ProjectCode = ""
  RowStart = 3
  ColCount = 1
  nColStart = 0
  nColEnd = 0
  StrDate = Cstr(Date)
  StrDate = Left(StrDate,6) & Right(StrDate,2)
  TemplName = "VOK"
  
  'Получаем шифр Проекта
  If Obj.Attributes("ATTR_PROJECT").Empty = False Then
    If not Obj.Attributes("ATTR_PROJECT").Object is Nothing Then
      Set Project = Obj.Attributes("ATTR_PROJECT").Object
      ProjectCode = Project.Attributes("ATTR_PROJECT_CODE").Value
    End If
  End If
  
  'Получаем результат выборки
  Set Query = ThisApplication.Queries("QUERY_VOK_DOC")
  Query.Parameter("OBJ") = Obj
  Set Sheet = Query.Sheet
  
  If Sheet.RowsCount = 0 Then
    Msgbox "Нет данных для выгрузки.",vbExclamation
    Exit Sub
  End If

  ColCount = Sheet.ColumnsCount
  nColEnd = ColCount

  '"Ведомость основного комплекта рабочих чертежей"
  Set docType = ThisApplication.Classifiers("NODE_DOC_TYPES_ALL").Classifiers.Find("ВОК")
  
  fName = Obj.Attributes("ATTR_PROJECT_BASIC_CODE") 
  If Not docType Is Nothing Then _
    fName = fName & "-" & docType.Code
  
  fName = ThisApplication.ExecuteScript("CMD_FILES_LIBRARY","CharsChange",fName,"_")
  fName = fName & ".docx"
  
  'Запрос папки выгрузки
'  Fpath = GetPathSave()
  SelFileName = GetFileSave(fName)
  If IsArray(SelFileName) = False Then Exit Sub
  SaveFileName = SelFileName(0)
  
  pos = InStrRev(SaveFileName,"\")
  Fpath = Left(SaveFileName,pos-1)
  fName = Right(SaveFileName,Len(SaveFileName)-pos)
  
  'Проверка файла
'  FileIsOpened = ThisApplication.ExecuteScript("CMD_SS_LIB", "FileIsOpened", Fpath&"\"&TemplName&".docx")
  FileIsOpened = ThisApplication.ExecuteScript("CMD_SS_LIB", "FileIsOpened", Fpath&"\"&fName)
  If FileIsOpened Then
    Msgbox "Невозможно документ, т.к. файл открыт в редакторе",vbExclamation,"Отчет: ВОК"
    Exit Sub
  End If
  
  ThisApplication.Utility.WaitCursor = True
  
  'Выгрузка шаблона
  Set Templ = GetTemplate("",Fpath,fName,TemplName & ".docx")
        
  'Запуск Word
  NewDoc = WordStart(Fpath,ObjWord,ObjFile,Table,ColCount,RowStart)

  RowStart = 3

  If not ObjFile Is Nothing Then  
    'Заполнение таблицы
    Call VokTableFill(Table,Sheet,RowStart,nColStart,nColEnd)
    Call DocPropFill(Obj,ObjFile,Sheet)
    Call FieldsFill(Obj,ObjFile,Sheet)
    Call UpdateAllFields(ObjFile)
    ObjWord.Visible = True
'    ObjFile.SaveAs
    ObjFile.Save
    Set ObjWord = Nothing
  End If
  
  ThisApplication.Utility.WaitCursor = False
End Sub


''=================================================================================================
''Процедура заполнения таблицы WORD
''Table:Object - ссылка на таблицу WORD
''Sheet:Object - ссылка на таблицу выборки
''RowStart:Integer - номер первой строки для заполнения
''nColStart:Integer - номер столбца, с которого начинается заполнение
''nColEnd:Integer - номер столбца, до которого заполняем
'Sub VokTableFill(Table,Sheet,RowStart,nColStart,nColEnd)
'  Count = 0 'Счетчик строк
'  For i = 0 to Sheet.RowsCount-1
'    k = 1 'счетчик столбцов
'    If Count <> 0 Then
'      Table.Rows.Add
'    End If
'    For j = nColStart to nColEnd
'      If k < Table.Columns.Count Then
''        Table.cell(i+RowStart,k+1).range.text = Sheet.CellValue(i,j)
'                Table.cell(i+RowStart,k).range.text = Sheet.CellValue(i,j)
'        k = k + 1
'      End If
'    Next
'    Count = Count + 1
'    'Table.cell(i+RowStart,0).range.text = Count
'  Next
'End Sub


'=================================================================================================
'Процедура заполнения таблицы WORD
'Table:Object - ссылка на таблицу WORD
'Sheet:Object - ссылка на таблицу выборки
'RowStart:Integer - номер первой строки для заполнения
'nColStart:Integer - номер столбца, с которого начинается заполнение
'nColEnd:Integer - номер столбца, до которого заполняем
Sub VokTableFill(Table,Sheet,RowStart,nColStart,nColEnd)
  Count = 0 'Счетчик строк
  Table.cell(RowStart-1,1).range.text = Sheet.CellValue(0,0)
  Table.cell(RowStart,1).range.text = Sheet.CellValue(0,1)
  For i = 1 to Sheet.RowsCount
    If Count <> 0 Then
      Table.Rows.Add
    End If
    
    ChNum = Sheet.CellValue(i-1,"Примечание")
    If ChNum = "0" Then 
      ChNum = ""
    Else
      ChNum = "Изм." & ChNum
    End If
    
    Table.cell(i+RowStart,1).range.text = Sheet.CellValue(i-1,"Обозначение")
    Table.cell(i+RowStart,2).range.text = Sheet.CellValue(i-1,"Наименование")
    Table.cell(i+RowStart,3).range.text = ChNum
    Count = Count + 1
  Next
End Sub

Sub DocPropFill(Obj,ObjFile,Sheet)
'  ThisApplication.AddNotify "FieldsFill"
  If ObjFile Is Nothing Then Exit Sub
  For each prop In ObjFile.CustomDocumentProperties
    Val = vbNullString
'    ThisApplication.AddNotify prop.Name
    Select Case prop.Name
      
      Case "ATTR_DOC_CODE"
      Val = Left(ObjFile.Name,Len(ObjFile.Name)-5)
      Case "ATTR_DOCUMENT_NAME"
        Val = "Ведомость основных комплектов рабочих чертежей"
        prop.Value = Val
      Case "ExternFunctions.Mycompany"
        Val = ThisApplication.ExecuteScript("ExternFunctions","Mycompany",Obj)
      Case "ExternFunctions.StageCode"
        Val = ThisApplication.ExecuteScript("ExternFunctions","StageCode",Obj)
      Case "ExternFunctions.GetObjectDesc"
        Val = Obj.Attributes("ATTR_WORK_DOCS_FOR_BUILDING_NAME")
      Case "ExternFunctions.GetDocDevelopUser"
        Set user = ThisApplication.CurrentUser
        If Not user Is Nothing Then
          Val = user.LastName
        End If
  '      Val = ThisApplication.ExecuteScript("ExternFunctions","GetDocDevelopUser",Obj)
  '    Case "ExternFunctions.GetDocCheckUser1"
  '      Val = ThisApplication.ExecuteScript("ExternFunctions","GetDocCheckUser1",Obj)
  '    Case "ExternFunctions.GetDocNKUser"
  '      Val = ThisApplication.ExecuteScript("ExternFunctions","GetDocNKUser",Obj)
      Case "ExternFunctions.GetDocApproveUser"
        Set user = Obj.Attributes("ATTR_PROJECT").Object.Attributes("ATTR_PROJECT_GIP").User
        If Not user Is Nothing Then
          Val = user.LastName
        End If
    End Select
    prop.Value = Val
  Next
End Sub

Sub FieldsFill(Obj,ObjFile,Sheet)
'  ThisApplication.AddNotify "FieldsFill"
  If ObjFile Is Nothing Then Exit Sub
  'Заполнение шапки шаблона
  For Each Fld in ObjFile.Fields
'    ThisApplication.AddNotify "Зашло"
    FldName = LCase(Trim(Fld.Code.Text))
    Select Case FldName
      Case "project"
              Fld.Result.Text = Sheet.CellValue(0,0)
      Case "dept"
              Fld.Result.Text = Dept
      Case "datein"
              Fld.Result.Text = DateIn
      Case "dateout"
              Fld.Result.Text = DateOut
      Case "dategen"
              Fld.Result.Text = Date
      Case "user"
              Fld.Result.Text = CU.Description
    End Select
    Fld.Update
  Next
End Sub

Function GetTargetDoc(Obj)
  Set GetTargetDoc = Nothing
  Set docs = Obj.Objects.ObjectsByDef("OBJECT_DOC_DEV")

  If docs.Count > 0 Then 
    For each oDoc In docs
      oDoc.permissions = SysAdminPermissions
      If oDoc.Attributes.Has("ATTR_PROJECT_DOC_TYPE") Then
        Set cls = oDoc.Attributes("ATTR_PROJECT_DOC_TYPE").Classifier
        If Not cls Is Nothing Then
          If cls.code = "ВОК" Then
            Set GetTargetDoc = oDoc
            Exit For
          End If
        End If
      End If
    Next
  End If
  If GetTargetDoc Is Nothing Then
    Set GetTargetDoc = CreateVokDok(Obj)
  End If
End Function

Function CreateVokDok(Obj)
  Set CreateVokDok = Nothing
  Set docType = ThisApplication.Classifiers("NODE_DOC_TYPES_ALL").Classifiers.FindBySysId("NODE_FFDAAA1F_50D7_4F99_B128_2A178231D6EA")
  If docType Is Nothing Then Exit Function
  Obj.Permissions = SysAdminPermissions
  
  On error Resume Next
  Set newObj = Obj.Objects.Create("OBJECT_DOC_DEV")
  If err.code <>0 Then 
    Err.clear
    Exit Function
  End If
   
  
  NewObj.Attributes("ATTR_PROJECT_DOC_TYPE").Classifier = docType
  'NewObj.Attributes("ATTR_DOC_CODE") = docType.Code
  NewObj.Attributes("ATTR_DOCUMENT_NAME") = docType.Description
  Call ThisApplication.ExecuteScript("FORM_DOC_DEV","CodeGen",NewObj)
  Set CreateVokDok = NewObj
End Function

Sub UpdateAllFields(ActiveDocument)
  Set Application = ActiveDocument.Application
  Application.ScreenUpdating = False 'Отключение обновления экрана
  ActiveDocument.PrintPreview 'Предварительный просмотр
  ActiveDocument.ClosePrintPreview 'Закрыть предварительный просмотр
  Application.ScreenUpdating = True 'Обновить экран
End Sub


