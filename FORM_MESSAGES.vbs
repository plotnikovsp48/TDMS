' Форма ввода - Таблица сообщений
' Автор: Чернышов Д.С.
'
' Работа с маршрутной таблицей
'------------------------------------------------------------------------------
' Авторское право c ЗАО <СиСофт>, 2016 г.

USE CMD_FSO
USE CMD_EXCEL

'==============================================================================================
'Выгрузка сообщений в Excel 
Sub BUTTON_TO_EXCEL_OnClick()
  ThisApplication.Utility.WaitCursor = True
  Set TableRows = ThisObject.Attributes("ATTR_MESSAGES_TABLE").Rows
  sMess = ""
  For Each Row in TableRows
    MessTitle = Replace(Row.Attributes(3), chr(13), "", 1, -1, vbTextCompare)
    MessBody = Replace(Row.Attributes(4), chr(13), "", 1, -1, vbTextCompare)
    If Len(MessBody) > 0 Then
      StrMess = Row.Attributes(0)&";"&Row.Attributes(1)&";"&Row.Attributes(2)&";"&MessTitle&";"&MessBody
    Else
      StrMess = Row.Attributes(0)&";"&Row.Attributes(1)&";"&Row.Attributes(2)&";"&Row.Attributes(3)
    End If
    StrMess = Replace(StrMess, chr(10), chr(126), 1, -1, vbTextCompare)
    StrMess = Replace(StrMess, chr(32), chr(95), 1, -1, vbTextCompare)
    'StrMess = Replace(StrMess, chr(59), chr(10), 1, -1, vbTextCompare)
    'StrMess = Replace(StrMess, chr(34)&chr(34), chr(34))
    'StrMess = Replace(StrMess, chr(13), "", 1, -1, vbTextCompare)
    If sMess <> "" Then
      sMess = sMess & chr(10) & StrMess
    Else
      sMess = StrMess
    End If
  Next
  ThisObject.CheckOut
  'fname = ThisObject.WorkFolder & "\" & ThisObject.Description & ".txt"
  On Error Resume Next
  Set objShellApp = CreateObject("Shell.Application")
  Set objFolder = objShellApp.BrowseForFolder(0, "Сохранить файл в папку", 0)
  fname = objFolder.Self.Path & "\" & ThisObject.Description & ".txt"
  If Err.Number <> 0 Then
    MsgBox "Папка не выбрана!", vbInformation
  End If
  
  res = CreateTextFileFromStr(sMess,fname)
  
  If res = True Then objShellApp.ShellExecute fname
  Set objShellApp = Nothing
  
  ThisApplication.Utility.WaitCursor = False
End Sub

'==============================================================================================
'Загрузка сообщений из Excel 
Sub BUTTON_FROM_EXCEL_OnClick()
  ThisObject.Permissions = SysAdminPermissions
  
  Key = Msgbox("Внимание! Все данные в таблице сообщений будут перезаписаны!" & chr(10) & _
    "Продолжить?", vbQuestion+VbYesNo)
  If Key = vbNo Then Exit Sub
  'выбираем файл
  fname = ThisApplication.ExecuteScript("CMD_DIALOGS","SelectFileDlg","FILE_ANY")  
  'создаем версию таблицы сообщений
  ThisObject.Versions.Create ' - НЕ ЗАБЫТЬ ВКЛЮЧИТЬ
  'считываем файл сообщений в таблицу
  sRoute = CreateStrFromTextFile(fname)
  If Trim(fname) = "" Then Exit Sub
  
  ThisApplication.Utility.WaitCursor = True
  Set TableRows = ThisObject.Attributes("ATTR_MESSAGES_TABLE").Rows
  TableRows.RemoveAll
  sMess = Replace(sRoute, chr(59), chr(32), 1, -1, vbTextCompare)
  arr = Split(sMess, chr(10))
  RowCount = 0
  For i = 0 to UBound(arr)
    Mess = arr(i)
    MessArr = Split(Mess, " ")
    Num = UBound(MessArr)
    If Len(Mess) > 3 Then
      Set NewRow = TableRows.Create
      RowCount = RowCount + 1
      
      'Флаг сообщения
      MessFlag = MessArr(0)
      If MessFlag = "Ложь" Then
        MessFlag = False
      Else
        MessFlag = True
      End If
      NewRow.Attributes(0) = MessFlag
      
      'Номер сообщения
      MessNum = MessArr(1)
      NewRow.Attributes(1) = MessNum
      
      'Тип сообщения
      MessType = MessArr(2)
      MessType = Replace(MessType, "_", " ", 1, -1, vbTextCompare)
      Set cMessType = ThisApplication.Classifiers("NODE_MESSAGE_TYPE").Classifiers.Find(MessType)
      If not cMessType is Nothing Then
        NewRow.Attributes(2) = cMessType
      Else
        NewRow.Attributes(2) = ThisApplication.Classifiers("NODE_MESSAGE_TYPE").Classifiers.Find("NOT SET")
      End If
      
      'Текст сообщения
      MessStr0 = MessArr(3)
      MessStr0 = Replace(MessStr0, "_", " ", 1, -1, vbTextCompare)
      MessStr0 = Replace(MessStr0, "~", chr(10), 1, -1, vbTextCompare)
      NewRow.Attributes(3) = MessStr0
      
      'Текст письма
      If Num > 3 Then
        MessStr1 = MessArr(4)
        MessStr1 = Replace(MessStr1, "_", " ", 1, -1, vbTextCompare)
        MessStr1 = Replace(MessStr1, "~", chr(10), 1, -1, vbTextCompare)
        NewRow.Attributes(4) = MessStr1
      End If
    End If
  Next
  
  ThisApplication.Utility.WaitCursor = False
  Msgbox "Таблица сообщений заполнена." & chr(10) & "Создано " & RowCount & " строк."
  ThisObject.Update
End Sub

'Кнопка поиска текста сообщения
Sub BUTTON_SEARCH_OnClick()
  Set TableA = ThisForm.Controls("ATTR_MESSAGES_TABLE").ActiveX
  Set TableRows = ThisObject.Attributes("ATTR_MESSAGES_TABLE").Rows
  Start = TableA.SelectedRow
  If Start <> 0 Then Start = Start + 1
  Set Dlg = ThisApplication.Dialogs.SimpleEditDlg
  Dlg.Prompt = "Введите текст"
  Dlg.Caption = "Поиск текста сообщения"
  If ThisForm.Dictionary.Exists("WordsSeek") Then
    Dlg.Text = ThisForm.Dictionary.Item("WordsSeek")
  End If
  If Dlg.Show Then
    Txt = Dlg.Text
    If Txt <> "" Then
      ThisForm.Dictionary.Item("WordsSeek") = Txt
      iRow = -1
      For i = Start to TableRows.Count-1
        Set Row = TableRows(i)
        If InStr(1, Row.Attributes("ATTR_MESSAGE_TEXT").Value, Txt, vbTextCompare) <> 0 Then
          iRow = i
        ElseIf InStr(1, Row.Attributes("ATTR_MESSAGES_TABLE_BODY").Value, Txt, vbTextCompare) <> 0 Then
          iRow = i
        End If
        If iRow <> -1 Then
          TableA.SelectedRow = iRow
          'Num = Row.Attributes("ATTR_MESSAGE_CODE").Value
          'Msgbox "Строка найдена." & chr(10) & "Код сообщения: " & Num
          Exit For
        End If
      Next
      If iRow = -1 Then
        Msgbox "Сообщения не найдены.", vbExclamation
        Exit Sub
      End If
    End If
  End If
End Sub

