' Команда - Скопировать из договора
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  Set Query = ThisApplication.Queries("QUERY_CONTRACTS_SELECT_COPY")
  Set Objects = Query.Objects
  If Objects.Count = 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 1604
    Exit Sub 
  End If
  
  ThisScript.SysAdminModeOn
  Set Dlg = ThisApplication.Dialogs.SelectObjectDlg
  Dlg.SelectFromObjects = Objects
  If Dlg.Show Then
    If Dlg.Objects.Count = 0 Then
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 1605
      Exit Sub
    End If
    Set Contr = Dlg.Objects(0)
    If Contr.Content.Count = 0 Then
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 1609, Contr.Description
      Exit Sub
    End If
    Count = 0
    For Each Child in Contr.Content
      Set NewObj = Child.Duplicate(Obj)
      Count = Count + 1
    Next
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 1606, Count
  End If
End Sub
