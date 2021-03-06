
Call Main()
ThisApplication.Utility.Waitcursor = False
msgbox "Отчет сформирован."

Sub Main
  ThisApplication.Utility.Waitcursor = TRUE
  Set proj = ThisObject
  'проверка на кол-во осн комплектов в стадии, если 0 выходим
  If proj.ReferencedBy.ObjectsByDef("OBJECT_WORK_DOCS_FOR_BUILDING").Count = 0 then
    msgbox "Ошибка. Отсутствуют комплекты в текущем проекте. Выполнение команды прекращено."
    Exit Sub
  End If
  
  Set file = ThisApplication.FileDefs("FILE_DOC_XLS").Templates("Working_documents_registry_template.xlsx")
  datetime = ThisApplication.CurrentTime
  DocNameToSave = "Report_work_doc_registry_" & Day(datetime) & "-" & Month(datetime) & "_" &_ 
    Hour(datetime) & "-" & Minute(datetime) & "-" & Second(datetime) & ".xlsx"
  DocNameToSave = ThisApplication.WorkFolder & "\" & DocNameToSave
  file.CheckOut(DocNameToSave)
  Set ExcelApp = CreateObject("Excel.Application")
  Set WrkBook = ExcelApp.Workbooks.Open(DocNameToSave)
  Set List = WrkBook.ActiveSheet
  'заполняем excel колонками*

  Set dep_receivers_dict = ThisApplication.Dictionary("DepReceivers")
  dep_receivers_dict.RemoveAll
  start_col_num = 13
  Set DepReceiversQr = ThisApplication.Queries("QUERY_REPORT_WORKDOCREG_DEP_REC_UNIQ")
  DepReceiversQr.Parameter("PROJECT") = proj.GUID
  Set qrDepReceiversSheet = DepReceiversQr.Sheet
  'если кол-во отделов-получателей из того же ОП что и тек пользователь в выборке = 0,
  'удаляем лишнюю колонку, дозаполняем номера и Dictionary
  'переменная обозначающая, наличие отделов-получателей. False - есть, True - только смежные
  OnlyNeighborDep = False
  'переменная для хранения номера колонки
  'последний номер колонки будет №смежной колонки+5
  '12 - последний номер колонки перед подразделениями-получателями
  initial_col_num = 12
  If qrDepReceiversSheet.RowsCount = 0 Then
   OnlyNeighborDep = True
   List.Columns(13).Delete -4159
'    List.Range(List.Cells(4,13), List.Cells(5,13)).EntireColumn.Delete -4159
   List.Cells(7,13) = "Обмен заданиями"
  Else
   Set CheckForSmQr = ThisApplication.Queries("QUERY_REPORT_WORKDOCREG_SMETA_CHECK")
   For i = 0 To qrDepReceiversSheet.RowsCount-1
    CheckForSmQr.Parameter("DEP_IDENTIFY") = qrDepReceiversSheet.CellValue(i,"DEP_RECEIVERS_ID")
    Set CheckForSmQrSheet = CheckForSmQr.Sheet
    If CheckForSmQrSheet.RowsCount = 0 Then
      initial_col_num = initial_col_num + 1
     If initial_col_num <> 13 Then
      List.Columns(initial_col_num).Insert -4161, 0
     End If
     List.Cells(8,initial_col_num) = qrDepReceiversSheet.CellValue(i,"DEP_RECEIVERS_CODE")
     List.Cells(9,initial_col_num) = initial_col_num
     dep_receivers_dict.add qrDepReceiversSheet.CellValue(i,"DEP_RECEIVERS_CODE"), initial_col_num
    Else
     dep_receivers_dict.add qrDepReceiversSheet.CellValue(i,"DEP_RECEIVERS_CODE"), "SM"
    End If
    Set CheckForSmQrSheet = Nothing
   Next
  End If
