' $Workfile: COMMAND.SCRIPT.CMD_DLL.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Библиотека функций
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.


'==============================================================================
' Метод создает экземпляр объекта и открывает его карточку. При этом 
' обрабатывается событие "Object_BeforeCreate"
'------------------------------------------------------------------------------
' sObjDef_:String - Системный идентификатор типа создаваемого объекта
' p_:TDMSObject - Родительский объект в составе которого создается новый 
'                 информационный объект
' Create:TDMSObject - Созданный экземпляр объекта
'==============================================================================
Function Create(sObjDef_,p_)
  Dim o,EditObjDlg,hnd
  Set Create = Nothing
  
  If VarType(p_)<>9 Then Exit Function
  
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

  Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
  o.Permissions = SysAdminPermissions 
  EditObjDlg.object = o
  EditObjDlg.ParentWindow = ThisApplication.hWnd
  If Not EditObjDlg.Show Then 
    o.Erase 
  End If
  Set Create = o
End Function

'==============================================================================
' Метод удаляет все роли с информационного объекта
'------------------------------------------------------------------------------
' o_:TDMSObject - Обрабатываемый информационный объект
'==============================================================================
Sub RemoveRoles(o_)
  o_.Permissions = SysAdminPermissions
  For Each r In o_.Roles
    o_.Roles.Remove r
  Next
End Sub


'==============================================================================
' Назначает пользователя или группу на роль
'------------------------------------------------------------------------------
' o_:TDMSObject - Обрабатываемый информационный объект
' srd_:String - Системный идентификатор роли
' su_:String - Системный идентификатор пользователя или группы
' SetRole:Boolean - Результат выполнения. True - назначена
'==============================================================================
Function SetRole(o_,srd_,su_)
  Dim rd,u,r
  Set rd = Nothing
  Set u = Nothing
  SetRole = False
  
  If ThisApplication.RoleDefs.Has(srd_) Then 
    Set rd = ThisApplication.RoleDefs(srd_)
  End If
  If ThisApplication.Groups.Has(su_) Then 
    Set u = ThisApplication.Groups(su_)
  End If
  If ThisApplication.Users.Has(su_) Then 
    Set u = ThisApplication.Users(su_)
  End If
  
  If rd Is Nothing Or u Is Nothing Then Exit Function
  o_.Permissions = SysAdminPermissions 
  Set r = o_.Roles.Create(rd,u)
  r.Inheritable=False
  
  SetRole = True
End Function

'==============================================================================
' Удаление всех ролей пользователя
'------------------------------------------------------------------------------
' o_:TDMSObject - Обрабатываемый информационный объект
' sRoleDef_:String - Системный идентификатор роли
' u_:TDMSUser - Пользователь
'==============================================================================
Private Sub DelUserRole(o_,u_,sRoleDef_)
  o_.Permissions = SysAdminPermissions
  For Each r In o_.RolesForUser(u_)
    If r.RoleDefName = sRoleDef_ Then
      o_.Roles.Remove r
    End If
  Next
End Sub


'==============================================================================
' Удаление всех ролей по системному идентификатору
'------------------------------------------------------------------------------
' o_:TDMSObject - Обрабатываемый информационный объект
' sRoleDef_:String - Системный идентификатор роли
'==============================================================================
Private Sub DelDefRole(o_,sRoleDef_)
  o_.Permissions = SysAdminPermissions
  For Each r In o_.RolesByDef(sRoleDef_)
      o_.Roles.Remove r
  Next
End Sub


'==============================================================================
' Установить значение атрибута
'------------------------------------------------------------------------------
' o_:TDMSObject - Обрабатываемый информационный объект
' sAttrDef_:String - Системный идентификатор атрибута
' value_ - Устанавливаемое значение
'==============================================================================
'Private Sub SetAttr(o_,sAttrDef_,value_)
'  o_.Permissions = SysAdminPermissions 
'  If o_.Attributes.Has(sAttrDef_) Then
'    o_.Attributes(sAttrDef_) = value_
'  End If
'End Sub

'==============================================================================
' Установить значение атрибута
'------------------------------------------------------------------------------
' o_:TDMSObject - Обрабатываемый информационный объект
' sAttrDef_:String - Системный идентификатор атрибута
' value_ - Устанавливаемое значение
' SetAttr: Boolean True - атрибут установлен
'                  False - атрибут не установлен
'==============================================================================
'PUBLIC SUB SetAttribute (byval Destination, nameAttribute, valueAttribute, boolAddAttributeIfNotExist)
PUBLIC SUB SetAttr(Destination, nameAttribute, valueAttribute)', boolAddAttributeIfNotExist)
 '/* Присвоить значение атрибуту
 '/* Source может быть: Объект, Форма, Коллекция атрибутов, ссылка на Атрибут (но не табличный), строка табличного атрибута
 '/* boolAddAttributeIfNotExist = True - добавить атрибут к объекту, если его там нет
 '** если  Destination - Форма, Атрибут или Табличный Атрибут, то boolAddAttributeIfNotExist игнорируется
 '** так как для этих объектов нельзя добавить атрибут runtime
 '//** доработано 01.08.2013 13:52
  THISSCRIPT.SYSADMINMODEON
  boolAddAttributeIfNotExist = False
  
    IF Destination is Nothing THEN EXIT sub
    if isNull(valueAttribute) or isEmpty(valueAttribute)  then
      clearATTRIBUTE Destination, nameAttribute 
      exit sub
    elseif VARTYPE(valueAttribute)=vbObject then
      if valueAttribute is Nothing then
        clearATTRIBUTE Destination, nameAttribute
        exit sub
      end if
    elseif VARTYPE(valueAttribute)=vbString THEN   
      if valueAttribute=vbNulLString then 
        clearATTRIBUTE Destination, nameAttribute
        exit sub
      end if
    end if
    
    set cAttributeDefs=THISAPPLICATION.ATTRIBUTEDEFS   
    select case TypeName(Destination)
      case "ITDMSObject"
        Destination.Permissions = SysAdminPermissions
        IF nameAttribute=vbNullString  then exit sub
        SET cAttrs=Destination.ATTRIBUTES
        if cAttrs.has(nameAttribute) then         
          set xAttr=cAttrs(nameAttribute)
        elseif boolAddAttributeIfNotExist and cAttributeDefs.HAS(nameAttribute) then
          set xAttr=cAttrs.create(cAttributeDefs(nameAttribute))
        else
          exit sub
        end if
      case "ITDMSInputForm"
        'Destination.Permissions = SysAdminPermissions
        IF nameAttribute=vbNullString  then exit sub
        SET cAttrs=Destination.ATTRIBUTES
        if cAttrs.has(nameAttribute) then         
          set xAttr=cAttrs(nameAttribute)
        else
          exit sub
        end if        
      case "ITDMSAttributes"
        IF nameAttribute=vbNullString  then exit sub
        if Destination.has(nameAttribute) then         
          set xAttr=Destination(nameAttribute)
        elseif boolAddAttributeIfNotExist and cAttributeDefs.HAS(nameAttribute) then
          set xAttr=Destination.create(cAttributeDefs(nameAttribute))
        else
          exit sub
        end if              
      case "ITDMSAttribute"
        set xAttr=Destination
      case "ITDMSTableAttributeRow" ' конкретная строчка табличного атрибута
        IF nameAttribute=vbNullString  then exit sub
        set Destination=Destination.Attributes
        if Destination.has(nameAttribute) then         
          set xAttr=Destination(nameAttribute)
        else
          exit sub
        end if                                 
      case else
        exit sub
    end select  
  
    SELECT CASE xAttr.TYPE
      CASE TDMOBJECTLINK
        if TypeName(valueAttribute)<>"ITDMSObject" then exit sub
        xAttr.OBJECT=valueAttribute    
      CASE TDMCLASSIFIER, TDMLIST 
        if VarType(valueAttribute)=vbString then
          set clsValueAttribute=thisapplication.Classifiers.FindBySysId(valueAttribute)
          if clsValueAttribute is Nothing then exit sub
          xAttr.CLASSIFIER=clsValueAttribute 
        elseif TypeName(valueAttribute)<>"ITDMSClassifier" then 
          exit sub             
        else
          xAttr.CLASSIFIER=valueAttribute      
        end if
      CASE TDMUSERLINK
        select case TypeName(valueAttribute)
          case "ITDMSUser"
            xAttr.USER=valueAttribute        
          case "ITDMSGroup"
            xAttr.Group=valueAttribute        
        end select
      CASE TDMFILELINK
        if TypeName(valueAttribute)<>"ITDMSFile" then exit sub
          xAttr.FILE=valueAttribute      
      CASE TDMTABLE
        exit sub
      CASE ELSE
        IF VARTYPE(valueAttribute)=vbObject THEN exit sub
        xAttr.VALUE=VALUEATTRIBUTE
    END SELECT  
      
  THISSCRIPT.SYSADMINMODEOFF
