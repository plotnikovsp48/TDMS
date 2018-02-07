' $Workfile: OBJECTDEF.SCRIPT.OBJECT_ADVANCE_NOTIFICATION.scr $ 
' $Date: 30.01.07 19:38 $ 
' $Revision: 1 $ 
' $Author: Oreshkin $ 
'
' Предварительное извещение
'------------------------------------------------------------------------------
' Авторское право c ЗАО <НАНОСОФТ>, 2008 г.


Sub Object_BeforeCreate(o_, p_, Cancel)
	Dim vStatus
	If p_ Is Nothing Then 
		Set vStatus = Nothing
	Else
		Set vStatus = p_.Status
	End If
	
	Call SetAttrs(o_)
	Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",o_,vStatus,o_,o_.ObjectDef.InitialStatus)
End Sub

Sub Object_BeforeErase(o_, cn_)
	Dim result
	'result1 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckContent", o_)
	result = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckReferencedBy", o_)	
 	cn_=result
 	Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", o_)	
End Sub

Private Sub SetAttrs(o_)
	o_.Attributes("ATTR_ADVANCE_NOTIFICATION_NUM") = ThisApplication.ExecuteScript("CMD_DLL","GetNum","QUERY_AN_NUM")+1
End Sub