'option explicit
thisscript.SysAdminModeOn
'нужно отгрузить Елене
'потом скинуть на проверку Сергею
Dim goToBack', goToBack2
goToBack = 0
'goToBack2 = 2
dim nameDict, indexDict, additionalNameForSubNames
 set nameDict = thisApplication.Dictionary("union_kdN")
 set indexDict = thisApplication.Dictionary("union_kdI")
 
 dim index
'Мой комбобокс===================================================================================================
function MyComboBox(AttributesArray)'вывод диалогового окна с выбором значений и вводом собственного
  dim actionCount, i, AttributeDescription
  AttributeDescription = AttributesArray(0).Description
  actionCount = 2
  set MyComboBox = AttributesArray(0)
  dim selDlg, RetVal, curStr, objs
  set selDlg = ThisApplication.Dialogs.SelectDlg
  selDlg.SelectFrom = AttributesArray 
  selDlg.Prompt = "Выберите значение для атрибута " & AttributeDescription
  RetVal = selDlg.Show
  dim sldlgObjs, sldlgObjsCount
  sldlgObjs = selDlg.Objects
  sldlgObjsCount = ubound(sldlgObjs)+1 
  while sldlgObjsCount<>1 'не выпускать из диалога при отмене и выбором больше 1 значения
    if RetVal = false then'если отмена, то откатываем изменения и выходим из функции
      goToBack = 1
      'goToBack2 = 1
     ' ThisApplication.AbortTransaction
    exit function
  end if
    RetVal = selDlg.Show'показ
    if RetVal <> false then
      sldlgObjs = selDlg.Objects
      sldlgObjsCount = ubound(sldlgObjs)+1
      if sldlgObjsCount<>1 then RetVal=false
    else
       goToBack = 1  
      'goToBack2 = 2 
       'ThisApplication.AbortTransaction   
      exit function
    end if
  Wend
  
  if RetVal = false then'если отмена, то откатываем изменения и выходим из функции
    goToBack = 1
    'ThisApplication.AbortTransaction
    exit function
  end if
'  while RetVal=false or sldlgObjsCount<>1 'не выпускать из диалога при отмене и выбором больше 1 значения
'    RetVal = selDlg.Show'показ
'    if RetVal <> false then
'      sldlgObjs = selDlg.Objects
'      sldlgObjsCount = ubound(sldlgObjs)+1
'      if sldlgObjsCount<>1 then RetVal=false
'    end if
'  Wend
      
  objs=selDlg.Objects
  set curStr = objs(0)
  set MyComboBox=curStr
end function
'================================================================================================================

'Перепривзяка по родителям=======================================================================================
sub ChangeParent(obj, oldPar, newPar)
   obj.Parent = newPar
   'if not newPar.objects.has(obj) then
      newPar.objects.Add obj
   'end if
   if isEmpty(nameDict(obj.attributes("ATTR_CORR_ADD_FIO").value)) then
    set nameDict(obj.attributes("ATTR_CORR_ADD_FIO").value) = thisApplication.CreateCollection(tdmCollection)
   end if
   if isEmpty(indexDict(obj.attributes("ATTR_CORR_ADD_FIO").value)) then
    set indexDict(obj.attributes("ATTR_CORR_ADD_FIO").value) = thisApplication.CreateDictionary
   end if
   
   nameDict(obj.attributes("ATTR_CORR_ADD_FIO").value).add obj.attributes("ATTR_COR_USER_NAME").value
   'nameDict(obj.attributes("ATTR_CORR_ADD_FIO").value) = obj.attributes("ATTR_COR_USER_NAME").value
   'indexDict(obj.attributes("ATTR_CORR_ADD_FIO").value) = index
   indexDict(obj.attributes("ATTR_CORR_ADD_FIO").value)(obj.attributes("ATTR_COR_USER_NAME").value) = index
   index = index + 1
   oldPar.objects.Remove obj
end sub
'================================================================================================================
sub unionCorr(obj, newPar)
 if not obj.Parent is nothing then
    obj.Parent = newPar  
 end if
 ' set union
 dim col 
 set col = thisApplication.CreateCollection(tdmCollection) 

 col.add newPar.objects(indexDict(obj.attributes("ATTR_CORR_ADD_FIO").value)(obj.attributes("ATTR_COR_USER_NAME").value))
 col.add obj
 generalUnion(col)
 if goToBack = 1 then
  exit sub
 end if
 if not obj.Parent is nothing then
  obj.erase
 end if
