' Автор: Стромков С.А.
'
' Модуль генерации шифров объектов
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016


'==============================================================================
' Функция формирует описание объекта
'------------------------------------------------------------------------------
' ПРИНИМАЕТ:
'   Number:Integer - номер сообщения
'   Str1:String - Параметр 1 для подстановки в сообщение
'   Str2:String - Параметр 2 для подстановки в сообщение
'   Str3:String - Параметр 3 для подстановки в сообщение
'   Str4:String - Параметр 4 для подстановки в сообщение
' ВОЗВРАЩАЕТ:
'   ShowWarning:Integer- код ошибки MsgBox
'==============================================================================
Function ObjectDescription(o_)
  ObjectDescription=-1
  Dim oDefDesc
  set oDef=o_.ObjectDef
  oDefDesc=oDef.DescriptionFormat
  
  do while ObjectDescription=-1
    if InStr(oDefDesc,"{")=0 then 
      ObjectDescription=oDefDesc
      msgbox ObjectDescription
      exit Function
    end if
    
    pos1 = InStr(oDefDesc,"{")
    pos2 = InStr(oDefDesc,"}")
    attrname=mid (oDefDesc,pos1+1,pos2-pos1-1)
    attr=o_.Attributes(attrname)
    
    oDefDesc_=replace(oDefDesc,"{"&attrname&"}",attr)
    oDefDesc=oDefDesc_
  loop
End Function

Function ObjectNumber(o_)
  ObjectNumber = false
  dim num(1)
  dim a
  dim oDef
  oDef=o_.ObjectDefName
  num(1)="OBJECT_WORK_DOCS_FOR_BUILDING|{.ATTR_WORK_DOCS_FOR_BUILDING_CODE}|.|{ATTR_WORK_DOCS_FOR_BUILDING_POZ}"

  for i=1 to ubound(num)
    a=split(num(i),"|")
    if a(0)=oDef then
      ObjectNumber=""
      for j=1 to Ubound(a)
        ObjectNumber=ObjectNumber+a(j)
      next
    end if    
  next
End Function


' Проверяем наличие объекта по одному из обязательных, уникальных параметров, 
' если объект должен быть уникальным в папке
Function CheckObjExist(o_,attr,Desc,mCode)
  CheckObjExist=false
  set p =o_.Parent
  If p Is Nothing Then Exit Function
  for each o in p.Content
    if o.attributes.has(attr) then  
      if o.attributes(attr) = Desc and o.handle <> o_.handle then
        ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, mCode,Desc,o_.Parent.Description
        CheckObjExist=true
      end if
    end if
  next
End Function

'Функция формирует Шифр объекта
Function GetObjNumber(Obj)
 Set p = GetAttribute(Obj,"ATTR_PROJECT","")

 Select Case Obj.ObjectDefName
'    Case "OBJECT_PROJECT_SECTION"  'Раздел проектной документации
'      If Obj.Attributes.Has("ATTR_PROJECT_DOCS_SECTION") Then
'        txt = Obj.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier.Code
'      End If
          
    Case "OBJECT_PROJECT_SECTION_SUBSECTION"  'Подраздел проектной документации
      If Obj.Attributes.Has("ATTR_PROJECT_DOCS_SECTION") Then
        txt = Obj.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier.Code
      End If
          
    Case "OBJECT_SURV"  'Работа
      If Obj.Attributes.Has("ATTR_S_SURV_TYPE") Then
        txt = Obj.Attributes("ATTR_S_SURV_TYPE")
      End If
          
    Case "OBJECT_T_TASK"  'Задание
'      Set tRows =  GetAttribute(Obj,"ATTR_T_TASK_TDEPTS_TBL","")
'      Set Obj0 = GetAttribute(Obj,"ATTR_T_TASK_DEPARTMENT","")
'      If not Obj0 is Nothing Then
'        Code0 = GetAttribute(Obj0,"ATTR_CODE","")
'      End If
'      txt = GetAttribute(p,"ATTR_NAME_SHORT","") & " ЗПО № " & GetAttribute(p,"ATTR_PROJECT_CODE","") &_
'      "-" & GetAttribute(Obj,"ATTR_T_TASK_NUM","") & " (" & Code0 & ">" & DeptList(tRows) & ")"
        
    Case "OBJECT_STAGE"  'Стадия
      txt = Obj.Attributes("ATTR_PROJECT").Object.Attributes("ATTR_PROJECT_CODE") 
      If Obj.Attributes("ATTR_PROJECT_STAGE_CODE").Empty = False Then
        txt = txt & "/" & Obj.Attributes("ATTR_PROJECT_STAGE_CODE")
      End If
      
  End Select
  
  GetObjNumber = txt
end function

'Превращает коллекцию объектов в строку
Function DeptList(tRows)
  txt = ""
  For Each Row in tRows
    Code = ""
    Set Obj = GetAttribute(Row,"ATTR_T_TASK_DEPT","")
    Code = GetAttribute(Obj,"ATTR_CODE","")
    If Code <> "" Then
      If txt <> "" Then
        txt = txt & ", " & Code
      Else
        txt = Code
      End If
    End If
  Next
  DeptList = txt
End Function


PUBLIC FUNCTION getAttribute (byval Source, nameAttribute, defValue) '* as Variant
 '/* Получить значение атрибута по имени
 '/* Source может быть: Объект, Форма, Коллекция атрибутов, ссылка на Атрибут, строка табличного атрибута
 '/* defValue возвращается если: атрибут не содержит значения, атрибут отсутствует, источник или имя атрибута не указаны.
  THISSCRIPT.SYSADMINMODEON
    if varType(defValue)=vbObject then
      SET getAttribute=DEFVALUE 
    else
      getAttribute=DEFVALUE
    end if
    IF Source IS NOTHING THEN EXIT FUNCTION
    
    select case TypeName(Source)
      case "ITDMSObject"
        Source.Permissions = SysAdminPermissions
        IF nameAttribute=vbNullString  then exit function
        SET cAttrs=Source.ATTRIBUTES
        if not cAttrs.has(nameAttribute) then exit function
        set xAttr=cAttrs(nameAttribute)
      case "ITDMSInputForm"
        IF nameAttribute=vbNullString  then exit function
        SET cAttrs=Source.ATTRIBUTES
        if not cAttrs.has(nameAttribute) then exit function
        set xAttr=cAttrs(nameAttribute)      
      case "ITDMSAttributes"
        IF nameAttribute=vbNullString  then exit function
        if not Source.has(nameAttribute) then exit function
        set xAttr=Source(nameAttribute)        
      case "ITDMSAttribute", "ITDMSTableAttribute"
        set xAttr=Source
      case "ITDMSTableAttributeRow" ' конкретная строчка табличного атрибута
        IF nameAttribute=vbNullString  then exit function
        set Source=Source.Attributes
        if not Source.has(nameAttribute) then exit function
        set xAttr=Source(nameAttribute)         
      case else
        exit function
    end select

    if xAttr.Empty and xAttr.TYPE<>TDMTABLE then exit function        
    
    SELECT CASE xAttr.TYPE
          CASE TDMOBJECTLINK
            SET getAttribute=xAttr.OBJECT
          CASE TDMCLASSIFIER, TDMLIST
            SET getAttribute=xAttr.CLASSIFIER     
          CASE TDMUSERLINK
            SET getAttribute=xAttr.USER      
            IF getAttribute IS NOTHING THEN SET getAttribute=xAttr.Group  
          CASE TDMFILELINK
            SET getAttribute=xAttr.FILE     
          CASE TDMTABLE
            SET getAttribute=xAttr.ROWS      
          CASE ELSE
           getAttribute=xAttr.VALUE          
    END SELECT        

  THISSCRIPT.SYSADMINMODEOFF  
