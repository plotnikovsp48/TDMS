
Sub CloseOrderByResol(Obj,resSysName)
'thisapplication.AddNotify "CloseOrderByResol - " & Time
  Set user = ThisApplication.CurrentUser
  
  arr = Split(resSysName,",")
  txt = vbNullString
  For i =0 To Ubound(arr)
    Set res = ThisApplication.Classifiers("NODE_CORR_REZOL").Classifiers.FindBySysId(arr(i))
    If txt = vbNullString Then
      txt = "='" & res.SysName & "'"
    Else
      txt =  txt & " or ='" & res.SysName & "'"
    End If
  Next

'  Set resol = ThisApplication.Classifiers("NODE_CORR_REZOL").Classifiers.FindBySysId(resSysName)
  Set orders = Nothing
  Set orders = GetOrderByResol(Obj,txt,User)
  
  If orders Is Nothing Then exit Sub
  For each order In orders
'    thisapplication.AddNotify "CloseOrderByResol - " & order.description & " - " & Time 
    
    Call  ThisApplication.ExecuteScript("CMD_KD_ORDER_LIB","SetOrderDone",order,"","")
'    thisapplication.AddNotify "CloseOrderByResol - (exit) " & Time
  Next
'  thisapplication.AddNotify "CloseOrderByResol - (end) " & Time
End Sub

Sub CloseAllOrderByResol(Obj,resSysName)
'thisapplication.AddNotify "CloseAllOrderByResol - " & Time
  arr = Split(resSysName,",")
  txt = vbNullString
  For i =0 To Ubound(arr)
    Set res = ThisApplication.Classifiers("NODE_CORR_REZOL").Classifiers.FindBySysId(arr(i))
    If txt = vbNullString Then
      txt = "='" & res.SysName & "'"
    Else
      txt =  txt & " or ='" & res.SysName & "'"
    End If
  Next

  Set resol = ThisApplication.Classifiers("NODE_CORR_REZOL").Classifiers.FindBySysId(resSysName)
  Set orders = GetOrderByResol(Obj,txt,Nothing)
  If orders Is Nothing Then exit Sub
  For each order In orders
    Call  ThisApplication.ExecuteScript("CMD_KD_ORDER_LIB","SetOrderDone",order,"","")
  Next
End Sub

'Sub CloseOrderByResol(Obj,resSysName)
'  Set user = ThisApplication.CurrentUser
'  Set resol = ThisApplication.Classifiers("NODE_CORR_REZOL").Classifiers.FindBySysId(resSysName)
'  Set orders = GetOrderByResol(Obj,Resol,User)
'  If orders Is Nothing Then exit Sub
'  For each order In orders
'    Call  ThisApplication.ExecuteScript("CMD_KD_ORDER_LIB","SetOrderDone",order,"","")
'  Next
'End Sub


Sub CloseOrders(Obj,resSysName)
'thisapplication.AddNotify "CloseOrders - " & Time
  Set order = GetCurUserOrder(Obj)
  if order is nothing then exit sub
  call ThisApplication.ExecuteScript("CMD_KD_ORDER_LIB","Set_order_Done",order)
End Sub

function GetCurUserOrder(Obj)
'thisapplication.AddNotify "GetCurUserOrder - " & Time
  set GetCurUserOrder = nothing
  set query = thisAppLication.Queries("QUERY_KD_ALL_USER_ODER")
  query.Parameter("PARAM0") = Obj.handle
  query.Parameter("PARAM1") = thisApplication.CurrentUser
  set objs = query.Objects
  if objs.Count = 0 then exit function
  if objs.Count = 1 then 
    set GetCurUserOrder = objs(0)
    exit function
  end if
  
  'если не выполненое получение
  for each order in objs
    if order.StatusName = "STATUS_KD_ORDER_IN_WORK" then set GetCurUserOrder = order
  next
  'если нет то 
  if GetCurUserOrder is nothing then _
      set GetCurUserOrder = objs(0)
  
end function

Sub RejectOrderByResol(Obj,resSysName)
  Set user = ThisApplication.CurrentUser
  Set resol = ThisApplication.Classifiers("NODE_CORR_REZOL").Classifiers.FindBySysId(resSysName)

  Set orders = GetOrderByResol(Obj,Resol,User)
  If orders Is Nothing Then exit Sub
  msgbox orders.count
  For each order In orders
    Call  ThisApplication.ExecuteScript("CMD_KD_ORDER_LIB","Set_OrderCancel",order)
  Next
