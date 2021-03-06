' Команда - Создать Акт
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call CreateCCR(ThisObject)

Function CreateCCR(Obj)
  Set CreateCCR = Nothing
  Set docBase = Nothing
  Set CurObj = Nothing
  ThisScript.SysAdminModeOn
  ObjDefName = "OBJECT_CONTRACT_COMPL_REPORT"
  
    Set oSel = ThisApplication.Shell.SelObjects
    If oSel.Count > 0 Then
      Set CurObj = oSel(0)
    End If
  
  'Использование словаря для заполнения атрибутов объекта
  If Not CurObj Is Nothing Then
    If CurObj.IsKindOf("OBJECT_KD_BASE_DOC") Then
      Set oContr = CurObj.Attributes("ATTR_KD_AGREENUM").Object 
      If Not oContr Is Nothing Then
        Set docBase = oContr
'        ThisApplication.Dictionary(ObjDefName).Item("Contract") = oContr.Guid
      End If
      
    ElseIf CurObj.IsKindOf("OBJECT_CONTRACT") Then
      Set docBase = CurObj
'      ThisApplication.Dictionary(ObjDefName).Item("Contract") = Obj.Guid
    
    ElseIf CurObj.Attributes.Has("ATTR_CONTRACT") Then
      Set docBase = CurObj.Attributes("ATTR_CONTRACT").Object
'    Else
'      Set docBase = Nothing
    End If
  End If
  
  If Not docBase Is Nothing Then
  
    ThisApplication.Dictionary(ObjDefName).Item("Contract") = docBase.Guid
  
  End If
  
  Set ObjRoots = thisApplication.ExecuteScript("CMD_KD_FOLDER","GET_FOLDER","",thisApplication.ObjectDefs(ObjDefName))
  if  ObjRoots is nothing then  
    msgBox "Не удалось создать папку", vbCritical, "Объект не был создан"
    exit Function
  end if
  ObjRoots.Permissions = SysAdminPermissions
    
  'Создаем объект
  Set NewObj = ObjRoots.Objects.Create(ObjDefName)
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = NewObj
    RetVal = Dlg.Show
  If NewObj.StatusName = thisApplication.ObjectDefs(ObjDefName).InitialStatus.SysName Then '"STATUS_COCOREPORT_DRAFT" Then
    If Not RetVal Then
      NewObj.Erase
      Exit Function
    End If
  End If
  Set CreateCCR = NewObj
End Function
