
Sub Object_BeforeCreate(Obj, Parent, Cancel)
  If Parent Is Nothing Then Exit Sub
  ' Назначение администратора
  Obj.Permissions = SysAdminPermissions 

  If Parent.ObjectDefName = "OBJECT_FOLDER" Then
    Set folderType = Parent.Attributes("ATTR_FOLDER_TYPE").Classifier
    If folderType.SysName <> "NODE_FOLDER_PROJECT_WORK" Then
       msgbox "Невозможно создать объект проектирования на этом уровне",vbCritical,"Создать объект проектирования"
       Cancel = True   
       Exit Sub 
    End If
  End If
  Set oProj = Parent.Attributes("ATTR_PROJECT").Object
  If InStr(LCase(oProj.Attributes("ATTR_PROJECT_WORK_TYPE").Value), "кадастровые работы") <> 0 Then
    Obj.Attributes("ATTR_WORK_DOCS_FOR_BUILDING_TYPE").Classifier = _
      ThisApplication.Classifiers("NODE_BUILDING_TYPE").Classifiers.find("Участок")
  End If
  Call SetAttrs(Obj, Parent)
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Parent,Parent.Status,Obj,Obj.ObjectDef.InitialStatus)  
End Sub

Sub SetAttrs(Obj, Parent)
  aList = "ATTR_LAND_USE_CATEGORY,ATTR_BUILDING_STAGE,ATTR_WORK_DOCS_FOR_BUILDING_TYPE,ATTR_PROJECT,ATTR_STARTDATE_PLAN,ATTR_ENDDATE_PLAN"
  Call ThisApplication.ExecuteScript("CMD_DLL", "AttrsSyncBetweenObjs", Parent,Obj,aList)
End Sub

Sub Object_BeforeErase(Obj, Cancel)
  Dim result
  result = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckContent", Obj)
  Cancel=result
  Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", Obj) 
End Sub
