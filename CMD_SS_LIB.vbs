' Option Explicit

' this function is not intended for direct use,
' call it with ThisApplication.ExecuteScript
' ExecuteScript method provides Empty values for unset parameters
' caption  - string, dialog caption
' from     - variant, source to pick users, a group/department sysId or users collection
' single   - boolean, users collection is returned if this parameter is set to False 
'            otherwise first of selected
' retval   - object, selected user or users collection
Private Function PickUser(caption, from, singleUser)
  Set PickUser = Nothing
  
  ' by default first picked user is returned
  If IsEmpty(singleUser) Then singleUser = True
  
  ' create dialog
  Dim dlg
  Set dlg = ThisApplication.Dialogs.SelectUserDlg
  dlg.Caption = caption
  
  ' setup dialog
  If Not IsEmpty(from) Then
    If vbObject = VarType(from) Then
      If singleUser And (1 = from.Count) Then
        Set PickUser = from(0)
        Exit Function
      End If
      dlg.SelectFromUsers = from
    ElseIf vbString = VarType(from) Then
      If ThisApplication.Groups.Has(from) Then
        dlg.SelectFromUsers = ThisApplication.Groups(from).Users
      Else
        Dim dep
        Set dep = ThisApplication.Departments.AllSubNodes.FindBySysId(from)
        If Not dep Is Nothing Then dlg.SelectFromUsers = dep.AssignedUsers
      End If
    End If
  End If
  
  ' pick users
  If Not dlg.Show() Then Exit Function
  If 0 = dlg.Users.Count Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1171
    Exit Function
  End If
  
  ' setup result
  If singleUser Then
    Set PickUser = dlg.Users(0)
  Else
    Set PickUser = dlg.Users
  End If
End Function

' resolve classifier by name, code or SysId
' root  - object, root classifier
' leaf  - string, item to find
Public Function ResolveClassifier(root, leaf)
  Set ResolveClassifier = Nothing
  
  Dim leafs
  Set leafs = root.AllSubNodes
  Set ResolveClassifier = leafs.FindBySysId(leaf)
  If Not ResolveClassifier Is Nothing Then Exit Function
  Set ResolveClassifier = DepthScan(root, leaf)
End Function

' helper to scan classifiers tree
Private Function DepthScan(root, what)
  Set DepthScan = Nothing
  
  Set DepthScan = root.Classifiers.Find(what)
  If Not DepthScan Is Nothing Then Exit Function
  
  Dim c, probe
  For Each c In root.Classifiers
    If c.Classifiers.Count > 0 Then
      Set probe = DepthScan(c, what)
      If Not probe Is Nothing Then
        Set DepthScan = probe
        Exit Function
      End If
    End If
  Next
End Function

' inserts new row to the history of assignments on specific object
' obj      - object, target object
' role     - string, target role
' action   - string or object, reference to NODE_KD_HIST_ACTION classifier
' assignee - string or user, new assignee
Public Sub UpdateAssignmentsHistory(obj, role, action, assignee)
  
  If Not obj.Attributes.Has("ATTR_ASSIGNMENTS_HISTORY") Then
    Err.Raise vbObjectError, "CMD_ADD_STRUCTURE_EDIT_ROLE", _
      "Объект {" & obj.Description & "} должен иметь атрибут {ATTR_ASSIGNMENTS_HISTORY}"
  End If
  
  If (vbObject <> VarType(role)) And (vbString <> VarType(role)) Then
    Err.Raise vbObjectError, "CMD_ADD_STRUCTURE_EDIT_ROLE", _
      "Недопустимый тип аргумента, {" & TypeName(role) & "}"
  End If
  
  ' parse action
  Dim actionClass
  Set actionClass = ResolveClassifier(_
    ThisApplication.Classifiers("NODE_KD_HIST_ACTION"), action)
  
  Dim table, att
  Set table = obj.Attributes("ATTR_ASSIGNMENTS_HISTORY").Rows
  Set att = table.Create().Attributes
  
  att("ATTR_KD_HIST_DATE").Value        = ThisApplication.CurrentTime
  att("ATTR_KD_HIST_ACTION").Classifier = actionClass
  att("ATTR_HIST_PRINCIPIAL").User      = ThisApplication.CurrentUser
  att("ATTR_HIST_ASSIGNEE").User        = assignee
  If vbObject = VarType(role) Then
    att("ATTR_KD_HIST_NOTE").Value = role.Description
  Else
    If ThisApplication.RoleDefs.Has(role) Then
      att("ATTR_KD_HIST_NOTE").Value = ThisApplication.RoleDefs(role).Description
    Else
      att("ATTR_KD_HIST_NOTE").Value = role
    End If
  End If
