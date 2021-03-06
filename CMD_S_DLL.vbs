' Автор: Стромков С.А.
'
' Библиотека функций стандартной версии
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

USE "CMD_DLL"

'==============================================================================
' Функция осуществляет комплексную проверку наличия состава объекта  
' и ссылок на удаляемый объект
'------------------------------------------------------------------------------
' O_:TDMSObject - Удаляемый объект
'==============================================================================
Function CheckBeforeErase(o_)
  CheckBeforeErase=true
  Dim result1,result2
  result1 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckContent", o_)
  if  result1 then Exit Function
  result2 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckReferencedBy", o_) 
  CheckBeforeErase=result1 Or result2
End Function

'==============================================================================
' Функция является модификацией функции Create из библиотеки CMD_DLL
' с возможностью отключения показа окна свойств объекта 
'------------------------------------------------------------------------------
' sObjDef_:String - Системный идентификатор типа создаваемого объекта
' p_:TDMSObject - Родительский объект в составе которого создается новый 
'                 информационный объект
' dlgShow_:Boolean - Метка открытия окна создания объекта. True - открывать, 
'                    False - не открывать
' CreateObj:TDMSObject - Созданный экземпляр объекта
'==============================================================================
Function CreateObj(sObjDef_,p_,dlgShow_)

  Dim o,EditObjDlg,hnd
  Set CreateObj = Nothing
  
  If VarType(p_)<>9 Then Exit Function
  If VarType(dlgShow_)<>11 Then Exit Function
  If  ThisApplication.ObjectDefs.Index(sObjDef_)=-1 Then Exit Function

  If p_ Is Nothing Then
    On Error Resume Next
      Set o = ThisApplication.ObjectDefs(sObjDef_).CreateObject
      hnd =o.Handle
    On Error GoTo 0
  Else
    On Error Resume Next
      Set o = p_.Objects.Create(sObjDef_)
      hnd =o.Handle
    On Error GoTo 0   
  End If
  
  If Err.Number<>0 Then Exit Function
  
  Set o = ThisApplication.Utility.GetObjectByHandle(hnd)
  If o Is Nothing Then Exit Function
  if dlgShow_ then
    Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
    o.Permissions = SysAdminPermissions 
    EditObjDlg.object = o
    EditObjDlg.ParentWindow = ThisApplication.hWnd
    If Not EditObjDlg.Show Then 
      o.Erase 
      Exit Function
    End If
  End If
  Set CreateObj = o
End Function


Sub SetRefToComplex(o_,sAttrDef_)
  if VarType(o_) <>9 Then Exit Sub
  If Not o_.Attributes.Has(sAttrDef_) Then Exit Sub
  Set c_=o_.Attributes(sAttrDef_).Object
  call AddObjLink(o_,c_)
End Sub

'==============================================================================
' Функция возвращает объект из атрибута типа ссылка на объект
'------------------------------------------------------------------------------
'sAttrDef_:SysName атрибута, содержащего ссылку на объект
'o_:TDMSObject - Объект к которому добавляется ссылка
'==============================================================================
Function GetObjFromAttr(o_,sAttrDef_)
  Set GetObjFromAttr=Nothing
  if VarType(o_)<>9 Then Exit Function
  If o_ Is Nothing Then Exit Function
  If Not o_.Attributes.Has(sAttrDef_) Then Exit Function
  Set c_=o_.Attributes(sAttrDef_).Object
  If c_ Is Nothing Then Exit Function
  Set GetObjFromAttr=c_
End Function

'==============================================================================
' Процедура Добавляет к Объекту ссылки на коллекцию объектов
'------------------------------------------------------------------------------
'oColl_:TDMSObjects - Коллекция добавляемых объектов.
'p_:TDMSObject - Объект к которому добавляется ссылка
'==============================================================================
Sub AddObjLinks (oColl_,p_)
  'Входные проверки
  If VarType(p_) <>9 Then Exit Sub
  If p_ Is Nothing Then Exit Sub
  If oColl_.count=0 Then Exit Sub
  For each l in oColl_
    If Not p_.Content.Has(l) then
        Call ThisApplication.ExecuteScript("CMD_S_DLL", "AddObjLink", l,p_) 
    End If
  Next 
End Sub

'==============================================================================
' Добавляет ссылку на объект
'------------------------------------------------------------------------------
' o_:TDMSObject - Объект на который добавляется ссылка
' p_:TDMSObject - Объект в который добавляется ссылка
'==============================================================================
Sub AddObjLink(o_,p_)
  'Входные проверки
  If VarType(o_) <>9 Then Exit Sub
  If VarType(p_) <>9 Then Exit Sub
  If o_ Is Nothing Then Exit Sub
  If p_ Is Nothing Then Exit Sub
  
  p_.Permissions = SysAdminPermissions 
  p_.Content.add(o_)
End Sub


