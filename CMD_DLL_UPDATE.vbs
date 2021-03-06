
Sub RemoveSysFromObjDef(str)
  ar = Split(str,":")
  
  If Ubound(ar) < 1 Then Exit Sub
  
  ObjDefName = ar(0)
  List= ar(1)
  arr = Split(List,",")
  For Each ObjSysName In arr
    call SystemObjRemoveFromObject(str0,ObjDefName,ObjSysName)
  Next
End Sub


' Удаление связи типа объекта с атрибутом, командой, формой и т.д.
Sub SystemObjRemoveFromObject(str0,ObjDefName,ObjSysName)
  Progress.Text = "Обновляются связи объекта: " & ObjDefName
  on Error Resume Next
  ' атрибуты
  Set ObjDef = ThisApplication.ObjectDefs(ObjDefName)
  If ObjDef Is Nothing Then Exit Sub
  If ThisApplication.AttributeDefs.Has(ObjSysName) Then
    If ObjDef.AttributeDefs.Has(ObjSysName) Then
      Set Attr = ThisApplication.AttributeDefs(ObjSysName)
      Descr = Attr.Description
      ObjDef.AttributeDefs.Remove Attr
      ' атрибуты, которые нужно оставить, но без установок по умолчанию, после удаления добавляем опять
      If ObjSysName = "ATTR_CONTRACT_TYPE" or ObjSysName = "ATTR_TENDER_STATUS_EIS" Then 
        ObjDef.AttributeDefs.Add Attr
      Else
        If ObjDef.AttributeDefs.Has(ObjSysName) = False Then
          str0 = str0 & chr(10) & "Из типа объекта """ & ObjDef.Description & """ удален атрибут """ & Descr & """"
        End If
      End If
    End If
   ElseIf ThisApplication.InputForms.Has(ObjSysName) Then
      If ObjDef.InputForms.Has(ObjSysName) Then
        Set Form = ThisApplication.InputForms(ObjSysName)
        Descr = Form.Description
        ObjDef.InputForms.Remove Form
          If ObjDef.InputForms.Has(ObjSysName) = False Then
            str0 = str0 & chr(10) & "Из типа объекта """ & ObjDef.Description & """ удалена форма ввода """ & Descr & """"
          End If
      End If
    ElseIf ThisApplication.ObjectDefs.Has(ObjSysName) Then
      If ObjDef.ObjectDefs.Has(ObjSysName) Then
        Set Form = ThisApplication.ObjectDefs(ObjSysName)
        Descr = Form.Description
        ObjDef.ObjectDefs.Remove Form
          If ObjDef.ObjectDefs.Has(ObjSysName) = False Then
            str0 = str0 & chr(10) & "Из типа объекта """ & ObjDef.Description & """ удален тип объекта """ & Descr & """"
          End If
      End If
    ElseIf ThisApplication.Statuses.Has(ObjSysName) Then
      Set stat = ThisApplication.Statuses(ObjSysName)
      Descr = stat.Description
      If ObjDef.Statuses.Has(stat) Then
        ObjDef.Statuses.Remove stat
        str0 = str0 & chr(10) & "Из типа объекта """ & ObjDef.Description & """ удален статус """ & Descr & """"
      End If
    ElseIf ThisApplication.FileDefs.Has(ObjSysName) Then
      Set fDef = ThisApplication.FileDefs(ObjSysName)
      Descr = fDef.Description
      If ObjDef.FileDefs.Has(fDef) Then
        ObjDef.FileDefs.Remove fDef
        str0 = str0 & chr(10) & "Из типа объекта """ & ObjDef.Description & """ удален статус """ & Descr & """"
      End If
    ElseIf ThisApplication.Commands.Has(ObjSysName) Then
      Set comm = ThisApplication.Commands(ObjSysName)
      Descr = comm.Description
      If ObjDef.Commands.Has(comm) Then
          ObjDef.Commands.Remove comm
          str0 = str0 & chr(10) & "Из типа объекта """ & ObjDef.Description & """ удалена команда """ & Descr & """"
      End If
    End If
  On Error GoTo 0
End Sub

Sub AddSystemAttribute(aList)
  Progress.Text = "Добавляются системные атрибуты"
  arr = Split(aList,",")
    str0=""
  For each attrname In arr
    If ThisApplication.AttributeDefs.Has(AttrName) Then
      If ThisApplication.Attributes.Has(AttrName) = False Then
        Progress.Text = "Добавляются системные атрибуты: " & attrname
        Set Attr = ThisApplication.Attributes.Create(ThisApplication.AttributeDefs(AttrName))
        str0 = str0 & chr(13) & "Добавлен системный атрибут """ &_
          ThisApplication.AttributeDefs(AttrName).Description & """"
      Else
      str0 = str0 & chr(13) & "---Cистемный атрибут """ &_
          ThisApplication.AttributeDefs(AttrName).Description & """ уже есть в системе"
      End If
    Else
      str0 = str0 & chr(13) & "***ОШИБКА: Атрибут """ &_
          AttrName & """ отсутствует в системе"
    End If
  Next
End Sub

Sub SetSectionsDefault()
  For each Obj In ThisApplication.ObjectDefs("OBJECT_PROJECT_SECTION").Objects
    Call SetSectionDefault(Obj)
  Next
  For each Obj In ThisApplication.ObjectDefs("OBJECT_PROJECT_SECTION_SUBSECTION").Objects
    Call SetSectionDefault(Obj)
  Next
End Sub

Sub SetSectionDefault(Obj)

  Call ThisApplication.ExecuteScript("OBJECT_PROJECT_SECTION","SetStartAttrs",Obj,Obj.Parent)
  Call ThisApplication.ExecuteScript("CMD_PROJECT_SECTION_ADD","SetSectionAttrs",Obj)
  Call ThisApplication.ExecuteScript("OBJECT_PROJECT_SECTION","SetDescriptions",Obj)

End Sub

Sub RemoveStatusFromCommand(command,Stat)
  Set comm = ThisApplication.Commands(command)
  If Not comm Is Nothing Then
    If comm.Statuses.Has(Stat) Then
      comm.Statuses.Remove ThisApplication.Statuses(Stat)
    End If
  End If
End Sub

Sub ObjAttrSync(List)'oDefName)
  arr1 = Split(List, ",")
  For each oDefName in arr1
    If ThisApplication.ObjectDefs.Has(oDefName) = True Then 
      Set ObjDef = ThisApplication.ObjectDefs(oDefName)
      Progress.Text = "Синхронизация атрибутов объектов: " & ObjDef.Description
      CountDel = 0
      CountAddCountAdd = 0
      For Each Obj In ObjDef.Objects
        Call ThisApplication.ExecuteScript("CMD_CREATED_OBJECTS_ATTR_SYNC","AttrsDelAdd",Obj,ObjDef,CountDel,CountAdd)
      Next
    End If
  Next
End Sub

Sub AddQueryToObj(Obj,qSysName)
  If Obj.Queries.Has(qSysName) = False Then
    Obj.Queries.Add (qSysName)
  End If
End Sub

Function AddGroup(SysName)
  Set AddGroup = Nothing
  If ThisApplication.Groups.Has(SysName) = False Then
    Set AddGroup = ThisApplication.Groups.Create
  Else
    Set AddGroup = ThisApplication.Groups(SysName)
  End If
End Function

Sub RemoveRoleFromCommand(command,role)
  Set comm = ThisApplication.Commands(command)
  If comm.RoleDefs.Has(role) Then
    comm.RoleDefs.Remove ThisApplication.RoleDefs(role)
  End If
End Sub


' Удаление из системы различных элементов
Sub SystemObjDelByList(List)
  arr = Split(List,",")
  For each DefName in arr
    Progress.Text = "Удаление из системы: " & DefName
    Call ThisApplication.ExecuteScript("CMD_TASKS_EXECUTE","SystemObjDel","",DefName)
  Next
End Sub

Sub AddQuery(Obj,List,ListToRem)
      arr = Split(List,",")
      For Each q In arr
        If Not Obj.Queries.Has(q) Then
          Obj.Queries.Add q
        End If
      Next
      arr = Split(ListToRem,",")
      For Each q In arr
        If Obj.Queries.Has(q) Then
          Obj.Queries.Remove q
        End If
      Next
End Sub

Sub AddSubQuery(List)
  arr = Split(List,",")
  If ThisApplication.Queries.Has(arr(0)) = False Then Exit Sub
  Set q =  ThisApplication.Queries(arr(0))   
  For i = 1 to Ubound(arr)
    If ThisApplication.Queries.Has(arr(i)) = True Then
      If Not q.Queries.Has(arr(i)) Then
        q.Queries.Add arr(i)
      End If
    End If
  Next
End Sub