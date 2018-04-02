'=============================================
'Проверка существования глобальной переменной
function IsExistsGlobalVarrible(VarName)
  Set dict = ThisApplication.Dictionary(thisapplication.CurrentUser.SysName)
  IsExistsGlobalVarrible = dict.Exists(VarName) 
end function

'=============================================
'Установаить значение глобавльной переменной
sub SetGlobalVarrible(VarName, Value)
   Set dict = ThisApplication.Dictionary(thisapplication.CurrentUser.SysName)
   if dict.Exists(VarName) then
     dict.Item(VarName) = Value
   else
     call dict.Add(VarName,Value)
   end if
end sub

'=============================================
'Получить значение глобавльной переменной
function GetGlobalVarrible(VarName)
 Set dict = ThisApplication.Dictionary(thisapplication.CurrentUser.SysName)
   if dict.Exists(VarName) then
     GetGlobalVarrible = dict.Item(VarName) 
   else
     'MsgBox "Ошибка чтения значения глобальной переменной: такая переменная не найдена " & VarName, vbCritical,"Ошибка"
     GetGlobalVarrible = ""
   end if
end function

'=============================================
'Установаить значение объектной глобавльной переменной
sub SetObjectGlobalVarrible(VarName, Value)
   Set dict = ThisApplication.Dictionary(thisapplication.CurrentUser.SysName)
   if dict.Exists(VarName) then
     Set dict.Item(VarName) = Value
   else
     call dict.Add(VarName,Value)
   end if
end sub

'=============================================
'Удалить глобальную переменную
sub RemoveGlobalVarrible(VarName)
   Set dict = ThisApplication.Dictionary(thisapplication.CurrentUser.SysName)
   if dict.Exists(VarName) then
     call dict.Remove(VarName)
   end if
end sub

'=============================================
'Получить значение объектной глобавльной переменной
function GetObjectGlobalVarrible(VarName)
 Set dict = ThisApplication.Dictionary(thisapplication.CurrentUser.SysName)
   if dict.Exists(VarName) then
     Set GetObjectGlobalVarrible = dict.Item(VarName) 
     
   else
     'MsgBox "Ошибка чтения значения глобальной переменной: такая переменная не найдена " & VarName, vbCritical,"Ошибка"
     Set GetObjectGlobalVarrible = Nothing
   end if
end function


