' Команда - Получение ПСД подтверждено (Накладная)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  'Подтверждение
'  Key = Msgbox("Подтвердить получение ПСД?",vbYesNo+vbQuestion)
'  If Key = vbNo Then Exit Function
  
  'Запрос ФИО получателя и даты
  Set Form = ThisApplication.InputForms("FORM_INVOICE_CLOSE")
  Form.Show
  If Form.Dictionary.Exists("FORM_KEY_PRESSED") Then
    If Form.Dictionary.Item("FORM_KEY_PRESSED") = False Then Exit Function
  End If
  
  'Заполнение атрибутов накладной
  Obj.Attributes("ATTR_USER2_STR").Value = Form.Attributes("ATTR_USER2_STR").Value
  Obj.Attributes("ATTR_USER_POSITION2_STR").Value = Form.Attributes("ATTR_USER_POSITION2_STR").Value
  Obj.Attributes("ATTR_INVOICE_RECEIPT_DATE").Value = Form.Attributes("ATTR_INVOICE_RECEIPT_DATE").Value
  Obj.Attributes("ATTR_INVOICE_RECIPIENT_COMMENT").Value = Form.Attributes("ATTR_INVOICE_RECIPIENT_COMMENT").Value

  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,"STATUS_INVOICE_CLOSED")
  Main = True
  'Оповещение 
  Call SendMessage(Obj)
  Call SendOrder(Obj)
End Function



'==============================================================================
' Отправка оповещения о подтверждении получения ПСД накладной ГИПу и Куратору договора
'------------------------------------------------------------------------------
' o_:TDMSObject - накладная
'==============================================================================
Private Sub SendMessage(o_)
  CurU = ThisApplication.CurrentUser.Description
  For Each r In o_.RolesByDef("ROLE_GIP")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1404, u, o_, Nothing, o_.Description, CurU, Date
  Next
  For Each r In o_.RolesByDef("ROLE_CONTRACT_RESPONSIBLE")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1404, u, o_, Nothing, o_.Description, CurU, Date
  Next  
End Sub

Sub SendOrder(Obj)
  Set uToUser = Obj.Attributes("ATTR_CHECKER").User
  If uToUser Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_CORR_REZOL_INF"
  txt = "Накладная: """ & Obj.Description & """ Получена получателем"
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,""
  
  Set uToUser = Obj.Attributes("ATTR_SIGNER").User
  If uToUser Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_CORR_REZOL_INF"
  txt = "Накладная: """ & Obj.Description & """ Получена получателем"
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,""
End Sub
