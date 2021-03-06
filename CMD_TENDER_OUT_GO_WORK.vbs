' Команда - Передать в работу
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call PurchaseGoWork(ThisObject,False)

Sub PurchaseGoWork(Obj,Result)
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  AttrStatus = False
  AttrName = "ATTR_TENDER_STATUS"
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      If not Obj.Attributes(AttrName).Classifier is Nothing Then
        If Obj.Attributes(AttrName).Classifier.Code = 2 Then AttrStatus = True
      End If
    End If
  End If
  
  Set u0 = Nothing 'Сотрудник Группы
  Set u1 = Nothing 'Ответственый за подготовку
  Set u2 = Nothing ' Руководитель ПЭО
  Set u3 = Nothing ' Куратор закупки
  Set u4 = Nothing ' Ответственный за КП/НКП
  Set User1 = Nothing
  Set User2 = Nothing
  
  StatusName = "STATUS_TENDER_OUT_IN_WORK"
  
   If Obj.Attributes.Has("ATTR_TENDER_CURATOR") Then
    If Obj.Attributes("ATTR_TENDER_CURATOR").Empty = False Then
      If not Obj.Attributes("ATTR_TENDER_CURATOR").User is Nothing Then
       Set u3 = Obj.Attributes("ATTR_TENDER_CURATOR").User
      End If
    End If
  End If
   If Obj.Attributes.Has("ATTR_TENDER_KP_DESI") Then
    If Obj.Attributes("ATTR_TENDER_KP_DESI").Empty = False Then
      If not Obj.Attributes("ATTR_TENDER_KP_DESI").User is Nothing Then
       Set u4 = Obj.Attributes("ATTR_TENDER_KP_DESI").User
      End If
    End If
  End If 
  
  'Проверка атрибутов
  Str = AttrsCheck(Obj,u0,u1,u2)
  If Str <> "" Then
    Msgbox "Обязательные атрибуты " & Str & " не заполнены", vbExclamation
    Exit Sub
  End If
  
    'Ввод даты
    Txt = "Введите до какой даты требуется подготовить документацию"
   Data = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","FormDataInter",ThisObject, Txt, "ATTR_TENDER_GET_OFFERS_STOP_TIME", "") 
   PlanDate = Data
   If PlanDate = "" then Exit Sub
'   If PlanDate = "" Then PlanDate = Date + 1
 
  
    'Если закупка "Поданная" В разработку НКП
  '--------------------------------------------------
  If AttrStatus = True Then  
  
      'Маршрут
    RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
    If RetVal = -1 Then
      Obj.Status = ThisApplication.Statuses(StatusName)
    End If
    
    'Создание ролей и поручений
    RoleName = "ROLE_TENDER_MATERIAL_RESP"
'   resol = "NODE_COR_STAT_MAIN"
'  resol = "NODE_CORR_REZOL_POD"
'  ObjType = "OBJECT_KD_ORDER_SYS"
       resol = "NODE_CORR_REZOL_POD"
       ObjType = "OBJECT_KD_ORDER_NOTICE"
    
'   Set User1 = u3
'   If User1 is Nothing Then 
'    Set User1 = u1
'    txt = "Прошу назначить ответственных за подготовки нового коммерческого предложения для заявки " & Obj.Description
'   Else
'   txt = "Прошу подготовить документацию для нового коммерческого предложения по заявке " & Obj.Description   
'   End if
     
'    If not User1 is Nothing Then
'     If User1.SysName <> CU.SysName Then
'     ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,User1,CU,resol,txt,PlanDate 'Создание поручения
'     End If
'     ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,User1,"ROLE_TENDER_MATERIAL_RESP,ROLE_INITIATOR" 'Роли    
'    End If 
    
'   Set User2 = u4
'    txt = "Прошу подготовить документацию для нового коммерческого предложения по заявке " & Obj.Description 
'   If User2 is Nothing Then 
    Set User2 = u2
    txt = "Прошу назначить ответственных и проконтролировать подготовку нового коммерческого предложения для заявки " & Obj.Description
'   End if

    If not User2 is Nothing Then
     If User2.SysName <> CU.SysName Then
     ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,User2,CU,resol,txt,PlanDate 'Создание поручения
     End If
     '        Msgbox "Пользователю """ & User.Description & """ выдано поручение",vbInformation
     ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,User2,"ROLE_TENDER_KP_DESI,ROLE_INITIATOR" 'Роли 
    End If 
  