'**************
'в initial_col_num последний номер колонки перед смежными подразделениями
'в last_col_num последний номер колонки
'*************
  last_col_num = initial_col_num + 6
  'проставление номеров остальных колонок, начиная со смежных подразделений
  For i = initial_col_num+1 To last_col_num
   List.Cells(9,i) = i
'   dep_receivers_dict.add qrDepReceiversSheet.CellValue(i,"DEP_RECEIVERS_CODE"), initial_col_num
  Next
  List.Cells(10,1) = proj.Attributes("ATTR_NAME_SHORT")
  Set StageQR = ThisApplication.Queries("QUERY_REPORT_WORKDOCREG_FULLSET_TOP")
' ЭД-ЭС замена Этапа договора (находится в договоре) на Этап строительства (находится) в Проекте в Этапах строительства
'  Set contract = proj.Attributes("ATTR_CONTRACT").Object
  Set ConstructionPhasesCol = proj.ReferencedBy.ObjectsByDef("OBJECT_BUILD_STAGE")
  start_row = 11
  row_num = start_row
  dep_receivers_dict.add "row_num", row_num
  If ConstructionPhasesCol.Count > 0 Then
'  If Not contract Is Nothing Then
    ConstructionPhasesCol.Sort True
'   If contract.ReferencedBy.ObjectsByDef("OBJECT_CONTRACT_STAGE").Count > 0 Then
    For Each stage IN ConstructionPhasesCol
      row_num = dep_receivers_dict.Item("row_num")
      StageQR.Parameter("PROJECT") = proj.GUID
      StageQR.Parameter("STAGE") = stage.GUID
      Set StageObjects = StageQR.Objects
      If StageObjects.Count > 0 Then
      'заполняем excel информации по Этапу
       List.Cells(row_num,1) = stage.Description
       With List.Range(List.Cells(row_num,1), List.Cells(row_num, last_col_num))
         .MergeCells = True
         .HorizontalAlignment = -4108
         .WrapText = True
         .Borders.LineStyle = 1
         .Borders.Weight = -4138
         .Font.Bold = True
         .Font.Size = 14
         .Interior.Color = 15921906
       End With
       stage_num = stage.Attributes("ATTR_CODE")
       row_num = dep_receivers_dict.Item("row_num") + 1
       dep_receivers_dict.Item("row_num") = row_num
       For each fullset in StageObjects
        'здесь находятся "верхушки" деревьев Полных комплектов, относящихся к одному этапу
        'всё что в их составе относится к этому же этапу
        'разворачиваем последовательно, сначала все полные комплекты, потом основные комплекты
        Call ExploreTreeRecursion(fullset,stage_num,List,last_col_num,dep_receivers_dict)
       Next
      End If
    Next
 '  Else
   'если нет этапов
   'End If
'  Else
    'если нет договора
  End If
  'комплекты без этапов
  row_num = dep_receivers_dict.Item("row_num")
  StageQR.Parameter("PROJECT") = proj.GUID
  StageQR.Parameter("STAGE") = "NULL"
  Set StageObjects = StageQR.Objects
  If StageObjects.Count > 0 Then
   'заполняем excel информации по Этапу
   List.Cells(row_num,1) = "Комплекты без этапов"
   With List.Range(List.Cells(row_num,1), List.Cells(row_num, last_col_num))
    .MergeCells = True
    .HorizontalAlignment = -4108
    .WrapText = True
    .Borders.LineStyle = 1
    .Borders.Weight = -4138
    .Font.Bold = True
    .Font.Size = 14
    .Interior.Color = 15921906
   End With
   stage_num = ""
   row_num = dep_receivers_dict.Item("row_num") + 1
   dep_receivers_dict.Item("row_num") = row_num
   For each fullset in StageObjects
    Call ExploreTreeRecursion(fullset,stage_num,List,last_col_num,dep_receivers_dict)
   Next
  End If
  
  
  
  ExcelApp.Visible = True
End Sub

