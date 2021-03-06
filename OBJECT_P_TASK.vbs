USE "CMD_DLL_ROLES"
USE "CMD_PLAN_TASK_LIB"

Sub Object_BeforeCreate(Obj, Parent, Cancel)
  Call Set_PLAN_TASK_WORK_TYPE(Obj,"Основная")
End Sub

Sub Object_Created(Obj, Parent)
  Set oLink = Obj.Attributes("ATTR_OBJECT").Object
  
'  If oLink Is Nothing Then Exit Sub

  Call SetPlanTaskRoles(Obj)
  
  Call SetTaskAttrs(Obj)
  Call SetDefaultDates(Obj)
End Sub

Sub Object_StatusChanged(Obj, Status)
'  ' Прописываем дату закрытия задачи
'  If Status.SysName = "STATUS_P_TASK_FINISHED" Then
'    If Obj.Attributes.Has("ATTR_OBJECT") Then
'      Set LinkedObj = Obj.Attributes("ATTR_OBJECT").Object
'      If LinkedObj Is Nothing Then Exit Sub
'      Obj.Attributes("ATTR_ENDDATE_FACT") = LinkedObj.StatusModifyTime
'    End If
'  End If
End Sub

Sub SetTaskAttrs (Obj)
  Obj.Permissions = SysAdminPermissions
  Set oLink = Obj.Attributes("ATTR_OBJECT").Object
  If oLink Is Nothing Then Exit Sub
  ObjChanged = False
  ' Атрибут Обозначение
  attr = ""
  If oLink.Attributes.Has ("ATTR_WORK_DOCS_SET_CODE") Then attr = "ATTR_WORK_DOCS_SET_CODE"
  If oLink.Attributes.Has ("ATTR_SECTION_CODE") Then attr = "ATTR_SECTION_CODE"
  If oLink.Attributes.Has ("ATTR_T_TASK_CODE") Then attr = "ATTR_T_TASK_CODE"
  If oLink.Attributes.Has ("ATTR_VOLUME_CODE") Then attr = "ATTR_VOLUME_CODE"
  If attr <> vbNullString Then
    If oLink.Attributes.Has (attr) Then
      val = oLink.Attributes(attr)
      If val <> Obj.Attributes("ATTR_P_TASK_CODE") Then Obj.Attributes("ATTR_P_TASK_CODE") = val : ObjChanged = True
    End If
  End If

  
  ' Атрибут Наименование
  attr = ""
  If oLink.Attributes.Has ("ATTR_NAME") Then attr = "ATTR_NAME"
  If oLink.Attributes.Has ("ATTR_WORK_DOCS_SET_NAME") Then attr = "ATTR_WORK_DOCS_SET_NAME"
  If oLink.Attributes.Has ("ATTR_NAME_SHORT") Then attr = "ATTR_NAME_SHORT"
  If oLink.Attributes.Has ("ATTR_VOLUME_NAME") Then attr = "ATTR_VOLUME_NAME"
  If attr <> vbNullString Then
    If oLink.Attributes.Has (attr) Then
      val = oLink.Attributes(attr)
      If val <> Obj.Attributes("ATTR_P_TASK_NAME") Then Obj.Attributes("ATTR_P_TASK_NAME") = val : ObjChanged = True
    End If
  End If
  
  ' Атрибут код проекта
  Set oProject = oLink.Attributes("ATTR_PROJECT").Object
  For Each oStage in oProject.ContentAll.ObjectsByDef("OBJECT_STAGE")
    If oStage.ContentAll.Has(oLink.Handle) Then
      Val = oStage.Attributes("ATTR_PROJECT_STAGE").Classifier.Description
      If val <> Obj.Attributes("ATTR_P_TASK_STAGE_NAME") Then _
            Obj.Attributes("ATTR_P_TASK_STAGE_NAME") = val : ObjChanged = True
    End If
  Next
  
  
  ' Атрибут Титул
  If Not oLink.Parent Is Nothing Then
    If oLink.Parent.IsKindOf("OBJECT_WORK_DOCS_FOR_BUILDING") Then  
      val = oLink.Parent.Description
      If val <> Obj.Attributes("ATTR_P_TASK_TITUL_NAME") Then _
              Obj.Attributes("ATTR_P_TASK_TITUL_NAME") = val : ObjChanged = True
    Else
      
    End If
  End If

  ' Атрибут Ответственный
  attr = ""
  If oLink.Attributes.Has ("ATTR_RESPONSIBLE") Then 
  
    Set u = oLink.Attributes("ATTR_RESPONSIBLE").User
    If Not u Is Nothing Then
      Descr = ""
      val = u.Handle
      Set user = Obj.Attributes("ATTR_RESPONSIBLE").User
      If Not user Is Nothing Then
        If Obj.Attributes("ATTR_RESPONSIBLE").User.handle <> val Then
          Obj.Attributes("ATTR_RESPONSIBLE") = u
          ObjChanged = True
        End If
      Else
        Obj.Attributes("ATTR_RESPONSIBLE") = u
        ObjChanged = True
      End If
      If u.Attributes.Has("ATTR_KD_USER_DEPT") Then
        If u.Attributes("ATTR_KD_USER_DEPT").Empty = False Then
          If not u.Attributes("ATTR_KD_USER_DEPT").Object is Nothing Then
            Val = u.Attributes("ATTR_KD_USER_DEPT").Object.Handle
            Set dept = Obj.Attributes("ATTR_USER_DEPT").Object
            If Not dept Is Nothing Then
              If Obj.Attributes("ATTR_USER_DEPT").Object.Handle <> val Then
                Obj.Attributes("ATTR_USER_DEPT").Object = u.Attributes("ATTR_KD_USER_DEPT").Object
                Descr = u.Attributes("ATTR_KD_USER_DEPT").Object.Description
                ObjChanged = True
              End If
            Else
              Obj.Attributes("ATTR_USER_DEPT").Object = u.Attributes("ATTR_KD_USER_DEPT").Object
            End If
          End If
        End If
      End If
      If Descr <> "" Then
        val = u.Description & ", " & Descr
      Else
        val = u.Description
      End If
      If Obj.Attributes("ATTR_RESPONSIBLE_TXT") <> val Then
        Obj.Attributes("ATTR_RESPONSIBLE_TXT") = val
        ObjChanged = True
      End If
    End If
  End If
  If ObjChanged = True Then Obj.SaveChanges
