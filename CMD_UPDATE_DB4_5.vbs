USE "CMD_DLL_UPDATE"
'===========================================================================================================
' Обновление за 28.07.2017


  ThisScript.SysAdminModeOn
  ThisApplication.Utility.WaitCursor = True
  Set Progress = ThisApplication.Dialogs.ProgressDlg
  Progress.Start
  progress.SetLocalRanges 0,100
  progress.Position = 0
  
  Call Update()
  
  progress.Position = 100
  ThisApplication.Utility.WaitCursor = False
  Progress.Stop
  
  
Sub Update()
  ans = msgbox ("Процедура обновления может занять некоторое время. Продолжить? ",vbQuestion+vbYesNo,_
    "Обновление базы от 11.09.2017")
  If ans<>vbYes Then Exit Sub
  
  Call Run()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub

Sub Run()

'================================= Новое обновление БД-4



  Call DeleteClassifiers()
    progress.Position = 20
  Call AddSystemAttribute(AttrList()) 
    progress.Position = 40
  Call SetSystemAttrs(AttrList())
    progress.Position = 70

 Call DeleteTemplates()
Call RemoveFromObjDef
    progress.Position = 100
End Sub


' Установка системных атрибутов
Sub SetSystemAttrs(aList)
  Progress.Text = "Настройка системных атрибутов"
  lst = "ATTR_AGREENENT_SETTINGS" & aList
  arr = Split(lst,",")
  
  For each attrname In arr
    Progress.Text = "Настройка системных атрибутов: " & attrname
    Select Case attrname
      Case "ATTR_AGREENENT_SETTINGS"
        Call Set_ATTR_AGREENENT_SETTINGS()

    End Select
  Next
End Sub


' Заполняем функцию в таблицу согласования
Sub Set_ATTR_AGREENENT_SETTINGS()
  ' Заполняем функцию в таблицу согласования
  val = "OBJECT_PURCHASE_DOC;PurchaseDocCheck"
  Set Table = ThisApplication.Attributes("ATTR_AGREENENT_SETTINGS")
    For each row in Table.Rows
      Select Case row.Attributes("ATTR_KD_OBJ_TYPE").Value
        Case "OBJECT_PURCHASE_DOC"
          row.attributes("ATTR_KD_CHECK_FUNCTION").value = val
        Case "OBJECT_T_TASK"
          row.attributes("ATTR_KD_CHECK_FUNCTION").value = "CMD_DLL;CheckAgreeStatus"
          row.attributes("ATTR_KD_START_STATUS").value = "STATUS_T_TASK_IN_WORK; STATUS_T_TASK_IS_CHECKING; STATUS_T_TASK_IS_SIGNING;STATUS_T_TASK_IS_SIGNED"
        Case "OBJECT_PURCHASE_OUTSIDE","OBJECT_CONTRACT","OBJECT_CONTRACT_COMPL_REPORT","OBJECT_AGREEMENT"
          row.attributes("ATTR_KD_CHECK_FUNCTION").value = "CMD_DLL;CheckAgreeStatus"
        Case "OBJECT_WORK_DOCS_SET","OBJECT_VOLUME"
          row.attributes("ATTR_KD_CHECK_FUNCTION").value = "CMD_DLL;CheckAgreeStatus"
        Case "OBJECT_DOC_DEV","OBJECT_DRAWING"
          row.attributes("ATTR_KD_CHECK_FUNCTION").value = "CMD_DLL;CheckAgreeStatus"
          row.attributes("ATTR_KD_START_STATUS").value = "STATUS_DOC_IS_ADDED;STATUS_DOCUMENT_CHECK;STATUS_DOCUMENT_CREATED;STATUS_DOCUMENT_DEVELOPED"
        Case "OBJECT_STAGE","OBJECT_DOCUMENT_AN"
          row.attributes("ATTR_KD_CHECK_FUNCTION").value = "CMD_DLL;CheckAgreeStatus"
      End Select
    Next
