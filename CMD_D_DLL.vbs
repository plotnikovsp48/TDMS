' Библиотека функций Делопроизводство
'------------------------------------------------------------------------------
' Автор: Р.Г.Шишкин, А.В.Орешкин
' Авторское право © ЗАО «СИСОФТ», 2010 г.

'==============================================================================
' Метод создает экземпляр объекта и открывает его карточку. При этом 
' обрабатывается событие "Object_BeforeCreate"
'------------------------------------------------------------------------------
' sObjDef_:String - Системный идентификатор типа создаваемого объекта
' p_:TDMSObject - Родительский объект в составе которого создается новый 
'                 информационный объект
' Create:TDMSObject - Созданный экземпляр объекта
'==============================================================================
Function Create(sObjDef_,p_)
  Dim o,EditObjDlg,hnd
  
  Set Create = Nothing
  
  ' Создание объекта
  If p_ Is Nothing Then
    On Error Resume Next
      Set o = ThisApplication.ObjectDefs(sObjDef_).CreateObject
      Call ThisApplication.ExecuteScript("CMD_D_DLL", "RunEvent",o.ObjectDefName,"Object_BeforeCreate",3,o,Nothing,False)
      Call ThisApplication.ExecuteScript("CMD_D_DLL", "RunEvent",o.ObjectDefName,"Object_Created",2,o,Nothing)
      Call ThisApplication.ExecuteScript("CMD_D_DLL", "RunEvent",o.ObjectDefName,"Object_Modified",1,o)
      hnd =o.Handle
    On Error GoTo 0
  Else
    On Error Resume Next
      Set o = p_.Objects.Create(sObjDef_)
      Call ThisApplication.ExecuteScript("CMD_D_DLL", "RunEvent",o.ObjectDefName,"Object_BeforeCreate",3,o,p_,False)
      Call ThisApplication.ExecuteScript("CMD_D_DLL", "RunEvent",o.ObjectDefName,"Object_Created",2,o,p_)
      Call ThisApplication.ExecuteScript("CMD_D_DLL", "RunEvent",o.ObjectDefName,"Object_Modified",1,o)
      hnd =o.Handle
    On Error GoTo 0 
  End If
   
  If Err.Number<>0 Then Exit Function
  
  ' T4FIX: Объект ещё не сохранён в базу, поэтому получение его в 4-ке заведомо даст nothing
  'Set o = ThisApplication.Utility.GetObjectByHandle(hnd)
  
  If o Is Nothing Then Exit Function
  
  ' Открытие регистрационной карточки
  o.Permissions = SysAdminPermissions
  Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
  EditObjDlg.ActiveForm = o.ObjectDef.InputForms(0) ' Первая форма
  EditObjDlg.object = o
  EditObjDlg.ParentWindow = ThisApplication.hWnd
  ' Статус, устанавливаемый до создания объекта и позволяющий убрать команды контекстного меню формы
  o.Status = ThisApplication.Statuses("STATUS_D_BEFORE_CREATE")
 'o.Update ' T4FIX: Сохраним объект с новым статусом в базу
  o.SaveChanges tdmSaveOptSerialize

  If Not EditObjDlg.Show Then 
    Set o = ThisApplication.Utility.GetObjectByHandle(hnd)  ' Т.к. система помнит старый экземпляр объекта без изменения статуса
    If Not o Is Nothing Then
      If Not o.Parent Is Nothing Then o.Parent.Permissions = SysAdminPermissions
      o.Permissions = SysAdminPermissions
      o.Erase 
      Exit Function
    End If
  ' T4FIX: case 1405
  else
    o.Status = o.ObjectDef.InitialStatus
    '  o.Update ' T4FIX: Сохраним объект с новым статусом в базу
  End If
  Set Create = o
End Function

'==============================================================================
' Метод создает экземпляр объекта но НЕ открывает его карточку. При этом 
' обрабатывается событие "Object_BeforeCreate"
'------------------------------------------------------------------------------
' sObjDef_:String - Системный идентификатор типа создаваемого объекта
' p_:TDMSObject - Родительский объект в составе которого создается новый 
'                 информационный объект
' Create:TDMSObject - Созданный экземпляр объекта
'==============================================================================
Function CreateO(sObjDef_,p_)
  Dim o,EditObjDlg,hnd
  
  Set CreateO = Nothing
  
  If p_ Is Nothing Then
    On Error Resume Next
      Set o = ThisApplication.ObjectDefs(sObjDef_).CreateObject
      Call ThisApplication.ExecuteScript("CMD_D_DLL", "RunEvent",o.ObjectDefName,"Object_BeforeCreate",3,o,Nothing,False)
      Call ThisApplication.ExecuteScript("CMD_D_DLL", "RunEvent",o.ObjectDefName,"Object_Created",2,o,Nothing)
      Call ThisApplication.ExecuteScript("CMD_D_DLL", "RunEvent",o.ObjectDefName,"Object_Modified",1,o)      
      hnd =o.Handle
    On Error GoTo 0
  Else
    On Error Resume Next
      Set o = p_.Objects.Create(sObjDef_)
      Call ThisApplication.ExecuteScript("CMD_D_DLL", "RunEvent",o.ObjectDefName,"Object_BeforeCreate",3,o,p_,False)
      Call ThisApplication.ExecuteScript("CMD_D_DLL", "RunEvent",o.ObjectDefName,"Object_Created",2,o,p_)
      Call ThisApplication.ExecuteScript("CMD_D_DLL", "RunEvent",o.ObjectDefName,"Object_Modified",1,o)      
      hnd =o.Handle
    On Error GoTo 0 
  End If
   
  If Err.Number<>0 Then Exit Function
  
  ' T4FIX: Объект сохранять в базу ещё рано
  ' потому что не заполнены обязательные атрибуты, а при сохранении они будут проверены.
  ' o.Update
  ' Set o = ThisApplication.Utility.GetObjectByHandle(hnd)
  
  If o Is Nothing Then Exit Function
'  If Not ThisApplication.ObjectDefs(sObjDef_).Objects.Has(hnd) Then Exit Function
  Set CreateO = o
End Function

'==============================================================================
' Функция открывает дилог создания объекта и сохраняет ThisObject в словарь
'------------------------------------------------------------------------------
' sObjDef_:String - Системный идентификатор типа создаваемого объекта
' p_:TDMSObject - Родительский объект в составе которого создается новый 
'                 информационный объект
' CreateODialog:TDMSObject - Созданный экземпляр объекта
'==============================================================================
Function CreateODialog(sObjDef_, p_, oCurrent_)
Set CreateODialog = Nothing
  ' Сохраняем ThisObject в словарь
  Set tDict = ThisApplication.Dictionary("CreateODialog")
    tDict.RemoveAll
    tDict.Add "ThisObj", oCurrent_
  Set dCreateO = ThisApplication.Dialogs.CreateObjectDlg
    dCreateO.ObjectDef = sObjDef_
    dCreateO.ActiveForm = ThisApplication.ObjectDefs(sObjDef_).InputForms(0)
    dCreateO.ParentObject = p_
  If Not dCreateO.Show Then Exit Function
  Set CreateODialog = dCreateO.Object
  tDict.RemoveAll
End Function


'==============================================================================
' Метод возвращает строку констант. Данный метод выделен для того, чтобы
' можно было абстрагироваться от места, где хранятся константы
' Сейчас это текст отдельной команды
'------------------------------------------------------------------------------
' GetConst:String - строка констант
'==============================================================================
Function GetConst()
  GetConst = ThisApplication.ExecuteScript("CMD_D_CONST","GetConst")
End Function

'==============================================================================
' Метод возвращает рабочую папку, в составе которой создается 
' информационный объект.
'------------------------------------------------------------------------------
' sRootSysName:String - Системный идентификатор рабочей папки
' sRootStatus:String - Системный идентификатор статуса в котором должна 
' находится рабочая папка
' GetRootFolder:TDMSObject - Рабочая папка
'==============================================================================
Function GetRootFolder(sRootSysName,sRootStatus)
  Set GetRootFolder = Nothing
  Set SearchFolder = ThisApplication.CreateQuery
  SearchFolder.AddCondition 2, sRootSysName
  SearchFolder.AddCondition 4, sRootStatus
  If SearchFolder.Sheet.RowsCount > 0 Then Set GetRootFolder = SearchFolder.Objects(0)
End Function

'==============================================================================
' Метод возвращает имя группы связанной с подразделением  и имеющие с уникальный 
' префикс
'------------------------------------------------------------------------------
' sDepartment_:String - Описание(наименование) подразделеня
' sGroupID_:String - Уникальный префикс группы
' GetGroupName:String - Системное имя группы
'==============================================================================
Function GetGroupName(sDepartment_, sGroupID_)
  Dim sDepartmentSysName
  Dim sGroupSysName
  Dim CHANGE
  Dim vDep
  
  GetGroupName = ""
  CHANGE = ""
  
  Set vDep = ThisApplication.Departments.Classifiers.Find(sDepartment_)
  If vDep Is Nothing Then Set vDep = ThisApplication.Positions.Classifiers.Find(sDepartment_)
  If vDep Is Nothing Then Exit Function
  
  sSysName = vDep.SysName
  
  If InStr(sSysName,"NODE_POSITION") > 0 Then
    CHANGE = "NODE_POSITION"
  End IF
  
  If InStr(sSysName,"NODE_DEPARTMENT") > 0 Then
    CHANGE = "NODE_DEPARTMENT"
  End If
  
  If CHANGE = "" Then Exit Function
  
  sDepartmentSysName = GetDepartmentSysName(sDepartment_)
  
  sGroupSysName = Replace(sDepartmentSysName, CHANGE, sGroupID_,1, -1, vbTextCompare)
  GetGroupName = sGroupSysName
End Function

'==============================================================================
' Метод возвращает рабочую директорию данного подразделения
'------------------------------------------------------------------------------
' dep_:String|TDMSClassifier - Системный идентификатор, описание подразделеня
' GetDepWorkPath:String - Рабочая директория
'==============================================================================
Function GetDepWorkPath(dep_)
  Dim oConfig
  GetDepWorkPath = ""
  Set vDepDictionary = ThisApplication.Dictionary("Dep")
  
  Select Case TypeName(dep_)
    Case "ITDMSClassifier"
      sClassifName = dep_.SysName
    Case "String"
      'sClassifName = dep_
      sClassifName = ThisApplication.Departments.Classifiers.Find(dep_).SysName
    Case Else
      Exit Function
  End Select
  If TypeName(vDepDictionary(sClassifName)) = "Empty" Then Exit Function
  vDictElement = vDepDictionary(sClassifName)
  GetDepWorkPath = vDictElement(1)
