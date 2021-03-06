use CMD_KD_SET_PERMISSIONS

'=============================================
Sub Object_Created(Obj, Parent)
   call Set_Permission (Obj)
   'call CreateCopyPerson(Obj)
End Sub

'=============================================
sub CreateCopyPerson(ParentObj)
  ParentObj.Permissions = SysAdminPermissions
  set objType = thisApplication.ObjectDefs("OBJECT_CORR_ADDRESS_PERCON")
  Set persObj = ParentObj.Objects.Create(objType)
  if persObj is nothing then 
    msgbox "Неудалось создать пользователя!", vbCritical, "Ошибка!"
    exit sub
  end if
  'persObj.Attributes("ATTR_COR_USER_CORDENT").Object = ParentObj
  persObj.Attributes("ATTR_CORR_ADD_FIO").Value = ParentObj.Description
  persObj.Attributes("ATTR_COR_USERNAME_DP").Value = ParentObj.Description
  persObj.Attributes("ATTR_CORR_ADD_EMAIL").Value = ParentObj.Attributes("ATTR_CORDENT_EMAIL").value
  persObj.Attributes("ATTR_CORR_ADD_ADDRESS").Value = ParentObj.Attributes("ATTR_CORDENT_ADDRES").value
  persObj.Attributes("ATTR_CORR_ADD_TELEFON").Value = ParentObj.Attributes("ATTR_CORDENT_TELEPHONE").value
  persObj.Attributes("ATTR_CORR_ADD_FAX").Value = ParentObj.Attributes("ATTR_CORDENT_FAX").value
  persObj.Update()
end sub
'=============================================
'Sub Object_StatusChanged(Obj, Status)
'   call Set_Permission (Obj)
'End Sub

Sub Object_BeforeErase(Obj, Cancel)'added by PlotnikovSP
if Obj.ReferencedBy.Count > 0 Then
    dim RefObj, RefObjects, strInfo, collection
    set collection = thisApplication.CreateCollection(tdmObjects)
    set RefObjects=Obj.ReferencedBy
    strInfo = Chr(13)
    For Each RefObj In RefObjects
      collection.add RefObj
    Next
    
    dim form1
    Set form1 = ThisApplication.InputForms("FORM_FOR_DELETE_KD_AND_USERS")
    set form1.Dictionary("coll") = collection
    
    dim obj2, ref, i, sdlg
    set obj2 = thisApplication.CreateCollection(tdmObjects)
    if Obj.ObjectDefName="OBJECT_CORRESPONDENT" then
      for each ref in Obj.ReferencedBy
        if ref.ObjectDefName = "OBJECT_CORR_ADDRESS_PERSON" or ref.ObjectDefName = "OBJECT_CORR_ADDRESS_PERCON" then 
          obj2.add ref
        end if
      next
      if obj2.Count <> Obj.ReferencedBy.Count then 
        form1.Caption = "Удаление невозможно, т.к. корреспондент используется в"
        form1.Show
        Cancel = true
        exit sub
      end if
      if obj2.Count>0 then
        for each i in obj2
          if i.ReferencedBy.Count=0 then i.erase
        next
      end if
    end if
    
    if Obj.ObjectDefName="OBJECT_CORR_ADDRESS_PERSON" or Obj.ObjectDefName= "OBJECT_CORR_ADDRESS_PERCON" then
      for each ref in Obj.ReferencedBy
        if ref.ObjectDefName = "OBJECT_CORRESPONDENT" then 
          obj2.add ref
        end if
      next
      if obj2.Count <> Obj.ReferencedBy.Count then 
        form1.Caption = "Удаление невозможно, т.к. контактное лицо используется в"
        form1.Show
        Cancel = true
        exit sub
      end if
      if obj2.Count>0 then
        for each i in obj2
          if i.ReferencedBy.Count=1 then i.erase
        next
      end if
    end if
  end if
End Sub
