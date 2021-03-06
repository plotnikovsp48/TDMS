' Команда - Загрузить протокол комиссии (Внутренняя закупка)
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
    If not Clf is Nothing Then Set Clf = Clf.Classifiers.Find("Протокол подведения итогов")
    Doc.Attributes("ATTR_PURCHASE_DOC_TYPE").Classifier = Clf
    Doc.Attributes("ATTR_DOCUMENT_NAME").Value = "Протокол подведения итогов"
    If not OrgObj is Nothing Then Doc.Attributes("ATTR_T_TASK_DEPARTMENT").Object = OrgObj
    
    Code = ThisApplication.ExecuteScript("CMD_S_NUMBERING","PurchaseDocCodeGen", Doc)
    If Code <> "" Then
    Doc.Attributes("ATTR_DOC_CODE").Value = Code
    End If
    regnum = ThisApplication.ExecuteScript("CMD_S_NUMBERING","PurchaseDocRegNumGen", Doc)
    Call SetRegNumber(Doc,regnum)
    
    
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
 'дата протокола соответствует дате, указанной в поле «Планируемая дата подведения итогов»
 ' Если дата не задана, задаем текущую   
 Data = ""
 Attrname = "ATTR_TENDER_RESULT_DATA_EIS"
 If Obj.Attributes.Has(Attrname) Then
 If Obj.Attributes(Attrname).empty = False Then
 If Obj.Attributes(Attrname).value <> "" Then  Data = Obj.Attributes(Attrname).value
 Else
 Obj.Attributes(Attrname).value = Date 
 Data = Date
 End If
 End If
'    MsgBox Data
    'Отображаем диалог редактирования объекта
    Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
    EditObjDlg.Object = Doc
    If EditObjDlg.Show Then
      If not Doc is Nothing Then
       If Obj.Attributes.Has("ATTR_TENDER_PROTOCOL") = True Then
       Obj.Attributes("ATTR_TENDER_PROTOCOL").Object = doc
         If Obj.Attributes.Has("ATTR_TENDER_PROTOCOL_DATA_NUM_EIS") = True Then
          Obj.Attributes("ATTR_TENDER_PROTOCOL_DATA_NUM_EIS").Value = (Doc.Attributes("ATTR_REG_NUMBER").Value &  "-"  & Num & chr(32) &  "от" & chr(32) & Data)
         End If
       End If 
       If Obj.Attributes.Has("ATTR_TENDER_FINISH_PROTOCOL") = True Then
       Obj.Attributes("ATTR_TENDER_FINISH_PROTOCOL").Object = doc
       End If 
'        'Маршрут
'        StatusName = "STATUS_TENDER_CHECK_RESULT"
'        RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
'        If RetVal = -1 Then
'          Obj.Status = ThisApplication.Statuses(StatusName)
'        End If
      End If
    End If
    
    'Результат импорта
    'If StrMsg <> "" Then 
    '  MsgBox "К объекту было добавлено " & count & " файлов:" & StrMsg, vbInformation
    'End If
  End If
  
  ThisScript.SysAdminModeOff
End Sub

'Генерим номер с датой

 Sub SetRegNumber(Obj,Num)
 ThisApplication.Utility.WaitCursor = True
 Set Parent = Obj.Parent
  'дата протокола соответствует дате, указанной в поле «Планируемая дата подведения итогов»
 ' Если дата не задана, задаем текущую   
 Data = ""
 Attrname = "ATTR_TENDER_RESULT_DATA_EIS"
 If Parent.Attributes.Has(Attrname) Then
 If Parent.Attributes(Attrname).empty = False Then
 If Parent.Attributes(Attrname).value <> "" Then  Data = Parent.Attributes(Attrname).value
 Else
' Parent.Attributes(Attrname).value = Date 
 Data = Date
 End If
 End If
' MsgBox Data
  regnum = ThisApplication.ExecuteScript("CMD_S_NUMBERING","PurchaseDocCodeGen", Obj) 
  Namu = "Протокол подведения итогов №" & chr(32) & regnum & chr(32) &  "от" & chr(32) & Data
 
'  regnum = "№ " & chr(32) & regnum '&  "-"  & Num & chr(32) &  "от" & chr(32) & Date
'  regnum = "/"  & regnum 
  
  If Obj.Attributes.Has("ATTR_PROJECT_ORDINAL_NUM") = False Then
    Obj.Attributes.Create("ATTR_PROJECT_ORDINAL_NUM")
  End If
  Obj.Attributes("ATTR_PROJECT_ORDINAL_NUM") = num
  Obj.Attributes("ATTR_REG_NUMBER") = regnum
  Obj.Attributes("ATTR_DOCUMENT_NAME") = Namu
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
