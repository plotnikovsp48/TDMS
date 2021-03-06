If ThisObject.ObjectDefName = "OBJECT_STAGE" Then
 If MsgBox("Данная сформирует xml-файл для загрузки в MS Project. Старый xml-файл стадии, при его наличии, будет удален. Продолжить?",vbExclamation+vbYesNo,"Внимание!") = vbYes Then
  Call Main()
 Else
  Msgbox "Выполнение команды прекращено."
 End If
Else
 Msgbox "Ошибка выполнения команды. Местом запуска команды должна быть Стадия. Обратитесь к администратору системы."
End If

Sub Main()
Set proj = ThisObject.Attributes("ATTR_PROJECT").Object
If proj is Nothing Then
 Msgbox "Ошибка выполнения команды. В атрибутах текущей Стадии нет ссылки на Проект. Обратитесь к администратору системы."
 Exit Sub
End If
Set planning = proj.Content.ObjectsByDef("OBJECT_P_ROOT").Item(0)
If proj is Nothing Then
 Msgbox "Ошибка выполнения команды. Объект Планирование в составе Проекта не найден. Обратитесь к администратору системы."
 Exit Sub
End If
'поиск соответствующего для сохранения документа в составе Планирования
' ИО Документ (OBJECT_DOCUMENT) в составе ИО Планирование в проекте. 
' Тип документа (ATTR_DOCUMENT_TYPE) = График проекта (NODE_DOCUMENT_SCHEDULE)
' Наименование документа (ATTR_DOCUMENT_NAME) = График по стадии {Описание стадии}
filename = "График по стадии " & ThisObject.Description
ShouldCreateDoc = True
If planning.Content.ObjectsByDef("OBJECT_DOCUMENT").Count <> 0 Then
  For Each Doc In planning.Content.ObjectsByDef("OBJECT_DOCUMENT")
   If Doc.Attributes.Has("ATTR_DOCUMENT_TYPE") Then
    If Doc.Attributes("ATTR_DOCUMENT_TYPE").Empty = False Then
     If Doc.Attributes("ATTR_DOCUMENT_TYPE").Classifier.Description = "График проекта" Then
      If Doc.Attributes("ATTR_DOCUMENT_NAME") = filename Then
       Set xmlDoc = Doc
       ShouldCreateDoc = False
       Exit For
      End If
     End If
    End If
   End If
  Next
  Set Doc = Nothing
End If

'создание нового документа в составе Планирования согласно спецификации
If ShouldCreateDoc = True Then
 planning.Permissions = SysAdminPermissions
 Set xmlDoc = planning.Objects.Create("OBJECT_DOCUMENT")
 xmlDoc.Permissions = SysAdminPermissions
 xmlDoc.Attributes("ATTR_DOCUMENT_TYPE").Classifier = ThisApplication.Classifiers.FindBySysId("NODE_DOCUMENT_SCHEDULE")
 xmlDoc.Attributes("ATTR_DOCUMENT_NAME") = filename
 xmlDoc.Description = xmlDoc.Attributes("ATTR_DOCUMENT_NAME")
End If
  
filename = filename & ".xml"
xmlDoc.Permissions = SysAdminPermissions
If xmlDoc.Files.Has(filename) then xmlDoc.Files(filename).Erase
xmlDoc.Update
xmlDoc.Files.AddCopy ThisApplication.FileDefs("FILE_MSPROJECT_XML").Templates("template.xml"), filename
xmlDoc.Update
Set xmlFile = xmlDoc.Files(filename)
xmlFile.CheckOut xmlDoc.Files(filename).Workfilename
xmlDoc.Files(filename).CheckOut xmlDoc.Files(filename).Workfilename

'начало рыботы с xml

'Call parseXML(xmlFile.Workfilename, proj)
Set xmlProj = CreateObject("MSXML2.DOMDocument.6.0")
xmlProj.setProperty "SelectionLanguage", "XPath"
xmlProj.Async = False
xmlProj.load(xmlFile.Workfilename)


changetime = ThisApplication.CurrentTime
Set ChangeTag = xmlproj.SelectSingleNode("/*[local-name()='Project']/*[local-name()='Name']")
ChangeTag.Text = proj.Description
Set ChangeTag = xmlproj.SelectSingleNode("/*[local-name()='Project']/*[local-name()='Author']")
ChangeTag.Text = ThisApplication.CurrentUser.SysName
Set ChangeTag = xmlproj.SelectSingleNode("/*[local-name()='Project']/*[local-name()='CreationDate']")
ChangeTag.Text = projectDateFormat(changetime)
Set ChangeTag = xmlproj.SelectSingleNode("/*[local-name()='Project']/*[local-name()='LastSaved']")
ChangeTag.Text = projectDateFormat(changetime)

Set ChangeTag = xmlproj.SelectSingleNode("/*[local-name()='Project']/*[local-name()='StartDate']")
ChangeTag.Text = "" 'projectDateFormat(changetime)
Set ChangeTag = xmlproj.SelectSingleNode("/*[local-name()='Project']/*[local-name()='FinishDate']")
ChangeTag.Text = "" 'projectDateFormat(changetime)
Set ChangeTag = xmlproj.SelectSingleNode("/*[local-name()='Project']/*[local-name()='CurrentDate']")
ChangeTag.Text = projectDateFormat(changetime)

'работа с задачами

'- Стадия «Рабочая документация» NODE_PROJECT_STAGE_W: Выборка QUERY_SCHEDULE_STAGE_W
'- прочие стадии: Выборка: QUERY_SCHEDULE_STAGE_P

Set TasksNode = xmlproj.SelectSingleNode("/*[local-name()='Project']/*[local-name()='Tasks']")
Set TaskRecord = xmlProj.createNode(1,"Task","http://schemas.microsoft.com/project")
TasksNode.appendChild(TaskRecord)

