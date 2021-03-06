' Команда - Загрузить Акт (Внутренняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject, ThisForm)

Sub Main(Obj, Form)
  ThisScript.SysAdminModeOn

  Set Dlg = ThisApplication.Dialogs.FileDlg
  Set ObjDef = ThisApplication.ObjectDefs("OBJECT_PURCHASE_DOC")

    '  Открытие диалога загрузки файлов
  str = ""
  '"Файлы ZIP|*.zip|All Files (*.*)|*.*||"
  For Each FileDef in ObjDef.FileDefs
    str0 = FileDef.Description & "|" & FileDef.Extensions & "|"
    If str <> "" Then
      str = str & str0
    Else
      str = str0
    End If
  Next
  str = Replace(str,",",";") & "|"
  Dlg.Filter = str
  If Dlg.Show Then
    StrMsg = "Выберите файлы документа"
    If Dlg.FileName = "" Then
      Msgbox "Файлы не выбраны.", vbExclamation
      Exit Sub
    End If
'    Проверяем и добавляем файлы в документ
    Set Doc = Obj.Objects.Create(ObjDef)
   For Each Fname in Dlg.FileNames
        Set FDef = CheckFileDef(Doc,Fname)
      If not FDef is Nothing Then
        Set NewFile = Doc.Files.Create(FDef.SysName)
        On Error Resume Next
        NewFile.CheckIn FName
        If Err <> 0 Then
          FShortName = Right(FName, Len(Fname) - InStrRev(FName, "\"))
          MsgBox "Файл """ & FShortName & """ уже есть в составе объекта.", vbInformation
          'удалить пустой файл
          NewFile.Erase
        Else
          StrMsg = StrMsg & Chr(13) & FName
          count = count+1
        End If
        On Error Goto 0
      End If
    Next    
      '    Заполняем атрибуты в документе
  Set OrgObj = Nothing
  OrgName = "Отдел по договорной работе и закупочным процедурам"
    Set Clf = ThisApplication.Classifiers.Find("Вид документа закупки")
    If not Clf is Nothing Then Set Clf = Clf.Classifiers.Find("Заявка на запрос предложений")
    Doc.Attributes("ATTR_PURCHASE_DOC_TYPE").Classifier = Clf
    Doc.Attributes("ATTR_DOCUMENT_NAME").Value = "Заявка на запрос предложений"
    If not OrgObj is Nothing Then Doc.Attributes("ATTR_T_TASK_DEPARTMENT").Object = OrgName
'    Заполняем атрибут Участник в документе
   Set Table = Form.Controls("ATTR_TENDER_INSIDE_ORDER_LIST").ActiveX
       nRow = Table.SelectedRow
  If not nRow+1 => Table.RowCount Then 
  Set Row = Table.RowValue(nRow)
   If not Row is Nothing Then 
  If Row.Attributes("ATTR_TENDER_INVITATION_COUNT_EIS").Empty Then Exit Sub
  If Row.Attributes("ATTR_TENDER_INVITATION_COUNT_EIS").Object is Nothing Then Exit Sub
  Doc.Attributes("ATTR_TENDER_INVITATION_COUNT_EIS") = row.Attributes("ATTR_TENDER_INVITATION_COUNT_EIS")
  End If
  End If  
 Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
    EditObjDlg.Object = Doc
  If EditObjDlg.Show Then
   End If
   End If
End Sub

'Функция проверки типа файла на доступные для объекта
Function CheckFileDef(Obj,FName)
  Set CheckFileDef = Nothing
  FExtension = "*." & Right(FName, Len(Fname) - InStrRev(FName, "."))
  For Each FDef In Obj.ObjectDef.FileDefs
    If InStr(FDef.Extensions, FExtension) <> 0 Then
      Set CheckFileDef = FDef
      Exit Function
    End If
  Next
End Function