END FUNCTION

' Функция формирует Шифр проекта
Sub Set_ATTR_PROJECT_CODE (o_)
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr", o_,"ATTR_PROJECT_CODE", text1 & text2  
End Sub

'============================================================================================
'Функция формирования обозначения Полного комплекта
'Obj - ссылка на Полный комплект
Function WorkDocsBuildCodeGen(Obj)
  WorkDocsBuildCodeGen = ""
  Code = ""
  Set Parent = Obj.parent
  
  If parent Is Nothing Then Exit Function
  pDefname = parent.objectDefName
  
  If pDefName = "OBJECT_STAGE" Then
    'Код проекта
    Set oLink = ObjectLinkGet(Obj,"ATTR_PROJECT")
    If not oLink is Nothing Then
      Code = oLink.Attributes("ATTR_PROJECT_CODE").Value
    End If
    'Номер этапа строительства
    Set oLink = ObjectLinkGet(Obj,"ATTR_BUILDING_STAGE")
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
    'Код подобъекта
    If Obj.Attributes("ATTR_BUILDING_TYPE").Empty = False Then
      Num = Obj.Attributes("ATTR_BUILDING_TYPE").Classifier.Code
      If Num <> "" Then
        If Code <> "" Then
          Code = Code & "-" & Num
        Else
          Code = Num
        End If
      End If
    End If
    'Поз. по ГП
    Num = Obj.Attributes("ATTR_BUILDING_CODE").Value
    If Num <> "" Then
      If Code <> "" Then
        Code = Code & "-" & Num
      Else
        Code = Num
      End If
    End If
  ElseIf pDefName = "OBJECT_WORK_DOCS_FOR_BUILDING" Then
    Code = parent.attributes("ATTR_PROJECT_BASIC_CODE").Value
    'Код подобъекта
    If Obj.Attributes("ATTR_BUILDING_TYPE").Empty = False Then
      Num = Obj.Attributes("ATTR_BUILDING_TYPE").Classifier.Code
      If Num <> "" Then
        If Code <> "" Then
          Code = Code & "." & Num
        Else
          Code = Num
        End If
      End If
    End If
    'Поз. по ГП
    Num = Obj.Attributes("ATTR_BUILDING_CODE").Value
    If Num <> "" Then
      If Code <> "" Then
        Code = Code & "-" & Num
      Else
        Code = Num
      End If
    End If
  End If
  WorkDocsBuildCodeGen = Code
End Function

'============================================================================================
'Функция проверки перед формированием обозначения Полного комплекта
'Obj - ссылка на Полный комплект
Function WorkDocsBuildCodeGenCheck(Obj)
  WorkDocsBuildCodeGenCheck = True
  'Статус
  If Obj.StatusName = "STATUS_WORK_DOCS_FOR_BUILDING_IS_DEVELOPING" Then
    'True
  Else
    WorkDocsBuildCodeGenCheck = False
    Exit Function
  End If
  'Роль
  Set Roles = Obj.RolesForUser(ThisApplication.CurrentUser)
  If Roles.Has("ROLE_LEAD_DEVELOPER") = False and Roles.Has("ROLE_PART_RESP") = False Then
    WorkDocsBuildCodeGenCheck = False
  End If
End Function

'============================================================================================
'Функция формирования обозначения Проектного документа, чертежа
'Obj - ссылка на Проектный документ, Чертеж
Function DocDevCodeGen(Obj)
  DocDevCodeGen = ""
  Code = ""
  'Определяем Вид работ по проекту - ПЭМИК или другой
  WorkType = ""
  Set oLink = ObjectLinkGet(Obj,"ATTR_PROJECT")
  If not oLink is Nothing Then
    If oLink.Attributes("ATTR_PROJECT_WORK_TYPE").Empty = False Then
      If oLink.Attributes("ATTR_PROJECT_WORK_TYPE").Classifier.SysName = "NODE_WORK_TYPE_PEMC" Then
        WorkType = "ПЭМИК"
      End If
    End If
  End If
  
  'Вид работ - не ПЭМИК
  If WorkType = "" Then
    'Обозначение комплекта
    If not Obj.Parent is Nothing Then
      Set oParent = Obj.Parent
      If oParent.Attributes.Has("ATTR_WORK_DOCS_SET_CODE") Then
        Code = oParent.Attributes("ATTR_WORK_DOCS_SET_CODE").Value
        Num = oParent.Attributes("ATTR_WORK_DOCS_SET_NAME").Value
        If Num <> "" Then
          If Code = "" Then
            Code = Num
          End If
        End If
      ElseIf oParent.Attributes.Has("ATTR_PROJECT_BASIC_CODE") Then
        Code = oParent.Attributes("ATTR_PROJECT_BASIC_CODE").Value
        Num = oParent.Attributes("ATTR_WORK_DOCS_FOR_BUILDING_NAME").Value
      ElseIf oParent.Attributes.Has("ATTR_VOLUME_CODE") Then
        Code = oParent.Attributes("ATTR_VOLUME_CODE").Value
      End If
    End If

    
    Select Case Obj.ObjectDefName
      Case "OBJECT_DOC_DEV"
        ' Объект проектирования
        If Obj.Attributes("ATTR_UNIT").Empty = False Then
          If Not Obj.Attributes("ATTR_UNIT").object Is Nothing Then
            Set oUnit = Obj.Attributes("ATTR_UNIT").Object
            ' Позиция по ГП
            Num = GetUnitCodeForDocNum(oUnit,"")
            If Num <> "" Then
              If Code <> "" Then
                Code = Code & "-" & Num
              Else
                Code = Num
              End If
            End If
          End If
        End If
        'Тип документа
        If Obj.Attributes("ATTR_PROJECT_DOC_TYPE").Empty = False Then
          Num = Obj.Attributes("ATTR_PROJECT_DOC_TYPE").Classifier.Code
          If Num <> "" Then
            If Code <> "" Then
              Code = Code & "-" & Num
            Else
              Code = Num
            End If
          End If
        End If
      Case "OBJECT_DRAWING"
          ' Объект проектирования
        If Obj.Attributes("ATTR_UNIT").Empty = False Then
          If Not Obj.Attributes("ATTR_UNIT").object Is Nothing Then
            Set oUnit = Obj.Attributes("ATTR_UNIT").Object
            ' Позиция по ГП
            Num = GetUnitCodeForDocNum(oUnit,"")
            If Num <> "" Then
              If Code <> "" Then
                Code = Code & "-" & Num
              Else
                Code = Num
              End If
            End If
          End If
        End If
        'Чертеж
          Page = Obj.Attributes("ATTR_G_PAGE_NUM")
          If Page <> "" Then
            If Code <> "" Then
              Code = Code & "-" & Page
            Else
              Code = Page '"л." &
            End If
          End If
    End Select

  'Вид работ - ПЭМИК
  ElseIf WorkType = "ПЭМИК" Then
    If not Obj.Parent is Nothing Then
      Set oParent = Obj.Parent
      'Код раздела
      Set oLink = ObjectLinkGet(oParent,"ATTR_VOLUME_SECTION")
      If not oLink is Nothing Then
        If oLink.Attributes("ATTR_PROJECT_DOCS_SECTION").Empty = False Then
          Num = oLink.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier.Code
          If Num <> "" Then
            Code = Num
          End If
        End If
      End If
      'Номер отчета
      If oParent.ObjectDefName = "OBJECT_VOLUME" Then
        Num = oParent.Attributes("ATTR_VOLUME_PART_NUM").Value
        If Num <> "" Then
          If Code <> "" Then
            Code = Code & "-" & Num
          Else
            Code = Num
          End If
        End If
      End If
      'Номер этапа
      If oParent.ObjectDefName = "OBJECT_WORK_DOCS_SET" Then
        Set oLink = ObjectLinkGet(oParent,"ATTR_CONTRACT_STAGE")
        If not oLink is Nothing Then
          Num = oLink.Attributes("ATTR_CONTRACT_STAGE_NUM").Value
          If Code <> "" Then
            Code = Code & "-" & Num
          Else
            Code = Num
          End If
        End If
      End If
      'Регистрационный номер договора
      Set Project = ObjectLinkGet(Obj,"ATTR_PROJECT")
      If not Project is Nothing Then
        Set oLink = ObjectLinkGet(Project,"ATTR_CONTRACT")
        If not oLink is Nothing Then
          Num = oLink.Attributes("ATTR_REG_NUMBER").Value
          If Code <> "" Then
            Code = Code & "-" & Num
          Else
            Code = Num
          End If
        End If
      End If
      'Номер книги
      If oParent.ObjectDefName = "OBJECT_VOLUME" Then
        Num = oParent.Attributes("ATTR_BOOK_NUM").Value
        If Num <> "" Then
          If Code <> "" Then
            Code = Code & "-" & Num
          Else
            Code = Num
          End If
        End If
      End If
    End If
  End If
  
  DocDevCodeGen = Code
