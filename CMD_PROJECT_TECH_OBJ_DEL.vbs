' Команда - Удалить из БД все объекты технического документооборота
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE CMD_SS_PROGRESS

Call Main(ThisObject)

Sub Main(Root)
  ThisScript.SysAdminModeOn
  Key = Msgbox("Выполнение команды полностью удалит все объекты технического документооборота."&_
  chr(10)&"Перед выполнением команды рекомендуется сделать резервную копию БД."&_
  chr(10)&chr(10)&"Продолжить?",vbYesNo+vbQuestion)
  If Key = vbNo Then Exit Sub
  
  Set Dict = ThisApplication.Dictionary("DelObjOperation")
  Set Progress = New CProgress
  'Progress.SetRange 0, MaxCount
  progress.Text = "Анализ данных..."
  
  ThisApplication.Utility.WaitCursor = True
  
  Set Query = ThisApplication.Queries("QUERY_PROJECT_TECH_OBJ_DEL")
  Set Objects = Query.Objects
  MaxCount = Objects.Count
  If MaxCount < 2 Then
    Msgbox "Объекты для удаления не найдены.", vbInformation
    Exit Sub
  End If
  CountDelObj = 0
  CountDelQuery = 0
  CountDo = 0
  AttrName = "ATTR_FOLDER_NAME"
  
  on Error Resume Next
  
  'Анализ данных
  Progress.SetRange 0, MaxCount
  For Each Obj in Objects
    Set q0 = ThisApplication.CreateQuery
    q0.Permissions = sysadminpermissions
    q0.AddCondition tdmQueryConditionObjectDef, "OBJECT_P_TASK"
    q0.AddCondition tdmQueryConditionAttribute, Obj, "ATTR_OBJECT"
    Set q1 = ThisApplication.CreateQuery
    q1.Permissions = sysadminpermissions
    q1.AddCondition tdmQueryConditionObjectDef, "'OBJECT_KD_ORDER_SYS' or 'OBJECT_KD_ORDER_REP' or 'OBJECT_KD_ORDER_NOTICE'"
    q1.AddCondition tdmQueryConditionAttribute, Obj, "ATTR_KD_DOCBASE"
    Set q2 = ThisApplication.CreateQuery
    q2.Permissions = sysadminpermissions
    q2.AddCondition tdmQueryConditionObjectDef, "OBJECT_KD_AGREEMENT"
    q2.AddCondition tdmQueryConditionAttribute, Obj, "ATTR_KD_HIST_OBJECT"
    For Each Child in Obj.Content
      If Child.ObjectDefName = "OBJECT_KD_FILE" Then
        MaxCount = MaxCount + 1
      End If
    Next
    MaxCount = MaxCount + q0.Objects.Count + q1.Objects.Count + q2.Objects.Count
    Check = True
    If Obj.ObjectDefName = "OBJECT_FOLDER" Then
      If Obj.Attributes.Has(AttrName) Then
        If StrComp(Obj.Attributes(AttrName).Value,"Архив до 2017 года",vbTextCompare) = 0 Then Check = False
      End If
    End If
    If Check = False Then MaxCount = MaxCount - 1
    Progress.Step
  Next
  'Msgbox MaxCount & " объектов для удаления",vbInformation
  
  'Удаление найденных объектов
  Dict.Item("exe") = True
  progress.Text = "Удаление объектов..."
  Progress.SetRange 0, MaxCount
  Set Sheet = Query.Sheet
  Do While Objects.Count > 1 and CountDo < 10
    For i = 0 to Sheet.RowsCount-1
      Set Obj = Sheet.RowValue(i)
      'Поиск и удаление плановых задач, связанных с объектом
      Set q0 = ThisApplication.CreateQuery
      q0.Permissions = sysadminpermissions
      q0.AddCondition tdmQueryConditionObjectDef, "OBJECT_P_TASK"
      q0.AddCondition tdmQueryConditionAttribute, Obj, "ATTR_OBJECT"
      For Each Obj0 in q0.Objects
        CheckStep = ObjDelProc(Obj0,CountDelObj,CountDelQuery)
        If CheckStep = True Then Progress.Step
      Next
      
      'Поиск и удаление поручений, связанных с объектом
      Set q1 = ThisApplication.CreateQuery
      q1.Permissions = sysadminpermissions
      q1.AddCondition tdmQueryConditionObjectDef, "'OBJECT_KD_ORDER_SYS' or 'OBJECT_KD_ORDER_REP' or 'OBJECT_KD_ORDER_NOTICE'"
      q1.AddCondition tdmQueryConditionAttribute, Obj, "ATTR_KD_DOCBASE"
      For Each Obj0 in q1.Objects
        CheckStep = ObjDelProc(Obj0,CountDelObj,CountDelQuery)
        If CheckStep = True Then Progress.Step
      Next
      
      'Поиск и удаление Согласований, связанных с объектом
      Set q2 = ThisApplication.CreateQuery
      q2.Permissions = sysadminpermissions
      q2.AddCondition tdmQueryConditionObjectDef, "OBJECT_KD_AGREEMENT"
      q2.AddCondition tdmQueryConditionAttribute, Obj, "ATTR_KD_HIST_OBJECT"
      For Each Obj0 in q2.Objects
        CheckStep = ObjDelProc(Obj0,CountDelObj,CountDelQuery)
        If CheckStep = True Then Progress.Step
      Next
      
      'Поиск и удаление Файлов в составе объекта
      For Each Child in Obj.Content
        If Child.ObjectDefName = "OBJECT_KD_FILE" Then
          CheckStep = ObjDelProc(Child,CountDelObj,CountDelQuery)
          If CheckStep = True Then Progress.Step
        End If
      Next
      
      'Удаление объекта
      CheckStep = False
      Check = True
      If Obj.ObjectDefName = "OBJECT_FOLDER" Then
        If Obj.Attributes.Has(AttrName) Then
          If StrComp(Obj.Attributes(AttrName).Value,"Архив до 2017 года",vbTextCompare) = 0 Then Check = False
        End If
      End If
      If Check = True Then CheckStep = ObjDelProc(Obj,CountDelObj,CountDelQuery)
      If CheckStep = True Then Progress.Step
      
    Next
    Set Sheet = Query.Sheet
    CountDo = CountDo + 1
  Loop
  
  Dict.Item("exe") = False
  ThisApplication.Utility.WaitCursor = False
  Msgbox "Удалено " & CountDelObj & " объектов" & chr(10) &_
    "Удалено " & CountDelQuery & " выборок", vbInformation
