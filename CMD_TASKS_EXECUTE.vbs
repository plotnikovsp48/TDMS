
' Команда - Внести изменения в БД
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2018 г.


ThisScript.SysAdminModeOn
ThisApplication.Utility.WaitCursor = True
Set Progress = ThisApplication.Dialogs.ProgressDlg
Progress.Start

'Задание 027
'Call Task27

'Задание 026
'Call Task26

'Задание 033
'Call Task33

'Задание 034
'Call Task34

'Задание 028
'Call Task28

'Задание 036
'Call Task36

'Задание 041
'Call Task41

'Задание 038
'Call Task38

'Call Case4031

'Call Case4111

'Call Case4157

'Call Case4158

'Call Case4215

'Call Case4219

'Call Case4220

'Call Case4241

'Call Case4236

'Call Case4249

'Call Case4251

'Call Case4249

'Call Case4262

'Call Case4287

'Call Case4307

'Call Case4300

'Call Case4313

'Call Case4325

'Call Case4293

'Call Case4330

'Call Case4339

'Call Case4338

'Call Case4353

'Call Case4345

'Call Case4332

'Call Case4342

'Call Case4337

'Call Case4356

'Call Case4384

'Call Case4349

'Call Case4383

'Call Case4394

'Call Case4391

'Call Case4470

'Call Case4492

'Call Case4584

'Call Case4484

Call Case6097

ThisApplication.Utility.WaitCursor = False
Progress.Stop

'===========================================================================================================
Sub Task27()
  str = "Задание 027:"
  str0 = ""
  Progress.Text = "Выполняется задание 027"
  
  'Обновляем атрибуты объекта типа "Проект"
  StrAdd = "ATTR_DURATION,ATTR_CONTRACT,ATTR_PROJECT_STAGE_CODE,ATTR_CURATOR,ATTR_USER,ATTR_USER_DEPT," &_
  "ATTR_PROJECTS_LINKED"
  StrDel = "ATTR_S_COMPLEX,ATTR_REG_NUMBER"
  Call ObjDefAttrAddAll("OBJECT_PROJECT",StrAdd,StrDel,str0)
  
  'Обновляем атрибуты объекта типа "Раздел"
  StrAdd = "ATTR_CONTRACT_STAGE,ATTR_NAME"
  StrDel = "ATTR_SUBCONTRACTOR_CLS"
  Call ObjDefAttrAddAll("OBJECT_PROJECT_SECTION",StrAdd,StrDel,str0)
  
  'Обновляем атрибуты объекта типа "Подраздел"
  StrAdd = "ATTR_CONTRACT_STAGE,ATTR_NAME"
  StrDel = ""
  Call ObjDefAttrAddAll("OBJECT_PROJECT_SECTION_SUBSECTION",StrAdd,StrDel,str0)
  
  'Обновляем атрибуты объекта типа "Том"
  StrAdd = "ATTR_VOLUME_SECTION,ATTR_CONTRACT_STAGE,ATTR_VOLUME_PART_NAME,ATTR_BOOK_NUM,ATTR_CHANGE_NUM"
  StrDel = ""
  Call ObjDefAttrAddAll("OBJECT_VOLUME",StrAdd,StrDel,str0)
  
  'Обновляем атрибуты объекта типа "Полный комплект"
  StrAdd = "ATTR_BUILDING_CODE,ATTR_BUILDING_TYPE,ATTR_CONTRACT_STAGE,ATTR_PROJECT_BASIC_CODE"
  StrDel = "ATTR_SUBCONTRACTOR_CLS,ATTR_WORK_DOCS_FOR_BUILDING_POZ,ATTR_WORK_DOCS_FOR_BUILDING_CODE"
  Call ObjDefAttrAddAll("OBJECT_WORK_DOCS_FOR_BUILDING",StrAdd,StrDel,str0)
  
  'Обновляем атрибуты объекта типа "Основной комплект"
  StrAdd = "ATTR_CHANGE_NUM,ATTR_CONTRACT_STAGE"
  StrDel = ""
  Call ObjDefAttrAddAll("OBJECT_WORK_DOCS_SET",StrAdd,StrDel,str0)
  
  'Обновляем атрибуты объекта типа "Проектный документ"
  StrAdd = "ATTR_CHANGE_NUM,ATTR_RESPONSIBLE,ATTR_P_TASK_DATE_PLANE_START,ATTR_P_TASK_DATE_PLANE_END," &_
  "ATTR_DURATION_PLAN,ATTR_P_TASK_DATE_FACT_START,ATTR_P_TASK_DATE_FACT_END,ATTR_DURATION_FACT,ATTR_TOPLATAN"
  StrDel = ""
  Call ObjDefAttrAddAll("OBJECT_DOC_DEV",StrAdd,StrDel,str0)
  
  'Обновляем атрибуты объекта типа "Чертеж"
  StrAdd = "ATTR_CHANGE_NUM,ATTR_RESPONSIBLE,ATTR_P_TASK_DATE_PLANE_START,ATTR_P_TASK_DATE_PLANE_END," &_
  "ATTR_DURATION_PLAN,ATTR_P_TASK_DATE_FACT_START,ATTR_P_TASK_DATE_FACT_END,ATTR_DURATION_FACT,ATTR_TOPLATAN"
  StrDel = ""
  Call ObjDefAttrAddAll("OBJECT_DRAWING",StrAdd,StrDel,str0)
  
  'Обновляем атрибуты объекта типа "Документ"
  StrAdd = "ATTR_RESPONSIBLE,ATTR_KD_AGREENUM,ATTR_KD_ТLINKPROJ,ATTR_KD_LINKPROJ,ATTR_KD_GIP"
  StrDel = ""
  Call ObjDefAttrAddAll("OBJECT_DOCUMENT",StrAdd,StrDel,str0)
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Task26()
  str = "Задание 026:"
  str0 = ""
  Progress.Text = "Выполняется задание 026"
  
  'Удаляем Исходный материал
  If ThisApplication.ObjectDefs.Has("OBJECT_BOD_DOC") Then
    count = 0
    For Each Obj in ThisApplication.ObjectDefs("OBJECT_BOD_DOC").Objects
      Obj.Erase
      count = count + 1
    Next
    If count <> 0 Then
      str0 = str0 & chr(10) & chr(9) & "Удалено объектов типа ""Исходный материал"" - " & count
    End If
    If ThisApplication.ObjectDefs("OBJECT_BOD_DOC").Objects.Count = 0 Then
      ThisApplication.ObjectDefs("OBJECT_BOD_DOC").Erase
      str0 = str0 & chr(10) & chr(9) & "Удален тип объектов ""Исходный материал"""
    End If
  End If
  If ThisApplication.InputForms.Has("FORM_S_BOD_DOC") Then
    ThisApplication.InputForms("FORM_S_BOD_DOC").Erase
    str0 = str0 & chr(10) & chr(9) & "Удалена форма ввода ""Исходный материал"""
  End If
  
  'Замена объекта Документация, передаваемая заказчику на выборку
  If ThisApplication.Queries.Has("QUERY_DOCS_FOR_CUSTOMER") = False Then
    str0 = str0 & chr(10) & chr(9) & "Не найдена в системе выборка ""Документация, передаваемая заказчику""!"
  Else
    Set Query = ThisApplication.Queries("QUERY_DOCS_FOR_CUSTOMER")
    If ThisApplication.ObjectDefs.Has("OBJECT_DOCS_FOR_CUSTOMER") Then
      count = 0
      For Each Obj in ThisApplication.ObjectDefs("OBJECT_DOCS_FOR_CUSTOMER").Objects
        If not Obj.Parent is Nothing Then
          If Obj.Parent.Queries.Has("Документация, передаваемая заказчику") = False Then
            Obj.Parent.Queries.AddCopy Query
          End If
        End If
        If Obj.Content.Count <> 0 Then
          Obj.Content.RemoveAll
        End If
        Obj.Erase
        count = count + 1
      Next
      If count <> 0 Then
        str0 = str0 & chr(10) & chr(9) & "Заменено объектов типа ""Документация, передаваемая заказчику"" - " & count
      End If
      If ThisApplication.ObjectDefs("OBJECT_DOCS_FOR_CUSTOMER").Objects.Count = 0 Then
        ThisApplication.ObjectDefs("OBJECT_DOCS_FOR_CUSTOMER").Erase
        str0 = str0 & chr(10) & chr(9) & "Удален тип объектов ""Документация, передаваемая заказчику"""
      End If
    End If
  End If
  
  'Удаляем Информационно-удостоверяющий лист
  If ThisApplication.ObjectDefs.Has("OBJECT_SIGN_CARD") Then
    count = 0
    For Each Obj in ThisApplication.ObjectDefs("OBJECT_SIGN_CARD").Objects
      Obj.Erase
      count = count + 1
    Next
    If count <> 0 Then
      str0 = str0 & chr(10) & chr(9) & "Удалено объектов типа ""Информационно-удостоверяющий лист"" - " & count
    End If
    If ThisApplication.ObjectDefs("OBJECT_SIGN_CARD").Objects.Count = 0 Then
      ThisApplication.ObjectDefs("OBJECT_SIGN_CARD").Erase
      str0 = str0 & chr(10) & chr(9) & "Удален тип объектов ""Информационно-удостоверяющий лист"""
    End If
  End If
  
  'Удаляем Объект строительства
  If ThisApplication.ObjectDefs.Has("OBJECT_COMPLEX") Then
    count = 0
    For Each Obj in ThisApplication.ObjectDefs("OBJECT_COMPLEX").Objects
      If Obj.Content.Count <> 0 Then
        Obj.Content.RemoveAll
      End If
      Obj.Erase
      count = count + 1
    Next
    If count <> 0 Then
      str0 = str0 & chr(10) & chr(9) & "Удалено объектов типа ""Объект строительства"" - " & count
    End If
    If ThisApplication.ObjectDefs("OBJECT_COMPLEX").Objects.Count = 0 Then
      ThisApplication.ObjectDefs("OBJECT_COMPLEX").Erase
      str0 = str0 & chr(10) & chr(9) & "Удален тип объектов ""Объект строительства"""
    End If
  End If
  If ThisApplication.InputForms.Has("FORM_COMPLEX") Then
    ThisApplication.InputForms("FORM_COMPLEX").Erase
    str0 = str0 & chr(10) & chr(9) & "Удалена форма ввода ""Объект строительства"""
  End If
  
  'Удаляем Объекты строительства
  If ThisApplication.ObjectDefs.Has("OBJECT_COMPLEX_DIR") Then
    count = 0
    For Each Obj in ThisApplication.ObjectDefs("OBJECT_COMPLEX_DIR").Objects
      If not Obj is Nothing Then
        Obj.Erase
        count = count + 1
      End If
    Next
    If count <> 0 Then
      str0 = str0 & chr(10) & chr(9) & "Удалено объектов типа ""Объекты строительства"" - " & count
    End If
    If ThisApplication.ObjectDefs("OBJECT_COMPLEX_DIR").Objects.Count = 0 Then
      ThisApplication.ObjectDefs("OBJECT_COMPLEX_DIR").Erase
      str0 = str0 & chr(10) & chr(9) & "Удален тип объектов ""Объекты строительства"""
    End If
  End If
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Task33()
  str = "Задание 033:"
  str0 = ""
  Progress.Text = "Выполняется задание 033"
  Set Root = ThisApplication.Root
  Set ObjDef = ThisApplication.ObjectDefs("OBJECT_CONTRACTS")
  If ObjDef.Objects.Count = 0 Then
    Set NewObj = Root.Objects.Create(ObjDef)
    str0 = str0 & chr(10) & chr(9) & "В корневом каталоге создан объект типа ""Договоры"""
  End If
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Task34()
  str = "Задание 034:"
  str0 = ""
  Progress.Text = "Выполняется задание 034"
  
  'Обновляем атрибуты объекта типа "Договор"
  StrAdd = "ATTR_CONTRACTOR,ATTR_CONTACT_PERSON,ATTR_STARTDATE_PLAN,ATTR_ENDDATE_PLAN," &_
  "ATTR_DURATION_PLAN,ATTR_ENDDATE_FACT,ATTR_AUTOR,ATTR_CURATOR,ATTR_CONTRACT_CLOSE_TYPE," &_
  "ATTR_CONTRACT_VALUE,ATTR_CONTRACT_TEVENT_TYPE,ATTR_CONTRACT_EVENT_TYPE,ATTR_DATA_CHANGE," &_
  "ATTR_CONTACT_PERSON,ATTR_CONTRACT_MAIN,ATTR_TENDER_MAIN"
  StrDel = ""
  Call ObjDefAttrAddAll("OBJECT_CONTRACT",StrAdd,StrDel,str0)
  
  'Обновляем атрибуты объекта типа "Дополнительное соглашение"
  StrAdd = "ATTR_CONTRACTOR,ATTR_CONTACT_PERSON,ATTR_STARTDATE_PLAN,ATTR_ENDDATE_PLAN," &_
  "ATTR_DURATION_PLAN,ATTR_ENDDATE_FACT,ATTR_AUTOR,ATTR_CURATOR,ATTR_CONTRACT_CLOSE_TYPE," &_
  "ATTR_CONTRACT_VALUE,ATTR_CONTRACT_TEVENT_TYPE,ATTR_CONTRACT_EVENT_TYPE,ATTR_DATA_CHANGE," &_
  "ATTR_CONTACT_PERSON,ATTR_CONTRACT_MAIN,ATTR_TENDER_MAIN"
  StrDel = ""
  Call ObjDefAttrAddAll("OBJECT_CONTRACT_ADD",StrAdd,StrDel,str0)
  
  'Обновляем атрибуты объекта типа "Этап"
  StrAdd = "ATTR_STARTDATE_PLAN,ATTR_ENDDATE_PLAN,ATTR_DURATION_PLAN,ATTR_STARTDATE_FACT,ATTR_ENDDATE_FACT," &_
  "ATTR_DURATION_FACT,ATTR_ENDDATE_ESTIMATED,ATTR_HISTORY_CHANGE_OF_TIMING"
  StrDel = ""
  Call ObjDefAttrAddAll("OBJECT_CONTRACT_STAGE",StrAdd,StrDel,str0)
  
  'Обновляем атрибуты объекта типа "Акт"
  StrAdd = "ATTR_NUMBER,ATTR_PRICE_W_VAT,ATTR_PRICE,ATTR_VAT"
  StrDel = ""
  Call ObjDefAttrAddAll("OBJECT_CONTRACT_COMPL_REPORT",StrAdd,StrDel,str0)
  
  'Обновляем атрибуты объекта типа "Соглашение"
  StrAdd = "ATTR_NUMBER"
  StrDel = ""
  Call ObjDefAttrAddAll("OBJECT_AGREEMENT",StrAdd,StrDel,str0)

  'Журнал выполнения
  Call Notify(str,str0)
