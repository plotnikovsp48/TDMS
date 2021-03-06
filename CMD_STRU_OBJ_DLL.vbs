USE "CMD_S_DLL"

'==========================================================
' Возвращает руководителя отдела
'----------------------------------------------------------
' dept_:TDMSObject - Элемент оргструктуры
' GetChiefByDept:TDMSUser   Ссылка на пользователя
'                     Nothing - Руководитель не задан          
'==========================================================
Function GetChiefByDept(dept_)
  Set GetChiefByDept = Nothing
  ' Проверка входных параметров
  If VarType(dept_) <> 9 Then Exit Function
  If dept_ Is Nothing Then Exit Function
  If Not dept_.IsKindOf("OBJECT_STRU_OBJ") Then Exit Function
  If dept_.Attributes.Has("ATTR_KD_CHIEF") Then
    Set GetChiefByDept = dept_.Attributes("ATTR_KD_CHIEF").User
  End If
End Function

'==========================================================
' Возвращает руководителя элемента оргструктуры, к которому относится пользователь
'----------------------------------------------------------
' u_:TDMSUser - пользователь
' GetChiefForUser:TDMSUser   Ссылка на элемент оргструктуры
'                      Nothing - элемент оргструктуры не задан           
'==========================================================
Function GetChiefForUser(u_)
  Set GetChiefForUser = Nothing
  
  ' Проверка входных параметров
  If VarType(u_) <> 9 Then Exit Function
  If u_ Is Nothing Then Exit Function
  
  Set oDept = GetDept(u_)
  If oDept Is Nothing Then Exit Function
  Set GetChiefForUser = GetChiefByDept(oDept)
End Function

'==========================================================
' Возвращает элемент оргструктуры, к которому относится пользователь
'----------------------------------------------------------
' u_:TDMSUser - пользователь
' GetDept:TDMSObject   Ссылка на элемент оргструктуры
'                      Nothing - элемент оргструктуры не задан          
'==========================================================
Function GetDept(u_)
  Set GetDept = Nothing
  ' Проверка входных параметров
  If VarType(u_) <> 9 Then Exit Function
  If u_ Is Nothing Then Exit Function
  
  If u_.Attributes.Has("ATTR_KD_USER_DEPT") Then
    If u_.Attributes("ATTR_KD_USER_DEPT").Empty = False Then
      If not u_.Attributes("ATTR_KD_USER_DEPT").Object is Nothing Then
        Set GetDept = u_.Attributes("ATTR_KD_USER_DEPT").Object
      End If
    End If
  End If
End Function

'======================================================================================
'Возвращает элемент оргструктуры по названию
'======================================================================================
Function GetDeptByName(OrgName)
  Set GetDeptByName = Nothing
  If OrgName = "" Then Exit Function
  For Each StrObj in ThisApplication.ObjectDefs("OBJECT_STRU_OBJ").Objects
    If StrObj.Attributes.Has("ATTR_NAME") Then
      If StrComp(StrObj.Attributes("ATTR_NAME").Value,OrgName,vbTextCompare) = 0 Then
          'If not StrObj.Attributes("ATTR_KD_CHIEF").User is Nothing Then
            Set GetDeptByName = StrObj
            Exit For
          'End If
      End If
    End If
  Next
End Function

'==========================================================
' Возвращает руководителя элемента оргструктуры, 
' которому подчиняется пользователь по иерархии. 
' При этом руководитель должен входить в состав группы
' Если 
'----------------------------------------------------------
' u_:TDMSUser - пользователь
' GroupName:TDMSGroup Системный идентификатор группы, в коорую входит искомый пользователь
'                      Если группа не задана, то возвращает руководителя элемента оргструктуры,
'                      в который входит пользователь
' GetChiefForUserByGroup:TDMSUser   Ссылка на элемент оргструктуры
'                      Nothing - элемент оргструктуры не задан           
'==========================================================
Function GetChiefForUserByGroup(u_,GroupName)
  Set GetChiefForUserByGroup = Nothing
  Set Dept = GetDeptForUserByGroup(u_,GroupName)
  
  If Dept Is Nothing Then
    Set Chief = GetChiefForUser(u_)
  Else
    Set Chief = GetChiefByDept(Dept)
  End If
  If Chief Is Nothing Then Exit Function
  Set GetChiefForUserByGroup = Chief
End Function

