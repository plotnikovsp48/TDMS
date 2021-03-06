' Команда - Вернуть на доработку (Соглашение)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  ThisScript.SysAdminModeOn
  
   
  'Запрос причины
    result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину возврата соглашения:")
    If IsEmpty(result) Then
      Exit Function 
    ElseIf trim(result) = "" Then
      msgbox "Невозможно вернуть соглашение не указав причину." & vbNewLine & _
          "Пожалуйста, введите причину возврата.", vbCritical, "Не задана причина возврата!"
      Exit Function
    End If
      
  ThisApplication.Utility.WaitCursor = True
  
  'Создание рабочей версии
  Obj.Versions.Create ,Result
  
  'Маршрут
  StatusName = "STATUS_AGREEMENT_EDIT"'"STATUS_AGREEMENT_DRAFT"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_KD_SING")
  
  'Оповещение пользователей
  Call MessageSend(Obj,Result)
  
  ThisApplication.Utility.WaitCursor = False
  ThisScript.SysAdminModeOff
  Main = True
End Function

Sub MessageSend(Obj,Result)
  Str = ""
  Call UserStackFill(Obj,"ROLE_AGREEMENT_AUTHOR",str)
  
  If Str <> "" Then
    Arr = Split(Str,",")
    Count = UBound(Arr)
    If Count >=0 Then
      For i = 0 to Count
        If ThisApplication.Users.Has(Arr(i)) Then
          Set u = ThisApplication.Users(Arr(i))
          ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1526, u, Obj, Nothing, Obj.Description, ThisApplication.CurrentUser.Description, Result, Date
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

