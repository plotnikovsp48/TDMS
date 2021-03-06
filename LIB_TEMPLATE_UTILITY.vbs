'=============================
Function GetAttributeValuesFromQuery(ObjType, AttrType)

  Set GetAttributeValuesFromQuery = Nothing

  ' создаём запрос
  set query = thisApplication.CreateQuery()
  ' указываем тип объектов, из которого будем собирать значения аттрибутов
  query.AddCondition tdmQueryConditionObjectDef, ObjType
  
  Set result = query.Objects
  Dim entryCollection()
  ReDim entryCollection(result.Count)
  i = 0
  
  For Each obj in result
    ' получаем искомый аттрибут
    Set attr = obj.Attributes(AttrType)

    ' получаем значение аттрибута
    entry = attr.Value
    
    ' добавляем в коллекцию
    entryCollection(i) = entry
    i = i + 1
  Next
  
  GetAttributeValuesFromQuery = entryCollection
End Function

'=============================
' собираем значения поля в таблице, которая является аттрибутом некоторого типа объектов
Function GetGridAttributeValuesFromQuery(ObjType, GridName, AttrType, PrintAttr, ObjAttr)

  GetGridAttributeValuesFromQuery = _
      Base_GetGridAttributeValuesWithConditionFromQuery( _
          ObjType, GridName, AttrType, _
          PrintAttr, ObjAttr, _
          False , Nothing, Nothing, Nothing)

End Function

'=============================
' собираем значения поля в таблице, которая является аттрибутом некоторого типа объектов
' а заодно накладываем условие, что в столбце ConditionType таблицы ConditionList
' того же объекта есть значение ConditionValue 
Function GetGridAttributeValuesWithConditionFromQuery(ObjType, GridName, AttrType, _
  PrintAttr, ObjAttr, _
  ConditionList, ConditionType, ConditionValue)
  
  GetGridAttributeValuesWithConditionFromQuery = _
      Base_GetGridAttributeValuesWithConditionFromQuery( _
          ObjType, GridName, AttrType, _
          PrintAttr, ObjAttr, _
          True , ConditionList, ConditionType, ConditionValue)
  
End Function

'=============================
' собираем значения поля в таблице, которая является аттрибутом некоторого типа объектов
Function Base_GetGridAttributeValuesWithConditionFromQuery(ObjType, GridName, AttrType, _
              PrintAttr, ObjAttr, _
              NeedCondition, ConditionList, ConditionType, ConditionValue)

  Set Base_GetGridAttributeValuesWithConditionFromQuery = Nothing

  set query = thisApplication.CreateQuery()
  query.AddCondition tdmQueryConditionObjectDef, ObjType
  
  ' чтобы получить список из всех значений аттрибута из всех объектов, 
  ' нужно создать массив и добавить в неё все аттрибуты
      
  Set result = query.Objects
  maxItem = 0 'result.Count
  Dim entryCollection()
  'ReDim entrycollection(maxItem)
  i = 0
  
  ' проходимся по всем спискам шаблонов
  For Each obj in result: Do
  
    ' если объект списка не удовлетворяет нашему условию (заданный тип не содержится в списке типов) - пропускаем
    If NeedCondition Then
      skipping = True
      Set condList = obj.Attributes(ConditionList)
      If condList.Rows.Count = 0 Then Exit Do
      For Each row In condList.Rows
        If row.Attributes(ConditionType).Value = ConditionValue Then
          skipping = False
          Exit For
        End If
      Next
    
      If skipping Then Exit Do
  
    End If ' NeedCondiion
  
    ' получаем таблицу
    Set list = obj.Attributes(GridName)
    Dim listName
    listName = ""
    
    maxItem = maxItem + list.Rows.Count
    ReDim Preserve entrycollection(maxItem)
        
    ' нужно для обозначения названия таблицы, откуда взято отдельное значение.
    ' В принципе, вместо названия здесь можно запрашивать любой аттрибут, лишь бы его потом можно было &
    If PrintAttr Then listName = obj.Attributes(ObjAttr).Value
    
    ' проходимся по содержимому таблицы
    For each row in list.Rows
      If i = maxItem Then Exit For
      Dim entry
      
      ' получаем отдельный шаблон
      Set attr = row.Attributes(AttrType)
      entry = attr.Value
      'MsgBox entry
      ' добавляем в коллекцию
      If PrintAttr Then entry = entry & " {" & listName & "}"
      
      entryCollection(i) = entry 
      
      i = i + 1
    Next
  Loop While False: Next
    
  Base_GetGridAttributeValuesWithConditionFromQuery = entryCollection
End Function

