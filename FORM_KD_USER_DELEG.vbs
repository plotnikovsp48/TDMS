

'=============================================
Sub BTN_ADD_DELEG_OnClick()
  set newUser = thisform.Attributes("ATTR_USER").User
  if newUser is nothing then
    msgbox "Не выбран сотрудник!"
    exit sub
  end if  
  thisApplication.CurrentUser.DelegateRightsTo(newUser)
  thisApplication.CurrentUser.RedirectMailForDelegateRightsTo()
End Sub
'=============================================
Sub BTN_DEL_DELEG_OnClick()
  Set control = thisForm.Controls("QUERY_USER_DELEG")
  iSel = control.ActiveX.SelectedItem
  If iSel < 0 Then 
     msgbox "Не выбран замещающий!"
     Exit Sub 
  end if  

  ar = thisapplication.Utility.ArrayToVariant(control.SelectedItems)
  Answer = MsgBox( "Вы уверены, что хотите удалить из списка замещающих " & Cstr(Ubound(ar)+1) _
         & " пользователя(ей)?" , vbQuestion + vbYesNo,"Удалить?")
  if Answer <> vbYes then exit sub

  for i = 0 to Ubound(ar)
     set user =  control.value.RowValue(ar(i))
     thisApplication.CurrentUser.WithdrawDelegatedRightsTo(user)
  next

End Sub