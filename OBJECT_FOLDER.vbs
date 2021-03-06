' $Workfile: OBJECTDEF.SCRIPT.OBJECT_FOLDER.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 5 $ 
' $Author: Oreshkin $ 
'
' Раздел
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.

USE "CMD_DLL_ROLES"

Sub Object_BeforeCreate(Obj, Parent, Cancel)
  ' Назначение администратора
  Obj.Permissions = SysAdminPermissions 

  If Parent.ObjectDefName = "OBJECT_FOLDER" Then
    Set folderType = Parent.Attributes("ATTR_FOLDER_TYPE").Classifier
    If folderType.SysName = "NODE_FOLDER_PROJECT_WORK" Then
       msgbox "Невозможно создать папку на этом уровне",vbCritical,"Создать документ"
       Cancel = True   
       Exit Sub 
    End If
  End If
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Parent,Parent.Status,Obj,Obj.ObjectDef.InitialStatus)  
  Call SetAttrs(Obj)
End Sub


Sub Object_BeforeErase(o_, cn_)
  Dim result
  result = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckContent", o_)
  cn_=result
  Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", o_) 
End Sub

Sub Object_BeforeContentRemove(o_, RemoveCollection, Cancel)
  Dim result,o
  result = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckEraseFlag", RemoveCollection)
  If Not result Then Exit Sub
  ' Проверка наличие контейнеров непосредственно содержащие удаляемые объекты
  Set o = CheckUplinks(RemoveCollection)
  If o Is Nothing Then Exit Sub
  ' Подтверждение удаления
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbExclamation+vbYesNo, 1020,o.ObjectDef.Description,o.ObjectDef.Description)
  If result <> vbYes Then Cancel=True
End Sub

'==============================================================================
' Функция проверяет наличие контейнеров непосредственно содержащие данный 
' объект
'------------------------------------------------------------------------------
' os_:TDMSObjects - Коллекция удаляемых из состава объектов
' CheckUplinks:TDMSObject - Объект не входящий не в один контейнер и не 
'    содержащийся на рабочем столе
'==============================================================================
Private Function CheckUplinks(os_)
  Set CheckUplinks = Nothing
  For Each o In os_
    If ((o.Uplinks.Count <= 1) And (Not ThisApplication.Desktop.Objects.Has(o.GUID))) Then
      Set CheckUplinks = o
      Exit Function
    End If
  Next
End Function

Sub Object_BeforeModify(Obj, cn_)
  '  Проверка наличия папки с таким же наименованием в составе родителя
'  Dim result
'  result=ThisApplication.ExecuteScript ("CMD_S_DLL", "CheckObjByAttr", o_, "ATTR_FOLDER_NAME")
'  If result > 0 Then cn_=True
End Sub

' Установка атрибутов
Private Sub SetAttrs(o_)
  ' Установка наименования папки
'  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr", o_, "ATTR_FOLDER_NAME", "Новая папка"
End Sub

Sub ContextMenu_BeforeShow(Commands, Obj, Cancel)
  If Not IsCanEditContent(Obj) Then
    Commands.Remove ThisApplication.Commands("CMD_FOLDER_IMPORT")
  End If
  If Obj.Attributes.Has("ATTR_FOLDER_TYPE") Then
    Set cls = Obj.Attributes("ATTR_FOLDER_TYPE").Classifier
    If Not cls Is Nothing Then
      Select Case Obj.Attributes("ATTR_FOLDER_TYPE").Classifier.Sysname
        Case "NODE_FOLDER_GENERAL" ' Папка общего назначения
          Commands.Remove ThisApplication.Commands("CMD_OBJECT_UNIT_CREATE")
          Commands.Remove ThisApplication.Commands("CMD_CREATE_BUILD_STAGE")
          Commands.Add ThisApplication.Commands("CMD_SECTION_CREATE")
          
        Case "NODE_ISSUES", "NODE_FOLDER_BOD", "NODE_FOLDER_AUTH-SUPERVISION","NODE_FOLDER_PEMC"
          For each Comm In Commands
            Commands.Remove comm
          Next
          Commands.Add ThisApplication.Commands("CMD_DOCUMENT_CREATE")
          Commands.Add ThisApplication.Commands("CMD_SECTION_CREATE")
        Case "NODE_OBJECT_BUILD_STAGE" ' Этап строительства
          For each Comm In Commands
            Commands.Remove comm
          Next
          'Commands.Add ThisApplication.Commands("CMD_CREATE_BUILD_STAGE")
          ' Добавляем команду Создать объект проектирования
          Set CU = ThisApplication.CurrentUser
          Set Roles = Obj.RolesForUser(CU)
          cName = "CMD_CREATE_BUILD_STAGE"
          Set comm = ThisApplication.Commands(cName)
          Set CommStat = ThisApplication.Commands(cName).Statuses
          Set CommRoles = ThisApplication.Commands(cName).RoleDefs
                  
          If CommStat.Has(Obj.StatusName) Then
            For each r In CommRoles
              If Roles.Has(r.Sysname) Then
                Commands.Add ThisApplication.Commands(cName)
                Exit For
              End If
            Next
          End If
          
        Case "NODE_FOLDER_PROJECT_WORK" ' Папка для структуры объекта
          For each Comm In Commands
            Commands.Remove comm
          Next
          ' Добавляем команду Создать объект проектирования
          Set CU = ThisApplication.CurrentUser
          Set Roles = Obj.RolesForUser(CU)
          cName = "CMD_OBJECT_UNIT_CREATE"
          Set comm = ThisApplication.Commands(cName)
          Set CommStat = ThisApplication.Commands(cName).Statuses
          Set CommRoles = ThisApplication.Commands(cName).RoleDefs
                  
          If CommStat.Has(Obj.StatusName) Then
            For each r In CommRoles
              If Roles.Has(r.Sysname) Then
                Commands.Add ThisApplication.Commands(cName)
                Exit For
              End If
            Next
          End If
        Case Else
          For each Comm In Commands
            Commands.Remove comm
          Next
      End Select
    End If
  End If
End Sub

Sub Object_Modified(Obj)
  Obj.Permissions = SysadminPermissions
  Call SetDescription(Obj)
  If Obj.Attributes.Has("ATTR_FOLDER_TYPE") Then
    If Obj.Attributes("ATTR_FOLDER_TYPE").Empty = False Then
      Obj.Icon = Obj.Attributes("ATTR_FOLDER_TYPE").Classifier.Icon
    End If
  End If
End Sub

Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
  If OkBtnPressed = False Then Exit Sub
  Cancel = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckBeforeClose",Obj)
End Sub



