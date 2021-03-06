' Команда  - Общая структура объектов
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "CMD_DLL_REPORTS"

Call Main(ThisObject)

Sub Main(Obj)
  Set CU = ThisApplication.CurrentUser
  Set ObjWord = Nothing
  Set ObjFile = Nothing
  Set Table = Nothing
  Set Templ = Nothing
  Set Stage = Nothing
  Set Parent = Nothing
  Set Query = Nothing
  Guid = Obj.Guid
  ClfName0 = "Рабочая документация"
  ClfName1 = "Проектная документация"
  RowStart = 1
  ColCount = 1
  nColStart = 0
  nColEnd = 0
  ColorGreen = RGB(0,176,80)
  ColorWhite = RGB(255,255,255)
  TemplName = "Общая структура объектов"
  
  'Запрос стадии проектирования
  Pstage = False 'Проектная документация
  WStage = False 'Рабочая документация
  For Each Child in Obj.Content
    If Child.ObjectDefName = "OBJECT_STAGE" Then
      Val = Child.Attributes("ATTR_PROJECT_STAGE").Value
      If StrComp(Val,ClfName0,vbTextCompare) = 0 Then
        WStage = True
        Set Stage = Child
      End If
      If StrComp(Val,ClfName1,vbTextCompare) = 0 Then Pstage = True
    End If
  Next
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_FOLDER"
  q.AddCondition tdmQueryConditionAttribute, Obj, "ATTR_PROJECT"
  q.AddCondition tdmQueryConditionAttribute, "NODE_FOLDER_PROJECT_WORK", "ATTR_FOLDER_TYPE"
  Set Objects = q.Objects
  If Objects.Count > 0 Then
    Set Parent = Objects(0)
    Pstage = True
  End If
  
  'Не найдены стадии
  If Wstage = False and Pstage = False Then
    Msgbox "Стадии проектирования не найдены.",vbExclamation
    Exit Sub
    
  'Рабочая документация
  ElseIf Wstage = True and Pstage = False Then
    Set Query = ThisApplication.Queries("QUERY_REPORT_GENERAL_STUCT_PROJECT_1")
    Set Parent = Stage
    
  'Проектная документация
  ElseIf Wstage = False and Pstage = True Then
    Set Query = ThisApplication.Queries("QUERY_REPORT_GENERAL_STUCT_PROJECT_0")
    
  'Выбор стадии
  Else
    Set Dlg = ThisApplication.Dialogs.SelectDlg
    Arr = Split(ClfName0&";"&ClfName1,";")
    Dlg.SelectFrom = Arr
    If Dlg.Show Then
      Arr0 = Dlg.Objects
      If Ubound(Arr0) > -1 Then
        Val = Arr0(0)
        If Val = ClfName0 Then
          Set Query = ThisApplication.Queries("QUERY_REPORT_GENERAL_STUCT_PROJECT_1")
          Set Parent = Stage
        ElseIf Val = ClfName1 Then
          Set Query = ThisApplication.Queries("QUERY_REPORT_GENERAL_STUCT_PROJECT_0")
        End If
      End If
    End If
  End If
  If Query is Nothing Then Exit Sub
  If Parent is Nothing Then Exit Sub
  
  
  'Set q = ThisApplication.CreateQuery
  'q.Permissions = sysadminpermissions
  'q.AddCondition tdmQueryConditionObjectDef, "OBJECT_STAGE"
  'q.AddCondition tdmQueryConditionAttribute, Obj, "ATTR_PROJECT"
  'q.AddCondition tdmQueryConditionAttribute, "= '"&ClfName0&"' or = '"&ClfName1&"'", "ATTR_PROJECT_STAGE"
  'Set Objects = q.Objects
  'If Objects.Count = 0 Then
  '  Msgbox "Стадии проектирования не найдены.",vbExclamation
  '  Exit Sub
  'ElseIf Objects.Count = 1 Then
  '  Set Stage = Objects(0)
  'ElseIf Objects.Count > 1 Then
  '  Set Dlg = ThisApplication.Dialogs.SelectDlg
  '  Dlg.SelectFrom = Objects
  '  If Dlg.Show Then
  '    If Dlg.Objects.Count > 0 Then
  '      Set Stage = Dlg.Objects(0)
  '    End If
  '  End If
  'End If
  'If Stage is Nothing Then Exit Sub
  
  'Зпрашиваем структуру в виде таблицы
  'StageName = Stage.Attributes("ATTR_PROJECT_STAGE").Value
  '' Рабочая документация
  'If StageName = ClfName0 Then
  '  Set Query = ThisApplication.Queries("QUERY_REPORT_GENERAL_STUCT_PROJECT_1")
  '  Set Parent = Stage
  '' Проектная документация
  'ElseIf StageName = ClfName1 Then
  '  Set Query = ThisApplication.Queries("QUERY_REPORT_GENERAL_STUCT_PROJECT_0")
  '  Set q = ThisApplication.CreateQuery
  '  q.Permissions = sysadminpermissions
  '  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_FOLDER"
  '  q.AddCondition tdmQueryConditionAttribute, Obj, "ATTR_PROJECT"
  '  q.AddCondition tdmQueryConditionAttribute, "NODE_FOLDER_PROJECT_WORK", "ATTR_FOLDER_TYPE"
  '  Set Objects = q.Objects
  '  If Objects.Count > 0 Then Set Parent = Objects(0)
  'End If
  ParentGuid = Parent.Guid
  Query.Parameter("PROJECT") = Obj
  Query.Parameter("PARENT") = Parent
  Set Sheet = Query.Sheet
  ColCount = Sheet.ColumnsCount
  nColEnd = ColCount-1
  If Sheet.RowsCount = 0 Then
    Msgbox "Структура объектов не найдена.",vbExclamation
    Exit Sub
  End If
  
  fName = Obj.Description & " - Общая структура объектов " & Now() & ".docx"

  'Запрос папки выгрузки
