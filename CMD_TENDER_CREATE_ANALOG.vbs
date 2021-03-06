' Команда - Создать аналогичную закупку
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Set Main = Nothing
  Set Root = Nothing
  NeedToSelect = True
  If Obj.ObjectDefName = "OBJECT_TENDER_INSIDE" Then
    If Obj.parent.Attributes.Has("ATTR_TENDER_TYPE") Then
      If Obj.parent.Attributes("ATTR_TENDER_TYPE").Empty = False Then
        Set Clf = Obj.parent.Attributes("ATTR_TENDER_TYPE").Classifier
        oDefName = Replace(Clf.SysName,"NODE","OBJECT")
        Set Root = GetTenderRoot(oDefName)
        If Not Root Is Nothing Then
          NeedToSelect = False
          Set Root = GetTenderRoot(oDefName)
        End If
      End If
    End If
    
   
  If Root Is Nothing Then Exit Function
  Root.Permissions = SysAdminPermissions
  On error resume next
  Set NewObj = Root.Objects.Create(oDefName)
  
  ' Если создание объекта отменилось
  If err.Number <>0 Then
    err.clear
    Exit Function
  End If
  Call SetAttrs(Obj,NewObj)
  Set Main = NewObj 
 
 
   Key = Msgbox("Копировать лоты?", vbQuestion+vbYesNo)
       If Key = vbYes Then
  For Each Child in Obj.Objects
    If Child.ObjectDefName = "OBJECT_PURCHASE_LOT" Then
    Set NewChObj = Main.Objects.Create("OBJECT_PURCHASE_LOT")
    Call SetAttrs(Child,NewChObj)
    Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = NewChObj
  RetVal = Dlg.Show
  If NewChObj.StatusName = "STATUS_LOT_IN_WORK" Then
    Set Dict = ThisApplication.Dictionary(ThisObject.GUID)
    If Dict.Exists("ObjEdit") = False Then
      If Not RetVal Then
        NewChObj.Erase
        End If
    End If
  End If
    End If
    Next 
  End If
  
 RegNum = ThisApplication.ExecuteScript("CMD_S_NUMBERING","PurchaseInsideNumGet",Main,"")
    If RegNum <> "" Then
      Arr = Split(RegNum,"#")
      Num = cLng(Arr(1))
      RegNum = Replace(RegNum,"#","")
      Main.Attributes("ATTR_TENDER_CLIENTS_NUM").Value = RegNum
    End If
    
 Set Dlg = ThisApplication.Dialogs.EditObjectDlg
 Dlg.Object = NewObj
 RetVal = Dlg.Show
  If NewObj.StatusName = "STATUS_TENDER_DRAFT" Then
    Set Dict = ThisApplication.Dictionary(ThisObject.GUID)
    If Dict.Exists("ObjEdit") = False Then
      If Not RetVal Then
        NewObj.Erase
        Exit Function
      End If
    End If
  End If
  End If
 
End Function
    
  Sub SetAttrs(BaseObj,Obj)
  If BaseObj Is Nothing Or Obj Is Nothing Then Exit Sub
  ThisScript.SysAdminModeOn
  
  If BaseObj.ObjectDefName = "OBJECT_TENDER_INSIDE" Then
  
 AttrStr = "ATTR_TENDER_PRIORITY,ATTR_TENDER_SMOLL_PRICE_FLAG,ATTR_TENDER_ONLINE,ATTR_TENDER_TIPE,ATTR_TENDER_PLAN_PART_NAME," &_
