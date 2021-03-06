Option Explicit

USE CMD_SS_SYSADMINMODE

Private Function GetTempPath(extension)
  GetTempPath = vbNullString
  
  Dim fso: Set fso = CreateObject("Scripting.FileSystemObject")
  
  Const TemporaryFolder = 2

  Dim name: name = fso.GetTempName()
  name = Replace(name, fso.GetExtensionName(name), extension)
  GetTempPath = fso.BuildPath(fso.GetSpecialFolder(TemporaryFolder), name)
End Function

Public Sub TDMS2MSProject(obj)
  Dim func: func = "TDMS2MSProject"
  
  Dim file, xml, pjProject, pjTasks
  Set file = PrepareSyncTarget(obj)
  If file Is Nothing Then Exit Sub
  file.CheckOut file.WorkFileName
  
  Dim msproject
  Set msproject = CreateObject("MSProject.Application")
  msproject.Visible = True
  If Not msproject.FileOpenOrCreate(file.WorkFileName) Then Exit Sub
  
  Dim tmp: tmp = GetTempPath("xml")
  msproject.ActiveProject.SaveAs tmp, , , , , , , , , "MSProject.xml"
  
  Set xml = CreateObject("Msxml2.DomDocument.6.0")
  xml.async = False
  xml.resolveExternals = False
  xml.setProperty "SelectionLanguage", "XPath"
  xml.load tmp
  If (0 <> xml.parseError.errorCode) Then
    CreateObject("Scripting.FileSystemObject").DeleteFile tmp
    Err.Raise vbObjectError, ComposeLocation(func), _
      BuildXmlParseErrorMessage(xml.parseError)
  End If
  xml.setProperty "SelectionNamespaces", "xmlns:pj='http://schemas.microsoft.com/project'"
  Set pjProject = xml.selectSingleNode("pj:Project")
  Set pjTasks = pjProject.selectSingleNode("pj:Tasks")
  
  EnsureProjectHasSyncFields pjProject
  
  ResetUIDGenerators
  
  Dim data, i
  data = CollectData(obj, Empty)
  
  Dim correlation: correlation = Correlate(pjTasks, data)
  
  Dim create: create = correlation(0)
  For i = LBound(create) To UBound(create)
    CreateProjectTask pjTasks, create(i)
  Next
  
  Dim update: update = correlation(1)
  For i = LBound(update) To UBound(update)
    UpdateProjectTask pjTasks, update(i)
  Next
  
  Dim delete: delete = correlation(2)
  For i = LBound(delete) To UBound(delete)
    pjTasks.removeChild delete(i)
  Next
  
  SaveDomWithIndent xml, tmp

  Const pjMerge = 1
  
  msproject.FileOpenEx tmp, False, pjMerge
  CreateObject("Scripting.FileSystemObject").DeleteFile tmp
End Sub

Public Sub MSProject2TDMS(obj)
  Dim func: func = "MSProject2TDMS"
  
  Dim file, xml, pjProject
  Set file = PrepareSyncTarget(obj)
  If file Is Nothing Then Exit Sub
  file.CheckOut file.WorkFileName
  
  Dim msproject
  Set msproject = CreateObject("MSProject.Application")
  msproject.Visible = True
  If Not msproject.FileOpenOrCreate(file.WorkFileName) Then Exit Sub
  
  Dim tmp: tmp = GetTempPath("xml")
  msproject.ActiveProject.SaveAs tmp, , , , , , , , , "MSProject.xml"
  
  msproject.Quit 0
  Set msproject = Nothing
  
  Set xml = CreateObject("Msxml2.DomDocument.6.0")
  xml.async = False
  xml.resolveExternals = False
  xml.setProperty "SelectionLanguage", "XPath"
  xml.load tmp
  If (0 <> xml.parseError.errorCode) Then
    CreateObject("Scripting.FileSystemObject").DeleteFile tmp
    Err.Raise vbObjectError, ComposeLocation(func), _
      BuildXmlParseErrorMessage(xml.parseError)
  End If
  xml.setProperty "SelectionNamespaces", "xmlns:pj='http://schemas.microsoft.com/project'"
  Set pjProject = xml.selectSingleNode("pj:Project")
  
  Dim tasks: tasks = GetProjectData(pjProject.selectSingleNode("pj:Tasks"))
  Dim rcorrelate: rcorrelate = ReverseCorrelate(tasks)
  
  Dim sam: Set sam = New SysAdminMode
  
  Dim i, item, update: update = rcorrelate(1)
  For i = LBound(update) To UBound(update)
    Set item = update(i)
    If item.Exists("object") Then SyncNodeToObject item("node"), item("object")
    If item.Exists("reftask") Then SyncNodeToObject item("node"), item("reftask")
  Next
  
  CreateObject("Scripting.FileSystemObject").DeleteFile tmp
End Sub

Private Sub SyncNodeToObject(node, object)
  
  Dim att: Set att = object.Attributes
  If att.Has("ATTR_STARTDATE_FACT") Then att("ATTR_STARTDATE_FACT").Value = ParseDateTime(GetAttribute(node, "Start"))
  If att.Has("ATTR_ENDDATE_FACT") Then att("ATTR_ENDDATE_FACT").Value = ParseDateTime(GetAttribute(node, "Finish"))
End Sub

Private Function ReverseCorrelate(items)
  Dim i, create, update, delete
  create = Array(): update = Array(): delete = Array()
  
  For i = LBound(items) To UBound(items)
    Dim obj: Set obj = ThisApplication.GetObjectByGUID(items(i)("uid"))
    If Not obj Is Nothing Then 
      items(i).Add "object", obj
      Dim lastModifyTime
      Dim refs, reftask: Set reftask = Nothing
      Set refs = obj.ReferencedBy.ObjectsByDef("OBJECT_P_TASK")
      If refs.Count > 0 Then Set reftask = refs.Item(0)
      If Not reftask Is Nothing Then
        items(i).Add "reftask", reftask
        lastModifyTime = Max(obj.ModifyTime, reftask.ModifyTime)
      Else
        lastModifyTime = obj.ModifyTime
      End If
      If items(i)("lastSyncTime") > lastModifyTime Then
        ReDim Preserve update(UBound(update) + 1)
        Set update(Ubound(update)) = items(i)
      End If
    End If
  Next
  
  ReverseCorrelate = Array(create, update, delete)
