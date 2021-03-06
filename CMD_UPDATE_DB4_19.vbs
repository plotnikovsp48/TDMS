
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
    "Обновление базы от 21.11.2017")
  If ans<>vbYes Then Exit Sub
  
  Call Run()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub

Sub Run()

'================================= Новое обновление БД-4

Call SetSystemAttrs("")
progress.Position = 20
cALL AddAttrs()
progress.Position = 35
cALL SetExec()
progress.Position = 50
Call DeleteComm()
progress.Position = 60
Call DeleteForms()
progress.Position = 65
Call PanelSettingsAdd()
progress.Position = 80
Call DeleteQUERY()
progress.Position = 90

'===================================================  

End Sub

' Установка системных атрибутов
Sub SetSystemAttrs(aList)
  Progress.Text = "Настройка системных атрибутов"
  lst = "ATTR_STAGE_SETTINGS,ATTR_AGREENENT_SETTINGS," & aList
  arr = Split(lst,",")
  
  For each attrname In arr
    Progress.Text = "Настройка системных атрибутов: " & attrname
    Select Case attrname
      Case "ATTR_STAGE_SETTINGS"
        Call Set_ATTR_STAGE_SETTINGS()
      Case "ATTR_AGREENENT_SETTINGS"
        Call Set_ATTR_AGREENENT_SETTINGS()
    End Select
  Next
End Sub

Sub Set_ATTR_STAGE_SETTINGS()
  Set Table = ThisApplication.Attributes("ATTR_STAGE_SETTINGS")
  List = "Проект экологического мониторинга и контроля,,Проект экологического мониторинга и контроля"
  arr = Split(List,",")
  For i = 0 to Ubound(arr) step 3
  check = True
    For each row In Table.Rows
      If row.attributes("ATTR_PROJECT_STAGE").Classifier.Description = arr(i) Then 
        check = False
        Exit For
      End If
    Next
    If check Then
      Set cls = ThisApplication.Classifiers.Find(arr(i))
      Set cls1 = ThisApplication.Classifiers.Find(arr(i+1))
      Set cls2 = ThisApplication.Classifiers.Find(arr(i+2))
      If Not cls Is Nothing Then
        Set NewRow = Table.Rows.Create
        NewRow.Attributes(0).Classifier = cls
        If Not cls1 Is Nothing Then NewRow.Attributes(1).Classifier = ThisApplication.Classifiers.Find(arr(i+1))
        If Not cls2 Is Nothing Then NewRow.Attributes(2).Classifier = ThisApplication.Classifiers.Find(arr(i+2))
      End If
    End If
  Next
End Sub

Sub Set_ATTR_AGREENENT_SETTINGS()
  List = "OBJECT_T_TASK,OBJECT_DOCUMENT"
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
          row.attributes("ATTR_AFTER_FUNCTION").value = "OBJECT_T_TASK;TaskAgreeCheck"
        Case "OBJECT_DOCUMENT"
          row.attributes(0).value = "OBJECT_DOCUMENT"
          row.attributes(1).value = "STATUS_DOCUMENT_CREATED"
          row.attributes(2).value = "STATUS_DOCUMENT_AGREED"
          row.attributes(3).value = "STATUS_DOCUMENT_DEVELOPED"
          row.attributes(7).value = "CMD_DLL;CheckAgreeStatus"
          row.attributes(10).value = "CMD_DLL_ROLES;Set_Tech_Permission"
      End Select
    Next
End Sub

Sub DeleteComm()
Progress.Text = "Обновляются команды"
List = "CMD_REP_AGREE_TENDER,CMD_EEFD583D_20E7_424D_8BA4_D506600D57BC,CMD_TASK_DEVELOPER_APPOINT"
Call SystemObjDelByList(List)
End Sub

Sub DeleteForms()
ThisScript.SysAdminModeOn
Progress.Text = "Удаление форм:"
  list = "FORM_NK,FORM_CCR_ZA_PAYMENT,FORM_TENDER_PLAN-OLD"
  Call SystemObjDelByList(List)
End Sub

Sub PanelSettingsAdd()
  Set Objs = ThisApplication.ObjectDefs("OBJECT_PANEL_CONFIG")
  If Objs.Objects.Count = 0 Then Exit Sub
  Set Obj = Objs.Objects(0)
  Set Table = Obj.Attributes("ATTR_PANEL_CONFIG_TAB")
  List = "PROFILE_GIP,,False," &_
         "PROFILE_NK,{D4A5BFDD-0D62-4DA6-9F0E-8758A2EB819C},True," &_
         "PROFILE_COMPL,{0F20E044-FACA-4641-9B7D-020A0BEA7CAD},True," &_
         "PROFILE_ARM_DEVELOPERS,,False," &_
         "PROFILE_CONTRACTS_MANAGEMENT,,False," &_
         "PROFILE_P_PLANING,,False," &_
         "PROFILE_TENDER,,False"
         
  arr = Split(List,",")
  For i = 0 to Ubound(arr) step 3
    Addrow = True
    For Each Row In Table.Rows
      If row.attributes(0).Value = arr(i) Then
        Addrow = False
        Exit For 
      End If
    Next
    
    If Addrow = True Then
      Set NewRow = Table.Rows.Create
    Else
      Set NewRow = row
    End If
    
    NewRow.attributes(0).Value = arr(i)
    NewRow.attributes(1).Value = arr(i+1)
    NewRow.attributes(2).Value = arr(i+2)
    
  Next
