' Автор: Стромков С.А.
'
' Библиотека функций стандартной версии
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016 г.

USE "CMD_STRU_OBJ_DLL"
USE "CMD_DLL_ROLES"
USE "CMD_FILES_LIBRARY"
USE "CMD_LIBRARY"

Sub Object_BeforeCreate(Obj, p_, Cancel)
  sysID = ThisApplication.ExecuteScript ("CMD_KD_REGNO_KIB","Get_Sys_Id",Obj)
  if sysID = 0 then 
      Cancel = true
      exit sub
  else  
    Obj.Attributes("ATTR_KD_IDNUMBER").value = sysID
  end if
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",p_,p_.Status,Obj,Obj.ObjectDef.InitialStatus)    
  ' Установка атрибутов
  Call SetAttrs(p_,Obj)
  ' Создаем файл в задании из шаблона или предлагаем выбрать с диска
  'Call AddFile(Obj)
End Sub

Sub Object_Created(Obj, Parent)
  Obj.Permissions = SysAdminPermissions
  ' Установка ролей
  Call UpdateRoles(Obj)
'  ' Создаем файл в задании из шаблона или предлагаем выбрать с диска
'  Call AddFile(Obj)
  ' создание плановой задачи
  Call ThisApplication.ExecuteScript("CMD_ADD_TO_PLATAN", "Main", Obj)
  
  ' рассылка оповещения ответственным
  Call SendMessage(Obj)
End Sub

Sub Object_BeforeErase(o_, cn_)
  cn_= ThisApplication.ExecuteScript("CMD_S_DLL", "CheckBeforeErase", o_) 
  Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", o_) 
End Sub

Sub Object_BeforeModify(Obj, Cancel)
'ThisApplication.AddNotify "Object_BeforeModify - " & Time
'  Set Dict = ThisApplication.Dictionary("DelObjOperation")
  Check = True
  'Отключено, т.к. в некоторых случаях вызывает ошибку
' 30.01.2018
'  If Dict.Exists("exe") Then
'    If Dict.Item("exe") = True Then Check = False
'  End If
  If Check = True Then Call UpdateRoles(Obj)
End Sub

Sub Object_Modified(Obj)
  ThisApplication.DebugPrint "Object_Modified " & Time
  ThisScript.SysAdminModeOn
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS", "SendOrderToResponsible",Obj)
  ThisApplication.ExecuteScript "CMD_DLL","SetIcon",Obj
  Call ThisApplication.ExecuteScript("CMD_PLAN_TASK_LIB","UpdatePlanTask",Obj)
End Sub

Sub UpdateRoles(Obj)
  Obj.Permissions = SysAdminPermissions
  'Обновление ролей от атрибутов "Проверил" и "Разработал"
  'Проверил - Ответственный за подготовку задания
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole",Obj,"ATTR_RESPONSIBLE","ROLE_RESPONSIBLE")
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole",Obj,"ATTR_RESPONSIBLE","ROLE_T_TASK_OUT_CHECKER")
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole",Obj,"ATTR_T_TASK_DEVELOPED","ROLE_T_TASK_DEVELOPER")
'  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole",Obj,"ATTR_T_TASK_CHECKED","ROLE_CHECKER")
'  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole",Obj,"ATTR_SIGNER","ROLE_SIGNER")
'  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole",Obj,"ATTR_DOCUMENT_CONF","ROLE_TASK_ACCEPT")
End Sub


Sub Object_StatusBeforeChange(Obj, Status, Cancel)
ThisApplication.DebugPrint "Object_StatusBeforeChange"
  ThisScript.SysAdminModeOn
  'Записываем текущий статус в словарь
  Obj.Dictionary.Item("PrevStatusName") = Obj.StatusName
End Sub

Sub Object_StatusChanged(Obj, Status)
  If Status is Nothing Then Exit Sub
  ThisScript.SysAdminModeOn
  Call SetIcon(Obj)
'  ' -- > Case 5632 --
'  If Status.SysName = "STATUS_T_TASK_IN_WORK" Then
'    Obj.Attributes("ATTR_SIGN_DATA").Empty = True
'  End If
'  ' -- Case 5632 < --
  
'  If Status.SysName = "STATUS_T_TASK_IN_WORK" Then
'    RoleName = "ROLE_INITIATOR"
''    If Obj.Roles.Has(RoleName) = False Then
'      Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole",Obj,"ATTR_T_TASK_DEVELOPED",RoleName)
''    End If
'  End If
  
  If Status.SysName = "STATUS_T_TASK_IS_SIGNING" Then
    RoleName = "ROLE_SIGNER"
    If Obj.Roles.Has(RoleName) = False Then
      Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole",Obj,"ATTR_SIGNER",RoleName)
    End If
  End If
  
