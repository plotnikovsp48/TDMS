' Команда - Завершить (Документ закупки)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
'  Main = False
  ThisScript.SysAdminModeOn
  
  ' Проверка наличия файла
'  If StrComp(Obj.Attributes("ATTR_PURCHASE_DOC_TYPE").Value,"Информационная карта",vbTextCompare) <> 0 Then Exit Function 'If Not CheckDoc(Obj) and
  If StrComp(Obj.Attributes("ATTR_PURCHASE_DOC_TYPE").Value,"Информационная карта",vbTextCompare) = 0 Then
   If Obj.StatusName <> "STATUS_DOC_AGREED" Then
    Msgbox "Информационная карта может быть завершена только после согласования" & str,vbExclamation
    Exit Function
   End If
   If Obj.Parent.StatusName <> "STATUS_TENDER_IN_WORK" Then
    Msgbox " Информационная карта может быть завершена только в закупке в статусе Разработка документации " & str,vbExclamation
    Exit Function
   End If
   u0 = Obj.Parent.Attributes("ATTR_TENDER_ACC_CHIF")
' Подтверждение перевода закупки и выдачи поручения.* Закомментировано после упрознения закрытия карты кнопкой Закрыть  
'   ans = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, 6013, Obj.Parent.Attributes("ATTR_TENDER_ACC_CHIF")) ' Запрос подтверждения   
'  If ans = vbNo Then Exit Function
  
     If StrComp(Obj.Parent.Attributes("ATTR_TENDER_TIPE").Value, "Закупка товаров", vbTextCompare) = 0 Then ' Проверка атрибутов
      If Obj.Attributes("ATTR_TENDER_GUARANTEE_REQUIREMENTS").Empty = True Then
       Msgbox "Не заполнен обязательный атрибут «Требования к условиям и срокам гарантийного обслуживания» " & str,vbExclamation
  Obj.Update ' Открытие нужной вкладки для ввода не заполненного атрибута 
  Obj.Dictionary.Item("FormActive") = "FORM_TENDER_INF_LIST_CLIENT_REQUIREMENTS"
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = Obj
  Dlg.Show
       Exit Function
      End If
     End If
'     Передача цен в материалы ЕИС (табл.)
  AttrName1 = "ATTR_TENDER_INVITATION_PRICE_EIS" 
  AttrName = "ATTR_TENDER_ITEM_PRICE_MAX_VALUE"
  ThisApplication.ExecuteScript "CMD_DLL","AttrValueCopy", Obj.Attributes(AttrName), Obj.Attributes(AttrName1)
'Заполнение атрибута "Дата фактического предоставления материалов для подготовки закупочной документации"
        AttrName = "ATTR_TENDER_FACT_MATERIAL_TAKE_OFF_DATA"
      If Obj.Attributes.Has(AttrName) Then Obj.Attributes(AttrName).Value = Date
      If Obj.Parent.Attributes.Has(AttrName) Then Obj.Parent.Attributes(AttrName).Value = Date
'  Сохранение изменений документа Информационная карта
    ThisApplication.Dictionary(Obj.GUID).Item("ObjEdit") = False
    Obj.Update
'   Синхронизация с закупкой   
 AttrStr = "ATTR_TENDER_PRICE,ATTR_TENDER_NDS_PRICE," &_
      "ATTR_TENDER_FACT_MATERIAL_TAKE_OFF_DATA,ATTR_TENDER_ITEM_PRICE_MAX_VALUE," &_
      "ATTR_NDS_VALUE,ATTR_LOT_NDS_VALUE,ATTR_TENDER_START_WORK_DATA,ATTR_TENDER_INVOCE_PUBLIC_DATA," &_
      "ATTR_TENDER_ADVANCE_PLAN_PAY,ATTR_TENDER_ADDITIONAL_REQUIREMENTS,ATTR_TENDER_BID_REQUIREMENTS," &_
      "ATTR_TENDER_GUARANTEE_REQUIREMENTS,ATTR_TENDER_RF_CONF_REQUIREMENTS_DOC_LIST," &_
      "ATTR_TENDER_EXPERIENCE_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_PERSONAL_CONF_REQUIREMENTS_DOC_LIST," &_
      "ATTR_TENDER_RIG_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_ISO9001_REQUIREMENTS," &_
      "ATTR_TENDER_ADDITIONAL_INFORMATION,ATTR_TENDER_END_WORK_DATA,ATTR_TENDER_SUM_NDS,ATTR_TENDER_INVITATION_PRICE_EIS"    
      
      ThisApplication.ExecuteScript "CMD_DLL","AttrsSyncBetweenObjs", Obj, Obj.Parent, AttrStr
   
 ' Смена статуса документа
  StatusName = "STATUS_DOC_IS_END"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
 ' Смена статуса закупки     
   ThisApplication.ExecuteScript "CMD_TENDER_IN_GO_IS_APPROVING", "Main", Obj.Parent 