End Function

' Возвращает часть обозначения документа, формируемую от объекта проектрования
' Obj: TDMSObject - объект проектирования, указанный на корточке документа
Function GetUnitCodeForDocNum(Obj,code_)
  GetUnitCodeForDocNum = ""
  ucode = ""
  uNum = Obj.Attributes("ATTR_UNIT_CODE").Value
  Set cls_ucode = Obj.Attributes("ATTR_UNIT_TYPE").Classifier

  If Not cls_ucode Is Nothing Then ucode = cls_ucode.Code

  If uNum = vbNullString Then 
    code = ucode
  Else
    code = uNum
  End If
  
  If Obj.Parent.ObjectDefName = "OBJECT_UNIT" Then
    Num = GetUnitCodeForDocNum(Obj.Parent,code)
  End If

  If Num = "" Then
    code = code
  Else
    code = num & "-" & code
  End If

  GetUnitCodeForDocNum = code
End Function

'============================================================================================
'Функция проверки перед формированием обозначения Проектного документа
'Obj - ссылка на Полный комплект
Function DocDevCodeGenCheck(Obj)
  DocDevCodeGenCheck = True
  'Статус
  If Obj.StatusName = "STATUS_DOCUMENT_CREATED" Then
    'True
  Else
    DocDevCodeGenCheck = False
    Exit Function
  End If
  'Роль
  Set Roles = Obj.RolesForUser(ThisApplication.CurrentUser)
  If Roles.Has("ROLE_STRUCT_DEVELOPER") = False and Roles.Has("ROLE_DOC_DEVELOPER") = False Then
    DocDevCodeGenCheck = False
  End If
End Function

'============================================================================================
'Функция формирования Номера конкурентной закупки
'Obj - ссылка на 
Function TenderConcurentNumGen(Obj)
  TenderConcurentNumGen = ""
  Code = ""
'Номер компании в АСЭЗ
  AttrName = "ATTR_TENDER_ASEZ_NUM"
  If ThisApplication.Attributes.Has(AttrName) Then
    If ThisApplication.Attributes(AttrName).Empty = False Then
      Code = ThisApplication.Attributes(AttrName).Value
    End If
  End If
  'Уникальный номер закупки
  AttrName = "ATTR_TENDER_UNIQUE_NUM"
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      If Code <> "" Then
        Code = Code & "/" & Obj.Attributes(AttrName).Value
      Else
        Code = Obj.Attributes(AttrName).Value
      End If
    End If
  End If
  'Постоянная часть
  If Code <> "" Then
    Code = Code & "/ЗП/ГОС/Э"
  Else
    Code = "ЗП/ГОС/Э"
  End If
  'Дата публикации извещения о закупке
  AttrName = "ATTR_TENDER_INVITATION_DATA_EIS"
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      If Code <> "" Then
        Code = Code & "/" & Obj.Attributes(AttrName).Value
      Else
        Code = Obj.Attributes(AttrName).Value
      End If
    End If
  End If
  
  TenderConcurentNumGen = Code
End Function

'============================================================================================
'Функция формирования Обозначения документа закупки
'Obj - ссылка на 
Function PurchaseDocCodeGen(Obj)
  PurchaseDocCodeGen = ""
  Code = ""
  If Obj.Parent is Nothing Then Exit Function
  Set Parent = Obj.Parent
  
  'Порядковый номер документа такого типа
  Set Query = ThisApplication.Queries("QUERY_PURCHASE_DOCS_SEARCH_FOR_TYPE")
  Query.Parameter("GUID") = "<> '" & Obj.GUID & "'"
  Query.Parameter("PARENT") = Parent
  AttrName = "ATTR_PURCHASE_DOC_TYPE"
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      If not Obj.Attributes(AttrName).Classifier is Nothing Then
        Set Clf = Obj.Attributes(AttrName).Classifier
        Query.Parameter("TYPE") = Clf
      End If
    End If
  End If
  Set Objects = Query.Objects
  Code = Objects.Count + 1
  
  'Уникальный номер закупки
'  AttrName = "ATTR_TENDER_UNIQUE_NUM"
   AttrName = "ATTR_TENDER_CONCURENT_NUM_EIS"

'  AttrName = "ATTR_TENDER_NUM_EIS"
  If Parent.Attributes.Has(AttrName) Then
    If Parent.Attributes(AttrName).Empty = False Then
      Val = Parent.Attributes(AttrName).Value ' &  "-" 
'      Code = Val & "0" & Code 
       Code = Code & "/" & Val
    End If
  End If
  AttrName = "ATTR_TENDER_EIS_NUM"
  If Parent.Attributes.Has(AttrName) Then
    If Parent.Attributes(AttrName).Empty = False Then
      Val = Parent.Attributes(AttrName).Value &  "-" 
      Code = Val & "0" & Code 
    End If
  End If
  'Проверка на повтор
  Query.Parameter("CODE") = Code
  Do While Query.Objects.Count > 0
    i = i + 1
    Code = i & Val
    Query.Parameter("CODE") = Code
  Loop
  
  PurchaseDocCodeGen = Code
End Function





'============================================================================================
'Функция формирования Обозначения документа закупки
'Obj - ссылка на 
Function PurchaseDocRegNumGen(Obj)
  PurchaseDocRegNumGen = ""
  Set parent = Obj.parent
  If Parent Is Nothing Then exit Function
  GetNewNO = 0
  Set QueryDoc = ThisApplication.Queries("QUERY_GET_PDOCMAX_NO")
  QueryDoc.Parameter("PARAM0") = parent.Handle
  QueryDoc.Parameter("PARAM1") = obj.Attributes("ATTR_PURCHASE_DOC_TYPE").Classifier
  Set sh = QueryDoc.Sheet
  if not sh is nothing then 
    if sh.RowsCount >0 then 
      IntValue = sh.CellValue(0,0)
