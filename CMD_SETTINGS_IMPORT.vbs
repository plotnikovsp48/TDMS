
call ChangeOrdParent()

' EV перенос поручений на ознакомление
sub ChangeOrdParent()
  set objYear = thisApplication.GetObjectByGUID("{33E0C3A2-FDE9-4D73-8C27-929F6C47FDF2}")
  if objYear is nothing then
    str = "Не найдена папка с годом для поручений"
    msgbox str, vbCritical
    thisApplication.AddNotify str
    exit sub
  end if
  set qry = thisApplication.Queries("QUERY_CHILD_ORDERS")
  set objs = qry.Objects
  for each order  in objs
   set oldPar = order.Parent
   order.Parent = objYear
   objYear.Objects.Add order
   oldPar.Objects.Remove order
   order.update
   thisApplication.AddNotify "order " & order.description & " was moved"
  next
end sub

'call CreateSysAttrs()

'if thisApplication.CurrentUser.Type = 2 then _
'    call del_Docs()

'sub del_Docs()
'  set dlg = thisApplication.Dialogs.SelectDlg
'  set qry = thisApplication.Queries("QUERY_KD_ALL_DOCS")
'  set sh = qry.Sheet
'  dlg.UseCheckBoxes = true
'  dlg.SelectFrom = sh
'  if dlg.Show then 
'    set objs = dlg.Objects.Objects
'    thisApplication.AddNotify "Selected " & CStr(objs.count) & " docs - " & Cstr(now)
'    for each obj in objs
'      thisApplication.AddNotify obj.Description & " "& CStr(Now)
'      Del_Doc(obj)
'    next
'    del_obj_without_doc()
'  end if
'  thisApplication.AddNotify "finished - " & Cstr(now)
'  
'end sub

'sub del_obj_without_doc()
'  'поручения
'  set query = thisApplication.Queries("QUERY_A042AE92_BD48_4181_AEFD_3B7B29C4F113")
'  set objs = query.Objects
'  thisApplication.AddNotify "has " & CStr(objs.count) & " orders - " & Cstr(now)
'  for each teg in objs 
'      teg.Erase
'  next
'  'согласвоание
'  set query = thisApplication.Queries("QUERY_7C71D8F5_C845_40E0_878F_B68A33255BC0")
'  set objs = query.Objects
'  thisApplication.AddNotify "has " & CStr(objs.count) & " agreements - " & Cstr(now)
'  for each teg in objs 
'      teg.Erase
'  next
'  'markd
'  set query = thisApplication.Queries("QUERY_C4AE8E9A_7F05_48BE_B9C3_4E518932734E")
'  set objs = query.Objects
'  thisApplication.AddNotify "has " & CStr(objs.count) & " marks - " & Cstr(now)
'  for each teg in objs 
'      teg.Erase
'  next
'  
'end sub

'sub del_Doc(docObj)
'  on error resume next
'  'удаляем все проучения
'  set qry = thisApplication.Queries("QUERY_KD_ALL_OREDRS_BY_DOC")
'  qry.Parameter("PARAM0") = docObj
'  set objs = qry.Objects
'  thisApplication.AddNotify "has " & CStr(objs.count) & " ordets - " & Cstr(now)
'  for each order in objs
'    order.Erase
'  next
'  'удаляем согласования
'  set query = ThisApplication.Queries("QUERY_GET_ARGEEMENT")
'  query.Parameter("PARAM0") = docObj.handle
'  set objs = query.Objects
'  thisApplication.AddNotify "has " & CStr(objs.count) & " argreements - " & Cstr(now)
'  for each obj in objs
'    set agree = obj
'    agree.Erase
'  next
'  'метки
'  set query = thisApplication.Queries("QUERY_OBJ_MARK")
'  query.Parameter("PARAM0") = docObj.handle
'  set objs = query.Objects
'  thisApplication.AddNotify "has " & CStr(objs.count) & " mark - " & Cstr(now)
'  for each teg in objs 
'      teg.Erase
'  next
'  
'  'связи надо проверять?
'  docObj.Erase
'  if err.Number <> 0 then 
'    msgbox err.Description
'    err.Clear
'  end if
'  
'end sub
''DelQuery()

