' Команда - Создать договор субподряда
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

USE "CMD_DLL_CONTRACTS"

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
'  'Определяем контейнер "Договоры"
  Set Parent = GetContractRoot
  If Parent is Nothing Then Exit Sub
  
  'Использование словаря для заполнения атрибутов объекта
  'ThisApplication.Dictionary(Parent.GUID).Item("MainContract") = Obj.Guid
  'ThisApplication.Dictionary(Parent.GUID).Item("SubContract") = True
  
  Set cls = ThisApplication.Classifiers.FindBySysId("NODE_CONTRACT_EXP")

  'Создаем объект
  Parent.Permissions = SysAdminPermissions
  Set NewObj = Parent.Objects.Create("OBJECT_CONTRACT")
  'Заполняем атрибуты
  ' Класс договора
  NewObj.Attributes("ATTR_CONTRACT_CLASS").Classifier = cls
  'Основной договор
  NewObj.Attributes("ATTR_CONTRACT_MAIN").Object = Obj
  'Тип договора
  Set Clf = ThisApplication.Classifiers.FindBySysId("NODE_CONTRACT_TYPE_5")
  If not Clf is Nothing Then NewObj.Attributes("ATTR_CONTRACT_TYPE").Classifier = Clf
  'Заказчик
  Call FillCompany(NewObj)
  
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
      Dlg.Object = NewObj
      RetVal = Dlg.Show
      
  If NewObj.StatusName = "STATUS_CONTRACT_DRAFT" Then
    If Not RetVal Then
      NewObj.Erase
      Exit Function
    End If
  End If
End Sub
