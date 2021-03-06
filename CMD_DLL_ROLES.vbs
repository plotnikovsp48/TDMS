' Автор: Стромков С.А.
'
' Библиотека функций для работы с ролями. В дополнение к CMD_DLL
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

USE "CMD_S_DLL"
'==============================================================================
' Функция Создает роль на объекте, если ее нет
'------------------------------------------------------------------------------
' o_:TDMSObject - Обрабатываемый информационный объект
' sRole_:String - Системный идентификатор роли
' u_:String - Системный идентификатор пользователя или группы
' AddRole:Boolean - Результат выполнения. True - создана
'==============================================================================
Private Function AddRole(o_,u_,sRole_)
  AddRole = False
  ' Если роль отсутствует на объекте, то создаем
  Dim result
  If Not o_.Roles.Has(sRole_) Then 
    result = ThisApplication.ExecuteScript ("CMD_DLL","SetRole",o_,sRole_,u_)
    If Not result Then Exit Function
  End If
  AddRole = True
End Function

'==============================================================================
' Метод удаляет с объекта o_ роли vRoleDef_ для пользователя
' Если vRoleDef_ пустой - удаляет все роли. 
'------------------------------------------------------------------------------
' o_:TDMSObject - Текущий объект
' u_:TDMSUser - пользователь. для кого удаляется роль
' sRole_:String - Системное имя роли
' RemoveRoles:Void()
'==============================================================================
Sub RemoveRoleForUser(o_,u_,sRole_)
  o_.Permissions = SysAdminPermissions
  ' Удаляем роли sRole_
    For Each rToRemove In o_.RolesForUser(u_)
      If sRole_ = "" Then 
        rToRemove.Erase
      ElseIf rToRemove.RoleDefName = sRole_ Then
        rToRemove.Erase
      End If 
    Next
End Sub

'==============================================================================
' Метод удаляет с объекта o_ роли vRoleDef_ для пользователя
' Если vRoleDef_ пустой - удаляет все роли. 
'------------------------------------------------------------------------------
' o_:TDMSObject - Текущий объект
' u_:TDMSUser - пользователь. для кого удаляется роль
' sRole_:String - Системное имя роли
' RemoveRoles:Void()
'==============================================================================
Sub RemoveRole(o_,sRole_)
  o_.Permissions = SysAdminPermissions
  ' Удаляем роли sRole_
  If o_.Roles.Has(sRole_) Then
    For Each rToRemove In o_.RolesByDef(sRole_)
'      If sRole_ = "" Then 
        rToRemove.Erase
'      ElseIf rToRemove.RoleDefName = sRole_ Then
'        rToRemove.Erase
'      End If 
    Next
  End If
End Sub

'==============================================================================
' Процедура назначает пользователя на роль. Если роль отсутствует на объекте, то создаем
'------------------------------------------------------------------------------
' o_:TDMSObject - Обрабатываемый информационный объект
' sRole_:String - Системный идентификатор роли
' u_:String - Системный идентификатор пользователя или группы
'==============================================================================
Private Sub ChangeRole(o_,u_,sRole_)
  ' Если роль отсутствует на объекте, то создаем
  If Not AddRole(o_,u_,sRole_) Then Exit Sub
  o_.Permissions = SysAdminPermissions
  For Each r In o_.RolesByDef(sRole_)
    r.User = u_
  Next
End Sub

'==============================================================================
'Процедура обновления полностью зависимой от атрибута роли (синхронизация)
'------------------------------------------------------------------------------
'Obj:Object - Ссылка на объект
'AttrName:String - Системное имя атрибута
'RoleName:String - Системное имя роли
'==============================================================================
Public Sub UpdateAttrRole(Obj,AttrName,RoleName)
  ThisScript.SysAdminModeOn
  Set Roles = Obj.RolesByDef(RoleName)
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      Set u = Obj.Attributes(AttrName).User
      If u Is Nothing Then Exit Sub
      If Roles.Count > 0 Then
        'Меняем существующие роли
        For Each Role in Roles
          If not Role.User is Nothing Then
            If Role.User.SysName <> u.SysName Then Role.User = u
          Else
            Role.User = u
          End If
        Next
      Else
        'Создаем новые роли
        Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,u.SysName)
      End If
    Else
      'Стираем роли
      If Roles.Count > 0 Then
        For Each Role in Roles
          Role.Erase
        Next
      End If
    End If
  End If
  ThisScript.SysAdminModeOff
End Sub

Public Sub UpdateAttrRoles(Obj,AttrName,RoleNameList)
  ThisScript.SysAdminModeOn
  ArrRoles = Split(RoleNameList,",")
  For Each Role In ArrRoles
    If Obj.Roles.Has(Role) Then
        Call UpdateAttrRole(Obj,AttrName,Role)
    End If
  Next
  ThisScript.SysAdminModeOff
