
Call Run(ThisObject)

Sub Run(Obj)
  Dim o
  Set o =  ThisApplication.ExecuteScript("CMD_DLL", "Create","OBJECT_FOLDER",Obj)
End Sub



