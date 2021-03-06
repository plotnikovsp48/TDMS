
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
    "Обновление базы от 25.09.2017")
  If ans<>vbYes Then Exit Sub
  
  Call Run()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub

Sub Run()

'================================= Новое обновление БД-4
  Call DeleteComm()
  Call DeleteQUERY()
  Call DeleteObj() 
  Call DeleteAttrs()
  Call RemoveFromObjDef()
  Call ObjAttrsSync()
  Call misc()
    progress.Position = 60
  Call SetSystemAttrs("")
End Sub

Sub DeleteComm()
Progress.Text = "Обновляются команды"
List = "CMD_WORK_DOCS_SET_APPROVE,CMD_WORK_DOCS_SET_TO_APPROVING,CMD_VOLUME_TO_APPROVING,CMD_WORK_DOCS_SET_INVALIDATED"
Call SystemObjDelByList(List)
End Sub

Sub DeleteQUERY()
List = "QUERY_COMMENTS,QUERY_FAVORIT1,QUERY_CONTRACTS_FAVORIT,QUERY_TASK_FAVORIT,QUERY_TENDER_FAVORIT"
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
  ObjList = "OBJECT_WORK_DOCS_FOR_BUILDING,OBJECT_WORK_DOCS_SET,OBJECT_TENDER_INSIDE"
  ObjArr = Split(ObjList,",")
  
  For Each ObjDefName In ObjArr
    Progress.Text = "Обновляются связи объектов: " & ObjDefName
    Select Case ObjDefName
      Case "OBJECT_WORK_DOCS_FOR_BUILDING"
        List = "ATTR_CONTRACT_STAGE"
      Case "OBJECT_WORK_DOCS_SET"
        List = "ATTR_CONTRACT_STAGE"
      Case "OBJECT_TENDER_INSIDE"
        List = "ATTR_TENDER_ANALOG"
    End Select
  
    arr = Split(List,",")
    For Each ObjSysName In arr
      call SystemObjRemoveFromObject(str0,ObjDefName,ObjSysName)
    Next
  Next
End Sub

Sub ObjAttrsSync()
  Progress.Text = "Обновление атрибутов объекта:"
  List =  "OBJECT_WORK_DOCS_FOR_BUILDING,OBJECT_WORK_DOCS_SET,OBJECT_TENDER_INSIDE"

  Call ObjAttrSync(List)
End Sub


Sub misc()
  Progress.Text = "Обновление атрибутов объекта:"
  ThisApplication.ObjectDefs("OBJECT_TENDER_INSIDE").AttributeDefs.Add Thisapplication.AttributeDefs("ATTR_TENDER_ANALOG")
  List =  "OBJECT_TENDER_INSIDE"
  Call ObjAttrSync(List)
  
  
  If ThisApplication.FileDefs.Has("FILE_CONTRACT") Then
    Set fDef = ThisApplication.FileDefs("FILE_CONTRACT")
      If fDef.Templates.Has("Акт.docx") Then fDef.Templates("Акт.docx").Erase
      If fDef.Templates.Has("Соглашение.docx") Then fDef.Templates("Соглашение.docx").Erase
      If fDef.Templates.Has("Шаблон договора.docx") Then fDef.Templates("Шаблон договора.docx").Erase
  End If
  If ThisApplication.FileDefs.Has("FILE_T_TEMPLATE") Then
    Set fDef = ThisApplication.FileDefs("FILE_T_TEMPLATE")
      If fDef.Templates.Has("default.docx") Then
        fDef.Templates("default.docx").Erase
      End If
  End If
  If ThisApplication.FileDefs.Has("FILE_TRANSFER_DOCUMENT") Then
    Set fDef = ThisApplication.FileDefs("FILE_TRANSFER_DOCUMENT")
    If fDef.Templates.Has("Ведомость ЭВКД.xls") Then fDef.Templates("Ведомость ЭВКД.xls").Erase
    If fDef.Templates.Has("ЭВКД.docx") Then fDef.Templates("ЭВКД.docx").Erase
    If fDef.Templates.Has("Передаточный_документ_(шаблон).docx") Then fDef.Templates("Передаточный_документ_(шаблон).docx").Erase
  End If
End Sub

' Установка системных атрибутов
Sub SetSystemAttrs(aList)
  Progress.Text = "Настройка системных атрибутов"
  lst = "ATTR_STRU_OBJ_SETTINGS," & aList
  arr = Split(lst,",")
  
  For each attrname In arr
    Progress.Text = "Настройка системных атрибутов: " & attrname
    Select Case attrname
      Case "ATTR_STRU_OBJ_SETTINGS"
        Call Set_ATTR_STRU_OBJ_SETTINGS()
    End Select
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
