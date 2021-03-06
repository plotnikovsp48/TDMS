'проверка, что запуск на проекте
'вопрос по поводу запуска
Call Main()
ThisApplication.Utility.Waitcursor = False

Sub Main()
  ThisApplication.Utility.Waitcursor = TRUE
  Set qrTasks = ThisApplication.Queries("QUERY_REPORT_OUTGOING_TASKS_ALLTASKS_CURRPROJ1")
  qrTasks.Parameter("CURR_PR0J") = ThisObject.GUID
  Set qrTasksSheet = qrTasks.Sheet
  If qrTasksSheet.RowsCount = 0 Then
   msgbox "Отсутствуют данные для формирования отчета (Задания с заполненными полями " &_
    """Объект проектирования"", таблица ""В отделы"")." & Chr(13) &_
    "Выполнение команды прекращено.",vbOkOnly,"Ошибка!"
   Exit Sub
  End If
  Set qrSenders = ThisApplication.Queries("QUERY_REPORT_OUTGOING_TASKS_ALLSENDERS_CURRPROJ1")
  qrSenders.Parameter("CURR_PR0J") = ThisObject.GUID
  Set qrSendersSheet = qrSenders.Sheet
  If qrSendersSheet.RowsCount = 0 Then
   msgbox "Отсутствуют данные для формирования отчета (Задания с заполненными полями " &_
    """Объект проектирования"", таблица ""В отделы"")." & Chr(13) &_
    "Выполнение команды прекращено.",vbOkOnly,"Ошибка!"
   Exit Sub
  End If

  Set file = ThisApplication.FileDefs("FILE_DOC_XLS").Templates("Outgouing_tasks_registry_template1.xlsx")
  datetime = ThisApplication.CurrentTime
  DocNameToSave = "Report_outgoing_tasks_reg1_" & Day(datetime) & "-" & Month(datetime) & "_" &_ 
    Hour(datetime) & "-" & Minute(datetime) & "-" & Second(datetime) & ".xlsx"
  DocNameToSave = ThisApplication.WorkFolder & "\" & DocNameToSave
  file.CheckOut(DocNameToSave)
  Set ExcelApp = CreateObject("Excel.Application")
  Set WrkBook = ExcelApp.Workbooks.Open(DocNameToSave)
  Set List = WrkBook.ActiveSheet
  
  'заполняю словарь с номерами колонок отделов для того, чтобы при заполнении находить номер колонки
  Set senders_dict = ThisApplication.Dictionary("Senders")
  Set receivers_dict = ThisApplication.Dictionary("Receivers")
  senders_dict.RemoveAll
  receivers_dict.RemoveAll
  start_col_num = 0
  fin_col_num = 4
  List.Cells(1,2).Value = ThisObject.Attributes("ATTR_PROJECT_CODE").Value & " - " & ThisObject.Attributes("ATTR_NAME_SHORT").Value
  For i = 0 To qrSendersSheet.RowsCount-1
    fin_col_num = fin_col_num + 1
    start_col_num = fin_col_num
    Sender_code = qrSendersSheet.CellValue(i,"CODE_SENDER")
    List.Cells(3,fin_col_num).Value = Sender_code
    List.Cells(3,fin_col_num).Font.Bold = True
    Set qrReceivers = ThisApplication.Queries("QUERY_REPORT_OUTGOING_TASKS_SENDER_RECIVERS_CURRPROJ1")
    qrReceivers.Parameter("CURR_PR0J") = ThisObject.GUID
    qrReceivers.Parameter("DEP-T") = qrSendersSheet.CellValue(i,"GUID_SENDER")
    Set qrReceiversSheet = qrReceivers.Sheet
    If qrReceiversSheet.RowsCount > 0 Then
      For j = 0 To qrReceiversSheet.RowsCount-1
        Receiver_code = qrReceiversSheet.CellValue(j,"CODE_RECEIVER")
        List.Cells(4,fin_col_num+j).Value = Receiver_code
        List.Cells(4,fin_col_num+j).Font.Bold = True
        With List.Range(List.Cells(4,fin_col_num+j),List.Cells(4,fin_col_num+j))
          .Borders(7).LineStyle = 1'xlContinuous
          .Borders(10).LineStyle = 1'xlContinuous
          .Borders(7).Weight = 2
          .Borders(10).Weight = 2
        End With
        If Not receivers_dict.Exists(Sender_code & "@#" & Receiver_code) Then _
          receivers_dict.add Sender_code & "@#" & Receiver_code, fin_col_num+j
        If j = qrReceiversSheet.RowsCount-1 Then
         List.Cells(4,fin_col_num+j+1) = "Статус"
         List.Cells(4,fin_col_num+j+1).Font.Bold = True
         With List.Range(List.Cells(4,fin_col_num+j+1),List.Cells(4,fin_col_num+j+1))
          .Borders(7).LineStyle = 1'xlContinuous
          .Borders(10).LineStyle = 1'xlContinuous
          .Borders(7).Weight = 2
          .Borders(10).Weight = 2
         End With
         If Not receivers_dict.Exists(Sender_code & "@#Статус") Then _
            receivers_dict.add Sender_code & "@#Статус", fin_col_num+j+1
         fin_col_num = fin_col_num+ j + 1
        End If
      Next
    End If
    If fin_col_num <> start_col_num Then
     senders_dict.add Sender_code, start_col_num & "###" & fin_col_num
     With List.Range(List.Cells(3, start_col_num), List.Cells(3, fin_col_num))
       .MergeCells = True
       .HorizontalAlignment = -4108
       .WrapText = True
       .Borders.LineStyle = 1
       .Borders.Weight = -4138
     End With
     List.Range(List.Cells(3, start_col_num), List.Cells(3, fin_col_num-1)).Columns.Group
    End If
  Next 
  List.Range(List.Cells(4,5), List.Cells(4, fin_col_num)).HorizontalAlignment = -4108
  List.Range(List.Cells(4,5), List.Cells(4, fin_col_num)).WrapText = True
