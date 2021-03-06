
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
    "Обновление базы от 13.11.2017")
  If ans<>vbYes Then Exit Sub
  
  Call Run()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub

Sub Run()

'================================= Новое обновление БД-4

Call SetSystemAttrs("")
progress.Position = 20
cALL AddAttrs()
progress.Position = 50
progress.Position = 60

progress.Position = 65
Call DeleteForms()
progress.Position = 80
Call DeleteAttrs()
'progress.Position = 80
Call AddGroups()
progress.Position = 90

'===================================================  

End Sub


' Установка системных атрибутов
Sub SetSystemAttrs(aList)
  Progress.Text = "Настройка системных атрибутов"
  lst = "ATTR_AGREENENT_SETTINGS," & aList
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
  Set Table = ThisApplication.Attributes("ATTR_AGREENENT_SETTINGS")
    For each row in Table.Rows
      Select Case row.Attributes("ATTR_KD_OBJ_TYPE").Value
        Case "OBJECT_CONTRACT"
          row.attributes("ATTR_KD_FINISH_STATUS").value = "STATUS_CONTRACT_FOR_SIGNING"
          row.attributes("ATTR_AFTER_AGREE_FUNCTION").value = "OBJECT_CONTRACT;AfterAgreeProcessing"
      End Select
    Next
End Sub

Sub AddAttrs()

List = "OBJECT_TENDER_INSIDE,ATTR_TENDER_RES_CHECK_METOD,ATTR_TENDER_ORDER:" & _
        "OBJECT_PURCHASE_OUTSIDE,ATTR_TENDER_OUT_FLOW_CASTOM,ATTR_TENDER_ORDER:" & _
        "OBJECT_PURCHASE_FOLDER,ATTR_TENDER_OUT_FLOW_CASTOM"
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
  
  
'Во внутреннюю закупку OBJECT_TENDER_INSIDE:
'ATTR_TENDER_RES_CHECK_METOD, ATTR_TENDER_ORDER

'Во внешнюю закупку OBJECT_PURCHASE_OUTSIDE:
'ATTR_TENDER_OUT_FLOW_CASTOM, ATTR_TENDER_ORDER

'В Закупки OBJECT_PURCHASE_FOLDER:
'ATTR_TENDER_OUT_FLOW_CASTOM

End Sub

Sub DeleteForms()
ThisScript.SysAdminModeOn
Progress.Text = "Удаление форм:"
list = "FORM_5A9A12E9_9A81_4269_BE2B_9DF16CF06E4D,"
Call SystemObjDelByList(List)
End Sub

Sub DeleteAttrs()
ThisScript.SysAdminModeOn
  Progress.Text = "Обновление атрибутов"
  
  List = "ATTR_7BF71D0B_0D56_4059_854B_A80709A72825,"
  arr = Split(List,",")
  For each attr in arr
    Progress.Text = "Удаление атрибутов из типов объектов: " & attr
    Call ThisApplication.ExecuteScript("CMD_TASKS_EXECUTE","SystemObjDel","",attr)
    ' Удаление атрибутов из типов объектов
    Call AttrProcessing(attr)
  Next
End Sub

Sub DelAttr(ObjsName)
  ThisScript.SysAdminModeOn
     If ThisApplication.AttributeDefs.Has(ObjsName) = True Then 
      Set Attr = ThisApplication.AttributeDefs(ObjsName)
      Attr.Erase
      If ThisApplication.AttributeDefs.Has(ObjsName) = False Then
        str0 = str0 & chr(10) & "Из системы удален тип атрибута """ & Descr & """"
      End If
    End If
End Sub

Sub AttrProcessing(ObjSysName)
ThisScript.SysAdminModeOn
  If ThisApplication.AttributeDefs.Has(ObjSysName) Then
    Set Attr = ThisApplication.AttributeDefs(ObjSysName)
    Descr = Attr.Description
    For Each ObjDef in ThisApplication.ObjectDefs
      If ObjDef.AttributeDefs.Has(Attr) Then
        ObjDef.AttributeDefs.Remove Attr
        Progress.Text = "Удаление атрибутов из типов объектов: " & Descr & ": " & ObjDef.Description
        str0 = str0 & chr(10) & "Из типа объекта объекта """ & ObjDef.Description & """ удален атрибут """ & Descr & """"
      End If
    Next
  End If    
End Sub

Sub AddGroups()
  Set gr = AddGroup("GROUP_CONTRACTS_ISSUE")
  gr.SysName = "GROUP_CONTRACTS_ISSUE"
  gr.Description = "Оформление договоров"
  Set u = ThisApplication.Users.GetUserByLogin("Скрипальщикова")
  If gr.Users.Has(u) = False Then
    gr.Users.Add ThisApplication.Users.GetUserByLogin("Скрипальщикова")
  End If
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
