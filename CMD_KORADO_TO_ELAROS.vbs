' $Workfile: COMMAND.SCRIPT.CMD_KORADO_TO_ELAROS.scr $ 
' $Date: 10.10.08 15:57 $ 
' $Revision: 3 $ 
' $Author: Oreshkin $ 
'
' конвертирование данных из Корадо в Эларос
'------------------------------------------------------------------------------
' Авторское право © ЗАО «НАНОСОФТ», 2008 г.


' Перечень изменений
'------------------------------------------------------------------------------
' ДОКУМЕНТ
' 1. Владелец(Администратор ИО) получает роли: - 
'    "Назначить разработчика документа"
'    "Разработчик"
'                 и дополнительную роль в зависимости от статуса: 
'    "Документ в разработке" - Завершить разработку документа
'    "Документ разработан"   - Вернуть в разработку документ
' 2. Разработчики документов отличные от владельца получают роль 
'    "Соразработчик"
' 3. Администратором ИО становится пользователь "SYSADMIN"
' 4. Добавить атрибуты: 
'    "Примечание"
'    "Инвентарный номер"
'    "Утверждающий"
'    "Обозначение документа"
'    "Проект"
' 5. При наличие роли "Утверждающий", устанавливаем атрибут "Утверждающий"
'    !!!При наличие нескольких ролей ОСТАВИТ ОДНУ ПЕРВУЮ!!!


' ПАПКА
' 1. Владелец(Администратор ИО) получает роли: - 
'    "Назначить ответственного за папку" 
'    "Ведение структуры"
'    "Куратор"
' 2. Разработчики папки отличные от владельца получают роль 
'    "Соразработчик"
' 3. Администратором ИО становится пользователь "SYSADMIN"
' 4. Добавить атрибуты: 
'    "Примечание"
'    "Проект"
' 5. Папки присваивается статус
'    "Папка в разработке"

'Удаление команды "Назначить администратора" с типа ИО "Папка"

Sub Conv(osDocs_,osFolders_)
  Call ConvDocs(osDocs_)
  Call ConvFolders(osFolders_)
  ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1169
End Sub

Private Sub ConvDocs(osDocs_)
  Dim uAdm,r,a,o
  For Each o In osDocs_
    ' 1. Владелец(Администратор ИО) получает роли: - 
    '    "Назначить разработчика документа"
    '    "Разработчик"
    Set uAdm = o.Administrator
    ' Назначаем Администратору роль "Назначить разработчика документа"
    Set r = o.Roles.Create("ROLE_DOC_DEVELOPER_APPOINT",uAdm)
    r.Inheritable = False
    ' 2. Изменяем роль разработчика на роль соразработчика
    For Each r In o.RolesByDef("ROLE_DEVELOPER")
      ' Если разработчик является администратором
      If Not r.User Is Nothing Then
        If r.User.Handle <> uAdm.Handle Then
          r.RoleDef = ThisApplication.RoleDefs("ROLE_CO_AUTHOR")
        End If
      End If
    Next
    ' Назначаем Администратору роль "Разработчик"
    If Not o.RolesForUser(uAdm).Has("ROLE_DEVELOPER") Then
      Set r = o.Roles.Create("ROLE_DOC_DEVELOPER_APPOINT",uAdm)
      r.Inheritable = False   
    End If
    '    Назначаем Администратору дополнительную роль в зависимости от статуса: 
    '    "Документ в разработке" - Завершить разработку документа
    '    "Документ разработан"   - Вернуть в разработку документ
    If o.StatusName = "STATUS_DOCUMENT_CREATED" Then 
      Set r = o.Roles.Create("ROLE_DOC_DEVELOPED",uAdm)
      r.Inheritable = False   
    End If
    If o.StatusName = "STATUS_DOCUMENT_DEVELOPED" Then 
      Set r = o.Roles.Create("ROLE_DOC_BACK_TO_WORK",uAdm)
      r.Inheritable = False   
    End If
    ' 3. Администратором ИО становится пользователь "SYSADMIN"    
    o.Administrator = ThisApplication.Users("SYSADMIN")
    ' 4. Добавить атрибуты: 
    '    "Примечание"
    If Not o.Attributes.Has("ATTR_INF") Then
      Set a = o.Attributes.Create("ATTR_INF")
    End If
    '    "Инвентарный номер"
    If Not o.Attributes.Has("ATTR_NUM") Then
      Set a = o.Attributes.Create("ATTR_NUM")
    End If    
    '    "Утверждающий"
    If Not o.Attributes.Has("ATTR_DOCUMENT_CONF") Then
      Set a = o.Attributes.Create("ATTR_DOCUMENT_CONF")
    End If        
    '    "Обозначение документа"
    If Not o.Attributes.Has("ATTR_DOC_CODE") Then
      Set a = o.Attributes.Create("ATTR_DOC_CODE")
    End If      
    '    "Проект"   
    If Not o.Attributes.Has("ATTR_PROJECT") Then
      Set a = o.Attributes.Create("ATTR_PROJECT")
    End If    
    ' 5. При наличие роли "Утверждающий", устанавливаем атрибут "Утверждающий"
    '    !!!При наличие нескольких ролей ОСТАВИТ ОДНУ ПЕРВУЮ!!!
    If o.RolesByDef("ROLE_CONFIRMATORY").Count > 0 Then
      If Not o.RolesByDef("ROLE_CONFIRMATORY")(0).User Is Nothing Then
        o.Attributes("ATTR_DOCUMENT_CONF") = o.RolesByDef("ROLE_CONFIRMATORY")(0).User
      End If
    End If
  Next
End Sub

Private Sub ConvFolders(osFolders_)
  Dim uAdm,r,a,o
  For Each o In osFolders_
    ' 1. Владелец(Администратор ИО) получает роли: - 
    '    "Назначить ответственного за папку" 
    '    "Ведение структуры"
    '    "Куратор"    
    Set uAdm = o.Administrator
    ' Назначаем Администратору роль "Назначить ответственного за папку"
    Set r = o.Roles.Create("ROLE_FOLDER_DEVELOPER_APPOINT",uAdm)
    r.Inheritable = False
    ' Назначаем Администратору роль "Ведение структуры"
    Set r = o.Roles.Create("ROLE_STRUCT_DEVELOPER",uAdm)
    r.Inheritable = False   
    ' Назначаем Администратору роль "Куратор"
    Set r = o.Roles.Create("ROLE_RESPONSIBLE",uAdm)
    r.Inheritable = False   
    ' 2. Разработчики папки отличные от владельца получают роль 
    '    "Соразработчик"
    For Each r In o.RolesByDef("ROLE_DEVELOPER")
      ' Если разработчик является администратором
      If Not r.User Is Nothing Then
        If r.User.Handle <> uAdm.Handle Then
          r.RoleDef = ThisApplication.RoleDefs("ROLE_CO_AUTHOR")
        End If
      End If
    Next
    ' 3. Администратором ИО становится пользователь "SYSADMIN"
    o.Administrator = ThisApplication.Users("SYSADMIN")
    ' 4. Добавить атрибуты: 
    '    "Примечание"
    If Not o.Attributes.Has("ATTR_INF") Then
      Set a = o.Attributes.Create("ATTR_INF")
    End If
    '    "Проект"
    If Not o.Attributes.Has("ATTR_PROJECT") Then
      Set a = o.Attributes.Create("ATTR_PROJECT")
    End If    
    ' 5. Папки присваивается статус
    '    "Папка в разработке"
    o.Status = ThisApplication.Statuses("STATUS_FOLDER_IS_DEVELOPING")
  Next
End Sub

