sub Git_ConnectTo_GitHub
  'curUser = thisapplication.Users.Current
  'thisapplication.UserMailRoot 
  'set shell = CreateObject("Shell.Application")
  'shell.ShellExecute "powershell", "git", "cd C:/Users/Станислав/Desktop/git_test"
  
 '"cd (git --exec-path)"
   
  repository = "D:\Git repositaries\Pr5"
  Set objShell = CreateObject("WScript.Shell")
  
  set WshExec = objShell.exec("git --exec-path")
  'ttt = WshExec.StdOut
  Set TextStream = WshExec.StdOut
  While Not TextStream.AtEndOfStream
    Str = Str & Trim(TextStream.ReadLine()) & vbCrLf
  Wend
  Set FSO = CreateObject("Scripting.FileSystemObject")
  pathToGit = FSO.GetParentFolderName(Str)
  pathToGit = FSO.GetParentFolderName(pathToGit)
  pathToGit = FSO.GetParentFolderName(pathToGit)
  pathToGit = pathToGit & "\" & "git-bash.exe"
  
  Set objShellApp = CreateObject("Shell.Application")
  objShellApp.ShellExecute "powerShell", "echo '# TDMS' >> D:\'Git repositaries'\Pr1\README.md"'pathToGit, "git init """ & repository & """" ' "echo 1 >> README.md"'"cd """ & repository & """"
 ' objShellApp.ShellExecute repository
  'objShell.exec "git bash echo"'"git init """ & repository & """"
  
  'objShell.Exec pathToGit & " cd D:\Git repositaries\Pr5" '& " ""git init D:\Git repositaries\Pr5"""' & " ""D:\Git repositaries\Pr5""" '& " git init ""D:\Git repositaries\Pr5"""
  'objShell.Exec pathToGit & " git init " & repository


'"'" init """ & repository & """"
  'MsgBox pathToGit
  't = 1
  'set WshExec = objShell.exec("git")
  'Set InStream = WshExec.StdIn
 ' InStream.WriteLine "cd " & repository
 ' InStream.WriteLine "git init " + repository
  'InStream.WriteLine "echo "# TDMS" >> README.md"
  t = 1
  'objShell.Exec "git init """ & repository &"""" '& vbNewline & _
  'objShell.Exec "echo ""# TDMS"" >>" & repository & "README.md"
 ' objShell.Exec "echo ""# TDMS"" >> README.md"
  'objShell.Exec "echo ""# TDMS"" >> README.md"
   '"echo ""# TDMS"" >> README.md"
  '"git init"
  '"cd ""D:/Git repositaries/Pr3""" & vbNewline & _
  
  '"git init ""D:/Git repositaries/Pr2""" & vbNewline & _
  
 
 
 'obj'Shell.run "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe D:/Programm files/Git/git-bash.exe"
 
 'objShell.Exec "D:/Programm files/Git/git-bash.exe ""git init""
  'objShell.Exec "D:/Programm files/Git/git-bash.exe"
   'D:/Programm files/Git/git-bash.exe 'git --help'"
' objShell.Exec "D:/Programm files/Git/git-bash.exe echo ""# t2"" >> README.md " & vbnewline & "git init" & vbnewline & "git add README.md" & vbnewline & "git commit -m ""first commit"""& vbnewline &"git remote add origin https://github.com/plotnikovsp48/t2.git"& vbnewline &"git push -u origin master"
 'objShell.Exec "D:/Programm files/Git/git-bash.exe git init"
 ''objShell.Exec "D:/Programm files/Git/git-bash.exe git add README.md"
 'objShell.Exec "D:/Programm files/Git/git-bash.exe git commit -m ""first commit"""
 'objShell.Exec "D:/Programm files/Git/git-bash.exe git git remote add origin https://github.com/plotnikovsp48/ttt.git"
 ' objShell.Exec "D:/Programm files/Git/git-bash.exe git push -u origin master" 
  
  'objShell.run("C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe")
  'objShell.run("powershell -Executionpolicy Bypass -nologo -noninteractive git init")
  'objShell.run("powershell -Executionpolicy Bypass -nologo -noninteractive -file .\script.ps1 -parameter Example")
  
  
 'Set objShellApp = CreateObject("Shell.Application")
 ' objShellApp.ShellExecute "powershell.exe", "", "C:\Windows\System32\WindowsPowerShell\v1.0\", "git-bash.exe", ""
  
end sub

Git_ConnectTo_GitHub