Sub ExploreTreeRecursion(eFullSet,eStageNum,List,last_col_num,dep_receivers_dict)
  row_num = dep_receivers_dict.Item("row_num")
  fullset_val = eFullSet.Description
  If eFullSet.Attributes("ATTR_BUILDING_CODE") <> "" Then
   fullset_val = fullset_val & " (поз. " & eFullSet.Attributes("ATTR_BUILDING_CODE") & ")"
  End If
  Call Fill_OBJECT_WORK_DOCS_FOR_BUILDING_in_Excel(fullset_val,eStageNum,List,row_num,last_col_num)
  row_num = dep_receivers_dict.Item("row_num") + 1
  dep_receivers_dict.Item("row_num") = row_num
  If eFullSet.Content.ObjectsByDef("OBJECT_WORK_DOCS_SET").Count > 0 Then
    For Each sChild In eFullSet.Content.ObjectsByDef("OBJECT_WORK_DOCS_SET")
     If sChild.Attributes("ATTR_BUILDING_STAGE") = eFullSet.Attributes("ATTR_BUILDING_STAGE") Then
      Call Fill_ATTR_CONTRACT_STAGE_in_Excel(sChild,eStageNum,List,last_col_num,dep_receivers_dict)
     End If
    Next
  End If
  
  If eFullSet.Content.ObjectsByDef("OBJECT_WORK_DOCS_FOR_BUILDING").Count > 0 Then
    For Each Child In eFullSet.Content.ObjectsByDef("OBJECT_WORK_DOCS_FOR_BUILDING")
     If Child.Attributes("ATTR_BUILDING_STAGE") = eFullSet.Attributes("ATTR_BUILDING_STAGE") Then
       Call ExploreTreeRecursion(Child,eStageNum,List,last_col_num,dep_receivers_dict)
     End If
    Next
  End If
End Sub
'Заполнение ПОлного комплекта
Sub Fill_OBJECT_WORK_DOCS_FOR_BUILDING_in_Excel(fDescr,fStageNum,List,fRowNum,fLastColNum)
   List.Cells(fRowNum,1) = fDescr
   With List.Range(List.Cells(fRowNum,1), List.Cells(fRowNum, 2))
         .MergeCells = True
         .HorizontalAlignment = -4108
         .WrapText = True
         .Borders.LineStyle = 1
         .Borders.Weight = -4138
         .Font.Bold = True
         .Font.Size = 12
   End With
   List.Cells(fRowNum,3) = "'" & fStageNum
   With List.Range(List.Cells(fRowNum,3), List.Cells(fRowNum, 3))
         .HorizontalAlignment = -4108
         .WrapText = True
         .Borders.LineStyle = 1
         .Borders.Weight = -4138
         .Font.Bold = True
         .Font.Size = 12
   End With
   With List.Range(List.Cells(fRowNum,4), List.Cells(fRowNum, fLastColNum))
         .HorizontalAlignment = -4108
         .WrapText = True
         '.Borders(9) = xlEdgeBottom
         '.Borders(8) = xlTop
         .Borders(9).LineStyle = 1
         .Borders(9).Weight = -4138
         .Borders(8).LineStyle = 1
         .Borders(8).Weight = -4138
         .Font.Bold = True
         .Font.Size = 12
   End With
   With List.Range(List.Cells(fRowNum,fLastColNum), List.Cells(fRowNum, fLastColNum))
         .Borders(10).LineStyle = 1
         .Borders(10).Weight = -4138
   End With
End Sub

