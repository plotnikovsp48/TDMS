use CMD_KD_LIB_LOGS
use CMD_KD_USER_PERMISSIONS

'=================================
sub Set_Permission (object)

  object.Permissions = SysAdminPermissions

  if object is nothing then
    WriteError "Не указан объект, для которого необходимо задать права."
    exit sub
  end if
  
  'проверяем есть ли в настройках
  if CheckInSettings(object) then exit sub
  st = object.StatusName 
  if st<>"" then 
    if st = "STATUS_KD_CANCEL" then 
      Set_Cancel_Permission(object)
      exit sub
    end if
  end if  

  Select Case object.ObjectDefName
    Case "OBJECT_KD_FOLDER" 
        Set_Default_Permission object
    case "OBJECT_KD_DOC_OUT"
        Set_Our_Doc object
    case "OBJECT_KD_DOC_IN"
        Set_IN_Doc object   
    case "OBJECT_KD_ORDER_REP","OBJECT_KD_ORDER_NOTICE","OBJECT_KD_ORDER_SYS"     
        Set_Order_Permission object
    case "OBJECT_KD_DIRECTION"
        Set_ORD_Permission object
    case "OBJECT_KD_MEMO" 
        Set_Memo_Permission object
    case "OBJECT_KD_PROTOCOL"
        Set_Prot_Permission object      
    case "OBJECT_KD_ZA_PAYMENT"
        Set_Payment_Permission object   
    case "OBJECT_CORRESPONDENT","OBJECT_CORR_ADDRESS_PERCON"
        set_Cordent_Permission object
    case "OBJECT_STRU_OBJ"
        set_Dept_Permission object
    case "OBJECT_MARK"
        Set_Mark_Permission object 
    case "OBJECT_KD_ORDER_TEMPLATE","OBJECT_KD_AGREE_TEMPLATE"
        Set_Templ_Permission object
    Case Else 
        Set_Default_Permission object
  End Select
end sub 

'=================================
function CheckInSettings(object)
  CheckInSettings = false
  'проверяем есть ли в настройках
  if IsExistsGlobalVarrible("Settings") then RemoveGlobalVarrible("Settings") ' EV чтобы наверняка свои настройки были

  set settings = thisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB","GetSettingsByObjS", object, true)
  if not settings is nothing then 
    str =  settings.Attributes("ATTR_KD_PERMISSIONS").value
    if str > "" then  
       strArr = split(str,";")
       if UBound(strArr) >= 1 then 
          on error resume next
          execSetFun = ThisApplication.ExecuteScript(strArr(0), strArr(1), object)
          Err.Clear
          on error GoTo 0
          CheckInSettings = true
          exit function
       end if 
    end if
  end if
end function

'=================================
sub Set_Cancel_Permission(object)
  Del_all_roles object ' EV чтобы быть уверенным, что не остались лишние роли
  Add_Role object,"Пользователь", Object.CreateUser.Description, false  
end sub

'=================================
sub Set_Default_Permission (object)
  Del_all_roles object ' EV чтобы быть уверенным, что не остались лишние роли
  Add_Role object,"Пользователь","Все пользователи",false  
end sub

'=================================
sub set_Cordent_Permission (object)
  dev = ""
  if thisObject.Roles.Has("ROLE_DEVELOPER") then 
    set devUser = thisObject.Roles("ROLE_DEVELOPER").User
    if not devUser is nothing then dev = devUser.description
  end if
  Del_all_roles object ' EV чтобы быть уверенным, что не остались лишние роли
  if dev <>"" then   Add_Role object,"Разработчик", dev, false  
  Add_Role object,"Пользователь","Все пользователи",false  
  Add_Role object,"Разработчик","Делопроизводители",false  
