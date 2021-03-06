' Команда - Загрузить Акт (Внутренняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  
  Set Dlg = ThisApplication.Dialogs.FileDlg
  Set ObjDef = ThisApplication.ObjectDefs("OBJECT_PURCHASE_DOC")
  If ObjDef.FileDefs.Count = 0 Then
    Msgbox "Документ закупки не может иметь файлов.", vbExclamation
    Exit Sub
  End If
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
    StrMsg = ""
    If Dlg.FileName = "" Then
      Msgbox "Файлы не выбраны.", vbExclamation
      Exit Sub
    End If
    
    Set OrgObj = Nothing
    OrgName = "Отдел по договорной работе и закупочным процедурам"
    For Each StrObj in ThisApplication.ObjectDefs("OBJECT_STRU_OBJ").Objects
      If StrObj.Attributes.Has("ATTR_NAME") and StrObj.Attributes.Has("ATTR_KD_CHIEF") Then
        If StrComp(StrObj.Attributes("ATTR_NAME").Value,OrgName,vbTextCompare) = 0 Then
          Set OrgObj = StrObj
        End If
      End If
    Next
    Set Doc = Obj.Objects.Create(ObjDef)
    Set Clf = ThisApplication.Classifiers.Find("Вид документа закупки")
    If not Clf is Nothing Then Set Clf = Clf.Classifiers.Find("Методика анализа")
    Doc.Attributes("ATTR_PURCHASE_DOC_TYPE").Classifier = Clf
    Doc.Attributes("ATTR_DOCUMENT_NAME").Value = "Методика анализа"
    If not OrgObj is Nothing Then Doc.Attributes("ATTR_T_TASK_DEPARTMENT").Object = OrgObj
    
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
    
    'Отображаем диалог редактирования объекта
    Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
    EditObjDlg.Object = Doc
  If EditObjDlg.Show Then
     If not Doc is Nothing Then
  Obj.Attributes("ATTR_TENDER_RES_CHECK_METOD").Object = doc
        'Маршрут
'        StatusName = "STATUS_TENDER_CHECK_RESULT"
        RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
        If RetVal = -1 Then
 '          Obj.Status = ThisApplication.Statuses(StatusName)
        End If
      End If
    End If
   
   'Результат импорта
'    'If StrMsg <> "" Then 
'    '  MsgBox "К объекту было добавлено " & count & " файлов:" & StrMsg, vbInformation
'    'End If
  End If
  
  ThisScript.SysAdminModeOff
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
