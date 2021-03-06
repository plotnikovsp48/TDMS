' Команда - Создать закупку
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.
USE "CMD_DLL"

Call Main(ThisObject)

Function Main(Obj)
  Set Main = Nothing
  Set Root = Nothing
  NeedToSelect = True
  If Obj.ObjectDefName = "OBJECT_PURCHASE_FOLDER" Then
    If Obj.Attributes.Has("ATTR_TENDER_TYPE") Then
      If Obj.Attributes("ATTR_TENDER_TYPE").Empty = False Then
        Set Clf = Obj.Attributes("ATTR_TENDER_TYPE").Classifier
        oDefName = Replace(Clf.SysName,"NODE","OBJECT")
        Set Root = GetTenderRoot(oDefName)
        If Not Root Is Nothing Then
          NeedToSelect = False
          Set Root = GetTenderRoot(oDefName)
        End If
      End If
    End If
  ElseIf Obj.ObjectDefName = "OBJECT_CONTRACT" Then
    oDefName = "OBJECT_TENDER_INSIDE"
    NeedToSelect = False
  ElseIf Not Obj.Parent Is Nothing Then
    If Obj.Parent.ObjectDefName = "OBJECT_PURCHASE_FOLDER" Then
      If Obj.Parent.Attributes.Has("ATTR_TENDER_TYPE") Then
        If Obj.Parent.Attributes("ATTR_TENDER_TYPE").Empty = False Then
          Set Clf = Obj.Parent.Attributes("ATTR_TENDER_TYPE").Classifier
          oDefName = Replace(Clf.SysName,"NODE","OBJECT")
          If Not Root Is Nothing Then
            NeedToSelect = False
          End If
        End If
      End If
    End If
  End If
    
  If NeedToSelect = True Then
    If ThisApplication.Classifiers.Has("Вид закупки") Then
      Set Clfs = ThisApplication.Classifiers("Вид закупки").Classifiers
      Set Dlg = ThisApplication.Dialogs.SelectDlg
      Dlg.Caption = "Выбор типа закупки"
      Dlg.SelectFrom = Clfs
      Dlg.SetSelection = Clfs(0)
      If Dlg.Show Then
        If Dlg.Objects.Count <> 0 Then
          Set Clf = Dlg.Objects(0)
          oDefName = Replace(Clf.SysName,"NODE","OBJECT")
          Set Root = GetTenderRoot(oDefName)
        Else
          Msgbox "Необходимо выбрать тип закупки", vbExclamation
          Exit Function
        End If
      Else 
        Exit Function
      End If
    End If
  End If
  
  Set Root = GetTenderRoot(oDefName)
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
  ' Копируем из договора атрибуты
  ' По требованию Протасова
  ' 19.01.2018
  Call SetBaseDocInfo(Obj,NewObj)
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = NewObj
  RetVal = Dlg.Show
  If NewObj.StatusName = "STATUS_TENDER_OUT_PLANING" Or NewObj.StatusName = "STATUS_TENDER_DRAFT" Then
    Set Dict = ThisApplication.Dictionary(ThisObject.GUID)
    If Dict.Exists("ObjEdit") = False Then
      If Not RetVal Then
        NewObj.Erase
        Exit Function
      End If
    End If
  End If
  Set Main = NewObj
End Function

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

Sub SetAttrs(BaseObj,Obj)
  If BaseObj Is Nothing Or Obj Is Nothing Then Exit Sub
  
  If BaseObj.ObjectDefName = "OBJECT_CONTRACT" Then
    Obj.Attributes("ATTR_TENDER_REASON").Value = BaseObj.Attributes("ATTR_CONTRACT_SUBJECT").Value
  End If
End Sub

' Копирование атрибутов из базового документа
Sub SetBaseDocInfo(BaseObj,Obj)
  If BaseObj Is Nothing Then Exit Sub
  If Obj Is Nothing Then Exit Sub
'  Call ThisApplication.ExecuteScript ("CMD_S_DLL","SetLinkToBaseDoc",BaseObj,Obj,"Документ-основание")
  
  Select Case BaseObj.ObjectDefName
'    Case "OBJECT_PURCHASE_OUTSIDE" ' Договор создается из внешней закупки
'      ' Атрибут закупка
'      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", Obj, "ATTR_TENDER", BaseObj, True
'      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", Obj, "ATTR_CONTRACT_wTENDER", True, True
'      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", Obj, "ATTR_PURCHASE_FROM_EI", False, True
'      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", Obj, "ATTR_CONTRACT_SUBJECT", BaseObj.Attributes("ATTR_NAME"), True
'      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", Obj, "ATTR_CUSTOMER", BaseObj.Attributes("ATTR_TENDER_CLIENT").Object, True
'      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", Obj, "ATTR_CURATOR", BaseObj.Attributes("ATTR_TENDER_CURATOR").User, True

    Case "OBJECT_CONTRACT" ' Закупка создается из договора
      ' Атрибут закупка
      ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F", Obj, "ATTR_TENDER", BaseObj, True
      
      AttrName0 = "ATTR_TENDER_METHOD_NAME"
      If BaseObj.Attributes.Has(AttrName0) and Obj.Attributes.Has(AttrName0) Then
        Call AttrValueCopy(BaseObj.Attributes(AttrName0),Obj.Attributes(AttrName0))
      End If
      
      AttrName1 = "ATTR_TENDER_REASON_POINT"
      AttrName0 = "ATTR_PURCHASE_BASIS"
      If BaseObj.Attributes.Has(AttrName0) and Obj.Attributes.Has(AttrName1) Then
        Call AttrValueCopy(BaseObj.Attributes(AttrName0),Obj.Attributes(AttrName1))
      End If
          
      AttrName1 = "ATTR_TENDER_SMSP_EXCLUDE_CODE"
      AttrName0 = "ATTR_SMSP_EXCLUDE_CODE"
      If BaseObj.Attributes.Has(AttrName0) and Obj.Attributes.Has(AttrName1) Then
        Call AttrValueCopy(BaseObj.Attributes(AttrName0),Obj.Attributes(AttrName1))
      End If
      
      AttrName1 = "ATTR_TENDER_WORK_START_PLAN_DATA"
      AttrName0 = "ATTR_STARTDATE_PLAN"
      If BaseObj.Attributes.Has(AttrName0) and Obj.Attributes.Has(AttrName1) Then
        Call AttrValueCopy(BaseObj.Attributes(AttrName0),Obj.Attributes(AttrName1))
      End If
      
      AttrName1 = "ATTR_TENDER_WORK_END_PLAN_DATA"
      AttrName0 = "ATTR_ENDDATE_PLAN"
      If BaseObj.Attributes.Has(AttrName0) and Obj.Attributes.Has(AttrName1) Then
        Call AttrValueCopy(BaseObj.Attributes(AttrName0),Obj.Attributes(AttrName1))
      End If
          
      AttrName1 = "ATTR_TENDER_PAY_CONDITIONS"
      AttrName0 = "ATTR_DUE_DATE"
      If BaseObj.Attributes.Has(AttrName0) and Obj.Attributes.Has(AttrName1) Then
        Call AttrValueCopy(BaseObj.Attributes(AttrName0),Obj.Attributes(AttrName1))
      End If
    Case Else
  End Select
End Sub


