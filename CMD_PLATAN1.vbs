Set user = Thisapplication.CurrentUser
'Set user = ThisApplication.Users("USER_E513E0B0_C90B_49FC_A411_05FC3097E2DB") 'Рошук - планнер
'Set user = ThisApplication.Users("USER_85551D33_2F27_4DE2_A43F_817174A8F610") 'Астапов - планнер
'Set user = ThisApplication.Users("USER_6F495E44_846A_4F37_8CFA_CF120FF49FDC") 'Антоненко - executor
'Set user = ThisApplication.Users("USER_F2753307_160E_4C7C_B64B_AC3DA8D1AF01") 'Ульянов - ГИП
'Set user = ThisApplication.Users("USER_9D0BE384_D355_4673_81ED_90C55E09B2DB") 'руководство
'Set user = ThisApplication.Users("USER_7287A08D_73AA_4645_8BC3_D8092EC513A3") 'Зайцева ЭТО нач
UserFIO = user.SysName
BaseName = ThisApplication.DatabaseName
ServerName = ThisApplication.ServerName
UserSqlName = "platanuser"
UserSqlPassword = "platanuser"


'планировщик
set q = ThisApplication.Queries("QUERY_PLANNER")
q.Parameter("PARAM0") = user

'ГИП
set q1 = ThisApplication.Queries("QUERY_PLATAN_GIP")
q1.Parameter("PARAM0") = user.Handle

'Начальник отдела (планировщик)
q2 = user.Groups.Has("GROUP_LEAD_DEPT")

'Руководство
q3 = user.Groups.Has("GROUP_CHIEFS") or user.Groups.Has("GROUP_GIP") or user.Groups.Has("GROUP_LEAD_ENGINNERS")

If q1.sheet.RowsCount > 0 Then 

   UserPrm = "gip" 
else
'   if (q.sheet.RowsCount > 0) or q2 then
'      UserPrm = "planner"
'   else
'      If q3 Then
'         UserPrm = "root"
'      else   
         UserPrm = "executor"    
'      end if   
'   end if
end if         
  Set FSO = CreateObject("Scripting.FileSystemObject")
  if FSO.FileExists("C:\platan\platan.exe") Then
     'вызов ПЛАТАН передаем параметры
     Set WSHShell = CreateObject("WScript.Shell")  
     Param = "C:\platan\platan.exe "&chr(34)&UserFio&chr(34)&" "&chr(34)&UserPrm&chr(34)_
     &" "&chr(34)&BaseName&chr(34)
     WSHShell.Run "C:\platan\platan.exe "&chr(34)&UserFio&chr(34)_
     &" "&chr(34)&UserPrm&chr(34)_
     &" "&chr(34)&BaseName&chr(34)_
     &" "&chr(34)&ServerName&chr(34)_
     &" "&chr(34)&UserSqlName&chr(34)_
     &" "&chr(34)&UserSqlPassword&chr(34)
     Set WSHShell = Nothing 
  Else
    msgbox "ПЛАТАН не установлен на этом рабочем месте",vbCritical
  End If
