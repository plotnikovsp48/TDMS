use OBJECT_KD_BASE_DOC
use CMD_KD_CURUSER_LIB

'=============================================
' конечный статус
function Check_FinishStatus(stName)
  Check_FinishStatus = (stName = "STATUS_KD_CANCEL") or (stName = "STATUS_SIGNED") or (stName = "STATUS_KD_PAID")
end function
'=============================================
function Check_RegStatus(stName)
  Check_RegStatus = false
end function
'=============================================
sub AfterSinging(DocObj)
    AddExecuterOrder(DocObj)
    if isSecretary(GetCurUser()) then
      msgBox "Приложите резолюцию", vbInformation
     call LoadFileToDocByObj("FILE_KD_RESOLUTION",DocObj)
    end if
end sub
'=============================================
sub  AddExecuterOrder(DocObj)
  set exec = DocObj.Attributes("ATTR_AP_EXEC").User
  if exec is nothing then exit sub
  set cType = thisApplication.ObjectDefs(thisApplication.ObjectDefs("OBJECT_KD_ORDER_REP").Description)
  call CreateTypeOrderToUser(nothing, DocObj, cType, exec)
end sub
'=============================================
sub AfterOrderDone(DocObj,order)
  if docObj.StatusName = "STATUS_SIGNED" then 
    if order.Attributes("ATTR_KD_RESOL").Classifier.SysName = "NODE_TO_PAID" then 
      docObj.Permissions = SysAdminPermissions
      thisScript.SysAdminModeOn
      if docObj.Status.sysName <> thisApplication.Statuses("STATUS_KD_PAID").SysName then 
          docObj.Status = thisApplication.Statuses("STATUS_KD_PAID")
          docObj.Update
      end if
    end if  
  end if
end sub

'=============================================
function GetCardName()
  GetCardName = "FORM_AP_CARD"
end function
'=============================================
function CanIssueOrder(DocObj)
'  CanIssueOrder = false
'  if docObj.attributes.has("ATTR_KD_KI") then 
'    if docObj.attributes("ATTR_KD_KI").value = true then  
'      CanIssueOrder = true
'      exit function
'    end if
'  end if
'  docStat = DocObj.StatusName
'  str = ";STATUS_SIGNED;"
'  if Instr(";" & str & ";", ";" & docStat & ";") > 0 then _
      CanIssueOrder = true
end function
'=============================================
function GetTypeFileArr(docObj)
  set cUser = GetCurUser()
  isSin = isSecretary(cUser) or IsSigner(cUser, docObj)

  st = docObj.StatusName
  select case st
    case "STATUS_KD_DRAFT"
      if IsExecutor(cUser, docObj)  then _
          GetTypeFileArr = array("Приложение","Скан документа")  
    case "STATUS_KD_AGREEMENT"
      if IsCanAprove(cUser, docObj)  or HasReview(cUser,docObj) then _
          GetTypeFileArr = array("Приложение")  
    case "STATUS_SIGNING","STATUS_SIGNED"
      if isSin then _
          GetTypeFileArr = array("Приложение")  
  end select
end function
