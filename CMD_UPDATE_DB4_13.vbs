
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
    "Обновление базы от 03.11.2017")
  If ans<>vbYes Then Exit Sub
  
  Call Run()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub

Sub Run()

'================================= Новое обновление БД-4

'Call ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetGroupsChiefsByDept",ThisApplication.GetObjectByGUID("{CFE31FC9-3B51-4B71-A2C0-2A47A00B3647}"))
Call SetSystemAttrs("")
progress.Position = 20
Call DeleteForms()
progress.Position = 40
Call RemoveFromObjDef()
progress.Position = 50
Call SetDispForProjects()
progress.Position = 60
Call DeleteComm()
progress.Position = 65
Call RemoveFakeMarks()
progress.Position = 80
Call DeleteQUERY()
progress.Position = 80
Call PanelSettingsAdd()

progress.Position = 90
Call ThisApplication.ExecuteScript("CMD_SET_DEPT_BULK","Main")


'===================================================  

'Call ObjAttrsSync()
'

'  
'  Call misc()


'  
'  Call PanelQueriesUpdate()
'  
'  Call DeleteObj() 
'  Call DeleteAttrs()
End Sub

' Список системных атрибутов технического документооборота
Function AttrList()
  AttrList = "ATTR_TENDER_SMALL_PURSHASE_LIMIT"
End Function

Sub PanelSettingsAdd()
  Set Objs = ThisApplication.ObjectDefs("OBJECT_PANEL_CONFIG")
  If Objs.Objects.Count = 0 Then Exit Sub
  Set Obj = Objs.Objects(0)
  Set Table = Obj.Attributes("ATTR_PANEL_CONFIG_TAB")
  List = "PROFILE_GIP,,," &_
         "PROFILE_NK,{D4A5BFDD-0D62-4DA6-9F0E-8758A2EB819C},x," &_
         "PROFILE_COMPL,{0F20E044-FACA-4641-9B7D-020A0BEA7CAD},x," &_
         "PROFILE_ARM_DEVELOPERS,,," &_         
         "PROFILE_CONTRACTS_MANAGEMENT,,," &_         
         "PROFILE_P_PLANING,,," &_         
         "PROFILE_TENDER,,"
         
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

Sub changePSectionLink()
Set cls = ThisApplication.Classifiers.FindBySysId("NODE_PROJECT_STRUCT1_10.1")
'Set cls = ThisApplication.Classifiers.FindBySysId("NODE_PROJECT_STRUCT1_10(1)")
Set cls1 = ThisApplication.Classifiers.FindBySysId("NODE_PROJECT_STRUCT1_10(1)")
If cls Is Nothing Then Exit Sub
Set os = cls.AssignedObjects
If os Is Nothing Then Exit Sub

For Each o In os
  For each attr in o.Attributes
    If attr.Type = 6 or attr.Type = 8 Then
      Set link = attr.Classifier
      If Not link Is Nothing Then
        If link.Handle = cls.Handle Then
          attr.Classifier = cls1
        End If
      End If
    End If
  Next
Next
End Sub