End Sub

Sub DeleteQUERY()
List = "QUERY_REFFERENCED_DOCS,QUERY_75BCFCDF_809A_42DD_8E23_FE280BECD868"
Call SystemObjDelByList(List)
End Sub

' Заполняем функцию в таблицу согласования
Sub Set_ATTR_KD_T_FORMS_SHOW()
  List = "OBJECT_CONTRACT,STATUS_CONTRACT_DRAFT,FORM_CONTRACT," & _
          "OBJECT_CONTRACT,STATUS_CONTRACT_FOR_SIGNING,FORM_CONTRACT," & _
          "OBJECT_CONTRACT,STATUS_CONTRACT_COMPLETION,FORM_CONTRACT," & _
          "OBJECT_CONTRACT,STATUS_CONTRACT_PAUSED,FORM_CONTRACT," & _
          "OBJECT_CONTRACT,STATUS_CONTRACT_CLOSED,FORM_CONTRACT," & _
          "OBJECT_CONTRACT,STATUS_CONTRACT_SIGNED,FORM_CONTRACT"

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

Sub AddAttrs()
  ThisApplication.DebugPrint "AddAttrs"
  List = "OBJECT_DOC_DEV,ATTR_DOC_CODE,ATTR_UNIT,ATTR_RESPONSIBLE,ATTR_DOCUMENT_NAME,ATTR_INF_T,ATTR_INF,ATTR_CHECK_LIST:"  & _
          "OBJECT_CONTRACT_COMPL_REPORT,ATTR_KD_EXEC,ATTR_KD_NOTE:"  & _
          "OBJECT_PURCHASE_OUTSIDE,ATTR_KD_EXEC,ATTR_KD_NOTE:"  & _
          "OBJECT_TENDER_INSIDE,ATTR_KD_EXEC,ATTR_KD_NOTE:"  & _
          "OBJECT_CONTRACT,ATTR_KD_EXEC,ATTR_KD_NOTE:"  & _
          "OBJECT_AGREEMENT,ATTR_KD_EXEC,ATTR_KD_NOTE:"  & _
          "OBJECT_T_TASK,ATTR_KD_EXEC,ATTR_KD_NOTE:"  & _
          "OBJECT_DOC,ATTR_KD_EXEC,ATTR_KD_NOTE"':"  & _
'          "OBJECT_LIST_AN,ATTR_KD_EXEC,ATTR_KD_NOTE:"  & _
'          "OBJECT_DOCUMENT_AN,ATTR_KD_EXEC,ATTR_KD_NOTE:" & _
'          "OBJECT_DOCUMENT,ATTR_KD_EXEC,ATTR_KD_NOTE"
          '          "OBJECT_DRAWING,ATTR_KD_EXEC,ATTR_KD_NOTE:"  & _
'          "OBJECT_DOC_DEV,ATTR_KD_EXEC,ATTR_KD_NOTE:"  & _
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


Sub AddSearchQueries()
  Set Obj = ThisApplication.GetObjectByGUID("{CB841149-1125-45E0-BB2B-2ECE14BA8357}")
  If Obj Is Nothing Then
  For each Obj In ThisApplication.ObjectDefs("OBJECT_ARM_FOLDER").Objects
    If Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ПОИСК" Then
      Exit For
    End If
  Next
  End If
    Call AddQueryToObj(Obj,"QUERY_S_ARCH_DOCS")
End Sub

Sub RemoveFromObjDef()
  Progress.Text = "Обновляются связи объекта:"
  ObjList = "OBJECT_VOLUME"
  ObjArr = Split(ObjList,",")
  
  For Each ObjDefName In ObjArr
    Progress.Text = "Обновляются связи объектов: " & ObjDefName
    Select Case ObjDefName
      Case "OBJECT_VOLUME","OBJECT_WORK_DOCS_SET"
        List = "FORM_KD_AGREE"
    End Select
  
    arr = Split(List,",")
    For Each ObjSysName In arr
      call SystemObjRemoveFromObject(str0,ObjDefName,ObjSysName)
    Next
  Next
End Sub


Sub SetExec()
  ThisApplication.DebugPrint "SetExec"
  List = "OBJECT_CONTRACT_COMPL_REPORT,OBJECT_CONTRACT,OBJECT_AGREEMENT,OBJECT_DRAWING,OBJECT_DOC_DEV,"  & _
          "OBJECT_LIST_AN,OBJECT_DOCUMENT_AN,OBJECT_DOCUMENT,OBJECT_T_TASK"
  Arr = Split(List,",")
  
  for each ar In Arr
    For each obj In ThisApplication.ObjectDefs(ar).Objects
      If Obj.Attributes.Has("ATTR_T_TASK_DEVELOPED") Then
        Set User = Obj.Attributes("ATTR_T_TASK_DEVELOPED").User 
      ElseIf Obj.Attributes.Has("ATTR_RESPONSIBLE") Then
        Set User = Obj.Attributes("ATTR_RESPONSIBLE").User
      ElseIf Obj.Attributes.Has("ATTR_AUTOR") Then
        Set User = Obj.Attributes("ATTR_AUTOR").User
      End If
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", obj, "ATTR_KD_EXEC", User, True
    Next
  Next
End Sub