'==========================================================
' Возвращает начальника отдела, 
' которому подчиняется пользователь по иерархии. 
'----------------------------------------------------------
' u_:TDMSUser - пользователь
' GetDeptChiefByUser:TDMSUser   Ссылка на элемент оргструктуры
'                      Nothing - элемент оргструктуры не задан           
'==========================================================
Function GetDeptChiefByUser(u_)
  Set GetDeptChiefByUser = Nothing
  If u_ Is Nothing Then Exit Function
  Set GetDeptChiefByUser = GetChiefForUserByGroup(u_,"GROUP_LEAD_DEPT")
End Function


'===========================================================================================================
' Возвращает ссылку на элемент оргструктуры, у которого руководитель входит в группу Руководители отделов
' Поиск идет по иерархии вверх от пользователя
' Предназначена для получения ссылки на элемент оргструктуры, являющегося отделом
'-----------------------------------------------------------------------------------------------------------
'===========================================================================================================
Function GetDeptForUserByGroup(u_,GroupName)
  Set GetDeptForUserByGroup = Nothing
' Проверка входных параметров
  If VarType(u_) <> 9 Then Exit Function
  If u_ Is Nothing Then Exit Function
  If ThisApplication.Groups.Has(GroupName) Then 
    Set Dept = GetDept(u_)
    If Dept Is Nothing Then Exit Function
    Set oDef = Dept.ObjectDef
    Check = False
    Do While Check = False
      Set Chief = GetChiefByDept(Dept)
      If Chief Is Nothing Then
        Set p = Dept.Parent
        If Not p Is Nothing Then
          If not Dept.Parent is Nothing And Dept.Parent.ObjectDef.Handle = Dept.ObjectDef.Handle Then
            Set Dept = Dept.Parent
          Else
            Exit Do
          End If
        End If
      Else
        If Chief.Groups.Has(GroupName) = True Then
          Check = True
          Exit Do
        Else
          If not Dept.Parent is Nothing And Dept.Parent.ObjectDef.Handle = Dept.ObjectDef.Handle Then
            Set Dept = Dept.Parent
          Else
            Exit Do
          End If
        End If
      End If
    Loop
    
    If Check = False Then
      Set Dept = GetDept(u_)
    End If
  Else
    Set Dept = GetDept(u_)
  End If
  
  If Dept Is Nothing Then Exit Function
  
  Set GetDeptForUserByGroup = Dept
End Function

'==========================================================
' Возвращает код элемента оргструктуры, к которому относится пользователь
'----------------------------------------------------------
' u_:TDMSUser - пользователь
' GetDeptCode:String - код элемента оргструктуры
'==========================================================
Function GetDeptCode(dept_)
  GetDeptCode = ""
  ' Проверка входных параметров
  If VarType(dept_) <> 9 Then Exit Function
  If dept_ Is Nothing Then Exit Function
  
  aCode = "ATTR_CODE"
  If dept_.Attributes.Has(aCode) Then
    GetDeptCode = dept_.Attributes(aCode).Value
  End If
End Function

'==========================================================
' Возвращает код элемента оргструктуры, к которому относится пользователь
'----------------------------------------------------------
' u_:TDMSUser - пользователь
' GetDeptCodeByUser:String - код элемента оргструктуры
'==========================================================
Function GetDeptCodeByUser(u_)
  GetDeptCodeByUser = ""
  ' Проверка входных параметров
  If VarType(u_) <> 9 Then Exit Function
  If u_ Is Nothing Then Exit Function
  Set oDept = GetDept(u_)
  If oDept Is Nothing Then Exit Function
  GetDeptCodeByUser = GetDeptCode(oDept)
End Function


'==========================================================
' Возвращает пользователя с указанной должностью
'----------------------------------------------------------
' post:String - название должности
' GetUserByPOST:TDMSUser - пользователь
'==========================================================
Function GetUserByPOST(post)
  Set GetUserByPOST = Nothing
  For each user In ThisApplication.Users
    If user.attributes.Has("ATTR_POST") Then 
      Set clspost = user.attributes("ATTR_POST").Classifier
      If Not clspost Is Nothing Then
        If clspost.Description = post Then
          Set GetUserByPOST = user
          Exit Function
        End If
      End If
    End If
  Next
End Function

Function GetChiefAccountant()
  Set GetChiefAccountant = Nothing
    post = "Главный бухгалтер"
    Set User = GetUserByPOST(post)
    If User is Nothing Then 
      OrgName = "Бухгалтерия"
      Set Dept = GetDeptByName(OrgName)
      Set user = GetChiefByDept(Dept)
    End If
  Set GetChiefAccountant = user
