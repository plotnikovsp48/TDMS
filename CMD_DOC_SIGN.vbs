' Команда - Подписать Документ
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "CMD_PROJECT_DOCS_LIBRARY"

Call Run(ThisObject)

Function Run(Obj)
  Run = False
  If not Obj.Permissions.LockOwner then 
    If Obj.Permissions.Locked <> FALSE Then 
        msgbox "Невозможно подписать документ, т.к. " & Obj.Permissions.LockUser.Description & _
          " уже заблокировал документ.", vbCritical, "Подписание не возможно!"
        exit Function ' Объект кем-то заблокирован
     end if
'     ThisObject.Lock
  end if

  ThisScript.SysAdminModeOn
  Set User = Nothing
  Set CU = ThisApplication.CurrentUser
  
  'Проверка объекта
  If Obj.Status is Nothing Then Exit Function
  
  'Запрос комментария
  result = ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","GetComment","Комментарий:")
  If IsEmpty(result) Then 
    Exit Function 
  End If  
  'Заполнение комментария
  Set Row = Nothing
  Set Row = GetRowCheckList(Obj,"check",CU,Nothing,Nothing)
  If Row Is Nothing Then _
    Set Row = GetRowCheckList(Obj,"deptchief",CU,Nothing,Nothing)
  If not Row is Nothing Then
    Row.Attributes("ATTR_RESOLUTION").Classifier = _
      ThisApplication.Classifiers.FindBySysId("NODE_ACCEPT")
    Row.Attributes("ATTR_DATA").Value = Date
    Row.Attributes("ATTR_T_REJECT_REASON").Value = result
  End If
    
  ' Закрываем поручение
'  msgbox "Закрываю поручение"
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_KD_CHECK")
  
'  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrders",Obj,"NODE_KD_CHECK")
  
  'Определение следующего проверяющего
  Set Row = Nothing
  Set Row = GetRowCheckList(Obj,"check",Nothing,CU,Nothing)
  If Row Is Nothing Then _
    Set Row = GetRowCheckList(Obj,"deptchief",Nothing,CU,Nothing)
  If not Row is Nothing Then
    Set u = Row.Attributes("ATTR_USER").User
    'Изменение роли
    RoleName = "ROLE_DOC_CHECKER"
    Set Roles = Obj.RolesByDef(RoleName)
    For Each Role in Roles
      Role.User = u
    Next
    'Создание поручения
    resol = "NODE_KD_CHECK"
    ObjType = "OBJECT_KD_ORDER_SYS"
    txt = "документ """ & Obj.Description & """"
    planDate = DateAdd ("d", 1, Date) 'Date + 1
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,u,CU,resol,txt,PlanDate
    
    'Оповещение
    ThisApplication.ExecuteScript "CMD_MESSAGE","SendMessage",1118,u,Obj,Nothing,Obj.Description,CU.Description,Date
    
    Run = True
    Exit Function
  End If
  
  'Если нет больше проверяющих, то меняем статус
  'Изменение статуса
  StatusName = "STATUS_DOCUMENT_DEVELOPED"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  'Оповещение
  Call SendMessage(Obj,result)
  Call SendOrder(Obj)
  Run = True
End Function

Private Sub SendMessage(Obj,comment)
  Dim u
  If Obj.Attributes.Has("ATTR_RESPONSIBLE") Then
    If Obj.Attributes("ATTR_RESPONSIBLE").Empty = False Then
      Set  u = Obj.Attributes("ATTR_RESPONSIBLE").User
    End If
  ElseIf Obj.Attributes.Has("ATTR_AUTOR") Then
    If Obj.Attributes("ATTR_AUTOR").Empty = False Then
      Set  u = Obj.Attributes("ATTR_AUTOR").User
    End If
  End If
  
  If Not u Is Nothing Then 
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1212, u, Obj, Nothing, Obj.Description, Date
    Exit Sub
  End If
  
  For Each r In Obj.RolesByDef("ROLE_DOC_DEVELOPER")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1212, u, Obj, Nothing, Obj.Description, Date
  Next
End Sub

'==============================================================================
' Отправка поручение на доработку задания
' разработчику задания 
'------------------------------------------------------------------------------
' o_:TDMSObject - разработанное задание
'==============================================================================
Sub SendOrder(Obj)
  
  If Obj.Attributes.Has("ATTR_AUTOR") Then
    If Not Obj.Attributes("ATTR_AUTOR").Empty Then
      Set uToUser = Obj.Attributes("ATTR_AUTOR").User
      If uToUser Is Nothing Then Exit Sub
'      ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB", "CreateSystemOrder", _
'        Obj, "OBJECT_KD_ORDER_NOTICE", Obj.Attributes("ATTR_AUTOR").User, _
'        ThisApplication.CurrentUser, "NODE_CORR_REZOL_INF", result, ""
    End If
  ElseIf Obj.Attributes.Has("ATTR_RESPONSIBLE") Then
    If Not Obj.Attributes("ATTR_RESPONSIBLE").Empty Then
      Set uToUser = Obj.Attributes("ATTR_RESPONSIBLE").User
      If uToUser Is Nothing Then Exit Sub
    End If
  End If
  
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_CORR_REZOL_INF"
  txt = "Документ """ & Obj.Description & """ проверен "
  planDate = ""
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,planDate
End Sub
