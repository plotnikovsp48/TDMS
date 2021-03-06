' Команда - Удалить Проект
'------------------------------------------------------------------------------
' Автор: Стромков С.А.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  Set p = Obj.Parent
  ThisScript.SysAdminModeOn
  If CheckObj(Obj) = True Then
    Key = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion + vbYesNo, 1031, Obj.Description )
    If Key = vbNo Then Exit Sub
    Obj.Permissions = SysAdminPermissions 
    Call DeleteContent(Obj)
      Call ThisApplication.ExecuteScript("CMD_S_DLL", "RemoveObjQuery", Obj)
      Obj.Erase
  Else
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 1602, Obj.Description
    Exit Sub
  End If
  ThisApplication.Shell.Update p
End Sub

'Функция проверки проекта на удаление
Function CheckObj(Obj)
  CheckObj = True
  'Проект не имеет связей с другими объектами, кроме объектов, расположенных непосредственно в составе проекта
  For Each LinkObj in Obj.ReferencedBy
    If Not LinkObj.Handle = Obj.Handle Then
      If LinkObj.Parent.Handle <> Obj.Handle Then
        If LinkObj.Attributes.Has("ATTR_SYSTEM_FOLDER") Then 
          If LinkObj.Attributes("ATTR_SYSTEM_FOLDER") = False Then
            CheckObj = False
            Exit Function
          End If
        Else
          CheckObj = False
          Exit Function
        End If
      End If
    End If
  Next
End Function

Sub DeleteContent(Obj)
  Obj.Permissions = SysAdminPermissions 
    For each o in Obj.Content
      o.Permissions = SysAdminPermissions 
      Call ThisApplication.ExecuteScript("CMD_S_DLL", "RemoveObjQuery", o)
      If o.Content.Count > 0 Then Call DeleteContent(o)
      o.Erase
    Next
End Sub