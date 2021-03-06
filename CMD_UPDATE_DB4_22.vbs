
USE "CMD_DLL_UPDATE"
'===========================================================================================================


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
    "Обновление базы от 07.12.2017")
  If ans<>vbYes Then Exit Sub
  
  Call Run()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub

Sub Run()

'================================= Новое обновление БД-4

Call RemoveFromObjDef()
  progress.Position = 20
Call DeleteStatuses()
  progress.Position = 30
'Call AddAttrs()
  progress.Position = 50
Call DeleteClassifiers()
  progress.Position = 70
  ' Удаление объектов по списку
Call DeleteObj()
  progress.Position = 90
Call DeleteAttrs()

'===================================================  

End Sub

' Установка системных атрибутов
Sub SetSystemAttrs(aList)
  Progress.Text = "Настройка системных атрибутов"
  lst = "ATTR_AGREENENT_SETTINGS,ATTR_KD_COPY_ATTRS," & aList
  arr = Split(lst,",")
  
  For each attrname In arr
    Progress.Text = "Настройка системных атрибутов: " & attrname
    Select Case attrname
      Case "ATTR_AGREENENT_SETTINGS"
        Call Set_ATTR_AGREENENT_SETTINGS()
      Case "ATTR_KD_COPY_ATTRS"
        Call Set_ATTR_KD_COPY_ATTRS()
    End Select
  Next
End Sub

Sub Set_ATTR_KD_COPY_ATTRS()
  List =  "OBJECT_UNIT,ATTR_WORK_DOCS_FOR_BUILDING_TYPE," &_
          "OBJECT_UNIT,ATTR_LAND_USE_CATEGORY," &_
          "OBJECT_UNIT,ATTR_UNIT_TYPE," &_
          "OBJECT_UNIT,ATTR_BUILDING_STAGE," &_
          "OBJECT_UNIT,ATTR_UNIT_NAME," &_
          "OBJECT_UNIT,ATTR_STARTDATE_PLAN," &_
          "OBJECT_UNIT,ATTR_ENDDATE_PLAN"

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
        r.Attributes("ATTR_KD_OBJ_TYPE").value = arr(i)
        r.Attributes("ATTR_KD_ATTR").value = arr(i+1)
      End If
  Next
End Sub



Sub Set_ATTR_AGREENENT_SETTINGS()
  List = "OBJECT_T_TASK"
  arr = Split(List,",")
  
  ' Заполняем функцию в таблицу согласования
  Set Table = ThisApplication.Attributes("ATTR_AGREENENT_SETTINGS")
  
  For i = 0 To Ubound(arr)
    addrow = True
    For each row in Table.Rows
      If row.Attributes(0).Value = arr(i) Then
        addrow = False
        Exit For
      End If
    Next
    If Addrow = True Then 
      Set NewRow = Table.Rows.Create
      NewRow.Attributes(0).Value= arr(i)
    End If
  Next
    For each row in Table.Rows
      Select Case row.Attributes("ATTR_KD_OBJ_TYPE").Value
        Case "OBJECT_T_TASK"
          row.attributes(7).value = "CMD_DLL;CheckAgreeStatus"
          row.attributes(8).value = "OBJECT_T_TASK;TaskAgreeCheck"
      End Select
    Next
End Sub

Sub RemoveFromObjDef()
  Progress.Text = "Обновляются связи объекта:"
  ObjList = "OBJECT_VOLUME,OBJECT_DOC_DEV"
  ObjArr = Split(ObjList,",")
  
  For Each ObjDefName In ObjArr
    Progress.Text = "Обновляются связи объектов: " & ObjDefName
    Select Case ObjDefName
      Case "OBJECT_VOLUME"
        List = "FILE_AUTOCAD_DWG,FILE_E-THE_ORIGINAL,FILE_ANY,CMD_VOLUME_PASS_NK,CMD_VOLUME_APPROVE,CMD_VOLUME_SET_ARH_N"
      Case "OBJECT_DOC_DEV"
        List = "FILE_OBJECT_DOCUMENT"
    End Select
  
    arr = Split(List,",")
    For Each ObjSysName In arr
      call SystemObjRemoveFromObject(str0,ObjDefName,ObjSysName)
    Next
  Next
End Sub

Sub misc()
  Call RemoveRoleFromCommand("CMD_CONTRACT_STAGE_CREATE","ROLE_APPROVER")
  Call RemoveRoleFromCommand("CMD_DOC_INVALIDATED","ROLE_DOC_DEVELOPER")
  Call RemoveRoleFromCommand("CMD_DOC_INVALIDATED","ROLE_LEAD_DEVELOPER")
  Call RemoveRoleFromCommand("CMD_VOLUME_PASS_NK","ROLE_VOLUME_PASS_NK")
  Call RemoveRoleFromCommand("CMD_WORK_DOCS_SET_PASS_NK","ROLE_WORK_DOCS_SET_PASS_NK")
End Sub

Sub RefreshIcons()
  ' Иконки договоров
  Set q = ThisApplication.CreateQuery
  q.AddCondition tdmQueryConditionObjectDef, "='OBJECT_CONTRACT' or ='OBJECT_T_TASK'"
  Set root = q
  If Not root Is Nothing Then Call ThisApplication.ExecuteScript("CMD_REFRESH_ICONS","Run",root)
End Sub

Sub DeleteStatuses()
  Progress.Text = "Обновляются статусы"
    List = "STATUS_TENDER_IS_MATCHING,STATUS_DOC_IS_MATCHING,STATUS_TENDER_IN_IS_MATCHING,STATUS_TENDER_OUT_IS_MATCHING,STATUS_CONTRACT_AGREEMENT"
  Call SystemObjDelByList(List)