'нулевой таск
   'у конечны= Summary = 0, IsPublished = 1
   '1 ftUID,ftID,ftName,ftActive,ftManual,ftType,ftIsNull
   '2 ftCreateDate,ftWBS,ftOutlineNumber,ftOutlineLevel,ftPriority,ftStart,ftFinish,ftDuration
   '3 ftManualStart,ftManualFinish,ftManualDuration,ftDurationFormat,ftWork,ftResumeValid,ftEffortDriven,ftRecurring,_
   '3 ftOverAllocated,ftEstimated,ftMilestone,
   '4 ftSummary,ftDisplayAsSummary,ftCritical,ftIsSubproject,ftIsSubprojectReadOnly,ftExternalTask,ftEarlyStart,
   '4 ftEarlyFinish,ftLateStart,
   '5 ftLateFinish, ftStartVariance,ftFinishVariance,ftWorkVariance,ftFreeSlack,ftTotalSlack,ftStartSlack,_
   '5 ftFinishSlack,ftFixedCost,ftFixedCostAccrual,ftPercentComplete,ftPercentWorkComplete,ftCost,_
   '5 ftOvertimeCost,ftOvertimeWork,
   '6 ftActualDuration,ftActualCost,ftActualOvertimeCost,ftActualWork,ftActualOvertimeWork,ftRegularWork,
   '6 ftRemainingDuration,ftRemainingCost,ftRemainingWork,ftRemainingOvertimeCost,ftRemainingOvertimeWork,
   '7 ftACWP,ftCV,ftConstraintType,ftCalendarUID,ftLevelAssignments,ftLevelingCanSplit,ftLevelingDelay,
   '7 ftLevelingDelayFormat,ftIgnoreResourceCalendar,ftHideBar,ftRollup,ftBCWS,ftBCWP,ftPhysicalPercentComplete,_
   '7 ftEarnedValueMethod,ftIsPublished,ftCommitmentType
If IsDate(proj.Attributes("ATTR_STARTDATE_PLAN")) = False Then 
 dStart = projectDateFormat(ThisApplication.CurrentTime)
Else
 dStart = projectDateFormat(proj.Attributes("ATTR_STARTDATE_PLAN"))
End If
If IsDate(proj.Attributes("ATTR_ENDDATE_PLAN")) = False Then 
 dFinish = projectDateFormat(ThisApplication.CurrentTime)
Else
 dFinish = projectDateFormat(proj.Attributes("ATTR_ENDDATE_PLAN"))
End If

Call FillTask(xmlProj,TaskRecord,"0","0","","1","0","1","0","",_
"0","0","0","500",dStart,dFinish,"PT0H0M0S","",_
"","PT0H0M0S","53","PT0H0M0S","0","0","0",_
"0","1","0","1","0","1","0",_
"0","0","","","","",_
"0","0","0.00","0","0","0",_
"0","0","3","0","0","0",_
"0","PT0H0M0S",_
"PT0H0M0S","0","0","PT0H0M0S","PT0H0M0S","PT0H0M0S","PT0H0M0S","0","PT0H0M0S","0","PT0H0M0S",_
"0.00","0.00","0","-1","","1","1","0","8","0","0","0","0.00","0.00","0","0","0","0",_
False,"","","",_
False,"","","",_
False,"")


'Проект
Set TaskRecord = xmlProj.createNode(1,"Task","http://schemas.microsoft.com/project")
TasksNode.appendChild(TaskRecord)

Call FillTask(xmlProj,TaskRecord,"1","1",proj.Description,"1","0","0","0",_
"","1","1","1","500",dStart,dFinish,"PT0H0M0S",_
"","","PT0H0M0S","53","PT0H0M0S","0","0","0","0","1","0",_
"1","0","1","0","0","0","","","",_
"","0","0","0.00","0","0","0","0","0","3","0","0","0","0","PT0H0M0S",_
"PT0H0M0S","0","0","PT0H0M0S","PT0H0M0S","PT0H0M0S","PT0H0M0S","0","PT0H0M0S","0","PT0H0M0S",_
"0.00","0.00","0","-1","","1","1","0","8","0","0","0","0.00","0.00","0","0","0","0",_
False,"","","",_
False,"","","",_
False,"")

'Стадия
Set TaskRecord = xmlProj.createNode(1,"Task","http://schemas.microsoft.com/project")
TasksNode.appendChild(TaskRecord)
'признак "конечной" задачи
If ThisObject.Content.Count > 0 Then
 Stage_Summarise = 1
Else
 Stage_Summarise = 0
End If

If IsDate(ThisObject.Attributes("ATTR_STARTDATE_PLAN")) = False Then 
 dStart = projectDateFormat(ThisApplication.CurrentTime)
Else
 dStart = projectDateFormat(ThisObject.Attributes("ATTR_STARTDATE_PLAN"))
End If
If IsDate(ThisObject.Attributes("ATTR_ENDDATE_PLAN")) = False Then 
 dFinish = projectDateFormat(ThisApplication.CurrentTime)
Else
 dFinish = projectDateFormat(ThisObject.Attributes("ATTR_ENDDATE_PLAN"))
End If

Call FillTask(xmlProj,TaskRecord,"2","2",ThisObject.Description,"1","0","0","0",_
"","1.1","1.1","2","500",dStart,dFinish,"PT0H0M0S",_
"","","PT0H0M0S","53","PT0H0M0S","0","0","0","0","1","0",_
Stage_Summarise,"0","1","0","0","0","","","",_
"","0","0","0.00","0","0","0","0","0","3","0","0","0","0","PT0H0M0S",_
"PT0H0M0S","0","0","PT0H0M0S","PT0H0M0S","PT0H0M0S","PT0H0M0S","0","PT0H0M0S","0","PT0H0M0S",_
"0.00","0.00","0","-1","","1","1","0","8","0","0","0","0.00","0.00","0","0","0","0",_
False,"","","",_
False,"","","",_
False,"")

If Stage_Summarise = 1 Then
 If ThisObject.Attributes("ATTR_PROJECT_STAGE").Classifier.SysName = "NODE_PROJECT_STAGE_W" Then
  containerID = "OBJECT_WORK_DOCS_FOR_BUILDING"
  childID = "OBJECT_WORK_DOCS_SET"
  qrID = "QUERY_SCHEDULE_STAGE_W"
 Else
  containerID = "OBJECT_PROJECT_SECTION"
  childID = "OBJECT_PROJECT_SECTION_SUBSECTION"
  qrID = "QUERY_SCHEDULE_STAGE_P"
 End If
End If
If planning.Queries.Has(qrID) = False Then planning.Queries.Add ThisApplication.Queries(qrID)
Set oQR = planning.Queries(qrID)
Set oCol = oQR.Objects
Set oSheet = oQR.Sheet
'словарь с парами исполнителей
Set executors_dict = ThisApplication.Dictionary(Executors)

Call AddContentWithRecursion(xmlProj,TasksNode,ThisObject,oCol,oSheet,executors_dict,"1.1.","2","2",containerID,childID)


xmlProj.save(xmlFile.Workfilename)
xmlFile.CheckIn xmlDoc.Files(filename).WorkFileName


