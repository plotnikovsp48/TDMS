' Команда - Вернуть на доработку
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.
USE "CMD_DLL_ROLES"

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  ThisScript.SysAdminModeOn
  
  if Obj.StatusName = "STATUS_KD_AGREEMENT" then ' если на согласовании прерываем согласование
    call thisApplication.ExecuteScript("CMD_KD_AGREEMENT_LIB","ReturnToWork",Obj)
    exit Function
  end if
  
  If Not IsAuthor(Obj,ThisApplication.CurrentUser) Then
    'Запрос причины
    result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину возврата договора:")
    If IsEmpty(result) Then
      Exit Function 
    ElseIf trim(result) = "" Then
      msgbox "Невозможно вернуть договор не указав причину." & vbNewLine & _
          "Пожалуйста, введите причину возврата.", vbCritical, "Не задана причина возврата!"
      Exit Function
    End If
  Else
    result = "Возвращен в разработку автором"
  End If
  
  ThisApplication.Utility.WaitCursor = True
  
  'Создание рабочей версии
  Obj.Versions.Create ,Result
  
  Call SendOrder(Obj)
  'Оповещение пользователей
  Call MessageSend(Obj)
  
  'Маршрут
  StatusName = "STATUS_CONTRACT_DRAFT"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_KD_SING")
  
  ThisApplication.Utility.WaitCursor = False
  ThisScript.SysAdminModeOff
  Main = True
End Function


Sub SendOrder(Obj)
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","SendOrder_NODE_KD_RETUN_USER",Obj)
End Sub

Sub MessageSend(Obj)
  Str = ""
  Call UserStackFill(Obj,"ROLE_CONTRACT_AUTOR",str)
  Call UserStackFill(Obj,"ROLE_CONTRACT_RESPONSIBLE",str)
  
  If Str <> "" Then
    Arr = Split(Str,",")
    Count = UBound(Arr)
    If Count >=0 Then
      For i = 0 to Count
        If ThisApplication.Users.Has(Arr(i)) Then
          Set u = ThisApplication.Users(Arr(i))
          ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1535, u, Obj, Nothing, Obj.Description, ThisApplication.CurrentUser.Description, Date
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

