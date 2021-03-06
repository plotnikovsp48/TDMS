
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
    "Обновление базы от 27.12.2017")
  If ans<>vbYes Then Exit Sub
  
  Call Run()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub

Sub Run()

'================================= Новое обновление БД-4
Call DeleteClassifiers()
progress.Position = 30
Call SetSystemAttrs("")
progress.Position = 60
Call PanelQueriesUpdate()
progress.Position = 100
'===================================================  

End Sub

Sub DeleteClassifiers()
  List = "NODE_D4C6DD35_EEA2_451C_8FD6_DECEA50BB5CE"
  Call SystemObjDelByList(List)
End Sub


' Установка системных атрибутов
Sub SetSystemAttrs(aList)
  Progress.Text = "Настройка системных атрибутов"
  lst = "ATTR_KD_T_FORMS_SHOW," & aList
  arr = Split(lst,",")
  
  For each attrname In arr
    Progress.Text = "Настройка системных атрибутов: " & attrname
    Select Case attrname
      Case "ATTR_KD_T_FORMS_SHOW"
        Call Set_ATTR_KD_T_FORMS_SHOW()
    End Select
  Next
End Sub

' Заполняем функцию в таблицу согласования
Sub Set_ATTR_KD_T_FORMS_SHOW()
'  List = "OBJECT_KD_DOC_IN,STATUS_KD_DRAFT,FORM_ID_CARD," & _
'"OBJECT_KD_DOC_IN,STATUS_KD_VIEWED_RUK,FORM_KD_DOC_ORDERS," & _
'"OBJECT_KD_DOC_OUT,STATUS_KD_DRAFT,FORM_KD_DOC_AGREE," & _
'"OBJECT_KD_DOC_OUT,CREATE,FORM_OUT_CREATE," & _
'"OBJECT_KD_DOC_OUT,STATUS_SIGNED,FORM_KD_OUT_CARD," & _
'"OBJECT_KD_DOC_OUT,STATUS_SENT,FORM_KD_OUT_CARD," & _
'"OBJECT_KD_DIRECTION,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
'"OBJECT_KD_DIRECTION,STATUS_KD_DRAFT,FORM_KD_DOC_AGREE," & _
'"OBJECT_KD_DIRECTION,CREATE,FORM_ORD_CREATE," & _
'"OBJECT_KD_DIRECTION,STATUS_SIGNED,FORM_KD_DOC_ORDERS," & _
'"OBJECT_KD_DIRECTION,STATUS_KD_IN_FORCE,FORM_KD_DOC_ORDERS," & _
'"OBJECT_KD_MEMO,STATUS_KD_DRAFT,FORM_KD_MEMO_CARD," & _
'"OBJECT_KD_MEMO,CREATE,FORM_KD_MEMO_CREATE," & _
'"OBJECT_KD_MEMO,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
'"OBJECT_KD_MEMO,STATUS_SIGNED,FORM_KD_DOC_AGREE," & _
'"OBJECT_KD_MEMO,STATUS_KD_APPROVED,FORM_KD_DOC_ORDERS," & _
'"OBJECT_KD_ZA_PAYMENT,CREATE,FORM_KD_AP_CREATE," & _
'"OBJECT_KD_ZA_PAYMENT,STATUS_KD_DRAFT,FORM_KD_DOC_AGREE," & _
'"OBJECT_KD_ZA_PAYMENT,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
'"OBJECT_KD_ZA_PAYMENT,STATUS_SIGNING,FORM_KD_DOC_AGREE," & _
'"OBJECT_KD_ZA_PAYMENT,STATUS_SIGNED,FORM_KD_DOC_ORDERS," & _
'"OBJECT_KD_PROTOCOL,CREATE,FORM_PROTOCOL_CREATE," & _
'"OBJECT_KD_PROTOCOL,STATUS_KD_DRAFT,FORM_KD_DOC_AGREE," & _
'"OBJECT_KD_PROTOCOL,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
'"OBJECT_KD_PROTOCOL,STATUS_SIGNED,FORM_KD_DOC_ORDERS," & _
'"OBJECT_PURCHASE_OUTSIDE,STATUS_TENDER_OUT_PLANING,FORM_TENDER_OUTSIDE_MAIN," & _
'"OBJECT_PURCHASE_OUTSIDE,STATUS_KD_AGREEMENT,FORM_TENDER_OUTSIDE_MAIN," & _
'"OBJECT_T_TASK,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
'"OBJECT_CONTRACT,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
'"OBJECT_AGREEMENT,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
'"OBJECT_CONTRACT_COMPL_REPORT,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
'"OBJECT_INVOICE,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
'"OBJECT_DOC_DEV,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
'"OBJECT_DOC_DEV,STATUS_DOCUMENT_IS_SENT_TO_NK,FORM_DOC_NK," & _
'"OBJECT_DOC_DEV,STATUS_DOCUMENT_IS_TAKEN_NK,FORM_DOC_NK," & _
'"OBJECT_DRAWING,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
'"OBJECT_DRAWING,STATUS_DOCUMENT_IS_SENT_TO_NK,FORM_DOC_NK," & _
'"OBJECT_DRAWING,STATUS_DOCUMENT_IS_TAKEN_NK,FORM_DOC_NK," & _
'"OBJECT_DOCUMENT,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
'"OBJECT_DOCUMENT_AN,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
'"OBJECT_LIST_AN,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
'"OBJECT_CONTRACT,STATUS_CONTRACT_DRAFT,FORM_CONTRACT," & _
'"OBJECT_CONTRACT,STATUS_CONTRACT_FOR_SIGNING,FORM_CONTRACT," & _
'"OBJECT_CONTRACT,STATUS_CONTRACT_COMPLETION,FORM_CONTRACT," & _
'"OBJECT_CONTRACT,STATUS_CONTRACT_PAUSED,FORM_CONTRACT," & _
'"OBJECT_CONTRACT,STATUS_CONTRACT_CLOSED,FORM_CONTRACT," & _
'"OBJECT_CONTRACT,STATUS_CONTRACT_SIGNED,FORM_CONTRACT," & _
 List =  "OBJECT_T_TASK,STATUS_T_TASK_IN_WORK,FORM_S_TASK," & _
          "OBJECT_T_TASK,STATUS_T_TASK_IS_CHECKING,FORM_S_TASK," & _
          "OBJECT_T_TASK,STATUS_T_TASK_IS_SIGNING,FORM_S_TASK," & _
          "OBJECT_T_TASK,STATUS_T_TASK_IS_SIGNED,FORM_KD_DOC_AGREE," & _
          "OBJECT_T_TASK,STATUS_T_TASK_IS_APPROVING,FORM_S_TASK," & _
          "OBJECT_T_TASK,STATUS_T_TASK_APPROVED,FORM_S_TASK," & _
          "OBJECT_T_TASK,STATUS_T_TASK_INVALIDATED,FORM_S_TASK"

  arr = Split(List,",")
  Set Table = ThisApplication.Attributes("ATTR_KD_T_FORMS_SHOW")
  NeedToAdd = False
  For i = 0 to Ubound(arr) step 3
    For each row in Table.Rows
        If (row.Attributes("ATTR_KD_OBJ_TYPE").Value = arr(i) And _
          row.Attributes("ATTR_KD_START_STATUS").Value = arr(i+1) And _
          row.Attributes("ATTR_KD_FORMS_LIST").Value = arr(i+2)) = False Then
          NeedToAdd = True
        Else
          NeedToAdd = False
          Exit For
        End If
    Next
    If NeedToAdd Then
      Set NewRow = Table.Rows.Create
      NewRow.Attributes("ATTR_KD_OBJ_TYPE") = arr(i) 
      NewRow.Attributes("ATTR_KD_START_STATUS") = arr(i+1) 
      NewRow.Attributes("ATTR_KD_FORMS_LIST") = arr(i+2) 
      NeedToAdd = False
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
    If Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "УПРАВЛЕНИЕ ДОГОВОРАМИ" Then
'      ARM = "CONTRACT"
'    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ЗАКУПКИ" Then
'      ARM = "TENDER"
'    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "АРМ ГИПа" Then
'      ARM = "GIP"
'    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "НОРМОКОНТРОЛЬ" Then
'      ARM = "NK"
'    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ВЫПУСК ДОКУМЕНТАЦИИ" OR Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "АРМ Комплектация документации" Then
'      Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ВЫПУСК ДОКУМЕНТАЦИИ"
'      ARM = "ISSUE"
'    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ВЫПУСК ДОКУМЕНТАЦИИ (РС)" Then
'      ARM = "ISSUE_DT"
'    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "РУКОВОДСТВО" Then
'      ARM = "TOP_MANAG"
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "РУКОВОДИТЕЛЬ ОТДЕЛА" Then
      ARM = "DEPT_CHIEF"
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ДОКУМЕНТЫ" Then
      ARM = "DOCS"
'    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ПЛАНИРОВАНИЕ" Then
'      ARM = "PLAN"
    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ПРОИЗВОДСТВЕННЫЙ ОТДЕЛ" Then
      ARM = "DEPT"
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