End Sub

'Процедура удаления объекта
Function ObjDelProc(ObjDel,CountDelObj,CountDelQuery)
  ObjDelProc = False
  'Удаление выборок из состава объекта
  For Each Query in ObjDel.Queries
    If ThisApplication.Queries.Has(Query.SysName) = False Then
      ObjDel.Queries.Remove Query
      CountDelQuery = CountDelQuery + 1
    End If
  Next
  
  'Удаление объекта
  If ObjDel.Content.Count = 0 Then
    If ObjDel.ReferencedBy.Count = 0 Then
      Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", ObjDel)
      Err.Clear
      ObjDel.Erase
      If Err.Number = 0 Then
        CountDelObj = CountDelObj + 1
        ObjDelProc = True
      End If
    Else
      For Each o In ObjDel.ReferencedBy
        For Each Attr in o.Attributes
          If Attr.Type = 7 Then
            If not Attr.Object is Nothing Then
              If Attr.Object.Guid = ObjDel.Guid Then
                Attr.Object = Nothing
              End If
            End If
          ElseIf Attr.Type = 11 Then
            For Each Row in Attr.Rows
              For Each Attr0 in Row.Attributes
                If Attr0.Type = 7 Then
                  If not Attr0.Object is Nothing Then
                    If Attr0.Object.Guid = ObjDel.Guid Then
                      Attr.Rows.Remove Row
                      Exit For
                    End If
                  End If
                End If
              Next
            Next
          End If
        Next
      Next
    End If
  Else
    For Each Child in ObjDel.Content
      If Child.ObjectDefName = "OBJECT_KD_PROTOCOL" or Child.ObjectDefName = "OBJECT_KD_DIRECTION" Then
        ObjDel.Objects.Remove Child
      End If
    Next
  End If
End Function