End Function

Private Function GetAttribute(node, id)
  GetAttribute = vbNullString
  
  Dim attNode: Set attNode = node.selectSingleNode("pj:" & id)
  If attNode Is Nothing Then Exit Function
  GetAttribute = attNode.text
End Function

Private Function GetExtendedAttribute(node, id)
  GetExtendedAttribute = vbNullString
  
  Dim attNode, valueNode
  Set attNode = node.selectSingleNode("pj:ExtendedAttribute[pj:FieldID = " & id & "]")
  If attNode Is Nothing Then Exit Function
  Set valueNode = attNode.selectSingleNode("pj:Value")
  If valueNode Is Nothing Then Exit Function
  GetExtendedAttribute = valueNode.text
End Function

Private Function GetProjectData(root)
  GetProjectData = Array()
  
  Const pjCustomTaskText30 = 188744016
  Const pjCustomTaskDate10 = 188743954
  
  Dim nodes, item, ret: ret = Array()
  Set nodes = root.selectNodes("pj:Task[" & _
        "(pj:ExtendedAttribute/pj:FieldID = " & pjCustomTaskText30 & ") " & _
        "and (pj:ExtendedAttribute/pj:FieldID = " & pjCustomTaskDate10 & ")]")
  For Each item In nodes
    Dim info: Set info = CreateObject("Scripting.Dictionary")
    info.Add "node", item
    info.Add "uid", GetExtendedAttribute(item, pjCustomTaskText30)
    info.Add "lastSyncTime", ParseDateTime(GetExtendedAttribute(item, pjCustomTaskDate10))
    ReDim Preserve ret(UBound(ret) + 1)
    Set ret(UBound(ret)) = info
  Next
  GetProjectData = ret
End Function

Private Sub EnsureProjectHasSyncFields(project)
  
  Const NODE_ELEMENT = 1
  
  Dim xmlDoc
  Set xmlDoc = project.ownerDocument
  
  Dim extAttributes
  Set extAttributes = project.selectSingleNode("pj:ExtendedAttributes")
  If extAttributes Is Nothing Then
    Set extAttributes = xmlDoc.createNode(NODE_ELEMENT, "ExtendedAttributes", xmlDoc.NamespaceURI)
    project.appendChild extAttributes
  End If
  
  Const pjCustomTaskDate10 = 188743954
  
  Dim eatt, dict
  Set eatt = extAttributes.selectSingleNode("pj:ExtendedAttribute[pj:FieldID = " & pjCustomTaskDate10 & "]")
  If eatt Is Nothing Then
    Set dict = CreateObject("Scripting.Dictionary")
    dict("FieldID") = pjCustomTaskDate10
    dict("FieldName") = "Date10"
    dict("Alias") = "TDMS Last Sync"
    dict("Guid") = "000039B7-8BBE-4CEB-82C4-FA8C0B400112"
    AppendExtendedAttributeDef extAttributes, dict
  End If
  
  Const pjCustomTaskText30 = 188744016
  
  Set eatt = extAttributes.selectSingleNode("pj:ExtendedAttribute[pj:FieldID = " & pjCustomTaskText30 & "]")
  If eatt Is Nothing Then
    Set dict = CreateObject("Scripting.Dictionary")
    dict("FieldID") = pjCustomTaskText30
    dict("FieldName") = "Text30"
    dict("Alias") = "TDMS UID"
    dict("Guid") = "9B8A9692-CEAC-E711-A98B-B459E374061C"
    AppendExtendedAttributeDef extAttributes, dict
  End If
  
End Sub

Private Function AppendExtendedAttributeDef(parent, def)
  
  Const NODE_ELEMENT = 1
  
  Dim node, keys, i
  Set node = parent.ownerDocument.createNode(NODE_ELEMENT, "ExtendedAttribute", parent.namespaceURI)
  parent.appendChild node
  
  keys = def.Keys
  For i = LBound(keys) To UBound(keys)
    SetPropertyNode node, keys(i), def(keys(i))
  Next
End Function

Private Sub SaveDomWithIndent(xmlDom, filename)

  Dim reader: Set reader = CreateObject("MSXML2.SAXXMLReader")
  Dim writer: Set writer = CreateObject("MSXML2.MXXMLWriter")
  Dim stream: Set stream = CreateObject("ADODB.STREAM")
  stream.Open
  stream.Charset = "UTF-8"

  writer.indent = True
  writer.encoding = "UTF-8"
  writer.output = stream
  Set reader.contentHandler = writer
  Set reader.errorHandler = writer

  reader.parse xmlDom
  writer.flush

  Const adSaveCreateOverwrite = 2
  stream.SaveToFile filename, adSaveCreateOverwrite
End Sub

Private Sub CreateProjectTask(tasks, unit)
  
  Const NODE_ELEMENT = 1
  
  Dim xmlDoc, newNode
  Set xmlDoc = tasks.ownerDocument
  
  ' internal msproject uid
  unit("uid") = GetMaxUID(tasks, "Task") + 1
  
  Set newNode = xmlDoc.createNode(NODE_ELEMENT, "Task", tasks.namespaceURI)
  tasks.appendChild newNode
  
  SyncUnitToTask newNode, unit
  
  Const pjCustomTaskText30 = 188744016
  SetExtendedAttribute newNode, pjCustomTaskText30, unit("object").GUID
  
  Const pjCustomTaskDate10 = 188743954
  SetExtendedAttribute newNode, pjCustomTaskDate10, unit("lastSyncTime")
  
End Sub