end sub
'=================================
sub Set_Templ_Permission (object)
  Del_all_roles object ' EV чтобы быть уверенным, что не остались лишние роли
  if object.Attributes("ATTR_KD_PERS_TEMPL").value = true then
    set author = object.Attributes("ATTR_KD_AUTH").user
    if  author is nothing then set author = thisApplication.CurrentUser
    Add_Role object,"Разработчик", author.SysName,false  
  else
    Add_Role object,"Пользователь","Все пользователи",false  
  end if  
  Add_Role object,"Разработчик","Администраторы шаблонов",false  

end sub
'=================================
sub set_Dept_Permission (object)
  if  object.Roles.Count > 1 then exit sub ' Если уже задали, то перераздавать нельзя 
  Del_all_roles object ' EV чтобы быть уверенным, что не остались лишние роли
  Add_Role object,"Пользователь","Все пользователи",false  
  Add_Role object,"Разработчик","Редактирование оргструктуры",false  

end sub
'=================================
sub Del_all_roles (object)
  if object is nothing then
    WriteError "Не указан объект, для которого необходимо задать права."
    exit sub
  end if
  
'  For each Role in object.Roles
'    Role.Erase()
'  next
  object.Roles.RemoveAll
end sub

'=================================
Sub ADD_Role(Obj,myRole,myGroup, IsInheritable)
ThisScript.SysAdminModeOn
'thisApplication.AddNotify myRole & "  " &  Obj.description & " - " &cStr(timer) 
    Set Roles = Obj.Roles
    If ThisApplication.Groups.Has(myGroup) Then 
       Set Group = ThisApplication.Groups(myGroup)
'       if HasRoleG(Obj, myRole,Group )then exit sub
    else
      if ThisApplication.Users.Has(myGroup) then 
        set Group = ThisApplication.Users(myGroup)
'        if HasRoleU(Obj, myRole,Group )then exit sub
       else
'         msgbox "Не найдена группа [" & myGroup & "]!"
         WriteError "Не найдена группа [" & myGroup & "] для объекта [" & _
            Obj.Description & "]!"
         exit sub
       end if  
    End If
      
   if HasRole(Roles, myRole,Group )then exit sub
'    if HasRoleN(Obj, myRole,Group )then exit sub
    if ThisApplication.RoleDefs.Has(myRole) then 
      Set newRole = Roles.Create (myRole, Group) 
      newRole.Inheritable = IsInheritable
    else 
         WriteError "Не найдена роль [" &  description & "] для объекта [" & Obj.Description & "]!"
    end if 
'thisApplication.AddNotify myRole & " e - " & cStr(timer)
 ThisScript.SysAdminModeOff
End Sub

'=================================
function HasRoleU(Obj, myRole,Group )
  dim roles
  HasRoleU = false
  set roles = Obj.RolesForUser(Group)
  if roles.Count = 0 then exit function
  for each role in roles
    If Role.Description = myRole Then
    HasRoleU = true
    exit function
    end if 
  next
end function
'=================================
function HasRoleG(Obj, myRole,Group )
  dim roles
  HasRoleG = false
  set roles = Obj.RolesForGroup(Group)
  if roles.Count = 0 then exit function
  for each role in roles
    If Role.Description = myRole Then
    HasRoleG = true
    exit function
    end if 
  next
end function
'=================================
function HasRole(Roles, myRole,Group )
  dim role
    HasRole = true
'    For each Role in Roles
    for i = 0 to Roles.Count-1
      set Role = Roles(i)
       If Role.Description = myRole Then
          If not Role.Group is Nothing Then
             If Role.Group.Description = Group.Description Then 
                Exit function
             End If  
          else 
              If not Role.User is Nothing Then
                 If Role.User.SysName  = Group.SysName Then 
                    Exit function
                 End If  
               end if  
          End if    
       End if   
    Next 
    HasRole = false
end function
'=================================
sub Set_Our_Doc(docObj)
  Select Case docObj.StatusName
    Case "STATUS_KD_DRAFT","STATUS_KD_CHECK"
        call set_Doc_Edit_Permission(docObj)  
'    case "OBJECT_KD_DOC_OUT"
'        Set_Our_Doc docObj
    Case Else 
        set_Doc_Out_Usual_Permission docObj
        'Set_Default_Permission docObj
  End Select