Sub Fill_ATTR_CONTRACT_STAGE_in_Excel(fChild,fStageNum,List,fLastColNum,dep_receivers_dict)
  fRowNum = dep_receivers_dict.Item("row_num")
  List.Cells(fRowNum,1) = fChild.Attributes("ATTR_WORK_DOCS_SET_NAME")
  List.Cells(fRowNum,2) = fChild.Attributes("ATTR_WORK_DOCS_SET_CODE")
  List.Cells(fRowNum,3) = "'" & fStageNum
  'разработчик
  If fChild.Attributes("ATTR_SUBCONTRACTOR_CLS").Empty = False THen
    List.Cells(fRowNum,4) = fChild.Attributes("ATTR_SUBCONTRACTOR_CLS").Object.Description
  Else
    List.Cells(fRowNum,4) = "КГНГП"
  End If
  'планируемая дата выпуска, фактическая дата выпуска
  If fChild.ReferencedBy.ObjectsbyDef("OBJECT_P_TASK").Count > 0 THen
    List.Cells(fRowNum,5) = fChild.ReferencedBy.ObjectsbyDef("OBJECT_P_TASK").Item(0).Attributes("ATTR_ENDDATE_PLAN")
    List.Cells(fRowNum,6) = fChild.ReferencedBy.ObjectsbyDef("OBJECT_P_TASK").Item(0).Attributes("ATTR_ENDDATE_FACT")
    List.Cells(fRowNum,fLastColNum-4) = fChild.ReferencedBy.ObjectsbyDef("OBJECT_P_TASK").Item(0).Attributes("ATTR_ENDDATE_FACT")
    List.Range(List.Cells(fRowNum,5), List.Cells(fRowNum,6)).NumberFormat = "dd.mm.yyyy"
    List.Range(List.Cells(fRowNum,fLastColNum-4), List.Cells(fRowNum,fLastColNum-4)).NumberFormat = "dd.mm.yyyy"
  End If
  'Изменения
  Set maxChangePermitQr = ThisApplication.Queries("QUERY_REPORT_WORKDOCREG_CHANGE_PERMITMAX")
  maxChangePermitQr.Parameter("COMPLECT") = fChild.GUID
  Set maxChangePermitQrSheet = maxChangePermitQr.Sheet
  If maxChangePermitQrSheet.RowsCount <> 0 and maxChangePermitQrSheet.CellValue(0,0) <> 0 Then
    Set ChangePermitQr = ThisApplication.Queries("QUERY_REPORT_WORKDOCREG_CHANGE_PERMIT")
    ChangePermitQr.Parameter("COMPLECT") = fChild.GUID
    ChangePermitQr.Parameter("CHANGE_PERM_NUM") = maxChangePermitQrSheet(0,0)
    Set ChangePermitQrSheet = ChangePermitQr.Sheet
    change_num = maxChangePermitQrSheet.CellValue(0,0)
    change_date = ""
    changers = ""
    If ChangePermitQrSheet.RowsCount <> 0 Then
      change_date = ChangePermitQrSheet.CellValue(0,1)
      For j = 0 To ChangePermitQrSheet.RowsCount-1
        If ChangePermitQrSheet.CellValue(j,"USER_FIO") <> "" Then
          changers = changers & ChangePermitQrSheet.CellValue(j,"USER_FIO")
          If j <> ChangePermitQrSheet.RowsCount-1 Then 
            changers = changers & ", "
          End If
        End If
      Next
    End If
    Set ChangePermitQrSheet = Nothing
    Set ChangePermitQr = Nothing
    List.Cells(fRowNum,8) = change_num
    List.Cells(fRowNum,9) = change_date
    List.Range(List.Cells(fRowNum,9), List.Cells(fRowNum,9)).NumberFormat = "dd.mm.yyyy"
    List.Cells(fRowNum,10) = changers
  End If
  Set maxChangePermitQrSheet = Nothing
  Set maxChangePermitQr = Nothing
  'отделы

  Set DepReceiversDatesQr = ThisApplication.Queries("QUERY_REPORT_WORKDOCREG_DEP_REC_DATES")
  DepReceiversDatesQr.Parameter("PROJECT") = fChild.Attributes("ATTR_PROJECT").Object.GUID
  DepReceiversDatesQr.Parameter("SET") = fChild.GUID
  Set DepReceiversDatesSheet = DepReceiversDatesQr.Sheet
  If DepReceiversDatesSheet.RowsCount <> 0 Then
   For j = 0 To DepReceiversDatesSheet.RowsCount-1
    If DepReceiversDatesSheet.CellValue(j,"TASK_DATE") <> "" Then
      If dep_receivers_dict.Exists(DepReceiversDatesSheet.CellValue(j,"DEP_RECEIVERS_CODE")) Then
        r_col = dep_receivers_dict.Item(DepReceiversDatesSheet.CellValue(j,"DEP_RECEIVERS_CODE"))
        If r_col <> "SM" Then
         If List.Cells(fRowNum,r_col).Value <> "" Then
           List.Cells(fRowNum,r_col).Value = List.Cells(fRowNum,r_col).Value & Chr(10) &_
            DateFormat(FormatDateTime(CDate(DepReceiversDatesSheet.CellValue(j,"TASK_DATE")),2))
         Else
           List.Cells(fRowNum,r_col).Value = DateFormat(FormatDateTime(CDate(DepReceiversDatesSheet.CellValue(j,"TASK_DATE")),2))
