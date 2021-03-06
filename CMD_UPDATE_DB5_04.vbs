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
    "Обновление базы от 29.01.2018")
  If ans<>vbYes Then Exit Sub
  
  Call Run()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub

'================================= Новое обновление БД-4
Sub Run()

Call UpdatePT()
Call AddGroups()
End Sub
'===================================================  


Sub UpdatePT()
For each Obj In ThisApplication.ObjectDefs("OBJECT_P_TASK").Objects
  Obj.Update
Next
End Sub


Sub AddGroups()
  Set gr = AddGroup("GROUP_CONTRACT_FILES_EDIT_NOTIFY")
  gr.SysName = "GROUP_CONTRACT_FILES_EDIT_NOTIFY"
  gr.Description = "Уведомление об изменении файлов договора"
End Sub
