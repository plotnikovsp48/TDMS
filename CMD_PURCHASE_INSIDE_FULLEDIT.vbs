' Команда - Редактировать (Внутренняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  
  'Проверка состояния
  Check = True
  If Obj.Roles.Has("ROLE_FULLACCESS") Then Check = False
  If Obj.StatusName = "STATUS_FULLACCESS" Then Check = False
  If Check = False Then
    Msgbox "Объект уже открыт для редактирования!", vbCritical
    Exit Sub
  End If
  
  'Добавляем атрибут
  If Obj.Attributes.Has("ATTR_ORIGINAL_STATUS_NAME") = False Then
    Obj.Attributes.Create ThisApplication.AttributeDefs("ATTR_ORIGINAL_STATUS_NAME")
  End If
  Obj.Attributes("ATTR_ORIGINAL_STATUS_NAME").Value = Obj.StatusName
  
  Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,"ROLE_FULLACCESS",ThisApplication.CurrentUser)
  Obj.Status = ThisApplication.Statuses("STATUS_FULLACCESS")
  
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = Obj
  Dlg.Show
  
  ThisScript.SysAdminModeOff
End Sub