'           List.Range(List.Cells(fRowNum,r_col), List.Cells(fRowNum,r_col)).NumberFormat = "dd.mm.yyyy"
         End If
        Else
         If List.Cells(fRowNum,fLastColNum-2).Value = "" THen
          List.Cells(fRowNum,fLastColNum-2).Value = DateFormat(FormatDateTime(CDate(DepReceiversDatesSheet.CellValue(j,"TASK_DATE")),2))
'          List.Range(List.Cells(fRowNum,r_col), List.Cells(fRowNum,r_col)).NumberFormat = "dd.mm.yyyy"
         Else
          List.Cells(fRowNum,fLastColNum-2).Value = List.Cells(fRowNum,fLastColNum-2).Value & Chr(10) &_ 
           DateFormat(FormatDateTime(CDate(DepReceiversDatesSheet.CellValue(j,"TASK_DATE")),2))
         End If
'         List.Range(List.Cells(fRowNum,fLastColNum-2), List.Cells(fRowNum,fLastColNum-2)).NumberFormat = "dd.mm.yyyy"
        End If
      End If
    End If
   Next
  End If
  With List.Range(List.Cells(fRowNum,1), List.Cells(fRowNum, fLastColNum))
         .HorizontalAlignment = -4108
         .WrapText = True
         .Borders.LineStyle = 1
         .Borders.Weight = 2
         .Font.Bold = False
         .Font.Size = 10
  End With
  'Согласование ОЛ/ТЧДЗ с Заказчиком
  Set GetOLforSetQr = ThisApplication.Queries("QUERY_REPORT_WORKDOCREG_OL")
  GetOLforSetQr.Parameter("COMPLECT") = fChild.GUID
  Set GetOLforSetQrSheet = GetOLforSetQr.Sheet
  ol_list = ""
  If GetOLforSetQrSheet.RowsCount <> 0 Then
   For j = 0 To GetOLforSetQrSheet.RowsCount-1
    ol_list = ol_list & GetOLforSetQrSheet.CellValue(j,0) & ":" & GetOLforSetQrSheet.CellValue(j,1)
    If j <> GetOLforSetQrSheet.RowsCount-1 Then 
     ol_list = ol_list & "; "
    End If
   Next
   List.Cells(fRowNum,fLastColNum-3) = ol_list
  End If
  Set GetOLforSetQr = Nothing
  Set GetOLforSetQrSheet = Nothing   
  fRowNum = dep_receivers_dict.Item("row_num") + 1
  dep_receivers_dict.Item("row_num") = fRowNum
End Sub

Function DateFormat(mDate)
    dd = Day(mDate)
    If Len(dd) = 1 Then dd = "0" & dd
    mm = Month(mDate)
    If Len(mm) = 1 Then mm = "0" & mm   
    yyyy = Year(mDate)
    DateFormat= dd & "." & mm & "." & yyyy
End Function
