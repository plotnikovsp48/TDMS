' Автор: Чернышов Д.С.
'
' Форма ввода - Добавить вид изысканий
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2017 г.


Sub Form_BeforeShow(Form, Obj)
  'Заполнение дерева
  ThisApplication.Utility.WaitCursor = True
  Set Dict = ThisApplication.Dictionary("SurvTree")
  If Dict.Exists("Handle") Then
    Handle = Dict.Item("Handle")
    Set Obj = ThisApplication.Utility.GetObjectByHandle(Handle)
  Else
    Exit Sub
  End If
  Set Query = ThisApplication.Queries("QUERY_SURV_SEARCH_TREE")
  If Obj.Attributes.Has("ATTR_PROJECT") Then
    If Obj.Attributes("ATTR_PROJECT").Empty = False Then
      If not Obj.Attributes("ATTR_PROJECT").Object is Nothing Then
        Query.Parameter("PROJECT") = Obj.Attributes("ATTR_PROJECT").Object
      End If
    End If
  End If
  Set Tree = Form.Controls("TREE").ActiveX
  Tree.CheckBoxes = True
  
  'Определяем корневой узел классификаторов
  If Obj.ObjectDefName = "OBJECT_PROJECT_DOCS_I" Then
    Set Clfs = ThisApplication.Classifiers("NODE_S_SURV_WORK")
  ElseIf Obj.ObjectDefName = "OBJECT_SURV" Then
    If Obj.Attributes("ATTR_S_SURV_TYPE").Empty = False Then
      Set Clfs = Obj.Attributes("ATTR_S_SURV_TYPE").Classifier
    Else
      Msgbox "У объекта не указан вид изыскания!", vbExclamation
      Exit Sub
    End If
  End If
  
  Root = Tree.InsertItem(Obj.Description, 0, 1)
  Tree.SetItemIcon Root , Obj.Icon
  Count = 0
  
  'Первый уровень
  If Clfs.Classifiers.Count <> 0 Then
    For Each Clf1 in Clfs.Classifiers
      Query.Parameter("SURV") = Clf1
      If Query.Objects.Count = 0 Then
        ItemGuid1 = Clf1.SysName
        ItemValue = Clf1.Code & " - " & Clf1.Description
        TableItem1 =  Tree.InsertItem(ItemValue, Root, 1)
        Tree.SetItemData TableItem1, ItemGuid1
        Tree.SetItemIcon TableItem1 , Clf1.Icon
        Count = Count + 1
        
        'Второй уровень
        For Each Clf2 in Clf1.Classifiers
          Query.Parameter("SURV") = Clf2
          If Query.Objects.Count = 0 Then
            ItemGuid2 = Clf2.SysName
            ItemValue = Clf2.Code & " - " & Clf2.Description
            TableItem2 =  Tree.InsertItem(ItemValue, TableItem1, 1)
            Tree.SetItemData TableItem2, ItemGuid2
            Tree.SetItemIcon TableItem2 , Clf2.Icon
            Count = Count + 1
          End If
        Next
      End If
    Next
  Else
    Msgbox """" & Obj.Description & """ является конечной папкой структуры.", vbExclamation
    Form.Close
    Exit Sub
  End If
  
  ThisApplication.Utility.WaitCursor = False
  If Count = 0 Then
    Msgbox "Нет доступных для создания, видов изыскания.", vbExclamation
    Form.Close
  End If
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

Sub Form_BeforeClose(Form, Obj, Cancel)
  If ThisForm.Dictionary.Item("FORM_KEY_PRESSED") = True Then
    Set Tree = Form.Controls("TREE").ActiveX
    Root = Tree.RootItem
    'Если нет ниодного флага в дереве
    If Tree.GetCheck(Root) = False Then
      Msgbox "Вы не выбрали ни одного вида изысканий", vbExclamation
      Cancel = True
      Exit Sub
    End If
    'Создаем объекты
    Set Dict = ThisApplication.Dictionary("SurvTree")
    If Dict.Exists("Handle") Then
      Handle = Dict.Item("Handle")
      Set Obj = ThisApplication.Utility.GetObjectByHandle(Handle)
      Count = 0
      ThisApplication.Utility.WaitCursor = True
      Call TreeLoopCheckCreate(Obj,Tree,Root,Count)
      ThisApplication.Utility.WaitCursor = False
      Msgbox "Создано " & Count & " видов изысканий.", vbInformation
    Else
      Exit Sub
    End If
  End If
End Sub

'Процедура поиска по дереву отмеченных узлов для создания объектов
Sub TreeLoopCheckCreate(Obj,Tree,hItem,Count)
  hChild = Tree.GetChildItem(hItem)
  If hChild <> 0 Then
    Set Child = ObjCreate(Obj,Tree,hChild,Count)
    If not Child is Nothing Then
      Call TreeLoopCheckCreate(Child,Tree,hChild,Count)
    End If
  Else
    Exit Sub
  End If
  Do While Tree.GetNextSiblingItem(hChild) <> 0
    hChild = Tree.GetNextSiblingItem(hChild)
    If hChild <> 0 Then
      Set Child = ObjCreate(Obj,Tree,hChild,Count)
      If not Child is Nothing Then
        Call TreeLoopCheckCreate(Child,Tree,hChild,Count)
      End If
    Else
      Exit Sub
    End If
  Loop
End Sub

'Функция создания объекта
Function ObjCreate(Parent,Tree,hChild,Count)
  Set ObjCreate = Nothing
  If Tree.GetCheck(hChild) = True Then
    Data = Tree.GetItemData(hChild)
    Set Clf = ThisApplication.Classifiers.FindBySysId(Data)
    If not Parent is Nothing and not Clf is Nothing Then
      ThisScript.SysAdminModeOn
      Set ObjCreate = Parent.Objects.Create("OBJECT_SURV")
      ObjCreate.Attributes("ATTR_S_SURV_TYPE").Classifier = Clf
      'ObjCreate.Update
      ThisScript.SysAdminModeOff
      Count = Count + 1
    End If
  End If
End Function