'  If Status.SysName = "STATUS_T_TASK_IS_SIGNED" Then
'    RoleName = "ROLE_INITIATOR"
'      Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole",Obj,"ATTR_T_TASK_DEVELOPED",RoleName)
'      Call ThisApplication.ExecuteScript ("CMD_DLL","SetRole",Obj,RoleName,ThisApplication.CurrentUser)
''      Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole",Obj,"ATTR_SIGNER",RoleName)
'  End If
  
  If Obj.StatusName = "STATUS_T_TASK_IS_SIGNED" Then
'    If Obj.StatusName = "STATUS_T_TASK_IS_SIGNING" Then
    RoleName = "ROLE_INITIATOR"
    Set dvlpr = Obj.Attributes("ATTR_T_TASK_DEVELOPED").User
    Set sgnr = Obj.Attributes("ATTR_SIGNER").User
      Call ThisApplication.ExecuteScript ("CMD_DLL","DelDefRole",Obj,RoleName)
      Call ThisApplication.ExecuteScript ("CMD_DLL","SetRole",Obj,RoleName,dvlpr)
'      Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole",Obj,"ATTR_T_TASK_DEVELOPED",RoleName)
      Call ThisApplication.ExecuteScript ("CMD_DLL","SetRole",Obj,RoleName,sgnr)
'      Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole",Obj,"ATTR_SIGNER",RoleName)
    End If
'  End If
    
  If Status.SysName = "STATUS_T_TASK_IS_APPROVING" Then
    RoleName = "ROLE_TASK_ACCEPT"
    If Obj.Roles.Has(RoleName) = False Then
      Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_DOCUMENT_CONF",RoleName)
    End If
  End If
  
  
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
  
  ' Если не заполнена дата подписания, то заполняем после передачи на согласование
  ' Это в случае, когда полписан сразу отправил на согласование
  If Status.SysName = "STATUS_KD_AGREEMENT"  Then
    If Obj.Attributes.Has("ATTR_SIGN_DATA") = False Then Obj.Attributes.Create("ATTR_SIGN_DATA")
    If Obj.Attributes("ATTR_SIGN_DATA").Empty = True Then
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", Obj, "ATTR_SIGN_DATA", Date(), True
    End If
  End If
  
  
  ' Закрываем плановую задачу
  If Status.SysName = "STATUS_T_TASK_APPROVED" or Status.SysName = "STATUS_T_TASK_INVALIDATED" Then
    Call ThisApplication.ExecuteScript("CMD_PLAN_TASK_LIB", "ClosePlanTask",Obj)
  End If
    
  If Obj.Dictionary.Exists("PrevStatusName") Then
    sName = Obj.Dictionary.Item("PrevStatusName")
    ' Постобработка согласования при отклонении задания
    If sName = "STATUS_KD_AGREEMENT" Then 'And Status.SysName = StatusReturnAfterAgreed Then
      Call ThisApplication.ExecuteScript("CMD_PROJECT_DOCS_LIBRARY","AgreementPostProcess",Obj) 
    End If
    If Status.SysName = "STATUS_T_TASK_IN_WORK" Then ' Прибавляем цикл, если задание вернулось на доработку
      Call TaskLoopIncrease(Obj)
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", Obj, "ATTR_SIGN_DATA", vbNullString, True
      RoleName = "ROLE_INITIATOR"
      Call ThisApplication.ExecuteScript("CMD_DLL","DelDefRole",Obj,RoleName)
      Call ThisApplication.ExecuteScript("CMD_DLL_ROLES", "UpdateAttrRole",Obj,"ATTR_T_TASK_DEVELOPED",RoleName)
    End If
  End If
End Sub


'Функция проверки Задания перед отправкой на согласование
Function TaskAgreeCheck(Obj)
  TaskAgreeCheck = False
  StatusCheck = False
  
'  ' Проверка наличия файла
'  If Not ThisApplication.ExecuteScript("CMD_DLL", "CheckDoc",Obj) Then Exit Function
    
'  '  Проверка статуса
'  If Obj.Status is Nothing Then 
'    Msgbox "Отправка на согласование невозможно из статуса. Статус не установлен", _
'      vbCritical, "Отправка отменена!"
'      Exit Function
'  End If
'  Set uExec = Obj.Attributes("ATTR_T_TASK_DEVELOPED").User
'  Set uResp = Obj.Attributes("ATTR_RESPONSIBLE").User
'  
'  If Obj.StatusName = "STATUS_T_TASK_IS_SIGNING" Then
'    StatusCheck = True
'  ElseIf Obj.StatusName = "STATUS_T_TASK_IN_WORK" Then
'    If Not uExec Is Nothing And Not uResp Is Nothing Then
'      If uExec.Handle = uResp.Handle Then
'        StatusCheck = True
'      End If
'    End If
'  ElseIf Obj.StatusName = "STATUS_T_TASK_IS_SIGNED" Then 
'    StatusCheck = True
'  End If
  
