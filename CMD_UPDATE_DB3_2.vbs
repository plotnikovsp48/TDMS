USE "CMD_DLL_UPDATE"
'===========================================================================================================
' Обновление за 28.07.2017


  ThisScript.SysAdminModeOn
  ThisApplication.Utility.WaitCursor = True
  Set Progress = ThisApplication.Dialogs.ProgressDlg
  Progress.Start
  progress.SetLocalRanges 0,100
  progress.Position = 0
  
  Call Update3()
  
  progress.Position = 100
  ThisApplication.Utility.WaitCursor = False
  Progress.Stop
  
  
Sub Update3()
  ans = msgbox ("Процедура обновления может занять некоторое время. Продолжить? ",vbQuestion+vbYesNo,_
    "Микрообновление базы от 14.08.2017")
  If ans<>vbYes Then Exit Sub
  
  Call Update3_2()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub


Sub Update3_2()

'================================= Новое обновление БД-3

  Call ChangeTenderClass()
    progress.Position = 20
  Call DeleteClassifiers()
    progress.Position = 40
  Call AddSystemAttribute(AttrList()) 
    progress.Position = 60
  Call SetSystemAttrs(AttrList())
    progress.Position = 80
  Call ObjAttrsSync()
    progress.Position = 90
  Call misc()
  Call PanelQueriesUpdate()
    progress.Position = 100
  Call MoveTechObjects1()
End Sub

Sub ChangeTenderClass()
  For Each Obj in ThisApplication.ObjectDefs("OBJECT_PURCHASE_FOLDER").Objects
            Set clf = Obj.Attributes("ATTR_TENDER_TYPE").Classifier
            If clf Is Nothing Then
              If Obj.Description = "Внешние закупки" Then
              Obj.Attributes("ATTR_TENDER_TYPE").Classifier = _
                ThisApplication.Classifiers("NODE_C4FADFDE_85E0_44AD_BC1D_DF184586E883").Classifiers("NODE_PURCHASE_OUTSIDE")
              ElseIf Obj.Description = "Внутренние закупки" Then
              Obj.Attributes("ATTR_TENDER_TYPE").Classifier = _
                ThisApplication.Classifiers("NODE_C4FADFDE_85E0_44AD_BC1D_DF184586E883").Classifiers("NODE_TENDER_INSIDE")
              End If
            Else
              If clf.SysName = "NODE_65D8E68D_4F16_4133_823C_7C4E667A10D7" Then
                Obj.Attributes("ATTR_TENDER_TYPE").Classifier = _
                ThisApplication.Classifiers("NODE_C4FADFDE_85E0_44AD_BC1D_DF184586E883").Classifiers("NODE_PURCHASE_OUTSIDE")
              ElseIf clf.SysName = "NODE_FB0CD208_A15F_4BDB_B9A6_EDDAC69646F4" Then
                Obj.Attributes("ATTR_TENDER_TYPE").Classifier = _
                ThisApplication.Classifiers("NODE_C4FADFDE_85E0_44AD_BC1D_DF184586E883").Classifiers("NODE_TENDER_INSIDE")
              End If
            End If
          Next
End Sub

Sub DeleteClassifiers()
  List = "NODE_65D8E68D_4F16_4133_823C_7C4E667A10D7,NODE_FB0CD208_A15F_4BDB_B9A6_EDDAC69646F4"
Call SystemObjDelByList(List)
End Sub

  
'' Список системных атрибутов технического документооборота
Function AttrList()
  AttrList = "ATTR_FOLDER_OBJECT_PURCHASE_OUTSIDE,ATTR_FOLDER_OBJECT_TENDER_INSIDE"
End Function