'sub DelQuery()
'  set folder =  thisApplication.GetObjectByGUID("{1DDEE052-4DBE-44A5-8058-7B2EC4AAB9EF}")
'  if not folder is nothing then 
'      if folder.Queries.Has("QUERY_ARM_5_CP") then 
'        folder.Queries.Remove(thisApplication.Queries("QUERY_ARM_5_CP") )
'        thisApplication.AddNotify "remove QUERY_ARM_5_CP"
'      end if
'  end if
'end sub

'sub DelQuery()
'  set q =  thisApplication.Queries("QUERY_ARM_ORDER_IN")
'  if q.Queries.Has("QUERY_ARM_2_D") then 
'        q.Queries.Remove(thisApplication.Queries("QUERY_ARM_2_D") )
'        thisApplication.AddNotify "remove QUERY_ARM_2_D"
'  end if        
'  set folder =  thisApplication.GetObjectByGUID("{1DDEE052-4DBE-44A5-8058-7B2EC4AAB9EF}")
'  if not folder is nothing then 
'      if folder.Queries.Has("QUERY_ARM_1_DCP") then 
'        folder.Queries.Remove(thisApplication.Queries("QUERY_ARM_1_DCP") )
'        thisApplication.AddNotify "remove QUERY_ARM_1_DCP"
'      end if
'      if folder.Queries.Has("QUERY_FAVORIT") then 
'        folder.Queries.Remove(thisApplication.Queries("QUERY_FAVORIT") )
'        thisApplication.AddNotify "remove QUERY_FAVORIT"
'      end if
'      if folder.Queries.Has("QUERY_ON_CONTOL") then 
'        folder.Queries.Remove(thisApplication.Queries("QUERY_ON_CONTOL") )
'        thisApplication.AddNotify "remove QUERY_ON_CONTOL"
'      end if
'      if folder.Queries.Has("QUERY_ARM_5_CP") then 
'        folder.Queries.Remove(thisApplication.Queries("QUERY_ARM_5_CP") )
'        thisApplication.AddNotify "remove QUERY_ARM_5_CP"
'      end if

'  end if
'end sub

'SetSysATTR()  

'call UpdateUrAddress() ' изменяем юр. адрес

'call CreateSysAttrs() 'создаем атрибут для нового сис айди  и группы
'call CreateDocFolder()
'call delCMD()
'call changeD()
'call setSysAttr()

'sub SetSysATTR()    
'  if thisApplication.Attributes.Has("ATTR_KD_T_FORMS_SHOW") then 
'      set rows = thisApplication.Attributes("ATTR_KD_T_FORMS_SHOW").Rows
'       set newRow = rows.Create
'       NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_DOC_OUT"
'       NewRow.Attributes("ATTR_KD_START_STATUS").Value = "STATUS_SIGNING"
'       NewRow.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_KD_OUT_CARD"
'       thisApplication.AddNotify "1 Add row OBJECT_KD_DOC_OUT - STATUS_SIGNING"
'  end if     
'end sub
''=================================
'sub changeD()
'  set obj = thisApplication.GetObjectByGUID("{1DDEE052-4DBE-44A5-8058-7B2EC4AAB9EF}")' делопроизводство секретарь
'  if obj is nothing then 
'    thisApplication.AddNotify "Folder делопроизводство not fount"
'    exit sub
'  end if
'  if obj.Queries.Has("QUERY_ARM_2_D") then 
'    obj.Queries.Remove("QUERY_ARM_2_D")
'    thisApplication.AddNotify "Remove QUERY_ARM_2_D"
'  end if
'  if not obj.Queries.Has("QUERY_ARM_5_CP") then 
'    obj.Queries.Add("QUERY_ARM_5_CP")
'    thisApplication.AddNotify "add QUERY_ARM_5_CP"
'  end if