'       IntValue = IntTryParse(sh.CellValue(0,0))
      GetNewNO = CInt(IntValue)
    end if 
  end if 
  GetNewNO = GetNewNO + 1
  PurchaseDocRegNumGen = GetNewNO
End Function

'============================================================================================
'Функция формирования обозначения Задания
'Obj - ссылка на Задание
Function TtaskCodeGen(Obj)
  TtaskCodeGen = ""
  Code = ""
  'Краткое наименование проекта
  Set oLink = ObjectLinkGet(Obj,"ATTR_PROJECT")
  If not oLink is Nothing Then
    ' Изменено по результатам испытаний в Самаре
'    code = oLink.Attributes("ATTR_NAME_SHORT").Value
    pCode = oLink.Attributes("ATTR_PROJECT_CODE").Value
    pShName = oLink.Attributes("ATTR_NAME_SHORT").Value
    If Trim(pCode) <> vbNullString Then code = Trim(pCode)
    If Trim(pShName) <> vbNullString Then 
      code = Trim(code & " " & pShName)
    End If
'    'Код проекта
'    Num = Trim(oLink.Attributes("ATTR_PROJECT_CODE").Value)
'    If Num <> "" Then
'      If Code <> "" Then
'        Code = Code & " ЗПО № " & Num
'      Else
'        Code = "ЗПО № " & Num
'      End If
'    End If
  End If
  
  'Номер задания
  If Obj.Attributes("ATTR_T_TASK_NUM").Empty = False Then
    Num = Obj.Attributes("ATTR_T_TASK_NUM").Value
    If Num <> "" Then
      If Code <> "" Then
        Code = Code & " ЗПО №" & Num
      Else
        Code = "ЗПО № " & Num
      End If
    End If
  End If
'  If Obj.Attributes("ATTR_T_TASK_NUM").Empty = False Then
'    Num = Obj.Attributes("ATTR_T_TASK_NUM").Value
'    If Num <> "" Then
'      If Code <> "" Then
'        Code = Code & " - " & Num
'      Else
'        Code = Num
'      End If
'    End If
'  End If
  
  'Аббревиатура выдающего отдела
  If Obj.Attributes("ATTR_T_TASK_DEPARTMENT").Empty = False Then
    If not Obj.Attributes("ATTR_T_TASK_DEPARTMENT").Object is Nothing Then
      Set Obj0 = Obj.Attributes("ATTR_T_TASK_DEPARTMENT").Object
      If Obj0.Attributes.Has("ATTR_CODE") Then
        Num = Obj0.Attributes("ATTR_CODE").Value
        If Num <> "" Then
          If Code <> "" Then
'            Code = Code & " (" & Num
            ' Изменено по результатам испытаний в Самаре
            Code = Code & " " & Num
          Else
            Code = Num
          End If
        End If
      End If
    End If
  End If
  
  'Аббревиатура принимающих отделов
  Set TableRows = Obj.Attributes("ATTR_T_TASK_TDEPTS_TBL").Rows
  If TableRows.Count <> 0 Then
    Code = Code & ">"
    Depts = ""
    For Each Row in TableRows
      If Row.Attributes("ATTR_T_TASK_DEPT").Empty = False Then
        If not Row.Attributes("ATTR_T_TASK_DEPT").Object is Nothing Then
          Set Obj0 = Row.Attributes("ATTR_T_TASK_DEPT").Object
          If Obj0.Attributes.Has("ATTR_CODE") Then
            Num = Obj0.Attributes("ATTR_CODE").Value
            If Num <> "" Then
              If Depts <> "" Then
                Depts = Depts & ", " & Num
              Else
                Depts = Num
              End If
            Else
              If Obj0.Attributes.Has("ATTR_NAME") Then
                name = Obj0.Attributes("ATTR_NAME").Value
                If Depts <> "" Then
                  Depts = Depts & ", " & Name
                Else
                  Depts = Name
                End If  
              End If         
            End If
          End If
        End If
      End If
    Next
    Code = Code & Depts
  End If
  
  'Добавляем скобку в конце
  ' Изменено по результатам испытаний в Самаре
'  If InStr(Code,"(") <> 0 Then Code = Code & ")"
  
  TtaskCodeGen = Code
End Function

'============================================================================================
'Функция формирования номера Тома
'Obj - ссылка на Том
Function VolumeNumCodeGen(Obj)
  VolumeNumCodeGen = ""
  Code = ""
  'Номер раздела
  Set oLink = ObjectLinkGet(Obj,"ATTR_VOLUME_SECTION")
  If not oLink is Nothing Then
    If oLink.Attributes("ATTR_SECTION_NUM").Empty = False Then
      Code = oLink.Attributes("ATTR_SECTION_NUM").Value
    End If
  End If
  'Номер части
  If Obj.Attributes("ATTR_VOLUME_PART_NUM").Empty = False Then
    Num = Obj.Attributes("ATTR_VOLUME_PART_NUM").Value
    If Num <> "" Then
      If Code <> "" Then
        Code = Code & "." & Num
      Else
        Code = Num
      End If
    End If
  End If
  'Номер книги
  If Obj.Attributes("ATTR_BOOK_NUM").Empty = False Then
    Num = Obj.Attributes("ATTR_BOOK_NUM").Value
    If Num <> "" Then
      If Code <> "" Then
        Code = Code & "." & Num
      Else
        Code = Num
      End If
    End If
  End If
  
  VolumeNumCodeGen = Code
End Function

'============================================================================================
'Функция проверки перед формированием номера, наименования, обозначения Тома
'Obj - ссылка на Том
Function VolumeCodeCheck(Obj)
  VolumeCodeCheck = True
  'Статус
  If Obj.StatusName = "STATUS_VOLUME_CREATED" or Obj.StatusName = "STATUS_VOLUME_IS_BUNDLING" Then
    'True
  Else
    VolumeCodeCheck = False
    Exit Function
  End If
  'Роль
  Set Roles = Obj.RolesForUser(ThisApplication.CurrentUser)
  If Roles.Has("ROLE_VOLUME_COMPOSER") = False Then
    VolumeCodeCheck = False
  End If
  If Obj.attributes.Has("ATTR_RESPONSIBLE") Then
    If Obj.attributes("ATTR_RESPONSIBLE").Empty = False Then
      If Not Obj.attributes("ATTR_RESPONSIBLE").User Is Nothing Then
        Set u = Obj.attributes("ATTR_RESPONSIBLE").User
        If ThisApplication.CurrentUser.SysName = u.SysName Then
          VolumeCodeCheck = False
        End If
      End If
    End If
  End If
End Function