End Sub

'==============================================================================
' Выбор пользователя из группы
'------------------------------------------------------------------------------
' g_:TDMSGroup - Группа пользователй
' SelectUserByGroup:TDMSUser - Выбранный пользователь
'==============================================================================
Function SelectUserByGroup(g_)
  Set SelectUserByGroup = Nothing
  If Not ThisApplication.Groups.Has(g_) Then Exit Function
  Set dSelectUser = ThisApplication.Dialogs.SelectUserDlg
    Set ug = ThisApplication.Groups(g_).Users
    If ug.Count > 0 Then
      dSelectUser.SelectFromUsers = ug
      If dSelectUser.Show Then 
        If dSelectUser.Users.Count > 0 Then Set SelectUserByGroup = dSelectUser.Users(0)
      End If
    Else
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1040, ThisApplication.Groups(g_).Description
    End If
End Function

'==============================================================================
' Выбор пользователей из группы
'------------------------------------------------------------------------------
' g_:TDMSGroup - Группа пользователй
' SelectUsersByGroup:TDMSUser - Выбранный пользователь
'==============================================================================
Function SelectUsersByGroup(g_)
  Set SelectUsersByGroup = Nothing
  If Not ThisApplication.Groups.Has(g_) Then Exit Function
  Set dSelectUser = ThisApplication.Dialogs.SelectUserDlg
    Set ug = ThisApplication.Groups(g_).Users
    If ug.Count > 0 Then
      dSelectUser.SelectFromUsers = ug
      If dSelectUser.Show Then 
        If dSelectUser.Users.Count > 0 Then Set SelectUsersByGroup = dSelectUser.Users
      End If
    Else 
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1040, ThisApplication.Groups(g_).Description
    End If
End Function


'==============================================================================
' Заполнение атрибута объекта "Ответственный"
'------------------------------------------------------------------------------
' o_:TDMSObject - Обрабатываемый информационный объект
' u_:TDMSUser - Назначаемый пользователь
'==============================================================================
Sub SetResponsible (o_,u_)
ThisApplication.DebugPrint "SetResponsible "
  aDefName = "ATTR_RESPONSIBLE"
  If Not ThisApplication.AttributeDefs.Has(aDefName) Then Exit Sub
  If u_ Is Nothing Or VarType(u_)<>9 Then Exit Sub
  
  ' Если нет атрибута - добавляем
  If Not o_.Attributes.Has(aDefName) Then o_.Attributes.Create(aDefName)
  o_.Attributes(aDefName).User = u_
End Sub


'==============================================================================
' Проверка вхождения пользователя в группу с выдачей сообщения
'------------------------------------------------------------------------------
' u_:TDMSUser - Назначаемый пользователь
' gr_:TDMSGroup - Системное наименование группы
'==============================================================================
Function IsGroupMemberMessage(u_,gr_)
  IsGroupMemberMessage = False
  If u_ Is Nothing Or VarType(u_)<>9 Then Exit Function
  If Not ThisApplication.Groups.Has(gr_) Then Exit Function
  g = ThisApplication.Groups(gr_).Description
  
  If Not IsGroupMember(u_,gr_) Then 
    Call ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbCritical, 1030,g)
    Exit Function
  End If
  IsGroupMemberMessage = True
End Function

'==============================================================================
' Проверка вхождения пользователя в группу
'------------------------------------------------------------------------------
' u_:TDMSUser - Назначаемый пользователь
' gr_:TDMSGroup - Системное наименование группы
'==============================================================================
Function IsGroupMember(u_,gr_)
  IsGroupMember = False
  If u_ Is Nothing Or VarType(u_)<>9 Then Exit Function
  If Not ThisApplication.Groups.Has(gr_) Then Exit Function
  If Not ThisApplication.Groups(gr_).Users.Has(u_) Then Exit Function
  IsGroupMember = True
End Function


