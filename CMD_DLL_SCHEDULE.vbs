
'Set WSHShell = CreateObject("Wscript.Shell")
'Call WSHShell.Run("msproject.exe C:\TEMP\PROJECT\doc.xml")
'Now set the focus to the project file
'WSHShell.AppActivate "msproject"
'Do whatever else you want to the file here

'Call OpenProject("C:\TEMP\PROJECT\doc.xml")

'Sub OpenProject(xmlDoc,path_) 
'    Dim pjApp
'    Set pjApp = CreateObject("MSProject.Application") 
'    pjApp.Visible = True 
'    pjApp.FileOpen path_
''    pjApp.FileSave 
''    pjApp.FileClose 
''    pjApp.Quit 
'End Sub


Sub OpenProject(xmlDoc,path_) 
    
    filename = Left(path_,Len(path_)-3) & "mpp"
    pos = InStrRev(filename,"\")
    
    fname = right(filename,Len(path_) - pos)

  xmlDoc.Permissions = SysAdminPermissions
  If xmlDoc.Files.Has(fname) = False then 'xmlDoc.Files(filename).Erase
    xmlDoc.Files.AddCopy ThisApplication.FileDefs("FILE_SCHEDULE_MPP").Templates("График разработки РД.mpp"), fname
    xmlDoc.Update
  End If
  
  Set xmlFile = xmlDoc.Files(fname)
  xmlFile.CheckOut xmlDoc.Files(fname).Workfilename
  xmlDoc.Files(fname).CheckOut xmlDoc.Files(fname).Workfilename
    
    
    
    Dim pjApp
    Set pjApp = CreateObject("MSProject.Application") 
    pjApp.Visible = True 
    'pjApp.FileOpen xmlFile.Workfilename
    pjApp.FileOpen path_
   ' pjApp.FileSaveAs filename

'    pjApp.FileClose 
'    pjApp.Quit 
End Sub
