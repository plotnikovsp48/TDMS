' $Workfile: COMMAND.SCRIPT.CMD_DOC_SET_ARH_N.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Присвоить документу инвентарный номер
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.


Dim o
Set o = ThisObject
Call Main(o)

Sub Main(o_)
  Dim result
  ' Проверка порядка назначения Инв. номера
  If ThisApplication.Attributes("ATTR_DOC_NUM_SET") = True Then 
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1111
    Exit Sub
  End If
  
  result = ThisApplication.ExecuteScript("CMD_DIALOGS","EditDlg","Укажите инвентарный номер","Инвентарный номер:")
  If result = Chr(1) Then
    Exit Sub
  End If    
  Call SetInvNum(o_,result)
End Sub

Private Sub SetInvNum(o_,sNum_)
  o_.Permissions = SysAdminPermissions
  o_.Attributes("ATTR_NUM") = sNum_ 
End Sub