end sub

'=================================
sub set_Doc_Edit_Permission (docObj)
  Del_all_roles docObj ' EV чтобы быть уверенным, что не остались лишние роли
  set excuter = docObj.Attributes("ATTR_KD_EXEC").user
  if not excuter is nothing then  
      Add_Role docObj, "Разработчик", excuter.SysName, false  
      Add_Role docObj, "Инициатор согласования", excuter.SysName, false  
  end if    
  set cont = docObj.Attributes("ATTR_KD_CHIEF").user
  if not cont is nothing then 
      Add_Role docObj, "Разработчик", cont.SysName, false  
      Add_Role docObj, "Инициатор согласования", cont.SysName, false  
  end if
'  if  docObj.Attributes("ATTR_KD_KI").value = true then _ ' EV пока делаем всегда
            Set_limited_Permition(docObj)
    
end sub

'=================================
sub set_Doc_Out_Usual_Permission (docObj)
  Del_all_roles docObj ' EV чтобы быть уверенным, что не остались лишние роли
  Add_Role docObj, "Пользователь", "Полный просмотр " & docObj.ObjectDef.Description, false   
  
'  set excuter = docObj.Attributes("ATTR_KD_EXEC").user
'  if not excuter is nothing then  _
'      Add_Role docObj, "Разработчик", excuter.SysName, false  
'  
'  set cont = docObj.Attributes("ATTR_KD_CHIEF").user
'  if not cont is nothing then _
'      Add_Role docObj, "Разработчик", cont.SysName, false  
'  
  set cont = docObj.Attributes("ATTR_KD_SIGNER").user
  if not cont is nothing then _
      Add_Role docObj, "Подписант", cont.SysName, false  
      
  Add_Role docObj, "Делопроизводитель", "GROUP_SECRETARY", false      

  if  docObj.Attributes("ATTR_KD_KI").value = true then 
    set excuter = docObj.Attributes("ATTR_KD_EXEC").user
    if not excuter is nothing then  _
        Add_Role docObj, "Пользователь", excuter.SysName, false  
    
    set cont = docObj.Attributes("ATTR_KD_CHIEF").user
    if not cont is nothing then _
        Add_Role docObj, "Пользователь", cont.SysName, false  

    Set_limited_Permition(docObj)
  else          
    Add_Role docObj, "Пользователь", "Все пользователи", false   
  end if
  set excuter = docObj.Attributes("ATTR_KD_EXEC").user
  if not excuter is nothing then _  
      Add_Role docObj, "Инициатор согласования", excuter.SysName, false  
  set cont = docObj.Attributes("ATTR_KD_CHIEF").user
  if not cont is nothing then _
      Add_Role docObj, "Инициатор согласования", cont.SysName, false  

     
  Add_Aprove(docObj)
end sub

'=================================
sub Add_Aprove(docObj)

  set agreeObj =  thisApplication.ExecuteScript("FORM_KD_AGREE", "GetAgreeObjByObj",docObj)
  if agreeObj is nothing then exit sub
  
  Set TAttrRows = agreeObj.Attributes("ATTR_KD_TAPRV").Rows
  for each row in TAttrRows
      set user = Row.Attributes("ATTR_KD_APRV").user
      if not user is nothing then  
            Add_Role docObj, "Согласующий", user.SysName, false   
      end if
  next
end sub

'=================================
sub Set_IN_Doc(docObj)
  Select Case docObj.StatusName
    Case "STATUS_KD_DRAFT"
        call set_DocIn_Edit_Permission(docObj)  
    Case Else 
        call set_DocIN_Usual_Permission(docObj)
  End Select
end sub

'=================================
sub set_DocIn_Edit_Permission(docObj)  
  Del_all_roles docObj ' EV чтобы быть уверенным, что не остались лишние роли
  
  Add_Role docObj, "Разработчик", "GROUP_SECRETARY", false 
'  if  docObj.Attributes("ATTR_KD_KI").value = true then _
            Set_limited_Permition(docObj)
 