Sub DeleteClassifiers()
  List = "NODE_PROJECT_STRUCT5_0,NODE_PROJECT_STRUCT6_0,NODE_PROJECT_STRUCT1_10.1,NODE_5819E753_E0EC_46A7_9912_5C686C3BD533," &_
          "NODE_60F4A7FE_5B7F_40E3_904F_46F4ED3EB7B0,NODE_A1912B2C_0538_4ACC_B626_C9706AFB6165,NODE_EF1C6F99_F4D2_4A32_B864_EBABF8F8652B," &_
          "NODE_CAF744B2_E058_4D35_9973_A14085714553,NODE_CCD265A7_1B8C_4A63_9693_1599036CAAC0,NODE_F84F8822_2E90_490D_A46F_CDEDDE5AAC08," &_
          "NODE_F3246FBB_1B61_4732_A5FF_2CA33D33FFC4,NODE_0CAF9EA5_82B3_4945_98D1_ADFC7CD173F0,NODE_44D5A372_E1E3_438E_9367_E4624A0BBDB2," &_
          "NODE_33684378_1A02_4C91_A6F6_EEAC9867E30A,NODE_72801DDC_C2BC_4788_85CA_F1AA89781849,NODE_70EBF495_DC98_48B0_A95C_A616BA1EC2AD," &_
          "NODE_08E01F9A_5D59_45B5_9F7B_BC0ED6D06862,NODE_BC3F7DB5_2E94_4BF4_9A36_991B2CBA85EB,NODE_E5042CC3_D8A5_43F9_8A38_B4580AAB4798," &_
          "NODE_10C4C95A_E558_4430_AEC8_2499DFA8F6B7,NODE_93F82C93_8A13_4A60_A164_685AD7E0618F,NODE_E7C7DF59_5DAA_47DA_998B_5AA89098A338," &_
          "NODE_EE897E29_8062_4914_B494_0261919B12F1,NODE_CBE0F6C1_3990_4476_A45E_BF8278522A08,NODE_F55A39C1_854D_455D_B589_EC09C755C2A7," &_
          "NODE_1B374D9F_5904_4253_804B_3A19ECE97BA0,NODE_5686376A_1404_4011_AEFF_DA33836AD76D,NODE_8A864C3C_6150_47BE_BAEA_0A1B597EB378," &_
          "NODE_9AE5A456_ED09_42F8_A366_966D0183874F,NODE_5AE58525_1F2E_4B81_9D3D_DFC9FF6097D5,NODE_2AC31CEB_34D8_429A_B76F_1E2D68766C23," &_
          "NODE_3B5AC72D_F286_41F1_B889_5DEC0EEDC296,NODE_6D6E05E5_7B35_4EA5_A283_0402B77E0F27,NODE_F6B6732A_299E_4539_9C0F_3198C69FDFE1," &_
          "NODE_041AAAE0_1499_4ECC_928A_8D2BD269D584,NODE_BE82A3CF_DF42_47E9_8DA2_F71B86669CBB,NODE_AB15811E_036D_44D9_A6EE_DACFDCDF8160," &_
          "NODE_A03B459D_E793_46D5_9A79_C73E03107A1D,NODE_568273FF_3115_434C_A8DC_14A40D4B23C3,NODE_DE2688A1_806F_4D9E_A61F_5B4DE2BF9C25," &_
          "NODE_190DA627_BD35_4E57_93B7_150AC49FEC05,NODE_6FE22D96_B591_4424_A430_C2B2FED816FA,NODE_40D399EE_C6A6_4C28_80CE_BA2E225DDD3A," &_
          "NODE_39F7F3E4_0439_4B1D_983A_0A53619C4F52,NODE_028C264F_B762_4992_B260_257922CEB237,NODE_9C54D93A_7694_41E6_B67F_6C4B21068D79," &_
          "NODE_DC38EC97_01CD_4F89_8353_C11C4425493B,NODE_C5F929F5_0588_4F3B_A10B_F6069B7D2F24,NODE_F93A9041_ECA6_4A8E_A855_A36174C92CB9," &_
          "NODE_61A5BFA1_3CC8_4D42_B2BB_98A6D3181050,NODE_45B44DDC_CEA3_4F1E_B046_59009A47AE06,NODE_C6D27C8A_A5A9_4659_B023_253C93675EBF," &_
          "NODE_4C50FB0C_59D7_4811_BDB8_743F0E6F2039,NODE_E6880708_0E89_45D6_A56D_92FE5AB19003,NODE_FE89D1C1_7BA8_458E_A468_94776948A972," &_
          "NODE_16363660_CF33_4D15_9926_E6814793DCDB,NODE_97163C0B_4751_4337_AB9B_F257E5AF19B9,NODE_D1DE3BC6_DE9C_4100_B35F_CD27F30BD6DC," &_
          "NODE_4E9AD6B0_C57D_4F43_B76B_C0B1B2AC179E,NODE_6308A761_D87D_49C4_8802_4160D7FB967C,NODE_D59D644E_ABC7_49A2_B069_035F8F076884," &_
          "NODE_64E276EB_08EF_420E_BEE8_113C0B66AB70,NODE_4F80A670_AD7E_4A16_9CC9_579BC0F6C2B3,NODE_8FACAB3E_F37E_4188_A7CB_8A0E4B5DE81C," &_
          "NODE_EBDFB448_98A2_425D_8BB2_767EBC6125FB,NODE_02851EE5_1BC1_4B0C_A176_A64FD53A5C82,NODE_9AC7DF19_FCA5_4142_B38E_8A544DC99D76," &_
          "NODE_AFD3CB97_B4A5_45D5_9E02_F4575A68B86E,NODE_DA3EEBBF_1676_44D4_AC3A_3FDF767A7666,NODE_7B0AA703_563C_4173_B75B_25AF4A60BCE5," &_
          "NODE_C176B56B_FE48_4FD9_A6EC_A7E058CBF166,NODE_AC72C7A8_A084_4F4E_B6DA_F6ACC42BE26F,NODE_EE58F9DD_63CD_4ECB_9625_3CA4939C7655," &_
          "NODE_FFDD80BF_DD7B_4958_A6ED_69EF8D8ADC5D,NODE_FE1ADE8E_C98A_47A8_96A0_93265B528B63,NODE_87B76F97_8A91_4C88_AAB9_E2F9558C7405," &_
          "NODE_CC387B54_8EF7_4575_90F2_6CCE8BDE05AB,NODE_2825D229_36C7_408D_8010_EC8D155657BA,NODE_7D9477EB_8C62_497A_B691_01B92380C3F6," &_
          "NODE_F5A4724B_D9B7_4B67_97B1_0C59700C97A6,NODE_0F3DC2B3_AC7B_4300_9016_2855BF3B761D,NODE_F3A14581_2B94_4DD5_814D_E79485DB156E," &_
          "NODE_76073AC3_3EFD_46EF_A47A_30C7BAC4005F,NODE_A715329E_0C83_4F9F_B697_3755DD121029,NODE_9FC95768_C316_4EE6_9245_1382EBB1C1EE," &_
          "NODE_63C14102_FF3F_451C_BC88_5B6CC2389CB9,NODE_8E5C7EAA_7574_4E72_AEC8_9E4EA127CCEE,NODE_525E5077_D4DC_4784_AD86_189B8F3FE137," &_
          "NODE_61C86CDB_6359_47D4_8D41_008C81C5A7A8,NODE_54DE8222_EE5C_4EFF_921F_FF4055948BDF,NODE_86DDA7D1_7AC3_4E63_A3FA_8F37D6903E4E," &_
          "NODE_7A69C519_CF60_4EC6_80DC_68E7017B367D,NODE_7510F7F3_25C9_4C02_9528_B9B8170B4CA4,NODE_CB405C71_F595_44A4_905A_C55E267C0E2F," &_
          "NODE_0AE1A6A2_7EA1_4177_9135_42E1E44757D8,NODE_C286D3B8_C804_4146_ABAE_307EB11DE715,NODE_1EB343C3_85C4_410A_9795_5A5A308C814A," &_
          "NODE_023609A7_DC25_4A20_8D42_76F2866530B7,NODE_D3A41C21_ABAD_4FF4_90A2_A688408C7710,NODE_59C0E7F9_3170_4505_9CCD_49C4A1426E7A," &_
          "NODE_586C6732_05FC_4566_B6BB_80952B8188AA,NODE_CFB8FDFD_FBE4_44DB_928A_2CC5C964FB2D,NODE_D3A41C21_ABAD_4FF4_90A2_A688408C7710," &_
          "NODE_59C0E7F9_3170_4505_9CCD_49C4A1426E7A,NODE_586C6732_05FC_4566_B6BB_80952B8188AA,NODE_CFB8FDFD_FBE4_44DB_928A_2CC5C964FB2D"