"ATTR_TENDER_REASON,ATTR_TENDER_ANALOG_LIST,ATTR_TENDER_ANALOG_TABLE,ATTR_TENDER_COMPETITIVE_METHOD_NAME," &_
"ATTR_TENDER_URGENTLY_FLAG,ATTR_TENDER_URGENCY_REASON,ATTR_TENDER_STARTER_NAME,ATTR_TENDER_METHOD_NAME," &_
"ATTR_TENDER_REASON_POINT,ATTR_TENDER_SMALL_BUSINESS_FLAG,ATTR_TENDER_SMSP_SUBCONTRACT_FLAG,ATTR_TENDER_SMSP_SUBCONTRACT_SUMM," &_
"ATTR_TENDER_SMSP_EXCLUDE_CODE,ATTR_TENDER_PAY_CONDITIONS,ATTR_TENDER_BALANS_CODE,ATTR_TENDER_BUDGET_ITEM_CODE," &_
"ATTR_TENDER_TECH_PART_RESP,ATTR_TENDER_MATERIAL_STATUS,ATTR_TENDER_CLIENT_NOTES,ATTR_TENDER_INVOCE_PUBLIC_DATA," &_
"ATTR_TENDER_ITEM_PRICE_MAX_VALUE,ATTR_TENDER_POSSIBLE_CLIENT,ATTR_TENDER_ADVANCE_PLAN_PAY,ATTR_TENDER_ADDITIONAL_REQUIREMENTS," &_
"ATTR_TENDER_BID_REQUIREMENTS,ATTR_TENDER_GUARANTEE_REQUIREMENTS,ATTR_TENDER_RIG_CONF_REQUIREMENTS_DOC_LIST," &_
"ATTR_TENDER_EXPERIENCE_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_PERSONAL_CONF_REQUIREMENTS_DOC_LIST," &_
"ATTR_TENDER_RF_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_ISO9001_REQUIREMENTS,ATTR_TENDER_ADDITIONAL_INFORMATION," &_
"ATTR_TENDER_EXPERT_LIST"
  End If

 If BaseObj.ObjectDefName = "OBJECT_PURCHASE_LOT" Then

 AttrStr = "ATTR_LOT_NUM,ATTR_TENDER_LOT_POS_TYPE,ATTR_TENDER_OKVED2,ATTR_TENDER_OKPD2," &_
 "ATTR_TENDER_CURRENCY,ATTR_TENDER_OKATO,ATTR_TENDER_OBJECT_TYPE,ATTR_LOT_DETAIL," &_
 "ATTR_TENDER_LOT_NAME,ATTR_TENDER_LOT_PRICE,ATTR_TENDER_NOMENCLATUR_GROPE_MTR,ATTR_TENDER_NDS_PRICE," &_
 "ATTR_TENDER_PLAN_PART_NAME,ATTR_TENDER_FINANS_PAR,ATTR_TENDER_LOT_NDS_PRICE,ATTR_LOT_NDS_VALUE"
  End If 
   
ThisApplication.ExecuteScript "CMD_DLL","AttrsSyncBetweenObjs", BaseObj, Obj, AttrStr
    
End Sub

Function GetTenderRoot(ObjDefName)
  Set GetTenderRoot = Nothing
  ' Стандартная функция с раскладкой по годам. оставляем на всякий случай, но комментируем
  'Set ObjRoots = thisApplication.ExecuteScript("CMD_KD_FOLDER","GET_FOLDER","",thisApplication.ObjectDefs(ObjDefName))
  Set ObjRoots = GETFOLDER("",thisApplication.ObjectDefs(ObjDefName))
    if ObjRoots is nothing then  
      msgBox "Не удалось создать папку", vbCritical, "Объект не был создан"
      exit Function
    end if
    Set GetTenderRoot = ObjRoots
End Function

' Функция определения корневой папки, если не надо раскладывать по годам
function GETFOLDER(year_my, objType)
    set GETFOLDER = nothing
    thisscript.SysAdminModeOn
    if objType is nothing then exit function
    if objType.SuperObjectDefs.Has("OBJECT_KD_ORDER") then set objType = thisApplication.ObjectDefs("OBJECT_KD_ORDER")
    attrName = "ATTR_FOLDER_" & objType.SysName
    if not thisApplication.Attributes.Has(attrName) then exit function
    folder_Guid = thisApplication.Attributes(attrName).Value
    set folder_Obj =  thisApplication.GetObjectByGUID(folder_Guid)
    if folder_Obj is nothing then exit function
    
    set GETFOLDER = folder_Obj
end function


