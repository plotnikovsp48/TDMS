' Автор: Стромков С.А.
'
' Создает график
'------------------------------------------------------------------------------
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call CreateSchedule(ThisObject)

Function CreateSchedule(Obj)
  
  Set CreateSchedule = Nothing
  
  Set ObjRoots = Obj

  'Создаем объект
  ObjRoots.Permissions = SysAdminPermissions
  Set NewObj = ObjRoots.Objects.Create("OBJECT_SCHEDULE")

  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
      Dlg.Object = NewObj
      RetVal = Dlg.Show
      
      Set inStatus = ThisApplication.ObjectDefs("OBJECT_SCHEDULE").InitialStatus
      If Not inStatus Is Nothing Then
        inStatusName = ThisApplication.ObjectDefs("OBJECT_SCHEDULE").InitialStatus.StatusName
      Else 
        inStatusName = vbNullString
      End If
      
      If NewObj.StatusName = inStatusName Then
        If Not RetVal Then
          NewObj.Erase
          Exit Function
        End If
      End If
    Set CreateSchedule = NewObj
End Function
