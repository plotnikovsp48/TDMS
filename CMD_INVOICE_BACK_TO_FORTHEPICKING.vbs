' Команда - Вернуть на комплектацию (Накладная)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  ThisScript.SysAdminModeOn
    'Запрос причины
    result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину возврата накладной:")
    If IsEmpty(result) Then
      Exit Function 
    ElseIf trim(result) = "" Then
      msgbox "Невозможно вернуть накладную не указав причину." & vbNewLine & _
          "Пожалуйста, введите причину возврата.", vbCritical, "Не задана причина возврата!"
      Exit Function
    End If    
  
  If Obj.StatusName = "STATUS_INVOICE_ONCHECK" Then
    resol = "NODE_KD_CHECK"
  ElseIf Obj.StatusName = "STATUS_INVOICE_ONSIGN" Then
    resol = "NODE_KD_SING"
  End If                       
  'Создание версии
  Obj.Versions.Create ,result
  'Изменение статуса
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,"STATUS_INVOICE_EDIT")
  'Оповещение 
  Set u = ThisApplication.Groups("GROUP_COMPL")
  CurU = ThisApplication.CurrentUser.Description
  ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1401, u, Obj, Nothing, Obj.Description, CurU, Obj.VersionDescription, Date
  
  
  ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","RejectOrderByResol",Obj,resol)
    
  Call  SendOrder(Obj)

  Main = True
End Function

Sub SendOrder(Obj)
  Set uToUser = Obj.Attributes("ATTR_AUTOR").User
  If uToUser Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_KD_RETUN_USER"
  txt = "Накладная """ & Obj.Description & """ возвращена на доработку"
  planDate = ""
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
End Sub