Private Function NewResource(root, group, principal, type_)
  NewResource = -1
  
  Const NODE_ELEMENT = 1
  
  Dim xmlDoc, newNode
  Set xmlDoc = root.ownerDocument
  
  Dim uid: uid = GetMaxUID(root, "Resource") + 1
  Set newNode = xmlDoc.createNode(NODE_ELEMENT, "Resource", root.namespaceURI)
  root.appendChild newNode
  
  SetPropertyNode newNode, "UID", uid
  SetPropertyNode newNode, "Type", type_
  SetPropertyNode newNode, "Name", principal
  SetPropertyNode newNode, "Group", group
  NewResource = uid
End Function

Private Function LookupResource(root, group, principal, type_)
  LookupResource = -1
  
  Dim resource
  Set resource = root.selectSingleNode("pj:Resource[" & _
    "pj:Name = '" & principal & "' " & _
    "and pj:Group = '" & group & "']")
  If resource Is Nothing Then
    LookupResource = NewResource(root, group, principal, type_): Exit Function  
  End If
  LookupResource = CLng(resource.selectSingleNode("pj:UID").text)
End Function

Private Function NewAssignment(root, taskUID)
  Set NewAssignment = Nothing
  
  Const NODE_ELEMENT = 1
  
  Dim xmlDoc, newNode
  Set xmlDoc = root.ownerDocument
  
  Dim uid: uid = GetMaxUID(root, "Assignment") + 1
  Set newNode = xmlDoc.createNode(NODE_ELEMENT, "Assignment", root.namespaceURI)
  root.appendChild newNode
  
  SetPropertyNode newNode, "UID", uid  
  SetPropertyNode newNode, "TaskUID", taskUID
  Set newAssignment = newNode
End Function

Private Function LookupAssignment(root, taskUID)
  Set LookupAssignment = Nothing
  
  Dim node
  Set node = root.selectSingleNode("pj:Assignment[" & _
    "pj:TaskUID = '" & taskUID & "']")
  If node Is Nothing Then
    Set LookupAssignment = NewAssignment(root, taskUID): Exit Function  
  End If
  Set LookupAssignment = node
End Function

Private Sub SyncResource(node, unit)
  Dim project, resources, assignments
  Set project = node.ownerDocument.documentElement
  Set resources = project.selectSingleNode("pj:Resources")
  Set assignments = project.selectSingleNode("pj:Assignments")
  Dim uid: uid = node.selectSingleNode("pj:UID").text
  Dim ruid: ruid = LookupResource(resources, unit("resource.group"), unit("resource.principal"), unit("resource.type"))
  Dim assignment
  Set assignment = LookupAssignment(assignments, node.selectSingleNode("pj:UID").text)
  SetPropertyNode assignment, "ResourceUID", ruid
End Sub

Private Sub SyncUnitToTask(node, unit)
  If unit.Exists("uid") Then SetPropertyNode node, "UID", unit("uid")
  SetPropertyNode node, "OutlineLevel", unit("outlineLevel")
  SetPropertyNode node, "OutlineNumber", unit("outlineNumber")
  SetPropertyNode node, "Name", unit("object").Description
  SetPropertyNode node, "Summary", unit("summary")
  SetPropertyNode node, "Start", unit("start")
  SetPropertyNode node, "Finish", unit("finish")
  If 0 = unit("summary") Then
    If unit.Exists("constraintType") Then SetPropertyNode node, "ConstraintType", unit("constraintType")
    If unit.Exists("constraintDate") Then SetPropertyNode node, "ConstraintDate", unit("constraintDate")
    If unit.Exists("manual") Then SetPropertyNode node, "Manual", unit("manual")
  End If
  If unit("completed") Then
    SetPropertyNode node, "PercentComplete", 100
  End If
  If (vbNullString <> unit("resource.group")) _
    And (vbNullString <> unit("resource.principal")) Then
    SyncResource node, unit
  End If
End Sub

Private Sub UpdateProjectTask(tasks, unit)

  Const pjCustomTaskText30 = 188744016
  
  Dim targetNode
  Set targetNode = tasks.selectSingleNode("pj:Task[(pj:ExtendedAttribute) " & _
        "and (pj:ExtendedAttribute/pj:FieldID = " & pjCustomTaskText30 & ") " & _
        "and (pj:ExtendedAttribute/pj:Value = '" & unit("object").GUID & "')]")
  
  If targetNode Is Nothing Then Exit Sub
  
  SyncUnitToTask targetNode, unit
  
  Const pjCustomTaskDate10 = 188743954
  SetExtendedAttribute targetNode, pjCustomTaskDate10, unit("lastSyncTime")
End Sub

Private Sub SetExtendedAttribute(node, id, value)
  
  Const NODE_ELEMENT = 1
  
  Dim attNode
  Set attNode = node.selectSingleNode("pj:ExtendedAttribute[pj:FieldId = " & id & "]")
  If attNode Is Nothing Then
    Set attNode = node.ownerDocument.createNode(NODE_ELEMENT, "ExtendedAttribute", node.namespaceURI)
    node.appendChild attNode
  End If
  
  SetPropertyNode attNode, "FieldID", id
  If IsDate(value) Then
    SetPropertyNode attNode, "Value", FormatDateTime(value)
  Else
    SetPropertyNode attNode, "Value", value
  End If
End Sub

Private Sub ResetUIDGenerators()
  Const Key = "TDMS2MSProjectUIDGenerators"
  If ThisApplication.Dictionary.Exists(Key) Then ThisApplication.Dictionary.Remove Key
End Sub

Private Function GetMaxUID(root, tag)
  GetMaxUID = 0
  
  Const Key = "TDMS2MSProjectUIDGenerators"
  If Not ThisApplication.Dictionary.Exists(Key) Then
    Set ThisApplication.Dictionary.Item(Key) = CreateObject("Scripting.Dictionary")
  End If
  
  Dim dict: Set dict = ThisApplication.Dictionary.Item(Key)
  If dict.Exists(tag) Then
    GetMaxUID = dict(tag) + 1: dict(tag) = GetMaxUID: Exit Function
  End If
  
  Dim nodeSet, item
  Set nodeSet = root.selectNodes("pj:" & tag & "/pj:UID")
  For Each item In nodeSet
    If CLng(item.Text) > GetMaxUID Then GetMaxUID = CLng(item.Text)
  Next
  dict(tag) = GetMaxUID