'filename = filename & ".xml"
'xmlDoc.Permissions = SysAdminPermissions
'If xmlDoc.Files.Has(filename) then xmlDoc.Files(filename).Erase
'xmlDoc.Update
'xmlDoc.Files.AddCopy ThisApplication.FileDefs("FILE_MSPROJECT_XML").Templates("template.xml"), filename
'xmlDoc.Update
'Set xmlFile = xmlDoc.Files(filename)
'xmlFile.CheckOut xmlDoc.Files(filename).Workfilename
'xmlDoc.Files(filename).CheckOut xmlDoc.Files(filename).Workfilename

On Error Resume Next
Set objProject = CreateObject("MSProject.Application")
'objProject.Visible = True
If Not objProject Is Nothing Then
  Call CodingConv(xmlFile.Workfilename)
  Set fObj = CreateObject("Scripting.FileSystemObject") 
  Set tStream = fObj.OpenTextFile(xmlFile.Workfilename) 
  xContents = tStream.ReadAll
  objProject.OpenXML(xContents) 
  objProject.Visible = True
  tStream.Close
'  newfilename = Left(xmlFile.Workfilename,Len(xmlFile.Workfilename)-4) & ".mpp"
'  shortnewfilename = Left(filename,Len(filename)-4) & ".mpp"
'  xmlDoc.Permissions = SysAdminPermissions
'  If xmlDoc.Files.Has(filename) then xmlDoc.Files(filename).Erase
'  If xmlDoc.Files.Has(shortnewfilename) then xmlDoc.Files(shortnewfilename).Erase
'  xmlDoc.Update  
'  set errs = objProject.ActiveProject.FileSaveAs(newfilename,"MSProject.MPP") 'newfilename,"pjMPP12"
'  objProject.ActiveProject.FileClose
'  Set xmlFile = xmlDoc.Files.Create("FILE_SCHEDULE_MPP",newfilename)
'  xmlDoc.Update
  
  
  
  'objProject.Visible = True
'  objProject.Quit
  
'  Set fObj = Nothing
'  Set tStream = Nothing  
'  xContents = ""
'  Set objProject = Nothing
Else
' Msgbox "xml-файл для импорта в MS Project сформирован."
End If

Msgbox "xml-файл для импорта в MS Project сформирован."
executors_dict.RemoveAll
Set executors_dict = Nothing
Set oQR = nothing
Set oCol = nothing
Set oSheet = nothing
Set proj = nothing
Set planning = nothing
Set xmlDoc = nothing
Set NodeList = Nothing
Set ChangeTag = Nothing
Set xmlProj = Nothing
ShouldCreateDoc = ""
filename = ""
End Sub

Sub CodingConv(mfile)
  Set ADODBStream = CreateObject("ADODB.Stream")
  ADODBStream.Type = 2
  ADODBStream.Charset = "UTF-8"
  ADODBStream.Open()
  ADODBStream.LoadFromFile(mfile)
  Text = ADODBStream.ReadText()
  ADODBStream.Close()
  ADODBStream.Charset = "windows-1251"
  ADODBStream.Open()
  ADODBStream.WriteText(Text)
  ADODBStream.SaveToFile mfile, 2
  ADODBStream.Close()
End Sub

Sub AddContentWithRecursion(xmlProj,TasksNode,pObj,oCol,oSheet,executors_dict,pNum,commonTaskNum,pOutlineLevel,pContSysName,pChildSysName)',needRecursion)
 currOutlineLevel = pOutlineLevel + 1
 For i = 0 To pObj.Content.Count-1
  Set cObj = pObj.Content.Item(i)
  'если в составе есть прочие объекты, они не учитываются
  If cObj.ObjectDefName = pContSysName Or cObj.ObjectDefName = pChildSysName Then
   'сквозной номер задачи для вычисления ID задачи MS Proj
   commonTaskNum = commonTaskNum + 1
   'порядковый номер текущего объекта в составе родительского
   num = i + 1
   'номер в иерархии задач MS Proj
   treeNum = pNum & num
   'определение финальная это задача или нет
   ShouldSummarise = 1
   IsManual = 0
   ftConstraintType = "0"
   ManualDuration = "PT0H0M0S"
   If cObj.ObjectDefName = pChildSysName Then 
    ShouldSummarise = 0
    IsManual = 1
'    ManualDuration = "PT0H20000M0S"
   Else
    If cObj.Content.ObjectsByDef(pContSysName).Count = 0 And cObj.Content.ObjectsByDef(pChildSysName).Count = 0 Then 
     ShouldSummarise = 0
     IsManual = 1
'     ManualDuration = "PT0H20000M0S"
    End If
   End If
   'запись для текущего объекта
   Set TaskRecord = xmlProj.createNode(1,"Task","http://schemas.microsoft.com/project")
   TasksNode.appendChild(TaskRecord)
 
   qNumber = oCol.Index(cObj.GUID)
   needBaseLineDates = False
   blStart = ""
   blFinish = ""
   If qNumber = "-1" Then
    dStart = projectDateFormat(ThisApplication.CurrentTime)
    dFinish = projectDateFormat(ThisApplication.CurrentTime)
    dDuration = CalculateWorkingHours(dStart,dFinish)
    fStart = dStart
    fFinish = dFinish
    fDuration = dDuration
   Else
   
'Запланированное начало    Ожидаемая дата начала работ
'ATTR_STARTDATE_ESTIMATED
'Запланированное окончание   Ожидаемая дата окончания работ
'ATTR_ENDDATE_ESTIMATED


    dStart = oSheet.CellValue(qNumber,"Ожидаемая дата начала работ")
    dFinish = oSheet.CellValue(qNumber,"Ожидаемая дата окончания работ")
    tempdStart = dStart
    tempdFinish = dFinish
    dDuration = CalculateWorkingHours(tempdStart,tempdFinish)

'    duration1 = CalculateWorkingHours(qStart,qFinish)
'    msgbox qStart & " " & qFinish & " " & duration1

    If dStart = "" Or IsDate(dStart) = False Then
     dStart = projectDateFormat(ThisApplication.CurrentTime)
'     dStart = ""
    Else
     dStart = projectDateFormat(dStart)
    End If
    ftConstraintDate = dStart
    If ftConstraintDate <> "" Then ftConstraintType = "5"
    If dFinish = "" Or IsDate(dFinish) = False Then
     dFinish = projectDateFormat(ThisApplication.CurrentTime)
'     dFinish = ""
    Else
     dFinish = projectDateFormat(dFinish)
    End If