End Sub

' find users assigned to specific role
' obj     - object, probe
' roleDef - variant, identifier or roledef object
Public Function CollectAssignees(obj, roleDef)
  Set CollectAssignees = ThisApplication.CreateCollection(tdmUsers)
  
  Dim r 
  For Each r In obj.RolesByDef(roleDef)
    If Not r.User Is Nothing Then
      CollectAssignees.Add r.User
    End If
  Next
End Function

' checks if ATTR_CONTRACT_STAGE edit enabled
' obj - object to check
Public Function EnableContractStageEdit(Obj)
  EnableContractStageEdit = True
  
  ' perhaps we need to scan uplinks collection ??
  If obj.Parent Is Nothing Then Exit Function
  
  Dim att
  Set att = obj.Parent.Attributes
  If Not att.Has("ATTR_CONTRACT_STAGE") Then Exit Function
  EnableContractStageEdit = att("ATTR_CONTRACT_STAGE").Empty
End Function

' propagates attribute value to content
' should be wrapped into transaction externally
' objects - object, objects collection
' def - string, attribute definition
' value - variant, new value
Public Sub PropagateValue(objects, def, value)
  
  Dim o, att
  For Each o In objects
    o.Permissions = SysAdminPermissions
    Set att = o.Attributes
    If att.Has(def) Then SetAttribute att(def), value
  Next
End Sub

Public Sub PropagateAttribute(objects, attribute)
  
  If tdmTable = attribute.Type Then _
    Err.Raise vbObjectError, "CMD_SS_LIB.PropagateAttribute", "Unsupported tdmTable attribute type"
  
  If tdmClassifier = attribute.Type Or tdmList = attribute.Type Then
    PropagateValue objects, attribute.AttributeDefName, attribute.Classifier
  ElseIf tdmObjectLink = attribute.Type Then
    PropagateValue objects, attribute.AttributeDefName, attribute.Object
  ElseIf tdmUserLink = attribute.Type Then
    PropagateValue objects, attribute.AttributeDefName, attribute.User
  ElseIf tdmFileLink = attribute.Type Then
    PropagateValue objects, attribute.AttributeDefName, attribute.File
  Else
    PropagateValue objects, attribute.AttributeDefName, attribute.Value
  End If
End Sub

Private Sub SetAttribute(att, value)
  
  If IsEmpty(value) Then att.Empty = True: Exit Sub
  If vbObject = VarType(value) Then
    If value Is Nothing Then att.Empty = True: Exit Sub
  End If
  
  If tdmTable = att.Type Then _
    Err.Raise vbObjectError, "CMD_SS_LIB.SetAttribute", "Unsupported tdmTable attribute type"
    
  If tdmClassifier = att.Type Then
    att.Classifier = value
  ElseIf tdmObjectLink = att.Type Then
    att.Object = value
  ElseIf tdmUserLink = att.Type Then
    att.User = value
  ElseIf tdmFileLink = att.Type Then
    att.File = Value
  Else
    att.Value = value
  End If
End Sub

' clear attribute values
' obj - object, object or content for processing
' list - string, attribute defs list
Public Sub ClearAttributes(obj, list)
  
  If "ITDMSObject" = TypeName(obj) _
    Or "ITDMSTableAttributeRow" = TypeName(obj) Then
    ClearAttributesSingle obj, list: Exit Sub
  End If
  
  If "ITDMSObjects" = TypeName(obj) Then
    Dim o
    For Each o In obj
      ClearAttributesSingle o, list
    Next
    Exit Sub
  End If
  
  Err.Raise vbObjectError, "CDM_SS_LIB.ClearAttributes", _
    "Unexpected object type - " & TypeName(obj)
