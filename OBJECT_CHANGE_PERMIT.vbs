' $Workfile: OBJECTDEF.SCRIPT.OBJECT_CHANGE_PERMIT.scr $ 
' $Date: 30.01.07 19:38 $ 
' $Revision: 1 $ 
' $Author: Oreshkin $ 
'
' Разрешение на изменения
'------------------------------------------------------------------------------
' Авторское право c ЗАО <НАНОСОФТ>, 2008 г.


Sub Object_BeforeCreate(Obj, Parent, Cancel)

  sysID = ThisApplication.ExecuteScript ("CMD_KD_REGNO_KIB","Get_Sys_Id",Obj)
  if sysID = 0 then 
      Cancel = true
      exit sub
  else  
    Obj.Attributes("ATTR_KD_IDNUMBER").value = sysID
  end if
    
  Dim vStatus
  If Parent Is Nothing Then 
    Set vStatus = Nothing
  Else
    Set vStatus = Parent.Status
  End If
  
  Call SetAttrs(Obj)
  'Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,vStatus,Obj,Obj.ObjectDef.InitialStatus)
End Sub

Sub Object_BeforeErase(Obj, Cancel)
  Dim result1,result2
  result1 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckContent", Obj)
  result2 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckReferencedBy", Obj) 
  Cancel=result1 Or result2
  Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", Obj) 
End Sub


Private Sub SetAttrs(Obj)
  Obj.Attributes("ATTR_CHANGE_PERMIT_NUM") = ThisApplication.ExecuteScript("CMD_DLL","GetNum","QUERY_CHANGE_PERMIT_NUM")+1
End Sub
