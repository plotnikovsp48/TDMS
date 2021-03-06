use CMD_KD_GLOBAL_VAR_LIB
use CMD_KD_CURUSER_LIB

'=============================================
Sub Form_BeforeShow(Form, Obj)
    SetCurUser()

    call BTN_REFRESH_OnClick()
'     call CreateTree(Form)
'     set dic = ThisApplication.Dictionary("P1")
'     dic.RemoveAll
'     dic.Add "f1", Form
'     
'     Form.Controls("STATIC1").Value = "Обновлено " &  cStr(Time)
End Sub

'=============================================
sub showQuery(hItem)
  on error resume next
  Set tree = ThisForm.Controls("TDMSTREE1").ActiveX
  set q = tree.GetItemObject(hItem)
  if q is nothing then exit sub
  
  qname = GetGlobalVarrible("WinQuery") ' EV чтобы не обновлять если в окне состава ввыбрана другая выборка
  if qname = "" then exit sub

'  qname_ = objQ.sysName
'  Set q = ThisApplication.Queries(qname_)
  Set sheet = q.Sheet
  call SetGlobalVarrible("WinQuery", q.sysName) 'эqname_)
  call SetGlobalVarrible("WinSaveQName", "t") ' EV флаг для очистки

  Thisapplication.Shell.ListInitialize sheet
  on error goto 0
end sub
'=============================================
Sub TDMSTREE1_DblClick(hItem,bCancelDefault)
  showQuery(hItem)
end sub
'=============================================
Sub TDMSTREE1_Selected(hItem,action)
'  ReadQueryForProfiles(profs) 'обноввляем и все данные
  RefreshSelItem(thisForm)
''thisApplication.AddNotify "selected - " & cStr(timer)
'  set ax_Tee = thisForm.Controls("TDMSTREE1").ActiveX
'  if hItem = 0 then exit sub
''thisApplication.AddNotify "selected - " & cStr(hItem) & " - " &  cStr(ax_Tee.SelectedItem)
'  Set q = ax_Tee.GetItemObject(hItem)
'  If TypeName(q) <> "ITDMSQuery" Then exit sub
'  str = GetGlobalVarrible("Start")
'  if str = "T" then 
'    RemoveGlobalVarrible("Start")
'  else
'    ax_Tee.Collapse(hItem)
'    call SetGlobalVarrible("WinQuery", q.sysName) ' EV чтобы обновилась выборка
'    call SetGlobalVarrible("FromSel", "T")
'    call UpdateQueryCountTxt(hItem,ax_Tee,q) 
'    call RemoveGlobalVarrible("FromSel")
'  end if
 ' if action = 3 then _
    showQuery(hItem)
'  thisApplication.AddNotify "selected end - " & cStr(timer)
    
End Sub
'=============================================
sub RefreshSelItem(Frm)
  on error resume next
  if IsEmpty(frm) then exit sub
  if frm is nothing then exit sub
  if not Frm.Controls.Has("TDMSTREE1") then exit sub

  set ax_Tee = Frm.Controls("TDMSTREE1").ActiveX
  hItem = ax_Tee.SelectedItem
  if hItem = 0 then exit sub
  Set q = ax_Tee.GetItemObject(hItem)
  If TypeName(q) <> "ITDMSQuery" Then exit sub
  str = GetGlobalVarrible("Start")
  if str = "T" then 
    RemoveGlobalVarrible("Start")
  else
    ax_Tee.Collapse(hItem)
    call SetGlobalVarrible("WinQuery", q.sysName) ' EV чтобы обновилась выборка
    call SetGlobalVarrible("FromSel", "T")
    call UpdateQueryCountTxt(hItem,ax_Tee,q) 
    call RemoveGlobalVarrible("FromSel")
  end if
end sub 
''=============================================
'sub RefreshItem(hItem)
'  call SetGlobalVarrible("FromSel", "T")
'  set ax_Tee = thisForm.Controls("TDMSTREE1").ActiveX
'  if hItem = 0 then exit sub
'  Set q = ax_Tee.GetItemObject(hItem)
'  If TypeName(q) <> "ITDMSQuery" Then exit sub