' Добавление системных атрибутов
Sub AddSystemAttribute(aList)
  Progress.Text = "Добавляются системные атрибуты"
  arr = Split(aList,",")
  str0 = ""
  For each attrname In arr
    If ThisApplication.AttributeDefs.Has(AttrName) Then
      If ThisApplication.Attributes.Has(AttrName) = False Then
        Progress.Text = "Добавляются системные атрибуты: " & attrname
        Set Attr = ThisApplication.Attributes.Create(ThisApplication.AttributeDefs(AttrName))
        str0 = str0 & chr(13) & "Добавлен системный атрибут """ &_
          ThisApplication.AttributeDefs(AttrName).Description & """"
      Else
      str0 = str0 & chr(13) & "---Cистемный атрибут """ &_
          ThisApplication.AttributeDefs(AttrName).Description & """ уже есть в системе"
      End If
    Else
      str0 = str0 & chr(13) & "***ОШИБКА: Атрибут """ &_
          AttrName & """ отсутствует в системе"
    End If
  Next
  call Log(str0)
End Sub

' Установка системных атрибутов
Sub SetSystemAttrs(aList)
  Progress.Text = "Настройка системных атрибутов"
  lst = aList
  arr = Split(lst,",")
  
  For each attrname In arr
    Progress.Text = "Настройка системных атрибутов: " & attrname
    If ThisApplication.AttributeDefs.Has(attrname) = True Then
      If ThisApplication.Attributes.Has(attrname) = False Then
        ThisApplication.Attributes.Create Thisapplication.AttributeDefs(attrname)
      End If
      Select Case attrname
        Case "ATTR_FOLDER_OBJECT_PURCHASE_OUTSIDE"
          For Each Obj in ThisApplication.ObjectDefs("OBJECT_PURCHASE_FOLDER").Objects
            Set clf = Obj.Attributes("ATTR_TENDER_TYPE").Classifier
            If clf Is Nothing Then
              Obj.Attributes("ATTR_TENDER_TYPE").Classifier = _
                ThisApplication.Classifiers("NODE_C4FADFDE_85E0_44AD_BC1D_DF184586E883").Classifiers("NODE_PURCHASE_OUTSIDE")
            End If
            If Not clf Is Nothing Then
              If clf.SysName = "NODE_PURCHASE_OUTSIDE" Then
                Set Attr = ThisApplication.Attributes(attrname)
                Attr.Value = Obj.GUID
                Exit For
              End If
            End If
          Next
        Case "ATTR_FOLDER_OBJECT_TENDER_INSIDE"
          For Each Obj in ThisApplication.ObjectDefs("OBJECT_PURCHASE_FOLDER").Objects
            Set clf = Obj.Attributes("ATTR_TENDER_TYPE").Classifier
            If clf Is Nothing Then
              Obj.Attributes("ATTR_TENDER_TYPE").Classifier = _
                ThisApplication.Classifiers("NODE_C4FADFDE_85E0_44AD_BC1D_DF184586E883").Classifiers("NODE_TENDER_INSIDE")
            End If
            If Not clf Is Nothing Then
              If clf.SysName = "NODE_TENDER_INSIDE" Then
                Set Attr = ThisApplication.Attributes(attrname)
                Attr.Value = Obj.GUID
                Exit For
              End If
            End If
          Next
        Case "ATTR_AGREENENT_SETTINGS"
          Call Set_ATTR_AGREENENT_SETTINGS()
      End Select
    End If
  Next
End Sub

Sub Log(txt)
  'msgbox txt
End Sub

Sub MoveTechObjects1()
  ThisScript.SysAdminModeOn
  'Перемещение объектов в техническую папку
  List = "OBJECT_LIST_AN"
  For each obj in ThisApplication.ObjectDefs("OBJECT_SYSTEM_ID").Objects
    Set root = ThisApplication.GetObjectByGUID("{E6B689C1-18CC-4835-8597-D3025419D039}")
    If InStr(List,obj.attributes("ATTR_KD_OBJECT_TYPE")) <> 0 Then
      Set p = Obj.Parent
      If p Is Nothing Then
        root.Objects.Add Obj
      ElseIf p.Handle <> root.Handle Then
        root.Objects.Add Obj
      End If
    End If
  Next
End Sub

Sub Misc()
  ThisScript.SysAdminModeOn
  For each Obj In ThisApplication.ObjectDefs("OBJECT_CONTRACT").Objects
    If Obj.Attributes.Has("ATTR_CONTRACT") = False Then
      Obj.Attributes.Create Thisapplication.AttributeDefs("ATTR_CONTRACT")
    End If
    
    If Obj.Attributes("ATTR_CONTRACT").Object Is Nothing Then
      Call ThisApplication.ExecuteScript ("CMD_DLL", "SetAttr_F", Obj, "ATTR_CONTRACT", Obj, True)
    End If
  Next
End Sub

' Синхронизация атрибутов объектов
Sub ObjAttrsSync()
  Progress.Text = "Обновление атрибутов объекта:"
  List =  "OBJECT_CONTRACT"
          
  arr1 = Split(List, ",")
  pos = progress.Position
  For each oDefName in arr1
    If ThisApplication.ObjectDefs.Has(oDefName) Then 
      Set oDef = ThisApplication.ObjectDefs(oDefName)
      Call ObjAttrSync(oDef)
    End If
  Next
End Sub

Sub ObjAttrSync(oDef)
  Progress.Text = "Синхронизация атрибутов объектов: " & oDef.Description
  Set ObjDef = oDef
  CountDel = 0
  CountAddCountAdd = 0
  For Each Obj In oDef.Objects
    Call ThisApplication.ExecuteScript("CMD_CREATED_OBJECTS_ATTR_SYNC","AttrsDelAdd",Obj,ObjDef,CountDel,CountAdd)
  Next
End Sub

' Заполняем функцию в таблицу согласования
Sub Set_ATTR_AGREENENT_SETTINGS()
  ' Заполняем функцию в таблиу согласования
  val = "OBJECT_T_TASK;SendOrder"
  Set Table = ThisApplication.Attributes("ATTR_AGREENENT_SETTINGS")
    For each row in Table.Rows
      Select Case row.Attributes("ATTR_KD_OBJ_TYPE").Value
        Case "OBJECT_T_TASK"
          row.attributes("ATTR_AFTER_AGREE_FUNCTION").value = val
      End Select
    Next
End Sub

Sub PanelQueriesUpdate()
  Progress.Text = "Обновление выборок рабочего стола"
  Set o = ThisApplication.GetObjectByGUID("{A830F094-FAAC-48A6-8DC7-641B4C8B4610}")
  
  If ThisApplication.Desktop.Objects.Has(o) = False Then
    ThisApplication.Desktop.Objects.add o
  End If
    
  For Each Obj In ThisApplication.ObjectDefs("OBJECT_ARM_FOLDER").Objects
    ARM = ""
    If Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ПОРУЧЕНИЯ" Then
      ARM = "ORDERS"
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ДЕЛОПРОИЗВОДСТВО (Д)" Then
      ARM = "DPD"
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ДЕЛОПРОИЗВОДСТВО (С)" Then
      ARM = "DPC"
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ДЕЛОПРОИЗВОДСТВО (Р)" Then
      ARM = "DPR"
    End If
    
    List = ""
    ListToRem = ""
        
    Select Case ARM
      Case "ORDERS"
        Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
        List = ""
        ListToRem = "QUERY_FOR_N,QUERY_ON_NK,QUERY_FAVORIT1,QUERY_ON_CONTOL1"
        Call AddQuery(Obj,List,ListToRem)
      Case "DPD"
        Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
        List = ""
        ListToRem = "QUERY_INVOICE_DESCTOP,QUERY_DESCTOP_INVOICE_MY,QUERY_INVOICE_DOCS_ON_CHECK,QUERY_INVOICE_DOCS_APPROVED," &_
        "QUERY_DESCTOP_INVOICE_DOCS_READY_TO_ISSUE,QUERY_FAVORIT1,QUERY_ON_CONTOL1"
        Call AddQuery(Obj,List,ListToRem) 
      Case "DPC"
        Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
        List = ""
        ListToRem = "QUERY_INVOICE_DESCTOP,QUERY_DESCTOP_INVOICE_MY,QUERY_INVOICE_DOCS_ON_CHECK,QUERY_INVOICE_DOCS_APPROVED," &_
        "QUERY_DESCTOP_INVOICE_DOCS_READY_TO_ISSUE,QUERY_FAVORIT1,QUERY_ON_CONTOL1"
        Call AddQuery(Obj,List,ListToRem)
      Case "DPR"
        Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
        List = ""
        ListToRem = "QUERY_INVOICE_DESCTOP,QUERY_DESCTOP_INVOICE_MY,QUERY_INVOICE_DOCS_ON_CHECK,QUERY_INVOICE_DOCS_APPROVED," &_
        "QUERY_DESCTOP_INVOICE_DOCS_READY_TO_ISSUE,QUERY_FAVORIT1,QUERY_ON_CONTOL1"
        Call AddQuery(Obj,List,ListToRem) 
    End Select
  Next  
End Sub