End Function

'======================================================================================
' Возвращает ссылку на отдел из таблицы настроек отделов и групп, в зависимости от метки
'--------------------------------------------------------------------------------------
' ID: Строка - метка действия
' GetDeptByID: TDMSObject - Ссылка на отдел
'======================================================================================
Function GetDeptByID (ID)
  Set GetDeptByID = Nothing
      If ThisApplication.Attributes.Has("ATTR_STRU_OBJ_SETTINGS") Then
        Set Table = ThisApplication.Attributes("ATTR_STRU_OBJ_SETTINGS")
        For Each row In Table.Rows
          If row.Attributes("ATTR_ID") = ID Then
            Set GetDeptByID = row.Attributes("ATTR_DEPT").Object
            Exit For
          End If
        Next
      End If
End Function

'======================================================================================
' Возвращает ссылку на руководителя отдела из таблиы настроек отделов и групп, в зависимости от метки
'--------------------------------------------------------------------------------------
' ID: Строка - метка действия
' GetChiefByID: TDMSObject - Ссылка на отдел
'======================================================================================
Function GetChiefByID(ID)
  Set GetChiefByID = Nothing
  
  Set oDept = GetDeptByID(ID)
  
  If Not oDept Is Nothing Then
    If oDept.Attributes.Has("ATTR_KD_CHIEF") Then
      Set GetChiefByID = oDept.Attributes("ATTR_KD_CHIEF").User
    End If
  End If
End Function
      
     
Function CheckObj12()
  CheckObj12 = False
  Set Obj = ThisObject
  Set CU = ThisApplication.CurrentUser
  Set chief = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetChiefForUserByGroup",CU,"GROUP_LEAD_DEPT")
  If chief Is Nothing Then Exit Function
  Set Resp = Obj.Attributes("ATTR_RESPONSIBLE").User
  If Resp Is Nothing Then Exit Function
  CheckObj12 = (Resp.Handle = chief.Handle)
End Function

' Функция проверяет, относятся ли два пользователя к одному отделу
' Отделом считается элемент оргструктуры, руководитель которого состоит в группе Руководители отделов
Function IsTheSameDeptByUsers(u1,u2)
thisapplication.DebugPrint "IsTheSameDeptByUsers " & Time
  IsTheSameDeptByUsers = False
  
  If IsEmpty(u1) or IsEmpty(u2) Then Exit Function
  If u1 Is Nothing or u2 Is Nothing Then Exit Function
  
  ' Вариант 1 - оба пользователя - один и тот же пользователь
  If u1.Handle = u2.Handle Then
    IsTheSameDeptByUsers = True
    thisapplication.DebugPrint "IsTheSameDeptByUsers -1 " & Time
    Exit Function
  End If
  
  ' Вариант 2 - оба пользователя из одного элемента оргструктуры
  Set Dept1 = GetDept(u1)
  Set Dept2 = GetDept(u2)
  If Dept1 Is Nothing Or Dept2 Is Nothing Then Exit Function
  
  If Dept1.Handle = Dept2.Handle Then 
    IsTheSameDeptByUsers = True
    thisapplication.DebugPrint "IsTheSameDeptByUsers -2" & Time
    Exit Function
  End If
  
  ' Вариант 3 - Если начальник отдела обоих пользователей один и тот же
  Set Dept1 = GetDeptForUserByGroup(u1,"GROUP_LEAD_DEPT")
  Set Dept2 = GetDeptForUserByGroup(u2,"GROUP_LEAD_DEPT")
  If Dept1 Is Nothing Or Dept2 Is Nothing Then Exit Function
  
  If Dept1.Handle = Dept2.Handle Then 
    IsTheSameDeptByUsers = True
    thisapplication.DebugPrint "IsTheSameDeptByUsers -3 " & Time
    Exit Function
  End If
  thisapplication.DebugPrint "IsTheSameDeptByUsers (end) " & Time
End Function

