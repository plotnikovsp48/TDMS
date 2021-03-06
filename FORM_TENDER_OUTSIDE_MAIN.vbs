' Форма ввода - Основное (Внешняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

USE "OBJECT_PURCHASE_OUTSIDE"
USE "CMD_KD_ORDER_LIB"
USE "CMD_DLL_COMMON_BUTTON"
use "CMD_KD_COMMON_LIB"

USE "CMD_TENDER_OUT_ADD_APPROV"
USE "CMD_TENDER_OUT_GO_WORK_APPROVE"
USE "CMD_TENDER_OUT_GO_WORK"
USE "CMD_TENDER_OUT_UPLOAD"
USE "CMD_TENDER_OUT_CLOSE"

Sub Form_BeforeShow(Form, Obj)
 Call ThisApplication.ExecuteScript("CMD_DLL", "ShowBtnIcon",Form,Obj)
' ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSaveCancelBlock", Form, Obj 

  Call StatusCommentEnable(Form,Obj)
  Form.Controls("BUTTON_DEL").Enabled = False
  Form.Caption = Form.Description
  Call BtnEnable(Form,Obj)
  Call AttrsEnable(Form,Obj)
  Call SetChBox(Obj)
   End Sub
   
''Событие закрытия формы
'Sub Form_BeforeClose(Form, Obj, Cancel)
' 'Проверка кода статуса
' AttrName = "ATTR_TENDER_STATUS"
' If Obj.Attributes.Has(AttrName) Then
'    If Obj.Attributes(AttrName).Empty = False Then
'    Code1 = Obj.Attributes(AttrName).Classifier.Code
'    If Obj.Status.SysName = "STATUS_TENDER_OUT_PUBLIC" and (Code1 = 4 or Code1 = 5 or Code1 = 3) Then
'    If Code1 = 3 Then
'     ans = msgbox("Закрыть закупку как отмененную?",vbQuestion+vbYesNo,"Закрытие закупки")
'  If ans <> vbYes Then exit Sub
''   Obj.Attributes(AttrName0).Classifier = ThisApplication.Classifiers.FindBySysId("NODE_2A102408_E255_493B_88C9_A67CB84FB50C")
'   StatusName = "STATUS_TENDER_CLOSE"
'    'Маршрут
'      Obj.Status = ThisApplication.Statuses(StatusName)
'      msgbox "Закупка закрыта", vbInformation
'      Result = True
'     End If
'  If Code1 = 4 Then
'   ans = msgbox("Закрыть закупку как Выигранную?",vbQuestion+vbYesNo,"Закрытие закупки")
'  If ans <> vbYes Then 
'  Cancel = True
'  exit Sub
'  End If
''   Obj.Attributes(AttrName0).Classifier = ThisApplication.Classifiers.FindBySysId("NODE_2A102408_E255_493B_88C9_A67CB84FB50C")
'   StatusName = "STATUS_TENDER_WIN"
'   Call PurchaseCloseBySelect(Obj,CU,u0,u1,u2,u3,StatusName,Clf,Val)
'  If Clf is Nothing then exit Sub
''    'Маршрут
''      Obj.Status = ThisApplication.Statuses(StatusName)
''      
''      msgbox "Закупка закрыта как выигранная", vbInformation
''      Result = True
'     End If
'     If Code1 = 5 Then
'   ans = msgbox("Закрыть закупку как Проигранную?",vbQuestion+vbYesNo,"Закрытие закупки")
'  If ans <> vbYes Then exit Sub
''   Obj.Attributes(AttrName0).Classifier = ThisApplication.Classifiers.FindBySysId("NODE_2A102408_E255_493B_88C9_A67CB84FB50C")
'   StatusName = "STATUS_TENDER_LOST"
'    'Маршрут
'      Obj.Status = ThisApplication.Statuses(StatusName)
'      msgbox "Закупка закрыта как проигранная", vbInformation
'      Result = True
'     End If
'    End If
'      End If
'        End If
'End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  ThisApplication.Dictionary(Obj.GUID).Item("ObjEdit") = True
  Call BtnEnable(Form,Obj)
  'Статус закупки
  If Attribute.AttributeDefName = "ATTR_TENDER_STATUS" Then
    'Проверка кода статуса
    If Attribute.Empty = False and OldAttribute.Empty = False Then
      Code1 = Attribute.Classifier.Code
      Code0 = OldAttribute.Classifier.Code
      If IsNumeric(Code1) and IsNumeric(Code0) Then
        If Code1 <= Code0 Then
          Msgbox "На данной стадии такое значение статуса закупки невозможно.",vbExclamation
          Cancel = True
          Exit Sub
        End If
      End If
    End If
    
    If Attribute.Empty = False Then
    Code1 = Attribute.Classifier.Code
     If IsNumeric(Code1) Then
      If Code1 = 3  Then
        Result = False
       Call PurchaseClose(ThisObject,Result)
       If Result = True Then
       ThisObject.SaveChanges
       Thisform.close True
       Else 
       Cancel = True
       Exit Sub
      End If
     End If
     
     
     
      If Obj.Status.SysName = "STATUS_TENDER_OUT_PUBLIC" and (Code1 = 4 or Code1 = 5) Then
       Call PurchaseClose(ThisObject,Result)
      End If
     
      If Obj.Status.SysName <> "STATUS_TENDER_OUT_PUBLIC" and (Code1 = 4 or Code1 = 5) Then 
       msgbox "Заявка должна быть размещена" ,vbExclamation
       Cancel = True
       Exit Sub
      End If 
     If Code1 = 2 and Obj.Status.SysName <> "STATUS_TENDER_OUT_APPROVED" and Obj.Status.SysName <> "STATUS_TENDER_OUT_PUBLIC" Then 
       msgbox "Заявка должна быть утверждена" ,vbExclamation
       Cancel = True
       Exit Sub
      End If  
      
         
    End If
   End If
    Call StatusCommentEnable(Form,Obj)
    Call BtnEnable(Form,Obj)
    
  'Укрупненное состояние закупки
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_GLOBAL_STATUS" Then
    Call BtnEnable(Form,Obj)
    'Проверка кода статуса
    If Attribute.Empty = False Then
      Code1 = Attribute.Classifier.SysName
      If (Obj.Status.SysName = "STATUS_TENDER_OUT_ADD_APPROVED" or Obj.Status.SysName = "STATUS_TENDER_OUT_IS_APPROVING") and Code1 = "NODE_MAIN_TENDER_CONSDITION_NO" Then
       Call PurchaseClose(ThisObject,Result)
       If Result = False Then 
     Cancel = true
     Exit Sub
     End If
   End If
   End If
    
    
  'Ответственное структурное подразделение за подготовку заявки. 
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_DEPT_RESP" Then
    AttrName = "ATTR_TENDER_DOC_RESP"
    If Obj.Attributes.Has(AttrName) Then
'      OrgName = "Ответственное структурное подразделение за подготовку заявки"
   OrgName = Obj.Attributes("ATTR_TENDER_DEPT_RESP").Value
'     msgbox OrgName ,vbExclamation
      Set User = ThisApplication.ExecuteScript("CMD_DLL", "OrgUserGet", OrgName)
      If not User is Nothing Then Obj.Attributes(AttrName).User = User
      If User is Nothing Then Obj.Attributes(AttrName) = empty
      End If
    
     'Ответственный за подготовку заявки
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_DOC_RESP" Then
    AttrName = "ATTR_TENDER_DEPT_RESP"
    If Obj.Attributes.Has(AttrName) Then
'      OrgName = "Ответственное структурное подразделение за подготовку заявки"
  Set OrgName = Obj.Attributes("ATTR_TENDER_DOC_RESP")
'     msgbox OrgName.description ,vbExclamation
     Set Dept = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB", "OrgGet", OrgName)
'       msgbox Dept ,vbExclamation
'       ThisForm.Controls(AttrName).Value = Dept
  If not Dept is Nothing Then Obj.Attributes(AttrName) = Dept
  If Dept is Nothing Then Obj.Attributes(AttrName) = empty
        ThisForm.Refresh
    End If
    
     'Куратор 
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_CURATOR" Then
    AttrName = "ATTR_TENDER_CURATOR"
    If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      If not Obj.Attributes(AttrName).User is Nothing Then
        Set uToUser = Obj.Attributes(AttrName).User
        If Obj.Status.SysName = "STATUS_TENDER_OUT_IN_WORK" then
        ans = msgbox("Назначить пользователя " & uToUser.description & " ответственным за подготовку документации по закупке?" ,vbQuestion+vbYesNo )
         If ans <> vbYes Then 
         Cancel = True
         Exit Sub
         End If
        
      
         'Создание поручения новому куратору
       Set uFromUser = ThisApplication.CurrentUser   
       resol = "NODE_CORR_REZOL_POD"
'       resol = "NODE_COR_STAT_MAIN"
       ObjType = "OBJECT_KD_ORDER_NOTICE"
       txt = "Прошу обеспечить подготовку материалов для заявки " & Obj.Description & " в указанные сроки"
       PlanDate = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_TIME")
       If PlanDate = "" Then PlanDate = Date + 1
       If uToUser.SysName <> uFromUser.SysName Then
       ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,uToUser,uFromUser,resol,txt,PlanDate 
       End If
