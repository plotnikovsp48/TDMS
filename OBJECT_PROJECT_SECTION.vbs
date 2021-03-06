
Sub Object_BeforeCreate(Obj, Parent, Cancel)
  Dim vOInitialStatus
  Dim vPInitialStatus
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Parent,Parent.Status,Obj,Obj.ObjectDef.InitialStatus)
  Call SetStartAttrs(Obj, Parent)
End Sub

Sub Object_BeforeErase(o_, cn_)
  cn_= ThisApplication.ExecuteScript("CMD_S_DLL", "CheckBeforeErase", o_) 
  Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", o_) 
End Sub

Sub Object_BeforeContentRemove(Obj, RemoveCollection, Cancel)
  Cancel = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckEraseFlag", RemoveCollection)
End Sub

Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
  if OkBtnPressed then 
    Dim oAttr,CheckValue
    oAttr="ATTR_NAME"'"ATTR_SECTION_CODE" '"ATTR_S_PSECTION_NUM"'
    If Not (Obj.Attributes("ATTR_SECTION_CODE").value = "-") Then
      CheckValue = Obj.Attributes(oAttr).value
      If ThisApplication.ExecuteScript("CMD_S_NUMBERING","CheckObjExist",Obj,oAttr,CheckValue,1201) then
        Cancel=true
      end if
    End If
    If Cancel Then Exit Sub
  End If
End Sub

Sub ContextMenu_BeforeShow(Commands, Obj, Cancel)
  '   В зависимости от того найдена ли задача добавляются соответствующие команды
  '   Учитывать в ПЛАТАН - Задача не найдена
  Dim cmd
  cmd = "CMD_ADD_TO_PLATAN"
  If ThisApplication.ExecuteScript(cmd, "EnableCommand", Obj) Then
    Commands.Add ThisApplication.Commands(cmd)
  End If
End Sub

Sub Object_Created(Obj, Parent)
  If Parent.ObjectDefName <> "OBJECT_PROJECT_SECTION" Then
    'Добавление выборки "Задания"
    QueryName = "QUERY_T_TASK_IN_PROJ"
  End If
  If ThisApplication.Queries.Has(QueryName) Then
    Set Query = ThisApplication.Queries(QueryName)
    If Obj.Queries.Has(Query.Description) = False Then
      Obj.Queries.AddCopy Query
    End If
  End If
  'Формируем обозначение Раздела
  If ThisApplication.ExecuteScript("CMD_S_NUMBERING", "ProjectSectionCodeGenCheck",Obj) = True Then
    Val = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "ProjectSectionCodeGen",Obj)
    If Obj.Attributes("ATTR_SECTION_CODE").Value <> Val Then Obj.Attributes("ATTR_SECTION_CODE").Value = Val  
  End If
  
  ' создание плановой задачи
  Call ThisApplication.ExecuteScript("CMD_ADD_TO_PLATAN", "Main", Obj)
  
  ' copy subcontractor attributes
  Dim parentAtt
  If Parent Is Nothing Then Exit Sub
  Set parentAtt = Parent.Attributes
  If Not parentAtt.Has("ATTR_SUBCONTRACTOR_WORK") Then Exit Sub
  If Not parentAtt("ATTR_SUBCONTRACTOR_WORK").Value Then Exit Sub
  SetupSubContractorAttributes parentAtt, Obj
End Sub

Private Sub SetupSubContractorAttributes(source, obj)
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr", _
    obj, "ATTR_SUBCONTRACTOR_WORK", source("ATTR_SUBCONTRACTOR_WORK").Value
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr", _
    obj, "ATTR_SUBCONTRACTOR_CLS", source("ATTR_SUBCONTRACTOR_CLS").Value
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr", _
    obj, "ATTR_CONTRACT_SUBCONTRACTOR", source("ATTR_CONTRACT_SUBCONTRACTOR").Value
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr", _
    obj, "ATTR_SUBCONTRACTOR_DOC_CODE", source("ATTR_SUBCONTRACTOR_DOC_CODE").Value
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr", _
    obj, "ATTR_SUBCONTRACTOR_DOC_NAME", source("ATTR_SUBCONTRACTOR_DOC_NAME").Value
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr", _
    obj, "ATTR_SUBCONTRACTOR_DOC_INF", source("ATTR_SUBCONTRACTOR_DOC_INF").Value
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr", _
    obj, "ATTR_TENDER_OUT_REQUIRED", source("ATTR_TENDER_OUT_REQUIRED").Value
End Sub

Sub Object_BeforeModify(Obj, Cancel)
  Call SetDescriptions(Obj)
End Sub

Sub SetDescriptions(Obj)
  ThisApplication.DebugPrint "SetDescriptions"  & time
  'Заполняем атрибут Описание
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetDescription",Obj)
  
  'Заполняем атрибут Описание короткое
  Val = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "ProjectSectionShortDescrGen",Obj)
  If Obj.Attributes("ATTR_DESCRIPTION_SHORT").Value <> Val Then Obj.Attributes("ATTR_DESCRIPTION_SHORT").Value = Val
