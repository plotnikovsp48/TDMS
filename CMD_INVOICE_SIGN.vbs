' Команда - Передать на проверку (Накладная)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

USE CMD_SS_TRANSACTION

Call Main(ThisObject)

Function Main(Obj)
  ThisScript.SysAdminModeOn
  Main = False
  ' Подтверждение
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, 1529, Obj.Description)    
  If result = vbNo Then Exit Function
  
  Set tr = New Transaction
  
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,"STATUS_INVOICE_SIGNED")
  'Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_KD_SING")
  'Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrders",Obj,"NODE_KD_SING")

  Call SendOrder(Obj)
  
  Call CopyFilesToOwners(Obj)
  Call RouteConnectedObjectsToArchive(Obj)
  
  tr.Commit
  Main = True
End Function


Private Sub RouteConnectedObjectsToArchive(Invoice)
  ThisScript.SysAdminModeOn
  Set TableRows = Invoice.Attributes("ATTR_INVOICE_TDOCS").Rows
  
  For Each Row In TableRows
    Set Obj = Row.Attributes("ATTR_INVOICE_DOCS_OBJ").Object
    If Not Obj Is Nothing Then
      If InStr(1, Obj.StatusName, "IS_APPROVED") > 0 Then
        For Each Child In Obj.ContentAll
          If Child.ObjectDefName = "OBJECT_DRAWING" or Child.ObjectDefName = "OBJECT_DOC_DEV" Then
            If "STATUS_DOCUMENT_FIXED" = Child.StatusName Then 
              Child.StatusName = "STATUS_ARH"
              If Child.Permissions.Locked = True Then
                Child.Unlock
              End If  
            End If
          End If
        Next
        For Each Change In Obj.ReferencedBy.ObjectsByDef("OBJECT_CHANGE_PERMIT")
          If "STATUS_CHANGE_PERMIT_CLOSED" <> Change.StatusName Then
            If Change.Permissions.Locked = True Then
              Change.Unlock
            End If 
            Change.StatusName = "STATUS_CHANGE_PERMIT_CLOSED"
          End If
        Next
        
        Obj.StatusName = "STATUS_ARH"
      End If
    End If
  Next
End Sub


Private Sub CopyFilesToOwners(Invoice)
  Set dict = CreateObject("Scripting.Dictionary")
  Set TableDocRows = Invoice.Attributes("ATTR_INVOICE_TDOCS").Rows
  
  For Each RowDocs In TableDocRows
    If not RowDocs.Attributes("ATTR_INVOICE_DOCS_OBJ").Object is Nothing Then
      Set Doc = RowDocs.Attributes("ATTR_INVOICE_DOCS_OBJ").Object
      If InStr(1, Doc.StatusName, "IS_APPROVED") > 0 Then
        Call ThisApplication.ExecuteScript("FORM_FILES_ARCHIVE","LoadFiles",Doc)
      End If
    End If
  Next
End Sub

Sub SendOrder(Obj)
  Set uToUser = Obj.Attributes("ATTR_AUTOR").User
  If uToUser Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_CORR_REZOL_INF"
  txt = "Накладная """ & Obj.Description & """ подписана"
  planDate = ""
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,planDate
End Sub


