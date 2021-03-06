' $Workfile: dump.CMD_SEND.scr $ 
' $Date: 30.05.07 13:35 $ 
' $Revision: 1 $ 
' $Author: Oreshkin $ 
'
' Отправка файла
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

Set o = ThisObject
Call Run(o)


Sub Run(o_)
  Dim fMain
  Dim arrFiles
  Dim sMailClientType
  Dim oSendDocs
  Dim sMailTitle
  Dim sMailText
  
  o_.Permissions = SysAdminPermissions 
  
  ' Определяем тип почтового клиента
  sMailClientType = GetMailClientType(o_)
  ' не определен почтовый клиент
  If sMailClientType = "" Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1025
    Exit Sub
  End If
  
  ' Информационный объект не содержит файлов
  If o_.Files.Count = 0 Then 
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1024
    Exit Sub
  End If
  
  
  ' Получаем колекцию файлов    
  Set oSendDocs = ThisApplication.Shell.SelObjects '.ObjectsByDef("OBJECT_DOCUMENT")
  arrFiles = GetFiles(oSendDocs)  
  
  ' Папка не содержит файлов
  If UBound(arrFiles) <0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1026
    Exit Sub
  End If  

  Call CheckOut(oSendDocs)
  
  If oSendDocs.Count>1 Then
    sMailTitle = "Документы из nanoTDMS"
  Else
    sMailTitle = o_.Description
  End If
  
  sMailText = "Сообщение готово к отправке."& Chr(10)& Chr(10)&_
              "Примечание: Для предотвращения заражения компьютерными вирусами почтовые программы могут запрещать отправление или получение вложенных файлов.  Проверьте параметры безопасности почтовой программы для обработки вложений."
  
  Call SendMail(arrFiles,sMailClientType,sMailTitle,sMailText)
  Call CheckIn(oSendDocs)
End Sub



Sub SendMail(arrFiles_,sMailClientType_,sMailTitle_,sMailText_)
  Dim sComm
  ' Определяем тип почтового клиента
  If sMailClientType_ = "NODE_DEFAULT_MAIL_CLIENT" Then
    ThisApplication.Utility.SendEMailMAPI "",sMailTitle_,sMailText_,arrFiles_
    'ThisApplication.Utility.SendEMailMAPI "",sMailTitle_,sMailText_,arrFiles_.Owner.Files
  Else
    sComm = Replace(sMailClientType_,"NODE_","CMD_")
    ThisApplication.ExecuteScript sComm,"Send",arrFiles_,sMailTitle_
  End If
End Sub

' Функция возвращает тип(системное имя) выбранного почтого клиента(узла классификатора) 
Private Function GetMailClientType(o_)
  If ThisApplication.CurrentUser.Attributes("ATTR_MAIL_CLIENT")<> "" Then
    GetMailClientType = ThisApplication.CurrentUser.Attributes("ATTR_MAIL_CLIENT").Classifier.SysName
  Else
    GetMailClientType = ""  
  End If  
End Function

' Получаем колекцию файлов
Private Function GetFiles(os_)
  Dim o,count
  Dim arr()
  count = 0
  
  ' Временное решение из-за отсутствие мультивыбора объетов в нутри выборки 
  If os_.Count = 1 Then
    ThisObject.Permissions = SysAdminPermissions
    For Each f In ThisObject.Files
      count = count + 1
      ReDim Preserve arr(count-1)
      Set arr(count-1) = f
    Next
  Else
    For Each o In os_
      For Each f In o.Files
        count = count + 1
        ReDim Preserve arr(count-1)
        Set arr(count-1) = f
      Next
    Next
  End If
  GetFiles = arr
End Function

Private Sub CheckOut(os_)
  Dim o
  For Each o In os_
    On Error Resume Next
      If o.Files.Count > 0 Then o.CheckOut
    On Error GoTo 0
  Next
End Sub

Private Sub CheckIn(os_)
  Dim o
  For Each o In os_
    On Error Resume Next
      If o.Files.Count > 0 Then o.CheckIn
    On Error GoTo 0
  Next
End Sub