'==============================================================================
' Проверяет наличие объектов уазанног типа в составе объекта
'------------------------------------------------------------------------------
' o_:TDMSObject - Объект в составе которого ищутся объекты
' oDefType_:Строка - Искомый тип объекта
'==============================================================================
Function CheckIfObjInContent(o_,oDefType_)
  Set CheckIfObjInContent=Nothing
  'Входные проверки
  If VarType(o_) <>9 Then Exit Function
  If o_ Is Nothing Then Exit Function

  For each o in o_.Content
    If o.ObjectDefName=oDefType_ Then 
      CheckIfObjInContent = True 
      Exit Function
    Else
      CheckIfObjInContent = False
    End If
  Next
End Function

'==============================================================================
'  Добавление файла к объекту с запросом на добавление или без запроса
'------------------------------------------------------------------------------
'  o_:TDMSObject - Объект, к которому добавляем файл
'  Ask_:Boolean - True - выводит запрос на добавление файла
'               - False - не выводит запрос на добавление файла
'==============================================================================
Sub AddFileToObj (o_,Ask_)
  If Ask_ Then
    answer=ThisApplication.ExecuteScript( "CMD_MESSAGE", "ShowWarning", vbQuestion+vbYesNo, 1210, o_.Description)
    If answer<>vbYes Then Exit Sub
  End If
  Call AddFileDial (o_)
End Sub


'==============================================================================
'  Диалог добавления файла к объекту
'------------------------------------------------------------------------------
'  o_: - объект к которому цеплять файлы
'==============================================================================   
Sub AddFileDial (o_)
    Set Dlg = ThisApplication.Dialogs.AddFileDlg
    Dlg.Object = o_
    Dlg.Show
End Sub

'==============================================================================
'  Добавляет к объекту файл из шаблона объекта
'------------------------------------------------------------------------------
'  AddFileTempl: true - если файл добавлен из шаблона, false - если добавить не удалось
'  o_: - объект к которому цеплять файлы
'  fDef_ : системный идентификатор Типа файла
'  t_: Имя шаблона типа файла
'  f_: Имя файла после прикрепления к карточке объекта
'==============================================================================        
Function AddFileTempl (o_,fDef_,t_,f_)
  AddFileTempl=false
  'if o_.ObjectDef.FileDefs.Has(fDef_) Then
'    Set fDefSignCard = o_.ObjectDef.FileDefs.Item(fDef_)
    Set fDefSignCard = ThisApplication.FileDefs(fDef_)
        if fDefSignCard.Templates.has(t_) then 
          index = fDefSignCard.Templates.Index(t_)
          o_.Permissions = SysAdminPermissions
          o_.Files.AddCopy fDefSignCard.Templates(index), f_
          AddFileTempl=true
        end if
  'End if
End Function


'==============================================================================
' Функция проверяет наличие контента в составе удаляемого объекта. При этом 
' проверяется вся ветвь и игнорируются объекты типа:
' "OBJECT_UTASK_DIR" 
' "OBJECT_DOCS_FOR_CUSTOMER"
' "OBJECT_PROJECT_DOCS_P"
' "OBJECT_PROJECT_DOCS_W"
' "OBJECT_BOD"
' "OBJECT_T_TASKS"
'------------------------------------------------------------------------------
' ПРИНИМАЕТ:
'   O_:TDMSObject - Удаляемый объект
'==============================================================================
Function CheckProjectContent(o_)
  Dim sObjDef
  CheckProjectContent = True
  For Each o In o_.Content
    sObjDef = o.ObjectDefName
    If sObjDef <>"OBJECT_PROJECT_DOCS_I" And sObjDef <> "OBJECT_T_TASKS" And sObjDef <> "OBJECT_UTASK_DIR" And sObjDef <> "OBJECT_PROJECT_DOCS_P" And sObjDef <> "OBJECT_PROJECT_DOCS_W" And sObjDef <> "OBJECT_BOD" Then
      ' And sObjDef <> "OBJECT_DOCS_FOR_CUSTOMER"
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1102, o_.Description
      Exit Function
    End If
    If o.Objects.Count > 0 Then
      if CheckProjectContent(o) then
        Exit Function 
      end if
    End If
  Next
  CheckProjectContent = False
End Function

'==============================================================================
' Получить ссылку на проект
'------------------------------------------------------------------------------
' o_:TDMSObject - Обрабатываемый информационный объект
' value_ - Устанавливаемое значение
'==============================================================================
Function GetProjLink(o_)
  Dim adProjLink
  adProjLink="ATTR_PROJECT"
  Set GetProjLink = Nothing
  If o_.Attributes.Has(adProjLink) Then
    Set GetProjLink = o_.Attributes (adProjLink).Object
  End If
End Function

'==============================================================================
' Установить ссылку на проект
'------------------------------------------------------------------------------
' o_:TDMSObject - Обрабатываемый информационный объект
' value_ - Устанавливаемое значение
'==============================================================================
Private Sub SetProjLink(Obj,value_)
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetAttr", Obj,"ATTR_PROJECT",value_)
End Sub