'  If StatusCheck = False Then 
'    Msgbox "Отправка на согласование невозможно из статуса """ & Obj.Status.Description & """", _
'      vbCritical, "Отправка отменена!"
'      Exit Function
'  End If

  If Not SetRequiredApprovers(Obj) Then Exit Function
    
'  ' Заполнение атрибута Исполнитель
'  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", Obj, "ATTR_KD_EXEC", CU, True
  TaskAgreeCheck = True
End Function

Function SetRequiredApprovers(Obj)
  SetRequiredApprovers = False
  'Добавление начальников отделов-адресатов в список согласующих
  If Obj.Attributes.Has("ATTR_T_TASK_TDEPTS_TBL") Then
    Set TableRows = Obj.Attributes("ATTR_T_TASK_TDEPTS_TBL").Rows
    Set Dict = ThisApplication.Dictionary(Obj.GUID&"CheckAgree")
    Dict.RemoveAll
    'Составляем список пользователей
    For Each Row in TableRows
      If Row.Attributes("ATTR_T_TASK_DEPT").Empty = False Then
        If not Row.Attributes("ATTR_T_TASK_DEPT").Object is Nothing Then
          Set Dept = Row.Attributes("ATTR_T_TASK_DEPT").Object
          Set User = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetChiefByDept", Dept)
          If not User is Nothing Then
            If Dict.Exists(User.SysName) = False Then
              Dict.Item(User.SysName) = User.SysName
            End If
          End If
        End If
      End If
    Next
    'Вносим пользователей в список согласующих
    Set AgreeObj = ThisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB","GetAgreeObjByObj",Obj)
    If AgreeObj is Nothing Then Exit Function
    Set TableRows = AgreeObj.Attributes("ATTR_KD_TAPRV").Rows
    'Определение нового номера блока
    BlockNum = 0
    For Each Row in TableRows
      CurNum = Row.Attributes("ATTR_KD_APRV_NO_BLOCK").Value
      If CurNum > BlockNum Then
        BlockNum = CurNum
      End If
    Next
    BlockNum = BlockNum + 1
    itemArray = dict.Items
    AttrName = "ATTR_KD_APRV"
    For Each element In itemArray
      If ThisApplication.Users.Has(element) Then
        Set u = ThisApplication.Users(element)
        Check = True
        For Each Row in TableRows
          If Row.Attributes(AttrName).Empty = False Then
            If not Row.Attributes(AttrName).User is Nothing Then
              If u.SysName = Row.Attributes(AttrName).User.SysName Then
                Check = False
                Exit For
              End If
            End If
          End If
        Next
        If Check = True Then
          aTime = DateAdd ("d", 3, Date) 
          Call ThisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB","CreateAppRow",AgreeObj,BlockNum,aTime,u)
        End If
      End If
    Next
  End If
  Dict.RemoveAll
  SetRequiredApprovers = True
End Function

Sub ContextMenu_BeforeShow(Commands, Obj, Cancel)

  'Добавляем команду Вернуть для доработки
  Set Roles = Obj.RolesForUser(ThisApplication.CurrentUser)
  If Obj.StatusName = "STATUS_T_TASK_IS_CHECKING" and Roles.Has("ROLE_CHECKER") = False Then
    Commands.Remove ThisApplication.Commands("CMD_TASK_BACK_TO_WORK")
  ElseIf Obj.StatusName = "STATUS_T_TASK_IS_CHECKING" and Roles.Has("ROLE_CHECKER") = False Then
    Commands.Remove ThisApplication.Commands("CMD_TASK_BACK_TO_WORK")
  End If
  
  Dim cmd
  cmd = "CMD_ADD_TO_PLATAN"
  If ThisApplication.ExecuteScript(cmd, "EnableCommand", Obj) Then
    Commands.Add ThisApplication.Commands(cmd)
  End If
End Sub

'Функция получения номера задания
Function TaskNumGet(Obj)
  TaskNumGet = 1
  Set Project = Nothing
  If Obj.Attributes("ATTR_PROJECT").Empty = False Then
    If not Obj.Attributes("ATTR_PROJECT").Object is Nothing Then
      Set Project = Obj.Attributes("ATTR_PROJECT").Object
    End If
  End If
  If Project is Nothing Then Exit Function
  Set Query = ThisApplication.Queries("QUERY_TASK_NUM")
  Query.Parameter("PROJECT") = Project
  Set Sheet = Query.Sheet
  If Sheet.RowsCount > 0 Then
    TaskNumGet = Sheet.CellValue(0,0) + 1
  End If
End Function