'==========================================================
' Возвращает ГИПа проекта
'----------------------------------------------------------
' o_:TDMSObject - Объект внутри проекта
' GetProjectGip:TDMSUser   Ссылка на ГИПа проекта
'                     Nothing - ГИП не задан          
'==========================================================
Function GetProjectGip(o_)
  ThisScript.SysAdminModeOn
  Set GetProjectGip = Nothing
 
  ' Проверка входных параметров
  If VarType(o_) <> 9 Then Exit Function
  If o_ Is Nothing Then Exit Function
  aGip = "ATTR_PROJECT_GIP"
  aProj = "ATTR_PROJECT"
  
  Set oProj = Nothing
  If o_.Attributes.Has(aProj) Then 
    If o_.Attributes(aProj).Empty = False Then
      If Not o_.Attributes(aProj).Object Is Nothing Then
        Set oProj = o_.Attributes(aProj).Object
      End If
    End If
  End If

  If oProj Is Nothing Then Set oProj = GetUplinkObj(o_,"OBJECT_PROJECT")
  If oProj Is Nothing Then Exit Function
  
  If oProj.Attributes.Has(aGip) Then
    If oProj.Attributes(aGip).Empty = False Then
      If not oProj.Attributes(aGip).User is Nothing Then
        Set GetProjectGip = oProj.Attributes(aGip).User
      End If
    End If
  End If
End Function

' Определяем Утверждающего по умолчанию
' Для Заданий, Чертежей, Проектных документов
Function GetDefaultDocApprover(o_)
  ThisScript.SysAdminModeOn
  Set GetDefaultDocApprover = Nothing
 
  ' Проверка входных параметров
  If VarType(o_) <> 9 Then Exit Function
  If o_ Is Nothing Then Exit Function
  aGip = "ATTR_PROJECT_GIP"
  aProj = "ATTR_PROJECT"
  
  Set oProj = Nothing
  If o_.Attributes.Has(aProj) Then 
    If o_.Attributes(aProj).Empty = False Then
      If Not o_.Attributes(aProj).Object Is Nothing Then
        Set oProj = o_.Attributes(aProj).Object
      End If
    End If
  End If

  If oProj Is Nothing Then Set oProj = GetUplinkObj(o_,"OBJECT_PROJECT")
  If oProj Is Nothing Then Exit Function
  
  Set Table = oProj.Attributes("ATTR_GIP_DEPUTIES")
  Set CU = ThisApplication.CurrentUser
  Set Dept = CU.Attributes("ATTR_KD_DEPART").Object
  
  For each row In Table.Rows
    Set user = row.attributes("ATTR_USER").User
    If Not user Is Nothing Then
      Set userdept = user.Attributes("ATTR_KD_DEPART").Object
      If IsTheSameObj(Dept,userdept) Then
        Set GetDefaultDocApprover = user
        Exit Function
      End If
    End If
  Next
    
  If oProj.Attributes.Has(aGip) Then
    If oProj.Attributes(aGip).Empty = False Then
      If not oProj.Attributes(aGip).User is Nothing Then
        Set GetDefaultDocApprover = oProj.Attributes(aGip).User
      End If
    End If
  End If
End Function


'==============================================================================
' Процедура назначения ролей согласования
'------------------------------------------------------------------------------
' Obj:TDMSObject - Объект согласования, Поручение
'==============================================================================
Sub Set_Tech_Permission (Obj)
  ' По требованию договорников вернули возможность согласующим редактировать файлы 17.01.2018
  ' т.к. роль Согласующий дает права на редактирование файлов.
  ' Роль назначается на все объекты ТД, которые передаются на согласование
  Call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS","Add_Aprove",Obj)
  
'  Call Add_User_Role(Obj)
  
  If Obj.IsKindOf("OBJECT_CONTRACT") = False Then
    Call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS","Add_Role",Obj,"Пользователь","Все пользователи",false)
  End If
End Sub

sub Add_User_Role(docObj)
'  Call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS","Add_Aprove",docObj)
'  set agreeObj =  thisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "GetAgreeObjByObj",docObj)
'  if agreeObj is nothing then exit sub
'  
'  Set TAttrRows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows
'  for each row in TAttrRows
'      set user = Row.Attributes("ATTR_KD_APRV").user
'      if not user is nothing then  
'        
'        Call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS","Add_Role",docObj,"Согласующий",user.SysName,false)
'      end if
'  next
end sub