END SUB

'==============================================================================
' Установить значение атрибута
'------------------------------------------------------------------------------
' o_:TDMSObject - Обрабатываемый информационный объект
' sAttrDef_:String - Системный идентификатор атрибута
' value_ - Устанавливаемое значение
' SetAttr: Boolean True - атрибут установлен
'                  False - атрибут не установлен
'==============================================================================
'PUBLIC SUB SetAttribute (byval Destination, nameAttribute, valueAttribute, boolAddAttributeIfNotExist)
PUBLIC SUB SetAttr_F(Destination, nameAttribute, valueAttribute, boolAddAttributeIfNotExist)
 '/* Присвоить значение атрибуту
 '/* Source может быть: Объект, Форма, Коллекция атрибутов, ссылка на Атрибут (но не табличный), строка табличного атрибута
 '/* boolAddAttributeIfNotExist = True - добавить атрибут к объекту, если его там нет
 '** если  Destination - Форма, Атрибут или Табличный Атрибут, то boolAddAttributeIfNotExist игнорируется
 '** так как для этих объектов нельзя добавить атрибут runtime
 '//** доработано 01.08.2013 13:52
  THISSCRIPT.SYSADMINMODEON
  
    IF Destination is Nothing THEN EXIT sub
    if isNull(valueAttribute) or isEmpty(valueAttribute)  then
      clearATTRIBUTE Destination, nameAttribute 
      exit sub
    elseif VARTYPE(valueAttribute)=vbObject then
      if valueAttribute is Nothing then
        clearATTRIBUTE Destination, nameAttribute
        exit sub
      end if
    elseif VARTYPE(valueAttribute)=vbString THEN   
      if valueAttribute=vbNulLString then 
        clearATTRIBUTE Destination, nameAttribute
        exit sub
      end if
    end if
    
    set cAttributeDefs=THISAPPLICATION.ATTRIBUTEDEFS   
    select case TypeName(Destination)
      case "ITDMSObject"
        Destination.Permissions = SysAdminPermissions
        IF nameAttribute=vbNullString  then exit sub
        SET cAttrs=Destination.ATTRIBUTES
        if cAttrs.has(nameAttribute) then         
          set xAttr=cAttrs(nameAttribute)
        elseif boolAddAttributeIfNotExist and cAttributeDefs.HAS(nameAttribute) then
          set xAttr=cAttrs.create(cAttributeDefs(nameAttribute))
        else
          exit sub
        end if
      case "ITDMSInputForm"
        'Destination.Permissions = SysAdminPermissions
        IF nameAttribute=vbNullString  then exit sub
        SET cAttrs=Destination.ATTRIBUTES
        if cAttrs.has(nameAttribute) then         
          set xAttr=cAttrs(nameAttribute)
        else
          exit sub
        end if        
      case "ITDMSAttributes"
        IF nameAttribute=vbNullString  then exit sub
        if Destination.has(nameAttribute) then         
          set xAttr=Destination(nameAttribute)
        elseif boolAddAttributeIfNotExist and cAttributeDefs.HAS(nameAttribute) then
          set xAttr=Destination.create(cAttributeDefs(nameAttribute))
        else
          exit sub
        end if              
      case "ITDMSAttribute"
        set xAttr=Destination
      case "ITDMSTableAttributeRow" ' конкретная строчка табличного атрибута
        IF nameAttribute=vbNullString  then exit sub
        set Destination=Destination.Attributes
          if Destination.has(nameAttribute) then
             set xAttr=Destination(nameAttribute)
          Else
            Exit Sub
        end if 
      case else
        exit sub
    end select  
  
    SELECT CASE xAttr.TYPE
      CASE TDMOBJECTLINK
        if TypeName(valueAttribute)<>"ITDMSObject" then exit sub
        xAttr.OBJECT=valueAttribute    
      CASE TDMCLASSIFIER, TDMLIST 
        if VarType(valueAttribute)=vbString then
          set clsValueAttribute=thisapplication.Classifiers.FindBySysId(valueAttribute)
          if clsValueAttribute is Nothing then exit sub
          xAttr.CLASSIFIER=clsValueAttribute 
        elseif TypeName(valueAttribute)<>"ITDMSClassifier" then 
          exit sub             
        else
          xAttr.CLASSIFIER=valueAttribute      
        end if
      CASE TDMUSERLINK
        select case TypeName(valueAttribute)
          case "ITDMSUser"
            xAttr.USER=valueAttribute        
          case "ITDMSGroup"
            xAttr.Group=valueAttribute        
        end select
      CASE TDMFILELINK
        if TypeName(valueAttribute)<>"ITDMSFile" then exit sub
          xAttr.FILE=valueAttribute      
      CASE TDMTABLE
        exit sub
      CASE ELSE
        IF VARTYPE(valueAttribute)=vbObject THEN exit sub
        xAttr.VALUE=VALUEATTRIBUTE
    END SELECT  
      
  THISSCRIPT.SYSADMINMODEOFF
END SUB

