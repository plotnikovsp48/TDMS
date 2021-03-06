' Автор: Стромков С.А.
'
' Создание разделов
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

Dim o,p,arr(),odef
Set oProj = ThisObject.Attributes("ATTR_PROJECT").Object
ThisObject.Permissions = SysAdminPermissions

Call Main (ThisObject)

'Основная процедура. Одинаковая для всех разделов и подразделов
Sub Main(Obj)
  Dim vDivisions
  Set cls = Prepare (Obj)
  If cls is nothing Then Exit Sub
  
  Call CreateArrayFromClassifiers(cls.Classifiers)
  ' Выбор разделов
  vDivisions = SelectDialog(arr)
  If VarType(vDivisions) = 0 Then Exit Sub
  ' Создание разделов
  Call CreateSections(Obj,vDivisions,odef)
End Sub

'==============================================================================
' Поиск корневого узла классификатора структуры проекта в зависимости от стадии и вида проектируемого объекта
'------------------------------------------------------------------------------
' o_: TDMSObject - объект с которого создается раздел/подраздел
' Prepare: TDMSClissIfiers - коллекция узлов классификатора для отображения в диалоге
' oDef: - тип объекта, который создается
'==============================================================================
Function Prepare(o_)
  Set Prepare = Nothing
  Select case o_.ObjectDefName  'sysID типа объекта, внутри которого строим разделы\подразделы
    Case "OBJECT_STAGE"
      Set clsRoot = ThisApplication.Classifiers.FindBySysId("NODE_PROJECT_STRUCT").Classifiers
      oDef = "OBJECT_PROJECT_SECTION"
      
      Set cls = GetStageStructureRoot(o_)
        If cls Is Nothing Then 
          msgbox "Структура проекта не найдена!",vbCritical,"Ошибка"
          Exit Function
        End If
    Case "OBJECT_PROJECT_SECTION"
      cls = o_.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier.SysName
      oDef = "OBJECT_PROJECT_SECTION_SUBSECTION"
  End Select  

'  Set Prepare = clsRoot.FindBySysId(cls)
  Set Prepare = clsRoot.FindBySysId(cls.SysName)
End Function

Private Sub CreateArrayFromClassifiers(vClassifiers)
  If oProj is Nothing Then
    ReDim Preserve arr(vClassifiers.count)
    For i = 0 To vClassifiers.count-1
      Set arr(i) = vClassifiers.Item(i)
    Next
    Exit Sub
  End If
  
  ThisApplication.Utility.WaitCursor = True
  
  Set Query = ThisApplication.Queries("QUERY_REPORT_PROJECT_SECTION_STATUS")
  Query.Parameter("PROJECT") = oProj
  
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
'--------Отображение окна с разделами--------
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

'==============================================================================
'--------Создание разделов--------
'Создаёт отмеченные пользователем разделы
'==============================================================================
Private Sub CreateSections(o_,vDivisions_,oDefName_)
  Dim sect
  Dim sDiv,sDivn

  'Цикл по всем выделенным пользователем объектам
  For i=0 To UBound(vDivisions_)
    Set sect = vDivisions_(i)
    sDivn = sect.Code
    CheckValue=sect.Description

    'Создание нового объекта
    If Not  o_.Objects.Has(CheckValue) Then
      Set NewObj = CreateSection(o_,sect,oDefName_)
      
'      Set oNew = o_.Objects.Create(oDefName_) 
'      
'          ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", oNew,"ATTR_PROJECT_DOCS_SECTION", vDiv,True
'          
'          Call SetSectionAttrs(oNew)

    End If
  Next
End Sub

'==============================================================================
'--------Создание раздела--------
'Создаёт раздел
'==============================================================================
Private Function CreateSection(Root,sect,oDefName_)
  Set CreateSection = Nothing
  'Создание нового объекта
  Set oNew = Root.Objects.Create(oDefName_) 
    ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", oNew,"ATTR_PROJECT_DOCS_SECTION", sect,True
    Call SetSectionAttrs(oNew)
    Set CreateSection = oNew
End Function

'Заполнение атрибутов, зависящих от атрибута Раздел документации
Sub SetSectionAttrs(oNew)
  Set cls = oNew.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier
  If cls Is Nothing Then Exit Sub
  clsCode = cls.Code
  clsDecs = cls.Description
  ' Атрибут - Код
  If Trim(clsCode) <> "" Then
    ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", oNew,"ATTR_CODE", clsCode,True
  End If

  ' Атрибут - Наименование
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", oNew,"ATTR_NAME", oNew.Attributes("ATTR_PROJECT_STRUCTURE_TYPE").Classifier.Description & " " & clsDecs,True
  ' Атрибут - Номер Раздела\Подраздела
  Code = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "ProjectSectionNumGen", oNew)
  If Code <> "" Then oNew.Attributes("ATTR_SECTION_NUM").Value = Code

  ' Генерируем обозначение
  Call ThisApplication.ExecuteScript("FORM_PROJECT_SECTION","Set_ATTR_SECTION_CODE",oNew)