'==============================================================================
' Установить ссылку на договор
'------------------------------------------------------------------------------
' o_:TDMSObject - Обрабатываемый информационный объект
' value_ - Устанавливаемое значение
'==============================================================================
Private Sub SetContractLink(o_,value_)
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetAttr", o_,"ATTR_CONTRACT",value_)
End Sub

'==============================================================================
' Находит в составе объекта родителя объект у которого такое же значение указанного атрибута
'------------------------------------------------------------------------------
' o_:TDMSObject - Обрабатываемый информационный объект
' attrDefName_ - Проверяемый атрибут
' CheckObjByAttr - результат - количество найденных объектов
'==============================================================================
Public Function CheckObjByAttr(o_, attrDefName_)
  CheckObjByAttr = 0
  
  If Not o_.Attributes.Has(attrDefName_) Then Exit Function
  If o_ Is Nothing Then Exit Function
  Dim p,attr, ob, od, Result
  attr=o_.Attributes(attrDefName_).Value
  Set p=o_.Parent
  Set od=o_.ObjectDef

  for each ob in p.Objects.ObjectsByDef(od)
    Result = IsTheSameObj(ob,o_)
    If Not Result AND ob.Attributes(attrDefName_) = attr Then 
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1203, od.Description, attr , p.Description
      CheckObjByAttr=1
      Exit Function
    End If
  Next 
End Function


'==============================================================================
' Проверяет, являются ли 2 объекта одним и тем же или разные
'------------------------------------------------------------------------------
' o1_:TDMSObject - Обрабатываемый информационный объект 1
' o2_:TDMSObject - Обрабатываемый информационный объект 2
' IsTheSameObj - результат - False - различные
'                            True - один и тот же 
'                            Nothing - сравнение невозможно
'==============================================================================
Function IsTheSameObj(o1_,o2_)
  IsTheSameObj = False
  'Входные проверки
  If VarType(o1_) <>9 Then Exit Function
  If VarType(o2_) <>9 Then Exit Function
  If o1_ Is Nothing Then Exit Function
  If o2_ Is Nothing Then Exit Function
  
  
  If o1_.Handle = o2_.Handle Then IsTheSameObj=True
End Function

'==============================================================================
' Устанавливает значение атрибута на всю ветвь объектов
'------------------------------------------------------------------------------
' oRoot_:TDMSObject - корневой объект ветки
' attr_: - SysID атрибута 
' value_ - Устанавливаемое значение
'==============================================================================
Sub SetAttrToContentAll (oRoot_,attr_,value_)
  Dim o
  'Входные проверки
  If VarType(oRoot_) <>9 Then Exit Sub
  If oRoot_ Is Nothing Then Exit Sub
  If Not ThisApplication.AttributeDefs.Has(attr_) Then Exit Sub
  ' Назначаем атрибут на всю ветку
  For Each o In oRoot_.ContentAll
    o.Permissions = SysAdminPermissions
    If o.Attributes.Has(attr_) Then
      o.Attributes(attr_).Object = value_
    End If
  Next
End Sub

'==============================================================================
' Удаляет все выборки в объекте
'------------------------------------------------------------------------------
' o_:TDMSObject - Объект, в котором удаляются выборки
'==============================================================================
Sub RemoveObjQuery (Obj)
  'Входные проверки
  If VarType(Obj) <>9 Then Exit Sub
  If Obj Is Nothing Then Exit Sub
  For Each Query in Obj.Queries
    Obj.Queries.Remove Query
  Next
End Sub


'==============================================================================
' Функция получения одной организации
'------------------------------------------------------------------------------
' GetCompany:TDMSObject - Контрагент
'==============================================================================
Function GetCompany()
  Set GetCompany = Nothing
  Dim oCol, oCorr
  Set oCol = ThisApplication.Queries("QUERY_S_ENTERPRIZES")
  If oCol Is Nothing Then 
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning",vbExclamation, 1701
    Exit Function
  End If  
  Set oCorr = SelectObjectDialog (oCol,"Выберите только одну организацию:")
  If oCorr is Nothing Then Exit Function
  Set GetCompany = oCorr
End Function

'==============================================================================
' Получение коллекции объектов из выборки
'------------------------------------------------------------------------------
' qName_:String - Системный идентификатор выборки
' GetAddressList:TDMSObjects - коллекция адресов
'==============================================================================
Function GetCollectionByQ (qName_)
  Set GetCollectionByQ = Nothing
  Set q = ThisApplication.Queries(qName_)
  If q.Objects.count = 0 Then
      Exit Function
  End If
  Set GetCollectionByQ = q.Objects
  GetCollectionByQ.sort 1
End Function