Call SystemObjDelByList(List)
End Sub

Sub DeleteQUERY()
List = "QUERY_75BCFCDF_809A_42DD_8E23_FE280BECD868"
Call SystemObjDelByList(List)
End Sub

Sub DeleteComm()
Progress.Text = "Обновляются команды"
List = "CMD_TASK_DEVELOPER_APPOINT"
Call SystemObjDelByList(List)
End Sub

Sub DeleteObj()
  Progress.Text = "Удаляются типы объектов"
  list = "OBJECT_COMMENT," &_
  ""
  Call SystemObjDelByList(List)
End Sub



Sub DeleteAttrs()
  Progress.Text = "Обновление атрибутов"

  List = "ATTR_D5F5C071_5F54_4361_9A3B_D5C85A8DDFE2"
  Call SystemObjDelByList(List)
End Sub

Sub RemoveFromObjDef()
  Progress.Text = "Обновляются связи объекта:"
  ObjList = "OBJECT_TENDER_INSIDE"
  ObjArr = Split(ObjList,",")
  
  For Each ObjDefName In ObjArr
    Progress.Text = "Обновляются связи объектов: " & ObjDefName
    Select Case ObjDefName
      Case "OBJECT_TENDER_INSIDE"
        List = "FORM_DOCS_TLINKS"
    End Select
  
    arr = Split(List,",")
    For Each ObjSysName In arr
      call SystemObjRemoveFromObject(str0,ObjDefName,ObjSysName)
    Next
  Next
End Sub

Sub ObjAttrsSync()
  Progress.Text = "Обновление атрибутов объекта:"
  List =  "OBJECT_VOLUME"

  Call ObjAttrSync(List)
End Sub

Sub SetDispForProjects()
  ThisScript.SysAdminModeOn
  For each obj in ThisApplication.ObjectDefs("OBJECT_PROJECT").Objects
    If Obj.Attributes.Has("ATTR_PROJECT_DISPATCHER") = False Then
      Obj.Attributes.Create("ATTR_PROJECT_DISPATCHER")
    End If
  Next
