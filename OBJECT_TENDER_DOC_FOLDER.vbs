' Тип объекта - Тендерная документация
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

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
  
  'Планируемая потребность форма 2.2 (МТР)
  GroupName = "GROUP_TENDER_INSIDE"
  Check = True
  If cG.Has(GroupName) Then
    Check = False
  End If
  If Check = True Then
    Commands.Remove ThisApplication.Commands("CMD_PLANED_NEEDS_FORM_2.2_MTR")
    Commands.Remove ThisApplication.Commands("CMD_PLANED_NEEDS_FORM_2.1_URG")
    Commands.Remove ThisApplication.Commands("CMD_SPECIFAIED_NEEDS_FORM_2.2_MTR")
    Commands.Remove ThisApplication.Commands("CMD_SPECIFAIED_NEEDS_FORM_2.1_URG")
    Commands.Remove ThisApplication.Commands("CMD_SPECIFAIED_NEEDS_FORM_EP")
    Commands.Remove ThisApplication.Commands("CMD_PLANED_NEEDS_FORM_EP")
  End If
End Sub
