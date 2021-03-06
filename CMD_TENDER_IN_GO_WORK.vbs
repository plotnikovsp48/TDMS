' Команда - Взять в разработку (Внутренняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Sub Main(Obj)
  ThisScript.SysAdminModeOn
  
  'Запрос подтверждения
  Key = Msgbox("Перевести закупку в разработку?", vbQuestion+vbYesNo)
  If Key = vbNo Then
    Exit Sub
  End If
  
  'Маршрут
  StatusName = "STATUS_TENDER_IN_WORK"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  'Создание роли
  Set CU = ThisApplication.CurrentUser
  RoleName = "ROLE_PURCHASE_RESPONSIBLE"
  If Obj.RolesForUser(CU).Has(RoleName) = False Then
    Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,CU)
  End If
  
  'Создание документа закупки
  Set Doc = InfoDocGet(Obj)
  If not Doc is Nothing Then
    Msgbox "Закупка взята в разработку.", vbInformation
  Else
  AttrStr = "ATTR_TENDER_FACT_MATERIAL_TAKE_OFF_DATA,ATTR_TENDER_ITEM_PRICE_MAX_VALUE," &_
      "ATTR_NDS_VALUE,ATTR_LOT_NDS_VALUE,ATTR_TENDER_START_WORK_DATA,ATTR_TENDER_INVOCE_PUBLIC_DATA," &_
      "ATTR_TENDER_ADVANCE_PLAN_PAY,ATTR_TENDER_ADDITIONAL_REQUIREMENTS,ATTR_TENDER_BID_REQUIREMENTS," &_
      "ATTR_TENDER_GUARANTEE_REQUIREMENTS,ATTR_TENDER_RF_CONF_REQUIREMENTS_DOC_LIST," &_
      "ATTR_TENDER_EXPERIENCE_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_PERSONAL_CONF_REQUIREMENTS_DOC_LIST," &_
      "ATTR_TENDER_RIG_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_ISO9001_REQUIREMENTS,ATTR_TENDER_SUM_NDS," &_
      "ATTR_TENDER_ADDITIONAL_INFORMATION,ATTR_TENDER_END_WORK_DATA,ATTR_TENDER_POSSIBLE_CLIENT"
  
'    AttrStr = "ATTR_TENDER_FACT_MATERIAL_TAKE_OFF_DATA,ATTR_TENDER_ITEM_PRICE_MAX_VALUE," &_
'    "ATTR_LOT_NDS_VALUE,ATTR_TENDER_START_END_WORK_DATA,ATTR_TENDER_INVOCE_PUBLIC_DATA," &_
'    "ATTR_TENDER_ADVANCE_PLAN_PAY,ATTR_TENDER_ADDITIONAL_REQUIREMENTS,ATTR_TENDER_BID_REQUIREMENTS," &_
'    "ATTR_TENDER_GUARANTEE_REQUIREMENTS,ATTR_TENDER_RF_CONF_REQUIREMENTS_DOC_LIST," &_
'    "ATTR_TENDER_EXPERIENCE_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_PERSONAL_CONF_REQUIREMENTS_DOC_LIST," &_
'    "ATTR_TENDER_RIG_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_ISO9001_REQUIREMENTS,ATTR_TENDER_ADDITIONAL_INFORMATION"
  
    Set NewObj = Obj.Objects.Create("OBJECT_PURCHASE_DOC")
    NewObj.Status = ThisApplication.Statuses("STATUS_DOC_IN_WORK")
    NewObj.Attributes("ATTR_RESPONSIBLE").User = CU
    NewObj.Attributes("ATTR_DOCUMENT_NAME").Value = "Информационная карта"
    AttrName = "ATTR_KD_USER_DEPT"
    If CU.Attributes.Has(AttrName) Then
      If CU.Attributes(AttrName).Empty = False Then
        If not CU.Attributes(AttrName).Object is Nothing Then
          NewObj.Attributes("ATTR_T_TASK_DEPARTMENT").Object = CU.Attributes(AttrName).Object
        End If
      End If
    End If
    
    NewObj.Attributes("ATTR_PURCHASE_DOC_TYPE").Classifier = _
      ThisApplication.Classifiers.Find("Вид документа закупки").Classifiers.Find("Информационная карта")
    ThisApplication.ExecuteScript "CMD_DLL","AttrsSyncBetweenObjs", Obj, NewObj, AttrStr
    ThisApplication.ExecuteScript "OBJECT_PURCHASE_DOC","Pricesync", NewObj
'    ThisApplication.ExecuteScript "OBJECT_PURCHASE_DOC","Pricesync", Obj
    Msgbox "Закупка взята в разработку. Информационная карта создана", vbInformation
  End If
  
  ThisScript.SysAdminModeOff
End Sub

'Функция возвращает документ закупки с типом "Информационная карта"
Function InfoDocGet(Obj)
  Set InfoDocGet = Nothing
  Set Clf0 = ThisApplication.Classifiers.Find("Вид документа закупки")
  If Clf0 is Nothing Then Exit Function
  Set Clf = Clf0.Classifiers.Find("Информационная карта")
  If Clf is Nothing Then Exit Function
  AttrName = "ATTR_PURCHASE_DOC_TYPE"
  For Each Doc in Obj.Objects
    If Doc.ObjectDef.SysName = "OBJECT_PURCHASE_DOC" Then
      If Doc.Attributes.Has(AttrName) = True Then
        If Doc.Attributes(AttrName).Empty = False Then
          If not Doc.Attributes(AttrName).Classifier is Nothing Then
            If Doc.Attributes(AttrName).Classifier.SysName = Clf.SysName Then
              Set InfoDocGet = Doc
              Exit Function
            End If
          End If
        End If
      End If
    End If
  Next
End Function

'Sub MessageSend(Obj)
'  Str = ""
'  Call UserStackFill(Obj,"ROLE_TENDER_INICIATOR",str)
'  
'  
'  If Str <> "" Then
'    Arr = Split(Str,",")
'    Count = UBound(Arr)
'    If Count >=0 Then
'      For i = 0 to Count
'        If ThisApplication.Users.Has(Arr(i)) Then
'          Set u = ThisApplication.Users(Arr(i))
'          ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 6001, u, Obj, Nothing, Obj.Description, ThisApplication.CurrentUser.Description 
'        End If
'      Next
'    End If
'  End If
'End Sub

''Процедура заполнения строки пользователей для уведомления
'Sub UserStackFill(Obj,RoleName,str)
'  Set Roles = Obj.RolesByDef(RoleName)
'  For Each Role in Roles
'    If not Role.User is Nothing Then
'      Set User = Role.User
'    Else
'      Set User = Role.Group
'    End If
'    If Str <> "" Then
'      If InStr(Str,User.SysName) = 0 Then
'        Str = Str & "," & User.SysName
'      End If
'    Else
'      Str = User.SysName
'    End If
'  Next
'End Sub
