' $Workfile: COMMAND.SCRIPT.CMD_VOLUME_SET_ARH_N.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' Присвоить тому инвентарный номер
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.


Dim o
Set o = ThisObject
Call Main(o)

Sub Main(o_)
  Dim result
  result = ThisApplication.ExecuteScript("CMD_DIALOGS","EditDlg","Укажите инвентарный номер","Инвентарный номер:")
  If result = Chr(1) Then
    Exit Sub
  End If
  Call SetInvNum(o_,result)
End Sub

Private Sub SetInvNum(o_,sNum_)
  Dim o
  o_.Permissions = SysAdminPermissions
  For Each o In o_.Objects
    Call SetInvNum(o,sNum_)
  Next
  If o_.Attributes.has("ATTR_NUM") Then 
    o_.Attributes("ATTR_NUM") = sNum_ 
  End If
End Sub