End Sub

Sub Task28()
  str = "Задание 028:"
  str0 = ""
  Progress.Text = "Выполняется задание 028"
  FilePath = "F:\Import.xlsx"
  Set Cls = ThisApplication.Classifiers.Find("NODE_D285A2A4_EFA1_4EAE_BBEF_400FF4AC6BDF")
  If Cls is Nothing Then
    Str0 = Str0 & chr(10) & chr(9) & "Классификатор не найден!"
    Exit Sub
  End If
  
  For Each C in Cls.Classifiers
    Cls.Classifiers.Remove C
  Next
  Cls.Classifiers.Update
  
  Set ExcelApp = CreateObject("Excel.Application")
  ExcelApp.WorkBooks.Open FilePath
  For i = 1 to 500
    Value1 = ExcelApp.ActiveSheet.Cells(i,1).Value
    Value2 = ExcelApp.ActiveSheet.Cells(i,2).Value
    Value3 = ExcelApp.ActiveSheet.Cells(i,3).Value
    Value4 = ExcelApp.ActiveSheet.Cells(i,4).Value
    If Value3 <> "" Then
      If InStr(Value1,".") = 0 Then
      Set NewCls = Cls.Classifiers.Create
        NewCls.Description = Value3
        If Value2 <> "" Then NewCls.Code = Value2
        If Value4 <> "" Then NewCls.SysName = Value4
        Str0 = Str0 & chr(10) & chr(9) & "Создан классификатор """ & Value1 & " - " & Value3 & """"
      Else
        Set NewCls0 = NewCls.Classifiers.Create
        NewCls0.Description = Value3
        If Value2 <> "" Then NewCls0.Code = Value2
        If Value4 <> "" Then NewCls0.SysName = Value4
        Str0 = Str0 & chr(10) & chr(9) & "Создан классификатор """ & Value1 & " - " & Value3 & """"
      End If
    Else
      Exit For
    End If
  Next
  
  ExcelApp.Quit
  Set ExcelApp = Nothing
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

Sub Task36()
  str = "Задание 036:"
  str0 = ""
  Progress.Text = "Выполняется задание 036"
  
  'Статусы для объекта типа Договор
  Call StatusSet(str0,"OBJECT_CONTRACT","STATUS_CONTRACT_IN_WORK")
  'Статусы для объекта типа Доп. соглашение
  Call StatusSet(str0,"OBJECT_CONTRACT_ADD","STATUS_CONTRACT_IN_WORK")
  'Статусы для объекта типа Этап
  Call StatusSet(str0,"OBJECT_CONTRACT_STAGE","STATUS_CONTRACT_STAGE_DRAFT")
  'Статусы для объекта типа Акт
  Call StatusSet(str0,"OBJECT_CONTRACT_COMPL_REPORT","STATUS_COCOREPORT_DRAFT")
  'Статусы для объекта типа Соглашение
  Call StatusSet(str0,"OBJECT_AGREEMENT","STATUS_AGREEMENT_DRAFT")
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Task41()
  str = "Задание 041:"
  str0 = ""
  Progress.Text = "Выполняется задание 041"
  
  Count = 0
  Set Query = ThisApplication.Queries("QUERY_INVOICE_IN_PROJECT")
  For Each Project in ThisApplication.ObjectDefs("OBJECT_PROJECT").Objects
    If Project.Queries.Has("Накладные") = False Then
      Project.Queries.AddCopy Query
      Count = Count + 1
    End If
  Next
  If Count > 0 Then
    Str0 = Str0 & chr(10) & chr(9) & "Создано " & Count & " выборок в объектах типа ""Проект"""
  End If
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Task38()
  str = "Задание 038:"
  str0 = ""
  Progress.Text = "Выполняется задание 038"
  
  Count = 0
  Set Query = ThisApplication.Queries("QUERY_CONTRACT_STAGES")
  For Each Obj in ThisApplication.ObjectDefs("OBJECT_CONTRACT").Objects
    If Obj.Queries.Has("Этапы") = True Then
      For Each Quer in Obj.Queries
        If Quer.Description = "Этапы" Then
          Obj.Queries.Remove Obj.Queries.Item("Этапы")
        End If
      Next
    End If
    Obj.Queries.AddCopy Query
    Count = Count + 1
  Next
  If Count > 0 Then
    Str0 = Str0 & chr(10) & chr(9) & "Создано " & Count & " выборок в объектах типа ""Договор"""
  End If
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4031()
  str = "Кейс 4031:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4031"
  
  CountAdd = 0
  CountSet = 0
  
  'Добавление атрибутов
  For Each Obj in ThisApplication.ObjectDefs("OBJECT_PROJECT").Objects
    If Obj.Attributes.Has("ATTR_PROJECT_ORDINAL_NUM") = False Then
      Call ObjDefAttrAddAll("OBJECT_PROJECT","ATTR_PROJECT_ORDINAL_NUM","",str0)
      CountAdd = CountAdd + 1
    Else
      Obj.Attributes("ATTR_PROJECT_ORDINAL_NUM").Value = ""
    End If
    Obj.Update
  Next
  'Назначение кода проекта
  For Each Obj in ThisApplication.ObjectDefs("OBJECT_PROJECT").Objects
    Code = ThisApplication.ExecuteScript("OBJECT_PROJECT", "ProjectCodeGet", Obj, Obj.CreateTime)
    If Code <> "" Then
      If Obj.Attributes("ATTR_PROJECT_CODE").Value <> Code Then
        On Error Resume Next
        Obj.Attributes("ATTR_PROJECT_CODE").Value = Code
        On Error GoTo 0
        If Obj.Attributes("ATTR_PROJECT_CODE").Value = Code Then
          Obj.Update
          CountSet = CountSet + 1
        End If
      End If
    End If
  Next
  If CountAdd > 0 Then
    Str0 = Str0 & chr(10) & chr(9) & "Добавлено " & CountAdd & " атрибутов к объектам типа ""Проект"""
  End If
  If CountSet > 0 Then
    Str0 = Str0 & chr(10) & chr(9) & "Изменено " & CountSet & " кодов проекта у объектов типа ""Проект"""
  End If
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4111()
  str = "Кейс 4111:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4111"
  
  CountAdd = 0
  CountSet = 0
  
  'Добавление атрибутов
  For Each Obj in ThisApplication.ObjectDefs("OBJECT_T_TASK").Objects
    If Obj.Attributes.Has("ATTR_RESPONSIBLE") = False Then
      Call ObjDefAttrAddAll("OBJECT_T_TASK","ATTR_RESPONSIBLE","",str0)
      CountAdd = CountAdd + 1
    End If
    Obj.Update
  Next
  If CountAdd > 0 Then
    Str0 = Str0 & chr(10) & chr(9) & "Добавлено " & CountAdd & " атрибутов к объектам типа ""Задание"""
  End If
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4157()
  str = "Кейс 4157:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4157"
  
  CountAdd0 = 0
  CountAdd1 = 0
  CountAdd2 = 0
  CountAdd3 = 0
  AttrName = "ATTR_TSESSION"
  
  'Добавление атрибутов к ИО Задание
  For Each Obj in ThisApplication.ObjectDefs("OBJECT_T_TASK").Objects
    If Obj.Attributes.Has(AttrName) = False Then
      Call ObjDefAttrAddAll("OBJECT_T_TASK",AttrName,"",str0)
      CountAdd0 = CountAdd0 + 1
    End If
    Obj.Update
  Next
  If CountAdd0 > 0 Then
    Str0 = Str0 & chr(10) & chr(9) & "Добавлено " & CountAdd0 & " атрибутов к объектам типа ""Задание"""
  End If
  
  'Добавление атрибутов к ИО Документ
  For Each Obj in ThisApplication.ObjectDefs("OBJECT_DOCUMENT").Objects
    If Obj.Attributes.Has(AttrName) = False Then
      Call ObjDefAttrAddAll("OBJECT_DOCUMENT",AttrName,"",str0)
      CountAdd1 = CountAdd1 + 1
    End If
    Obj.Update
  Next
  If CountAdd1 > 0 Then
    Str0 = Str0 & chr(10) & chr(9) & "Добавлено " & CountAdd1 & " атрибутов к объектам типа ""Документ"""
  End If
  
  'Добавление атрибутов к ИО Чертеж
  For Each Obj in ThisApplication.ObjectDefs("OBJECT_DRAWING").Objects
    If Obj.Attributes.Has(AttrName) = False Then
      Call ObjDefAttrAddAll("OBJECT_DRAWING",AttrName,"",str0)
      CountAdd2 = CountAdd2 + 1
    End If
    Obj.Update
  Next
  If CountAdd2 > 0 Then
    Str0 = Str0 & chr(10) & chr(9) & "Добавлено " & CountAdd2 & " атрибутов к объектам типа ""Чертеж"""
  End If
  
  'Добавление атрибутов к ИО Проектный документ
  For Each Obj in ThisApplication.ObjectDefs("OBJECT_DOC_DEV").Objects
    If Obj.Attributes.Has(AttrName) = False Then
      Call ObjDefAttrAddAll("OBJECT_DOC_DEV",AttrName,"",str0)
      CountAdd3 = CountAdd3 + 1
    End If
    Obj.Update
  Next
  If CountAdd3 > 0 Then
    Str0 = Str0 & chr(10) & chr(9) & "Добавлено " & CountAdd3 & " атрибутов к объектам типа ""Проектный документ"""
  End If
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4158()
  str = "Кейс 4158:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4158"
  
  CountSet = 0
  
  'Определяем текущий год
  YearStr = CStr(Year(Date))
  Stol = Mid(YearStr, 2, 1)
  If Stol = 0 Then
    YearStr = Right(YearStr,2)
  Else
    YearStr = Right(YearStr,3)
  End If
  
  'Изменение атрибутов
  For Each Obj in ThisApplication.ObjectDefs("OBJECT_PROJECT").Objects
    Num = Obj.Attributes("ATTR_PROJECT_ORDINAL_NUM").Value
    NumStr = CStr(Num)
    If Len(NumStr) < 2 Then
      NumStr = "00" & NumStr
    ElseIf Len(NumStr) < 3 Then
      NumStr = "0" & NumStr
    End If
    Code = NumStr & "." & YearStr
    If Obj.Attributes("ATTR_PROJECT_CODE") <> Code Then
      Obj.Attributes("ATTR_PROJECT_CODE") = Code
      Obj.Update
      CountSet = CountSet + 1
    End If
  Next
  If CountSet > 0 Then
    Str0 = Str0 & chr(10) & chr(9) & "Изменено " & CountSet & " атрибутов у объектов типа ""Проект"""
  End If
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4215()
  str = "Кейс 4215:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4215"
  
  CountAdd = 0
  CountDel = 0
  
  'Добавление атрибутов
  ObjDefName = "OBJECT_INVOICE"
  For Each Obj in ThisApplication.ObjectDefs(ObjDefName).Objects
    If Obj.Attributes.Has("ATTR_DATA") = False Then
      Call ObjDefAttrAddAll(ObjDefName,"ATTR_DATA","",str0)
      CountAdd = CountAdd + 1
    End If
    If Obj.Attributes.Has("ATTR_REG_NUMBER") = False Then
      Call ObjDefAttrAddAll(ObjDefName,"ATTR_REG_NUMBER","",str0)
      CountAdd = CountAdd + 1
    End If
    If Obj.Attributes.Has("ATTR_REGISTERED") = False Then
      Call ObjDefAttrAddAll(ObjDefName,"ATTR_REGISTERED","",str0)
      CountAdd = CountAdd + 1
    End If
    If Obj.Attributes.Has("ATTR_REG") = False Then
      Call ObjDefAttrAddAll(ObjDefName,"ATTR_REG","",str0)
      CountAdd = CountAdd + 1
    End If
    Call ObjDefAttrAddAll(ObjDefName,"","ATTR_INVOICE_NUMBER,ATTR_INVOICE_DATE",str0)
    Obj.Update
  Next
  If CountAdd > 0 Then
    Str0 = Str0 & chr(10) & chr(9) & "Добавлено " & CountAdd & " атрибутов к объектам типа ""Накладная"""
  End If
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4219()
  str = "Кейс 4219:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4219"
  
  CountDel = 0
  
  'Добавление атрибутов
  StrAdd = "ATTR_SUBCONTRACTOR_CLS,ATTR_SUBCONTRACTOR_DOC_CODE,ATTR_SUBCONTRACTOR_DOC_INF,"&_
  "ATTR_SUBCONTRACTOR_DOC_NAME,ATTR_SUBCONTRACTOR_WORK"
  Call ObjDefAttrAddAll("OBJECT_VOLUME",StrAdd,"",str0)
  Call ObjDefAttrAddAll("OBJECT_SURV",StrAdd,"",str0)
  Call ObjDefAttrAddAll("OBJECT_WORK_DOCS_SET",StrAdd,"",str0)
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4220()
  str = "Кейс 4220:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4220"
  
  CountDel = 0
  CountErr = 0
  
  'Удаляем объкты
  'Дополнительное соглашение
  If ThisApplication.ObjectDefs.Has("OBJECT_CONTRACT_ADD") Then
    For Each Obj in ThisApplication.ObjectDefs("OBJECT_CONTRACT_ADD").Objects
      Call ThisApplication.ExecuteScript("CMD_S_DLL", "RemoveObjQuery", Obj)
      Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", Obj)
      For Each Child in Obj.ContentAll
        Call ThisApplication.ExecuteScript("CMD_S_DLL", "RemoveObjQuery", Child)
        Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", Child)
        on Error Resume Next
        Descr = Child.Description
        Child.Erase
        If Err.Number = 0 Then
          str0 = str0 & chr(10) & chr(9) & "Объект """ & Descr & """ удален из системы!"
          CountDel = CountDel + 1
        Else
          CountErr = CountErr + 1
        End If
        On Error GoTo 0
      Next
      
      on Error Resume Next
      Descr = Obj.Description
      Obj.Erase
      If Err.Number = 0 Then
        str0 = str0 & chr(10) & chr(9) & "Объект """ & Descr & """ удален из системы!"
        CountDel = CountDel + 1
      Else
        CountErr = CountErr + 1
      End If
      On Error GoTo 0
    Next
  End If
  
  'Том Субподрядчика
  If ThisApplication.ObjectDefs.Has("OBJECT_VOLUME_SUBCONTRACTOR") Then
    For Each Obj in ThisApplication.ObjectDefs("OBJECT_VOLUME_SUBCONTRACTOR").Objects
      Call ThisApplication.ExecuteScript("CMD_S_DLL", "RemoveObjQuery", Obj)
      Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", Obj)
      For Each Child in Obj.ContentAll
        Call ThisApplication.ExecuteScript("CMD_S_DLL", "RemoveObjQuery", Child)
        Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", Child)
        on Error Resume Next
        Descr = Child.Description
        Child.Erase
        If Err.Number = 0 Then
          str0 = str0 & chr(10) & chr(9) & "Объект """ & Descr & """ удален из системы!"
          CountDel = CountDel + 1
        Else
          CountErr = CountErr + 1
        End If
        On Error GoTo 0
      Next
      
      on Error Resume Next
      Descr = Obj.Description
      Obj.Erase
      If Err.Number = 0 Then
        str0 = str0 & chr(10) & chr(9) & "Объект """ & Descr & """ удален из системы!"
        CountDel = CountDel + 1
      Else
        CountErr = CountErr + 1
      End If
      On Error GoTo 0
    Next
  End If
  
  'Основной комплект Субподрядчика
  If ThisApplication.ObjectDefs.Has("OBJECT_WORK_DOCS_SET_SUBCONTRACTOR") Then
    For Each Obj in ThisApplication.ObjectDefs("OBJECT_WORK_DOCS_SET_SUBCONTRACTOR").Objects
      Call ThisApplication.ExecuteScript("CMD_S_DLL", "RemoveObjQuery", Obj)
      Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", Obj)
      For Each Child in Obj.ContentAll
        Call ThisApplication.ExecuteScript("CMD_S_DLL", "RemoveObjQuery", Child)
        Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", Child)
        on Error Resume Next
        Descr = Child.Description
        Child.Erase
        If Err.Number = 0 Then
          str0 = str0 & chr(10) & chr(9) & "Объект """ & Descr & """ удален из системы!"
          CountDel = CountDel + 1
        Else
          CountErr = CountErr + 1
        End If
        On Error GoTo 0
      Next
      
      on Error Resume Next
      Descr = Obj.Description
      Obj.Erase
      If Err.Number = 0 Then
        str0 = str0 & chr(10) & chr(9) & "Объект """ & Descr & """ удален из системы!"
        CountDel = CountDel + 1
      Else
        CountErr = CountErr + 1
      End If
      On Error GoTo 0
    Next
  End If
  
  'Удаляем типы объектов
  SysName = "OBJECT_CONTRACT_ADD"
  If ThisApplication.ObjectDefs.Has(SysName) Then
    Set ObjDef = ThisApplication.ObjectDefs(SysName)
    Descr = ObjDef.Description
    If ObjDef.Objects.Count = 0 Then
      ObjDef.Erase
      str0 = str0 & chr(10) & chr(9) & "Удален тип объекта """ & Descr & """"
    End If
  End If
  SysName = "OBJECT_VOLUME_SUBCONTRACTOR"
  If ThisApplication.ObjectDefs.Has(SysName) Then
    Set ObjDef = ThisApplication.ObjectDefs(SysName)
    Descr = ObjDef.Description
    If ObjDef.Objects.Count = 0 Then
      ObjDef.Erase
      str0 = str0 & chr(10) & chr(9) & "Удален тип объекта """ & Descr & """"
    End If
  End If
  SysName = "OBJECT_WORK_DOCS_SET_SUBCONTRACTOR"
  If ThisApplication.ObjectDefs.Has(SysName) Then
    Set ObjDef = ThisApplication.ObjectDefs(SysName)
    Descr = ObjDef.Description
    If ObjDef.Objects.Count = 0 Then
      ObjDef.Erase
      str0 = str0 & chr(10) & chr(9) & "Удален тип объекта """ & Descr & """"
    End If
  End If
  
  If Str0 <> "" Then
    str0 = str0 & chr(10) & chr(9) & "Удалено объектов = " & CountDel
    str0 = str0 & chr(10) & chr(9) & "Ошибок удаления = " & CountErr
  End If
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4236()
  str = "Кейс 4236:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4236"

  Count = 0
  CountAdd = 0
  CountDel = 0
  
  'Обновление атрибутов
  Attr0name = "ATTR_CONTRACT_VALUE"
  Attr1name = "ATTR_CONTRACT_VALUE_REST"
  Attr2name = "ATTR_CONTRACT_PENALTY_SUMM_PER_DAY"
  Attr3name = "ATTR_CONTRACT_PENALTY_PERCENT_PER_DAY"
  
  For Each Obj in ThisApplication.ObjectDefs("OBJECT_CONTRACT").Objects
    Set ObjAttr = Obj.Attributes
    'Считываем значения
    Attr0 = GetAttrValue4236(ObjAttr,Attr0Name)
    Attr1 = GetAttrValue4236(ObjAttr,Attr1Name)
    Attr2 = GetAttrValue4236(ObjAttr,Attr2Name)
    Attr3 = GetAttrValue4236(ObjAttr,Attr3Name)
    
    'Удаляем атрибуты
    Call ObjAttrDel(ObjAttr,Attr0name,CountDel)
    Call ObjAttrDel(ObjAttr,Attr1name,CountDel)
    Call ObjAttrDel(ObjAttr,Attr2name,CountDel)
    Call ObjAttrDel(ObjAttr,Attr3name,CountDel)
    
    'Добавляем атрибуты
    Call ObjAttrAdd(ObjAttr,Attr0name,CountAdd)
    Call ObjAttrAdd(ObjAttr,Attr1name,CountAdd)
    Call ObjAttrAdd(ObjAttr,Attr2name,CountAdd)
    Call ObjAttrAdd(ObjAttr,Attr3name,CountAdd)
    
    'Записываем значения
    If ObjAttr.Has(Attr0name) Then
      If ObjAttr(Attr0name).Value <> Attr0 Then
        ObjAttr(Attr0name).Value = Attr0
        Count = Count + 1
      End If
    End If
    If ObjAttr.Has(Attr1name) Then
      If ObjAttr(Attr1name).Value <> Attr1 Then
        ObjAttr(Attr1name).Value = Attr1
        Count = Count + 1
      End If
    End If
    If ObjAttr.Has(Attr2name) Then
      If ObjAttr(Attr2name).Value <> Attr2 Then
        ObjAttr(Attr2name).Value = Attr2
        Count = Count + 1
      End If
    End If
    If ObjAttr.Has(Attr3name) Then
      If ObjAttr(Attr3name).Value <> Attr3 Then
        ObjAttr(Attr3name).Value = Attr3
        Count = Count + 1
      End If
    End If
  Next
  
  If Count <> 0 Then
    str0 = chr(10) & "Обновлено " & Count & " атрибутов у объектов типа ""Договор"""
  End If
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4241()
  str = "Кейс 4241:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4241"
  
  CountDel = 0
  
  'Добавление атрибутов
  StrAdd = "ATTR_KD_COREDENT_TYPE"
  Call ObjDefAttrAddAll("OBJECT_CORRESPONDENT",StrAdd,"",str0)
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4249()
  str = "Кейс 4249:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4249"
  
  CountAdd = 0
  CountStatus = 0
  
  'Изменение статуса
  For Each Obj in ThisApplication.ObjectDefs("OBJECT_CONTRACT").Objects
    If Obj.StatusName = "STATUS_CONTRACT_IN_WORK" or Obj.Status is Nothing Then
      Obj.Status = ThisApplication.Statuses("STATUS_CONTRACT_DRAFT")
      Count = Count + 1
    End If
  Next
  If Count <> 0 Then
    str0 = chr(10) & "Обновлены статусы у " & Count & " объектов типа ""Договор"""
  End If
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4251()
  str = "Кейс 4251:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4251"
  
  CountAdd = 0
  
  'Добавление атрибутов
  StrAdd = "ATTR_DUE_DATE,ATTR_DAY_TYPE,ATTR_KD_COREDENT_TYPE,ATTR_OKVED2,ATTR_SMSP_EXCLUDE_CODE"
  Call ObjDefAttrAddAll("OBJECT_CONTRACT",StrAdd,"",str0)
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4249()
  str = "Кейс 4249:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4249"
  
  CountAdd = 0
  
  'Добавление атрибутов
  StrAdd = "ATTR_CONTRACT_CLASS"
  Call ObjDefAttrAddAll("OBJECT_CONTRACT",StrAdd,"",str0)
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4262()
  str = "Кейс 4262:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4262"
  
  CountAdd = 0
  
  'Добавление атрибутов
  StrAdd = "ATTR_FILES_ARCHIVE_TABLE"
  Call ObjDefAttrAddAll("OBJECT_WORK_DOCS_SET",StrAdd,"",str0)
  Call ObjDefAttrAddAll("OBJECT_VOLUME",StrAdd,"",str0)
  StrAdd = "FORM_FILES_ARCHIVE"
  Call ObjDefFormAdd("OBJECT_WORK_DOCS_SET",StrAdd,"",str0)
  Call ObjDefFormAdd("OBJECT_VOLUME",StrAdd,"",str0)
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4287()
  str = "Кейс 4287:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4287"
  
  CountAdd = 0
  
  'Добавление атрибутов
  StrAdd = "ATTR_CONTRACT_STAGE_CLOSE_TYPE,ATTR_DATA"
  Call ObjDefAttrAddAll("OBJECT_CONTRACT_STAGE",StrAdd,"",str0)
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4293()
  str = "Кейс 4293:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4293"
  
  CountAdd = 0
  
  'Добавление атрибутов
  StrAdd = "ATTR_IS_SIGNET_BY_CORRESPONDENT"
  Call ObjDefAttrAddAll("OBJECT_CONTRACT_COMPL_REPORT",StrAdd,"",str0)
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4300()
  str = "Кейс 4300:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4300"
  
  CountAdd = 0
  
  'Добавление атрибутов
  StrAdd = "ATTR_CCR_INCOMING"
  Call ObjDefAttrAddAll("OBJECT_CONTRACT_COMPL_REPORT",StrAdd,"",str0)
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4325()
  str = "Кейс 4325:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4325"
  
  CountAdd = 0
  
  'Удаление атрибутов
  StrDel = "ATTR_P_TASK_PROJECT_CODE"
  Call ObjDefAttrAddAll("OBJECT_P_TASK","",StrDel,str0)
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4330()
  str = "Кейс 4330:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4330"
  
  CountAdd = 0
  
  'Удаление атрибутов
  StrDel = "ATTR_ENDORSER"
  Call ObjDefAttrAddAll("OBJECT_CONTRACT_COMPL_REPORT","",StrDel,str0)
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4332()
  str = "Кейс 4332:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4332"
  
  Count = 0
  
  'Обновление таблицы Связанные части проекта
  If ThisApplication.ObjectDefs.Has("OBJECT_T_TASK") Then
    For Each Task in ThisApplication.ObjectDefs("OBJECT_T_TASK").Objects
      If Task.Attributes.Has("ATTR_T_TASK_PPLINKED") Then
        For Each Row in Task.Attributes("ATTR_T_TASK_PPLINKED").Rows
          If Row.Attributes.Has("ATTR_OBJECT_TYPE") Then
            If Row.Attributes("ATTR_OBJECT_TYPE").Empty = True and _
            Row.Attributes("ATTR_T_LINKEDOBJECT").Empty = False Then
              If not Row.Attributes("ATTR_T_LINKEDOBJECT").Object is Nothing Then
                Row.Attributes("ATTR_OBJECT_TYPE").Value = Row.Attributes("ATTR_T_LINKEDOBJECT").Object.ObjectDef.Description
                Count = Count + 1
              End If
            End If
          End If
        Next
      End If
    Next
  End If
  If Count <> 0 Then
    str0 = chr(10) & "Обновлено " & Count & " строк."
  End If
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4337()
  str = "Кейс 4337:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4337"
  
  CountAdd = 0
  CountDel = 0
  
  'Обновление атрибутов
  StrAdd = "ATTR_PRICE,ATTR_PRICE_W_VAT,ATTR_VAT"
  StrDel = StrAdd
  Call ObjDefAttrAddAll("OBJECT_CONTRACT_COMPL_REPORT",StrAdd,StrDel,str0)
  Call ObjDefAttrAddAll("OBJECT_CONTRACT_STAGE",StrAdd,StrDel,str0)
  StrAdd = "ATTR_TENDER_ITEM_PRICE_MAX_VALUE"
  StrDel = StrAdd
  Call ObjDefAttrAddAll("OBJECT_TENDER_INSIDE",StrAdd,StrDel,str0)
  Call ObjDefAttrAddAll("OBJECT_PURCHASE_DOC",StrAdd,StrDel,str0)
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4338()
  str = "Кейс 4338:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4338"
  
  CountAdd = 0
  CountDel = 0
  
  'Добавление атрибутов
  StrAdd = "ATTR_PURCHASE_FROM_EI"
  StrDel = "ATTR_CONTRACT_WORK_TYPE"
  Call ObjDefAttrAddAll("OBJECT_CONTRACT",StrAdd,StrDel,str0)
  
  'Добавление атрибутов
  StrAdd = "ATTR_CONTRACT_WORK_TYPE"
  Call ObjDefAttrAddAll("OBJECT_CONTRACT_STAGE",StrAdd,"",str0)
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4339()
  str = "Кейс 4339:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4339"
  
  CountAdd = 0
  
  'Добавление атрибутов
  StrAdd = "ATTR_SECTION_NUM,ATTR_SECTION_CODE"
  StrDel = "ATTR_S_PSECTION_NUM"
  Call ObjDefAttrAddAll("OBJECT_PROJECT_SECTION",StrAdd,StrDel,str0)
  Call ObjDefAttrAddAll("OBJECT_PROJECT_SECTION_SUBSECTION",StrAdd,StrDel,str0)
  On Error Resume Next
  If ThisApplication.AttributeDefs.Has(StrDel) Then
    ThisApplication.AttributeDefs.Remove ThisApplication.AttributeDefs(StrDel)
  End If
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4342()
  str = "Кейс 4342:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4342"
  
  Count = 0
  
  'Обновление описания разделов
  If ThisApplication.ObjectDefs.Has("OBJECT_PROJECT_SECTION") Then
    For Each Obj0 in ThisApplication.ObjectDefs("OBJECT_PROJECT_SECTION").Objects
      Obj0.Update
      Count = Count + 1
    Next
  End If
  If Count <> 0 Then
    str0 = chr(10) & "Обновлено " & Count & " описаний объектов типа ""Раздел""."
  End If
  
  Count = 0
  'Обновление описания подразделов
  If ThisApplication.ObjectDefs.Has("OBJECT_PROJECT_SECTION_SUBSECTION") Then
    For Each Obj0 in ThisApplication.ObjectDefs("OBJECT_PROJECT_SECTION_SUBSECTION").Objects
      Obj0.Update
      Count = Count + 1
    Next
  End If
  If Count <> 0 Then
    str0 = str0 & chr(10) & "Обновлено " & Count & " описаний объектов типа ""Подраздел""."
  End If
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4345()
  str = "Кейс 4345:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4345"
  
  Count = 0
  
  'Обновление описания проектов
  If ThisApplication.ObjectDefs.Has("OBJECT_PROJECT") Then
    For Each Project in ThisApplication.ObjectDefs("OBJECT_PROJECT").Objects
      Project.Update
      Count = Count + 1
    Next
  End If
  If Count <> 0 Then
    str0 = chr(10) & "Обновлено " & Count & " описаний проектов."
  End If
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4353()
  str = "Кейс 4353:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4353"
  
  CountAdd = 0
  CountDel = 0
  
  'Удаление атрибутов
  StrDel = "ATTR_S_DEPARTMENT"
  Call ObjDefAttrAddAll("OBJECT_P_TASK","",StrDel,str0)
  Call SystemObjDel(str0,"ATTR_SIGN_CARD")
  Call SystemObjDel(str0,"FORM_CONTRACT_ADD")
  Call SystemObjDel(str0,"FORM_CONTRACT_ADD_LINKS")
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4307()
  str = "Кейс 4307:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4307"
  
  CountAdd = 0
  CountDel = 0
  
  'Добавление атрибутов
  StrAdd = "ATTR_TENDER_BUDGET_ITEM_CODE"
  Call ObjDefAttrAddAll("OBJECT_TENDER_INSIDE",StrAdd,"",str0)
  
  'Удаление атрибутов
  StrDel = StrAdd
  Call ObjDefAttrAddAll("OBJECT_PURCHASE_LOT","",StrDel,str0)
  
  'Системные атрибуты
  Arr = Split("ATTR_TENDER_ALARM1,ATTR_TENDER_ALARM2,ATTR_TENDER_ALARM3,ATTR_TENDER_ALARM4",",")
  For i = 0 to Ubound(Arr)
    AttrName = Arr(i)
    If ThisApplication.AttributeDefs.Has(AttrName) Then
      If ThisApplication.Attributes.Has(AttrName) = False Then
        Set Attr = ThisApplication.Attributes.Create(ThisApplication.AttributeDefs(AttrName))
        str0 = str0 & chr(10) & "Добавлен системный атрибут """ &_
          ThisApplication.AttributeDefs(AttrName).Description & """"
        If i = 0 Then Attr.Value = 14
        If i = 1 Then Attr.Value = 20
        If i = 2 Then Attr.Value = 15
        If i = 3 Then Attr.Value = 10
      End If
    End If
  Next
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4356()
  str = "Кейс 4356:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4356"
  
  'Смена ссылки на классификатор у атрибутов
  SysName0 = "NODE_PURCHASE_BASIS"
  SysName1 = "NODE_4D0FDBD7_DA18_4835_B266_991DC779A44C"
  Set Clf1 = ThisApplication.Classifiers.FindBySysId(SysName1)
  If not Clf1 is Nothing Then
    Descr = Clf1.Description
    For Each AttrDef in ThisApplication.AttributeDefs
      If not AttrDef.Classifier is Nothing Then
        If AttrDef.Classifier.SysName = SysName0 Then
          AttrDef.Classifier = Clf1
          str0 = str0 & chr(10) & "У типа атрибута """ & AttrDef.Description & """ изменена ссылка на классификатор """ & Descr & """"
        End If
      End If
    Next
  End If
  
  'Удаление классификаторов
  Call SystemObjDel(str0,"NODE_6433F12A_1170_4BCF_B758_C6D3D6BAAD4D")
  Set Clf0 = ThisApplication.Classifiers.FindBySysId(SysName0)
  If not Clf0 is Nothing Then
    Check = True
    For Each Clf in Clf0.Classifiers
      If Len(Clf.Code) > 3 Then
        Check = False
        Exit For
      End If
    Next
    If Check = True Then
      Call SystemObjDel(str0,"NODE_PURCHASE_BASIS")
    End If
  End If
  
  'Смена системного имени классификатора
  Set Clf1 = ThisApplication.Classifiers.FindBySysId(SysName1)
  If ThisApplication.Classifiers.FindBySysId(SysName0) is Nothing and not Clf1 is Nothing Then
    Clf1.SysName = SysName0
    str0 = str0 & chr(10) & "Изменено системное имя классификатора """ & Clf1.Description & """ на """ &_
      SysName0 & """"
  End If
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4313()
  str = "Кейс 4313:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4313"
  
  CountAdd = 0
  
  'Обновление атрибутов
  StrAdd = "ATTR_S_DEPARTMENT"
  StrDel = StrAdd
  Call ObjDefAttrAddAll("OBJECT_P_TASK",StrAdd,StrDel,str0)
  
  StrAdd = "ATTR_T_TASK_DEPT"
  StrDel = StrAdd
  Call ObjDefAttrAddAll("OBJECT_T_TASK",StrAdd,StrDel,str0)
  
  StrAdd = "ATTR_PRINT_REQUEST_DEPT"
  StrDel = StrAdd
  Call ObjDefAttrAddAll("OBJECT_PRINT_REQUEST",StrAdd,StrDel,str0)
  
  StrAdd = "ATTR_T_TASK_DEPARTMENT"
  StrDel = StrAdd
  Call ObjDefAttrAddAll("OBJECT_T_TASK",StrAdd,StrDel,str0)
  Call ObjDefAttrAddAll("OBJECT_TENDER_DOC",StrAdd,StrDel,str0)
  Call ObjDefAttrAddAll("OBJECT_PURCHASE_DOC",StrAdd,StrDel,str0)
  
  StrAdd = "ATTR_USER_DEPT"
  StrDel = StrAdd
  Call ObjDefAttrAddAll("OBJECT_PROJECT",StrAdd,StrDel,str0)
  Call ObjDefAttrAddAll("OBJECT_P_TASK",StrAdd,StrDel,str0)
  
  'StrAdd = "ATTR_T_MATCHING_PERSON_DEPT"
  'StrDel = StrAdd
  'Call ObjDefAttrAddAll("",StrAdd,StrDel,str0)
  
  StrAdd = "ATTR_T_TASK_TDEPT"
  StrDel = StrAdd
  Call ObjDefAttrAddAll("OBJECT_T_TASK",StrAdd,StrDel,str0)
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4349()
  str = "Кейс 4349:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4349"
  
  'Добавление атрибутов
  StrAdd = "ATTR_PURCHASE_DOC_TYPE,ATTR_T_TASK_DEPARTMENT"
  Call ObjDefAttrAddAll("OBJECT_PURCHASE_DOC",StrAdd,"",str0)
  StrAdd = "ATTR_TENDER_ITEM_PRICE_MAX_VALUE,ATTR_TENDER_START_WORK_DATA,ATTR_TENDER_END_WORK_DATA"
  StrDel = "ATTR_TENDER_ITEM_PRICE_MAX_VALUE,ATTR_TENDER_START_END_WORK_DATA"
  Call ObjDefAttrAddAll("OBJECT_TENDER_INSIDE",StrAdd,StrDel,str0)
  Call ObjDefAttrAddAll("OBJECT_PURCHASE_DOC",StrAdd,StrDel,str0)
  StrAdd = "ATTR_TENDER_INVITATION_PRICE_EIS,ATTR_TENDER_ADVANCE_PLAN_PAY,ATTR_TENDER_NUM_EIS" &_
  ",ATTR_TENDER_INSIDE_ORDER_LIST"
  Call ObjDefAttrAddAll("OBJECT_TENDER_INSIDE",StrAdd,StrAdd,str0)
  
  'Добавление атрибута в системные
  AttrName = "ATTR_TENDER_ASEZ_NUM"
  If ThisApplication.AttributeDefs.Has(AttrName) Then
    If ThisApplication.Attributes.Has(AttrName) = False Then
      Set Attr = ThisApplication.Attributes.Create(ThisApplication.AttributeDefs(AttrName))
      str0 = str0 & chr(10) & "Добавлен системный атрибут """ &_
        ThisApplication.AttributeDefs(AttrName).Description & """"
      Attr.Value = "0180"
    End If
  End If
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4383()
  str = "Кейс 4383:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4383"
  
  'Удаление статуса
  StatusName = "STATUS_T_TASK_IS_MATCHING"
  Call SystemObjDel(str0,StatusName)
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4384()
  str = "Кейс 4384:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4384"
  
  CountAdd = 0
  
  'Добавление атрибутов
  StrAdd = "ATTR_EIS_NUM,ATTR_EIS_PUBLISH,ATTR_FULFILLDATE_PLAN"
  Call ObjDefAttrAddAll("OBJECT_CONTRACT",StrAdd,"",str0)
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4391()
  str = "Кейс 4391:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4391"
  
  CountAdd = 0
  
  'Добавление атрибутов
  StrAdd = "ATTR_DESCRIPTION"
  Call ObjDefAttrAddAll("OBJECT_PROJECT_SECTION_SUBSECTION",StrAdd,"",str0)
  Call ObjDefAttrAddAll("OBJECT_PROJECT_SECTION",StrAdd,"",str0)
  Call ObjDefAttrAddAll("OBJECT_WORK_DOCS_FOR_BUILDING",StrAdd,"",str0)
  For Each Obj in ThisApplication.ObjectDefs("OBJECT_PROJECT_SECTION_SUBSECTION").Objects
    Val = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "ProjectSectionFullDescrGen",Obj)
    If Obj.Attributes.Has(StrAdd) Then
      Obj.Attributes(StrAdd).Value = Val
    End If
  Next
  For Each Obj in ThisApplication.ObjectDefs("OBJECT_PROJECT_SECTION").Objects
    Val = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "ProjectSectionFullDescrGen",Obj)
    If Obj.Attributes.Has(StrAdd) Then
      Obj.Attributes(StrAdd).Value = Val
    End If
  Next
  For Each Obj in ThisApplication.ObjectDefs("OBJECT_WORK_DOCS_FOR_BUILDING").Objects
    If Obj.Attributes.Has(StrAdd) Then
      Obj.Attributes(StrAdd).Value = Obj.Description
    End If
  Next
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4394()
  str = "Кейс 4394:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4394"
  
  CountAdd = 0
  
  'Добавление атрибутов
  StrAdd = "ATTR_FOLDER_TYPE"
  Set Clf = ThisApplication.Classifiers.FindBySysId("NODE_FOLDER_GENERAL")
  Call ObjDefAttrAddAll("OBJECT_FOLDER",StrAdd,"",str0)
  For Each Obj in ThisApplication.ObjectDefs("OBJECT_FOLDER").Objects
    If Obj.Attributes.Has(StrAdd) and not Clf is Nothing Then
      If Obj.Attributes(StrAdd).Empty = True Then
        Obj.Attributes(StrAdd).Classifier = Clf
      End If
    End If
  Next
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4470()
  str = "Кейс 4470:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4470"
  
  CountAdd = 0
  
  'Создание записей в системной таблице
  AttrName = "ATTR_KD_COPY_ATTRS"
  Arr = Split("ATTR_CHECK_LIST,ATTR_DOCUMENT_NAME,ATTR_PROJECT",",")
  If ThisApplication.Attributes.Has(AttrName) = False Then
    ThisApplication.Attributes.Create ThisApplication.AttributeDefs(AttrName)
  End If
  Set Rows = ThisApplication.Attributes(AttrName).Rows
  DefName = "OBJECT_DOC_DEV"
  Check = True
  For Each Row in Rows
    If Row.Attributes("ATTR_KD_OBJ_TYPE").Value = DefName Then
      Check = False
      Exit For
    End If
  Next
  If Check = True Then
    For i = 0 to Ubound(Arr)
      Set NewRow = Rows.Create
      NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = DefName
      NewRow.Attributes("ATTR_KD_ATTR").Value = Arr(i)
    Next
    str0 = chr(10) & "В системный атрибут ""Копируемые атрибуты"" добавлены строки для """ & ThisApplication.ObjectDefs(DefName).Description & """"
  End If
  
  DefName = "OBJECT_DRAWING"
  Check = True
  For Each Row in Rows
    If Row.Attributes("ATTR_KD_OBJ_TYPE").Value = DefName Then
      Check = False
      Exit For
    End If
  Next
  If Check = True Then
    For i = 0 to Ubound(Arr)
      Set NewRow = Rows.Create
      NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = DefName
      NewRow.Attributes("ATTR_KD_ATTR").Value = Arr(i)
    Next
    str0 = str0 & chr(10) & "В системный атрибут ""Копируемые атрибуты"" добавлены строки для """ & ThisApplication.ObjectDefs(DefName).Description & """"
  End If
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4484()
  str = "Кейс 4484:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4484"
  
  Count = 0
  
  'Удаление команд
  Call SystemObjDel(str0,"CMD_TENDER_OUT_GO_INVALIDATED")
  Call SystemObjDel(str0,"CMD_TENDER_OUT_APPROVE")
  Call SystemObjDel(str0,"CMD_TENDER_OUT_BACK_TO_WORK")
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4492()
  str = "Кейс 4492:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4492"
  
  CountAdd = 0
  
  'Создание записей в системной таблице
  AttrName = "ATTR_KD_COPY_ATTRS"
  Arr = Split("ATTR_T_TASK_TDEPTS_TBL,ATTR_RESPONSIBLE,ATTR_DOCUMENT_CONF,ATTR_T_TASK_CHECKED," &_
  "ATTR_T_TASK_DEVELOPED,ATTR_SIGNER,ATTR_T_TASK_CONTENT,ATTR_NAME_SHORT,ATTR_T_TASK_SET," &_
  "ATTR_T_TASK_PPLINKED,ATTR_CONTRACT_STAGE,ATTR_UNIT,ATTR_T_TASK_DEPARTMENT",",")
  If ThisApplication.Attributes.Has(AttrName) = False Then
    ThisApplication.Attributes.Create ThisApplication.AttributeDefs(AttrName)
  End If
  Set Rows = ThisApplication.Attributes(AttrName).Rows
  DefName = "OBJECT_T_TASK"
  Check = True
  For Each Row in Rows
    If Row.Attributes("ATTR_KD_OBJ_TYPE").Value = DefName Then
      Check = False
      Exit For
    End If
  Next
  If Check = True Then
    For i = 0 to Ubound(Arr)
      Set NewRow = Rows.Create
      NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = DefName
      NewRow.Attributes("ATTR_KD_ATTR").Value = Arr(i)
    Next
    str0 = chr(10) & "В системный атрибут ""Копируемые атрибуты"" добавлены строки для """ & ThisApplication.ObjectDefs(DefName).Description & """"
  End If
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case4584()
  str = "Кейс 4584:"
  str0 = ""
  Progress.Text = "Выполняется кейс 4584"
  
  Count = 0
  
  'Добавление атрибута "Папка для Актов" в системные
  AttrName = "ATTR_FOLDER_OBJECT_CONTRACT_COMPL_REPORT"
  If ThisApplication.AttributeDefs.Has(AttrName) Then
    If ThisApplication.Attributes.Has(AttrName) = False Then
      Set Attr = ThisApplication.Attributes.Create(ThisApplication.AttributeDefs(AttrName))
      str0 = str0 & chr(10) & "Добавлен системный атрибут """ &_
        ThisApplication.AttributeDefs(AttrName).Description & """"
      For Each Obj in ThisApplication.ObjectDefs("OBJECT_KD_FOLDER").Objects
        If Obj.Attributes("ATTR_FOLDER_NAME").Value = "Акты" Then
          Attr.Value = Obj.GUID
          Exit For
        End If
      Next
    End If
  End If
  'Добавление атрибута "Папка для Соглашений" в системные
  AttrName = "ATTR_FOLDER_OBJECT_AGREEMENT"
  If ThisApplication.AttributeDefs.Has(AttrName) Then
    If ThisApplication.Attributes.Has(AttrName) = False Then
      Set Attr = ThisApplication.Attributes.Create(ThisApplication.AttributeDefs(AttrName))
      str0 = str0 & chr(10) & "Добавлен системный атрибут """ &_
        ThisApplication.AttributeDefs(AttrName).Description & """"
      For Each Obj in ThisApplication.ObjectDefs("OBJECT_KD_FOLDER").Objects
        If Obj.Attributes("ATTR_FOLDER_NAME").Value = "Соглашения" Then
          Attr.Value = Obj.GUID
          Exit For
        End If
      Next
    End If
  End If
  'Добавление атрибута "Папка для Накладных" в системные
  AttrName = "ATTR_FOLDER_OBJECT_INVOICE"
  If ThisApplication.AttributeDefs.Has(AttrName) Then
    If ThisApplication.Attributes.Has(AttrName) = False Then
      Set Attr = ThisApplication.Attributes.Create(ThisApplication.AttributeDefs(AttrName))
      str0 = str0 & chr(10) & "Добавлен системный атрибут """ &_
        ThisApplication.AttributeDefs(AttrName).Description & """"
      For Each Obj in ThisApplication.ObjectDefs("OBJECT_KD_FOLDER").Objects
        If Obj.Attributes("ATTR_FOLDER_NAME").Value = "Накладные" Then
          Attr.Value = Obj.GUID
          Exit For
        End If
      Next
    End If
  End If
  
  'Перенос объектов типа "Акт", "Соглашение", "Накладная" в новые папки
  Guid = ThisApplication.Attributes("ATTR_FOLDER_OBJECT_CONTRACT_COMPL_REPORT").Value
  If Guid <> "" Then
    Set Folder = ThisApplication.GetObjectByGUID(Guid)
    If not Folder is Nothing Then
      For Each Obj in ThisApplication.ObjectDefs("OBJECT_CONTRACT_COMPL_REPORT").Objects
        If Folder.Objects.Has(Obj.Handle) = False Then
          Folder.Objects.Add Obj
          Count = Count + 1
        End If
      Next
    End If
  End If
  
  Guid = ThisApplication.Attributes("ATTR_FOLDER_OBJECT_AGREEMENT").Value
  If Guid <> "" Then
    Set Folder = ThisApplication.GetObjectByGUID(Guid)
    If not Folder is Nothing Then
      For Each Obj in ThisApplication.ObjectDefs("OBJECT_AGREEMENT").Objects
        If Folder.Objects.Has(Obj.Handle) = False Then
          Folder.Objects.Add Obj
          Count = Count + 1
        End If
      Next
    End If
  End If
  
  Guid = ThisApplication.Attributes("ATTR_FOLDER_OBJECT_INVOICE").Value
  If Guid <> "" Then
    Set Folder = ThisApplication.GetObjectByGUID(Guid)
    If not Folder is Nothing Then
      For Each Obj in ThisApplication.ObjectDefs("OBJECT_INVOICE").Objects
        If Folder.Objects.Has(Obj.Handle) = False Then
          Folder.Objects.Add Obj
          Count = Count + 1
        End If
      Next
    End If
  End If
  
  str0 = str0 & chr(10) & "Переопределены родительские объекты у " & Count & " объектов."
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

'===========================================================================================================
Sub Case6097()
  str = "Кейс 6097:"
  str0 = ""
  Progress.Text = "Выполняется кейс 6097"
  
  CountAdd = 0
  
  'Добавление атрибутов
  StrAdd = "ATTR_OLD_CONTRACT"
  Call ObjDefAttrAddAll("OBJECT_CONTRACT",StrAdd,"",str0)
  
  'Заполнение атрибута Контактное лицо
  Set Query = ThisApplication.Queries("QUERY_CONTACT_PERSON_FOR_CONTRACT")
  AttrName0 = "ATTR_CONTACT_PERSON"
  AttrName1 = "ATTR_CONTACT_PERSON_STR"
  If ThisApplication.AttributeDefs.Has(AttrName0) Then
    AttrDescr = ThisApplication.AttributeDefs(AttrName0).Description
  End If
  For Each Obj in ThisApplication.ObjectDefs("OBJECT_CONTRACT").Objects
    If Obj.Attributes.Has(AttrName1) and Obj.Attributes.Has(AttrName0) Then
      If Obj.Attributes(AttrName1).Empty = False and Obj.Attributes(AttrName0).Empty = True Then
        Val = Obj.Attributes(AttrName1).Value
        Pos = InStr(Val,", ")-1
        If Pos >= 0 Then Val = Left(Val,Pos)
        If Val <> "" Then
        Param = "= '*" & Val & "*'"
          Query.Parameter("DESCR") = Param
        End If
        Set Objects = Query.Objects
        If Objects.Count = 1 Then
          Obj.Attributes(AttrName0).Object = Objects(0)
          str0 = str0 & chr(10) & chr(9) & "Заполнен атрибут """ & AttrDescr & """ у договора """ & Obj.Description & """"
        End If
      End If
    End If
  Next
  
  'Журнал выполнения
  Call Notify(str,str0)
End Sub

Function GetAttrValue4236(ObjAttr,AttrName)
  GetAttrValue4236 = "0"
  If ObjAttr.Has(AttrName) Then
    Attr = ObjAttr(AttrName).Value
    If Attr = "" Then Attr = "0"
    Str = ""
    LenStart = Len(Attr)
    LenDiff = 0
    Check = True
    For i = 0 to LenStart-1
      Char0 = Mid(Attr,i+1-LenDiff,1)
      If IsNumeric(Char0) = False Then
        If StrComp(Char0,".",vbTextCompare) = 0 Then
          Attr = Replace(Attr,".",",")
          If Check = False Then
            Attr = Left(Attr,i-LenDiff) & Right(Attr,LenStart-i-1)
            LenDiff = LenDiff + 1
          End If
          Check = False
        ElseIf StrComp(Char0,",",vbTextCompare) = 0 Then
          If Check = False Then
            Attr = Left(Attr,i-LenDiff) & Right(Attr,LenStart-i-1)
            LenDiff = LenDiff + 1
          End If
          Check = False
        Else
          Attr = Left(Attr,i-LenDiff) & Right(Attr,LenStart-i-1)
          LenDiff = LenDiff + 1
        End If
      End If
    Next
  End If
  GetAttrValue4236 = Attr
End Function

'===========================================================================================================
'Процедура глобального добавления/удаления атрибутов
Sub ObjDefFormAdd(ObjDefStr,StrAdd,StrDel,str0)
  If ThisApplication.ObjectDefs.Has(ObjDefStr) Then
    Set ObjDef = ThisApplication.ObjectDefs(ObjDefStr)
    Set ObjDefForms = ObjDef.InputForms
    ObjDefDescr = ObjDef.Description
    ArrAdd = Split(StrAdd,",")
    ArrDel = Split(StrDel,",")
    'добавляем формы к типу
    For i = 0 to UBound(ArrAdd)
      Sysname = ArrAdd(i)
      If ObjDefForms.Has(Sysname) = False Then
        If ThisApplication.InputForms.Has(Sysname) Then
          FormDescr = ThisApplication.InputForms(Sysname).Description
          ObjDefForms.Add ThisApplication.InputForms(Sysname)
          str0 = str0 & chr(10) & chr(9) & "Добавлена форма ввода """ & FormDescr & """ к типу объекта """ & ObjDefDescr & """"
        Else
          str0 = str0 & chr(10) & chr(9) & "Форма ввода """ & Sysname & """ отсутствует в системе!"
        End If
      End If
    Next
    'удаляем формы у типа
    For i = 0 to UBound(ArrDel)
      Sysname = ArrAdd(i)
      If ObjDefForms.Has(Sysname) Then
        ObjDefForms.Remove ObjDefForms(Sysname)
        FormDescr = ThisApplication.InputForms(Sysname).Description
        str0 = str0 & chr(10) & chr(9) & "Удалена форма ввода """ & FormDescr & """ у типа объекта """ & ObjDefDescr
      End If
    Next
    
    Call StrAddDel(Str0,CountAdd,CountDel,ObjDefDescr)
  End If