End Sub

'=================================================================
' Функция определяет корневой узел классификатора, 
' содержащего требуемые Разделы
' Поиск осуществляется по системному табличному атрибуту ATTR_STAGE_SETTINGS
' в зависимости от значений атрибутов ИО Стадия ATTR_PROJECT_STAGE и ATTR_SITE_TYPE_CLS
'-----------------------------------------------------------------
' GetStageStructureRoot: Узел классификатора
'                        Nothing - если узел не найден
'=================================================================
Function GetStageStructureRoot(Obj)
  Set GetStageStructureRoot = Nothing
    Set stage = Obj.Attributes("ATTR_PROJECT_STAGE").Classifier
    Set objprojtype = Obj.Attributes("ATTR_SITE_TYPE_CLS").Classifier
    
    If Not ThisApplication.Attributes.Has("ATTR_STAGE_SETTINGS") Then Exit Function
    Set rows = ThisApplication.Attributes("ATTR_STAGE_SETTINGS").Rows
    For Each row In rows
      If row.Attributes(0).Classifier.Handle = stage.Handle Then 
          If row.Attributes(1).Classifier Is Nothing Then
            Set GetStageStructureRoot = row.Attributes(2).Classifier
            Exit Function
          Else
            If Not objprojtype Is Nothing Then
              If row.Attributes(1).Classifier.Handle = objprojtype.Handle Then
                Set GetStageStructureRoot = row.Attributes(2).Classifier
                Exit Function
              End If
            End If
          End If
      End If
    Next
End Function

'' Автор: Стромков С.А.
''
'' Создание разделов
''------------------------------------------------------------------------------------------------------
'' Авторское право © ЗАО «СиСофт», 2016

'Dim o,p,arr(),odef
'Set o = ThisObject
'Set oProj = o.Attributes("ATTR_PROJECT").Object
'o.Permissions = SysAdminPermissions

'Call Main (o)

''Основная процедура. Одинаковая для всех разделов и подразделов
'Sub Main(o_)
'  Dim vDivisions
'  Set cls = Prepare (o_)
'  If cls is nothing Then Exit Sub
'  
'  Call CreateArrayFromClassifiers(cls.Classifiers)
'  ' Выбор разделов
'  vDivisions = SelectDialog(arr)
'  If VarType(vDivisions) = 0 Then Exit Sub
'  ' Создание разделов
'  Call CreateSections(o_,vDivisions,odef)
'End Sub

''==============================================================================
'' Поиск корневого узла классификатора структуры проекта в зависимости от стадии и вида проектируемого объекта
''------------------------------------------------------------------------------
'' o_: TDMSObject - объект с которого создается раздел/подраздел
'' Prepare: TDMSClissIfiers - коллекция узлов классификатора для отображения в диалоге
'' oDef: - тип объекта, который создается
''==============================================================================
'Function Prepare(o_)
'  Set Prepare = Nothing
'  Select case o_.ObjectDefName  'sysID типа объекта, внутри которого строим разделы\подразделы
'    Case "OBJECT_STAGE"
'      Set clsRoot = ThisApplication.Classifiers.FindBySysId("NODE_PROJECT_STRUCT").Classifiers
'      oDef = "OBJECT_PROJECT_SECTION"
'      
'      Set cls = GetStageStructureRoot(o_)
'        If cls Is Nothing Then 
'          msgbox "Структура проекта не найдена!",vbCritical,"Ошибка"
'          Exit Function
'        End If
'    Case "OBJECT_PROJECT_SECTION"
'      cls = o_.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier.SysName
'      oDef = "OBJECT_PROJECT_SECTION_SUBSECTION"
'  End Select  

''  Set Prepare = clsRoot.FindBySysId(cls)
'  Set Prepare = clsRoot.FindBySysId(cls.SysName)
'End Function

'Private Sub CreateArrayFromClassifiers(vClassifiers)
'  If oProj is Nothing Then
'    ReDim Preserve arr(vClassifiers.count)
'    For i = 0 To vClassifiers.count-1
'      Set arr(i) = vClassifiers.Item(i)
'    Next
'    Exit Sub
'  End If
'  
'  ThisApplication.Utility.WaitCursor = True
'  
'  Set Query = ThisApplication.Queries("QUERY_REPORT_PROJECT_SECTION_STATUS")
'  Query.Parameter("PROJECT") = oProj
'  
'  Check = True
'  For Each Clf in vClassifiers
'    Query.Parameter("TYPE") = Clf
'    If Query.Sheet.CellValue(0,0) = "" Then
'      If Check = True Then
'        i = -1
'        Check = False
'      Else
'        i = Ubound(arr)
'      End If
'      ReDim Preserve arr(i+1)
'      Set arr(Ubound(arr)) = Clf
'    End If
'  Next
'  
'  ThisApplication.Utility.WaitCursor = False
'End Sub

