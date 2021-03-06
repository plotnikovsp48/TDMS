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
    "Обновление базы от 04.09.2017")
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
  Call DeleteComm()
    progress.Position = 60
  Call SetSystemAttrs(AttrList())
    progress.Position = 70
  Call misc()
 
  Call ObjAttrsSync()
    progress.Position = 80
  Call contractIssueDateFill()
    progress.Position = 90
  Call AddSearchQueries()
    progress.Position = 100
End Sub


Sub DeleteClassifiers()
  List = "NODE_PROJECT_STRUCT4_10.1_"
 
Call SystemObjDelByList(List)
End Sub

Function AttrList()
  AttrList = "ATTR_FOLDER_OBJECT_CHANGE_PERMIT,ATTR_CERTIFICATE_SRO"
End Function


' Установка системных атрибутов
Sub SetSystemAttrs(aList)
  Progress.Text = "Настройка системных атрибутов"
  lst = aList
  arr = Split(lst,",")
  
  For each attrname In arr
    Progress.Text = "Настройка системных атрибутов: " & attrname
    If ThisApplication.AttributeDefs.Has(attrname) = True Then
      If ThisApplication.Attributes.Has(attrname) = False Then
        ThisApplication.Attributes.Create Thisapplication.AttributeDefs(attrname)
      End If
      Select Case attrname
        Case "ATTR_CERTIFICATE_SRO"
          Set Attr = ThisApplication.Attributes(attrname)
              Attr.Value = "Свидетельство СРО № П-963-2016-2466091092-175 от 26 мая 2016 г."
        Case "ATTR_FOLDER_OBJECT_CHANGE_PERMIT"
          For Each Obj in ThisApplication.ObjectDefs("OBJECT_KD_FOLDER").Objects
            If Obj.Attributes("ATTR_FOLDER_NAME").Value = "Разрешения на изменение" Then
              Set Attr = ThisApplication.Attributes(attrname)
              Attr.Value = Obj.GUID
              Exit For
            End If
          Next
      End Select
    End If
  Next
End Sub

Sub DeleteComm()
Progress.Text = "Обновляются команды"
List = "CMD_WORK_DOCS_SET_SET_ARH_N,CMD_TASK_SEND_TO_APPROVE,CMD_BOOK_G_CHECK,CMD_BOD_DOC_FIX,CMD_TENDER_INSIDE_NEW"
Call SystemObjDelByList(List)
End Sub

Sub Misc()
  List = "OBJECT_VOLUME:CMD_CHANGE_PERMIT_CREATE,OBJECT_WORK_DOCS_SET:CMD_CHANGE_PERMIT_CREATE,OBJECT_WORK_DOCS_SET:CMD_WORK_DOCS_SET_BACK_IN_WORK"
  arr = Split(List,",")
  For each attr in arr
    ar = Split(attr,":")
    Call  RemoveCommandFromObject(ar(0),ar(1))

  Next

'   Убираем с команд лишние статусы
  Call RemoveStatusFromCommand("CMD_WORK_DOCS_SET_BACK_IN_WORK","STATUS_WORK_DOCS_SET_IS_CHECKED_BY_NK")
  Call RemoveStatusFromCommand("CMD_WORK_DOCS_SET_BACK_IN_WORK","STATUS_WORK_DOCS_SET_IS_AGREED")
  Call RemoveStatusFromCommand("CMD_WORK_DOCS_SET_BACK_IN_WORK","STATUS_WORK_DOCS_SET_IS_APPROVED")

End Sub

Sub RemoveCommandFromObject(ObjDef,Command)
  If ThisApplication.ObjectDefs.Has(ObjDef) = False Then Exit Sub
  If ThisApplication.ObjectDefs(ObjDef).Commands.Has(Command) Then
    ThisApplication.ObjectDefs(ObjDef).Commands.Remove(Command)
  End If
End Sub


Sub ObjAttrsSync()
  Progress.Text = "Обновление атрибутов объекта:"
  List =  "OBJECT_CONTRACT,OBJECT_AGREEMENT,OBJECT_CONTRACT_COMPL_REPORT,OBJECT_DOCUMENT,OBJECT_WORK_DOCS_SET,OBJECT_VOLUME"
  Call ObjAttrSync(List)
End Sub

Sub contractIssueDateFill()
  For each Obj In ThisApplication.ObjectDefs("OBJECT_CONTRACT").Objects
    If Obj.Attributes("ATTR_DATA").Empty = False Then
      If Obj.Attributes.Has("ATTR_KD_REGDATE")= False Then Obj.Attributes.Create ThisApplication.AttributeDefs("ATTR_KD_REGDATE")
      Obj.Attributes("ATTR_KD_REGDATE") = Obj.Attributes("ATTR_DATA").value
    End If
    If Obj.Attributes("ATTR_KD_REGDATE").Empty = True Then
      Obj.Attributes("ATTR_KD_REGDATE") = Date
    End If
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
    Call AddQueryToObj(Obj,"QUERY_S_PROJECT_ALL")
    Call AddQueryToObj(Obj,"QUERY_S_CONTRACT_ALL")
    Call AddQueryToObj(Obj,"QUERY_S_PURCHASE_OUTSIDE")
    Call AddQueryToObj(Obj,"QUERY_S_TENDER_INSIDE")
End Sub