end sub
'=================================
sub set_DocIN_Usual_Permission(docObj)  
  Del_all_roles docObj ' EV чтобы быть уверенным, что не остались лишние роли
  Add_Role docObj, "Пользователь", "Полный просмотр " & docObj.ObjectDef.Description, false   
  if  docObj.Attributes("ATTR_KD_KI").value = false then 
    Add_Role docObj, "Пользователь", "Все пользователи", false   
  else      
    Set_limited_Permition(docObj)
  end if 
  Add_Role docObj, "Делопроизводитель", "GROUP_SECRETARY", false  
end sub

'=================================
sub Set_Order_Permission (orderObj)
  Select Case orderObj.StatusName
    Case "STATUS_KD_ORDER_SENT","STATUS_KD_DRAFT"
        call set_Order_Edit_Permission(orderObj)  
    Case "STATUS_KD_ORDER_IN_WORK"
        call set_Order_InWork_Permission(orderObj)  
    Case Else 
        call Set_Default_Permission (orderObj)
  End Select
end sub
'=================================
sub set_Order_Edit_Permission(orderObj)  
  Del_all_roles orderObj ' EV чтобы быть уверенным, что не остались лишние роли
  
  set autor = orderObj.Attributes("ATTR_KD_AUTH").user
  if not autor is nothing then  _
      Add_Role orderObj, "Разработчик", autor.SysName, false  
  
  set reger = orderObj.Attributes("ATTR_KD_REG").user
  if not reger is nothing then _
      Add_Role orderObj, "Разработчик", reger.SysName, false  

  if orderObj.Attributes.has("ATTR_KD_CONTR") then 
    set cont = orderObj.Attributes("ATTR_KD_CONTR").user
    if not cont is nothing then _
        Add_Role orderObj, "Разработчик", cont.SysName, false  
  end if

   Add_Role orderObj, "Пользователь", "Все пользователи", false   
end sub
'=================================
sub set_Order_InWork_Permission(orderObj)  
  Del_all_roles orderObj ' EV чтобы быть уверенным, что не остались лишние роли
  
  set exec = orderObj.Attributes("ATTR_KD_OP_DELIVERY").user
  if not exec is nothing then  _
      Add_Role orderObj, "Исполнитель", exec.SysName, false  
   Add_Role orderObj, "Пользователь", "Все пользователи", false   
end sub

'=================================
sub Set_ORD_Permission(docObj)
  Select Case docObj.StatusName
    Case "STATUS_KD_DRAFT"
        call set_ORD_Edit_Permission(docObj)  
    Case Else 
        call set_ORD_Usual_Permission(docObj)
  End Select
end sub

'=================================
sub set_ORD_Edit_Permission (docObj)
  Del_all_roles docObj ' EV чтобы быть уверенным, что не остались лишние роли
  set excuter = docObj.Attributes("ATTR_KD_EXEC").user
  if not excuter is nothing then 
      Add_Role docObj, "Разработчик", excuter.SysName, false  
      Add_Role docObj, "Инициатор согласования", excuter.SysName, false  
  end if    
  set excuter = docObj.Attributes("ATTR_KD_REG").user
  if not excuter is nothing then  
      Add_Role docObj, "Разработчик", excuter.SysName, false  
      Add_Role docObj, "Инициатор согласования", excuter.SysName, false     
  end if    
'  if  docObj.Attributes("ATTR_KD_KI").value = true then _
            Set_limited_Permition(docObj)

end sub