'==============================================================================
' Копирование роли
'------------------------------------------------------------------------------
' oIn_:TDMSObject - Объект, на который копируется роль
' oOut_:TDMSObject - Объект, с которого копируется роль
' srd_:String - Системный идентификатор копируемой роли
'==============================================================================
Private Function CopyRoles(oIn_,oOut_,srd_)
  Dim rd,u,r,su
  Set rd = Nothing
  Set u = Nothing
  
  CopyRoles = False
  
  If ThisApplication.RoleDefs.Has(srd_) Then 
    Set rd = ThisApplication.RoleDefs(srd_)
  End If
  
  If rd Is Nothing Then Exit Function 
    
  oIn_.Permissions = SysAdminPermissions 
  For Each r In oOut_.RolesByDef(srd_)
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    
    If Not u Is Nothing Then
      Set rNew = oIn_.Roles.Create(rd,u)
      rNew.Inheritable=False
    End If
  Next
  
  CopyRoles = True
End Function

'==============================================================================
' Функция дополняет строку нулями
'------------------------------------------------------------------------------
' ПРИНИМАЕТ:
'   Str:String - Дополняемая строка
'   Num:Integer - Длина строки
' ВОЗВРАЩАЕТ:
'   AddZeros:String - Дополненную строку
'==============================================================================
Private Function AddZeros(Str,Num)
    AttrLen = Len(Str)
    If AttrLen > Num Then AttrLen = Num
    AddZeros = String (Num - AttrLen,"0") & Str
End Function


'==============================================================================
' Копирование атрибутов
'------------------------------------------------------------------------------
' oIn_:TDMSObject - Объект, на который копируются атрибуты
' oOut_:TDMSObject - Объект, с которого копируются атрибуты
'==============================================================================
Private Sub CopyAttrs(oOut_,oIn_)
  oIn_.Permissions = SysAdminPermissions 
  For Each a In oOut_.Attributes
    sAttrSysName = a.AttributeDefName
    If oIn_.Attributes.has(sAttrSysName) Then
      oIn_.Attributes(sAttrSysName) = a
    End If
  Next
End Sub

'==============================================================================
' Изменение значка информационного объекта в зависимости от типа документа
'------------------------------------------------------------------------------
' o_:TDMSObject - Объект, но котором изменяем значек
' SetIconDocType:Boolean - TRUE - значек изменен
'                   FALSE - значек не изменен
'==============================================================================
Private Function SetIconDocType(o_)
  Dim sDocType  ' Тип документа
  Dim vIcon     ' :TDMSIcon
  
  SetIconDocType = False
  ' Проверка входных параметров
  If VarType(o_) <> 9 Then Exit Function
  If o_ Is Nothing Then Exit Function
  
  o_.Permissions = SysAdminPermissions 
  
  ' Проверка типа документа
  If o_.ObjectDefName = "OBJECT_DOC_DEV" Then
    ' Проверка наличия атрибута "Тип документа"
    If Not o_.Attributes.Has("ATTR_PROJECT_DOC_TYPE") Then Exit Function
    sDocType = o_.Attributes("ATTR_PROJECT_DOC_TYPE")
    ' Проверка установки атрибута "Тип документа"
    If sDocType = "" Then 
      SetIconDocType = SetIconObjType(o_)
      Exit Function
    End If
    
    Set vIcon = o_.Attributes("ATTR_PROJECT_DOC_TYPE").Classifier.Icon
    o_.Icon = vIcon
    SetIconDocType = True 
  Else
    ' Проверка наличия атрибута "Тип документа"
    If Not o_.Attributes.Has("ATTR_DOCUMENT_TYPE") Then Exit Function
    sDocType = o_.Attributes("ATTR_DOCUMENT_TYPE")
    ' Проверка установки атрибута "Тип документа"
    If sDocType = "" Then 
      SetIconDocType = SetIconObjType(o_)
      Exit Function
    End If
    
    Set vIcon = o_.Attributes("ATTR_DOCUMENT_TYPE").Classifier.Icon
    o_.Icon = vIcon
    SetIconDocType = True
  End If
End Function

'==============================================================================
' Изменение значка информационного объекта в зависимости от типа файла
'------------------------------------------------------------------------------
' o_:TDMSObject - Объект, но котором изменяем значек
' SetIconFileType:Boolean - TRUE - значек изменен
'                   FALSE - значек не изменен
'==============================================================================
Private Function SetIconFileType(o_)
  Dim vIcon     ' :TDMSIcon
  
  SetIconFileType = False
  ' Проверка входных параметров
  If VarType(o_) <> 9 Then Exit Function
  If o_ Is Nothing Then Exit Function
    
  o_.Permissions = SysAdminPermissions 
    
  ' Проверка наличия файла
  If o_.Files.Count=0 Then 
    SetIconFileType = SetIconObjType(o_)
    Exit Function
  End If
  
  Set vIcon = o_.Files.Main.FileDef.Icon
  o_.Icon = vIcon
  SetIconFileType = True
End Function

'==============================================================================
' Изменение значка информационного объекта в зависимости от типа объекта
'------------------------------------------------------------------------------
' o_:TDMSObject - Объект, но котором изменяем значек
' SetIconObjType:Boolean - TRUE - значек изменен
'                   FALSE - значек не изменен
'==============================================================================
Private Function SetIconObjType(o_)
  Dim vIcon     ' :TDMSIcon
  
  SetIconObjType = False
  ' Проверка входных параметров
  If VarType(o_) <> 9 Then Exit Function
  If o_ Is Nothing Then Exit Function
  
  o_.Permissions = SysAdminPermissions 
  
  Set vIcon = o_.ObjectDef.Icon
  o_.Icon = vIcon
  SetIconObjType = True
End Function


'==============================================================================
' Изменение значка информационного объекта
'------------------------------------------------------------------------------
' o_:TDMSObject - Объект, но котором изменяем значек
' SetIconObjType:Boolean - TRUE - значек изменен
'                   FALSE - значек не изменен
'==============================================================================
'Private Function SetIcon(o_)
'  Dim sIconType
'  SetIcon = False
'  ' Проверка наличия глобального атрибута в системе
'  If Not ThisApplication.Attributes.Has("ATTR_DOC_ICON_TYPE") Then Exit Function
'  sIconType = ThisApplication.Attributes("ATTR_DOC_ICON_TYPE")  
'  ' Проверка установки глобального атрибута в системе
'  If sIconType = "" Then Exit Function
'  Select Case sIconType
'      Case "по типу документа"
'          SetIcon = SetIconDocType(o_)
'      Case "по типу файла"
'          SetIcon = SetIconFileType(o_)
'      Case Else
'          SetIcon = SetIconFileType(o_)
'  End Select
'End Function

'=================================
Sub SetIcon(Obj)
  Obj.Permissions = SysAdminPermissions ' задаем права 
