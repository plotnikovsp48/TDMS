
'Sub File_Added(File, Object)
''  Object.Description = File.FileName
'  Object.Attributes("ATTR_NAME") = File.FileName
'End Sub

Sub Object_Created(Obj, Parent)
    call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", Obj)
End Sub

Sub File_CheckedIn(File, Object)
  Object.Attributes("ATTR_NAME") = File.FileName

End Sub