'=================================
sub set_ORD_Usual_Permission (docObj)
  Del_all_roles docObj ' EV чтобы быть уверенным, что не остались лишние роли
  Add_Role docObj, "Пользователь", "Полный просмотр " & docObj.ObjectDef.Description, false   
  
  set cont = docObj.Attributes("ATTR_KD_SIGNER").user
  if not cont is nothing then _
      Add_Role docObj, "Подписант", cont.SysName, false  
      
  Add_Role docObj, "Делопроизводитель", "GROUP_SECRETARY", false      

  set excuter = docObj.Attributes("ATTR_KD_EXEC").user
  if not excuter is nothing then  _
      Add_Role docObj, "Пользователь", excuter.SysName, false     
      Add_Role docObj, "Инициатор согласования", excuter.SysName, false     
  Add_Aprove(docObj)
  if  docObj.Attributes("ATTR_KD_KI").value = true then 
    Set_limited_Permition(docObj)
  else
    Add_Role docObj, "Пользователь", "Все пользователи", false   
  end if          
end sub

'=================================
sub Set_Memo_Permission(docObj)
  Select Case docObj.StatusName
    Case "STATUS_KD_DRAFT","STATUS_SIGNING"
        call set_Doc_Edit_Permission(docObj)  
    Case Else 
        call set_Memo_Usual_Permission(docObj)
  End Select
end sub
'=================================
sub set_Memo_Usual_Permission (docObj)
  Del_all_roles docObj ' EV чтобы быть уверенным, что не остались лишние роли
  Add_Role docObj, "Пользователь", "Полный просмотр " & docObj.ObjectDef.Description, false   
  
'  set cont = docObj.Attributes("ATTR_KD_SIGNER").user
'  if not cont is nothing then _
'      Add_Role docObj, "Подписант", cont.SysName, false  
'      
  if  docObj.Attributes("ATTR_KD_KI").value = false then 
    Add_Role docObj, "Пользователь", "Все пользователи", false   
  else      
    Set_limited_Permition(docObj)
  end if 
  Add_Role docObj, "Делопроизводитель", "GROUP_SECRETARY", false  
  set excuter = docObj.Attributes("ATTR_KD_EXEC").user
  if not excuter is nothing then  
      Add_Role docObj, "Пользователь", excuter.SysName, false  
      Add_Role docObj, "Инициатор согласования", excuter.SysName, false  
  end if    
  set excuter = docObj.Attributes("ATTR_KD_CHIEF").user
  if not excuter is nothing then  
      Add_Role docObj, "Пользователь", excuter.SysName, false     
      Add_Role docObj, "Инициатор согласования", excuter.SysName, false  
  end if   
  Add_Aprove(docObj)
end sub

'=================================
sub Set_Prot_Permission(docObj)
  Select Case docObj.StatusName
    Case "STATUS_KD_DRAFT"
        call set_ORD_Edit_Permission(docObj)  
    Case Else 
        call set_Prot_Usual_Permission(docObj)
  End Select

end sub
'=================================
sub set_Prot_Usual_Permission (docObj)
  Del_all_roles docObj ' EV чтобы быть уверенным, что не остались лишние роли
  Add_Role docObj, "Пользователь", "Полный просмотр " & docObj.ObjectDef.Description, false   
  
  set cont = docObj.Attributes("ATTR_KD_EXEC").user
  if not cont is nothing then _
      Add_Role docObj, "Подписант", cont.SysName, false  
      
  Add_Role docObj, "Делопроизводитель", "GROUP_SECRETARY", false      

  if  docObj.Attributes("ATTR_KD_KI").value = true then 
    Set_limited_Permition(docObj)
  else
    Add_Role docObj, "Пользователь", "Все пользователи", false   
  end if          

  set excuter = docObj.Attributes("ATTR_KD_EXEC").user
  if not excuter is nothing then  _
      Add_Role docObj, "Пользователь", excuter.SysName, false  
      Add_Role docObj, "Инициатор согласования", excuter.SysName, false  
  set excuter = docObj.Attributes("ATTR_KD_REG").user
  if not excuter is nothing then  _
      Add_Role docObj, "Пользователь", excuter.SysName, false     
      Add_Role docObj, "Инициатор согласования", excuter.SysName, false  
  Add_Aprove(docObj)