'  Fpath = GetPathSave
  SelFileName = GetFileSave(fName)
  If IsArray(SelFileName) = False Then Exit Sub
  SaveFileName = SelFileName(0)
'  If Fpath = "" Then Exit Sub
  pos = InStrRev(SaveFileName,"\")
  Fpath = Left(SaveFileName,pos-1)
  fName = Right(SaveFileName,Len(SaveFileName)-pos)
  
  
  'Проверка файла
'  FileIsOpened = ThisApplication.ExecuteScript("CMD_SS_LIB", "FileIsOpened", Fpath&"\"&TemplName&".docx")
  FileIsOpened = ThisApplication.ExecuteScript("CMD_SS_LIB", "FileIsOpened", SaveFileName)
  If FileIsOpened Then
    Msgbox "Невозможно сформировать состав проекта, т.к. файл открыт в редакторе",vbExclamation
    Exit Sub
  End If
  
  ThisApplication.Utility.WaitCursor = True
  
  'Выгрузка шаблона
  Set Templ = FindTemplate("",Fpath,TemplName)
        
  'Запуск Word
  NewDoc = WordStart(Fpath,ObjWord,ObjFile,Table,ColCount,RowStart)
    
  If not ObjFile Is Nothing Then  
    'Заполнение таблицы
    Call TableLoopFill(Table,Sheet,0,ParentGuid,Query,ColorGreen,ColorWhite)
    ObjWord.Visible = True
    ObjFile.Save
    Set ObjWord = Nothing
  End If
  
  ThisApplication.Utility.WaitCursor = False
End Sub

'Процедура циклического заполнения таблицы
Private Sub TableLoopFill(Table,Sheet,RowCount,ParentGuid,Query,ColorGreen,ColorWhite)
  For i = 0 to Sheet.RowsCount-1
    Set Obj0 = Sheet.RowValue(i)
    If RowCount > 0 Then Table.Rows.Add
    RowNum = Table.Rows.Count
    Table.cell(RowNum,1).range.text = Sheet.CellValue(i,0)
    Table.cell(RowNum,2).range.text = Sheet.CellValue(i,1)
    
    If Sheet.CellValue(i,2) = ParentGuid Then
      Table.cell(RowNum,2).Range.Bold = 1
      Table.Rows(RowNum).Shading.BackgroundPatternColor = ColorGreen
      Table.cell(RowNum,2).Range.Font.Size = "11"
    Else
      Table.cell(RowNum,2).Range.Bold = 0
      Table.Rows(RowNum).Shading.BackgroundPatternColor = ColorWhite
      Table.cell(RowNum,2).Range.Font.Size = "10"
    End If
    
    RowCount = RowCount + 1
    If not Obj0 is Nothing Then
      Query.Parameter("PARENT") = Obj0
      Set Sheet0 = Query.Sheet
      If Sheet.RowsCount > 0 Then
        Call TableLoopFill(Table,Sheet0,RowCount,ParentGuid,Query,ColorGreen,ColorWhite)
      End If
    End If
  Next
End Sub