'  If Obj.Status Is Nothing Then Exit Sub
  status = Obj.StatusName
  stArr =  Split(status,"_") 
  ind = Ubound(stArr)
  if ind < 0 then exit sub
   
  objDef = obj.ObjectDefName
  imgName = "IMG_" & objDef
  Select Case objDef
    Case "OBJECT_CONTRACT"
      Set cClassCls = Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier
      If Not cClassCls Is Nothing Then
        cClass = Obj.Attributes("ATTR_CONTRACT_CLASS").Classifier.SysName
        clArr = Split(cClass,"_") 
        clInd = Ubound(clArr)
        if clInd > 0 then
          imgName = imgName & "_" & clArr(clInd)
        End If
      End If
      If status = "STATUS_CONTRACT_CLOSED" Then
        If Obj.Attributes("ATTR_CONTRACT_CLOSE_TYPE").Empty = False Then
          cClose = Obj.Attributes("ATTR_CONTRACT_CLOSE_TYPE").Classifier.SysName
          ctArr = Split(cClose,"_") 
          ctInd = Ubound(ctArr)
          if ctInd > 0 then
            imgName = imgName & "_" & ctArr(ctInd)
          End If
        End If
      End If
    Case "OBJECT_AGREEMENT"
    Case "OBJECT_CONTRACT_COMPL_REPORT"
   
  End Select
  imgName = imgName & "_" & stArr(ind)
  'thisApplication.AddNotify imgName  
  if ThisApplication.Icons.Has(imgName) then
    if not imgName = Obj.Icon.SysName then
      Obj.Icon = ThisApplication.Icons(imgName)
    end if
  else ' EV если не нашли ставим от объекта
'    if not obj.ObjectDef.Icon.SysName = Obj.Icon.SysName then
'      Obj.Icon = obj.ObjectDef.Icon
'    end if
'     
  end if
end sub


'==============================================================================
' Метод возвращает значение первой строки первой колонки листа выборки
'------------------------------------------------------------------------------
' sQuerySysName_:String- Системный идентификатор выборки
' GetNum:Ыекштп- Значение ячейки (1,1)
'==============================================================================
Private Function GetNum(sQuerySysName_)
  On Error Resume Next
  GetNum = ThisApplication.Queries(sQuerySysName_).Sheet.CellValue(0,0)
  On Error GoTo 0
  If  GetNum = "" Then GetNum = 0
End Function

'==============================================================================
' Метод устанавливает флаг контрола на форме в Read Only
'------------------------------------------------------------------------------
' f_:TDMSForm - Форма TDMS
' sListAttrs_:String - Список системных идентификаторов атрибутов, 
'                      поля которых на форме должны быть Read Only
'==============================================================================
Sub SetControlReadOnly(f_,sListAttrs_)
  Dim Attrs
  Attrs = Split(sListAttrs_,",")
  For Each sAttr In Attrs
    If f_.Controls.Has(sAttr)Then f_.Controls.Item(sAttr).ReadOnly = True
  Next
End Sub

'==============================================================================
' Метод скрывает\отображает контролы на форме
'------------------------------------------------------------------------------
' f_:TDMSForm - Форма TDMS
' sListAttrs_:String - Список системных идентификаторов атрибутов, 
'                      поля которых на форме должны быть скрыты
' bFlag_:Boolean - True:Контрол виден False:Контрон не виден
'==============================================================================
Sub SetControlVisible(f_,sListAttrs_,bFlag_)
  Dim Attrs
  Attrs = Split(sListAttrs_,",")
  For Each sAttr In Attrs
    If f_.Controls.Has(sAttr)Then f_.Controls.Item(sAttr).Visible = bFlag_
    If f_.Controls.Has("T_" & sAttr)Then f_.Controls.Item("T_" & sAttr).Visible = bFlag_
  Next
End Sub

'==============================================================================
' Метод скрывает контролы на форме
'------------------------------------------------------------------------------
' f_:TDMSForm - Форма TDMS
' sListAttrs_:String - Список системных идентификаторов атрибутов, 
'                      поля которых на форме должны быть скрыты
'==============================================================================
Sub HideControls(f_,sListAttrs_)
  Call SetControlVisible(f_,sListAttrs_,False)
End Sub

'==============================================================================
' Метод отображает контролы на форме
'------------------------------------------------------------------------------
' f_:TDMSForm - Форма TDMS
' sListAttrs_:String - Список системных идентификаторов атрибутов, 
'                      поля которых на форме должны быть скрыты
'==============================================================================
Sub ShowControls(f_,sListAttrs_)
  Call SetControlVisible(f_,sListAttrs_,True)
End Sub

'======================================================================================
'Процедура, которая исключает из результата выборки объекты, которые уже есть в таблице
'--------------------------------------------------------------------------------------
'Objects:Collection - Коллекция объектов для фильтрации
'AttrName:String - Системное имя атрибута в таблице для проверки
'TableRows:Collection - Коллекция строк таблицы
'======================================================================================
Sub QueryObjectsFilter(Objects,AttrName,TableRows)
  ThisApplication.Utility.WaitCursor = True
  'Исключаем объекты, которые уже есть в таблице
  If TableRows.Count > 0 Then
    For Each Row in TableRows
      If Row.Attributes(AttrName).Empty = False Then
        
        If not Row.Attributes(AttrName).Object is Nothing Then
          Set Obj = Row.Attributes(AttrName).Object
          If Objects.Has(Obj) Then
            Objects.Remove Obj
          End If
        End If
        If not Row.Attributes(AttrName).User is Nothing Then
          Set Obj = Row.Attributes(AttrName).User
          If Objects.Has(Obj.Description) Then
            Objects.Remove Obj
          End If
        End If
      End If
    Next
  End If
  ThisApplication.Utility.WaitCursor = False
End Sub

'======================================================================================
'Процедура сортировки по описанию объекта
'--------------------------------------------------------------------------------------
'AttrName:String - Системное имя атрибута в таблице
'TableRows:Collection - Коллекция строк таблицы
'======================================================================================
Sub TableRowsSort(TableRows,AttrName)
  'Создание виртуальной таблицы
  Set NewSheet = ThisApplication.CreateSheet
  NewSheet.AddColumn 1
  i = 0
  For Each Row in TableRows
    NewSheet.AddRow
    NewSheet.CellValue(i,0) = Row.Attributes(AttrName).Value
    i = i + 1
  Next
  
  'Сортировка виртуальной атблицы по возрастанию
  NewSheet.Sort 0, False
  
  'Сравнение и синхронизация настоящей таблицы с виртуальной
  For i = TableRows.Count-1 to 0 Step -1
    Val = TableRows(i).Attributes(AttrName).Value
    If StrComp(Val,NewSheet.CellValue(i,0),vbTextCompare) <> 0 Then
      For j = NewSheet.RowsCount-1 to 0 Step -1
        If StrComp(Val,NewSheet.CellValue(j,0),vbTextCompare) = 0 Then
          TableRows.Swap i, j
          TableRows.Update
        End If
      Next
    End If
  Next
End Sub

