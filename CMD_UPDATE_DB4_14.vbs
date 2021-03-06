
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
    "Обновление базы от 07.11.2017")
  If ans<>vbYes Then Exit Sub
  
  Call Run()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub

Sub Run()

'================================= Новое обновление БД-4

Call SetSystemAttrs("")
progress.Position = 20
Call AddSearchQueries()
'progress.Position = 40
Call RemoveFromObjDef()
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
  lst = "ATTR_PLATAN_LINK_SETTINGS," & aList
  arr = Split(lst,",")
  
  For each attrname In arr
    Progress.Text = "Настройка системных атрибутов: " & attrname
    Select Case attrname
      Case "ATTR_PLATAN_LINK_SETTINGS"
        ThisApplication.Attributes("ATTR_PLATAN_LINK_SETTINGS") = "OBJECT_WORK_DOCS_SET;OBJECT_PROJECT_SECTION_SUBSECTION;OBJECT_PROJECT_SECTION;OBJECT_T_TASK;OBJECT_VOLUME"
    End Select
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