'  ax_Tee.Collapse(hItem)
'  call SetGlobalVarrible("WinQuery", q.sysName) ' EV чтобы обновилась выборка
'  call UpdateQueryCountTxt(hItem,ax_Tee,q) 
'  showQuery(hItem)
'  RemoveGlobalVarrible("FromSel")
'end sub
'=============================================
sub GoToQiery2()
 Dim arr(4),arTree(4)
   Set tree = ThisForm.Controls("TDMSTREE1").ActiveX
  'Если двойной клик был по узлу, который связан с объектом,
  'то показываем окно свойств этого объекта при помощи диалога TDMS
  qry = tree.GetItemData(hItem)
  if qry =  "" then exit sub
  lev = 0
  arr(lev) = qry
  par1 = tree.GetParentItem(hItem)
  if par1<>0 then 
    lev = lev + 1
    qry = tree.GetItemData(par1)
    arr(lev) = qry
    par2 = tree.GetParentItem(par1)
    if par2<>0 then 
      lev = lev + 1
      qry = tree.GetItemData(par2)
      arr(lev) = qry
'      par3 = tree.GetParentItem(par2)
'      if par3<>0 then 
'        lev = lev + 1
'        qry = tree.GetItemData(par3)
'        arr(lev) = qry
'      end if
    end if
  end if
  if lev = 0 then exit sub
  if lev = 1 then
    Set arTree(1) = ThisApplication.Desktop
    set fld = ThisApplication.Desktop.Objects(arr(1))
    Set arTree(2) =  fld
    set qry = fld.Queries(arr(0))
    Set arTree(3) = qry
  elseif lev = 2 then 
    Set arTree(1) = ThisApplication.Desktop
    set fld = ThisApplication.Desktop.Objects(arr(2))
    Set arTree(2) =  fld
    set qry = fld.Queries(arr(1))
    Set arTree(3) = qry
    set qry = qry.Queries(arr(0))
    Set arTree(4) = qry
  end if
  ThisApplication.Shell.SetActiveTreeItem(arTree)
'  GoToQuery(qry)
'  GetParentItem
End Sub

'=============================================
sub GoToQuery(qry)
  set folder = GetDOFolder()
  if folder is nothing then exit sub
  Dim arr(3)
  Set arr(1) = ThisApplication.Desktop
  Set arr(2) = folder 
  Set arr(3) = arr(2).Queries(qry)
  
  ThisApplication.Shell.SetActiveTreeItem(arr)

end sub

'=============================================
function GetDOFolder()
  set GetDOFolder = nothing
  set root = ThisApplication.Desktop
  set folder = nothing
  for each obj in root.Objects
    if obj.IsKindOf("OBJECT_ARM_FOLDER") then 
        set GetDOFolder = obj
        exit for
    end if
  next
end function


'=============================================
sub CreateTree(Frm)
  Dim pconf ' объект со связкой профиль-папки АРМ
  Dim profiles ' Профили текущего пользователя
  Dim q ' выборка, возвращающая строку связки профиля и папок АРМа
  Dim ax_Tee ' Дерево оперативных выборок
  Dim root ' корневой узел дерева
  Dim folders ' строка GUID папок АРМа с разделителем ";"
  Dim folder ' папка АРМа
  Dim fArr ' масив GUID папок АРМа
  Dim i ' счетчик
  
  Set pconf = ThisApplication.GetObjectByGUID("{3EC03146-87F4-4778-9A43-A4B4F60C489B}") ' Берем объект со связкой профиль-папки АРМ
  If pconf Is Nothing Then exit sub
  Set profiles = GetCurUser().Profiles
  
  call ReadQueryForProfiles(profiles,frm)
  set ax_Tee = Frm.Controls("TDMSTREE1").ActiveX
  if ax_Tee is nothing then exit sub
  ax_Tee.DisplayFullContent = false
  ax_Tee.HotTracking = true
'    ax_Tee.DeleteAllItems
'thisApplication.AddNotify cstr(timer)  
  If ax_Tee.count>0 Then
    root = ax_Tee.RootItem
    selItem = ax_Tee.SelectedItem 
    While root >0 ' Перебираем все корневые папки в дереве 
'      If ax_Tee.IsItemExpanded(root) Then ' Если узел открыт (!!! метод определения открытого узла не работает)
        call UpdateQueryCount(ax_Tee.GetChildItem(root),ax_Tee) 
'      end if
      root = ax_Tee.GetNextSiblingItem(root)
    Wend
    ShowQuery(selItem)
  Else
    call CreateForProfil("PROFILE_ALL", ax_Tee) ' А.О.:Добавил
    call CreateForProfil("PROFILE_DEFAULT", ax_Tee)
    For Each profil In profiles
      ' А.О.: изменил условия
      if (profil.SysName <> "PROFILE_DEFAULT") and (profil.SysName <> "PROFILE_ALL")  then _
        call CreateForProfil(profil.SysName, ax_Tee)
    Next  
  End If 
  err.Clear
  on error goto 0
  set dic = ThisApplication.Dictionary("P1")
  dic.Item("curTime") = Time ' запоминаем время последненго обновления