end sub
'=================================
sub Set_Payment_Permission (docObj)
  Select Case docObj.StatusName
    Case "STATUS_KD_DRAFT"
        call set_Payment_Draft_Permission(docObj)  
    Case "STATUS_KD_AGREEMENT"
        call set_Payment_Agr_Permission(docObj)  
    Case Else 
        call set_Payment_Usual_Permission(docObj)
  End Select
end sub

'=================================
sub set_Payment_Draft_Permission(docObj)
  Del_all_roles docObj ' EV чтобы быть уверенным, что не остались лишние роли
  set excuter = docObj.Attributes("ATTR_KD_EXEC").user
  if not excuter is nothing then  
      Add_Role docObj, "Разработчик", excuter.SysName, false  
      Add_Role docObj, "Инициатор согласования", excuter.SysName, false  
  end if
'  if  docObj.Attributes("ATTR_KD_KI").value = true then _
            Set_limited_Permition(docObj)
  Add_Role docObj, "Делопроизводитель", "GROUP_SECRETARY", false  

end sub
'=================================
sub set_Payment_Agr_Permission(docObj)
'  Set_Limited_Permition( docObj) зачем два раза?
  Del_all_roles docObj ' EV чтобы быть уверенным, что не остались лишние роли
  Add_Role docObj, "Пользователь", "Полный просмотр " & docObj.ObjectDef.Description, false   
  set excuter = docObj.Attributes("ATTR_KD_EXEC").user
  if not excuter is nothing then  
      Add_Role docObj, "Пользователь", excuter.SysName, false  
      Add_Role docObj, "Инициатор согласования", excuter.SysName, false  
  end if
  Add_Aprove(docObj)
  Set_Limited_Permition( docObj)
end sub
'=================================
sub set_Payment_Usual_Permission(docObj)
  Del_all_roles docObj ' EV чтобы быть уверенным, что не остались лишние роли
  Add_Role docObj, "Пользователь", "Полный просмотр " & docObj.ObjectDef.Description, false   
  set excuter = docObj.Attributes("ATTR_KD_EXEC").user  
  if not excuter is nothing then  _
      Add_Role docObj, "Пользователь", excuter.SysName, false  
      
  Add_Aprove(docObj)
        
  Add_Role docObj, "Делопроизводитель", "GROUP_SECRETARY", false      

  set sing = docObj.Attributes("ATTR_KD_SIGNER").user
  if not sing is nothing then  _
      Add_Role docObj, "Подписант", sing.SysName, false  
  Set_Limited_Permition( docObj)
end sub
'=================================
Sub Set_Limited_Permition( Letter)  
    ThisScript.SysAdminModeOn   
    set OrderUsers = GetUsersByOrders(Letter)
    for each user  in OrderUsers
'      order.Permissions = SysAdminPermissions
'      set user = order.Attributes("ATTR_CORR_ORDER_TO").User
      if not user is nothing then _
          if Letter.RolesForUser(user).Count = 0 then _
              Add_Role letter,"Пользователь", user.SysName , false
    next 
End Sub
'=================================
function GetUsersByOrders(Letter)
  set query = ThisApplication.Queries("QUERY_KD_ALL_USER_BY_ORDERS_BY_DOC")
  query.Parameter("PARAM0") = letter.Handle
  set GetUsersByOrders = query.Users
  set query = ThisApplication.Queries("QUERY_ALL_CONTROL_BY_ORDER")
  query.Parameter("PARAM0") = letter.Handle
  set users = query.Users
  for each user in users
    GetUsersByOrders.Add user
  next
end function
'=================================
sub Set_Mark_Permission(Mark)
  
  Mark.Permissions = SysAdminPermissions
  Del_all_roles Mark
  set user = Mark.Attributes("ATTR_MARK_USER").User
  Add_Role Mark,"Разработчик",user.SysName, false
  
  if  Mark.Attributes("ATTR_MARK_TYPE").Value=ThisApplication.Classifiers("NODE_MARK_TYPE").Classifiers._
      Item("NODE_MARK_TYPE_INST").description then
    Add_Role Mark,"Пользователь","Все пользователи", false
  end if 
  
end sub  