End Function

Private Sub SetPropertyNode(node, tag, value)
  
  Const NODE_ELEMENT = 1
  
  Dim propertyNode
  Set propertyNode = node.selectSingleNode("pj:" & tag)
  If propertyNode Is Nothing Then
    Set propertyNode = node.ownerDocument.createNode(NODE_ELEMENT, tag, node.namespaceURI)
    node.appendChild propertyNode
  End If
  propertyNode.Text = value
End Sub

Private Function Correlate(tasks, objects)

  Const pjCustomTaskText30 = 188744016
  Const pjCustomTaskDate10 = 188743954
  
  Dim i, create, update, delete
  create = Array(): update = Array(): delete = Array()
  
  Dim node, obj
  For i = LBound(objects) To UBound(objects)
    Set obj = objects(i)
    Set node = tasks.selectSingleNode("pj:Task[(pj:ExtendedAttribute) " & _
        "and (pj:ExtendedAttribute/pj:FieldID = " & pjCustomTaskText30 & ") " & _
        "and (pj:ExtendedAttribute/pj:Value = '" & obj("object").GUID & "')]")
    If node Is Nothing Then
      ' new TDMS object
      ReDim Preserve create(UBound(create) + 1)
      Set create(UBound(create)) = obj
    Else
      ' get modification date
      Dim attNode, valueNode
      Set attNode = node.selectSingleNode("pj:ExtendedAttribute[pj:FieldID = " & pjCustomTaskDate10 & "]")
      If Not attNode Is Nothing Then
        Set valueNode = attNode.selectSingleNode("pj:Value")
        If Not valueNode Is Nothing Then
          Dim pjSyncTime: pjSyncTime = ParseDateTime(valueNode.text)
          If obj("lastSyncTime") > pjSyncTime Then
            ReDim Preserve update(UBound(update) + 1)
            Set update(UBound(update)) = obj
          End If
        End If
      End If
    End If
  Next
  
  ' deleted in TDMS
  Dim pjGUIDs, guid: Set pjGUIDs = CollectProjectGUIDs(tasks)
  For i = LBound(objects) To UBound(objects)
    guid = objects(i)("object").GUID
    If pjGUIDs.Exists(guid) Then pjGUIDs.Remove guid
  Next
  If pjGUIDs.Count > 0 Then 
    Dim items: items = pjGUIDs.Items
    For i = LBound(items) To UBound(items)
      ReDim Preserve delete(UBound(delete) + 1)
      Set delete(UBound(delete)) = items(i)
    Next
  End If
  
  Correlate = Array(create, update, delete)
End Function

Private Function CollectProjectGUIDs(tasks)
  Set CollectProjectGUIDs = CreateObject("Scripting.Dictionary")
  
  Const pjCustomTaskText30 = 188744016
  
  Dim attCollection, attNode, valueNode
  Set attCollection = tasks.SelectNodes("pj:Task/pj:ExtendedAttribute[pj:FieldID = " & pjCustomTaskText30 & "]")
  If attCollection Is Nothing Then Exit Function
    
  For Each attNode In attCollection
    Set valueNode = attNode.SelectSingleNode("pj:Value")
    If Not valueNode Is Nothing Then _
      CollectProjectGUIDs.Add valueNode.Text, attNode.parentNode
  Next
End Function

Private Function PrepareSyncTarget(obj)
  Dim func: func = "PrepareSyncTarget"
  Dim vbArgError: vbArgError = 5
  If "OBJECT_STAGE" <> obj.ObjectDefName Then Err.Raise vbArgError, ComposeLocation(func)
  If AttIsNullOrEmpty(obj, "ATTR_PROJECT_STAGE_CODE") Then _
    Err.Raise vbObjectError, ComposeLocation(func), "<ATTR_PROJECT_STAGE_CODE> attribute is missing"
  
  Set PrepareSyncTarget = Nothing
  
  Dim project
  Set project = obj.Attributes("ATTR_PROJECT").Object
  If IsNullOrEmpty(project) Then _
    Err.Raise, vbObjectError, ComposeLocation(func), "reference to project is not set"
  
  Dim content
  Set content = project.Objects.ObjectsByDef("OBJECT_P_ROOT")
  If Not IsSingleObject(content) Then _
    Err.Raise vbObjectError, ComposeLocation(func), "expected single object of type <OBJECT_P_ROOT>"
  
  Dim query, charts
  Set query = ThisApplication.CreateQuery()
  query.AddCondition tdmQueryConditionParent, content(0)
  query.AddCondition tdmQueryConditionObjectDef, "OBJECT_DOCUMENT"
  query.AddCondition tdmQueryConditionAttribute, "График по стадии " & obj.Description, "ATTR_DOCUMENT_NAME"
  query.AddCondition tdmQueryConditionAttribute, _
    ThisApplication.Classifiers.FindBySysId("NODE_DOCUMENT_SCHEDULE"), "ATTR_DOCUMENT_TYPE"
  query.AddCondition tdmQueryConditionAttribute, project, "ATTR_PROJECT"
  
  Set charts = query.Objects
  If IsEmptyCollection(charts) Then charts = Array(CreateChart(content(0), obj))
  
  If Not IsSingleObject(charts) Then _
    Err.Raise vbObjectError, ComposeLocation(func), "expected single chart object"
  
  Dim chart: Set chart = charts(0)
  Dim file: Set file = Nothing
  Dim name: name = "График по стадии " & obj.Description & ".mpp"
  If Not chart.Files.Has(name) Then
    Dim mpp: Set mpp = SelectProjectTemplate()
    If mpp Is Nothing Then Exit Function
    Set file = chart.Files.AddCopy(mpp, name)
    chart.Update
    Set file = chart.Files(name)
  End If
  If file Is Nothing Then Set file = chart.Files(name)
  
  file.CheckOut file.WorkFileName
  ' chart.CheckOut
  Set PrepareSyncTarget = file
