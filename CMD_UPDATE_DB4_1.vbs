USE "CMD_DLL_UPDATE"

'===========================================================================================================
' Обновление за 28.07.2017


  ThisScript.SysAdminModeOn
  ThisApplication.Utility.WaitCursor = True
  Set Progress = ThisApplication.Dialogs.ProgressDlg
  Progress.Start
  progress.SetLocalRanges 0,100
  progress.Position = 0
  
  Call Update()
  
  progress.Position = 100
  ThisApplication.Utility.WaitCursor = False
  Progress.Stop
  
  
Sub Update()
  ans = msgbox ("Процедура обновления может занять некоторое время. Продолжить? ",vbQuestion+vbYesNo,_
    "Обновление базы от 21.08.2017")
  If ans<>vbYes Then Exit Sub
  
  Call Run()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub


Sub Run()

'================================= Новое обновление БД-4

  Call DeleteAttrs()
    progress.Position = 20
  Call RemoveFromObjDef()
    progress.Position = 40
  Call SetSystemAttrs(AttrList())
    progress.Position = 80
  Call DeleteComm()
  Call misc()
  Call PanelQueriesUpdate()
    Call MoveObjects()
    progress.Position = 100
End Sub


Sub DeleteClassifiers()
  List = "NODE_65D8E68D_4F16_4133_823C_7C4E667A10D7,NODE_FB0CD208_A15F_4BDB_B9A6_EDDAC69646F4"
  Call SystemObjDelByList(List)
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
  AttrList = "ATTR_FOLDER_OBJECT_PURCHASE_OUTSIDE,ATTR_FOLDER_OBJECT_TENDER_INSIDE"
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
  lst = "ATTR_KD_COPY_ATTRS,ATTR_STRU_OBJ_SETTINGS" & aList
  arr = Split(lst,",")
  
  For each attrname In arr
    Progress.Text = "Настройка системных атрибутов: " & attrname
    If ThisApplication.AttributeDefs.Has(attrname) = True Then
      If ThisApplication.Attributes.Has(attrname) = False Then
        ThisApplication.Attributes.Create Thisapplication.AttributeDefs(attrname)
      End If
      Select Case attrname
        Case "ATTR_KD_COPY_ATTRS"
          Call Set_ATTR_KD_COPY_ATTRS("OBJECT_INVOICE")
        Case "ATTR_STRU_OBJ_SETTINGS"
          Call Set_ATTR_STRU_OBJ_SETTINGS()
      End Select
    End If
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

  List = "ATTR_INVOICE_RECIPI-ENT_COMMENT,ATTR_INVOICE_NUMBER,ATTR_INVOICE_DATE"
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
List = "CMD_0A8DD9DC_B9EC_47BB_8EFA_550B05AB82E8,CMD_INVOICE_CHANGE_REGISTRATION_NUM,CMD_TENDER_OUT_GO_INVALIDATED," &_
        "CMD_TENDER_OUT_APPROVE,CMD_TENDER_OUT_BACK_TO_WORK"
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
  ' Убираем с команд лишние статусы
 Call RemoveStatusFromCommand("CMD_TENDER_OUT_CLOSE","STATUS_TENDER_OUT_PLANING")
 Call RemoveStatusFromCommand("CMD_TENDER_OUT_TO_PUBLIC","STATUS_TENDER_OUT_APPROVED")
 Call RemoveStatusFromCommand("CMD_TENDER_OUT_UPLOAD","STATUS_TENDER_OUT_APPROVED")
   ' Убираем с команд лишние роли
 Call RemoveRoleFromCommand("CMD_TENDER_NEW_RESP","ROLE_RESPONSIBLE")
 
 
 
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
  List =  "ID_PLANING_DEPT,Планово-экономический отдел,Плановый отдел для накладных и др."
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
  List =  "OBJECT_INVOICE,OBJECT_WORK_DOCS_SET,OBJECT_PURCHASE_OUTSIDE"
          
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
      Case "OBJECT_INVOICE"
        CopyAttrsList = "" &_
                        "OBJECT_INVOICE,ATTR_INVOICE_EVERTYPE," &_
                        "OBJECT_INVOICE,ATTR_CHECKER," &_
                        "OBJECT_INVOICE,ATTR_SIGNER," &_
                        "OBJECT_INVOICE,ATTR_INVOICE_RECIPIENT," &_
                        "OBJECT_INVOICE,ATTR_INVOICE_ADDRESS," &_
                        "OBJECT_INVOICE,ATTR_PROJECT," &_
                        "OBJECT_INVOICE,ATTR_INVOICE_DISCTYPE," &_
                        "OBJECT_INVOICE,ATTR_INVOICE_TDOCS," &_
                        "OBJECT_INVOICE,ATTR_INVOICE_PAPER," &_
                        "OBJECT_INVOICE,ATTR_INVOICE_FILES," &_
                        "OBJECT_INVOICE,ATTR_INVOICE_TFILES"
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
  ObjList = "OBJECT_PURCHASE_OUTSIDE"
  ObjArr = Split(ObjList,",")
  
  For Each ObjDefName In ObjArr
    Progress.Text = "Обновляются связи объектов: " & ObjDefName
    Select Case ObjDefName
      Case "OBJECT_PURCHASE_OUTSIDE"
        List = "ATTR_!!!,ATTR_1DF14B82_44FD_4940_9186_946773575A72,ATTR_6BC6A446_4AC8_452D_9AEB_B66E6C445581," &_
        "STATUS_TENDER_OUT_IS_MATCHING,FORM_TENDER_OUTSIDE_PUBLIC,FORM_TENDER_FULL_DOCUMENTATION," &_
        "STATUS_TENDER_PLANING,STATUS_TENDER_ADD_APPROVED,STATUS_TENDER_IS_MATCHING,STATUS_TENDER_AGREED," &_
        "STATUS_TENDER_IS_APPROVING,STATUS_TENDER_APPROVED,STATUS_TENDER_IN_WORK,STATUS_TENDER_PUBLIC"

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
  For Each Obj In ThisApplication.ObjectDefs("OBJECT_ARM_FOLDER").Objects
    ARM = ""
    If Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ДОКУМЕНТЫ" Then
      ARM = "USER"
    End If
    
    List = ""
    ListToRem = ""
        
    Select Case ARM
    Case "USER"
      Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_VOLUMES_AND_SUITES"
      ListToRem = "QUERY_DESCTOP_VOLUMES_SETS_MY"
      Call AddQuery(Obj,List,ListToRem)
  End Select
Next  
 
End Sub


