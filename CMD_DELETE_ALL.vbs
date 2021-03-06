'Команда - Удалить с составом
' Автор: Чернышов Д.С.
'
' Удаляет объект со всем его составом
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  ThisApplication.Utility.WaitCursor = True
  Count = 0
  'Удаление состава
  Call DeleteContent(Obj,Count)
  
'  For Each Child in Obj.ContentAll
'    Call QueriesDel(Child)
'    Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", Child)
'    Child.Erase
'    Count = Count + 1
'  Next
  Call QueriesDel(Obj)
  Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", Obj)
  Obj.Erase
  Count = Count + 1
  ThisApplication.Utility.WaitCursor = False
  If Count <> 0 Then
    Msgbox "Удалено " & count & " объектов", vbInformation
  End If
End Sub

'Процедура удаления выборок из состава
Sub QueriesDel(Obj)
  For Each Query in Obj.Queries
    Query.Erase
  Next
End Sub

Sub DeleteContent(Obj,Count)
  Obj.Permissions = SysAdminPermissions 
    For each Child in Obj.Content
      Child.Permissions = SysAdminPermissions 
      Call QueriesDel(Child)
      If Child.Content.Count > 0 Then Call DeleteContent(Child,Count)
      Child.Erase
      Count = Count + 1
    Next
End Sub