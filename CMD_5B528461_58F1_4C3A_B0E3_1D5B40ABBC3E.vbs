

call CreateGroup("GROUP_SECRETARY","Делопроизводители")
call CreateGroup("GROUP_COR_RECIPIENT","Редактирование контрагентов")
call CreateGroup("GROUP_EDIT_DEPT","Редактирование оргструктуры")


sub CreateGroup(sysName, Descr)
  Set Groups = ThisApplication.Groups
  if not Groups.Has(sysName) then 
    Set NewGroup = Groups.Create
    NewGroup.SysName = sysName
    NewGroup.Description = Descr
  end if                                
end sub