End Sub

Sub misc()
  Progress.Text = "Обновление атрибутов объекта:"
  
    If ThisApplication.FileDefs.Has("FILE_REPORT_TEMPLATE") Then
    Set fDef = ThisApplication.FileDefs("FILE_REPORT_TEMPLATE")
    If fDef.Templates.Has("VOK----------.docx") Then fDef.Templates("VOK----------.docx").Erase
  End If
  
  Set oDef = ThisApplication.ObjectDefs("OBJECT_STAGE")
  If oDef.Commands.Has("CMD_B8F008D7_C008_40A6_A762_3D34BCC9653D") Then _
    oDef.Commands.Remove ThisApplication.Commands("CMD_B8F008D7_C008_40A6_A762_3D34BCC9653D")
  If oDef.Commands.Has("CMD_DELETE_ALL") Then _
    oDef.Commands.Remove ThisApplication.Commands("CMD_DELETE_ALL")
End Sub

' Установка системных атрибутов
Sub SetSystemAttrs(aList)
  Progress.Text = "Настройка системных атрибутов"
  lst = "ATTR_AGREENENT_SETTINGS,ATTR_STAGE_SETTINGS," & aList
  arr = Split(lst,",")
  
  For each attrname In arr
    Progress.Text = "Настройка системных атрибутов: " & attrname
    Select Case attrname
      Case "ATTR_AGREENENT_SETTINGS"
        Call Set_ATTR_AGREENENT_SETTINGS()
      Case "ATTR_STAGE_SETTINGS"
        Call Set_ATTR_STAGE_SETTINGS()
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
    If Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "УПРАВЛЕНИЕ ДОГОВОРАМИ" Then
      ARM = "CONTRACT"
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ЗАКУПКИ" Then
      ARM = "TENDER"
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "АРМ ГИПа" Then
      ARM = "GIP"
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "НОРМОКОНТРОЛЬ" Then
      ARM = "NK"
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ВЫПУСК ДОКУМЕНТАЦИИ" OR Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "АРМ Комплектация документации" Then
      Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ВЫПУСК ДОКУМЕНТАЦИИ"
      ARM = "ISSUE"
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ВЫПУСК ДОКУМЕНТАЦИИ (РС)" Then
      ARM = "ISSUE_DT"
    End If
    
    List = ""
    ListToRem = ""
        
    Select Case ARM
    Case "CONTRACT"
      Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_DESCTOP_AGREEMENT_ACTIVE,QUERY_DESCTOP_CONTRACTS,QUERY_DESCTOP_CONTRACTS_BY_TYPE"
      ListToRem = "QUERY_DESCTOP_CONTRACT_TO_DO,QUERY_DESCTOP_CONTRACTS_DOCS_TO_AGREE,QUERY_DESCTOP_CONTRACT_DOCS," &_
                  "QUERY_DESCTOP_CONTRACTS_DOCS_ONSIGN"
      Call AddQuery(Obj,List,ListToRem)
    Case "NK"
      Progress.Text = "Обновление выборок рабочего стола: " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_FOR_N,QUERY_ON_NK"
      Call AddQuery(Obj,List,ListToRem)
    Case "GIP"
      Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_PROJECTS_EDIT,QUERY_DESCTOP_READY_FOR_ISSUE"
      ListToRem = "QUERY_FOR_APPROVE"
      Call AddQuery(Obj,List,ListToRem)
    Case "TENDER"
      Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_DESCTOP_TENDER_INSIDE,QUERY_DESCTOP_TENDER_OUTSIDE"
      ListToRem = "QUERY_DESCTOP_TENDER_DOCS_TO_AGREE"
      Call AddQuery(Obj,List,ListToRem)
    Case "ISSUE"
      Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_INVOICE_DOCS_APPROVED,QUERY_DESCTOP_INVOICE_DOCS_READY_TO_ISSUE"
      ListToRem = "QUERY_INVOICE_DESCTOP,QUERY_DESCTOP_INVOICE_MY,QUERY_INVOICE_DOCS_ON_CHECK"
      Call AddQuery(Obj,List,ListToRem)
    Case "ISSUE_DT"
      Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_INVOICE_DESCTOP,QUERY_DESCTOP_INVOICE_MY"
      ListToRem = "QUERY_PROJECTS_EDIT,QUERY_INVOICE_DOCS_ON_CHECK," &_
                  "QUERY_INVOICE_DOCS_APPROVED,QUERY_DESCTOP_INVOICE_DOCS_READY_TO_ISSUE"
      Call AddQuery(Obj,List,ListToRem)
  End Select