End Function

Private Function SelectProjectTemplate()
  Dim func: func = "SelectProjectTemplate"
  
  Set SelectProjectTemplate = Nothing
  Dim source: Set source = ThisApplication.FileDefs("FILE_OBJECT_SCHEDULE").Templates
  If IsSingleObject(source) Then
    Set SelectProjectTemplate = source(0): Exit Function
  End If
  
  Dim dlg: Set dlg = ThisApplication.Dialogs.SelectDlg
  dlg.Caption = "Выбор шаблона"
  dlg.Prompt = "Выберите шаблон для создания графика в Microsoft Project"
  dlg.SelectFrom = source
  If Not dlg.Show Then Exit Function
  If IsEmptyCollection(dlg.Objects) Then Exit Function
  Set SelectProjectTemplate = dlg.Objects(0)
End Function

Private Function BuildXmlParseErrorMessage(perr)
  BuildXmlParseErrorMessage = vbNullString
  Dim a: a = Array(0, 0, 0, 0)
  a(0) = "Xml parse error:"
  a(1) = perr.url
  a(2) = "row: " & perr.line & ", column: " & perr.linepos
  a(3) = perr.reason
  BuildXmlParseErrorMessage = Join(a, vbCrLf)
End Function

Private Function CreateChart(parent, ref)
  Set CreateChart = Nothing
  
  Dim sam, obj
  Set sam = New SysAdminMode
  Set obj = parent.Content.Create("OBJECT_DOCUMENT")
  With obj.Attributes
    .Item("ATTR_DOCUMENT_TYPE").Classifier = _
      ThisApplication.Classifiers.FindBySysId("NODE_DOCUMENT_SCHEDULE")
    .Item("ATTR_DOCUMENT_NAME") = "График по стадии " & ref.Description
    obj.Description = .Item("ATTR_DOCUMENT_NAME").Value
  End With
  Set CreateChart = obj
End Function

Private Function IsSingleObject(collection)
  Dim func: func = "IsSingleObject"
  
  If vbObject = VarType(collection) Then
    IsSingleObject = 1 = collection.Count
  ElseIf (VarType(collection) And vbArray) > 0 Then
    IsSingleObject = 0 = UBound(collection)
  Else
    Err.Raise vbObjectError, ComposeLocation(func), "unexpected argument"
  End If  
End Function

Private Function IsEmptyCollection(collection)
  IsEmptyCollection = 0 = collection.Count
End Function

Public Function CollectData(obj, key)
  CollectData = Array()
  Dim func: func = "CollectData"
  
  Dim dispatcher
  Set dispatcher = CreateObject("Scripting.Dictionary")
  dispatcher.Add "ПД", "CollectDataProject"
  dispatcher.Add "РД", "CollectDataWork"
  
  If IsNullOrEmpty(obj) Then _
    Err.Raise vbObjectError, ComposeLocation(func), "<obj> argument can't be null"
  
  If StringIsNullOrEmpty(key) Then key = "DefaultSortKey"
  
  Dim att
  Set att = obj.Attributes
  If AttIsNullOrEmpty(obj, "ATTR_PROJECT_STAGE_CODE") Then _
    Err.Raise vbObjectError, ComposeLocation(func), "<obj> doesn't have <ATTR_PROJECT_STAGE_CODE> attribute"
  
  Dim index: index = att("ATTR_PROJECT_STAGE_CODE").Value
  If Not dispatcher.Exists(index) Then _
    Err.Raise vbObjectError, ComposeLocation(func), "unknown stage code <" & index & ">"
    
  Dim callMe: callMe = ComposeFunctionCall(dispatcher(index), Array("obj", "key"))
  CollectData = Eval(callMe)
  
  Set dispatcher = Nothing
End Function

Private Function CollectDataImpl(obj, key, defs)
  Dim result, children: result = Array():  ReDim result(1)
  Set result(0) = ComposeTask(obj.Attributes("ATTR_PROJECT").Object, Nothing, 1)
  Set result(1) = ComposeTask(obj, result(0), 1)
  children = GetChildTasks(result(1), defs, key)
  result = CombineArrays(result, children)
  CollectDataImpl = result
End Function

Private Function GetChildTasks(parent, defs, sortFunc)
  GetChildTasks = Array()

  Dim joinedDefs: joinedDefs = Join(defs, ";")
  
  Dim sorter, obj, getKeyCall
  Set sorter = CreateObject("System.Collections.SortedList")
  getKeyCall = ComposeFunctionCall(sortFunc, Array("obj"))
  For Each obj In parent("object").Content
    If InStr(1, joinedDefs, obj.ObjectDefName) Then _
      sorter.Add Eval(getKeyCall), obj
  Next
  
  Dim i, children, result: result = Array()
  For i = 0 To sorter.Count - 1
    ReDim Preserve result(UBound(result) + 1)
    Set result(UBound(result)) = ComposeTask(sorter.GetByIndex(i), parent, i + 1)
    children = GetChildTasks(result(UBound(result)), defs, sortFunc)
    result = CombineArrays(result, children)
  Next
  GetChildTasks = result
End Function