End Sub

'===========================================================================================================
'Процедура глобального добавления/удаления атрибутов
Sub ObjDefAttrAddAll(ObjDefStr,StrAdd,StrDel,str0)
  If ThisApplication.ObjectDefs.Has(ObjDefStr) Then
    Set ObjDef = ThisApplication.ObjectDefs(ObjDefStr)
    Set ObjDefAttr = ObjDef.AttributeDefs
    ObjDefDescr = ObjDef.Description
    ArrAdd = Split(StrAdd,",")
    ArrDel = Split(StrDel,",")
    'удаляем атрибуты у типа
    For i = 0 to UBound(ArrDel)
      Call ObjDefAttrDel(ObjDefDescr,ObjDefAttr,ArrDel(i),str0)
    Next
    'добавляем атрибуты к типу
    For i = 0 to UBound(ArrAdd)
      Call ObjDefAttrAdd(ObjDefDescr,ObjDefAttr,ArrAdd(i),str0)
    Next
    
    'Обновляем атрибуты существующих объектов
    CountAdd = 0
    CountDel = 0
    For Each Obj in ObjDef.Objects
      Set ObjAttr = Obj.Attributes
      'удаляем атрибуты у объектов
      For i = 0 to UBound(ArrDel)
        Call ObjAttrDel(ObjAttr,ArrDel(i),CountDel)
      Next
      'добавляем атрибуты к объектам
      For i = 0 to UBound(ArrAdd)
        Call ObjAttrAdd(ObjAttr,ArrAdd(i),CountAdd)
      Next
    Next
    
    Call StrAddDel(Str0,CountAdd,CountDel,ObjDefDescr)
  End If
