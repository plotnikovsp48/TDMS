' Автор: Стромков С.А.
'
' Этап 
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016 г.

USE "CMD_DLL_CONTRACTS"

Sub Object_BeforeCreate(Obj, Parent, Cancel)
'  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Parent,Parent.Status,Obj,Obj.ObjectDef.InitialStatus)  
  
  Call SetAttrs(Obj, Parent)
  
'  'Заполнение атрибутов
'  Set Dict = ThisApplication.Dictionary(Obj.ObjectDefName)
'  If Dict.Exists("Contract") Then
'    ObjGuid = Dict.Item("Contract")
'    Dict.Remove("Contract")
'    Set MainObj = ThisApplication.GetObjectByGUID(ObjGuid)
'    If not MainObj is Nothing Then
'      Obj.Attributes("ATTR_CONTRACT").Object = MainObj
'    End If
'  End If
  Call SetRoles(Obj)
End Sub

Sub Object_BeforeErase(o_, cn_)
  Dim result1,result2
  result1 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckContent", o_)
  result2 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckReferencedBy", o_) 
  cn_=result1 Or result2
  If cn_ Then Exit Sub
  Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", o_) 
End Sub

Sub Object_StatusChanged(o_, Status)
  ThisScript.SysAdminModeOn
  Select Case o_.StatusName
    Case "STATUS_CONTRACT_STAGE_IN_WORK"            ' Устанавливаем дату начала работ по факту при переходе В работу
      aDefName = "ATTR_STARTDATE_FACT"
      If Not o_.Attributes.Has(aDefName) Then o_.Attributes.Create ThisApplication.AttributeDefs(aDefName)
      o_.Attributes(aDefName) = Date   
    Case "STATUS_CONTRACT_STAGE_COMPLETION"         ' Устанавливаем дату окончания работ по факту при переходе на Завершен
      aDefName = "ATTR_ENDDATE_FACT"
      If Not o_.Attributes.Has(aDefName) Then o_.Attributes.Create ThisApplication.AttributeDefs(aDefName)
      o_.Attributes(aDefName) = Date  
    Case "STATUS_CONTRACT_STAGE_INVALIDATED"         ' Устанавливаем дату окончания работ по факту при переходе на Аннулирован
      aDefName = "ATTR_ENDDATE_FACT"
      If Not o_.Attributes.Has(aDefName) Then o_.Attributes.Create ThisApplication.AttributeDefs(aDefName)
      o_.Attributes(aDefName) = Date  
  End Select
    ThisScript.SysAdminModeOff
End Sub

Sub Object_Modified(Obj)
  
  Set resp = Obj.Attributes("ATTR_RESPONSIBLE").User
  Set roles = Obj.RolesForUser(resp)
  
  If roles.Has("ROLE_COORDINATOR_2") = False Then
    Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_RESPONSIBLE","ROLE_COORDINATOR_2")
  End If
End Sub

Sub Object_PropertiesDlgInit(Dialog, Obj, Forms)
  ' отмечаем все поручения по этапу договора прочитанными
  'if obj.StatusName <> "STATUS_DOCUMENT_CREATED" And obj.StatusName <> "STATUS_DOC_IS_ADDED" then _
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","Set_OrdersReaded",Obj
  
  Set User = ThisApplication.CurrentUser
  isCur = ThisApplication.ExecuteScript("CMD_DLL_CONTRACTS","IsCurator",Obj,User)
  isControler = User.Groups.Has("GROUP_PLANNING_ECONOMISTS") = True
  'Скрываем форму "Информация о договоре"
  
  If (User.Groups.Has("GROUP_CONTRACTS") = False) and (User.SysName <> "SYSADMIN") And (Not isCur) And (Not isControler) Then
    If Dialog.InputForms.Has("FORM_STAGE_INFO") Then
      Dialog.InputForms.Remove Dialog.InputForms("FORM_STAGE_INFO")
    End If
  End If
End Sub

'==============================================================================
' Установка атрибутов объекта
'------------------------------------------------------------------------------
' ПРИНИМАЕТ:
'   Obj:TDMSObject - Объект, которому устанавливаем атрибуты. (Этап)
'   Parent:TDMSObject - Объект, в составе которого создается этап (Договор или Этап)
'==============================================================================
Sub SetAttrs(Obj, Parent)
  Obj.Permissions = SysAdminPermissions
  If Not Parent Is Nothing Then
    'Устанавливаем куратора, начальную и конечную дату с родителя
    aList = "ATTR_CONTRACT,ATTR_RESPONSIBLE,ATTR_CURATOR,ATTR_STARTDATE_PLAN,ATTR_ENDDATE_PLAN"  
    Call ThisApplication.ExecuteScript("CMD_DLL", "AttrsSyncBetweenObjs", Parent,Obj,aList)
  End If
  
  If Parent.ObjectDefName = "OBJECT_CONTRACT_STAGE" Then
    Obj.Attributes("ATTR_CONTRACT_STAGE").Object = Parent
  ElseIf Parent.ObjectDefName = "OBJECT_CONTRACT" Then
    Obj.Attributes("ATTR_CONTRACT").Object = Parent
  End If
End Sub

Private Sub SyncCuratorFromContract(Obj)
  'Устанавливаем куратора, начальную и конечную дату с договора
  Set p = Obj.Attributes("ATTR_CONTRACT").Object
  aList = "ATTR_CURATOR"
  Call ThisApplication.ExecuteScript("CMD_DLL", "AttrsSyncBetweenObjs", p,Obj,aList)
End Sub

' Установка ролей
Private Sub SetRoles(o_)
  'Устанавливаем роль Гип в соответствии с формой
  o_.Permissions = SysAdminPermissions 
  Set u = ThisApplication.CurrentUser
  Set gAllUs = ThisApplication.Groups("ALL_USERS")
  
  Call ThisApplication.ExecuteScript("CMD_DLL", "DelDefRole",o_,"ROLE_VIEW")
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetRole",o_,"ROLE_VIEW",gAllUs)
  
  Call ThisApplication.ExecuteScript("CMD_DLL", "DelDefRole",o_,"ROLE_RESPONSIBLE")
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetRole",o_,"ROLE_RESPONSIBLE",u)
  
  Call ThisApplication.ExecuteScript("CMD_DLL", "DelDefRole",o_,"ROLE_STRUCT_DEVELOPER")
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetRole",o_,"ROLE_STRUCT_DEVELOPER",u)
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",o_,"ATTR_CURATOR","ROLE_CONTRACT_RESPONSIBLE")
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",o_,"ATTR_RESPONSIBLE","ROLE_COORDINATOR_2")
'  Call ThisApplication.ExecuteScript("CMD_DLL", "SetRole",o_,"ROLE_DEVELOPER",ThisApplication.Groups("GROUP_CONTRACTS"))
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetRole",o_,"ROLE_FULLACCESS",ThisApplication.Groups("GROUP_PLANNING_ECONOMISTS"))
End Sub