Private Function ComposeTask(obj, parent, index)
  Set ComposeTask = Nothing
  Dim func: func = "ComposeTask"
  Dim vbArgError: vbArgError = 5
  
  If vbObject <> VarType(obj) Then Err.Raise vbArgError, ComposeLocation(func), "invalid <obj> argument"
  If vbObject <> VarType(parent) Then Err.Raise vbArgError, ComposeLocation(func), "invalid <parent> argument"
  If IsEmpty(index) Then Err.Raise vbArgError, ComposeLocation(func), "invalid <index> argument"
  If Not parent Is Nothing Then
    If (Not parent.Exists("outlineLevel")) Or (Not parent.Exists("outlineNumber")) Then _
      Err.Raise vbArgError, ComposeLocation(func), "invalid <parent> argument"
      
    parent("summary") = 1
  End If
  
  Dim tmp, pTask: Set pTask = Nothing
  Set tmp = obj.ReferencedBy.ObjectsByDef("OBJECT_P_TASK")
  If tmp.Count > 0 Then Set pTask = tmp(0)
  
  Dim objAtt : Set objAtt = obj.Attributes
  Dim taskAtt: Set taskAtt = Nothing
  If Not pTask Is Nothing Then Set taskAtt = pTask.Attributes
  
  Dim dict
  Set dict = CreateObject("Scripting.Dictionary")
  Set dict("object") = obj
  If pTask Is Nothing Then
    dict("lastSyncTime") = obj.ModifyTime
  Else
    dict("lastSyncTime") = Max(obj.ModifyTime, pTask.ModifyTime)
  End If
  If Not parent Is Nothing Then
    dict("outlineLevel") = parent("outlineLevel") + 1
    dict("outlineNumber") = Join(CombineArrays(Split(parent("outlineNumber"), "."), Array(index)), ".")
  Else
    dict("outlineLevel") = 1
    dict("outlineNumber") = index
  End If
  dict("start") = GetStartDate(IIf(pTask Is Nothing, objAtt, taskAtt))
  dict("finish") = GetFinishDate(IIf(pTask Is Nothing, objAtt, taskAtt))
  dict("summary") = 0
  dict("constraintType") = 4
  dict("constraintDate") = dict("start")
  dict("manual") = 1
  dict("completed") = GetCompletionState(pTask)
  dict("resource.group") = GetResourceGroup(objAtt, taskAtt)
  dict("resource.principal") = GetResourcePrincipal(objAtt, taskAtt)
  dict("resource.type") = GetResourceType(objAtt)
  Set ComposeTask = dict
End Function

Private Function GetResourceType(attributes)
  
  ' see definitions at https://msdn.microsoft.com/en-us/library/vs/alm/bb968434(v=office.12).aspx
  Const pjResourceTypeMaterial = 0
  Const pjResourceTypeWork = 1
  Const pjResourceTypeCost = 2
  
  GetResourceType = pjResourceTypeMaterial
  If attributes.Has("ATTR_SUBCONTRACTOR_WORK") Then
    If attributes("ATTR_SUBCONTRACTOR_WORK").Value Then
      GetResourceType = pjResourceTypeCost: Exit Function
    End If
  End If
  GetResourceType = pjResourceTypeWork
End Function

Private Function GetResourceGroup(objAtt, taskAtt)
  GetResourceGroup = vbNullString
  If objAtt Is Nothing Then Exit Function
  If objAtt.Has("ATTR_SUBCONTRACTOR_WORK") Then
    If objAtt("ATTR_SUBCONTRACTOR_WORK").Value Then
      GetResourceGroup = "Подрядчик": Exit Function
    End If
  End If
  
  If objAtt.Has("ATTR_S_DEPARTMENT") Then
    Dim ud: Set ud = objAtt("ATTR_S_DEPARTMENT").Object
    If Not ud Is Nothing Then
      If Not AttIsNullOrEmpty(ud, "ATTR_NAME") Then
        GetResourceGroup = ud.Attributes("ATTR_NAME").Value: Exit Function
      End If
    End If
  End If
  
  If taskAtt Is Nothing Then Exit Function
  If taskAtt.Has("ATTR_USER_DEPT") Then
    Set ud = taskAtt("ATTR_USER_DEPT").Object
    If Not ud Is Nothing Then
      If AttIsNullOrEmpty(ud, "ATTR_NAME") Then Exit Function
      GetResourceGroup = ud.Attributes("ATTR_NAME").Value
    End If
  End If
End Function

Private Function GetResourcePrincipal(objAtt, taskAtt)
  GetResourcePrincipal = vbNullString
  If objAtt Is Nothing Then Exit Function
  If objAtt.Has("ATTR_SUBCONTRACTOR_WORK") Then
    If objAtt("ATTR_SUBCONTRACTOR_WORK").Value Then
      If objAtt.Has("ATTR_SUBCONTRACTOR_CLS") Then
        Dim sco: Set sco = objAtt("ATTR_SUBCONTRACTOR_CLS").Object
        If Not sco Is Nothing Then
          GetResourcePrincipal = sco.Description: Exit Function
        End If
      End If
    End If
  End If
  If objAtt.Has("ATTR_RESPONSIBLE") Then
    GetResourcePrincipal = GetResponsible(objAtt): Exit Function
  End If
  If taskAtt Is Nothing Then Exit Function
  If taskAtt.Has("ATTR_RESPONSIBLE") Then
    GetResourcePrincipal = GetResponsible(taskAtt): Exit Function
  End If
End Function

Private Function GetResponsible(attSet)
  GetResponsible = vbNullString
  If attSet Is Nothing Then Exit Function
  If attSet.Has("ATTR_RESPONSIBLE") Then
    If Not attSet("ATTR_RESPONSIBLE").Empty Then
      If Not attSet("ATTR_RESPONSIBLE").User Is Nothing Then
        GetResponsible = attSet("ATTR_RESPONSIBLE").User.Description: Exit Function
      End If
      If Not attSet("ATTR_RESPONSIBLE").Group Is Nothing Then
        GetResponsible = attSet("ATTR_RESPONSIBLE").Group.Description: Exit Function
      End If
    End If
  End If
End Function

Private Function GetCompletionState(obj)
  GetCompletionState = False
  If obj Is Nothing Then Exit Function
  GetCompletionState = "STATUS_P_TASK_FINISHED" = obj.StatusName
End Function

Private Function GetStartDate(attributes)
  GetStartDate = ThisApplication.CurrentTime
  
  If attributes.Has("ATTR_STARTDATE_FACT") Then
    Dim a: Set a = attributes("ATTR_STARTDATE_FACT")
    If Not a.Empty Then GetStartDate = a.Value
  End If
  GetStartDate = FormatDateTime(DateValue(GetStartDate))