'  set obj = thisApplication.GetObjectByGUID("{CB841149-1125-45E0-BB2B-2ECE14BA8357}")'поиск
'  if obj is nothing then 
'    thisApplication.AddNotify "Folder поиск not fount"
'    exit sub
'  end if
'  if not obj.Queries.Has("QUERY_S_KD_ORD") then 
'    obj.Queries.add("QUERY_S_KD_ORD")
'    thisApplication.AddNotify "add QUERY_S_KD_ORD"
'  end if

'  set  cmds = thisApplication.Root.ObjectDef.Commands
'  if cmds.has("CMD_SET_FIO") then cmds.Remove("CMD_SET_FIO")
'  'if cmds.has("CMD_KD_EDIT_COMMENT") then cmds.Remove("CMD_KD_EDIT_COMMENT")
'  
'  set qry = thisApplication.Queries("QUERY_ARM_1_DCP_COUNT")
'  if not qry is nothing then qry.Erase ' .SysName = "QUERY_ARM_1_DCP_COUNT_old"
'end sub
''=================================
'sub delCMD()
'  if thisApplication.Commands.Has("CMD_KD_ADD_QUERY") then 
'    set cmd  = thisApplication.Commands("CMD_KD_ADD_QUERY")
'    cmd.Erase
'  end if
''  thisApplication.Commands.Remove(thisApplication.Commands("CMD_KD_ADD_QUERY"))
'end sub
''=================================
'sub setSysAttr()
'    Set Rows = ThisApplication.Attributes("ATTR_AGREENENT_SETTINGS").Rows
'      For Each Row in Rows
'        if Row.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_DIRECTION" then 
'            Row.Attributes("ATTR_AFTER_AGREE_FUNCTION") = "CMD_KD_AGREEMENT_LIB;AddChiefOrder"
'            thisApplication.AddNotify "set OBJECT_KD_DIRECTION" 
'        end if   
'        if Row.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_PROTOCOL" then 
'            Row.Attributes("ATTR_AFTER_AGREE_FUNCTION") = "CMD_KD_AGREEMENT_LIB;AddExecOrderToPrep"
'            thisApplication.AddNotify "set OBJECT_KD_PROTOCOL" 
'        end if  
'      Next   
'end sub

