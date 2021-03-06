USE "CMD_DLL_CONTRACTS"
USE "CMD_DLL_ROLES"

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Call SetControls(Form,Obj)
  CreateTree(nothing)
End Sub

Sub SetControls(Form,Obj)
  Set user = ThisApplication.CurrentUser
  isAuth = IsAuthor(Obj,User)
  isCur = ThisApplication.ExecuteScript("CMD_DLL_CONTRACTS","IsCurator",Obj,User)
  isApr = ThisApplication.ExecuteScript("CMD_KD_USER_PERMISSIONS","IsAprover",user,Obj)
  
  isLock = ObjectIsLockedByUser(Obj)
  
  With Form.Controls
    .Item("ADD_STAGE").Enabled = (isAuth or isCur or isApr) And Not isLock
    .Item("ADD_STAGE").Visible = isAuth or isCur or isApr
    .Item("DEL_STAGE").Enabled = (isAuth or isCur or isApr) And Not isLock
    .Item("DEL_STAGE").Visible = isAuth or isCur or isApr
    .Item("BTN_CHECK_STAGE_SUMM").Enabled = (isAuth or isCur or isApr) And Not isLock
    .Item("BTN_CHECK_STAGE_SUMM").Visible = isAuth or isCur or isApr
  End With
End Sub

Sub ADD_STAGE_OnClick()
  set oRoot = GetStageFromTree()
  if oRoot is nothing then Set oRoot = ThisObject
  ADD_STAGE_ToTree(oRoot)
  CreateTree(nothing)
End Sub

Sub DEL_STAGE_OnClick()
  DEL_STAGE_FromTree()
End Sub

sub CreateTree(curStage)
'thisApplication.AddNotify "create tree - " & CStr(timer)
    dim dict,odict,curItem
    curItem = 0
    set ax_Tee = thisForm.Controls("TDMSTREEStage").ActiveX  
    if ax_Tee is nothing then exit sub
    ax_Tee.DeleteAllItems
    ax_Tee.Font.Size = 10
    ax_Tee.HotTracking = true
'    if curStage is nothing then 
'      set curStage = GetStagesToApplay()
'      if curStage is nothing then  set curStage = GetCurUserRealOrder()
'    end if     
'thisApplication.AddNotify "ger cur order - " & CStr(timer)
    Root = ax_Tee.InsertItem("Этапы", 0, 1)
    ax_Tee.SetItemData Root, thisObject
    ax_Tee.SelectedItem = ax_Tee.RootItem
'    SelectedItem = 0
    Set dict = ThisApplication.Dictionary("tree")
    Set odict = ThisApplication.Dictionary("tobject")

    dict.RemoveAll

    ' Получаем все поручения по документу
    Set q = ThisApplication.Queries("QUERY_TREE_STAGE")
    q.Parameter("PARAM0") = thisObject
    Set sheet = q.Sheet

    ' строем дерево
    For i = 0 to sheet.RowsCount-1
      ' берем GUID родительского поручения
      pGuid = sheet.CellValue(i,2)
      ' берем GUID поручения
      guid = sheet.CellValue(i,1)
      hParent = ax_Tee.RootItem
      ' Если есть родительский узел, то создаем дочернее в нем
      If dict.Exists(pGuid)Then hParent = dict.Item(pGuid)

      txt = sheet.CellValue(i,0) & " | Ответственный: " & sheet.CellValue(i,4) & _
              " | Вид работ: " & sheet.CellValue(i,5)  & _
              " | Начало (план): " & sheet.CellValue(i,6) & _
              " | Окончание (план): " & sheet.CellValue(i,7) & _
              " | Статус: " & sheet.CellValue(i,8)

      ' создаем дочерний узел
      ch = ax_Tee.InsertItem(txt,hParent,0)  
      call ax_Tee.SetItemData(ch,sheet.Objects(i))
      call ax_Tee.SetItemIcon(ch, sheet.RowIcon(i))

      if not curStage is nothing then 
        if curStage.GUID = guid then 
          'ax_Tee.SelectedItem = ch  
          curItem = ch
        end if
        ax_Tee.Expand(ch)
      end if
      ' сохраняем связку описания и номера узла в дереве
      dict.Add guid, ch      
'thisApplication.AddNotify "dict.Add guid, ch  - " & CStr(timer)
    Next
    ax_Tee.SelectedItem curItem
    'ax_Tee.Expand(curItem)
    ax_Tee.Expand(ax_Tee.RootItem)
end sub

