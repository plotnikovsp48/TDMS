
Call Main(ThisObject)

Function Main(Root)
  Set Main = Nothing
  If root Is Nothing Then Exit Function
  If Root.IsKindOf("OBJECT_PROJECT") <> True Then 
    msgbox "Невозможно создать стадию на этом уровне",vbCritical,"Создать стадию"
    Exit Function
  End If
  
  Set cls = ThisApplication.Classifiers.FindBySysId("NODE_PROJECT_STAGE")
  If  cls  Is Nothing Then
    msgbox "Не найден список стадий. Обратитесь к системному администратору!",vbCritical,"Создать стадию"
  End If
  
  Check = ThisApplication.ExecuteScript("OBJECT_STAGE","AllStageCheck",Root)
  If Check = False Then
      Msgbox "В проекте все стадии созданы!", vbExclamation,"Создать стадию"
      Exit Function
  End If
  
  Set Clf = ThisApplication.ExecuteScript("CMD_CREATE_OBJECT_STAGE","SelectStage",Root)
  If Clf Is Nothing Then Exit Function
  
  Set Main = CreateStageByCls(Root,Clf)
End Function

Function SelectStage(oProj)
  Set SelectStage = Nothing
  Set Query = ThisApplication.Queries("QUERY_STAGES_OF_PROJECT_SEL")
  Query.Parameter("PROJECT") = oProj
  Set Objects = Query.Objects
  Str = ""
  Set Clfs = ThisApplication.Classifiers("NODE_PROJECT_STAGE").Classifiers
  For Each Clf in Clfs
    If CheckStage(Objects,Clf) = True Then
      If Str <> "" Then
        Str = Str & ";" & Clf.Code & " - " & Clf.Description
      Else
        Str = Clf.Code & " - " & Clf.Description
      End If
    End If
  Next
  Arr = Split(Str,";")
  Set Dlg = ThisApplication.Dialogs.SelectDlg
  Dlg.SelectFrom = Arr
  If Dlg.Show Then
    If UBound(Dlg.Objects) = -1 Then
      Msgbox "Вы не выбрали ни одной стадии.", vbExclamation
      Exit Function
    ElseIf UBound(Dlg.Objects) > 0 Then
      Msgbox "Выберите только одну стадию!", vbExclamation
      Exit Function
    Else
      Arr = Dlg.Objects
      Str = Join(Arr,";")
      If Str <> "" Then
        Code = Left(Str, InStr(Str," - ")-1)
        Descr = Right(Str, Len(Str) - InStr(Str, " - ")-2)
        If Clfs.Has(Descr) Then
          Set SelectStage = Clfs.Find(Descr)
        End If
      End If
    End If
  End If
End Function

'Функция проверки наличия стадии в проекте
Function CheckStage(Objects,Clf)
  CheckStage = True
  For Each Obj in Objects
    If Obj.Attributes("ATTR_PROJECT_STAGE").Empty = False Then
      If Obj.Attributes("ATTR_PROJECT_STAGE").Classifier.SysName = Clf.SysName Then
        CheckStage = False
        Exit Function
      End If
    End If
  Next
End Function

Function CreateStageByCls(ObjRoot,cls)
  Set CreateStageByCls = Nothing
  If ObjRoot Is Nothing Then Exit Function
  If cls Is Nothing Then Exit Function
  
  ObjRoot.Permissions = SysAdminPermissions
  On error Resume Next
  Set NewObj = ObjRoot.Objects.Create("OBJECT_STAGE")
  If NewObj Is Nothing or err.Number <> 0 Then
    err.clear
    on error GoTo 0
    Exit Function
  End If
  
  NewObj.Attributes("ATTR_PROJECT_STAGE").Classifier = cls
  Call Set_PROJECT_STAGE_CODE (NewObj)
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = NewObj
  RetVal = Dlg.Show
     
      If NewObj.StatusName = "STATUS_STAGE_DRAFT" Then
        If Not RetVal Then
          NewObj.Erase
          Exit Function
        End If
      End If
    Set CreateStageByCls = NewObj
End Function



Sub Set_PROJECT_STAGE_CODE (o_)
  sProjectStage = o_.Attributes("ATTR_PROJECT_STAGE").Classifier.Code
  Set comments = o_.Attributes("ATTR_PROJECT_STAGE").Classifier.Comments
  For Each Comment In Comments
    Val = ThisApplication.ExecuteScript("CMD_DLL", "getStringByTag", Comment.text,"ATTR_PROJECT_STAGE_CODE")
    If Not Val = vbNulLString Then Exit For
  Next
  
  If Val = vbNulLString Then 
    o_.Attributes("ATTR_PROJECT_STAGE_CODE") = sProjectStage
  Else
    o_.Attributes("ATTR_PROJECT_STAGE_CODE") = Val
  End If

  Val = ThisApplication.ExecuteScript("CMD_S_NUMBERING","GetObjNumber",o_)
  If o_.Attributes("ATTR_PROJECT_STAGE_NUM").Value <> Val Then
    o_.Attributes("ATTR_PROJECT_STAGE_NUM") = Val
  End If
  
End Sub