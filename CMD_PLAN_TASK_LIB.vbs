USE "CMD_DLL"

' Создание плановой задачи
Function Create_Plan_Task(BaseObj)
  Set Create_Plan_Task = Nothing
  ptType = 0
  If BaseObj Is Nothing Then
    Set dlg = ThisApplication.Dialogs.SelectClassifierDlg
    dlg.Root = ThisApplication.Classifiers("NODE_PLAN_TASK_TYPE")
    dlg.Caption = "Выберите тип задачи"
    
    RetVal = dlg.Show
    If (RetVal<>TRUE) Then Exit Function

    Set cls = dlg.Classifier
    If IsNumeric(cls.code) Then
      ptType = CInt(cls.code)
    End If
  End If

  Set Create_Plan_Task = Create_Plan_Task_By_Type(BaseObj,ptType)
End Function

'======================================================================================
' Создание плановой задачи по типу
Function Create_Plan_Task_By_Type(BaseObj,ptType)
  Set Create_Plan_Task_By_Type = Nothing

  ObjDefName = "OBJECT_P_TASK"
  If Not BaseObj Is Nothing Then
    Set ObjRoots = GetObjectRoot(ObjDefName)
    ptType = 0
  Else
    If ptType <> 1 And ptType <> 2 Then 
      msgbox "Неверный тип задачи, будет установлен тип Общепроизводственная задача",vbExclamation,"Плановая задача"
      ptType = 1
    End If
    Set ObjRoots = GetCommonPtRoot()
  End If
  If ObjRoots Is Nothing Then Exit Function
  ObjRoots.Permissions = SysAdminPermissions
  ptName = vbNullString
  
  ' Если без связанного объекта - запрашиваем наименование задачи
  If BaseObj Is Nothing Then
    Set dlg = ThisApplication.Dialogs.SimpleEditDlg
    dlg.Prompt = "Введите наименование задачи"
    dlg.Caption = "Новая задача"
    
    RetVal = dlg.Show
    If (RetVAl <> True) or trim(dlg.Text) = "" Then Exit Function
    ptName = dlg.Text
  End If
  
  'Создаем объект
  Set NewObj = ObjRoots.Objects.Create(ObjDefName)
  NewObj.Attributes("ATTR_OBJECT").Object = BaseObj
  NewObj.Attributes("ATTR_PLAN_TASK_TYPE") = ptType
  NewObj.Attributes("ATTR_TOPLATAN") = True
  If ptName <> vbNullString Then
    NewObj.Attributes("ATTR_P_TASK_NAME") = ptName
    NewObj.Attributes("ATTR_P_TASK_CODE") = ptName
  End If
  
  Set Create_Plan_Task_By_Type = NewObj
End Function

'======================================================================================
' Папка для общепроизводственных задач
Function GetCommonPtRoot()
  Set GetCommonPtRoot = Nothing
  If ThisApplication.Attributes.Has("ATTR_FOLDER_OBJECT_P_TASK_COMMON") = False Then
    ThisApplication.Attributes.Create("ATTR_FOLDER_OBJECT_P_TASK_COMMON")
    Set root = FindPtFolder()
    
    If Not root Is Nothing Then _
      ThisApplication.Attributes("ATTR_FOLDER_OBJECT_P_TASK_COMMON") = root.guid
  End If
    
  oGuid = ThisApplication.Attributes("ATTR_FOLDER_OBJECT_P_TASK_COMMON")
  Set ObjRoots = ThisApplication.GetObjectByGUID(oGuid)
  if  ObjRoots is nothing then  
    Set ObjRoots = FindPtFolder()
    If ObjRoots Is Nothing Then
      msgBox "Не удалось создать папку", vbCritical, "Объект не был создан"
      exit Function
    End If
  end if
  Set GetCommonPtRoot = ObjRoots
End Function

'======================================================================================
' Поиск папки по наименованию, если другими способами не удалось найти
Function FindPtFolder()
  Set FindPtFolder = Nothing
  Set f = ThisApplication.GetObjectByGUID(ThisApplication.Attributes("ATTR_FOLDER_OBJECT_P_TASK"))
  For each folder in f.Objects
    If folder.Attributes("ATTR_FOLDER_NAME").Value = "Общепроизводственные" Then
      Set FindPtFolder = folder
      Exit Function
    End If
  Next
End Function

'======================================================================================
' Создает копию задачи, если основная задача была закрыта, с признаком Доработка
Function CopyPt(Obj)
  Set CopyPt = Nothing
  If Obj.IsKindOf("OBJECT_P_TASK") = False Then Exit Function
  Set ObjRoots = GetObjectRoot("OBJECT_P_TASK")
  If ObjRoots Is Nothing Then Exit Function
  ObjRoots.Permissions = SysAdminPermissions
  Set NewObj = Obj.Duplicate(ObjRoots)
  Call Set_PLAN_TASK_WORK_TYPE(NewObj,"Доработка")
  ThisObject.Status = ThisObject.ObjectDef.InitialStatus
End Function

'======================================================================================
' Установка признака Вид работы для плановой задачи
Sub Set_PLAN_TASK_WORK_TYPE(Obj,wType)
  Set cls = ThisApplication.Classifiers("NODE_PLAN_TASK_WORK_TYPE").Classifiers.Find(wType)
  If cls Is Nothing Then Exit Sub
    If Obj.Attributes.Has("ATTR_PLAN_TASK_WORK_TYPE") = False Then _
      Obj.Attributes.Create("ATTR_PLAN_TASK_WORK_TYPE")
    
    Obj.Attributes("ATTR_PLAN_TASK_WORK_TYPE").Classifier = cls
End Sub

' Обновляет параметры плановой задачи
Sub UpdatePlanTask(Obj)
  If Obj Is Nothing Then Exit Sub
  Set oPlanTask = GetPlanTaskLink(Obj)
  If oPlanTask Is Nothing Then Exit Sub
  Call ThisApplication.ExecuteScript("OBJECT_P_TASK","SetTaskAttrs",oPlanTask)
End Sub

Function GetPlanTaskLink(Obj)
  ThisApplication.DebugPrint "GetPlanTaskLink " & Time
  Set GetPlanTaskLink = Nothing
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_P_TASK"
  q.AddCondition tdmQueryConditionAttribute, Obj, "ATTR_OBJECT"
  'Set Objects = q.Objects
  set o = Nothing
  on error resume next
  Set o = q.Objects(0)
  on error goto 0
  
  If o is nothing Then Exit Function
  Set GetPlanTaskLink = o
  
'  If Objects.Count > 0 Then
'    Set GetPlanTaskLink = Objects(0)
'  End If
ThisApplication.DebugPrint "GetPlanTaskLink (end) " & Time
End Function


Sub ClosePlanTask(Obj)
  If Obj Is Nothing Then Exit Sub
  Set oPT = GetPlanTaskLink(Obj)
  If oPT Is Nothing Then Exit Sub
  If oPT.StatusName = "STATUS_P_TASK_FINISHED" Then Exit Sub
  oPT.Permissions = sysadminpermissions
  oPT.Attributes("ATTR_ENDDATE_FACT") = Obj.StatusModifyTime
  oPT.Status = ThisApplication.Statuses("STATUS_P_TASK_FINISHED") 
End Sub