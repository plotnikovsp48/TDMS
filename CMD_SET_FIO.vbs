'  on error resume next

'call SetFIO()

'call SetSysATTR()

'call DellForms()
'   
'call CreateGroup()


'on error goto 0

'sub CreateGroup()
'  if not thisApplication.Groups.Has("GROUP_MEMO_CHIEFS") then 
'      Set NewGroup = thisApplication.Groups.Create
'      NewGroup.SysName = "GROUP_MEMO_CHIEFS"
'      NewGroup.Description = "Группа утверждающих СЗ"
'      Set Users = NewGroup.Users 
'      set user = ThisApplication.Users("Сенютин Александр Анатольевич")
'      if user is nothing then 
'        thisApplication.AddNotify "user not fount - Сенютин Александр Анатольевич "
'      else
'        Users.Add user
'        thisApplication.AddNotify "add user - Сенютин Александр Анатольевич "
'      end if
'      set user = ThisApplication.Users("Артюшин Алексей Геннадьевич")
'      if user is nothing then 
'        thisApplication.AddNotify "user not fount - Артюшин Алексей Геннадьевич "
'      else
'        Users.Add user
'        thisApplication.AddNotify "add user - Артюшин Алексей Геннадьевич "
'      end if
'      set user = ThisApplication.Users("Теликова Раиса Сергеевна")
'      if user is nothing then 
'        thisApplication.AddNotify "user not fount - Теликова Раиса Сергеевна "
'      else
'        Users.Add user
'        thisApplication.AddNotify "add user - Теликова Раиса Сергеевна "
'      end if
'      set user = ThisApplication.Users("Оганов Гарри Сергеевич")
'      if user is nothing then 
'        thisApplication.AddNotify "user not fount - Оганов Гарри Сергеевич "
'      else
'        Users.Add user
'        thisApplication.AddNotify "add user - Оганов Гарри Сергеевич "
'      end if
'  end if              
'    if err.Number <> 0 then 
'      thisApplication.AddNotify err.Description
'      err.clear
'    end if
'end sub

'sub DellForms()
'  set objDef = thisApplication.ObjectDefs("OBJECT_KD_DIRECTION")
'  if objDef.InputForms.Has("FORM_KD_PR_SEND") then _
'      objDef.InputForms.Remove("FORM_KD_PR_SEND")
'  thisApplication.AddNotify " del FORM_KD_PR_SEND "
'  set objDef = thisApplication.ObjectDefs("OBJECT_KD_MEMO")
'  if objDef.InputForms.Has("FORM_KD_MEMO") then _
'      objDef.InputForms.Remove("FORM_KD_MEMO")
'  thisApplication.AddNotify " del FORM_KD_MEMO "      

'  if objDef.InputForms.Has("FORM_KD_MEMO_SEND") then _
'      objDef.InputForms.Remove("FORM_KD_MEMO_SEND")
'  thisApplication.AddNotify " del FORM_KD_PR_SEND "
'    if err.Number <> 0 then 
'      thisApplication.AddNotify err.Description
'      err.clear
'    end if
'end sub

'sub SetFIO
'  on error resume next
'  for each user in thisApplication.Users
'  
'    GetUserFIO = user.Description
'    UserArr = Split(GetUserFIO," ")
'  '   thisApplication.AddNotify Ubound(UserArr) 
'    select case Ubound (UserArr) 
'      case 1      GetUserFIO = Left(UserArr(1),1) & ". " & UserArr(0)
'      case 2,3    GetUserFIO = Left(UserArr(1),1) & ". " & Left(UserArr(2),1) & ". " & UserArr(0) 
'    end select   
'  '  GetUserFIO = Left(user.FirstName,1) & "." & Left(user.MiddleName,1) & ". " & user.LastName
'    user.Attributes("ATTR_KD_FIO").value = GetUserFIO
'    thisApplication.AddNotify user.description & " -> " & GetUserFIO
'    if err.Number <> 0 then 
'      thisApplication.AddNotify err.Description
'      err.clear
'    end if
'  next
'end sub

'sub SetSysATTR()    
'    on error resume next
'    if not thisApplication.Attributes.Has("ATTR_KD_FORMS_LIST") then 
'      thisApplication.Attributes.Create( thisApplication.AttributeDefs("ATTR_KD_FORMS_LIST"))
'    end if
'    thisApplication.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_KD_MEMO_CREATE;FORM_ARGEE_CREATE;FORM_KD_ORDER_CREATE;FORM_OUT_CREATE;FORM_ORD_CREATE"
'    thisApplication.AddNotify "add ATTR_KD_FORMS_LIST"

