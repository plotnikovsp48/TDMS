use OBJECT_KD_BASE_DOC

'=============================================
' конечный статус
function Check_FinishStatus(stName)
  Check_FinishStatus = (stName = "STATUS_KD_CANCEL") or (stName = "STATUS_KD_APPROVED")
end function
' функции для шаблона
'=============================================
Extern GetExecutor [Alias ("Исполнитель"), HelpString ("Инофрмация об исполнителе")]
function GetExecutor(Object)
  GetExecutor = ""
  if Object.ObjectDefName <>"OBJECT_KD_MEMO" then exit function
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
    case 2      GetUserFIO = Left(UserArr(1),1) & "." & Left(UserArr(2),1) & ". " & UserArr(0) 
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
Extern GetSignFio [Alias ("ФИО подписанта"), HelpString ("ФИО подписанта")]
function GetSignFio(Object)
  GetSignFio =""
  if Object.ObjectDefName <>"OBJECT_KD_MEMO" then exit function
  set signer = object.Attributes("ATTR_KD_CHIEF").user
  if signer is nothing then exit function
  GetSignFio = GetUserFIO(signer)
end function  
'=============================================
Extern GetToWhom [Alias ("ФИО Кому"), HelpString ("ФИО Кому")]
function GetToWhom(Object)
  GetToWhom =""
  if Object.ObjectDefName <>"OBJECT_KD_MEMO" then exit function
  set signer = object.Attributes("ATTR_KD_ADRS").user
  if signer is nothing then exit function
  GetToWhom = GetUserFIO(signer)
end function  
'=============================================
function GetCardName()
  GetCardName = "FORM_KD_MEMO_CARD"
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
'  str = ";STATUS_KD_APPROVED;"
'  if Instr(";" & str & ";", ";" & docStat & ";") > 0 then _
      CanIssueOrder = true
end function
'=============================================
function GetTypeFileArr(docObj)
  isSin = isSecretary(ThisApplication.CurrentUser) or IsApprover(ThisApplication.CurrentUser, docObj)
  set cUser = GetCurUser()

  st = docObj.StatusName
  select case st
    case "STATUS_KD_DRAFT"
      if IsExecutor(cUser, docObj) or IsController(cUser, docObj) then _
          GetTypeFileArr = array("Документ","Приложение","Скан документа")  
    case "STATUS_SIGNING"
      if IsController(cUser, docObj) then _
          GetTypeFileArr = array("Документ","Приложение","Скан документа")  
    case "STATUS_SIGNED"
      if IsExecutor(cUser, docObj) or IsController(cUser, docObj) then _
          GetTypeFileArr = array("Скан документа")  
    case "STATUS_KD_AGREEMENT"
      if IsCanAprove(cUser, docObj) or HasReview(cUser,docObj) then _
          GetTypeFileArr = array("Приложение")  
    case "STATUS_KD_APPROVAL","STATUS_KD_APPROVED"
      if isSin then _
          GetTypeFileArr = array("Резолюция")  
  end select
end function
'=============================================
function Check_RegStatus(stName)
  Check_RegStatus = false'(stName = "STATUS_KD_APPROVED")
end function

