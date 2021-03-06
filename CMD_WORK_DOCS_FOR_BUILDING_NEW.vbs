' Автор: Стромков С.А.
'
' Создание разделов
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

Dim o,p,arr(),cls,odef
Set p = ThisObject.Attributes("ATTR_PROJECT").Object
ThisObject.Permissions = SysAdminPermissions

Call Main (ThisObject)

Sub Main(Obj)
  If VarType(Obj)<>9 Then Exit Sub
  If Obj Is Nothing Then Exit Sub
  If Obj.Attributes.Has("ATTR_WORK_DOCS_FOR_BUILDING_TYPE") = False Then
    Obj.Attributes.Create("ATTR_WORK_DOCS_FOR_BUILDING_TYPE")
  End If
  If Obj.Attributes("ATTR_WORK_DOCS_FOR_BUILDING_TYPE").Empty = False Then
    Set cls = Obj.Attributes("ATTR_WORK_DOCS_FOR_BUILDING_TYPE").Classifier
    If Not Cls Is Nothing Then
      clsSysName = cls.SysName
        If clsSysName = "NODE_BUILDING_TYPE_BUILDING" Then
          msgbox "Невозможно создать полный комплект в составе полного комплекта здания/сооружения",vbCritical,"Ошибка"
          Exit Sub
        End If
    End If
'  Else
'    msgbox "Не задан тип полного комплекта",vbExclamation,"Не заполнен атрибут"
'    Exit Sub
  End If
  sObjDef = "OBJECT_WORK_DOCS_FOR_BUILDING"
  Set Obj =Create(sObjDef,Obj)
End Sub

'==============================================================================
' Проверка входных условий
'------------------------------------------------------------------------------
' sObjDef_:String - Системный идентификатор типа объекта
' p_:TDMSObject - Полный комплект или Стадия в составе которых создается полный комплект
' StartCondCheck: Boolean   True - входные условия выполнены
'                           False - входные условия не выполнены
'==============================================================================
Function Create(sObjDef_,p_)
  ThisScript.SysAdminModeOn
  Dim o,EditObjDlg,hnd
  Set Create = Nothing
  
  If VarType(p_)<>9 Then Exit Function
  
  If p_ Is Nothing Then Exit Function
  If  ThisApplication.ObjectDefs.Index(sObjDef_)=-1 Then Exit Function
  on error resume next
  Set o = p_.Objects.Create(sObjDef_)
  If o is nothing then exit Function
  Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
  o.Permissions = SysAdminPermissions 
  EditObjDlg.object = o
  EditObjDlg.ParentWindow = ThisApplication.hWnd
  If Not EditObjDlg.Show Then 
    o.Erase 
  End If
  Set Create = o
End Function

