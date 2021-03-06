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
    "Обновление базы от 19.01.2018")
  If ans<>vbYes Then Exit Sub
  
  Call Run()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub

Sub Run()

'================================= Новое обновление БД-4
Call UpdatePlantTask()
progress.Position = 5
Call ThisApplication.ExecuteScript("CMD_Update_Project_Q","Run")
progress.Position = 15
Call UpdateRolesForContracts()
progress.Position = 90
Call PanelQueriesUpdate()
progress.Position = 95
Call AddSearchQueries()
'===================================================  

End Sub

Sub UpdatePlantTask()
  Set Col = ThisApplication.ObjectDefs("OBJECT_P_TASK").Objects
  For each Obj In Col
    progress.text = "Обновление задачи: " & Obj.Description
    Obj.Permissions = SysadminPermissions
    Call ThisApplication.ExecuteScript("OBJECT_P_TASK","SetPlanTaskRoles",Obj)
  Next
End Sub

Sub UpdateRolesForContracts()
  Set Col = ThisApplication.ObjectDefs("OBJECT_CONTRACT").Objects
  For each Obj In Col
    progress.text = "Обновление ролей договора: " & Obj.Description
    Obj.Permissions = SysadminPermissions
    ' Замена роли Ограниченный просмотр договоров на Права:Ограниченный просмотр
    For each role In Obj.RolesByDef("ROLE_VIEW_CONTRACTS")
      If ThisApplication.Groups.Has(role.Group) Then Set u = role.Group
      If ThisApplication.Groups.Has(role.User) Then Set u = role.User
      If Not u Is Nothing Then 
        role.erase
        Set NewRole = Obj.Roles.Create("ROLE_VIEW_ONLY",u)
        NewRole.Inheritable = False
      End If
    Next
    If Obj.Roles.Has("ROLE_VIEW_ONLY")= False Then
      Set NewRole = Obj.Roles.Create ("ROLE_VIEW_ONLY",ThisApplication.Groups("ALL_USERS"))
      NewRole.Inheritable = False
    End If
    ' Добавляем роль для закупщиков
    ' Str 20/01/2018
    If Obj.Roles.Has("ROLE_TENDER_EDIT_FOR_CONTRACTS")= False Then
      Set NewRole = Obj.Roles.Create ("ROLE_TENDER_EDIT_FOR_CONTRACTS",ThisApplication.Groups("GROUP_TENDER"))
      NewRole.Inheritable = False
    End If
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
     If 1 = 2 Then
'    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "УПРАВЛЕНИЕ ДОГОВОРАМИ" Then
'      ARM = "CONTRACT"
'    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ЗАКУПКИ" Then
'      ARM = "TENDER"
'    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "АРМ ГИПа" Then
'      ARM = "GIP"
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "НОРМОКОНТРОЛЬ" Then
      ARM = "NK"
