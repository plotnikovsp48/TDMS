
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
    "Обновление базы от 04.10.2017")
  If ans<>vbYes Then Exit Sub
  
  Call Run()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub

Sub Run()

'================================= Новое обновление БД-4
  

  Call ObjAttrsSync()
  Call misc()
  Call DeleteComm()
'===================================================  
End Sub



Sub DeleteComm()
Progress.Text = "Обновляются команды"
List = "CMD_2F93F233_6DAE_499E_96D1_FE7459599271"
Call SystemObjDelByList(List)
End Sub

Sub ObjAttrsSync()
  Progress.Text = "Обновление атрибутов объекта:"
  List =  "OBJECT_WORK_DOCS_FOR_BUILDING,OBJECT_WORK_DOCS_SET,OBJECT_VOLUME,OBJECT_DOC_DEV,OBJECT_DRAWING,OBJECT_T_TASK"

  Call ObjAttrSync(List)
End Sub


Sub misc()
  Progress.Text = "Обновление атрибутов объекта:"
  
    If ThisApplication.FileDefs.Has("FILE_REPORT_TEMPLATE") Then
    Set fDef = ThisApplication.FileDefs("FILE_REPORT_TEMPLATE")
    If fDef.Templates.Has("VOK----------.docx") Then fDef.Templates("VOK----------.docx").Erase
  End If
  
  Set oDef = ThisApplication.ObjectDefs("OBJECT_STAGE")
  If oDef.Commands.Has("CMD_B8F008D7_C008_40A6_A762_3D34BCC9653D") Then _
    oDef.Commands.Remove ThisApplication.Commands("CMD_B8F008D7_C008_40A6_A762_3D34BCC9653D")
  If oDef.Commands.Has("CMD_DELETE_ALL") Then _
    oDef.Commands.Remove ThisApplication.Commands("CMD_DELETE_ALL")
End Sub





