' Форма ввода - Копирование из структуры объекта
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "CMD_DLL"

Sub Form_BeforeShow(Form, Obj)
  Set Dict = ThisApplication.Dictionary("UnitsTree")
  Set Tree = Form.Controls("TREE").ActiveX
  Tree.CheckBoxes= True
  Set oFolder = Nothing
  Root = Tree.InsertItem("Объекты проектирования", 0, 1)
  Tree.SetItemIcon Root , ThisApplication.Icons.SystemIcon(125)
  Tree.SetCheck Root, True
  SelectedItem = 0
  ThisForm.Attributes("ATTR_STAGE_PROJECT_STRUCT_PUBLIC").Value = True
  
  If Dict.Exists("oFolderHandle") Then
    Handle = Dict.Item("oFolderHandle")
    Dict.Remove "oFolderHandle"
    Set oFolder = ThisApplication.Utility.GetObjectByHandle(Handle)
  End If
  
  If oFolder is Nothing Then Exit Sub
  ThisApplication.Utility.WaitCursor = True
  
  'Заполнение дерева
  Call TreeFill(Tree,oFolder,Root)
  Tree.Expand Root
  
  ThisApplication.Utility.WaitCursor = False
  
End Sub

'Циклическая процедура заполнения дерева
Sub TreeFill(Tree,Obj,Item)
  For Each Child in Obj.Content
    TableItem1 =  Tree.InsertItem(Child.Description, Item, 1)
    Tree.SetItemData TableItem1, Child
    Tree.SetItemIcon TableItem1, Child.Icon
    Tree.SetCheck TableItem1, True
    Call TreeFill(Tree,Child,TableItem1)
  Next
End Sub

Sub Form_BeforeClose(Form, Obj, Cancel)
  If ThisForm.Dictionary.Item("FORM_KEY_PRESSED") = True Then
    Set Tree = Form.Controls("TREE").ActiveX
    Root = Tree.RootItem
    'Если нет ниодного флага в дереве
    If Tree.GetCheck(Root) = False Then
      Msgbox "Вы не выбрали ни одного объекта проектирования", vbExclamation
      Cancel = True
      Exit Sub
    End If
    
    'Определяем параметры запуска
    Set Dict = ThisApplication.Dictionary("UnitsTree")
    If Dict.Exists("StageHandle") and Dict.Exists("CreateFlag") and Dict.Exists("RootHandle") Then
      Handle = Dict.Item("StageHandle")
      CreateFlag = Dict.Item("CreateFlag")
      rParent = Dict.Item("RootHandle")
      rItem = -1
      Dict.Remove "StageHandle"
      Dict.Remove "RootHandle"
      Dict.Remove "CreateFlag"
      Set oStage = ThisApplication.Utility.GetObjectByHandle(Handle)
      
      'Создаем объекты
      Count = 0
      If not oStage is Nothing Then
        ThisApplication.Utility.WaitCursor = True
        Code = ""
        Set oLink = ThisApplication.ExecuteScript("CMD_S_NUMBERING","ObjectLinkGet",oStage,"ATTR_PROJECT")
        If not oLink is Nothing Then
          Code = oLink.Attributes("ATTR_PROJECT_CODE").Value
        End If
        'Номер этапа строительства
        Set oLink = ThisApplication.ExecuteScript("CMD_S_NUMBERING","ObjectLinkGet",oStage,"ATTR_BUILDING_STAGE")
        If not oLink is Nothing Then
          Num = oLink.Attributes("ATTR_CODE").Value
          If Num <> "" Then
            If Code <> "" Then
              Code = Code & "/" & Num
            Else
              Code = Num
            End If
          End If
        End If
        Set AttrsRows = Form.Attributes("ATTR_PROJECT_STRUCT_ATTRS_TBL").Rows
        Set StructRows = Form.Attributes("ATTR_PROJECT_STRUCT_TBL").Rows
        Call TreeLoopCheckCreate(oStage,Tree,Root,Count,CreateFlag,StructRows,AttrsRows,rParent,rItem,Code)
        ThisApplication.Utility.WaitCursor = False
      End If
      Dict.Item("CreateObjCount") = Count
    Else
      Exit Sub
    End If
  End If