'============================================================================================
'Функция формирования обозначения Тома
'Obj - ссылка на Том
Function VolumeCodeGen(Obj)
  VolumeCodeGen = ""
  Code = ""
  'Код проекта
  Set oLink = ObjectLinkGet(Obj,"ATTR_PROJECT")
  If not oLink is Nothing Then
    Code = oLink.Attributes("ATTR_PROJECT_CODE").Value
  End If
  'Код раздела
  Set oLink = ObjectLinkGet(Obj,"ATTR_VOLUME_SECTION")
  If not oLink is Nothing Then
    If oLink.Attributes("ATTR_PROJECT_DOCS_SECTION").Empty = False Then
      Num = oLink.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier.Code
      If Num <> "" Then
        If Code <> "" Then
          Code = Code & "-" & Num
        Else
          Code = Num
        End If
      End If
    End If
  End If
  
  If Obj.Parent.Attributes("ATTR_PROJECT_STRUCTURE_TYPE").Value = "Раздел" Then
    delimetr = ""
  ElseIf Obj.Parent.Attributes("ATTR_PROJECT_STRUCTURE_TYPE").Value = "Подраздел" Then
    delimetr = "."
  End If
  
  
  ' Номер части
  If Obj.Attributes("ATTR_VOLUME_PART_NUM").Empty = False Then
    Num = Obj.Attributes("ATTR_VOLUME_PART_NUM").Value
    If Num <> "" Then
      If Code <> "" Then
        Code = Code & delimetr &  Num
        'Code = Code & "." & Num
      Else
        Code = Num
      End If
    End If
  End If
  'Номер книги
  If Obj.Attributes("ATTR_BOOK_NUM").Empty = False Then
    Num = Obj.Attributes("ATTR_BOOK_NUM").Value
    If Num <> "" Then
      If Code <> "" Then
        Code = Code & "." & Num
      Else
        Code = Num
      End If
    End If
  End If
  
  VolumeCodeGen = Code
End Function

'============================================================================================
'Функция формирования наименования Тома
'Obj - ссылка на Том
Function VolumeNameGen(Obj)
  VolumeNameGen = ""
  Code = ""
  'Наименование раздела
  Set oLink = ObjectLinkGet(Obj,"ATTR_VOLUME_SECTION")
  If not oLink is Nothing Then
    If oLink.ObjectDefName = "OBJECT_PROJECT_SECTION" Then
      If oLink.Attributes("ATTR_PROJECT_DOCS_SECTION").Empty = False Then
        Code = "Раздел " & oLink.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier.Description
      End If
    End If
  End If
  
  'Наименование подраздела
  Set oLink = ObjectLinkGet(Obj,"ATTR_VOLUME_SECTION")
  If not oLink is Nothing Then
    If oLink.ObjectDefName = "OBJECT_PROJECT_SECTION_SUBSECTION" Then
      Set parent = oLink.Parent
      If Not parent Is Nothing Then
        If parent.Attributes("ATTR_PROJECT_DOCS_SECTION").Empty = False Then
          Code = "Раздел " & parent.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier.Description
        End If
      End If
      
      If oLink.Attributes("ATTR_PROJECT_DOCS_SECTION").Empty = False Then
        Code = Code & ". " & "Подраздел " & oLink.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier.Description
      End If
    End If
  End If
  
  'Номер части
  If Obj.Attributes("ATTR_VOLUME_PART_NUM").Empty = False Then
    Num = Obj.Attributes("ATTR_VOLUME_PART_NUM").Value
    If Num <> "" Then
      If Code <> "" Then
        Code = Code & ". Часть " & Num
      Else
        Code = Num
      End If
    End If
  End If
  'Наименование части
  If Obj.Attributes("ATTR_VOLUME_PART_NAME").Empty = False Then
    Num = Obj.Attributes("ATTR_VOLUME_PART_NAME").Value
    If Num <> "" Then
      If Code <> "" Then
        'Code = Code & " " & chr(171) & Num & chr(187)
        Code = Code & " " & chr(34) & Num & chr(34)
      Else
        Code = Num
      End If
    End If
  End If
  'Номер книги
  If Obj.Attributes("ATTR_BOOK_NUM").Empty = False Then
    Num = Obj.Attributes("ATTR_BOOK_NUM").Value
    If Num <> "" Then
      If Code <> "" Then
        Code = Code & ". Книга " & Num
      Else
        Code = Num
      End If
    End If
  End If
  'Наименование книги
  If Obj.Attributes("ATTR_BOOK_NAME").Empty = False Then
    Num = Obj.Attributes("ATTR_BOOK_NAME").Value
    If Num <> "" Then
      If Code <> "" Then
       ' Code = Code & " " & chr(171) & Num & chr(187)
        Code = Code & " " & chr(34) & Num & chr(34)
      Else
        Code = Num
      End If
    End If
  End If
  
  ' Тип тома
  If Obj.Attributes("ATTR_VOLUME_TYPE").Empty = False Then
    Num = Obj.Attributes("ATTR_VOLUME_TYPE").Classifier.code
    If Num <> "" Then
      If Code <> "" Then
        Code = Code & " " & Num
      Else
        Code = Num
      End If
    End If
  End If
  
  VolumeNameGen = Code
End Function

'============================================================================================
'Функция формирования полного описания Раздела
'Obj - ссылка на Раздел
Function ProjectSectionFullDescrGen(Obj)
  ProjectSectionFullDescrGen = ""
  Descr = ""
  '{ATTR_SECTION_NUM}. {ATTR_PROJECT_DOCS_SECTION.code} - {ATTR_NAME}
  'Номер раздела
  If Obj.Attributes.Has("ATTR_SECTION_NUM") = False Then
    Obj.Attributes.Create("ATTR_SECTION_NUM")
  End If
  If Obj.Attributes("ATTR_SECTION_NUM").Empty = False Then
    Descr = Obj.Attributes("ATTR_SECTION_NUM").Value
  End If
  'Код раздела
  If Obj.Attributes("ATTR_PROJECT_DOCS_SECTION").Empty = False Then
    If not Obj.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier is Nothing Then
'      Val = Obj.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier.Code
      Val = Obj.Attributes("ATTR_CODE")
      If Val <> "" Then
        If Descr <> "" Then
          Descr = Descr & ". " & Val
        Else
          Descr = Val
        End If
      End If
    End If
  End If
  'Наименование
  If Obj.Attributes("ATTR_NAME").Empty = False Then
    Val = Obj.Attributes("ATTR_NAME").Value
    If Val <> "" Then
      If Descr <> "" Then
        If Not Obj.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier Is Nothing Then
          If Obj.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier.Description = "Непроектный раздел" Then
            'Descr = Descr & " - Раздел " & Obj.Attributes("ATTR_SECTION_NUM") & " " & chr(34) & Val & chr(34)
            Descr = Descr & " - " & Val
          Else 
            Descr = Descr & " - " & Val
          End If
        End If
      Else
        Descr = Val
      End If
    End If
  End If
  
  ProjectSectionFullDescrGen = Descr
End Function

'============================================================================================
'Функция формирования короткого описания Раздела
'Obj - ссылка на Раздел
Function ProjectSectionShortDescrGen(Obj)
  ProjectSectionShortDescrGen = ""
  Descr = ""
  ATTR_SECTION_NUM = Obj.Attributes("ATTR_SECTION_NUM")
  Set cls = Obj.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier
  
  Code = Obj.Attributes("ATTR_CODE").Value
  If Not Obj.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier Is Nothing Then
    If Obj.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier.Description = "Непроектный раздел" Then
  '  If Obj.Attributes("ATTR_SECTION_NUM").Value = "NO" Then ' Непроектный раздел
      Descr = Obj.Attributes("ATTR_NAME").Value
      If Descr <> "" Then
        If Code <> "" Then
          treeDesc = ATTR_SECTION_NUM & ". " & Code'Code
        Else
          treeDesc = ATTR_SECTION_NUM & " - "& Descr
        End If
      End If
    Else ' Разделы по классификатору
      ' Атрибут для описания в дереве
      If Code = vbNullString Then
        treeDesc = Descr
      Else
        treeDesc = ATTR_SECTION_NUM & ". " & Code
      End If
    End If
  End If
  If Not cls Is Nothing Then
    If Trim(treeDesc) = "" Then treeDesc = cls.Description
  End If
  If Trim(treeDesc) = "" Then treeDesc = "<Без названия>"
  ProjectSectionShortDescrGen = treeDesc
