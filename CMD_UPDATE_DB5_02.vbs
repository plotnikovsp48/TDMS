USE "CMD_TASKS_EXECUTE"
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
    "Обновление базы от 12.01.2018")
  If ans<>vbYes Then Exit Sub
  
  Call Run()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub

Sub Run()

'================================= Новое обновление БД-4
Call Case6097()
Call SetSystemAttrs("")
progress.Position = 100
'===================================================  

End Sub

Sub Case6097()
  str = "Кейс 6097:"
  str0 = ""
  Progress.Text = "Выполняется кейс 6097"
  
  CountAdd = 0
  
  'Добавление атрибутов
  StrAdd = "ATTR_OLD_CONTRACT"
  Call ObjDefAttrAddAll("OBJECT_CONTRACT",StrAdd,"",str0)
  
  'Заполнение атрибута Контактное лицо
  Set Query = ThisApplication.Queries("QUERY_CONTACT_PERSON_FOR_CONTRACT")
  AttrName0 = "ATTR_CONTACT_PERSON"
  AttrName1 = "ATTR_CONTACT_PERSON_STR"
  If ThisApplication.AttributeDefs.Has(AttrName0) Then
    AttrDescr = ThisApplication.AttributeDefs(AttrName0).Description
  End If
  For Each Obj in ThisApplication.ObjectDefs("OBJECT_CONTRACT").Objects
    If Obj.Attributes.Has(AttrName1) and Obj.Attributes.Has(AttrName0) Then
      If Obj.Attributes(AttrName1).Empty = False and Obj.Attributes(AttrName0).Empty = True Then
        Val = Obj.Attributes(AttrName1).Value
        Pos = InStr(Val,", ")-1
        If Pos >= 0 Then Val = Left(Val,Pos)
        If Val <> "" Then
        Param = "= '*" & Val & "*'"
          Query.Parameter("DESCR") = Param
        End If
        Set Objects = Query.Objects
        If Objects.Count = 1 Then
          Obj.Attributes(AttrName0).Object = Objects(0)
          str0 = str0 & chr(10) & chr(9) & "Заполнен атрибут """ & AttrDescr & """ у договора """ & Obj.Description & """"
        End If
      End If
    End If
  Next
  
  'Журнал выполнения
'  Call Notify(str,str0)
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
  List =  "OBJECT_T_TASK-,STATUS_T_TASK_IN_WORK,FORM_S_TASK," & _
          "OBJECT_CONTRACT-,STATUS_T_TASK_INVALIDATED,FORM_S_TASK"

  arr = Split(List,",")
  Set Table = ThisApplication.Attributes("ATTR_KD_T_FORMS_SHOW")

  For i = 0 to Ubound(arr) step 3
    For each row in Table.Rows
        If row.Attributes("ATTR_KD_OBJ_TYPE").Value = arr(i) Then
          Row.Attributes("ATTR_KD_OBJ_TYPE") = Left(arr(i),Len(arr(i))-1)
        End If
    Next
  Next
End Sub
