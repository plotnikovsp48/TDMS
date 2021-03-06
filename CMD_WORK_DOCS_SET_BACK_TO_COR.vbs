' Автор: Стромков С.А.
'
' Возврат Основного комплекта на доработку с нормоконтроля или утверждения 
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
    
    'Запрос причины
    result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Укажите причину возврата комплекта:")
    If IsEmpty(result) Then
      Exit Function 
    ElseIf trim(result) = "" Then
      msgbox "Невозможно вернуть комплект не указав причину." & vbNewLine & _
          "Пожалуйста, введите причину возврата.", vbCritical, "Не задана причина возврата!"
      Exit Function
    End If
                       
  ' Создание рабочей версии
  Obj.Versions.Create ,result
  
  'Формирование словаря пользователей для оповещения
  Set Dict = ThisObject.Dictionary
  Set cu = ThisApplication.CurrentUser   '  Пользователь, выполняющий команду
  Set curs = o.RolesForUser (cu) '  Коллекция ролей объекта, в которые входит текущий пользователь
  'ГИП - Комплект на утверждении - Ответственный проектировщик
  If curs.Has("ROLE_GIP") = True and Obj.StatusName = "STATUS_WORK_DOCS_SET_IS_APPROVING" Then
    Call AddUser(Obj,Dict,"ROLE_LEAD_DEVELOPER")
  End If
  'Комплект прошел нормоконтроль - Комплект взят на нормоконтроль - Ответственный проектировщик
  If curs.Has("ROLE_WORK_DOCS_SET_PASS_NK") = True and Obj.StatusName = "STATUS_WORK_DOCS_SET_IS_TAKEN_NK" Then
    Call AddUser(Obj,Dict,"ROLE_LEAD_DEVELOPER")
  End If
  'Ответственный проектировщик - любой статус - ГИП,Комплект прошел нормоконтроль
  If curs.Has("ROLE_LEAD_DEVELOPER") = True Then
    Call AddUser(Obj,Dict,"ROLE_GIP")
    Call AddUser(Obj,Dict,"ROLE_WORK_DOCS_SET_PASS_NK")
  End If

  Res = Run(Obj)
  Main = True
    
  ' Изменение статуса прилагаемых документов  
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOCUMENT")
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOC_IS_FIXED",oDoc,"STATUS_DOCUMENT_CREATED") 
  Next
  
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DOC_DEV")
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOCUMENT_FIXED",oDoc,"STATUS_DOCUMENT_CREATED")  
  Next
  
  For Each oDoc In Obj.Objects.ObjectsByDef("OBJECT_DRAWING")
    Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",oDoc,"STATUS_DOCUMENT_FIXED",oDoc,"STATUS_DOCUMENT_CREATED") 
  Next
  
  ' рассылка оповещения ответственным
  Call SendMessages (Obj, Dict)

  If Res Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1130, Obj.Description
  End If
End Function

Function Run(Obj)
  Run = False
  Dim NextStatus
  NextStatus ="STATUS_WORK_DOCS_SET_IS_DEVELOPING"
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,NextStatus)   
  Run = True  
End Function

'==============================================================================
' Определяет кому отправлять сообщения
'------------------------------------------------------------------------------
' Obj:TDMSObject - возвращенный комплект
'==============================================================================
Private Sub SendMessages(Obj,Dict)
  Set cu = ThisApplication.CurrentUser
  itemArray = Dict.Items
  For Each El In itemArray
    Set u = SetU(El)
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1130, u, Obj, Nothing, Obj.Description, cu.Description, ThisApplication.CurrentTime, Obj.VersionDescription
  Next
End Sub

'Процедура добавляет в коллекцию пользователя
Sub AddUser(Obj,Dict,Role0)
  Set Roles = Obj.RolesByDef(Role0)
  For Each Role in Roles
    If not Role.User is Nothing Then
      If Dict.Exists(Role.User.SysName) = False Then
        Dict.Item(Role.User.SysName) = Role.User.SysName
      End If
    Else
      If Dict.Exists(Role.Group.SysName) = False Then
        Dict.Item(Role.Group.SysName) = Role.Group.SysName
      End If
    End If
  Next