End Sub

Private Sub ClearAttributesSingle(obj, list)
  Dim a, i, att
  a = Split(list, ";")
  For i = LBound(a) To UBound(a)
    Set att = obj.Attributes
    If att.Has(a(i)) Then att(a(i)).Empty = True
  Next
End Sub

Public Function ReadyForInspection(obj)
  ReadyForInspection = Not GetInspector(obj) Is Nothing
End Function

Public Function GetInspector(obj)
  ThisApplication.DebugPrint "GetInspector "&time()
  Set GetInspector = Nothing

  Dim row
  Set row = GetInspectorRow(obj)
  If row Is Nothing Then Exit Function
  Set GetInspector = row.Attributes("ATTR_USER").User
End Function

Private Function GetInspectorRow(obj)
  Set GetInspectorRow = Nothing
  
  Dim att, row
  Set att = obj.Attributes
  If Not att.Has("ATTR_CHECK_LIST") Then Exit Function
  For Each row In att("ATTR_CHECK_LIST").Rows
    Dim rowAtt, c
    Set rowAtt = row.Attributes
    If Not rowAtt("ATTR_USER").User Is Nothing Then
      If Not rowAtt("ATTR_CHECK_TYPE").Classifier Is Nothing Then
        Set c = rowAtt("ATTR_CHECK_TYPE").Classifier
        If "nk" = c.Code Then
          Set GetInspectorRow = row: Exit Function
        End If
      End If
    End If
  Next  
End Function

Public Function GetInspectionObject(target)
  Set GetInspectionObject = Nothing
  ' заменено для увеличения быстродействия 11.10.2017
'  Dim refs
'  Set refs = target.ReferencedBy.ObjectsByDef("OBJECT_NK")
'  If 0 = refs.Count Then Exit Function
'  Set GetInspectionObject = refs(0)
  
  Set nk = ThisApplication.Dictionary("NK")
  guid = target.guid
  if nk.Exists(guid) Then 
    Set GetInspectionObject = nk.Item(guid) 
  End If
End Function


Sub SaveLinkNK(Obj_)
  ThisApplication.DebugPrint "SaveLinkNK "&time()
  dim q
  
  guid = Obj_.GUID
'  Set nk = ThisApplication.Dictionary("NK")
'  if nk.Exists(guid) Then Exit Sub
  
  set q = ThisApplication.Queries("QUERY_LINK_NK")
  q.Parameter("PARAM0") = Obj_
  set o = Nothing
  on error resume next
  Set o = q.Objects(0)
  on error goto 0
  
  If o is nothing Then Exit Sub
  
  Set nk = ThisApplication.Dictionary("NK")
  if nk.Exists(guid) Then 
    Set nk.Item(guid) = o
  Else
    nk.Add guid, o  
  End If  
End Sub

Public Function HasInspectionObject(target)
  HasInspectionObject = target.ReferencedBy.ObjectsByDef("OBJECT_NK").Count > 0
End Function

Public Function CreateInspectionObject(target)
  Set CreateInspectionObject = Nothing
  Set objType = ThisApplication.ObjectDefs("OBJECT_NK")
  Set ObjRoots = ThisApplication.ExecuteScript("CMD_KD_FOLDER", "GET_FOLDER", "",objType)
  If  ObjRoots Is Nothing Then  
    MsgBox "Не удалось создать папку", vbCritical, "Объект не был создан"
    Exit Function
  End If
  ObjRoots.Permissions = SysAdminPermissions
  Set CreateInspectionObject = ObjRoots.Objects.Create(objType)
  CreateInspectionObject.Description = target.Description & " - нормоконтроль"
  CreateInspectionObject.Attributes("ATTR_OBJECT").Object = target
  ThisApplication.ExecuteScript "CMD_KD_SET_PERMISSIONS", "Set_Permission", CreateInspectionObject
End Function

