USE "CMD_KD_LIB_DOC_IN"
use CMD_KD_COMMON_LIB
use CMD_KD_COMMON_BUTTON_LIB 

Set CurrentUser = ThisApplication.CurrentUser
set FSO = CreateObject("Scripting.FileSystemObject")
docStat = ThisObject.StatusName
'Set Chk = ThisForm.Controls("CHECKBOX1").ActiveX

'=============================================
Sub Form_BeforeShow(Form, Obj)    
    EnabledCtrl()    
    SetChBox()
    ShowUsers()
End Sub

'=============================================
sub SetChBox()
  set chk = thisForm.Controls("CHECKBOX1").ActiveX
  if chk is nothing then exit sub
  If ThisForm.Controls("ATTR_KD_VD_INСNUM").Value = "Без номера" Then 
       Chk.value = true
  else 
       Chk.value = false
  End if  
end sub
'=============================================
Sub BTN_REG_OnClick()
    'проверка на заполнение полей
    mes = Check_Fields ()
    
    If not mes = "" Then
       msgbox mes, vbCritical, "Не заполнены обязательные поля!"
       Exit Sub
    End if
      ' проверяем есть скан
    set file = GetFileByType("FILE_KD_SCAN_DOC")
    if file is nothing then 
      msgBox "Невозможно зарегистрироватьдокумент, т.к. не приложен скан документа!", vbCritical, "Регистрация невозможна"
      exit sub
    end if

    ThisObject.Attributes("ATTR_KD_NUM").Value = GetNewNO(thisObject)
    ThisObject.Attributes("ATTR_KD_ISSUEDATE").Value = Now
    ThisObject.Attributes("ATTR_KD_REG").User = ThisApplication.CurrentUser
    ThisObject.Status = ThisApplication.Statuses("STATUS_KD_REGISTERED")
    thisObject.Update
    Set_Permission (thisObject)
    msgBox "Документ зарегистрирован", vbInformation
End Sub

'=============================================
Function EnabledCtrl()
  
  docStat = ThisObject.StatusName
  isSec = isSecretary(ThisApplication.CurrentUser)
  thisform.Controls("BTN_REG").Enabled = isSec and docStat = "STATUS_KD_DRAFT"
  thisform.Controls("BTN_ADD_CONTR").Enabled = isSec and docStat = "STATUS_KD_DRAFT"
  thisform.Controls("BTN_DEL_CONTRDENT").Enabled = isSec and docStat = "STATUS_KD_DRAFT"
  thisform.Controls("BTN_ADD_SCAN").Enabled = isSec and docStat = "STATUS_KD_REGISTERED"
  thisform.Controls("BTN_ADD_ORDER").Enabled = isSec and docStat = "STATUS_KD_VIEWED_RUK"
  thisform.Controls("BUT_ADD_FILE").Enabled = isSec and (docStat = "STATUS_KD_DRAFT" )
  thisform.Controls("BUT_DEL_FILE").Enabled = isSec and (docStat = "STATUS_KD_DRAFT")
'  thisform.Controls("BUT_ADD_FILE").Enabled = isSec and (docStat = "STATUS_KD_DRAFT" or docStat = "STATUS_KD_REGISTERED")
'  thisform.Controls("BUT_DEL_FILE").Enabled = isSec and (docStat = "STATUS_KD_DRAFT" or docStat = "STATUS_KD_REGISTERED")

  
  
'  For each Cntrl in Thisform.Controls
'      Cntrl.ReadOnly = Enbld 
'  Next    
'  Thisform.Controls("ATTR_KD_NUM").ReadOnly = True 'рег.номер
'  Thisform.Controls("ATTR_KD_ISSUEDATE").ReadOnly = True 'дата регистрации
'  Thisform.Controls("ATTR_KD_REG").ReadOnly = True 'зарегистрировал
End Function

'=============================================
Sub CHECKBOX1_Change()

   if not IsCanEdit() then 
     SetChBox()
     exit sub
   end if
   set chk = thisForm.Controls("CHECKBOX1").ActiveX
   
   With ThisForm.Controls("ATTR_KD_VD_INСNUM")
    If chk.Value = true Then
       .Value = "Без номера"
       .ReadOnly = True
    Else
       .Value = "" 
       .ReadOnly = False
    End if   
   End With 
End Sub

'=============================================
Sub BUT_ADD_FILE_OnClick()
    AddFilesToDoc()
End Sub

'=============================================
Sub BUT_DEL_FILE_OnClick()
    DelFilesFromDoc()
    ThisObject.Update
End Sub

'=============================================
Sub BTN_ADD_CONTR_OnClick()
   Set Q = ThisApplication.Queries("QUERY_COR_GET_CORDENTs")
   Set SelObjDlg = ThisApplication.Dialogs.SelectDlg
      SelObjDlg.SelectFrom = Q.Sheet
      RetVal = SelObjDlg.Show
      If RetVal Then
         Set Cordent = SelObjDlg.Objects.Objects(0)
         ThisForm.Attributes("ATTR_KD_CPNAME") = Cordent.Parent
         ThisForm.Attributes("ATTR_KD_CPADRS") = Cordent
      End if
End Sub

'=============================================
Sub BTN_DEL_CONTRDENT_OnClick()
   ThisForm.Attributes("ATTR_KD_CPNAME") = ""
   ThisForm.Attributes("ATTR_KD_CPADRS") = ""
End Sub

'=============================================
Sub QUERY_KD_FILES_IN_DOC_DblClick(iItem, bCancelDefault)
  Thisscript.SysAdminModeOn
  Set s = thisForm.Controls("QUERY_KD_FILES_IN_DOC").ActiveX
  set File = s.ItemObject(iItem) 
  File_CheckOut(file)
  bCancelDefault = true
'    Set s = thisForm.Controls("QUERY_KD_FILES_IN_DOC").ActiveX
'    Set File = s.ItemObject(iItem)
'    Set dict = ThisApplication.Dictionary("Files")
'    If dict.Exists("FileName") Then 
'       dict.Item("FileName") = File.FileName
'    else
'       dict.Add "FileName", File.FileName
'    end if 
'    Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
'    EditObjDlg.Object = ThisObject
'    EditObjDlg.ActiveForm = EditObjDlg.InputForms("FORM_CORR_PDF")
'    EditObjDlg.Show 
'    bCancelDefault = True
End Sub

'=============================================
Sub ATTR_KD_CPNAME_ButtonClick(Cancel)
    Cancel = True
End Sub
'=============================================
Sub ATTR_KD_CPADRS_ButtonClick(Cancel)
  Cancel = true
End Sub


'=============================================
Sub BTNPackUnLoad_OnClick()
   UnloadFilesFromDoc()
End Sub

'=============================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  if form.Controls.Has("TXT_" & Attribute.AttributeDefName) then ShowUser(Attribute.AttributeDefName)
  
  if Attribute.AttributeDefName = "ATTR_KD_VD_SENDDATE" then
      if Attribute.Value > date then
          msgbox "Дата отправки ВД не может быть больше текущей даты", vbCritical, "Изменение отменено"
          cancel = true
      end if 
  end if
  
End Sub

'=============================================
Sub BTN_ADD_SCAN_OnClick()
  LoadFileToDoc("FILE_KD_RESOLUTION")
  Set_Doc_Ready(thisObject)
End Sub

'=============================================
Sub BTN_ADD_ORDER_OnClick()
   call CreateOrders(nothing, thisObject)
End Sub
