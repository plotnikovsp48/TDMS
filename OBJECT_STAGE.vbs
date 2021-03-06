' Автор: Стромков С.А.
'
' Создание разделов
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

USE "COMMENT_FUNCTION_LIBRARY"

Sub Object_BeforeCreate(o_, p_, Cancel)
  Dim vOInitialStatus
  Dim vPInitialStatus
  'Проверка стадий в проекте
  If not p_ is Nothing Then
    Check = AllStageCheck(p_)
    If Check = False Then
      Msgbox "В проекте все стадии созданы!", vbExclamation,"Создать стадию"
      Cancel = True
      Exit Sub
    End If
  End If
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",p_,p_.Status,o_,o_.ObjectDef.InitialStatus)
  Call SetDefaultAttrs(o_)
End Sub

Sub Object_Created(Obj, p_)
  Call CreateStageStructure(Obj, p_)
End Sub

Sub Object_Modified(o_)
  Call SetIconClassIcon(o_,"ATTR_PROJECT_STAGE")
End Sub

Sub ContextMenu_BeforeShow(Commands, Obj, Cancel)
  ' В зависимости от Стадии скрываем команды от других стадий
  sTage = Obj.Attributes("ATTR_PROJECT_STAGE").Classifier.Sysname
  Select Case sTage
    Case "NODE_PROJECT_STAGE_W"
      ' Удалить команды "Добавить разделы", "Добавить непроектный раздел", "Отчет: Сводный Отчет по состоянию Разделов"
      Commands.Remove ThisApplication.Commands("CMD_PROJECT_SECTION_ADD")
      Commands.Remove ThisApplication.Commands("CMD_PROJECT_SECTION_OTHER_ADD")
      'Commands.Remove ThisApplication.Commands("CMD_PROJECT_SECTIONS_SUMMARY")
    Case Else
      ' Удалить команды "Добавить полный комплект", СВОК
      Commands.Remove ThisApplication.Commands("CMD_WORK_DOCS_FOR_BUILDING_NEW")
      Commands.Remove ThisApplication.Commands("CMD_SVOK_DOC")
  End Select
  
  Dim cmd
  cmd = "CMD_REVOKE_STRUCTURE_EDIT"
  If Commands.Has(cmd) Then
    If ThisApplication.ExecuteScript(cmd, "DisableCommand", Obj) Then
      Commands.Remove cmd
    End If
  End If
  
  'Команда Скопировать из структуры объекта
  Check = ThisApplication.ExecuteScript("FORM_PROJECT_STAGE_STRUCT","BtnCopyStructEnabled",Obj)
  If Check = False Then Commands.Remove ThisApplication.Commands("CMD_STRUCT_COPY_FROM_UNITS")
End Sub

Sub Object_StatusChanged(Obj, Status)
  If Status is Nothing Then Exit Sub
  ThisScript.SysAdminModeOn
  
  'Определение статуса после согласования
  StatusAfterAgreed = ""
  Set Rows = ThisApplication.Attributes("ATTR_AGREENENT_SETTINGS").Rows
  For Each Row in Rows
    If Row.Attributes("ATTR_KD_OBJ_TYPE").Value = Obj.ObjectDefName Then
      StatusAfterAgreed = Row.Attributes("ATTR_KD_FINISH_STATUS")
      Exit For
    End If
  Next
  'Отработка маршрутов для механизма согласования
  If Status.SysName = "STATUS_KD_AGREEMENT" or Status.SysName = StatusAfterAgreed Then
    If Obj.Dictionary.Exists("PrevStatusName") Then
      sName = Obj.Dictionary.Item("PrevStatusName")
      If ThisApplication.Statuses.Has(sName) Then
        Set PrevSt = ThisApplication.Statuses(sName)
        Call ThisApplication.ExecuteScript("CMD_ROUTER","RunNonStatusChange",Obj,PrevSt,Obj,Status.SysName) 
      End If
    End If
  End If
End Sub

Sub Object_StatusBeforeChange(Obj, Status, Cancel)
  ThisScript.SysAdminModeOn
  'Записываем текущий статус в словарь
  Obj.Dictionary.Item("PrevStatusName") = Obj.StatusName
End Sub

'Функция проверки наличия всех стадий в проекте
Function AllStageCheck(p_)
  AllStageCheck = False
  Count = 0
  For Each Clf in ThisApplication.Classifiers("NODE_PROJECT_STAGE").Classifiers
    Check = False
    For Each Stage in p_.Content
      If Stage.ObjectDefName = "OBJECT_STAGE" Then
        If Stage.Attributes("ATTR_PROJECT_STAGE").Empty = False Then
          If Stage.Attributes("ATTR_PROJECT_STAGE").Classifier.SysName = Clf.SysName Then
            Check = True
            Exit For
          End If
        End If
      End If
    Next
    If Check = False Then
      Count = Count + 1
    End If
  Next
  If Count > 0 Then AllStageCheck = True
End Function

'==============================================================================
' Изменение значка информационного объекта в зависимости от значения классификатора на атрибуте объекта
'------------------------------------------------------------------------------
' o_:TDMSObject - Объект, но котором изменяем значек
' a_:TDMSAttribute - Атрибут объекта типа классификатор, с которого будет взят значек
'==============================================================================
Private Sub SetIconClassIcon(o_,a_)
  Dim vIcon     ' :TDMSIcon
  ' Проверка входных параметров
  If VarType(o_) <> 9 Then Exit Sub
  If o_ Is Nothing Then Exit Sub
  If Not o_.Attributes.Has(a_) Then Exit Sub
  o_.Permissions = SysAdminPermissions 
  Set vIcon = o_.Attributes(a_).Classifier.Icon
  o_.Icon = vIcon
End Sub

Sub Object_BeforeErase(Obj, Cancel)
  Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", Obj) 
