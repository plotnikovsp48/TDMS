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
  ans = msgbox ("Процедура обновления может занять некоторое время. Продолжить? ",vbQuestion+vbYesNo,"Обновление базы от 06.08.2017")
  If ans<>vbYes Then Exit Sub
  
  Call Update3_1()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub


' Добавление системных атрибутов
Sub Update3_1()


'================================= Новое обновление БД-3


  Call DeleteClassifiers()
    progress.Position = 1
  call DelVersion()
    progress.Position = 3
  Call DeleteStatuses()
    progress.Position = 5
  Call AddSystemAttribute(AttrList())   ' Работает
    progress.Position = 9 
  Call SetSystemAttrs(AttrList())   ' Работает
    progress.Position = 15
  Call DeleteObj()               ' Работает
    progress.Position = 20
  Call RemoveFromObjDef()         ' Работает
    progress.Position = 30
  Call DeleteForms()           ' Работает
    progress.Position = 40
  Call DeleteProfiles()
    progress.Position = 50
  Call AddUnitFolderToProject()
    progress.Position = 55
  Call DeleteComm()
    progress.Position = 60
  Call DeleteQUERY()
    progress.Position = 80
  Call misc() 
    progress.Position = 82
  Call DeleteTemplates()         ' Работает
    progress.Position = 84
  Call PanelSettingsAdd()
    progress.Position = 85
  Call ObjAttrsSync()
    progress.Position = 90
  Call misc2()
    progress.Position = 93
  Call DeleteAttrs()
    progress.Position = 95
  Call MoveObjects()
    progress.Position = 97
  Call MoveTechObjects1()
  Call MoveTechObjects2()
    progress.Position = 98
  call MoveContractFolder()
    progress.Position = 99
  Call MoveProjectFolder()
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
  List = "PROFILE_TENDER,{56A692B1-6D61-4CC0-8613-46AF522D4F49},x," &_
         "PROFILE_CONTRACTS_MANAGEMENT,{ED965767-0977-41DF-8C32-3478E7EA6FD1},x," &_
         "PROFILE_GIP,{75843AEE-A5FC-4343-86BA-85A87B4A748B},x," &_
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
  lst = "ATTR_STAGE_SETTINGS,ATTR_KD_COPY_ATTRS,ATTR_KD_FILE_FORMS,ATTR_AGREENENT_SETTINGS,ATTR_FOLDER_OBJECT_CONTRACT," & aList
  arr = Split(lst,",")
  
  For each attrname In arr
    Progress.Text = "Настройка системных атрибутов: " & attrname
    Select Case attrname
'      Case "ATTR_DUE_DATE_FOR_SMALL_BUSINESS"
'        Val = 30
'        If ThisApplication.Attributes.Has(AttrName) = True Then
'          ThisApplication.Attributes(AttrName) = val
'        End If
'      Case "ATTR_FOLDER_OBJECT_CONTRACT_COMPL_REPORT"
'        For Each Obj in ThisApplication.ObjectDefs("OBJECT_KD_FOLDER").Objects
'          If Obj.Attributes("ATTR_FOLDER_NAME").Value = "Акты" Then
'            Set Attr = ThisApplication.Attributes(attrname)
'            Attr.Value = Obj.GUID
'            Exit For
'          End If
'        Next
'      Case "ATTR_FOLDER_OBJECT_AGREEMENT"
'        For Each Obj in ThisApplication.ObjectDefs("OBJECT_KD_FOLDER").Objects
'          If Obj.Attributes("ATTR_FOLDER_NAME").Value = "Соглашения" Then
'            Set Attr = ThisApplication.Attributes(attrname)
'            Attr.Value = Obj.GUID
'            Exit For
'          End If
'        Next
'      Case "ATTR_STRU_OBJ_SETTINGS"
'        Call Set_ATTR_STRU_OBJ_SETTINGS()

