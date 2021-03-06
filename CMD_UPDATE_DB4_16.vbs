
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
    "Обновление базы от 14.11.2017")
  If ans<>vbYes Then Exit Sub
  
  Call Run()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub

Sub Run()

'================================= Новое обновление БД-4

Call SetSystemAttrs("")
progress.Position = 20
cALL AddAttrs()
progress.Position = 90

'===================================================  

End Sub

' Установка системных атрибутов
Sub SetSystemAttrs(aList)
  Progress.Text = "Настройка системных атрибутов"
  lst = "ATTR_KD_T_FORMS_SHOW," & aList
  arr = Split(lst,",")
  
  For each attrname In arr
    Progress.Text = "Настройка системных атрибутов: " & attrname
    Select Case attrname
      Case "ATTR_KD_T_FORMS_SHOW"
        Call Set_ATTR_KD_T_FORMS_SHOW()
    End Select
  Next
End Sub

' Заполняем функцию в таблицу согласования
Sub Set_ATTR_KD_T_FORMS_SHOW()
  List = "OBJECT_T_TASK,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
          "OBJECT_CONTRACT,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
          "OBJECT_AGREEMENT,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
          "OBJECT_CONTRACT_COMPL_REPORT,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
          "OBJECT_INVOICE,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
          "OBJECT_DOC_DEV,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
          "OBJECT_DOC_DEV,STATUS_DOCUMENT_IS_SENT_TO_NK,FORM_DOC_NK," & _
          "OBJECT_DOC_DEV,STATUS_DOCUMENT_IS_TAKEN_NK,FORM_DOC_NK," & _
          "OBJECT_DRAWING,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
          "OBJECT_DRAWING,STATUS_DOCUMENT_IS_SENT_TO_NK,FORM_DOC_NK," & _
          "OBJECT_DRAWING,STATUS_DOCUMENT_IS_TAKEN_NK,FORM_DOC_NK," & _
          "OBJECT_DOCUMENT,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
          "OBJECT_DOCUMENT_AN,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE," & _
          "OBJECT_LIST_AN,STATUS_KD_AGREEMENT,FORM_KD_DOC_AGREE"
  arr = Split(List,",")
  Set Table = ThisApplication.Attributes("ATTR_KD_T_FORMS_SHOW")
  NeedToAdd = False
  For i = 0 to Ubound(arr) step 3
    For each row in Table.Rows
        If (row.Attributes("ATTR_KD_OBJ_TYPE").Value = arr(i) And _
          row.Attributes("ATTR_KD_START_STATUS").Value = arr(i+1) And _
          row.Attributes("ATTR_KD_FORMS_LIST").Value = arr(i+2)) = False Then
          NeedToAdd = True
        Else
          NeedToAdd = False
          Exit For
        End If
    Next
    If NeedToAdd Then
      Set NewRow = Table.Rows.Create
      NewRow.Attributes("ATTR_KD_OBJ_TYPE") = arr(i) 
      NewRow.Attributes("ATTR_KD_START_STATUS") = arr(i+1) 
      NewRow.Attributes("ATTR_KD_FORMS_LIST") = arr(i+2) 
      NeedToAdd = False
    End If          
  Next
End Sub

Sub AddAttrs()
  List = "OBJECT_CONTRACT_COMPL_REPORT,ATTR_CCR_ZA" 
  Arr1 = Split(List,":")
  
  for each arr In Arr1
    Ar = Split(arr,",")
    For i = 1 To Ubound(ar)
      For each obj In ThisApplication.ObjectDefs(ar(0)).Objects
        If Obj.Attributes.Has(ar(i)) = False Then
          Obj.Attributes.Create ar(i)
        End If
      Next
    Next
  Next
End Sub


Sub AddSearchQueries()
  Set Obj = ThisApplication.GetObjectByGUID("{CB841149-1125-45E0-BB2B-2ECE14BA8357}")
  If Obj Is Nothing Then
  For each Obj In ThisApplication.ObjectDefs("OBJECT_ARM_FOLDER").Objects
    If Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ПОИСК" Then
      Exit For
    End If
  Next
  End If
    Call AddQueryToObj(Obj,"QUERY_S_ARCH_DOCS")
End Sub

Sub RemoveFromObjDef()
  Progress.Text = "Обновляются связи объекта:"
  ObjList = "OBJECT_VOLUME"
  ObjArr = Split(ObjList,",")
  
  For Each ObjDefName In ObjArr
    Progress.Text = "Обновляются связи объектов: " & ObjDefName
    Select Case ObjDefName
      Case "OBJECT_VOLUME","OBJECT_WORK_DOCS_SET"
        List = "FORM_KD_AGREE"
    End Select
  
    arr = Split(List,",")
    For Each ObjSysName In arr
      call SystemObjRemoveFromObject(str0,ObjDefName,ObjSysName)
    Next
  Next
End Sub