'======================================================================================
'Процедура создания записи в журнал сессий объекта
'--------------------------------------------------------------------------------------
'Obj:Object - Ссылка на объект
'Flag:Bulean - True - файлы загружены, False - файлы выгружены
'======================================================================================
Sub TsessionRowCreate(Obj,Flag)
  ' Если нет доступа на редактирование то не пишем
  If Obj.Permissions.LockOwner = False Then Exit Sub
  ThisScript.SysAdminModeOn
  'Проверка атрибута
  AttrName = "ATTR_TSESSION"
  If Obj.Attributes.Has(AttrName) = False Then
    Obj.Attributes.Create ThisApplication.AttributeDefs(AttrName)
  End If
  Set TableRows = Obj.Attributes(AttrName).Rows
  'Новая запись
  Set NewRow = TableRows.Create
  NewRow.Attributes("ATTR_DATA").Value = Date
  NewRow.Attributes("ATTR_USER").Value = ThisApplication.CurrentUser
  If Flag = True Then
    'Загружен
    Set Clf = ThisApplication.Classifiers("NODE_SESSION_EVENT").Classifiers.Find("0")
  Else
    'Выгружен
    Set Clf = ThisApplication.Classifiers("NODE_SESSION_EVENT").Classifiers.Find("1")
  End If
  If not Clf is Nothing Then
    NewRow.Attributes("ATTR_SESSION_TYPE").Classifier = Clf
  End If
End Sub

'======================================================================================
'Функция поиска подписанта
'Возвращает ссылку на руководителя самого верхнего узла элемента оргструктуры
'======================================================================================
Function SignerGet()
  Set SignerGet = Nothing
  
  set q = ThisApplication.Queries("QUERY_KD_SINGERS")
  q.Parameter("PARAM0") = 0
  For each u In q.Users
    If u.Attributes("ATTR_KD_GRADE").Value = "1" Then 
      Set SignerGet = u
      exit Function
    End If
  Next
  
  If SignerGet Is Nothing Then Exit Function
  
  Check = True
  For Each StrObj in ThisApplication.ObjectDefs("OBJECT_STRU_OBJ").Objects
    
    For Each Parent in StrObj.Uplinks
      If Parent.ObjectDefName = "OBJECT_STRU_OBJ" Then
        Check = False
        Exit For
      ElseIf Parent.ObjectDefName = "OBJECT_KD_FOLDER" Then
        Exit For
      End If
    Next
    If Check = True Then
      If StrObj.Attributes("ATTR_KD_CHIEF").Empty = False Then
        If not StrObj.Attributes("ATTR_KD_CHIEF").User is Nothing Then
          Set SignerGet = StrObj.Attributes("ATTR_KD_CHIEF").User
        End If
      End If
      Exit Function
    End If
  Next
End Function

'======================================================================================
'Функция поиска пользователя по элементу оргструктуры
'Возвращает ссылку на пользователя элемента оргструктуры по названию
'======================================================================================
Function OrgUserGet(OrgName)
ThisScript.SysAdminModeOn
  Set OrgUserGet = Nothing
  If OrgName = "" Then Exit Function
  For Each StrObj in ThisApplication.ObjectDefs("OBJECT_STRU_OBJ").Objects
    If StrObj.Attributes.Has("ATTR_NAME") and StrObj.Attributes.Has("ATTR_KD_CHIEF") Then
      If StrComp(StrObj.Attributes("ATTR_NAME").Value,OrgName,vbTextCompare) = 0 Then
        If StrObj.Attributes("ATTR_KD_CHIEF").Empty = False Then
          If not StrObj.Attributes("ATTR_KD_CHIEF").User is Nothing Then
            Set OrgUserGet = StrObj.Attributes("ATTR_KD_CHIEF").User
            Exit For
          End If
        End If
      End If
    End If
  Next
  ThisScript.SysAdminModeOff
End Function

'======================================================================================
'Процедура синхронизации значений атрибутов между двумя объектами
'--------------------------------------------------------------------------------------
'Obj0:Object - Объект, с которого копируются значения
'Obj1:Object - Объект, в который копируются значения
'AttrStr:String - перечисление SysID атрибутов для синхронизации
'======================================================================================
Sub AttrsSyncBetweenObjs(Obj0,Obj1,AttrStr)
  If AttrStr = "" Then Exit Sub
  Arr = Split(AttrStr,",")
  For i = 0 to Ubound(Arr)
    AttrName = Arr(i)
    If ThisApplication.AttributeDefs.Has(AttrName) and Obj0.Attributes.Has(AttrName) and _
    Obj1.Attributes.Has(AttrName) Then
      Call AttrValueCopy(Obj0.Attributes(AttrName),Obj1.Attributes(AttrName))
    End If
  Next
End Sub

'======================================================================================
'Процедура копирования значения атрибута
'--------------------------------------------------------------------------------------
'Attr0:Object - Атрибут, с которого копируется значение
'Attr1:Object - Атрибут, в который копируется значение
'======================================================================================
Sub AttrValueCopy(Attr0,Attr1)
  ThisScript.SysAdminModeOn
  Select case Attr0.AttributeDef.Type
    Case 6,8 'Классификатор
      If not Attr0.Classifier is Nothing Then
        If not Attr1.Classifier is Nothing Then
          If Attr1.Classifier.SysName <> Attr0.Classifier.SysName Then
            Attr1.Classifier = Attr0.Classifier
          End If
        Else
          Attr1.Classifier = Attr0.Classifier
        End If
      Else
        Attr1.Classifier = Nothing
      End If
    Case 7 'Ссылка на объект
      If not Attr0.Object is Nothing Then
        If not Attr1.Object is Nothing Then
          If Attr1.Object.Guid <> Attr0.Object.Guid Then
            Attr1.Object = Attr0.Object
          End If
        Else
          Attr1.Object = Attr0.Object
        End If
      Else
        Attr1.Object = Nothing
      End If
    Case 9 'Ссылка на пользователя
      If not Attr0.User is Nothing Then
        If not Attr1.User is Nothing Then
          If Attr1.User.SysName <> Attr0.User.SysName Then
            Attr1.User = Attr0.User
          End If
        Else
          Attr1.User = Attr0.User
        End If
      Else
        Attr1.User = Nothing
      End If
    Case 11 'Таблица
      Attr1.Rows.RemoveAll
      If Attr0.Rows.count>0 Then
        For Each Row0 in Attr0.Rows
          Set Row1 = Attr1.Rows.Create
          For i = 0 to Row0.Attributes.Count-1
            Call AttrValueCopy(Row0.Attributes(i),Row1.Attributes(i))
          Next
        Next
      End If
    Case Else 'Остальные
      If Attr1.Value <> Attr0.Value Then
        Attr1.Value = Attr0.Value
      End If
  End Select
End Sub


public Function getMainComment(byVal clsNode) ' as string
  '/* считать текст, содержащийся в основном комментарии (доступен для простмотра и редактирования пользовтаелем)
  getMainComment=vbNulLString
  if varType(clsNode)=vbObject then
    if clsNode is Nothing then exit function
  elseif isNull(clsNode) or isempty(clsNode) then
    exit function
  elseif clsNode="" then
    exit function
  else
    set clsNode=thisApplication.Classifiers.FindBySysId(clsNode)
    if clsNode is Nothing then exit function
  end if
  if clsNode.comments.count>0 then
    getMainComment=clsNode.comments(0).text
  end if
end function