'  thisApplication.AddNotify cstr(time)  
end sub
'=============================================
sub ReadQueryForProfiles(profs, frm)
'    queries = thisApplication.Queries
  userName = frm.Controls("TDMSEDITUSER").Value
  set user = nothing
  if userName = "" then exit sub
  if thisApplication.Users.Has(userName) then _ 
    set User = thisApplication.Users(userName)
  if user is nothing then exit sub
  
    set newq = nothing 
    set newq = thisApplication.Queries("QUERY_SUM_PROFILE_ALL") 'count test
    if not newq is nothing then 
        newq.Parameter("Param0") = user
        set sh = newq.sheet
        SetQueryCountInDic(sh)
    end if
    For Each profil In profs
      set newq = thisApplication.Queries("QUERY_SUM_" & profil.sysname) 'count test
      if not newq is nothing then 
          newq.Parameter("Param0") = user
          set sh = newq.sheet
          SetQueryCountInDic(sh)
      end if
    Next  

end sub
'=============================================
sub CreateForProfil(profilName, ax_Tee)
  Dim q ' выборка, возвращающая строку связки профиля и папок АРМа
  Set q = ThisApplication.Queries("QUERY_PANEL_CONFIG") 
     q.Parameter("PARAM1") = profilName
     set sh = q.Sheet
     if sh.RowsCount>0 then 
      folders = ""
      folders = q.Sheet.CellValue(0,0) ' считываем строку GUID
      flag = q.Sheet.CellValue(0,1) 
      fArr = Split(folders,";")
      For i=0 to UBound(fArr)
        Set folder = ThisApplication.GetObjectByGUID(fArr(i))
        If not folder is Nothing Then        
          root = ax_Tee.InsertObject(folder, 0,0)      
          If  flag Then 
            call ax_Tee.Expand(root)
            call UpdateQueryCount(ax_Tee.GetChildItem(root),ax_Tee)          
          end if      
        End if
      Next
     end if 
end sub

''=============================================
sub UpdateQueryCount(root_,ax_Tee_)

'  ThisApplication.AddNotify root_
'  ThisApplication.AddNotify ax_Tee_.IsItemExpanded(root_)
  Dim q
  Dim sh
  Dim cnt
  Dim cntQ
  Dim cntNQ
  Dim str
  
  cnt = 0
  cntN = 0
  
  If root_= 0 Then Exit Sub
  Set q = ax_Tee_.GetItemObject(root_)
'  thisApplication.AddNotify q.description 
  If TypeName(q)<> "ITDMSQuery" Then Exit Sub
' А.О.: Закоментировал, т.к. пока не используем подвыборки второго уровня (22.06.2017)
'  If q.Queries.count <> 0  Then ' третий и ниже уровень
'    ax_Tee_.Expand(root_)
'    call UpdateQueryCount(ax_Tee_.GetChildItem(root_),ax_Tee_)  
'    ax_Tee_.Collapse(root_)  ' схлопывает элементы 3 и ниже уровня
'  End If
  call UpdateQueryCount(ax_Tee_.GetNextSiblingItem(root_),ax_Tee_)  ' берет следующий дочерний и вызывает рекурсивно обработку
  call UpdateQueryCountTxt(root_,ax_Tee_,q)
end sub

''=============================================
'sub ClearQueryInDic()
'  Set dict = ThisApplication.Dictionary("QUERIESCOUNT")
'  dict.RemoveAll  
'end sub
'=============================================
sub SetQueryCountInDic(sheet)
  if sheet is nothing then exit sub
  for i = 0 to sheet.RowsCount - 1
   VarName = sheet.CellValue(i,0)
   call SetQueryCount(VarName, sheet.CellValue(i,1))
  next
end sub
'=============================================
sub SetQueryCount(qname, count)
  Set dict = ThisApplication.Dictionary("QUERIESCOUNT")
   if dict.Exists(qname) then
      dict.Item(qname) = count
   else
     call dict.Add(qname,count)
   end if
end sub
'=============================================
function GetQCount(qName)
  dim res
  GetQCount = -1
  res = GetGlobalVarrible("FromSel")
'  RemoveGlobalVarrible("FromSel")
  if res = "T" then exit function ' если из селекты читаем из самой выборки

  Set dict = ThisApplication.Dictionary("QUERIESCOUNT")
  if dict.Exists(qName)  then _ 
    GetQCount = dict.Item(qName) 
  if isEmpty(GetQCount) then GetQCount = -1
end function
'=============================================
sub UpdateQueryCountTxt(root_,ax_Tee_,q)
  IsItemExpanded = false
  qname = GetGlobalVarrible("WinQuery")
  if qName > "" then 
    if q.Queries.Has(qName) then IsItemExpanded = true
  end if
