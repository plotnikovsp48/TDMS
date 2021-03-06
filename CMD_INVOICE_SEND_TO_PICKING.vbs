' Команда - Передать на комплектацию (Накладная)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  'Проверяем выполнение входных условий
  Result = CheckObj(Obj)
  If Result = False Then
    Msgbox "В накладной есть неутвержденная документация."&chr(10)&"Действие отменено.", vbExclamation
    Exit Sub
  End If

  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,"STATUS_INVOICE_FORTHEPICKING")
End Sub

'Проверка - Вся приложенная документация должна быть утверждена
Function CheckObj(Obj)
  CheckObj = True
  Set TableRows = Obj.Attributes("ATTR_INVOICE_TDOCS").Rows
  For Each Row in TableRows
    If Row.Attributes("ATTR_INVOICE_DOCS_OBJ").Empty = False Then
      If not Row.Attributes("ATTR_INVOICE_DOCS_OBJ").Object is Nothing Then
        Set Doc = Row.Attributes("ATTR_INVOICE_DOCS_OBJ").Object
        If Doc.StatusName <> "STATUS_WORK_DOCS_SET_IS_APPROVED" and _
        Doc.StatusName <> "STATUS_VOLUME_IS_APPROVED" Then
          CheckObj = False
          Exit For
        End If
      End If
    End If
  Next
End Function