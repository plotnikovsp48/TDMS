' Команда - Утвердить участие
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call PurchaseWorkApprove(ThisObject,False)

Sub PurchaseWorkApprove(Obj,Result)
'  ThisScript.SysAdminModeOn
'  Set CU = ThisApplication.CurrentUser
'  Set User = Nothing
'  

'     
'  'Выбор пользователя, если не задан
'  AttrName = "ATTR_TENDER_RESP_OUPPKZ"
'  If Obj.Attributes.Has(AttrName) Then
'    Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName)
'    If User is Nothing Then
'      Set Dlg = ThisApplication.Dialogs.SelectUserDlg
'      Dlg.Caption = "Выбор пользователя"
'      If Dlg.Show Then
'        If Dlg.Users.Count > 0 Then
'          Set User = Dlg.Users(0)
'          Obj.Attributes(AttrName).User = User
'        End If
'      End If
'    End If
'  End If
'  If User is Nothing Then
'    Msgbox "Пользователь не выбран. Действие отменено.", vbExclamation
'    Exit Sub
'  End If
'  



'  
'     'Если Специалист ОУППКЗ - текущий пользователь - запрос даты не нужен
''  Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,"ATTR_TENDER_RESP_OUPPKZ")
''  If not User is Nothing Then
''  If CU.SysName = User.SysName Then
''   ans = msgbox("Утвердить закупку?",vbQuestion+vbYesNo,"Закрытие закупки")
''   If ans <> vbYes Then exit Sub
''   End If 
''  If CU.SysName <> User.SysName Then
''    'Ввод даты
''    Txt = "Введите до какой даты необходимо исполнить"
''   Data = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","FormDataInter",ThisObject, Txt, "", date + 1) 
''   PlanDate = Data
''   If PlanDate = "" then Exit Sub

''  End If   
''  End If  
''  
''  If PlanDate = "" Then PlanDate = Date + 1
'  
'  
'  
'  
'  ThisApplication.Utility.WaitCursor = True
'  'Маршрут
'  StatusName = "STATUS_TENDER_OUT_APPROVED"
'  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
'  If RetVal = -1 Then
'    Obj.Status = ThisApplication.Statuses(StatusName)
'  End If
'  
'  'Заполнение атрибута
'  AttrName = "ATTR_TENDER_GLOBAL_STATUS"
'  If Obj.Attributes.Has(AttrName) Then
'    Obj.Attributes(AttrName).Classifier = ThisApplication.Classifiers.FindBySysId("NODE_MAIN_TENDER_CONSDITION_YES")
'  End If
'  
'  'Создание роли
'  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,User,"ROLE_PURCHASE_RESPONSIBLE,ROLE_INITIATOR," 'Роли Сотруднику Группы
''  RoleName = "ROLE_PURCHASE_RESPONSIBLE"
'    
'  'Создание поручения
'' resol = "NODE_COR_STAT_MAIN"
'  resol = "NODE_CORR_REZOL_POD"
'  ObjType = "OBJECT_KD_ORDER_SYS"
'  txt = "Прошу подготовить и визировать у генерального директора Распоряжение о подготовке заявки"
'  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,User,CU,resol,txt,PlanDate
''  If not User is Nothing Then
''   If User.SysName <> CU.SysName Then
''    Msgbox "Закупка передана пользователю """ & User.Description & """ для подготовки и подписания Распоряжения о подготовке заявки. Срок до " & PlanDate ,vbInformation
''   End If
''  End If
'  ThisApplication.Utility.WaitCursor = False
  Result = True
'  ThisScript.SysAdminModeOff
End Sub