'==============================================================================
' Отображение окна с контрагентами
'------------------------------------------------------------------------------
' col_:TDMSObjects - коллекция объектов
' txt_:String - Текст заголовка окна
' SelectDialog:TDMSObjects - коллекция объектов (Первый в списке выбранных)
'==============================================================================
Private Function SelectDialog(col_,txt_)
  Set SelectDialog = Nothing  
  'Окно
  Set SelDlg = ThisApplication.Dialogs.SelectDlg
  SelDlg.Prompt = txt_
  'Объекты
  SelDlg.SelectFrom = col_
  RetVal = SelDlg.Show
  ' Если ничего не выбрано или диалог отменен, выйти
  Set ObjCol = SelDlg.Objects
  If (RetVal<>TRUE) Or (ObjCol.Count=0) Then Exit Function
  'Отбираем только первый выбранный объект
  Set SelectDialog = ObjCol(0)
End Function

'==============================================================================
' Создает нового контрагента
'------------------------------------------------------------------------------
' CreateOrg:TDMSObject - Созданный объект
'==============================================================================
Function CreateOrg()
  Set CreateOrg = Nothing
  set ObjRoots = thisApplication.GetObjectByGUID("{A60FEBB1-E4EF-4DC0-A8B6-32D720FEFBF2}") ' Корреспонденты
  if ObjRoots is nothing then 
      msgbox "Не удалось найти папку Корреспонденты!"
      exit Function
    end if  
  
  ObjRoots.Permissions = SysAdminPermissions
  set objType = thisApplication.ObjectDefs("OBJECT_CORRESPONDENT")
  Set CreateDocObject = ObjRoots.Objects.Create(objType)

 'Инициализация свойств диалога создания объекта
  Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
  CreateObjDlg.Object = CreateDocObject
  ans = CreateObjDlg.Show
  If ans Then
  Set CreateOrg = CreateDocObject
  End If
end Function

'==============================================================================
' Отображение окна с сотрудниками контрагента
'------------------------------------------------------------------------------
' col_:TDMSObjects - коллекция объектов
' txt_:String - Текст заголовка окна
' SelectObjectDialog:TDMSObjects - коллекция объектов
'==============================================================================
Private Function SelectObjectDialog(col_,txt_)
  Set SelectObjectDialog = Nothing  
  'Окно
  Set SelDlg = ThisApplication.Dialogs.SelectDlg
  SelDlg.Prompt = txt_
  'Объекты
  SelDlg.SelectFrom = col_.Sheet

  RetVal = SelDlg.Show
  
  If (RetVal<>TRUE) Then Exit Function
  ' Если ничего не выбрано или диалог отменен, выйти
  Set ObjCol = SelDlg.Objects
  If  (ObjCol.RowsCount=0) Then Exit Function
  'Отбираем только первый выбранный объект
  
  Set SelectObjectDialog = selDlg.Objects
  
End Function

'Public Function SetAttr(o_,sAttrDef_,value_)
'  SetAttr = False
'  If Not o_.Attributes.Has(sAttrDef_) Then Exit Function
'  o_.Permissions = SysAdminPermissions 
'  Dim sAttrType
'  Set attr = o_.Attributes(sAttrDef_)
'  sAttrType = attr.Type
'  Select Case sAttrType
'    Case 6, 8 ' Классификатор (TDMSClassifier).
'        attr.Classifier = aOut_.Classifier
'    Case 7 ' Ссылка на объект (TDMSObject) 
'      If Not value_ Is Nothing Then
'        If Not attr.Object Is Nothing Then
'          If o_.Attributes(sAttrDef_).Object.Handle <> value_.Handle Then
'            attr.Object = value_
'          End If
'        Else
'          attr.Object = value_
'        End If
'      Else 
'        o_.Attributes(sAttrDef_).Object = Nothing
'      End If
'    Case 9 ' Ссылка на пользователя (TDMSUser).
'        attr.User = aOut_.User
'    Case 11 ' Таблица (TDMSTableAttribute).
'        Call CopyTable(aOut_.Rows,aIn_.Rows)
'    Case Else
'        attr.Value = aOut_.Value
'  End Select
'  SetAttr = True
'End Function  
  
'==============================================================================
' Функция возвращает объект по типу объекта из вышестоящих по иерархии
'------------------------------------------------------------------------------
' oDefName_:SysName типа объекта, который ищем
' o_:TDMSObject - Искомый объект из вышестоящих по иерархии
'==============================================================================
Function GetUplinkObj(o_,oDefName_)
  Set GetUplinkObj=Nothing
  if VarType(o_)<>9 Then Exit Function
  if ThisApplication.ObjectDefs.Has(oDefName_) = False Then Exit Function
  Check = False
  Set p = o_.parent 
  If p Is Nothing Then Exit Function
  If p.ObjectDefName = "ROOT_DEF" Then Exit Function
  If p.ObjectDefName <> oDefName_ Then
    Set GetUplinkObj = GetUplinkObj(p,oDefName_)
  Else
    Set GetUplinkObj = p
  End If
End Function