End Sub

Function SetU(UG)
  Set SetU = Nothing
  If ThisApplication.Groups.Has(UG) Then
    Set SetU = ThisApplication.Groups(UG)
  ElseIf ThisApplication.Users.Has(UG) Then
    Set SetU = ThisApplication.Users(UG)
  End If
End Function

'==============================================================================
' Отправка оповещения ответственному о возвращении комплекта на доработку
'------------------------------------------------------------------------------
' Obj:TDMSObject - возвращенный комплект
'==============================================================================
'Private Sub SendMessageToRole(Obj,str_,r_)
'  Dim u
'  For Each r In Obj.RolesByDef(r_)
'    If Not r.User Is Nothing Then
'      Set u = r.User
'    End If
'    If Not r.Group Is Nothing Then
'      Set u = r.Group
'    End If
'        
'    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1130, u, Obj, Nothing, Obj.Description, cu.Description, ThisApplication.CurrentTime, str_
'  Next
'End Sub

'==============================================================================
' Отправка оповещения ответственному о возвращении комплекта на доработку
'------------------------------------------------------------------------------
' Obj:TDMSObject - возвращенный комплект
'==============================================================================
'Private Sub SendMessageToOldRole(ors_,str_,r_)
'  Dim u
'  For Each r In ors_
'  msgbox r.RoleDefName
'    If r.RoleDefName=r_ Then
'      If Not r.User Is Nothing Then
'        Set u = r.User
'      End If
'      If Not r.Group Is Nothing Then
'        Set u = r.Group
'      End If
'          
'      ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1130, u, Obj, Nothing, Obj.Description, cu.Description, ThisApplication.CurrentTime, str_
'    End If
'  Next
'End Sub

' Проверяет есть ли у указанного пользователя искомая роль в коллекции
' cr_: TDMSRoles - коллекция ролей
' u_: TDMSUser - Пользователь
' r_: TDMSRole - роль
'Function CheckUserRole(cr_,u_,r_)
'  CheckUserRole = False
'  'Set urs = Obj.RolesForUser (u_)
''  If Not urs.Has (r_) Then Exit Function
'  If Not cr_.Has (r_) Then Exit Function
'  CheckUserRole = True
'End Function

'==============================================================================
' Определяет кому отправлять сообщения
'------------------------------------------------------------------------------
' Obj:TDMSObject - возвращенный комплект
'==============================================================================
'Private Sub SendMessages(Obj,str_)
'  Dim u
'    
'  If CheckUserRole(curs,cu,"ROLE_GIP") And Not CheckUserRole(curs,cu,"ROLE_LEAD_DEVELOPER") Then 
'    Call SendMessageToRole(Obj,str_,"ROLE_LEAD_DEVELOPER")
'    Exit Sub
'  End If
'  
'  If CheckUserRole(curs,cu,"ROLE_WORK_DOCS_SET_PASS_NK") And Not CheckUserRole(curs,cu,"ROLE_LEAD_DEVELOPER") Then 
'    Call SendMessageToRole(Obj,str_,"ROLE_LEAD_DEVELOPER")
'    Exit Sub
'  End If
'  
'  If CheckUserRole(curs,cu,"ROLE_LEAD_DEVELOPER") And Not CheckUserRole(curs,cu,"ROLE_GIP") And csID="STATUS_WORK_DOCS_SET_IS_APPROVING" Then 
'    Call SendMessageToRole(Obj,str_,"ROLE_GIP")
'    'Exit Sub
'  End If
'  
'  If CheckUserRole(curs,cu,"ROLE_LEAD_DEVELOPER") And Not CheckUserRole(curs,cu,"ROLE_WORK_DOCS_SET_PASS_NK") Then 
'    Call SendMessageToOldRole(ors,str_,"ROLE_WORK_DOCS_SET_PASS_NK")
'    'Exit Sub
'  End If
'End Sub
