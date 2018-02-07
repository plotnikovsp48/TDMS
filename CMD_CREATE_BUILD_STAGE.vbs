' Команда - Создать Этап строительства
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.


Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  ObjDefName = "OBJECT_BUILD_STAGE"
  
  'Создаем объект
  Set NewObj = Obj.Objects.Create("OBJECT_BUILD_STAGE")

  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = NewObj
  RetVal = Dlg.Show
  If NewObj.StatusName = "STATUS_BUILDING_STAGE_DRAFT" Then
    If Not RetVal Then
      NewObj.Erase
      Exit Sub
    End If
  End If  
End Sub