Sub TDMSTREEStage_ContextMenu(hItem,x,y,bCancel)
 ThisScript.SysAdminModeOn
  Set Tree = ThisForm.Controls("TDMSTREEStage").ActiveX
  If hItem = 0 Then Exit Sub
  set stage = Tree.GetItemData(hItem)
  pItem = Tree.GetItemText(hItem)
  Set menu = ThisApplication.Dialogs.ContextMenu
  Set Obj = ThisObject
  Set User = ThisApplication.CurrentUser
  '========================================================================================
  isAuth = IsAuthor(Obj,User)
  isCur = ThisApplication.ExecuteScript("CMD_DLL_CONTRACTS","IsCurator",Obj,User)
  isApr = ThisApplication.ExecuteScript("CMD_KD_USER_PERMISSIONS","IsAprover",user,Obj)
  isLock = ObjectIsLockedByUser(Obj)
  
  If (isAuth or isCur or isApr) And Not isLock  Then
    menu.AppendUserMenu 1, "Создать этап", 24
  End If

  If hItem <> Tree.RootItem Then
    menu.AppendUserMenu 2, "Свойства", ThisApplication.Icons("IMG_EDIT").SystemIndex
    If (isAuth or isCur or isApr) And Not isLock  Then
      menu.AppendSeparator
      menu.AppendUserMenu 10, "Удалить", ThisApplication.Icons("IMG_DELETE").SystemIndex
    End If
  End If
  
  result = menu.Show(x, y)
  
  Select Case result
    Case 1 'Создать этап
      Set NewStage = Nothing
      Set NewStage = ADD_STAGE_ToTree(stage)
      If NewStage Is Nothing Then Exit Sub
      CreateTree(nothing)
'      Tree.UpdateItem hItem, False
'      Tree.Expand hItem
    Case 2 'Редактировать этап
      ShowStage(hItem)
      CreateTree(nothing)
'      Tree.UpdateItem hItem, False
'      Tree.Expand hItem
    Case 10 'Удалить
      Call DEL_STAGE_FromTree()
  End Select
End Sub

Sub TDMSTREEStage_DblClick(hItem,bCancelDefault)
  ShowStage(hItem)

End Sub

'=============================================
Sub ShowStage(hItem)
    set ax_Tee = thisForm.Controls("TDMSTREEStage").ActiveX 
    if ax_Tee is nothing then exit sub
    set oStage = ax_Tee.GetItemData(hItem)
    if oStage is nothing then exit sub
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
    CreateObjDlg.Object = oStage
    ans = CreateObjDlg.Show

'    if ans then call updateTreeNode(cOrder,hItem,ax_Tee)
    CreateTree(oStage)
'    ax_Tee.UpdateItem hItem, False
'    ax_Tee.Expand hItem
End Sub

Sub TDMSTREEStage_Expanded(hItem,bExpanded)
  If bExpanded = True Then
    Set Tree = ThisForm.Controls("TDMSTREEStage").ActiveX
    Tree.SortChildren(hItem)
  End If
End Sub

Sub BTN_CHECK_STAGE_SUMM_OnClick()

  str = vbNullString
  Call CheckStages(ThisObject,str)
  If str = vbNullString Then str = "Проверка завершена!"

  Msgbox str,vbInformation,"Проверка суммы этапов"
End Sub

Sub CheckStages(Obj,str)
  str1 = vbNullString
  Set q = ThisApplication.Queries("QUERY_CHECK_STAGE_SUMM")
  q.Parameter("PARAM0") = Obj
  If Cdbl(q.Sheet(0,0)) <> Cdbl(q.Sheet(0,2)) Then 
    str = str & "Сумма стоимости этапов " & q.Sheet(0,2) & " не равна стоимости договора " & q.Sheet(0,0) & chr(10)
  End If
  If Cdbl(q.Sheet(0,1)) <> Cdbl(q.Sheet(0,3)) Then 
    str = str & "Сумма стоимости этапов с НДС " & q.Sheet(0,3) & " не равна стоимости договора с НДС" & q.Sheet(0,1)
  End If

  Set q = thisApplication.Queries("QUERY_CONTRACT_STAGES")
  q.Permissions = sysadminpermissions
  q.Parameter("CONTRACT") = Obj
  
  If q.Objects.count > 0 Then
    For each oStage In q.Objects
      If oStage.Parent.Handle <> Obj.Handle Then
      If oStage.Attributes("ATTR_PRICE").Empty or oStage.Attributes("ATTR_PRICE_W_VAT").Empty Then
        If str1 = vbNullString Then
          str1 = "- " & oStage.Description
        Else
          str1 = str1 & chr(10) & "- " & oStage.Description
        End If
      End If
      End If
    Next
  End If  
  
  If str1 <> vbNullString Then
    If str = vbNullString Then
      str = str & "Не указаны стоимости этапов: " & str1
    Else
      str = str & chr(10) & "Не указаны стоимости этапов: " & str1
    End If
  End If
End Sub