ThisScript.SysAdminModeOn'PlotnikovSP
Set FSO = CreateObject("Scripting.FileSystemObject") 
Set objShell = CreateObject("Shell.Application")

Set objFolder = objShell.BrowseForFolder (0, "Выберите папку:", 0, 0)

If Not objFolder Is Nothing Then
  forbiddenSymbols = Array("\","/",":","*","?","""","<",">","|")
  predescription = thisObject.ObjectDef.Description & " - " & thisObject.Description
  for each sym in forbiddenSymbols
    predescription = Replace(predescription, sym, "_")
  next

  path = ObjFolder.Self.Path & "\" & left(predescription, 100)   
  
  If not FSO.FolderExists(Path) then FSO.CreateFolder( Path )
      For each File in thisobject.Files
         File.CheckOut Path & "\" & File.FileName 
      Next
      
  objShell.Explore(Path) 
end if
ThisScript.SysAdminModeOff