'      Case "ATTR_PLATAN_LINK_SETTINGS"
'        If ThisApplication.Attributes.Has("ATTR_PLATAN_LINK_SETTINGS") Then
'          ThisApplication.Attributes("ATTR_PLATAN_LINK_SETTINGS") = "OBJECT_WORK_DOCS_SET;OBJECT_PROJECT_SECTION_SUBSECTION;OBJECT_PROJECT_SECTION;OBJECT_T_TASK"
'        End If
      Case "ATTR_KD_COPY_ATTRS"
        Call Set_ATTR_KD_COPY_ATTRS("OBJECT_DOCUMENT")
        Call Set_ATTR_KD_COPY_ATTRS("OBJECT_DOCUMENT_AN")
        Call Set_ATTR_KD_COPY_ATTRS("OBJECT_PURCHASE_DOC")
        Call Set_ATTR_KD_COPY_ATTRS("OBJECT_VOLUME")  
      Case "ATTR_AGREENENT_SETTINGS"
        Call Set_ATTR_AGREENENT_SETTINGS()
'      Case "ATTR_KD_FILE_FORMS"
'        Call Set_ATTR_KD_FILE_FORMS()
      Case "ATTR_STAGE_SETTINGS"
        Call Set_ATTR_STAGE_SETTINGS()
      Case "ATTR_FOLDER_OBJECT_NK"
        For Each Obj in ThisApplication.ObjectDefs("OBJECT_KD_FOLDER").Objects
          If Obj.Attributes("ATTR_FOLDER_NAME").Value = "Нормоконтроль" Then
            Set Attr = ThisApplication.Attributes(attrname)
            Attr.Value = Obj.GUID
            Exit For
          End If
        Next
      Case "ATTR_FOLDER_OBJECT_CONTRACT"
        Set Obj = ThisApplication.ExecuteScript("CMD_DLL_CONTRACTS","GetContractRoot")
        Set Attr = ThisApplication.Attributes(attrname)
        Attr.Value = Obj.GUID

'      Case "ATTR_FOLDER_OBJECT_P_TASK"
'        For Each Obj in ThisApplication.ObjectDefs("OBJECT_KD_FOLDER").Objects
'          If Obj.Attributes("ATTR_FOLDER_NAME").Value = "Плановые задачи" Then
'            Set Attr = ThisApplication.Attributes(attrname)
'            Attr.Value = Obj.GUID
'            Exit For
'          End If
'        Next
    End Select
  Next
End Sub

Sub Log(txt)
  'msgbox txt
End Sub

' Удаление объектов по списку
Sub DeleteObj()
  Progress.Text = "Удаляются типы объектов"
  list = "OBJECT_PRINT_REQUEST," &_
  ""
Call SystemObjDelByList(List)
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
    List = "STATUS_D_ENTERPRIZE_CHEKED"
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
List = "QUERY_DESCTOP_DEVELOP_TASKS,QUERY_REPORT_PROJECT_fCOMP_TYPE,QUERY_TASK_JOURNAL_INCOMING,QUERY_TASK_JOURNAL_OUTCOMING,QUERY_S_OBJECT_TASKS," &_
"QUERY_DESCTOP_MY_TASKS,QUERY_ISSUED_PRINT_REQUEST_DEFAULT,QUERY_COMPLITE_PRINT_REQUEST_OPERATOR,QUERY_COMPLITE_PRINT_REQUEST_DEFAULT," &_
"QUERY_PRINT_REQUEST_OPERATOR,QUERY_WORK_PRINT_REQUEST_OPERATOR,QUERY_PRINT_REQUEST_MAX_NUM,QUERY_PRINT_REQUEST_DEFAULT,QUERY_NEW_PRINT_REQUEST_DEFAULT,QUERY_NEW_PRINT_REQUEST_OPERATOR"
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