'==============================================================================
' Процедура преобразования роли "Инициатор согласования"
'------------------------------------------------------------------------------
' Obj:TDMSObject - Объект с ролью (Объект уже перешел в нужный статус)
' StatusName:TDMSstring - Системное имя статуса перехода
'==============================================================================
Sub InitiatorModified (Obj,StatusName)
  ThisScript.SysAdminModeOn
  RoleIni = "ROLE_INITIATOR"
  Set User = Nothing
  If StatusName = "" Then
    StatusName = Obj.StatusName
  End If
  If Obj is Nothing Then Exit Sub
  
  'Модификация роли в зависимости от типа объекта
  'Тендерная документация
  Select Case Obj.ObjectDefName
    'Внешняя закупка
    Case "OBJECT_PURCHASE_OUTSIDE"
      Set User = UserForRoleGet(Obj, "ROLE_PURCHASE_RESPONSIBLE", "")
    'Внутренняя закупка
    Case "OBJECT_TENDER_INSIDE"
      Set User = UserForRoleGet(Obj, "ROLE_PURCHASE_RESPONSIBLE", "")
    'Документ закупки
    Case "OBJECT_PURCHASE_DOC"
      Set User = UserForRoleGet(Obj, "ROLE_TENDER_DOCS_RESP_DEVELOPER", "")
  End Select
  
  'Модификация роли в зависимости от статуса объекта
  Select Case StatusName
    Case "STATUS_T_TASK_IN_WORK"
      Set User = UserForRoleGet(Obj, "ROLE_T_TASK_DEVELOPER", "ATTR_T_TASK_DEVELOPED")
    Case "STATUS_T_TASK_IS_CHECKING"
      Set User = UserForRoleGet(Obj, "ROLE_CHECKER", "ATTR_T_TASK_CHECKED")
    Case "STATUS_T_TASK_IS_SIGNING"
      Set User = UserForRoleGet(Obj, "ROLE_SIGNER", "ATTR_SIGNER")
    Case "STATUS_T_TASK_IS_SIGNED"
      Set User = UserForRoleGet(Obj, "ROLE_T_TASK_DEVELOPER", "ATTR_T_TASK_DEVELOPED")
  End Select
  
  If not User is Nothing Then
    If Obj.Roles.Has(RoleIni) = False Then
      Check = AddRole(Obj,User,RoleIni)
    Else
      Set Roles = Obj.RolesByDef(RoleIni)
      For Each Role in Roles
        If InStr(User.SysName,"GROUP") = 0 and InStr(User.SysName,"ALL") = 0 Then
          Role.User = User
        Else
          Role.Group = User
        End If
      Next
    End If
  End If
End Sub

'==============================================================================
' Функция получения пользователя или группы для роли
'------------------------------------------------------------------------------
' Obj:TDMSObject - Объект с ролью (Объект уже перешел в нужный статус)
'==============================================================================
Function UserForRoleGet (Obj, RoleName, AttrName)
  Set UserForRoleGet = Nothing
  If Obj is Nothing Then Exit Function
  Set Roles = Obj.RolesByDef(RoleName)
  If Roles.Count > 0 Then
    Set Role = Roles(0)
    If not Role.User is Nothing Then
      Set UserForRoleGet = Role.User
    Else
      Set UserForRoleGet = Role.Group
    End If
    Exit Function
  End If
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      If not Obj.Attributes(AttrName).User is Nothing Then
        Set UserForRoleGet = Obj.Attributes(AttrName).User
      End If
    End If
  End If
End Function

' Проверка, имеет ли текущий пользователь права на редактирование структуры объекта
Function IsCanEditContent(Obj)
  IsCanEditContent = False
  Set roles = Obj.RolesForUser(ThisApplication.CurrentUser)
  For Each role In Roles
     select case role.RoleDef.Permissions.EditContent
      case 1:IsCanEditContent = true
      case 2:IsCanEditContent = false
          exit function 
     end select  
  Next     
End Function

' Проверка, имеет ли текущий пользователь права на редактирование объекта
Function IsCanEdit(Obj)
  ThisApplication.DebugPrint "IsCanEdit " & Time
  IsCanEdit = False
  Set roles = Obj.RolesForUser(ThisApplication.CurrentUser)
  For Each role In Roles
     select case role.RoleDef.Permissions.Edit
      case 1:IsCanEdit = true
      case 2:IsCanEdit = false
          exit function 
     end select  
  Next     
End Function

' Проверка, имеет ли текущий пользователь права на редактирование файлов
Function IsCanEditFiles(Obj)
  IsCanEditFiles = False
  Set roles = Obj.RolesForUser(ThisApplication.CurrentUser)
  For Each role In Roles
     select case role.RoleDef.Permissions.EditFiles
      case 1:IsCanEditFiles = true
      case 2:IsCanEditFiles = false
          exit function 
     end select  
  Next     
End Function

' Проверка, имеет ли текущий пользователь права на просмотр файлов
Function IsCanViewFiles(Obj)
  IsCanViewFiles = False
  Set roles = Obj.RolesForUser(ThisApplication.CurrentUser)
  For Each role In Roles
     select case role.RoleDef.Permissions.ViewFiles
      case 1:IsCanViewFiles = true
      case 2:IsCanViewFiles = false
          exit function 
     end select  
  Next     
End Function