'      Удаление ролей прежнему пользователю  
       If not OldAttribute is Nothing Then
       resol = "NODE_COR_DEL_MAIN"
       Set uToUser = OldAttribute.User
       Call ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","RoleUserDel",Obj,uToUser, "ROLE_TENDER_MATERIAL_RESP,ROLE_INITIATOR,")
       End If
      End If
       
     'Создание роли новому куратору - Инициатор согласования и Отв. за материалы 
        Set uToUser = Obj.Attributes(AttrName).User     
       ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,uToUser,"ROLE_TENDER_MATERIAL_RESP,ROLE_INITIATOR,"
  End If
 End If  
End If    

ElseIf Attribute.AttributeDefName = "ATTR_TENDER_KP_DESI" Then
    AttrName = "ATTR_TENDER_KP_DESI"
    If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      If not Obj.Attributes(AttrName).User is Nothing Then
        Set uToUser = Obj.Attributes(AttrName).User
         If Obj.Status.SysName = "STATUS_TENDER_OUT_IN_WORK" then
        ans = msgbox("Назначить пользователя " & uToUser.description & " ответственным за подготовку документации по закупке?" ,vbQuestion+vbYesNo )
         If ans <> vbYes Then 
         Cancel = True
         Exit Sub
         End If
        
       'Создание роли новому Отв. за КП/НКП - Инициатор согласования и Отв. за КП
       ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,uToUser,"ROLE_TENDER_KP_DESI,ROLE_INITIATOR," 'Роли Ответственному за подготовку
         'Создание поручения Отв. за КП/НКП
'      resol = "NODE_COR_STAT_MAIN"
       resol = "NODE_CORR_REZOL_POD"
       ObjType = "OBJECT_KD_ORDER_NOTICE"
       txt = "Прошу обеспечить подготовку материалов для заявки " & Obj.Description & " в указанные сроки"
       PlanDate = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_TIME")
       If PlanDate = "" Then PlanDate = Date + 1
      
       Set uFromUser = ThisApplication.CurrentUser 
       If uToUser.SysName <> uFromUser.SysName Then
       ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,uToUser,uFromUser,resol,txt,PlanDate 
       End If
'       Удаление ролей и поручение прежнему ответственному
       If not OldAttribute is Nothing Then
       Set uToUser = OldAttribute.User
       Call ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","RoleUserDel",Obj,uToUser, "ROLE_TENDER_KP_DESI,ROLE_INITIATOR,")
       End If
     
    End If
  End If
 End If  
End If    


  'Дата получения информации
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_INFO_GET_TIME" Then
    Data2 = Attribute.Value
    Data3 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_TIME")
    Delta = 0
    flag = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMaxData",Data3,Data2,Delta)
    
    If Flag Then
      Cancel = flag
      Exit Sub
    End If
   
    
  'Дата и время окончания приема заявок
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_GET_OFFERS_STOP_TIME" Then
    Data1 = Obj.Attributes("ATTR_TENDER_INFO_GET_TIME")
    Data2 = Attribute.Value
    Data3 = Obj.Attributes("ATTR_TENDER_OFFERS_OPEN_TIME")
    Delta = 0
    flag = (Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Delta)) Or _
           Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMaxData",Data3,Data2,Delta)
    If Flag Then
      Cancel = flag
      Exit Sub
    End If
    Data4 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_TIME")
    Tm = CStr(Data4)
    TmLength = Len(Tm)
    If TmLength > 10 Then
    Tm = Right(Tm, 8)  
    Tm = Left(Tm, 5) 
    Else
    Tm = " "
    End If
'    AttrTo = "ATTR_TENDER_GET_OFFERS_STOP_TIME_VAL"
'    Call ThisApplication.ExecuteScript("CMD_DLL","SETATTR_F",Obj,AttrTo,Tm,True)
   
   If Data2 =  Data3 Then
   
    Data5 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_MINUTES").Value
    Data6 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_HOUR").Value
    Ch2 = Obj.Attributes("ATTR_TENDER_OFFERS_OPEN_HOUR").Value
    Mi2 = Obj.Attributes("ATTR_TENDER_OFFERS_OPEN_MINUTES").Value
    
     flag = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB", "CheckTime", Form, Obj, Data6, Data5, Ch2, Mi2)
     If not Flag Then
     
     Obj.Attributes("ATTR_TENDER_OFFERS_OPEN_HOUR").Value = ""
     Obj.Attributes("ATTR_TENDER_OFFERS_OPEN_MINUTES").Value = ""
     Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_MINUTES").Value = ""
     Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_HOUR").Value = ""
     
     Tm =  "--:--" 
     AttrTo = "ATTR_TENDER_GET_OFFERS_STOP_TIME_VAL"
     Call ThisApplication.ExecuteScript("CMD_DLL","SETATTR_F",Obj,AttrTo,Tm,True) 
     AttrTo = "ATTR_TENDER_OFFERS_OPEN_TIME_VAL"
     Call ThisApplication.ExecuteScript("CMD_DLL","SETATTR_F",Obj,AttrTo,Tm,True)
     Exit Sub
     End If
    End If
    
  'Дата и время окончания приема заявок с часов
   ElseIf Attribute.AttributeDefName = "ATTR_TENDER_GET_OFFERS_STOP_HOUR" Then
    Data1 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_MINUTES").Value
    Data2 = Attribute.Value
    Data3 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_TIME_VAL")
    Ch2 = Obj.Attributes("ATTR_TENDER_OFFERS_OPEN_HOUR").Value
    Mi2 = Obj.Attributes("ATTR_TENDER_OFFERS_OPEN_MINUTES").Value
   Data4 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_TIME").Value
   Data5 = Obj.Attributes("ATTR_TENDER_OFFERS_OPEN_TIME").Value
  If Data4 = Data5 Then
     flag = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB", "CheckTime", Form, Obj, Data2, Data1, Ch2, Mi2)
     If not Flag Then
      Cancel = not flag
      Exit Sub
    End If
 End If
    Tm = Data2 & ":" & Data1
     AttrTo = "ATTR_TENDER_GET_OFFERS_STOP_TIME_VAL"
    Call ThisApplication.ExecuteScript("CMD_DLL","SETATTR_F",Obj,AttrTo,Tm,True)     
      
       
   'Дата и время окончания приема заявок с минут
   ElseIf Attribute.AttributeDefName = "ATTR_TENDER_GET_OFFERS_STOP_MINUTES" Then
    Data1 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_HOUR").Value
    Data2 = Attribute.Value
    Data3 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_TIME_VAL")
    Ch2 = Obj.Attributes("ATTR_TENDER_OFFERS_OPEN_HOUR").Value
    Mi2 = Obj.Attributes("ATTR_TENDER_OFFERS_OPEN_MINUTES").Value
   Data4 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_TIME").Value
   Data5 = Obj.Attributes("ATTR_TENDER_OFFERS_OPEN_TIME").Value
  If Data4 = Data5 Then
    flag = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB", "CheckTime", Form, Obj, Data1, Data2, Ch2, Mi2)
    If not Flag Then
      Cancel = not flag
      Exit Sub
    End If
  End If 
    Tm = Data1 & ":" & Data2
     AttrTo = "ATTR_TENDER_GET_OFFERS_STOP_TIME_VAL"
    Call ThisApplication.ExecuteScript("CMD_DLL","SETATTR_F",Obj,AttrTo,Tm,True)     
      
       
  'Дата и время вскрытия
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_OFFERS_OPEN_TIME" Then
    Data1 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_TIME")
    Data2 = Attribute.Value
    Data3 = Obj.Attributes("ATTR_TENDER_SUMMARIZING_PLAN_TIME")
 
    Delta = 0
    flag = (Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Delta)) Or _
           Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMaxData",Data3,Data2,Delta)
    If Flag Then
      Cancel = flag
      Exit Sub
    End If
    Tm = CStr(Data2)
    TmLength = Len(Tm)
    If TmLength > 10 Then
    Tm = Right(Tm, 8)  
    Tm = Left(Tm, 5) 
    Else
    Tm = " "
    End If
