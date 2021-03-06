
' Команда - Приступить к выполнению (Этап)
'------------------------------------------------------------------------------
' Автор: Стромков С.А.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

USE "CMD_DLL_ROLES"

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  ' Проверка
  If Not CheckConditions(Obj) Then Exit Function
  
  ' Подтверждение
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, 1515, Obj.Description)    
  If result <> vbYes Then
    Exit Function
  End If  
  
  ' Основной блок
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,"STATUS_CONTRACT_STAGE_IN_WORK")
  Call UpdateAttrRole(Obj,"ATTR_RESPONSIBLE","ROLE_COORDINATOR_2")
  Call SendMessage(Obj) 
  Call SendOrder(Obj) 
  Main = True
End Function

' Проверка входных условий
Function CheckConditions (o_)
  CheckConditions = False
    ' Проверка назначения ответственного
    If o_.Attributes.Has("ATTR_RESPONSIBLE") Then
      If o_.Attributes("ATTR_RESPONSIBLE").Empty Then 
        Msgbox "Этап не может быть переведен в работу, т.к. не задан ответственный!", vbCritical, "Ошибка" 
        Exit Function
      End If
    End If
    ' Планируемые даты
    If o_.Attributes("ATTR_STARTDATE_PLAN").Empty Or o_.Attributes("ATTR_ENDDATE_PLAN").Empty Then
      Msgbox "Этап не может быть переведен в работу, т.к. не заданы планируемые даты!", vbCritical, "Ошибка" 
      Exit Function
    End If
    
    If o_.Attributes("ATTR_CONTRACT_STAGE_CLOSE_TYPE").Classifier Is Nothing Then
      msgbox "Этап не может быть переведен в работу, т.к. не заданы способ закрытия этапа!", vbCritical, "Ошибка" 
      Exit Function
    End If
'    ' Проверка состава работ
'    Set stJobs = o_.ReferencedBy
'    'Если коллекция пустая, закончить работу
'    If stJobs.Count=0 Then
'      MsgBox "Этап не может быть переведен в работу, т.к. нет работ, связанных с Этапом!", vbCritical, "Ошибка" 
'      Exit Function
'    End If
  CheckConditions = True
End Function

'==============================================================================
' Отправка оповещения о начале работ по этапу координатору
'------------------------------------------------------------------------------
' o_:TDMSObject - Этап
'==============================================================================
Private Sub SendMessage(o_)
  ' Начаты работы по "%" договора %. 
  ' Вы являетесь координатором этого Этапа. 
  ' Дата начала работ по этапу: %
  ' Сроки выполнения работ по этапу: %
  Set contract = o_.Attributes("ATTR_CONTRACT").Object
  strTime = "с " & o_.Attributes("ATTR_STARTDATE_PLAN") & " по " & o_.Attributes("ATTR_ENDDATE_PLAN")
  Dim u
  For Each r In o_.RolesByDef("ROLE_COORDINATOR_2")
    If Not r.User Is Nothing Then
      Set u = r.User
    End If
    If Not r.Group Is Nothing Then
      Set u = r.Group
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1514, u, o_, Nothing, o_.Description, contract.Description, ThisApplication.CurrentTime, strTime
  Next
End Sub

Sub SendOrder(Obj)
  Set uCurator = Obj.Attributes("ATTR_CURATOR").User
  If uCurator Is Nothing Then 
  Set oContr = Obj.Attributes("ATTR_CONTRACT").Object
  Set uCur = oContr.Attributes("ATTR_CURATOR").User
  If uCur Is Nothing Then Exit Sub
  Set uToUser = uSur
  End If
      
  Select Case Obj.Attributes("ATTR_CONTRACT_STAGE_CLOSE_TYPE").Classifier.Description
    Case "требуется заключение договора"
      ' Куратору
      If Not uCurator Is Nothing Then
        Set uFromUser = ThisApplication.CurrentUser
        Set uToUser = uCurator
        resol = "NODE_CORR_REZOL_INF"
        txt = "Через 30 дней истекает срок подготовки договора субподряда к этапу " & Obj.Description & " договора " & Obj.Attributes("ATTR_CONTRACT").Object.Description
        planDate = Obj.Attributes("ATTR_DATA") - 30
        ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,planDate
      End If

      ' Руководителю договорного отдела
      Set uToUser = Nothing
      Set oDept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetDeptByID","ID_CONTRACT_CREATE")

      If Not oDept Is Nothing Then
        If oDept.Attributes.Has("ATTR_CHIEF") Then
          Set uToUser = oDept.Attributes("ATTR_CHIEF").User
        End If
      End If
      
      If Not uToUser Is Nothing Then
        Set uFromUser = ThisApplication.CurrentUser
        resol = "NODE_CORR_REZOL_OFO"
        txt = "Через 30 дней истекает срок подготовки договора субподряда к этапу " & Obj.Description & " договора " & Obj.Attributes("ATTR_CONTRACT").Object.Description
        planDate = Obj.Attributes("ATTR_DATA") - 30
        ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,planDate
      End If
    Case "требуется проведение конкурентной закупки"
      ' Куратору
      If Not uCurator Is Nothing Then
        Set uFromUser = ThisApplication.CurrentUser
        Set uToUser = uCurator
        resol = "NODE_CORR_REZOL_INF"
        txt = "Через 180 дней истекает срок проведения конкурентной закупки по этапу " & Obj.Description & " договора " & Obj.Attributes("ATTR_CONTRACT").Object.Description
        planDate = Obj.Attributes("ATTR_DATA") - 180
        ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,planDate
      End If
    
      ' Руководителю группы подготовки и проведения закупочных проедур
      Set uToUser = Nothing
      Set oDept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetDeptByID","ID_TENDER_CREATE")

      If Not oDept Is Nothing Then
        If oDept.Attributes.Has("ATTR_CHIEF") Then
          Set uToUser = oDept.Attributes("ATTR_CHIEF").User
        End If
      End If
      If Not uToUser Is Nothing Then
        Set uFromUser = ThisApplication.CurrentUser
        resol = "NODE_CORR_REZOL_PKZ"
        txt = "Через 180 дней истекает срок проведения конкурентной закупки по этапу " & Obj.Description & " договора " & Obj.Attributes("ATTR_CONTRACT").Object.Description
        planDate = Obj.Attributes("ATTR_DATA") - 180
        ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_NOTICE",uToUser,uFromUser,resol,txt,planDate
      End If
  End Select
End Sub