' Проверка, является ли пользователь автором.
' Если пользователь не задан, то проверяется текущий пользователь
Function IsAuthor(Obj,User_)
  IsAuthor = False
  If Obj Is Nothing Then Exit Function
  If user_ Is Nothing Then 
    Set user = ThisApplication.CurrentUser
  Else
    Set user = user_
  End If
  If Obj.Attributes.Has("ATTR_AUTOR") = False Then
    Obj.Attributes.Create ThisApplication.AttributeDefs("ATTR_AUTOR")
  End If
  Set u = Obj.Attributes("ATTR_AUTOR").User
  If Not u Is Nothing Then 
    If user.Handle = u.Handle Then
      IsAuthor = True
    End If
  Else
    Set Roles = Obj.RolesForUser(User)
    If Roles.Has("ROLE_CONTRACT_AUTOR") Then
      IsAuthor = True
    End If
  End If
End Function

' Проверка пользователя на присутствие с таблице проверяющих, разработчика
' Проверка, является ли пользователь разработчиком или соразработчиком
' Если пользователь не задан, то проверяется текущий пользователь
Function IsDeveloper(Obj,user_)
  IsDeveloper = False
  If Obj Is Nothing Then Exit Function
  If user_ Is Nothing Then 
    Set user = ThisApplication.CurrentUser
  Else
    Set user = user_
  End If
  Set u = Nothing
  Set Roles = Obj.RolesForUser(user)
  Select Case Obj.ObjectDefName
    Case "OBJECT_T_TASK"
      If Roles.Has("ROLE_T_TASK_DEVELOPER") Then 
        IsDeveloper = True
        Exit Function
      Else
        If Obj.Attributes.has("ATTR_T_TASK_DEVELOPED") then
          set u = Obj.Attributes("ATTR_T_TASK_DEVELOPED").user
  '        If u is nothing then exit function
  '        IsDeveloper = (u.SysName = user.SysName)
        End If
      End If
    Case Else
      If Obj.Attributes.Has("ATTR_RESPONSIBLE") Then
        Set u = Obj.Attributes("ATTR_RESPONSIBLE").User
'        If u Is Nothing Then Exit Function
'        IsDeveloper = (u.sysname = user.sysname)
      End If
  End Select
  
  If Not u Is Nothing Then 
    IsDeveloper = (u.sysname = user.sysname) 
  End If
  
  ' Добавляем проверку на соразработчика
  IsDeveloper = IsDeveloper or (Roles.Has("ROLE_CO_AUTHOR") = True)
 
End Function

' Проверка, является ли пользователь проверяющим.
' Если пользователь не задан, то проверяется текущий пользователь
Function IsChecker(Obj,user_)
  IsChecker = False
  If Obj Is Nothing Then Exit Function
  If User_ Is Nothing Then 
    Set User = ThisApplication.CurrentUser
  Else
    Set user = user_
  End If
  Set Roles = Obj.RolesForUser(user)
  If Roles.Has("ROLE_CHECKER") Or Roles.Has("ROLE_DOC_CHECKER") Then 
    IsChecker = True
  Else  
    Select Case Obj.ObjectDefName
      Case "OBJECT_T_TASK"
          If not Obj.Attributes.has("ATTR_T_TASK_CHECKED") then exit function
          set Checker = Obj.Attributes("ATTR_T_TASK_CHECKED").user
          set Checker2 = Obj.Attributes("ATTR_USER_CHECKED").user
          If Checker is nothing then exit function
          If Checker2 Is Nothing Then
            IsChecker = (Checker.SysName = user.SysName)
          Else
            IsChecker = (Checker.SysName = user.SysName) or (Checker2.SysName = user.SysName)
          End If
      Case "OBJECT_CONTRACT_COMPL_REPORT"
          If not Obj.Attributes.has("ATTR_USER_CHECKED") then exit function
          set Checker = Obj.Attributes("ATTR_USER_CHECKED").user
          If Checker is nothing then exit function
          IsChecker = (Checker.SysName = user.SysName)
      Case Else
          If not Obj.Attributes.has("ATTR_CHECKER") then exit function
          set Checker = Obj.Attributes("ATTR_CHECKER").user
          If Checker is nothing then exit function
          IsChecker = (Checker.SysName = user.SysName)
    End Select
  End If
End Function

' Проверка, является ли пользователь проверяющим.
' Если пользователь не задан, то проверяется текущий пользователь
Function IsSigner(Obj,user)
  IsSigner = False
  If Obj Is Nothing Then Exit Function
  If User Is Nothing Then 
    Set us = ThisApplication.CurrentUser
  Else
    Set us = User
  End If
  Set Roles = Obj.RolesForUser(us)
  If Roles.Has("ROLE_TO_SIGN") or Roles.Has("ROLE_SIGNER") Then 
    IsSigner = True
  Else
    If not Obj.Attributes.has("ATTR_SIGNER") then exit function
    set signer = Obj.Attributes("ATTR_SIGNER").user
    If signer is nothing then exit function
    IsSigner = (signer.SysName = us.SysName)
  End If
