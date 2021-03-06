sub CheckTwoDialogs(Form)
  if isempty(thisapplication.Dictionary("CheckWindowsLimit")("stack")) then
    set stack = thisapplication.CreateCollection(tdmCollection)
  else
    set stack = thisapplication.Dictionary("CheckWindowsLimit")("stack")
  end if 
  
  if not isempty(ThisApplication.Dictionary(thisapplication.CurrentUser.SysName)("WinLev")) then
    lev = ThisApplication.Dictionary(thisapplication.CurrentUser.SysName)("WinLev")
  else
    lev = 0
    exit sub
  end if
  if lev = 1 then
    while stack.Count > 0
      stack.Remove(0)
    wend
  end if
  
  if thisapplication.Dictionary("CheckWindowsLimit")("Exceptions") = 1 then
    if stack.count>1 then
      stack.Remove(stack.count - 1)
    end if
    thisapplication.Dictionary("CheckWindowsLimit")("Exceptions") = 0
  end if
  
  stack.Add Form
  
  if lev > 2 then'lev - количество открытых окон
    while stack.count>2
     stack(0).close
     stack.Remove(0)
    wend
  end if

  set thisapplication.Dictionary("CheckWindowsLimit")("stack") = stack
end sub
