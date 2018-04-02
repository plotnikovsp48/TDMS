sub printSign(filePdfWithMarks, currentMark)'(File, String)!!!!!!!!!!!ЗДЕСЬ ИЗМЕНЕНИЯ !!!!!!!!!
  thisscript.SysAdminModeOn
  For Each f In ThisApplication.FileDefs("PDFPublisher").Templates
    f.checkout f.WorkFileName
    If f.filename = "PDFPublisher.exe" Then
      ' Запоминаем путь к запускаемому модулю PDFPublisher.exe И ЗДЕСЬ!!!!
      pdfPublisherEXE = f.WorkFileName
    End If
  Next
  
  If isEmpty(pdfPublisherEXE) Then
    msgbox "Не установлена библиотека PDFPublisher." & chr(13) &_
           "Обратитесь к системному администратору", VbCritical, "Команда не выполнена"
    exit sub
  End If  
  
  set query = thisapplication.Queries("QUERY_GET_FACSIMILE")
  query.Parameter("PARAM0") = thisapplication.CurrentUser
  if query.Files.Count < 1 then
    msgbox "Не задано факсимиле подпись для данного пользователя." & chr(13) &_
           "Обратитесь к системному администратору", VbCritical, "Команда не выполнена"
    exit sub
  end if
  
 ' pdfPublisherPath = Left(pdfPublisherEXE, InStrRev(pdfPublisherEXE,"\"))
  Set objShell = CreateObject("WScript.Shell")
  filePdfWithMarks.checkOut'выгружаем в рабочую директорию
  query.Files(0).CheckOut'выгружаем в рабочую директорию
  paramsEXE = "imageonlabel --label=" & """currentMark"" --imageFile=" & _
   query.Files(0).WorkFileName & " --width=fit --input=" & """" & filePdfWithMarks.workFileName & _
   """ --output=""temp_facsimile.pdf"""

  'objShell.Run(pdfPublisherEXE)
  Set objShell = Nothing
  'tt = 123
  thisscript.SysAdminModeOff
end sub

printSign