'  List.Range(List.Cells(4,1), List.Cells(4, fin_col_num)).AutoFilter
  curr_num = ""
  cur_row_num = 6
  task_state = ""
  For i = 0 To qrTasksSheet.RowsCount-1
    est_date = qrTasksSheet.CellValue(i,"TASK_EST_DATE")
    If est_date <> "" Then
      est_date = FormatDateTime(CDate(est_date),2)
    End If
    task_state = qrTasksSheet.CellValue(i,"TASK_STATE")
    If curr_num <> qrTasksSheet.CellValue(i,"OUNIT_NUM") Then
      curr_num = qrTasksSheet.CellValue(i,"OUNIT_NUM")
      cur_row_num = cur_row_num+1
      List.Cells(cur_row_num,1).Value = qrTasksSheet.CellValue(i,"OUNIT_NUM")
      List.Cells(cur_row_num,2).Value = qrTasksSheet.CellValue(i,"OUNIT_NAME")
      List.Range(List.Cells(cur_row_num+1,1),List.Cells(cur_row_num+1,1)).EntireRow.Insert
    End If
    If receivers_dict.Exists(qrTasksSheet.CellValue(i,"CODE_SENDER") & "@#" &_
     qrTasksSheet.CellValue(i,"CODE_RECEIVER")) Then
     r_col = receivers_dict.Item(qrTasksSheet.CellValue(i,"CODE_SENDER") & "@#" &_
      qrTasksSheet.CellValue(i,"CODE_RECEIVER"))
      If qrTasksSheet.CellValue(i,"DATE") <> "" Then
       If List.Cells(cur_row_num,r_col).Value <> "" Then
'        If List.Cells(cur_row_num,r_col).Value = "-" Then
'          List.Cells(cur_row_num,r_col).Value = FormatDateTime(CDate(qrTasksSheet.CellValue(i,"DATE")),2)
'        Else
          List.Cells(cur_row_num,r_col).Value = List.Cells(cur_row_num,r_col).Value & Chr(10) &_
           FormatDateTime(CDate(qrTasksSheet.CellValue(i,"DATE")),2)
'        End If
       Else
         List.Cells(cur_row_num,r_col).Value = FormatDateTime(CDate(qrTasksSheet.CellValue(i,"DATE")),2)
       End If
