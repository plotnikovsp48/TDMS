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
  ans = msgbox ("Процедура обновления может занять некоторое время. Продолжить? ",vbQuestion+vbYesNo,"Микрообновление базы от 11.08.2017")
  If ans<>vbYes Then Exit Sub
  
  Call Update3_1()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub


' Добавление системных атрибутов
Sub Update3_1()


'================================= Новое обновление БД-3

  Call DeleteStatuses()
    progress.Position = 5
  Call SetSystemAttrs(AttrList())   ' Работает
    progress.Position = 15
  Call changeFDefs()
  Call RemoveFromObjDef()         ' Работает
  Call DeleteQUERY()
    progress.Position = 80
  Call PanelSettingsAdd()
    progress.Position = 85
  Call ObjAttrsSync()
    progress.Position = 90
  Call PanelQueriesUpdate()
  progress.Position = 100

'========================================================
End Sub


Sub misc2()
  Set oDef = ThisApplication.ObjectDefs("OBJECT_PURCHASE_OUTSIDE")
  If oDef.AttributeDefs.Has("ATTR_TENDER_COMPETITOR_PRICE_TABLE") = False Then
    oDef.AttributeDefs.Add Thisapplication.AttributeDefs("ATTR_TENDER_COMPETITOR_PRICE_TABLE")
  End If
  
  For each obj In ThisApplication.ObjectDefs("OBJECT_PURCHASE_OUTSIDE").Objects
    If Obj.attributes.Has("ATTR_TENDER_COMPETITOR_PRICE_TABLE") = False Then
      Obj.attributes.Create Thisapplication.AttributeDefs("ATTR_TENDER_COMPETITOR_PRICE_TABLE")
    End If
  Next
  
  Set oDef = ThisApplication.ObjectDefs("OBJECT_FOLDER")
  For each od In oDef.ObjectDefs
    If od.SysName = "OBJECT_OBJECT_DOCUMENT" Or od.SysName = "OBJECT_UNIT" Then
      
    End If
  Next
End Sub

Sub DelVersion
  Set Obj = Thisapplication.GetObjectByGUID("{89F01573-A899-4592-8BE1-E9DFF1CEAF79}")
  If Obj.Versions.Has("1") Then
  Obj.Versions.Remove("1")
  End If
End Sub

Sub PanelSettingsAdd()
  Set Objs = ThisApplication.ObjectDefs("OBJECT_PANEL_CONFIG")
  If Objs.Objects.Count = 0 Then Exit Sub
  Set Obj = Objs.Objects(0)
  Set Table = Obj.Attributes("ATTR_PANEL_CONFIG_TAB")
  List = "PROFILE_GIP,{75843AEE-A5FC-4343-86BA-85A87B4A748B};{41F5069E-F2FA-4A86-BFFC-009A6B27628F};{CCCE02F3-CB3E-4A81-A967-515591493CAC},x," &_
         "PROFILE_NK,{D4A5BFDD-0D62-4DA6-9F0E-8758A2EB819C},x," &_
         "PROFILE_COMPL,{0F20E044-FACA-4641-9B7D-020A0BEA7CAD},x," &_
         "PROFILE_ARM_DEVELOPERS,{CCCE02F3-CB3E-4A81-A967-515591493CAC};{41F5069E-F2FA-4A86-BFFC-009A6B27628F},x"         
         
  arr = Split(List,",")
  For i = 0 to Ubound(arr) step 3
    check = False
    For Each Row In Table.Rows
      If arr(i) <> "PROFILE_ARM_USER" Then
        If row.attributes("ATTR_PANEL_CONFIG_TAB_PROFIL").Value = arr(i) Then
          Check = True
          Exit For 
        End If
      ElseIf row.attributes("ATTR_PANEL_CONFIG_TAB_PROFIL").Value = "PROFILE_ARM_USER" Then
        val = row.attributes("ATTR_PANEL_CONFIG_TAB_FOLDERS").Value
        If InStr(val,arr(i+1)) = 0 Then
          val = val & ";" & arr(i+1)
          row.attributes("ATTR_PANEL_CONFIG_TAB_FOLDERS") = val
          val = ""
         End If
        Check = True
      End If
    Next
    If check = False Then
      Set row = Table.Rows.Create
      row.Attributes("ATTR_PANEL_CONFIG_TAB_PROFIL") = arr(i)
      row.Attributes("ATTR_PANEL_CONFIG_TAB_FOLDERS") = arr(i+1)
      row.Attributes("ATTR_ATTR_PANEL_CONFIG_TAB_EXPAND") = (arr(i+2) = "x")
    Else
      row.Attributes("ATTR_PANEL_CONFIG_TAB_FOLDERS") = arr(i+1)
      row.Attributes("ATTR_ATTR_PANEL_CONFIG_TAB_EXPAND") = (arr(i+2) = "x")
    End If
  Next
End Sub
  
'' Список системных атрибутов технического документооборота
Function AttrList()
  AttrList = "ATTR_FOLDER_OBJECT_NK," &_
  ""
End Function

Sub DeleteTemplates()
  List = "FILE_AUTOCAD_DWG,ОЧ03A0A.dwg,FILE_AUTOCAD_DWG,ОЧ03A1A.dwg,FILE_AUTOCAD_DWG,ОЧ03A2A.dwg,FILE_AUTOCAD_DWG,ОЧ03A3A.dwg,FILE_AUTOCAD_DWG,ОЧ03A4A.dwg,FILE_AUTOCAD_DWG,Заготовка_штампа.dwg"
  arr = Split(List,",")
  
  For i = 0 To Ubound(arr) Step 2
    Call DeleteTemplate(arr(i),Arr(i+1))
  Next
End Sub

Sub DeleteTemplate(fDefSysName,file)
  If ThisApplication.FileDefs.Has(fDefSysName) Then
    Set fDef = ThisApplication.FileDefs(fDefSysName)
      If fDef.Templates.Has(file) Then
        fDef.Templates(file).Erase
      End If
  End If
End Sub

  
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
  lst = "ATTR_AGREENENT_SETTINGS," & aList
  arr = Split(lst,",")
  
  For each attrname In arr
    Progress.Text = "Настройка системных атрибутов: " & attrname
    Select Case attrname
      Case "ATTR_AGREENENT_SETTINGS"
        Call Set_ATTR_AGREENENT_SETTINGS()
    End Select
  Next
End Sub

Sub Log(txt)
  'msgbox txt
End Sub


' Удаление форм по списку
Sub DeleteForms()
Progress.Text = "Удаление форм:"
  list = "FORM_TENDER_MEMBER_LIST,FORM_TENDER_INF_LIST_CLIENTS,FORM_TENDER_OUTSIDE_PUBLIC," &_
  "FORM_TENDER_RESP,FORM_TENDER_OUTSIDE_MAIN1,FORM_TENDER_INFO_CARD,FORM_TENDER_INSIDE_MAIN_," &_
  "FORM_TENDER_OUT,FORM_TENDER_INSIDE,FORM_TENDER_DOCUMENTATION,FORM_40791867_8ABB_4A7F_921E_B918898C57EA," &_
  "FORM_TASK_JOURNAL,FORM_9D39BC82_CFB8_4D46_82F8_4DC3B5A64E6A,FORM_P_TASK_LINKED_TASKS,FORM_KEUWORDS," &_
  "FORM_DOCUMENT_REFFERENCES,FORM_COMMENT_PROPERTIES,FORM_CONTRACT_COMPL_REPORT_INVOICE,FORM_WORK_DOCS_FOR_SPECIALTY," &_
  "FORM_AE304658_63FD_4763_9515_026D7C869B72"
  