'==============================================================================
' Функция возвращает объект из атрибута типа ссылка на объект
'------------------------------------------------------------------------------
' oDefName_:SysName типа объекта, который ищем
' o_:TDMSObject - Объект к которому добавляется ссылка
'==============================================================================
Function GetStage(o_)
  Set GetStage = Nothing
  if VarType(o_)<>9 Then Exit Function
  If o_.IsKindOf("OBJECT_STAGE") Then 
    Set GetStage = o_
    Exit Function
  End If
  Set GetStage = GetUplinkObj(o_,"OBJECT_STAGE")
End Function


Function CopyTask(o_)
  CopyTask = false 
  ThisScript.SysAdminModeOn
  Set ObjRoots = o_.Parent
  If  ObjRoots is nothing then  
    MsgBox "Не удалось создать задание", vbCritical, "Объект не был создан"
    Exit Function
  End If
  Set newtask = Nothing
  ObjRoots.Permissions = SysAdminPermissions
  Set newtask = ObjRoots.Objects.Create(o_.ObjectDef)

  if newtask is nothing then 
    msgbox "Не удалось создать задание", vbCritical, "Ошибка"
    exit function
  end if
  
  if not CopyDocAttrs(o_,newtask) then 
    msgbox "Не удалось скопировать атрибуты документа", vbCritical, "Ошибка"
    exit function
  end if
  
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetAttr_F", newtask,"ATTR_T_TASK_LINK",o_,True)
  
  Call ThisApplication.ExecuteScript("FORM_S_TASK", "SetCode", newtask)
  
  newtask.update  
  Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
  CreateObjDlg.Object = newtask
  ans = CreateObjDlg.Show
  If not ans then 
'    Set oPlanTask = GetPlanTaskLink(newtask)
    Set oPlanTask = ThisApplication.ExecuteScript("CMD_PLAN_TASK_LIB","GetPlanTaskLink",newtask)
    If Not oPlanTask Is Nothing Then oPlanTask.erase
    newtask.erase
    Exit Function
  End If

  CopyTask = true
end function    


Function CopyDocAttrs(docObj,newDoc) 
  CopyDocAttrs = false
  set deftype = docObj.ObjectDef
    if not thisApplication.Attributes.Has("ATTR_KD_COPY_ATTRS") then exit function
    set rows = thisApplication.Attributes("ATTR_KD_COPY_ATTRS").Rows
    for each row in rows
      if row.Attributes(0).value = deftype.SysName then 
        attrName = row.Attributes(1).value & "," & attrName
      end if
    next
    call AttrsSyncBetweenObjs(docObj,newDoc,attrName)
  CopyDocAttrs = true
end function


Function ObjExist (t_, attr_, o_)
  ObjExist = True
  If VarType(o_)<>9 Then Exit Function
  If t_ Is Nothing Then Exit Function
  If o_ Is Nothing Then Exit Function
  Set Rows = t_.Rows
  For Each row In Rows
    If Not row.Attributes.Has(attr_) Then Exit Function
      If IsTheSameObj(row.attributes(attr_).Object,o_) Then 
        Exit Function
      End If
  Next
  ObjExist = False
End Function

'==============================================================================
' Ищет объекты такого же типа с указанным атрибутом и значением
' Для проверки уникальности атрибута, если в свойствах атрибута уникальность не установлена
' IsObjectByAttrExist: Boolean  True - объекты найдены
'                               False - объекты не найдены 
'==============================================================================
Function IsObjectByAttrExist(Obj,aDefName,Value)
  IsObjectByAttrExist = False
  If Obj Is Nothing Then Exit Function
  
  Set oDef = Obj.ObjectDef
  
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, oDef
  q.AddCondition tdmQueryConditionAttribute, Value, aDefName
  If q.Objects.count > 0 Then
    IsObjectByAttrExist = True
    Exit Function
  End If 
End Function

Sub SetContractStage(Obj, attr)
  If Not Obj.Attributes.Has(attr) Then Exit Sub
  Select Case Obj.ObjectDefName
  Case "OBJECT_CONTRACT_COMPL_REPORT"
    Set oContr = Obj.Attributes("ATTR_CONTRACT").Object
    If oContr Is Nothing Then Exit Sub
    Set oStage = SelStagesByContract(oContr)
  Case Else
    Set oStage = SelStage(Obj)
  End Select
  If Not oStage Is Nothing Then
    Obj.Attributes(attr).Object = oStage
  End If
End Sub

Function PickContractStage(obj)
  Set PickContractStage = Nothing
  
  If Not obj.Attributes.Has("ATTR_CONTRACT_STAGE") Then Exit Function
  If "OBJECT_CONTRACT_COMPL_REPORT" = obj.ObjectDefName Then
    Dim c
    Set c = obj.Attributes("ATTR_CONTRACT").Object
    If c Is Nothing Then Exit Function
    Set PickContractStage = SelStagesByContract(c)
    Exit Function
  End If
  Set PickContractStage = SelStage(obj)
End Function

Sub ContractStageDelete(Obj)
  If Obj.Attributes.Has("ATTR_CONTRACT_STAGE") Then
    Obj.Attributes("ATTR_CONTRACT_STAGE").Object = Nothing
  End If