End Sub

Sub Object_PropertiesDlgInit(Dialog, Obj, Forms)
  Dim attributes, inputForms, hideSubcontractor
  Set attributes = Obj.Attributes
  Set inputForms = Dialog.InputForms
  hideSubcontractor = Not attributes.Has("ATTR_SUBCONTRACTOR_WORK")
  If Not hideSubcontractor Then _
    hideSubcontractor = False = attributes("ATTR_SUBCONTRACTOR_WORK").Value
    
  If hideSubcontractor Then
    If inputForms.Has("FORM_SUBCONTRACTOR") Then
      inputForms.Remove inputForms("FORM_SUBCONTRACTOR")
    End If
  Else
    If Obj.Dictionary.Exists("FormActive") Then
      If inputForms.Has("FORM_SUBCONTRACTOR") and Obj.Dictionary.Item("FormActive") = True Then
        Dialog.ActiveForm = inputForms("FORM_SUBCONTRACTOR")
        Obj.Dictionary.Remove("FormActive")
      End If
    End If
  End If
  
    ' Закрываем информационные поручения 
    Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_CORR_REZOL_INF")
    Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_STAT_MAIN")
    Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_DEL_MAIN")
    
    ' отмечаем все поручения по разделу/подразделу прочитанными
  'if obj.StatusName <> "STATUS_DOCUMENT_CREATED" And obj.StatusName <> "STATUS_DOC_IS_ADDED" then _
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","Set_OrdersReaded",Obj

End Sub

' Установка базовых атрибутов
Sub SetStartAttrs(Obj,Parent)
  
  ' Заполняем ссылку на проект
  Set proj = ThisApplication.ExecuteScript("CMD_S_DLL","GetProject",Obj)
  If Not proj Is Nothing Then
    Obj.Attributes("ATTR_PROJECT").Object= proj
  End If
    
  ' Заполняем ссылку на стадию
  If Obj.Attributes.Has("ATTR_STAGE") Then
    Set stage = ThisApplication.ExecuteScript("CMD_S_DLL","GetStage",Obj)
    If Not stage Is Nothing Then
      Obj.Attributes("ATTR_STAGE").Object= stage
    End If
  End If
  
  ' Заполняем Тип части проекта
  Set cls = Thisapplication.Classifiers("NODE_PROJECT_STRUCTURE_TYPE")
  aSysName = "ATTR_PROJECT_STRUCTURE_TYPE"
  If Parent.ObjectDef.Handle = Obj.ObjectDef.Handle Then
    If Parent.Attributes.Has(aSysName) Then
      If Parent.Attributes(aSysName).Classifier.SysName = "NODE_PROJECT_STRUCTURE_SECTION" Then
        Obj.Attributes(aSysName).Classifier = cls.Classifiers("NODE_PROJECT_STRUCTURE_SUBSECTION")
      End If
    End If
  Else
    If Parent.Attributes.Has(aSysName) Then
      If Not Parent.Attributes(aSysName).Classifier Is Nothing Then
        If Parent.Attributes(aSysName).Classifier.SysName = "NODE_PROJECT_STRUCTURE_SECTION" Then
          Obj.Attributes(aSysName).Classifier = cls.Classifiers("NODE_PROJECT_STRUCTURE_SUBSECTION")
        End If
      Else
        If Parent.ObjectDefName = "OBJECT_PROJECT_SECTION" Then
          Obj.Attributes(aSysName).Classifier = cls.Classifiers("NODE_PROJECT_STRUCTURE_SUBSECTION")
        End If
      End If
    Else
      Obj.Attributes(aSysName).Classifier = cls.Classifiers("NODE_PROJECT_STRUCTURE_SECTION")
    End If
  End If
  ' Заполняем отдел
  Call ThisApplication.ExecuteScript("CMD_DEVELOPER_APPOINT","SetDept",Obj,Obj.Attributes("ATTR_RESPONSIBLE").User)
End Sub


Sub Object_StatusChanged(Obj, Status)
  ' Закрываем плановую задачу
  If Status.SysName = "STATUS_PROJECT_SECTION_FIXED" or Status.SysName = "STATUS_S_INVALIDATED" Then
    Call ThisApplication.ExecuteScript("CMD_PLAN_TASK_LIB", "ClosePlanTask",Obj)
  End If
End Sub

Sub Object_Modified(Obj)
  Call ThisApplication.ExecuteScript ("CMD_DLL_ORDERS", "SendOrderToResponsible",Obj)
'  Call ThisApplication.ExecuteScript("CMD_DEVELOPER_APPOINT","Run",Obj,Obj.Attributes("ATTR_RESPONSIBLE").User)
  ' Обновляем плановую задачу
  Call ThisApplication.ExecuteScript("CMD_PLAN_TASK_LIB","UpdatePlanTask",Obj)
End Sub