'if not ax_Tee_.IsItemExpanded(root_) then 
if not IsItemExpanded then 
  cnt = GetQCount(q.SysName & "_COUNT")
'  ThisApplication.AddNotify cstr(timer) & " - " & q.SysName & "_COUNT" & " - " &cnt
  if cnt = -1 then 
    Set qs = thisApplication.Queries
    if qs.Has(q.SysName & "_COUNT") then 
  '  ThisApplication.AddNotify q.SysName & "_COUNT"  
      set cntQ = qs(q.SysName & "_COUNT")
      set sh = cntQ.sheet
      cnt = sh.CellValue(0,0)
    else
      set sh = q.sheet
      cnt = sh.rowsCount
  ' А.О.: Закоментировал, т.к. пока нет подвыборок с COUNT(22.06.2017)      
    end if
    call SetQueryCount(q.SysName & "_COUNT", cnt)
  end if
  if cnt <> 0 then 
    str  = q.Description & " (" & cStr(cnt)
      '  ThisApplication.AddNotify q.SysName & "_COUNTN"
    cntN = GetQCount(q.SysName & "_COUNTN")
    if cntN = -1 then 
      Set qs = thisApplication.Queries
      if qs.Has(q.SysName & "_COUNTN") then 
        set cntNQ = qs(q.SysName & "_COUNTN")
        set sh = cntNQ.sheet
        on error resume next
        cntN = sh.CellValue(0,0)
        if err.Number <> 0 then _
          thisApplication.AddNotify "error"
      end if
      call SetQueryCount(q.SysName & "_COUNTN", cntN)
    end if  
    if cntN > 0 then   
      str = str & "/"&cStr(cntN) & ")"
'        strX = "/ "&cStr(cntN) & ")"
      Call ax_Tee_.SetItemExtraText(root_,strX)   
      Call ax_Tee_.SetItemBold(root_, true)   
    else   
      Call ax_Tee_.SetItemBold(root_, false)   
      str = str & ")"
    end if
'    else   
'        str = str & ")"
'    end if
  else
    str  = q.Description
    Call ax_Tee_.SetItemBold(root_, false)   
  end if
else
  str  = q.Description 
  Call ax_Tee_.SetItemBold(root_, false)   
  call UpdateQueryCount(ax_Tee_.GetChildItem(root_),ax_Tee_)   
end if

'  ThisApplication.AddNotify cstr(timer) & " - " & str
  Call ax_Tee_.SetItemText(root_,str)      
 
End Sub
'=============================================
function CreateQueryTree(qry, root,ax_Tee)
   CreateQueryTree = 0
   cnt = 0
   cntN = 0
   if thisApplication.Queries.Has(qry.SysName & "_COUNT") then 
      set cntQ = thisApplication.Queries(qry.SysName & "_COUNT")
      set sh = cntQ.sheet
      cnt = sh.CellValue(0,0)
   else
      set sh = qry.sheet
      cnt = sh.rowsCount
   end if
   if thisApplication.Queries.Has(qry.SysName & "_COUNTN") then 
'  on error resume next
      set cntNQ = thisApplication.Queries(qry.SysName & "_COUNTN")
      set sh = cntNQ.sheet
      cntN = sh.CellValue(0,0)
   end if
   str  = qry.Description & " ("&cStr(cnt)&")" & " ("&cStr(cntN)&")"
   ch = ax_Tee.InsertItem(str,root,0)  
   call ax_Tee.SetItemData(ch,qry.SysName)
   call ax_Tee.SetItemIcon(ch, qry.Icon)
   CreateQueryTree = ch
end function
'=============================================
sub CreateTreeOld(Frm)
  on error resume next
  if IsEmpty(frm) then exit sub
  if frm is nothing then exit sub
  
  set  folder = GetDOFolder()
  if folder is nothing then exit sub
     if not Frm.Controls.Has("TDMSTREE1") then exit sub
     set ax_Tee = Frm.Controls("TDMSTREE1").ActiveX
     if ax_Tee is nothing then exit sub
     ax_Tee.DeleteAllItems
     root = ax_Tee.InsertItem("Документы в работе",0,0) 
     for each qry in folder.Queries
        set sh = qry.sheet
       str  = qry.Description &" ("&cStr(sh.rowsCount)&")"
       ch = ax_Tee.InsertItem(str,root,0)  
       call ax_Tee.SetItemData(ch,qry.SysName)
     next 
