
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
    "Обновление базы от 06.10.2017")
  If ans<>vbYes Then Exit Sub
  
  Call Run()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub

Sub Run()

'================================= Новое обновление БД-4

Call RemoveFromObjDef()
Call DeleteForms()
Call ObjAttrsSync()
Call DeleteQUERY()

'===================================================  

End Sub

Sub DeleteQUERY()
List = "QUERY_REFFERENCED_DOCS"
Call SystemObjDelByList(List)
End Sub

Sub RemoveFromObjDef()
  Progress.Text = "Обновляются связи объекта:"
  ObjList = "OBJECT_CONTRACT_COMPL_REPORT,OBJECT_INVOICE,OBJECT_WORK_DOCS_SET,OBJECT_VOLUME"
  ObjArr = Split(ObjList,",")
  
  For Each ObjDefName In ObjArr
    Progress.Text = "Обновляются связи объектов: " & ObjDefName
    Select Case ObjDefName
      Case "OBJECT_CONTRACT_COMPL_REPORT"
        List = "FORM_DOCS_TLINKS"
      Case "OBJECT_INVOICE"
        List = "FORM_PROJECT_PARTS_LINKED"
      Case "OBJECT_WORK_DOCS_SET","OBJECT_VOLUME"
        List = "FORM_NK,FORM_DOCS_TLINKS"  
    End Select
  
    arr = Split(List,",")
    For Each ObjSysName In arr
      call SystemObjRemoveFromObject(str0,ObjDefName,ObjSysName)
    Next
  Next
End Sub

Sub ObjAttrsSync()
  Progress.Text = "Обновление атрибутов объекта:"
  List =  "OBJECT_WORK_DOCS_FOR_BUILDING"

  Call ObjAttrSync(List)
End Sub







Sub DeleteForms()
  Progress.Text = "Обновляются формы"
    List = "FORM_DOCS_TLINKS,FORM_C73146F5_9E42_4BF2_856A_2A23DBA21254"
Call SystemObjDelByList(List)
End Sub
