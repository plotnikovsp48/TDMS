' Команда - Отправлена (Накладная)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  Set CurU = ThisApplication.CurrentUser
  ' Подтверждение
  ans = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, 1406, Obj.ObjectDef.Description, Obj.Description)    
  If ans <> vbYes Then
    Exit Function
  End If  
  
  
  'Проверяем выполнение входных условий
  Result = CheckObj(Obj)
  If Result = False Then
    Msgbox "У накладной должен быть указан ""Регистрационный №""."&chr(10)&"Действие отменено.", vbExclamation
    Exit Function
  End If

  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,"STATUS_INVOICE_SENDED")
  
  'Заполнение атрибутов накладной
  Obj.Attributes("ATTR_USER").Value = CurU
  Obj.Attributes("ATTR_USER_POSITION_STR").Value = CurU.Position
  Obj.Attributes("ATTR_INVOICE_SENT_DATE").Value = Date
  
  Main = True
  'Оповещение 
  Call SendMessage(Obj)
  Call SendOrder(Obj)
End Function

'Проверка условий
Function CheckObj(Obj)
  CheckObj = True
  If Obj.Attributes("ATTR_REG_NUMBER").Empty = True Then CheckObj = False
End Function

'==============================================================================
' Отправка оповещения об отправке накладной ГИПу и Куратору договора
'------------------------------------------------------------------------------
' o_:TDMSObject - накладная
'==============================================================================
Private Sub SendMessage(o_)
  CurUdescr = ThisApplication.CurrentUser.Description
  For Each r In o_.RolesByDef("ROLE_GIP")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1403, u, o_, Nothing, o_.Description, CurUdescr, Date
  Next
  For Each r In o_.RolesByDef("ROLE_CONTRACT_RESPONSIBLE")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1403, u, o_, Nothing, o_.Description, CurUdescr, Date
  Next  
End Sub

Private Sub SendOrder(Obj)
  Set uToUser = Obj.Attributes("ATTR_CHECKER").User
  If uToUser Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_CORR_REZOL_INF"
  txt = "Накладная отправлена: """ & Obj.Description & """"
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,""
  
  Set uToUser = Obj.Attributes("ATTR_SIGNER").User
  If uToUser Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_CORR_REZOL_INF"
  txt = "Накладная отправлена: """ & Obj.Description & """"
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,""
End Sub