'     ch = ax_Tee.InsertItem("Недавние документы",root,0)  
'     call ax_Tee.SetItemData(ch,"QUERY_ARM_1_DCP") 
''     ch = ax_Tee.InsertItem("Выданные",root,0)  
'     ch = ax_Tee.InsertItem("Подготовить (3)",root,0)  
'     call ax_Tee.SetItemData(ch,"QUERY_ARM_5_CP")
'     ch = ax_Tee.InsertItem("Проверить (5)",root,0)  
'     call ax_Tee.SetItemData(ch,"QUERY_ARM_6_CP")
'     ch = ax_Tee.InsertItem("Рассмотреть.Подписать",root,0)  
     call ax_Tee.Expand(root)
     err.Clear
     on error goto 0
end sub
'=============================================
Sub BTN_REFRESH_OnClick()
'thisApplication.AddNotify "BTN_REFRESH_OnClick - " & cStr(timer)
     call CreateTree(thisForm)
     set dic = ThisApplication.Dictionary("P1")
     dic.RemoveAll
     dic.Add "f1", thisForm
'thisApplication.AddNotify "BTN_REFRESH_OnClick end  - " & cStr(timer)
     thisForm.Controls("STATIC1").Value = "Обновлено " &  cStr(Time)
End Sub

'=============================================
'Sub TDMSTREE1_ExpandInit(hItem)
'  set ax_Tee = thisForm.Controls("TDMSTREE1").ActiveX
'    While hItem >0  Перебираем все корневые папки в дереве 
'        call UpdateQueryCount(ax_Tee.GetChildItem(hItem),ax_Tee) 
'      root = ax_Tee.GetNextSiblingItem(hItem)
'    Wend

'End Sub
'=============================================
Sub TDMSTREE1_Expanded(hItem,bExpanded)
  set ax_Tee = thisForm.Controls("TDMSTREE1").ActiveX
  Set q = ax_Tee.GetItemObject(hItem)
  If TypeName(q) <> "ITDMSQuery" Then exit sub
  if bExpanded then 
    Call ax_Tee.SetItemText(hItem,q.Description )
    Call ax_Tee.SetItemBold(hItem, false)   
    While hItem >0  'Перебираем все корневые папки в дереве 
      call UpdateQueryCount(ax_Tee.GetChildItem(hItem),ax_Tee) 
      hItem = ax_Tee.GetNextSiblingItem(hItem)
    Wend
  else
     call UpdateQueryCountTxt(hItem,ax_Tee,q) 
  end if
End Sub

'=============================================
sub SelectInOrder(frm)
  on error resume next
  if IsEmpty(frm) then exit sub
  if frm is nothing then exit sub
  if not Frm.Controls.Has("TDMSTREE1") then exit sub
  set ax_Tee = Frm.Controls("TDMSTREE1").ActiveX
  set q = thisApplication.Queries("QUERY_ARM_ORDER_IN")
  hItem = ax_Tee.FindObject(q.Handle,0)
 ' call SetGlobalVarrible("Start","T")
  ax_Tee.SelectedItem = hItem  

end sub
'=============================================
sub SetCurUser()
  set us = thisApplication.CurrentUser.GetDelegatedRightsFromUsers()
  if us.Count = 0 then 
    thisForm.Controls("TDMSEDITUSER").Value = thisApplication.CurrentUser.Description
    thisForm.Controls("TDMSEDITUSER").Visible = false
    thisForm.Controls("TDMSEDITUSER").ActiveX.buttontype = 2
  else
    us.Add(thisApplication.CurrentUser)
    thisForm.Controls("TDMSEDITUSER").ActiveX.ComboItems = us
    thisForm.Controls("TDMSEDITUSER").Value = thisApplication.CurrentUser.Description
    thisForm.Controls("TDMSEDITUSER").ActiveX.buttontype = 2
   end if
'  set us1 = us(0)  
end sub
'=============================================
Sub TDMSEDITUSER_Modified()
  RemoveGlobalVarrible("SelectedUserOP")
  userName = thisForm.Controls("TDMSEDITUSER").Value
  set user = nothing
  if userName = "" then exit sub
  if thisApplication.Users.Has(userName) then _ 
    set User = thisApplication.Users(userName)
  if user is nothing then exit sub
  call SetObjectGlobalVarrible("SelectedUserOP",user)
  set ax_Tee = thisForm.Controls("TDMSTREE1").ActiveX
  if ax_Tee is nothing then exit sub
  ax_Tee.DeleteAllItems ' EV чтобы полность пересоздать дерево
  call RemoveGlobalVarrible("WinQuery") ' EV чтобы обновилась выборка
  BTN_REFRESH_OnClick()
  
  SelectInOrder(thisForm)
End Sub