End Function

'==============================================================================
' Метод возвращает системное имя подразделения 
'------------------------------------------------------------------------------
' sDepartment_:String - Описание(наименование) подразделения
' GetDepartmentSysName:String - Системное имя подразделения
'==============================================================================
Function GetDepartmentSysName(sDepartment_)
  Dim sDepartmentSysName
  Dim sParentDepartmentSysName
  Dim vDepartment
  Dim vParentDepartment
  Dim sRootSysName
  
  const ROOTDEPSYSNAME = "CLS_DEPRTMENTS"
  const ROOTPOSSYSNAME = "CLS_POSITIONS"
  
  sDepartmentSysName = ""
  Set vParentDepartment = ThisApplication.Departments.Classifiers.Find(sDepartment_)
  ' Если не нашли подразделение
  If vParentDepartment Is Nothing Then
    Set vParentDepartment = ThisApplication.Positions.Classifiers.Find(sDepartment_)
    sRootSysName = ROOTPOSSYSNAME
  Else
    sRootSysName = ROOTDEPSYSNAME
  End If
  
  sParentDepartmentSysName = vParentDepartment.SysName
  
  Do
    Set vDepartment = vParentDepartment
    sDepartmentSysName = sParentDepartmentSysName
    Set vParentDepartment = vDepartment.Parent
    sParentDepartmentSysName = vParentDepartment.SysName
  Loop While sParentDepartmentSysName <> sRootSysName
  
  GetDepartmentSysName = sDepartmentSysName
End Function


'==============================================================================
' Метод проверяет вхождение пользователя в специализированную группу
' имеющую указанный префикс
'------------------------------------------------------------------------------
' u_:TDMSUser - Пользователь TDMS
' sDepartment_:String - Описание(наименование) подразделеня
' sGroupID_:String - Уникальный префикс группы
' CheckUserPosition:Boolean - TRUE - входит в группу
'==============================================================================
Function CheckDepDir(uCur_,vDep_)
  dim g
  On Error Resume Next 
    Execute ThisApplication.ExecuteScript("CMD_D_DLL","GetConst") 
  On Error GoTo 0     
  CheckDepDir = True
  
  If TypeName(vDep_) = "String" Then Set vDep_ = ThisApplication.Departments.classifiers.Find(vDep_)
  If vDep_ Is Nothing Then 
    CheckDepDir = False
    Exit Function
  End If
  
  If ThisApplication.Groups("GROUP_DEPARTMENT_OFFICE").Users.Has(uCur_) And vDep_.SysName = "NODE_DEPARTMENT_OFFICE"  Then Exit Function
  Set g = GetGroupByDepartment(vDep_, GROUP_MANAGERS_PREFIX)
  If g Is Nothing Then 
    CheckDepDir = False
    Exit Function
  End If
  If g.Users.Has(uCur_) Then Exit Function
  
  CheckDepDir = False
End Function

'==============================================================================
' Метод удаляет с объекта o_ роли vRoleDef_. 
' Если vRoleDef_ пустой - удаляет все роли. 
'------------------------------------------------------------------------------
' o_:TDMSObject - Текущий объект
' vRoleDef_:String - Системное имя роли
' RemoveRoles:Void()
'==============================================================================
Sub RemoveRoles(o_, vRoleDef_)
o_.Permissions = SysAdminPermissions
  If vRoleDef_ = "" Then
  ' Удаляем все роли
    For Each rToRemove In o_.Roles
      rToRemove.Erase
    Next
  Else
  ' Удаляем роли RoleDef
    For Each rToRemove In o_.RolesByDef(vRoleDef_)
      rToRemove.Erase
    Next
  End If
End Sub

'==============================================================================
' Метод добавляет объекту роли vRoleDef_.
'------------------------------------------------------------------------------
' o_:TDMSObject - Текущий объект
' vRoleDef_:String - Системное имя роли
' vAssignCollection_:Variant - коллекция, массив, экземпляр пользователей/групп
' bInherit_:Bool - флаг "наследуемая"
' bUnique_:Bool - флаг уникальности
' AssignRoles:Void()
'==============================================================================
Sub AssignRoles(o_, vRoleDef_, vAssignCollection_, bInherit_, bUnique_)
  If o_ Is Nothing Then Exit Sub
  o_.Permissions = SysAdminPermissions
  Set rCreated = Nothing
  Select Case TypeName(vAssignCollection_)
    Case "ITDMSUsers", "ITDMSGroups", "Variant()" ' Коллекции и массивы
      For Each vAssign In vAssignCollection_
        If Not bUnique_ Then
          Set rCreated = o_.Roles.Create(vRoleDef_, vAssign)
          rCreated.Inheritable = bInherit_
        ElseIf Not RoleExists(o_, vRoleDef_, vAssign) Then
          Set rCreated = o_.Roles.Create(vRoleDef_, vAssign)
          rCreated.Inheritable = bInherit_
        End If
      Next
    Case "ITDMSUser", "ITDMSGroup" ' Экземпляр
      If Not bUnique_ Then
        Set rCreated = o_.Roles.Create(vRoleDef_, vAssignCollection_)
        rCreated.Inheritable = bInherit_  
        ' добавление роли ГИП на документ      
        call AssignGIPRoles(o_, vAssignCollection_)
      ElseIf Not RoleExists(o_, vRoleDef_, vAssignCollection_) Then
        Set rCreated = o_.Roles.Create(vRoleDef_, vAssignCollection_)
        rCreated.Inheritable = bInherit_
        ' добавление роли ГИП на документ    
        call AssignGIPRoles(o_, vAssignCollection_)
      End If
    Case "String"
      If ThisApplication.Groups.Has(vAssignCollection_) Then Set vAssign = ThisApplication.Groups(vAssignCollection_)
      If ThisApplication.Users.Has(vAssignCollection_) Then Set vAssign = ThisApplication.Users(vAssignCollection_)
      If Not vAssign Is Nothing Then 
        If Not bUnique_ Then
          Set rCreated = o_.Roles.Create(vRoleDef_, vAssign)
          rCreated.Inheritable = bInherit_
        ElseIf Not RoleExists(o_, vRoleDef_, vAssign) Then
          Set rCreated = o_.Roles.Create(vRoleDef_, vAssign)
          rCreated.Inheritable = bInherit_
        End If      
      End If
    Case Else
      Exit Sub
  End Select
End Sub
'==============================================================================
' Метод проверяет вхождение пользователя в группу ГИПов
' o_:TDMSObject - Текущий объект
' vAssignCollection_:Variant - экземпляр пользователей
'------------------------------------------------------------------------------
Function AssignGIPRoles(o_, vAssignCollection_)

   Select Case TypeName(vAssignCollection_)
      Case "ITDMSUser"
         if not vAssignCollection_.Attributes("ATTR_D_USER_GROUP_MAIN").Empty then
            set o = vAssignCollection_.Attributes("ATTR_D_USER_GROUP_MAIN").object
            o.Permissions = SysAdminPermissions
            if not o.StatusName = "STATUS_D_GROUP_ACTIVE" then exit function
            if RoleExists(o_, "ROLE_D_ORDER_CONTROL", vAssignCollection_) then exit function
            if RoleExists(o_, "ROLE_D_ORD_CONTROL", vAssignCollection_) then exit function
            Set Groups = ThisApplication.Groups   
            Set GroupGip = ThisApplication.ExecuteScript ("CMD_D_EXAMINED", "GroupeGipExist", o)
            if not GroupGip is nothing then
               o_.Permissions = SysadminPermissions
               If not RoleExists(o_, "ROLE_D_GIP", GroupGip) then Call AssignRoles(o_, "ROLE_D_GIP", GroupGip, False, True)
               set userbook = GroupGip.users
               for each us in userbook
                  If ThisApplication.Departments.Classifiers.Has(us.Department) = True Then          
                     Set g = GetGroupByDepartment(us.Department, GROUP_BOOKWORKERS_PREFIX)
                     if not g is nothing then
                        If not RoleExists(o_, "ROLE_D_BOOKKEEPING_WORKER", g) then _
                           Call AssignRoles(o_, "ROLE_D_BOOKKEEPING_WORKER", g, False, True)
                     end if
                  end if
               next
            end if
         end if
   End Select
End function
'==============================================================================
' Метод проверяет наличие роли vRoleDef_ для пользователя vAssigned_
'------------------------------------------------------------------------------
' o_:TDMSObject - Текущий объект
' vRoleDef_:String - Системное имя роли
' vAssigned_:Variant - ссылка на пользователя/группу
' RoleExists:Bool - True если роль существует
'==============================================================================
Function RoleExists(o_, vRoleDef_, vAssigned_)
RoleExists = False
o_.Permissions = SysAdminPermissions
  For Each rAssigned In o_.RolesByDef(vRoleDef_)
    sRoleAssignedSysName = ""
    On Error Resume Next
      sRoleAssignedSysName = rAssigned.User.SysName
    On Error GoTo 0
    If sRoleAssignedSysName = "" Then _
      sRoleAssignedSysName = rAssigned.Group.SysName
    If vAssigned_.SysName = sRoleAssignedSysName Then
      RoleExists = True
      Exit Function
    End If
  Next
On Error GoTo 0
End Function

'==============================================================================
' Метод ищет группы по подразделению в зависимости от sPrefix_
'------------------------------------------------------------------------------
' dep_:Variant - системное имя или ссылка на узел классификатора "подразделения"
' sPrefix_:String - Тип искомой группы Руководитель/Делопроизводитель
' GetGroupByDepartment:iTDMSGroup
'==============================================================================
Function GetGroupByDepartment(dep_, sPrefix_)
'MsgBox(sPrefix_)
On Error Resume Next
  ' Загрузка констант
  Execute ThisApplication.ExecuteScript("CMD_D_DLL","GetConst") 