end sub

sub generalUnion(curObjects)
 ' goToBack2 = 0
  objCount = curObjects.Count
    set nullAttributes = curObjects(0).Attributes
    attrCount = nullAttributes.Count
      'on error resume next
    for i=1 to objCount-1
      set curAttributes = curObjects(i).Attributes
      for j=0 to attrCount-1
        if nullAttributes(j).Value<>curAttributes(j).Value and curAttributes(j).Value<>"" then
          if nullAttributes(j).Value ="" then
            nullAttributes(j) = curAttributes(j)
          else
            nullAttributes(j) = MyComboBox(Array(nullAttributes(j), curAttributes(j)))
          end if
        end if     
        if goToBack = 1 then
          exit sub
        end if
      next
      if goToBack = 1 then
        exit sub
      end if
      if not curObjects(i).objects is Nothing then
        for each j in curObjects(i).objects'обьединение контактных лиц
          if isEmpty(nameDict(j.attributes("ATTR_CORR_ADD_FIO").value)) then
            ChangeParent j, curObjects(i), curObjects(0)
          elseif not nameDict(j.attributes("ATTR_CORR_ADD_FIO").value).has(j.attributes("ATTR_COR_USER_NAME").value) then
            ChangeParent j, curObjects(i), curObjects(0)
          else
            unionCorr j, curObjects(0)
          end if
          if goToBack = 1 then
            exit sub
          end if
        next
      end if
      if goToBack = 1 then
        exit sub
      end if
    next

  
  '==============================================================================
  'if goToBack2 = 1 then'откат изменений
  if goToBack = 1 then'откат изменений
    exit sub
  end if
  dim k, g, curobj, curattr, hk, hc, row,g_element,g_element_attribute, row_attribute
  
  'Просмотр связей и их замещение первым=========================================
  for i=1 to objCount-1 'бежим по объектам
    set curobj=curObjects(i)
    'attrCount = curobj.Attributes.Count
    for each j in curobj.ReferencedBy 'по связям объектов

      for each g in j.Attributes 'по атрибутам связей ATTR_KD_TCP
        if (not g.Object is nothing) then
          if g.Object.guid = curobj.guid or (g.Object.ObjectDefName = "OBJECT_CORR_ADDRESS_PERCON") then
            g.Object = curObjects(0)
          end if
        end if

        if g.rows.count > 0 then
          for each row in g.rows
            for each row_attribute in row.attributes
              if (not row_attribute.Object is nothing) then
                if row_attribute.Object.guid = curobj.guid or row_attribute.Object.ObjectDefName = "OBJECT_CORRESPONDENT"  then'добавленное PlotnikovSP 15.02.2018
                  row_attribute.Object = curObjects(0)
                end if
              end if
            next
          next
        end if
      next
    next
  next
end sub



