' Команда  - Титульный лист
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2016 г.

USE "CMD_DLL_REPORTS"

Call Main

Sub Main()
  Set CU = ThisApplication.CurrentUser
  Set ObjWord = Nothing
  Set ObjFile = Nothing
  Set Table = Nothing
  Set Templ = Nothing
  ProjectCode = ""
  UserDescr = ""
  RowStart = 1
  ColCount = 1
  nColStart = 0
  nColEnd = 0
  StrDate = Cstr(Date)
  StrDate = Left(StrDate,6) & Right(StrDate,2)
  
  'Получаем ФИО первого заместителя генерального директора
  Set Node = ThisApplication.Classifiers.FindBySysId("NODE_FIRST_DEPUTY_GENERAL_DIRECTOR")
  If not Node is Nothing Then
    If Node.AssignedUsers.Count > 0 Then
      Set User = Node.AssignedUsers(0)
      If User.FirstName <> "" and User.MiddleName <> "" and User.LastName <> "" Then
        UserDescr = User.FirstName & " " & User.MiddleName & " " & User.LastName
      Else
        UserDescr = User.Description
      End If
    End If
  End If
  
  'Получаем шифр Проекта
  'If ThisObject.Attributes("ATTR_PROJECT").Empty = False Then
  '  If not ThisObject.Attributes("ATTR_PROJECT").Object is Nothing Then
  '    Set Project = ThisObject.Attributes("ATTR_PROJECT").Object
  '    ProjectCode = Project.Attributes("ATTR_PROJECT_CODE").Value
  '  End If
  'End If
  
  'Получаем результат выборки
  Set Query = ThisApplication.Queries("QUERY_WDS_TIT_LIST")
  Query.Parameter("GUID") = ThisObject.GUID
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
  Set Templ = FindTemplate("",Fpath,"WDS_TLIST")
        
  'Запуск Word
  'NewDoc = WordStart(Fpath,ObjWord,ObjFile,Table,ColCount,RowStart)
    
  'If not ObjFile Is Nothing Then
    
    set ObjWord = CreateObject("Word.Application")
    If InStrRev(Fpath,"\") <> Len(Fpath) Then
      'Открытие существующего документа
      set ObjFile = ObjWord.Documents.open(Fpath)
    
      nColStart = 1
      
      'Set Fields = ObjFile.Sections(1).Range.Fields
      'Set Section = ObjFile.Sections(1)
      
      'Заполнение шапки шаблона
      For Each Fld in ObjFile.Fields
        FldName = LCase(Trim(Fld.Code.Text))
        Select Case FldName
          Case "1"
            Fld.Result.Text = Sheet.CellValue(0,0)
          Case "2"
            Fld.Result.Text = Sheet.CellValue(0,1)
          Case "3"
            Fld.Result.Text = Sheet.CellValue(0,2)
          Case "4"
            Fld.Result.Text = Sheet.CellValue(0,3)
          Case "5"
            Fld.Result.Text = Sheet.CellValue(0,4)
          Case "6"
            Fld.Result.Text = Sheet.CellValue(0,5)
          Case "7"
            Fld.Result.Text = UserDescr
        End Select
      Next
      
    End If
    
    ThisApplication.Utility.WaitCursor = False
    ObjWord.Visible = True
    ObjFile.Save
    Set ObjWord = Nothing
  'End If
End Sub

