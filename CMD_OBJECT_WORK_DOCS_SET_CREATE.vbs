' Автор: Стромков С.А.
'
' Создание основного комплекта
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

Set Obj = ThisObject
Obj.Permissions = SysAdminPermissions

Call Main (Obj)

Sub Main(Obj)
  If VarType(Obj)<>9 Then Exit Sub
  If Obj Is Nothing Then Exit Sub
  sObjDef = "OBJECT_WORK_DOCS_SET"
  Set Obj = Create(sObjDef,Obj)
End Sub

'==============================================================================
' Проверка входных условий
'------------------------------------------------------------------------------
' sObjDef_:String - Системный идентификатор типа объекта
' root:TDMSObject - Полный комплект в составе которого создается основной комплект
' Create:TDMSObject - созданный основной комплект
'==============================================================================
Function Create(sObjDef_,root)
  ThisScript.SysAdminModeOn
  Dim Dlg,hnd
  Set Create = Nothing
  
  If VarType(root)<>9 Then Exit Function
  
  If root Is Nothing Then Exit Function
  If  ThisApplication.ObjectDefs.Index(sObjDef_)=-1 Then Exit Function
  on error resume next
  Set NewObj = root.Objects.Create(sObjDef_)
  If NewObj is nothing then exit Function
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  NewObj.Permissions = SysAdminPermissions 
  Dlg.object = NewObj
  Dlg.ParentWindow = ThisApplication.hWnd
  RetVal = Dlg.Show
  
  If Not RetVal Then 
    If NewObj.ReferencedBy.count = 0 Then 
      NewObj.Erase 
      Exit Function
    End If
  End If
  Set Create = NewObj
End Function

