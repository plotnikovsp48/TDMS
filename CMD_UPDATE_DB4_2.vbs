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
    "Микрообновление базы от 21.08.2017")
  If ans<>vbYes Then Exit Sub
  
  Call Run()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub

Sub Run()

'================================= Новое обновление БД-4
  Call ObjAttrsSync()
  progress.Position = 25
  Call Set_Stage()
  progress.Position = 85
  Progress.Text = "Обновление выборок стадий:"
  Call ThisApplication.ExecuteScript("CMD_Update_STAGE_Q","Run")
  progress.Position = 100
End Sub

' Синхронизация атрибутов объектов
Sub ObjAttrsSync()
  Progress.Text = "Обновление атрибутов объекта:"
  List =  "OBJECT_INVOICE,OBJECT_WORK_DOCS_SET,OBJECT_PURCHASE_OUTSIDE"
          
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


Sub Set_Stage()
  List = "OBJECT_WORK_DOCS_FOR_BUILDING,OBJECT_WORK_DOCS_SET,OBJECT_PROJECT_SECTION_SUBSECTION,OBJECT_PROJECT_SECTION,OBJECT_VOLUME"

  arr = Split(List,",")
  For i = 0 to Ubound(arr)
    Progress.Text = "Заполнение атрибута Стадия: " & arr(i)
    Call SetStage(arr(i))
  Next
End Sub

Sub SetStage(ObjDefName)
  For each Obj In ThisApplication.ObjectDefs(ObjDefName).Objects
    If Obj.Attributes.Has("ATTR_STAGE") = False Then
      Obj.Attributes.Create ThisApplication.AttributeDefs("ATTR_STAGE")
    End If
    If Obj.Attributes("ATTR_STAGE").Empty = True Then
      Set Stage = ThisApplication.ExecuteScript("CMD_S_DLL","GetStage",Obj)
      Obj.Attributes("ATTR_STAGE") = Stage
    End If
  Next
End Sub