'=================================
'sub CreateSysAttrs()
'  arr = array("OBJECT_KD_ORDER","OBJECT_KD_PROTOCOL","OBJECT_KD_DOC_IN","OBJECT_KD_DOC_OUT","OBJECT_KD_MEMO",_
'      "OBJECT_KD_DIRECTION","OBJECT_KD_ZA_PAYMENT","OBJECT_KD_DOC")
'  for i = 0 to 7   
''    call CreateSysAttr(arr(i))
'    if i>0 then CreateViewGroup(arr(i))
''    DelCMDFromObj(arr(i))
'  next  
'end sub
'''=================================
''sub DelCMDFromObj(objName)
''  on error resume next
''  set cmds = thisApplication.ObjectDefs(objName).Commands
''  'if cmds.has("CMD_KD_ADD_COMMENT") then 
''  cmds.Remove("CMD_KD_ADD_COMMENT")
''  'if cmds.has("CMD_KD_EDIT_COMMENT") then 
''  cmds.Remove("CMD_KD_EDIT_COMMENT")
''  if err.Number <>0 then 
''      thisApplication.AddNotify err.Description & err.Number 
''      err.clear
''  end if    
''  on error goto 0
''end sub
''=================================
'sub CreateViewGroup(objName)
'  on error resume next
'  grSys = "GROUP_VIEW_" & objName
'  if not thisApplication.Groups.Has(grSys) then 
'      set objDef = thisApplication.ObjectDefs(objName)
'      if objDef is nothing then exit sub
'      Set NewGroup = thisApplication.Groups.Create
'      NewGroup.SysName = grSys
'      NewGroup.Description = "Полный просмотр " & objDef.Description
'      thisApplication.AddNotify "create " & grSys
'      Set Users = NewGroup.Users 
'      set user = ThisApplication.Users("SYSADMIN")
'      if user is nothing then 
'        thisApplication.AddNotify "user not fount - SYSADMIN"
'      else
'        Users.Add user
'        thisApplication.AddNotify "add user - SYSADMIN "
'      end if
'  end if
'  if err.Number <>0 then err.clear
'  on error goto 0
'end sub
''=================================
'sub CreateDocFolder()
'on error resume next
'  attrName = "ATTR_FOLDER_OBJECT_KD_DOC"
'  if not thisApplication.Attributes.Has(attrName) then 
'    thisApplication.Attributes.Create(attrName)
'    thisApplication.AddNotify "add " & attrName
'  end if
'  set pFolder = thisApplication.GetObjectByGUID("{0F7ADC13-FC89-4EB0-8D07-031090FA8982}")
'  if pFolder is nothing then 
'    thisApplication.AddNotify "Не найдена техническая папка"
'    exit sub
'  end if
'  set newfolder = pFolder.Objects.Create("OBJECT_KD_FOLDER")
'  newfolder.Attributes("ATTR_FOLDER_NAME").value = "Без документа-основания"
'  newfolder thisobject.Roles.Create(thisApplication.RoleDefs("ROLE_USER"), thisApplication.Groups("ALL_USERS"))
'  newfolder.update

'  thisApplication.Attributes(attrName).Value = newfolder.Guid 
'if err.Number <> 0 then err.clear
'on error goto 0  
'end sub  
''=================================
'sub CreateSysAttr(ObjTypeSysName)
'  attrName = "ATTR_" & ObjTypeSysName
'  if not thisApplication.AttributeDefs.Has(attrName) then 
'    Set AttrDef = thisApplication.AttributeDefs.Create
'    AttrDef.Description = "SisID for " & attrName
'    AttrDef.SysName = attrName
'    AttrDef.Type = tdmInteger
'    thisApplication.AddNotify "create " & attrName
'  end if
'  if not thisApplication.Attributes.Has(attrName) then 
'    thisApplication.Attributes.Create(attrName)
'    thisApplication.AddNotify "add " & attrName
'  end if
'  set SysIDObj = Get_Obj_Sys_ID(ObjTypeSysName)  
'  if not SysIDObj is nothing then 
'    if thisApplication.Attributes(attrName).Value < SysIDObj.attributes("ATTR_KD_IDNUMBER").value then _
'         thisApplication.Attributes(attrName).Value = SysIDObj.attributes("ATTR_KD_IDNUMBER").value
'  else    
'     thisApplication.Attributes(attrName).Value = 0
'  end if   
'  thisApplication.AddNotify attrName & " = " &  thisApplication.Attributes(attrName).Value
'end sub
''=================================
'function Get_Obj_Sys_ID(objType)
'  set Get_Obj_Sys_ID = nothing
'  Set QueryDoc = thisApplication.Queries("QUERY_GET_OBJECT_SYSTEM_ID")
'  QueryDoc.Parameter("PARAM0") = objType
'  Set objs = QueryDoc.Objects
'  if not objs is nothing then 
'    if objs.Count >0 then _
'      set Get_Obj_Sys_ID = objs(0)
'  end if 
'end function

''=================================
'sub UpdateUrAddress
'on error resume next
'  thisScript.SysAdminModeOn
'  set qry = thisApplication.Queries("QUERY_KD_CORDENT")
'  set objs  = qry.Objects 
'  for each obj in objs
'    thisApplication.AddNotify "Update - " & obj.description
'    if obj.Attributes.has("ATTR_S_JPERSON_ADDRESS_ACTUAL") then _
'       obj.Attributes.Remove(obj.Attributes("ATTR_S_JPERSON_ADDRESS_ACTUAL"))
'    obj.Attributes.Create("ATTR_S_JPERSON_ADDRESS_ACTUAL")
'  next
'  on error goto 0
'end sub

''=================================
''call createGroup  
''call RenameQury()
''call changeD()
''call PanelQueriesUpdate()

''sub changeD()
''  set obj = thisApplication.GetObjectByGUID("{1DDEE052-4DBE-44A5-8058-7B2EC4AAB9EF}")
''  if obj is nothing then 
''    thisApplication.AddNotify "Folder not fount"
''    exit sub
''  end if
''  if obj.Queries.Has("QUERY_FAVORIT1") then 
''    obj.Queries.Remove("QUERY_FAVORIT1")
''    thisApplication.AddNotify "Remove Frovorit1"
''  end if
''  if not obj.Queries.Has("QUERY_FAVORIT") then 
''    obj.Queries.Add("QUERY_FAVORIT")
''    thisApplication.AddNotify "add QUERY_FAVORIT"
''  end if
''  if not obj.Queries.Has("QUERY_ON_CONTOL") then 
''    obj.Queries.Add("QUERY_ON_CONTOL")
''    thisApplication.AddNotify "add QUERY_ON_CONTOL"
''  end if  
''end sub

'sub RenameQury
'  set qry =  thisApplication.Queries("QUERY_ARM_8_P_COUNT")
'  if not qry is nothing then 
'    qry.SysName = "QUERY_ARM_8_P_COUNT2"
'    thisApplication.AddNotify "rename QUERY_ARM_8_P_COUNT"
'  end if
''  set qry =  thisApplication.Queries("QUERY_ARM_8_P_COUNT")
''  if not qry is nothing then 
''    qry.SysName = "QUERY_ARM_8_P_COUNT2"
''  end if
'end sub

'sub createGroup
'    if not thisApplication.Groups.Has("GROUP_TEMPL_EDIT") then 
'      Set NewGroup = thisApplication.Groups.Create
'      NewGroup.SysName = "GROUP_TEMPL_EDIT"
'      NewGroup.Description = "Администраторы шаблонов"
'      Set Users = NewGroup.Users 
'      set user = ThisApplication.Users("SYSADMIN")
'      if user is nothing then 
'        thisApplication.AddNotify "user not fount - SYSADMIN"
'      else
'        Users.Add user
'        thisApplication.AddNotify "add user - SYSADMIN "
'      end if
'    end if
'end sub

'Sub PanelQueriesUpdate()
'  thisApplication.AddNotify "Обновление выборок рабочего стола"
'  Set o = ThisApplication.GetObjectByGUID("{A830F094-FAAC-48A6-8DC7-641B4C8B4610}")
'  
'  If ThisApplication.Desktop.Objects.Has(o) = False Then
'    ThisApplication.Desktop.Objects.add o
'  End If
'    
'  For Each Obj In ThisApplication.ObjectDefs("OBJECT_ARM_FOLDER").Objects
'    ARM = ""
'    If Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ПОРУЧЕНИЯ" Then
'      ARM = "ORDERS"
'    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ДЕЛОПРОИЗВОДСТВО (Д)" Then
'      ARM = "DPD"
'    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ДЕЛОПРОИЗВОДСТВО (С)" Then
'      ARM = "DPC"
'    ElseIf Obj.Attributes("ATTR_ARM_FOLDER_NAME") = "ДЕЛОПРОИЗВОДСТВО (Р)" Then
'      ARM = "DPR"
'    End If
'    
'    List = ""
'    ListToRem = ""
'        
'    Select Case ARM
'      Case "ORDERS"
'        thisApplication.AddNotify "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
'        List = ""
'        ListToRem = "QUERY_FOR_N,QUERY_ON_NK,QUERY_FAVORIT1,QUERY_ON_CONTOL1"
'        Call AddQuery(Obj,List,ListToRem)
'      Case "DPD"
'        thisApplication.AddNotify "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
'        List = ""
'        ListToRem = "QUERY_INVOICE_DESCTOP,QUERY_DESCTOP_INVOICE_MY,QUERY_INVOICE_DOCS_ON_CHECK,QUERY_INVOICE_DOCS_APPROVED," &_
'        "QUERY_DESCTOP_INVOICE_DOCS_READY_TO_ISSUE,QUERY_FAVORIT1,QUERY_ON_CONTOL1"
'        Call AddQuery(Obj,List,ListToRem) 
'      Case "DPC"
'        thisApplication.AddNotify "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
'        List = ""
'        ListToRem = "QUERY_INVOICE_DESCTOP,QUERY_DESCTOP_INVOICE_MY,QUERY_INVOICE_DOCS_ON_CHECK,QUERY_INVOICE_DOCS_APPROVED," &_
'        "QUERY_DESCTOP_INVOICE_DOCS_READY_TO_ISSUE,QUERY_FAVORIT1,QUERY_ON_CONTOL1"
'        Call AddQuery(Obj,List,ListToRem)
'      Case "DPR"
'        thisApplication.AddNotify "Обновление выборок рабочего стола " & Obj.Attributes("ATTR_ARM_FOLDER_NAME")
'        List = ""
'        ListToRem = "QUERY_INVOICE_DESCTOP,QUERY_DESCTOP_INVOICE_MY,QUERY_INVOICE_DOCS_ON_CHECK,QUERY_INVOICE_DOCS_APPROVED," &_
'        "QUERY_DESCTOP_INVOICE_DOCS_READY_TO_ISSUE,QUERY_FAVORIT1,QUERY_ON_CONTOL1"
'        Call AddQuery(Obj,List,ListToRem) 
'    End Select
'  Next  
'End Sub

'Sub AddQuery(Obj,List,ListToRem)
'      arr = Split(List,",")
'      For Each q In arr
'        If Not Obj.Queries.Has(q) Then
'          Obj.Queries.Add q
'        End If
'      Next
'      arr = Split(ListToRem,",")
'      For Each q In arr
'        If Obj.Queries.Has(q) Then
'          Obj.Queries.Remove q
'        End If
'      Next
'End Sub


'  call  SetSysATTR()    
'  call delForms()
'  
'sub delForms()
'  set objDef = thisApplication.ObjectDefs("OBJECT_KD_PROTOCOL")
'  if objDef.InputForms.Has("FORM_KD_PROT") then  objDef.InputForms.Remove("FORM_KD_PROT")
'  if objDef.InputForms.Has("FORM_KD_PROT_DISTRIB") then  objDef.InputForms.Remove("FORM_KD_PROT_DISTRIB")
'  if objDef.InputForms.Has("FORM_PROT_SEND") then  objDef.InputForms.Remove("FORM_PROT_SEND")

'  set objDef = thisApplication.ObjectDefs("OBJECT_KD_ZA_PAYMENT")
'  if objDef.InputForms.Has("FORM_KD_PAYMENT_SEND") then  objDef.InputForms.Remove("FORM_KD_PAYMENT_SEND")
'  if objDef.AttributeDefs.Has("ATTR_KD_AUTH") then objDef.AttributeDefs.Remove("ATTR_KD_AUTH")
'   thisApplication.AddNotify "objDef.InputForms.Remove(FORM_KD_PAYMENT_SEND)"
'end sub  
'  
'sub SetSysATTR()    
'  if thisApplication.Attributes.Has("ATTR_KD_T_FORMS_SHOW") then 
'      set rows = thisApplication.Attributes("ATTR_KD_T_FORMS_SHOW").Rows
'       set newRow = rows.Create
'       NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_ZA_PAYMENT"
'       NewRow.Attributes("ATTR_KD_START_STATUS").Value = "CREATE"
'       NewRow.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_KD_AP_CREATE"
'       thisApplication.AddNotify "1 Add row OBJECT_KD_ZA_PAYMENT - CREATE"
'       
'       set newRow = rows.Create
'       NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_ZA_PAYMENT"
'       NewRow.Attributes("ATTR_KD_START_STATUS").Value = "STATUS_KD_DRAFT"
'       NewRow.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_KD_DOC_AGREE"
'       thisApplication.AddNotify "2 Add row STATUS_KD_DRAFT - FORM_KD_DOC_AGREE"

'       set newRow = rows.Create
'       NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_ZA_PAYMENT"
'       NewRow.Attributes("ATTR_KD_START_STATUS").Value = "STATUS_KD_AGREEMENT"
'       NewRow.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_KD_DOC_AGREE"
'       thisApplication.AddNotify "3 Add row STATUS_KD_AGREEMENT - FORM_KD_DOC_AGREE"

'       set newRow = rows.Create
'       NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_ZA_PAYMENT"
'       NewRow.Attributes("ATTR_KD_START_STATUS").Value = "STATUS_SIGNING"
'       NewRow.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_KD_DOC_AGREE"
'       thisApplication.AddNotify "4 Add row STATUS_SIGNING - FORM_KD_DOC_AGREE"

'       set newRow = rows.Create
'       NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_ZA_PAYMENT"
'       NewRow.Attributes("ATTR_KD_START_STATUS").Value = "STATUS_SIGNED"
'       NewRow.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_KD_DOC_ORDERS"
'       thisApplication.AddNotify "5 Add row STATUS_SIGNED - FORM_KD_DOC_ORDERS"

'       set newRow = rows.Create
'       NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_PROTOCOL"
'       NewRow.Attributes("ATTR_KD_START_STATUS").Value = "CREATE"
'       NewRow.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_PROTOCOL_CREATE"
'       thisApplication.AddNotify "6 Add row OBJECT_KD_PROTOCOL - CREATE"
'       set newRow = rows.Create
'       NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_PROTOCOL"
'       NewRow.Attributes("ATTR_KD_START_STATUS").Value = "STATUS_KD_DRAFT"
'       NewRow.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_KD_DOC_AGREE"
'       thisApplication.AddNotify "7 Add row OBJECT_KD_PROTOCOL - STATUS_KD_DRAFT"
'       set newRow = rows.Create
'       NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_PROTOCOL"
'       NewRow.Attributes("ATTR_KD_START_STATUS").Value = "STATUS_KD_AGREEMENT"
'       NewRow.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_KD_DOC_AGREE"
'       thisApplication.AddNotify "8 Add row OBJECT_KD_PROTOCOL - STATUS_KD_AGREEMENT"
'''       set newRow = rows.Create
'''       NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_PROTOCOL"
'''       NewRow.Attributes("ATTR_KD_START_STATUS").Value = "STATUS_SIGNING"
'''       NewRow.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_KD_DOC_AGREE"
'''       thisApplication.AddNotify "7 Add row OBJECT_KD_PROTOCOL - FORM_KD_DOC_AGREE"
'       set newRow = rows.Create
'       NewRow.Attributes("ATTR_KD_OBJ_TYPE").Value = "OBJECT_KD_PROTOCOL"
'       NewRow.Attributes("ATTR_KD_START_STATUS").Value = "STATUS_SIGNED"
'       NewRow.Attributes("ATTR_KD_FORMS_LIST").Value = "FORM_KD_DOC_ORDERS"
'       thisApplication.AddNotify "8 Add row OBJECT_KD_PROTOCOL - FORM_KD_DOC_ORDERS"
'       
'       rows.Update
'       if err.Number <> 0 then 
'       thisApplication.AddNotify err.Description
'       err.clear
'    end if