Sub AddFile(Obj)
  fDef = "FILE_" & Obj.ObjectDefName
  't_= Obj.Attributes("ATTR_T_TASK_TYPE").Classifier.Code &".docx"
  t_= GetTemplateName(Obj)
  If ThisApplication.FileDefs(fDef).Templates.Has(t_) = False Then t_="default.docx"
  'filename =Obj.Attributes("ATTR_T_TASK_NUM") &".docx"
  filename = GetDefaultFileName(Obj) 
  If filename = vbNullString Then 
    filename = t_
  Else
    filename = filename & ".docx"
  End If

  if Not ThisApplication.ExecuteScript("CMD_S_DLL", "AddFileTempl", Obj,fDef,t_,filename) Then
    Call ThisApplication.ExecuteScript("CMD_S_DLL", "AddFileDial", Obj)
  end if
  Obj.CheckOut
  fn = Obj.WorkFolder & "\" & Obj.Files.Main.FileName
 ' FName = CreatePDF(Obj,fn)
    '  If FName <> "" Then Call LoadFile(Obj,"FILE_E-THE_ORIGINAL",FName)
End Sub

'Установка атрибутов
Private Sub SetAttrs(p_,Obj)
  'Заполняем атрибуты по умолчанию перед открытием окна создания Задания
  Set u = Thisapplication.CurrentUser
  'Исполнитель
  If Obj.Attributes("ATTR_T_TASK_DEVELOPED").Empty Then
    Obj.Attributes("ATTR_T_TASK_DEVELOPED").User = u
  End If
  
  GroupName = "GROUP_LEAD_DEPT"
  
  Set Dept = GetDeptForUserByGroup(u,GroupName)
  
  'Заполняем Отдел
  Obj.Attributes("ATTR_T_TASK_DEPARTMENT").Object = Dept
  If Obj.Attributes("ATTR_T_TASK_DEPARTMENT").Empty Then Exit Sub

  'Заполняем Подписанта
  Set uChief = GetChiefForUserByGroup(u,GroupName)
  
  If Not uChief Is Nothing and Obj.Attributes.Has("ATTR_SIGNER") Then
    Check = true
    If uChief.Groups.Has(GroupName) = False Then
      Check = False
    Else
      If Obj.Attributes("ATTR_SIGNER").Empty = False Then
        If Not Obj.Attributes("ATTR_SIGNER").User Is Nothing Then 
          If Obj.Attributes("ATTR_SIGNER").User.Handle = uChief.Handle Then 
            Check = False
          End If
        End If
      End If
    End If
      If Check Then
        Obj.Attributes("ATTR_SIGNER").User = uChief
      End If
  End If
  
  'Заполняем ответственного
  Set uChief = GetChiefByDept(dept)
  
  If not uChief Is Nothing and Obj.Attributes.Has("ATTR_RESPONSIBLE") Then
    Check = True
    If uChief.Groups.Has(GroupName) = False Then
      Check = False
    Else
      If Obj.Attributes("ATTR_RESPONSIBLE").Empty = False Then
        If Not Obj.Attributes("ATTR_RESPONSIBLE").User Is Nothing Then 
          If Obj.Attributes("ATTR_RESPONSIBLE").User.Handle = uChief.Handle Then 
            Check = False
          End If
        End If
      End If
    End If
    If Check = True Then
      Obj.Attributes("ATTR_RESPONSIBLE").User = uChief
    End If
  End If

  ' Проверяющего оставлять незаполненным при создании задания
  ' Требование заказчика от 12.09.2017
'  'Проверил
'  Set Chief = Nothing
'  Set Dept = GetDept(u)
'  Do While Chief is Nothing
'    If not Dept is Nothing Then
'      Set Chief = GetChiefByDept(Dept)
'      If Chief is Nothing Then
'        If not Dept.Parent is Nothing Then
'          Set Dept = Dept.Parent
'        Else
'          Set Chief = u
'        End If
'      End If
'    Else
'      Exit Do
'    End If
'  Loop
'  Obj.Attributes("ATTR_T_TASK_CHECKED").User = Chief

' Заполняем Утверждающего
' Для проектов по скважинам Утверждающий - это Руководитель управления
' или руководитель элемента оргструктуры, расположенного выше отдела ответственного по заданию
 Set oProj = Obj.Attributes("ATTR_PROJECT").Object
 If Not oProj Is Nothing Then
   Set ProjType = oProj.Attributes("ATTR_PROJECT_WORK_TYPE").Classifier
   If Not ProjType Is Nothing Then
    If ProjType.Description = "Проекты скважин" Then
      Set ParentDept = Dept.Parent
      If Not ParentDept Is Nothing Then
        Obj.Attributes("ATTR_DOCUMENT_CONF").User = GetChiefByDept(ParentDept)
      End If
    End If
   End If
 End If
 
 ' Если проект не по скважинам, то ищем ГИПа
  If Obj.Attributes("ATTR_DOCUMENT_CONF").Empty = True Then