End Sub  

Function PickBuildingStage(obj)
  Set PickBuildingStage = Nothing
  
'  If Not obj.Attributes.Has("ATTR_CONTRACT_STAGE") Then Exit Function

  Set PickBuildingStage = SelBuildStage(obj)
End Function

Sub BuildingStageDelete(Obj)
  If Obj.Attributes.Has("ATTR_BUILDING_STAGE") Then
    Obj.Attributes("ATTR_BUILDING_STAGE").Object = Nothing
  End If
End Sub  

Function SelStage(Obj)
  Set SelStage = Nothing
  Set q = ThisApplication.Queries("QUERY_CONTRACT_STAGES_FOR_PROJECT")
  q.Parameter("PARAM0") = Obj
  If q.Objects.count = 0 Then
    q.Parameter("PARAM0") = Obj.Parent
  End If  
    
    If q.Objects.count = 0 Then
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1701
      Exit Function
    End If  

  Set oStage = SelectObjDlg(q.Objects)
  
  If Not oStage Is Nothing Then 
    Set SelStage = oStage
  End If
End Function

Function SelStagesByContract(Obj)
  Set SelStagesByContract = Nothing
  Set q = ThisApplication.Queries("QUERY_CONTRACT_STAGES_BY_CONTRACT")
  q.Parameter("PARAM0") = Obj

    If q.Objects.count = 0 Then
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1701
      Exit Function
    End If  

  Set oStage = SelectObjDlg(q.Objects)
  
  If Not oStage Is Nothing Then 
    Set SelStagesByContract = oStage
  End If
End Function

Function SelBuildStage(Obj)
  Set SelBuildStage = Nothing
  Set q = ThisApplication.Queries("QUERY_BUILDING_STAGES_FOR_PROJECT")
  q.Parameter("PARAM0") = Obj
  If q.Objects.count = 0 Then
    q.Parameter("PARAM0") = Obj.Parent
  End If  
    
    If q.Objects.count = 0 Then
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1701
      Exit Function
    End If  

  Set oStage = SelectObjDlg(q.Objects)
  
  If Not oStage Is Nothing Then 
    Set SelBuildStage = oStage
  End If
End Function
'==============================================================
' Копирует значение атрибута на объекты
'--------------------------------------------------------------
' Obj:TDMSObject - объект-источник
' oColl:TDMSObjects - коллекция объектов, на которую копируется значение атрибута
' aDefName: Системное имя атрибута
'============================================================== 
Sub SetCascadeAttr(Obj, oColl,aDefName)
  If aDefName = "" Then Exit Sub
    For each o In oColl
      Call AttrsSyncBetweenObjs(Obj,o,aDefName)
    Next
End Sub


'==============================================================================
' Функция возвращает объект из атрибута типа ссылка на объект
'------------------------------------------------------------------------------
' oDefName_:SysName типа объекта, который ищем
' o_:TDMSObject - Объект к которому добавляется ссылка
'==============================================================================
Function GetProject(o_)
  Set GetProject = Nothing
  if VarType(o_)<>9 Then Exit Function
  check = False
  If o_.ObjectDefName = "OBJECT_PROJECT" Then
    Set GetProject = o_
    Exit Function
  Else
    If o_.Attributes.Has("ATTR_PROJECT") Then
      If o_.Attributes("ATTR_PROJECT").Empty = False Then
        If Not o_.Attributes("ATTR_PROJECT").Object Is Nothing Then
          check = True
        End If
      End If
    End If
  End If
  
  If check Then
    Set GetProject = o_.Attributes("ATTR_PROJECT").Object
  Else
    Set GetProject = GetUplinkObj(o_,"OBJECT_PROJECT")
  End If
End Function

'==============================================================================
' Открыть диалог выбора объектов: если задан аргумент ObjDefName - c набором
'однотипных объектов, если ObjDefName пустая строка - показать все объекты Рабочего стола.
'==============================================================================
Function SelectObjDlg(oCol_)
        Set SelectObjDlg = Nothing
        Dim SelObjDlg, RetVal, ObjCol
        
'        ' Если в коллекции
'        If oCol_.count = 1 Then
'          Set SelectObjDlg=ObjCol.Item(0)
'          Exit Function
'        End If
        'Получить ссылку на диалог
        Set SelObjDlg = ThisApplication.Dialogs.SelectObjectDlg
        
        SelObjDlg.Prompt = "Выберите один объект:"
        SelObjDlg.SelectFromObjects = oCol_

        RetVal=SelObjDlg.Show
        ' Если ничего не выбрано или диалог отменен, выйти
        Set ObjCol = SelObjDlg.Objects
        If (RetVal<>TRUE) Or (ObjCol.Count=0) Then Exit Function
        Set SelectObjDlg=ObjCol.Item(0)
End Function

