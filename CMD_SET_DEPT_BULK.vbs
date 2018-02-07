Call Main()

Sub Main()
  ThisScript.SysAdminModeOn
  List = "OBJECT_VOLUME,OBJECT_WORK_DOCS_SET,OBJECT_PROJECT_SECTION_SUBSECTION,OBJECT_PROJECT_SECTION"
  arr = Split(List,",")
  ThisApplication.Utility.WaitCursor = True
  For each ar In Arr
    Call Run(ar)
  Next
  ThisApplication.Utility.WaitCursor = False
End Sub

Sub Run(oDefName)
  If ThisApplication.ObjectDefs.Has(oDefName) = False Then Exit Sub
  For each o In ThisApplication.ObjectDefs(oDefName).Objects
    If O.attributes.Has("ATTR_RESPONSIBLE")=False Then o.attributes.create ("ATTR_RESPONSIBLE")
    sET User = O.attributes("ATTR_RESPONSIBLE").User
    If Not User Is Nothing Then 
      Call SetDept(o,User)
    End If
  Next
End Sub

Sub SetDept(Obj,User)
  ThisScript.SysAdminModeOn
  Obj.permissions = sysadminpermissions
  If Obj.Attributes.Has("ATTR_S_DEPARTMENT") = False Then
    Obj.attributes.create ("ATTR_S_DEPARTMENT")
  End If
    
  Set dept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetDeptForUserByGroup",User,"GROUP_LEAD_DEPT")
  If Dept Is Nothing Then Exit Sub
  Set d1 = Obj.Attributes("ATTR_S_DEPARTMENT").Object
  chk = False
  If d1 Is Nothing Then 
    chk = True
  Else
    If Obj.Attributes("ATTR_S_DEPARTMENT").Object.Handle <> Dept.Handle Then
      chk = True
    End If
  End If
  If chk Then Obj.Attributes("ATTR_S_DEPARTMENT").Object = Dept
End Sub