Sub DeleteClassifiers()
  List = "NODE_DBE14BCF_FA66_4138_9AC9_37861319DAF5,NODE_0F2FD361_8BCB_4C59_881D_E7CF2450FD2F,NODE_F3DC0DA8_AA97_48FB_B625_FB5442F2CC8C," &_
         "NODE_1EC746D0_65BA_46B5_A22E_07449292AB72,NODE_3B57CE6B_6530_4188_A19F_2FA3C698A25B,NODE_CE077613_C682_4415_A5DB_E322E79801A1," &_
         "NODE_5DE7474F_8C67_46A7_B5B2_568E4AE67402,NODE_C63C5C0B_73C0_41B0_B16D_C28219DFB98D,NODE_A11A8247_9A16_4B2A_B89B_CBAA01C040B0," &_
         "NODE_D48B7B60_0200_4863_85FA_A2AFA375A53F,NODE_DDDCAA00_B696_4785_898B_CDC4BFFD7B5C,NODE_70F097F2_231B_48B9_9B85_C34191972CF9," &_
         "NODE_39A7B506_4A2A_429A_B40A_C629FC03DB21,NODE_5FD51EF6_FAD0_45A8_B0FE_5884532FFA6C,NODE_CC059D95_8702_4E08_97D8_A605F771F3F7," &_
         "NODE_09D52117_FE4B_4B13_B5A7_EB3DB11FEF19,NODE_83287393_244C_436B_9188_ABA460FEBED6,NODE_7CDE9A40_67DE_4643_9026_AA297944D447," &_
         "NODE_1BE05BFB_234C_4779_BC8E_564CF94770AC,NODE_6DFB0084_2161_47BE_8ED1_DEA4AB692631,NODE_73B3576A_56C3_4483_9E93_DC112DE57401," &_
         "NODE_4E02C1DB_A08F_4EB6_B94C_0283C38163B1,NODE_DD3B526E_5568_499E_8514_E1F0682FD16C,NODE_5288D101_11D6_402C_9742_AAA7160E3F1B," &_
         "NODE_8A9E9DA0_EB6D_4E59_B326_B8A84E116502,NODE_2E147331_0BDC_4EA0_8C5D_CABBCA9F6FB3,NODE_2A60DEC5_9E85_454E_838E_86661F248BA3," &_
         "NODE_BB55BD1F_0DED_454D_A647_E9E5947FB3CD,NODE_7229A5A5_4712_4DD9_A492_C3C2963F3F33,NODE_A0183CA8_D592_4DA8_A669_639AE0050B49," &_
         "NODE_EA8DB8C0_5AC9_40D5_95D7_74E3A9B9D094,NODE_F16A2ECD_94B7_425B_A74B_665D171C2AA3,NODE_1DF7BE75_09A3_4538_B1D2_0238608DE085," &_
         "NODE_57B122E7_0213_482C_A1AE_05C51CE3B36F,NODE_E2B04E88_2DC7_4E4F_BF4C_3931ABDE0C92,NODE_A0C09916_A587_4E0A_8CD0_0FDA01CABCB9," &_
         "NODE_51BFBBC5_5A40_43E5_BDEF_24C59C3EA4AF,NODE_6891064E_E0C0_494E_8667_2CE2CE842BCC,NODE_D375994C_8500_49CB_8670_F0108D5BCDD7," &_
         "NODE_B27A2DE9_D08B_4231_A13C_41D5E2D40122,NODE_324A0A97_1579_4D3D_8BCD_2DE277663714,NODE_A3576BEF_60F3_47CE_8964_9F09EA31105E," &_
         "NODE_34F02EB3_9219_4C4F_AE2C_FFA56A809A31,NODE_289E0E44_C095_4940_8CF7_9E36C0D3038A,NODE_72DF51B4_5FD7_4352_B5E6_BEB73089129E," &_
         "NODE_B07DE2B7_D93A_4260_89D5_A7622F3D0315,NODE_40F2E69E_E5DA_46AC_B96D_407911A410A0,NODE_6168DEE2_710D_4ABB_B3A2_A878153A75CD," &_
         "NODE_CA85536F_02F8_4345_8A94_36C4484766B4,NODE_78754674_80A9_4E18_B5E8_B40F8FBE9DD7,NODE_7ABF4EE2_6B79_4549_AEB1_CEBEDBD110F1," &_
         "NODE_F74A15B2_270B_49C1_A5D0_A1AC6E8F75C7,NODE_F0234179_0BD4_4293_9FA6_6A3B0A9784DC"
  ' Пока не удаляем:
  '"NODE_CF28CFFF_7A21_4F42_A51E_6EA015B4E0B5,NODE_2062457E_F096_4305_A930_19AEC496D139" 
Call SystemObjDelByList(List)
End Sub