'    Set uGIP = GetProjectGip(p_)
    Set uGIP = GetDefaultDocApprover(p_)
    If Not uGIP Is Nothing Then
      If Obj.Attributes.Has("ATTR_DOCUMENT_CONF") Then
        Check = true
        If Obj.Attributes("ATTR_DOCUMENT_CONF").Empty = False Then
          If Not Obj.Attributes("ATTR_DOCUMENT_CONF").User Is Nothing Then 
            If Obj.Attributes("ATTR_DOCUMENT_CONF").User.Handle = uGIP.Handle Then 
              Check = False
            End If
          End If
        End If
        If Check Then
          Obj.Attributes("ATTR_DOCUMENT_CONF").User = uGIP
        End If
      End If
    End If
  End If
  
  ' Заполняем обозначение
  Obj.Attributes("ATTR_T_TASK_NUM") = TaskNumGet(Obj)
  Obj.Attributes("ATTR_T_TASK_CODE").Value = _
    ThisApplication.ExecuteScript("CMD_S_NUMBERING", "TtaskCodeGen",Obj) 
End Sub


'==============================================================================
' Отправка оповещения ответственному проектировщику о назначении его ответственным
'------------------------------------------------------------------------------
' o_:TDMSObject - взятый комплект на нормоконтроль
'==============================================================================
Private Sub SendMessage(o_)
  Dim u
  Dim cu
  Set cu = ThisApplication.CurrentUser
  ' Оповещение Разработчику задания
  For Each r In o_.RolesByDef("ROLE_T_TASK_DEVELOPER")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    
    If Not u.Handle = cu.Handle Then
      ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 3501, u, o_, Nothing, o_.Description, cu.Description
    End If
  Next
  ' Оповещение Ответственному за подготовку задания
  For Each r In o_.RolesByDef("ROLE_T_TASK_OUT_CHECKER")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    
    ' Отправляем оповещение, если получатель - другой пользователь
    If Not u.Handle = cu.Handle Then
      ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 3502, u, o_, Nothing, o_.Description, cu.Description
    End If
  Next
End Sub

