

Sub Object_Created(Obj, Parent)
    Obj.Files.AddCopy thisApplication.FileDefs("FILE_4D7EEDFC_512B_4263_BC95_E3C2040F7343").Templates(0), fName
    Obj.SaveChanges()
End Sub