End Sub



Sub DeleteClassifiers()
  List = "NODE_PROJECT_STRUCT4_10.1_"
 
Call SystemObjDelByList(List)
End Sub

Function AttrList()
  AttrList = ""
End Function





Sub Misc()
' Удаляем файлы

Set fDef = ThisApplication.FileDefs("FILE_OBJECT_VOLUME")
For each file In fDef.Templates

Next

End Sub




Sub RemoveCommandFromObject(ObjDef,Command)
  If ThisApplication.ObjectDefs.Has(ObjDef) = False Then Exit Sub
  If ThisApplication.ObjectDefs(ObjDef).Commands.Has(Command) Then
    ThisApplication.ObjectDefs(ObjDef).Commands.Remove(Command)
  End If
End Sub


Sub DeleteTemplates()
  List = "FILE_OBJECT_VOLUME,Пояснительная записка.doc,FILE_OBJECT_VOLUME,Раздел 5 ИОС.docx,FILE_OBJECT_VOLUME,Титульный лист Тома.docx," &_
        "FILE_ANY,Пояснительная записка.doc,FILE_ANY,Раздел 5 ИОС.docx,FILE_ANY,Титульный лист Тома.docx"
  arr = Split(List,",")
  
  For i = 0 To Ubound(arr) Step 2
    Call DeleteTemplate(arr(i),Arr(i+1))
  Next
End Sub

Sub DeleteTemplate(fDefSysName,file)
  If ThisApplication.FileDefs.Has(fDefSysName) Then
    Set fDef = ThisApplication.FileDefs(fDefSysName)
      If fDef.Templates.Has(file) Then
        fDef.Templates(file).Erase
      End If
  End If
End Sub


Sub RemoveFromObjDef()
  Progress.Text = "Обновляются связи объекта:"
  ObjList = "OBJECT_DOC,OBJECT_AGREEMENT,OBJECT_CONTRACT,OBJECT_CONTRACT_COMPL_REPORT,OBJECT_CONTRACT_STAGE,OBJECT_DOCUMENT,OBJECT_PURCHASE_DOC," &_
  "OBJECT_PURCHASE_LOT,OBJECT_PURCHASE_OUTSIDE,OBJECT_T_TASK,OBJECT_TENDER_INSIDE,OBJECT_DOC_DEV,OBJECT_DRAWING"
  ObjArr = Split(ObjList,",")
  
  For Each ObjDefName In ObjArr
    Progress.Text = "Обновляются связи объектов: " & ObjDefName
    Select Case ObjDefName
      Case "OBJECT_AGREEMENT"
        List = "FORM_KD_AGREE"
      Case "OBJECT_CONTRACT"
        List = "FORM_KD_AGREE"
      Case "OBJECT_CONTRACT_COMPL_REPORT"
        List = "FORM_KD_AGREE"
      Case "OBJECT_CONTRACT_STAGE"
        List = "FORM_KD_AGREE"
      Case "OBJECT_DOCUMENT"
        List = "FORM_KD_AGREE"
      Case "OBJECT_DOC"
        List = "FORM_KD_AGREE"
      Case "OBJECT_PURCHASE_DOC"
        List = "FORM_KD_AGREE"
      Case "OBJECT_PURCHASE_LOT"
        List = "FORM_KD_AGREE"
      Case "OBJECT_PURCHASE_OUTSIDE"
        List = "FORM_KD_AGREE"
      Case "OBJECT_T_TASK"
        List = "FORM_KD_AGREE"
      Case "OBJECT_TENDER_INSIDE"
        List = "FORM_KD_AGREE"
      Case Else
        List = "FORM_KD_AGREE"
    End Select
  
    arr = Split(List,",")
    For Each ObjSysName In arr
      call SystemObjRemoveFromObject(str0,ObjDefName,ObjSysName)
    Next
  Next
End Sub