End Function

' Проверка, является ли пользователь инициатором согласования.
' Если пользователь не задан, то проверяется текущий пользователь
Function IsInitiator(Obj,user)
  IsInitiator = False
  If Obj Is Nothing Then Exit Function
  If User Is Nothing Then 
    Set us = ThisApplication.CurrentUser
  Else
    Set us = User
  End If
  
  Set Roles = Obj.RolesForUser(us)
  If Roles.Has("ROLE_INITIATOR") Then 
    IsInitiator = True
  End If
End Function


' Проверка, является ли пользователь проверяющим.
' Если пользователь не задан, то проверяется текущий пользователь
Function IsAprover(Obj,user)
  IsAprover = False
  If Obj Is Nothing Then Exit Function
  If User Is Nothing Then 
    Set us = ThisApplication.CurrentUser
  Else
    Set us = User
  End If
  Set Roles = Obj.RolesForUser(us)
  If Roles.Has("ROLE_CONFIRMATORY") Then 
    IsAprover = True
  Else
    If not Obj.Attributes.has("ATTR_DOCUMENT_CONF") then exit function
    set Checker = Obj.Attributes("ATTR_DOCUMENT_CONF").user
    If Checker is nothing then exit function
    IsAprover = (Checker.SysName = us.SysName)
  End If
End Function

' Проверяет заблокирован ли объект другим пользователем
' Возвращает True - Если объект заблокирован другим пользователем
' Возвращает False - Если объект заблокирован текущим пользователем или не заблокирован никем
Function IsLocked(Obj,user)
  IsLocked = (IsLockedByUser(Obj,user) = 0)
End Function

' -1 - если объект не заблокирован
' 0 - Если заблокировн другим пользователем
' 1 - Если заблокирован указанным пользователем
Function IsLockedByUser(Obj,user)
  IsLockedByUser = -1
  If Obj Is Nothing Then Exit Function
  If user Is Nothing Then 
    Set u = ThisApplication.CurrentUser
  Else
    Set u = user
  End If
  If Obj.Permissions.Locked = True Then
       If Obj.Permissions.LockUser.Handle <> u.Handle Then
        IsLockedByUser = 0
       Else
        IsLockedByUser = 1
       End If
  Else 
    IsLockedByUser = 1       
  End If
End Function

' проверяет, является пользователь нормоконтролером
Function isNCUser(Obj,user)
  isNCUser = False
  Set Roles = Obj.RolesForUser(user)

  If Not (Roles.Has("ROLE_NK") or Roles.Has("ROLE_VOLUME_PASS_NK") or Roles.Has("ROLE_WORK_DOCS_SET_PASS_NK")) Then Exit Function

  isNCUser = True
End Function

' проверяет, является пользователь планировщиком 
Function isPlanner(Obj,user)
  isPlanner = False
  If Obj Is Nothing Then Exit Function
  If user Is Nothing Then set user = ThisApplication.CurrentUser
  Set resp = Obj.Attributes("ATTR_RESPONSIBLE").user
  If Not resp Is Nothing Then
    Set dept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetDept",resp)
  End If
  
' планировщик в отделе ответственного
  q0 = False
  If Not dept Is Nothing Then
    If dept.RolesForUser(user).Has("ROLE_P_PLAN") Then q0 = True
  End If
  
  'ГИП
  Set gip = GetProjectGip(Obj)
  q1 = False
  If Not Gip Is Nothing Then
    If gip.handle = user.Handle Then
      q1 = True
    End If
  End If

  ' Ответственный на объекте
  q2 = False
  If Not resp Is Nothing Then
    q2 = (resp.Handle = user.Handle)
  End If
'Руководство
q3 = user.Groups.Has("GROUP_CHIEFS") or user.Groups.Has("GROUP_GIP") or user.Groups.Has("GROUP_LEAD_ENGINNERS")

   if q1 or q0 or q2 then
   '   UserPrm = "planner"
     isPlanner = True
   else
      If q3 Then
         UserPrm = "root"
      else   
         UserPrm = "executor"    
      end if   
   end if
End Function

' Проверка, является ли пользователь ГИПом.
' Если пользователь не задан, то проверяется текущий пользователь
Function IsProjectGip(Obj,user)
  IsProjectGip = False
  If Obj Is Nothing Then Exit Function
  If user Is Nothing Then 
    Set u = ThisApplication.CurrentUser
  Else
    Set u = user
  End If
  Set Gip = GetProjectGip(Obj)
  If Gip Is Nothing Then Exit Function
  IsProjectGip = (Gip.handle = u.Handle)