End Function

'============================================================================================
'Функция формирования обозначения Раздела
'Obj - ссылка на Том
Function ProjectSectionCodeGen(Obj)
  ProjectSectionCodeGen = ""
  Code = ""
  'Код проекта
'  Set oLink = ObjectLinkGet(Obj,"ATTR_PROJECT")
'  If not oLink is Nothing Then
'    Code = oLink.Attributes("ATTR_PROJECT_CODE").Value
'  End If
  Set oStage = ThisApplication.ExecuteScript ("CMD_S_DLL", "GetStage", Obj)
  If not oStage is Nothing Then
    Code = oStage.Attributes("ATTR_PROJECT_STAGE_NUM").Value
  End If
  
  'Код раздела
  If Obj.Attributes("ATTR_PROJECT_DOCS_SECTION").Empty = False Then
'    Num = Obj.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier.Code
    Num = Obj.Attributes("ATTR_CODE")
    If Num <> "" Then
      If Code <> "" Then
        Code = Code & "-" & Num
      Else
        Code = Num
      End If
    End If
  End If
  
  ' Отключено Протокол Москва
'  ' Этап договора
'  Set stage = Obj.Attributes("ATTR_CONTRACT_STAGE").Object
'  If Not stage Is Nothing Then
'    If stage.Attributes("ATTR_CONTRACT_STAGE_NUM").Empty = False Then
'      sNum = stage.Attributes("ATTR_CONTRACT_STAGE_NUM")
'      Code = code & "/" & sNum
'    End If
'  End If
  ProjectSectionCodeGen = Code
End Function

'============================================================================================
'Функция формирования номера Раздела
'Obj - ссылка на раздел
Function ProjectSectionNumGen (Obj)
  ProjectSectionNumGen  = ""
  Code = ""
  'Номер раздела
  If not Obj is Nothing Then
    If Obj.Attributes("ATTR_PROJECT_DOCS_SECTION").Empty = False Then
      Num = Obj.Attributes("ATTR_PROJECT_DOCS_SECTION").Classifier.SysName
      Code = Right(Num, Len(Num)-InStrRev(Num, "_"))
    End If
  End If
  If code = "NO" Then code = ""
  ProjectSectionNumGen = Code
End Function

'============================================================================================
'Функция проверки перед формированием обозначения Раздела
'Obj - ссылка на Основной комплект
Function ProjectSectionCodeGenCheck(Obj)
  ProjectSectionCodeGenCheck = True
  'Статус
  If Obj.StatusName <> "STATUS_PROJECT_SECTION_IS_DEVELOPING" Then
    ProjectSectionCodeGenCheck = False
    Exit Function
  End If
  'Роль
'  Set Roles = Obj.RolesForUser(ThisApplication.CurrentUser)
'  If Roles.Has("ROLE_LEAD_DEVELOPER") = False Then
'    ProjectSectionCodeGenCheck = False
'  End If
End Function

'============================================================================================
'Функция формирования обозначения Основного комплекта
'Obj - ссылка на Основной комплект
Function WorkDocsSetCodeGen(Obj)
  WorkDocsSetCodeGen = ""
  Code = ""
  'Обозначение Полного комплекта
  If not Obj.Parent is Nothing Then
    Code = Obj.Parent.Attributes("ATTR_PROJECT_BASIC_CODE").Value
  End If
  'Код марки Основного комплекта по классификатору
  If Obj.Attributes("ATTR_WORK_DOCS_SET_MARK").Empty = False Then
    Num = Obj.Attributes("ATTR_WORK_DOCS_SET_MARK").Classifier.Code
    If Num <> "" Then
      If Code <> "" Then
        Code = Code & "-" & Num
      Else
        Code = Num
      End If
    End If
  End If
  
  'Порядковый номер комплекта по проекту
  Set Query = ThisApplication.Queries("QUERY_WORKDOCSET_SEARCH_ON_CODE")
  Query.Parameter("PROJECT") = Obj.Attributes("ATTR_PROJECT").Object
  Query.Parameter("NOTOBJ") = "<> '" & Obj.Description & "'"
  Query.Parameter("CODE") = Obj.Attributes("ATTR_WORK_DOCS_SET_MARK").Classifier
  Set Objects = Query.Objects
  If Objects.Count > 0 Then
    Num = 0
    For Each qObj in Objects
      Num0 = GetNumDocsSet(qObj)
      If Num < Num0 Then
        Num = Num0
      End If
    Next
    Code = Code & Num+1
    Obj.Attributes("ATTR_WORK_DOCS_SET_NUMBER").Value = Clng(Num)+1
  End If
  
  WorkDocsSetCodeGen = Code
End Function

Function WorkDocsSetCodeGenNumb(Obj,Numb)
  WorkDocsSetCodeGenNumb = ""
  Code = ""
  'Обозначение Полного комплекта
  If not Obj.Parent is Nothing Then
    Code = Obj.Parent.Attributes("ATTR_PROJECT_BASIC_CODE").Value
  End If
  'Код марки Основного комплекта по классификатору
  If Obj.Attributes("ATTR_WORK_DOCS_SET_MARK").Empty = False Then
    Num = Obj.Attributes("ATTR_WORK_DOCS_SET_MARK").Classifier.Code
    If Num <> "" Then
      If Code <> "" Then
        Code = Code & "-" & Num
      Else
        Code = Num
      End If
    End If
  End If
  
  'Порядковый номер комплекта по проекту
  Set Query = ThisApplication.Queries("QUERY_WORKDOCSET_SEARCH_ON_CODE")
  Query.Parameter("PROJECT") = Obj.Attributes("ATTR_PROJECT").Object
  Query.Parameter("NOTOBJ") = "<> '" & Obj.Description & "'"
  Query.Parameter("CODE") = Obj.Attributes("ATTR_WORK_DOCS_SET_MARK").Classifier
  Set Objects = Query.Objects
  If Objects.Count > 0 Then
    Num = 0
    For Each qObj in Objects
      Num0 = GetNumDocsSet(qObj)
      If Num < Num0 Then
        Num = Num0
      End If
    Next
    Code = Code & Num+1
    Obj.Attributes("ATTR_WORK_DOCS_SET_NUMBER").Value = Clng(Num)+1
  End If
  
  WorkDocsSetCodeGenNumb = Code
End Function
'============================================================================================
'Функция формирования описания договораа
'Obj:Object - ссылка на договор

