
Sub Object_Created(Obj, Parent)
   call ThisApplication.ExecuteScript("CMD_KD_SET_PERMISSIONS", "Set_Permission", Obj)
End Sub

'Sub List_BeforeShow(Sheet)
'  if thisObject.Description ="Все СЗ по проектам" then
'    set q = thisapplication.Queries("QUERY_ALL_PM_MEMO")
'    set sh = q.Sheet
'    Sheet.Set sh
'  end if 
'  if thisObject.Description ="2. Входящий документ" then
'    set q = thisapplication.Queries("QUERY_COR_PDO_IN")
'    set sh = q.Sheet
'    Sheet.Set sh
'  end if 
'  if thisObject.GUID ="{1A95061D-AB1C-4586-8D35-D08E941EAE3A}" then 'Входящие 
'    set q = thisapplication.Queries("QUERY_COR_IN_CHIEF")
'    set sh = q.Sheet
'    Sheet.Set sh
'  end if 
'  if thisObject.GUID ="{BAFA6118-E987-4F6B-90AF-F10969E85ABF}" then 'На контроле
'    set sh = GetContlosSheet()
'    if not sh is nothing then 
'      Sheet.Set sh
'    end if
'  end if 
'  if thisObject.GUID ="{80489691-537C-4FBA-813F-E6E8AC467D7C}" then 'невыполненые
'    set sh = GetNotSend()
'    if not sh is nothing then 
'      Sheet.Set sh
'    end if
'  end if 
'  if thisObject.GUID ="{20A3FCD0-0626-49EA-9139-F4D2B18D86D6}" then 'поиск по меткам
'    set q = thisapplication.Queries("QUERY_ALLMARKS")
'    set sh = q.Sheet
'    Sheet.Set sh
'  end if 
'  
'  
'End Sub

'function GetNotSend()
'  set GetNotSend = nothing

'  set curUser = thisApplication.CurrentUser

'  if curUser.Groups.Has("GROUP_CORR_R_CHIEF") then 
'    set q = thisapplication.Queries("QUERY_COR_NOT_SEND")'1. Нераззосланные руководством
'  else 
'    set q = thisapplication.Queries("QUERY_COR_IN_ALL_IN_OTD")'1. Невыполненые в отделе
'  end if
'  set GetNotSend = q.Sheet

'end function
''________________________
'' EV подставляем выборку в зависимости от роли сотрудника
'function GetContlosSheet()

'  set GetContlosSheet = nothing

'  set curUser = thisApplication.CurrentUser

'  if curUser.Groups.Has("GROUP_CORR_R_CHIEF") then 
'    set q = thisapplication.Queries("QUERY_COR_CHIEFS_CONTROL")'("QUERY_COR_IN_NOT_ANS")'2.2 На контроле у руководства
'  else if IsChief(curUser) and not curUser.Groups.Has("GROUP_CORR_OGIP_CHIEF") then 
'      set q = thisapplication.Queries("QUERY_COR_CONTROL_IN_DEPT")'("QUERY_COR_IN_NOT_ANS")'2.2 На контроле в отделе
'      else
'        set q = thisapplication.Queries("QUERY_COR_IN_NOT_ANS")'("QUERY_COR_IN_NOT_ANS")'ответственный и не выполнено
'      end if  
'  end if
'  set GetContlosSheet = q.Sheet
'end function

''EV проверяем наличие группы начальник отдела
''________________________
'function IsChief(user)
'  IsChief = false
'  for each group in user.Groups
'    if InStr(group.SysName,"_CHIEF")>0 then 
'      IsChief = true
'      exit function
'    end if 
'  next
'end function