Sub Misc()
  ThisScript.SysAdminModeOn

  Progress.Text = "Обновляю состав: OBJECT_VOLUME"
  Call SyncObjContentByList("OBJECT_VOLUME","OBJECT_DOC_DEV,OBJECT_FOLDER,OBJECT_DRAWING")
  Progress.Text = "Обновляю состав: OBJECT_PROJECT_SECTION"
  Call SyncObjContentByList("OBJECT_PROJECT_SECTION","OBJECT_VOLUME,OBJECT_PROJECT_SECTION_SUBSECTION")
  Progress.Text = "Обновляю состав: OBJECT_PROJECT_SECTION_SUBSECTION"
  Call SyncObjContentByList("OBJECT_PROJECT_SECTION_SUBSECTION","OBJECT_VOLUME")
  
  Progress.Text = "Обновляю состав: OBJECT_WORK_DOCS_SET"
  Call SyncObjContentByList("OBJECT_WORK_DOCS_SET","OBJECT_DOC_DEV,OBJECT_FOLDER,OBJECT_DRAWING")
  
  Progress.Text = "Обновляю состав: OBJECT_WORK_DOCS_FOR_BUILDING"
  Call SyncObjContentByList("OBJECT_WORK_DOCS_FOR_BUILDING","OBJECT_WORK_DOCS_FOR_BUILDING,OBJECT_WORK_DOCS_SET")
  
  ' Убираем значения по умолчанию
  Set odef = ThisApplication.ObjectDefs("OBJECT_PURCHASE_LOT")
  Set attr = odef.AttributeDefs("ATTR_TENDER_OKATO")
  attr.Value = ""
  
  
  Set odef = ThisApplication.ObjectDefs("OBJECT_TENDER_INSIDE")
  Set attr = odef.AttributeDefs("ATTR_TENDER_STATUS_EIS")
  attr.Value = ""

  Progress.Text = "Обновление ролей команд:"
  ' Убираем с команд лишние роли
  Call RemoveRoleFromCommand("CMD_DOC_APPROVE","ROLE_LEAD_DEVELOPER")
  Call RemoveRoleFromCommand("CMD_STAGE_CHANGE_ROWS","ROLE_RESPONSIBLE")
  
'  ' Убираем с команд лишние статусы
' Call RemoveStatusFromCommand("CMD_BOD_DOC_FIX","STATUS_WORK_DOCS_SET_IS_DEVELOPING")
'  
' Удаляем лишние узлы классификаторов
'  Set cls = ThisApplication.Classifiers.FindBySysId("NODE_DOC_TYPES_ALL")
'  
'  Set cls1 = cls.Classifiers.FindBySysId("NODE_CONTRACT_CLOSE_INVALIDATED")
'  If Not cls1 Is nothing Then cls1.Erase
'  
'  Set cls1 = cls.Classifiers.FindBySysId("NODE_CONTRACT_CLOSE_FULLFILL")
'  If Not cls1 Is nothing Then cls1.Erase
'  
'  Set cls1 = cls.Classifiers.FindBySysId("NODE_CONTRACT_CLOSE_CANCEL")
'  If Not cls1 Is nothing Then cls1.Erase
'  
'  Set cls1 = cls.Classifiers.FindBySysId("NODE_CONTRACT_CLOSE_TYPE")
'  If Not cls1 Is nothing Then cls1.Erase
  
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
  List = "OBJECT_DOCUMENT_AN,STATUS_DOCUMENT_CREATED,STATUS_DOCUMENT_AGREED,STATUS_DOCUMENT_DEVELOPED,CMD_DLL_ROLES;Set_Tech_Permission"
  arr = Split(List,",")
  For i=0 to Ubound(arr) Step 5
    check = false
    Set Table = ThisApplication.Attributes("ATTR_AGREENENT_SETTINGS")
      For each row in Table.Rows
        If row.Attributes("ATTR_KD_OBJ_TYPE").Value = arr(i) Then
        check = True
        End If
      Next
      
      If Check = Flase Then
        Set R = Table.Rows.Create
        r.Attributes("ATTR_KD_OBJ_TYPE").Value = arr(i)
        r.attributes("ATTR_KD_RETURN_STATUS").value = arr(i+1)
        r.attributes("ATTR_KD_FINISH_STATUS").value = arr(i+2)
        r.attributes("ATTR_KD_START_STATUS").value = arr(i+3)
        r.attributes("ATTR_KD_PERMISSIONS").value = arr(i+4)
      End If
   Next
  
  ' Заполняем функцию в таблиу согласования
  val = "OBJECT_TENDER_INSIDE;CheckBeforeAgree"
  Set Table = ThisApplication.Attributes("ATTR_AGREENENT_SETTINGS")
    For each row in Table.Rows
      Select Case row.Attributes("ATTR_KD_OBJ_TYPE").Value
        Case "OBJECT_TENDER_INSIDE"
          row.attributes("ATTR_KD_CHECK_FUNCTION").value = val
      End Select
    Next
