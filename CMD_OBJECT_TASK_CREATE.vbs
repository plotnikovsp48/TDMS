
Call CreateTask(ThisObject)

Sub CreateTask (p_)
'  ThisApplication.AddNotify "CreateTask " & Time
  ThisScript.SysAdminModeOn
  
  chk =ThisApplication.ExecuteScript ("CMD_PROJECT_DOCS_LIBRARY","DocCreatePermissionsCheck",Nothing,p_)
  
  If chk = False Then
    Cancel = True
    Exit Sub
  End If
  
  sName = p_.StatusName
  If sName = "STATUS_S_INVALIDATED" Then
    msgbox "Невозможно создать задание, т.к. " & p_.Description & " в статусе " & p_.Status.Description & ".",vbCritical,"Создание задания"
    Exit Sub
  End If
  
  Set CU = ThisApplication.CurrentUser
  
  If CU.Attributes("ATTR_KD_USER_DEPT").Empty = True Then
    msgbox "Вы не можете создать задание, т.к. не задан отдел",vbCritical,"Создать задание"
    Exit Sub
  End If
  
  Set ObjRoot = ThisApplication.ExecuteScript("OBJECT_T_TASK","GetTaskFolder",p_)
  
  If ObjRoot Is Nothing Then 
    msgbox "Невозможно создать задание, т.к. не найдена папка для заданий",vbCritical,"Создать задание"
    Exit Sub
  End If
  
  'Создаем объект
  Set NewObj = ObjRoot.Objects.Create("OBJECT_T_TASK")
  Call setLink(p_,NewObj)
  NewObj.SaveChanges(0)
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = NewObj
'  ThisApplication.AddNotify "CreateTask (end) " & Time
  RetVal = Dlg.Show
  
  If NewObj.Status.SysName = NewObj.ObjectDef.InitialStatus.SysName Then
    If Not RetVal Then
      Set rObjs = NewObj.ReferencedBy
      If Not rObjs Is Nothing Then
        For each rObj In rObjs
          rObj.Permissions = SysadminPermissions
          rObj.Erase
        Next
      End If
      On error resume next
      NewObj.Erase
      If err <>0 Then err.clear
      Exit Sub
    End If
  End If
  
End Sub

' Устанавливает связь со стартовым объектом
Sub setLink(StartObj,Obj)
  ThisScript.SysAdminModeOn
  ThisApplication.DebugPrint "setLink" & Time
  If Obj Is Nothing Then exit Sub
  If StartObj Is Nothing Then exit Sub
  
  oDefName = StartObj.ObjectDefName
  Select Case oDefName
    Case "OBJECT_T_TASK"
      Set Dept_Return = StartObj.Attributes("ATTR_T_TASK_DEPARTMENT").Object
      
      ' Таблица получателей
      Set User = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetChiefByDept",Dept_Return)
      Call ThisApplication.ExecuteScript("FORM_S_TASK","Add_Reciever",Obj,User)
      
      ' Таблица связей с заданием
      ' На новом задании
      Set TableRows = Obj.Attributes("ATTR_T_TASK_LINKED").Rows
      Call ThisApplication.ExecuteScript("FORM_PROJECT_PARTS_LINKED","Add_Task_Link",TableRows,StartObj)
      
      ' на исходном задании
      Set TableRows = StartObj.Attributes("ATTR_T_TASK_LINKED").Rows
      Call ThisApplication.ExecuteScript("FORM_PROJECT_PARTS_LINKED","Add_Task_Link",TableRows,Obj)
      
      ' Копируем связи с частями проектов, этапом, объектом проектирования
      attrList = "ATTR_T_TASK_PPLINKED,ATTR_UNIT,ATTR_CONTRACT_STAGE"
      Call ThisApplication.ExecuteScript("CMD_DLL","AttrsSyncBetweenObjs",StartObj,Obj,attrList)
    Case "OBJECT_UNIT"
      Obj.Attributes("ATTR_UNIT").Object = StartObj
    Case "OBJECT_PROJECT_SECTION","OBJECT_PROJECT_SECTION_SUBSECTION"
      Call SetProjectPartLink (Obj,StartObj)
        
        Set stage = StartObj.Attributes("ATTR_CONTRACT_STAGE").Object
        If Not Stage Is Nothing Then
          Obj.Attributes("ATTR_CONTRACT_STAGE") = Stage
        End If
    Case "OBJECT_WORK_DOCS_SET"
      Call SetProjectPartLink (Obj,StartObj)

        Set BuildStage = StartObj.Attributes("ATTR_BUILDING_STAGE").Object
        If Not BuildStage Is Nothing Then
          Set Stage = BuildStage.Attributes("ATTR_CONTRACT_STAGE").Object
          Obj.Attributes("ATTR_CONTRACT_STAGE") = Stage
        End If
    Case Else
      Exit Sub
  End Select
End Sub

Sub SetProjectPartLink (Obj,docBase)
  Obj.Permissions = SysAdminPermissions
  If Obj Is Nothing or docBase Is Nothing Then Exit Sub
  oDefName = docBase.ObjectDefName
  If Obj.Attributes.Has("ATTR_T_TASK_PPLINKED") = False Then Exit Sub
  
  Set Table = Obj.Attributes("ATTR_T_TASK_PPLINKED")
  Set NewRow = Table.Rows.Create
  NewRow.Attributes("ATTR_T_LINKEDOBJECT").Object = docBase
  NewRow.Attributes("ATTR_OBJECT_TYPE") = ThisApplication.ObjectDefs(oDefName).Description

End Sub