On Error GoTo 0
  Set GetGroupByDepartment = Nothing
  Set vDepDictionary = ThisApplication.Dictionary("Dep")
  Select Case TypeName(dep_)
    Case "ITDMSClassifier"
      sClassifName = dep_.SysName
    Case "String"
      If dep_ = "" Then Exit Function
      'sClassifName = dep_
      sClassifName = ThisApplication.Departments.Classifiers.Find(dep_).SysName
    Case Else
      Exit Function
  End Select
  If TypeName(vDepDictionary(sClassifName)) = "Empty" Then Exit Function
  vDictElement = vDepDictionary(sClassifName)
  Select Case sPrefix_
    Case GROUP_MANAGERS_PREFIX
      'MsgBox(vDictElement(2))
      Set GetGroupByDepartment = vDictElement(2)
    Case GROUP_BOOKWORKERS_PREFIX    
      'MsgBox(vDictElement(3))
      Set GetGroupByDepartment = vDictElement(3)
    Case GROUP_DEPARTMENT_PREFIX
      Set GetGroupByDepartment = vDictElement(4)
  End Select
End Function

'==============================================================================
' Метод ищет группы по должности в зависимости от sPrefix_
'------------------------------------------------------------------------------
' position_:Variant - системное имя или ссылка на узел классификатора "Должности"
' sPrefix_:String - Тип искомой группы Руководитель/Делопроизводитель
' GetGroupByPosition:iTDMSGroup
'==============================================================================
Function GetGroupByPosition(position_, sPrefix_)
  Set GetGroupByPosition = Nothing
  Set vDepDictionary = ThisApplication.Dictionary("Dep")
    Select Case TypeName(position_)
    Case "ITDMSClassifier"
      sClassifName = position_.SysName
    Case "String"
      If position_ = "" Then Exit Function
' Слеповичев ИИ 22.02.2011

      Set sClassificator = ThisApplication.Positions.Classifiers.Find(position_)
      if sClassificator is Nothing then Exit Function
      sClassifName = sClassificator.SysName
' Текст до 22.02.2011
'      If position_ = "" Then Exit Function
'      sClassifName = ThisApplication.Positions.Classifiers.Find(position_).SysName
    Case Else
      Exit Function
    End Select
  If TypeName(vDepDictionary(sClassifName)) = "Empty" Then Exit Function
  vDictElement = vDepDictionary(sClassifName)
'  On Error Resume Next
  Select Case sPrefix_
    Case "GROUP_MANAGERS" 'GROUP_MANAGERS_PREFIX
      Set GetGroupByPosition = vDictElement(2)
    Case "GROUP_BOOKWORKERS" 'GROUP_BOOKWORKERS_PREFIX
      Set GetGroupByPosition = vDictElement(3)
  End Select
End Function


'==============================================================================
' Метод ищет руководителя по подразделению
'------------------------------------------------------------------------------
' vClassif_:Variant - системное имя или ссылка на узел классификатора
' GetDepChief:iTDMSUser
'==============================================================================
Function GetDepChief(vClassif_)
  Set GetDepChief = Nothing
  Set vDepDictionary = ThisApplication.Dictionary("Dep")
  Select Case TypeName(vClassif_)
    Case "ITDMSClassifier"
      sClassifName = vClassif_.SysName
    Case "String"
      'sClassifName = vClassif_
      sClassifName = ThisApplication.Departments.Classifiers.Find(vClassif_).SysName
    Case Else
      Exit Function
  End Select
  If TypeName(vDepDictionary(sClassifName)) = "Empty" Then Exit Function
  vDictElement = vDepDictionary(sClassifName)
  Set uChief = vDictElement(0)
  If uChief Is Nothing Then
    Set gChiefs = vDictElement(2)
    If Not gChiefs Is Nothing Then _
      If gChiefs.Users.Count > 0 Then _
        Set uChief = gChiefs.Users(0)
  End If
  Set GetDepChief = uChief
End Function

'==============================================================================
' Метод ищет родь по пользователю/группе и дефенишену
'------------------------------------------------------------------------------
' o_:TDMSObject - ссылка на объект
' vRoleDef_:Variant - системное имя или ссылка на дефенишн роли
' vAssigned_:Variant - ссылка на пользователя или группу
' GetExactRole:iTDMSRole
'==============================================================================
Function GetExactRole(o_, vRoleDef_, vAssigned_)
  Set GetExactRole = Nothing
  o_.Permissions = SysAdminPermissions
  For Each r In o_.RolesByDef(vRoleDef_)
    Set vAssigned = Nothing
    On Error Resume Next
      Set vAssigned = r.User
    On Error GoTo 0
    If vAssigned Is Nothing Then _
      Set vAssigned = r.Group
    If vAssigned.SysName = vAssigned_.SysName Then
      Set GetExactRole = r
      Exit Function
    End If
  Next
End Function


'==============================================================================
' Метод ищет конкретную роль и удаляет её
'------------------------------------------------------------------------------
' o_:TDMSObject - ссылка на объект
' vRoleDef_:Variant - системное имя или ссылка на дефенишн роли
' vAssigned_:Variant - ссылка на пользователя или группу
'==============================================================================
Sub RemoveExactRole(o_, vRoleDef_, vAssigned_)
  o_.Permissions = SysAdminPermissions
  Set rToRemove = GetExactRole(o_, vRoleDef_, vAssigned_)
  If Not rToRemove Is Nothing Then _
  o_.Roles.Remove rToRemove
End Sub

'==============================================================================
' Метод Собирает пользователей по массиву определений ролей
'------------------------------------------------------------------------------
' o_:TDMSObject - ссылка на объект
' arrayRoleDefs_:Array - массив определений ролей
' GetUsersForMessage:ITDMSUsers - коллекция полученных пользователей
'==============================================================================
Function GetUsersForMessage(o_, arrayRoleDefs_)
  Set uCur = ThisApplication.CurrentUser
  Set usCollection = ThisApplication.CreateCollection(2)
  For Each rDef In arrayRoleDefs_
    For Each r In o_.RolesByDef(rDef)
      Set vAssigned = Nothing
      If Not r.User Is Nothing Then _
        Set vAssigned = r.User
      If Not vAssigned Is Nothing Then
        If Not usCollection.Has(vAssigned) And vAssigned.SysName <> uCur.SysName Then 
          usCollection.Add vAssigned
        End If
      Else
        Set vAssigned = r.Group
        For Each u In vAssigned.Users
          If u.Attributes("ATTR_D_USER_MAIL_FLAG") = True Then 
            If Not usCollection.Has(u) And vAssigned.SysName <> uCur.SysName Then 
              usCollection.Add u
            End If
           end If
        Next
      End If
    Next
  Next
  Set GetUsersForMessage = usCollection
End Function


'==============================================================================
' Функция предоставляет диалог выбора файла в зависимости от получаемого 
' типу файла
'------------------------------------------------------------------------------
' ВОЗВРАЩАЕТ:
'   SelectFileDlg:String - Полное имя файла
'   sPath_:String - Путь по умолчанию
'   SelectFileDlg:Array - массив имен файлов, выделенных пользователем
'==============================================================================
Function SelectFileDlg(sFileType_, sPath_)
' -------------------------------------------------------
' Закоментировано при реализации кейс 611
'  if not IsEmpty(sPath_) then
'    'Если sPath_ не доступен, устанавливаем sPath_ в Мои Документы
'    'Case 451
'    Set FSO = CreateObject("Scripting.FileSystemObject")
'    Set WShell = CreateObject("WScript.Shell")
'    If FSO.FolderExists(sPath_) = False Then
'      MyDoc = WShell.SpecialFolders("MyDocuments")
'      sPath_ = MyDoc
'    End if
'  end if
' -------------------------------------------------------  
  SelectFileDlg = ""
  Set FileDef = ThisApplication.FileDefs(sFileType_)
  If FileDef Is Nothing Then Exit Function
  Set SelFileDlg = ThisApplication.Dialogs.FileDlg
  SelFileDlg.Filter = FileDef.Description & " (" & FileDef.Extensions & ")|" & replace(FileDef.Extensions,",",";") & "||"
  SelFileDlg.InitialDirectory = sPath_
  If SelFileDlg.Show Then 
    SelectFileDlg = SelFileDlg.FileNames
  End If
  Set SelFileDlg = ThisApplication.Dialogs.FileDlg
End Function

