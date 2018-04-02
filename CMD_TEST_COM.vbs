'msgbox 1111
Extern getHWND [Alias ("HWND"), HelpString ("HWND")]
Function getHWND() 
  getHWND = thisapplication.HWND
End Function

Extern changeStatusObject[Alias ("changeStatusObject"), HelpString ("changeStatusObject")]
Function changeStatusObject() 
  set obj = thisapplication.GetObjectByGUID("{388801F1-86DA-4E4C-8A2A-4C9C447261D0}")
  obj.Permissions = SysAdminPermissions
  Msgbox "Текущие права на объект " & obj.Description & " изменены на  sysadmin " & obj.Permissions.sysadmin
End Function

Extern StartChat[Alias ("StartChat"), HelpString ("StartChat")]
Function StartChat()
  set curDicPars = thisapplication.Dictionary("writeHTMLPars")
  curDicPars.RemoveAll
  curDicPars("guid") = thisobject.GUID
  curDicPars("user") = thisapplication.CurrentUser.description
  openMyChat
End Function

use CMD_LIBRARY
Extern sendMessageToChat[Alias("sendMessageToChat"), HelpString("sendMessageToChat")]
function sendMessageToChat(message, chatId, from, theme, objectGUID)
  SendMail2 chatId, theme, thisapplication.GetObjectByGUID(objectGUID), false, message, false, from
end function

Extern FindNewsInTDMS [Alias ("FindNewsInTDMS"), HelpString ("FindNewsInTDMS")]
Function FindNewsInTDMS() 
  Set q = ThisApplication.Queries("QUERY_SUM_PROFILE_ALL")
  q.Parameter("PARAM0") = thisapplication.CurrentUser
  textRet = ""
  count = q.Sheet.RowsCount
  for i=0 to count-1
    textRet = textRet & q.Sheet.CellValue(i,0) & "=" & q.Sheet.CellValue(i,1) & "\n"
  next
     
  FindNewsInTDMS = textRet
End Function

sub CreateFormNew(obj)
end sub

sub CreateNoModalForm
end sub

sub CreateNoModalDialog()
'  Set EditObjDlg  = ThisApplication.Dialogs.EditObjectDlg
'  EditObjDlg.Object = thisobject
'  EditObjDlg.ParentWindow = ThisApplication.hWnd
'  EditObjDlg.Show
       


'  'Set NewForm =thisobject.ObjectDef.InputForms("ATTR_KD_TEXT")'Create

  set dict = thisapplication.Dictionary("testForm1")
  Set NewForm = ThisApplication.InputForms("FORM_CHILD_WIND")'Create
  NewForm.Description = "1234"
  NewForm.Caption = "testForm"
  set dict("tf") = NewForm
  
  'NewForm.ParentWindow = ThisApplication.hWnd
'  NewForm.Controls("TDMSTREEOrder") = thisForm.Controls("TDMSTREEOrder")
  NewForm.Show   
 
 


 
  'TDMSInputForm
'  
'  Set CreateObjDlg  = ThisApplication.Dialogs.CreateObjectDlg
'  CreateObjDlg.ObjectDef = "FORM_CHILD_WIND"
'  CreateObjDlg.ParentObject = ThisApplication.Root
'  CreateObjDlg.ParentWindow = ThisApplication.hWnd
'  CreateObjDlg.ActiveForm = ThisApplication.Inputforms("FORM_CHILD_WIND")
'CreateObjDlg.Show
    
end sub

'CreateNoModalDialog


sub openMyChat()'FORM_IE_BR

  set newForm = thisApplication.InputForms("FORM_IE_BR")'Shell.Explorer.2
  newForm.Caption = "IE"
  'set ax = newForm.controls("ACTIVEX1")
  
  newForm.Show   
  'FORM_IE_BR

end sub
'openMyChat
'changeStatusObject


Sub ShowProgress()
        Dim Progress, i, Str, q, t
        
        'Инициализировать прогрессбар...
        Set Progress = ThisApplication.Dialogs.ProgressDlg
        
        'Вывести прогресс на экран
        Progress.Start
        
        'Сначала "уложить" три этапа операции на одной шкале
        For i = 1 To 3
                Str = "Этап № " & i & "; процент выполнения " ' Выводим номер этапа
                Progress.SetLocalRanges ((i - 1) * 100 / 3), (i * 100 / 3) ' Установка локальных границ прогресса
                For q = 0 To 1000
                        t = Timer + 0.02
                        Progress.Position = q ' Установка текущего процента выполнения
                        Progress.Text = Str & q & "%"
                        'Смоделировать задержку (0.02 секунды)
                        While Timer < t 
                        Wend
                Next
        Next
        
        'Теперь каждому этапу отвести полноценную шкалу
        Progress.ResetLocalRanges 
        For i = 4 To 5
                Str = "Этап № " & i & "; процент выполнения " ' Выводим номер этапа
                For q = 0 To 1000
                        t = Timer + 0.02
                        Progress.Position = q ' Установка текущего процента выполнения
                        Progress.Text = Str & q & "%"
                        'Смоделировать задержку (0.02 секунды)
                        While Timer < t 
                        Wend
                Next
        Next
        
        ' Закрыть диалог индикатора выполнения
        Progress.Stop
End Sub


ShowProgress