'Основная функция слияния========================================================================================
sub unionObjectsInQuery(UnionMessage, UnionQuery)
  goToBack = 0
  index = 0
  if thisapplication.IsActiveTransaction then
    thisapplication.CommitTransaction
  end if
 ' thisApplication.CreateCollection
  nameDict.RemoveAll
  indexDict.RemoveAll
 
  
  Dim selDlg, query, curObjects, objCount, i, j, attrCount, nullAttributes, curAttributes
  set selDlg = ThisApplication.Dialogs.SelectDlg
  
  selDlg.Caption = UnionMessage
  set query = ThisApplication.Queries(UnionQuery)
  selDlg.SelectFrom = query.sheet
  
  if selDlg.Show = true then'показ 
  

  'Слияние первого с остальными=================================================='
    set curObjects = selDlg.Objects.Objects
    if not curObjects(0).objects is Nothing then'заполнение словаря сотрудников
      'for each j in curObjects(0).objects
      for index = 0 to curObjects(0).objects.count-1
        set obj = curObjects(0).objects(index)
       if isEmpty(nameDict(obj.attributes("ATTR_CORR_ADD_FIO").value)) then
        set nameDict(obj.attributes("ATTR_CORR_ADD_FIO").value) = thisApplication.CreateCollection(tdmCollection)
       end if
       if isEmpty(indexDict(obj.attributes("ATTR_CORR_ADD_FIO").value)) then
        set indexDict(obj.attributes("ATTR_CORR_ADD_FIO").value) = thisApplication.CreateDictionary
       end if
        nameDict(obj.attributes("ATTR_CORR_ADD_FIO").value).add obj.attributes("ATTR_COR_USER_NAME").value
        indexDict(obj.attributes("ATTR_CORR_ADD_FIO").value)(obj.attributes("ATTR_COR_USER_NAME").value) = index
        'index = index+1
      next
      index = curObjects(0).objects.count
    end if
   
   
   'общая часть как для корреспондентов, так и для сотрудников
    thisapplication.StartTransaction   
    objCount = curObjects.Count
    set nullAttributes = curObjects(0).Attributes
    attrCount = nullAttributes.Count
      'on error resume next
    for i=1 to objCount-1
      set curAttributes = curObjects(i).Attributes
      for j=0 to attrCount-1
        'if not isEmpty(curAttributes(nullAttributes(j).AttributeDefName)) then
        if curAttributes.has(nullAttributes(j).AttributeDefName) then
        if nullAttributes(j).Value<>curAttributes(j).Value and curAttributes(nullAttributes(j).AttributeDefName).Value<>"" then
          if nullAttributes(j).Value ="" then
            nullAttributes(j) = curAttributes(j)
          else
            nullAttributes(j) = MyComboBox(Array(nullAttributes(j), curAttributes(j)))
          end if
        end if     
        if goToBack = 1 then
          exit sub
        end if
        end if
      next
      if not curObjects(i).objects is Nothing then
        for each j in curObjects(i).objects'обьединение контактных лиц
          if isEmpty(nameDict(j.attributes("ATTR_CORR_ADD_FIO").value)) then
            ChangeParent j, curObjects(i), curObjects(0)
          elseif not nameDict(j.attributes("ATTR_CORR_ADD_FIO").value).has(j.attributes("ATTR_COR_USER_NAME").value) then
            ChangeParent j, curObjects(i), curObjects(0)
          else
            unionCorr j, curObjects(0)
          end if
        next
      end if
    next
  else
    goToBack = 1
  end if
  
  '==============================================================================
  if goToBack = 1 then'откат изменений ATTR_TENDER_SMS_P_TYPE AttributeDefName
    exit sub
  end if
  dim k, g, curobj, curattr, hk, hc, row,g_element,g_element_attribute, row_attribute
  
  'Просмотр связей и их замещение первым=========================================
  for i=1 to objCount-1 'бежим по объектам
    set curobj=curObjects(i)
    'attrCount = curobj.Attributes.Count
    for each j in curobj.ReferencedBy 'по связям объектов

      for each g in j.Attributes 'по атрибутам связей ATTR_KD_TCP
        if (not g.Object is nothing) then
          if g.Object.guid = curobj.guid or g.Object.ObjectDefName = "OBJECT_CORRESPONDENT" then
            g.Object = curObjects(0)
          end if
        end if

        if g.rows.count > 0 then
          for each row in g.rows
            for each row_attribute in row.attributes
              if (not row_attribute.Object is nothing) then
                if row_attribute.Object.guid = curobj.guid or row_attribute.Object.ObjectDefName = "OBJECT_CORRESPONDENT"  then'добавленное PlotnikovSP 15.02.2018
                  row_attribute.Object = curObjects(0)
                end if
              end if
            next
          next
        end if
      
      

      next
    next
  next
  '==============================================================================
  if goToBack = 1 then'откат изменений
    exit sub
  end if
  'Удаление лишних уже без связей================================================
  'on error resume next
  thisapplication.CommitTransaction
  'странная ошибка без разделения транзакции!!!
  thisapplication.StartTransaction
  for i=1 to objCount-1 
    curObjects(i).erase
  next
  '==============================================================================
  thisapplication.CommitTransaction
  MsgBox "Слияние завершено"    
end sub   
'msgbox 1
unionObjectsInQuery "Выберите контрагентов для слияния", "QUERY_KD_CORDENT"
if thisapplication.IsActiveTransaction then _
  thisapplication.AbortTransaction
'unionObjectsInQuery("Выберите контактных лиц для слияния", "QUERY_ALL_KD_PEOPLE")

'нюанс - нужно заменить удаленные объекты там, где они используются

'механизм соединения атрибутов:
  'сливаем все атрибуты в нулевой объект:
    'пробегаем все объекты кроме нулевого и сравниваем их значения атрибутов с ссответствующим атрибутом в нулевом
    'если не нулевой атрибут пустой или равен нулевому, то проскакиваем его на атрибут в следующем объекте
    'иначе: предлагаем пользователю самому выбрать, какой атрибут использовать, либо ввести свой 
      '(создать специальное диалоговое окно)
'profit :)




