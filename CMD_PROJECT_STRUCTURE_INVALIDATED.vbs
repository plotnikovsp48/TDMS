' Команда - Аннулировать (Основной комплект, Том, Раздел, Подраздел)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  ThisScript.SysAdminModeOn
  
  'Проверка
  Check = ObjectsCheck(Obj)
  If Check = False Then
    Msgbox "Нельзя аннулировать " & Obj.Description & "! В составе есть редактируемые объекты!", vbCritical
  End If
  
    'Запрос причины аннулирования
    result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину аннулирования:")
    If IsEmpty(result) Then
      Exit Function 
    ElseIf trim(result) = "" Then
      msgbox "Невозможно аннулировать не указав причину." & vbNewLine & _
          "Пожалуйста, введите причину аннулирования.", vbCritical, "Не задана причина аннулирования!"
      Exit Function
    End If
  
  ThisApplication.Utility.WaitCursor = True
  
  'Создание рабочей версии
  Obj.Versions.Create ,Result
  
  'Аннулирование состава
  For Each Child in Obj.ContentAll
    If Child.ObjectDefName = "OBJECT_DOCUMENT" or Child.ObjectDefName = "OBJECT_DOC_DEV" or _
    Child.ObjectDefName = "OBJECT_DRAWING" Then
      If Child.StatusName <> "STATUS_DOCUMENT_INVALIDATED" Then
        StatusName = "STATUS_DOCUMENT_INVALIDATED"
        RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Child,Child.Status,Child,StatusName)
        If RetVal = -1 Then
          Child.Status = ThisApplication.Statuses(StatusName)
        End If
        Call MessageSend(Child)
      End If
    ElseIf Child.ObjectDefName = "OBJECT_PROJECT_SECTION_SUBSECTION" or Child.ObjectDefName = "OBJECT_VOLUME" Then
      If Child.StatusName <> "STATUS_S_INVALIDATED" Then
        StatusName = "STATUS_S_INVALIDATED"
        RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Child,Child.Status,Child,StatusName)
        If RetVal = -1 Then
          Child.Status = ThisApplication.Statuses(StatusName)
        End If
        Call MessageSend(Child)
      End If
    End If
  Next
  
  Call Run(Obj)
  
  Call MessageSend(Obj)
  
  'Заполнение атрибута
  'If Obj.Attributes.Has("ATTR_CONTRACT_CLOSE_TYPE") Then
  '  Obj.Attributes("ATTR_CONTRACT_CLOSE_TYPE").Classifier = _
  '    ThisApplication.Classifiers.Find("NODE_CONTRACT_CLOSE_INVALIDATED")
  'End If
  
  ThisApplication.Utility.WaitCursor = False
  ThisScript.SysAdminModeOff
  Main = True
End Function

Sub Run(Obj)
'Маршрут
  StatusName = "STATUS_S_INVALIDATED"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
End Sub

'Функция проверки
Function ObjectsCheck(Obj)
  ObjectsCheck = True
  If Obj.Permissions.Locked = True Then
    ObjectsCheck = False
    Exit Function
  Else
    For Each Child in Obj.ContentAll
      If Child.Permissions.Locked = True Then
        ObjectsCheck = False
        Exit Function
      End If
    Next
  End If
End Function

Sub MessageSend(Obj)
  Str = ""
  If Obj.ObjectDefName = "OBJECT_DOC_DEV" or Obj.ObjectDefName = "OBJECT_DRAWING" Then
    Call UserStackFill(Obj,"ROLE_DOC_DEVELOPER",str)
  ElseIf Obj.ObjectDefName = "OBJECT_DOCUMENT" Then
    Call UserStackFill(Obj,"ROLE_DEVELOPER",str)
  ElseIf Obj.ObjectDefName = "OBJECT_WORK_DOCS_SET" or Obj.ObjectDefName = "OBJECT_PROJECT_SECTION" or _
  Obj.ObjectDefName = "OBJECT_PROJECT_SECTION_SUBSECTION" Then
    Call UserStackFill(Obj,"ROLE_LEAD_DEVELOPER",str)
  ElseIf Obj.ObjectDefName = "OBJECT_VOLUME" Then
    Call UserStackFill(Obj,"ROLE_VOLUME_COMPOSER",str)
  End If
  
  If Str <> "" Then
    Arr = Split(Str,",")
    Count = UBound(Arr)
    If Count >=0 Then
      For i = 0 to Count
        If ThisApplication.Users.Has(Arr(i)) Then
          Set u = ThisApplication.Users(Arr(i))
          ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1532, u, Obj, Nothing, Obj.Description, _
              Obj.VersionDescription, ThisApplication.CurrentUser.Description, Date
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

