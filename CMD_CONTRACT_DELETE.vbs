' Команда - Удалить Договор
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  Set p = Obj.Parent
  If CheckObj(Obj) = True Then
    Key = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion + vbYesNo, 1031, Obj.Description )
    If Key = vbNo Then Exit Sub
    Call ThisApplication.ExecuteScript("CMD_S_DLL", "RemoveObjQuery", Obj)
    Obj.Erase
  Else
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 1602, Obj.Description
    Exit Sub
  End If
  ThisApplication.Shell.Update p
End Sub

'Функция проверки договора на удаление
Function CheckObj(Obj)
  CheckObj = True
  'Объекты в составе
  If Obj.Content.Count > 0 Then
    CheckObj = False
    Exit Function
  End If
  'Договор не имеет связей с другими объектами, кроме договоров
  For Each LinkObj in Obj.ReferencedBy
    If LinkObj.ObjectDefName <> "OBJECT_CONTRACT" Then
      CheckObj = False
      Exit Function
    End If
  Next
End Function