'     Msgbox "Закупка передана пользователям """ & User1.Description & ", " & User2.Description & """ для разработки НКП",vbInformation
     Msgbox "Закупка передана пользователю """ & User2.Description & """ для разработки НКП",vbInformation
    Result = True    
  '------------------------------------------------------------------------------------------------------     
  'Если закупка "Не Поданная" В разработку КП
  '------------------------------------------------------------------------------------------------------
  Else
  Result = False
    'Проверка атрибутов, назначение ролей и отправка уведомлений
    Str = AttrsCheck(Obj,u0,u1,u2)
    RoleName = "ROLE_PURCHASE_RESPONSIBLE"
    If u1 is Nothing Then
      Msgbox "Обязательный атрибут ""Ответственный за подготовку закупочной документации"" не заполнен", vbExclamation
      Exit Sub
    End If
  
  '---------------------------------------------------
  'Перенесено из Передать в работу. Проброс команд
  '---------------------------------------------------
  Set CU = ThisApplication.CurrentUser
  Set User = Nothing
   'Выбор пользователя, если не задан
  AttrName = "ATTR_TENDER_RESP_OUPPKZ"
  If Obj.Attributes.Has(AttrName) Then
    Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName)
    If User is Nothing Then
      Set Dlg = ThisApplication.Dialogs.SelectUserDlg
      Dlg.Caption = "Выбор пользователя"
      If Dlg.Show Then
        If Dlg.Users.Count > 0 Then
          Set User = Dlg.Users(0)
          Obj.Attributes(AttrName).User = User
        End If
      End If
    End If
  End If
  If User is Nothing Then
    Msgbox "Пользователь не выбран. Действие отменено.", vbExclamation
    Exit Sub
  End If
  'Маршрут
  StatusName = "STATUS_TENDER_OUT_APPROVED"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  'Заполнение атрибута
  AttrName = "ATTR_TENDER_GLOBAL_STATUS"
  If Obj.Attributes.Has(AttrName) Then
    Obj.Attributes(AttrName).Classifier = ThisApplication.Classifiers.FindBySysId("NODE_MAIN_TENDER_CONSDITION_YES")
  End If
  'Создание роли
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,User,"ROLE_PURCHASE_RESPONSIBLE,ROLE_INITIATOR," 'Роли Сотруднику Группы
  'Создание поручения
'  resol = "NODE_CORR_REZOL_POD"
'  ObjType = "OBJECT_KD_ORDER_SYS"
       resol = "NODE_CORR_REZOL_POD"
       ObjType = "OBJECT_KD_ORDER_NOTICE"
  txt = "Прошу подготовить и визировать у генерального директора Распоряжение о подготовке заявки"
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,User,CU,resol,txt,PlanDate
 
  '------------------------------------------------------
  'Конец проброса
  '------------------------------------------------------
     
        'Маршрут
    StatusName = "STATUS_TENDER_OUT_IN_WORK"    
    RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
    If RetVal = -1 Then
      Obj.Status = ThisApplication.Statuses(StatusName)
    End If
    
      If not u3 is Nothing  Then
        Set uToUser = u3
       'Создание роли и поручения Куратору - Инициатор согласования и Отв. за материалы      
        ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,uToUser,"ROLE_TENDER_MATERIAL_RESP,ROLE_INITIATOR"
       'Создание поручения новому куратору
       Set uFromUser = ThisApplication.CurrentUser   
'      resol = "NODE_COR_STAT_MAIN"
'      ObjType = "OBJECT_KD_ORDER_SYS"
       resol = "NODE_CORR_REZOL_POD"
       ObjType = "OBJECT_KD_ORDER_NOTICE"

       txt = "Прошу обеспечить подготовку материалов для заявки " & Obj.Description & " в указанные сроки"
       PlanDate = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_TIME")
       If PlanDate = "" Then PlanDate = Date + 1
       If uToUser.SysName <> uFromUser.SysName Then
       ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,uToUser,uFromUser,resol,txt,PlanDate 
       End If
      End If
      
'       If not u4 is Nothing  Then
'        Set uToUser = u4
'       'Создание роли и поручения ответственному за КП/НКП - Инициатор согласования и Отв. за материалы      
'        ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,uToUser,"ROLE_TENDER_KP_DESI,ROLE_INITIATOR"
'       'Создание поручения новому куратору
'       Set uFromUser = ThisApplication.CurrentUser   
'       resol = "NODE_COR_STAT_MAIN"
'       ObjType = "OBJECT_KD_ORDER_NOTICE"
'       txt = "Прошу обеспечить подготовку материалов для заявки " & Obj.Description & " в указанные сроки"
'       PlanDate = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_TIME")
'       If PlanDate = "" Then PlanDate = Date + 1
'       If uToUser.SysName <> uFromUser.SysName Then
'       ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,uToUser,uFromUser,resol,txt,PlanDate 
'       End If
'      End If
     
     
    If not (u0 is Nothing and u1 is Nothing) Then
    
 '      'Создание поручения Сотруднику Группы 
'       resol = "NODE_COR_STAT_MAIN"
'       ObjType = "OBJECT_KD_ORDER_REP"
       resol = "NODE_CORR_REZOL_POD"
       ObjType = "OBJECT_KD_ORDER_NOTICE"


       txt = "Прошу проконтролировать подготовку материалов для заявки " & Obj.Description 
       If PlanDate = "" Then PlanDate = Date + 1
'        ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1512, u0, Obj, Nothing, ThisApplication.RoleDefs(RoleName).Description, Obj.Description, CU.Description, Date
'        Вы назначены на роль "%" на "%" Назначил: % Дата: %
       Set uToUser = u0
       Set uFromUser = ThisApplication.CurrentUser 
       ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,uToUser,"ROLE_PURCHASE_RESPONSIBLE,ROLE_INITIATOR," 'Роли Сотруднику Группы
       Check = false
        If u0.SysName <> CU.SysName Then
        ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,uToUser,uFromUser,resol,txt,PlanDate
        Check = true
        End If
      
   
'       ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1512, u1, Obj, Nothing, ThisApplication.RoleDefs(RoleName).Description, Obj.Description, CU.Description, Date

       'Создание поручения Ответственному за подготовку
       txt = "Прошу назначить ответственного и проконтролировать подготовку материалов для заявки " & Obj.Description 
       Set uToUser = u1
       Set uFromUser = ThisApplication.CurrentUser
       ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,uToUser,uFromUser,resol,txt,PlanDate
       ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,uToUser,"ROLE_TENDER_MATERIAL_RESP,ROLE_INITIATOR," 'Роли Ответственному за подготовку
       'Создание роли просмотр и поручения пользователям в списке
       txt = "Прошу ознакомиться """ & Obj.Description & """"
       ListUsers = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","OrderGenByList",ThisObject, "ATTR_TENDER_OUT_ORDER_TO_WORK_CASTOM", txt)
      'Создание роли и поручения Руководителю ПЭО
'      Set uToUser = u2
'      If not uToUser is Nothing Then
'      ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,uToUser,uFromUser,resol,txt,PlanDate
'      ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,uToUser,"ROLE_TENDER_KP_DESI,ROLE_INITIATOR" 'Роли Руководителю ПЭО
'      End If
'      
'      If Check = true then  Msgbox "Закупка """ & Obj.Description & """ передана в работу ползователям " & u0.Description & ", " & u1.Description ,vbInformation
'      If Check = false then  Msgbox "Закупка """ & Obj.Description & """ передана в работу ползователю " & u1.Description ,vbInformation
'     
      End If
       Msgbox "Закупка передана пользователям: " & chr(10) & chr(10) &" - " & U0.Description & chr(10)& chr(10) &" - " & U1.Description & chr(10) & chr(10) _
     & "для подготовки документации по заявке." & chr(10) & chr(10) & "Срок до " & chr(10) & PlanDate _
     & chr(10) & chr(10) & "Пользователям: " & ListUsers & " выдано поручение для ознакомления " ,vbInformation
  Result = True
  ThisScript.SysAdminModeOff
  End If
   
End Sub

'Проверка заполненности атрибутов
Function AttrsCheck(Obj,u0,u1,u2)
  AttrsCheck = ""
  Str = ""
  AttrName0 = "ATTR_TENDER_RESP_OUPPKZ"
  AttrName1 = "ATTR_TENDER_DOC_RESP"
  AttrName2 = "ATTR_TENDER_PEO_CHIF"
  
  Check = False
  If Obj.Attributes.Has(AttrName0) Then
    If Obj.Attributes(AttrName0).Empty = False Then
      If not Obj.Attributes(AttrName0).User is Nothing Then
        Check = True
        Set u0 = Obj.Attributes(AttrName0).User
      End If
    End If
  End If
  If Check = False Then
    If Str <> "" Then
      Str = Str & ", " & ThisApplication.AttributeDefs(AttrName0).Description
    Else
      Str = ThisApplication.AttributeDefs(AttrName0).Description
    End If
  End If
  
  Check = False
  If Obj.Attributes.Has(AttrName1) Then
    If Obj.Attributes(AttrName1).Empty = False Then
      If not Obj.Attributes(AttrName1).User is Nothing Then
        Check = True
        Set u1 = Obj.Attributes(AttrName1).User
      End If
    End If
  End If
  If Check = False Then
    If Str <> "" Then
      Str = Str & ", " & ThisApplication.AttributeDefs(AttrName1).Description
    Else
      Str = ThisApplication.AttributeDefs(AttrName1).Description
    End If
  End If
  
  Check = False
  If Obj.Attributes.Has(AttrName2) Then
    If Obj.Attributes(AttrName2).Empty = False Then
      If not Obj.Attributes(AttrName2).User is Nothing Then
        Check = True
        Set u2 = Obj.Attributes(AttrName2).User
      End If
    End If
  End If
  If Check = False Then
    If Str <> "" Then
      Str = Str & ", " & ThisApplication.AttributeDefs(AttrName2).Description
    Else
      Str = ThisApplication.AttributeDefs(AttrName2).Description
    End If
  End If
  
  If Str <> "" Then AttrsCheck = Str
End Function