'      Else
'       If List.Cells(cur_row_num,r_col).Value = "" Then List.Cells(cur_row_num,r_col).Value = "-"
      End If
      'раскраска ячейки
      If task_state = "Задание выдано" Then
        List.Cells(cur_row_num,r_col).Interior.ColorIndex = 6
      ElseIf task_state <> "Задание выдано" And task_state <> "Аннулировано" THen
        If est_date <> "" Then
          If DateDiff("d",est_date,FormatDateTime(CDate(ThisApplication.CurrentTime),2)) > 0 Then
            List.Cells(cur_row_num,r_col).Interior.ColorIndex = 3
          Else
            List.Cells(cur_row_num,r_col).Interior.ColorIndex = 43
          End If
        End If
      End If
    End If
    If est_date <> "" Then
      If List.Cells(cur_row_num,3).Value = "" Then
        List.Cells(cur_row_num,3).Value = est_date
        List.Cells(cur_row_num,4).Value = est_date
      Else
        If DateDiff("d",est_date,CDate(List.Cells(cur_row_num,3).Value)) > 0 Then
          List.Cells(cur_row_num,3).Value = est_date
        ElseIf DateDiff("d",CDate(List.Cells(cur_row_num,4).Value),est_date) > 0 Then
          List.Cells(cur_row_num,4).Value = est_date
        End If
      End If
    End If
    finishUnitLine = False
    If i < qrTasksSheet.RowsCount-1 then
      If curr_num <> qrTasksSheet.CellValue(i+1,"OUNIT_NUM") Then finishUnitLine = True
    ElseIf i = qrTasksSheet.RowsCount-1 Then
     finishUnitLine = True
    End If
    If finishUnitLine = True Then

      For Each Key In senders_dict.Keys
        Key_col_num = senders_dict.Item(Key)
        srart_coll = CInt(Left(Key_col_num,InStr(Key_col_num,"###")-1))
        finish_coll = CInt(Right(Key_col_num,Len(Key_col_num)-InStrRev(Key_col_num,"###")-2))
        primeStatecolor = -4142
        For k = srart_coll To finish_coll-1
          If List.Cells(cur_row_num,k).Value = "" And _ 
            List.Cells(cur_row_num,k).Interior.ColorIndex = -4142 Then
             List.Cells(cur_row_num,k).Value = "-"
          ElseIf List.Cells(cur_row_num,k).Interior.ColorIndex <> -4142 Then
           Select Case List.Cells(cur_row_num,k).Interior.ColorIndex
            Case 6
              If primeStatecolor = -4142 Then primeStatecolor = 6
            Case 43
              If primeStatecolor <> 3 Then primeStatecolor = 43
            Case 3
              primeStatecolor = 3
           End Select
          End If
        Next
'        List.Cells(cur_row_num,finish_coll).Interior.PatternColorIndex = xlAutomatic
        List.Cells(cur_row_num,finish_coll).Interior.ColorIndex = CInt(primeStatecolor)
      Next
    End If
  Next
  List.Range(List.Cells(4,1), List.Cells(cur_row_num, fin_col_num)).AutoFilter
  With List.Range(List.Cells(6, 1), List.Cells(cur_row_num, fin_col_num)).Borders
    .LineStyle = 1
    .Weight = 2 '-4138 
  End With
  
  With List.Range(List.Cells(5,fin_col_num),List.Cells(5,fin_col_num))
'          .Borders(7).LineStyle = 1'xlContinuous
          .Borders(10).LineStyle = 1'xlContinuous
'          .Borders(7).Weight = 2
          .Borders(10).Weight = 2
  End With
  ExcelApp.Application.Visible = True
   
  senders_dict.RemoveAll
  receivers_dict.RemoveAll
  Set List = Nothing
  Set WrkBook = Nothing
  Set ExcelApp = Nothing
  Set file = Nothing
  Set senders_dict = Nothing
  Set receivers_dict = Nothing
  Set qrSendersSheet = Nothing
  Set qrSenders = Nothing
  Set qrTasksSheet = Nothing
  Set qrTasks = Nothing
End Sub