' заполнение базовых дат
'Базовое начало
'(Плановое начало)   Дата начала работ по плану
'ATTR_STARTDATE_PLAN
'Базовое окончание 
'(Плановое окончание)    Дата окончания работ по плану
'ATTR_ENDDATE_PLAN

    blStart = oSheet.CellValue(qNumber,"Дата начала работ по плану")
    blFinish = oSheet.CellValue(qNumber,"Дата окончания работ по плану")
    tempblStart = blStart
    tempblFinish = blFinish
    blDuration = CalculateWorkingHours(tempblStart,tempblFinish)
    
    If blStart <> "" Or blFinish <> "" Then
     needBaseLineDates = True
     If IsDate(blStart) = True Then
      blStart = projectDateFormat(blStart)
     Else
      blStart = ""
     End If
     If IsDate(blFinish) = True Then
      blFinish = projectDateFormat(blFinish)
     Else
      blFinish = ""
     End If
    End If

'Начало 
'(Фактическое начало)    Дата начала работ по факту
'ATTR_STARTDATE_FACT
'Окончание 
'(Фактическое окончание)   Дата окончания работ по факту
'ATTR_ENDDATE_FACT

    fStart = oSheet.CellValue(qNumber,"Дата начала работ по факту")
    fFinish = oSheet.CellValue(qNumber,"Дата окончания работ по факту")
    tempfStart = fStart
    tempfFinish = fFinish
    fDuration = CalculateWorkingHours(tempfStart,tempfFinish)
    fillFasD = False
    If fStart <> "" And fFinish <> "" Then
     If IsDate(fStart) = True And IsDate(fStart) = True Then
      fStart = projectDateFormat(fStart)
      fFinish = projectDateFormat(fFinish)
     Else
      fillFasD = True
     End If
    Else
     fillFasD = True
    End If
    If fillFasD = True Then
     fStart = dStart
     fFinish = dFinish
     fDuration = dDuration
     If fStart = "" Then projectDateFormat(ThisApplication.CurrentTime)
     If fFinish = "" Then projectDateFormat(ThisApplication.CurrentTime)
     If fDuration = "" Then fDuration = "PT0H0M0S"
    End If





'Resources
    ShouldAddResource = False
    ShouldAddAssignment = False
    contractor_flag = oSheet.CellValue(qNumber,"Выполняется субподрядчиком")
    If contractor_flag = True Then
     contractor_group = "Подрядчик"
     contractor_name = oSheet.CellValue(qNumber,"Субподрядчик")
    Else
     contractor_group = oSheet.CellValue(qNumber,"Отдел")
     contractor_name = oSheet.CellValue(qNumber,"Ответственный")
    End If
    If contractor_name <> "" Then
     If Not executors_dict.Exists(contractor_group & "@#$%" & contractor_name) Then
      'нужно создавать ресурс
      ShouldAddResource = True
      'нужно создавать/дополнять сквозной счетчик ресурсов
      If Not executors_dict.Exists("LastContractorNumberr") Then executors_dict.add "LastContractorNumberr", 0
      executor_num = executors_dict.Item("LastContractorNumberr") + 1
      executors_dict.Item("LastContractorNumberr") = executor_num
      executors_dict.add contractor_group & "@#$%" & contractor_name, executor_num
     Else
      ' не нужно создавать ресурс, нужно его найти и взять его номер
      executor_num = executors_dict.Item(contractor_group & "@#$%" & contractor_name)
     End If
'assignments
     ShouldAddAssignment = True
     'порядковый номер назначения
     If Not executors_dict.Exists("AssignmentNumberr") Then executors_dict.add "AssignmentNumberr", 0
     assignment_num = executors_dict.Item("AssignmentNumberr") + 1
     executors_dict.Item("AssignmentNumberr") = assignment_num
    End If
   End If 



   'у конечны= Summary = 0, IsPublished = 1
   '1 ftUID,ftID,ftName,ftActive,ftManual,ftType,ftIsNull
   '2 ftCreateDate,ftWBS,ftOutlineNumber,ftOutlineLevel,ftPriority,ftStart,ftFinish,ftDuration
   '3 ftManualStart,ftManualFinish,ftManualDuration,ftDurationFormat,ftWork,ftResumeValid,ftEffortDriven,ftRecurring,_
   '3 ftOverAllocated,ftEstimated,ftMilestone,
   '4 ftSummary,ftDisplayAsSummary,ftCritical,ftIsSubproject,ftIsSubprojectReadOnly,ftExternalTask,ftEarlyStart,
   '4 ftEarlyFinish,ftLateStart,
   '5 ftLateFinish, ftStartVariance,ftFinishVariance,ftWorkVariance,ftFreeSlack,ftTotalSlack,ftStartSlack,_
   '5 ftFinishSlack,ftFixedCost,ftFixedCostAccrual,ftPercentComplete,ftPercentWorkComplete,ftCost,_
   '5 ftOvertimeCost,ftOvertimeWork,
   '6 ftActualDuration,ftActualCost,ftActualOvertimeCost,ftActualWork,ftActualOvertimeWork,ftRegularWork,
   '6 ftRemainingDuration,ftRemainingCost,ftRemainingWork,ftRemainingOvertimeCost,ftRemainingOvertimeWork,
   '7 ftACWP,ftCV,ftConstraintType,ftCalendarUID,ftConstraintDate,ftLevelAssignments,ftLevelingCanSplit,ftLevelingDelay,
   '7 ftLevelingDelayFormat,ftIgnoreResourceCalendar,ftHideBar,ftRollup,ftBCWS,ftBCWP,ftPhysicalPercentComplete,_
   '7 ftEarnedValueMethod,ftIsPublished,ftCommitmentType
   '8 custom_baseline Options
   '9 Resources 
   '10 assignments
'   Call FillTask(xmlProj,TaskRecord,commonTaskNum,commonTaskNum,cObj.Description,"1",IsManual,"0","0",_
   '2    "",treeNum,treeNum,currOutlineLevel,"500",dStart,dFinish,C"PT0H0M0S",_
   '3   dStart,dFinish,ManualDuration,"39","PT0H0M0S","0","0","0","0","1","0",_

   Call FillTask(xmlProj,TaskRecord,commonTaskNum,commonTaskNum,cObj.Description,"1",IsManual,"0","0",_
   "",treeNum,treeNum,currOutlineLevel,"500",fStart,fFinish,fDuration,_  
   fStart,fFinish,fDuration,"39","PT0H0M0S","0","0","0","0","1","0",_
   ShouldSummarise,"0","1","0","0","0","PT0H0M0S","PT0H0M0S","PT0H0M0S",_
   "PT0H0M0S","0","0","0.00","0","0","0","0","0","3","0","0","0","0","PT0H0M0S",_
   "PT0H0M0S","0","0","PT0H0M0S","PT0H0M0S","PT0H0M0S","PT0H0M0S","0","PT0H0M0S","0","PT0H0M0S",_
   "0.00","0.00",ftConstraintType,"-1",ftConstraintDate,"1","1","0","8","0","0","0","0.00","0.00","0","0","0","0",_
   needBaseLineDates,blStart,blFinish,blDuration,_
   ShouldAddResource,executor_num,contractor_name,contractor_group,_
   ShouldAddAssignment,assignment_num)
   
   
   If ShouldSummarise = 1 Then Call AddContentWithRecursion(xmlProj,TasksNode,cObj,oCol,oSheet,executors_dict,treeNum & ".",commonTaskNum,currOutlineLevel,pContSysName,pChildSysName)
  End If 
 Next