public Function getStringByTag(TagOrNode, strTag) ' as string
  '/* Выделить значение по тегу как строку
  '/* тег построен по формуле: {strSetting=Значение} 
  getStringByTag=vbNulLString
  if  strTag=vbNulLString then exit function
  if varType(TagOrNode)=vbObject then
    strSetting=getMainComment(TagOrNode)
  else
    strSetting=TagOrNode
    if strSetting=vbNulLString then exit function    
  end if
  posStart=instr(1, strSetting, "{" + strTag + "=")
  if posStart>0 then
    posFinish=instr(posStart, strSetting, "}", vbTextCompare)
    if posFinish>0 then
      getStringByTag=replace(mid(strSetting, posStart, posFinish-posStart),"{" + strTag + "=", "") 
    end if
  end if
end function

sub ShowBtnIcon(Form,Obj)
  set btnfav = Form.Controls("BTN_TO_FAV").ActiveX
  if ThisApplication.ExecuteScript("CMD_MARK_LIB","HasMark",Obj, "избранное") then
      btnfav.Image = thisApplication.Icons("IMG_IMPORTANT_ACTIVE")
  else
      btnfav.Image = thisApplication.Icons("IMG_IMPORTANT_PASSIVE")
  end if
  set btnfav = Form.Controls("BTN_TO_CONTROL").ActiveX
  if ThisApplication.ExecuteScript("CMD_MARK_LIB","HasMark",Obj, "на контроле") then
      btnfav.Image = thisApplication.Icons("IMG_ONCONTROL_ACTIVE")
  else
      btnfav.Image = thisApplication.Icons("IMG_ONCONTROL_PASSIVE")
  end if
end sub

