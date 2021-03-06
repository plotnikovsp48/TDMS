' $Workfile: OBJECTDEF.SCRIPT.OBJECT_WORK_DOCS_FOR_BUILDING.scr $ 
' $Date: 30.01.07 19:38 $ 
' $Revision: 1 $ 
' $Author: Oreshkin $ 
'
' Полный комплект
'------------------------------------------------------------------------------
' Авторское право c ЗАО <НАНОСОФТ>, 2008 г.

USE "CMD_S_DLL"

Sub Object_BeforeCreate(Obj, Parent, cn_)
  '  Проверяем выполнение входных условий
  Dim result
  result=Not StartCondCheck (Obj,Parent)
  If result Then 
    cn_= result
    Exit Sub
  End If
  
  Dim vOInitialStatus
  Dim vPInitialStatus
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Parent,Parent.Status,Obj,Obj.ObjectDef.InitialStatus)
  
  ' Копируем даты с родителя или с проекта
  Call SetDates(Obj, Parent)
  'Формируем обозначение
  'If ThisApplication.ExecuteScript("CMD_S_NUMBERING", "WorkDocsBuildCodeGenCheck",Obj) = True Then
   ' Obj.Attributes("ATTR_PROJECT_BASIC_CODE") = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "WorkDocsBuildCodeGen",Obj)
  'End If
End Sub

Sub Object_BeforeErase(o_, cn_)
  Dim result1,result2
  result1 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckContent", o_)
  result2 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckReferencedBy", o_) 
  cn_=result1 Or result2
  Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", o_) 
End Sub
 
 Sub Object_BeforeContentRemove(Obj, RemoveCollection, Cancel)
  Cancel = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckEraseFlag", RemoveCollection)
End Sub


'==============================================================================
' Проверка входных условий
'------------------------------------------------------------------------------
' o_:TDMSObject - Полный комплект
' p_:TDMSObject - Полный комплект или Рабочая документация или Стадия
' StartCondCheck: Boolean   True - входные условия выполнены
'                           False - входные условия не выполнены
'==============================================================================
Private Function StartCondCheck(o_,p_)
  StartCondCheck = False
  sName = p_.StatusName
  oName = p_.ObjectDefName
  
  Set Stage = GetStage(o_)
  sNameStage = Stage.StatusName
  
  ' Проверяем статус полного комплекта
  If sName <> "STATUS_WORK_DOCS_FOR_BUILDING_IS_DEVELOPING" And oName = "OBJECT_WORK_DOCS_FOR_BUILDING"  Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1266
    Exit Function
  End If
    
    ' Проверяем статус Стадии
    If sNameStage <> "STATUS_STAGE_DRAFT" And sNameStage <> "STATUS_STAGE_EDIT" Then
      msgbox "Невозможно создать полный комплект. Стадия должна быть в режиме редактирования структуры проекта",vbCritical,"Ошибка создания полного комплекта"
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbCritical, 1284
      Exit Function
    End If
  
  ' Проверяем статус Стадии
  If oName = "OBJECT_STAGE" Then
    If sName <> "STATUS_STAGE_DRAFT" And sName <> "STATUS_STAGE_EDIT" Then
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1266
      Exit Function
    End If
  End If

  ' Проверяем статус Рабочей документации
  If sName <> "STATUS_PROJECT_DOCS_W_IS_DEVELOPING" And oName = "OBJECT_PROJECT_DOCS_W" Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1266
    Exit Function
  End If
  
  ' Проверяем принадлежность пользователя к группе ГИПов
  If Not ThisApplication.Groups("GROUP_GIP").Users.Has(ThisApplication.CurrentUser) Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1030, ThisApplication.Groups("GROUP_GIP").Description
    Exit Function
  End If
  
  StartCondCheck = True
End Function

Sub Object_Modified(Obj)
  ThisApplication.DebugPrint "Object_Modified" & Time
  'Заполняем атрибут Описание
  Call SetDescription(Obj)
End Sub

Sub Object_Created(Obj, Parent)
'ThisApplication.AddNotify "Object_Created"
  If Obj.Attributes("ATTR_STAGE").Object Is Nothing Then
    Set Stage = GetStage(Obj)
    If Not Stage Is Nothing Then Obj.Attributes("ATTR_STAGE").Object = Stage
  End If
End Sub

Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
  If OkBtnPressed = True Then
    Cancel = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckBeforeClose",Obj)
  Else
    If Obj.ReferencedBy.count > 0 Then
      Obj.SaveChanges
      Cancel = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckBeforeClose",Obj)
    End If
  End If 
End Sub


Sub SetDates(Obj, Parent)
  Set oProj = Obj.Attributes("ATTR_PROJECT").Object
  Call AttrsSyncBetweenObjs(Parent,Obj,"ATTR_STARTDATE_PLAN,ATTR_ENDDATE_PLAN,ATTR_STARTDATE_ESTIMATED,ATTR_ENDDATE_ESTIMATED")
  If Obj.Attributes("ATTR_STARTDATE_PLAN").Empty or Obj.Attributes("ATTR_ENDDATE_PLAN").Empty Then
    Call AttrsSyncBetweenObjs(oProj,Obj,"ATTR_STARTDATE_PLAN,ATTR_ENDDATE_PLAN,ATTR_STARTDATE_ESTIMATED,ATTR_ENDDATE_ESTIMATED")
  End If
End Sub