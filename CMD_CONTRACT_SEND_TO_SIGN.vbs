' Команда - Отправить на подписание (Договор)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  ThisScript.SysAdminModeOn
  'Проверка состояния
  str = CheckObj(Obj)
  If str <> "" Then
    Msgbox "Не заполнен обязательный атрибут """ & str & """",vbExclamation
    Exit Function
  End If
  
  'Маршрут
  StatusName = "STATUS_CONTRACT_FOR_SIGNING"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  'Оповещение пользователей
  Call SendMessage (Obj)
  Call SendOrder(Obj)
  
  ThisScript.SysAdminModeOff
  Main = True
End Function

' Отправка поручения подписанту
Sub SendOrder(Obj)
  List = "ATTR_SIGNER"
  
  arr = Split(List,",")
  
  For each ar In arr
    If Obj.Attributes.Has(ar) Then
      Set uToUser = Obj.Attributes(ar).User
      If Not uToUser Is Nothing Then
        Set uFromUser = ThisApplication.CurrentUser
        resol = "NODE_KD_SING"
        txt = Obj.Description
        planDate = DateAdd ("d", 1, Date) 'Date + 1
        ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
      End If
    End If
  Next
End Sub

'==============================================================================
' Отправка оповещения ответственному о возврате тома утверждающим
'------------------------------------------------------------------------------
' o_:TDMSObject - завизированный комплект
'==============================================================================
Private Sub SendMessage(Obj)
  Dim u
  'Оповещение пользователя
  Set u = Obj.Attributes("ATTR_SIGNER").User
  If u Is Nothing Then Exit Sub
  ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1611, u, Obj, Nothing, Obj.Description, ThisApplication.CurrentUser.Description,ThisApplication.CurrentTime
End Sub


'Функция проверки состояния договора
Function CheckObj(Obj)
  CheckObj = ""
'  'Зарегистрирован
'  If Obj.Attributes("ATTR_REGISTERED").Value = False Then
'    CheckObj = "Зарегистрирован"
'    Exit Function
'  End If
'  'Регистрационный номер
'  If Obj.Attributes("ATTR_REG_NUMBER").Empty = True Then
'    CheckObj = "Регистрационный номер"
'    Exit Function
'  End If
'  'Дата регистрации
'  If Obj.Attributes("ATTR_DATA").Empty = True Then
'    CheckObj = "Дата регистрации"
'    Exit Function
'  End If
'  'Зарегистрировал
'  If Obj.Attributes("ATTR_REG").Empty = True Then
'    CheckObj = "Зарегистрировал"
'    Exit Function
'  End If
  'Подписант
  If Obj.Attributes("ATTR_SIGNER").Empty = True Then
    CheckObj = "Подписант"
    Exit Function
  End If
End Function