End Function

Private Function GetFinishDate(attributes)
  GetFinishDate = ThisApplication.CurrentTime
  
  If attributes.Has("ATTR_ENDDATE_FACT") Then
    Dim a: Set a = attributes("ATTR_ENDDATE_FACT")
    If Not a.Empty Then GetFinishDate = a.Value
  End If
  
  GetFinishDate = DateValue(GetFinishDate)
  GetFinishDate = DateAdd("d", 1, GetFinishDate)
  GetFinishDate = DateAdd("s", -1, GetFinishDate)
  GetFinishDate = FormatDateTime(GetFinishDate)
End Function

Private Function CollectDataProject(obj, key)
  CollectDataProject = CollectDataImpl(obj, key, _
    Array("OBJECT_PROJECT_SECTION", "OBJECT_PROJECT_SECTION_SUBSECTION", "OBJECT_VOLUME"))
End Function

Private Function CollectDataWork(obj, key)
  CollectDataWork = CollectDataImpl(obj, key, _
    Array("OBJECT_WORK_DOCS_FOR_BUILDING", "OBJECT_WORK_DOCS_SET"))
End Function

Private Function DefaultSortKey(obj)
  DefaultSortKey = vbNullString
  Dim dispatcher: Set dispatcher = CreateObject("Scripting.Dictionary")
  dispatcher.Add "OBJECT_PROJECT", _
    ComposeFunctionCall("DotDecimalKey", Array("obj.Attributes(""ATTR_PROJECT_CODE"").Value"))
  dispatcher.Add "OBJECT_STAGE", _
    ComposeFunctionCall("DotDecimalKey", Array("obj.Attributes(""ATTR_PROJECT_STAGE_NUM"").Value"))
  dispatcher.Add "OBJECT_PROJECT_SECTION", _
    ComposeFunctionCall("DotDecimalKey", Array("obj.Attributes(""ATTR_SECTION_NUM"").Value"))
  dispatcher.Add "OBJECT_PROJECT_SECTION_SUBSECTION", _
    ComposeFunctionCall("DotDecimalKey", Array("obj.Attributes(""ATTR_SECTION_NUM"").Value"))
  dispatcher.Add "OBJECT_VOLUME", _
    ComposeFunctionCall("DotDecimalKey", Array("obj.Attributes(""ATTR_VOLUME_NUM"").Value"))
  dispatcher.Add "OBJECT_WORK_DOCS_FOR_BUILDING", _
    "obj.Attributes(""ATTR_PROJECT_BASIC_CODE"").Value"
  dispatcher.Add "OBJECT_WORK_DOCS_SET", _
    "obj.Attributes(""ATTR_WORK_DOCS_SET_CODE"").Value"
  DefaultSortKey = Eval(dispatcher(obj.ObjectDefName)) & obj.Description & obj.GUID
End Function

Private Function AttIsNullOrEmpty(obj, def)
  AttIsNullOrEmpty = False
  Dim func: func = "AttIsNullOrEmpty"
  If IsNullOrEmpty(obj) Then Err.Raise vbObjectError, ComposeLocation(func), "invalid argument <obj>"
  Dim att: Set att = obj.Attributes
  If Not att.Has(def) Then AttIsNullOrEmpty = True: Exit Function
  AttIsNullOrEmpty = att(def).Empty
End Function

Private Function IsNullOrEmpty(arg)
  IsNullOrEmpty = False
  Dim func: func = "IsNullOrEmpty"
  If IsEmpty(arg) Then IsNullOrEmpty = True: Exit Function
  If vbObject <> VarType(arg) Then _
    Err.Raise vbObjectError, ComposeLocation, "invalid argument type <" & TypeName(arg) & ">"
  IsNullOrEmpty = (arg Is Nothing)
End Function

Private Function StringIsNullOrEmpty(arg)
  StringIsNullOrEmpty = False
  Dim func: func = "StringIsNullOrEmpty"
  If IsEmpty(arg) Then StringIsNullOrEmpty = True: Exit Function
  If vbString <> VarType(arg) Then _
    Err.Raise vbObjectError, ComposeLocation(func), "invalid argument type <" & TypeName(arg) & ">"
  StringIsNullOrEmpty = 0 = Len(arg)
End Function

Private Sub CheckComposeArguments(method, args)
  Dim i, func: func = "CheckComposeArguments"
  If StringIsNullOrEmpty(method) Then _
    Err.Raise vbObjectError, ComposeLocation(func), "empty method is not allowed"
  If Not IsArray(args) Then _
    Err.Raise vbObjectError, ComposeLocation(func), "array expected at <args>"
  For i = LBound(args) To UBound(args)
    If StringIsNullOrEmpty(args(i)) Then _
      Err.Raise vbObjectError, ComposeLocation(func), "empty argument at <" & i & ">"
  Next
End Sub

Private Function ComposeFunctionCall(method, args)
  ComposeFunctionCall = vbNullString
  CheckComposeArguments method, args
  ComposeFunctionCall = method & "(" & Join(args, ", ") & ")"     
End Function

Private Function ComposeSubCall(method, args)
  ComposeSubCall = vbNullString
  CheckComposeArguments method, args
  ComposeSubCall = method & " " & Join(args, ", ")
End Function

Private Function ScriptName()
  ScriptName = "CMD_SS_MSPROJECT_EXCHANGE_LIB"
End Function

Private Function ComposeLocation(src)
  ComposeLocation = ScriptName & "." & src
End Function

Public Function FormatNumber(num, digits)
  FormatNumber = vbNullString
  Dim func: func = "FormatNumber"
  Dim vbArgError: vbArgError = 5
  If (Not IsNumeric(num)) Or (Not IsNumeric(digits)) Then _
    Err.Raise vbArgError, ComposeLocation(func)
  FormatNumber = CStr(num)
  If Len(FormatNumber) < digits Then _
    FormatNumber = String(digits - Len(FormatNumber), "0") & FormatNumber
