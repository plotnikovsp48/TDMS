Extern StartChat[Alias ("StartChat"), HelpString ("StartChat")]
Function StartChat()
  set curDicPars = thisapplication.Dictionary("writeHTMLPars")
  curDicPars.RemoveAll
  curDicPars("guid") = thisobject.GUID
  curDicPars("user") = thisapplication.CurrentUser.description
  curDicPars("sysuser") = thisapplication.CurrentUser.SysName
  set newForm = thisApplication.InputForms("FORM_IE_BR")
  newForm.Caption = "StartChat"
  newForm.Show   
End Function

sub startEvent(Form)
  set ie = Form.Controls("ACTIVEX1").ActiveX
  set curDicPars = thisapplication.Dictionary("writeHTMLPars")
  pathAndPars = "D:\Dropbox\IdeaProjects\TDMS_Chat\build\web\index.html" & "?guid=" & curDicPars("guid") & "&user=" & curDicPars("user") & "&sysuser=" & curDicPars("sysuser")
  ie.navigate2 pathAndPars, &h0400
end sub

Extern GetMailHTML[Alias ("GetMailHTML"), HelpString ("GetMailHTML")]
Function GetMailHTML(guid)
  'createOutputThemesOfChatData(guid)
  GetMailHTML = thisApplication.ExecuteScript("CMD_CREATE_HTML_WITH_MAIL_HISTORY", "createHTML_Output", guid)
End Function

use CMD_LIBRARY
Extern sendMessageToChat[Alias("sendMessageToChat"), HelpString("sendMessageToChat")]
function sendMessageToChat(message, chatId, from, theme, objectGUID)
  set from2 = thisapplication.Users.Item(from)
 ' set to2 = thisapplication.Users.Item(chatId)'Вот непонятно как здесь быть??? chatId - групповой идентификатор
  SendMail2 from2, theme, thisapplication.GetObjectByGUID(objectGUID), false, message, false, chatId
end function

StartChat

'Дальше идет обработка перед выводом-----------------------------------------------------------------
  
  '0 - имя отправителя
  '1 - ид отправителя
  '2 - имя получателя
  '3 - ид получателя
  '4 - тема
  '5 - текст
  '6 - дата

Extern createOutputThemesOfChatData[Alias ("createOutputThemesOfChatData"), HelpString ("createOutputThemesOfChatData")]
function createOutputThemesOfChatData(guid)
  thisscript.SysAdminModeOn
  
  set obj = thisApplication.GetObjectByGUID(guid)
  set query = ThisApplication.Queries("QUERY_GET_OBJECT_THEMES")
  query.Parameter("PARAM0") = obj
  
  set curSheet = query.Sheet
  qrc = curSheet.RowsCount-1
  
  output = curSheet.CellValue(i, 0)
  for i=1 To qrc
    output = output & "&" & curSheet.CellValue(i, 0)
  next
  createOutputThemesOfChatData = output
  
  thisscript.SysAdminModeOff
end function

Extern createOutputMessagesOfThemOfChatData[Alias ("createOutputThemesOfChatData"), HelpString ("createOutputMessagesOfThemOfChatData")]
function createOutputMessagesOfThemOfChatData(guid, theme)
  thisscript.SysAdminModeOn
  
  set obj = thisApplication.GetObjectByGUID(guid)
  set query = ThisApplication.Queries("QUERY_GET_MES_FOR_THEME_OF_OBJ")
  query.Parameter("PARAM0") = obj
  query.Parameter("PARAM1") = theme
  
  set curSheet = query.Sheet
  qrc = curSheet.RowsCount-1
  dim i: i=0
  
  'dim user1: set user1 = thisapplication.Users(CStr(curSheet.CellValue(i, 0)))
  
  dim output: output = curSheet.CellValue(i, 0) & "||" & curSheet.CellValue(i, 1) & "->" & vbNewLine & curSheet.CellValue(i, 2) & vbNewLine & curSheet.CellValue(i, 3)
  for i=1 To qrc
    output = output & "&" & curSheet.CellValue(i, 0) & "||" & curSheet.CellValue(i, 1) & "->" & vbNewLine & curSheet.CellValue(i, 2) & vbNewLine & curSheet.CellValue(i, 3)
  next
  createOutputMessagesOfThemOfChatData = output
    
  thisscript.SysAdminModeOff
end function