End Sub

Sub RejectAllOrderByResol(Obj,resSysName)
'  thisapplication.AddNotify "RejectAllOrderByResol - " & Time
  Set resol = ThisApplication.Classifiers("NODE_CORR_REZOL").Classifiers.FindBySysId(resSysName)

  Set orders = GetOrderByResol(Obj,Resol,Nothing)
  If orders Is Nothing Then exit Sub
  
  For each order In orders
'    thisapplication.AddNotify "RejectAllOrderByResol - " & order.description & " - " & Time 
    Call  ThisApplication.ExecuteScript("CMD_KD_ORDER_LIB","Set_OrderCancel",order)
  Next
End Sub

' Возвращает коллекцию незакрытых поручений, связанное с объектом, пользователем, резолюцией
Function GetOrderByResol(Obj,Resol,User)
'thisapplication.AddNotify "GetOrderByResol - " & Time
  Set GetOrderByResol = Nothing
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "='OBJECT_KD_ORDER_SYS' or ='OBJECT_KD_ORDER_NOTICE'"
  q.AddCondition tdmQueryConditionStatus, "<>'STATUS_KD_ORDER_DONE' and <> 'STATUS_KD_OREDR_CANCEL'"
  If Not User Is Nothing Then
    q.AddCondition tdmQueryConditionAttribute, user, "ATTR_KD_OP_DELIVERY"
  End If
  q.AddCondition tdmQueryConditionAttribute, Obj, "ATTR_KD_DOCBASE"
  q.AddCondition tdmQueryConditionAttribute, resol, "ATTR_KD_RESOL"
  If q.Objects.count = 0 Then Exit Function

  Set GetOrderByResol = q.Objects
End Function

'==============================================================================
' Отправка поручение на доработку документа
' разработчику документа 
'------------------------------------------------------------------------------
' o_:TDMSObject - документ
'==============================================================================
Sub SendOrder_NODE_KD_RETUN_USER(Obj)
  If Obj Is Nothing Then Exit Sub
  Select Case Obj.ObjectDefName
    Case "OBJECT_T_TASK"
      aName = "ATTR_T_TASK_DEVELOPED"
    Case "OBJECT_DRAWING", "OBJECT_DOC_DEV"
      aName = "ATTR_RESPONSIBLE"
    Case Else
      aName = "ATTR_AUTOR"
  End Select
  
  '\\\\\\\\\\
  If Obj.Attributes.Has(aName) Then
    If Not Obj.Attributes(aName).Empty Then
      Set uToUser = Obj.Attributes(aName).User
      If uToUser Is Nothing Then Exit Sub
    End If
  End If
  '\\\\\\\\\\\\\\\\\\\\\\\\\\
  
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_KD_RETUN_USER"
  txt = """" & Obj.Description & """ возвращен на доработку. Причина: " & Obj.VersionDescription
  planDate = DateAdd ("d", 1, Date) 'Date + 1
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
End Sub

