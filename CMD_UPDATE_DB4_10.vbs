
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
    "Обновление базы от 19.10.2017")
  If ans<>vbYes Then Exit Sub
  
  Call Run()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub

Sub Run()

'================================= Новое обновление БД-4
Call ObjAttrsSync()
Call SetSystemAttrs("")

End Sub


Sub ObjAttrsSync()
  Progress.Text = "Обновление атрибутов объекта:"
  List =  "OBJECT_VOLUME"

  Call ObjAttrSync(List)
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
  List = "OBJECT_DOCUMENT,STATUS_DOCUMENT_CREATED,STATUS_DOCUMENT_AGREED,STATUS_DOCUMENT_DEVELOPED,CMD_DLL_ROLES;Set_Tech_Permission,CMD_DLL;CheckAgreeStatus"
  arr = Split(List,",")
  For i=0 to Ubound(arr) Step 6
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
        r.attributes("ATTR_KD_CHECK_FUNCTION").value = arr(i+5)
        
      End If
   Next
  
  ' Заполняем функцию в таблиу согласования
  Set Table = ThisApplication.Attributes("ATTR_AGREENENT_SETTINGS")
    For each row in Table.Rows
      Select Case row.Attributes("ATTR_KD_OBJ_TYPE").Value
        Case "OBJECT_PURCHASE_OUTSIDE"
          row.attributes("ATTR_KD_FINISH_STATUS").value = "STATUS_TENDER_OUT_IS_APPROVING"
          row.attributes("ATTR_KD_START_STATUS").value = "STATUS_TENDER_OUT_ADD_APPROVED;STATUS_TENDER_OUT_IN_WORK;STATUS_TENDER_OUT_PUBLIC"
      End Select
    Next
End Sub