Next  
 
  List = "QUERY_DESCTOP_VOLUMES_SETS_MY,QUERY_WORK_SETS_IS_DEVELOPING_MY,QUERY_DESCTOP_VOLUMES_SETS_MY_AGREED,QUERY_DESCTOP_VOLUMES_SETS_MY_NK"
  'Call AddSubQuery(List)
  
  List = "QUERY_DESCTOP_CONTRACT_DOCS,QUERY_DESCTOP_CONTRACT_DOCS_MY,QUERY_DESCTOP_AGREEMENT_ACTIVE"
  'Call AddSubQuery(List)
  
  List = "QUERY_DESCTOP_CONTRACTS,QUERY_DESCTOP_CONTRACTS_COMPLETION,QUERY_DESCTOP_CONTRACTS_ONCONTRACTOR,QUERY_DESCTOP_CONTRACTS_ONSIGN," &_
          "QUERY_DESCTOP_CONTRACTS_PAUSED,QUERY_DESCTOP_CONTRACTS_ONAGREEMENT"
  'Call AddSubQuery(List)
  
  List = "QUERY_DESCTOP_CONTRACTS_BY_TYPE,QUERY_DESCTOP_CONTRACTS_BY_TYPE_PRO,QUERY_DESCTOP_CONTRACTS_BY_TYPE_EXP,QUERY_DESCTOP_CONTRACTS_BY_TYPE_GPH," &_
         "QUERY_DESCTOP_CONTRACTS_BY_TYPE_SALES,QUERY_DESCTOP_CONTRACTS_BY_TYPE_OU,QUERY_DESCTOP_CONTRACTS_BY_TYPE_OTHER" 
  'Call AddSubQuery(List)
End Sub


' Заполняем функцию в таблицу согласования
Sub Set_ATTR_AGREENENT_SETTINGS()
  ' Заполняем функцию в таблицу согласования
  Set Table = ThisApplication.Attributes("ATTR_AGREENENT_SETTINGS")
    For each row in Table.Rows
      Select Case row.Attributes("ATTR_KD_OBJ_TYPE").Value
        Case "OBJECT_T_TASK"
          row.attributes("ATTR_AFTER_FUNCTION").value = "OBJECT_T_TASK;TaskAgreeCheck"
      End Select
    Next
End Sub

Sub Set_ATTR_STAGE_SETTINGS()
  Set Table = ThisApplication.Attributes("ATTR_STAGE_SETTINGS")
  For each row In Table.Rows
    If row.attributes("ATTR_PROJECT_STAGE").Classifier.SysName = ThisApplication.Classifiers.FindBySysId("NODE_PROJECT_STAGE_TP").SysName Then
      row.attributes("ATTR_STAGE_STRUCTURE").Classifier = ThisApplication.Classifiers.FindBySysId("NODE_PROJECT_STRUCT13")
    End If
  Next
End Sub

Sub DeleteForms()
  Progress.Text = "Обновляются формы"
    List = "FORM_NK,FORM_TENDER_PLAN,FORM_CCR_ZA_PAYMENT,FORM_TENDER_PLAN-OLD"
  Call SystemObjDelByList(List)
End Sub

Sub SetContractsPermissions()
  ThisScript.SysAdminModeOn
  For each obj In ThisApplication.ObjectDefs("OBJECT_CONTRACT").Objects
    
    If Obj.Roles.Has("ROLE_VIEW") Then 
      Set newRole = Obj.Roles("ROLE_VIEW")
      newRole.Group = ThisApplication.Groups("GROUP_CONTRACTS")
    Else
      Set newRole = obj.Roles.Create("ROLE_VIEW","GROUP_CONTRACTS")
    End If
    newRole.Inheritable = False
    
    If Obj.Roles.Has("ROLE_VIEW_CONTRACTS") Then 
      Set Rls = Obj.Roles("ROLE_VIEW_CONTRACTS")
      Set newRole = Rls
      newRole.Group = ThisApplication.Groups("ALL_USERS")
    Else
      Set newRole = obj.Roles.Create("ROLE_VIEW_CONTRACTS","ALL_USERS")
    End If
    newRole.Inheritable = False
  Next
End Sub

Sub RemoveFakeMarks()
  Set os = ThisApplication.ObjectDefs("OBJECT_MARK").Objects
  For Each o In os
    o.Permissions = SysAdminPermissions
    For Each r In o.Roles
      If r.RoleDefName <> "ROLE_DEVELOPER" Then 
        o.Roles.Remove r
      End If
    Next
  Next
End Sub