End Sub

Sub AddAttrs()
  ThisApplication.DebugPrint "AddAttrs"
  List = "OBJECT_VOLUME,ATTR_VOLUME_TYPE,ATTR_ARCH_DEPART:" &_
          "OBJECT_WORK_DOCS_SET,ATTR_ARCH_DEPART:" &_
          "OBJECT_CONTRACT_COMPL_REPORT,ATTR_KD_REGDATE:" &_
          "OBJECT_CONTRACT,ATTR_KD_REGDATE:" &_
          "OBJECT_AGREEMENT,ATTR_KD_REGDATE"
          
  Arr1 = Split(List,":")
  
  for each arr In Arr1
    Ar = Split(arr,",")
    For i = 1 To Ubound(ar)
      For each obj In ThisApplication.ObjectDefs(ar(0)).Objects
        If Obj.Attributes.Has(ar(i)) = False Then
          Obj.Attributes.Create ar(i)
        End If
      Next
    Next
  Next
End Sub

Sub DeleteClassifiers()
  List = "NODE_2B014CE7_8781_47A5_BF6D_6761FECC79D5,NODE_D67E3441_B6E1_4151_B765_4FD2FFB2F486,NODE_AFB7FA97_EB04_47DC_9308_41A145EC44CA"
  Call SystemObjDelByList(List)
End Sub

' Удаление объектов по списку
Sub DeleteObj()
  Progress.Text = "Удаляются типы объектов"
  list = "OBJECT_PROJECTS_DOCS," &_
  ""
Call SystemObjDelByList(List)
End Sub

Sub DeleteAttrs()
  Progress.Text = "Удаляются типы объектов"
  list = "ATTR_PROJECTS_DOCS_NAME," &_
  ""
  'ATTR_7C4FBE23_B08C_4B24_A6BF_5FC3D2FD83B4,ATTR_TENDER_CARD_ATTR_TABLE,ATTR_TENDER_RESP_USER,ATTR_TENDER_REASON_URGENTLY_FLAG
  Call SystemObjDelByList(List)
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
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "РУКОВОДСТВО" Then
      ARM = "TOP_MANAG"
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "РУКОВОДИТЕЛЬ ОТДЕЛА" Then
      ARM = "DEPT_CHIEF"
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ПЛАНИРОВАНИЕ" Then
      ARM = "PLAN"
    End If
    
    List = ""
    ListToRem = ""
    
    Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
    
  Select Case ARM
    Case "CONTRACT"
      List = "QUERY_DESCTOP_AGREEMENT_ACTIVE,QUERY_DESCTOP_CONTRACTS,QUERY_DESCTOP_CONTRACTS_BY_TYPE,QUERY_S_CONTRACT_MINE"
      ListToRem = "QUERY_DESCTOP_CONTRACT_TO_DO,QUERY_DESCTOP_CONTRACTS_DOCS_TO_AGREE,QUERY_DESCTOP_CONTRACT_DOCS," &_
                  "QUERY_DESCTOP_CONTRACTS_DOCS_ONSIGN"
      Call AddQuery(Obj,List,ListToRem)
    Case "NK"
      List = "QUERY_FOR_N,QUERY_ON_NK"
      Call AddQuery(Obj,List,ListToRem)
    Case "GIP"
      List = "QUERY_PROJECTS_EDIT,QUERY_DESCTOP_READY_FOR_ISSUE,SAMPLE_IO_TASKS"
      ListToRem = "QUERY_FOR_APPROVE"
      Call AddQuery(Obj,List,ListToRem)
    Case "TENDER"
      List = "QUERY_DESCTOP_TENDER_INSIDE,QUERY_DESCTOP_TENDER_OUTSIDE"
      ListToRem = "QUERY_DESCTOP_TENDER_DOCS_TO_AGREE"
      Call AddQuery(Obj,List,ListToRem)
    Case "ISSUE"
      List = "QUERY_INVOICE_DOCS_APPROVED,QUERY_DESCTOP_INVOICE_DOCS_READY_TO_ISSUE"
      ListToRem = "QUERY_INVOICE_DESCTOP,QUERY_DESCTOP_INVOICE_MY,QUERY_INVOICE_DOCS_ON_CHECK"
      Call AddQuery(Obj,List,ListToRem)
    Case "ISSUE_DT"
      List = "QUERY_INVOICE_DESCTOP,QUERY_DESCTOP_INVOICE_MY"
      ListToRem = "QUERY_PROJECTS_EDIT,QUERY_INVOICE_DOCS_ON_CHECK," &_
                  "QUERY_INVOICE_DOCS_APPROVED,QUERY_DESCTOP_INVOICE_DOCS_READY_TO_ISSUE"
      Call AddQuery(Obj,List,ListToRem)
    Case "TOP_MANAG"
      List = "CONTRACT_WORK_FOR_CURATOR,THE_MILESTONES_ON_THE_CONTRACTS_MY,ALL_SCHEDULED_TASKS"
      ListToRem = ""
      Call AddQuery(Obj,List,ListToRem)
    Case "DEPT_CHIEF"
      Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "CONTRACT_WORK_FOR_CURATOR,THE_MILESTONES_ON_THE_CONTRACTS_MY,ALL_SCHEDULED_TASKS"
      ListToRem = ""
      Call AddQuery(Obj,List,ListToRem)
    Case "PLAN"
      List = "SAMPLE_IO_TASKS"
      ListToRem = ""
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