Call SystemObjDelByList(List)
End Sub

Sub DeleteAttrs()
  Progress.Text = "Обновление атрибутов"

  List = "ATTR_E8B2E9BF_9970_4638_9FDE_189C25ACDA71,ATTR_P_PLAN_CODE," &_
         "ATTR_COMPLEX_CODE,ATTR_COMPLEX_TYPE,ATTR_SECTION_NAME," &_
         "ATTR_STAMP_POS_10_4,ATTR_P_PLAN_DATE_START,ATTR_P_PLAN_DATE_END"
Call SystemObjDelByList(List)
End Sub

Sub DeleteStatuses()
  Progress.Text = "Обновляются статусы"
    List = "STATUS_INVOICE_APPROVED,STATUS_INVOICE_IS_APPROVING"
Call SystemObjDelByList(List)
End Sub

Sub DeleteProfiles()
Progress.Text = "Обновляются профили"
List = "PROFILE_GROUP_ISSUE"
Call SystemObjDelByList(List)
End Sub

Sub UpdateProfiles()
Progress.Text = "Обновляются профили"

For each prof In ThisApplication.Profiles

  Select Case prof.Sysname
    Case "PROFILE_SYSADMIN"
      List = "CMD_CHANGE_DOC_ICONS,CMD_DOCUMENT_CREATE,CMD_SEARCH_DOCUMENTS,CMD_SEARCH_COMPLECT,CMD_CREATE_PROJECT,CMD_SECTION_CREATE,CMD_PROJECT_EXPORT,"
    Case "PROFILE_ARH"
      List = "CMD_DOCUMENT_CREATE,CMD_SECTION_CREATE"
    Case "PROFILE_COMPL"
      List = "CMD_DOCUMENT_CREATE,CMD_SECTION_CREATE"
    Case "PROFILE_NK"
      List = "CMD_DOCUMENT_CREATE,CMD_SECTION_CREATE"
    Case "PROFILE_P_PLANING"
      List = "CMD_DOCUMENT_CREATE,CMD_SECTION_CREATE,CMD_SEARCH_DOCUMENTS,CMD_SEARCH_COMPLECT"
    Case "PROFILE_ARM_DEVELOPERS"
      List = "CMD_KD_CREATE_DOC,CMD_SECTION_CREATE,CMD_SEARCH_DOCUMENTS,CMD_SEARCH_COMPLECT"
    Case "PROFILE_TENDER"
      List = "CMD_PURCHASE_CREATE"
  End Select
  
  arr = Split(List,",")
Next
End Sub

Sub DeleteComm()
Progress.Text = "Обновляются команды"
List = "CMD_EDIT,CMD_TASK_SEND_TO_APPROVE,CMD_BOOK_G_CHECK,CMD_BOD_DOC_FIX,CMD_TENDER_INSIDE_NEW"
Call SystemObjDelByList(List)
End Sub


Sub DeleteQUERY()
List = "QUERY_DESCTOP_4TYPES_ONSIGN,QUERY_ACCEPT,QUERY_DOC_MY,QUERY_AB356CC3_840F_458C_AFA3_9207AB35538E,QUERY_ACCB9CB3_9090_45B9_B375_2073A3067AB8," &_
        "QUERY_F69C8F32_2DC0_4666_ACFE_8C1C73A3B12A,QUERY_AA530508_C315_4335_AB72_0C40549478E4,QUERY_30B96AD0_586B_446D_BB7D_80E02E7E57A4," &_
        "QUERY_C8B28A60_6A7A_4054_98E3_DCD40C0E4701,QUERY_2CD68326_26A2_4FFB_8B69_3FCAD6307EFE,QUERY_17740DD6_D562_45B8_BDA6_43ECD92F39E1," &_
        "QUERY_DESCTOP_CONTRACTS_ACCEPTED,QUERY_DESCTOP_CONTRACTS_MY,QUERY_3C4A70FE_8D34_44A3_B17A_47CE301C02A5,QUERY_4FA769B9_6678_46DF_AC65_EEF9B201D3C1," &_
        "QUERY_9543A3D4_89CD_4B26_9FC3_84516CDAAD59,QUERY_DESCTOP_DEVELOP_TASKS,QUERY_DESCTOP_DEVELOP_TASKS_MY_DEVELOP,QUERY_DESCTOP_AGREEMENT_ONSIGN," &_
        "QUERY_E3F37559_7F60_453C_ADD8_7922F0A08B8F,QUERY_145DBA01_7D60_487C_8EFB_AB896B6847B5,QUERY_1B2257B0_EC1B_49D7_88FD_5F5FC839DC92"
Call SystemObjDelByList(List)
End Sub

Sub DeleteRoles()
Progress.Text = "Настройка ролей"
  List = ","
Call SystemObjDelByList(List)
End Sub

Sub MoveTechObjects1()
ThisScript.SysAdminModeOn

  'Перемещение объектов в техническую папку
  List = "OBJECT_DOC_DEV,OBJECT_DOCUMENT,OBJECT_DOCUMENT_AN,OBJECT_DRAWING,OBJECT_PURCHASE_DOC," &_
         "OBJECT_T_TASK,OBJECT_TENDER_INSIDE,OBJECT_PURCHASE_OUTSIDE"
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
  
  Set nkObj = ThisApplication.GetObjectByGUID("{498B43BA-F927-46C8-9CB7-D6C6F1913956}")
  
  If Not nkObj  Is Nothing Then
    Set p = nkObj.Parent
    If p Is Nothing Then
        root.Objects.Add nkObj
      ElseIf p.Handle <> root.Handle Then
        root.Objects.Add nkObj
      End If
  End If
  
  ' техническая папка договорной документации
  For each oFol In ThisApplication.ObjectDefs("OBJECT_KD_FOLDER").Objects
    If oFol.guid = "{56287434-D630-4F7D-8144-D5248A6FEC88}" Then
      Set cRoot = ThisApplication.GetObjectByGUID("{F9CEC7A4-5F45-4780-9690-5C28FD7E496A}")
      Set p = oFol.parent
      If Not p Is Nothing Then
        If oFol.Parent.handle <> croot.Handle Then
          cRoot.Objects.Add oFol
        End If
        oFol.Attributes("ATTR_FOLDER_NAME") = "Техническая папка"
        Exit For
      Else
        cRoot.Objects.Add oFol
        oFol.Attributes("ATTR_FOLDER_NAME") = "Техническая папка"
      End If
    End If
  Next
  
   'Перемещение объектов договорной документации в техническую папку
  List = "OBJECT_AGREEMENT,OBJECT_CONTRACT,OBJECT_CONTRACT_COMPL_REPORT"
  
  For each obj in ThisApplication.ObjectDefs("OBJECT_SYSTEM_ID").Objects
    Set root = ThisApplication.GetObjectByGUID("{56287434-D630-4F7D-8144-D5248A6FEC88}")
    If InStr(List,obj.attributes("ATTR_KD_OBJECT_TYPE")) <> 0 Then
      If Obj.Parent.Handle <> root.Handle Then
        Obj.Parent.Objects.Remove Obj
        root.Objects.Add Obj
      End If
    End If
  Next
