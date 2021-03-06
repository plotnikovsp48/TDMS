' Команда  - Создать Заявку на печать
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2016 г.

Call Main

Sub Main()
  Set Form = ThisApplication.InputForms("FORM_PRINT_REQUEST_FILES_SEL")
  Set TableRows = Form.Attributes("ATTR_FILES_TBL").Rows
  Set CU = ThisApplication.CurrentUser
  
  'Заполняем форму выбора файлов
  Select Case ThisObject.ObjectDefName
    'Чертеж
    Case "OBJECT_DRAWING"
      Call TableObjFill(TableRows,ThisObject)
    'Проектный документ
    Case "OBJECT_DOC_DEV"
      Call TableObjFill(TableRows,ThisObject)
    'Документ
    Case "OBJECT_DOCUMENT"
      Call TableObjFill(TableRows,ThisObject)
    'Раздел
    Case "OBJECT_PROJECT_SECTION"
      Call TableObjFill(TableRows,ThisObject)
      For Each Child in ThisObject.ContentAll
        If Child.ObjectDefName = "OBJECT_PROJECT_SECTION_SUBSECTION" or _
        Child.ObjectDefName = "OBJECT_DRAWING" or Child.ObjectDefName = "OBJECT_DOC_DEV" Then
          Call TableObjFill(TableRows,Child)
        End If
      Next
    'Подраздел
    Case "OBJECT_PROJECT_SECTION_SUBSECTION"
      Call TableObjFill(TableRows,ThisObject)
      For Each Child in ThisObject.ContentAll
        If Child.ObjectDefName = "OBJECT_DRAWING" or Child.ObjectDefName = "OBJECT_DOC_DEV" Then
          Call TableObjFill(TableRows,Child)
        End If
      Next
    'Основной комплект
    Case "OBJECT_WORK_DOCS_SET"
      For Each Child in ThisObject.ContentAll
        If Child.ObjectDefName = "OBJECT_DRAWING" or Child.ObjectDefName = "OBJECT_DOC_DEV" Then
          Call TableObjFill(TableRows,Child)
        End If
      Next
    'Том
    Case "OBJECT_VOLUME"
      Call TableObjFill(TableRows,ThisObject)
      For Each Child in ThisObject.ContentAll
        If Child.ObjectDefName = "OBJECT_DOCUMENT" Then
          Call TableObjFill(TableRows,Child)
        End If
      Next
    'Разрешение на изменения
    Case "OBJECT_CHANGE_PERMIT"
      Call TableObjFill(TableRows,ThisObject)
  End Select
  
  'Если нет файлов, то выходим
  If TableRows.Count = 0 Then
    Msgbox "Нет файлов для печати.", vbExclamation
    Exit Sub
  End If
  
  'Показыаем форму выбора файлов
  If Form.Show Then
    'Проверяем, есть ли выбранные файлы
    Check = False
    For Each Row in TableRows
      If Row.Attributes("ATTR_FILES_TBL_CHECK").Value = True Then
        Check = True
        Exit For
      End If
    Next
    If Check = False Then
      Msgbox "Вы не выбрали ни одного файла.", vbExclamation
      Exit Sub
    End If
    
    'Создание Заявки на печать
    ThisApplication.Utility.WaitCursor = True
    Set NewObj = ThisApplication.ObjectDefs("OBJECT_PRINT_REQUEST").CreateObject
    Set TableRows0 = NewObj.Attributes("ATTR_PRINT_REQUEST_FILES_TBL").Rows
    Set Dlg = ThisApplication.Dialogs.EditObjectDlg
    Dlg.Object = NewObj
    'Заполнение атрибутов Заявки
    NewObj.Attributes("ATTR_PRINT_REQUEST_USER").User = CU
    'NewObj.Attributes("ATTR_PRINT_REQUEST_DEPT").Classifier = CU.DepartmentClassifier
    If CU.Attributes.Has("ATTR_KD_USER_DEPT") Then
      If CU.Attributes("ATTR_KD_USER_DEPT").Empty = False Then
        If not CU.Attributes("ATTR_KD_USER_DEPT").Object is Nothing Then
          NewObj.Attributes("ATTR_PRINT_REQUEST_DEPT").Object = CU.Attributes("ATTR_KD_USER_DEPT").Object
        End If
      End If
    End If
    NewObj.Attributes("ATTR_PRINT_REQUEST_NUM").Value = GetRequestNum
    If ThisObject.Attributes.Has("ATTR_PROJECT") Then
      If ThisObject.Attributes("ATTR_PROJECT").Empty = False Then
        If not ThisObject.Attributes("ATTR_PROJECT").Object is Nothing Then
          NewObj.Attributes("ATTR_PROJECT").Object = ThisObject.Attributes("ATTR_PROJECT").Object
        End If
      End If
    End If
    For Each Row in TableRows
      If Row.Attributes("ATTR_FILES_TBL_CHECK").Value = True Then
        Set NewRow = TableRows0.Create
        Set Obj0 = Row.Attributes("ATTR_FILES_TBL_OBJECT").Object
        If Obj0.Attributes.Has("ATTR_S_FORMAT") = True Then
          NewRow.Attributes("ATTR_PRINT_FORMAT").Classifier = Obj0.Attributes("ATTR_S_FORMAT").Classifier
        End If
      End If
      NewRow.Attributes("ATTR_PRINT_COPY_COUNT").Value = 1
      NewRow.Attributes("ATTR_PRINT_SCALE").Value = 100
      NewRow.Attributes("ATTR_PRINT_FILE").Value = FilesCopy(Row,Obj0,NewObj)
    Next
    
    'Создаем роли
    Call ThisApplication.ExecuteScript("CMD_DLL", "SetRole",NewObj,"ROLE_PRINT_STARTER",CU)
    
    ThisApplication.Utility.WaitCursor = False
    Dlg.Show
  End If
End Sub

'Процедура добавления в таблицу файлов от указанного объекта
Sub TableObjFill(TableRows,Obj)
  For Each File in Obj.Files
    Set NewRow = TableRows.Create
    NewRow.Attributes("ATTR_FILES_TBL_FILE_NAME").Value = File.FileName
    NewRow.Attributes("ATTR_FILES_TBL_OBJECT").Object = Obj
  Next
End Sub

'Функция получения номера заявки
Function GetRequestNum()
  GetRequestNum = 1
  Set Query = ThisApplication.Queries("QUERY_PRINT_REQUEST_MAX_NUM")
  Set Sheet = Query.Sheet
  If Sheet.RowsCount <> 0 Then
    GetRequestNum = Sheet.CellValue(0,0)+1
  End If
End Function

'Функция копирования файла из одного объета в другой
'Row:Object - Ссылка на строку с файлом
'Obj0:Object - Объект, с которого копируется файл
'Obj1:Object - Объект, в который копируется файл
'Функция возвращает имя скопированного файла
Function FilesCopy(Row,Obj0,Obj1)
  FilesCopy = ""
  Fname = Row.Attributes("ATTR_FILES_TBL_FILE_NAME").Value
  For Each File0 in Obj0.Files
    If File0.FileName = Fname Then
      For Each File1 in Obj1.Files
        If File1.FileName = Fname Then
          Fname = Obj0.Description & " - " & Fname
          Exit For
        End If
      Next
      Set NewFile = Obj1.Files.AddCopy(File0, Fname)
      FilesCopy = NewFile.FileName
      Exit For
    End If
  Next
End Function


