' Команда - Создать Объект проектирования
'------------------------------------------------------------------------------
' Автор: Стромков С.А.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  ObjDefName = "OBJECT_UNIT"
  'Использование словаря для заполнения атрибутов объекта
  'ThisApplication.Dictionary(ObjDefName).Item("Contract") = Obj.Guid
  
  'Создаем объект
  Set NewObj = Obj.Objects.Create(ObjDefName)
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = NewObj
  If Not Dlg.Show Then
    NewObj.Erase
  End If
End Sub
