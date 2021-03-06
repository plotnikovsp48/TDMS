' Автор: Стромков С.А.
'
' Договор 
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016 г.

USE "CMD_S_DLL"
USE "CMD_DLL_ROLES"
USE "CMD_DLL_CONTRACTS"

Sub Object_BeforeCreate(Obj, Parent, Cancel)
  If Not IsGroupMemberMessage(ThisApplication.CurrentUser,"GROUP_CONTRACTS") Then 
    Cancel = True
    Exit Sub
  End If
    
  sysID = ThisApplication.ExecuteScript ("CMD_KD_REGNO_KIB","Get_Sys_Id",Obj)
  if sysID = 0 then 
      Cancel = true
      exit sub
  else  
    Obj.Attributes("ATTR_KD_IDNUMBER").value = sysID
  end if
  
  'Заполнение атрибутов
  'Подписант
  Set Signer = ThisApplication.ExecuteScript("CMD_DLL", "SignerGet")
  If not Signer is Nothing Then
    Obj.Attributes("ATTR_SIGNER").User = Signer
  End If
  
 
  Set Dict = ThisApplication.Dictionary(Obj.ObjectDefName)
  If Dict.Exists("Contract") Then
    ObjGuid = Dict.Item("Contract")
    Dict.Remove("Contract")
    Set MainObj = ThisApplication.GetObjectByGUID(ObjGuid)
    If not MainObj is Nothing Then
      Obj.Attributes("ATTR_CONTRACT").Object = MainObj
    End If

    Set oCust = MainObj.Attributes("ATTR_CUSTOMER").Object
    Set oContr = MainObj.Attributes("ATTR_CONTRACTOR").Object
    Set oMyComp = ThisApplication.Attributes("ATTR_MY_COMPANY").Object
    
    
    If IsTheSameObj(oCust,oMyComp) Then
      Obj.Attributes("ATTR_CONTRACTOR").Object = oContr
    Else
      Obj.Attributes("ATTR_CONTRACTOR").Object = oCust
    End If
    
    Call SetRoles(Obj)
  End If
End Sub

Sub Object_Modified(Obj)
'  Call SetRoles(Obj)
End Sub

Sub Object_StatusChanged(Obj, Status)
  If Status is Nothing Then Exit Sub
  ThisScript.SysAdminModeOn
  
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
  
    ' Постобработка согласования
  If Obj.Dictionary.Exists("PrevStatusName") Then
    sName = Obj.Dictionary.Item("PrevStatusName")
    If sName = "STATUS_KD_AGREEMENT" Then
      Call ThisApplication.ExecuteScript("CMD_PROJECT_DOCS_LIBRARY","AgreementPostProcess",Obj) 
    End If
  End If
End Sub

Sub Object_StatusBeforeChange(Obj, Status, Cancel)
ThisApplication.DebugPrint "Object_StatusBeforeChange"
  ThisScript.SysAdminModeOn
  'Записываем текущий статус в словарь
  Obj.Dictionary.Item("PrevStatusName") = Obj.StatusName
End Sub


' Установка ролей
Private Sub SetRoles(Obj)
  'Устанавливаем роль Гип в соответствии с формой
  Obj.Permissions = SysAdminPermissions 
  Set cu = ThisApplication.CurrentUser
  Set gAllUs = ThisApplication.Groups("ALL_USERS")
  
  Call ThisApplication.ExecuteScript("CMD_DLL", "DelDefRole",Obj,"ROLE_VIEW")
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetRole",Obj,"ROLE_VIEW",gAllUs)
  
  Call ThisApplication.ExecuteScript("CMD_DLL", "DelDefRole",Obj,"ROLE_RESPONSIBLE")
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetRole",Obj,"ROLE_RESPONSIBLE",cu)
  
  Call ThisApplication.ExecuteScript("CMD_DLL", "DelDefRole",Obj,"ROLE_STRUCT_DEVELOPER")
  Call ThisApplication.ExecuteScript("CMD_DLL", "SetRole",Obj,"ROLE_STRUCT_DEVELOPER",cu)
  
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_AUTOR","ROLE_INITIATOR")
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_AUTOR","ROLE_AGREEMENT_AUTHOR")
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_SIGNER","ROLE_SIGNER")
End Sub

Sub Object_BeforeModify(Obj, Cancel)
  Call SetDescription(Obj)
    ' Автор
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_SIGNER","ROLE_SIGNER")
End Sub


Sub Object_PropertiesDlgInit(Dialog, Obj, Forms)
  Call ShowDefaultForm(Dialog, Obj, Forms)
  ' Закрываем информационные поручения 
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_CORR_REZOL_INF")
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_STAT_MAIN")
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_DEL_MAIN")
  
  ' отмечаем все поручения по документу прочитанными
  if obj.StatusName <> "STATUS_AGREEMENT_DRAFT" then _
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","Set_OrdersReaded",Obj
End Sub

function Check_FinishStatus(stName)
  Check_FinishStatus = (stName = "STATUS_AGREEMENT_EDIT") or _
                        (stName = "STATUS_AGREEMENT_INVALIDATED") or _
                        (stName = "STATUS_AGREEMENT_FORCED")
end function

