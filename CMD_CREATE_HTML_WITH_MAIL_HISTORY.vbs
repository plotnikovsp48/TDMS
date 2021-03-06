function commutativeConcatenation(string1, string2)'коммутативное сложение строк для идентификации отдельных чатов
  if string1 <= string2 then
    commutativeConcatenation = string1 & "~" & string2
  else
    commutativeConcatenation = string2 & "~" & string1
  end if
end function

use CMD_TEST_COM
function createHTML_Output(guid)
  thisscript.SysAdminModeOn
  set obj = thisApplication.GetObjectByGUID(guid)
  set query = ThisApplication.Queries("QUERY_DISCUSSION")
  query.Parameter("PARAM0") = obj
  
  Set objFSO=CreateObject("Scripting.FileSystemObject")
  outFile=thisapplication.WorkFolder & "\tempMailHistory8.html"
  
  'htmlView = "<!doctype html><html><head><meta charset=""cp1251""><title>" & obj.Description & _
  '"</title></head><body>"
  
  writeText = ""
  set curdic = thisapplication.Dictionary("writeHTML")
  set curdicCol = thisapplication.Dictionary("writeHTMLCol")
 ' set curDicPars = thisapplication.Dictionary("writeHTMLPars")
  curdic.RemoveAll
  curdicCol.RemoveAll
  
  qrc = query.Sheet.RowsCount-1
  
  for i=0 To qrc
    'if i = 71 then
    'ttt = 1+1
   ' end if
   ' writeText = writeText & query.Sheet.CellValue(i, 6) & vbNewLine & _
    'query.Sheet.CellValue(i, 0) & ":" & query.Sheet.CellValue(i, 1) & " -> "& _
   ' query.Sheet.CellValue(i, 2) & ":" & query.Sheet.CellValue(i, 3) & vbNewLine & "Тема:" & _
   ' query.Sheet.CellValue(i, 4) & vbNewLine & query.Sheet.CellValue(i, 5) & vbNewLine & vbNewLine
    
    header = ""
    tempText = query.Sheet.CellValue(i, 4)
    id1 = commutativeConcatenation(query.Sheet.CellValue(i, 1),query.Sheet.CellValue(i, 3))
    id2 = tempText
    if InStr(1, tempText, "Re:") <> 0 then'ответ на сообщение
      tempText = Mid(tempText, 5)
      id2 = tempText
      tempText = id1 & "_" & id2
      tempI = curdic(tempText)
      header = "В ответ на сообщение " & query.Sheet.CellValue(tempI, 0) & query.Sheet.CellValue(tempI, 5) & " " & vbNewLine & query.Sheet.CellValue(tempI, 6) '& "<br>" & vbNewLine
    end if
    tempText = id1 & "_" & id2
    
    if isEmpty(curdic(tempText)) then
      curdic(tempText) = i
      set curdicCol(tempText) = thisapplication.CreateCollection(tdmCollection)
     ' curdicCol(tempText) .add i
    'else
      ' curdicCol(tempText) .add i
    end if 
    'curdicCol(tempText).add i
    
    body = query.Sheet.CellValue(i, 0) & " -> " & query.Sheet.CellValue(i, 2) & " по теме """ & id2 & """" & _
    "<Br>" & vbNewLine & query.Sheet.CellValue(i, 5)& "<Br>" & vbNewLine & query.Sheet.CellValue(i, 6)'& "<br>" & "<br>" & vbNewLine & vbNewLine
    if header <> "" then _
      header = header & "<Br>"
    curdicCol(tempText).add header & body
'    writeText = writeText & header & body
'    if i <> query.Sheet.RowsCount-1 then
'      writeText = writeText & "~~"
'    end if
  next
  
  
  writeText = ""
  for each ChatID in curdicCol
    writeText = writeText & "<Br><Hr>Идентификатор чата: " & ChatID & "<Br>"
    for each Message in curdicCol(ChatID)
      writeText = writeText & Message & "<Br><Br>"
    next
  next
  
  
  
  'Дальше идет обработка перед выводом-----------------------------------------------------------------
  
  '0 - имя отправителя
  '1 - ид отправителя
  '2 - имя получателя
  '3 - ид получателя
  '4 - тема
  '5 - текст
  '6 - дата
  
  'tdmObjects
  
  while instr(writeText, "?<html>") <> 0
    writeText = replace(writeText, "?<html>", "<html>")
  wend
  
  tempHR = instr(writeText, "<hr>") + 4'чтобы отрезать еще и разделитель
  
  while tempHR <> 0
    tempMark1 = InStrRev(writeText, "<body>", tempHR-5)
    tempMark2 = InStrRev(writeText, "<hr>", tempHR-5)
    tempR = 0
    tempN = 0
    if tempMark2 <= tempMark1 and tempMark2 <> 0 then
      tempR = tempHR - tempMark2 
      tempHR = tempMark2
      tempN = 4
    else
      tempR = tempHR - tempMark1
      tempHR = tempMark1
      tempN = 6
    end if
    tempStr = mid(writeText, tempHR + tempN, tempR - tempN)
    
    writeText = replace(writeText, tempStr, "")
    writeText = left(writeText, tempHR-1) & " " & left(tempStr, len(tempStr)-4) & " " & mid(writeText, tempHR)
    tempHR = instr(writeText, "<hr>")
  wend
  
'  tempHR = instr(writeText, "<hr>")
'  while tempHR <> 0
'    tempBody2 = instr(writeText, "</div>")
'    writeText = replace(writeText, mid(writeText, tempHR, tempBody2-tempHR), "")
'    tempHR = instr(writeText, "<hr>")
'  wend
  
 
  'writeText = writeText
  
  
   while instr(writeText, "<meta content=""text/html; charset=unicode"" http-equiv=""Content-Type"">")
    writeText = replace(writeText, "<meta content=""text/html; charset=unicode"" http-equiv=""Content-Type"">", "")
  wend
  while instr(writeText, "<html>")
    writeText = replace(writeText, "<html>", "")
  wend
  while instr(writeText, "</html>")
    writeText = replace(writeText, "</html>", "")
  wend
  
  tempBody = instr(writeText, "<body>")
  while tempBody
    tempBody2 = instr(tempBody, writeText, "</body>")
    if tempBody2 <> 0 then
      writeText = replace(writeText, mid(writeText, tempBody, tempBody2-tempBody + 7), "")
    else
      writeText = replace(writeText, "<body>", "")
    end if
    tempBody = instr(writeText, "<body>")
  wend
  while instr(writeText, "</body>")
    writeText = replace(writeText, "</body>", "")
  wend
   while instr(writeText, "<head>")
    writeText = replace(writeText, "<head>", "")
  wend
  while instr(writeText, "</head>")
    writeText = replace(writeText, "</head>", "")
  wend
 
  while instr(writeText, "<div>")
    writeText = replace(writeText, "<div>", "")
  wend
  while instr(writeText, "</div>")
    writeText = replace(writeText, "</div>", "")
  wend
  while instr(writeText, "<br>")
    writeText = replace(writeText, "<br>", "")
  wend
   while instr(writeText, "<BR>")
    writeText = replace(writeText, "<BR>", "")
  wend
   while instr(writeText, vbNewLine)
    writeText = replace(writeText, vbNewLine, "")
  wend
   while instr(writeText, vbCrLf)
    writeText = replace(writeText, vbCrLf, "")
  wend
   while instr(writeText, vbCr)
    writeText = replace(writeText, vbCr, "")
  wend
  while instr(writeText, vbLf)
    writeText = replace(writeText, vbLf, "")
  wend
  
  while instr(writeText, "<Br><Br>")
    writeText = replace(writeText, "<Br><Br>", "<Br>")
  wend
  
   'htmlView = htmlView & writeText & "</body></html>"
   createHTML_Output = writeText
   
  'curDicPars("guid") = thisobject.GUID
  'curDicPars("user") = thisapplication.CurrentUser.description
  'curDicPars("path") = outFile
  
  
  
  
  'D:\Dropbox\IdeaProjects\TDMS_Chat\build\web\
  'Set objFile = objFSO.CreateTextFile("D:\Dropbox\IdeaProjects\TDMS_Chat\build\web\tempMailHistory8.html",True)
  'Set objFile = objFSO.CreateTextFile(outFile,True)
  'objFile.Write htmlView'(thisobject.GUID & "<guid>" & writeText)'htmlView'writeText
  'objFile.Close
  
  
 ' openMyChat
  
  'CreateObject("WScript.Shell").Run(outFile)
  'thisscript.SysAdminModeOff
end function

createHTML_Output
