use OBJECT_KD_BASE_DOC
use CMD_KD_CURUSER_LIB

'=============================================
' конечный статус
function Check_FinishStatus(stName)
  Check_FinishStatus = (stName = "STATUS_KD_CANCEL") or (stName = "STATUS_KD_IN_FORCE") or (stName = "STATUS_KD_INACTIVE")
end function
'=============================================
' конечный статус
function Can_SendToSing(obj)
  Can_SendToSing = (obj.Permissions.Edit = 1)
end function

'=============================================
Extern GetExecutor [Alias ("Исполнитель"), HelpString ("Инофрмация об исполнителе")]'PlotnikovSP modify
function GetExecutor(Object)
  GetExecutor = ""
  'if Object.ObjectDefName <>"OBJECT_KD_DOC_OUT" then exit function
  set excutor = object.Attributes("ATTR_KD_EXEC").user
  if excutor is nothing then exit function
  GetExecutor = GetUserFIO(excutor) & chr(13) & "Тел. " & GetUserPhone(excutor)
end function

'=============================================
function GetUserFIO(user)
  thisScript.SysAdminModeOn
  GetUserFIO = trim(user.Attributes("ATTR_KD_FIO").value)
  if len(GetUserFIO) > 3 then exit function
  GetUserFIO = user.Description
  UserArr = Split(GetUserFIO," ")
  select case Ubound (UserArr) 
    case 1      GetUserFIO = Left(UserArr(1),1) & ". " & UserArr(0) 
    case 2      GetUserFIO = Left(UserArr(1),1) & ". " & Left(UserArr(2),1) & ". " & UserArr(0) 
  end select   
'  GetUserFIO = Left(user.FirstName,1) & "." & Left(user.MiddleName,1) & ". " & user.LastName
  user.Attributes("ATTR_KD_FIO").value = GetUserFIO
end function
'=============================================
function GetUserPhone(user)
  GetUserPhone = trim(user.Phone)
  if  GetUserPhone > "" then exit function
  GetUserPhone = " Не задан"
end function

'=============================================
Extern GetSignFio [Alias ("ФИО подписанта"), HelpString ("ФИО подписанта")]'PlotnikovSP modify
function GetSignFio(Object)
  GetSignFio =""
  'if Object.ObjectDefName <>"OBJECT_KD_DOC_OUT" then exit function
  set signer = object.Attributes("ATTR_KD_SIGNER").user
  if signer is nothing then exit function
  GetSignFio = GetUserFIO(signer)
end function  
'=============================================
function GetCardName()
  GetCardName = "FORM_ORD_CARD"
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
'  str = ";STATUS_KD_IN_FORCE;"
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
          GetTypeFileArr = array("Документ","Приложение")  
    case "STATUS_KD_AGREEMENT"
      if IsCanAprove(cUser, docObj) or HasReview(cUser,docObj) then _
          GetTypeFileArr = array("Документ","Приложение")  
    case "STATUS_SIGNING","STATUS_SIGNED","STATUS_KD_IN_FORCE"
      if isSin then _
          GetTypeFileArr = array("Скан документа")  
  end select
end function
'=============================================
function Check_RegStatus(stName)
  Check_RegStatus = (stName = "STATUS_KD_REGIST")
end function