'Функция формирует имя для первого файла задания
Function FirstFileNameGet(Obj,File)
  FirstFileNameGet = File.FileName
  str = GetTaskFileName(Obj)
  If str = vbNullString Then Exit Function
  Fname = File.FileName
  FShortName = Right(FName, Len(Fname) - InStrRev(FName, "\"))
  Fname = Left(FShortName, InStrRev(FShortName, ".")-1)
  Ftype = Right(FShortName, Len(FShortName)-InStrRev(FShortName, ".")+1)
  
  str = str & Ftype
  If str <> Ftype Then FirstFileNameGet = str
End Function

Function GetTaskFileName(Obj)
  GetTaskFileName = vbNullString
  Set Project = Nothing
  If Obj.Attributes("ATTR_PROJECT").Empty = False Then
    If not Obj.Attributes("ATTR_PROJECT").Object is Nothing Then
      Set Project = Obj.Attributes("ATTR_PROJECT").Object
    End If
  End If
  If Project is Nothing Then Exit Function
  GetTaskFileName = "ЗПО № " & Project.Attributes("ATTR_PROJECT_CODE").Value & "-" &_
    Obj.Attributes("ATTR_T_TASK_NUM").Value
End Function


'Sub File_Added(File, Object)
'  ThisScript.SysAdminModeOn
'  'Переименование первого файла
'  If Object.Files.Count = 1 Then
'    File.FileName = FirstFileNameGet(Object,File)
'  End If
'End Sub


Sub Object_CheckedIn(Obj)
  'Запись в журнал сессиий - Загружен
  ThisApplication.ExecuteScript "CMD_DLL", "TsessionRowCreate", Obj, True
End Sub

Sub Object_BeforeCheckOut(Obj, Cancel)
  'Запись в журнал сессиий - Выгружен
  ThisApplication.ExecuteScript "CMD_DLL", "TsessionRowCreate", Obj, False
End Sub


' Процедура запускается 
Sub SendOrder(Obj)

  If Obj.StatusName <> "STATUS_T_TASK_IS_APPROVING" Then Exit Sub

  Set uToUser = Obj.Attributes("ATTR_DOCUMENT_CONF").User
'  If uToUser Is Nothing Then Exit Sub

  Set Users = ThisApplication.CreateCollection(tdmUsers)
  
  If Users.Has(uToUser) = False Then Users.Add uToUser
  
  Set oProj = Obj.Attributes("ATTR_PROJECT").Object

  Set TableRows = oProj.Attributes("ATTR_GIP_DEPUTIES").Rows
  For Each Row in TableRows
    If Row.Attributes("ATTR_USER").Empty = False Then
      Set User = Row.Attributes("ATTR_USER").User
      If Users.Has(User) = False Then Users.Add User
    End If
  Next
  
  If Users.count = 0 Then Exit Sub
  
  Set uFromUser = Obj.Attributes("ATTR_T_TASK_DEVELOPED").User
  If uFromUser Is Nothing Then 
    Set uFromUser = ThisApplication.CurrentUser
  End If
  
  resol = "NODE_KD_APROVER"
  txt = "Прошу утвердить задание """ & Obj.Description & """"
  planDate = DateAdd ("d", 1, Date)
    
  For each user In Users
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",User,uFromUser,resol,txt,planDate
  Next
End Sub


Sub File_CheckedIn(File, Object)
  Call FileChkInProcessing(File, Object)
End Sub

Sub File_Erased(File, Object)
  thisScript.SysAdminModeOn
  Call ThisApplication.ExecuteScript("OBJECT_DOC","File_Erased",File, Object)
'   pdfFileName = ThisApplication.ExecuteScript("OBJECT_KD_BASE_DOC","getFileName",File.FileName) & "###.pdf"
'   if object.Files.Has(pdfFileName) then 
'      on error resume next
'      object.Files(pdfFileName).Erase
'      if err.Number<> 0 then err.Clear
'      on error goto 0
'    end if
End Sub

Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
  Thisscript.SysAdminModeOn
'  ThisApplication.AddNotify "OBJECT_T_TASK - Object_PropertiesDlgBeforeClose"
  Set Dic = ThisApplication.Dictionary(Obj.Handle)

  If OkBtnPressed = True Then
    chk = ThisApplication.ExecuteScript("CMD_S_DLL","CheckBeforeClose",Obj)
    Cancel = (Not chk)
    If Cancel Then Exit Sub
    If IsEmpty(Dic) Then Exit Sub
    If Dic.Exists("oldResp") Then
      set oldrespuser = ThisApplication.Users(Dic.Item("oldResp"))
      If Not oldrespuser Is Nothing Then 
        Call ThisApplication.ExecuteScript("CMD_DOC_DEVELOPER_APPOINT","SendOrderToResp",Obj,"oldResp",oldrespuser)
      End If
      Dic.Remove("oldResp")
    End If
    If Dic.Exists("newResp") = True Then
      set newrespuser = ThisApplication.Users(Dic.Item("newResp"))
      If Not newrespuser Is Nothing Then 
        Call ThisApplication.ExecuteScript("CMD_DOC_DEVELOPER_APPOINT","SendOrderToResp",Obj,"newResp",newrespuser)
      End If
      Dic.Remove("newResp")
    End If
    
'    ' -- > Case 5641 --
'    If chk Then
'      Set oOld = ThisApplication.GetObjectByGUID(Obj.GUID)
'      If Not oOld Is Nothing Then
'        'iNewCount = oOld.Attributes("ATTR_DOCS_TLINKS").Rows.Count
'        'iOldCount = Obj.Attributes("ATTR_DOCS_TLINKS").Rows.Count
'        'If iNewCount <> iOldCount Then
'        If IsTableModified(oOld.Attributes("ATTR_DOCS_TLINKS").Rows, Obj.Attributes("ATTR_DOCS_TLINKS").Rows) Then
'          Set uChief = GetChiefByDept(Obj.Attributes("ATTR_T_TASK_DEPARTMENT").Object) 
'          If uChief Is Nothing Then Exit Sub
'          mBody = _
'            "Пользователь " + ThisApplication.CurrentUser.Description + _
'            " изменил состав таблицы ""Результирующие документы"" задания """ + _ 
'            Obj.Description + _
'            """. Для просмотра изменений перейдите на вкладку Задание.Связи."
'          Call SendMail(uChief, "Изменения задания " + Obj.Description, Obj, False, mBody, False)
'        End If
'      End If
'    End If
'    ' -- Case 5641 < --
  End If
  Set dict = ThisApplication.Dictionary(Obj.GUID)
  If ThisApplication.ExecuteScript("FORM_PROJECT_PARTS_LINKED","userIsReciever",Obj,ThisApplication.CurrentUser) Then 
    If dict.Exists("ORes") Then
      Call CheckIfTableModified(Obj)
    End If
  End IF
  
  if obj.permissions.view <> 0 then
    if thisObject.Permissions.LockOwner then 
      if ThisObject.Permissions.Locked = true Then 
        ThisObject.Unlock ThisObject.Permissions.LockType
      end if
    end if
  end if
End Sub

' Проверка изменений таблицы результатов
Sub CheckIfTableModified(Obj)
    ''''''''''''''''''''''''''''''''''''''''''''
    Set col2 = Thisapplication.CreateCollection(TDMSObjects)
'    Set rows = Obj.Attributes("ATTR_DOCS_TLINKS").Rows
    Set rows = Obj.Attributes("ATTR_KD_T_LINKS").Rows
    For each row in rows
      Set o = row.Attributes("ATTR_KD_LINKS_DOC").Object
      If Not o Is Nothing Then
        col2.add row.Attributes(0).Object
      End If
    Next
    Set dict = ThisApplication.Dictionary(Obj.GUID)
    Set oldObj = dict.Item("ORes")
    
    If IsTableModified(oldObj, col2) Then
          Set uChief = GetChiefByDept(Obj.Attributes("ATTR_T_TASK_DEPARTMENT").Object) 
          If uChief Is Nothing Then Exit Sub
          mBody = _
            "Пользователь " + ThisApplication.CurrentUser.Description + _
            " изменил состав таблицы ""Результирующие документы"" задания """ + _ 
            Obj.Description + _
            """. Для просмотра изменений перейдите на вкладку Задание.Связи."
          Call SendMail(uChief, "Изменения задания " + Obj.Description, Obj, False, mBody, False)
    End If
    dict.Remove("ORes")
End Sub
' -- > Case 5641 --
Function IsTableModified(tOld, tNew)
  ThisApplication.DebugPrint "IsTableModified " & Time
  IsTableModified = True
  for each o In tOld
    If tNew.Has(o) = False Then Exit Function
  Next
  
  For each o In tNew
    If tOld.Has(o) = False Then Exit Function
  Next
  
'  If tOld.Count <> tNew.Count Then Exit Function
'  iRow = 0
'  For Each r In tOld
'    Set nRow = tNew.Item(iRow)
'    For Each attr In r.Attributes
'      If attr.Value <> nRow.Attributes(attr.AttributeDefName).Value Then Exit Function
'    Next
'    iRow = iRow + 1
'  Next
  IsTableModified = False
  ThisApplication.DebugPrint IsTableModified & " " & Time
End Function
' -- Case 5641 < --

'=============================================
' конечные статусы
' статусы из которых нельзя возвращать в работу
function Check_FinishStatus(stName)
  Check_FinishStatus = (stName = "STATUS_T_TASK_APPROVED") or _
                        (stName = "STATUS_T_TASK_INVALIDATED")
end function

'Т.е. функция должна называться Check_FinishStatus(stName) и в нее передается текущий статус объекта
'Создавать ее надо для кажного типа объекта, а не для родителя

' Тогда для каждого типа объекта необходимо определить функцию, 
' которая возвращает список доступных для добавления типов файлов по статусам и возможностям пользователя.  
' В функцию передается текущий документ 
'=============================================
function GetTypeFileArr(docObj)
  Set CU = thisApplication.CurrentUser
  isInit  = IsInitiator(docObj,CU)
  isCanAppr = ThisApplication.ExecuteScript("CMD_KD_USER_PERMISSIONS","IsCanAprove",CU,docObj)
  
  st = docObj.StatusName
  select case st
    case "STATUS_T_TASK_IN_WORK"
      if IsDeveloper(docObj,CU)  then _
          GetTypeFileArr = array("Задание","Приложение","Скан документа")  
    case "STATUS_T_TASK_IS_CHECKING"
      if IsChecker(docObj,CU) then _
          GetTypeFileArr = array("Задание","Приложение","Скан документа")  
    case "STATUS_T_TASK_IS_SIGNING"
      if IsSigner(docObj,CU) then _
          GetTypeFileArr = array("Скан документа")  
    case "STATUS_KD_AGREEMENT"
      if isCanAppr then _
          GetTypeFileArr = array("Скан документа")  
    case "STATUS_T_TASK_IS_APPROVING"
      if ThisApplication.ExecuteScript("FORM_S_TASK","userIsAcceptor",docObj,CU) then _
          GetTypeFileArr = array("Скан документа")  
  end select
end function

Sub Object_PropertiesDlgInit(Dialog, Obj, Forms)
  Call ShowDefaultForm(Dialog, Obj, Forms)

  ' Закрываем информационные поручения 
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_CORR_REZOL_INF")
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_STAT_MAIN")
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_DEL_MAIN")
  ' отмечаем все поручения по документу прочитанными
  'if obj.StatusName <> "STATUS_T_TASK_IN_WORK" then _
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","Set_OrdersReaded",Obj
  
  If ThisApplication.ExecuteScript("FORM_PROJECT_PARTS_LINKED","userIsReciever",Obj,ThisApplication.CurrentUser) Then 
    Call SaveResTable(Obj)
  End If
End Sub

' Запоминаем содержимое таблицы результатов, чтобы потом сравнить и выдать оповещение ответственному
Sub SaveResTable(Obj)
    '----------------------
    Set col = Thisapplication.CreateCollection(TDMSObjects)
'    Set rows = Obj.Attributes("ATTR_DOCS_TLINKS").Rows
    Set rows = Obj.Attributes("ATTR_KD_T_LINKS").Rows
    For each row in rows
      Set o = row.Attributes("ATTR_KD_LINKS_DOC").Object
      If Not o Is Nothing Then
        col.add row.Attributes("ATTR_KD_LINKS_DOC").Object
      End If
    Next
    Set dict = ThisApplication.Dictionary(Obj.GUID)
    Set dict.Item("ORes") = col
End Sub

Sub TaskLoopIncrease(Obj)
  If Obj.Attributes.Has("ATTR_LOOP") = True Then
    num = Obj.Attributes("ATTR_LOOP") + 1
    Obj.Attributes("ATTR_LOOP") = num
  End If
End Sub

'================================================================================
' Ищем папку Задания в проекте
'--------------------------------------------------------------------------------
' StartObj:TDMSObject - Объект, на котором выполняется команда создания задания
' GetTaskFolder:TDMSObject - Объект - контейнер для задания
'================================================================================
Function GetTaskFolder(StartObj)
  ThisApplication.DebugPrint "GetTaskFolder" & Time
  Set GetTaskFolder = Nothing
  If StartObj.Attributes.Has("ATTR_PROJECT") = False Then Exit Function
  Set oProj = StartObj.Attributes("ATTR_PROJECT").Object
  
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "OBJECT_T_TASKS"
  q.AddCondition tdmQueryConditionAttribute, oProj, "ATTR_PROJECT"
  If q.Objects.count = 0 Then Exit Function
  Set GetTaskFolder = q.Objects(0)
End Function

function CanIssueOrder(DocObj)
'  CanIssueOrder = false
'  docStat = DocObj.StatusName
'  str = ";STATUS_T_TASK_IS_CHECKING;STATUS_T_TASK_IS_SIGNING;STATUS_T_TASK_APPROVED;"
'  if Instr(";" & str & ";", ";" & docStat & ";") > 0 then _
      CanIssueOrder = true
end function

Function CopyAttrsFromDocBase(newObj, docBase)
  CopyAttrsFromDocBase = False
  Set oProj = docBase.Attributes("ATTR_PROJECT").Object
  If Not oProj Is Nothing Then
    Set oContr = oProj.Attributes("ATTR_CONTRACT").Object
    If Not oContr Is Nothing Then
      If NewObj.Attributes.Has("ATTR_KD_AGREENUM") Then
        NewObj.Attributes("ATTR_KD_AGREENUM").Object = oContr
      End If
    End If
  End If
  CopyAttrsFromDocBase = True
End function

'*********************************************************************************************
'                                                                                            *
'                                 ВНЕШНИЕ ФУНКЦИИ                                            *
'                                                                                            *
'*********************************************************************************************

'=============================================================================================

Extern GetTaskResp [Alias ("Ответственный"), HelpString ("Ответственный")]
Function GetTaskResp(Obj) 
  GetTaskResp = " "
  Set user = Obj.Attributes("ATTR_RESPONSIBLE").User
  If user Is Nothing Then Exit Function
  GetTaskResp = user.Description
End Function
'=============================================================================================
Extern GetTaskRespFIO [Alias ("Ответственный. ФИО"), HelpString ("Ответственный ФИО")]
Function GetTaskRespFIO(Obj) 
  GetTaskRespFIO = " "
  Set user = Obj.Attributes("ATTR_RESPONSIBLE").User
  If user Is Nothing Then Exit Function
  GetTaskRespFIO= user.Attributes("ATTR_KD_FIO")
End Function
'=============================================================================================
Extern GetTaskCheck [Alias ("Проверил"), HelpString ("Проверил")]
Function GetTaskCheck(Obj) 
  GetTaskCheck = " "
  Set user = Obj.Attributes("ATTR_USER_CHECKED").User
  If user Is Nothing Then _
    Set user = Obj.Attributes("ATTR_T_TASK_CHECKED").User
  If user Is Nothing Then Exit Function
  GetTaskCheck = user.Description
End Function
'=============================================================================================
Extern GetTaskCheckFIO [Alias ("Проверил. ФИО"), HelpString ("Проверил ФИО")]
Function GetTaskCheckFIO(Obj) 
  GetTaskCheckFIO = " "
  Set user = Obj.Attributes("ATTR_USER_CHECKED").User
  If user Is Nothing Then _
    Set user = Obj.Attributes("ATTR_T_TASK_CHECKED").User
  If user Is Nothing Then Exit Function
  GetTaskCheckFIO= user.Attributes("ATTR_KD_FIO")
End Function
'=============================================================================================
