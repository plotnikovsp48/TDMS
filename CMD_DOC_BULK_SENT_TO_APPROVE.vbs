' Автор: Стромков С.А.
'
' Передача на утверждение Основного комплекта
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016


Call Main(ThisObject)

Function Main(Obj)
  Main = False
  
  Set q = ThisApplication.Queries("QUERY_DOCS_BY_STATUS")
  q.Parameter("PARENT") = Obj
  q.Parameter("STATUS") = "='STATUS_DOCUMENT_IS_CHECKED_BY_NK'"
  'q.Parameter("STATUS") = "<> 'STATUS_DOCUMENT_FIXED' And <> 'STATUS_DOCUMENT_IS_APPROVING' And <> 'STATUS_DOCUMENT_INVALIDATED'"
  
  Set oCol = q.Objects
  If oCol.Count = 0 Then 
    msgbox "Нет документов, готовых для передачи на утверждение",vbExclamation,"Передать на утверждение"
    Exit Function
  End If
  
  Set dlg = ThisApplication.Dialogs.SelectObjectDlg
  dlg.SelectFromObjects = q.Objects
  dlg.Caption = "Выберите документы"
  
  RetVal = dlg.Show
  ' Если ничего не выбрано или диалог отменен, выйти
  Set ObjCol = dlg.Objects
  If (RetVal<>TRUE) Or (ObjCol.Count=0) Then Exit Function
  
  For each oDoc In ObjCol
    oDoc.Permissions = SysAdminPermissions
    Call ThisApplication.ExecuteScript("CMD_DOC_SENT_TO_APPROVE","Run",oDoc)
  Next
  Call ThisApplication.ExecuteScript("CMD_DOC_SENT_TO_APPROVE","SendToApprove",Obj)

  Main = True
End Function
