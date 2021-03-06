' Команда - Отправить на подпись (Акт)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  ThisScript.SysAdminModeOn
  
  'Проверка состояния
  CheckAttr = False
  If Obj.Attributes.Has("ATTR_SIGNER") Then
    If Obj.Attributes("ATTR_SIGNER").Empty = False Then
      If not Obj.Attributes("ATTR_SIGNER").User Is Nothing Then CheckAttr = True
    End If
  End If
  If CheckAttr = False Then
    Msgbox "Заполните поле ""Подписант""", vbCritical
    Exit Function
  End If
  If Obj.Files.Count = 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbCritical, 1004
    Exit Function
  End If
  
  'Запрос подтверждения
  Key = Msgbox ("Отправить """ & Obj.Description & """ на подпись?",vbYesNo+vbQuestion)
  If Key = vbNo Then Exit Function
  Call Run(Obj)
  Main = True
End Function
  
Sub Run(Obj)
  ThisScript.SysAdminModeOn
  ThisApplication.Utility.WaitCursor = True
  
  'Маршрут
  StatusName = "STATUS_COCOREPORT_FOR_SIGNING"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  'Создание роли
  Set Roles = Obj.RolesByDef("ROLE_SIGNER")
  For Each Role in Roles
    Role.Erase
  Next
  Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,"ROLE_SIGNER",Obj.Attributes("ATTR_SIGNER").User)
  
  'Оповещение пользователей
  Call MessageSend(Obj)
  Call SendOrder(Obj)
  ThisApplication.Utility.WaitCursor = False
  ThisScript.SysAdminModeOff
End Sub

Sub SendOrder(Obj)

  Set uToUser = Obj.Attributes("ATTR_SIGNER").User
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_KD_SING"
  txt =  Obj.Description
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
          ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1536, u, Obj, Nothing, Obj.Description, ThisApplication.CurrentUser.Description, Date
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

