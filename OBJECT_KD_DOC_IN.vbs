use OBJECT_KD_BASE_DOC
use CMD_KD_CURUSER_LIB
'=============================================
'статус для копирования поручений секретарю
function Check_RegStatus(stName)
  Check_RegStatus = false
end function
'=============================================
' конечный статус
function Check_FinishStatus(stName)
  Check_FinishStatus = (stName = "STATUS_KD_CANCEL")
end function
'=============================================
function GetCardName()
  GetCardName = "FORM_ID_CARD"
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
'  str = "STATUS_KD_REGISTERED;STATUS_KD_VIEWED_RUK;"
'  if Instr(";" & str & ";", ";" & docStat & ";") > 0 then _
      CanIssueOrder = true
end function
'=============================================
function GetTypeFileArr(docObj)
  isSec = isSecretary(GetCurUser()) 
  if not isSec then exit function
  
  st = docObj.StatusName
  select case st
    case "STATUS_KD_DRAFT"
      GetTypeFileArr = array("Скан документа","Приложение")  
    case "STATUS_KD_REGISTERED"
      GetTypeFileArr = array("Скан документа","Приложение","Резолюция")  
    case "STATUS_KD_VIEWED_RUK"  
      GetTypeFileArr = array("Скан документа","Приложение","Резолюция")  
  end select
end function
'=============================================
