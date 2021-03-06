use CMD_KD_COMMON_LIB
use OBJECT_KD_BASE_DOC
use CMD_KD_CURUSER_LIB

'=============================================
function Check_RegStatus(stName)
  Check_RegStatus = (stName = "STATUS_SIGNED")
end function
'=============================================
' конечный статус
function Check_FinishStatus(stName)
  Check_FinishStatus = (stName = "STATUS_KD_CANCEL") or (stName = "STATUS_SIGNED")or (stName = "STATUS_SENT")
end function

''=============================================
'Sub Object_PropertiesDlgInit(Dialog, Obj, Forms)
'  'ThisApplication.AddNotify "Object_PropertiesDlgInit " & CStr(Timer())
'  If ThisApplication.Dictionary.Exists("SetRecip") Then _
'    If not Forms.Has("FORM_KD_CORDENTS") then _
'      Forms.Add("FORM_KD_CORDENTS")

'  RemoveForm "SetRecip", "FORM_KD_CORDENTS",Dialog,Forms

'End Sub

'Sub File_Added(File, Object)
'End Sub

' функции для шаблона
'=============================================
Extern GetRecipiend [Alias ("Список получателей"), HelpString ("Список адресов, телефонов получаетелей")]'PlotnikovSP 13.03.2018 - почему старая неоптимизированная функция??? :) 
function GetRecipiend(Object)
  GetRecipiend = ""
  if Object.ObjectDefName <>"OBJECT_KD_DOC_OUT" then exit function
  set rows = Object.Attributes("ATTR_KD_TCP").Rows
  if rows.Count = 0 then exit function
  for each row in rows
    set cordent = row.Attributes("ATTR_KD_CPADRS").Object
    set org = row.Attributes("ATTR_KD_CPNAME").Object
    pfr = ""
    on error resume next
    pfr = org.Attributes("ATTR_S_JPERSON_ORG_TYPE").Classifier.Code
    on error goto 0
    If pfr = "" Then pfr = org.Attributes("ATTR_S_JPERSON_ORG_TYPE")
    if not cordent is nothing  and not org is nothing then 
        'if i>0 then GetRecipiend = GetRecipiend & chr(13) & chr(13)' EV отделяем строки
        GetRecipiend = GetRecipiend & cordent.Attributes("ATTR_COR_USER_POS_DP").Value & chr(13)
        GetRecipiend = GetRecipiend & pfr & " """ & org.Attributes("ATTR_CORDENT_NAME").Value & """" & chr(13)
        GetRecipiend = GetRecipiend & cordent.Attributes("ATTR_COR_USER_SHORT").Value & " "   _
                        & cordent.Attributes("ATTR_COR_USERNAME_DP").Value & chr(13) 
        if trim(cordent.Attributes("ATTR_CORR_ADD_ADDRESS").Value) <> "" then 
            GetRecipiend = GetRecipiend & "Адрес: " & trim(cordent.Attributes("ATTR_CORR_ADD_ADDRESS").Value) & chr(13) 
        end if 
        if trim(cordent.Attributes("ATTR_CORR_ADD_TELEFON").Value) <> "" or trim(cordent.Attributes("ATTR_CORR_ADD_FAX").Value) <> "" then 
            GetRecipiend = GetRecipiend & "Телефон/факс: " & trim(cordent.Attributes("ATTR_CORR_ADD_TELEFON").Value) _
            & chr(13) & trim(cordent.Attributes("ATTR_CORR_ADD_FAX").Value) & chr(13) 'PlotnikovSP - разделил телефон и факс
        end if
        GetRecipiend = GetRecipiend & "E-mail: " & cordent.Attributes("ATTR_CORR_ADD_EMAIL").Value & chr(13) & chr(13)
        'GetRecipiend = GetRecipiend & chr(13) & chr(13)' EV отделяем строки 
    end if
  next
end function
'=============================================
Extern GetRecipiend1 [Alias ("Список получетелей1"), HelpString ("Список адресов, телефонов получаетелей")]
function GetRecipiend1(Object)
  str = GetRecipiend(Object)
  GetRecipiend1 = left(str, 255)
end function
'=============================================
Extern GetRecipiend2 [Alias ("Список получетелей2"), HelpString ("Список адресов, телефонов получаетелей")]
function GetRecipiend2(Object)
  str = GetRecipiend(Object)
  GetRecipiend2 = mid(str, 256, 255)
end function
'=============================================
Extern GetRecipiend3 [Alias ("Список получетелей3"), HelpString ("Список адресов, телефонов получаетелей")]
function GetRecipiend3(Object)
  str = GetRecipiend(Object)
  GetRecipiend3 = mid(str, 511, 255)
end function

'=============================================
Extern GetCall [Alias ("Обращение"), HelpString ("Обращение к получателю")]
function GetCall(Object)
  GetCall = ""
  if Object.ObjectDefName <>"OBJECT_KD_DOC_OUT" then exit function
  set rows = Object.Attributes("ATTR_KD_TCP").Rows
  if rows.Count = 0 then exit function
  set UserRow = rows(0) 
  i = 0
  if rows.Count > 1 then
    for each row in rows
      if row.attributes("ATTR_TO_SEND").value = false then  
        i = i + 1
        set UserRow = row
      end if
    next
  end if
  if i > 1  then 
      GetCall = "Уважаемые господа,"
  else  
     if UserRow is nothing then exit function
     set cordent = UserRow.Attributes("ATTR_KD_CPADRS").Object
     if cordent is nothing then exit function
'EV не скопировались атрибуты
     thisScript.SysAdminModeOn
     cordent.Permissions = SysAdminPermissions
     if not cordent.Attributes.has("ATTR_KD_CALL") then cordent.Attributes.Create ThisApplication.AttributeDefs("ATTR_KD_CALL")
     str = cordent.Attributes("ATTR_KD_CALL").value
     if str = "" then str = "Уважаемый(ая)"
     GetCall = str & " " _
        & cordent.Attributes("ATTR_COR_USER_NAME").value & "!"
  end if  
end function
'=============================================
Extern GetExecutor [Alias ("Исполнитель"), HelpString ("Информация об исполнителе")]'PlotnikovSP 13.03.2018
function GetExecutor(Object)
  GetExecutor = ""
  if Object.ObjectDefName <>"OBJECT_KD_DOC_OUT" then exit function
  set excutor = object.Attributes("ATTR_KD_EXEC").user
  if excutor is nothing then exit function
  UserArr = Split(excutor.Description," ")
  GetExecutor = UserArr(0) & " " & UserArr(1) & " " & UserArr(2) & chr(13) & "тел. " & GetUserPhoneOut(excutor) & _
  chr(13) & "газ.: (721) 4-" & trim(excutor.phone)
 ' GetExecutor = GetUserFIO(excutor) & chr(13) & "тел. " & GetUserPhoneOut(excutor)'PlotnikovSP 13.03.2018
end function

'=============================================
function GetUserFIO(user)
  thisScript.SysAdminModeOn
'  GetUserFIO = trim(user.Attributes("ATTR_KD_FIO").value)
'  if len(GetUserFIO) > 3 then exit function
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

' внешний телефон
'=============================================
function GetUserPhoneOut(user)
  dim tel, telvn
  telvn = trim(user.Phone)
  GetUserPhoneOut = telvn 

  filial = user.Attributes("ATTR_KD_DEPART")
  If filial = "" Then exit function
  Select case filial
    case "М - Москва"
      tel = " +7(495)966-25-50"
    case "К - Красноярск"
      tel = " +7(391)256-80-30"
    case "С - Самара"
      tel = " +7(846)379-26-84"
    case "Т - Тюмень"
      tel = " +7(3452)67-92-00"
  End Select
  GetUserPhoneOut = tel & ", доб. " & telvn
end function

'=============================================
Extern GetSignFio [Alias ("ФИО подписанта"), HelpString ("ФИО подписанта")]
function GetSignFio(Object)
  GetSignFio =""
  if Object.ObjectDefName <>"OBJECT_KD_DOC_OUT" then exit function
  set signer = object.Attributes("ATTR_KD_SIGNER").user
  if signer is nothing then exit function
  GetSignFio = GetUserFIO(signer)
end function  
'=============================================
function GetCardName()
  GetCardName = "FORM_KD_OUT_CARD"
end function
'=============================================
function CanIssueOrder(DocObj)
'  CanIssueOrder = false
'  docStat = DocObj.StatusName
'  str = ";STATUS_SENT;"
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
      if IsExecutor(cUser, docObj) or  IsController(cUser, docObj) then _
          GetTypeFileArr = array("Документ","Приложение","Загрузить приложение из дочерних поручений")  
    case "STATUS_KD_AGREEMENT"
      if IsCanAprove(cUser, docObj) or HasReview(cUser,docObj) then _
          GetTypeFileArr = array("Документ","Приложение")  
    case "STATUS_SIGNING", "STATUS_SIGNED"
      if isSin then _
          GetTypeFileArr = array("Документ","Приложение","Скан документа")  
    case "STATUS_SENT"
         if isSin then _
          GetTypeFileArr = array("Скан документа")  
 
  end select
end function
'=============================================
Extern GetRepNo [Alias ("Ответ На"), HelpString ("Номер письма ответа на")]
function GetRepNo(Object)
  GetRepNo = "                              "
  if Object.ObjectDefName <>"OBJECT_KD_DOC_OUT" then exit function
  set rows = object.Attributes("ATTR_KD_VD_REPGAZ").rows
  if rows.Count = 0 then exit function
  set letObj = rows(0).attributes("ATTR_KD_D_REFGAZNUM").object
  if letObj is nothing then exit function
  val = letObj.attributes("ATTR_KD_VD_INСNUM").value
  spacenum = (20 - Len(val))
  if spacenum > 0 Then val = val & Space(spacenum)
  GetRepNo = val
end function
'=============================================
Extern GetRepDate [Alias ("Дата Ответ На"), HelpString ("Дата отправки письма ответа на")]
function GetRepDate(Object)
  GetRepDate = "                              "
  if Object.ObjectDefName <>"OBJECT_KD_DOC_OUT" then exit function
  set rows = object.Attributes("ATTR_KD_VD_REPGAZ").rows
  if rows.Count = 0 then exit function
  set letObj = rows(0).attributes("ATTR_KD_D_REFGAZNUM").object
  if letObj is nothing then exit function
  val = letObj.attributes("ATTR_KD_VD_SENDDATE")
  spacenum = (20 - Len(val))
  if spacenum > 0 Then val = val & Space(spacenum)
  GetRepDate = val
end function
