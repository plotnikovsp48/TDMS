' Команда - Утвердить размещение на площадке (Внутренняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Function Main(Form,Obj)
  ThisScript.SysAdminModeOn
 Set CU = ThisApplication.CurrentUser 
  
  ' Проверка атрибутов
   Attr = "ATTR_TENDER_INVITATION_PRICE_EIS,ATTR_TENDER_INVITATION_DATA_EIS,ATTR_TENDER_GROUP_CHIF" '&_
 '"ATTR_TENDER_CONCURENT_NUM_EIS,ATTR_TENDER_NUM_EIS," 
  Check = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","AttrCheckAttr",Form, Obj, Attr)
'  Msgbox " " & Check,vbExclamation
  If Check <> "" then
   ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","MainControlsBackColorAlarm",Form, Obj, Check
   Check = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","AttrCheckAttr",Form, Obj, Attr, True)
   ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","AttrControlsBackColorOff",Form, Obj, Check
  Exit Function
   End If
 
   'Выбор пользователя
  AttrName = "ATTR_TENDER_RESPONSIBLE_EIS"
  If Obj.Attributes.Has(AttrName) Then
    Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName)
    If User is Nothing Then
      Set Dlg = ThisApplication.Dialogs.SelectUserDlg
      Dlg.Caption = "Выберите пользователя, ответственного за подготовку и размещение закупки"
      If Dlg.Show Then
        If Dlg.Users.Count > 0 Then
          Set User = Dlg.Users(0)
       Obj.Attributes(AttrName) = User
        End If
      End If
    End If
  End If
  If User is Nothing Then
    Msgbox "Пользователь не выбран. Действие отменено.", vbExclamation
    Exit Function
  End If
  
   AttrName = "ATTR_TENDER_RESPONSIBLE_EIS"
  Set u0 = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName)
  If CU.SysName <> u0.SysName Then
  Result = ThisApplication.ExecuteScript("CMD_MESSAGE","ShowWarning",vbQuestion+VbYesNo, 6011,u0.Description,Obj.Description)
  If Result = vbNo Then Exit Function
  else
  Result = Msgbox("Вы указали себя ответственным за подготовку и размещение закупки. Вы действительно хотите взять закупку в работу?",vbYesNo+vbQuestion)
  If Result = vbNo Then Exit Function
  End If
  ThisApplication.Utility.WaitCursor = True
  
    'Маршрут
  StatusName = "STATUS_TENDER_IN_APPROVED"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
   End If

'Заполнение атрибута
  AttrName = "ATTR_TENDER_STATUS_EIS"
  If Obj.Attributes.Has(AttrName) Then
    Obj.Attributes(AttrName).Classifier = ThisApplication.Classifiers.FindBySysId("NODE_39BDAAE0_2286_4154_96DE_E31241D7434F")
  End If
  
  'Создание поручения
   
  AttrName0 = "ATTR_TENDER_GROUP_CHIF"
  AttrName1 = "ATTR_TENDER_RESPONSIBLE_EIS"
  Data1 = Obj.Attributes("ATTR_TENDER_INVITATION_DATA_EIS")
  Set u0 = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName0)
  Set u1 = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName1)
  If PlanDate = "" Then PlanDate = Data1
  resol = "NODE_COR_STAT_MAIN"
  ObjType = "OBJECT_KD_ORDER_NOTICE"
  txt = "Прошу подготовить и разместить закупку в указанные сроки"
  If not u0 is Nothing Then
   If CU.SysName <> u1.SysName Then
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,u1,CU,resol,txt,PlanDate
         Msgbox "Закупка передана исполнителю """ & u1.Description & """ для подготовки к публикации. Выдано поручение.",vbInformation
    End If
  End If
  If CU.SysName = u1.SysName Then
         Msgbox "Закупка взята вами для подготовки к публикации.",vbInformation
    End If
  main = true
   ThisApplication.Utility.WaitCursor = False
  Result = True
  ThisScript.SysAdminModeOff
  
End Function
