USE "CMD_DLL_ROLES"

'Thisscript.SysAdminModeOn

Set ProjectsFolder = ThisObject

If Not ProjectsFolder.GUID = "{3D19C1E4-9884-4A0B-A9AF-F898F1B5CFC0}" Then Set ProjectsFolder = ThisApplication.GetObjectByGUID("{3D19C1E4-9884-4A0B-A9AF-F898F1B5CFC0}")

If Not ProjectsFolder Is Nothing Then 
  Call Main(ProjectsFolder)
Else
  msgbox "Не могу найти папку Проекты. Операция завершена"
End If

Sub Main (p_)
  If Not IsGroupMemberMessage(ThisApplication.CurrentUser,"GROUP_GIP") Then Exit Sub
  Call CreateProject(p_)
End Sub

Sub CreateProject(p_)
  Set NewObj = p_.Objects.Create("OBJECT_PROJECT")
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
      Dlg.Object = NewObj
      If Not Dlg.Show Then
        NewObj.Erase
      End If
End Sub
