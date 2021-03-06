use OBJECT_KD_BASE_DOC
use CMD_KD_CURUSER_LIB

'=============================================
' конечный статус
function Check_FinishStatus(stName)
  Check_FinishStatus = (stName = "STATUS_KD_CANCEL") or (stName = "STATUS_SIGNED")
end function

Extern GetCompaniesWithPeople [Alias ("Контрагенты"), HelpString ("Информация о контрагентах")]'PlotnikovSP created
function GetCompaniesWithPeople(Object)
  dim query, sh, hq, i,j,k, d,c

  set query = thisApplication.Queries("QUERY_EXIST_CUR")
  query.Parameter("PARAM0") = Object
  set sh = query.Sheet
  hq = sh.RowsCount
  
  Set d = thisapplication.CreateDictionary
  
  for i=0 to hq-1
  
    if d.exists(sh.CellValue(i, 0))=false then
      set d(sh.CellValue(i, 0)) = thisapplication.CreateCollection(tdmCollection)
    end if
    
    set c = thisapplication.CreateCollection(tdmCollection)
    c.add sh.CellValue(i, 1)
    c.add sh.CellValue(i, 2)
    d(sh.CellValue(i, 0)).add c
  next
  
  dim ret
  ret = ""
  for each i in d
  
    ret = ret & i & vbCrLf
    
    for each j in d(i)
      for each k in j
        ret = ret & " - " & k
      next
      ret = ret & vbCrLf
    next
    
    ret = ret & vbCrLf
  next
  
  GetCompaniesWithPeople=ret
end function

'=============================================
Extern GetExecutor [Alias ("Председатель"), HelpString ("Информация об председателе")]
function GetExecutor(Object)
  GetExecutor = ""
'  if not Object.Attributes.has("ATTR_KD_EXEC") then exit function
'  set excutor = object.Attributes("ATTR_KD_EXEC").user
'  if excutor is nothing then exit function
'  GetExecutor = GetUserFIO(excutor) ' & chr(13) & "Тел. " & GetUserPhone(excutor)
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
Extern GetSecr [Alias ("Секретарь"), HelpString ("Информация об секретарь")]
function GetSecr(Object)
  GetSecr = ""
  if not Object.Attributes.has("ATTR_KD_EXEC") then exit function
  set excutor = object.Attributes("ATTR_KD_EXEC").user
  if excutor is nothing then exit function
  GetSecr = GetUserFIO(excutor) ' & chr(13) & "Тел. " & GetUserPhone(excutor)
end function
'=============================================
function GetCardName()  
  GetCardName = "FORM_PROTOCOL_CARD"
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
          GetTypeFileArr = array("Документ","Приложение")  
    case "STATUS_KD_AGREEMENT"
      if IsCanAprove(cUser, docObj) or HasReview(cUser,docObj) then _
          GetTypeFileArr = array("Документ","Приложение")  
    case "STATUS_SIGNING","STATUS_SIGNED"
      if IsExecutor(cUser, docObj) then _
          GetTypeFileArr = array("Документ","Приложение","Скан документа")  
  end select
end function
'=============================================
function Check_RegStatus(stName)
  Check_RegStatus = false
end function