'==========================================================
' Возвращает коллекцию вложенных элементов оргструктуры
'----------------------------------------------------------
' dept_:TDMSObject - Элемент оргструктуры
' GetGroupsByDept:TDMSUser   Ссылка на пользователя
'                     Nothing - Руководитель не задан          
'==========================================================
Function GetGroupsByDept(dept_)
  Set GetGroupsByDept = Nothing
  ' Проверка входных параметров
  If VarType(dept_) <> 9 Then Exit Function
  If dept_ Is Nothing Then Exit Function
  If Not dept_.IsKindOf("OBJECT_STRU_OBJ") Then Exit Function
  
  Set GetGroupsByDept = dept_.ContentAll.ObjectsByDef("OBJECT_STRU_OBJ")
End Function

'==========================================================
' Возвращает коллекцию руководителей элементов оргструктуры
' в составе отдела
'----------------------------------------------------------
' dept_:TDMSObject - Элемент оргструктуры
' GetGroupsChiefsByDept:TDMSUser   Ссылка на пользователя
'                     Nothing - Руководитель не задан          
'==========================================================
Function GetGroupsChiefsByDept(dept_)
  Set GetGroupsChiefsByDept = Nothing
  ' Проверка входных параметров
  If VarType(dept_) <> 9 Then Exit Function
  If dept_ Is Nothing Then Exit Function
  If Not dept_.IsKindOf("OBJECT_STRU_OBJ") Then Exit Function
  Set oDepts = GetGroupsByDept(dept_)
  Set users = ThisApplication.CreateCollection(tdmUsers)
  Set user = GetChiefByDept(dept_)
  If Not user Is Nothing Then
    Users.Add User
  End If
  For each d In oDepts
    Set user = GetChiefByDept(d)
    If Not user Is Nothing Then
      If Users.Has(User) = False Then
        Users.Add User
      End If
    End If
  Next
  Set GetGroupsChiefsByDept = Users
End Function

'==========================================================
' Возвращает полный перечень сотрудников отдела, включая группы
' в составе отдела
'----------------------------------------------------------
' dept_:TDMSObject - Элемент оргструктуры
' GetAllUsersByDept:TDMSUsers   коллекция сотрудников всех элементов
'                       оргструктуры от заданной ветки
'==========================================================
Function GetAllUsersByDept(dept_)
  Set GetAllUsersByDept = Nothing
  ' Проверка входных параметров
  If VarType(dept_) <> 9 Then Exit Function
  If dept_ Is Nothing Then Exit Function
  If Not dept_.IsKindOf("OBJECT_STRU_OBJ") Then Exit Function
  Set oDepts = GetGroupsByDept(dept_)
  Set usrs = ThisApplication.CreateCollection(tdmUsers)
  For each u In GetUsersByDept(dept_)
    usrs.add u
  Next
  For each d In oDepts
    For each u In GetUsersByDept(d)
      usrs.add u
    Next
  Next
  Set GetAllUsersByDept = Usrs
End Function

'==========================================================
' Возвращает сотрудников элемента оргструктуры
'----------------------------------------------------------
' dept_:TDMSObject - Элемент оргструктуры
' GetUsersByDept:TDMSUsers   коллекция сотрудников элемента оргструктуры
'==========================================================
Function GetUsersByDept(dept_)
  Set GetUsersByDept = Nothing
  If dept_ Is Nothing Then Exit Function
  Set q = ThisApplication.Queries("QUERY_DEPT_USERS")
  q.Parameter("PARAM0") = dept_

  Set GetUsersByDept = q.Users
End Function


' Возвращает нормоконтролера по-умолчанию
Function GetDefaultNK(sysObj_)
'thisApplication.AddNotify sysObj_.Description
  Set GetDefaultNK = Nothing
  If sysObj_ Is Nothing Then Exit Function
  Set p = sysObj_.Parent
  Set user = Nothing
  If p.Attributes.Has("ATTR_NK_PERSON") Then
    If p.Attributes("ATTR_NK_PERSON").Empty = False Then
      Set user = p.Attributes("ATTR_NK_PERSON").User
    End If
  End If
  If User Is Nothing Then
    If p.Attributes.Has("ATTR_S_DEPARTMENT") Then
      If p.Attributes("ATTR_S_DEPARTMENT").Empty = False Then
        Set dept = p.Attributes("ATTR_S_DEPARTMENT").Object
          If not dept Is Nothing Then
            If dept.roles.Has("ROLE_NK") = True Then 
              Set User = dept.Roles("ROLE_NK").User
            End If
          End If
      End If
    End If
  End If
  If User Is Nothing Then Set User = GetDeptChiefByUser(ThisApplication.CurrentUser)
  Set GetDefaultNK = User
End Function
