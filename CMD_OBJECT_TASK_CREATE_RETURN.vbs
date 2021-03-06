

'Call ThisApplication.ExecuteScript("CMD_OBJECT_TASK_CREATE","CreateTask",ThisObject)

Call CreateTask(ThisObject)

Function CreateTask (docObj)
  Set CreateTask = Nothing
  ThisApplication.DebugPrint "CreateTask" & Time
  ThisScript.SysAdminModeOn
  Set ObjRoot = ThisApplication.ExecuteScript("OBJECT_T_TASK","GetTaskFolder",docObj)
  
  If ObjRoot Is Nothing Then 
    msgbox "Невозможно создать задание",vbCritical,"Создать задание"
    Exit Function
  End If
  
  'Создаем объект
  Set NewObj = ObjRoot.Objects.Create("OBJECT_T_TASK")
  Call setLink(docObj,NewObj)
  NewObj.SaveChanges(0)
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = NewObj
  RetVal = Dlg.Show
  If NewObj.Status.SysName = NewObj.ObjectDef.InitialStatus.SysName Then
    If Not RetVal Then
      ThisApplication.Utility.WaitCursor = True
      Set rObjs = NewObj.ReferencedBy
      If Not rObjs Is Nothing Then
        For each rObj In rObjs
          rObj.Permissions = SysadminPermissions
          rObj.Erase
        Next
      End If
      NewObj.Erase
      Exit Function
      ThisApplication.Utility.WaitCursor = False
    End If
  End If
  Set CreateTask = NewObj
End Function

'===================================================================
' Устанавливает связь со стартовым объектом
'-------------------------------------------------------------------
' StartObj: TDMSObject - объект, с которого выполняется команда
' Obj: TDMSObject - Ответное задание
'===================================================================
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
    Case Else
      Exit Sub
  End Select
End Sub

