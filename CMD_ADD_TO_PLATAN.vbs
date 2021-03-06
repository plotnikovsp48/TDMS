

ThisScript.SysAdminModeOn

Call Main (ThisObject)

Sub Main (o_)
  ' Создаём плановую задачу
  Set oNew = ObjToPLATAN (o_)
    
  if oNew Is Nothing Then Exit Sub
  
  'Устанавливаем ссылку плановой задачи на объект
  attr="ATTR_OBJECT"
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetAttr", oNew,attr,o_)
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetAttr", oNew,"ATTR_TOPLATAN",True)
End Sub

' Создание плановой задачи
Function ObjToPLATAN(o_)
  Set ObjToPLATAN = Nothing
  ObjDefName = "OBJECT_P_TASK"
  Set ObjRoots = thisApplication.ExecuteScript("CMD_KD_FOLDER","GET_FOLDER","",thisApplication.ObjectDefs(ObjDefName))
  if  ObjRoots is nothing then  
    msgBox "Не удалось создать папку", vbCritical, "Объект не был создан"
    exit Function
  end if
  ObjRoots.Permissions = SysAdminPermissions
    
  'Создаем объект
  Set NewObj = ObjRoots.Objects.Create(ObjDefName)

  Set ObjToPLATAN = NewObj
End Function

' Функция возвращает незакрытый коментарий текущего пользователя
Function GetObjectTask (Obj)
  Set GetObjectTask = Nothing ' Возвращает Nothing если коментария несуществует
  Set oTasks = Obj.ReferencedBy.ObjectsByDef("OBJECT_P_TASK")
  
  If oTasks.count>0 Then
    Set GetObjectTask = oTasks(0)
  End If
End Function

' returns True if this command should present in object's context menu
Public Function EnableCommand(obj)
  thisApplication.DebugPrint "EnableCommand " & Time()
  EnableCommand = False
  
  ' check system attribute
  If Not EnabledForDef(obj.ObjectDef) Then Exit Function
  ' lookup referenced task
  ' Изменено для увеличения быстродействия системы 17.10.2017 Стромков С.А.
  Set q = ThisApplication.Queries("QUERY_P_TASK_FOR_OBJECT")
  q.parameter("PARAM0") = Obj

  on error resume next
  Set oPT = q.Objects(0)
  If oPT is nothing Then 
    EnableCommand = True
    Exit Function
  End If

  '  EnableCommand = obj.ReferencedBy.ObjectsByDef("OBJECT_P_TASK").Count = 0
End Function

' helper, returns True if input objectDef is listed in ATTR_PLATAN_LINK_SETTINGS
Private Function EnabledForDef(def)
  thisApplication.DebugPrint "EnabledForDef -1 " & Time()
  EnabledForDef = False
  
  Dim att
  Set att = ThisApplication.Attributes
  If Not att.Has("ATTR_PLATAN_LINK_SETTINGS") Then Exit Function
  
  Dim probe, pattern
  probe = LCase(ThisApplication.Attributes("ATTR_PLATAN_LINK_SETTINGS").Value)
  pattern = LCase(def.SysName)
  EnabledForDef = InStr(1, probe, pattern) > 0
  thisApplication.DebugPrint "EnabledForDef -2 " & Time()
End Function