Function GetContractDescription(Obj)
  Obj.Permissions=SysadminPermissions
  GetContractDescription = ""
  If Obj.Attributes.Has("ATTR_REG_NUMBER") = False Then Exit Function
      If Obj.Attributes("ATTR_REG_NUMBER").Empty = True Then
        YearStr = Date
        YearStr = CStr(Year(YearStr))
        YearStr = Right(YearStr,2)
        SysID = CStr(Obj.Attributes("ATTR_KD_IDNUMBER").Value)
        If Len(SysID)<3 Then
          SysID = Right("000" & SysID,3)
        End If
    
        desc = "[" & SysID & "/" & YearStr & "]"
      Else
        ATTR_REG_NUMBER = Obj.Attributes("ATTR_REG_NUMBER").Value
        Select Case Obj.ObjectDefName
          Case "OBJECT_CONTRACT"
            desc = "№ " & ATTR_REG_NUMBER
            If Obj.Attributes.Has("ATTR_DATA") = True Then
              If Obj.Attributes("ATTR_DATA").Empty = False Then
                ATTR_DATA = Obj.Attributes("ATTR_DATA").Value
                desc = desc & " от " & ATTR_DATA
              End If
            End If
          Case "OBJECT_CONTRACT_COMPL_REPORT"
            desc = "Акт № " & ATTR_REG_NUMBER
            If Obj.Attributes.Has("ATTR_DATA") = True Then
              If Obj.Attributes("ATTR_DATA").Empty = False Then
                ATTR_DATA = Obj.Attributes("ATTR_DATA").Value
                desc = desc & " от " & ATTR_DATA
              End If
            End If        
                   
          Case "OBJECT_AGREEMENT"
            desc = "Соглашение № " & ATTR_REG_NUMBER
            If Obj.Attributes.Has("ATTR_DATA") = True Then
              If Obj.Attributes("ATTR_DATA").Empty = False Then
                ATTR_DATA = Obj.Attributes("ATTR_DATA").Value
                desc = desc & " от " & ATTR_DATA
              End If
            End If
            If Obj.Attributes("ATTR_AGREEMENT_TYPE").Empty = False Then
              Set cls = Obj.Attributes("ATTR_AGREEMENT_TYPE").Classifier
              If Not cls Is Nothing Then 
                desc = desc & " " & Obj.Attributes("ATTR_AGREEMENT_TYPE").Classifier.Description
              End If
            End If
          Case Else
            desc = ""
        End Select
      End If
  GetContractDescription = desc
End Function


'============================================================================================
'Функция получения регистрационного номера договора
'Obj:Object - ссылка на проект
'DateReg:Date - дата регистрации договора (не задано, если текущая)
Function ContractRegNumGet(Obj,DateReg)
  ThisScript.SysAdminModeOn
  ContractRegNumGet = ""
  If DateReg = "" Then DateReg = Date
  'Определяем текущий год
  YearStr = CStr(Year(DateReg))
  Stol = Mid(YearStr, 2, 1)
  If Stol = 0 Then
    YearStr = Right(YearStr,2)
  Else
    YearStr = Right(YearStr,3)
  End If
  
  'Поиск максимального номера в текущем году
  Set Query = ThisApplication.Queries("QUERY_CONTRACT_REGNUM_GET")
  Par = ">= 01.01." & YearStr & " AND <= 31.12." & YearStr
  Query.Parameter("OBJ") = "<> '" & Obj.Description & "'" 
  Query.Parameter("YEAR") = Par
  If Query.Sheet.RowsCount > 0 Then
    Num = Query.Sheet.CellValue(0,0)
  Else
    Num = 1
  End If
  
  'Определяем порядковый номер договора
  Num = Num + 1
  NumStr = CStr(Num)
  ContractRegNumGet = "НГП-#" & NumStr & "#/" & YearStr
End Function

'============================================================================================
'Функция получения регистрационного номера накладной
'Obj:Object - ссылка на проект
'DateReg:Date - дата регистрации накладной (не задано, если текущая)
Function InvoiceRegNumGet(Obj,DateReg)
  ThisScript.SysAdminModeOn
  InvoiceRegNumGet = ""
  If DateReg = "" Then DateReg = Date
  'Определяем текущий год
  YearStr = CStr(Year(DateReg))
  Stol = Mid(YearStr, 2, 1)
  If Stol = 0 Then
    YearStr = Right(YearStr,2)
  Else
    YearStr = Right(YearStr,3)
  End If
  
  'Поиск максимального номера в текущем году
  Set Query = ThisApplication.Queries("QUERY_INVOICE_REGNUM_GET")
'   Query.Parameter("PARAM0") = obj.parent.handle
   Query.Parameter("PARAM1") = obj.Attributes("ATTR_PROJECT").Object
   Query.Parameter("PARAM3") = obj.Handle
'  Par = ">= 01.01." & YearStr & " AND <= 31.12." & YearStr
'  Query.Parameter("OBJ") = "<> '" & Obj.Description & "'" 
'  Query.Parameter("YEAR") = Par
  If Query.Sheet.RowsCount > 0 Then
    Num = Query.Sheet.CellValue(0,0)
  Else
    Num = 1
  End If
  
  'Определяем порядковый номер договора
  Num = Num + 1
  NumStr = CStr(Num)
  InvoiceRegNumGet = NumStr
End Function

Function AgreementRegNumGet(Obj,DateReg)
  ThisScript.SysAdminModeOn
  AgreementRegNumGet = ""
  If DateReg = "" Then DateReg = Date
  'Определяем текущий год
  YearStr = CStr(Year(DateReg))
  Stol = Mid(YearStr, 2, 1)
  If Stol = 0 Then
    YearStr = Right(YearStr,2)
  Else
    YearStr = Right(YearStr,3)
  End If
  
  'Поиск максимального номера в текущем году
  Set Query = ThisApplication.Queries("QUERY_AGREEMENT_REGNUM_GET")
  Query.Parameter("PARAM0") = obj.parent.handle
  Query.Parameter("PARAM3") = obj.Handle
  If Query.Sheet.RowsCount > 0 Then
    Num = Query.Sheet.CellValue(0,0)
  Else
    Num = 1
  End If
  
  'Определяем порядковый номер договора
  Num = Num + 1
  NumStr = CStr(Num)
  AgreementRegNumGet = NumStr
End Function

Function CCRRegNumGet(Obj,DateReg)
  ThisScript.SysAdminModeOn
  CCRRegNumGet = ""
  If DateReg = "" Then DateReg = Date
  'Определяем текущий год
  YearStr = CStr(Year(DateReg))
  Stol = Mid(YearStr, 2, 1)
  If Stol = 0 Then
    YearStr = Right(YearStr,2)
  Else
    YearStr = Right(YearStr,3)
  End If
  
  'Поиск максимального номера в текущем году
  Set Query = ThisApplication.Queries("QUERY_CCR_REGNUM_GET")
  Query.Parameter("PARAM0") = obj.parent.handle
  Query.Parameter("PARAM3") = obj.Handle
  If Query.Sheet.RowsCount > 0 Then
    Num = Query.Sheet.CellValue(0,0)
  Else
    Num = 1
  End If
  
  'Определяем порядковый номер договора
  Num = Num + 1
  NumStr = CStr(Num)
  CCRRegNumGet = NumStr
End Function

'============================================================================================
'Функция получения номера внутренней закупки
'Obj:Object - ссылка на закупку
'DateReg:Date - дата (не задано, если текущая)
Function PurchaseInsideNumGet(Obj,DateReg)
  ThisScript.SysAdminModeOn
  PurchaseInsideNumGet = ""
  TenderPlan = ""
  If DateReg = "" Then DateReg = Date
  
  'Определяем текущий год
  Par = ""
  YearStr = ""
  If Obj.Attributes.Has("ATTR_TENDER_PLAN_YEAR") Then
    If Obj.Attributes("ATTR_TENDER_PLAN_YEAR").Empty = False Then
      If not Obj.Attributes("ATTR_TENDER_PLAN_YEAR").Classifier is Nothing Then
        YearStr = Obj.Attributes("ATTR_TENDER_PLAN_YEAR").Classifier.Description 'Code
        Par = YearStr
        YearStr = Right(YearStr,2)
      End If
    End If
  End If
  
  If YearStr = "" Then
  YearStr = CStr(Year(DateReg))
  Stol = Mid(YearStr, 2, 1)
  If Stol = 0 Then
    YearStr = Right(YearStr,2)
    Par = 20 & YearStr