End Sub


Sub RemoveFromObjDef()
  Progress.Text = "Обновляются связи объекта:"
  ObjList = "OBJECT_TENDER_INSIDE,OBJECT_PURCHASE_OUTSIDE,OBJECT_DRAWING,OBJECT_VOLUME," &_
            "OBJECT_PROJECT_SECTION_SUBSECTION,OBJECT_PROJECT_SECTION,OBJECT_PURCHASE_LOT"
  ObjArr = Split(ObjList,",")
  
  For Each ObjDefName In ObjArr
    Progress.Text = "Обновляются связи объектов: " & ObjDefName
    Select Case ObjDefName
      Case "OBJECT_TENDER_INSIDE"
        List = "FORM_TENDER_INSIDE_ORDER_LIST,FORM_TENDER_POSSIBLE_CLIENT," &_
                "ATTR_7C4FBE23_B08C_4B24_A6BF_5FC3D2FD83B4,ATTR_TENDER_CARD_ATTR_TABLE,ATTR_TENDER_RESP_USER,ATTR_TENDER_REASON_URGENTLY_FLAG"
      Case "OBJECT_PURCHASE_OUTSIDE"
        List = "FORM_DOCUMENT_REFFERENCES,ATTR_TENDER_COMPETITOR_PRICE_TABLE," &_
                "ATTR_TENDER_CLIENT_NAME,ATTR_TENDER_DIAL_PRICE,ATTR_7C4FBE23_B08C_4B24_A6BF_5FC3D2FD83B4," &_
                "ATTR_TENDER_CARD_ATTR_TABLE,ATTR_TENDER_RESP_USER,ATTR_TENDER_REASON_URGENTLY_FLAG"
      Case "OBJECT_DRAWING"
        List = "ExternFunctions"
      Case "OBJECT_PROJECT_SECTION"
        List = "ATTR_S_PSECTION_NUM"
      Case "OBJECT_PROJECT_SECTION_SUBSECTION"
        List = "ATTR_S_PSECTION_NUM"
      Case "OBJECT_PURCHASE_LOT"
        List = "ATTR_TENDER_LOT_NDS"
      Case "OBJECT_VOLUME"
        List = "CMD_VOLUME_BACK_IN_WORK,FORM_KD_AGREE,FORM_NK"
      Case "OBJECT_PURCHASE_DOC"
        List = "FORM_KD_DOC_ORDERS"
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

    End If
    
    
    Select Case ARM
    Case "TASK"
      Progress.Text = "Обновление выборок рабочего стола: " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_DESCTOP_IN_TASKS,QUERY_DESCTOP_OUT_TASKS,QUERY_DESCTOP_DEVELOP_TASKS,QUERY_DESCTOP_CONFIRM_TASKS,QUERY_DESCTOP_TASKS_ON_CHECK," &_
             "QUERY_DESCTOP_TASKS_ON_APPROVE,QUERY_DESCTOP_TASKS_ON_SIGN"
      arr = Split(List,",")
    
      For Each q In arr
        If Not Obj.Queries.Has(q) Then
          Obj.Queries.Add q
        End If
      Next
    Case "CONTRACT"
      Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_DESCTOP_CONTRACT_DOCS,QUERY_DESCTOP_CONTRACTS,QUERY_DESCTOP_CONTRACTS_MY"
      arr = Split(List,",")
    
      For Each q In arr
        If Not Obj.Queries.Has(q) Then
          Obj.Queries.Add q
        End If
      Next
    Case "TENDER"
      Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_DESCTOP_TENDER_INSIDE,QUERY_DESCTOP_TENDER_OUTSIDE"
      arr = Split(List,",")
    
      For Each q In arr
        If Not Obj.Queries.Has(q) Then
          Obj.Queries.Add q
        End If
      Next
    Case "GIP"
      Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_PROJECTS_EDIT,QUERY_FOR_APPROVE"
      arr = Split(List,",")
    
      For Each q In arr
        If Not Obj.Queries.Has(q) Then
          Obj.Queries.Add q
        End If
      Next
    Case "USER"
      Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_DOC_MY,QUERY_ACCEPT,QUERY_DOCS_MY_ON_CHECK"
      arr = Split(List,",")
    
      For Each q In arr
        If Not Obj.Queries.Has(q) Then
          Obj.Queries.Add q
        End If
      Next
  End Select
Next  
 
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
