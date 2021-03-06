USE "CMD_DLL_UPDATE"
'===========================================================================================================


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
    "Обновление базы от 19.03.2018")
  If ans<>vbYes Then Exit Sub
  
  Call Run()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub




'================================= Новое обновление БД-4
Sub Run()
  Call SetSystemAttrs("ATTR_KD_T_FORMS_SHOW")
End Sub
'===================================================  


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
  List =  "OBJECT_AGREEMENT,STATUS_AGREEMENT_DRAFT,FORM_AGREEMENT," & _
"OBJECT_AGREEMENT,STATUS_AGREEMENT_FOR_SIGNING,FORM_AGREEMENT," & _
"OBJECT_AGREEMENT,STATUS_AGREEMENT_SIGNED,FORM_AGREEMENT," & _
"OBJECT_AGREEMENT,STATUS_AGREEMENT_EDIT,FORM_AGREEMENT," & _
"OBJECT_AGREEMENT,STATUS_AGREEMENT_FORCED,FORM_AGREEMENT," & _
"OBJECT_AGREEMENT,STATUS_AGREEMENT_INVALIDATED,FORM_AGREEMENT"

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