End Function

Public Function FormatDate(arg)
  FormatDate = vbNullString
  Dim func: func = "FormatDate"
  Dim vbArgError: vbArgError = 5
  If Not IsDate(arg) Then Err.Raise vbArgError, ComposeLocation(func)
  FormatDate = Join( Array( _
    FormatNumber(Year(arg), 4), _
    FormatNumber(Month(arg), 2), _
    FormatNumber(Day(arg), 2)), "-")
End Function

Public Function FormatTime(arg)
  FormatTime = vbNullString
  Dim func: func = "FormatTime"
  Dim vbArgError: vbArgError = 5
  If Not IsDate(arg) Then Err.Raise vbArgError, ComposeLocation(func)
  FormatTime = Join(Array( _
    FormatNumber(Hour(arg), 2), _
    FormatNumber(Minute(arg), 2), _
    FormatNumber(Second(arg), 2)), ":")
End Function

Public Function FormatDateTime(arg)
  FormatDateTime = vbNullString
  Dim func: func = "FormatDateTime"
  Dim vbArgError: vbArgError = 5
  If Not IsDate(arg) Then Err.Raise vbArgError, ComposeLocation(func)
  FormatDateTime = Join(Array( _
    FormatDate(arg), FormatTime(arg)), "T")
End Function

Public Function FormatDuration(arg)
  FormatDuration = vbNullString
  Dim func: func = "FormatDuration"
  Dim vbArgError: vbArgError = 5
  If Not IsDate(arg) Then Err.Raise vbArgError, ComposeLocation(func)
  If arg < 0.0 Then Err.Raise vbArgError, ComposeLocation(func), "negative duration"
  Dim hour, minute, second
  hour = DateDiff("h", 0, arg): arg = DateAdd("h", -hour, arg)
  minute = DateDiff("n", 0, arg): arg = DateAdd("n", -minute, arg)
  second = DateDiff("s", 0, arg)
  FormatDuration = "PT" & hour & "H" & minute & "M" & second & "S"
End Function

Public Function FormatInterval(begin, end_)
  FormatInterval = vbNullString
  Dim func: func = "FormatInterval"
  Dim vbArgError: vbArgError = 5
  If Not IsDate(begin) Then Err.Raise vbArgError, ComposeLocation(func), "begin"
  If Not IsDate(end_) Then Err.Raise vbArgError, ComposeLocation(func), "end"
  If (end_ - begin) < 0 Then Err.Raise vbArgError, ComposeLocation(func), "invalid interval"
  FormatInterval = FormatDuration(CDate(end_ - begin))
End Function

Public Function IIf(condition, truePart, falsePart)
  If condition Then 
    If IsObject(truePart) Then Set IIf = truePart Else IIf = truePart
  Else
    If IsObject(falsePart) Then Set IIf = falsePart Else IIf = falsePart
  End If
End Function

Public Function CombineArrays(arg1, arg2)
  CombineArrays = Array()
  Dim func: func = "CombineArrays"
  Dim vbArgError: vbArgError = 5
  If Not IsArray(arg1) Then Err.Raise vbArgError, ComposeLocation(func), "arg1"
  If Not IsArray(arg2) Then Err.Raise vbArgError, ComposeLocation(func), "arg2"

  If (-1 = UBound(arg1)) Then CombineArrays = arg2: Exit Function
  If (-1 = UBound(arg2)) Then CombineArrays = arg1: Exit Function
  
  Dim i, j, a
  a = Array(): i = 0: j = LBound(a)
  ReDim a(UBound(arg1) + UBound(arg2) + 1)
  For i = LBound(arg1) To UBound(arg1)
    If IsObject(arg1(i)) Then Set a(j) = arg1(i) Else a(j) = arg1(i)
    j = j + 1
  Next
  For i = LBound(arg2) To Ubound(arg2)
    If IsObject(arg2(i)) Then Set a(j) = arg2(i) Else a(j) = arg2(i)
    j = j + 1
  Next
  CombineArrays = a
End Function

Public Function DotDecimalKey(str)
  DotDecimalKey = vbNullString
  
  Dim rexp, l, a, match, test
  Set rexp = New RegExp
  rexp.Pattern = "^(\d{1,3})"
  a = Array(): l = Len(str)
  While (l > 0)
    test = Right(str, l)
    Set match = rexp.Execute(test)
    If 0 = match.Count Then
      l = l - 1
    Else
      ReDim Preserve a(Ubound(a) + 1)
      a(UBound(a)) = FormatNumber(CLng(match(0).Value), 3)
      l = l - match(0).Length
    End If
  WEnd
  
  DotDecimalKey = Join(a, ".")
End Function

Private Function Max(x, y)
  If x > y Then Max = x Else Max = y
End Function

Private Function ParseDateTime(arg)
  ParseDateTime = CDate(0.0)
  Dim func: func = "ParseDateTime"
  Dim vbArgError: vbArgError = 5
  If vbString <> VarType(arg) Then Err.Raise vbArgError, ComposeLocation(func), "invalid argument type"
  Dim dt: dt = Split(arg, "T")
  If 1 <> UBound(dt) Then Err.Raise vbArgError, ComposeLocation(func), "unknown date/time format"
  Dim da: da = Split(dt(0), "-")
  If 2 <> UBound(da) Then Err.Raise vbArgError, ComposeLocation(func), "unknown date format"
  Dim ta: ta = Split(dt(1), ":")
  If 2 <> UBound(ta) Then Err.Raise vbArgError, ComposeLocation(func), "unknown time format"
  ParseDateTime = DateSerial(da(0), da(1), da(2)) + TimeSerial(ta(0), ta(1), ta(2))
End Function

Private Function ArraySize(arg)
  Dim func: func = "ArraySize"
  Dim vbArgError: vbArgError = 5
  If Not IsArray(arg) Then Err.Raise vbArgError, ComposeLocation(func), "invalid argument"
  ArraySize = UBound(arg) - LBound(arg) + 1
End Function