''==============================================================================
''--------Отображение окна с разделами--------
''
''==============================================================================
'Private Function SelectDialog(arr_)
'  SelectDialog = Empty  
'  'Окно
'  Set SelDlg = ThisApplication.Dialogs.SelectDlg
'  'Галочки
'  SelDlg.UseCheckBoxes = true
'  'Объекты
'  SelDlg.SelectFrom = arr_
'  If SelDlg.Show Then 
'    SelectDialog = SelDlg.Objects
'  End If
'End Function

''==============================================================================
''--------Создание разделов--------
''Создаёт отмеченные пользователем разделы
''==============================================================================
'Private Sub CreateSections(o_,vDivisions_,oDefName_)
'  Dim vDiv
'  Dim sDiv,sDivn

'  'Цикл по всем выделенным пользователем объектам
'  For i=0 To UBound(vDivisions_)
'    Set vDiv = vDivisions_(i)
'    
'      'Формируем значения заполняемых атрибутов и уникальное для данного раздела наименование          
'      Select case o_.ObjectDefName
'                                           
'        Case "OBJECT_STAGE"           'sysID типа объекта, внутри которого строим разделы\подразделы
'              'Обозначение родительского раздела и текущего
'              sDivn = vDiv.Code
'              'описание по которому проверяем наличие объекта, чтобы не создавать
'              CheckValue=vDiv.Description
'          
'        Case "OBJECT_PROJECT_SECTION"          'sysID типа объекта, внутри которого строим разделы\подразделы
'              'Обозначение родительского раздела и текущего
'              sDivn = vDiv.Code
'              'описание по которому проверяем наличие объекта, чтобы не создавать
'              CheckValue=vDiv.Description
'      End select

'    'Создание нового объекта
'    If Not  o_.Objects.Has(CheckValue) Then
'      Set oNew = o_.Objects.Create(oDefName_) 
'      
'          ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", oNew,"ATTR_PROJECT_DOCS_SECTION", vDiv,True
'          If vDiv.Description <> "Непроектный раздел" Then
'            Call SetSectionAttrs(oNew)
'          End If

'    End If
'  Next
'End Sub

''Заполнение атрибутов, зависящих от атрибута Раздел документации
'Sub SetSectionAttrs(oNew)
'  Set cls = oNew.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier
'  If cls Is Nothing Then Exit Sub
'  clsCode = cls.Code
'  clsDecs = cls.Description
'  ' Атрибут - Код
'  If Trim(clsCode) <> "" Then
'    ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", oNew,"ATTR_CODE", clsCode,True
'  End If

'  ' Атрибут - Наименование
'  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", oNew,"ATTR_NAME", oNew.Attributes("ATTR_PROJECT_STRUCTURE_TYPE").Classifier.Description & " " & clsDecs,True
'  ' Атрибут - Номер Раздела\Подраздела
'  Code = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "ProjectSectionNumGen", oNew)
'  If Code <> "" Then oNew.Attributes("ATTR_SECTION_NUM").Value = Code

'  ' Генерируем обозначение
'  Call ThisApplication.ExecuteScript("FORM_PROJECT_SECTION","Set_ATTR_SECTION_CODE",oNew)
'End Sub

''=================================================================
'' Функция определяет корневой узел классификатора, 
'' содержащего требуемые Разделы
'' Поиск осуществляется по системному табличному атрибуту ATTR_STAGE_SETTINGS
'' в зависимости от значений атрибутов ИО Стадия ATTR_PROJECT_STAGE и ATTR_SITE_TYPE_CLS
''-----------------------------------------------------------------
'' GetStageStructureRoot: Узел классификатора
''                        Nothing - если узел не найден
''=================================================================
'Function GetStageStructureRoot(Obj)
'  Set GetStageStructureRoot = Nothing
'    Set stage = Obj.Attributes("ATTR_PROJECT_STAGE").Classifier
'    Set objprojtype = Obj.Attributes("ATTR_SITE_TYPE_CLS").Classifier
'    
'    If Not ThisApplication.Attributes.Has("ATTR_STAGE_SETTINGS") Then Exit Function
'    Set rows = ThisApplication.Attributes("ATTR_STAGE_SETTINGS").Rows
'    For Each row In rows
'      If row.Attributes(0).Classifier.Handle = stage.Handle Then 
'          If row.Attributes(1).Classifier Is Nothing Then
'            Set GetStageStructureRoot = row.Attributes(2).Classifier
'            Exit Function
'          Else
'            If Not objprojtype Is Nothing Then
'              If row.Attributes(1).Classifier.Handle = objprojtype.Handle Then
'                Set GetStageStructureRoot = row.Attributes(2).Classifier
'                Exit Function
'              End If
'            End If
'          End If
'      End If
'    Next
'End Function