'  end if
'  if thisApplication.Attributes.Has("ATTR_KD_FORMS_LIST") then 
'    thisApplication.Attributes("ATTR_KD_FORMS_LIST").Value = _
'      ";FORM_KD_MEMO_CREATE;FORM_ARGEE_CREATE;FORM_KD_ORDER_CREATE;FORM_OUT_CREATE;FORM_ORD_CREATE;FORM_KD_AP_CREATE;FORM_PROTOCOL_CREATE;"
'    'thisApplication.Attributes("ATTR_KD_FORMS_LIST") & ";FORM_KD_AP_CREATE"
'    thisApplication.AddNotify "3 Add  ATTR_KD_FORMS_LIST - FORM_KD_AP_CREATE"
'    if err.Number <> 0 then 
'      thisApplication.AddNotify err.Description
'      err.clear
'    end if
'  end if
'  if not  thisApplication.Attributes.Has("ATTR_KD_DEL_FORMS") then _
'      thisApplication.Attributes.Create("ATTR_KD_DEL_FORMS")
'  thisApplication.Attributes("ATTR_KD_DEL_FORMS").Value = _
'    ";FORM_OUT_CREATE;FORM_KD_MEMO_CREATE;FORM_ORD_CREATE;FORM_KD_AP_CREATE;FORM_PROTOCOL_CREATE;"
'  thisApplication.AddNotify "4 set  ATTR_KD_DEL_FORMS  Value"

