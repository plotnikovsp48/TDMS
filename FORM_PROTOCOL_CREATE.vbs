use CMD_KD_COMMON_LIB
'use CMD_KD_FILE_LIB
use CMD_KD_PROTOCOL_LIB
use CMD_KD_COMMON_BUTTON_LIB  
use CMD_KD_REGNO_KIB
'use CMD_KD_SET_PERMISSIONS
'use CMD_KD_GLOBAL_VAR_LIB
'use CMD_KD_OUT_LIB  
'=============================================
Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description

  SetChBox()
  ShowKTNo()
  ShowSysID()
  SetInNumEnabled(Obj.Attributes("ATTR_KD_PROT_TYPE"))
  ShowBtnIcon()  
'  SetFieldAutoComp()
  call  SetGlobalVarrible("ShowForm", "FORM_PROTOCOL_CREATE")  
End Sub
'=============================================
Sub BTN_DEL_EXEC_OnClick()
   Del_User("ATTR_KD_EXEC")
End Sub
'=============================================
Sub Form_BeforeClose(Form, Obj, Cancel)
  txt = ThisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB", "CheckProtFileds", thisObject)
  if txt > ""  then 
    ans = msgbox( "Не все обязательные поля заполнены :" & vbNewLine & txt & vbNewLine , _
        vbCritical, "Создать документ невозможно!")
    Cancel = true    
    exit sub    
  end if 
' thisObject.Update
  thisObject.SaveChanges()   

'  call CreateMark("на контроле",thisObject, false)  
  ans = msgbox("Создать документ из шаблона Word?", vbQuestion + VbYesNo, "Создать word файл?")
  if ans = vbYes then createWord() 

  lev = GetGlobalVarrible("WinLevel") ' т.к. форма еще не закрылась и счетчик не пересчитался
  if lev <> "" then  
    lev = lev - 1
    'call SetGlobalVarrible("WinLevel", lev) 
  end if

  call  SetGlobalVarrible("ShowForm", "FORM_KD_DOC_AGREE")  
  Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
  CreateObjDlg.Object = thisObject
  ans = CreateObjDlg.Show
End Sub