Public Sub UpdateInspector(obj, user)
  obj.Permissions = SysAdminPermissions
  
  Dim row
  Set row = GetInspectorRow(obj)
  If row Is Nothing Then
    Set row = obj.Attributes("ATTR_CHECK_LIST").Rows.Create()
    row.Attributes("ATTR_CHECK_TYPE").Classifier = _
      ThisApplication.Classifiers("NODE_CHECK_TYPE").Classifiers.Find("nk")
  End If
  
  row.Attributes("ATTR_USER").User = user
End Sub

Public Function FindCheckListRow(obj, user)
  Set FindCheckListRow = Nothing
  
  Dim att, row, ratt, u
  Set att = obj.Attributes
  If Not att.Has("ATTR_CHECK_LIST") Then Exit Function
  
  For Each row In att("ATTR_CHECK_LIST").Rows
    Set ratt = row.Attributes
    If ratt.Has("ATTR_USER") Then
      Set u = ratt("ATTR_USER").User
      If Not u Is Nothing Then
        If u.SysName = user.SysName Then
          Set FindCheckListRow = row: Exit Function
        End If
      End If    
    End If
  Next
End Function

' synchronize role to attribute user/group
' obj     - object, object to update
' attDef  - string, attribute definition
' role    - string, role to sync
Public Sub SyncRoleToAtt(obj, attDef, role)

  Dim att, u
  Set att = obj.Attributes
  If Not att.Has(attDef) Then Exit Sub
  Set u = att(attDef).User
  If u Is Nothing Then Set u = att(attDef).Group
  
  SyncRoleToUser obj, role, u
End Sub

' 
' obj     - object
' row     - object, table row to get user
' attDef  - string, 
' role    - string
Public Sub SyncRoleToTableAtt(obj, row, attDef, role)

  Dim att, u
  
  Set att = row.Attributes
  If Not att.Has(attDef) Then Exit Sub
  Set u = att(attDef).User
  If u Is Nothing Then Set u = att(attDef).Group
  
  SyncRoleToUser obj, role, u
End Sub

' synchronize role to specified user/group
' if user isNullOrEmpty then role will be removed
' obj - object, object to update
' role - string, role to update
' user - string/object, user, group, or nothing
Public Sub SyncRoleToUser(obj, role, user)
  ThisScript.SysAdminModeOn
  If IsEmpty(user) Then Set user = Nothing
  
  If vbString = VarType(user) Then
    If ThisApplication.Users.Has(user) Then
      Set user = ThisApplication.Users(user)
    ElseIf ThisApplication.Groups.Has(user) Then
      Set user = ThisApplication.Groups(user)
    Else
      Set user = Nothing
    End If
  End If
  
  Dim currentRoles, r
  Set currentRoles = obj.RolesByDef(role)
  
  obj.Permissions = SysAdminPermissions
  If currentRoles.Count > 0 Then
    For Each r In currentRoles
      If Not user Is Nothing Then
        If ThisApplication.Users.Has(user) Then
          r.User = user
        Else
          r.Group = user
        End If
      Else
        r.Erase
      End If
    Next  
  Else
    If Not user Is Nothing Then
      obj.Roles.Create(role, user).Inheritable = False
    End If
  End If
End Sub

Public Function NormalizePath(source)
  NormalizePath = source
  NormalizePath = Replace(NormalizePath, "\", "_")
  NormalizePath = Replace(NormalizePath, "/", "_")
  NormalizePath = Replace(NormalizePath, ":", "_")
  NormalizePath = Replace(NormalizePath, "*", "_")
  NormalizePath = Replace(NormalizePath, "?", "_")
  NormalizePath = Replace(NormalizePath, """", "_")
  NormalizePath = Replace(NormalizePath, "<", "_")
  NormalizePath = Replace(NormalizePath, ">", "_")
  NormalizePath = Replace(NormalizePath, "|", "_")
End Function

' tests file availability
Public Function FileIsOpened(path)
  FileIsOpened = False
  
  Dim fso
  Set fso = CreateObject("Scripting.FileSystemObject")
  If Not fso.FileExists(path) Then Exit Function
  
  Dim saved
  saved = path
  path = path & ".1"
  
  On Error Resume Next
  fso.MoveFile saved, path
  FileIsOpened = 0 <> Err.Number
  On Error GoTo 0
  
  If Not FileIsOpened Then fso.MoveFile path, saved
End Function
