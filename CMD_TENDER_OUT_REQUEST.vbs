' Команда - Запросить доступ
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г. BUTTON_REQUEST
'txt = "Прошу предоставить доступ"
Call Main(ThisObject,txt)

Function Main(Obj, txt)
If IsEmpty(txt) = True Then txt = "Прошу предоставить доступ"
'  Main = False
  ThisScript.SysAdminModeOn
  Set CU = ThisApplication.CurrentUser
 
     
  If Obj.Parent.Attributes.Has("ATTR_TENDER_GROUP_CHIF") Then
  Set Resp = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj.Parent,"ATTR_TENDER_GROUP_CHIF")
  ' Resp = Obj.Parent.Attributes("ATTR_TENDER_GROUP_CHIF").value
  End If  
 
'  If Obj.Attributes.Has("ATTR_TENDER_RESP_OUPPKZ") Then  AttrResp = Obj.Attributes("ATTR_TENDER_RESP_OUPPKZ").value
  If Obj.Attributes.Has("ATTR_TENDER_GROUP_CHIF") Then
  Set Resp = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,"ATTR_TENDER_GROUP_CHIF")
   ' Resp = Obj.Attributes("ATTR_TENDER_GROUP_CHIF").value
  End If 

  
  PlanDate = Date + 3
 
  AttrName = "ATTR_TENDER_COST_PRICE"
  If Obj.Attributes.Has(AttrName) Then
   If Obj.Attributes(AttrName).Empty = True Then 
   Msgbox "Поле не заполненно", vbExclamation 
   Exit Function  
   End If 
  End If 
'  If Obj.Attributes.Has(AttrName) Then
'   If Obj.Attributes(AttrName).Empty = False Then

'  ans = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, 6015, AttrResp) ' Запрос подтверждения  
  If not Resp is Nothing Then 
   ans = msgbox("Запросить доступ?" & chr(10) & "(Пользователю """ & Resp.Description & """ будет выдано поручение)" ,vbQuestion+vbYesNo,"Запрос доступа")
  If ans = vbNo Then Exit Function   
'  ElseIf
   'Создание поручения
    resol = "NODE_CORR_REZOL_OTV"
    ObjType = "OBJECT_KD_ORDER_NOTICE"
'    txt = "Прошу предоставить данные по себестоимости закупки"
    
      ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,Resp,CU,resol,txt,PlanDate
      Msgbox "Пользователю """ & Resp.Description & """ выдано поручение - запрос на предоставление данных. Ответ должен быть дан до " & PlanDate & " ",vbInformation
    End If
   ThisScript.SysAdminModeOff
   End Function


