' Автор: Стромков С.А.
'
' Создание подразделов для выбранного раздела
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2017

Dim o,p,arr()
Set o = ThisObject
Set p = o.Attributes("ATTR_PROJECT").Object
o.Permissions = SysAdminPermissions

Call Main (o)

'Основная процедура. Одинаковая для всех разделов и подразделов
Sub Main(o_)
  Dim vDivisions
  Dim clsRoot,result
  Set clsRoot = o_.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier
  If clsRoot Is Nothing Then Exit Sub
  
  Set result = clsRoot.Classifiers

  If result.count = 0 Then 
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1254
    Exit Sub
  End If
  
  Call CreateArrayFromClassifiers(result)
  ' Выбор разделов
  vDivisions = SelectDialog(arr)
 
  If VarType(vDivisions) = 0 Then Exit Sub
  ' Создание разделов
  Call CreateSections(o_,vDivisions,"OBJECT_PROJECT_SECTION_SUBSECTION")
End Sub

'==============================================================================
'--------Отображение окна с подразделами--------
'
'==============================================================================
Private Function SelectDialog(arr_)
  SelectDialog = Empty  
  'Окно
  Set SelDlg = ThisApplication.Dialogs.SelectDlg
  'Галочки
  SelDlg.UseCheckBoxes = true
  'Объекты
  SelDlg.SelectFrom = arr_
  SelDlg.SetSelection = arr_
  If SelDlg.Show Then 
    SelectDialog = SelDlg.Objects
  End If
End Function

Private Sub CreateArrayFromClassifiers(vClassifiers)
  If p is Nothing Then
    ReDim Preserve arr(vClassifiers.count)
    For i = 0 To vClassifiers.count-1
      Set arr(i) = vClassifiers.Item(i)
    Next
    Exit Sub
  End If
  
  ThisApplication.Utility.WaitCursor = True
  
  Set Query = ThisApplication.Queries("QUERY_REPORT_PROJECT_SUBSECTION_STATUS")
  Query.Parameter("PROJECT") = p
  
  Check = True
  For Each Clf in vClassifiers
    Query.Parameter("TYPE") = Clf
    If Query.Sheet.CellValue(0,0) = "" Then
      If Check = True Then
        i = -1
        Check = False
      Else
        i = Ubound(arr)
      End If
      ReDim Preserve arr(i+1)
      Set arr(Ubound(arr)) = Clf
    End If
  Next
  
  ThisApplication.Utility.WaitCursor = False
End Sub


'==============================================================================
'--------Создание подразделов--------
'Создаёт выбранные пользователем подразделы
'==============================================================================
Private Sub CreateSections(o_,vDivisions_,oDefName_)
  Dim vDiv, sDiv,sDivn
  Dim oNew

  'Цикл по всем выделенным пользователем объектам
  For i=0 To UBound(vDivisions_)
    Set vDiv = vDivisions_(i)
    
      'Формируем значения заполняемых атрибутов и уникальное для данного раздела наименование          
      Select Case o_.ObjectDefName
        Case "OBJECT_PROJECT_SECTION"          'sysID типа объекта, внутри которого строим разделы\подразделы
          'Обозначение родительского раздела и текущего
          sDivn = vDiv.Code
          'описание по которому проверяем наличие объекта, чтобы не создавать
          ' Атрибут для описания в дереве
          
      End Select
    'Создание нового объекта
    'If Not  o_.Objects.Has(treeDesc) Then
      Set oNew = o_.Objects.Create(oDefName_)
      
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr", oNew,"ATTR_PROJECT_DOCS_SECTION", vDiv
      ThisApplication.ExecuteScript "CMD_PROJECT_SECTION_ADD","SetSectionAttrs",oNew
  Next
End Sub
