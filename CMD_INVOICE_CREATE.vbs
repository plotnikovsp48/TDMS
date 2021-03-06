' Команда - Создать накладную
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  ObjDefName = "OBJECT_INVOICE"
  Set ObjRoots = thisApplication.ExecuteScript("CMD_KD_FOLDER","GET_FOLDER","",thisApplication.ObjectDefs(ObjDefName))
  if  ObjRoots is nothing then  
    msgBox "Не удалось создать папку", vbCritical, "Объект не был создан"
    exit Sub
  end if
  
  Set proj = ThisApplication.ExecuteScript("CMD_S_DLL","GetProject",Obj)
  Set Dict = ThisApplication.Dictionary("INVOICE_CREATE")
'  If Dict.Exists("PROJECT")=False Then
'   ' Dict.Add("PROJECT")
'  End If
  ThisApplication.Dictionary("INVOICE_CREATE").Item("PROJECT") = proj.Guid
  ObjRoots.Permissions = SysAdminPermissions
    
  'Создаем объект
  Set NewObj = ObjRoots.Objects.Create(ObjDefName)
'  'Заполняем атрибуты
'  Call AttrFill(NewObj,ThisObject)
  'Отображаем диалог редактирования объекта
  Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
  EditObjDlg.Object = NewObj
  
  RetVal = EditObjDlg.Show
  If NewObj.StatusName = "STATUS_INVOICE_DRAFT" Then
    If Not RetVal Then
      NewObj.Erase
      Exit Sub
    End If
  End If
End Sub

'Автоматическое заполнение атрибутов
Sub AttrFill(Obj,oParent)
  'Ссылка на проект
  Set Project = Nothing
  If not oParent is Nothing Then
    If oParent.Attributes.Has("ATTR_PROJECT") Then
      If oParent.Attributes("ATTR_PROJECT").Empty = False Then
        If not oParent.Attributes("ATTR_PROJECT").Object is Nothing Then
          Set Project = oParent.Attributes("ATTR_PROJECT").Object
        End If
      End If
    ElseIf oParent.ObjectDefName = "OBJECT_PROJECT" Then
      Set Project = oParent
    End If
  End If
  If not Project is Nothing Then
    Obj.Attributes("ATTR_PROJECT").Object = Project
  End If
  
  'Получатель
  Set Recipient = Nothing
  If not Project is Nothing Then
    If Project.Attributes.Has("ATTR_CUSTOMER_CLS") Then
      If Project.Attributes("ATTR_CUSTOMER_CLS").Empty = False Then
        If not Project.Attributes("ATTR_CUSTOMER_CLS").Object is Nothing Then
          Set Recipient = Project.Attributes("ATTR_CUSTOMER_CLS").Object
          Obj.Attributes("ATTR_INVOICE_RECIPIENT").Object = Recipient
        End If
      End If
    End If
  End If
  
  'Адрес отправки
  If not Recipient is Nothing Then
    If Recipient.Attributes.Has("ATTR_CORDENT_ADDRES") Then
      If Recipient.Attributes("ATTR_CORDENT_ADDRES").Empty = False Then
        Obj.Attributes("ATTR_INVOICE_ADDRESS").Value = Recipient.Attributes("ATTR_CORDENT_ADDRES").Value
      End If
    End If
  End If
  
  'Тип электронной версии
  Obj.Attributes("ATTR_INVOICE_EVERTYPE").Classifier = _
    ThisApplication.Classifiers("NODE_EVERTYPE").Classifiers.Find("1")
  
  'Тип носителя
  Obj.Attributes("ATTR_INVOICE_DISCTYPE").Classifier = _
    ThisApplication.Classifiers("NODE_DISCTYPE").Classifiers.Find("DVD-R 4.7 Гб")
    
  'Электронная версия
  Obj.Attributes("ATTR_INVOICE_FILES").Value = True
End Sub