'    AttrTo = "ATTR_TENDER_OFFERS_OPEN_TIME_VAL"
'    Call ThisApplication.ExecuteScript("CMD_DLL","SETATTR_F",Obj,AttrTo,Tm,True)
   
    If Data2 = Data1 Then
   
    Data5 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_MINUTES").Value
    Data6 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_HOUR").Value
    Ch2 = Obj.Attributes("ATTR_TENDER_OFFERS_OPEN_HOUR").Value
    Mi2 = Obj.Attributes("ATTR_TENDER_OFFERS_OPEN_MINUTES").Value
    
     flag = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB", "CheckTime", Form, Obj, Data6, Data5, Ch2, Mi2)
     If not Flag Then
     
     Obj.Attributes("ATTR_TENDER_OFFERS_OPEN_HOUR").Value = ""
     Obj.Attributes("ATTR_TENDER_OFFERS_OPEN_MINUTES").Value = ""
     Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_MINUTES").Value = ""
     Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_HOUR").Value = ""
     
     Tm =  "--:--" 
     AttrTo = "ATTR_TENDER_GET_OFFERS_STOP_TIME_VAL"
     Call ThisApplication.ExecuteScript("CMD_DLL","SETATTR_F",Obj,AttrTo,Tm,True) 
     AttrTo = "ATTR_TENDER_OFFERS_OPEN_TIME_VAL"
     Call ThisApplication.ExecuteScript("CMD_DLL","SETATTR_F",Obj,AttrTo,Tm,True)
     Exit Sub
     End If
    End If 
    
    'Дата и время вскрытия  с часов
    
    ElseIf Attribute.AttributeDefName = "ATTR_TENDER_OFFERS_OPEN_HOUR" Then
    Data1 = Obj.Attributes("ATTR_TENDER_OFFERS_OPEN_MINUTES").Value
    Data2 = Attribute.Value
    Data3 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_TIME_VAL")
    Ch1 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_HOUR").Value
    Mi1 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_MINUTES").Value
   Data4 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_TIME").Value
   Data5 = Obj.Attributes("ATTR_TENDER_OFFERS_OPEN_TIME").Value
  If Data4 = Data5 Then
    flag = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB", "CheckTime", Form, Obj, Ch1, Mi1, Data2, Data1)
    If not Flag Then
      Cancel = not flag
      Exit Sub
    End If
  End If
    Tm = Data2 & ":" & Data1
     AttrTo = "ATTR_TENDER_OFFERS_OPEN_TIME_VAL"
    Call ThisApplication.ExecuteScript("CMD_DLL","SETATTR_F",Obj,AttrTo,Tm,True)     
   
  'Дата и время вскрытия  с минут
    
    ElseIf Attribute.AttributeDefName = "ATTR_TENDER_OFFERS_OPEN_MINUTES" Then
    Data1 = Obj.Attributes("ATTR_TENDER_OFFERS_OPEN_HOUR").Value
    Data2 = Attribute.Value
    Data3 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_TIME_VAL")
    Ch1 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_HOUR").Value
    Mi1 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_MINUTES").Value
   Data4 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_TIME").Value
   Data5 = Obj.Attributes("ATTR_TENDER_OFFERS_OPEN_TIME").Value
  If Data4 = Data5 Then
    flag = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB", "CheckTime", Form, Obj, Ch1, Mi1, Data1, Data2)
    If not Flag Then
      Cancel = not flag
      Exit Sub
    End If
   End If
     Tm = Data1 & ":" & Data2
     AttrTo = "ATTR_TENDER_OFFERS_OPEN_TIME_VAL"
     Call ThisApplication.ExecuteScript("CMD_DLL","SETATTR_F",Obj,AttrTo,Tm,True)     
   
   
  'Планируемая дата подведения итогов
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_SUMMARIZING_PLAN_TIME" Then
    Data1 = Obj.Attributes("ATTR_TENDER_OFFERS_OPEN_TIME")
    Data2 = Attribute.Value
    Data3 = Obj.Attributes("ATTR_TENDER_OFFERS_OPEN_TIME")
    Delta = 0
    flag = (Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Delta))
    If Flag Then
      Cancel = flag
      Exit Sub
    End If
    
  'Дата подачи заявки
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_PUBLIC_TIME" Then
    Data1 = Obj.Attributes("ATTR_TENDER_INFO_GET_TIME")
    Data2 = Attribute.Value
    Data3 = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_TIME")
    Delta = 0
    flag = (Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Delta)) Or _
           Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMaxData",Data3,Data2,Delta)
    If Flag Then
        Cancel = flag
        Exit Sub
    End If  
  
  
  'Себестоимость, Цена заявки после уторговывания, Цена заявки
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_COST_PRICE" or _
  Attribute.AttributeDefName = "ATTR_TENDER_OFFERS_SECOND_PRICE" or _
  Attribute.AttributeDefName = "ATTR_TENDER_OFFERS_PRICE" Then
    Cancel = not PriceCheck(Form,Obj)
    Exit Sub
  End If
  
  Call AttrsEnable(Form,Obj)
  
  'Пересчет процентов при смене цены заявки
  Call PercentCalc(Obj,-1)
End Sub

Sub Form_TableAttributeChange(Form, Object, TableAttribute, TableRow, ColumnAttributeDefName, OldTableRow, Cancel)
  ThisApplication.Dictionary(Object.GUID).Item("ObjEdit") = True
  Call BtnEnable(Form,Object)
End Sub

''Событие - Выделение в выборке документов закупки
'Sub QUERY_TENDER_ALL_DOCKS_Selected(iItem, action)
'  If iItem <> -1 Then
'    ThisForm.Controls("BUTTON_DEL").Enabled = True
'  Else
'    ThisForm.Controls("BUTTON_DEL").Enabled = False
'  End If
'End Sub

'Событие - Выделение в выборке Документов закупки
Sub QUERY_TENDER_ALL_DOCKS_Selected(iItem, action)
  Set Query = ThisForm.Controls("QUERY_TENDER_ALL_DOCKS")
  Set Objects = Query.SelectedObjects
  If iItem <> -1 Then
    If Objects.Count = 1 Then
      flag = ThisApplication.ExecuteScript("OBJECT_PURCHASE_DOC","UserCanDelete",ThisApplication.CurrentUser,Objects(0))
      ThisForm.Controls("BUTTON_DEL").Enabled = True And flag
    Else
      ThisForm.Controls("BUTTON_DEL").Enabled = False
    End If
  Else
    ThisForm.Controls("BUTTON_DEL").Enabled = False
  End If
End Sub


'Событие - Изменение в ячейке таблицы Стоимость по договорам подрядных организаций
Sub ATTR_TENDER_SUBCONTRACT_PRICE_TABLE_CellAfterEdit(nRow, nCol, strLabel, bCancel)
  Call PercentCalc(ThisObject,nRow)
End Sub

'Кнопка - Добавить
Sub BUTTON_ADD_OnClick()
  ThisScript.SysAdminModeOn
  Set NewObj = ThisObject.Objects.Create("OBJECT_PURCHASE_DOC")
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = NewObj
  Dlg.Show
End Sub