'    Obj.Parent.SaveChanges

   'Создание поручения Ответственному за постановку задачи в Группу руководителю (Главному бухгалтеру) * закоменчено после упрознения закрытия карты с кнопки
'  Set CU = ThisApplication.CurrentUser 
'  Data1 = Obj.Parent.Attributes("ATTR_TENDER_PRESENT_PLAN_DATA")
'  Set Objp = Obj.Parent
'  AttrName0 = "ATTR_TENDER_ACC_CHIF"
'   Set u0 = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Objp,AttrName0)
'   If PlanDate = "" Then PlanDate = Data1
'  resol = "NODE_COR_STAT_MAIN"
'  ObjType = "OBJECT_KD_ORDER_NOTICE"
'  txt = "Прошу поручить Группе управления закупками подготовку и размещение закупки в согласованные сроки"
' If not u0 is Nothing Then
'       ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Objp,ObjType,u0,CU,resol,txt,PlanDate
''         Msgbox "Закупка передана в Группу управления закупками. Главному бухгалтеру выдано поручение для постановки задачи о подготовке и объявления закупки до " & PlanDate,vbInformation," "
' Msgbox  ThisApplication.ExecuteScript("CMD_MESSAGE", "Message", 6016, Obj.Parent.Attributes("ATTR_TENDER_ACC_CHIF"), PlanDate) 
    
    
       'Создание поручения Руководителю группы от ответственного руководителя (бывшего главбуха) * добавлено после упрознения завершения Инф карты с кнопки 
  Set CU = ThisApplication.CurrentUser 
  Data1 = Obj.Parent.Attributes("ATTR_TENDER_PRESENT_PLAN_DATA")
  Set Objp = Obj.Parent
  AttrName0 = "ATTR_TENDER_ACC_CHIF"
  AttrName1 = "ATTR_TENDER_GROUP_CHIF"
   Set u0 = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Objp,AttrName0)
   Set u1 = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Objp,AttrName1)
   If PlanDate = "" Then PlanDate = Data1
  resol = "NODE_COR_STAT_MAIN"
  ObjType = "OBJECT_KD_ORDER_NOTICE"
  txt = "Прошу подготовить и разместить закупку """ & Obj.Parent.Description & """ в согласованные сроки"
 If not u0 is Nothing and not u1 is Nothing Then
       ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Objp,ObjType,u1,u0,resol,txt,PlanDate
'         Msgbox "Закупка передана в Группу управления закупками. Главному бухгалтеру выдано поручение для постановки задачи о подготовке и объявления закупки до " & PlanDate,vbInformation," "
' Msgbox  ThisApplication.ExecuteScript("CMD_MESSAGE", "Message", 6016, Obj.Parent.Attributes("ATTR_TENDER_ACC_CHIF"), PlanDate) 
    
    Main = True
   Exit Function
    End If
   End If
   
  'Маршрут обычного документа закупки
  If StrComp(Obj.Attributes("ATTR_PURCHASE_DOC_TYPE").Value,"Информационная карта",vbTextCompare) <> 0 Then
  ans = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, 6010, Obj.Description) ' Запрос подтверждения   
  If ans = vbNo Then Exit Function
   Msgbox "Документ завершен.",vbInformation
 End If
  StatusName = "STATUS_DOC_IS_END"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
          
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
 Main = True
  ThisScript.SysAdminModeOff
End Function

'==============================================================================
' Проверка наличия файла
'------------------------------------------------------------------------------
' Obj:TDMSObject - разработанное задание
' CheckDoc:Boolean - Результат проверки
'==============================================================================
Private Function CheckDoc(Obj)
  CheckDoc = False
  ' Проверка наличия файла
  If Obj.Files.count<=0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1004, Obj.ObjectDef.Description
    Exit Function
  End If  
  CheckDoc = True
End Function
