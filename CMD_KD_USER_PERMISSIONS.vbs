use CMD_KD_CURUSER_LIB

'==============================================================================
function IsAprover(user, docObj)
  set row = Get_AproveRow(user, docObj)
  if row is nothing then 
    IsAprover = false
  else
    IsAprover = true
  end if
end function

''==============================================================================
'function Get_AproveRow(user, docObj)
'    set Get_AproveRow = nothing
'    
'    if user is nothing or docObj is nothing then exit function
'    if not docObj.Attributes.has("ATTR_KD_TAPRV") then exit function
'    
'    Set TAttrRows = docObj.Attributes("ATTR_KD_TAPRV").Rows
'    for each row in TAttrRows
'      if row.Attributes("ATTR_KD_APRV").Value <> "" then 
'        if row.Attributes("ATTR_KD_APRV").User.SysName = user.SysName then 
'          set Get_AproveRow = row
'          exit function
'        end if  
'      end if
'    next

'end function

'==============================================================================
function IsExecutor(user, docObj)
  IsExecutor = false
  if not docObj.Attributes.has("ATTR_KD_EXEC") then exit function
  set execut = docObj.Attributes("ATTR_KD_EXEC").user
  if execut is nothing then exit function
  
  IsExecutor = (execut.SysName = user.SysName)
end function
'=============================================
function isInic(user, docObj)
  isInic = false
  for each role in docObj.RolesForUser(user)
    if role.RoleDefName = "ROLE_INITIATOR" then 
      isInic = true
      exit function
    end if  
  next
end function
''==============================================================================
'function isInic(user,docObj)
'    isInic = false
'    for each role in docObj.RolesForUser(thisApplication.CurrentUser)
'      if role.RoleDefName = "ROLE_INITIATOR" then 
'          isInic = true
'          exit function
'      end if 
'    next 
'end function
'==============================================================================
function IsAutor(user, docObj)
  IsAutor = false
  if not docObj.Attributes.has("ATTR_KD_AUTH") then exit function
  set execut = docObj.Attributes("ATTR_KD_AUTH").user
  if execut is nothing then exit function
  
  IsAutor = (execut.SysName = user.SysName)
end function

'==============================================================================
function IsController(user, docObj)
  IsController = false
  if not docObj.Attributes.has("ATTR_KD_CHIEF") then exit function
  set cont = docObj.Attributes("ATTR_KD_CHIEF").user
  if cont is nothing then exit function
  IsController = (cont.SysName = user.SysName)
end function
'==============================================================================
function IsSigner(user, docObj)
  IsSigner = false
  if not docObj.Attributes.has("ATTR_KD_SIGNER") then exit function
  set singer = docObj.Attributes("ATTR_KD_SIGNER").user
  if singer is nothing then exit function
  IsSigner = (singer.SysName = user.SysName)
end function

'==============================================================================
function IsApprover(user, docObj)
  IsApprover = false
  if not docObj.Attributes.has("ATTR_KD_ADRS") then exit function
  set singer = docObj.Attributes("ATTR_KD_ADRS").user
  if singer is nothing then exit function
  IsApprover = (singer.SysName = user.SysName)
end function
'==============================================================================
function isSecretary(user)
  isSecretary = user.Groups.Has("GROUP_SECRETARY")
end function

'==============================================================================
function Get_AproveRow(user, docObj)
  set Get_AproveRow = nothing
  set qry = thisApplication.Queries("QUERY_GET_AGREE_ROW")
  qry.Parameter("PARAM0") = docObj.handle
  qry.Parameter("PARAM1") = user'thisApplication.CurrentUser
  Set objs = qry.sheet
  if not objs is nothing then 
    if objs.RowsCount >0 then 
      set Get_AproveRow = objs.rowValue(0)
    end if
  end if    
end function
'==============================================================================
function IsCanAprove(user,docObj)
  IsCanAprove = HasAgreeOrder(user,docObj)'false
'  set row  = Get_AproveRow(user, docObj)
'  if row is nothing then exit function
'  set order =  row.attributes("ATTR_KD_LINK_ORDER").Object
'  if order is nothing then exit function
'  if order.StatusName = "STATUS_KD_ORDER_SENT" or  order.StatusName = "STATUS_KD_ORDER_IN_WORK" then _
'      IsCanAprove = true
end function
'==============================================================================
function HasSecr(user)
  HasSecr = false
  set qry = thisApplication.Queries("QUERY_GET_SECR_BY_CHIEF")
  qry.Parameter("PARAM0") = user 'thisApplication.CurrentUser
  set users = qry.Users
  if not users is nothing then 
    if users.Count > 0 then HasSecr = true
  end if
end function
'==============================================================================
function HasReview(user,docObj)
  HasReview = false
  set qry = thisApplication.Queries("QUERY_GET_REVIEW")
  qry.Parameter("PARAM1") = docObj.handle
  qry.Parameter("PARAM0") = user
  Set objs = qry.sheet
  if not objs is nothing then 
    if objs.RowsCount >0 then 
      HasReview = true
    end if
  end if    
end function

'==============================================================================
function HasAgreeOrder(user,docObj)
  HasAgreeOrder = false
  set qry = thisApplication.Queries("QUERY_KD_AFREE_ORDER")
  qry.Parameter("PARAM1") = docObj.handle
  qry.Parameter("PARAM0") = user
  Set objs = qry.sheet
  if not objs is nothing then 
    if objs.RowsCount >0 then 
      HasAgreeOrder = true
    end if
  end if    
end function