Function CopyObj(Obj)
  CopyObj = false 
  ThisScript.SysAdminModeOn
  Set ObjectDef = Nothing
 
  Select Case Obj.ObjectDefName
    Case "OBJECT_CONTRACT"
      Set ObjRoots = thisApplication.ExecuteScript("CMD_DLL_CONTRACTS","GetContractRoot")
    Case "OBJECT_CONTRACT_COMPL_REPORT","OBJECT_CONTRACT","OBJECT_AGREEMENT","OBJECT_INVOICE"
      Set ObjectDef = Obj.ObjectDef
      Set ObjRoots = thisApplication.ExecuteScript("CMD_KD_FOLDER","GET_FOLDER","",ObjectDef)
    Case Else
      Set ObjRoots = Obj.Parent
  End Select
  
  If  ObjRoots is nothing then  
    msgBox "Не удалось скопировать """ & Obj.Description & """", vbCritical, "Объект не был создан"
    exit function
  end if
  Set NewObj = Nothing
  ObjRoots.Permissions = SysAdminPermissions
  Set NewObj = ObjRoots.Objects.Create(Obj.ObjectDef)

  if NewObj is nothing then 
    msgbox "Не удалось скопировать """ & Obj.Description & """", vbCritical, "Объект не был создан"
    exit function
  end if

  if not ThisApplication.ExecuteScript("CMD_S_DLL", "CopyDocAttrs", Obj,NewObj) then
    msgbox "Не удалось скопировать атрибуты", vbCritical, "Ошибка"
    exit function
  end if
  
  NewObj.update  
  Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
  CreateObjDlg.Object = NewObj
  ans = CreateObjDlg.Show
  If not ans then 
    NewObj.erase
    Exit Function
  End If

  CopyObj = true
end function 

Sub PrintAgreeList(Obj)
    set agreeObj =  thisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "GetAgreeObjByObj",Obj)
    if agreeObj is nothing then exit sub
    set file = agreeObj.Files.Main
    if File is nothing then exit sub
    file.CheckOut file.WorkFileName ' извлекаем

    Set objShellApp = CreateObject("Shell.Application") 'открываем
    objShellApp.ShellExecute "explorer.exe", file.WorkFileName, "", "", 1
    Set objShellApp = Nothing  
End Sub

' Проверка стоимости на отрицательные значения
Function CheckPrice(Obj,Attr)
  CheckPrice = False
  If Obj Is Nothing Then Exit Function
  If Obj.Attributes.Has(attr) = False Then Exit Function
  If Obj.Attributes(attr).Value < 0 Then
    msgbox "Введенное значениие не может быть отрицательным:" & chr(10) & _
            "-" & Obj.Attributes(attr).AttributeDef.Description,vbExclamation,"Ошибка"
    Exit Function
  End If
  CheckPrice = True
End Function

'Функция получения ссылки на пользователя в атрибуте
Function GetUserFromAttr(Obj,AttrName)
  Set GetUserFromAttr = Nothing
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      If not Obj.Attributes(AttrName).User is Nothing Then
        Set GetUserFromAttr = Obj.Attributes(AttrName).User
      End If
    End If
  End If
End Function


function CheckAgreeStatus(docObj) 
  CheckAgreeStatus = false
  statuscheck = False
  
  ' Проверка наличия файла
  If Not ThisApplication.ExecuteScript("CMD_DLL", "CheckDoc",docObj) Then Exit Function
  
  txt = vbNullString
  
  Set CU = ThisApplication.CurrentUser
  isGIP = ThisApplication.ExecuteScript("CMD_DLL_ROLES","isGipOrDep",docObj,CU)
    
  Select Case docObj.ObjectDefName
    Case "OBJECT_T_TASK"  
'      If docObj.StatusName = "STATUS_T_TASK_IS_SIGNED" Then statuscheck = True

      Set uExec = docObj.Attributes("ATTR_T_TASK_DEVELOPED").User
      Set uResp = docObj.Attributes("ATTR_RESPONSIBLE").User
      
      If docObj.StatusName = "STATUS_T_TASK_IS_SIGNING" Then
        StatusCheck = True
      ElseIf docObj.StatusName = "STATUS_T_TASK_IN_WORK" Then
        If Not uExec Is Nothing And Not uResp Is Nothing Then
          If uExec.Handle = uResp.Handle Then
            StatusCheck = True
          End If
        End If
      ElseIf docObj.StatusName = "STATUS_T_TASK_IS_SIGNED" Then 
        StatusCheck = True
      End If
      Call ThisApplication.ExecuteScript("OBJECT_T_TASK","SetRequiredApprovers",docObj)

    Case "OBJECT_TENDER_INSIDE" 
      If docObj.StatusName = "STATUS_TENDER_DRAFT" Then statuscheck = True

    Case "OBJECT_CONTRACT"  
      If docObj.StatusName = "STATUS_CONTRACT_DRAFT" Then statuscheck = True

    Case "OBJECT_CONTRACT_COMPL_REPORT" 
      If docObj.StatusName = "STATUS_COCOREPORT_DRAFT" or docObj.StatusName = "STATUS_COCOREPORT_EDIT" Then statuscheck = True

    Case "OBJECT_WORK_DOCS_SET" 
      If docObj.StatusName = "STATUS_WORK_DOCS_SET_IS_DEVELOPING" Then statuscheck = True

    Case "OBJECT_VOLUME"  
      If docObj.StatusName = "STATUS_VOLUME_IS_BUNDLING" Then statuscheck = True

    Case "OBJECT_DOC_DEV","OBJECT_DRAWING" 
      If docObj.StatusName = "STATUS_DOCUMENT_DEVELOPED" or _
          (docObj.StatusName = "STATUS_DOCUMENT_CREATED" And isGIP) Then 
            statuscheck = True

      Else
        txt = "Отправьте на проверку"
      End If
    Case "OBJECT_AGREEMENT" 
      If docObj.StatusName = "STATUS_AGREEMENT_DRAFT" or docObj.StatusName = "STATUS_AGREEMENT_EDIT" Then statuscheck = True

    Case "OBJECT_STAGE" 
      If docObj.StatusName = "STATUS_STAGE_DRAFT" or docObj.StatusName = "STATUS_STAGE_DEVELOPING" Then statuscheck = True

    Case "OBJECT_DOCUMENT_AN" 
      If docObj.StatusName = "STATUS_DOCUMENT_DEVELOPED" Then statuscheck = True

  End Select
  If statuscheck = False Then 
    str = "Отправка на согласование из статуса """ & docObj.Status.Description & """ невозможна"
    If txt <> vbNullString Then
      str = str & ":" & chr(10) & txt
    End If
    msgbox str, _
        vbCritical, "Отправка отменена!"
        Exit Function
  End If
  
  ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",docObj,"NODE_KD_RETUN_USER")
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",docObj,"NODE_KD_SING")
  ' Заполнение атрибута Исполнитель
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", docObj, "ATTR_KD_EXEC", CU, True

  CheckAgreeStatus = true
end function


'Создает исходящий документ и прикладывает к нему объект
Function CreareDocOut (Obj)
  Set CreareDocOut = Nothing
  If ThisApplication.ObjectDefs.Has("OBJECT_KD_DOC_OUT") = False Then
    MsgBox "Невозможно создать исходящий документ. Обратитесь к Администратору.",vbCritical,"Ошибка создания ИД"
    exit Function
  End If
  Set objType = ThisApplication.ObjectDefs("OBJECT_KD_DOC_OUT")
  Set mail = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","Create_Doc_by_Type",objType, Obj)
  If mail Is Nothing Then Exit Function
  
  Set CreareDocOut = mail
End Function

'======================================================================================
' Устанавливает значение атрибута Описание(Пользовательское) для разных типов объектов
'--------------------------------------------------------------------------------------
' Obj:TDMSObject - объект для которого требуется установка описания
'======================================================================================
Sub SetDescription(Obj)
  Obj.Permissions = SysAdminPermissions
  If Obj.Attributes.Has("ATTR_DESCRIPTION") = False Then
    Obj.Attributes.Create "ATTR_DESCRIPTION"
  End If
  Select Case Obj.ObjectDefName
    Case "OBJECT_FOLDER","OBJECT_WORK_DOCS_FOR_BUILDING","OBJECT_WORK_DOCS_SET"
      val = Obj.Description      
    Case "OBJECT_CONTRACT","OBJECT_AGREEMENT","OBJECT_CONTRACT_COMPL_REPORT"
      val = ThisApplication.ExecuteScript("CMD_S_NUMBERING","GetContractDescription",ThisObject)
    Case "OBJECT_PROJECT_SECTION","OBJECT_PROJECT_SECTION_SUBSECTION"
      Val = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "ProjectSectionFullDescrGen",Obj)
    Case "OBJECT_VOLUME"
      val = "Том " & Obj.Attributes("ATTR_VOLUME_NUM") & " - " & Obj.Attributes("ATTR_VOLUME_NAME")
    Case "OBJECT_INVOICE"
      'Передаточный документ №{ATTR_REG_NUMBER}_ от {ATTR_DATA} ({ATTR_INVOICE_RECIPIENT})
      Set oProj = Obj.Attributes("ATTR_PROJECT").Object
      If oProj Is Nothing Then
        pShortName = vbNullString
      Else
        pShortName = oProj.Attributes("ATTR_NAME_SHORT").Value
      End If
      val = "Передаточный документ №" & Obj.Attributes("ATTR_REG_NUMBER") & "_" & _
                        pShortName & " от " & Obj.Attributes("ATTR_KD_ISSUEDATE") '& " (" & _
                        '                      Obj.Attributes("ATTR_INVOICE_RECIPIENT") & ")"
    End Select
  If Obj.Attributes("ATTR_DESCRIPTION").Value <> val Then Obj.Attributes("ATTR_DESCRIPTION").Value = val
End Sub



'==============================================================================
' Проверка наличия файлов в документе
'------------------------------------------------------------------------------
' Obj:TDMSObject - документ
' CheckDoc:Boolean - Результат проверки
'==============================================================================
Private Function CheckDoc(Obj)
  CheckDoc = False
  ' Проверка наличия файла
  If Obj.Files.count<=0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1004, Obj.ObjectDef.Description
    Exit Function
  End If  
  CheckDoc = True
End Function

PUBLIC SUB clearAttribute(Source, nameAttribute)
 '/* Очистить значение атрибута
 '/* Source может быть: Объект, Форма, Коллекция атрибутов, ссылка на Атрибут, строка табличного атрибута
 '/** если атрибут булевый - то присваивается неопределённое значение (Null)
 '/** если Source - ссылка на Атрибут (не табличный!), то nameAttribute - необязательный параметр
 '/*** так как значение по умолчанию можно пределить только если Source - ссылка на объект
  THISSCRIPT.SYSADMINMODEON  
    if Source is Nothing then exit sub
    select case typeName(Source)
      case "ITDMSAttribute", "ITDMSTableAttribute"
        set pAttribute=Source
      case "ITDMSAttributes"       
        if nameAttribute=vbNullString then exit sub
        if not Source.has(nameAttribute) then exit sub
        set pAttribute=Source(nameAttribute) 
      case "ITDMSTableAttributeRow" ' конкретная строчка табличного атрибута
        if nameAttribute=vbNullString then exit sub
        set cAttrs=Source.attributes
        if not cAttrs.has(nameAttribute) then exit sub
        set pAttribute=cAttrs(nameAttribute)               
      case "ITDMSObject"
        if nameAttribute=vbNullString then exit sub
        Source.Permissions = SysAdminPermissions
        set cAttrs=Source.attributes
        if not cAttrs.has(nameAttribute) then exit sub
        set pAttribute=cAttrs(nameAttribute) 
      case "ITDMSInputForm"
        if nameAttribute=vbNullString then exit sub
        set cAttrs=Source.attributes
        if not cAttrs.has(nameAttribute) then exit sub
        set pAttribute=cAttrs(nameAttribute)       
      case else
        exit sub
    end select  
 
    SELECT CASE pAttribute.TYPE  
      case TDMTABLE
        set rows=pAttribute.rows
        for each xRow in rows
          xRow.erase
        next ' xRow
'        clearTableAttribute pAttribute, nameAttribute, vbNullString
'      case tdmBool
'        pAttribute.Value=False
      case else
        pAttribute.Value=Null
    end select
    
  THISSCRIPT.SYSADMINMODEOff
end sub 

Public Sub clearTableAttribute (Source, NameAttribute, strFilter )
 '/* Удалить строки табличного атрибута, согласно фильтра
 '/* NameAttribute - имя табличного атрибута
 '/* strFilter=<имя атрибута в таблице><операция сравнения>[<значение>/<значение*>]
 '/* strFilter=vbNulLString - удаляются все строки в таблице
 '** например, strFilter="all_hidden_string_KeyForFindRow={clsAdress*"
 '** реализована операции сравнения: только типа Like
 '* сопровождается информацией о процессе выполнения в StatusBar
 '/+ дописать контент анализ для других операций сравнения (=, >, <, BETWEEN - для дат)
  THISSCRIPT.SYSADMINMODEOn
    IF Source IS NOTHING or  NameAttribute=vbNullString THEN EXIT SUB
    select case TypeName(Source)
      case "ITDMSObject" 
        Source.Permissions = SysAdminPermissions
        SET cAttr=Source.ATTRIBUTES     
      case "ITDMSInputForm"
        SET cAttr=Source.ATTRIBUTES      
      case "ITDMSAttributes" 
        SET cAttr=Source
      case "ITDMSTableAttribute"
        SET cAttr=Source.attributes
      case else    
        exit sub
    end select
    
    if not cAttr.has(NameAttribute) then exit sub
            
    if strFilter<>vbNullString then      
      parserFiler01 strFilter , NameAttribute, strLike
      if NameAttribute<>vbNullString and strLike<>vbNullString then boolFilter=True
    else
      boolFilter=False
    end if
    
    set cAttrRows=cAttr(NameAttribute).rows   
    strStatusBar="Удаление строк табличного атрибута... ":  thisApplication.shell.SetStatusBarText strStatusBar
    iX=0: mX=cAttrRows.Count 
    for each xRow in cAttrRows
      boolGotoNext = False      
      if boolFilter then  
        set cAttrs=xRow.attributes     
        strFilterAttr=cstr(getAttributeKeyValue(cAttrs(NameAttribute)))    
        if instr(1, strFilterAttr, strLike, vbTextCompare)>0 then
          ' continue
        else
          boolGotoNext=True
        end if                  
      end if 
      if not boolGotoNext then
        cAttrRows.remove xRow   
      end if                  
      iX=iX+1
      thisApplication.shell.SetStatusBarText strStatusBar & " " & int(iX*100/mX) & "%"
    next 'xRow
    thisApplication.shell.SetStatusBarText vbNullString   
  THISSCRIPT.SYSADMINMODEOff  
End Sub

' Установка активной формы перед открытием диалога свойств
Sub ShowDefaultForm(Dialog, Obj, Forms)
  'Определение активной формы
  If Obj.Dictionary.Exists("FormActive") Then
  ' Если была нажата кнопка перехода на другую форму, например, "На согласование"
  ' в статусе, для которого в настройках отображения форм ATTR_KD_T_FORMS_SHOW
  ' определена другая вкладка по-умолчанию, то зачитываем из словаря.
  ' Словать заполняется при нажатии на кнопку.
    FormName = Obj.Dictionary.Item("FormActive")
    If Dialog.InputForms.Has(FormName) Then
      Dialog.ActiveForm = Dialog.InputForms(FormName)
    End If
    Obj.Dictionary.Remove("FormActive")
  Else
    FormName = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetObjFroms",obj)
    If FormName <> vbNullString Then
      Dialog.ActiveForm = FormName
    End If
  End If
End Sub


Sub VersionCreate(Obj, txt)
  Obj.Permissions = SysAdminPermissions
  Obj.Versions.Create ,txt
  
  Set osVer = Obj.Versions
  Set oVer = osVer(osVer.Count-1)
  If oVer.Permissions.Locked = True Then
    oVer.Unlock oVer.Permissions.LockType
  End If
End Sub

'=============================================================
'Выбирает объект в дереве объектов
'-------------------------------------------------------------
'OBJ:TDMSOBJECT - искомый объект
'=============================================================
Function LocateObjInTree(Obj)
  LocateObjInTree = vbnullstring
  If Obj.Permissions.View = 0 Then Exit Function
  LocateObjInTree = ThisApplication.Shell.LocateInTree(Obj)
  Set col = ThisApplication.Shell.SelObjects
'  Set Target = col(0)
End Function

Sub JumpToObj(Obj)
  If Obj Is Nothing Then Exit Sub
  Set dlg = ThisApplication.Dialogs.EditObjectDlg
  dlg.Object = Obj
  ThisForm.Close True
  dlg.Show
End Sub


sub set_Doc_Cancel_Tech(Obj)
  If Obj.IsKindOf("OBJECT_CONTRACT") Then _
    Call ThisApplication.ExecuteScript("CMD_CONTRACT_INVALIDATED","Main",Obj)
    Obj.Savechanges(0)
  if not isEmpty(thisForm) then _
       thisForm.Close false

'Exit Sub
'  thisscript.SysAdminModeOn 
'   
'  if thisObject.StatusName = "STATUS_KD_DRAFT" or  thisObject.StatusName = "STATUS_KD_CHECK" then 'удалить совсем
'      Answer = MsgBox("Вы действительно хотите удалить документ?", vbCritical + vbYesNo,"Удалить документ?")
'      If answer <> vbYes Then exit sub 

'      del_AllOrders(thisObject)
'      thisObject.Erase
'      msgbox "Документ удален!"
'      if not isEmpty(thisForm) then _
'         thisForm.Close false
'      exit sub   
'  else
'    Answer = MsgBox("Вы действительно хотите Отменить подготовку документа?" & vbNewLine & _
'        "После отмены, документ перестанет быть доступным", VbCritical + vbYesNo, "Отменить подготовку документа?")
'    If answer <> vbYes Then exit sub 
''  спрашиваем комментарий 
'  txt =   txt = thisApplication.ExecuteScript("CMD_KD_COMMON_LIB", "GetComment","Введите причину отмены документа")
'  'GetComment("Введите причину отмены документа") 
'  if IsEmpty(txt) then exit sub
'  if trim(txt) = "" then 
'      msgbox "Невозможно отменить документ не указав причину." & vbNewLine & _
'        "Пожалуйста, введите причину отклонения", vbCritical, "Не задана причина отклонения!"
'      exit sub  
'  end if

'  'отменить все невыполненые поручения
'    delNotReadedOrder (thisObject)
'    set_AllOrderCancel(thisObject)
'  'изменить статус
'    thisObject.Status = thisApplication.Statuses("STATUS_KD_CANCEL")
'    thisObject.Update
'    call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", thisObject)
'  end if
'  msgbox "Документ отменен!"
'  if not isEmpty(thisForm) then _
'       thisForm.Close false
end sub

sub return_To_Work_Tech(Obj)
  If Obj.IsKindOf("OBJECT_CONTRACT") Then _
    Call ThisApplication.ExecuteScript("CMD_CONTRACT_BACK_TO_WORK","Main",Obj)
  
end sub

' Определение корневой папки для создания объекта
Function GetObjectRoot(ObjDefName)
  Set GetObjectRoot = Nothing
  Set ObjRoots = thisApplication.ExecuteScript("CMD_KD_FOLDER","GET_FOLDER","",thisApplication.ObjectDefs(ObjDefName))
  if  ObjRoots is nothing then  
    msgBox "Не удалось создать папку", vbCritical, "Объект не был создан"
    exit Function
  end if
  Set GetObjectRoot = ObjRoots
End Function
