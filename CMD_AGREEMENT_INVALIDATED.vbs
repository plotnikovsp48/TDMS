' Команда - Аннулировать соглашение
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  
  'Запрос причины аннулирования
  result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину аннулирования соглашения:")
  If IsEmpty(result) Then
    Exit Sub 
  ElseIf trim(result) = "" Then
    msgbox "Невозможно аннулировать соглашение не указав причину." & vbNewLine & _
        "Пожалуйста, введите причину аннулирования.", vbCritical, "Не задана причина аннулирования!"
    Exit Sub
  End If 
  
  ThisApplication.Utility.WaitCursor = True
  
  'Создание рабочей версии
  Obj.Versions.Create ,Result
  
  'Маршрут
  StatusName = "STATUS_AGREEMENT_INVALIDATED"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  'Оповещение пользователей
  Call MessageSend(Obj,Result)
  
  ThisApplication.Utility.WaitCursor = False
  ThisScript.SysAdminModeOff
End Sub

Sub MessageSend(Obj,Result)
  Str = ""
  Call UserStackFill(Obj,"ROLE_SIGNER",str)
  
  If Str <> "" Then
    Arr = Split(Str,",")
    Count = UBound(Arr)
    If Count >=0 Then
      For i = 0 to Count
        If ThisApplication.Users.Has(Arr(i)) Then
          Set u = ThisApplication.Users(Arr(i))
          ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1525, u, Obj, Nothing, Obj.Description, Result, ThisApplication.CurrentUser.Description, Date
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

