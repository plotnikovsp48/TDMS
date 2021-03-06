' Команда - Подписать (Акт)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  ThisScript.SysAdminModeOn
  'Запрос
  Key = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion+vbYesNo, 1529,Obj.Description)
  If Key = vbNo Then
    Exit Function
  End If

  'Маршрут
  StatusName = "STATUS_COCOREPORT_SIGNED"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER","Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  ' Закрываем поручение для текущего пользователя и подписанта
  Call ThisApplication.ExecuteScript("CMD_KD_ORDER_LIB","clouseAllOrderByRes",Obj,"NODE_KD_SING")
'  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_KD_SING")
  
  'Оповещение 
'  Call MessageSend(Obj)
  
  ' Пытаемся перевести в состояние На оплате или Закрыт.
  Res = ThisApplication.ExecuteScript("CMD_CCR_TO_PAY","Main",Obj)
  
  ThisScript.SysAdminModeOff
  Main = True
End Function

Sub MessageSend(Obj)
  Str = ""
  'Куратор договора
  Set Contract = ThisApplication.ExecuteScript("CMD_S_NUMBERING","ObjectLinkGet",Obj,"ATTR_CONTRACT")
  Call UserStackFill(Contract,"ROLE_CONTRACT_RESPONSIBLE",str)
  
  'Бухгалтерия
  Set u =  ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetChiefByID","ID_CCR_SIGNER")
  If not u is Nothing Then
    If Str <> "" Then
      If InStr(Str,u.SysName) = 0 Then
        Str = Str & "," & u.SysName
      End If
    Else
      Str = u.SysName
    End If
  End If
  
  If Str <> "" Then
    Arr = Split(Str,",")
    Count = UBound(Arr)
    If Count >=0 Then
      For i = 0 to Count
        If ThisApplication.Users.Has(Arr(i)) Then
          Set u = ThisApplication.Users(Arr(i))
          ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1541, u, Obj, Nothing, Obj.Description, ThisApplication.CurrentUser.Description, Date
        End If
      Next
    End If
  End If
End Sub

'Процедура заполнения строки пользователей для уведомления
Private Sub UserStackFill(Obj,RoleName,str)
  If Obj is Nothing Then Exit Sub
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

' Заявка на оплату
function Create_Doc_by_Type(objType, docBase)
    ThisScript.SysAdminModeOn
    set Create_Doc_by_Type = nothing
    Set ObjRoots = GET_FOLDER("",objType) 
    if  ObjRoots is nothing then  
      msgBox "Не удалось создать папку", vbCritical, "Объект не был создан"
      exit function
    end if
    CreateObj = true
    ObjRoots.Permissions = SysAdminPermissions
    Set CreateDocObject = ObjRoots.Objects.Create(objType)
    if objType.SysName = "OBJECT_KD_DOC_OUT" and not docBase is nothing then 
      ' если ИД, то записываем ответ на
      call thisApplication.ExecuteScript("CMD_KD_COMMON_BUTTON_LIB","AddReplDoc",CreateDocObject, docBase) 
    end if
    call Set_Permission (CreateDocObject)
    ' CreateDocObject.Update   
    ' Инициализация свойств диалога создания объекта
    formName = thisApplication.ExecuteScript("OBJECT_KD_BASE_DOC", "GetCreateFroms", CreateDocObject)
    if formName <> "" then  call SetGlobalVarrible("ShowForm", formName)  
     Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
     CreateObjDlg.Object = CreateDocObject
     ans = CreateObjDlg.Show
    
     if CreateDocObject.StatusName = "STATUS_KD_DRAFT" then   
       If not ans then
          If CreateObj Then 
             CreateDocObject.Erase  ' EV все-таки подумать как удалять
             exit function
          end if   
       End if
     end if
  
     'Set_Permition CreateDocObject EV т.к. перенесли в изменение статуса
      set Create_Doc_by_Type = CreateDocObject
end function