End Sub

'Процедура поиска по дереву отмеченных узлов для создания объектов
Sub TreeLoopCheckCreate(Obj,Tree,hItem,Count,CreateFlag,StructRows,AttrsRows,rParent,rItem,Code)
  hChild = Tree.GetChildItem(hItem)
  If hChild <> 0 Then
    Set Child = ObjCreate(Obj,Tree,hChild,Count,CreateFlag,StructRows,AttrsRows,rParent,rItem,Code)
    Call TreeLoopCheckCreate(Child,Tree,hChild,Count,CreateFlag,StructRows,AttrsRows,rItem,-1,Code)
  Else
    Exit Sub
  End If
  Do While Tree.GetNextSiblingItem(hChild) <> 0
    hChild = Tree.GetNextSiblingItem(hChild)
    If hChild <> 0 Then
      Set Child = ObjCreate(Obj,Tree,hChild,Count,CreateFlag,StructRows,AttrsRows,rParent,rItem,Code)
      Call TreeLoopCheckCreate(Child,Tree,hChild,Count,CreateFlag,StructRows,AttrsRows,rItem,-1,Code)
    Else
      Exit Sub
    End If
  Loop
End Sub

'Функция создания объекта
Function ObjCreate(Parent,Tree,hChild,Count,CreateFlag,StructRows,AttrsRows,rParent,rItem,Code)
  ThisScript.SysAdminModeOn
  Set ObjCreate = Nothing
  ObjDefName = "OBJECT_WORK_DOCS_FOR_BUILDING"
  If Tree.GetCheck(hChild) = True Then
    Set Unit = Tree.GetItemData(hChild)
    Set Attr0 = Unit.Attributes("ATTR_WORK_DOCS_FOR_BUILDING_TYPE")
    Set Attr1 = Unit.Attributes("ATTR_UNIT_TYPE")
    Set Attr2 = Unit.Attributes("ATTR_UNIT_NAME")
    Set Attr3 = Unit.Attributes("ATTR_UNIT_CODE")
    Set Attr4 = Unit.Attributes("ATTR_BUILDING_STAGE")
    If not Unit is Nothing Then
      rItem = GetrItemHandle(StructRows)
      Set RowAttrs = AttrsRows.Create
      Set RowStruct = StructRows.Create
      oName = GetrItemName(Code,Attr1,Attr3)
      RowStruct.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = rItem
      RowStruct.Attributes("ATTR_PROJECT_STRUCT_TBL_PARENT").Value = rParent
      RowStruct.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJTYPE").Value = ObjDefName
      RowStruct.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJNAME").Value = oName
      RowAttrs.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = rItem
      Call AttrValueCopy(Attr0, RowAttrs.Attributes("ATTR_WORK_DOCS_FOR_BUILDING_TYPE"))
      Call AttrValueCopy(Attr1, RowAttrs.Attributes("ATTR_BUILDING_TYPE"))
      Call AttrValueCopy(Attr2, RowAttrs.Attributes("ATTR_WORK_DOCS_FOR_BUILDING_NAME"))
      Call AttrValueCopy(Attr3, RowAttrs.Attributes("ATTR_BUILDING_CODE"))
      Call AttrValueCopy(Attr4, RowAttrs.Attributes("ATTR_BUILDING_STAGE"))
      Set Clf = ThisApplication.Classifiers.FindBySysId("NODE_PROJECT_STRUCT")
      If not Clf is Nothing Then RowAttrs.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier = Clf
      
      'Объекты создаются, только если флаг = TRUE
      If CreateFlag = True and not Parent is Nothing Then
        Set ObjCreate = Parent.Objects.Create(ObjDefName)
        RowStruct.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJGUID").Value = ObjCreate.GUID
        RowAttrs.Attributes("ATTR_PROJECT_STRUCT_TBL_OBJGUID").Value = ObjCreate.GUID
        Call AttrValueCopy(Attr0, ObjCreate.Attributes("ATTR_WORK_DOCS_FOR_BUILDING_TYPE"))
        Call AttrValueCopy(Attr1, ObjCreate.Attributes("ATTR_BUILDING_TYPE"))
        Call AttrValueCopy(Attr2, ObjCreate.Attributes("ATTR_WORK_DOCS_FOR_BUILDING_NAME"))
        Call AttrValueCopy(Attr3, ObjCreate.Attributes("ATTR_BUILDING_CODE"))
        Call AttrValueCopy(Attr4, ObjCreate.Attributes("ATTR_BUILDING_STAGE"))
        ObjCreate.Attributes("ATTR_PROJECT_BASIC_CODE").Value = Code
        Count = Count + 1
      Else
        RowStruct.Attributes("ATTR_PROJECT_STRUCT_TBL_CHANGE").Value = _
          ThisApplication.ExecuteScript("FORM_PROJECT_STAGE_STRUCT","GetAttrsList",ObjDefName)
        ThisForm.Attributes("ATTR_STAGE_PROJECT_STRUCT_PUBLIC").Value = False
      End If
    End If
  End If