End Sub

Sub SetDefaultDates (Obj)
  Obj.Permissions = SysAdminPermissions
  Set oLink = Obj.Attributes("ATTR_OBJECT").Object
  If oLink Is Nothing Then Exit Sub
  ' Этап договора + простановка дат
  If oLink.Attributes.Has("ATTR_CONTRACT_STAGE") Then
    If oLink.Attributes("ATTR_CONTRACT_STAGE").Empty = False Then
      Set contrStage = oLink.Attributes("ATTR_CONTRACT_STAGE").Object
      If Not contrStage Is Nothing Then
        aList = "ATTR_STARTDATE_PLAN,ATTR_ENDDATE_PLAN"
        Call ThisApplication.ExecuteScript("CMD_DLL", "AttrsSyncBetweenObjs", contrStage,Obj,aList)
        Obj.Attributes("ATTR_STARTDATE_ESTIMATED") = Obj.Attributes("ATTR_STARTDATE_PLAN")
        Obj.Attributes("ATTR_ENDDATE_ESTIMATED") = Obj.Attributes("ATTR_ENDDATE_PLAN")
      End If
    End If
  End If
End Sub


' Установка ожидаемой даты начала
Sub SetEstStart(Obj)
  Set Task = GetPlanTaskLink(Obj)
  If Task is Nothing Then Exit Sub
  Task.Permissions = SysAdminPermissions
  sDate = FormatDateTime(Date,vbShortDate)
  If Task.Attributes("ATTR_STARTDATE_ESTIMATED").Empty = True Then
    Task.Attributes("ATTR_STARTDATE_ESTIMATED") = sDate
  End If
  ' Если плановая дата начала не установлена, то задаем
  If Task.Attributes("ATTR_STARTDATE_PLAN").Empty = True Then
    Task.Attributes("ATTR_STARTDATE_PLAN") = sDate
  End If
End Sub

' Установка ожидаемой даты окончания
Sub SetEstEnd(Obj)
  Set Task = GetPlanTaskLink(Obj)
  If Task is Nothing Then Exit Sub
  Task.Permissions = SysAdminPermissions
  sDate = FormatDateTime(Date,vbShortDate)
  If Task.Attributes("ATTR_ENDDATE_ESTIMATED").Empty = True Then
    Task.Attributes("ATTR_ENDDATE_ESTIMATED") = sDate
  End If
  ' Если плановая дата окончания не установлена, то задаем
  If Task.Attributes("ATTR_ENDDATE_PLAN").Empty = True Then
    Task.Attributes("ATTR_ENDDATE_PLAN") = sDate
  End If
End Sub

Sub SetFactStart(Obj)
  Set Task = GetPlanTaskLink(Obj)
  If Task is Nothing Then Exit Sub
  Task.Permissions = SysAdminPermissions
  If Task.Attributes("ATTR_STARTDATE_FACT").Empty = True Then
    Task.Attributes("ATTR_STARTDATE_FACT") = FormatDateTime(Date,vbShortDate)
  End If
End Sub

Sub SetFactEnd(Obj)
  Set Task = GetPlanTaskLink(Obj)
  If Task is Nothing Then Exit Sub
  Task.Permissions = SysAdminPermissions
  If Task.Attributes("ATTR_ENDDATE_FACT").Empty = True Then
    Task.Attributes("ATTR_ENDDATE_FACT") = FormatDateTime(Date,vbShortDate)
  End If
End Sub

Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
  if obj.permissions.view <> 0 then 
    if thisObject.Permissions.LockOwner then 
      if ThisObject.Permissions.Locked = true Then 
        ThisObject.Unlock ThisObject.Permissions.LockType
      end if
    end if
  end if
End Sub

' Установка ролей
Sub SetPlanTaskRoles(Obj) 
  Obj.Permissions = SysAdminPermissions
  ' Удаляем все умолчательные роли
  Obj.Roles.RemoveAll
  ' Полные права всем, чтобы не менять доступ к объекту ролями
  Call AddRole(Obj,"ALL_USERS","ROLE_DEVELOPER")
End Sub




