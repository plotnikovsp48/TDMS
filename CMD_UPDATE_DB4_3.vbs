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
    "Обновление базы от 28.08.2017")
  If ans<>vbYes Then Exit Sub
  
  Call Run()
  msgbox "Обновление базы завершено!",vbInformation,"Завершение"
End Sub

Sub Run()

'================================= Новое обновление БД-4

  Call RemoveFromObjDef()
  progress.Position = 40
  Call ObjAttrsSync()
  progress.Position = 25
  Call DeleteAttrs()
  Call AddSysAttr()
  Call SetSystemAttrs(AttrList())
  progress.Position = 80
  Call misc()
  Call SetSectionsDefault()
  progress.Position = 100
End Sub



Sub RemoveFromObjDef()
  Progress.Text = "Обновляются связи объекта:"
  ObjList = "OBJECT_INVOICE,OBJECT_TENDER_INSIDE"
  ObjArr = Split(ObjList,",")
  
  For Each ObjDefName In ObjArr
    Progress.Text = "Обновляются связи объектов: " & ObjDefName
    Select Case ObjDefName
      Case "OBJECT_INVOICE"
        List = "ATTR_INVOICE_RECIPI-ENT_COMMENT,ATTR_DATA"
      Case "OBJECT_TENDER_INSIDE"
        List = "ATTR_33684181_DB4B_4797_9BD7_CD6C640D5514"
    End Select
    Call RemoveSysFromObjDef(ObjDefName & ":" & List)
  Next
End Sub


' Синхронизация атрибутов объектов
Sub ObjAttrsSync()
  Progress.Text = "Обновление атрибутов объекта:"
  List =  "OBJECT_INVOICE,OBJECT_TENDER_INSIDE,OBJECT_PURCHASE_OUTSIDE"
  Call ObjAttrSync(List)
End Sub




Sub Set_Stage()
  List = "OBJECT_WORK_DOCS_FOR_BUILDING,OBJECT_WORK_DOCS_SET,OBJECT_PROJECT_SECTION_SUBSECTION,OBJECT_PROJECT_SECTION,OBJECT_VOLUME"

  arr = Split(List,",")
  For i = 0 to Ubound(arr)
    Progress.Text = "Заполнение атрибута Стадия: " & arr(i)
    Call SetStage(arr(i))
  Next
End Sub

Sub SetStage(ObjDefName)
  For each Obj In ThisApplication.ObjectDefs(ObjDefName).Objects
    If Obj.Attributes.Has("ATTR_STAGE") = False Then
      Obj.Attributes.Create ThisApplication.AttributeDefs("ATTR_STAGE")
    End If
    If Obj.Attributes("ATTR_STAGE").Empty = True Then
      Set Stage = ThisApplication.ExecuteScript("CMD_S_DLL","GetStage",Obj)
      Obj.Attributes("ATTR_STAGE") = Stage
    End If
  Next
End Sub


Sub DeleteAttrs()
  Progress.Text = "Обновление атрибутов"

  List = "ATTR_!!!,ATTR_INVOICE_RECIPI-ENT_COMMENT,ATTR_INVOICE_NUMBER,ATTR_INVOICE_DATE," & _
         "ATTR_7C4FBE23_B08C_4B24_A6BF_5FC3D2FD83B4,ATTR_TENDER_CARD_ATTR_TABLE,ATTR_TENDER_RESP_USER," & _
         "ATTR_TENDER_REASON_URGENTLY_FLAG"
  Call  SystemObjDelByList(List)
End Sub

Function AttrList()
  AttrList = "ATTR_OBJECT_AGREEMENT,ATTR_OBJECT_DOCUMENT_AN,ATTR_OBJECT_LIST_AN,ATTR_OBJECT_T_TASK,ATTR_OBJECT_DOCUMENT,ATTR_OBJECT_DOC_DEV,ATTR_OBJECT_DRAWING,ATTR_OBJECT_CONTRACT,ATTR_OBJECT_CONTRACT_COMPL_REPORT,ATTR_OBJECT_PURCHASE_OUTSIDE,ATTR_OBJECT_INVOICE,ATTR_OBJECT_TENDER_INSIDE,ATTR_OBJECT_PURCHASE_DOC"
End Function

Sub AddSysAttr()
  List = AttrList()
  Call AddSystemAttribute(List)
End Sub


Sub SetSystemAttrs(aList)
  Progress.Text = "Настройка системных атрибутов"
  lst = "" & aList
  arr = Split(lst,",")
  
  For each attrname In arr
    Progress.Text = "Настройка системных атрибутов: " & attrname
    If ThisApplication.AttributeDefs.Has(attrname) = True Then
      If ThisApplication.Attributes.Has(attrname) = False Then
        ThisApplication.Attributes.Create Thisapplication.AttributeDefs(attrname)
      End If
      Select Case attrname
        Case "ATTR_OBJECT_AGREEMENT","ATTR_OBJECT_DOCUMENT_AN","ATTR_OBJECT_LIST_AN","ATTR_OBJECT_T_TASK","ATTR_OBJECT_DOCUMENT","ATTR_OBJECT_DOC_DEV","ATTR_OBJECT_DRAWING","ATTR_OBJECT_CONTRACT","ATTR_OBJECT_CONTRACT_COMPL_REPORT","ATTR_OBJECT_PURCHASE_OUTSIDE","ATTR_OBJECT_INVOICE","ATTR_OBJECT_TENDER_INSIDE","ATTR_OBJECT_PURCHASE_DOC"
          Call Set_SysID_ATTRS(attrname)
      End Select
    End If
  Next
End Sub

Sub Set_SysID_ATTRS(attrname)
  Set oColl = ThisApplication.ObjectDefs("OBJECT_SYSTEM_ID").Objects
  oDefName = Replace(attrname,"ATTR_","",1,1)
  For each Obj In oColl
    num = Obj.attributes("ATTR_KD_IDNUMBER")
    If Obj.attributes("ATTR_KD_OBJECT_TYPE") = oDefName Then
      If ThisApplication.AttributeDefs.Has(attrname) Then
        If ThisApplication.Attributes.Has(attrname) = False Then
          ThisApplication.Attributes.Create ThisApplication.AttributeDefs(attrname)
        End If
        ThisApplication.Attributes(attrname) = num
      End If
    End If
  Next
End Sub

Sub Misc()
  For each Obj In ThisApplication.ObjectDefs("OBJECT_FOLDER").Objects
    If Obj.Attributes("ATTR_FOLDER_NAME") = "Авторский надзор" And _
        Obj.Attributes("ATTR_FOLDER_TYPE").classifier.Sysname <> "NODE_FOLDER_AUTH-SUPERVISION" Then
      Obj.Attributes("ATTR_FOLDER_TYPE").classifier = ThisApplication.Classifiers("NODE_FOLDER_TYPES").Classifiers.FindBySysId("NODE_FOLDER_AUTH-SUPERVISION")
    End If
  Next
End Sub