End Function

' Проверка, является ли пользователь Зам ГИПа по проекту.
' Если пользователь не задан, то проверяется текущий пользователь
Function IsProjectGipDep(Obj,user)
  IsProjectGipDep = False
  If Obj Is Nothing Then Exit Function
  Set oProj = GetProject(Obj) 'Obj.Attributes("ATTR_PROJECT").Object
  If oProj Is Nothing Then Exit Function
  If user Is Nothing Then 
    Set u = ThisApplication.CurrentUser
  Else
    Set u = user
  End If
  Set q = ThisApplication.Queries("QUERY_GIP_DEP_FOR_PROJECT")
  q.Parameter("PARAM0") = oProj.handle
  q.Parameter("PARAM1") = u.Handle

  If q.Objects.Count = 0 Then Exit Function
  IsProjectGipDep = True
End Function

Function isGipOrDep(Obj,user)
  isGipOrDep = False
  If Obj Is Nothing Or User Is Nothing Then Exit Function
  isGipOrDep = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsProjectGip",Obj,user) or _
          ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsProjectGipDep",Obj,user)
End Function

Function ObjectIsLockedByUser(Obj)
  Set CU = ThisApplication.CurrentUser
  ObjectIsLockedByUser = false
  If Obj.Permissions.Locked = True Then
    If Obj.Permissions.LockUser.Handle <> CU.Handle  Then
      msgbox "В настоящий момент документ редактируется пользователем " & Obj.Permissions.LockUser.Description & _
      ". Некоторые действия с объектом могут быть недоступны или отклонены.", vbExclamation 
      ObjectIsLockedByUser = true
    end if
  end if  
End Function

Function IsDispatcher(Obj,User_)
  IsDispatcher = False
  If Obj Is Nothing Then Exit Function
  If user_ Is Nothing Then 
    Set user = ThisApplication.CurrentUser
  Else
    Set user = user_
  End If
  Set u = Obj.Attributes("ATTR_PROJECT_DISPATCHER").User
  If Not u Is Nothing Then 
    If user.Handle = u.Handle Then
      IsDispatcher = True
    End If
  Else

  End If
End Function




'==============================================================================
' Отправка поручение на доработку задания
' разработчику задания 
'------------------------------------------------------------------------------
' o_:TDMSObject - разработанное задание
'==============================================================================
Sub SendOrder(Obj)
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","SendOrder_NODE_KD_RETUN_USER",Obj)
'  Set uToUser = Obj.Attributes("ATTR_AUTOR").User
'  If uToUser Is Nothing Then Exit Sub
'  Set uFromUser = ThisApplication.CurrentUser
'  resol = "NODE_KD_RETUN_USER"
'  txt = "акт """ & Obj.Description & """ Причина: " & Obj.VersionDescription
'  planDate = DateAdd ("d", 1, Date) 'Date + 1
'  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
End Sub


Function GetEventType(intEventType, strType)
GetEventType = ""
        Dim EventType

        EventType = Array("Не определен", "Вход пользователя в систему", _
                                                "Выход пользователя из системы", "Создание объекта", "Редактирование объекта", _
                                                "Удаление объекта", "Создание версии объекта", "Удаление версии объекта", _
                                                "Дублирование объекта", "Изменение статуса объекта", "Простановка подписи на объект ", _
                                                "Добавление объекта в состав", "Удаление объекта из состава", "Исполнение команды", _
                                                "Событие общего вида (пользовательское)", "Экспорт объектов TDMS", _
                                                "Импорт объектов TDMS", "Экспорт схемы базы данных", "Ошибка", _
                                                "Добавление файла в файловый состав объекта", "Удаление файла", _
                                                "Выгрузка файла на жесткий диск", "Загрузка файла в хранилище файлов TDMS")
                                                
         Select Case intEventType
                Case tdmEventUndefined 
                    strType = EventType(0)
               Case tdmEventUserLogin 
                    strType = EventType(1)
               Case tdmEventUserLogoff
                    strType = EventType(2)
               Case tdmEventObjectCreate 
                    strType = EventType(3)
               Case tdmEventObjectEdit 
                    strType = EventType(4)
               Case tdmEventObjectRemove 
                    strType = EventType(5)
               Case tdmEventObjectVersion 
                    strType = EventType(6)
               Case tdmEventObjectVersionRemove 
                    strType = EventType(7)
               Case tdmEventObjectDuplicate
                    strType = EventType(8)
               Case tdmEventObjectStatus
                    strType = EventType(9)
               Case tdmEventObjectSigned
                    strType = EventType(10)
               Case tdmEventObjectContentAdd
                    strType = EventType(11)
               Case tdmEventObjectContentRemove
                    strType = EventType(12)
               Case tdmEventCommand 
                    strType = EventType(13)
               Case tdmEventCommon
                    strType = EventType(14)
               Case tdmEventExportObjects 
                    strType = EventType(15)
               Case tdmEventImportObjects
                    strType = EventType(16)
               Case tdmEventExportScheme
                    strType = EventType(17)
               Case tdmEventError
                     strType = EventType(18)
               Case tdmEventFileAdd 
                     strType = EventType(19)
               Case tdmEventFileErase  
                     strType = EventType(20)
               Case tdmEventFileCheckOut 
                     strType = EventType(21)
               Case tdmEventFileCheckIn 
                     strType = EventType(22)
             End Select
  GetEventType = strType