End Sub 

'Функция создания node в xml
'Возвращает созданный Node
'аргументы
'n_obj - Ссылка на DOM-объект XML
'n_type - тип узла
'n_name - имя создаваемого узла
'n_schema - схема XML
'Function CreateXMLNode(n_obj, n_type, n_name, n_schema)
 'Set CreateXMLNode = n_obj.createNode(n_type, n_name, n_schema)
'End Function

Function projectDateFormat(pDate)
 'условие для того чтобы можно было отловить в xml возможные проблемы с датой
 If IsDate(pDate) = True Then
  prM = Month(pDate)
  If Len(prM) = 1 Then prM = "0" & prM
  prDay = Day(pDate)
  If Len(prDay) = 1 Then prDay = "0" & prDay
  prH = Hour(pDate)
  If Len(prH) = 1 Then prH = "0" & prH
  prMin = Minute(pDate)
  If Len(prMin) = 1 Then prMin = "0" & prMin
  prSec = Second(pDate)
  If Len(prSec) = 1 Then prSec = "0" & prSec
  projectDateFormat = Year(pDate) & "-" & prM & "-" & prDay & "T" & prH & ":" & prMin & ":" & prSec
 Else
  projectDateFormat = "!Ошибка преобразования даты!" & pDate
 End If
End Function

Sub FillTask(xmlProj,TaskRecord,ftUID,ftID,ftName,ftActive,ftManual,ftType,ftIsNull,ftCreateDate,_
 ftWBS,ftOutlineNumber,ftOutlineLevel,ftPriority,ftStart,ftFinish,ftDuration,ftManualStart,_
 ftManualFinish,ftManualDuration,ftDurationFormat,ftWork,ftResumeValid,ftEffortDriven,ftRecurring,_
 ftOverAllocated,ftEstimated,ftMilestone,ftSummary,ftDisplayAsSummary,ftCritical,ftIsSubproject,_
 ftIsSubprojectReadOnly,ftExternalTask,ftEarlyStart,ftEarlyFinish,ftLateStart,ftLateFinish,_
 ftStartVariance,ftFinishVariance,ftWorkVariance,ftFreeSlack,ftTotalSlack,ftStartSlack,_
 ftFinishSlack,ftFixedCost,ftFixedCostAccrual,ftPercentComplete,ftPercentWorkComplete,ftCost,_
 ftOvertimeCost,ftOvertimeWork,ftActualDuration,ftActualCost,ftActualOvertimeCost,ftActualWork,_
 ftActualOvertimeWork,ftRegularWork,ftRemainingDuration,ftRemainingCost,ftRemainingWork,_
 ftRemainingOvertimeCost,ftRemainingOvertimeWork,ftACWP,ftCV,ftConstraintType,ftCalendarUID,ftConstraintDate,_
 ftLevelAssignments,ftLevelingCanSplit,ftLevelingDelay,ftLevelingDelayFormat,_
 ftIgnoreResourceCalendar,ftHideBar,ftRollup,ftBCWS,ftBCWP,ftPhysicalPercentComplete,_
 ftEarnedValueMethod,ftIsPublished,ftCommitmentType,_
 needBaseLineDates,blStart,blFinish,blDuration,_
 ShouldAddResource,resID,resName,resGroup,_
 ShouldAddAssignment,assID)
 
 '^вставить значения в массив и сделать цикл, чтобы сократить процедуру
 