'=============================================
function GetTypeFileArr(docObj)
  Set CU = ThisApplication.CurrentUser
  isAuth = IsAuthor(docObj,CU)
  isSign = IsSigner(docObj,CU)
  isChck = IsChecker(docObj,CU)
  isInit  = IsInitiator(docObj,CU)
  isCanAppr = ThisApplication.ExecuteScript("CMD_KD_USER_PERMISSIONS","IsCanAprove",CU,docObj)

  st = docObj.StatusName
  select case st
    case "STATUS_AGREEMENT_DRAFT","STATUS_AGREEMENT_EDIT"
      if isAuth  then _
          GetTypeFileArr = array("Документ","Приложение","Скан документа")  
    case "STATUS_AGREEMENT_FOR_SIGNING"
      if isSign then _
          GetTypeFileArr = array("Скан документа")  
    case "STATUS_AGREEMENT_AGREED"
      if isAuth then _
          GetTypeFileArr = array("Скан документа")  
    case "STATUS_AGREEMENT_FORCED"
      if isSign or isAuth then _
          GetTypeFileArr = array("Скан документа")  
    case "STATUS_KD_AGREEMENT"
      if isCanAppr then _
          GetTypeFileArr = array("Скан документа")  
    case "STATUS_AGREEMENT_INVALIDATED"
      if isAuth then _
          GetTypeFileArr = array("Скан документа")
    case "STATUS_AGREEMENT_SIGNED"
      if isSign or isAuth then _
          GetTypeFileArr = array("Скан документа")
  end select
end function

Sub Object_Created(Obj, Parent)
'  ' Автор
'  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_SIGNER","ROLE_SIGNER")
End Sub

function CanIssueOrder(DocObj)
'  CanIssueOrder = false
'  docStat = DocObj.StatusName
'  str = ";STATUS_AGREEMENT_DRAFT;STATUS_AGREEMENT_SIGNED;STATUS_AGREEMENT_FORCED;STATUS_AGREEMENT_EDIT;"
'  if Instr(";" & str & ";", ";" & docStat & ";") > 0 then _
      CanIssueOrder = true
end function

Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
  if obj.permissions.view = 0 then Exit Sub
  guid = Obj.GUID
  Set dict = ThisApplication.Dictionary(guid)
    If OkBtnPressed Then
      Cancel = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckBeforeClose",Obj)
'      Cancel = Not CheckBeforeClose(Obj)
      If Cancel Then Exit Sub
    
      If Obj.StatusName = "STATUS_CONTRACT_AGREED" or Obj.StatusName = "STATUS_CONTRACT_FOR_SIGNING" Then
        Call Set_ATTR_DATA(Obj)
      End If
      Call Set_StartEndATTR_DATA(Obj)
    Else  
        Call Set_ATTR_DATA(Obj)
        Call Set_StartEndATTR_DATA(Obj)
        If dict.Exists("ATTR_DATA") or dict.Exists("ATTR_STARTDATE_PLAN") or dict.Exists("ATTR_ENDDATE_PLAN") Then
          ans = msgbox("Сохранить изменения?",vbQuestion+vbYesNo,"Сохранить изменения")
          If ans = vbYes Then
            Obj.SaveChanges
          End If
        End If
    End If

  If dict.Exists("ATTR_DATA") Then dict.Remove("ATTR_DATA") 
  If dict.Exists("ATTR_STARTDATE_PLAN") Then dict.Remove("ATTR_STARTDATE_PLAN") 
  If dict.Exists("ATTR_ENDDATE_PLAN") Then dict.Remove("ATTR_ENDDATE_PLAN") 
  
  
End Sub


'' Проверка перед отправкой на согласование
'Function CheckBeforeClose(Obj)
'  CheckBeforeClose = False
'  str = CheckRequedFieldsBeforeClose(Obj)
'  If str <> "" Then
'    Msgbox "Не заполнены обязательные атрибуты: " & str,vbExclamation,"Соглашение"
'    Exit Function
'  End If
'  CheckBeforeClose = True
'End Function

'' Функция проверки заполнения обязательных полей
'Function CheckRequedFieldsBeforeClose(Obj)
'  CheckRequedFieldsBeforeClose = ""
'  str = ""
'  'Вид соглашения
'  If Obj.Attributes("ATTR_AGREEMENT_TYPE").Empty = True Then
'    CheckRequedFieldsBeforeClose = "Вид соглашения"
'    str = str & chr(10) & "- " & CheckRequedFieldsBeforeClose
'  End If
'  'Автор
'  If Obj.Attributes("ATTR_AUTOR").Empty = True Then
'    CheckRequedFieldsBeforeClose = "Автор"
'    str = str & chr(10) & "- " & CheckRequedFieldsBeforeClose
'  End If
'  'Подписант
'  If Obj.Attributes("ATTR_SIGNER").Empty = True Then
'    CheckRequedFieldsBeforeClose = "Подписант"
'    str = str & chr(10) & "- " & CheckRequedFieldsBeforeClose
'  End If
'  'Контрагент
'  If Obj.Attributes("ATTR_CONTRACTOR").Empty = True Then
'    CheckRequedFieldsBeforeClose = "Контрагент"
'    str = str & chr(10) & "- " & CheckRequedFieldsBeforeClose
'  End If
'  CheckRequedFieldsBeforeClose = str
'End Function