End Function

'Функция формирования наименования объекта Полный комплект
Private Function GetrItemName(Code,Attr1,Attr3)
  GetrItemName = Code
  'Код подобъекта
  If Attr1.Empty = False Then
    If not Attr1.Classifier is Nothing Then
      GetrItemName = GetrItemName & "-" & Attr1.Classifier.Code
    End If
  End If
  'Поз. по ГП
  Num = Attr3.Value
  If Num <> "" Then
    If GetrItemName <> "" Then
      GetrItemName = GetrItemName & "-" & Num
    Else
      GetrItemName = Num
    End If
  End If
End Function

'Функция генерации уникального идентификатора строки объекта в структуре
Private Function GetrItemHandle(StructRows)
  GethItemHandle = 0
  Check = True
  i = 0
  Randomize
  Do
    RandomNumber = Int ((100000 * Rnd) + 1)
    For Each Row in StructRows
      If Row.Attributes("ATTR_PROJECT_STRUCT_TBL_HITEM").Value = cStr(RandomNumber) Then
        Check = False
        Exit For
      End If
    Next
    i = i + 1
  Loop Until Check = True or i = 1000
  GetrItemHandle = RandomNumber
End Function

'Событие - Постановка флага в узле дерева
Sub TREE_Checked(hItem,bChecked,bCancel,action)
  Set Tree = ThisForm.Controls("TREE").ActiveX
  hParent = Tree.GetParentItem(hItem)
  
  If bChecked = True Then
    If hItem <> 0 Then
      Tree.SetCheck hParent, True
    End If
    If action = 2 Then
      Call ItemChecked(Tree,hItem,True)
    End If
  Else
    If action = 2 Then
      Call ItemChecked(Tree,hItem,False)
    End If
  End If
End Sub

'Циклическая процедура проставления/снятия флага
Private Sub ItemChecked(Tree,hItem,Flag)
  hChild = Tree.GetChildItem(hItem)
  If hChild <> 0 Then
    Tree.SetCheck hChild, Flag
    Call ItemChecked(Tree,hChild,Flag)
  Else
    Exit Sub
  End If
  Do While Tree.GetNextSiblingItem(hChild) <> 0
    hChild = Tree.GetNextSiblingItem(hChild)
    If hChild <> 0 Then
      Tree.SetCheck hChild, Flag
      Call ItemChecked(Tree,hChild,Flag)
    Else
      Exit Sub
    End If
  Loop
End Sub

'Нажата кнопка - OK
Sub Ok_OnClick()
  If ThisForm.Dictionary.Exists("FORM_KEY_PRESSED") Then
    ThisForm.Dictionary.Item("FORM_KEY_PRESSED") = True
  Else
    ThisForm.Dictionary.Add "FORM_KEY_PRESSED", True
  End If
End Sub

'Нажата кнопка - Отмена
Sub Cancel_OnClick()
  If ThisForm.Dictionary.Exists("FORM_KEY_PRESSED") Then
    ThisForm.Dictionary.Item("FORM_KEY_PRESSED") = False
  Else
    ThisForm.Dictionary.Add "FORM_KEY_PRESSED", False
  End If
End Sub