End Sub

Sub MoveTechObjects2()
ThisScript.SysAdminModeOn

  'Перемещение папки Договорная документация в корень
  Set Obj = ThisApplication.GetObjectByGUID("{F9CEC7A4-5F45-4780-9690-5C28FD7E496A}")
  Set p = Obj.Parent
  If Not p Is Nothing Then
    p.Objects.Remove Obj
    ThisApplication.Root.Objects.Add Obj
  End If
 
  Set odef = ThisApplication.ObjectDefs("OBJECT_KD_FOLDER")
  If oDef.ObjectDefs.Has("OBJECT_CONTRACTS") = False Then
   oDef.ObjectDefs.Add ThisApplication.ObjectDefs("OBJECT_CONTRACTS")
  End If
  If oDef.ObjectDefs.Has("OBJECT_PROJECTS") = False Then
   oDef.ObjectDefs.Add ThisApplication.ObjectDefs("OBJECT_PROJECTS")
  End If
 
 '=============== Перенос папки Договоры
  Set cFolder = ThisApplication.GetObjectByGUID("{519D5F9D-D680-4642-BAEE-573455D6778E}")
  Set newRoot = ThisApplication.GetObjectByGUID("{F9CEC7A4-5F45-4780-9690-5C28FD7E496A}")
  Set p = cFolder.Parent
  needToMove = False
  If Not p Is Nothing Then
    If p.Handle <> newRoot.Handle Then
      needToMove = true
    End If
  Else
    needToMove = true  
  End If
  
  If needToMove = true  Then
    Set oldRoot = ThisApplication.Root
    Oldroot.Permissions = sysadminpermissions
    Set Dt = ThisApplication.Desktop
    dt.Objects.Add cfolder
    On error resume next
    cfolder.Erase
    if err.Number<> 0 then err.Clear
    
    oldRoot.Objects.Remove cFolder
    oldRoot.Objects.Update
  End If

' '=============== Перенос папки Поекты
  Set cFolder = ThisApplication.GetObjectByGUID("{3D19C1E4-9884-4A0B-A9AF-F898F1B5CFC0}")
  Set newRoot = ThisApplication.GetObjectByGUID("{BE8B16DD-8CD1-4625-B8D4-BFC5B4341497}")
  Set p = cFolder.Parent
  needToMove = False
  If Not p Is Nothing Then
    If p.Handle <> newRoot.Handle Then
      needToMove = true
    End If
  Else
    needToMove = true  
  End If

  If needToMove = true  Then
    Set oldRoot = ThisApplication.Root
    Oldroot.Permissions = sysadminpermissions
    Set Dt = ThisApplication.Desktop
    dt.Objects.Add cfolder
    On error resume next
    cfolder.Erase
    if err.Number<> 0 then err.Clear
    
    oldRoot.Objects.Remove cFolder
    oldRoot.Objects.Update
  End If
End Sub

sub MoveContractFolder()
  Set cFolder = ThisApplication.GetObjectByGUID("{519D5F9D-D680-4642-BAEE-573455D6778E}")
  Set newRoot = ThisApplication.GetObjectByGUID("{F9CEC7A4-5F45-4780-9690-5C28FD7E496A}")
  newRoot.Permissions = sysadminpermissions
  
  newRoot.Objects.Add cFolder
  Newroot.Objects.Move cFolder,0
  Newroot.Objects.Update
End Sub
sub MoveProjectFolder()
  Set cFolder = ThisApplication.GetObjectByGUID("{3D19C1E4-9884-4A0B-A9AF-F898F1B5CFC0}")
  Set newRoot = ThisApplication.GetObjectByGUID("{BE8B16DD-8CD1-4625-B8D4-BFC5B4341497}")
  newRoot.Permissions = sysadminpermissions
  
  newRoot.Objects.Add cFolder
  Newroot.Objects.Move cFolder,0
  Newroot.Objects.Update
  Set groot = ThisApplication.Root
  groot.Objects.Move newroot,3
  groot.Objects.Update
End Sub
Sub MoveObjects()
  Progress.Text = "Перемещаю объекты"
  List = "OBJECT_NK"
  arr = Split(List,",")
  For each attr in arr
    Call MoveObject(attr)
  Next 
End Sub

Sub MoveObject(attr)
  If Not ThisApplication.Attributes.Has("ATTR_FOLDER_" & attr) Then Exit Sub
  Guid = ThisApplication.Attributes("ATTR_FOLDER_" & attr).Value
  If Guid <> "" Then
    Set Folder = ThisApplication.GetObjectByGUID(Guid)
    If not Folder is Nothing Then
      If Folder.Objects.Has("2017") Then
        Set p = Folder.Objects("2017")
      Else
        Set p = Folder.Objects.Create("OBJECT_KD_FOLDER")
        p.Attributes("ATTR_FOLDER_NAME") = "2017"
      End If
        For Each Obj in ThisApplication.ObjectDefs(attr).Objects
          If p.Objects.Has(Obj.Handle) = False Then
            'Obj.Parent.Objects.Remove Obj
            p.Objects.Add Obj
            Count = Count + 1
          End If
        Next
    End If
  End If
End Sub


Sub Set_ATTR_KD_FILE_FORMS()

  If ThisApplication.Attributes.Has("ATTR_KD_FILE_FORMS") = False Then Exit Sub
  List = "FORM_CONTRACT_COMPL_REPORT;FORM_CONTRACT;FORM_AGREEMENT;FORM_S_TASK;FORM_DRAWING;FORM_DOC_DEV;FORM_DOCUMENT_PROPERTIES;FORM_PURCHASE_DOC;"
  arr = Split(List,";")
  List1 = ThisApplication.Attributes("ATTR_KD_FILE_FORMS").Value
  val = List1
  arr1 = Split(List1,";")
  For each f In arr
    For each f1 In arr1
      If f=f1 Then
        check = false
        Exit For
      Else
        check = true
      End If
    Next
    If check Then val = val & ";" & f & ";"
  Next
  
  val = Replace(val, ";;", ";", 1, -1, vbTextCompare)  
  ThisApplication.Attributes("ATTR_KD_FILE_FORMS").Value = val
End Sub


Sub Misc()
  ThisScript.SysAdminModeOn
  Set Obj = ThisApplication.GetObjectByGUID("{5E5F341C-2533-41F6-BA0F-67FAF959E9D5}")

  If Obj Is Nothing Then Exit Sub

  Set root = ThisApplication.GetObjectByGUID("{E6B689C1-18CC-4835-8597-D3025419D039}")

  If root.Objects.Has(Obj) = False Then
    root.objects.add Obj
  End If
End Sub

Sub RemoveStatusFromCommand(command,Stat)
  Set comm = ThisApplication.Commands(command)
  If Not comm Is Nothing Then
    If comm.Statuses.Has(Stat) Then
      comm.Statuses.Remove ThisApplication.Statuses(Stat)
    End If
  End If
