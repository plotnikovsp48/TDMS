
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
    "Обновление базы от 17.11.2017")
  If ans<>vbYes Then Exit Sub
  
  Call Run()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub

Sub Run()

'================================= Новое обновление БД-4

Call SetSystemAttrs("")
progress.Position = 20
cALL AddAttrs()
progress.Position = 50
progress.Position = 60

'progress.Position = 65
'progress.Position = 80
'progress.Position = 80
progress.Position = 90

'===================================================  

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
      Case "ATTR_STRU_OBJ_SETTINGS"
        Call Set_ATTR_STRU_OBJ_SETTINGS()
    End Select
  Next
End Sub

Sub Set_ATTR_STRU_OBJ_SETTINGS()
  List =  "ID_CCR_SIGNER,Бухгалтерия,Визирует акты," & _
          "ID_CCR_RETURN_ORDER,Центр мониторинга,Подготавливает исходящее подрядчику о возврате акта," & _
          "ID_MONIT_CENTER,Центр мониторинга,Центр мониторинга," & _
          "ID_TENDER_IN_DEPT,Группа планирования и проведения конкурентных закупок,," & _
          "ID_TENDER_OUT_DEPT,Группа по участию в конкурентных закупках,," & _
          "ID_TENDER_CREATE,Группа планирования и проведения конкурентных закупок,"


  Set Table = ThisApplication.Attributes("ATTR_STRU_OBJ_SETTINGS")
  
  arr = Split(List, ",")
  For i=0 To Ubound(arr) Step 3
    For each row in Table.Rows
    Set r = Nothing
      If row.attributes("ATTR_ID").value = arr(i) Then
        check = true
        Exit For
      Else
        check = false
      End If
    Next
      Set os = ThisApplication.ObjectDefs("OBJECT_STRU_OBJ").Objects
        For Each o in os
          If o.Attributes("ATTR_NAME").value = arr(i+1) Then
            exit for
          End If
        Next
      If check = False Then
        If IsEmpty(o) = False Then
          set r = Table.Rows.Create
        End If
      Else
        If IsEmpty(o) = False Then
          Set r = Row
        End If
      End If
      If Not r Is Nothing Then
        r.Attributes("ATTR_ID").value = arr(i)
        r.Attributes("ATTR_DEPT").Object = o
        r.Attributes("ATTR_INF").value = arr(i+2)  
      End If
  Next
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
  List = "OBJECT_CONTRACT,ATTR_LOT,ATTR_EIS_PUBLISH_FACT,ATTR_FULFILLDATE_FACT,ATTR_PREVIOUS_STATUS:" & _
          "OBJECT_T_TASK,ATTR_KD_EXEC" 
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