End Function
'==========================================================================================
' Процедура сохранения в словарь данных о предыдущем разработчике и о новом
' Для выдачи поручения о назначении ответственным или о снятии ответственности пользователя
'------------------------------------------------------------------------------------------
' Obj: TDMSObject - объект, на котором меняется ответственный
' Attribute: TDMSAttribute - новый атрибут и новое значение
'                            (пользователь получит поручение о назначении его ответственным)
' OldAttribute: TDMSAttribute - старое значение изменяемого атрибута 
'                               (пользователь получит поручение о снятии ответственности)
'==========================================================================================
Sub ChangeResponsible(Obj,NewUser,OldUser)
  ThisScript.SysAdminModeOn
  ThisApplication.DebugPrint "ChangeResponsible"
    Set Dict = ThisApplication.Dictionary(Obj.Handle)
    If Not Dict Is Nothing Then 
      If Dict.Exists("oldResp") = False Then
          If Not OldUser Is Nothing Then
            dict.Add "oldResp",OldUser.sysname
          End If
      Else
        If Not OldUser Is Nothing Then
          dict.Item("oldResp") = OldUser.sysname
        End If
      End If
    Else
        If Not OldUser Is Nothing Then
          dict.Item("oldResp") = OldUser.sysname
        End If
    End If
    If Not NewUser Is Nothing Then
      dict.Item("newResp") = NewUser.sysname
    End If
End Sub


Sub SetDocDevAppoint(Obj)
  If Obj.Parent.Attributes.Has("ATTR_S_DEPARTMENT") = False Then Exit Sub
  Dim dept
  Set dept = Obj.Parent.Attributes("ATTR_S_DEPARTMENT").Object
  Set us = ThisApplication.ExecuteScript ("CMD_STRU_OBJ_DLL", "GetGroupsChiefsByDept", dept)
      ' Назначаем на роль Назначить разработчика документа руководителей групп отдела и Начальника отдела.
      ' Протокол Тюмень
      Obj.RolesByDef("ROLE_DOC_DEVELOPER_APPOINT").RemoveAll
      For each user In us
        If Obj.ObjectDefName = "OBJECT_DOC_DEV" or Obj.ObjectDefName = "OBJECT_DRAWING" Then
          Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,"ROLE_DOC_DEVELOPER_APPOINT",user)
        End If
      Next
End Sub

'==========================================================
' Возвращает диспетчера проекта
'----------------------------------------------------------
' Obj:TDMSObject - Объект внутри проекта
' GetProjectDispatcher:TDMSUser   Ссылка на диспетчера проекта
'                     Nothing - диспетчер не задан          
'==========================================================
Function GetProjectDispatcher(Obj)
  ThisScript.SysAdminModeOn
  Set GetProjectDispatcher = Nothing
 
  ' Проверка входных параметров
  If VarType(Obj) <> 9 Then Exit Function
  If Obj Is Nothing Then Exit Function
  
  aDefName = "ATTR_PROJECT_DISPATCHER"
  aProj = "ATTR_PROJECT"
  Set oProj = Nothing
  
  If Obj.IsKindOf("OBJECT_PROJECT") Then
    Set oProj = Obj
  Else
    If Obj.Attributes.Has(aProj) Then 
      If Obj.Attributes(aProj).Empty = False Then
        If Not Obj.Attributes(aProj).Object Is Nothing Then
          Set oProj = Obj.Attributes(aProj).Object
        End If
      End If
    End If
    If oProj Is Nothing Then Set oProj = GetUplinkObj(Obj,"OBJECT_PROJECT")
    If oProj Is Nothing Then Exit Function
  End If
  
  If oProj.Attributes.Has(aDefName) Then
    If oProj.Attributes(aDefName).Empty = False Then
      If not oProj.Attributes(aDefName).User is Nothing Then
        Set GetProjectDispatcher = oProj.Attributes(aDefName).User
      End If
    End If
  End If
End Function