End Sub

' Синхронизирует состав типа объекта со списком
' pObjDef - объект-родитель
' List - Список типов объектов состава
Sub SyncObjContentByList(pObjDef,List)
  If ThisApplication.ObjectDefs.Has(pObjDef) Then
    Set oDefParent = ThisApplication.ObjectDefs(pObjDef)
  End If
  arr = Split(List, ",")
 
  For Each oDef In oDefParent.ObjectDefs
    check = False
    For i=0 to Ubound(arr)
      If ThisApplication.ObjectDefs.Has(arr(i)) Then
        If oDef.SysName = arr(i) Then 
          check = check or True
        End If
      End If
    Next
    If check = False Then
      oDefParent.ObjectDefs.Remove oDef
    End If
  Next
  
  ' Добавляем тип объекта в состав если его нет
  For i=0 to Ubound(arr)
    If oDefParent.ObjectDefs.Has(arr(i)) = False Then
      If ThisApplication.ObjectDefs.Has(arr(i)) Then
        oDefParent.ObjectDefs.add ThisApplication.ObjectDefs(arr(i))
      End If
    End If
  Next
End Sub

Sub Set_ATTR_STRU_OBJ_SETTINGS()
  List =  "ID_CONTRACT_CREATE,Отдел по договорной работе и закупочным процедурам,Подготовка договоров," &_
  "ID_TENDER_CREATE,Группа подготовки и проведения закупочных процедур,Подготовка закупок"
  Set Table = ThisApplication.Attributes("ATTR_STRU_OBJ_SETTINGS")
  
  arr = Split(List, ",")
  For i=0 To Ubound(arr) Step 3
    For each row in Table.Rows
      If row.attributes("ATTR_ID").value = arr(i) Then
        check = true
        Exit For
      Else
        check = false
      End If
    Next
      If check = False Then
        set r = Table.Rows.Create
        Set os = ThisApplication.ObjectDefs("OBJECT_STRU_OBJ").Objects
        For Each o in os
          If o.Attributes("ATTR_NAME").value = arr(i+1) Then
            exit for
          End If
        Next
        r.Attributes("ATTR_ID").value = arr(i)
        r.Attributes("ATTR_DEPT").Object = o
        r.Attributes("ATTR_INF").value = arr(i+2)
      End If
  Next
End SUb

' Синхронизация атрибутов объектов
Sub ObjAttrsSync()
  Progress.Text = "Обновление атрибутов объекта:"
  List =  "OBJECT_T_TASK," &_
          "OBJECT_DOC," &_
          "OBJECT_TENDER_INSIDE," &_
          "OBJECT_PURCHASE_DOC," &_
          "OBJECT_PROJECT_SECTION," &_
          "OBJECT_PROJECT_SECTION_SUBSECTION," &_
          "OBJECT_VOLUME," &_
          "OBJECT_DOCUMENT_AN," &_
          "OBJECT_DRAWING," &_
          "OBJECT_DOC_DEV," &_
          "OBJECT_PROJECT," &_
          "OBJECT_CORRESPONDENT," &_
          "OBJECT_PURCHASE_FOLDER," &_
          "OBJECT_PURCHASE_OUTSIDE," &_
          "OBJECT_WORK_DOCS_SET"
          
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

  ' Удаление атрибутов из системы