'    if not thisApplication.Attributes.Has("ATTR_KD_SYS_VER") then 
'      thisApplication.Attributes.Create( thisApplication.AttributeDefs("ATTR_KD_SYS_VER"))
'    end if
'    thisApplication.Attributes("ATTR_KD_SYS_VER").Value = "5.0.302"
'    thisApplication.AddNotify "add ATTR_KD_SYS_VER"
'    
'    if thisApplication.Attributes.Has("ATTR_KD_T_FORMS_SHOW") then 
'      set rows = thisApplication.Attributes("ATTR_KD_T_FORMS_SHOW").Rows
'      set newRow = rows.Create
'       NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_DIRECTION"
'       NewRow.Attributes("ATTR_KD_START_STATUS").Value = "STATUS_KD_AGREEMENT"
'       NewRow.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_KD_DOC_AGREE"
'       thisApplication.AddNotify "1 Add row OBJECT_KD_DIRECTION - STATUS_KD_AGREEMENT"
'  
'       set newRow = rows.Create
'       NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_DIRECTION"
'       NewRow.Attributes("ATTR_KD_START_STATUS").Value = "STATUS_KD_DRAFT"
'       NewRow.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_KD_DOC_AGREE"
'       thisApplication.AddNotify "2 Add row OBJECT_KD_DIRECTION - STATUS_KD_DRAFT"
'  
'       set newRow = rows.Create
'       NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_DIRECTION"
'       NewRow.Attributes("ATTR_KD_START_STATUS").Value = "CREATE"
'       NewRow.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_ORD_CREATE"
'       thisApplication.AddNotify "3 Add row OBJECT_KD_DIRECTION - CREATE"
'  
'       set newRow = rows.Create
'       NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_DIRECTION"
'       NewRow.Attributes("ATTR_KD_START_STATUS").Value = "STATUS_SIGNED"
'       NewRow.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_KD_DOC_ORDERS"
'       thisApplication.AddNotify "4 Add row OBJECT_KD_DIRECTION - STATUS_KD_IN_FORCE"
'  
'       set newRow = rows.Create
'       NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_DIRECTION"
'       NewRow.Attributes("ATTR_KD_START_STATUS").Value = "STATUS_KD_IN_FORCE"
'       NewRow.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_KD_DOC_ORDERS"
'       thisApplication.AddNotify "5 Add row OBJECT_KD_DIRECTION - STATUS_KD_IN_FORCE"
'  
'       set newRow = rows.Create
'       NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_MEMO"
'       NewRow.Attributes("ATTR_KD_START_STATUS").Value = "STATUS_KD_DRAFT"
'       NewRow.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_KD_MEMO_CARD"
'       thisApplication.AddNotify "6 Add row OBJECT_KD_DIRECTION - FORM_KD_DOC_ORDERS"
'  
'       set newRow = rows.Create
'       NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_MEMO"
'       NewRow.Attributes("ATTR_KD_START_STATUS").Value = "CREATE"
'       NewRow.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_KD_MEMO_CREATE"
'       thisApplication.AddNotify "7 Add row OBJECT_KD_DIRECTION - CREATE"
'  
'       set newRow = rows.Create
'       NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_MEMO"
'       NewRow.Attributes("ATTR_KD_START_STATUS").Value = "STATUS_KD_AGREEMENT"
'       NewRow.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_KD_DOC_AGREE"
'       thisApplication.AddNotify "6 Add row OBJECT_KD_DIRECTION - STATUS_KD_AGREEMENT"
'  
'       set newRow = rows.Create
'       NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_MEMO"
'       NewRow.Attributes("ATTR_KD_START_STATUS").Value = "STATUS_SIGNED"
'       NewRow.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_KD_DOC_AGREE"
'       thisApplication.AddNotify "7 Add row OBJECT_KD_DIRECTION - STATUS_SIGNED"
'  
'       set newRow = rows.Create
'       NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_MEMO"
'       NewRow.Attributes("ATTR_KD_START_STATUS").Value = "STATUS_KD_APPROVED"
'       NewRow.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_KD_DOC_ORDERS"
'       thisApplication.AddNotify "7 Add row OBJECT_KD_DIRECTION - STATUS_KD_APPROVED"
'  
'       rows.Update
'     end if
'      Set Rows = ThisApplication.Attributes("ATTR_AGREENENT_SETTINGS").Rows
'      For Each Row in Rows
'        If Row.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_MEMO" Then
'          Row.Attributes("ATTR_KD_START_STATUS") = "STATUS_KD_DRAFT;STATUS_SIGNING;STATUS_SIGNED"
'          Row.Attributes("ATTR_AFTER_AGREE_FUNCTION") = "CMD_KD_AGREEMENT_LIB;AddApproverOrder"
'          thisApplication.AddNotify "set ATTR_KD_START_STATUS" 
'          Exit For
'        End If
'      Next

'end sub