'    Set Rows = ThisApplication.Attributes("ATTR_AGREENENT_SETTINGS").Rows
'      For Each Row in Rows
'        select case Row.Attributes("ATTR_KD_OBJ_TYPE").Value 
'          case "OBJECT_KD_ZA_PAYMENT"
'              Row.Attributes("ATTR_KD_FILE_LIST_ARR") = "CMD_KD_FILE_LIB;GetAPTypeFileArray"
'              Row.Attributes("ATTR_KD_OBJ_CARD_FORM") = "FORM_AP_CARD"
'              Row.Attributes("ATTR_AFTER_AGREE_FUNCTION") = "CMD_KD_AGREEMENT_LIB;AddChiefOrder"
'              Row.Attributes("ATTR_KD_STATUSES_FOR_ORDER") = "STATUS_SIGNED"
'              thisApplication.AddNotify "set OBJECT_KD_ZA_PAYMENT" 
'          case "OBJECT_KD_DOC_OUT"
'              Row.Attributes("ATTR_KD_FILE_LIST_ARR") = "CMD_KD_FILE_LIB;GetOUTTypeFileArray"
'              Row.Attributes("ATTR_KD_OBJ_CARD_FORM") = "FORM_KD_OUT_CARD"
'              thisApplication.AddNotify "set OBJECT_KD_DOC_OUT" 
'          case "OBJECT_KD_MEMO" 
'             ' Row.Attributes("ATTR_KD_FILE_LIST_ARR") = "STATUS_KD_DRAFT;STATUS_SIGNING;STATUS_SIGNED"
'              Row.Attributes("ATTR_KD_STATUSES_FOR_ORDER") = "STATUS_KD_APPROVED"
'              Row.Attributes("ATTR_KD_OBJ_CARD_FORM") = "FORM_KD_MEMO_CARD"
'              thisApplication.AddNotify "set OBJECT_KD_MEMO" 
'          case "OBJECT_KD_DOC_IN"
'              'Row.Attributes("ATTR_KD_FILE_LIST_ARR") = "CMD_KD_FILE_LIB;GetOUTTypeFileArray"
'              Row.Attributes("ATTR_KD_OBJ_CARD_FORM") = "FORM_ID_CARD"
'              thisApplication.AddNotify "set OBJECT_KD_DOC_IN" 
'          case "OBJECT_KD_DIRECTION"
'              'Row.Attributes("ATTR_KD_FILE_LIST_ARR") = "CMD_KD_FILE_LIB;GetOUTTypeFileArray"
'              Row.Attributes("ATTR_KD_OBJ_CARD_FORM") = "FORM_ORD_CARD"
'              Row.Attributes("ATTR_KD_STATUSES_FOR_ORDER") = "STATUS_KD_IN_FORCE"
'              thisApplication.AddNotify "set OBJECT_KD_DIRECTION" 
'          case "OBJECT_KD_PROTOCOL"
'              'Row.Attributes("ATTR_KD_FILE_LIST_ARR") = "CMD_KD_FILE_LIB;GetOUTTypeFileArray"
'              Row.Attributes("ATTR_KD_OBJ_CARD_FORM") = "FORM_PROTOCOL_CARD"
'              Row.Attributes("ATTR_KD_STATUSES_FOR_ORDER") = "STATUS_SIGNED"
'              Row.Attributes("ATTR_KD_FINISH_STATUS") = "STATUS_SIGNING"
'              thisApplication.AddNotify "set OBJECT_KD_DIRECTION" 
'        End select
'      Next   
'end sub