End Sub

'Процедура формирования количества в журнале
Sub StrAddDel(Str0,CountAdd,CountDel,ObjDefDescr)
  If CountAdd <> 0 Then
    Str0 = Str0 & chr(10) & chr(9) & "Добавлено " & CountAdd & " атрибутов к объектам типа """ & ObjDefDescr & """"
  End If
  If CountDel <> 0 Then
    Str0 = Str0 & chr(10) & chr(9) & "Удалено " & CountDel & " атрибутов у объектов типа """ & ObjDefDescr & """"
  End If
End Sub

'Процедура добавления атрибута к типу бъекта
Sub ObjDefAttrAdd(ObjDefDescr,ObjDefAttr,Sysname,str0)
  If ObjDefAttr.Has(Sysname) = False Then
    If ThisApplication.AttributeDefs.Has(Sysname) Then
      AttrDescr = ThisApplication.AttributeDefs(Sysname).Description
      ObjDefAttr.Add ThisApplication.AttributeDefs(Sysname)
      str0 = str0 & chr(10) & chr(9) & "Добавлен атрибут """ & AttrDescr & """ к типу объекта """ & ObjDefDescr & """"
    Else
      str0 = str0 & chr(10) & chr(9) & "Атрибут """ & Sysname & """ отсутствует в системе!"
    End If
  End If
End Sub

'Процедура удаления атрибута с типа объекта
Sub ObjDefAttrDel(ObjDefDescr,ObjDefAttr,Sysname,str0)
  If ObjDefAttr.Has(Sysname) Then
    ObjDefAttr.Remove ObjDefAttr(Sysname)
    AttrDescr = ThisApplication.AttributeDefs(Sysname).Description
    str0 = str0 & chr(10) & chr(9) & "Удален атрибут """ & AttrDescr & """ у типа объекта """ & ObjDefDescr
  End If