' Функция проверки дат
' с учетом минимального интервала
' CheckMinData:   True - Data2 больше минимально допустимой
'                 False - Data2 меньше минимально допустимой
Function CheckMinData(Data1,Data2,Delta)
  CheckMinData = True
  If Data1 <> 0 And Data2 <> 0 Then
    If Data2 < Data1 + Delta Then
      CheckMinData = False
      Msgbox "Дата не может быть ранее " & Data1 + Delta,vbExclamation,"Ошибка ввода даты"
    End If
  End If
End Function


' Функция проверки дат
' с учетом максимального интервала
' CheckMaxData:   True - Data2 больше минимально допустимой
'                 False - Data2 меньше минимально допустимой
Function CheckMaxData(Data1,Data2,Delta)
  CheckMaxData = True
  If Data1 <> 0 And Data2 <> 0 Then
    If Data2 > Data1 + Delta Then
      CheckMaxData = False
      Msgbox "Дата не может быть позднее " & Data1 + Delta,vbExclamation,"Ошибка ввода даты"
    End If
  End If
End Function

'==============================================================================
' Проверка заполнения обязательных полей по списку
' 
'------------------------------------------------------------------------------
' Obj:TDMSObject - разработанное задание
' attrList: String - список системных идентификаторов атрибутов,
'                    которые должны быть заполнены
'==============================================================================
Function CheckRequedFields(Obj,attrList)
  CheckRequedFields = ""
  str = ""
  If Obj Is Nothing Then exit Function
  arr = Split(attrList,",")
  
  For Each attr In arr
    If Obj.Attributes.Has(attr) Then
      If Obj.Attributes(attr).Empty = True Then
        aDesc = ThisApplication.AttributeDefs(attr).Description
        If str = "" Then
          str = "- " & aDesc
        Else
          str = str & chr(10) & "- " & aDesc
        End If
      End If
    End If
  Next
  CheckRequedFields = str
End Function


Function AttrIsEmpty(Obj,aSysName)
  AttrIsEmpty = True
  If Obj.Attributes.Has(aSysName) = False Then Exit Function
  AttrIsEmpty = (Obj.Attributes(aSysName).Empty = True)
End Function


Function CheckBeforeClose(Obj)
  CheckBeforeClose = False
  List = GetAttrListToCheck(Obj)
  str = CheckRequedFieldsBeforeClose(Obj,List)
  If str <> vbNullString Then
    Msgbox "Не заполнены обязательные атрибуты: " & str,vbExclamation,Obj.ObjectDef.Description
    Exit Function
  End If
  CheckBeforeClose = True
End Function

' Функция получения перечня полей для проверки
Function GetAttrListToCheck(Obj)
  GetAttrListToCheck = vbNullString
  If Obj Is Nothing Then Exit Function
  Select Case Obj.ObjectDefName
    Case "OBJECT_CONTRACT"
      List = "Тип договора:ATTR_CONTRACT_TYPE,Заказчик:ATTR_CUSTOMER,Исполнитель:ATTR_CONTRACTOR,Предмет договора:ATTR_CONTRACT_SUBJECT," &_
        "Срок оплаты:ATTR_DUE_DATE,Автор:ATTR_AUTOR,Подписант:ATTR_SIGNER"
    Case "OBJECT_CONTRACT_COMPL_REPORT"
      List = "Тема:ATTR_KD_TOPIC,Контрагент:ATTR_CONTRACTOR,Автор:ATTR_AUTOR,Ответственный бухгалтер:ATTR_SIGNER"
      If Obj.Attributes.Has("ATTR_CCR_INCOMING") Then
        If Obj.Attributes("ATTR_CCR_INCOMING") = False Then ' Акт Заказчика
