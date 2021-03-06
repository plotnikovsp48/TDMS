
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
    "Обновление базы от 04.12.2017")
  If ans<>vbYes Then Exit Sub
  
  Call Run()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub

Sub Run()

'================================= Новое обновление БД-4

Call RemoveFromObjDef()
  progress.Position = 20
Call SetSystemAttrs("")
  progress.Position = 50
Call misc()
Call AddAttrs()
Call RefreshIcons()
  progress.Position = 90

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
  ObjList = "OBJECT_STAGE,OBJECT_WORK_DOCS_SET,OBJECT_BOD,OBJECT_DOC_DEV,OBJECT_DOCUMENT,OBJECT_DRAWING"
  ObjArr = Split(ObjList,",")
  
  For Each ObjDefName In ObjArr
    Progress.Text = "Обновляются связи объектов: " & ObjDefName
    Select Case ObjDefName
      Case "OBJECT_STAGE"
        List = "FORM_KD_AGREE"
      Case "OBJECT_WORK_DOCS_SET","OBJECT_VOLUME"
        List = "FORM_KD_AGREE,FILE_AUTOCAD_DWG,FILE_E-THE_ORIGINAL,FILE_ANY"
      Case "OBJECT_BOD"
        List = "OBJECT_DOCUMENT_AN,STATUS_DOCUMENT_IS_APPROVING"
      Case "OBJECT_DOC_DEV"
        List = "FILE_DOC_PDF"
      Case "OBJECT_DOCUMENT"
        List = "FILE_DOC_DOC"
      Case "OBJECT_DRAWING"
        List = "FILE_ANY,STATUS_DOCUMENT_IS_APPROVING"
      
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


Sub AddAttrs()
  ThisApplication.DebugPrint "AddAttrs"
  List = "OBJECT_UNIT,ATTR_STARTDATE_PLAN,ATTR_ENDDATE_PLAN,ATTR_LAND_USE_CATEGORY,ATTR_WORK_DOCS_FOR_BUILDING_TYPE:" &_
  "OBJECT_PURCHASE_FOLDER,ATTR_TENDER_OUT_ORDER_TO_WORK_CASTOM:" &_
  "OBJECT_PURCHASE_OUTSIDE,ATTR_TENDER_OUT_ORDER_TO_WORK_CASTOM:" &_
  "OBJECT_T_TASK,ATTR_KD_NOTE"

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