Sub DelAttr(ObjsName)
     If ThisApplication.AttributeDefs.Has(ObjsName) = True Then 
      Set Attr = ThisApplication.AttributeDefs(ObjsName)
      Attr.Erase
      If ThisApplication.AttributeDefs.Has(ObjsName) = False Then
        str0 = str0 & chr(10) & "Из системы удален тип атрибута """ & Descr & """"
      End If
    End If
End Sub

Function CopyAttrsList(ObjSysName)
    Select Case ObjSysName
      Case "OBJECT_VOLUME"
        CopyAttrsList = "" &_
                        "OBJECT_VOLUME,ATTR_VOLUME_SECTION," &_
                        "OBJECT_VOLUME,ATTR_VOLUME_NUM," &_
                        "OBJECT_VOLUME,ATTR_VOLUME_NAME," &_
                        "OBJECT_VOLUME,ATTR_CONTRACT_STAGE," &_
                        "OBJECT_VOLUME,ATTR_VOLUME_PART_NAME," &_
                        "OBJECT_VOLUME,ATTR_VOLUME_PART_NUM," &_
                        "OBJECT_VOLUME,ATTR_BOOK_NUM," &_
                        "OBJECT_VOLUME,ATTR_BOOK_NAME," &_
                        "OBJECT_VOLUME,ATTR_VOLUME_CODE," &_
                        "OBJECT_VOLUME,ATTR_PROJECT," &_
                        "OBJECT_VOLUME,ATTR_RESPONSIBLE," &_
                        "OBJECT_VOLUME,ATTR_CONTRACT_SUBCONTRACTOR," &_
                        "OBJECT_VOLUME,ATTR_SUBCONTRACTOR_CLS," &_
                        "OBJECT_VOLUME,ATTR_SUBCONTRACTOR_DOC_NAME," &_
                        "OBJECT_VOLUME,ATTR_SUBCONTRACTOR_WORK," &_
                        "OBJECT_VOLUME,ATTR_SUBCONTRACTOR_DOC_INF"
      Case "OBJECT_PURCHASE_DOC"
        CopyAttrsList = "" &_
        "OBJECT_PURCHASE_DOC,ATTR_PURCHASE_DOC_TYPE," &_
        "OBJECT_PURCHASE_DOC,ATTR_DOCUMENT_NAME," &_
        "OBJECT_PURCHASE_DOC,ATTR_RESPONSIBLE," &_
        "OBJECT_PURCHASE_DOC,ATTR_T_TASK_DEPARTMENT," &_
        "OBJECT_PURCHASE_DOC,ATTR_TENDER_INVITATION_COUNT_EIS," &_
        "OBJECT_PURCHASE_DOC,ATTR_TENDER_DOC_TO_PUBLISH"
      Case "OBJECT_DOCUMENT"
        CopyAttrsList = "" &_
        "OBJECT_DOCUMENT,ATTR_DOCUMENT_TYPE," &_
        "OBJECT_DOCUMENT,ATTR_DOCUMENT_NAME," &_
        "OBJECT_DOCUMENT,ATTR_PROJECT," &_
        "OBJECT_DOCUMENT,ATTR_AUTOR," &_
        "OBJECT_DOCUMENT,ATTR_RESPONSIBLE," &_
        "OBJECT_DOCUMENT,ATTR_CHECKER," &_
        "OBJECT_DOCUMENT,ATTR_DOCUMENT_CONF"
      Case "OBJECT_DOCUMENT_AN"
        CopyAttrsList = "" &_
        "OBJECT_DOCUMENT_AN,ATTR_DOCUMENT_AN_TYPE," &_
        "OBJECT_DOCUMENT_AN,ATTR_REPORT_AN_TYPE," &_
        "OBJECT_DOCUMENT_AN,ATTR_DOCUMENT_NAME," &_
        "OBJECT_DOCUMENT_AN,ATTR_PROJECT," &_
        "OBJECT_DOCUMENT_AN,ATTR_AUTOR," &_
        "OBJECT_DOCUMENT_AN,ATTR_RESPONSIBLE," &_
        "OBJECT_DOCUMENT_AN,ATTR_CHECKER," &_
        "OBJECT_DOCUMENT_AN,ATTR_DOCUMENT_CONF"
      Case Else
        CopyAttrsList = "OBJECT_T_TASK,ATTR_T_TASK_TDEPTS_TBL," &_
        "OBJECT_T_TASK,ATTR_RESPONSIBLE," &_
        "OBJECT_T_TASK,ATTR_DOCUMENT_CONF," &_
        "OBJECT_T_TASK,ATTR_T_TASK_CHECKED," &_
        "OBJECT_T_TASK,ATTR_T_TASK_DEVELOPED," &_
        "OBJECT_T_TASK,ATTR_SIGNER," &_
        "OBJECT_T_TASK,ATTR_T_TASK_CONTENT," &_
        "OBJECT_T_TASK,ATTR_NAME_SHORT," &_
        "OBJECT_T_TASK,ATTR_T_TASK_SET," &_
        "OBJECT_T_TASK,ATTR_T_TASK_PPLINKED," &_
        "OBJECT_T_TASK,ATTR_CONTRACT_STAGE," &_
        "OBJECT_T_TASK,ATTR_UNIT," &_
        "OBJECT_T_TASK,ATTR_T_TASK_DEPARTMENT," &_
        "OBJECT_DOC_DEV,ATTR_CHECK_LIST," &_
        "OBJECT_DOC_DEV,ATTR_DOCUMENT_NAME," &_
        "OBJECT_DOC_DEV,ATTR_PROJECT," &_
        "OBJECT_DRAWING,ATTR_CHECK_LIST," &_
        "OBJECT_DRAWING,ATTR_DOCUMENT_NAME," &_
        "OBJECT_DRAWING,ATTR_PROJECT," &_
        "OBJECT_CONTRACT_COMPL_REPORT,ATTR_CONTRACT," &_
        "OBJECT_CONTRACT_COMPL_REPORT,ATTR_AUTOR," &_
        "OBJECT_CONTRACT_COMPL_REPORT,ATTR_TINVOICES," &_
        "OBJECT_CONTRACT_COMPL_REPORT,ATTR_CCR_INCOMING," &_
        "OBJECT_CONTRACT_COMPL_REPORT,ATTR_SIGNER," &_
        "OBJECT_CONTRACT_COMPL_REPORT,ATTR_USER_CHECKED," &_
        "OBJECT_CONTRACT,ATTR_CONTRACT_CLASS," &_
        "OBJECT_CONTRACT,ATTR_CONTRACT_TYPE," &_
        "OBJECT_CONTRACT,ATTR_CUSTOMER," &_
        "OBJECT_CONTRACT,ATTR_CONTRACTOR," &_
        "OBJECT_CONTRACT,ATTR_CONTRACT_SUBJECT," &_
        "OBJECT_CONTRACT,ATTR_DUE_DATE," &_
        "OBJECT_CONTRACT,ATTR_DAY_TYPE," &_
        "OBJECT_AGREEMENT,ATTR_AGREEMENT_TYPE," &_
        "OBJECT_AGREEMENT,ATTR_CONTRACT_SUBJECT," &_
        "OBJECT_AGREEMENT,ATTR_CONTRACTOR," &_
        "OBJECT_AGREEMENT,ATTR_CONTRACT"
    End Select
End Function


Sub Set_ATTR_KD_COPY_ATTRS(ObjSysName)
  List =  CopyAttrsList(ObjSysName)
  Set Table = ThisApplication.Attributes("ATTR_KD_COPY_ATTRS")
  
  arr = Split(List, ",")
  For i=0 To Ubound(arr) Step 2
    For each row in Table.Rows
      If row.attributes("ATTR_KD_OBJ_TYPE").value = arr(i) And row.attributes("ATTR_KD_ATTR").value = arr(i+1) Then
        check = true
        Exit For
      Else
        check = false
      End If
    Next
      If check = False Then
        set r = Table.Rows.Create
        Progress.Text = "Настройка системных атрибутов: " & ObjSysName
        r.Attributes("ATTR_KD_OBJ_TYPE").value = arr(i)
        r.Attributes("ATTR_KD_ATTR").value = arr(i+1)
      End If
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

Sub changeFDefs()
  ObjList = "OBJECT_DOC,OBJECT_DOCUMENT,OBJECT_DRAWING,OBJECT_LIST_AN,OBJECT_DOC_DEV,OBJECT_PURCHASE_DOC,OBJECT_DOCUMENT_AN," &_
            "OBJECT_CONTRACT_COMPL_REPORT,OBJECT_CONTRACT,OBJECT_AGREEMENT," &_
            "OBJECT_WORK_DOCS_SET,OBJECT_VOLUME,OBJECT_INVOICE,OBJECT_T_TASK"
  Arr = Split(ObjList,",")
  
  
  For each oDef In Arr
   Set oCol = ThisApplication.ObjectDefs(oDef).Objects
    For each Obj In oCol
      For each file in Obj.Files
        If file.FileDefName = "FILE_CONTRACT_THE_ORIGINAL" Then
          file.FileDef = ThisApplication.FileDefs("FILE_E-THE_ORIGINAL")
        End If
      Next
    Next
  Next
End Sub

Sub RemoveFromObjDef()
  Progress.Text = "Обновляются связи объекта:"
  ObjList = "OBJECT_DOC,OBJECT_DOCUMENT,OBJECT_DRAWING,OBJECT_LIST_AN,OBJECT_DOC_DEV,OBJECT_PURCHASE_DOC,OBJECT_DOCUMENT_AN," &_
            "OBJECT_CONTRACT_COMPL_REPORT,OBJECT_CONTRACT,OBJECT_AGREEMENT," &_
            "OBJECT_WORK_DOCS_SET,OBJECT_VOLUME,OBJECT_INVOICE,OBJECT_T_TASK"
  ObjArr = Split(ObjList,",")
  
  For Each ObjDefName In ObjArr
    Progress.Text = "Обновляются связи объектов: " & ObjDefName
    Select Case ObjDefName
      Case "OBJECT_VOLUME"
        List = "FILE_CONTRACT_THE_ORIGINAL"
      Case "OBJECT_DOCUMENT"
        List = "FILE_CONTRACT"
      Case "OBJECT_CONTRACT_COMPL_REPORT","OBJECT_CONTRACT","OBJECT_AGREEMENT"
        List = "FILE_CONTRACT_THE_ORIGINAL"
      Case "OBJECT_PURCHASE_DOC"
        List = "FILE_KD_EL_SCAN_DOC"
      Case "OBJECT_WORK_DOCS_SET"
        List = "FILE_CONTRACT_THE_ORIGINAL"
    End Select
  
    arr = Split(List,",")
    For Each ObjSysName In arr
      call SystemObjRemoveFromObject(str0,ObjDefName,ObjSysName)
    Next
  Next
End Sub

Sub AttrProcessing(ObjSysName)
  If ThisApplication.AttributeDefs.Has(ObjSysName) Then
    Set Attr = ThisApplication.AttributeDefs(ObjSysName)
    Descr = Attr.Description
    For Each ObjDef in ThisApplication.ObjectDefs
      If ObjDef.AttributeDefs.Has(Attr) Then
        ObjDef.AttributeDefs.Remove Attr
        Progress.Text = "Удаление атрибутов из типов объектов: " & Descr & ": " & ObjDef.Description
        str0 = str0 & chr(10) & "Из типа объекта объекта """ & ObjDef.Description & """ удален атрибут """ & Descr & """"
      End If
    Next
  End If    
End Sub

Sub SystemObjRemoveFromObject(str0,ObjDefName,ObjSysName)
  Progress.Text = "Обновляются связи объекта: " & ObjDefName
  on Error Resume Next
  ' атрибуты
  Set ObjDef = ThisApplication.ObjectDefs(ObjDefName)
  If ObjDef Is Nothing Then Exit Sub
  If ThisApplication.AttributeDefs.Has(ObjSysName) Then
    If ObjDef.AttributeDefs.Has(ObjSysName) Then
      Set Attr = ThisApplication.AttributeDefs(ObjSysName)
      Descr = Attr.Description
      ObjDef.AttributeDefs.Remove Attr
      ' атрибуты, которые нужно оставить, но без установок по умолчанию, после удаления добавляем опять
      If ObjSysName = "ATTR_CONTRACT_TYPE" or ObjSysName = "ATTR_TENDER_STATUS_EIS" Then 
        ObjDef.AttributeDefs.Add Attr
      Else
        If ObjDef.AttributeDefs.Has(ObjSysName) = False Then
          str0 = str0 & chr(10) & "Из типа объекта """ & ObjDef.Description & """ удален атрибут """ & Descr & """"
        End If
      End If
    End If
   ElseIf ThisApplication.InputForms.Has(ObjSysName) Then
      If ObjDef.InputForms.Has(ObjSysName) Then
        Set Form = ThisApplication.InputForms(ObjSysName)
        Descr = Form.Description
        ObjDef.InputForms.Remove Form
          If ObjDef.InputForms.Has(ObjSysName) = False Then
            str0 = str0 & chr(10) & "Из типа объекта """ & ObjDef.Description & """ удалена форма ввода """ & Descr & """"
          End If
      End If
    ElseIf ThisApplication.ObjectDefs.Has(ObjSysName) Then
      If ObjDef.ObjectDefs.Has(ObjSysName) Then
        Set Form = ThisApplication.ObjectDefs(ObjSysName)
        Descr = Form.Description
        ObjDef.ObjectDefs.Remove Form
          If ObjDef.ObjectDefs.Has(ObjSysName) = False Then
            str0 = str0 & chr(10) & "Из типа объекта """ & ObjDef.Description & """ удален тип объекта """ & Descr & """"
          End If
      End If
    ElseIf ThisApplication.Statuses.Has(ObjSysName) Then
      Set stat = ThisApplication.Statuses(ObjSysName)
      Descr = stat.Description
      If ObjDef.Statuses.Has(stat) Then
        ObjDef.Statuses.Remove stat
        str0 = str0 & chr(10) & "Из типа объекта """ & ObjDef.Description & """ удален статус """ & Descr & """"
      End If
    ElseIf ThisApplication.FileDefs.Has(ObjSysName) Then
      Set fDef = ThisApplication.FileDefs(ObjSysName)
      Descr = fDef.Description
      If ObjDef.FileDefs.Has(fDef) Then
        ObjDef.FileDefs.Remove fDef
        str0 = str0 & chr(10) & "Из типа объекта """ & ObjDef.Description & """ удален статус """ & Descr & """"
      End If
    ElseIf ThisApplication.Commands.Has(ObjSysName) Then
      Set comm = ThisApplication.Commands(ObjSysName)
      Descr = comm.Description
      If ObjDef.Commands.Has(comm) Then
          ObjDef.Commands.Remove comm
          str0 = str0 & chr(10) & "Из типа объекта """ & ObjDef.Description & """ удалена команда """ & Descr & """"
      End If
    End If
  On Error GoTo 0
End Sub

Sub Groups()
  Progress.Text = "Обновление групп"
  For Each group in ThisApplication.Groups
      Select Case group.SysName
        Case "GROUP_COMPL" group.Description = "Комплектация и выпуск"
        Case "GROUP_LEAD_GROUP" group.Description = "Руководители групп"
        Case "GROUP_LEAD_DEPT" group.Description = "Руководители отделов"
        Case "GROUP_CONTRACTS" group.Description = "Управление договорной документацией"
        Case "GROUP_TENDER" group.Description = "Управление тендерной документацией"
        Case "GROUP_PLAN" group.Description = "Группа планирования"
      End Select
  Next
  
  List = "GROUP_CCR,Управление актами,GROUP_CCR_SIGNERS,Подписанты Актов,GROUP_ECONOMISTS,Экономисты"
  arr = Split(List,",")
  
  For i = 0 to Ubound(arr)-1 Step 2
    If ThisApplication.Groups.Has(arr(i)) = False Then
      Set gr = ThisApplication.Groups.Create
      gr.SysName = arr(i)
      gr.Description = arr(i+1)
      Progress.Text = "Добавляются группы: " & gr.Description & " (" & gr.SysName & ")"
      
      Select Case gr.SysName
        Case "GROUP_CCR"
          gr.Users.Add ThisApplication.Users("Заборовский Андрей Валерьевич")
        Case "GROUP_CCR_SIGNERS"
          gr.Users.Add ThisApplication.Users("Сенютин Александр Анатольевич")
          gr.Users.Add ThisApplication.Users("Карпов Алексей Михайлович")
      End Select
    End If
  Next
  
      ' Добавляем роль ROLE_CCR_CREATE на договоры
    For Each Obj In ThisApplication.ObjectDefs("OBJECT_CONTRACT").Objects
      If Obj.StatusName = "STATUS_CONTRACT_COMPLETION" Or Obj.StatusName = "STATUS_CONTRACT_PAUSED" Then
        Set rd = ThisApplication.RoleDefs("ROLE_CCR_CREATE")
        If Obj.Roles.Has(rd) = False Then
          Set gr = ThisApplication.Groups("GROUP_CCR")
          Set role = Obj.Roles.Create("ROLE_CCR_CREATE",gr)
        End If
      End if
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
    If Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ЗАДАНИЯ" Then
      ARM = "TASK"
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "УПРАВЛЕНИЕ ДОГОВОРАМИ" Then
      ARM = "CONTRACT"
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ЗАКУПКИ" Then
      ARM = "TENDER"
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "АРМ ГИПа" Then
      ARM = "GIP"
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ДОКУМЕНТЫ" Then
      ARM = "USER"
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "НОРМОКОНТРОЛЬ" Then
      ARM = "NK"
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ВЫПУСК ДОКУМЕНТАЦИИ" OR Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "АРМ Комплектация документации" Then
      Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ВЫПУСК ДОКУМЕНТАЦИИ"
      ARM = "ISSUE"
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "РУКОВОДИТЕЛЬ ОТДЕЛА" Then
      ARM = "RUK"
    End If
    
    List = ""
    ListToRem = ""
        
    Select Case ARM
    Case "NK"
      Progress.Text = "Обновление выборок рабочего стола: " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_FOR_N,QUERY_ON_NK,QUERY_FAVORIT1,QUERY_ON_CONTOL1"
      Call AddQuery(Obj,List,ListToRem)
    Case "TASK"
      Progress.Text = "Обновление выборок рабочего стола: " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_DESCTOP_IN_TASKS,QUERY_DESCTOP_OUT_TASKS,QUERY_DESCTOP_TASKS_ON_CHECK,QUERY_DESCTOP_TASKS_DEVELOP_MY," &_
      "QUERY_DESCTOP_TASKS_ON_CHECK,QUERY_DESCTOP_TASKS_ON_SIGN,QUERY_DESCTOP_CONFIRM_TASKS," &_
             "QUERY_DESCTOP_TASKS_ON_APPROVE,QUERY_TASK_FAVORIT,QUERY_TASK_ON_CONTOL"
      Call AddQuery(Obj,List,ListToRem)
    Case "CONTRACT"
      Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_DESCTOP_AGREEMENT_ACTIVE,QUERY_DESCTOP_CONTRACTS,QUERY_DESCTOP_CONTRACTS_BY_TYPE,QUERY_DESCTOP_CONTRACT_TO_DO," &_
      "QUERY_DESCTOP_CONTRACTS_DOCS_TO_AGREE,QUERY_DESCTOP_CONTRACTS_DOCS_ONSIGN,QUERY_CONTRACTS_FAVORIT,QUERY_CONTRACTS_ON_CONTOL"
      ListToRem = "QUERY_DESCTOP_CONTRACT_TO_DO,QUERY_DESCTOP_CONTRACTS_DOCS_TO_AGREE,QUERY_DESCTOP_CONTRACT_DOCS,QUERY_DESCTOP_CONTRACTS_DOCS_ONSIGN"
      Call AddQuery(Obj,List,ListToRem)
    Case "TENDER"
      Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_DESCTOP_TENDER_INSIDE,QUERY_DESCTOP_TENDER_OUTSIDE,QUERY_DESCTOP_TENDER_DOCS_TO_AGREE," &_
      "QUERY_TENDER_FAVORIT,QUERY_TENDER_ON_CONTOL"
      Call AddQuery(Obj,List,ListToRem)
    Case "GIP"
      Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_PROJECTS_EDIT,QUERY_FOR_APPROVE,QUERY_DESCTOP_READY_FOR_ISSUE," &_
      "QUERY_FAVORIT1,QUERY_ON_CONTOL1"
      Call AddQuery(Obj,List,ListToRem)
    Case "ISSUE"
      Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_INVOICE_DESCTOP,QUERY_DESCTOP_INVOICE_MY,QUERY_INVOICE_DOCS_ON_CHECK," &_
      "QUERY_INVOICE_DOCS_APPROVED,QUERY_DESCTOP_INVOICE_DOCS_READY_TO_ISSUE," &_
      "QUERY_FAVORIT1,QUERY_ON_CONTOL1"
      ListToRem = "QUERY_PROJECTS_EDIT"
      Call AddQuery(Obj,List,ListToRem)
    Case "USER"
      Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_DESCTOP_DOC_MY,QUERY_SESCTOP_DOC_DEVELOP_MY,QUERY_DESCTOP_VOLUMES_SETS_MY," &_
      "QUERY_DESCTOP_DOCS_TO_AGREE,QUERY_DESCTOP_DOCS_ONSIGN,QUERY_DESCTOP_DOCS_ONSIGN," &_
      "QUERY_FAVORIT1,QUERY_ON_CONTOL1"
      ListToRem = "QUERY_DOCS_MY_ON_CHECK"
      Call AddQuery(Obj,List,ListToRem)
    Case "RUK"
      Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_DESCTOP_VOLUMES_SETS_MY,QUERY_DESCTOP_DOCS_ONSIGN,QUERY_DESCTOP_DOCS_TO_AGREE," &_
      "QUERY_FAVORIT1,QUERY_ON_CONTOL1"
      Call AddQuery(Obj,List,ListToRem)
  End Select
Next  
 
  List = "QUERY_DESCTOP_VOLUMES_SETS_MY,QUERY_WORK_SETS_IS_DEVELOPING_MY,QUERY_DESCTOP_VOLUMES_SETS_MY_AGREED,QUERY_DESCTOP_VOLUMES_SETS_MY_NK"
  Call AddSubQuery(List)
  
  List = "QUERY_DESCTOP_CONTRACT_DOCS,QUERY_DESCTOP_CONTRACT_DOCS_MY,QUERY_DESCTOP_AGREEMENT_ACTIVE"
  Call AddSubQuery(List)
  
  List = "QUERY_DESCTOP_CONTRACTS,QUERY_DESCTOP_CONTRACTS_COMPLETION,QUERY_DESCTOP_CONTRACTS_ONCONTRACTOR,QUERY_DESCTOP_CONTRACTS_ONSIGN," &_
          "QUERY_DESCTOP_CONTRACTS_PAUSED,QUERY_DESCTOP_CONTRACTS_ONAGREEMENT"
  Call AddSubQuery(List)
  
  List = "QUERY_DESCTOP_CONTRACTS_BY_TYPE,QUERY_DESCTOP_CONTRACTS_BY_TYPE_PRO,QUERY_DESCTOP_CONTRACTS_BY_TYPE_EXP,QUERY_DESCTOP_CONTRACTS_BY_TYPE_GPH," &_
         "QUERY_DESCTOP_CONTRACTS_BY_TYPE_SALES,QUERY_DESCTOP_CONTRACTS_BY_TYPE_OU,QUERY_DESCTOP_CONTRACTS_BY_TYPE_OTHER" 
  Call AddSubQuery(List)
End Sub

Sub ObjDelete()
  ThisScript.SysAdminModeOn
  Set col = ThisApplication.ObjectDefs("OBJECT_PURCHASE_LOT").Objects
  Call  DelObjectsByCollection(col)
  Set col = ThisApplication.ObjectDefs("OBJECT_PURCHASE_DOC").Objects
  Call  DelObjectsByCollection(col)
  Set col = ThisApplication.ObjectDefs("OBJECT_PURCHASE_OUTSIDE").Objects
  Call  DelObjectsByCollection(col)
  Set col = ThisApplication.ObjectDefs("OBJECT_TENDER_INSIDE").Objects
  Call  DelObjectsByCollection(col)
End Sub

Sub DelObjectsByCollection(col)
  ThisScript.SysAdminModeOn
  List = "{FF6B87BA-B7D0-434B-A73E-B98E996A9C11},{E556BC1B-E5F3-40BF-866C-B16FAC7DFBB3},{C132E4F3-6D02-45E0-A523-C6F905AC65ED}," &_
  "{2A898E42-D892-4266-8C75-F23D8ED097B9},{D1B7B439-9E96-4444-8F9E-3B3551A7DD4C},{14526782-B8B3-4F8A-981C-47A468D93F69},{7E262BC9-4667-443D-9081-3B57F5413805}"
  For Each Obj In col
    If InStr(List,Obj.Guid) = 0 Then
        Progress.Text = "Удаление объектов: " & Obj.Description
        obj.erase
    Else
      Set root = Nothing
      If Obj.ObjectDefName = "OBJECT_PURCHASE_OUTSIDE" Then
        Set root = ThisApplication.GetObjectByGUID("{73A3A564-8D3C-4B32-8DE4-AC343A7413E1}")
      ElseIf Obj.ObjectDefName = "OBJECT_TENDER_INSIDE" Then
        Set root = ThisApplication.GetObjectByGUID("{C363D8E3-724B-4461-830A-3AC480AAEBA6}")
      End If
        If Not root Is Nothing Then
          Set p = Obj.Parent
          If Not p Is Nothing Then
            If p.handle<>root.Handle Then
              root.Objects.Add Obj
            End If
          Else
            root.Objects.Add Obj
          End If  
        End If
    End If
  Next
End Sub

Sub AddUnitFolderToProject()
  For each proj In ThisApplication.ObjectDefs("OBJECT_PROJECT").Objects
    Call AddUnitFolder(proj)
  Next
End Sub

Sub AddUnitFolder(Obj)
  aFolderName = "ATTR_FOLDER_NAME"
  aFolderSystem = "ATTR_SYSTEM_FOLDER"
 Select Case Obj.Attributes("ATTR_PROJECT_WORK_TYPE").Classifier.Sysname
    Case "NODE_WORK_TYPE_AUTH-SUPERVISION"

    Case "NODE_WORK_TYPE_PEMC"
      
    Case "NODE_WORK_TYPE_SUPERVISING"
      
    Case Else
      Set clsFolderType = ThisApplication.Classifiers.FindBySysId("NODE_FOLDER_PROJECT_WORK")
      check = true
      For each Obj1 In Obj.Objects
        If Obj1.Attributes.Has("ATTR_FOLDER_TYPE") Then
          If Obj1.ObjectDefName = "OBJECT_FOLDER" And Obj1.Attributes("ATTR_FOLDER_TYPE").Classifier.Handle = clsFolderType.Handle Then
            check = False
            Exit For
          End If
        End If
      Next
      If Check = True Then
        'Создание папки Структура объекта проектирования
        Set o = Obj.Objects.Create("OBJECT_FOLDER")
'        Set o = ThisApplication.ExecuteScript("CMD_S_DLL", "CreateObj", "OBJECT_FOLDER",Obj,False)
        If Not IsObject(o) then 
          Er=True
        Else
          ThisApplication.ExecuteScript "CMD_DLL", "SetAttr", o, aFolderName, "Структура объекта"
          ThisApplication.ExecuteScript "CMD_DLL", "SetAttr", o, aFolderSystem, True
          ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", o, "ATTR_FOLDER_TYPE", clsFolderType, True
        End If
      End If
  End Select
End Sub


Sub Set_ATTR_STAGE_SETTINGS()
  Set Table = ThisApplication.Attributes("ATTR_STAGE_SETTINGS")
  For each row In Table.Rows
    
    If row.attributes("ATTR_STAGE_STRUCTURE").Empty = True or row.attributes("ATTR_STAGE_STRUCTURE").classifier Is Nothing Then
      f1 = row.attributes("ATTR_PROJECT_STAGE").Classifier.Description
      Set clsf2 = row.attributes("ATTR_SITE_TYPE_CLS").Classifier
      If clsf2 Is Nothing Then
        f2 = ""
      Else
        f2 = clsf2.Description
      End If
      Set cls = Struct(f1,f2)
      If Not cls Is Nothing Then
        row.attributes("ATTR_STAGE_STRUCTURE").classifier = cls
      End If
    Else
    set ccl = row.attributes("ATTR_STAGE_STRUCTURE").classifier
    End If
  Next
End Sub

Function Struct(f1,f2)
Set Struct = Nothing
List = "Основные технические решения;Линейный объект;NODE_PROJECT_STRUCT8;" &_
"Основные технические решения;Объект непроизводственного назначения;NODE_PROJECT_STRUCT7;" &_
"Основные технические решения;Объект производственного назначения;NODE_PROJECT_STRUCT7;" &_
"Проектная документация;Линейный объект;NODE_PROJECT_STRUCT2;" &_
"Проектная документация;Объект производственного назначения;NODE_PROJECT_STRUCT1;" &_
"Проектная документация;Объект непроизводственного назначения;NODE_PROJECT_STRUCT1;" &_
"Проектная документация;Скважина. Суша. Строительство;NODE_PROJECT_STRUCT15;" &_
"Проектная документация;Скважина. Суша. Расконсервация, консервация(ликвидация);NODE_PROJECT_STRUCT14;" &_
"Проектная документация;Скважина. Море (Вариант 1);NODE_PROJECT_STRUCT5;" &_
"Проектная документация;Скважина. Море (Вариант 2);NODE_PROJECT_STRUCT6;" &_
"Сбор исходных данных;;NODE_PROJECT_STRUCT10;" &_
"Сбор исходных данных стадии П;;NODE_PROJECT_STRUCT11;" &_
"Сбор исходных данных стадии Р;;NODE_PROJECT_STRUCT12;" &_
"Технический проект;;;" &_
"Проекты карьеров ОПИ;;NODE_PROJECT_STRUCT13;" &_
"Комплекс кадастровых и иных работ на земельные участки на период строительства объектов;;NODE_PROJECT_STRUCT_CADASTR1;" &_
"Комплекс кадастровых и иных работ на земельные участки на период эксплуатации объектов;;NODE_PROJECT_STRUCT_CADASTR2;" &_
"Комплекс кадастровых и иных работ по изготовлению технических планов и постановке ОКС на государственный кадастровый учет;;NODE_PROJECT_STRUCT_CADASTR3"
  arr = Split(List,";")
  For i = 0 to ubound(arr) step 3
    If arr(i) = f1 And arr(i+1) = f2 Then
      f3 = arr(i+2)
      Exit For
    End If
  Next
  Set cls = ThisApplication.Classifiers.FindBySysId(f3)
  Set Struct = cls
End Function


'Процедура удаления системного элемента из системы
Sub FileTypeDel(str0,ObjSysName)
  on Error Resume Next
  If ThisApplication.FileDefs.Has(ObjSysName) Then
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
    Set stat = ThisApplication.Statuses(ObjSysName)
    Descr = stat.Description
    For Each ObjDef in ThisApplication.ObjectDefs
      If ObjDef.Statuses.Has(stat) Then
        ObjDef.Statuses.Remove stat
        str0 = str0 & chr(10) & "Из типа объекта """ & ObjDef.Description & """ удален статус """ & Descr & """"
      End If
    Next

    ThisApplication.Statuses(ObjSysName).Erase
    If ThisApplication.Statuses.Has(ObjSysName) = False Then
      str0 = str0 & chr(10) & "Из системы удален статус """ & Descr & """"
    End If
  ElseIf ThisApplication.Commands.Has(ObjSysName) Then
    Set comm = ThisApplication.Commands(ObjSysName)
    Descr = comm.Description
        
    For Each ObjDef in ThisApplication.ObjectDefs
      If ObjDef.Commands.Has(comm) Then
        ObjDef.Commands.Remove comm
        str0 = str0 & chr(10) & "Из типа объекта """ & ObjDef.Description & """ удалена команда """ & Descr & """"
      End If
    Next
        
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