'    msgbox Par
  Else
    YearStr = Right(YearStr,3)
  End If
  End If
  'Определяем Название раздела Плана
  If Obj.Attributes.Has("ATTR_TENDER_PLAN_PART_NAME") Then
    If Obj.Attributes("ATTR_TENDER_PLAN_PART_NAME").Empty = False Then
      If not Obj.Attributes("ATTR_TENDER_PLAN_PART_NAME").Classifier is Nothing Then
        TenderPlan = Obj.Attributes("ATTR_TENDER_PLAN_PART_NAME").Classifier.Code
      End If
    End If
  End If
  
  'Поиск максимального номера в текущем году
  Set Query = ThisApplication.Queries("QUERY_PURCHASE_INSIDE_NUM_GET")
'  Par = ">= 01.01." & YearStr & " AND <= 31.12." & YearStr

  Query.Parameter("OBJ") = "<> '" & Obj.Description & "'" 
'  msgbox Query.Parameter("OBJ")
  Query.Parameter("YEAR") = Par
  
  If Query.Sheet.RowsCount > 0 Then
    Num = Query.Sheet.CellValue(0,0)
'    msgbox Num
  Else
    Num = 1
  End If
'   msgbox Query.Sheet.RowsCount
  'Определяем порядковый номер закупки
'  If Obj.Attributes("ATTR_PROJECT_ORDINAL_NUM").Empty = True Then
    Num = Num + 1
'  Else
'    Num = Obj.Attributes("ATTR_PROJECT_ORDINAL_NUM")
'  End If
  NumStr = CStr(Num)
  If Len(NumStr)<4 Then 
    NumStr = Right(("0000" & NumStr),4)
  End If
  If TenderPlan = "" Then
    PurchaseInsideNumGet = YearStr & "_НГП-#" & NumStr
  Else
    PurchaseInsideNumGet = YearStr & "_НГП-" & TenderPlan & "-#" & NumStr
  End If
End Function

'============================================================================================
'Функция проверки перед формированием обозначения Основного комплекта
'Obj - ссылка на Основной комплект
Function WorkDocsSetCodeGenCheck(Obj)
  WorkDocsSetCodeGenCheck = True
  'Статус
  If Obj.StatusName = "STATUS_WORK_DOCS_SET_IS_DEVELOPING" Then
    'True
  Else
    WorkDocsSetCodeGenCheck = False
    Exit Function
  End If
  'Роль
  Set Roles = Obj.RolesForUser(ThisApplication.CurrentUser)
  If Roles.Has("ROLE_LEAD_DEVELOPER") = False Then
    WorkDocsSetCodeGenCheck = False
  End If
End Function

'======================================================================================
'Функция получения номера Основного комплекта из шифра (максимум 5 цифр)
Function GetNumDocsSet(Obj)
  GetNumDocsSet = 0
  Descr = Obj.Attributes("ATTR_WORK_DOCS_SET_CODE").Value
  Chr1 = Right(Descr,1)
  If IsNumeric(Chr1) Then
    Chr2 = Right(Descr,2)
    If IsNumeric(Chr2) Then
      Chr3 = Right(Descr,3)
      If IsNumeric(Chr3) Then
        Chr4 = Right(Descr,4)
        If IsNumeric(Chr4) Then
          Chr5 = Right(Descr,5)
          If IsNumeric(Chr5) Then
            GetNumDocsSet = Chr5
          Else
            GetNumDocsSet = Chr4
          End If
        Else
          GetNumDocsSet = Chr3
        End If
      Else
        GetNumDocsSet = Chr2
      End If
    Else
      GetNumDocsSet = Chr1
    End If
  End If
End Function

'Функция получения ссылки на объект
'Obj - Объект, содержащий ссылку на объект
'AttrName - SySName атрибута, который содержит ссылку
Function ObjectLinkGet(Obj,AttrName)
  Set ObjectLinkGet = Nothing
  'В остальных случаях ищем атрибут с ссылкой
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      If not Obj.Attributes(AttrName).Object is Nothing Then
        Set ObjectLinkGet = Obj.Attributes(AttrName).Object
      End If
    End If
  End If
End Function

' generates new ID with pattern NNNN-YY
' depending on given object def and attribute def
' objDef - string, object definition
' attDef - string, optional, attribute definition
Public Function GetNewId(objDef, attDef)
ThisScript.SysAdminModeOn
  GetNewId = ""
  
  If IsEmpty(objDef) Or vbString <> VarType(objDef) Then _
    Err.Raise vbObjectError, "CMD_S_NUMBERING.GetNewId", _
      "Object definition required to produce new id"
  
  ' compose key    
  Dim key
  key = objDef
  If vbString = VarType(attDef) And "" <> attDef Then
    key = Join(Array(objDef, attDef), ".")
  End If
  
  ' locate generator object
  Dim gen
  Set gen = LocateGenerator(key)
  If gen Is Nothing Then Set gen = CreateNewGenerator(key)
  
  ' update generator object
  Dim id, att
  gen.Update
  Set att = gen.Attributes("ATTR_KD_IDNUMBER")
  id = att.Value
  gen.Permissions = SysAdminPermissions
  att.Value = id + 1
  gen.Update
'  gen.SaveChanges
  Set gen = Nothing
  
  GetNewId = id & "-" & Right(Year(ThisApplication.CurrentTime), 2)
End Function

' helper function to locate generator object
Private Function LocateGenerator(key)
  Set LocateGenerator = Nothing
  
  If vbString <> VarType(key) And "" = key Then
    Err.Raise vbObjectError, "CMD_S_NUMBERING.LocateGenerator", _
      "Invalid argument, key"
  End If
  
  Dim qry, objs
  Set qry = ThisApplication.CreateQuery()
  qry.AddCondition tdmQueryConditionObjectDef, "OBJECT_SYSTEM_ID"
  qry.AddCondition tdmQueryConditionAttribute, key, "ATTR_KD_OBJECT_TYPE"
  qry.AddCondition tdmQueryConditionAttribute, _
    Year(ThisApplication.CurrentTime), "ATTR_KD_YEAR"
  
  Set objs = qry.Objects
  If 0 = objs.Count Then Exit Function
  Set LocateGenerator = objs(0)
End Function

' helper function to create new generator object
Private Function CreateNewGenerator(key)
  Set CreateNewGenerator = Nothing
  
  If vbString <> VarType(key) And "" = key Then
    Err.Raise vbObjectError, "CMD_S_NUMBERING.CreateNewGenerator", _
      "Invalid argument, key"
  End If
  
  ThisScript.SysAdminModeOn
  
  Dim obj, r
  Set obj = ThisApplication.ObjectDefs("OBJECT_SYSTEM_ID").CreateObject()
  With obj.Attributes
    .Item("ATTR_KD_IDNUMBER").Value = 1
    .Item("ATTR_KD_OBJECT_TYPE").Value = key
    .Item("ATTR_KD_YEAR").Value = Year(ThisApplication.CurrentTime)
  End With
  For Each r In obj.Roles
    r.Erase
  Next
  obj.Roles.Create("ROLE_PUBLIC", _
    ThisApplication.Groups("ALL_USERS")).Inheritable = False
  obj.SaveChanges
  
  ThisScript.SysAdminModeOff
  Set CreateNewGenerator = obj
End Function
