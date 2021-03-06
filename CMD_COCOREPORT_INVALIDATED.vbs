' Команда - Аннулировать (Акт)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  'Запрос причины аннулирования
  result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину аннулирования акта:")
  If IsEmpty(result) Then
    Exit Sub 
  ElseIf trim(result) = "" Then
    msgbox "Невозможно аннулировать акт не указав причину." & vbNewLine & _
        "Пожалуйста, введите причину аннулирования.", vbCritical, "Не задана причина аннулирования!"
    Exit Sub
  End If  
  
  'Создание рабочей версии
  Obj.Versions.Create ,Result

  'Маршрут
  StatusName = "STATUS_COCOREPORT_INVALIDATED"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  'Оповещение 
  Call MessageSend(Obj)
  
  
  If Obj.Attributes.Has("ATTR_CCR_INCOMING") Then
    'Входящий - Истина
    If Obj.Attributes("ATTR_CCR_INCOMING").Value = True Then
    
      Set User =  ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetChiefByID","ID_CCR_RETURN_ORDER")
      Set CU = ThisApplication.CurrentUser
      resol = "NODE_4E1FB947_3927_4101_9C25_D52838C999F6"
      txt = "Прошу подготовить исходящее письмо о возврате акта"
      ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",User,CU,resol,txt,""
    'Входящий - Ложь
    Else
      
    End If
  End If
End Sub

Sub MessageSend(Obj)
  Str = ""
  Call UserStackFill(Obj,"ROLE_CONTRACT_RESPONSIBLE",str)
  
  If Str <> "" Then
    Arr = Split(Str,",")
    Count = UBound(Arr)
    If Count >=0 Then
      For i = 0 to Count
        If ThisApplication.Users.Has(Arr(i)) Then
          Set u = ThisApplication.Users(Arr(i))
          ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1532, u, Obj, Nothing, Obj.Description, Obj.VersionDescription, ThisApplication.CurrentUser.Description, Date
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
