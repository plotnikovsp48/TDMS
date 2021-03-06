' Команда  - Журнал входящих заданий
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2016 г.

USE "CMD_DLL_REPORTS"

Call Main

Sub Main()
  Set CU = ThisApplication.CurrentUser
  Set Form = ThisApplication.InputForms("FORM_TASK_JOURNAL")
  Set Dict = ThisApplication.Dictionary("JOURNAL")
  Set ObjWord = Nothing
  Set ObjFile = Nothing
  Set Table = Nothing
  Set Templ = Nothing
  RowStart = 1
  ColCount = 1
  nColStart = 0
  nColEnd = 0
  
  'Начальные условия для формы
  Form.Attributes("ATTR_S_START_DATE").Value = DateAdd("d",-30,Date)
  Form.Attributes("ATTR_S_END_DATE").Value = Date
  If CU.Attributes.Has("ATTR_KD_USER_DEPT") Then
    If CU.Attributes("ATTR_KD_USER_DEPT").Empty = False Then
      If not CU.Attributes("ATTR_KD_USER_DEPT").Object is Nothing Then
        Form.Attributes("ATTR_T_TASK_DEPARTMENT").Object = CU.Attributes("ATTR_KD_USER_DEPT").Object
      End If
    End If
  End If
  
  If Form.Show Then
    'Получаем результат выборки
    Set Query = ThisApplication.Queries("QUERY_TASK_JOURNAL_INCOMING")
    Dept = Form.Attributes("ATTR_T_TASK_DEPARTMENT").Value
    If Form.Attributes("ATTR_T_TASK_DEPARTMENT").Empty = False Then
      If not Form.Attributes("ATTR_T_TASK_DEPARTMENT").Object is Nothing Then
        Query.Parameter("DEPT") = Form.Attributes("ATTR_T_TASK_DEPARTMENT").Object
      End If
    End If
    Query.Parameter("PROJECT") = ThisObject
    DateIn = Form.Attributes("ATTR_S_START_DATE").Value
    DateOut = Form.Attributes("ATTR_S_END_DATE").Value
    If DateIn <> "" and DateOut <> "" Then
      Dict.Item("DateStart") = DateIn
      Dict.Item("DateEnd") = DateOut
      Query.Parameter("DATEDIF") = ">= '" & DateIn & "' AND <= '" & DateOut & "'"
    End If
    Set Sheet = Query.Sheet
    ColCount = Sheet.ColumnsCount
    nColEnd = ColCount-1
    If Sheet.RowsCount = 0 Then
      Msgbox "Журнал пуст.",vbExclamation
      Exit Sub
    End If
    
    'Запрос папки выгрузки
    Fpath = GetPathSave
    If Fpath = "" Then Exit Sub
    Fpath = Fpath & "\"
    
    ThisApplication.Utility.WaitCursor = True
    
    'Выгрузка шаблона
    Set Templ = FindTemplate("T",Fpath,"TASK_JOURNAL_INCOMING")
        
    'Запуск Word
    NewDoc = WordStart(Fpath,ObjWord,ObjFile,Table,ColCount,RowStart)
    
    If not ObjFile Is Nothing Then
      'Заполняем найденный шаблон
      If NewDoc = False and Table.Rows.Count > 1 Then
        nColStart = 6
        'Заполнение шапки шаблона
        For Each Fld in ObjFile.Fields
          FldName = LCase(Trim(Fld.Code.Text))
          Select Case FldName
            Case "project"
              Fld.Result.Text = Sheet.CellValue(0,0)
            Case "dept"
              Fld.Result.Text = Dept
            Case "datein"
              Fld.Result.Text = DateIn
            Case "dateout"
              Fld.Result.Text = DateOut
            Case "dategen"
              Fld.Result.Text = Date
            Case "user"
              Fld.Result.Text = CU.Description
          End Select
        Next
      Else
        'Заполняем новый документ
        Call TableHeaderFill(Table,Sheet,RowStart,ColCount)
      End If
        
      'Заполнение таблицы
      Call TableFill(Table,Sheet,RowStart,nColStart,nColEnd)
      
      ThisApplication.Utility.WaitCursor = False
      ObjWord.Visible = True
      ObjFile.Save
      Set ObjWord = Nothing
    End If
  End If
End Sub