'==============================================================================
' Метод добавляет выбранные файлы к объекту
'------------------------------------------------------------------------------
' o_:TDMSObject - Обрабатываемый информационный объект
' sFiles_:String - Строка с разделителем chr(0), возвращаемая диалогом MSComDlg
' sFileType_:String - Системное имя типа файла
' sPath_:String - Путь к файлам
' bMainFlag_:Boolean - Установить первый файл главным
' bReplace_:Boolean - Заменть(удалить) файлы данного типа
'==============================================================================
Sub AddFiles(o_,arrFiles_,sFileType_,bMainFlag_,bReplace_, bOneFile_)
  Dim fd
  Dim arrFiles
  Dim f
  Dim fMain
  Set cSameFiles = ThisApplication.CreateCollection(1) ' Коллекция таких же файл
  ThisScript.SysAdminModeOn
  o_.Permissions = SysAdminPermissions
  ' Запоминаем главный файл
  Set fMain = Nothing
  If o_.Files.count > 0 Then Set fMain = o_.Files.Main
  Set FileCollection = o_.Files
  iCycle = UBound(arrFiles_)
  If bOneFile_ Then iCycle = 0
  ' Если есть файлы с таким же именем но другим типом - отмена
  For i = 0 To iCycle
    aFullName = Split(arrFiles_(i), "\")
    sfName = aFullName(UBound(aFullName))
    Set f = FileCollection(sfName)
    If Not f Is Nothing Then
      If f.FileDefName <> sFileType_ Then
       ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 5051, sfName
       CancelCommand ""
      Else
        cSameFiles.Add f
      End If
    End If
  Next
  ' Режим замены
  If bReplace_ Then
    ' Удаляем файлы того же типа
    For Each f In o_.Files.FilesByDef(sFileType_)
      o_.Files.Remove f
    Next
  End If
  ' Удаляем одинаковые файлы
  For Each f In cSameFiles
      o_.Files.Remove f
'    aFullName = Split(arrFiles_(i), "\")
'    sfName = aFullName(UBound(aFullName))
'    If o_.Files.Has(sfName) Then _
'      o_.Files(sfName).Erase
  Next
  ' Добавление файлов
  Set fd = ThisApplication.FileDefs(sFileType_) 
  Set FSO = CreateObject("Scripting.FileSystemObject")
  For i = 0 To iCycle
    Set f = o_.Files.Create(fd, arrFiles_(i))
    Set File = FSO.GetFile(arrFiles_(i)) ' Ссылка на файл
    Set Folder = File.ParentFolder ' Родительская папка
    ' Поиск каталога "Обработанные" + перемещение
    Set fComplete = SerchCompleteFolder(Folder, "Обработанные")
    If Not fComplete Is Nothing Then
      new_file_name = fComplete.Path & "\" & File.Name
      i = 0
      do while FSO.FileExists(new_file_name)
        i = i + 1
        new_file_name = fComplete.Path & "\" & FSO.GetBaseName(File.Name) & "("&i&")." _
          & FSO.GetExtensionName(File.Name)
      loop
      File.Move(new_file_name)
    End If
  Next
  ' Case 62. Если можно добавить только 1 файл, а выбрано больше - оповещение
  If bOneFile_ And UBound(arrFiles_) >= 1 Then _
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 5046, f.FileName
  ' Устанавливаем главный файл
  If bMainFlag_ Then o_.Files.Main = f
End Sub

'==============================================================================
' Поиск папки sName_ в составе Folder_
'------------------------------------------------------------------------------
' Folder_:FSO.Folder - Ссылка на папку
' sName_:String - Имя искомой папки
' SerchCompleteFolder:Variant - Folder или Nothing
'==============================================================================
Function SerchCompleteFolder(Folder_, sName_)
  Set SerchCompleteFolder = Nothing
  For Each sFolder In Folder_.SubFolders
    If sFolder.Name = sName_ Then _
      Set SerchCompleteFolder = sFolder : Exit Function
  Next
End Function

'==============================================================================
' Назначение всех групп Делопроизводителей или руководителей на 
' определенную роль
'------------------------------------------------------------------------------
' o_:TDMSObject - Обрабатываемый информационный объект
' vRoleDef_:Variant - системное имя или ссылка на дефенишн роли
' iType_:Integer - Индекс в Словаре подразделений, по которому получаем назначаемую 
'==============================================================================
Sub SetGroupRoles(o_,vRoleDef_,iType)
  Dim vDepDictionary
  Dim arr
  
  Set vDepDictionary = ThisApplication.Dictionary("Dep")

  For Each key In vDepDictionary.Keys
    arr = vDepDictionary.Item(key)
    Set g = arr(iType) 
    If Not g Is Nothing Then
      Call AssignRoles(o_, vRoleDef_, g, False, False)
    End If
  Next
End Sub

'==============================================================================
' Копирование атрибутов
'------------------------------------------------------------------------------
' oIn_:TDMSObject - Объект, на который копируются атрибуты
' oOut_:TDMSObject - Объект, с которого копируются атрибуты
'==============================================================================
Sub CopyAttrs(oOut_,oIn_)
  dim newrows, rows
  dim nrow, row
  on error resume next 
  oIn_.Permissions = SysAdminPermissions 
  on error goto 0
  For Each a In oOut_.Attributes
    sAttrSysName = a.AttributeDefName
    If oIn_.Attributes.has(sAttrSysName) Then
        Set a2 = oIn_.Attributes(sAttrSysName)
        Call CopyAttr(a2,a)
    End If
  Next
End Sub

'==============================================================================
' Копирование атрибута
'------------------------------------------------------------------------------
' aIn_:TDMSAttribut - Атрибут, которому присваивается значение
' aOut_:TDMSAttribut - Атрибут, из которого копируются значение
'==============================================================================
Private Sub CopyAttr(aIn_,aOut_)
  Dim sAttrType
  sAttrType = aIn_.Type
  Select Case sAttrType
    Case 6, 8 ' Классификатор (TDMSClassifier).
        aIn_.Classifier = aOut_.Classifier
    Case 7 ' Ссылка на объект (TDMSObject) 
        aIn_.Object = aOut_.Object
    Case 9 ' Ссылка на пользователя (TDMSUser).
        aIn_.User = aOut_.User
    Case 11 ' Таблица (TDMSTableAttribute).
        Call CopyTable(aOut_.Rows,aIn_.Rows)
    Case Else
        aIn_.Value = aOut_.Value
  End Select
End Sub

'==============================================================================
' Копирование атрибута
'------------------------------------------------------------------------------
' rowsIn_:TDMSTableAttribut - Таблица, куда копируются значения
' rowsOut_:TDMSTableAttribut - Таблица, из которой копируются значение
'==============================================================================
Private Sub CopyTable(rowsOut_,rowsIn_)
  ' Очистка таблицы rowsIn_
  For i = rowsIn_.Count-1 To 0 Step -1
    rowsIn_.Remove i
  Next
  ' Копирование таблицы
  For Each rowOut In rowsOut_
    Set rowIn = rowsIn_.Create
    For Each a1 In rowOut.Attributes
      If rowIn.Attributes.Has(a1.AttributeDefName) Then 
        Set a2 = rowIn.Attributes(a1.AttributeDefName)
        Call CopyAttr(a2 ,a1)
      End If
    Next
  Next
End Sub
'==============================================================================
' Копирование роли
'------------------------------------------------------------------------------
' oIn_:TDMSObject - Объект, на который копируется роль
' oOut_:TDMSObject - Объект, с которого копируется роль
' srd_:String - Системный идентификатор копируемой роли
'==============================================================================
Private Function CopyRoles(oIn_,oOut_,srd_)
  Dim rd,u,r,su
  Set rd = Nothing
  Set u = Nothing
  
  CopyRoles = False
  
  If ThisApplication.RoleDefs.Has(srd_) Then 
    Set rd = ThisApplication.RoleDefs(srd_)
  End If
  
  If rd Is Nothing Then Exit Function 
    
  oIn_.Permissions = SysAdminPermissions 
  For Each r In oOut_.RolesByDef(srd_)
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    
    If Not u Is Nothing Then
      Set rNew = oIn_.Roles.Create(rd,u)
      rNew.Inheritable=False
    End If
  Next
  
  CopyRoles = True
End Function



Function GetProgressDlg(sDicName_)
  Dim vProgressDlg, dic 
  Set dic = ThisApplication.Dictionary(sDicName_)
  If dic.exists(sDicName_) Then
    Set vProgressDlg = dic.Item(sDicName_)
  Else
    Set vProgressDlg = ThisApplication.Dialogs.ProgressDlg
    dic.Add sDicName_, vProgressDlg
  End If
  Set GetProgressDlg = vProgressDlg
End Function

'==============================================================================
' Функция проверяемт заполнение необходимых атрибутов
'------------------------------------------------------------------------------
' o_:TDMSObject - Обрабатываемый командой информационный объект
' arrayRequired_:Array - массив идентификаторов обязательных атрибутов
' CheckAttrValues:String - перечень незаполненных атрибутов или ""
'==============================================================================
Function CheckAttrValues(o_, arrayRequired_)
CheckAttrValues = ""
  ' Массив обязательных для заполнения атрибутов
  Dim arrayEmptyAttr()
  iEmptyCount = -1
  For Each sElemName In arrayRequired_
    bA = o_.Attributes(sElemName).Type = 11
    bB = o_.Attributes(sElemName).Rows.Count = 0
    bC = o_.Attributes(sElemName).Empty 'Value = ""
'    Select Case TypeName(o_.Attributes(sElemName).Value)
'      Case "String"
'        bC = o_.Attributes(sElemName).Value = ""
'      Case "Long"
'        bC = o_.Attributes(sElemName).Value = 0
'    End Select
    If (bA And bB) Or (Not(bC Imp bA)) Then
      iEmptyCount = iEmptyCount + 1
      Redim Preserve arrayEmptyAttr(iEmptyCount)
      arrayEmptyAttr(iEmptyCount) = o_.Attributes(sElemName).AttributeDef.Description
    End If
  Next
  CheckAttrValues = Join(arrayEmptyAttr, ", ")
End Function

'==============================================================================
' Процедура проверяет наличие команды в колекции и удаляет команду из колекции
'------------------------------------------------------------------------------
' comCollection:TDMSCommands - Колекция команд
' comName:String -Системное имя команды
'==============================================================================
Sub RemoveCommand(comCollection, comName)
  If comCollection.Has(ThisApplication.Commands(comName)) Then comCollection.Remove ThisApplication.Commands(comName)
End Sub

'==============================================================================
' Метод устанавливает флаг контрола на форме в Read Only
'------------------------------------------------------------------------------
' f_:TDMSForm - Форма TDMS
' sListAttrs_:String - Список системных идентификаторов атрибутов, 
'                      поля которых на форме должны быть Read Only
' bFlag_:Boolean - True:Read Only  False:Доступен для редактирования
'==============================================================================
Sub SetControlReadOnly(f_,sListAttrs_,bFlag_)
  Dim Attrs
  
  If sListAttrs_ = "ALL" Then
    Call SetAllControlsReadOnly(f_,bFlag_)
    Exit Sub
  End If
  
  Attrs = Split(sListAttrs_,",")
  For Each sAttr In Attrs
    If f_.Controls.Has(sAttr) Then f_.Controls(sAttr).ReadOnly = bFlag_
  Next
End Sub

'==============================================================================
' Метод устанавливает флаг контролов на форме в Read Only
'------------------------------------------------------------------------------
' f_:TDMSForm - Форма TDMS
' bFlag_:Boolean - True:Read Only  False:Доступен для редактирования
'==============================================================================
Sub SetAllControlsReadOnly(f_,bFlag_)
  For Each control In f_.Controls
    control.ReadOnly = bFlag_
  Next
End Sub

'==============================================================================
' Метод скрывает контролы на форме
'------------------------------------------------------------------------------
' f_:TDMSForm - Форма TDMS
' sListAttrs_:String - Список системных идентификаторов атрибутов, 
'                      поля которых на форме должны быть скрыты
' bFlag_:Boolean - True:Контрол виден False:Контрон не виден
'==============================================================================
Sub SetControlVisible(f_,sListAttrs_,bFlag_)
  Dim Attrs
  Attrs = Split(sListAttrs_,",")
  For Each sAttr In Attrs
    If f_.Controls.Has(sAttr)Then f_.Controls.Item(sAttr).Visible = bFlag_
  Next
End Sub

'==============================================================================
' Функция дополняет строку нулями
'------------------------------------------------------------------------------
' ПРИНИМАЕТ:
'   Str:String - Дополняемая строка
'   Num:Integer - Длина строки
' ВОЗВРАЩАЕТ:
'   AddZeros:String - Дополненную строку
'==============================================================================
Private Function AddZeros(Str,Num)
    AttrLen = Len(Str)
    If AttrLen > Num Then AttrLen = Num
    AddZeros = String (Num - AttrLen,"0") & Str
End Function

'==============================================================================
' Функция позволяет выбрать пользователей из списка или стандартного диалога
'------------------------------------------------------------------------------
' ВОЗВРАЩАЕТ:
'   SelectRecipient:Variant - Коллекция выбранных пользователей/подразделений
'==============================================================================
Function SelectRecipient()
  Set SelectRecipient = Nothing
  Set os = ThisApplication.ExecuteScript("CMD_D_DIALOGS","SelectObjectDlg","OBJECT_D_SEND_GROUP",GetObjectsByDef("OBJECT_D_SEND_GROUP"))
End Function


'==============================================================================
' Собирает пользователей для собщения по массиву определений ролей
'------------------------------------------------------------------------------
' tObj:TDMSObject - Обрабатываемый объект
' RolesArray:Array - Массив системных идентификаторов ролей
' UsersForMessage:TDMSUsers - Колекция пользователей
'==============================================================================
Function UsersForMessage(tObj, RolesArray)
Set UsersForMessage = Nothing
Set uCur = ThisApplication.CurrentUser
Set uCollection = ThisApplication.CreateCollection(2)
  For Each tElem In RolesArray
    For Each role In tObj.RolesByDef(tElem)
      Set tAssigned = Nothing
      If Not role.User Is Nothing Then _
        Set tAssigned = role.User
      If Not tAssigned Is Nothing Then
        If Not uCollection.Has(tAssigned) Then 
          uCollection.Add tAssigned
        End If
      Else
        Set tAssigned = role.Group
        For Each tUser In tAssigned.Users
          If tUser.Attributes("ATTR_D_USER_MAIL_FLAG") = True Then 
            If Not uCollection.Has(tUser) Then 
              uCollection.Add tUser
            End If
           end If
        Next
      End If
    Next
  Next
  ' Самому себе сообщение не отправляется
  If uCollection.Has(uCur) Then uCollection.Remove uCur
Set UsersForMessage = uCollection
End Function


'==============================================================================
' Проверяем вхождение пользователя в группу делопроизводители подразделения 
'------------------------------------------------------------------------------
' vDep_:TDMSClassifier - Подразделение
' uCur_:TDMSUser - Текущий пользователь
' CheckDep:Boolean - Вхождение пользователя в группу делопроизводителя
'==============================================================================
Private Function CheckDep(vDep_,uCur_)
  dim g
  on error resume next  'изменено кейс 740,752
    Execute ThisApplication.ExecuteScript("CMD_D_DLL","GetConst") 
  on error goto 0       'изменено кейс 740,752
  CheckDep = True
  
  If TypeName(vDep_) = "String" Then Set vDep_ = ThisApplication.Departments.classifiers.Find(vDep_)
  If vDep_ Is Nothing Then 
    CheckDep = False
    Exit Function
  End If  
  
  If ThisApplication.Groups("GROUP_DEPARTMENT_OFFICE").Users.Has(uCur_) And vDep_.SysName = "NODE_DEPARTMENT_OFFICE"  Then Exit Function
  Set g = GetGroupByDepartment(vDep_, GROUP_BOOKWORKERS_PREFIX)
  If g Is Nothing Then CheckDep = False: Exit Function
  If g.Users.Has(uCur_) Then Exit Function
  CheckDep = False
End Function

'==============================================================================
' Выбор пользователя из указанного подразделения
'------------------------------------------------------------------------------
' vDep_:TDMSClassifier - Подразделение
' Select_User_By_Dep:TDMSUser - Выбранный пользователь
'==============================================================================
Function Select_User_By_Dep(vDep_)
  Set Select_User_By_Dep = Nothing
  Set dSelectUser = ThisApplication.Dialogs.SelectUserDlg
    Set uc = ThisApplication.Departments.Classifiers(vDep_).AssignedUsers
    If uc.Count > 0 Then
      dSelectUser.SelectFromUsers = uc
      If dSelectUser.Show Then 
        If dSelectUser.Users.Count > 0 Then Set Select_User_By_Dep  = dSelectUser.Users(0)
      End If
    End If
End Function
'==============================================================================
' Выбор пользователя из группы руководителей подразделения
'------------------------------------------------------------------------------
' vDep_:TDMSClassifier - Подразделение
' Select_User_By_Dep:TDMSUser - Выбранный пользователь
'==============================================================================
Function Select_User_By_Dir_Group(vDep_)
 Execute ThisApplication.ExecuteScript("CMD_D_DLL","GetConst") 
  Set Select_User_By_Dir_Group = Nothing
  'Case 1061
  Set usmanegers = ThisApplication.CreateCollection(2)
  If vDep_.Code = "0" Then
    Set g = ThisApplication.Groups("GROUP_DEPARTMENT_RUKOVODSTVO")
  Else
    Set g = GetGroupByDepartment(vDep_, GROUP_MANAGERS_PREFIX)
  End If
  If g Is Nothing Then Exit Function
    Set dSelectUser = ThisApplication.Dialogs.SelectUserDlg
    Set uc = g.Users    
    If uc.Count > 0 Then
      '-------------------------------------------------------
      ' Case 1061
      for each us1 in uc
         if not usmanegers.has(us1.description) then _
            usmanegers.add us1
      next
      Set usg = ThisApplication.Departments.Classifiers(vDep_).AssignedUsers
      If usg.Count > 0 Then
         for each us1 in usg
            if not us1.Attributes("ATTR_D_USER_GROUP_MAIN").Empty then 
               set o = us1.Attributes("ATTR_D_USER_GROUP_MAIN").object
               o.Permissions = SysAdminPermissions
               Set GroupGip = ThisApplication.ExecuteScript ("CMD_D_EXAMINED", "GroupeGipExist", o)
               if not GroupGip is nothing then         
                  if not usmanegers.has(us1.description) then _
                     usmanegers.add us1
               end if
            end if
         next
      end if
      '-------------------------------------------------------
      dSelectUser.SelectFromUsers = usmanegers
      If dSelectUser.Show Then 
        If dSelectUser.Users.Count > 0 Then Set Select_User_By_Dir_Group  = dSelectUser.Users(0)
      End If     
    End If
End Function
'==============================================================================
' Удаление выбранных строк из таблицы
'------------------------------------------------------------------------------
' sTableName_:String - Системное имя табличного атрибута
'==============================================================================
Sub RemoveRows(sTableName_)
  ArrayBound = -1
  With ThisObject.Attributes(sTableName_).Rows
    SelArr = ThisForm.Controls(sTableName_).SelectedItems
    On Error Resume Next
      ArrayBound = UBound(SelArr)
    On Error GoTo 0
    If .Count > 0 And ArrayBound > -1 Then
      For i = ArrayBound To 0 Step -1
        .Remove SelArr(i)
      Next
    End If
  End With
End Sub
'***добавлено 30.05.2012 Захаров М. Case 1127
'==============================================================================
' Удаление выбранных строк из таблицы с удалением ролей пользователей
'------------------------------------------------------------------------------
' sTableName_           :String - Системное имя табличного атрибута
' sTableUserColumnName_ :String - Системное имя атрибута в таблице sTableName_, содержащего ссылку на пользователя
' sRoleDefName_         :String - Системное имя удаляемой с объекта роли
'==============================================================================
Sub RemoveRowsWithRoles(sTableName_,sTableUserColumnName_,sRoleDefName_)
  ArrayBound = -1
  With ThisObject.Attributes(sTableName_).Rows
    SelArr = ThisForm.Controls(sTableName_).SelectedItems
    On Error Resume Next
      ArrayBound = UBound(SelArr)
    On Error GoTo 0
    If .Count > 0 And ArrayBound > -1 Then
      For i = ArrayBound To 0 Step -1
       For Each CheckRole In ThisObject.Roles
        If CheckRole.RoleDefName = sRoleDefName_ Then
         If Not CheckRole.User Is Nothing Then
          If CheckRole.User.Handle = .Item(SelArr(i)).Attributes(sTableUserColumnName_).User.Handle Then
           CheckRole.Erase
           Exit For
          End If
         End If
        End If
       Next
       .Remove SelArr(i)
      Next
    End If
  End With
End Sub
'==============================================================================
' Диалог выбора пользователей и подразделений из массива
'------------------------------------------------------------------------------
' aSendTo_:Variant() - Коллекция пользователей для выбора
'==============================================================================
Private Function GetFromArray(aSendTo_)
Dim aSelItems()
GetFromArray = aSelItems
  dim SelDeps
  Set SelDeps = ThisApplication.Dialogs.SelectDlg
  SelDeps.SelectFrom = aSendTo_' ThisApplication.Classifiers("CLS_DEPRTMENTS").Classifiers
  If SelDeps.Show Then
    GetFromArray = SelDeps.Objects
  End If
End Function

'==============================================================================
' Перенос выбранных пользователей в таблицу
'------------------------------------------------------------------------------
' aTable_:ITDMSAttribute - Редактируемая таблица
' sAttrName_:String - Имя заполняемого в таблице атрибута
' os_:Variant() - Словарь связей элемент - пользователь
' SendArray_:Variant() - Коллекция выбранных элементов
'==============================================================================
Private Sub AddToTable(aTable_, sAttrName_, os_, SendArray_)
  ' Добавление пользователей в список
    cTAttrChange = "ThisApplication.ExecuteScript(ThisForm.SysName, ""Form_TableAttributeChange""," & _
    "ThisForm, ThisObject, aTable_, tRow, sAttrName_, Nothing, False)"
    With aTable_.Rows
      For Each tItem In os_
        Set tUser = SendArray_.Item(tItem)      
        Set tRow = .Create
          tRow.Attributes(sAttrName_) = tUser
          Result = EVal (cTAttrChange)
      Next
    End With
End Sub

'==============================================================================
' Перенос выбранных пользователей и подразделений в таблицу
'------------------------------------------------------------------------------
' aTable_:ITDMSAttribute - Редактируемая таблица
' sAttrName_:String - Имя заполняемого в таблице атрибута (Пользователь)
' sAttrName_:String - Имя заполняемого в таблице атрибута (Отдел)
' os_:Variant() - Словарь связей элемент - пользователь
' SendArray_:Variant() - Коллекция выбранных элементов
'==============================================================================
Private Sub AddToTableWithDep(aTable_, sAttrName_, sDepAttrName_, sPosAttrName_, os_, SendArray_)
  ' Добавление пользователей в список
    cTAttrChange = "ThisApplication.ExecuteScript(ThisForm.SysName, ""Form_TableAttributeChange""," & _
    "ThisForm, ThisObject, aTable_, tRow, sAttrName_, Nothing, False)"
    With aTable_.Rows
      For Each tItem In os_
        Set tUser = SendArray_.Item(tItem)
        tcDep = Trim(tItem)
        Set tDep = ThisApplication.Departments.Classifiers.Find(tcDep)
        If tDep Is Nothing Then Set tDep = ThisApplication.Departments.Classifiers.Find(tUser.Department)
        Set tRow = .Create
          tRow.Attributes(sAttrName_) = tUser
          'Добавлено при реализаци 706 кейса
          tRow.Attributes(sDepAttrName_).Classifier = tDep
          tRow.Attributes(sPosAttrName_).Classifier = ThisApplication.Positions.Classifiers.Find(tUser.Position)
          Result = EVal (cTAttrChange)
     Next
    End With
End Sub

'==============================================================================
' Добавление подразделений в словарь из таблицы
'------------------------------------------------------------------------------
' dic_:Object - Ссылка на словарь
' taSendGroup_:TDMSTableAttribute - Добавляемый список
' ta_:TDMSTableAttribute - Проверяемый табличный атрибут
' sAttrName_:String - Поле редатируемой таблицы
'==============================================================================
Private Function AddFromTableToDictionary(dic_, taSendGroup_, ta_, sAttrName_)
  dim arrTemp
  dim count
  For Each row In taSendGroup_.rows
    key = GetKey(row) ' строка для диалога
    Set item = GetItem(row) ' Ключ, ссылка на пользователя
    ' если ключ не пустой то добавляем в словарь
    If Not item Is Nothing Then
      If Not QueryTable(item, ta_, sAttrName_) Then _
        dic_.Add key, item
'      Else
'        'Добавлено при реализаци 706 кейса
'        If Not GetDep(ta_, key) And item.Department <> "Руководство" Then
'          dic_.Add key, item
'        End If
'      End If
    End If
  Next
  Set AddFromTableToDictionary = dic_
End Function

'==============================================================================
' Проверяем наличие отдела в таблице рассылки
'------------------------------------------------------------------------------
' ta_:TDMSTableAttribute - Проверяемый табличный атрибут
' key_:String - Строка содержащая название подразделения
'==============================================================================
Private Function GetDep(ta, key_)
GetDep = False
MsgBox ta, ,key_
For Each sta In ta.rows
  If sta.Attributes("ATTR_D_DEPARTMENT").Classifier.Description = Trim(key_) Then
    GetDep = True
    Exit Function
  End If
Next
End Function

'==============================================================================
' Добавление подразделений в словарь из списка пользователей
'------------------------------------------------------------------------------
' dic_:Object - Ссылка на словарь
' ta_:TDMSTableAttribute - Проверяемый табличный атрибут
' sAttrName_:String - Поле редатируемой таблицы
' vSelFrom_:ITDMSUsers - Коллекция доступных для выбора пользователей
'==============================================================================
Private Function AddFromDialogToDictionary(dic_, ta_, sAttrName_, vSelFrom_)
  Set AddFromDialogToDictionary = dic_
  Set SelUser = ThisApplication.Dialogs.SelectUserDlg
  If Not vSelFrom_ Is Nothing Then _
    SelUser.SelectFromUsers = vSelFrom_
  If SelUser.Show = Flase Then Exit Function
  If SelUser.Users.Count = 0 Then Exit Function
  Set uCollection = SelUser.Users
  For Each u In uCollection
  '------------------------------------------------------------------------------
  ' Добавлено при разделении СЗ на СЗП и СЗР
  '------------------------------------------------------------------------------  
    if not u.Department = "" then 
       key = u.Description & " " & u.Position
       If Not QueryTable(u, ta_, sAttrName_) Then
          dic_.Add key, u
       End If
    else
       MsgBox "У сотрудника " & u.Description & " не указано подразделение. Выберите другого сотрудника.", vbCritical, "Ошибка"
    end if
  '------------------------------------------------------------------------------
  ' Завершение добавления разделения СЗ на СЗП и СЗР
  '------------------------------------------------------------------------------
  Next
  Set AddFromDialogToDictionary = dic_
End Function

'==============================================================================
' Формируем ключ словаря (все поля таблицы через пробел)
'------------------------------------------------------------------------------
' row_:TDMSRowAttribute - Ссылка на строку таблицы
'==============================================================================
Private Function GetKey(row_)
  dim str
  GetKey = ""
  If row_.Attributes.Count = 0 Then Exit Function
  ' соединяем все атрибуты
  For Each a In row_.Attributes
    str = str & a.Value & " "
  Next
  GetKey = str
End Function

'==============================================================================
' Формируем значение элемента словаря (ссылка на пользователя)
'------------------------------------------------------------------------------
' row_:TDMSRowAttribute - Ссылка на строку таблицы
'==============================================================================
Private Function GetItem(row_)
  dim str
  dim a
  dim sAttrType
  
  Set a = row_.Attributes(0)
  Select Case a.Type
    Case 6 'tdmClassifier
      Set GetItem = GetDepChief(a.classifier) ' руководитель подразделения
    Case 8 'tdmClassifier(List)
      Set GetItem = GetDepChief(a.classifier)
    Case 9 'tdmUserLink
      Set GetItem = a.User
    Case Else
      Set GetItem = Nothing
  End Select
End Function

'==============================================================================
' Проверка таблицы на наличие записи vSelect_
'------------------------------------------------------------------------------
' vSelect_:Variant() - Добавляемый элемент
' ta_:TDMSTableAttribute - Ссылка на табличный атрибут
' sAttrName_:String - Поле редатируемой таблицы
'==============================================================================
Function QueryTable(vSelect_, ta_, sAttrName_)
QueryTable = False
  For Each tRow In ta_.Rows
    If tRow.Attributes(sAttrName_).User.SysName = vSelect_.SysName Then
      QueryTable = True 
      Exit Function
    End If
  Next
End Function

'==============================================================================
' Проверка таблицы на наличие записи vSelect_
'------------------------------------------------------------------------------
' oParent_:ITDMSObject - объект родитель
' o_:ITDMSObject - объект родитель
'==============================================================================
Function ObjectRemove(oParent_, o_)
  ' Для "пробоя" запрета имитируем, что объект удаляется из системы
  Set tDict = ThisApplication.Dictionary
  If Not tDict.Exists("EraseCollection") Then
    tDict.Add "EraseCollection", ThisApplication.CreateCollection(0)
  End If
  Set tCol = tDict("EraseCollection")
    tCol.Add o_
    
  oParent_.Permissions = SysAdminPermissions
  oParent_.Objects.Remove o_
End Function

'==============================================================================
' Заполнение полей "Оригинал"
'------------------------------------------------------------------------------
' o_:ITDMSObject - объект
' u_: ITDMSUser - Пользователь которому передаётся оригинал
' dep_:Variant - Подразделение которому передаётся оригинал
'==============================================================================
Function FillOriginal(o_,  dep_, u_)
o_.Permissions = SysAdminPermissions
  o_.Attributes("ATTR_D_ORIGINAL_DEP") = dep_
  If Not u_ Is Nothing Then 
    o_.Attributes("ATTR_D_ORIGINAL_USER") = u_
    o_.Attributes("ATTR_D_ORIGINAL_POS") = u_.Position
  Else
    o_.Attributes("ATTR_D_ORIGINAL_USER") = ""
    o_.Attributes("ATTR_D_ORIGINAL_POS") = ""
  End If
End Function

Function RunEvent(sDef_,sEvent_,count_,a1_,a2_,a3_,a4_,a5_,a6_,a7_)
  If ThisApplication.CallObjectsEventsFromCOM Then Exit Function
  sParam = "a1_,a2_,a3_,a4_,a5_,a6_,a7_"
  sEventCommand = "ThisApplication.ExecuteScript(""" & sDef_ & """,""" & sEvent_ & """," & Left(sParam,count_*4-1) & ")"
  on error resume next
    result = Eval(sEventCommand)
  on error goto 0  
End Function



Function GetRowByUser(o_,u_,sAttrTable_,sAttrUser_)
  Set GetRowByUser = Nothing
  For Each vRow In o_.Attributes(sAttrTable_).Rows
    If vRow.Attributes(sAttrUser_).User.SysName = u_.SysName Then
      Set GetRowByUser = vRow
      Exit Function
    End If
  Next
End Function

Function GetDepsByUserGroup(u_, strGroup_)
GetDepsByUserGroup = ""
dBookerCount = -1
  For Each g In u_.Groups
    If InStr(g.SysName, strGroup_) > 0 Then
      dBookerCount = dBookerCount + 1
      Redim Preserve dBooker(dBookerCount)
      dBooker(dBookerCount) = Replace(g.SysName, strGroup_, "NODE_DEPARTMENT_", 1, -1, 1)
    End If
  Next
  If dBookerCount = -1 Then Exit Function
  GetDepsByUserGroup = Join(dBooker, ";")
End Function

'==============================================================================
' Удаление версий объекта
'------------------------------------------------------------------------------
' o_:TDMSObject - Обрабатываемый командой информационный объект
'==============================================================================
Sub RemoveVersionsFiles(o_)
  Set tDict = ThisApplication.Dictionary("SCAN_ADD")
    tDict.RemoveAll
    tDict.Add "Replace", True
  ThisScript.SysAdminModeOn
    sOGuid = o_.GUID
    For Each oVersion In o_.Versions
      If oVersion.GUID <> sOGuid Then _
        oVersion.Erase
    Next
    For Each f In o_.Files
      f.Erase
    Next
  ThisScript.SysAdminModeOff
    tDict.RemoveAll
End Sub

'==============================================================================
' Проверяет является ли пользователь руководителем
'------------------------------------------------------------------------------
' u_:TDMSUser - Обрабатываемый командой пользователь
'==============================================================================
Function UserIsDepManager(u_)
UserIsDepManager = False
  For Each g In u_.Groups
    If InStr(g.SysName, "GROUP_MANAGERS_") > 0 Then _
      UserIsDepManager = True: Exit Function
  Next
End Function

'==============================================================================
' Проверяет входит ли строка в массив
'------------------------------------------------------------------------------
' s_:String - Проверяемая строка
' a_:Variant() - Проверяемая массив
'==============================================================================
Function sInArray(s_, a_)
  sInArray = True
  For Each sElement In a_
    If s_ = sElement Then Exit Function
  Next
  sInArray = False
End Function


'==============================================================================
' Проверяет есть ли ключ в словаре
'------------------------------------------------------------------------------
' keyName_:String - Проверяемый ключ
' keyValue_:String - Значение ключа
'==============================================================================
Function KeyExists(keyName_, keyValue_)
KeyExists = False
  Set tDict = ThisApplication.Dictionary
  If Not tDict.Exists(keyName_) Then Exit Function
  Select Case TypeName (tDict(keyName_))
    Case "ITDMSObject"
      If tDict(keyName_).GUID <> keyValue_.Guid Then Exit Function
    Case Else
      Exit Function
  End Select
KeyExists = True
End Function

'==============================================================================
' Устанавливает доступность редактирования контролов РК в зависимости от массива
'------------------------------------------------------------------------------
' f_:ITDMSInputForm - ссылка на РК
' a_:String() - Массив доступных контролов
'==============================================================================
Sub EnableControls(f_, a_)
  For Each c In f_.Controls
    If sInArray(c.Name, a_) Then
      f_.Controls(c.Name).Enabled = True
    Else
      f_.Controls(c.Name).Enabled = False
    End If
  Next
End Sub

Sub InitBookersQueries() 
If Not ThisApplication.Desktop.Queries.Has ("QUERY_D_BOOKER") Then Exit Sub
' Загрузка констант
Execute ThisApplication.ExecuteScript("CMD_D_DLL","GetConst") 
Set qRoot = ThisApplication.Desktop.Queries("QUERY_D_BOOKER")
  For Each o In qRoot.Objects
    Set uDir = Nothing
    Set c = o.Attributes("ATTR_D_ARM_DEPARTMENT").Classifier
    Set gDepBooker = GetGroupByDepartment(c, GROUP_BOOKWORKERS_PREFIX)
    Set gDirBooker = GetGroupByPosition(c, GROUP_BOOKWORKERS_PREFIX)
    If c.AssignedUsers.Count > 0 Then Set uDir = c.AssignedUsers(0)
    For Each q In o.Queries
      Select Case q.SysName
        Case "QUERY_D_BOOKER_DOCS", "QUERY_D_BOOKER_RO", "QUERY_D_BOOKER_DOCUMENTS_TO_AFFAIR"
          o.Queries(q).Parameter("P_DEP") = gDepBooker
        Case "QUERY_D_DMS_DIR_RO_D"
          o.Queries(q).Parameter("P_USERDIR") = uDir.Handle
        Case "QUERY_D_DMS_DIR_DOCUMENTS_D"
          o.Queries(q).Parameter("P_DIR") = gDirBooker
      End Select
    Next
  Next
End Sub

Function GetObjectsByDef(sObjeDefName_)
  Set q = ThisApplication.CreateQuery
    q.AddCondition tdmQueryConditionObjectDef, sObjeDefName_
  Set GetObjectsByDef = q.Objects
End Function

'_____________________________________________________________________________________________________
' Сортировка состава по имени
' pObj - объект контейнер, состав которого сортируется
' addObj - сортируемы объект в составе
'_____________________________________________________________________________________________________
Sub SortObjects(pObj, addObj)
  ThisScript.SysAdminModeOn
  Set tQuery = ThisApplication.Queries("QUERY_CONTENT_SORT")
  tQuery.Permissions = SysAdminPermissions
  tQuery.Parameter("ObjDef") = addObj.ObjectDefName
  tQuery.Parameter("ObjParent") = pObj.GUID
  pObj.Permissions = SysAdminPermissions
  For Each o_ In tQuery.Objects
    o_.Roles.Create "ROLE_ADMIN", ThisApplication.CurrentUser
  Next
  position = Empty
  Set pCollection = pObj.Content
  qIndex = tQuery.Objects.Index(addObj) ' позиция в выборке
  oIndex = pCollection.Index(addObj) ' позиция в коллекции
  If tQuery.Objects.Count > 1 Then
    ' Определяем краевые положения объекта в выборке
    If qIndex = tQuery.Objects.Count-1 Then ' Нижний объект
      oIndexP = pCollection.Index(tQuery.Objects(qIndex-1))
      ' Определяем направление движения
      If oIndexP > oIndex Then ' Движение вниз
        position = oIndexP
      Else ' Движение вверх
        position = oIndexP + 1
      End If
    Else
'      Set nObj = tQuery.Objects(qIndex+1)
'      nObj.Roles.Create "ROLE_ADMIN", ThisApplication.CurrentUser
'      Set pCollection = pObj.Content
      oIndexN = pCollection.Index(tQuery.Objects(qIndex+1))
      ' Определяем направление движения
      If oIndexN > oIndex Then ' Движение вниз
        position = oIndexN - 1
      Else ' Движение вверх
        position = oIndexN
      End If
    End If
  End If
  ' Если требуется перестановка - переставляем
  If Not IsEmpty(position) And position <> oIndex Then
    pCollection.Move addObj, position
'    Set AR = GetExactRole(tQuery.Objects(qIndex+1), "ROLE_ADMIN", ThisApplication.CurrentUser)
'    nObj.Roles.Remove AR
    For Each o_ In tQuery.Objects
      Set AR = GetExactRole(o_, "ROLE_ADMIN", ThisApplication.CurrentUser)
      o_.Roles.Remove AR
    Next
    pCollection.Update
  End If
  ThisScript.SysAdminModeOff
End Sub

' Полная сортирока состава объекта
Sub SortContent(pObj)
  Set tQuery = ThisApplication.Queries("QUERY_CONTENT_SORT")
  tQuery.Permissions = SysAdminPermissions
  tQuery.Parameter("ObjParent") = pObj.GUID
  tQuery.Parameter("ObjDef") = "<>NULL" ' Сортировка вне зависимости от типов объектов
  Set contCollection = pObj.Objects
  Set qCollection = tQuery.Objects
  For Each tObj In contCollection
     contCollection(tObj).Order = qCollection.Index(tObj)
  Next
  contCollection.Update
End Sub

' Попытка дождаться снятия блокировки состава
Function ContentLocked(oContent)
  ContentLocked = False
  If oContent.Permissions.EditContent = 1 Then Exit Function
  bExit = False
  While bExit <> True
    ThisApplication.Utility.Sleep 100
    tCounter = tCounter+100
    bExit = CBool(oContent.Permissions.EditContent) Or tCounter=3000
  Wend
  If tCounter = 3000 Then ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 5049:_
    ContentLocked = True
End Function

Sub CodevFill(TableAttribute, Object)
If TableAttribute.AttributeDefName = "ATTR_D_CODEVELOPERS_TABLE" Then
  If TableAttribute.Rows.Count = 0 Then
    Exit Sub
  End If
  Object.Attributes("ATTR_CODEVELOPERS").Value = ""
  For Each R In TableAttribute.Rows
    Object.Attributes("ATTR_CODEVELOPERS").Value = Object.Attributes("ATTR_CODEVELOPERS").Value + _
      R.Attributes("ATTR_D_CODEVELOPER").User.Description + ", "
  Next
  LVal = Len(Object.Attributes("ATTR_CODEVELOPERS").Value) - 2
  Object.Attributes("ATTR_CODEVELOPERS").Value = Left(Object.Attributes("ATTR_CODEVELOPERS").Value, LVal)
End If
End Sub

'==============================================================================
' Преобразование листа в массив
'------------------------------------------------------------------------------
' s_:ITDMSSheet - лист состава
'==============================================================================
Function ArrayFromSheet(s_)
Dim tArray()
If s_.RowsCount <= 50 Then
  eInd = s_.RowsCount
Else
  eInd = 50
End If
'For i = 0 To s_.RowsCount -1
For i = 0 To eInd - 1
  ReDim Preserve tArray(i)
  tArray(i) = s_.CellValue(i,0)
Next
ArrayFromSheet = tArray
End Function

'==============================================================================
' Преобразование таблицы в массив по заданному полю
'------------------------------------------------------------------------------
' ra_:ITDMSRowsAttribute - лист состава
' sColumnDef_:String - поле таблицы для сбора
'==============================================================================
Function ArrayFromTable(ra_, sColumnDef_)
Dim tArray()
i = -1
For Each r In ra_
  i = i+1
  ReDim Preserve tArray(i)
  tArray(i) = r.Attributes(sColumnDef_).Value
Next
ArrayFromTable = tArray
End Function

'==============================================================================
' Преобразование коллекции в массив (обратный порядок)
'------------------------------------------------------------------------------
' vCollection_:ITDMSObjects - коллекция объектов
' ArrayFromCollection:Variant() - полученный массив
'==============================================================================
Function ArrayFromCollection(vCollection_)
Dim tArray()
i = -1
  If vCollection_.Count > 0 Then
    For j = vCollection_.Count -1 To 0 Step -1
      i = i+1
      ReDim Preserve tArray(i)
      Set tArray(i) = vCollection_(j)
    Next
  End If
ArrayFromCollection = tArray
End Function

'==============================================================================
' Приведение коллекции атрибутов объекта к его типу
'------------------------------------------------------------------------------
' o_:ITDMSObject - ссылка на объект
'==============================================================================
Sub SetAttrsByDef(o_)
  Set aDefsCollection = o_.ObjectDef.AttributeDefs
  Set asCollection = o_.Attributes
  ' Добавление отсутствующих
  For Each aDef In aDefsCollection
    If Not asCollection.Has(aDef.SysName) Then asCollection.Create(aDef.SysName)
  Next
  ' Удаление лишних
  For Each a In asCollection
    If Not aDefsCollection.Has(a.AttributeDefName) Then asCollection.Remove(a)
  Next
End Sub

'==============================================================================
' Очитка столбца в таблице объекта
'------------------------------------------------------------------------------
' o_:ITDMSObject - ссылка на объект
' sAttrTable_:String - имя таблицы
' arrAttrsForClean_:String - строка с именами столбцов (делиметр ",")
'==============================================================================
Sub ClearTable(o_,sAttrTable_,arrAttrsForClean_)
  dim vRow
  For Each vRow In o_.Attributes(sAttrTable_).Rows
    For Each sAttr In Split(arrAttrsForClean_,",")
      If vRow.Attributes.Has(sAttr) Then vRow.Attributes(sAttr) = ""
    Next
  Next
End Sub


'==============================================================================
' Искуственная ошибка для отмены событий обновления
'------------------------------------------------------------------------------
'==============================================================================
Sub CancelCommand(vSource_)
  ' Сбрасываем признак "Требует обновления"
  Set tDict = ThisApplication.Dictionary("QueryUpdate")
  Set quDict = ThisApplication.Dictionary("QueryUpdate")
  If quDict.Exists("Command") Then _
    If quDict("Command") = vSource_ Then quDict.Remove "Command"
  Err.Raise 1111, ,"Command has been canceled."
End Sub

'==============================================================================
' Создание события
'------------------------------------------------------------------------------
' o_:ITDMSObject - Объект события
' u_:ITDMSUser - Пользователь от чьего имени
' sDesc_:String - Описание события
' bUnique_:Boolean - Удалить аналогичные события
'==============================================================================
Function EventCreate(o_, u_, sDesc_, bUnique_)
  ThisScript.SysAdminModeOn
    ' Удаление лишних событий объекта
    If bUnique_ Then
      Set FiltEvent = ThisApplication.Events
        FiltEvent.Filter.Object = o_
        FiltEvent.Filter.Class = 4096
        FiltEvent.Filter.On = True
      For Each e In FiltEvent
        If CBool(e.Type = 4098 And e.Description = sDesc_) Then e.Erase
      Next
    End If
    ' Создание нового события
    Set eCreated = ThisApplication.CreateEvent(sDesc_)
    If TypeName(u_) = "ITDMSUser" Then eCreated.User = u_
    If TypeName(o_) = "ITDMSObject" Then eCreated.Object = o_
    Set EventCreate = eCreated
  ThisScript.SysAdminModeOff
End Function

'==============================================================================
' Поиск события
'------------------------------------------------------------------------------
' o_:ITDMSObject - Объект события
' u_:ITDMSUser - Пользователь от чьего имени
' sDesc_:String - Описание события
'==============================================================================
Function EventGet(o_, u_, sDesc_)
  Set EventGet = Nothing
  Set FiltEvent = o_.Events
    'FiltEvent.Filter.Object = o_
    If TypeName(u_) = "ITDMSUser" Then FiltEvent.Filter.User = u_
    FiltEvent.Filter.Class = 4096
    FiltEvent.Filter.On = True
  For Each e In FiltEvent
    If CBool(e.Type = 4098 And e.Description = sDesc_) Then _
      Set EventGet = e : Exit Function
  Next
End Function

Sub SheetObjectsGet(Sheet)

End Sub


'==============================================================================
' Процедура добавляет элемент в словарь
'------------------------------------------------------------------------------
' tDict_:ITDMSDictionary - ссылка на словарь
' key_:String - ключ
' v_:String - значение
'==============================================================================
Sub AddToDict(tDict_, key_, v_)
  If tDict_.Exists(key_) Then
    On Error Resume Next
      Set tDict_(key_) = v_
      If Err <> 0 Then _
      Err.Clear : tDict_(key_) = v_
    On Error GoTo 0
  Else
    tDict_.Add key_, v_
  End If
End Sub

Sub RemoveEvent(e_)
  If e_ Is Nothing Then Exit Sub
  ThisScript.SysAdminModeOn
    e_.Erase
  ThisScript.SysAdminModeOff
End Sub

'==============================================================================
' Функция в состав с блокировкой
'------------------------------------------------------------------------------
' o_:TDMSObject - Добавляем объект
' oParent_:TDMSObject - Блокируемый объект
' AddLocking:ITDMSEvent - Ссылка на блокирующее событие для последующей разблокировки
'==============================================================================
Function AddLocking(oParent_, o_)
  oParent_.Permissions = SysAdminPermissions
  ' Создаём запрос на редактирование состава
  Set eLock = EventCreate(ThisApplication,,"Редактирование состава", False)
  ' Ожидаем своей очереди
  bUnLocked = False
  Do
    bUnLocked = CheckEvent(ThisApplication, eLock)
  Loop Until bUnLocked
    ' Добавляем объект в состав
  Call AddContentLink(oParent_, o_)
  ' Удаляем событие
  RemoveEvent eLock
End Function

'==============================================================================
' Функция ожидает очереди на выполнение действия
'------------------------------------------------------------------------------
' o_:TDMSObject - Проверяемый объект
' eLock_:TDMSEvent - Событие в очереди
' CheckEvent:Boolean - Дождались
'==============================================================================
Function CheckEvent(o_, eLock_)
CheckEvent = False
  dEventTime = eLock_.Time
  seLockHandle = eLock_.Handle
  seLockDescription = eLock_.Description
  Set FiltEvent = o_.Events
  Set tFilter = FiltEvent.Filter
    tFilter.Class = 4096
  ' Так как в пределах 1 секунды сложно различать - необходимо подождать смены секунды
  While DateDiff("s", dEventTime, ThisApplication.CurrentTime) <= 0
    ThisApplication.Utility.Sleep(10)
  Wend
  ' События в очереди с датой до даты eLock_ выполняются раньше
  dBefore = DateAdd("s", -1, dEventTime)
  tFilter.TimeTo = dBefore
  ' При поиске по всему приложению - сужаем фильтр до 3 минут
  If TypeName(o_) = "ITDMSApplication" Then _
    tFilter.TimeFrom = DateAdd("n", -3, dEventTime)
  tFilter.On = True
  For Each e In FiltEvent
    If CBool(e.Type = 4098 And e.Description = seLockDescription) Then _
      If Not CancelEvent(e) Then Exit Function
  Next
  tFilter.On = False ' Сброс фильтра
  ' События в пределах 1 секунды выполняются всоответствии с величиной Handle
  ' Вторая проверка (в пределах 1 интервала)
  tFilter.TimeTo = dEventTime
  tFilter.TimeFrom = DateAdd("s", -1, dEventTime)
  tFilter.On = True
  For Each e In FiltEvent
    ' сам с собой не сравнивается
    If e.Handle <> seLockHandle Then _
      If CBool(e.Type = 4098 And e.Description = seLockDescription) Then _
        If e.Handle < seLockHandle Then Exit Function 'изменено 631 кейс 15.12.2011
  Next
CheckEvent = True
End Function

'==============================================================================
' Функция Удаление события с датой > 60 секунд
'------------------------------------------------------------------------------
' e_:TDMSEvent - Событие в очереди
'==============================================================================
Function CancelEvent(e_)
  CancelEvent = False
  dNow = ThisApplication.CurrentTime
  If DateDiff("s", e_.Time, dNow) > 120 Then
    CancelEvent = True
    RemoveEvent e_
  End If
End Function

' Упрощенная процедура добавления объекта в состав.
' Имеет ограничения - см. сохраненную процедуру в БД
' + не вызываются события Object_BeforeContentAdd, Object_ContentAdded.
Sub AddContentLink(ObjParent, ObjChild)
' T4FIX в 4-ке не должен загружаться состав, если не обращаться к его элементам
  ObjParent.Objects.Add ObjChild

'  guidParent = ObjParent.GUID
'  guidChild = ObjChild.GUID
'  sysnameUser = ThisApplication.CurrentUser.SysName
'  Set cmd = CreateObject("ADODB.Command")
'  cmd.ActiveConnection = GetConnection
' Запуситить хранимку
'  cmd.CommandType = 4
'  cmd.CommandText = "AddContentLink"
'  set param1 = cmd.CreateParameter("RetVal",3,4,-1,0)
'  cmd.Parameters.Append param1
'  set param2 = cmd.CreateParameter("ParentObjGUID",129,1,-1,guidParent)
'  cmd.Parameters.Append param2
'  set param3 = cmd.CreateParameter("ChildObjGUID",129,1,-1,guidChild)
'  cmd.Parameters.Append param3
'  set param4 = cmd.CreateParameter("UserSysName",129,1,-1,sysnameUser)
'  cmd.Parameters.Append param4
'  cmd.Execute
  ' cmd.Parameters("RetVal") - если хранимая процедура переписана для возврата значений
End Sub

 ' работает на нашей БД 
 Function GetConnection()       
  Set Connection = CreateObject("ADODB.Connection")
  pos = 0
  for i=1 to Len(ThisApplication.DatabaseLocation)
     str = mid(ThisApplication.DatabaseLocation, i, 1)
     if "\" = str then
        pos = pos+1
     end if
  next
  if pos > 1 then
     DBName = Left(ThisApplication.DatabaseLocation, InStr(ThisApplication.DatabaseLocation, ThisApplication.DataBaseName)-2)     
  else
     DBName = Left(ThisApplication.DatabaseLocation, InStr(ThisApplication.DatabaseLocation, "\")-1)
  end if
  ConnectionString = "Provider=SQLOLEDB;Data Source="&DBName&";Initial Catalog="&ThisApplication.DatabaseName&_
                     ";User ID="& ThisApplication.Attributes("ATTR_D_Login_SUBD").Value&";Password="&_
                     ThisApplication.Attributes("ATTR_D_Password_SUBD").Value&""
  Connection.Open ConnectionString
  set GetConnection = Connection
End Function

' работает на БД в Саратове (1 вариант работает с ошибкой)
'Function GetConnection()
'  Set Connection = CreateObject("ADODB.Connection")
'  ConnectionString = "Provider=SQLOLEDB;Data Source="&Left(ThisApplication.DatabaseLocation, InStr(ThisApplication.DatabaseLocation, "\")-1)&";Initial Catalog="&ThisApplication.DatabaseName&";User ID="&_
'    ThisApplication.Attributes("ATTR_D_Login_SUBD").Value&";Password="&_
'    ThisApplication.Attributes("ATTR_D_Password_SUBD").Value&""
'  Connection.Open ConnectionString
'  set GetConnection = Connection
'End Function