'=============================
Function IsModifiedCollection(OldCollection, NewCollection)
  IsModifiedCollection = False
  
   ' проверка на то, что диалог мы закрыли через ок, но на самом деле ничего не изменили
  If NewCollection.Count <> OldCollection.Count Then
    ' если не равно количество типов объектов - точно что-то изменилось
    IsModifiedCollection = True
  Else
    ' если хотя бы одного объекта из нового списка нету в старом - есть изменения
    For Each obj in NewCollection
      If OldCollection.Has(obj) = False Then
        IsModifiedCollection = true
      End If
    Next
  End If
  
End Function

'=============================
' находит первый попавшийся объект заданного типа с заданным значением заданного атрибута
Function FindObjectByAttrValue(ObjType, AttrType, AttrValue)
  Set sFindObjectByAttrValue = Nothing
  
  For Each el In ThisApplication.ObjectDefs(ObjType).Objects
    If el.Attributes(AttrType) = AttrValue Then
      Set FindObjectByAttrValue = el
      Exit Function
    End If
  Next
  
End Function

'=============================
Function IsValInArray(Val, ValArray)
  ' если введённый текст есть в ComboItems
  IsValInArray = False
  For Each el in ValArray 
    If Val = el Then
      IsValInArray = True
      Exit For
    End If
  Next
End Function

'=============================
Function TrimTextAfterToken(OrigText, TrimToken)
  TrimTextAfterToken = OrigText
  pos = InStrRev(OrigText, TrimToken)
  If pos > 0 Then
    TrimTextAfterToken = Left(origText, pos-1)
  End If
End Function

'=============================
Function CreateTemplateList(TemplateListName, AttrType)

  Set CreateTemplateList = Nothing

  ' FIXME: если недостаточно прав - сообщаем об этом
  ThisScript.SysAdminModeOn

  ' создаём новый объект в коллекции объектов, принадлежащих описанию типа
  Set objects = ThisApplication.ObjectDefs("OBJECT_TEMPLATE_LIST").Objects
  Set newObj = objects.Create("OBJECT_TEMPLATE_LIST")
  
  ' в качестве имени устанавливаем что-нибудь этакое по умолчанию
  newObj.Attributes("ATTR_TEMPLATE_LIST_NAME").Value = TemplateListName
  
  ' указываем данный тип атрибута
  If AttrType <> "" Then
    Set row = newObj.Attributes("ATTR_TEMPLATE_TYPES").Rows.Create
    row.Attributes("ATTR_TEMPLATE_ENTRY_TYPE").Value = AttrType
  End If
  
  Set CreateTemplateList = newObj
  ThisScript.SysAdminModeOff

End Function

'=============================
Function AddEntryToArray(Arr, Entry)

  If IsEmpty(Arr) Then
    Dim tmp()
    ReDim tmp(0)
    Arr = tmp
  End If
  
  strLen = UBound(Arr) + 1 ' получаем крайний индекс и "+1" для получения длины (отсчёт от нуля)
  ReDim Preserve Arr(strLen+1) ' добавляем ещё одну позицию к массиву
  Arr(strLen) = Entry
  
  AddEntryToArray = Arr
End Function