'          List = Replace(List,",Проверяющий:ATTR_USER_CHECKED","")
        End If
      End If
    Case "OBJECT_FOLDER"
      List = "Наименование:ATTR_FOLDER_NAME"
    Case "OBJECT_NK"
      List = "Код ошибки:ATTR_NK_RESULTS_CODE,Замечание:ATTR_NK_RESULTS_DESC"
    Case "OBJECT_BUILD_STAGE"
      List = "Номер этапа:ATTR_CODE,Наименование:ATTR_NAME"
    Case "OBJECT_WORK_DOCS_FOR_BUILDING"
      List = "Тип полного комплекта:ATTR_WORK_DOCS_FOR_BUILDING_TYPE,Базовое обозначение:ATTR_PROJECT_BASIC_CODE," &_
            "Наименование:ATTR_WORK_DOCS_FOR_BUILDING_NAME"
      ' Закрыто по требованию Самары. См. комментарии к отработке замечаний.
      '  "Код подобъекта:ATTR_BUILDING_TYPE"
    Case "OBJECT_DRAWING"
      ' Любой статус
      List = "Лист:ATTR_G_PAGE_NUM,Обозначение документа:ATTR_DOC_CODE,Наименование документа:ATTR_DOCUMENT_NAME," &_
            "Разработал:ATTR_RESPONSIBLE"
    Case "OBJECT_DOC_DEV"
      ' Любой статус
      List = "Тип документа:ATTR_PROJECT_DOC_TYPE,Обозначение документа:ATTR_DOC_CODE,Наименование документа:ATTR_DOCUMENT_NAME,"  &_
            "Разработал:ATTR_RESPONSIBLE"
    Case "OBJECT_DOCUMENT"
      ' Любой статус
      List = "Тип документа:ATTR_DOCUMENT_TYPE,Наименование документа:ATTR_DOCUMENT_NAME,"  &_
            "Автор:ATTR_AUTOR,Разработал:ATTR_RESPONSIBLE"
    Case "OBJECT_DOCUMENT_AN"
      ' Любой статус
      List = "Тип документа:ATTR_DOCUMENT_TYPE,Наименование документа:ATTR_DOCUMENT_NAME,"  &_
            "Автор:ATTR_AUTOR,Разработал:ATTR_RESPONSIBLE"
    Case "OBJECT_T_TASK"
      List = "Обозначение:ATTR_T_TASK_CODE,Тема:ATTR_NAME_SHORT,От отдела:ATTR_T_TASK_DEPARTMENT,"  &_
            "Разработал:ATTR_RESPONSIBLE,Исполнитель:ATTR_T_TASK_DEVELOPED"
    Case "OBJECT_AGREEMENT"
      List = "Вид соглашения:ATTR_AGREEMENT_TYPE,Автор:ATTR_AUTOR,Подписант:ATTR_SIGNER,"  &_
            "Контрагент:ATTR_CONTRACTOR"
  End Select
  
  GetAttrListToCheck = List
End Function

' Функция проверки заполнения полей
Function CheckRequedFieldsBeforeClose(Obj,List)
  CheckRequedFieldsBeforeClose = vbNullString
  Dim str,txt,aDefName
  
  str = vbNullString
  
  Arr = Split(List,",")
  
  For i = 0 To Ubound(arr)
    ar = Split(arr(i),":")
    txt = ar(0)
    aDefName = ar(1)
    val = checkAttr(Obj,txt,aDefName)
    If val <> vbNullString Then
      str = str & chr(10) & "- " & val
    End If
  Next
  CheckRequedFieldsBeforeClose = str
End Function

' Проверка поля
Function checkAttr(Obj,txt,aDefName)
  checkAttr = vbNullString
  If Obj.Attributes.has(aDefName) then
    If Obj.Attributes(aDefName).Empty = True Then
      checkAttr = txt
    End If
  End If
End Function



'=============================================================================
' Устанавливает связь между объектом и документом-основанием
' Связь добавляется в атрибут Связанные документы объекта Obj
'-----------------------------------------------------------------------------
' Obj: TDMSObject - документ, в который добавляется связь
' BaseObj: TDMSObject - документ-основание, связь на который устанавливается
'=============================================================================
Sub SetLinkToBaseDoc(BaseObj,Obj,noteTxt)
  If BaseObj Is Nothing Or Obj Is Nothing Then Exit Sub
  If Obj.Attributes.Has("ATTR_KD_T_LINKS") = False Then Exit Sub
  Set Table = Obj.Attributes("ATTR_KD_T_LINKS")
  Set Rows = Table.Rows
  Set NewRow = Rows.Create
  NewRow.Attributes(0).Object = BaseObj
  NewRow.Attributes(1).Value = thisApplication.CurrentUser
  NewRow.Attributes(2).Value = noteTxt
  Rows.Update
End Sub


Sub ShowTableObj(Table,aDefName)
  ThisScript.SysAdminModeOn
  Arr = Table.ActiveX.SelectedRows
  If UBound(Arr)<0 Then Exit Sub
  Set Row = Table.ActiveX.RowValue(Arr(0))
  Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
  set Obj = Row.Attributes(aDefName).Object
  if not Obj is nothing then 
    CreateObjDlg.Object = Obj
    ans = CreateObjDlg.Show
  end if
End Sub


Sub DeleteFromTable(Obj,Form,AttrName)
ThisScript.SysAdminModeOn
  Set Table = Form.Controls(AttrName).ActiveX
  
  ar = thisApplication.Utility.ArrayToVariant(Table.SelectedRows)  
    selCount = Ubound(ar)
    if selCount < 0 then ' EV не может быть т.к. всегда выделена хотябы одна строка
      msgbox "Не выбрана ни одна строка!", VbOKOnly+vbExclamation, "Выберите строку!"
      exit sub
    end if
    
    
  Arr = Table.SelectedRows
  If UBound(Arr)+1 = 0 Then Exit Sub
  'Подтверждение удаления
  Key = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion + vbYesNo, 1607, UBound(Arr)+1)
  If Key = vbNo Then Exit Sub
  'Удаление строк
  For i = 0 to UBound(Arr)
    Set Row = Table.RowValue(Arr(i))
    
    Row.Erase
  Next
End Sub