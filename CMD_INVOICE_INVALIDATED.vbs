' Команда - Аннулировать (Накладная)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  ThisScript.SysAdminModeOn

  'Запрос причины аннулирования
  result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину аннулирования накладной:")
  If IsEmpty(result) Then
    Exit Function 
  ElseIf trim(result) = "" Then
    msgbox "Невозможно аннулировать накладную не указав причину." & vbNewLine & _
        "Пожалуйста, введите причину аннулирования.", vbCritical, "Не задана причина аннулирования!"
    Exit Function
  End If  
  
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,"STATUS_INVOICE_INVALIDATED")
  'Оповещение 
  Set u = ThisApplication.Groups("GROUP_COMPL")
  CurU = ThisApplication.CurrentUser.Description
  ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1402, u, Obj, Nothing, Obj.Description, CurU, Date
  
    ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","RejectOrderByResol",Obj,"NODE_KD_CHECK")
  
  Call  SendOrder(Obj)

  Main = True
End Function

Sub SendOrder(Obj)
  Set uToUser = Obj.Attributes("ATTR_AUTOR").User
  If uToUser Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_CORR_REZOL_INF"
  txt = "Накладная """ & Obj.Description & """ аннулирована"
  planDate = ""
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,planDate
End Sub
