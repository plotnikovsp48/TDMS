' Команда - Вернуть на доработку (Акт)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  ThisScript.SysAdminModeOn
  
  'Запрос причины
    result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину возврата акта:")
    If IsEmpty(result) Then
      Exit Function 
    ElseIf trim(result) = "" Then
      msgbox "Невозможно вернуть акт не указав причину." & vbNewLine & _
          "Пожалуйста, введите причину возврата.", vbCritical, "Не задана причина возврата!"
      Exit Function
    End If
  
  ThisApplication.Utility.WaitCursor = True
  
  'Создание рабочей версии
  Obj.Versions.Create ,Result
  
  If Obj.StatusName = "STATUS_COCOREPORT_CHECK" Then
    resol = "NODE_KD_CHECK"
  ElseIf Obj.StatusName = "STATUS_COCOREPORT_FOR_SIGNING" Then
    resol = "NODE_KD_SING"
  End If    
  
  'Маршрут
  StatusName = "STATUS_COCOREPORT_EDIT"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,resol)
  
  'Оповещение пользователей
  Call MessageSend(Obj)
  Call SendOrder(Obj)
  
  ThisApplication.Utility.WaitCursor = False
  ThisScript.SysAdminModeOff
  Main = True
End Function

'==============================================================================
' Отправка поручение на доработку задания
' разработчику задания 
'------------------------------------------------------------------------------
' o_:TDMSObject - разработанное задание
'==============================================================================
Sub SendOrder(Obj)
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","SendOrder_NODE_KD_RETUN_USER",Obj)
'  Set uToUser = Obj.Attributes("ATTR_AUTOR").User
'  If uToUser Is Nothing Then Exit Sub
'  Set uFromUser = ThisApplication.CurrentUser
'  resol = "NODE_KD_RETUN_USER"
'  txt = "акт """ & Obj.Description & """ Причина: " & Obj.VersionDescription
'  planDate = DateAdd ("d", 1, Date) 'Date + 1
'  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
End Sub


Sub MessageSend(Obj)
  Str = ""
  Call UserStackFill(Obj,"ROLE_AUTHOR",str)
  
  If Str <> "" Then
    Arr = Split(Str,",")
    Count = UBound(Arr)
    If Count >=0 Then
      For i = 0 to Count
        If ThisApplication.Users.Has(Arr(i)) Then
          Set u = ThisApplication.Users(Arr(i))
          ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1538, u, Obj, Nothing, Obj.Description, ThisApplication.CurrentUser.Description, Obj.VersionDescription, Date
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