'====================================
Sub OnAttrWithTemplatesModified(AttrType)
  set ctrl = thisForm.Controls(AttrType).ActiveX
  
  ' если выбрана последняя строка - "создать новый список"
  If IsArray(ctrl.ComboItems) Then
    tmpStr = ctrl.Text
    tmpArr = ctrl.ComboItems
    bnd = UBound(tmpArr)
    
    ' делаем проверки на то, выбрали ли мы одну из последних двух строк
    CreateNewList = False ' последняя строка - добавить новый
    ChooseList = False    ' предпоследняя - выбрать существующий
  
    ' если введённый текст есть в ComboItems
    If IsValInArray(ctrl.Text, ctrl.ComboItems) Then
      If GetElInArray(ctrl.ComboItems, bnd) = ctrl.Text Then
        CreateNewList = True
      ElseIf GetElInArray(ctrl.ComboItems, bnd-1) = ctrl.Text Then
        ChooseList = True
      End If
      
      tmpStr = TrimTextAfterToken(ctrl.Text, " {") ' все строчки снабжаются "комментарием"
      
      If CreateNewList Or ChooseList Then ' обрезаем звёздочку с пробелом
        If Left(tmpStr,1) = "*" Then
          tmpStr = Right(tmpStr, Len(tmpStr)-2)
        End If
      End If
  
      ctrl.Text = tmpStr ' присваиваем один раз, чтобы текст не "мигал"
      
      If CreateNewList Then
        ' диалог выбора имени
        'Set dlg = ThisApplication.Dialogs.SimpleEditDlg
        result = InputBox("Введите название нового списка шаблонов:", "Выбор имени списка", "") '_
         ' "Список шаблонов атрибута " & AttrType)
        
        If result <> "" Then
        
          Set newObj = CreateTemplateList(result, AttrType)
          
          ' добавить нашу текущую строку в список шаблонов
          Set row = newObj.Attributes("ATTR_TEMPLATE_LIST").Rows.Create
          row.Attributes("ATTR_TEMPLATE_ENTRY").Value = ctrl.Text
          
          newObj.Update
          
          ' надо обновить ComboItems - к нам добавился новый список!
          OnAttrWithTemplatesRefreshComboItems(AttrType)
        End If
      ElseIf ChooseList Then
        Set dlg = ThisApplication.Dialogs.SelectDlg
        set query = thisApplication.CreateQuery()
        
        ' находим все списки шаблонов
        query.AddCondition tdmQueryConditionObjectDef, "OBJECT_TEMPLATE_LIST"
        dlg.SelectFrom = query.Objects
        dlg.Show        
        
        ' получаем выбранный список и добавляем в него
        Set list = dlg.Objects
        
        If list.Count > 0 Then
          ' по идее, пользователь должен выбрать только один объект.
          ' поскольку управлять возможностью мы не можем, разрешаем добавлять значения в несколько списков
          For Each obj In list: Do
            ' если не хватает прав изменять данный объект - выдаём ошибку
            If obj.Permissions.Edit = 0 Then
              MsgBox "Отсутствуют права записи в список """ & obj.Description & """!"
              Exit Do ' вместо continue
            End If

            ' если файл заблокирован, но не нами - выдаём ошибку
            If obj.Permissions.Locked And Not obj.Permissions.LockOwner Then
              MsgBox "Объект заблокирован пользователем " & obj.Permissions.LockUser & "!"
              Exit Do ' вместо continue
            End If
                      
            ' добавить текущую строку в список шаблонов
            Set row = obj.Attributes("ATTR_TEMPLATE_LIST").Rows.Create
            row.Attributes("ATTR_TEMPLATE_ENTRY").Value = ctrl.Text
            
            ' получается, мы не проверяем, используется ли выбранный список для шаблонов данного типа
            ' оставляем на пользователя? Если захочет, добавит в любой, а потом будет использовать его 
            ' для своего поля
            
            obj.Update
            
          Loop While False: Next
          
          ' надо обновить ComboItems - добавили новый шаблон!
          OnAttrWithTemplatesRefreshComboItems(AttrType)

        End If 'list.Count > 0
      End If 'If CreateNewList ElseIf ChooseList
    End If 'IsValInArray
  End If 'If IsArray(ctrl.ComboItems)
End Sub 'OnAttrWithTemplatesModified(AttrType)

'==================================
Sub OnAttrWithTemplatesBeforeAutoComplete(AttrType, Text)
  set ctrl = thisForm.Controls(AttrType).ActiveX
  
  If IsArray(ctrl.ComboItems) Then
    tmpArr = ctrl.ComboItems ' обходим такую штуку, что напрямую нельзя обратиться к ctrl.ComboItems(i)
      ' можно себе это объяснить, как то, что ComboItems не обладает оператором ()
      ' но поскольку в ComboItems хранится массив, мы можем его извлечь и обратиться к нему
    bnd = UBound(ctrl.ComboItems) 
    tmpArr(bnd-1) = "* " & Text & " { - Добавить в существующий список... - }"
    tmpArr(bnd) = "* " & Text & " { - Добавить в новый список... - }"
    ctrl.ComboItems = tmpArr
  End If
  
End Sub

'==================================
Sub OnAttrWithTemplatesRefreshComboItems(AttrType)
  Set ctrl = thisForm.Controls(AttrType).ActiveX
  
  ctrl.ComboItems = _
    GetGridAttributeValuesWithConditionFromQuery( _
      "OBJECT_TEMPLATE_LIST", "ATTR_TEMPLATE_LIST", "ATTR_TEMPLATE_ENTRY", _
      True, "ATTR_TEMPLATE_LIST_NAME", _
      "ATTR_TEMPLATE_TYPES", "ATTR_TEMPLATE_ENTRY_TYPE", AttrType)
      
  ctrl.ComboItems = AddEntryToArray(ctrl.ComboItems, "")  ' добавить в существующий список
  ctrl.ComboItems = AddEntryToArray(ctrl.ComboItems, "")  ' добавить в новый список
End Sub

'====================================
' потому что мы не можем напрямую обратиться к ComboItems(Index)
Function GetElInArray(Arr, Index)
  Set GetElInArray = Nothing

  If IsArray(Arr) Then GetElInArray = Arr(Index)

End Function
