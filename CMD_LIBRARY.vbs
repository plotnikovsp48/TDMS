' $Workfile: COMMAND.SCRIPT.CMD_LIBRARY.scr $ 
' $Date: 29.09.08 12:37 $ 
' $Revision: 2 $ 
' $Author: Oreshkin $ 
'
' Библиотека функций
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.


Function SendMail(cUsers, cSubject, cObjects, mSystem, mBody, Editable)
  SendMail = True
  Set nMessage = ThisApplication.CreateMessage
  nMessage.To = cUsers
  nMessage.Subject = cSubject
  nMessage.System = mSystem
  nMessage.Body = mBody
  If Not cObjects Is Nothing Then
    Select Case TypeName(cObjects)
      Case "ITDMSObject"
        nMessage.Attachments.Add cObjects
      Case "ITDMSObjects"
        For Each tObj In cObjects
          nMessage.Attachments.Add tObj
        Next
    End Select
  End If
  If Editable Then
    Set mDialog = ThisApplication.Dialogs.EditMessageDlg
    mDialog.Message =  nMessage
    If mDialog.Show = False Then SendMail = False
  Else nMessage.Send
  End If
End Function

'добавил многопочтовую отправку и отправку от конкретного пользователя
Function SendMail2(cUsers, cSubject, cObjects, mSystem, mBody, Editable, From)'PlotnikovSP 
  Thisscript.SysAdminModeOn
  SendMail2 = True
  Set nMessage = ThisApplication.CreateMessage
  'fdff = TypeName(cUsers)
  
  'typUs = TypeName(cUsers)
  
  Select Case TypeName(cUsers)
    Case "ITDMSUser"
      nMessage.To = cUsers
    Case "Variant()"
      For Each tUser In cUsers
        nMessage.ToAdd tUser
      next  
    Case "ITDMSUsers"
      'For Each tUser In cUsers
        nMessage.To = cUsers
    ' next  
    Case "String"
      nMessage.To = cUsers
  End Select

  nMessage.Subject = cSubject
  nMessage.System = mSystem
  nMessage.Body = mBody
  If Not cObjects Is Nothing Then
    Select Case TypeName(cObjects)
      Case "ITDMSObject"
        nMessage.Attachments.Add cObjects
      Case "ITDMSObjects"
        For Each tObj In cObjects
          nMessage.Attachments.Add tObj 'nMessage.ToAdd
        Next
    End Select
  End If
  
  if not isEmpty(From) then
    nMessage.From = From
  end if
  
  If Editable Then
    Set mDialog = ThisApplication.Dialogs.EditMessageDlg
    mDialog.Message =  nMessage
    If mDialog.Show = False Then SendMail2 = False
  Else nMessage.Send
  End If
  Thisscript.SysAdminModeOff
End Function