End Sub

'Процедура добавления атрибута к объекту
Sub ObjAttrAdd(ObjAttr,Sysname,CountAdd)
  If ObjAttr.Has(Sysname) = False and ThisApplication.AttributeDefs.Has(Sysname) Then
    ObjAttr.Create ThisApplication.AttributeDefs(Sysname)
    CountAdd = CountAdd + 1
  End If
End Sub

'Процедура удаления атрибута у объекта
Sub ObjAttrDel(ObjAttr,Sysname,CountDel)
  If ObjAttr.Has(Sysname) Then
    ObjAttr.Remove ObjAttr(Sysname)
    CountDel = CountDel + 1
  End If
End Sub

'Журнал выполнения
Sub Notify(str,str0)
  If str0 <> "" Then
    str = str & " Выполнено!" & str0
  Else
    str = str & " Нет изменений!"
  End If
  ThisApplication.AddNotify str
End Sub

Sub StatusSet(str0,ObjSysName,StatusName)
  If ThisApplication.ObjectDefs.Has(ObjSysName) Then
    Set ObjDef = ThisApplication.ObjectDefs(ObjSysName)
    If StatusName = "" Then
      str0 = str0 & chr(10) & chr(9) & "Не указан статус для объекта типа """ & ObjSysName & """"
    ElseIf ThisApplication.Statuses.Has(StatusName) Then
      Set Status = ThisApplication.Statuses(StatusName)
      Count = 0
      For Each Obj in ObjDef.Objects
        If Obj.Status is Nothing Then
          Obj.Status = Status
          Count = Count + 1
        End If
      Next
      If Count <> 0 Then
        str0 = str0 & chr(10) & chr(9) & "Определены статусы для " & Count & " объектов типа """ & ObjDef.Description & """"
      End If
    Else
      str0 = str0 & chr(10) & chr(9) & "Статус """ & StatusName & """ не найден в системе!"
    End If
  Else
    str0 = str0 & chr(10) & chr(9) & "Тип объекта """ & ObjSysName & """ не найден в системе!"
  End If
End Sub

'Процедура удаления системного элемента из системы
Sub SystemObjDel(str0,ObjSysName)
  on Error Resume Next
  If ThisApplication.AttributeDefs.Has(ObjSysName) Then
    Set Attr = ThisApplication.AttributeDefs(ObjSysName)
    Descr = Attr.Description
    For Each ObjDef in ThisApplication.ObjectDefs
      For Each Obj0 in ObjDef.Objects
        If Obj0.Attributes.Has(Attr) Then
          Obj0.Attributes.Remove Attr
          str0 = str0 & chr(10) & "Из объекта """ & Obj0.Description & """ удален атрибут """ & Descr & """"
        End If
      Next
      If ObjDef.AttributeDefs.Has(Attr) Then
        ObjDef.AttributeDefs.Remove Attr
        str0 = str0 & chr(10) & "Из типа объекта объекта """ & ObjDef.Description & """ удален атрибут """ & Descr & """"
      End If
    Next
   
    Attr.Erase
    If ThisApplication.AttributeDefs.Has(ObjSysName) = False Then
      str0 = str0 & chr(10) & "Из системы удален тип атрибута """ & Descr & """"
    End If
  ElseIf ThisApplication.ObjectDefs.Has(ObjSysName) Then
    Descr = ThisApplication.ObjectDefs(ObjSysName).Description
    For Each Obj0 in ThisApplication.ObjectDefs(ObjSysName).Objects
      Descr0 = Obj0.Description
      Obj0.Erase
      If ThisApplication.ObjectDefs(ObjSysName).Objects.Has(Obj0) = False Then
        str0 = str0 & chr(10) & "Из системы удален объект """ & Descr0 & """"
      End If
    Next
    ThisApplication.ObjectDefs(ObjSysName).Erase
    If ThisApplication.ObjectDefs.Has(ObjSysName) = False Then
      str0 = str0 & chr(10) & "Из системы удален тип объекта """ & Descr & """"
    End If
  ElseIf ThisApplication.InputForms.Has(ObjSysName) Then
    Set Form = ThisApplication.InputForms(ObjSysName)
    Descr = Form.Description
    For Each ObjDef in ThisApplication.ObjectDefs
      If ObjDef.InputForms.Has(ObjSysName) Then
        ObjDef.InputForms.Remove Form
        If ObjDef.InputForms.Has(ObjSysName) = False Then
          str0 = str0 & chr(10) & "Из типа объекта """ & ObjDef.Description & """ удалена форма ввода """ & Descr & """"
        End If
      End If
    Next
    Form.Erase
    If ThisApplication.InputForms.Has(ObjSysName) = False Then
      str0 = str0 & chr(10) & "Из системы удалена форма ввода """ & Descr & """"
    End If
  ElseIf Not ThisApplication.Classifiers.FindBySysId(ObjSysName) Is Nothing Then
    set cls = ThisApplication.Classifiers.FindBySysId(ObjSysName)
    Descr = cls.Description
    cls.Erase
    If ThisApplication.Classifiers.FindBySysId(ObjSysName) Is Nothing Then
      str0 = str0 & chr(10) & "Из системы удален классификатор """ & Descr & """"
    End If
  ElseIf ThisApplication.Statuses.Has(ObjSysName) Then
    Descr = ThisApplication.Statuses(ObjSysName).Description
    ThisApplication.Statuses(ObjSysName).Erase
    If ThisApplication.Statuses.Has(ObjSysName) = False Then
      str0 = str0 & chr(10) & "Из системы удален статус """ & Descr & """"
    End If
  ElseIf ThisApplication.Commands.Has(ObjSysName) Then
    Descr = ThisApplication.Commands(ObjSysName).Description
    ThisApplication.Commands(ObjSysName).Erase
    If ThisApplication.Commands.Has(ObjSysName) = False Then
      str0 = str0 & chr(10) & "Из системы удалена команда """ & Descr & """"
    End If
  ElseIf ThisApplication.RoleDefs.Has(ObjSysName) Then
    Set role = ThisApplication.RoleDefs(ObjSysName)
    Descr = role.Description
    For Each comm in ThisApplication.Commands
      If comm.RoleDefs.Has(role) Then
        comm.RoleDefs.Remove role
        str0 = str0 & chr(10) & "Из команды """ & comm.Description & """ удалена роль """ & Descr & """"
      End If
    Next
    
    ThisApplication.RoleDefs(ObjSysName).Erase
    If ThisApplication.RoleDefs.Has(ObjSysName) = False Then
      str0 = str0 & chr(10) & "Из системы удалена роль """ & Descr & """"
    End If
    
  ElseIf ThisApplication.Queries.Has(ObjSysName) Then
    Set role = ThisApplication.Queries(ObjSysName)
    Descr = role.Description
    
    ThisApplication.Queries(ObjSysName).Erase
    If ThisApplication.Queries.Has(ObjSysName) = False Then
      str0 = str0 & chr(10) & "Из системы удалена выборка """ & Descr & """"
    End If
  ElseIf ThisApplication.Profiles.Has(ObjSysName) Then
    Set prof = ThisApplication.Profiles(ObjSysName)
    Descr = prof.Description
    
    ThisApplication.Profiles(ObjSysName).Erase
    If ThisApplication.Profiles.Has(ObjSysName) = False Then
      str0 = str0 & chr(10) & "Из системы удалена выборка """ & Descr & """"
    End If
    
  End If
  On Error GoTo 0
End Sub

