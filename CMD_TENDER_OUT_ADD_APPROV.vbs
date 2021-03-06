' Команда - Одобрить (Внешняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call PurchaseAddApprove(ThisObject,False)

Sub PurchaseAddApprove(Obj,Result)
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  Set User = Nothing
  AttrStr = "ATTR_NAME,ATTR_TENDER_UNIQUE_NUM,ATTR_TENDER_FIRST_PRICE,ATTR_TENDER_ORGANIZER," &_
 "ATTR_TENDER_CLIENT,ATTR_TENDER_GET_OFFERS_STOP_TIME,ATTR_TENDER_SUMMARIZING_PLAN_TIME"
  str = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","AttrCheckAttr",, Obj, AttrStr)
   If str <> "" then Exit Sub
   
    'Выбор пользователя
  AttrName = "ATTR_TENDER_RESP_OUPPKZ"
  If Obj.Attributes.Has(AttrName) Then
    Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName)
    If User is Nothing Then
      Set Dlg = ThisApplication.Dialogs.SelectUserDlg
      Dlg.Caption = "Выбор пользователя"
      If Dlg.Show Then
        If Dlg.Users.Count > 0 Then
          Set User = Dlg.Users(0)
        End If
      End If
    End If
  End If
  If User is Nothing Then
    Msgbox "Пользователь не выбран. Действие отменено.", vbExclamation
    Exit Sub
  End If
   
     'Если Специалист ОУППКЗ - текущий пользователь - запрос даты не нужен
  Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,"ATTR_TENDER_RESP_OUPPKZ")
  If not User is Nothing Then
   If CU.SysName = User.SysName Then
   ans = msgbox("Одобрить закупку?",vbQuestion+vbYesNo,"Закрытие закупки")
   If ans <> vbYes Then exit Sub
   End If 
  If CU.SysName <> User.SysName Then
    'Ввод даты
       'Ввод даты
      
    Txt = "Введите до какой даты требуется произвести согласование"
   Data = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","FormDataInter",ThisObject, Txt, "ATTR_TENDER_GET_OFFERS_STOP_TIME", "") 
   PlanDate = Data
   If PlanDate = "" then Exit Sub
    
    
    
    
'  PlanDate = ""
'  FormName = "FORM_DATE_SELECT"
'  Set Form = ThisApplication.InputForms(FormName)
'  Set Dict = ThisApplication.Dictionary(FormName)
'  Dict.Item("description") = "Введите до какой даты требуется произвести согласование"
'  Dict.Item("Cel") = "No"
'    If Obj.Attributes.Has("ATTR_TENDER_GET_OFFERS_STOP_TIME") Then
'     If Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_TIME").Empty = False Then
'     Dict.Item("date") = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_TIME").value
'     End If   
'    End If
'    If Form.Show Then
'  Form.Attributes("ATTR_DATA") = Dict.Item("date")
'      If Dict.Exists("FORM_KEY_PRESSED") Then
'        If Dict.Exists("FORM_KEY_PRESSED") = True and Dict.Exists("date") Then 
'        Cel = Dict.Item("Cel")
'          PlanDate = Dict.Item("date")
'          Dict.RemoveAll
'      End If   
'      End If
'    End If
'  If Cel <> "Ок" Then Exit sub
  End If   
  End If  
  If PlanDate = "" Then PlanDate = Date + 1
  
 
  
  ThisApplication.Utility.WaitCursor = True
  
  'Маршрут
  StatusName = "STATUS_TENDER_OUT_ADD_APPROVED"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  'Создание роли
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,User,"ROLE_PURCHASE_RESPONSIBLE,ROLE_INITIATOR" 'Роли Сотруднику Группы
'  RoleNames = "ROLE_PURCHASE_RESPONSIBLE,ROLE_INITIATOR"
'  Set Roles = Obj.RolesForUser(User)
'  RlName = Split(RoleNames,",")
'    For i = 0 to Ubound(RlName)
'    if RlName(i) <> "" then 
'    RoleName = RlName(i)
'     If Roles.Has(RoleName) = False Then
'     Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,User)
'     End If
'     End If
'    next
   
  
  'Создание поручения. Если Одобряет Руководитель группы - поручение от него Сотруднику группы "Прошу провести согласование участия в закупке"
  'Если одобряет Сотрудник группы, или еще кто - поручение от него Руководителю группы "Закупка одобрена для согласования Участия"
  
  AttrName0 = "ATTR_TENDER_RESP_OUPPKZ"
  AttrName1 = "ATTR_TENDER_GROUP_CHIF"
  Set u0 = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName0)
  Set u1 = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName1)
  resol = "NODE_CORR_REZOL_POD"
  ObjType = "OBJECT_KD_ORDER_SYS"
  If not u0 is Nothing Then 
   If CU.SysName = u1.SysName Then
   txt = "Прошу обеспечить проведение согласования участия в закупке " & Obj.Description
   Set uToUser = u0
   Set uFromUser = u1
   elseif CU.SysName <> u1.SysName Then
   txt = "Закупка " & Obj.Description & chr(10)& chr(10) & " одобрена для согласования Участия " & "пользователем" & " - " & chr(10)& chr(10) & CU.Description 
   Set uToUser = u1
   Set  uFromUser = CU
   End If 
  End If 
  If not uToUser Is Nothing and not uFromUser Is Nothing Then 
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,uToUser,uFromUser,resol,txt,PlanDate
'    If uToUser.SysName <> CU.SysName Then
'      Msgbox "Пользователю """ & uToUser.Description & """ выдано поручение",vbInformation
'    End If
   End If  
  ThisApplication.Utility.WaitCursor = False
  Result = True
  ThisScript.SysAdminModeOff
End Sub
