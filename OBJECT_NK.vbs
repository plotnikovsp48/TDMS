Sub AddFile(Obj)
  Msgbox "В разработке!"
End Sub


Sub CloseALLComments(Obj)
  ThisApplication.DebugPrint "CloseALLComments "&time()
  If Obj Is Nothing Then Exit Sub
    ThisScript.SysAdminModeOn
    If Not Obj.Attributes.Has("ATTR_NK_RESULTS_TBL") Then Exit Sub
    Set Table = Obj.Attributes("ATTR_NK_RESULTS_TBL")
    Set Rows = Table.Rows
    For Each row in Rows
      If row.Attributes("ATTR_NK_RESULTS_CORRECTED") = False Then 
        row.Attributes("ATTR_NK_RESULTS_CORRECTED") = True
      End If
    Next
  Obj.Update
  
  Call ThisApplication.ExecuteScript("FORM_DOC_NK","GetTotalEr",Obj)
  Call ThisApplication.ExecuteScript("FORM_DOC_NK","GetOpenEr",Obj)
End Sub

'========================================================================
' Переводит объект Нормоконтроль в завершенное состояние с закрытием всех незакрытых замечаний
'------------------------------------------------------------------------
' Obj:TDMSObject - объект Нормоконтроль
'========================================================================
Sub CloseNK(Obj)
  ThisApplication.DebugPrint "CloseNK "&time()
  If Obj Is Nothing Then Exit Sub
    Call CloseALLComments(Obj)
    Obj.permissions = SysAdminPermissions
'    Obj.Attributes("ATTR_NK_VERSION").value = Obj.Attributes("ATTR_NK_VERSION").value +1
    
    Obj.Status = ThisApplication.Statuses("STATUS_NK_PASS")
    
    Obj.Versions.Create "Нормоконтроль пройден", "Дата прохождения нормоконтроля: " & ThisApplication.CurrentTime
    Obj.Update

End Sub

Sub Object_StatusBeforeChange(Obj, Status, Cancel)
  Obj.permissions = SysAdminPermissions
  If Status.SysName = "STATUS_NK" Then
      Obj.Attributes("ATTR_NK_VERSION").value = Obj.Attributes("ATTR_NK_VERSION").value +1
  End If
End Sub