End Sub

Sub Object_ContentAdded(Obj, AddCollection)
  'Call Sort(Obj)
End Sub

Sub Sort(o_)
  Dim os,o,count
  Dim i,j
  Dim v1,v2,d1,d2
  ThisScript.SysAdminModeOn
  o_.Permissions = SysAdminPermissions
  If o_ Is Nothing Then Exit Sub
  Set os = o_.Content
  count = os.Count
  For j= 0 To count
    For i=count-1 To 1 Step -1
      v1 = os.Item(i).Description
      d1 = os.Item(i).ObjectDefName
      v2 = os.Item(i-1).Description
      d2 = os.Item(i-1).ObjectDefName
      p1 = InStr(v1,".")
      p2 = InStr(v2,".")
      If p1 <> 0 And p1 <> Null Then 
        l1 = Right("00" & Left(v1,p1-1),2)
      Else
        l1 = "00"
      End If
      
      If p2 <> 0 And p2 <> Null Then 
        l2 = Right("00" & Left(v2,p2-1),2)
      Else
        l2 = "00"
      End If
      'l2 = Right("00" & Left(v2,p2-1),2)
      If d1 = d2 Then
        If d1 = "OBJECT_PROJECT_SECTION" Then 
          If StrComp(l1,l2,vbTextCompare) = -1 Then
            os.Swap os.Item(i), os.Item(i-1)
          End If
        Else
          If StrComp(v1,v2,vbTextCompare) = -1 Then
            os.Swap os.Item(i), os.Item(i-1)
          End If
        End If
      Else
        If InStr(ORDER,d1) < InStr(ORDER,d2) Then
          os.Swap os.Item(i), os.Item(i-1)
        End If            
      End If  
    Next
  Next
  os.Update
  ThisApplication.Shell.Update o_
'   ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1008
End Sub


Sub CreateStageStructure(Obj, Parent)
  Set cls = Nothing
  ' Документация, передаваемая заказчику
  If ThisApplication.Queries.Has("QUERY_DOCS_FOR_CUSTOMER") Then
    Obj.Queries.AddCopy ThisApplication.Queries("QUERY_DOCS_FOR_CUSTOMER")
  End If
  
  ' Для скваженщиков формируем структуры
  If Obj.Attributes("ATTR_SITE_TYPE_CLS") Is Nothing Then Exit Sub
    If Not  Obj.Attributes("ATTR_SITE_TYPE_CLS").Classifier Is Nothing Then
      Select Case Obj.Attributes("ATTR_SITE_TYPE_CLS").Classifier.Sysname
        Case "NODE_548A09E9_D674_48A0_A72E_B335A58CE45F"
          Set cls = ThisApplication.ExecuteScript("CMD_PROJECT_SECTION_ADD","Prepare",Obj)
        Case "NODE_D81A6621_5480_4640_B090_354903FD2EB3"
          Set cls = ThisApplication.ExecuteScript("CMD_PROJECT_SECTION_ADD","Prepare",Obj)
        Case "NODE_53121546_0B8E_4461_B56F_C7889D240001"
          Set cls = ThisApplication.ExecuteScript("CMD_PROJECT_SECTION_ADD","Prepare",Obj)
        Case "NODE_E6E9C163_11B8_4BF7_9805_C490D62EE91F"
          Set cls = ThisApplication.ExecuteScript("CMD_PROJECT_SECTION_ADD","Prepare",Obj)
      End Select
    End If
    If cls Is Nothing Then Exit Sub
    ThisApplication.Utility.WaitCursor = True
    Call CreateStructure(Obj, cls)
    If Obj.StatusName = "STATUS_STAGE_DRAFT" Or Obj.StatusName = "STATUS_STAGE_EDIT" Then
      Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,"STATUS_STAGE_DEVELOPING")
    End If
    ThisApplication.Utility.WaitCursor = False
    msgbox "Структура проекта создана", vbInformation
End Sub

Sub CreateStructure(Obj, cls)
  Obj.Permissions = SysAdminPermissions
  Set Progress = ThisApplication.Dialogs.ProgressDlg
  progress.Start
  count = cls.Classifiers.Count
  progress.Position = 0
  For each sect In cls.Classifiers
    progress.Position = 100/count * (cls.Classifiers.Index(sect) + 1)
    If sect.Description <> "Непроектный раздел" Then
      If Obj.ObjectDefName = "OBJECT_STAGE" Then oDef = "OBJECT_PROJECT_SECTION"
      If Obj.ObjectDefName = "OBJECT_PROJECT_SECTION" Then oDef = "OBJECT_PROJECT_SECTION_SUBSECTION"
      Progress.Text = "Создается " & ThisApplication.ObjectDefs(oDef).Description & ": " & sect.Description
      Set NewObj =  ThisApplication.ExecuteScript("CMD_PROJECT_SECTION_ADD","CreateSection",Obj,sect,oDef)  
        If sect.classifiers.count > 0 Then
          Call CreateStructure(NewObj, sect)
        End If
    End If
  Next
End Sub

Sub SetDefaultAttrs(Obj)
  Set oProj = Obj.Attributes("ATTR_PROJECT").Object
  If oProj Is Nothing Then Exit Sub
  ATTRSTARTDATEPLAN = oProj.Attributes("ATTR_STARTDATE_PLAN")
  Obj.Attributes("ATTR_STARTDATE_PLAN") = ATTRSTARTDATEPLAN
  ATTRENDDATEPLAN = oProj.Attributes("ATTR_ENDDATE_PLAN")
  Obj.Attributes("ATTR_ENDDATE_PLAN") = ATTRENDDATEPLAN
  Obj.Attributes("ATTR_ENDDATE_ESTIMATED") = ATTRENDDATEPLAN
End Sub
