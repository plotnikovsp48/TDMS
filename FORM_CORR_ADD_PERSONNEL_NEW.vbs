use CMD_KD_COMMON_LIB
use CMD_KD_COMMON_BUTTON_LIB

'=============================================
'Проверка правильности заполнения полей формы
function CheckFormComplete 

Result = true

if ThisObject.Attributes.Has("ATTR_CORR_ADD_FIO") then
   CheckStr = "if (ThisObject.Attributes(""ATTR_CORR_ADD_FIO"").Value = """") then MsgBox ""Не заданы ФИО"""
else
   CheckStr = "if (ThisObject.Attributes(""ATTR_CORR_ADD_NAME"").Value = """") then MsgBox ""Не задано наименование компании"""
end if

CheckStr = CheckStr & ",VbCritical,""Ошибка"" : Result = Result and false : end if"

execute CheckStr


 Result = Result and CheckEMail(ThisObject.Attributes("ATTR_CORR_ADD_EMAIL").Value,false)
'Проверка факса и телефона
 Result = Result and CheckPhoneNumber(ThisObject.Attributes("ATTR_CORR_ADD_TELEFON").Value)
' ThisApplication.AddNotify CStr(Result)
 Result = Result and CheckPhoneNumber(ThisObject.Attributes("ATTR_CORR_ADD_FAX").Value)
' ThisApplication.AddNotify CStr(Result)
 'call SetGlobalVarrible("COMLETE",Result)
 CheckFormComplete  = Result
end function

'=============================================
Sub Form_BeforeClose(Form, Obj,Cancel)
 if not CheckFormComplete then
    MsgBox "Поля формы содержат ошибки",vbExclamation,"Сохраенение невозможно"
    Cancel = true
    exit sub
 end if
'  if not CheckDoubleP() then Cancel = true
' if thisApplication.CurrentUser.Groups.Has("GROUP_COR_RECIPIENT") then 
'    if obj.StatusName <> "STATUS_KD_IN_FORCE" then 
'        obj.Status = thisApplication.Statuses("STATUS_KD_IN_FORCE")  
'        obj.Update
'    end if
' end if
end sub

'=============================================
Sub ATTR_CORR_ADD_EMAIL_Modified()
 call ClearAttribute("ATTR_CORR_ADD_EMAIL")
 call CheckEMail(ThisObject.Attributes("ATTR_CORR_ADD_EMAIL").Value,false)
End Sub
'=============================================
Sub ATTR_CORR_ADD_TELEFON_Modified()
 call ClearAttribute("ATTR_CORR_ADD_TELEFON")
 call CheckPhoneNumber(thisObject.Attributes("ATTR_CORR_ADD_TELEFON").Value)
End Sub
'=============================================
Sub ATTR_CORR_ADD_FAX_Modified()
 call ClearAttribute("ATTR_CORR_ADD_FAX")
 call CheckPhoneNumber(thisObject.Attributes("ATTR_CORR_ADD_FAX").Value)
End Sub
'=============================================
Sub Form_BeforeShow(Form, Obj)
'    thisForm.Controls("BTN_INFORCE").Enabled = thisApplication.CurrentUser.Groups.Has("GROUP_COR_RECIPIENT") and _
'        thisObject.StatusName <> "STATUS_KD_IN_FORCE"
  ShowBtnIcon()
End Sub

QUERY_CHECK_PERSON
'=============================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  call ClearAttribute(Attribute.AttributeDefName)
End Sub
'=================================
function  CheckDoubleP() 
  CheckDoubleP = false
    Set Q = thisApplication.Queries("QUERY_CHECK_PERSON")
    Q.Parameter("PARAM0") = thisObject.Attributes("ATTR_COR_USER_CORDENT").Object.handle
    Q.Parameter("PARAM1") = thisObject.Handle
    Q.Parameter("PARAM2") = thisObject.Description
    Q.Parameter("PARAM3") = thisObject.Attributes("ATTR_CORR_ADD_EMAIL").Value
    
    Set Objs = Q.Objects
    if Objs.Count > 0 then 
      set selObj = thisApplication.Dialogs.SelectObjectDlg
      selObj.Prompt = "Сотрудник с указанным ФИО и e-mail уже существует"
      SelObj.SelectFromObjects = Objs
      RetVal = selObj.Show 
      exit function
    end if
   CheckDoubleP = true 
End function