Set TRecord = xmlProj.createNode(1,"UID","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftUID
Set TRecord = xmlProj.createNode(1,"ID","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftID
If ftUID <> "0" Then
 Set TRecord = xmlProj.createNode(1,"Name","http://schemas.microsoft.com/project")
 TaskRecord.appendChild(TRecord)
 TRecord.text = ftName
End If
Set TRecord = xmlProj.createNode(1,"Active","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftActive
Set TRecord = xmlProj.createNode(1,"Manual","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftManual
Set TRecord = xmlProj.createNode(1,"Type","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftType
Set TRecord = xmlProj.createNode(1,"IsNull","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftIsNull
Set TRecord = xmlProj.createNode(1,"CreateDate","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftCreateDate
Set TRecord = xmlProj.createNode(1,"WBS","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftWBS
Set TRecord = xmlProj.createNode(1,"OutlineNumber","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftOutlineNumber
Set TRecord = xmlProj.createNode(1,"OutlineLevel","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftOutlineLevel
Set TRecord = xmlProj.createNode(1,"Priority","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftPriority
Set TRecord = xmlProj.createNode(1,"Start","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftStart
Set TRecord = xmlProj.createNode(1,"Finish","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftFinish
Set TRecord = xmlProj.createNode(1,"Duration","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftDuration
Set TRecord = xmlProj.createNode(1,"ManualStart","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftManualStart
Set TRecord = xmlProj.createNode(1,"ManualFinish","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftManualFinish
Set TRecord = xmlProj.createNode(1,"ManualDuration","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftManualDuration
Set TRecord = xmlProj.createNode(1,"DurationFormat","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftDurationFormat
Set TRecord = xmlProj.createNode(1,"Work","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftWork
Set TRecord = xmlProj.createNode(1,"ResumeValid","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftResumeValid
Set TRecord = xmlProj.createNode(1,"EffortDriven","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftEffortDriven
Set TRecord = xmlProj.createNode(1,"Recurring","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftRecurring
Set TRecord = xmlProj.createNode(1,"OverAllocated","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftOverAllocated
Set TRecord = xmlProj.createNode(1,"Estimated","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftEstimated
Set TRecord = xmlProj.createNode(1,"Milestone","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftMilestone
Set TRecord = xmlProj.createNode(1,"Summary","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftSummary
Set TRecord = xmlProj.createNode(1,"DisplayAsSummary","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftDisplayAsSummary
Set TRecord = xmlProj.createNode(1,"Critical","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftCritical
Set TRecord = xmlProj.createNode(1,"IsSubproject","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftIsSubproject
Set TRecord = xmlProj.createNode(1,"IsSubprojectReadOnly","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftIsSubprojectReadOnly
Set TRecord = xmlProj.createNode(1,"ExternalTask","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftExternalTask
Set TRecord = xmlProj.createNode(1,"EarlyStart","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftEarlyStart
Set TRecord = xmlProj.createNode(1,"EarlyFinish","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftEarlyFinish
Set TRecord = xmlProj.createNode(1,"LateStart","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftLateStart
Set TRecord = xmlProj.createNode(1,"LateFinish","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftLateFinish
Set TRecord = xmlProj.createNode(1,"StartVariance","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftStartVariance
Set TRecord = xmlProj.createNode(1,"FinishVariance","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftFinishVariance
Set TRecord = xmlProj.createNode(1,"WorkVariance","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftWorkVariance
Set TRecord = xmlProj.createNode(1,"FreeSlack","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftFreeSlack
Set TRecord = xmlProj.createNode(1,"TotalSlack","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftTotalSlack
Set TRecord = xmlProj.createNode(1,"StartSlack","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftStartSlack
Set TRecord = xmlProj.createNode(1,"FinishSlack","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftFinishSlack
Set TRecord = xmlProj.createNode(1,"FixedCost","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftFixedCost
Set TRecord = xmlProj.createNode(1,"FixedCostAccrual","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftFixedCostAccrual
Set TRecord = xmlProj.createNode(1,"PercentComplete","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftPercentComplete
Set TRecord = xmlProj.createNode(1,"PercentWorkComplete","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftPercentWorkComplete
Set TRecord = xmlProj.createNode(1,"Cost","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftCost
Set TRecord = xmlProj.createNode(1,"OvertimeCost","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftOvertimeCost
Set TRecord = xmlProj.createNode(1,"OvertimeWork","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftOvertimeWork
Set TRecord = xmlProj.createNode(1,"ActualDuration","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftActualDuration
Set TRecord = xmlProj.createNode(1,"ActualCost","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftActualCost
Set TRecord = xmlProj.createNode(1,"ActualOvertimeCost","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftActualOvertimeCost
Set TRecord = xmlProj.createNode(1,"ActualWork","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftActualWork
Set TRecord = xmlProj.createNode(1,"ActualOvertimeWork","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftActualOvertimeWork
Set TRecord = xmlProj.createNode(1,"RegularWork","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftRegularWork
Set TRecord = xmlProj.createNode(1,"RemainingDuration","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftRemainingDuration
Set TRecord = xmlProj.createNode(1,"RemainingCost","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftRemainingCost
Set TRecord = xmlProj.createNode(1,"RemainingWork","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftRemainingWork
Set TRecord = xmlProj.createNode(1,"RemainingOvertimeCost","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftRemainingOvertimeCost
Set TRecord = xmlProj.createNode(1,"RemainingOvertimeWork","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftRemainingOvertimeWork
Set TRecord = xmlProj.createNode(1,"ACWP","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftACWP
Set TRecord = xmlProj.createNode(1,"CV","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftCV
Set TRecord = xmlProj.createNode(1,"ConstraintType","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftConstraintType
Set TRecord = xmlProj.createNode(1,"CalendarUID","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftCalendarUID
Set TRecord = xmlProj.createNode(1,"ConstraintDate","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftConstraintDate
Set TRecord = xmlProj.createNode(1,"LevelAssignments","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftLevelAssignments
Set TRecord = xmlProj.createNode(1,"LevelingCanSplit","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftLevelingCanSplit
Set TRecord = xmlProj.createNode(1,"LevelingDelay","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftLevelingDelay
Set TRecord = xmlProj.createNode(1,"LevelingDelayFormat","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftLevelingDelayFormat
Set TRecord = xmlProj.createNode(1,"IgnoreResourceCalendar","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftIgnoreResourceCalendar
Set TRecord = xmlProj.createNode(1,"HideBar","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftHideBar
Set TRecord = xmlProj.createNode(1,"Rollup","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftRollup
Set TRecord = xmlProj.createNode(1,"BCWS","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftBCWS
Set TRecord = xmlProj.createNode(1,"BCWP","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftBCWP
Set TRecord = xmlProj.createNode(1,"PhysicalPercentComplete","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftPhysicalPercentComplete
Set TRecord = xmlProj.createNode(1,"EarnedValueMethod","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftEarnedValueMethod
Set TRecord = xmlProj.createNode(1,"IsPublished","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftIsPublished
Set TRecord = xmlProj.createNode(1,"CommitmentType","http://schemas.microsoft.com/project")
TaskRecord.appendChild(TRecord)
TRecord.text = ftCommitmentType
'baseline
If needBaseLineDates = True Then
 Set BLRecord = xmlProj.createNode(1,"Baseline","http://schemas.microsoft.com/project")
 TaskRecord.appendChild(BLRecord)
 Set TRecord = xmlProj.createNode(1,"Number","http://schemas.microsoft.com/project")
 BLRecord.appendChild(TRecord)
 TRecord.text = "0"
 Set TRecord = xmlProj.createNode(1,"Start","http://schemas.microsoft.com/project")
 BLRecord.appendChild(TRecord)
 TRecord.text = blStart
 Set TRecord = xmlProj.createNode(1,"Finish","http://schemas.microsoft.com/project")
 BLRecord.appendChild(TRecord)
 TRecord.text = blFinish
 Set TRecord = xmlProj.createNode(1,"Duration","http://schemas.microsoft.com/project")
 BLRecord.appendChild(TRecord)
 TRecord.text = blDuration
End If

'Resource 
 If ShouldAddResource = True Then
  Set ResourcesNode = xmlproj.SelectSingleNode("/*[local-name()='Project']/*[local-name()='Resources']")
  Set ResourceRecord = xmlProj.createNode(1,"Resource","http://schemas.microsoft.com/project")
  ResourcesNode.appendChild(ResourceRecord) 
  Set TRecord = xmlProj.createNode(1,"UID","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = resID
  Set TRecord = xmlProj.createNode(1,"ID","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = resID
  Set TRecord = xmlProj.createNode(1,"Name","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = resName
  Set TRecord = xmlProj.createNode(1,"Type","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "1"
  Set TRecord = xmlProj.createNode(1,"IsNull","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"Initials","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"Group","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = resGroup
  Set TRecord = xmlProj.createNode(1,"WorkGroup","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"MaxUnits","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "1.00"
  Set TRecord = xmlProj.createNode(1,"PeakUnits","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0.00"
  Set TRecord = xmlProj.createNode(1,"OverAllocated","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"CanLevel","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "1"
  Set TRecord = xmlProj.createNode(1,"AccrueAt","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "3"
  Set TRecord = xmlProj.createNode(1,"Work","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "PT0H0M0S"
  Set TRecord = xmlProj.createNode(1,"RegularWork","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "PT0H0M0S"
  Set TRecord = xmlProj.createNode(1,"OvertimeWork","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "PT0H0M0S"
  Set TRecord = xmlProj.createNode(1,"ActualWork","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "PT0H0M0S"
  Set TRecord = xmlProj.createNode(1,"RemainingWork","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "PT0H0M0S"
  Set TRecord = xmlProj.createNode(1,"ActualOvertimeWork","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "PT0H0M0S"
  Set TRecord = xmlProj.createNode(1,"RemainingOvertimeWork","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "PT0H0M0S"
  Set TRecord = xmlProj.createNode(1,"PercentWorkComplete","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"StandardRate","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"StandardRateFormat","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "2"
  Set TRecord = xmlProj.createNode(1,"Cost","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"OvertimeRate","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"OvertimeRateFormat","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "2"
  Set TRecord = xmlProj.createNode(1,"OvertimeCost","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"CostPerUse","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"ActualCost","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"ActualOvertimeCost","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"RemainingCost","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"RemainingOvertimeCost","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"WorkVariance","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0.00"
  Set TRecord = xmlProj.createNode(1,"CostVariance","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"SV","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0.00"
  Set TRecord = xmlProj.createNode(1,"CV","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0.00"
  Set TRecord = xmlProj.createNode(1,"ACWP","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0.00"
  Set TRecord = xmlProj.createNode(1,"CalendarUID","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "4"
  Set TRecord = xmlProj.createNode(1,"BCWS","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0.00"
  Set TRecord = xmlProj.createNode(1,"BCWP","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0.00"
  Set TRecord = xmlProj.createNode(1,"IsGeneric","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"IsInactive","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"IsEnterprise","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"BookingType","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"CreationDate","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = projectDateFormat(ThisApplication.CurrentTime)
  Set TRecord = xmlProj.createNode(1,"IsCostResource","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"IsBudget","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
 End If
 'assignment 
 If ShouldAddAssignment = True Then
  Set ResourcesNode = xmlproj.SelectSingleNode("/*[local-name()='Project']/*[local-name()='Assignments']")
  Set ResourceRecord = xmlProj.createNode(1,"Assignment","http://schemas.microsoft.com/project")
  ResourcesNode.appendChild(ResourceRecord)
  Set TRecord = xmlProj.createNode(1,"UID","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = assID
   Set TRecord = xmlProj.createNode(1,"TaskUID","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = ftUID
  Set TRecord = xmlProj.createNode(1,"ResourceUID","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = resID
  Set TRecord = xmlProj.createNode(1,"PercentWorkComplete","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"ActualCost","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"ActualOvertimeCost","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"ActualOvertimeWork","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "PT0H0M0S"
  Set TRecord = xmlProj.createNode(1,"ActualWork","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
'dura change
  TRecord.text = "PT0H0M0S"
  Set TRecord = xmlProj.createNode(1,"ACWP","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0.00"
  Set TRecord = xmlProj.createNode(1,"Confirmed","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"Cost","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"CostRateTable","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"  
  Set TRecord = xmlProj.createNode(1,"RateScale","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"  
  Set TRecord = xmlProj.createNode(1,"CostVariance","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"  
  Set TRecord = xmlProj.createNode(1,"CV","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0.00"  
  Set TRecord = xmlProj.createNode(1,"Delay","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"  
  Set TRecord = xmlProj.createNode(1,"Finish","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = ftFinish  
  Set TRecord = xmlProj.createNode(1,"FinishVariance","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"
  Set TRecord = xmlProj.createNode(1,"WorkVariance","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0"  
  Set TRecord = xmlProj.createNode(1,"HasFixedRateUnits","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "1"  
  Set TRecord = xmlProj.createNode(1,"FixedMaterial","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0" 
  Set TRecord = xmlProj.createNode(1,"LevelingDelay","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0" 
  Set TRecord = xmlProj.createNode(1,"LevelingDelayFormat","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "7" 
  Set TRecord = xmlProj.createNode(1,"LinkedFields","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0" 
  Set TRecord = xmlProj.createNode(1,"Milestone","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0" 
  Set TRecord = xmlProj.createNode(1,"Overallocated","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0" 
  Set TRecord = xmlProj.createNode(1,"OvertimeCost","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0" 
  Set TRecord = xmlProj.createNode(1,"OvertimeWork","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "PT0H0M0S" 
'      <RegularWork>PT161H0M0S</RegularWork>
  Set TRecord = xmlProj.createNode(1,"RegularWork","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "PT0H0M0S" 
  Set TRecord = xmlProj.createNode(1,"RemainingCost","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0" 
  Set TRecord = xmlProj.createNode(1,"RemainingOvertimeCost","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0" 
  Set TRecord = xmlProj.createNode(1,"RemainingOvertimeWork","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "PT0H0M0S" 
'      <RemainingWork>PT161H0M0S</RemainingWork>     
  Set TRecord = xmlProj.createNode(1,"RemainingWork","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
'dura change
  TRecord.text = ftDuration
  Set TRecord = xmlProj.createNode(1,"ResponsePending","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0" 
  Set TRecord = xmlProj.createNode(1,"Start","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = ftStart 
  Set TRecord = xmlProj.createNode(1,"StartVariance","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0" 
  Set TRecord = xmlProj.createNode(1,"Units","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "1" 
  Set TRecord = xmlProj.createNode(1,"UpdateNeeded","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0" 
  Set TRecord = xmlProj.createNode(1,"VAC","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0.00" 
'      <Work>PT161H0M0S</Work>      
  Set TRecord = xmlProj.createNode(1,"Work","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
'dura change
  TRecord.text = ftDuration
  Set TRecord = xmlProj.createNode(1,"WorkContour","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0" 
  Set TRecord = xmlProj.createNode(1,"BCWS","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0.00" 
  Set TRecord = xmlProj.createNode(1,"BCWP","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0.00" 
  Set TRecord = xmlProj.createNode(1,"BookingType","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0" 
  Set TRecord = xmlProj.createNode(1,"CreationDate","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = projectDateFormat(ThisApplication.CurrentTime)
  Set TRecord = xmlProj.createNode(1,"BudgetCost","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "0" 
  Set TRecord = xmlProj.createNode(1,"BudgetWork","http://schemas.microsoft.com/project")
  ResourceRecord.appendChild(TRecord)
  TRecord.text = "PT0H0M0S"
 End If
End Sub

'принимается, что если часы не заданы, то в день начала отрабатывается 8 часов и в день окончания 8 часов
'принимается, что рабочий день с 9 до 18 с часовым перерывом на обед с 13 до 14
Function CalculateWorkingHours(dateStart,dateFinish)
'задача - расчет длительности между двумя датами с учетом календаря
'кейс1: дата начала старше (>) даты окончания - возвращается 0, выход из ф-ии
'кейс2: период полностью попадает на выходной - перенос дат не делается, т.к. они - входной неизменный параметр
' считается как есть 
'кейс3: все остальные случаи - подсчет длительности с учетом выходных (уменьшением длительности на выходные)
 calculatedHours = "0"
 calculatedMinutes = "0"
 calculatedSeconds = "0"
 If IsDate(dateStart) = True And IsDate(dateFinish) = True Then
  dateStart = CDate(dateStart)
  dateFinish = CDate(dateFinish)
  If dateStart <= dateFinish Then
   If Hour(dateStart) = Hour(dateFinish) Then
   'приведение часов к календарю
   'если кол-во часов даты начала = 0 или меньше 9:00, кол-во часов даты начала = 9:00 
   'если кол-во часов даты окончания = 0 или больше 18:00, кол-во часов даты окончания = 18:00 
    If Hour(dateStart) < 9 Then 
     dateStart = DateValue(dateStart) & " 09:00:00"
    ElseIf Hour(dateStart) >= 18 Then
     dateStart = DateValue(dateStart) & " 09:00:00"
    End If
    If Hour(dateFinish) <= 9 Then 
     dateFinish = DateValue(dateFinish) & " 18:00:00"
    ElseIf Hour(dateFinish) >= 18 Then
     dateFinish = DateValue(dateFinish) & " 18:00:00"
    End If
    'определяем нужно ли делать проверку на необходимость сдвижки дат в связи с попаданием одной из дат на выходной 
    calculatedDays = datediff("d",dateStart,dateFinish,"2","1")
    DefineMoveDays = False
    If calculatedDays > 1 Then
     DefineMoveDays = True
    ElseIf calculatedDays = 1 Then
     If Weekday(dateStart,"2") <> 6 And Weekday(dateFinish,"2") <> 7 Then DefineMoveDays = True
    End IF
    
    If DefineMoveDays = True Then
     'сдвижка дат начала и окончания если они выпадают на выходные
     'начало двигается вперед, окончание назад
     bWorkingDay = Weekday(dateStart,"2")
     If bWorkingDay = 6 Or bWorkingDay = 7 Then 
      dateStart = DateAdd("d",8-bWorkingDay,dateStart)
      dateStart = DateValue(dateStart) & " 09:00:00"
     End If
     bWorkingDay = Weekday(dateFinish,"2")
     If bWorkingDay = 6 Or bWorkingDay = 7 Then
      If bWorkingDay = 6 Then
       dateFinish = DateAdd("d",bWorkingDay-7,dateFinish)
      ElseIf bWorkingDay = 7 Then
       dateFinish = DateAdd("d",bWorkingDay-9,dateFinish)
      End If
      dateFinish = DateValue(dateFinish) & " 18:00:00"
     End If
     calculatedDays = datediff("d",dateStart,dateFinish,"2","1")
    End If

   'расчет часов исходя из кейсов:
   '1. Разница между датой начала в часах и датой окончания в часах = 0, тогда длительность рассчит в минутах/секундах
   '2. Разница до двух часов, в этом случае она закладывается вся без вычета обеденного времени и минут/секунд(этот кейс пропускается в IF и идет by default)
   '3. Разница больше двух часов, но меньше 9 в пределах одного дня. Вычисляется необходимость вычета обеденного времени
   '4. Разница больше одного дня, тогда в первый день нужно вычесть обеденное время, и в последний день
   'остальные дни будут просто умножаться на 8 за вычетом выходных, расчет которых будет дальше
    calculatedHours = datediff("h",dateStart,dateFinish,"2","1")
    If calculatedHours = 0 Then
     calculatedMinutes = datediff("n",dateStart,dateFinish,"2","1")
     If calculatedMinutes = 0 Then
      calculatedSeconds = datediff("s",dateStart,dateFinish,"2","1")
     End If
    ElseIf calculatedHours >= 2 And calculatedHours <= 9 Then
     If calculatedHours + Hour(dateStart) > 13 And Hour(dateStart) <=13 Then
      calculatedHours = calculatedHours - 1
     End If
    ElseIf calculatedHours > 9 Then
     'посчитать разницу между первым днем старта и первым днем финиша в часах
     'посчитать кол-во дней, возможно что-то прибавить из предудущего пункта
     'выделить кратность к 7, вычесть выходные 
     calculatedHours = 9 - Hour(dateStart) + Hour(dateFinish)
     If Hour(dateStart) < 14 Then calculatedHours = calculatedHours - 1
     If Hour(dateFinish) > 13 Then calculatedHours = calculatedHours - 1
     calculatedDays = calculatedDays - 1

     FullWeeksCount = Fix(calculatedDays/7)
     If FullWeeksCount = 0 Then
     'определяем необходимость вычета выходных в случае если число дней меньше 7
      If DefineMoveDays = True Then
       If Weekday(dateStart,"2") - Weekday(dateFinish,"2") >= 0 Then
        calculatedDays = calculatedDays - 2
       ElseIf Weekday(dateFinish,"2") = 7 Or Weekday(dateFinish,"2") = 6 Then
        calculatedDays = calculatedDays - Weekday(dateFinish,"2") + 5
       End If
      End If     
     Else
      calculatedDays = ((calculatedDays-6+Weekday(dateStart,"2")-Weekday(dateFinish,"2"))/7)*5+4-Weekday(dateStart,"2")+Weekday(dateFinish,"2")
     End If
    End If
    calculatedHours = calculatedHours + calculatedDays*8 'datediff("d",dateStart,dateFinish,"2","1")*8
   End If
  End If
 End If
 CalculateWorkingHours = "PT" & calculatedHours & "H" & calculatedMinutes & "M" & calculatedSeconds & "S"
End Function