'Кнопка - Удалить
Sub BUTTON_DEL_OnClick()
  ThisScript.SysAdminModeOn
  Set Query = ThisForm.Controls("QUERY_TENDER_ALL_DOCKS")
  Set Objects = Query.SelectedObjects
  str = ""
  
  'Подтверждение удаления
  If Objects.Count <> 0 Then
    For Each Obj in Objects
      If Obj.Attributes.Has("ATTR_DOCUMENT_NAME") Then
        If Obj.Attributes("ATTR_DOCUMENT_NAME").Empty = False Then
          If str <> "" Then
            str = str & ", """ & Obj.Attributes("ATTR_DOCUMENT_NAME").Value & """"
          Else
            str = """" & Obj.Attributes("ATTR_DOCUMENT_NAME").Value & """"
          End If
        End If
      End If
    Next
    If str = "" Then str = Objects.Count & " документов закупки"
    Key = Msgbox("Удалить " & str & " из системы?",vbYesNo+vbQuestion)
    If Key = vbNo Then Exit Sub
  Else
    Exit Sub
  End If
  
  'Удаление строк из таблицы
  For Each Obj in Objects
    Obj.Erase
  Next
  ThisForm.Refresh
End Sub

'Кнопка - Добавить организацию
Sub BUTTON_EDIT_CONCURENT_LIST_OnClick()
  If ThisObject.Parent is Nothing Then Exit Sub
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = ThisObject.Parent
  Dlg.Show
End Sub

'Кнопка выбрать участника
Sub BUTTON_CLIENT_NAME_SELECT_OnClick()
  Set Table = ThisForm.Controls("ATTR_TENDER_COMPETITOR_PRICE_TABLE").ActiveX
  
  Set Table = ThisObject.Attributes("ATTR_TENDER_COMPETITOR_PRICE_TABLE")
  Set tbl = ThisObject.Parent.Attributes("ATTR_TENDER_CONCURENT_LIST")
'  nRow = Table.SelectedRow
'  nCol = Table.SelectedColumn
'  rCount = Table.RowCount
'  If nRow > -1 and nRow < rCount and not ThisObject.Parent is Nothing Then
  If tbl.Rows.Count>0 Then
    Set Dlg = ThisApplication.Dialogs.SelectDlg
    Dlg.SelectFrom = ThisObject.Parent.Attributes("ATTR_TENDER_CONCURENT_LIST").Rows
    Dlg.Caption = "Выбор участника"
    If Dlg.Show Then
      If Dlg.Objects.Count > 0 Then
        Set Rows = Dlg.Objects
        For each row in Rows
          Val = Row.Attributes("ATTR_NAME").Value
          Set row0 = Table.rows.Create
          AttrName = "ATTR_TENDER_CLIENT_NAME"
          If Row0.Attributes.Has(AttrName) Then
            Row0.Attributes(AttrName).Value = Val
          End If
        Next
      End If
    End If
  Else
    msgbox "Список конкуренов пуст",vbExclamation,"Добавление участника"
  End If
End Sub

'Кнопка выбрать участника
Sub BUTTON_REQUEST_OnClick()
 txt = "Прошу предоставить данные по себестоимости закупки"
 ThisApplication.ExecuteScript "CMD_TENDER_OUT_REQUEST", "Main", ThisObject, txt
End Sub

'Процедура определяет доступность поля "Комментарий к статусу"
Sub StatusCommentEnable(Form,Obj)
  Check = True
  If Obj.Attributes.Has("ATTR_TENDER_STATUS") Then
    If Obj.Attributes("ATTR_TENDER_STATUS").Empty = False Then
      If StrComp(Obj.Attributes("ATTR_TENDER_STATUS").Value, "Проигранная", vbTextCompare) = 0 Then
        Check = False
      End If
    End If
  End If
  Form.Controls("ATTR_TENDER_STATUS_FAIL_COMMENT").ReadOnly = Check
End Sub

'Процедура расчета значения атрибута % в таблице Стоимость по договорам подрядных организаций
Sub PercentCalc(Obj,nRow)
  ThisScript.SysAdminModeOn
  TableName = "ATTR_TENDER_SUBCONTRACT_PRICE_TABLE"
  PriceName = "ATTR_TENDER_OFFERS_PRICE"
  cPriceName = "ATTR_TENDER_CONTRACTOR_DIAL_PRICE"
  PercentName = "ATTR_TENDER_PERCENT"
  If Obj.Attributes.Has(TableName) = False Then Exit Sub
  If Obj.Attributes.Has(PriceName) = False Then Exit Sub
  If Obj.Attributes(PriceName).Empty Then Exit Sub
  Price = Obj.Attributes(PriceName).Value
  Set Rows = Obj.Attributes(TableName).Rows
  If Rows.Count = 0 Then Exit Sub
  
  If nRow <> -1 Then
    Set Row = Rows(nRow)
    If Row.Attributes(cPriceName).Empty = False Then
      cPrice = Row.Attributes(cPriceName).Value
      If Price <> 0 Then
        Val = cPrice / Price
        If Row.Attributes(PercentName).Value <> Val Then Row.Attributes(PercentName).Value = Val
      End If
    End If
  Else
    For Each Row in Rows
      If Row.Attributes(cPriceName).Empty = False Then
        cPrice = Row.Attributes(cPriceName).Value
        If Price <> 0 Then
          Val = cPrice / Price * 100
          If Row.Attributes(PercentName).Value <> Val Then Row.Attributes(PercentName).Value = Val
        End If
      End If
    Next
  End If
End Sub

'Процедура управления доступностью атрибутов
Sub AttrsEnable(Form,Obj)
  Set CU = ThisApplication.CurrentUser
  Set Roles = Obj.RolesForUser(CU)
  sName = Obj.StatusName
  pStatus = Obj.Attributes("ATTR_PREVIOUS_STATUS").Value
  
   'Причины
  Check = True
  
   AttrName1 = "ATTR_TENDER_GLOBAL_STATUS"
  If Obj.Attributes.Has(AttrName0) Then
    If Obj.Attributes(AttrName0).Empty = False Then
      If not Obj.Attributes(AttrName0).Classifier is Nothing Then
        AttrStatus = Obj.Attributes(AttrName0).Classifier.Code
      End If
    End If
  End If
 If AttrStatus <> 1 Then Check = False
  If AttrStatus = 2 Then  Check = False
  Form.Controls("ATTR_TENDER_REJECTION_REASON").ReadOnly = Check
  
  'Укрупненное состояние закупки
  Check = True
  If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then 
    If sName = "STATUS_TENDER_OUT_IS_APPROVING" Then
      Check = False
    ElseIf sName = "STATUS_TENDER_OUT_ADD_APPROVED" and pStatus = "STATUS_KD_AGREEMENT" Then
      Check = False
    End If
  End If
  Form.Controls("ATTR_TENDER_GLOBAL_STATUS").ReadOnly = Check
  
  'Ответственное структурное подразделение за подготовку заявки
  Check = True
  If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then Check = False
  Form.Controls("ATTR_TENDER_DEPT_RESP").ReadOnly = Check
  
  'Куратор закупки
  Check = True
  
  If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then Check = False
  
  Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,"ATTR_TENDER_DOC_RESP")
  
  If not User is Nothing Then
    If User.SysName = CU.SysName Then Check = False
    
  End If
  Form.Controls("ATTR_TENDER_CURATOR").ReadOnly = Check

  'Руководитель ПЭО
  check = (Obj.Attributes("ATTR_TENDER_PEO_CHIF").Empty = False)
  Form.Controls("ATTR_TENDER_PEO_CHIF").ReadOnly = check '(check or Roles.Has("ROLE_PURCHASE_RESPONSIBLE") = False)
  
  'Ответственный за КП/НКП
  Check = True
  Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,"ATTR_TENDER_PEO_CHIF")
  If not User is Nothing Then
    If User.SysName = CU.SysName Then Check = False
  End If
  If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then Check = False
  Form.Controls("ATTR_TENDER_KP_DESI").ReadOnly = Check
'   Form.Controls("ATTR_TENDER_KP_DESI").Enabled = not Check
  
  'Ответственный руководитель (Главный бухгалтер)
  check = (Obj.Attributes("ATTR_TENDER_ACC_CHIF").Empty = False)
  Form.Controls("ATTR_TENDER_ACC_CHIF").ReadOnly = (check or _
                          Roles.Has("ROLE_PURCHASE_RESPONSIBLE") = False)

  'Специалист группы
  Check = True
  Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,"ATTR_TENDER_GROUP_CHIF")
  If not User is Nothing Then
    If User.SysName = CU.SysName Then Check = False
  End If
  If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then Check = False
  Form.Controls("ATTR_TENDER_RESP_OUPPKZ").ReadOnly = Check
  
  'Ответственный за  подготовку закупочной документации
  Check = True
  If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then Check = False
  Form.Controls("ATTR_TENDER_DOC_RESP").ReadOnly = Check
  
  'Ответственный за  подготовку закупочной документации
  Check = True
  If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
    If sName = "STATUS_TENDER_OUT_ADD_APPROVED" or sName = "STATUS_TENDER_OUT_IN_WORK" or _
    sName = "STATUS_TENDER_OUT_PUBLIC" Then
      Check = False
    End If
  End If
  Form.Controls("ATTR_TENDER_STATUS").ReadOnly = Check
  
  'Себестоимость (видимость - только Группа)
   Form.Controls("ATTR_TENDER_COST_PRICE").Visible = CU.Groups.Has("GROUP_TENDER")
   Form.Controls("BUTTON_REQUEST").Visible = not CU.Groups.Has("GROUP_TENDER")
  
  'Блокируем контролы только для Группы (ATTR_TENDER_SUBCONTRACT_PRICE_TABLE - ислючено)
  Attr = "ATTR_NAME,ATTR_TENDER_UNIQUE_NUM,ATTR_TENDER_EIS_NUM,ATTR_TENDER_SMSP_FLAG,ATTR_TENDER_FIRST_PRICE,ATTR_TENDER_METHOD_NAME," &_
  "ATTR_TENDER_ORGANIZER,ATTR_TENDER_CLIENT,ATTR_TENDER_MEMBER,ATTR_TENDER_GLOBAL_STATUS,ATTR_TENDER_REJECTION_REASON," &_
  "ATTR_TENDER_DIRECTOR_RESOLUTION,ATTR_TENDER_INFO_GET_TIME,ATTR_TENDER_GET_OFFERS_STOP_TIME,ATTR_TENDER_OUT_FLOW_CASTOM," &_
  "ATTR_TENDER_OFFERS_OPEN_TIME,ATTR_TENDER_SUMMARIZING_PLAN_TIME,ATTR_TENDER_PUBLIC_TIME,ATTR_TENDER_DEPT_RESP,ATTR_TENDER_STATUS," &_
  "ATTR_TENDER_OFFERS_PRICE,ATTR_TENDER_OFFERS_SECOND_PRICE,ATTR_TENDER_COST_PRICE,ATTR_TENDER_STATUS_FAIL_COMMENT,ATTR_TENDER_RESULT," &_
  "ATTR_TENDER_FINISH_PROTOCOL,ATTR_TENDER_COMPETITOR_PRICE_TABLE,ATTR_TENDER_ORDER,BUTTON_CLIENT_NAME_SELECT,BUTTON_EDIT_CONCURENT_LIST," &_
  "ATTR_TENDER_OUT_ORDER_TO_WORK_CASTOM"
   ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","AttrBlockByGropeRoleStat",Form, Obj, Attr, CU, Stat, "GROUP_TENDER", False 'Роли
  End Sub

'Процедура управления доступностью основных кнопок на форме
Sub BtnEnable(Form,Obj)
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  Set Obj = ThisObject
  Set Roles = Obj.RolesForUser(CU)
  Set Dict = ThisApplication.Dictionary(Obj.Guid & " - BlockRoute")
  Dict.RemoveAll
  pStatus = Obj.Attributes("ATTR_PREVIOUS_STATUS").Value
  AttrStatus = 0
  AttrGlobalStatus = ""
  pos = ""
  AttrName0 = "ATTR_TENDER_STATUS"
  AttrName1 = "ATTR_TENDER_GLOBAL_STATUS"
  AttrName2 = "ATTR_TENDER_POS"
  If Obj.Attributes.Has(AttrName0) Then
    If Obj.Attributes(AttrName0).Empty = False Then
      If not Obj.Attributes(AttrName0).Classifier is Nothing Then
        AttrStatus = Obj.Attributes(AttrName0).Classifier.Code
      End If
    End If
  End If
  If Obj.Attributes.Has(AttrName1) Then
    If Obj.Attributes(AttrName1).Empty = False Then
      If not Obj.Attributes(AttrName1).Classifier is Nothing Then
        AttrGlobalStatus = Obj.Attributes(AttrName1).Classifier.SysName
      End If
    End If
  End If
  If Obj.Attributes.Has(AttrName2) Then
    If Obj.Attributes(AttrName2).Empty = False Then
    pos = Obj.Attributes(AttrName2).value
    End If
  End If
  
  Form.Controls("BUTTON_ORDER").Enabled = CU.Groups.Has("GROUP_TENDER")
  
  BtnList = "BUTTON_CUSTOM_SAVE,BUTTON_CUSTOM_CANCEL,BUTTON_ADD_APPROVE,BUTTON_APPROVAL_OF_PARTICIPATION," &_
  "BUTTON_APPROVE,BUTTON_TO_WORK,BUTTON_AGREEMENT_PLACING,BUTTON_UPLOAD,BUTTON_AGREEMENT_BARGAIN," &_
  "BUTTON_TO_DEVELOP_NKP,BUTTON_UPLOAD_NKP,BUTTON_LOAD_RESULT,BUTTON_CLOSE,BUTTON_GO_PEO,BUTTON_GO_GRP," &_
  "BUTTON_ADD_TP,BUTTON_ADD_KP,BUTTON_ADD_NKP"
  Arr = Split(BtnList,",")
  
  If ThisApplication.Dictionary(ThisObject.GUID).Exists("ObjEdit") Then
    If ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = True Then
      Dict.Item("BUTTON_CUSTOM_SAVE") = True
      Dict.Item("BUTTON_CUSTOM_CANCEL") = True
    End If
  End If
  
  Select Case Obj.StatusName
    'Плановая
    Case "STATUS_TENDER_OUT_PLANING"
      If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
        Dict.Item("BUTTON_ADD_APPROVE") = True
        If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
        Dict.Item("BUTTON_CLOSE") = True
      End If
    End If     
    'Одобрена
    Case "STATUS_TENDER_OUT_ADD_APPROVED"
      If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
        Dict.Item("BUTTON_CLOSE") = True
        If pStatus = "STATUS_KD_AGREEMENT" Then
          check = (Obj.Attributes("ATTR_TENDER_GLOBAL_STATUS").Empty = True)
          If check Then
            Dict.Item("BUTTON_APPROVE") = True
         
          End If
        End If
        If AttrGlobalStatus = "" Then
          Dict.Item("BUTTON_APPROVAL_OF_PARTICIPATION") = True
        End If
      End If
      
    'На утверждении
    Case "STATUS_TENDER_OUT_IS_APPROVING"
      If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
        check = (Obj.Attributes("ATTR_TENDER_GLOBAL_STATUS").Empty = True)
        If check Then Dict.Item("BUTTON_APPROVE") = True
        Dict.Item("BUTTON_CLOSE") = True
       
        If AttrStatus = 1 and pos = "Подготовка заявки к публикации" Then
          Dict.Item("BUTTON_UPLOAD") = True
        ElseIf AttrStatus = 2 and pos = "Подготовка заявки к публикации НКП" Then
          Dict.Item("BUTTON_UPLOAD_NKP") = True
'           Dict.Item("BUTTON_TO_DEVELOP_NKP") = True
        End If
      End If
        If AttrStatus = 2 and pos = "Подготовка заявки к публикации" Then
          Dict.Item("BUTTON_TO_DEVELOP_NKP") = True
        End If
     
    'Утверждена
    Case "STATUS_TENDER_OUT_APPROVED"
      If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") and AttrStatus <> 2 and _
      AttrGlobalStatus = "NODE_MAIN_TENDER_CONSDITION_YES" Then
        Dict.Item("BUTTON_TO_WORK") = True
        Dict.Item("BUTTON_CLOSE") = True
      End If

    'Разработка документации
    Case "STATUS_TENDER_OUT_IN_WORK"
      If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
        Dict.Item("BUTTON_CLOSE") = True
'        Dict.Item("BUTTON_AGREEMENT_PLACING") = True
        
        If AttrGlobalStatus = "NODE_MAIN_TENDER_CONSDITION_YES" and AttrStatus = 2 Then
          Dict.Item("BUTTON_UPLOAD_NKP") = True
        End If
      End If
'      If Roles.Has("ROLE_INITIATOR") Then  Dict.Item("BUTTON_AGREEMENT_PLACING") = True
      If Roles.Has("ROLE_TENDER_MATERIAL_RESP") and pos = "Разработка ТЧ" Then 
      Dict.Item("BUTTON_GO_PEO") = True 
      Dict.Item("BUTTON_ADD_TP") = True
      Dict.Item("BUTTON_ADD_KP") = True
      End If
      If Roles.Has("ROLE_TENDER_KP_DESI") and (pos = "Разработка ЭЧ" or pos = "Разработка НКП") Then 
      Dict.Item("BUTTON_GO_GRP") = True 
      Dict.Item("BUTTON_ADD_TP") = True
      Dict.Item("BUTTON_ADD_KP") = True
      Form.Controls("ATTR_TENDER_SUBCONTRACT_PRICE_TABLE").ReadOnly = True
      End If
      If Roles.Has("ROLE_TENDER_KP_DESI") and pos = "Разработка НКП" Then 
      Dict.Item("BUTTON_GO_GRP") = True 
      Dict.Item("BUTTON_ADD_TP") = True
      Dict.Item("BUTTON_ADD_NKP") = True
      Form.Controls("ATTR_TENDER_SUBCONTRACT_PRICE_TABLE").ReadOnly = True
      End If
        
        'Размещена на площадке
    Case "STATUS_TENDER_OUT_PUBLIC"
      If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
        Dict.Item("BUTTON_CLOSE") = True
        Dict.Item("BUTTON_LOAD_RESULT") = True
        If AttrStatus = 2 and Obj.Attributes("ATTR_TENDER_FINISH_PROTOCOL").empty = True Then
          Dict.Item("BUTTON_AGREEMENT_BARGAIN") = True
        End If
      End If
      
           'Завершена
    Case "STATUS_TENDER_CLOSE"
'          If AttrStatus = 3 or AttrStatus = 5 Then
        Qi = Obj.Attributes("ATTR_TENDER_STATUS_FAIL_COMMENT").Empty    
        Form.Controls("ATTR_TENDER_STATUS_FAIL_COMMENT").Visible = not Qi
        Form.Controls("ATTR_TENDER_POS").Visible = Qi        
      
  End Select
  
  isContrManager = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsGroupMember",CU,"GROUP_CONTRACTS")
  CanCreateContract = False
  If Obj.Attributes("ATTR_TENDER_STATUS").Empty = False Then
    Set cls = Obj.Attributes("ATTR_TENDER_STATUS").Classifier
    If Not cls Is Nothing Then CanCreateContract = (cls.Code = "4")
  End If
  Form.Controls("BUTTON_ADD_CONTRACT").Visible = isContrManager And CanCreateContract
  
  'Блокировка кнопок
  For i = 0 to Ubound(Arr)
    BtnName = Arr(i)
    If Dict.Exists(BtnName) Then
      Check = True
    Else
      Check = False
    End If
    If Form.Controls.Has(BtnName) Then
      Form.Controls(BtnName).Visible = Check
'      Form.Controls(BtnName).Enabled = Check
    End If
  Next
End Sub

'Кнопка - Сохранить
Sub BUTTON_CUSTOM_SAVE_OnClick()
'ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSave", ThisForm, ThisObject
Set Obj = ThisObject
  ThisScript.SysAdminModeOn
  Key = Msgbox("Сохранить внесенные изменения?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
  ThisApplication.Dictionary(Obj.GUID).Item("ObjEdit") = False
  Obj.Dictionary.Item("FormActive") = ThisForm.SysName
  ThisObject.SaveChanges
  ThisScript.SysAdminModeOff
End Sub

'Кнопка - Отменить
Sub BUTTON_CUSTOM_CANCEL_OnClick()
  ThisScript.SysAdminModeOn
  Key = Msgbox("Отменить внесенные изменения?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
  ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = False
  Guid = ThisObject.GUID
  ThisForm.Close False
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Set Obj = ThisApplication.GetObjectByGUID(Guid)
  Dlg.Object = Obj
  Dlg.Show
End Sub

'Кнопка - Одобрить
Sub BUTTON_ADD_APPROVE_OnClick()
  ThisScript.SysAdminModeOn
  
 AttrStr = "ATTR_TENDER_SMSP_FLAG,ATTR_NAME,ATTR_TENDER_UNIQUE_NUM,ATTR_TENDER_FIRST_PRICE,ATTR_TENDER_ORGANIZER," &_
 "ATTR_TENDER_CLIENT,ATTR_TENDER_GET_OFFERS_STOP_TIME,ATTR_TENDER_SUMMARIZING_PLAN_TIME,ATTR_TENDER_RESP_OUPPKZ"
Check = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","FormAttrCheckAlarm",ThisForm, ThisObject, AttrStr)

If Check = True Then Exit Sub
  Result = False
   ' Запускаем команду Одобрить
  Call PurchaseAddApprove(ThisObject,Result)
  If Result = True Then
   Set Obj = ThisObject
'   If ThisObject.Attributes.Has("ATTR_TENDER_GLOBAL_STATUS") Then
'      ThisObject.Attributes("ATTR_TENDER_GLOBAL_STATUS").Classifier = ThisApplication.Classifiers.FindBySysId("NODE_MAIN_TENDER_CONSDITION_YES")
'    End If
   ' - Состояние
  AttrName = "ATTR_TENDER_POS"
  If Obj.Attributes.Has(AttrName) Then
    Obj.Attributes(AttrName).value = "Закупка одобрена для согласования участия"
  End If
'   Msgbox "Закупка одобрена для согласования участия", vbInformation
    Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",ThisObject,"ATTR_TENDER_RESP_OUPPKZ")
    
  Set CU = ThisApplication.CurrentUser
  If not User is Nothing Then
  If CU.SysName <> User.SysName Then
  ThisObject.SaveChanges
  Thisform.close True
  Exit Sub
  End If
  End If
    ThisObject.SaveChanges
    Call AttrsEnable(ThisForm,ThisObject)
   
  End If
 End Sub

'Кнопка - Утвердить участие
Sub BUTTON_APPROVE_OnClick()
  ThisScript.SysAdminModeOn
  AttrStr = "ATTR_NAME,ATTR_TENDER_UNIQUE_NUM,ATTR_TENDER_FIRST_PRICE,ATTR_TENDER_ORGANIZER,ATTR_TENDER_DOC_RESP," &_
 "ATTR_TENDER_CLIENT,ATTR_TENDER_GET_OFFERS_STOP_TIME,ATTR_TENDER_SUMMARIZING_PLAN_TIME,ATTR_TENDER_RESP_OUPPKZ"
Check = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","FormAttrCheckAlarm",ThisForm, ThisObject, AttrStr)

If Check = True Then Exit Sub
   ' Запускаем команду 
  Set Obj = ThisObject
  Result = False
  Call PurchaseWorkApprove(ThisObject,Result)
 
'  Закрываем форму, или обновляем, если пользователь Спец. группы отв. за закупку
  If Result = True Then Call PurchaseGoWork(ThisObject,Result)
  If Result = True Then 
        'Заполнение атрибута
   AttrName = "ATTR_TENDER_POS"
   If Obj.Attributes.Has(AttrName) Then
    Obj.Attributes(AttrName) = "Разработка ТЧ"
   End If

   
'  Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",ThisObject,"ATTR_TENDER_RESP_OUPPKZ")
'  Set CU = ThisApplication.CurrentUser
'  If not User is Nothing Then
'  If CU.SysName <> User.SysName Then
  ThisObject.SaveChanges
  Thisform.close True
'  Exit Sub
'  End If
'  End If
'    ThisObject.SaveChanges
'    Call AttrsEnable(ThisForm,ThisObject)
  End If



'Проверяем и красим атрибуты
'  ThisScript.SysAdminModeOn
'   AttrStr = "ATTR_NAME,ATTR_TENDER_UNIQUE_NUM,ATTR_TENDER_FIRST_PRICE,ATTR_TENDER_ORGANIZER,ATTR_TENDER_DOC_RESP," &_
' "ATTR_TENDER_CLIENT,ATTR_TENDER_GET_OFFERS_STOP_TIME,ATTR_TENDER_SUMMARIZING_PLAN_TIME,ATTR_TENDER_RESP_OUPPKZ"
'Check = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","FormAttrCheckAlarm",ThisForm, ThisObject, AttrStr)
'If Check = True Then Exit Sub
   ' Запускаем команду 
'  Result = False
'  Call PurchaseGoWork(ThisObject,Result)
'  If Result = True Then
'  ThisObject.SaveChanges
'  Thisform.close True
'    ThisObject.SaveChanges
'    Call AttrsEnable(ThisForm,ThisObject)
'       Msgbox "Закупка передана в разработку", vbInformation
'  End If


End Sub

'Кнопка - Закрыть
Sub BUTTON_CLOSE_OnClick()
  ThisScript.SysAdminModeOn
   'Проверяем и красим атрибуты
   AttrStr = "ATTR_NAME,ATTR_TENDER_UNIQUE_NUM,ATTR_TENDER_FIRST_PRICE,ATTR_TENDER_ORGANIZER," &_
 "ATTR_TENDER_CLIENT,ATTR_TENDER_GET_OFFERS_STOP_TIME,ATTR_TENDER_SUMMARIZING_PLAN_TIME,ATTR_TENDER_RESP_OUPPKZ"
Check = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","FormAttrCheckAlarm",ThisForm, ThisObject, AttrStr)

If Check = True Then Exit Sub
  Result = False
  Set Obj = ThisObject
  Call PurchaseClose(Obj,Result)
  If Result = True Then
   ' - Состояние  
 AttrName = "ATTR_TENDER_POS"
  If Obj.Attributes.Has(AttrName) Then
    Obj.Attributes(AttrName).value = "Закупка закрыта"
  End If
  Obj.SaveChanges
  Thisform.close True
'    Call AttrsEnable(ThisForm,ThisObject)
  End If
End Sub

'Кнопка - Передать в работу
Sub BUTTON_TO_WORK_OnClick()
'Проверяем и красим атрибуты
  ThisScript.SysAdminModeOn
   AttrStr = "ATTR_NAME,ATTR_TENDER_UNIQUE_NUM,ATTR_TENDER_FIRST_PRICE,ATTR_TENDER_ORGANIZER,ATTR_TENDER_DOC_RESP," &_
 "ATTR_TENDER_CLIENT,ATTR_TENDER_GET_OFFERS_STOP_TIME,ATTR_TENDER_SUMMARIZING_PLAN_TIME,ATTR_TENDER_RESP_OUPPKZ"
Check = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","FormAttrCheckAlarm",ThisForm, ThisObject, AttrStr)
If Check = True Then Exit Sub
   ' Запускаем команду 
  Result = False
  Call PurchaseGoWork(ThisObject,Result)
  If Result = True Then
  Set Obj = ThisObject
     ' - Состояние  
 AttrName = "ATTR_TENDER_POS"
  If Obj.Attributes.Has(AttrName) Then
    Obj.Attributes(AttrName).value = "Закупка закрыта"
  End If
  ThisObject.SaveChanges
  Thisform.close True
'    ThisObject.SaveChanges
'    Call AttrsEnable(ThisForm,ThisObject)
'       Msgbox "Закупка передана в разработку", vbInformation
  End If
End Sub

'Кнопка - Выгрузить
Sub BUTTON_UPLOAD_OnClick()
  ThisScript.SysAdminModeOn
  Result = False
  Call PurchaseFilesUpload(ThisObject,Result)
  If Result = True Then
  Set Obj = ThisObject
  'Дата подачи заявки
  ThisObject.Attributes("ATTR_TENDER_PUBLIC_TIME").Value = Date
    ' - Состояние 
  AttrName = "ATTR_TENDER_POS"
  If Obj.Attributes.Has(AttrName) Then
    Obj.Attributes(AttrName).value = "Заявка опубликована. Мониторинг закупки на сайте"
  End If
    ThisObject.SaveChanges
    Call AttrsEnable(ThisForm,ThisObject)
  End If
End Sub

'Кнопка - Согласование участия
Sub BUTTON_APPROVAL_OF_PARTICIPATION_OnClick()
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",ThisObject,CU,"ROLE_INITIATOR"
'  RoleName = "ROLE_INITIATOR"
'  Set Roles = ThisObject.RolesForUser(CU)
'  If Roles.Has(RoleName) = False Then
'    Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",ThisObject,RoleName,CU.SysName)
'  End If
  AttrName = "ATTR_AGREEMENT_ENABLED"
  If ThisObject.Attributes.Has(AttrName) Then
    If ThisObject.Attributes(AttrName).Value = False Then ThisObject.Attributes(AttrName).Value = True
  End If
  ThisObject.SaveChanges
  ThisObject.Dictionary.Item("FormActive") = "FORM_KD_DOC_AGREE"
  Thisform.close True
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = ThisObject
  Dlg.Show
End Sub

'Кнопка - Согласование размещения
Sub BUTTON_AGREEMENT_PLACING_OnClick()
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  AttrName0 = "ATTR_TENDER_RESP_OUPPKZ"
  AttrName1 = "ATTR_TENDER_GROUP_CHIF"
  AttrName2 = "ATTR_TENDER_STATUS"
  RoleName = "ROLE_PURCHASE_RESPONSIBLE"
  Set User = Nothing
  
  Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",ThisObject,AttrName0)
  If User is Nothing Then
    'Если не заполнен атрибут Специалист ОУППКЗ
    Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",ThisObject,AttrName1)
  End If
  'Смена пользователя роли
  Check = False
  If not User is Nothing Then
    Set Roles = ThisObject.RolesByDef(RoleName)
    If Roles.Count > 0 Then
      For Each Role in Roles
        If not Role.User is Nothing Then
          If Role.User.SysName <> User.SysName Then
            Role.User = User
            Check = True
          End If
        End If
      Next
    Else
      Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",ThisObject,RoleName,User)
      Check = True
    End If
  End If
  'Оповещение о назначении роли
  If Check = True Then
    Call ThisApplication.ExecuteScript("CMD_MESSAGE", "SendMessage", 1512, User, ThisObject, Nothing, ThisApplication.RoleDefs(RoleName).Description, ThisObject.Description, CU.Description, Date)
  End If
  Set User = Nothing
  'Определение значения атрибута Статус закупки
  If ThisObject.Attributes.Has(AttrName2) Then
    Set Clfs = ThisApplication.Classifiers("NODE_TENDER_ORDER_STATUS").Classifiers.Find("Внешняя закупка")
    If not Clfs is Nothing Then
      Set Clf = Clfs.Classifiers.Find("1")
      If not Clf is Nothing Then
        ThisObject.Attributes(AttrName2).Classifier = Clf
      End If
    End If
  End If
  
  ThisObject.SaveChanges
  RoleName = "ROLE_INITIATOR"
  Set Roles = ThisObject.RolesForUser(CU)
  If Roles.Has(RoleName) = False Then
    Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",ThisObject,RoleName,CU.SysName)
  End If
  AttrName = "ATTR_AGREEMENT_ENABLED"
  If ThisObject.Attributes.Has(AttrName) Then
    If ThisObject.Attributes(AttrName).Value = False Then ThisObject.Attributes(AttrName).Value = True
  End If
  ThisObject.SaveChanges
  ThisObject.Dictionary.Item("FormActive") = "FORM_KD_DOC_AGREE"
  Thisform.close True
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = ThisObject
  Dlg.Show
End Sub

'Кнопка - Согласование уторговывания
Sub BUTTON_AGREEMENT_BARGAIN_OnClick()
Set CU = ThisApplication.CurrentUser
  RoleName = "ROLE_INITIATOR"
  Set Roles = ThisObject.RolesForUser(CU)
  If Roles.Has(RoleName) = False Then
    Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",ThisObject,RoleName,CU.SysName)
  End If
  AttrName = "ATTR_AGREEMENT_ENABLED"
  If ThisObject.Attributes.Has(AttrName) Then
    If ThisObject.Attributes(AttrName).Value = False Then ThisObject.Attributes(AttrName).Value = True
  End If
  ThisObject.SaveChanges
  ThisObject.Dictionary.Item("FormActive") = "FORM_KD_DOC_AGREE"
  Thisform.close True
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = ThisObject
  Dlg.Show
End Sub

'Кнопка - В разработку НКП
Sub BUTTON_TO_DEVELOP_NKP_OnClick()
   ThisScript.SysAdminModeOn
   'Проверяем и красим атрибуты
  ThisScript.SysAdminModeOn
   AttrStr = "ATTR_NAME,ATTR_TENDER_UNIQUE_NUM,ATTR_TENDER_FIRST_PRICE,ATTR_TENDER_ORGANIZER,ATTR_TENDER_DOC_RESP," &_
 "ATTR_TENDER_CLIENT,ATTR_TENDER_GET_OFFERS_STOP_TIME,ATTR_TENDER_SUMMARIZING_PLAN_TIME,ATTR_TENDER_RESP_OUPPKZ"
Check = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","FormAttrCheckAlarm",ThisForm, ThisObject, AttrStr)
If Check = True Then Exit Sub
   ' Запускаем команду 
  Result = False
  Call PurchaseGoWork(ThisObject,Result)
  If Result = True Then
   Set Obj = ThisObject
   ' - Состояние 
  AttrName = "ATTR_TENDER_POS"
  If Obj.Attributes.Has(AttrName) Then
    Obj.Attributes(AttrName).value = "Разработка НКП"
  End If
  ThisObject.SaveChanges
  Thisform.close True
  End If
  
'  'Маршрут
'  StatusName = "STATUS_TENDER_OUT_IN_WORK"
'  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",ThisObject,ThisObject.Status,ThisObject,StatusName)
'  If RetVal = -1 Then
'    Obj.Status = ThisApplication.Statuses(StatusName)
'  End If
'  
'  'Проверка соответствия ролей-атрибутов
'  RoleName = "ROLE_TENDER_DOCS_RESP_DEVELOPER"
'  Set User0 = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",ThisObject,"ATTR_TENDER_PEO_CHIF")
'  Set User1 = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",ThisObject,"ATTR_TENDER_KP_DESI")
'  If not User0 is Nothing Then
'    If ThisObject.RolesForUser(User0).Has(RoleName) = False Then
'      Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",ThisObject,RoleName,User0.SysName)
'    End If
'    Call ThisApplication.ExecuteScript("CMD_MESSAGE","SendMessage",6008,User0,ThisObject,Nothing,ThisObject.Description)
'  End If
'  If not User1 is Nothing Then
'    If ThisObject.RolesForUser(User1).Has(RoleName) = False Then
'      Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",ThisObject,RoleName,User1.SysName)
'    End If
'    Call ThisApplication.ExecuteScript("CMD_MESSAGE","SendMessage",6008,User1,ThisObject,Nothing,ThisObject.Description)
'  End If
'  ThisObject.SaveChanges
'  ThisForm.Refresh
End Sub

'Кнопка - Выгрузить НКП
Sub BUTTON_UPLOAD_NKP_OnClick()
  ThisScript.SysAdminModeOn
  Result = False
  Call PurchaseFilesUpload(ThisObject,Result)
  If Result = True Then
    Set Obj = ThisObject
   ' - Состояние 
  AttrName = "ATTR_TENDER_POS"
  If Obj.Attributes.Has(AttrName) Then
    Obj.Attributes(AttrName).value = "Заявка с НКП опубликована. Мониторинг закупки на сайте"
  End If
    ThisObject.SaveChanges
    Call AttrsEnable(ThisForm,ThisObject)
  End If
End Sub

'Загрузить результаты
Sub BUTTON_LOAD_RESULT_OnClick()
 ThisApplication.ExecuteScript "CMD_TENDER_IN_PROTOCOL_LOAD", "Main", ThisObject
   ThisObject.Update
   ThisObject.Dictionary.Item("FormActive") = "FORM_TENDER_OUTSIDE_MAIN"
End Sub

'Функция проверки типа файла на доступные для объекта
Function CheckFileDef(Obj,FName)
  Set CheckFileDef = Nothing
  FExtension = "*." & Right(FName, Len(Fname) - InStrRev(FName, "."))
  For Each FDef In Obj.ObjectDef.FileDefs
    If InStr(FDef.Extensions, FExtension) <> 0 Then
      Set CheckFileDef = FDef
      Exit Function
    End If
  Next
End Function

sub SetChBox(src)
  set chk = thisForm.Controls("EDIT_ATTR_TENDER_ONLINE").ActiveX
  chk.buttontype = 4
  Chk.value = CBool(src.Attributes("ATTR_TENDER_ONLINE").Value)
end sub

Sub EDIT_ATTR_TENDER_ONLINE_Modified()
  ThisObject.Attributes("ATTR_TENDER_ONLINE").Value = ThisForm.Controls("EDIT_ATTR_TENDER_ONLINE").ActiveX.Value
End Sub

'Функция проверки атрибутов: Себестоимость, Цена заявки после уторговывания, Цена заявки
Function PriceCheck(Form,Obj)
  PriceCheck = True
  AttrName0 = "ATTR_TENDER_COST_PRICE"
  AttrName1 = "ATTR_TENDER_OFFERS_SECOND_PRICE"
  AttrName2 = "ATTR_TENDER_OFFERS_PRICE"
  If Obj.Attributes.Has(AttrName0) = False Then Exit Function
  If Obj.Attributes(AttrName0).Empty Then Exit Function
  If Obj.Attributes.Has(AttrName2) = False Then Exit Function
  If Obj.Attributes(AttrName2).Empty = False Then
    If Obj.Attributes(AttrName0).Value > Obj.Attributes(AttrName2).Value Then
      Msgbox "Себестоимость не может превышать цену заявки",vbExclamation
      PriceCheck = False
    End If
  Else
    If Obj.Attributes.Has(AttrName1) = False Then Exit Function
    If Obj.Attributes(AttrName1).Empty Then Exit Function
    If Obj.Attributes(AttrName0).Value > Obj.Attributes(AttrName1).Value Then
      Msgbox "Себестоимость не может превышать цену заявки",vbExclamation
      PriceCheck = False
    End If
  End If
End Function


Sub BUTTON_ORDER_OnClick()
'"NODE_KD_PR_DIRECT"
  Set Obj = ThisObject
  set objType = thisApplication.ObjectDefs("OBJECT_KD_DIRECTION")
  Set Order = Create_Doc_by_Type(objType, Obj)
  If Order Is nothing Then Exit Sub
 
  AttrName = "ATTR_TENDER_ORDER"

  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F",Obj, AttrName, Order, True
'  If Obj.Attributes.Has(AttrName) = False Then Exit Sub


'  Obj.Attributes(AttrName).Value = Create_Doc_by_Type
End Sub

Sub BUTTON_ADD_CONTRACT_OnClick()
  Set cls = ThisApplication.Classifiers.FindBySysId("NODE_CONTRACT_PRO")
  Set oContr = ThisApplication.ExecuteScript("CMD_DLL_CONTRACTS","CreateContractByClass",ThisObject,cls)
End Sub

' Передаем закупку в ПЭО
Sub BUTTON_GO_PEO_OnClick()
ans = msgbox("Завершить разработку технической части?",vbQuestion+vbYesNo,"Завершение подготовки документации")
    If ans <> vbYes Then exit Sub
Set Obj = ThisObject

'  Set u1 = Nothing 'Ответственый за подготовку
  Set u2 = Nothing ' Руководитель ПЭО
'  If Obj.Attributes.Has(AttrName1) Then
'    If Obj.Attributes(AttrName1).Empty = False Then
'      If not Obj.Attributes(AttrName1).User is Nothing Then
'      Set u1 = Obj.Attributes(AttrName1).User
'      End If
'    End If
'  End If
 AttrName2 = "ATTR_TENDER_PEO_CHIF"
  If Obj.Attributes.Has(AttrName2) Then
    If Obj.Attributes(AttrName2).Empty = False Then
      If not Obj.Attributes(AttrName2).User is Nothing Then
       Set u2 = Obj.Attributes(AttrName2).User
      End If
    End If
  End If

  'Создание роли и поручения Руководителю ПЭО. 
      Set uToUser = u2
      Set uFromUser = ThisApplication.CurrentUser
      resol = "NODE_CORR_REZOL_POD"
      ObjType = "OBJECT_KD_ORDER_NOTICE"
      txt = "Прошу назначить ответственного и проконтролировать подготовку материалов для заявки " & Obj.Description 
      If not uToUser is Nothing Then
      ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,uToUser,uFromUser,resol,txt,PlanDate
      ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,uToUser,"ROLE_TENDER_KP_DESI,ROLE_INITIATOR," 'Роли Руководителю ПЭО
      End If
   
      Msgbox "Закупка " & Obj.Description   & chr(10) & chr(10) & "передана в работу ползователю " _
      & chr(10) & chr(10) & uToUser.Description & chr(10) & chr(10) & "для разработки экономической части",vbInformation
'      If Check = false then  Msgbox "Закупка """ & Obj.Description & """ передана в работу ползователю " & u1.Description ,vbInformation
       'Заполнение атрибута
  AttrName = "ATTR_TENDER_POS"
  If Obj.Attributes.Has(AttrName) Then
    Obj.Attributes(AttrName).value = "Разработка ЭЧ"
  End If
  
'    Удаление роли сотруднику
'     Call ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","RoleUserDel",Obj,uFromUser, "ROLE_TENDER_MATERIAL_RESP,ROLE_INITIATOR,")
  
  '  Закрываем форму, или обновляем, если пользователь Спец. группы отв. за закупку
  ThisObject.SaveChanges
  Thisform.close True
End Sub


Sub BUTTON_GO_GRP_OnClick()

    ans = msgbox("Завершить разработку?",vbQuestion+vbYesNo,"Завершение подготовки документации")
    If ans <> vbYes Then exit Sub
         Set Obj = ThisObject
         Set uToUser = Obj.Attributes("ATTR_TENDER_RESP_OUPPKZ").User 
         If uToUser Is Nothing Then Set uToUser = Obj.Attributes("ATTR_TENDER_GROUP_CHIF").User
         If uToUser Is Nothing Then Exit Sub
         Set uFromUser = ThisApplication.CurrentUser
         resol = "NODE_CORR_REZOL_POD"
         ObjType = "OBJECT_KD_ORDER_NOTICE"
         txt = "Прошу подготовить и разместить заявку по закупке """ & Obj.Description & """"
         PlanDate = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_TIME")
         PlanDate = Obj.Attributes("ATTR_TENDER_GET_OFFERS_STOP_TIME")
         If PlanDate = "" Then PlanDate = Date + 1
'         If planDate is Nothing Then planDate = Date + 1
         ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,uToUser,uFromUser,resol,txt,planDate

  'Маршрут
  StatusName = "STATUS_TENDER_OUT_IS_APPROVING"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  'Заполнение атрибута
  '- Статус закупки
  AttrName = "ATTR_TENDER_POS"
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
    pos = Obj.Attributes(AttrName).value
    End If
  End If
  If ThisObject.Attributes.Has("ATTR_TENDER_STATUS") Then
    Set Clfs = ThisApplication.Classifiers("NODE_TENDER_ORDER_STATUS").Classifiers.Find("Внешняя закупка")
    If not Clfs is Nothing Then
     If pos = "Разработка НКП" Then Set Clf = Clfs.Classifiers.Find("2")
     If pos = "Разработка ЭЧ" Then Set Clf = Clfs.Classifiers.Find("1")
      If not Clf is Nothing Then
        ThisObject.Attributes("ATTR_TENDER_STATUS").Classifier = Clf
      End If
    End If
  End If
  
  ' - Состояние
   If pos = "Разработка НКП" Then Obj.Attributes(AttrName).value = "Подготовка заявки к публикации НКП"
   If pos = "Разработка ЭЧ" Then Obj.Attributes(AttrName).value = "Подготовка заявки к публикации"
 
  
  'Создание роли
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,uToUser,"ROLE_PURCHASE_RESPONSIBLE,ROLE_INITIATOR" 'Роли Сотруднику Группы
   '  Закрываем форму
  ThisObject.SaveChanges
  Thisform.close True
End Sub

'Кнопка Добавить Техническое предложение
Sub BUTTON_ADD_TP_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","NewDocByTipe",ThisObject,"Техническое предложение",True,false,True,True
'(Obj,tp,pl,wk,pb,loc)
End Sub
'Кнопка Добавить Коммерческое предложение
Sub BUTTON_ADD_KP_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","NewDocByTipe",ThisObject,"Коммерческое предложение",True,false,True,True
End Sub

Sub BUTTON_ADD_NKP_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","NewDocByTipe",ThisObject,"Новое коммерческое предложение",True,false,True,True
End Sub

Sub Show_LinkClick(Button, Shift, url, bCancelDefault)
 BtnList = "BUTTON_CUSTOM_SAVE,BUTTON_CUSTOM_CANCEL,BUTTON_ADD_APPROVE,BUTTON_APPROVAL_OF_PARTICIPATION," &_
  "BUTTON_APPROVE,BUTTON_TO_WORK,BUTTON_AGREEMENT_PLACING,BUTTON_UPLOAD,BUTTON_AGREEMENT_BARGAIN," &_
  "BUTTON_TO_DEVELOP_NKP,BUTTON_UPLOAD_NKP,BUTTON_LOAD_RESULT,BUTTON_CLOSE,BUTTON_GO_PEO,BUTTON_GO_GRP," &_
  "BUTTON_ADD_TP,BUTTON_ADD_KP,BUTTON_ADD_NKP"
  Arr = Split(BtnList,",")
   Set Obj = ThisObject
   Set Dict = ThisApplication.Dictionary(Obj.Guid & " - BlockRoute")
   Dict.RemoveAll
  'Запоминаем как было
  For i = 0 to Ubound(Arr)
    BtnName = Arr(i)
    If ThisForm.Controls.Has(BtnName) Then Dict.Item(BtnName) = ThisForm.Controls(BtnName).Visible
  Next
    
  'Показываем все
  For i = 0 to Ubound(Arr)
    BtnName = Arr(i)
    If ThisForm.Controls.Has(BtnName) Then ThisForm.Controls(BtnName).Visible = True
      ThisForm.Controls(BtnName).Enabled = false
  Next
 ThisForm.Refresh 
 thisApplication.Utility.Sleep 5000
 
  For i = 0 to Ubound(Arr)
    BtnName = Arr(i)
    If ThisForm.Controls.Has(BtnName) Then
    ThisForm.Controls(BtnName).Visible = Dict.Item(BtnName)
    ThisForm.Controls(BtnName).Enabled = True
    End If
  Next
  ThisForm.Refresh 
End Sub


Sub BUTTON1_OnClick()
'txt = "ТЕСТ"
''ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","OrderGenByList",ThisObject, "ATTR_TENDER_OUT_ORDER_TO_WORK_CASTOM", txt
'a = ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","GetUnicUserList",ThisObject, "ATTR_TENDER_OUT_ORDER_TO_WORK_CASTOM", "ATTR_RESPONSIBLE")
' msgbox a

End Sub
'=====================================================================



'Кнопка - Загрузить протокол
Sub BUTTON_LOAD_PROTOCOL_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_IN_PROTOCOL_LOAD", "Main", ThisObject
ThisObject.Update
'ThisObject.Dictionary.Item("FormActive") = "FORM_TENDER_MATERIAL_EIS"
End Sub

Sub BTN_TIME_SHOW_LinkClick(Button, Shift, url, bCancelDefault)
ThisForm.Controls("ATTR_TENDER_GET_OFFERS_STOP_TIME_VAL").Visible = True
ThisForm.Controls("ATTR_TENDER_OFFERS_OPEN_TIME_VAL").Visible = True
End Sub

Sub BTN_TIME_SHOW_1_LinkClick(Button, Shift, url, bCancelDefault)
ThisForm.Controls("ATTR_TENDER_GET_OFFERS_STOP_TIME_VAL").Visible = not ThisForm.Controls("ATTR_TENDER_GET_OFFERS_STOP_TIME_VAL").Visible
ThisForm.Controls("ATTR_TENDER_OFFERS_OPEN_TIME_VAL").Visible = not ThisForm.Controls("ATTR_TENDER_OFFERS_OPEN_TIME_VAL").Visible
End Sub
