' Форма ввода - Структура проекта
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

'=============================================================================================================
Sub Form_BeforeClose(Form, Obj, Cancel)
  Call AttrsSave
End Sub

'=============================================================================================================
Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  ThisScript.SysAdminModeOn
  Set Progress = ThisApplication.Dialogs.ProgressDlg
  Log0 = ""
  
  Call ButtonsEnable0(Form,Obj)
  
  'Проверка Стадии проектирования
  str = StageCheckAttrs(Obj,"ATTR_PROJECT_STAGE")
  If str = "" Then
    StageName = Obj.Attributes("ATTR_PROJECT_STAGE").Classifier.SysName
    If StageName = "NODE_PROJECT_STAGE_OTR" or StageName = "NODE_PROJECT_STAGE_P" Then
      'Проверка Вида проектируемого объекта
      temp = StageCheckAttrs(Obj,"ATTR_SITE_TYPE_CLS")
      If temp <> "" Then
      'AttrName = "ATTR_SITE_TYPE_CLS"
        If str <> "" Then
          str = str & chr(10) & temp
        Else
          str = temp
        End If
      End If
    End If
  End If
  If str <> "" Then
    Msgbox "Перед созданием структуры проекта, необходимо указать:" & chr(10) & str, vbExclamation
    Form.Controls("BUTTON_STRUCTURE_EDIT").Enabled = False
  End If


  ThisApplication.Utility.WaitCursor = True
  Progress.Start
  Progress.Text = "Построение дерева..."
  
  'Промежуточная нумерация существующих строк
  Call TablePreNumeric(Obj)

  'Инициализация дерева
  Set Tree = Form.Controls("STAGETREE").ActiveX
  Root = Tree.InsertItem(Obj.Description, 0, 1)
  'Если вновь созданный узел уже был в таблице, то пересоздаем
  do Until TableItemUpdCheck(Obj,Root) = True
    Tree.DeleteItem Root
    Root = Tree.InsertItem(Obj.Description, 0, 1)
    Log0 = Log0 & chr(10) & Root
  Loop
  Tree.SetItemIcon Root , Obj.Icon
  SelectedItem = 0
  
  'Проверка атрибутов
  'AttrName = "ATTR_ORIGINAL_STATUS_NAME"
  'If Obj.Attributes.Has(AttrName) = False and ThisApplication.AttributeDefs.Has(AttrName) Then
  '  Obj.Attributes.Create ThisApplication.AttributeDefs(AttrName)
  'End If
  'AttrName = "ATTR_STAGE_PROJECT_STRUCT_PUBLIC"
  'If Obj.Attributes.Has(AttrName) = False and ThisApplication.AttributeDefs.Has(AttrName) Then
  '  Obj.Attributes.Create ThisApplication.AttributeDefs(AttrName)
  'End If
  'If Obj.Attributes.Has(AttrName) = False Then Exit Sub
  'AttrName = "ATTR_PROJECT_STRUCT_ATTRS_TBL"
  'If Obj.Attributes.Has(AttrName) = False and ThisApplication.AttributeDefs.Has(AttrName) Then
  '  Obj.Attributes.Create ThisApplication.AttributeDefs(AttrName)
  'End If
  'If Obj.Attributes.Has(AttrName) = False Then Exit Sub
  'AttrName = "ATTR_PROJECT_STRUCT_ATTRS_TBL2"
  'If Obj.Attributes.Has(AttrName) = False and ThisApplication.AttributeDefs.Has(AttrName) Then
  '  Obj.Attributes.Create ThisApplication.AttributeDefs(AttrName)
  'End If
  'If Obj.Attributes.Has(AttrName) = False Then Exit Sub
  'AttrName = "ATTR_PROJECT_STRUCT_TBL"
  'If Obj.Attributes.Has(AttrName) = False and ThisApplication.AttributeDefs.Has(AttrName) Then
  '  Obj.Attributes.Create ThisApplication.AttributeDefs(AttrName)
  'End If
  'If Obj.Attributes.Has(AttrName) = False Then Exit Sub
  
  AttrName = "ATTR_PROJECT_STRUCT_TBL"
  Set AttrsRows = Obj.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
  Set Rows = Obj.Attributes(AttrName).Rows
  If Rows.Count = 0 Then
    Set NewRow = Rows.Create
    NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_PARENT").Value = "0"
    NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJTYPE").Value = Obj.ObjectDefName
    NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJNAME").Value = Obj.Description
    NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJGUID").Value = Obj.GUID
    NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = Root
    Tree.SetItemData Root, NewRow
  End If
  
  'Обновление таблицы
  Call RowsUpdate(Root,0,Rows)
  
  'Заполнение дерева
  For Each Row in Rows
    If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_PARENT").Value <> "0" Then
      If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_PARENT").Empty = False Then
        pItem = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_PARENT").Value
        Item1 =  Tree.InsertItem(Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJNAME").Value, pItem, 1)
        do Until TableItemUpdCheck(Obj,Item1) = True
          Tree.DeleteItem Item1
          Item1 =  Tree.InsertItem(Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJNAME").Value, pItem, 1)
          Log0 = Log0 & chr(10) & Item1
        Loop
        hItem = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value
        Call RowsUpdate(Item1,hItem,Rows)
        Call RowsUpdate(Item1,hItem,AttrsRows)
        If Item1 <> 0 Then
          Tree.SetItemData Item1, Row
          ObjType = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJTYPE").Value
          If ObjType <> "" Then
            If ThisApplication.ObjectDefs.Has(ObjType) Then
              Tree.SetItemIcon Item1 , ThisApplication.ObjectDefs(ObjType).Icon
            End If
          End If
        End If
      End If
    Else
      Tree.SetItemData Tree.RootItem, Row
    End If
  Next
  
  Tree.SelectedItem = Tree.RootItem
  Tree.Expand Root
  Progress.Stop
  ThisApplication.Utility.WaitCursor = False
  
  'If Log0 <> "" Then
  '  ThisApplication.AddNotify Log0
  '  Tree.UpdateItem Root, True
  'End If
  
End Sub

'=============================================================================================================
'Кнопка - Удалить элемент
Sub BUTTON_ITEM_DEL_OnClick()
  Call ItemDel("")
  ThisObject.Attributes("ATTR_STAGE_PROJECT_STRUCT_PUBLIC").Value = False
  Call ButtonsEnable0(ThisForm,ThisObject)
End Sub

'=============================================================================================================
'Событие - Контекстное меню дерева
Sub STAGETREE_ContextMenu(hItem,x,y,bCancel)
  ThisScript.SysAdminModeOn
  Set Tree = ThisForm.Controls("STAGETREE").ActiveX
  Set Rows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_TBL").Rows
  Set AttrsRows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
  If hItem = 0 Then Exit Sub
  pItem = Tree.GetItemText(hItem)
  Set menu = ThisApplication.Dialogs.ContextMenu
  Set Clf = ThisObject.Attributes("ATTR_PROJECT_STAGE").Classifier
  If ThisApplication.ObjectDefs.Has("OBJECT_WORK_DOCS_FOR_BUILDING") Then
    Set Icon1 = ThisApplication.ObjectDefs("OBJECT_WORK_DOCS_FOR_BUILDING").Icon
  Else
    Msgbox "В системе отсутствует тип объекта ""Полный комплект""",vbExclamation
    Exit Sub
  End If
  If ThisApplication.ObjectDefs.Has("OBJECT_PROJECT_SECTION") Then
    Set Icon2 = ThisApplication.ObjectDefs("OBJECT_PROJECT_SECTION").Icon
  Else
    Msgbox "В системе отсутствует тип объекта ""Раздел""",vbExclamation
    Exit Sub
  End If
  If ThisApplication.ObjectDefs.Has("OBJECT_VOLUME") Then
    Set Icon3 = ThisApplication.ObjectDefs("OBJECT_VOLUME").Icon
  Else
    Msgbox "В системе отсутствует тип объекта ""Том""",vbExclamation
    Exit Sub
  End If
  
  Select Case Clf.SysName
    Case "NODE_PROJECT_STAGE_W"
      'If hItem = Tree.RootItem Then
        menu.AppendUserMenu 1, "Создать Полный комплект", 128
      'End If
    Case Else
      Set Row = Tree.GetItemData(hItem)
      If Row is Nothing Then Exit Sub
      ParentType = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJTYPE").Value
      If ParentType = "OBJECT_STAGE" Then
        menu.AppendUserMenu 2, "Добавить разделы", 90
      ElseIf ParentType = "OBJECT_PROJECT_SECTION" Then
        menu.AppendUserMenu 3, "Добавить подразделы", 90
        menu.AppendUserMenu 4, "Добавить Том", 44
      ElseIf ParentType = "OBJECT_PROJECT_SECTION_SUBSECTION" Then
        menu.AppendUserMenu 4, "Добавить Том", 44
      ElseIf ParentType = "OBJECT_VOLUME" Then
        menu.AppendUserMenu 4, "Добавить Том", 44
      End If
  End Select
  If hItem <> Tree.RootItem Then
    menu.AppendUserMenu 10, "Удалить", 63
  End If
  
  result = menu.Show(x, y)
  
  Select Case result
    Case 1 'Создать Полный комплект
      Call AddWorkDocs(Tree,Rows,AttrsRows,hItem,Icon1)
      Tree.UpdateItem hItem, False
      Tree.Expand hItem
      
    Case 2 'Добавить разделы
      Call AddSections(ThisObject,Tree,Rows,AttrsRows,hItem,Icon2)
      Tree.UpdateItem hItem, False
      Tree.Expand hItem
      
    Case 3 'Добавить подразделы
      Call AddSections(ThisObject,Tree,Rows,AttrsRows,hItem,Icon2)
      Tree.UpdateItem hItem, False
      Tree.Expand hItem
      
    Case 4 'Добавить Том от Раздела
      Call AddVolume(Tree,Rows,AttrsRows,hItem,Icon3)
      
    Case 10 'Удалить
      Call ItemDel(hItem)
      
  End Select
  
End Sub

'=============================================================================================================
'Процедура удаления узла дерева
Sub ItemDel(hItem)
  Set Tree = ThisForm.Controls("STAGETREE").ActiveX
  Set Rows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_TBL").Rows
  Set AttrsRows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
  If hItem = "" Then
    hItem = Tree.SelectedItem
  End If
  strItem = Cstr(hItem)
  str = strItem
  Call ArrFill(Rows,strItem,str)
  Arr = Split(str,",")
  For i = 0 to Ubound(Arr)
    For Each Row in Rows
      If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = Arr(i) Then
        Set Obj = ThisApplication.GetObjectByGUID(Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJGUID").Value)
        If Obj is Nothing Then
          Rows.Remove Row
        Else
          msgbox "Нельзя удалить элемент структуры, который уже существует.",vbExclamation
          Exit Sub
        End If
      End If
    Next
    For Each Row in AttrsRows
      If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = Arr(i) Then
        AttrsRows.Remove Row
        'Почему-то не удаляется одна строка
      End If
    Next
  Next
  Tree.DeleteItem hItem
  ThisForm.Controls("HITEM").Value = ""
End Sub

'=============================================================================================================
'Цикличная процедура удаления строк из таблицы
Sub ArrFill(Rows,hItem,str)
  For Each Row in Rows
    If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_PARENT").Value = hItem Then
      hItem0 = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value
      str = str & "," & hItem0
      Call ArrFill(Rows,hItem0,str)
    End If
  Next
End Sub

'=============================================================================================================
'Событие - Выделен узел в дереве
Sub STAGETREE_Selected(hItem,action)
  ThisScript.SysAdminModeOn
  Set Tree = ThisForm.Controls("STAGETREE").ActiveX
  Set Grid = ThisForm.Controls("ATTRSGRID").ActiveX
  
  'Если включен режим перемещения тома, то возврат выделения
  Set Dict = ThisForm.Dictionary
  If Dict.Exists("BackSelect") and Dict.Exists("hItem") Then
    If Dict.Item("BackSelect") = True Then
      bItem = Dict.Item("hItem")
      Tree.SelectedItem = bItem
      Exit Sub
    End If
  End If
  
  Call AttrsSave
  
  If hItem = Tree.RootItem Then
    Grid.RemoveAllRows
    Grid.Redraw
  Else
    Set Row = Tree.GetItemData(hItem)
    Call AttrsGridInit(Row)
    'ThisForm.Controls("BUTTON_ITEM_DEL").Enabled = True
  End If
  
  ThisForm.Controls("HITEM").Value = hItem
  ThisForm.Controls("ITEMNAME").Value = Tree.GetItemText(hItem)
  Call ButtonsEnable1(ThisForm,ThisObject)
End Sub

'=============================================================================================================
'Событие - Открыты дочерние элементы узла в дереве
Sub STAGETREE_Expanded(hItem,bExpanded)
  If bExpanded = True Then
    Set Tree = ThisForm.Controls("STAGETREE").ActiveX
    Tree.SortChildren(hItem)
  End If
End Sub

'=============================================================================================================
'Процедура Инициализации таблицы атрибутов на форме
Sub AttrsGridInit(Row)
  ThisScript.SysAdminModeOn
  Set Grid = ThisForm.Controls("ATTRSGRID").ActiveX
  Set Tree = ThisForm.Controls("STAGETREE").ActiveX
  Set AttrsRows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
  Set GridRows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL2").Rows
  Set AttrRow = Nothing
  GridRows.RemoveAll
  If Row is Nothing Then Exit Sub
  Attrs = ""
  hItem = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value
  
  ObjType = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJTYPE").Value
  Attrs = GetAttrsList(ObjType)
  
  'Создание строки атрибутов
  If hItem <> Tree.RootItem Then
    Set AttrRow = AttrsRowCreate(AttrsRows,hItem)
  End If
  
  'Создание строк таблицы на форме
  If Attrs <> "" Then
    Arr = Split(Attrs,",")
    For i = 0 to UBound(Arr)
      AttrSysName = Arr(i)
      If ThisApplication.AttributeDefs.Has(AttrSysName) Then
        Set NewRow = GridRows.Create
        Set AttrDef = ThisApplication.AttributeDefs(AttrSysName)
        NewRow.Attributes(0).Value = AttrDef.Description
        NewRow.Attributes(1).Value = AttrValueGet(Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value,AttrSysName)
        NewRow.Attributes(2).Value = AttrSysName
        If AttrDef.Type = 6 and not AttrRow is Nothing Then
          If AttrRow.Attributes(AttrSysName).Empty = False Then
            If not AttrRow.Attributes(AttrSysName).Classifier is Nothing Then
              NewRow.Attributes(3).Value = AttrRow.Attributes(AttrSysName).Classifier.SysName
            End If
          End If
        End If
      End If
    Next
  End If
  
  'Заполнение значений атрибутов в таблице
  hItemName = Tree.GetItemText(hItem)
  If StrComp(hItemName,"Непроектный раздел",vbTextCompare) = 0 Then
    Set clsRoot = GetRootClf(ThisObject,"OBJECT_STAGE",hItem)
    If not clsRoot is Nothing Then
      ClsName = clsRoot.SysName & "_NO"
      If clsRoot.Classifiers.Has(ClsName) Then
        Set Clf = clsRoot.Classifiers(ClsName)
        If not Clf is Nothing Then
          For Each Row in GridRows
            If Row.Attributes(0).Value = "ATTR_PROJECT_DOCS_SECTION" Then
              Row.Attributes(1).Value = Clf.Description
              Row.Attributes(3).Value = Clf.SysName
              Exit For
            End If
          Next
        End If
      End If
    End If
  End If
  
  Grid.DataSource = GridRows
  Grid.ColumnAutosize = True
  If Grid.ColumnCount = 4 Then
    Grid.RemoveColumn Grid.ColumnCount-1
    Grid.RemoveColumn Grid.ColumnCount-1
  End If
  Grid.InsertMode = False
  Grid.Redraw
End Sub

'=============================================================================================================
'Процедура сохранения значений атрибутов во внутреннюю таблицу
Sub AttrsSave()
  Set Tree = ThisForm.Controls("STAGETREE").ActiveX
  Set GridRows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL2").Rows
  Set Rows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
  Set StructRows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_TBL").Rows
  If GridRows.Count = 0 Then Exit Sub
  hItem = ThisForm.Controls("HITEM").Value
  If hItem = "" or hItem = Cstr(Tree.RootItem) Then Exit Sub
  
  'Получаем ссылку на строку
  Set Row = Nothing
  For Each Row0 in Rows
    If Row0.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = hItem Then
      Set Row = Row0
      Exit For
    End If
  Next
  If Row is Nothing Then
    Set Row = AttrsRowCreate(Rows,hItem)
    If Row is Nothing Then Exit Sub
  End If
  
  'Копируем описание объекта в таблицу структуры
  For Each Row0 in StructRows
    If Row0.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = hItem Then
      ItemName = Tree.GetItemText(hItem)
      If Row0.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJNAME").Value <> ItemName Then
        Row0.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJNAME").Value = ItemName
      End If
    End If
  Next
  
  'Копируем значения атрибутов в таблицу атрибутов
  Str = ""
  For Each GridRow in GridRows
    AttrName = GridRow.Attributes("ATTR_CODE").Value
    AttrValue = GridRow.Attributes("ATTR_VALUE").Value
    AttrSysName = GridRow.Attributes("ATTR_FILE_NAME").Value
    If AttrName <> "" Then
      If Row.Attributes.Has(AttrName) Then
        If Row.Attributes(AttrName).Value <> AttrValue Then
          If Row.Attributes(AttrName).Value = "NOTHING" and AttrValue = "" Then
          
          ElseIf StrComp(Row.Attributes(AttrName).Value,"Структура проектной документации",vbTextCompare) = 0 and AttrValue = "" Then
            
          Else
            Check = False
            Select Case AttrName
              'Раздел документации
              Case "ATTR_PROJECT_DOCS_SECTION"
                If AttrSysName <> "" Then
                  Set Clf = ThisApplication.Classifiers.FindBySysId(AttrSysName)
                  If not Clf is Nothing Then
                    Row.Attributes(AttrName).Classifier = Clf
                    Check = True
                  End If
                End If
                
              'Ответственный
              Case "ATTR_RESPONSIBLE"
                If AttrSysName <> "" Then
                  If ThisApplication.Users.Has(AttrSysName) Then
                    Row.Attributes(AttrName).User = ThisApplication.Users(AttrSysName)
                    Check = True
                  End If
                End If
                
              'Код подобъекта
              Case "ATTR_BUILDING_TYPE"
                If AttrSysName <> "" Then
                  Set Clf = ThisApplication.Classifiers.FindBySysId(AttrSysName)
                  If not Clf is Nothing Then
                    Row.Attributes(AttrName).Classifier = Clf
                    Check = True
                  End If
                End If
                
              'Тип полного комплекта
              Case "ATTR_WORK_DOCS_FOR_BUILDING_TYPE"
                If AttrSysName <> "" Then
                  Set Clf = ThisApplication.Classifiers.FindBySysId(AttrSysName)
                  If not Clf is Nothing Then
                    Row.Attributes(AttrName).Classifier = Clf
                    Check = True
                  End If
                End If
                
              'Этап строительства
              Case "ATTR_BUILDING_STAGE"
                If AttrSysName <> "" Then
                  Set SelObj = ThisApplication.GetObjectByGUID(AttrSysName)
                  If not SelObj is Nothing Then
                    Row.Attributes(AttrName).Object = SelObj
                    Check = True
                  End If
                End If
                
              Case Else
                Row.Attributes(AttrName).Value = AttrValue
                Check = True
            End Select
            If Check = True Then
              If Str <> "" Then
                Str = Str & "," & AttrName
              Else
                Str = AttrName
              End If
            End If
          End If
        End If
      End If
    End If
  Next
  If Str <> "" Then
    On Error Resume Next
    Set Row0 = Tree.GetItemData(hItem)
    ChangeStr = Row0.Attributes("ATTR_PROJECT_STRUCT_TBL_CHANGE").Value
    Check = True
    If ChangeStr <> "" Then
      Arr0 = Split(ChangeStr,",")
      Arr1 = Split(Str,",")
      If Ubound(Arr0) > Ubound(Arr1) Then Check = False
    End If
    If Check = True Then
      Row0.Attributes("ATTR_PROJECT_STRUCT_TBL_CHANGE").Value = Str
      ThisObject.Attributes("ATTR_STAGE_PROJECT_STRUCT_PUBLIC").Value = False
      Call ButtonsEnable0(ThisForm,ThisObject)
    End If
    On Error GoTo 0
  End If
  
  'Обязательные атрибуты заполняем стандартными значениями
  If Row.Attributes("ATTR_WORK_DOCS_FOR_BUILDING_NAME").Empty Then
    Row.Attributes("ATTR_WORK_DOCS_FOR_BUILDING_NAME").Value = "NOTHING"
  End If
  If Row.Attributes("ATTR_VOLUME_NAME").Empty Then
    Row.Attributes("ATTR_VOLUME_NAME").Value = "NOTHING"
  End If
  If Row.Attributes("ATTR_PROJECT_DOCS_SECTION").Empty Then
    Set Clf0 = ThisApplication.Classifiers.FindBySysId("NODE_PROJECT_STRUCT")
    Row.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier = Clf0
  End If
  
End Sub

'=============================================================================================================
'Функция получения значения атрибута из внутренней таблицы
Function AttrValueGet(hItem,AttrName)
  AttrValueGet = ""
  Set Rows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
  For Each Row in Rows
    If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = hItem Then
      If Row.Attributes.Has(AttrName) Then
        Val = Row.Attributes(AttrName).Value
        If Val <> "NOTHING" and StrComp(Val,"Структура проектной документации",vbTextCompare) <> 0 Then
          AttrValueGet = Row.Attributes(AttrName).Value
          Exit Function
        End If
      End If
    End If
  Next
End Function

'=============================================================================================================
'Функция создания строки атрибутов
Private Function AttrsRowCreate(AttrsRows,hItem)
  Set AttrsRowCreate = Nothing
  Check = False
  For Each AttrRow in AttrsRows
    If AttrRow.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = hItem Then
      Set AttrsRowCreate = AttrRow
      Exit Function
    End If
  Next
  If Check = False Then
    Set AttrRow = AttrsRows.Create
    AttrRow.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = hItem
    AttrRow.Attributes("ATTR_WORK_DOCS_FOR_BUILDING_NAME").Value = "NOTHING"
    AttrRow.Attributes("ATTR_VOLUME_NAME").Value = "NOTHING"
    Set Clf0 = ThisApplication.Classifiers.FindBySysId("NODE_PROJECT_STRUCT")
    AttrRow.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier = Clf0
    Set AttrsRowCreate = AttrRow
  End If
End Function

'=============================================================================================================
'Процедура обновления идентификаторов в таблицах
Sub RowsUpdate(hItem,hItemOld,Rows)
  Attr1 = "ATTR_PROJECT_STRUCT_TBL_HITEM"
  Attr2 = "ATTR_PROJECT_STRUCT_TBL_PARENT"
  If hItemOld = 0 Then
    For Each Row in Rows
      If Row.Attributes(Attr2).Value = 0 Then
        hItemOld = Row.Attributes(Attr1).Value
        Exit For
      End If
    Next
  End If
  If hItemOld <> 0 Then
    For Each Row in Rows
      If Row.Attributes(Attr1).Value = hItemOld Then Row.Attributes(Attr1).Value = hItem
      If Row.Attributes.Has(Attr2) Then
        If Row.Attributes(Attr2).Value = hItemOld Then Row.Attributes(Attr2).Value = hItem
      End If
    Next
  End If
End Sub

'=============================================================================================================
'Событие - Смена выделения в таблице атрибутов
Sub ATTRSGRID_SelChanged()
  Call AttrValueSelect(ThisForm,ThisObject)
End Sub

'=============================================================================================================
'Процедура выбора значения атрибута
Sub AttrValueSelect(Form,Obj)
  ThisScript.SysAdminModeOn
  Set Grid = Form.Controls("ATTRSGRID").ActiveX
  Set Tree = ThisForm.Controls("STAGETREE").ActiveX
  Set Rows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL2").Rows
  nRow = Grid.SelectedRow
  nCol = Grid.SelectedColumn
  hItem = Tree.SelectedItem
  Set Row = Tree.GetItemData(hItem)
  ObjType = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJTYPE").Value
  Set AttrRow = Grid.RowValue(nRow)
  If AttrRow is Nothing Then Exit Sub
  If nCol = 0 Then Exit Sub
  
  AttrName = AttrRow.Attributes("ATTR_CODE").Value
  Select Case AttrName
    'Раздел документации
    Case "ATTR_PROJECT_DOCS_SECTION"
    '  AttrName = "ATTR_PROJECT_DOCS_SECTION"
    '  If ThisApplication.AttributeDefs.Has(AttrName) Then
    '    Set Attr = ThisApplication.AttributeDefs(AttrName)
    '    If not Attr.Classifier is Nothing Then
    '      Set Dlg = ThisApplication.Dialogs.SelectClassifierDlg
    '      Dlg.Root = Attr.Classifier
    '      Dlg.Caption = "Выбор классификатора"
    '      If Dlg.Show Then
    '        If not Dlg.Classifier is Nothing Then
    '          AttrRow.Attributes("ATTR_VALUE").Value = Dlg.Classifier.Description
    '          AttrRow.Attributes("ATTR_FILE_NAME").Value = Dlg.Classifier.SysName
    '          oName = GetSectionName(1,Nothing)
    '          Tree.SetItemText hItem, oName
    '        End If
    '      End If
    '    End If
    '  End If
    
    'Ответственный
    Case "ATTR_RESPONSIBLE"
      AttrName = "ATTR_RESPONSIBLE"
      If ThisApplication.AttributeDefs.Has(AttrName) Then
        Set Attr = ThisApplication.AttributeDefs(AttrName)
          Set Dlg = ThisApplication.Dialogs.SelectUserDlg
          Dlg.SelectFromUsers = ThisApplication.Groups("ALL_USERS").Users
          Dlg.Caption = "Выбор ответственного"
          If Dlg.Show Then
            If Dlg.Users.Count > 0 Then
              AttrRow.Attributes("ATTR_VALUE").Value = Dlg.Users(0).Description
              AttrRow.Attributes("ATTR_FILE_NAME").Value = Dlg.Users(0).SysName
            End If
          End If
      End If
      
    'Код подобъекта
    Case "ATTR_BUILDING_TYPE"
      AttrName = "ATTR_BUILDING_TYPE"
      If ThisApplication.AttributeDefs.Has(AttrName) Then
        Set Attr = ThisApplication.AttributeDefs(AttrName)
        If not Attr.Classifier is Nothing Then
          Set Dlg = ThisApplication.Dialogs.SelectClassifierDlg
          Dlg.Root = Attr.Classifier
          Dlg.Caption = "Выбор классификатора"
          If Dlg.Show Then
            If not Dlg.Classifier is Nothing Then
              AttrRow.Attributes("ATTR_VALUE").Value = Dlg.Classifier.Description
              AttrRow.Attributes("ATTR_FILE_NAME").Value = Dlg.Classifier.SysName
              For i = 0 to Rows.Count-1
                If Rows(i).Attributes("ATTR_CODE").Value = "ATTR_WORK_DOCS_FOR_BUILDING_NAME" Then
                  Rows(i).Attributes("ATTR_VALUE").Value = Dlg.Classifier.Description
                  Grid.UpdateRow i
                  Exit For
                End If
              Next
              oName = GetWorkDocsName(Rows)
              Tree.SetItemText hItem, oName
            End If
          End If
        End If
      End If
      
    'Тип полного комплекта
    Case "ATTR_WORK_DOCS_FOR_BUILDING_TYPE"
      AttrName = "ATTR_WORK_DOCS_FOR_BUILDING_TYPE"
      If ThisApplication.AttributeDefs.Has(AttrName) Then
        Set Attr = ThisApplication.AttributeDefs(AttrName)
        If not Attr.Classifier is Nothing Then
          Set Dlg = ThisApplication.Dialogs.SelectClassifierDlg
          Dlg.Root = Attr.Classifier
          Dlg.Caption = "Выбор классификатора"
          If Dlg.Show Then
            If not Dlg.Classifier is Nothing Then
              AttrRow.Attributes("ATTR_VALUE").Value = Dlg.Classifier.Description
              AttrRow.Attributes("ATTR_FILE_NAME").Value = Dlg.Classifier.SysName
            End If
          End If
        End If
      End If
      
    'Этап строительства
    Case "ATTR_BUILDING_STAGE"
      AttrName = "ATTR_PROJECT"
      Set oProj = Nothing
      If Obj.Attributes.Has(AttrName) Then
        If Obj.Attributes(AttrName).Empty = False Then
          If not Obj.Attributes(AttrName).Object is Nothing Then
            Set oProj = Obj.Attributes(AttrName).Object
          End If
        End If
      End If
      If not oProj is Nothing Then
        Set q = ThisApplication.CreateQuery
        q.Permissions = sysadminpermissions
        q.AddCondition tdmQueryConditionObjectDef, "OBJECT_BUILD_STAGE"
        q.AddCondition tdmQueryConditionAttribute, oProj, "ATTR_PROJECT"
        Set Objects = q.Objects
        If Objects.Count > 0 Then
          Set Dlg = ThisApplication.Dialogs.SelectObjectDlg
          Dlg.SelectFromObjects = Objects
          Dlg.Caption = "Выбор этапа строительства"
          If Dlg.Show Then
            If Dlg.Objects.Count > 0 Then
              Set SelObj = Dlg.Objects(0)
              AttrRow.Attributes("ATTR_VALUE").Value = SelObj.Description
              AttrRow.Attributes("ATTR_FILE_NAME").Value = SelObj.GUID
            End If
          End If
        End If
      End If
      
  End Select
  
  Grid.UpdateRow nRow
End Sub

'=============================================================================================================
'Функция формирования имени Раздела
Function GetSectionName(Source,Row)
  GetSectionName = "Раздел"
  Set Clf = Nothing
  ClfCode = ""
  
  'Создание разделов
  If Source = 0 Then
    If not Row is Nothing Then
      If Row.Attributes("ATTR_PROJECT_DOCS_SECTION").Empty = False Then
        If not Row.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier is Nothing Then
          Set Clf = Row.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier
          If Trim(Clf.Code) = "-" or Trim(Clf.Code) = "" Then
            ClfCode = Clf.Description
          Else
            ClfCode = Clf.Code
          End If
        End If
      End If
    End If
  'Изменение имени из таблицы атрибутов
  ElseIf Source = 1 Then
    Set Rows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL2").Rows
    ClfCode = Row
    For Each Row0 in Rows
      If Row0.Attributes("ATTR_CODE").Value = "ATTR_PROJECT_DOCS_SECTION" Then
        ClfName = Row0.Attributes("ATTR_FILE_NAME").Value
        If ClfName <> "" Then
          Set Clf = ThisApplication.Classifiers.FindBySysId(ClfName)
        End If
      End If
    Next
  End If
  
  If not Clf is Nothing Then
    Num = Clf.SysName
    Code = Right(Num, Len(Num)-InStrRev(Num, "_"))
    If StrComp(Clf.Description,"непроектный раздел",vbTextCompare) = 0 Then
      If ClfCode <> "" and ClfCode <> "-" Then
        GetSectionName = ClfCode
      Else
        GetSectionName = "Непроектный раздел"
      End If
    Else
      GetSectionName = Code & " " & ClfCode
    End If
  End If
End Function

'=============================================================================================================
'Функция формирования имени Полного комплекта
Function GetWorkDocsName(Rows)
  GetWorkDocsName = "Полный комплект"
  Set Project = ThisApplication.ExecuteScript("CMD_S_NUMBERING","ObjectLinkGet",ThisObject,"ATTR_PROJECT")
  If Project is Nothing Then Exit Function
  
  Code = ""
  'Код проекта
  Code = Project.Attributes("ATTR_PROJECT_CODE").Value
  'Код подобъекта
  Set Clf = Nothing
  For Each Row in Rows
    If Row.Attributes("ATTR_CODE").Value = "ATTR_BUILDING_TYPE" Then
      ClfName = Row.Attributes("ATTR_FILE_NAME").Value
      If ClfName <> "" Then
        Set Clf = ThisApplication.Classifiers.FindBySysId(ClfName)
        Exit For
      End If
    End If
  Next
  If not Clf is Nothing Then
    Num = Clf.Code
    If Num <> "" Then
      If Code <> "" Then
        Code = Code & "-" & Num
      Else
        Code = Num
      End If
    End If
  End If
  'Поз. по ГП
  Num = ""
  For Each Row in Rows
    If Row.Attributes("ATTR_CODE").Value = "ATTR_BUILDING_CODE" Then
      Num = Row.Attributes("ATTR_VALUE").Value
      Exit For
    End If
  Next
  If Num <> "" Then
    If Code <> "" Then
      Code = Code & "-" & Num
    Else
      Code = Num
    End If
  End If
  
  GetWorkDocsName = Code
End Function


'=============================================================================================================
'Функция формирования имени Тома
Private Function GetSectionCode(Rows,hItem)
  GetSectionCode = ""
  For Each Row in Rows
    If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = hItem Then
      If Row.Attributes("ATTR_PROJECT_DOCS_SECTION").Empty = False Then
        If not Row.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier is Nothing Then
          Num = Row.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier.SysName
          Num = Right(Num, Len(Num)-InStrRev(Num, "_"))
          If Num <> "NO" Then
            GetSectionCode = Num
            Exit For
          End If
        End If
      End If
    End If
  Next
End Function

'=============================================================================================================
'Функция формирования имени Тома
Function GetVolumeName(RowAttr,Rows,nRow,Val)
  'Том {ATTR_VOLUME_NUM} - {ATTR_VOLUME_NAME}
  GetVolumeName = "Том"
  Code = ""
  'Номер раздела
  Set Tree = ThisForm.Controls("STAGETREE").ActiveX
  Set AttrsRows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
  hItem = Tree.SelectedItem
  pItem = Cstr(Tree.GetParentItem(hItem))
  Code = GetSectionCode(AttrsRows,pItem)
  
  'Номер части
  Num = ""
  If RowAttr is Nothing Then
    For i = 0 to Rows.Count-1
      If Rows(i).Attributes("ATTR_CODE").Value = "ATTR_VOLUME_PART_NUM" Then
        If i <> nRow Then
          Num = Rows(i).Attributes("ATTR_VALUE").Value
        Else
          Num = Val
        End If
        Exit For
      End If
    Next
  Else
    Num = RowAttr.Attributes("ATTR_VOLUME_PART_NUM").Value
  End If
  If Num <> "" Then
    If Code <> "" Then
      Code = Code & "." & Num
    Else
      Code = Num
    End If
  End If
  
  'Номер книги
  Num = ""
  If RowAttr is Nothing Then
    For i = 0 to Rows.Count-1
      If Rows(i).Attributes("ATTR_CODE").Value = "ATTR_BOOK_NUM" Then
        If i <> nRow Then
          Num = Rows(i).Attributes("ATTR_VALUE").Value
        Else
          Num = Val
        End If
        Exit For
      End If
    Next
  Else
    Num = RowAttr.Attributes("ATTR_BOOK_NUM").Value
  End If
  If Num <> "" Then
    If Code <> "" Then
      Code = Code & "." & Num
    Else
      Code = Num
    End If
  End If
  
  'Наименование
  Num = ""
  If RowAttr is Nothing Then
    For i = 0 to Rows.Count-1
      If Rows(i).Attributes("ATTR_CODE").Value = "ATTR_VOLUME_NAME" Then
        If i <> nRow Then
          Num = Rows(i).Attributes("ATTR_VALUE").Value
        Else
          Num = Val
        End If
        Exit For
      End If
    Next
  Else
    Num = RowAttr.Attributes("ATTR_VOLUME_NAME").Value
  End If
  If Num <> "" Then
    If Code <> "" Then
      Code = Code & " - " & Num
    Else
      Code = Num
    End If
  End If
  
  GetVolumeName = Code
End Function

'=============================================================================================================
'Процедура добавления разделов в дерево
Sub AddSections(Stage,Tree,Rows,AttrsRows,hItem,Icon)
  Set AttrsRows = Stage.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
  
  ThisApplication.Utility.WaitCursor = True
  'Определение корневого классификатора
  Set Row = Tree.GetItemData(hItem)
  ObjType = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJTYPE").Value
  Set Cls = GetRootClf(Stage,ObjType,hItem)
  If Cls Is Nothing Then
    ThisApplication.Utility.WaitCursor = False
    Msgbox "Структура проекта не найдена!",vbCritical,"Ошибка"
    Exit Sub
  End If
  
  'Формирование списка классификаторов
  Start = True
  Check0 = False
  Dim Arr()
  For Each Cls0 in Cls.Classifiers
    Check = True
    If Cls0.SysName <> Cls.SysName & "_NO" Then
      For Each Row in Rows
        If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_PARENT").Value = Cstr(hItem) Then
          If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJTYPE").Value = "OBJECT_PROJECT_SECTION" or _
          Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJTYPE").Value = "OBJECT_PROJECT_SECTION_SUBSECTION" Then
            hItem0 = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value
            For Each Row0 in AttrsRows
              If Row0.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = hItem0 Then
                If Row0.Attributes("ATTR_PROJECT_DOCS_SECTION").Empty = False Then
                  If not Row0.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier is Nothing Then
                    If Row0.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier.SysName = Cls0.SysName Then
                      Check = False
                      Exit For
                    End If
                  End If
                End If
              End If
            Next
          End If
        End If
        If Check = False Then Exit For
      Next
    End If
    If Check = True Then
      If Start = True Then
        i = -1
        Start = False
      Else
        i = Ubound(Arr)
      End If
      ReDim Preserve Arr(i+1)
      Set Arr(Ubound(Arr)) = Cls0
      Check0 = True
    End If
  Next
  ThisApplication.Utility.WaitCursor = False
  
  
  If Check0 = False Then
    Msgbox "Нет доступных для добавления элементов.",vbInformation
    Exit Sub
  End If
  
  'Определение типа создаваемого объекта
  NewObjType = "OBJECT_PROJECT_SECTION"
  If ObjType <> "" Then
    If ObjType = "OBJECT_PROJECT_SECTION" Then
      NewObjType = "OBJECT_PROJECT_SECTION_SUBSECTION"
      Set Icon = ThisApplication.ObjectDefs(NewObjType).Icon
    End If
  End If
  
  'Диалоговое окно
  Set SelDlg = ThisApplication.Dialogs.SelectDlg
  SelDlg.UseCheckBoxes = True
  SelDlg.SelectFrom = Arr
  If SelDlg.Show = False Then Exit Sub 
  
  'Создание разделов
  Count = Ubound(SelDlg.Objects)
  For Each Clf in SelDlg.Objects
    Set NewRow = Rows.Create
    NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_PARENT").Value = hItem
    NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJTYPE").Value = NewObjType
    Item1 =  Tree.InsertItem("Раздел", hItem, 1)
    Tree.SetItemIcon Item1 , Icon
    Tree.SetItemData Item1, NewRow
    NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = Item1
    Set AttrRow = AttrsRowCreate(AttrsRows,Item1)
    AttrRow.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier = Clf
    AttrRow.Attributes("ATTR_NAME").Value = Clf.Description
    AttrRow.Attributes("ATTR_CODE").Value = Clf.Code
    AttrRow.Attributes("ATTR_RESPONSIBLE").User = ThisApplication.CurrentUser
    SectionName = GetSectionName(0,AttrRow)
    NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJNAME").Value = SectionName
    NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_CHANGE").Value = GetAttrsList("OBJECT_PROJECT_SECTION")
    Stage.Attributes("ATTR_STAGE_PROJECT_STRUCT_PUBLIC").Value = False
    Call ButtonsEnable0(ThisForm,Stage)
    Tree.SetItemText Item1,SectionName
    If Count = 0 Then
      Tree.UpdateItem hItem, False
      Tree.SelectedItem = Item1
    ElseIf Count > 0 Then
      Tree.Expand Tree.RootItem
    End If
  Next
End Sub

'=============================================================================================================
'Процедура добавления тома в дерево
Sub AddVolume(Tree,Rows,AttrsRows,hItem,Icon3)
  'Определение родительского узла
  Set Row = Tree.GetItemData(hItem)
  If Row is Nothing Then Exit Sub
  hParent = -1
  AddType = "section"
  ItemType = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJTYPE").Value
  'Создание тома от раздела
  If ItemType = "OBJECT_PROJECT_SECTION" or ItemType = "OBJECT_PROJECT_SECTION_SUBSECTION" Then
    hParent = hItem
  'Создание тома от другого тома
  ElseIf ItemType = "OBJECT_VOLUME" Then
    hParent = Tree.GetParentItem(hItem)
    AddType = "volume"
  End If
  If hParent = -1 Then Exit Sub
  hChild = Tree.GetChildItem(hParent)
  PartNum = ""
  BookNum = ""
  SectionCode = ""
  MaxPartNum = -1
  oName = ""
  
  'Поиск названия раздела
  Set AttrsRows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
  SectionName = ""
  For Each pRow in AttrsRows
    If pRow.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = cStr(hParent) Then
      SectionName = pRow.Attributes("ATTR_NAME").Value
    End If
  Next
  SectionCode = GetSectionCode(AttrsRows,cStr(hParent))
  
  If hChild <> 0 Then
    'Создание виртуальной таблицы номеров томов
    TableArr = GetTableNumsVolumes(hParent)
    'Если до добавления был 1 том, то его атрибут Номер части = 1
    If Ubound(TableArr) = 0 Then
      StrhChild = cStr(hChild)
      'Изменения в таблице атрибутов
      For Each Row in AttrsRows
        If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM") = StrhChild Then
          Row.Attributes("ATTR_VOLUME_PART_NUM").Value = "1"
          PartNum = "2"
          oName = SectionCode & ".1" & " - " & Row.Attributes("ATTR_VOLUME_NAME").Value
          Tree.SetItemText hChild, oName
          Exit For
        End If
      Next
      'Изменения в таблице структуры
      For Each Row in Rows
        If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM") = StrhChild Then
          str = GetAttrsList("OBJECT_VOLUME")
          If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_CHANGE").Value <> str Then
            Row.Attributes("ATTR_PROJECT_STRUCT_TBL_CHANGE").Value = str
          End If
          If oName <> "" and Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJNAME").Value <> oName Then
            Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJNAME").Value = oName
          End If
        End If
      Next
    'Если до добавления было больше одного тома, то Номер части = максимальный + 1
    ElseIf Ubound(TableArr) > 0 Then
      'Если Том добавляет от раздела
      If AddType = "section" Then
        For i = 0 to Ubound(TableArr)
          TableCol = TableArr(i)
          If Ubound(TableCol) >= 0 Then
            If isNumeric(TableCol(0)) Then
              Val = cLng(TableCol(0))
              If Val > MaxPartNum Then MaxPartNum = Val
            End If
          End If
        Next
        If MaxPartNum <> -1 Then
          PartNum = cStr(MaxPartNum + 1)
        End If
      'Добавить Том от Тома
      ElseIf AddType = "volume" Then
        NumArr = GetNewVolumeCode("RIGHT",Tree,cStr(hItem))
        Call VolumeNumArrToParam(NumArr,SectionCode,PartNum,BookNum,True)
      End If
    End If
  End If
  
  'Определение имени элемента
  oName = SectionCode
  If PartNum <> "" Then oName = oName & "." & PartNum
  If BookNum <> "" Then oName = oName  & "."& BookNum
  oName = oName & " - " & SectionName
  
  'Создание элемента Том
  Set NewRow = Rows.Create
  NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_PARENT").Value = hParent
  NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJTYPE").Value = "OBJECT_VOLUME"
  NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJNAME").Value = oName
  Item1 =  Tree.InsertItem(oName, hParent, 1)
  Tree.SetItemIcon Item1 , Icon3
  Tree.SetItemData Item1, NewRow
  NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = Item1
  NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_CHANGE").Value = GetAttrsList("OBJECT_VOLUME")
  Set AttrRow = AttrsRowCreate(AttrsRows,Item1)
  AttrRow.Attributes("ATTR_RESPONSIBLE").User = ThisApplication.CurrentUser
  AttrRow.Attributes("ATTR_VOLUME_NAME").Value = SectionName
  AttrRow.Attributes("ATTR_VOLUME_PART_NUM").Value = PartNum
  AttrRow.Attributes("ATTR_BOOK_NUM").Value = BookNum
  Tree.UpdateItem hParent, False
  Tree.SortChildren(hParent)
  Tree.SelectedItem = Item1
End Sub

'=============================================================================================================
'Процедура добавления Полного комплекта в дерево
Sub AddWorkDocs(Tree,Rows,AttrsRows,hItem,Icon1)
  Set NewRow = Rows.Create
  NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_PARENT").Value = hItem
  NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJTYPE").Value = "OBJECT_WORK_DOCS_FOR_BUILDING"
  NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJNAME").Value = "Полный комплект"
  Item1 = Tree.InsertItem("Полный комплект", hItem, 1)
  Tree.SetItemIcon Item1 , Icon1
  Tree.SetItemData Item1, NewRow
  NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = Item1
  NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_CHANGE").Value = GetAttrsList("OBJECT_WORK_DOCS_FOR_BUILDING")
  Tree.UpdateItem hItem, False
  Tree.SelectedItem = Item1
End Sub

'=============================================================================================================
'Поиск корневого узла классификатора структуры проекта в зависимости от стадии и вида проектируемого объекта
Function GetRootClf(Stage,ObjType,hItem)
  Set GetRootClf = Nothing
  Select Case ObjType  'sysID типа объекта, внутри которого строим разделы\подразделы
    Case "OBJECT_STAGE"
      Set clsRoot = ThisApplication.Classifiers.FindBySysId("NODE_PROJECT_STRUCT").Classifiers
      StageClfSysID = Stage.Attributes("ATTR_PROJECT_STAGE").Classifier.SysName
      If Stage.Attributes("ATTR_SITE_TYPE_CLS").Empty = False Then
        ProjectTypeSysID = Stage.Attributes("ATTR_SITE_TYPE_CLS").Classifier.SysName
      Else
      ProjectTypeSysID = ""
      End If
      If ThisApplication.Attributes.Has("ATTR_STAGE_SETTINGS") = False Then Exit Function
      Set Rows0 = ThisApplication.Attributes("ATTR_STAGE_SETTINGS").Rows
      For Each Row0 In Rows0
        If Row0.Attributes(0).Empty = False Then
          If Not Row0.Attributes(0).Classifier is Nothing Then
            If Row0.Attributes(0).Classifier.SysName = StageClfSysID Then 
              If Row0.Attributes(1).Classifier Is Nothing Then
                If Row0.Attributes(2).Empty = False Then
                  If not Row0.Attributes(2).Classifier is Nothing Then
                    Set GetRootClf = Row0.Attributes(2).Classifier
                    Exit Function
                  End If
                End If
              Else
                If Row0.Attributes(1).Classifier.SysName = ProjectTypeSysID Then
                  If Row0.Attributes(2).Empty = False Then
                    If not Row0.Attributes(2).Classifier is Nothing Then
                      Set GetRootClf = Row0.Attributes(2).Classifier
                      Exit Function
                    End If
                  End If
                End If
              End If
            End If
          End If
        End If
      Next
          
    Case "OBJECT_PROJECT_SECTION"
      Set AttrsRows = Stage.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
      For Each Row in AttrsRows
        If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = cStr(hItem) Then
          If Row.Attributes("ATTR_PROJECT_DOCS_SECTION").Empty = False Then
            If not Row.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier is Nothing Then
              Set GetRootClf = Row.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier
              Exit Function
            End If
          End If
        End If
      Next
      
  End Select

  'Set GetRootClf = clsRoot.FindBySysId(cls.SysName)
End Function

'=============================================================================================================
'Функция проверки заполненности атрибутов Стадии
Function StageCheckAttrs(Obj,AttrName)
  StageCheckAttrs = ""
  Check = True
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty Then
      Check = False
    End If
  Else
    Check = False
  End If
  If Check = False Then
    StageCheckAttrs = Thisapplication.AttributeDefs(AttrName).Description
  End If
End Function

'=============================================================================================================
'Кнопка - Редактирование структуры
Sub BUTTON_STRUCTURE_EDIT_OnClick()
  ThisScript.SysAdminModeOn
  
  ThisObject.Attributes("ATTR_ORIGINAL_STATUS_NAME").Value = ThisObject.StatusName
  
  'Смена статуса
  StatusName = "STATUS_STAGE_EDIT"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",ThisObject,ThisObject.Status,ThisObject,StatusName)
  If RetVal = -1 Then
    ThisObject.Status = ThisApplication.Statuses(StatusName)
  End If
  
  'Создание роли "Редактирование структуры"
  Set CU = ThisApplication.CurrentUser
  Set Roles = ThisObject.RolesForUser(CU)
  RoleName = "ROLE_PROJECT_STRUCTURE_EDIT"
  If Roles.Has(RoleName) = False Then
    Call ThisApplication.ExecuteScript("CMD_DLL", "SetRole",ThisObject,RoleName,CU)
  End If
  
  'Создание версии
  ThisObject.Versions.Create ,"Редактирование структуры"
  
  ThisObject.Update
  ThisScript.SysAdminModeOff
End Sub

'=============================================================================================================
'Кнопка - Закончить редактирование структуры
Sub BUTTON_FINISH_OnClick()
  ThisScript.SysAdminModeOn
  
  StatusName = ThisObject.Attributes("ATTR_ORIGINAL_STATUS_NAME").Value
  If ThisObject.ObjectDef.Statuses.Has(StatusName) Then
    'Смена статуса
    RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",ThisObject,ThisObject.Status,ThisObject,StatusName)
    If RetVal = -1 Then
      ThisObject.Status = ThisApplication.Statuses(StatusName)
    End If
    
    'Удаление роли
    For Each Role in ThisObject.Roles
      If Role.RoleDefName = "ROLE_PROJECT_STRUCTURE_EDIT" Then
        ThisObject.Roles.Remove Role
      End If
    Next
    ThisObject.Update
  End If
  
  ThisScript.SysAdminModeOff
End Sub

'=============================================================================================================
'Процедура управления доступностью кнопок на форме
Sub ButtonsEnable0(Form,Obj)
  'Проверка ролей и статуса
  Set Roles = Obj.RolesForUser(ThisApplication.CurrentUser)
  Check = False
  If Obj.StatusName <> "STATUS_STAGE_EDIT" Then
    If Roles.Has("ROLE_GIP") or Roles.Has("ROLE_PROJECT_STRUCTURE_EDIT") Then
      Form.Controls("BUTTON_STRUCTURE_EDIT").Enabled = True
    Else
      Form.Controls("BUTTON_STRUCTURE_EDIT").Enabled = False
    End If
  ElseIf Roles.Has("ROLE_PROJECT_STRUCTURE_EDIT") Then
    Check = True
  End If
  
  Check0 = BtnCopyStructEnabled(Obj)
  Form.Controls("BUTTON_COPY").Visible = Check0
  Form.Controls("BUTTON_COPY").Enabled = Check0
  
  Form.Controls("STAGETREE").Enabled = Check
  If Check = True Then
    If Obj.Attributes("ATTR_STAGE_PROJECT_STRUCT_PUBLIC").Value = True Then
      Form.Controls("BUTTON_STRUCT_BACK").Enabled = False
      Form.Controls("BUTTON_PUBLIC").Enabled = False
      Form.Controls("PUBLIC").Value = "опубликована"
      'Form.Controls("BUTTON_FINISH").Enabled = True
    Else
      Form.Controls("BUTTON_STRUCT_BACK").Enabled = Check
      Form.Controls("BUTTON_PUBLIC").Enabled = Check
      Form.Controls("PUBLIC").Value = "не опубликована"
      'Form.Controls("BUTTON_FINISH").Enabled = False
    End If
    If Obj.Objects.Count > 0 Then
      Form.Controls("BUTTON_STRUCT_FILL").Enabled = True
    Else
      Form.Controls("BUTTON_STRUCT_FILL").Enabled = False
    End If
  End If
End Sub

'=============================================================================================================
'Процедура управления доступностью кнопок редактирования дерева на форме
Sub ButtonsEnable1(Form,Obj)
  If Form.Controls("STAGETREE").Enabled = True Then
    StageName = Obj.Attributes("ATTR_PROJECT_STAGE").Classifier.SysName
    Set Tree = Form.Controls("STAGETREE").ActiveX
    hItem = Tree.SelectedItem
    If hItem <> 0 Then
      Set Row = Tree.GetItemData(Tree.SelectedItem)
      ItemType = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJTYPE").Value
      If StageName <> "NODE_PROJECT_STAGE_W" Then
        Form.Controls("BUTTON_VOLUME_ADD").Visible = True
        Form.Controls("BUTTON_SECTION_ADD").Visible = True
        If ItemType = "OBJECT_STAGE" Then
          Form.Controls("BUTTON_SECTION_ADD").Enabled = True
          Form.Controls("BUTTON_VOLUME_ADD").Enabled = False
          Form.Controls("BUTTON_ITEM_DEL").Enabled = False
        ElseIf ItemType = "OBJECT_PROJECT_SECTION" Then
          Form.Controls("BUTTON_SECTION_ADD").Enabled = True
          Form.Controls("BUTTON_VOLUME_ADD").Enabled = True
          Form.Controls("BUTTON_ITEM_DEL").Enabled = True
        ElseIf ItemType = "OBJECT_PROJECT_SECTION_SUBSECTION" Then
          Form.Controls("BUTTON_SECTION_ADD").Enabled = False
          Form.Controls("BUTTON_VOLUME_ADD").Enabled = True
          Form.Controls("BUTTON_ITEM_DEL").Enabled = True
        ElseIf ItemType = "OBJECT_VOLUME" Then
          Form.Controls("BUTTON_SECTION_ADD").Enabled = False
          Form.Controls("BUTTON_VOLUME_ADD").Enabled = True
          Form.Controls("BUTTON_ITEM_DEL").Enabled = True
        End If
      Else
        'Включаем кнопку добавления Полного комплекта
        Form.Controls("BUTTON_WORKDOCS_ADD").Enabled = True
        Form.Controls("BUTTON_WORKDOCS_ADD").Visible = True
        Form.Controls("BUTTON_VOLUME_ADD").Visible = False
        Form.Controls("BUTTON_SECTION_ADD").Visible = False
        If ItemType = "OBJECT_STAGE" Then
          Form.Controls("BUTTON_ITEM_DEL").Enabled = False
        Else
          Form.Controls("BUTTON_ITEM_DEL").Enabled = True
        End If
      End If
    End If
  Else
    Form.Controls("BUTTON_WORKDOCS_ADD").Enabled = False
    Form.Controls("BUTTON_VOLUME_ADD").Enabled = False
    Form.Controls("BUTTON_SECTION_ADD").Enabled = False
    Form.Controls("BUTTON_ITEM_DEL").Enabled = False
  End If
End Sub

'=============================================================================================================
'Кнопка - Добавить Разделы (Подразделы)
Sub BUTTON_SECTION_ADD_OnClick()
  Set Tree = ThisForm.Controls("STAGETREE").ActiveX
  Set Rows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_TBL").Rows
  Set AttrsRows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
  hItem = Tree.SelectedItem
  If ThisApplication.ObjectDefs.Has("OBJECT_PROJECT_SECTION") Then
    Set Icon2 = ThisApplication.ObjectDefs("OBJECT_PROJECT_SECTION").Icon
  Else
    Msgbox "В системе отсутствует тип объекта ""Раздел""",vbExclamation
    Exit Sub
  End If
  Call AddSections(ThisObject,Tree,Rows,AttrsRows,hItem,Icon2)
  Tree.UpdateItem hItem, False
  Tree.Expand hItem
  ThisObject.Attributes("ATTR_STAGE_PROJECT_STRUCT_PUBLIC").Value = False
  Call ButtonsEnable0(ThisForm,ThisObject)
End Sub

'=============================================================================================================
'Кнопка - Добавить Разделы (Подразделы)
Sub BUTTON_VOLUME_ADD_OnClick()
  Set Tree = ThisForm.Controls("STAGETREE").ActiveX
  Set Rows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_TBL").Rows
  Set AttrsRows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
  hItem = Tree.SelectedItem
  If ThisApplication.ObjectDefs.Has("OBJECT_VOLUME") Then
    Set Icon = ThisApplication.ObjectDefs("OBJECT_VOLUME").Icon
  Else
    Msgbox "В системе отсутствует тип объекта ""Том""",vbExclamation
    Exit Sub
  End If
  Call AddVolume(Tree,Rows,AttrsRows,hItem,Icon)
  ThisObject.Attributes("ATTR_STAGE_PROJECT_STRUCT_PUBLIC").Value = False
  Call ButtonsEnable0(ThisForm,ThisObject)
  'Tree.UpdateItem hItem, False
End Sub

'=============================================================================================================
'Кнопка - Добавить Полный комплект
Sub BUTTON_WORKDOCS_ADD_OnClick()
  Set Tree = ThisForm.Controls("STAGETREE").ActiveX
  Set Rows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_TBL").Rows
  Set AttrsRows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
  hItem = Tree.SelectedItem
  If ThisApplication.ObjectDefs.Has("OBJECT_WORK_DOCS_FOR_BUILDING") Then
    Set Icon = ThisApplication.ObjectDefs("OBJECT_WORK_DOCS_FOR_BUILDING").Icon
  Else
    Msgbox "В системе отсутствует тип объекта ""Полный комплект""",vbExclamation
    Exit Sub
  End If
  Call AddWorkDocs(Tree,Rows,AttrsRows,hItem,Icon)
  ThisObject.Attributes("ATTR_STAGE_PROJECT_STRUCT_PUBLIC").Value = False
  Call ButtonsEnable0(ThisForm,ThisObject)
  'Tree.UpdateItem hItem, False
End Sub

'=============================================================================================================
'Кнопка - Сформировать существующую структуру
Sub BUTTON_STRUCT_FILL_OnClick()
  ThisScript.SysAdminModeOn
  Key = Msgbox("Формирование структуры заменит структуру проекта на этой форме на новую." &_
  chr(10) & "Продолжить?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
  Set Tree = ThisForm.Controls("STAGETREE").ActiveX
  Set Grid = ThisForm.Controls("ATTRSGRID").ActiveX
  Set StructRows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_TBL").Rows
  Set AttrsRows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
  Set TableRows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL2").Rows
  Set Progress = ThisApplication.Dialogs.ProgressDlg
  Stp = 0
  Stp0 = 0
  Count = ThisObject.ContentAll.Count
  If Count > 0 Then Stp = 100 / Count
  
  ThisApplication.Utility.WaitCursor = True
  
  'Очистка данных
  StructRows.RemoveAll
  AttrsRows.RemoveAll
  TableRows.RemoveAll
  Grid.RemoveAllRows
  Grid.Redraw
  Tree.DeleteAllItems
  ThisForm.Controls("ITEMNAME").Value = ""
  
  'Создание корневого узла
  Progress.Start
  Progress.Text = "Создание корневого узла"
  Root = Tree.InsertItem(ThisObject.Description, 0, 1)
  Tree.SetItemIcon Root , ThisObject.Icon
  SelectedItem = 0
  Set NewRow = StructRows.Create
  NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_PARENT").Value = "0"
  NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJTYPE").Value = ThisObject.ObjectDefName
  NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJNAME").Value = ThisObject.Description
  NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJGUID").Value = ThisObject.GUID
  NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = Root
  Tree.SetItemData Root, NewRow
  
  'Формирование дерева из существующих объектов
  Progress.Text = "Формирование структуры проекта"
  Call TreeNowFill(Tree,Grid,StructRows,AttrsRows,ThisObject,Root,Progress,Stp,Stp0)
  Tree.UpdateItem Root, True
  Tree.Expand Root
  Tree.SelectedItem = Root
  
  ThisObject.Attributes("ATTR_STAGE_PROJECT_STRUCT_PUBLIC").Value = True
  Call ButtonsEnable0(ThisForm,ThisObject)
  
  Progress.Stop
  ThisApplication.Utility.WaitCursor = False
  ThisScript.SysAdminModeOff
End Sub

'=============================================================================================================
'Кнопка - Отменить все изменения
Sub BUTTON_STRUCT_BACK_OnClick()
  ThisScript.SysAdminModeOn
  Set Versions = ThisObject.Versions
  If Versions.Count < 2 Then Exit Sub
  Key = Msgbox("Отменить все изменения?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
  Set Ver = Versions.Item(Versions.Count-1)
  newVersion = Ver.Versions.Create(,"Отмена изменений")
  ThisObject.Update
  ThisObject.Attributes("ATTR_STAGE_PROJECT_STRUCT_PUBLIC").Value = True
  Call ButtonsEnable0(ThisForm,ThisObject)
  
  ThisScript.SysAdminModeOff
End Sub

'=============================================================================================================
'Кнопка - Опубликовать структуру
Sub BUTTON_PUBLIC_OnClick()
  ThisScript.SysAdminModeOn
  Set StructRows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_TBL").Rows
  Set AttrsRows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
  Set Progress = ThisApplication.Dialogs.ProgressDlg
  ThisApplication.Utility.WaitCursor = True
  Stp = 0
  Stp0 = 0
  Count = 0
  For Each Row in StructRows
    If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJGUID").Empty = False and _
    Row.Attributes("ATTR_PROJECT_STRUCT_TBL_CHANGE").Empty = False Then Count = Count + 1
  Next
  If Count > 0 Then Stp = 100 / Count
  Call AttrsSave
  
  'Проверка блокировки объектов
  Str = ""
  For Each Row in StructRows
    If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJGUID").Empty = False and _
    Row.Attributes("ATTR_PROJECT_STRUCT_TBL_CHANGE").Empty = False Then
      Set Obj = ThisApplication.GetObjectByGUID(Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJGUID").Value)
      If not OBj is Nothing Then
        If Obj.Permissions.Locked = True Then
          If Str <> "" Then
            Str = Str & chr(10) & Obj.Description
          Else
            Str = Obj.Description
          End If
        End If
      End If
    End If
  Next
  If Str <> "" Then
    Msgbox "Сохранение невозможно." & chr(10) & "Следующие объекты заблокированы:" & chr(10) & Str, vbExclamation
    ThisApplication.Utility.WaitCursor = False
    Exit Sub
  End If
  
  'Обработка изменений
  Log1 = ""
  Progress.Start
  Progress.Text = "Публикация структуры"
  For Each Row in StructRows
    Set Obj = GetObjLink(StructRows,Row)
    If not Obj is Nothing Then
      If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_CHANGE").Empty = False Then
        ChangeList = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_CHANGE").Value
        If ChangeList <> "" Then
          Row.Attributes("ATTR_PROJECT_STRUCT_TBL_CHANGE").Value = ""
          Arr = Split(ChangeList,",")
          Log0 = Obj.ObjectDef.Description & " - " & Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJNAME").Value & ":" & chr(10)
          hItem = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value
          If Obj is Nothing Then
            Log0 = Log0 & "  Ошибка получения ссылки на объект"
          Else
            'Копирование значений атрибутов
            For Each Row0 in AttrsRows
              If Row0.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = hItem Then
                Check = False
                If Row0.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJGUID").Empty Then
                  Row0.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJGUID").Value = Obj.Guid
                  Check = True
                  Log0 = Log0 & "Объект создан и заполнены его атрибуты" & chr(10)
                End If
                For i = 0 to Ubound(Arr)
                  AttrName = Arr(i)
                  If Row0.Attributes.Has(AttrName) and Obj.Attributes.Has(AttrName) Then
                    Set Attr0 = Row0.Attributes(AttrName)
                    Set Attr1 = Obj.Attributes(AttrName)
                    AttrDescr = ThisApplication.AttributeDefs(AttrName).Description
                    Call ThisApplication.ExecuteScript("CMD_DLL","AttrValueCopy",Attr0,Attr1)
                    If Check = False Then Log0 = Log0 & "Обновлено значение атрибута """ & AttrDescr & """" & chr(10)
                    Select Case AttrName
                      Case "ATTR_BUILDING_TYPE"
                        Obj.Attributes("ATTR_PROJECT_BASIC_CODE").Value = _
                          ThisApplication.ExecuteScript("CMD_S_NUMBERING", "WorkDocsBuildCodeGen",Obj)
                      Case "ATTR_PROJECT_DOCS_SECTION"
                        If Row0.Attributes(AttrName).Empty = False Then
                          If not Row0.Attributes(AttrName).Classifier is Nothing Then
                            Num = Row0.Attributes(AttrName).Classifier.SysName
                            Code = Right(Num, Len(Num)-InStrRev(Num, "_"))
                            If Code = "NO" Then Code = "-"
                            Obj.Attributes("ATTR_SECTION_NUM").Value = Code
                          End If
                        End If
                        
                    End Select
                  End If
                Next
              End If
            Next
            'Запуск функций заполнения других атрибутов
            Select Case Obj.ObjectDefName
              Case "OBJECT_VOLUME"
                Obj.Attributes("ATTR_VOLUME_CODE").Value = _
                  ThisApplication.ExecuteScript("CMD_S_NUMBERING", "VolumeCodeGen",Obj)
                Obj.Attributes("ATTR_VOLUME_NUM").Value = _
                  ThisApplication.ExecuteScript("CMD_S_NUMBERING", "VolumeNumCodeGen",Obj)
                If Obj.Attributes("ATTR_VOLUME_NAME").Value = "NOTHING" Then Obj.Attributes("ATTR_VOLUME_NAME").Value = "-"
              Case "OBJECT_PROJECT_SECTION", "OBJECT_PROJECT_SECTION_SUBSECTION"
                If Obj.Attributes("ATTR_PROJECT_DOCS_SECTION").Empty = False and Obj.Attributes("ATTR_SECTION_NUM").Empty = False and _
                Obj.Attributes.Has("ATTR_DESCRIPTION_SHORT") Then
                  Set Clf = Obj.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier
                  If Trim(Clf.Code) = "-" or Trim(Clf.Code) = "" Then
                    Val = Clf.Description
                  Else
                    Val = Clf.Code
                  End If
                  sDescr = Obj.Attributes("ATTR_SECTION_NUM").Value & ". " & Val
                  Obj.Attributes("ATTR_DESCRIPTION_SHORT").Value = sDescr
                End If
            End Select
          End If
          Log1 = Log1 & chr(10) & Log0
        End If
      End If
      If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJGUID").Empty Then
        Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJGUID").Value = Obj.Guid
        Obj.Update
      End If
    End If
    Stp0 = Stp0 + Stp
    Progress.Position = Stp0
  Next
  If Log1 <> "" Then
    ThisApplication.AddNotify Log1
    ThisObject.Attributes("ATTR_STAGE_PROJECT_STRUCT_PUBLIC").Value = True
    Call ButtonsEnable0(ThisForm,ThisObject)
  Else
    Msgbox "Нет изменений в структуре.", vbInformation
  End If
  
  'Закрытие режима редактирования структуры
  StatusName = "STATUS_STAGE_DEVELOPING"
  If ThisObject.ObjectDef.Statuses.Has(StatusName) Then
    'Смена статуса
    RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",ThisObject,ThisObject.Status,ThisObject,StatusName)
    If RetVal = -1 Then
      ThisObject.Status = ThisApplication.Statuses(StatusName)
    End If
    
    'Удаление роли
    For Each Role in ThisObject.Roles
      If Role.RoleDefName = "ROLE_PROJECT_STRUCTURE_EDIT" Then
        ThisObject.Roles.Remove Role
      End If
    Next
  End If
  
  Progress.Stop
  ThisApplication.Utility.WaitCursor = False
  
  ThisObject.SaveChanges
  ThisForm.Close True
  
  ThisScript.SysAdminModeOff
End Sub

'Функция получения/создания сслыки на объект
Function GetObjLink(StructRows,Row)
  Set GetObjLink = Nothing
  Set Parent = Nothing
  'Получение ссылки на существующий объект
  ObjGuid = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJGUID").Value
  If ObjGuid <> "" Then
    Set Obj = ThisApplication.GetObjectByGUID(ObjGuid)
    If not Obj is Nothing Then
      Set GetObjLink = Obj
      Exit Function
    End If
  End If
  
  'Поиск родительского объекта
  pItem = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_PARENT").Value
  If pItem <> "" Then
    If pItem = "0" Then
      Set Parent = ThisObject
    Else
      For Each Row0 in StructRows
        If Row0.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = pItem Then
          ObjGuid = Row0.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJGUID").Value
          If ObjGuid <> "" Then
            Set Parent = ThisApplication.GetObjectByGUID(ObjGuid)
            If Parent is Nothing Then
              Exit Function
            Else
              Exit For
            End If
          End If
        End If
      Next
    End If
  End If
  
  'Создание объекта
  ObjTypeName = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJTYPE").Value
  If not Parent is Nothing and ObjTypeName <> "" Then
    If ThisApplication.ObjectDefs.Has(ObjTypeName) Then
      Set GetObjLink = Parent.Objects.Create(ObjTypeName)
      Exit Function
    Else
      Exit Function
    End If
  End If
  
End Function

'=============================================================================================================
'Цикличная процедура заполнения дерева
Sub TreeNowFill(Tree,Grid,StructRows,AttrsRows,Obj,pItem,Progress,Stp,Stp0)
  For Each Child in Obj.Content
    ChildType = Child.ObjectDefName
    ChildTypeDescr = Child.ObjectDef.Description
    Attrs = ""
    'Создание строки в таблице структуры
    If ChildType = "OBJECT_PROJECT_SECTION" or ChildType = "OBJECT_PROJECT_SECTION_SUBSECTION" or _
    ChildType = "OBJECT_VOLUME" or ChildType = "OBJECT_WORK_DOCS_FOR_BUILDING" Then
      Set NewRow = StructRows.Create
      NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_PARENT").Value = pItem
      NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJTYPE").Value = ChildType
      NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJNAME").Value = Child.Description
      NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJGUID").Value = Child.Guid
      hItem =  Tree.InsertItem(Child.Description, pItem, 1)
      Tree.SetItemIcon hItem , Child.Icon
      Tree.SetItemData hItem, NewRow
      NewRow.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = hItem
    End If
    
    'Получаем список атрибутов для заполнения
    Attrs = GetAttrsList(ChildType)
    
    'Заполняем атрибуты
    If Attrs <> "" Then
      Set AttrRow = AttrsRows.Create
      AttrRow.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = hItem
      AttrRow.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJGUID").Value = Child.Guid
      Arr = Split(Attrs,",")
      For i = 0 to Ubound(Arr)
        AttrName = Arr(i)
        If Child.Attributes.Has(AttrName) and AttrRow.Attributes.Has(AttrName) Then
          Set Attr0 = Child.Attributes(AttrName)
          Set Attr1 = AttrRow.Attributes(AttrName)
          Call ThisApplication.ExecuteScript("CMD_DLL","AttrValueCopy",Attr0,Attr1)
        End If
      Next
      'Заполняем пустые обязательные атрибуты
      For Each Attr in AttrRow.Attributes
        AttrName = Attr.AttributeDefName
        If Attr.Empty and Attr.AttributeDef.Required = True Then
          If AttrName = "ATTR_PROJECT_DOCS_SECTION" Then
            Attr.Classifier = ThisApplication.Classifiers.FindBySysId("NODE_PROJECT_STRUCT")
          ElseIf AttrName = "ATTR_WORK_DOCS_FOR_BUILDING_NAME" Then
            Attr.Value = "NOTHING"
          ElseIf AttrName = "ATTR_VOLUME_NAME" Then
            Attr.Value = "NOTHING"
          End If
        End If
      Next
    End If
    
    Stp0 = Stp0 + Stp
    Progress.Position = Stp0
    Call TreeNowFill(Tree,Grid,StructRows,AttrsRows,Child,hItem,Progress,Stp,Stp0)
  Next
End Sub

'=============================================================================================================
'Событие - Изменение значения ячейки
Sub ATTRSGRID_CellAfterEdit(nRow,nCol,strLabel,bCancel)
  Set Tree = ThisForm.Controls("STAGETREE").ActiveX
  Set Grid = ThisForm.Controls("ATTRSGRID").ActiveX
  Set Rows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL2").Rows
  hItem = Tree.SelectedItem
  Set Row = Tree.GetItemData(hItem)
  ObjType = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJTYPE").Value
  Set Row = Grid.RowValue(nRow)
  If Row is Nothing Then Exit Sub
  If nCol = 0 Then
    bCancel = True
    Exit Sub
  End If
  '"ATTR_BUILDING_CODE,ATTR_BUILDING_TYPE,ATTR_WORK_DOCS_FOR_BUILDING_NAME"
  '"ATTR_PROJECT_DOCS_SECTION,ATTR_NAME,ATTR_RESPONSIBLE,ATTR_CODE"
  '"ATTR_VOLUME_PART_NUM,ATTR_VOLUME_PART_NAME,ATTR_BOOK_NUM,ATTR_BOOK_NAME,ATTR_VOLUME_NAME,ATTR_RESPONSIBLE"

  'Отменяем редактирование для атрибутов, которые нельзя редактировать
  AttrName = Row.Attributes("ATTR_CODE").Value
  Select Case ObjType
    Case ""
      Exit Sub
    'Полный комплект
    Case "OBJECT_WORK_DOCS_FOR_BUILDING"
      
    'Раздел, Подраздел
    Case "OBJECT_PROJECT_SECTION", "OBJECT_PROJECT_SECTION_SUBSECTION"
      If AttrName = "ATTR_PROJECT_DOCS_SECTION" Then
        bCancel = True
        Exit Sub
      ElseIf AttrName = "ATTR_CODE" Then
        For Each Row0 in Rows
          If Row0.Attributes("ATTR_CODE").Value = "ATTR_PROJECT_DOCS_SECTION" Then
            If StrComp(Row0.Attributes("ATTR_VALUE").Value,"непроектный раздел",vbTextCompare) <> 0 Then
              bCancel = True
              Exit Sub
            Else
              oName = GetSectionName(1,strLabel)
              Tree.SetItemText hItem, oName
              Tree.UpdateItem hItem, False
              ThisForm.Controls("ITEMNAME").Value = oName
            End If
          End If
        Next
      End If
    'Том
    Case "OBJECT_VOLUME"
      If AttrName = "ATTR_VOLUME_PART_NUM" Then
        Check = ThisApplication.ExecuteScript("OBJECT_VOLUME","CheckPartNum",strLabel)
        If Check = False Then
          Msgbox "Некорректный номер части!",vbExclamation
          bCancel = True
          Exit Sub
        End If
      ElseIf AttrName = "ATTR_BOOK_NUM" Then
        Check = ThisApplication.ExecuteScript("OBJECT_VOLUME","CheckBookNum",strLabel)
        If Check = False Then
          Msgbox "Некорректный номер книги!",vbExclamation
          bCancel = True
          Exit Sub
        End If
      End If
      oName = GetVolumeName(Nothing,Rows,nRow,strLabel)
      Tree.SetItemText hItem, oName
      Tree.UpdateItem hItem, False
      ThisForm.Controls("ITEMNAME").Value = oName
  End Select

  If AttrName = "ATTR_PROJECT_DOCS_SECTION" Then
    bCancel = True
    Exit Sub
  End If
  
  ThisObject.Attributes("ATTR_STAGE_PROJECT_STRUCT_PUBLIC").Value = False
  Call ButtonsEnable0(ThisForm,ThisObject)
End Sub

'=============================================================================================================
'Функция получения списка атрибутов по типу объекта
Function GetAttrsList(ObjType)
  GetAttrsList = ""
  Select Case ObjType
    'Полный комплект
    Case "OBJECT_WORK_DOCS_FOR_BUILDING"
      GetAttrsList = "ATTR_WORK_DOCS_FOR_BUILDING_TYPE,ATTR_BUILDING_CODE,ATTR_BUILDING_TYPE,ATTR_WORK_DOCS_FOR_BUILDING_NAME,ATTR_BUILDING_STAGE"
    'Раздел
    Case "OBJECT_PROJECT_SECTION"
      GetAttrsList = "ATTR_PROJECT_DOCS_SECTION,ATTR_NAME,ATTR_RESPONSIBLE,ATTR_CODE"
    'Подраздел
    Case "OBJECT_PROJECT_SECTION_SUBSECTION"
      GetAttrsList = "ATTR_PROJECT_DOCS_SECTION,ATTR_NAME,ATTR_RESPONSIBLE"
    'Том
    Case "OBJECT_VOLUME"
      GetAttrsList = "ATTR_VOLUME_PART_NUM,ATTR_VOLUME_PART_NAME,ATTR_BOOK_NUM,ATTR_BOOK_NAME,ATTR_VOLUME_NAME,ATTR_RESPONSIBLE"
  End Select
End Function

'=============================================================================================================
'Функция проверки таблицы структуры на оригинальность номера узла
Function TableItemUpdCheck(Obj,hItem)
  TableItemUpdCheck = True
  Set StructRows = Obj.Attributes("ATTR_PROJECT_STRUCT_TBL").Rows
  hItem = Cstr(hItem)
  For Each Row in StructRows
    If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = hItem Then
      TableItemUpdCheck = False
      Exit Function
    End If
  Next
End Function

'=============================================================================================================
'Процедура промежуточной нумерации узлов в таблице
Sub TablePreNumeric(Obj)
  Num = 1
  Set StructRows = Obj.Attributes("ATTR_PROJECT_STRUCT_TBL").Rows
  Set AttrsRows = Obj.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
  Set Dict = Obj.Dictionary
  Dict.RemoveAll
  For Each Row in StructRows
    Dict.Item(Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value) = Num
    Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = Num
    pItem = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_PARENT").Value
    If Dict.Exists(pItem) Then
      Row.Attributes("ATTR_PROJECT_STRUCT_TBL_PARENT").Value = Dict.Item(pItem)
    End If
    Num = Num + 1
  Next
  For Each Row in AttrsRows
    hItem = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value
    If Dict.Exists(hItem) Then
      Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = Dict.Item(hItem)
    End If
  Next
  Dict.RemoveAll
End Sub

'=============================================================================================================
'Событие - Нажатие клавиши в дереве
Sub STAGETREE_KeyDown(pnChar,nShiftState)
  ThisScript.SysAdminModeOn
  Set Dict = ThisForm.Dictionary
  Check = False
  If Dict.Exists("BackSelect") Then
    Check = Dict.Item("BackSelect")
  End If
  
  'ENTER - входим/выходим в режим перемещения тома
  If nShiftState = 0 and pnChar = 13 Then
    Call VolumeMoveEnter(ThisForm)
  'Влево (режим перемещения тома)
  ElseIf nShiftState = 0 and pnChar = 37 and Check = True Then
    Call VolumeMoveLeft
  'Вверх (режим перемещения тома)
  ElseIf nShiftState = 0 and pnChar = 38 and Check = True Then
    Call VolumeMoveUp
  'Вправо (режим перемещения тома)
  ElseIf nShiftState = 0 and pnChar = 39 and Check = True Then
    Call VolumeMoveRight
  'Вниз (режим перемещения тома)
  ElseIf nShiftState = 0 and pnChar = 40 and Check = True Then
    Call VolumeMoveDown
  End If
End Sub

'=============================================================================================================
'Процедура включения/выключения режима перемещения тома
Sub VolumeMoveEnter(Form)
  Set Dict = Form.Dictionary
  Set Ctrl = Form.Controls("MAIN_TEXT")
  Set Tree = ThisForm.Controls("STAGETREE").ActiveX
  Set Grid = ThisForm.Controls("ATTRSGRID").ActiveX
  hItem = Tree.SelectedItem
  Set Row = Tree.GetItemData(hItem)
  Dict.Item("hItem") = hItem
  ObjType = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJTYPE").Value
  Val = "Режим перемещения тома. Для заверщения нажмите ""Enter"""
  Flag = False
  
  If Ctrl.Value = Val Then
    Ctrl.Value = ""
    Dict.Item("BackSelect") = False
  ElseIf ObjType = "OBJECT_VOLUME" Then
    Ctrl.Value = Val
    Dict.Item("BackSelect") = True
    Flag = True
  End If
  Form.Controls("BUTTON_MOVE_LEFT").Enabled = Flag
  Form.Controls("BUTTON_MOVE_UP").Enabled = Flag
  Form.Controls("BUTTON_MOVE_RIGHT").Enabled = Flag
  Form.Controls("BUTTON_MOVE_DOWN").Enabled = Flag
  Form.Controls("ATTRSGRID").Enabled = not Flag
  Grid.Redraw
End Sub

'=============================================================================================================
'Кнопка включения/выключения режима перемещения тома
Sub BUTTON_VOLUME_MOVE_OnClick()
  Call VolumeMoveEnter(ThisForm)
End Sub

'=============================================================================================================
'Кнопка перемещения тома вверх
Sub BUTTON_MOVE_UP_OnClick()
  Call VolumeMoveUp
End Sub

'Процедура перемещения тома вверх
Sub VolumeMoveUp()
  Set Tree = ThisForm.Controls("STAGETREE").ActiveX
  Set Rows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL2").Rows
  'Set Rows0 = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
  Set Grid = ThisForm.Controls("ATTRSGRID").ActiveX
  hItem = cStr(Tree.SelectedItem)
  hParent = cStr(Tree.GetParentItem(hItem))
  SectionCode = ""
  PartNum = ""
  BookNum = ""
  
  'ThisApplication.Utility.WaitCursor = True
  
  'Получаем новые значения
  NumArr = GetNewVolumeCode("UP",Tree,hItem)
  Call VolumeNumArrToParam(NumArr,SectionCode,PartNum,BookNum,True)
  'SectionCode = GetSectionCode(Rows0,hParent)
  
  'Записываем новые значения
  Call VolumeNumSaveParam(ThisObject,PartNum,BookNum)
  Call AttrsSave
  
  'Обновляем отображение всех параметров
  oName = GetVolumeName(Nothing,Rows,-1,"")
  Tree.SetItemText hItem, oName
  Tree.UpdateItem hItem, False
  Set Row = Tree.GetItemData(hItem)
  Call AttrsGridInit(Row)
  ThisForm.Controls("ITEMNAME").Value = Tree.GetItemText(hItem)
  
  'Если ниже по списку есть том с таким же номером, то уменьшаем его номер на 1
  hPrev = cStr(Tree.GetPrevSiblingItem(hItem))
  Call VolumeChangeForRank(ThisObject,ThisForm,hPrev,NumArr,SectionCode,1)
  
  'Сортируем тома в разделе
  hParent = cStr(Tree.GetParentItem(hItem))
  Tree.SortChildren(hParent)
  
  'ThisApplication.Utility.WaitCursor = False
End Sub

'=============================================================================================================
'Кнопка перемещения тома вниз
Sub BUTTON_MOVE_DOWN_OnClick()
  Call VolumeMoveDown
End Sub

'Процедура перемещения тома вниз
Sub VolumeMoveDown()
  Set Tree = ThisForm.Controls("STAGETREE").ActiveX
  Set Rows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL2").Rows
  Set Grid = ThisForm.Controls("ATTRSGRID").ActiveX
  hItem = cStr(Tree.SelectedItem)
  SectionCode = ""
  PartNum = ""
  BookNum = ""
  
  'ThisApplication.Utility.WaitCursor = True
  
  'Получаем новые значения
  NumArr = GetNewVolumeCode("DOWN",Tree,hItem)
  Call VolumeNumArrToParam(NumArr,SectionCode,PartNum,BookNum,True)
  
  'Записываем новые значения
  Call VolumeNumSaveParam(ThisObject,PartNum,BookNum)
  Call AttrsSave
  
  'Обновляем отображение всех параметров
  oName = GetVolumeName(Nothing,Rows,-1,"")
  Tree.SetItemText hItem, oName
  Tree.UpdateItem hItem, False
  
  Set Row = Tree.GetItemData(hItem)
  Call AttrsGridInit(Row)
  ThisForm.Controls("ITEMNAME").Value = Tree.GetItemText(hItem)
  
  'Если ниже по списку есть том с таким же номером, то уменьшаем его номер на 1
  hNext = cStr(Tree.GetNextSiblingItem(hItem))
  Call VolumeChangeForRank(ThisObject,ThisForm,hNext,NumArr,SectionCode,-1)
  
  'Сортируем тома в разделе
  hParent = cStr(Tree.GetParentItem(hItem))
  Tree.SortChildren(hParent)
  
  'ThisApplication.Utility.WaitCursor = False
End Sub

'=============================================================================================================
'Кнопка перемещения тома влево
Sub BUTTON_MOVE_LEFT_OnClick()
  Call VolumeMoveLeft()
End Sub

'Процедура перемещения тома влево
Sub VolumeMoveLeft()
  Set Tree = ThisForm.Controls("STAGETREE").ActiveX
  Set Rows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL2").Rows
  Set Grid = ThisForm.Controls("ATTRSGRID").ActiveX
  hItem = cStr(Tree.SelectedItem)
  SectionCode = ""
  PartNum = ""
  BookNum = ""
  
  'ThisApplication.Utility.WaitCursor = True
  
  'Получаем новые значения
  NumArr = GetNewVolumeCode("LEFT",Tree,hItem)
  Call VolumeNumArrToParam(NumArr,SectionCode,PartNum,BookNum,True)
  
  'Записываем новые значения
  Call VolumeNumSaveParam(ThisObject,PartNum,BookNum)
  Call AttrsSave
  
  'Обновляем отображение всех параметров
  oName = GetVolumeName(Nothing,Rows,-1,"")
  Tree.SetItemText hItem, oName
  Tree.UpdateItem hItem, False
  
  Set Row = Tree.GetItemData(hItem)
  Call AttrsGridInit(Row)
  ThisForm.Controls("ITEMNAME").Value = Tree.GetItemText(hItem)
  
  'Сортируем тома в разделе
  hParent = cStr(Tree.GetParentItem(hItem))
  Tree.SortChildren(hParent)
  
  'ThisApplication.Utility.WaitCursor = False
End Sub

'=============================================================================================================
'Кнопка перемещения тома вправо
Sub BUTTON_MOVE_RIGHT_OnClick()
  Call VolumeMoveRight
End Sub

'Процедура перемещения тома вправо
Sub VolumeMoveRight()
  Set Tree = ThisForm.Controls("STAGETREE").ActiveX
  Set Rows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL2").Rows
  Set Grid = ThisForm.Controls("ATTRSGRID").ActiveX
  hItem = cStr(Tree.SelectedItem)
  SectionCode = ""
  PartNum = ""
  BookNum = ""
  
  'ThisApplication.Utility.WaitCursor = True
  
  'Получаем новые значения
  NumArr = GetNewVolumeCode("RIGHT",Tree,hItem)
  Call VolumeNumArrToParam(NumArr,SectionCode,PartNum,BookNum,True)
  
  'Записываем новые значения
  Call VolumeNumSaveParam(ThisObject,PartNum,BookNum)
  Call AttrsSave
  
  'Обновляем отображение всех параметров
  oName = GetVolumeName(Nothing,Rows,-1,"")
  Tree.SetItemText hItem, oName
  Tree.UpdateItem hItem, False
  
  Set Row = Tree.GetItemData(hItem)
  Call AttrsGridInit(Row)
  ThisForm.Controls("ITEMNAME").Value = Tree.GetItemText(hItem)
  
  'Сортируем тома в разделе
  hParent = cStr(Tree.GetParentItem(hItem))
  Tree.SortChildren(hParent)
  
  'ThisApplication.Utility.WaitCursor = False
End Sub

'=============================================================================================================
'Процедура разбора массива-номера тома на переменные
Sub VolumeNumArrToParam(NumArr,SectionCode,PartNum,BookNum,SectionSeek)
  If Ubound(NumArr) = -1 Then Exit Sub
  If SectionSeek = True Then
    SectionCode = NumArr(0)
    TempPos = 1
  Else
    TempPos = 0
  End If
  If Ubound(NumArr) > TempPos-1 Then PartNum = NumArr(TempPos)
  If Ubound(NumArr) > TempPos Then
    For i = TempPos+1 to Ubound(NumArr)
      If BookNum <> "" Then
        BookNum = BookNum & "." & NumArr(i)
      Else
        BookNum = NumArr(i)
      End If
    Next
  End If
End Sub

'=============================================================================================================
'Процедура записи номера части и номера книги в таблицу атрибутов на форме
Sub VolumeNumSaveParam(Obj,PartNum,BookNum)
  Set Rows = Obj.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL2").Rows
  For Each Row in Rows
    If Row.Attributes("ATTR_CODE").Value = "ATTR_VOLUME_PART_NUM" and Row.Attributes("ATTR_VALUE").Value <> PartNum Then
      Row.Attributes("ATTR_VALUE").Value = PartNum
    End If
    If Row.Attributes("ATTR_CODE").Value = "ATTR_BOOK_NUM" and Row.Attributes("ATTR_VALUE").Value <> BookNum Then
      Row.Attributes("ATTR_VALUE").Value = BookNum
    End If
  Next
End Sub

'=============================================================================================================
'Функция определения нового номера тома
Function GetNewVolumeCode(Action,Tree,hItem)
  GetNewVolumeCode = ""
  Set Rows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
  Set StructRows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_TBL").Rows
  Root = cStr(Tree.RootItem)
  CurNum = ""
  NextNum = ""
  
  'Определение текущего номера тома
  hParent = cStr(Tree.GetParentItem(hItem))
  If hParent = Root Then Exit Function
  SectionCode = GetSectionCode(Rows,hParent)
  NumArr = GetArrNumFromItem(Tree,hItem)
  
  'Создание виртуальной таблицы номеров томов
  TableArr = GetTableNumsVolumes(hParent)
  
  Select Case Action
    Case "LEFT"
      NextNum = GetVolumeNumLeft(TableArr,NumArr)
      
    Case "RIGHT"
      'NextNum = NumArr
      'ReDim Preserve NextNum(UBound(NextNum) + 1)
      'NextNum(UBound(NextNum)) = "1"
      NextNum = GetVolumeNumRight(TableArr,NumArr)
      
    Case "UP"
      NextNum = NumArr
      Ub = UBound(NextNum)
      If Ub > -1 Then
        UbVal = NextNum(Ub)
        If isNumeric(UbVal) Then
          NextVal = 0
          NextVal = cLng(UbVal) - 1
          If NextVal > 0 Then
            NextNum(Ub) = cStr(NextVal)
          End If
        End If
      End If
      
    Case "DOWN"
      NextNum = NumArr
      Ub = UBound(NextNum)
      If Ub > -1 Then
        MaxValRank = GetMaxValueForRnk(TableArr,NextNum,Ub)
        UbVal = NextNum(Ub)
        If isNumeric(UbVal) and isNumeric(MaxValRank) Then
          UbValNum = cLng(UbVal)
          If UbValNum + 1 <= cLng(MaxValRank) Then
            NextNum(Ub) = cStr(UbValNum + 1)
          End If
        End If
      End If
      
  End Select
  
  NextNumStr = SectionCode & "." & Join(NextNum, ".")
  GetNewVolumeCode = Split(NextNumStr, ".")
End Function

'=============================================================================================================
'Функция формирования виртуальной таблицы номеров томов
Function GetTableNumsVolumes(hItem)
  Set Tree = ThisForm.Controls("STAGETREE").ActiveX
  Set StructRows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_TBL").Rows
  
  Arr = Array()
  hChild = Tree.GetChildItem(hItem)
  ReDim Preserve Arr(UBound(Arr) + 1)
  Arr(UBound(Arr)) = GetArrayFromVolume(hChild)
  
  Do While Tree.GetNextSiblingItem(hChild) <> 0
    hChild = Tree.GetNextSiblingItem(hChild)
    If hChild <> 0 Then
      ReDim Preserve Arr(UBound(Arr) + 1)
      Arr(UBound(Arr)) = GetArrayFromVolume(hChild)
    Else
      Exit Do
    End If
  Loop
  
  GetTableNumsVolumes = Arr
End Function

'=============================================================================================================
'Функция формирования строки для виртуальной таблицы номеров томов
Function GetArrayFromVolume(hItem)
  Set Rows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
  Str = ""
  hItemStr = cStr(hItem)
  For Each Row in Rows
    If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = hItemStr Then
      AttrName = "ATTR_VOLUME_PART_NUM"
      AttrName0 = "ATTR_BOOK_NUM"
      If Row.Attributes(AttrName).Empty = False Then
        Str = Row.Attributes(AttrName).Value
      End If
      If Row.Attributes(AttrName0).Empty = False Then
        If Str <> "" Then
          Str = Str & "." & Row.Attributes(AttrName0).Value
        Else
          Str = Row.Attributes(AttrName0).Value
        End If
      End If
    End If
  Next
  GetArrayFromVolume = Split(Str,".")
End Function

'=============================================================================================================
'Функция получения номера тома при движении влево
Function GetVolumeNumLeft(Table,Num)
  GetVolumeNumLeft = Num
  NextNum = Num
  NumPos = -1
  RankMaxValue = -1
  If Ubound(NextNum) < 0 Then Exit Function
  Redim Preserve NextNum(Ubound(NextNum)-1)
  Rank = Ubound(NextNum)
  If Rank = -1 Then Exit Function
  NumRank = NextNum(Rank)
  

  'Поиск строки текущего тома
  For i = 0 to Ubound(Table)
    TableCol = Table(i)
    If Ubound(Num) = Ubound(TableCol) Then
      Check = True
      For j = 0 to Ubound(TableCol)
        If Num(j) <> TableCol(j) Then
          Check = False
          Exit For
        End If
      Next
      If Check = True Then
        NumPos = i
        Exit For
      End If
    End If
  Next
  
  'Определение разряда - открытый или закрытый
  RankStatus = "open"
  For i = 0 to Ubound(Table)
    If i <> NumPos Then
      TableCol = Table(i)
      If Ubound(TableCol) >= Rank Then
        Check = True
        CheckMax = True
        For j = 0 to Rank
          If TableCol(j) <> Num(j) Then
            Check = False
            If j < Rank Then CheckMax = False
            Exit For
          End If
        Next
        If Check = True Then
          RankStatus = "close"
        End If
        If CheckMax = True Then
          If RankMaxValue < TableCol(Rank) Then RankMaxValue = TableCol(Rank)
        End If
      End If
    End If
  Next
  
  'Если нужный разряд открытый, то просто убираем крайний разряд от текущего номера
  If RankStatus = "open" Then
    GetVolumeNumLeft = NextNum
    Exit Function
  End If
  
  'Если разряд закрытый, то берем следующее, после максимального значения разряда
  NextNum(Rank) = cStr(RankMaxValue + 1)
  GetVolumeNumLeft = NextNum
End Function

'=============================================================================================================
'Функция получения номера тома при движении вправо
Function GetVolumeNumRight(Table,Num)
  GetVolumeNumRight = Num
  NextNum = Num
  NumPos = -1
  RankMaxValue = -1
  If Ubound(NextNum) < 0 Then Exit Function
  Redim Preserve NextNum(Ubound(NextNum)+1)
  NextNum(UBound(NextNum)) = "1"
  Rank = Ubound(NextNum)
  If Rank = -1 Then Exit Function
  NumRank = NextNum(Rank)
  

  'Поиск строки текущего тома
  For i = 0 to Ubound(Table)
    TableCol = Table(i)
    If Ubound(Num) = Ubound(TableCol) Then
      Check = True
      For j = 0 to Ubound(TableCol)
        If Num(j) <> TableCol(j) Then
          Check = False
          Exit For
        End If
      Next
      If Check = True Then
        NumPos = i
        Exit For
      End If
    End If
  Next
  
  'Определение разряда - открытый или закрытый
  RankStatus = "open"
  For i = 0 to Ubound(Table)
    If i <> NumPos Then
      TableCol = Table(i)
      If Ubound(TableCol) >= Rank Then
        Check = True
        CheckMax = True
        For j = 0 to Rank-1
          If TableCol(j) <> NextNum(j) Then
            Check = False
            If j < Rank Then CheckMax = False
            Exit For
          End If
        Next
        If Check = True Then
          RankStatus = "close"
        End If
        If CheckMax = True Then
          If RankMaxValue < TableCol(Rank) Then RankMaxValue = TableCol(Rank)
        End If
      End If
    End If
  Next
  
  'Если нужный разряд открытый, то просто добавляем крайний разряд к текущему номеру
  If RankStatus = "open" Then
    GetVolumeNumRight = NextNum
    Exit Function
  End If
  
  'Если разряд закрытый, то берем следующее, после максимального значения разряда
  NextNum(Rank) = cStr(RankMaxValue + 1)
  GetVolumeNumRight = NextNum
End Function

'=============================================================================================================
'Функция получения массива с номером указанного тома без номера раздела
Private Function GetArrNumFromItem(Tree,hItem)
  CurNum = ""
  Set Rows = ThisObject.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
  For Each Row in Rows
    If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = hItem Then
      If Row.Attributes("ATTR_VOLUME_PART_NUM").Empty = False Then
        CurNum = Row.Attributes("ATTR_VOLUME_PART_NUM").Value
      End If
      If Row.Attributes("ATTR_BOOK_NUM").Empty = False Then
        If CurNum <> "" Then
          CurNum = CurNum & "." & Row.Attributes("ATTR_BOOK_NUM").Value
        Else
          CurNum = Row.Attributes("ATTR_BOOK_NUM").Value
        End If
      End If
    End If
  Next
  GetArrNumFromItem = Split(CurNum,".")
End Function

'=============================================================================================================
'Процедура изменения номера тома по рангу для соседнего элемента дерева
Private Sub VolumeChangeForRank(Obj,Form,hItem,NumArr,SectionCode,ValChange)
  Set Rows0 = Obj.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
  Set Tree = Form.Controls("STAGETREE").ActiveX
  Set Grid = Form.Controls("ATTRSGRID").ActiveX
  If hItem <> "0" Then
    PartNum = ""
    BookNum = ""
    VolumeName = ""
    NumArrNext = GetArrNumFromItem(Tree,hItem)
    Rank = Ubound(NumArrNext)
    If Ubound(NumArr) = Rank + 1 Then
      'Проверка соседнего элемента на идентичность номера
      Check = True
      For i = 0 to Rank
        If i <> Rank and NumArrNext(i) <> NumArr(i+1) Then
          Check = False
          Exit For
        End If
      Next
      If Check = True Then
        Val = NumArrNext(Rank)
        If IsNumeric(Val) Then
          Val = cStr(cLng(Val) + ValChange)
          NumArrNext(Rank) = Val
          'msgbox Join(NumArrNext,".")
          'Внесение изменений в основную таблицу
          Call VolumeNumArrToParam(NumArrNext,SectionCode,PartNum,BookNum,False)
          For Each Row in Rows0
            If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = hItem Then
              If Row.Attributes("ATTR_VOLUME_PART_NUM").Value <> PartNum Then
                Row.Attributes("ATTR_VOLUME_PART_NUM").Value = PartNum
              End If
              If Row.Attributes("ATTR_BOOK_NUM").Value <> BookNum Then
                Row.Attributes("ATTR_BOOK_NUM").Value = BookNum
              End If
              VolumeName = Row.Attributes("ATTR_VOLUME_NAME").Value
              Exit For
            End If
          Next
          'Переименование элемента дерева
          oName = SectionCode
          If PartNum <> "" Then oName = oName & "." & PartNum
          If BookNum <> "" Then oName = oName & "." & BookNum
          If VolumeName <> "" Then oName = oName & " - " & VolumeName
          Tree.SetItemText hItem, oName
          Tree.UpdateItem hItem, False
        End If
      End If
    End If
  End If
End Sub

'=============================================================================================================
'Функция получения максимального значения по рангу в таблице номеров томов
Private Function GetMaxValueForRnk(Table,Num,Rank)
  GetMaxValueForRnk = -1
  If Rank = -1 Then Exit Function
  
  For i = 0 to Ubound(Table)
    TableCol = Table(i)
    If Ubound(TableCol) >= Rank Then
      CheckMax = True
      For j = 0 to Rank
        If TableCol(j) <> Num(j) Then
          If j < Rank Then CheckMax = False
          Exit For
        End If
      Next
      If CheckMax = True Then
        If GetMaxValueForRnk < TableCol(Rank) Then GetMaxValueForRnk = TableCol(Rank)
      End If
    End If
  Next
End Function

'=============================================================================================================
'Функция копирования структуры объектов проектирования в Полные комплекты
Function StructCopyFormUnits(Obj,CreateFlag)
  ThisScript.SysAdminModeOn
  StructCopyFormUnits = ""
  Set Dict = ThisApplication.Dictionary("UnitsTree")
  
  'Определение родительского узла объектов проектирования
  AttrName = "ATTR_PROJECT"
  Set oProj = Nothing
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      If not Obj.Attributes(AttrName).Object is Nothing Then
        Set oProj = Obj.Attributes(AttrName).Object
      End If
    End If
  End If
  If oProj is Nothing Then Exit Function
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_FOLDER"
  q.AddCondition tdmQueryConditionAttribute, oProj, AttrName
  q.AddCondition tdmQueryConditionAttribute, "NODE_FOLDER_PROJECT_WORK", "ATTR_FOLDER_TYPE"
  Set Objects = q.Objects
  If q.Objects.Count = 0 Then
    Msgbox "Папка объектов проектирования не найдена.",vbExclamation
    Exit Function
  Else
    Set oFolder = q.Objects(0)
  End If
  If oFolder.ContentAll.Count = 0 Then
    Msgbox "Объекты проектирования не найдены.",vbExclamation
    Exit Function
  End If
  
  Set AttrsRows0 = Obj.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
  Set StructRows0 = Obj.Attributes("ATTR_PROJECT_STRUCT_TBL").Rows
  Root = "0"
  For Each Row in StructRows0
    If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_PARENT").Value = Root Then
      Root = Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value
      Exit For
    End If
  Next
  
  'Инициализация формы
  Dict.Item("oFolderHandle") = oFolder.Handle
  Dict.Item("StageHandle") = Obj.Handle
  Dict.Item("CreateFlag") = CreateFlag
  Dict.Item("RootHandle") = Root
  Set Form = ThisApplication.InputForms("FORM_STRUCT_COPY_FROM_UNITS")
  If Form.Show Then
    'Копирование строк в Стадию
    Set AttrsRows = Form.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
    Set StructRows = Form.Attributes("ATTR_PROJECT_STRUCT_TBL").Rows
    If AttrsRows.Count > 0 and StructRows.Count > 0 Then
      'Удаляем старые строки
      AttrsRows0.RemoveAll
      For Each Row in StructRows0
        If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_PARENT").Value <> "0" Then
          StructRows0.Remove Row
        End If
      Next
      'Копируем новые строки с формы на форму
      For Each Row in AttrsRows
        Set NewRow = AttrsRows0.Create
        For Each Attr in Row.Attributes
          ThisApplication.ExecuteScript "CMD_DLL","AttrValueCopy",Attr,NewRow.Attributes(Attr.AttributeDefName)
        Next
      Next
      For Each Row in StructRows
        Set NewRow = StructRows0.Create
        For Each Attr in Row.Attributes
          ThisApplication.ExecuteScript "CMD_DLL","AttrValueCopy",Attr,NewRow.Attributes(Attr.AttributeDefName)
        Next
      Next
      AttrName = "ATTR_STAGE_PROJECT_STRUCT_PUBLIC"
      Obj.Attributes(AttrName).Value = Form.Attributes(AttrName).Value
      Obj.Update
    End If
  End If
  
End Function

'=============================================================================================================
'Кнопка - Скопировать из структуры объекта
Sub BUTTON_COPY_OnClick()
  Str = StructCopyFormUnits(ThisObject,False)
End Sub

'=============================================================================================================
'Функция управления доступностью кнопки/команды Скопировать из структуры объекта
Function BtnCopyStructEnabled(Obj)
  BtnCopyStructEnabled = False
  Set CU = ThisApplication.CurrentUser
  Set Roles = Obj.RolesForUser(CU)
  
  'Стадия = Рабочая документация
  AttrName = "ATTR_PROJECT_STAGE"
  If Obj.Attributes.Has(AttrName) = False Then Exit Function
  If Obj.Attributes(AttrName).Empty Then Exit Function
  If Obj.Attributes(AttrName).Classifier is Nothing Then Exit Function
  Set Clf = Obj.Attributes(AttrName).Classifier
  If Clf.Sysname <> "NODE_PROJECT_STAGE_W" Then Exit Function
  
  'Роли: ГИП, зам.ГИПа, Редактирование состава проекта
  If Roles.Has("ROLE_GIP") = False and Roles.Has("ROLE_GIP_DEP") = False and _
  Roles.Has("ROLE_PROJECT_STRUCTURE_EDIT") = False Then
    Exit Function
  End If
  
  'Рабочая документация не имеет дочерних объектов
  If Obj.ContentAll.Count <> 0 Then Exit Function
  
  BtnCopyStructEnabled = True
End Function






