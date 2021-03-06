' Тип объекта - Закупки
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Sub Object_PropertiesDlgInit(Dialog, Obj, Forms)
  'Доступность формы Список конкурентов
  Check = True
  AttrName = "ATTR_TENDER_TYPE"
  If Obj.Attributes.Has(AttrName) Then
    Val = Obj.Attributes(AttrName).Value
    If StrComp(Val,"Внешние закупки",vbTextCompare) = 0 Then
      Check = False
    End If
  End If
  
  If Check = True and Dialog.InputForms.Has("FORM_TENDER_CONCURENT_LIST") Then
    Dialog.InputForms.Remove("FORM_TENDER_CONCURENT_LIST")
  End If
   'Доступность формы Настройки
  Set CU = ThisApplication.CurrentUser
   Check = True
  AttrName = "ATTR_TENDER_TYPE"
  If Obj.Attributes.Has(AttrName) Then
    Val = Obj.Attributes(AttrName).Value
    If StrComp(Val,"Внешние закупки",vbTextCompare) = 0 Then
      Check = False
    End If
  End If
  
  If Check = True and Dialog.InputForms.Has("FORM_TENDER_INSIDE_FLOW_CUSTOM") Then
    Dialog.InputForms.Remove("FORM_TENDER_INSIDE_FLOW_CUSTOM")
  End If
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","FormAccessOffGropeInStr","FORM_TENDER_IN_DIAL", Obj, Dialog, "GROUP_CONTRACTS", CU ' По группам
  
    'Доступность формы Эксперты
  Set CU = ThisApplication.CurrentUser
   Check = True
  AttrName = "ATTR_TENDER_TYPE"
  If Obj.Attributes.Has(AttrName) Then
    Val = Obj.Attributes(AttrName).Value
    If StrComp(Val,"Внутренние закупки",vbTextCompare) = 0 Then
      Check = False
    End If
  End If
  
  If Check = True and Dialog.InputForms.Has("FORM_TENDER_EXPERT_LIST") Then
    Dialog.InputForms.Remove("FORM_TENDER_EXPERT_LIST")
  End If
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","FormAccessOffGropeInStr","FORM_TENDER_EXPERT_LIST", Obj, Dialog, "GROUP_TENDER_INSIDE", CU ' По группам
  
End Sub



'Sub Object_ContentAdded(Obj, AddCollection)
'  ThisApplication.ExecuteCommand "CMD_SORT",Obj
'End Sub

Sub ContextMenu_BeforeShow(Commands, Obj, Cancel)
  Set cU = ThisApplication.CurrentUser
  Set cG = CU.Groups
  Set cR = Obj.RolesForUser(cU)
  
  'Создать закупку
  GroupName = "GROUP_TENDER_INICIATORS"
  Check = True
  If cG.Has(GroupName) Then
    Check = False
  End If
  If Check = True Then
    Commands.Remove ThisApplication.Commands("CMD_PURCHASE_CREATE")
  End If
  
  'Импортировать из xml
  GroupName = "GROUP_TENDER"
  Check = True
  If cG.Has(GroupName) Then
    Check = False
  End If
  AttrName = "ATTR_TENDER_TYPE"
  If Obj.Attributes.Has(AttrName) Then
    If StrComp(Obj.Attributes(AttrName).Value,"Внешние закупки",vbTextCompare) <> 0 Then Check = True
  Else
    Check = True
  End If
  If Check = True Then
    Commands.Remove ThisApplication.Commands("CMD_TENDER_OUT_IMPORT")
  End If
End Sub