Sub SendOrder_Doc_AGREED(Obj)
  
  If Obj.Attributes.Has("ATTR_AUTOR") Then
    If Not Obj.Attributes("ATTR_AUTOR").Empty Then
      Set uToUser = Obj.Attributes("ATTR_AUTOR").User
      If uToUser Is Nothing Then Exit Sub
    End If
  ElseIf Obj.Attributes.Has("ATTR_T_TASK_DEVELOPED") Then
    If Not Obj.Attributes("ATTR_T_TASK_DEVELOPED").Empty Then
      Set uToUser = Obj.Attributes("ATTR_T_TASK_DEVELOPED").User
      If uToUser Is Nothing Then Exit Sub
    End If
  ElseIf Obj.Attributes.Has("ATTR_RESPONSIBLE") Then
    If Not Obj.Attributes("ATTR_RESPONSIBLE").Empty Then
      Set uToUser = Obj.Attributes("ATTR_RESPONSIBLE").User
      If uToUser Is Nothing Then Exit Sub
    End If
  End If
  
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_CORR_REZOL_INF"
  txt = Obj.ObjectDefName & " """ & Obj.Description & """ - согласование успешно завершено."
  planDate = ""
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,planDate
End Sub

Sub SendOrder_NODE_COR_STAT_MAIN(Obj,userTo,userFrom)
  ThisApplication.DebugPrint "SendOrder_NODE_COR_STAT_MAIN"
  If Obj Is Nothing Then Exit Sub
  If userTo Is Nothing Then Exit Sub
  If userFrom Is Nothing Then Exit Sub
  'Создание поручения о назначении ответственным
  resol = "NODE_COR_STAT_MAIN"
  txt = "Вы назначены ответственным за разработку "
  PlanDate = ""
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",userTo,userFrom,resol,txt,PlanDate
End Sub

Sub SendOrderToResponsible(Obj)
  ThisApplication.DebugPrint "SendOrderToResponsible" & Time
  NeedNotifyResp = True
  Set Stage = ThisApplication.ExecuteScript("CMD_S_DLL","GetStage",Obj)
  ' Если стадия планируется или на редактировании, то не рассылаем поручения
  ' Str 20/01/2018
  If Not Stage Is Nothing Then
    sName = Stage.StatusName
    If sName = "STATUS_STAGE_DRAFT" or sName = "STATUS_STAGE_EDIT" Then 
      NeedNotifyResp = False
    End If
  End If
  
  
  If Obj Is Nothing Then Exit Sub
  Obj.Permissions = SysAdminPermissions
  ' Если поменялся ответственный
    Set Dict = ThisApplication.Dictionary(Obj.Handle)
    If Dict Is Nothing Then Exit Sub
    ThisApplication.Utility.WaitCursor = True
    If Dict.Exists("newResp") Then
    ThisApplication.DebugPrint "newResp"
      Set NewUser = ThisApplication.Users(Dict("newResp"))
      Call changeRoles(Obj)
      If NeedNotifyResp Then Call SendOrderToResp(Obj,"newResp",NewUser)
      Dict.Remove("newResp")
    End If
    If Dict.Exists("oldResp") Then
    ThisApplication.DebugPrint "oldResp"
      Set OldUser = ThisApplication.Users(Dict("oldResp"))
      If OldUser.handle <> NewUser.handle Then
        If NeedNotifyResp Then Call SendOrderToResp(Obj,"oldResp",OldUser)
      End If
      Dict.Remove("oldResp")
    End If
    Dict.RemoveAll
    ThisApplication.Utility.WaitCursor = False
End Sub

'==============================================================================
' Отправка оповещения о завершении разработки задания 
' ответственному за подготовку задания 
'------------------------------------------------------------------------------
' o_:TDMSObject - разработанное задание
'==============================================================================
Sub SendOrderToResp(Obj,mark,User)
ThisApplication.DebugPrint "SendOrderToResp"
  If User Is Nothing Then Exit Sub
  Set uToUser = User
  Set uFromUser = ThisApplication.CurrentUser
 
  Select Case mark
    Case "oldResp"
      resol = "NODE_COR_DEL_MAIN"
      txt = "Вы больше не являетесь разработчиком """ & Obj.Description & """"
    Case "newResp"
      resol = "NODE_COR_STAT_MAIN"
      txt = "Вы назначены ответственным за разработку """ & Obj.Description & """"
  End Select
  'Создание поручения
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,""
End Sub


Sub changeRoles(Obj)
  Select Case Obj.ObjectDefName
    Case "OBJECT_T_TASK"
      Call ThisApplication.ExecuteScript ("CMD_DOC_DEVELOPER_APPOINT", "SetRoles",Obj)
    Case "OBJECT_PROJECT_SECTION","OBJECT_WORK_DOCS_SET","OBJECT_PROJECT_SECTION_SUBSECTION","OBJECT_VOLUME"
      Set userTo = Obj.Attributes("ATTR_RESPONSIBLE").User
      Call ThisApplication.ExecuteScript ("CMD_DEVELOPER_APPOINT", "ChangeRoles",Obj,userTo)
      Call ThisApplication.ExecuteScript ("CMD_DEVELOPER_APPOINT", "SetRolesForContent",Obj,userTo)
  End Select
End Sub

Sub Close_Return_order(Obj)
  ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_KD_RETUN_USER")
End Sub
