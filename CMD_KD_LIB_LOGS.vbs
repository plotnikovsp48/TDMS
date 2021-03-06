
'_________________________________________________________________________
' EV пишет в стандартный сегодняшний файл сообщений
Sub WriteLog(Msg)
Set FSO = CreateObject("Scripting.FileSystemObject")
    path = "C:\\TDMS\log"
  WriteFile path ,"TDMS-Log-" & Replace(Date,"/",".") &  ".txt", Msg, "Log"
end sub

'______________________________________________________________________________________________________________________________________________
'EV  пишет в стандартный сегодняшний файл ошибок
Sub WriteError(Msg)
Set FSO = CreateObject("Scripting.FileSystemObject")
  path = "C:\\TDMS\log"
  WriteFile path ,"TDMS-Error-" & Replace(Date,"/",".") &  ".txt", Msg, "Error"
end sub
'_________________________________________________________________________
'EV пишет в указанный файл с указанным сообщением
Sub WriteFile( Folder, FileName, Msg , MsgType)
  Set FSO = CreateObject("Scripting.FileSystemObject")
  if not FSO.FolderExists(Folder) then
    call CreateForldersHierachyLog(Folder)
  end if

  if not FSO.FolderExists(Folder) then
    msgbox Msg,vbCritical,MsgType 
    exit sub
  end if
  msg = Now & " "& MsgType &": "& Msg
  Set hFile = FSO.OpenTextFile(Folder&"\"& FileName,8,True)
  on error resume next
  hFile.WriteLine(msg)
  If Err.Number<>0 Then 
    msgbox err.Description 
    msgbox "msg = " & msg
    Err.Clear
  end if  
  on error goto 0
  hFile.Close  
  Set hFile = Nothing  
  Set FSO = Nothing
End Sub


'_________________________________________________________________________
'Создание иерархии папок, указанных в пути
sub CreateForldersHierachyLog(FolderPath)
  on error resume next
  err.clear
  Set FSO = CreateObject("Scripting.FileSystemObject")
  SplitArr = Split(FolderPath,"\")
  CurPath = SplitArr(0)
                 
  for i=LBound(SplitArr)+1 to UBound(SplitArr)
       CurPath = CurPath & "\" & SplitArr(i)
          if not FSO.FolderExists(CurPath) then
             FSO.CreateFolder(CurPath)
          end if
  Next
  if err.Number <> 0 then 
    txt = "Ощибка создания папки " & err.Description
    txt = txt & vbNewLine & "Путь  - " & FolderPath
    txt = txt & vbNewLine & "Пожалуйста, сообщите разработчикам" 
    msgbox txt, VbCritical, "создания папки "
    err.clear
  end if
  on error goto 0
end sub
