' Команда - Отправить на подписание
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  ThisScript.SysAdminModeOn
  
  'Проверка состояния объекта
  Check = CheckObj(Obj)
  If Check = False Then
    Msgbox "Приложите файл соглашения",vbExclamation
    Exit Function
  End If
  
'  'Проверка состояния объекта
'  If Obj.Attributes.Has("ATTR_REG_NUMBER") Then
'    If Obj.Attributes("ATTR_REG_NUMBER").Empty Then
'      Msgbox "Соглашение должно быть зарегистрировано.", vbExclamation
'      Exit Function
'    End If
'  End If
  
  'Запрос
  Key = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion+vbYesNo, 1527,Obj.Description)
  If Key = vbNo Then
    Exit Function
  End If
  
  'Создание роли Подписант
  Set Roles = Obj.RolesByDef("ROLE_SIGNER")
  If Roles.Count = 0 and Obj.Attributes.Has("ATTR_SIGNER") Then
    If not Obj.Attributes("ATTR_SIGNER").User is Nothing Then
      Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,"ROLE_SIGNER",Obj.Attributes("ATTR_SIGNER").User)
    End If
  End If
  
  'Маршрут
  StatusName = "STATUS_AGREEMENT_FOR_SIGNING"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","Close_Return_order",Obj)
  
  'Оповещение пользователей
  Call MessageSend(Obj)
  Call SendOrder(Obj)
  
  ThisScript.SysAdminModeOff
  Main = True
End Function

Sub SendOrder(Obj)

  Set uToUser = Obj.Attributes("ATTR_SIGNER").User
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_KD_SING"
  txt = Obj.Description
  planDate = DateAdd ("d", 1, Date) 'Date + 1
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate

End Sub

Sub MessageSend(Obj)
  Str = ""
  Call UserStackFill(Obj,"ROLE_SIGNER",str)
  
  If Str <> "" Then
    Arr = Split(Str,",")
    Count = UBound(Arr)
    If Count >=0 Then
      For i = 0 to Count
        If ThisApplication.Users.Has(Arr(i)) Then
          Set u = ThisApplication.Users(Arr(i))
          ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1611, u, Obj, Nothing, Obj.Description, ThisApplication.CurrentUser.Description, Date
        End If
      Next
    End If
  End If
End Sub

'Процедура заполнения строки пользователей для уведомления
Sub UserStackFill(Obj,RoleName,str)
  Set Roles = Obj.RolesByDef(RoleName)
  For Each Role in Roles
    If not Role.User is Nothing Then
      Set User = Role.User
    Else
      Set User = Role.Group
    End If
    If Str <> "" Then
      If InStr(Str,User.SysName) = 0 Then
        Str = Str & "," & User.SysName
      End If
    Else
      Str = User.SysName
    End If
  Next
End Sub

Function CheckObj(Obj)
  CheckObj = False
  Check0 = False
  Check1 = False
  For Each File in Obj.Files
    If File.FileDefName = "FILE_CONTRACT" Then Check0 = True
    If File.FileDefName = "FILE_E-THE_ORIGINAL" Then Check1 = True
    Exit For
  Next
  If Check0 = True and Check1 = True Then CheckObj = True
End Function