'    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ВЫПУСК ДОКУМЕНТАЦИИ" OR Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "АРМ Комплектация документации" Then
'      Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ВЫПУСК ДОКУМЕНТАЦИИ"
'      ARM = "ISSUE"
'    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ВЫПУСК ДОКУМЕНТАЦИИ (РС)" Then
'      ARM = "ISSUE_DT"
'    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "РУКОВОДСТВО" Then
'      ARM = "TOP_MANAG"
'    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "РУКОВОДИТЕЛЬ ОТДЕЛА" Then
'      ARM = "DEPT_CHIEF"
'    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ДОКУМЕНТЫ" Then
'      ARM = "DOCS"
'    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ПЛАНИРОВАНИЕ" Then
'      ARM = "PLAN"
'    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ПРОИЗВОДСТВЕННЫЙ ОТДЕЛ" Then
'      ARM = "DEPT"
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
      List = "QUERY_FOR_N,QUERY_ON_NK,QUERY_NK_DOCS_NOT_FINISHED"
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
      List = "QUERY_DESCTOP_VOLUMES_SETS_MY,QUERY_DESCTOP_IN_TASKS_PLAN,QUERY_DESCTOP_IN_TASKS,QUERY_DESCTOP_OUT_TASKS"
      ListToRem = "QUERY_DESCTOP_DOCS_ONSIGN,QUERY_DESCTOP_DOCS_TO_AGREE"
      Call AddQuery(Obj,List,ListToRem)
    Case "DOCS"
      Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_DESCTOP_DOC_MY,QUERY_VOLUMES_AND_SUITES,QUERY_DESCTOP_IN_TASKS,QUERY_DESCTOP_OUT_TASKS"
      ListToRem = "QUERY_SESCTOP_DOC_DEVELOP_MY,QUERY_DESCTOP_DOCS_TO_AGREE,QUERY_DESCTOP_DOCS_ONSIGN"
      Call AddQuery(Obj,List,ListToRem)
    Case "DEPT"
      Progress.Text = "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
      List = "QUERY_DESCTOP_DOC_MY,QUERY_DESCTOP_IN_TASKS_PLAN,QUERY_DESCTOP_IN_TASKS,QUERY_DESCTOP_OUT_TASKS,QUERY_VOLUMES_AND_SUITES,QUERY_DESCTOP_VOLUMES_SETS_MY"
      ListToRem = "QUERY_DESCTOP_VOLUMES_SETS_MY"
      Call AddQuery(Obj,List,ListToRem)
    Case "PLAN"
      List = "SAMPLE_IO_TASKS"
      ListToRem = ""
      Call AddQuery(Obj,List,ListToRem)
  End Select
Next  
 
  List = "QUERY_DESCTOP_VOLUMES_SETS_MY,QUERY_WORK_SETS_IS_DEVELOPING_MY,QUERY_DESCTOP_VOLUMES_SETS_MY_AGREED,QUERY_DESCTOP_VOLUMES_SETS_MY_NK,QUERY_DESCTOP_VOLUMES_SETS_MY_APPROVED"
  Call AddSubQuery(List)
  
  List = "QUERY_DESCTOP_DOC_MY,QUERY_SESCTOP_DOC_DEVELOP_MY,QUERY_DESCTOP_TASKS_DEVELOP_MY"
  Call AddSubQuery(List)
  
  List = "QUERY_DESCTOP_CONTRACT_DOCS,QUERY_DESCTOP_CONTRACT_DOCS_MY,QUERY_DESCTOP_AGREEMENT_ACTIVE"
  'Call AddSubQuery(List)
  
  List = "QUERY_DESCTOP_CONTRACTS,QUERY_DESCTOP_CONTRACTS_COMPLETION,QUERY_DESCTOP_CONTRACTS_ONCONTRACTOR,QUERY_DESCTOP_CONTRACTS_ONSIGN," &_
          "QUERY_DESCTOP_CONTRACTS_PAUSED,QUERY_DESCTOP_CONTRACTS_ONAGREEMENT"
  'Call AddSubQuery(List)
  
  List = "QUERY_DESCTOP_CONTRACTS_BY_TYPE,QUERY_DESCTOP_CONTRACTS_BY_TYPE_PRO,QUERY_DESCTOP_CONTRACTS_BY_TYPE_EXP,QUERY_DESCTOP_CONTRACTS_BY_TYPE_GPH," &_
         "QUERY_DESCTOP_CONTRACTS_BY_TYPE_SALES,QUERY_DESCTOP_CONTRACTS_BY_TYPE_OU,QUERY_DESCTOP_CONTRACTS_BY_TYPE_OTHER" 
  'Call AddSubQuery(List)
End Sub


Sub AddSearchQueries()
  Set Obj = ThisApplication.GetObjectByGUID("{CB841149-1125-45E0-BB2B-2ECE14BA8357}")
  If Obj Is Nothing Then
  For each Obj In ThisApplication.ObjectDefs("OBJECT_ARM_FOLDER").Objects
    If Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ПОИСК" Then
      Exit For
    End If
  Next
  End If
    Call AddQueryToObj(Obj,"QUERY_S_T_TASK")
End Sub

