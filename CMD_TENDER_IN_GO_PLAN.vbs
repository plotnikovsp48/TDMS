' Команда - Запланировать (Внутренняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisForm,ThisObject)

Function Main(Form, Obj)

  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
  Main = True
' Проверка перед запланированием
CheckBeforeClose = False
  str = CheckRequedFieldsBeforeClose(Form, Obj)
  If str <> "" Then
    Msgbox "Не заполнены обязательные атрибуты: " & str,vbExclamation
    
    Exit Function
  End If
 
 If Obj.Attributes("ATTR_TENDER_ASEZ_STATUS").Classifier.Description <> "Утвержден" Then
   Msgbox "Поле Статус закупки в АСЭЗ должно быть в значении Утвержден",vbInformation
   Exit Function
 End If
  
  'Запрос подтверждения
  AttrName0 = "ATTR_TENDER_RESP"
  Set u = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName0)
  Key = Msgbox("Запланировать закупку?", vbQuestion+vbYesNo)
'  Key = Msgbox("Пользователю " & u.Description & " будет выдано поручение. Перевести закупку в запланированные?", vbQuestion+vbYesNo)
  If Key = vbNo Then
    Exit Function
  End If
  
  'Маршрут
  StatusName = "STATUS_TENDER_IN_PLAN"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  Main = False
  Obj.SaveChanges ' Сохраняем
  'Создание поручения
  AttrName0 = "ATTR_TENDER_RESP"
  AttrName1 = "ATTR_TENDER_PLAN_ZD_PRESENT"
  Set u = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName0)
  resol = "NODE_CORR_REZOL_POD"
  ObjType = "OBJECT_KD_ORDER_REP"
  txt = "Прошу предоставить материалы в группу для размещения в установленные сроки"
  PlanDate = ""
  If Obj.Attributes.Has(AttrName1) Then
    If Obj.Attributes(AttrName1).Empty = False Then
      PlanDate = Obj.Attributes(AttrName1).Value
    End If
  End If
  If PlanDate = "" Then PlanDate = Date + 1
  
  If not u is Nothing Then
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,u,CU,resol,txt,PlanDate
    If u.SysName <> CU.SysName Then
      Msgbox "Закупка запланирована. Пользователю """ & u.Description & """ выдано поручение",vbInformation
    Else
      Msgbox "Закупка запланирована.",vbInformation
    End If
  Else
    Msgbox "Закупка запланирована.",vbInformation
  End If
  Obj.Refresh 
  ThisScript.SysAdminModeOff
End Function

' Функция проверки заполнения обязательных полей
Function CheckRequedFieldsBeforeClose(Form, Obj)
  CheckRequedFieldsBeforeClose = ""
  str = ""
  '1. Уникальный номер закупки 
  If Obj.Attributes("ATTR_TENDER_UNIQUE_NUM").Empty = True Then
    CheckRequedFieldsBeforeClose = "Уникальный номер закупки"
    str = str & chr(10) & "- " & CheckRequedFieldsBeforeClose
    Atr = "ATTR_TENDER_UNIQUE_NUM"
    str1 = str1 & "," & Atr
    'Exit Function
  End If
  '2. Номер ППЗ 
  If Obj.Attributes("ATTR_TENDER_PPZ_NUM").Empty = True Then
    CheckRequedFieldsBeforeClose = "Номер ППЗ"
    str = str & chr(10) & "- " & CheckRequedFieldsBeforeClose
    Atr = "ATTR_TENDER_PPZ_NUM"
    str1 = str1 & "," & Atr
    'Exit Function
  End If
    '3. Фактическая дата утверждения в АСЭЗ  
  If Obj.Attributes("ATTR_TENDER_FACT_ASEZ_PRUVE_DATA").Empty = True Then
    CheckRequedFieldsBeforeClose = "Фактическая дата утверждения в АСЭЗ"
    str = str & chr(10) & "- " & CheckRequedFieldsBeforeClose
    Atr = "ATTR_TENDER_FACT_ASEZ_PRUVE_DATA"
    str1 = str1 & "," & Atr
    'Exit Function
  End If
     '4.  Статус закупки в АСЭЗ
  If Obj.Attributes("ATTR_TENDER_ASEZ_STATUS").Empty = True Then
    CheckRequedFieldsBeforeClose = "Статус закупки в АСЭЗ"
    str = str & chr(10) & "- " & CheckRequedFieldsBeforeClose
    Atr = "ATTR_TENDER_ASEZ_STATUS"
    str1 = str1 & "," & Atr
    'Exit Function
  End If
  CheckRequedFieldsBeforeClose = str
  If IsEmpty(Form) = False and str1 <> "" Then
     ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","MainControlsBackColorAlarm",Form, Obj, Str1
  End If
End Function
