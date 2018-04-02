use CMD_KD_COMMON_LIB
use CMD_KD_CURUSER_LIB
'=================================
Sub Form_BeforeShow(Form, Obj)

' EV новая концепция - все могут смотреть, но править только своего
'  set curUser = GetCurUser()
'  ifMayEdit = curUser.Groups.Has("GROUP_COR_RECIPIENT") 'EV Редактирование корреспондентов
'  Form.Controls("BTNSET").Visible = ifMayEdit
'  Form.Controls("BTN_ADD_ORG").Visible = ifMayEdit
'  Form.Controls("BTN_ADD_PERS").Visible = ifMayEdit
  
End Sub

'=================================
Sub Form_BeforeClose(Form, Obj, Cancel)
    
'    if not CheckCordent() then
'      cancel = true
'      exit sub
'    end if  
'    If ThisApplication.Dictionary.Exists("SetRecip") Then ThisApplication.Dictionary.Remove "SetRecip"
   RemoveGlobalVarrible("ShowForm")
End Sub

''=================================
'function CheckCordent()
'  CheckCordent = true
'    Set ReplyRows = ThisObject.Attributes("ATTR_CORR_RECIPIENT_OUT").Rows
'        for j = 0 to ReplyRows.Count-1
'            if not ReplyRows(j).Attributes("ATTR_CORR_SEND_LETTER_TYPE_EMAIL").Value and _
'                not ReplyRows(j).Attributes("ATTR_CORR_SEND_LETTER_TYPE_POSTOFFICE").Value and _
'                not ReplyRows(j).Attributes("ATTR_CORR_SEND_LETTER_TYPE_FAX").Value then 
'                msgbox "Для получателя " &ReplyRows(j).Attributes("ATTR_UNLOAD_RECEPIENT").value & _ 
'                " не задано ни одного вида получения. " & chr(10) & _
'                " Пожалуйста, поставьте галочку у нужного вида получения или удалите получателя"
'                CheckCordent = false
'            end if    
'        next 
'end function

'=================================
Sub BTNADD_OnClick()
  set s = thisForm.Controls("QUERY_COR_GET_CORDENTs").ActiveX
   if s.SelectedItem < 0 then exit sub   
   ar = thisapplication.Utility.ArrayToVariant(Thisform.Controls("QUERY_COR_GET_CORDENTs").SelectedItems)
   
   for i = 0 to Ubound(ar)
     set cor = Thisform.Controls("QUERY_COR_GET_CORDENTs").value.RowValue(ar(i))
     call AddCorDent(thisObject,cor, true)
   next
End Sub

'=================================
sub AddCorDent(DocObj,CorDent, sil)
    ThisScript.SysAdminModeOn
    if CorDent is nothing then exit sub
    CorDent.Permissions = SysAdminPermissions
    if CorDent.Parent is nothing then exit sub
    
    Set ReplyRows = DocObj.Attributes("ATTR_KD_TCP").Rows

    'Проверка нет ли добавляемого получателя в списке
    if not  IsExistsObjItemCol(ReplyRows,cordent, "ATTR_KD_CPADRS")then  
      if DocObj.ObjectDefName = "OBJECT_KD_DOC_IN" then 
        set NewRow = ReplyRows()
      else  
       Set NewRow = ReplyRows.Create 
      end if
         
      NewRow.Attributes("ATTR_KD_CPADRS").Value = CorDent 
      NewRow.Attributes("ATTR_KD_CPNAME").Value = CorDent.Parent 
'      NewRow.Attributes("ATTR_COR_NPP").Value = ReplyRows.Count
      ReplyRows.Update
    else
      if sil then _
          msgBox "Полуатель " & CorDent.Description & " уже есть в списке. Добавление не будет произведено.", _
              vbInformation,"Получатель не добавлен!"
    end if   
end sub


'=================================
Sub BTNDEL_OnClick()
    'call DelRecipient()
    call Del_FromTable("ATTR_KD_TCP", "ATTR_KD_CPADRS") 
end Sub
 

'=================================
Sub BTNUP_OnClick()
    set s = thisForm.Controls("ATTR_KD_TCP").ActiveX
    if s.RowCOunt = 0 then exit sub   
    if s.SelectedRow=0 then exit sub
    
    Set ReplyRows = ThisObject.Attributes("ATTR_KD_TCP").Rows


'    ReplyRows(s.SelectedRow).Attributes("ATTR_COR_NPP").Value = ReplyRows(s.SelectedRow).Attributes("ATTR_COR_NPP").Value - 1
'    ReplyRows(s.SelectedRow-1).Attributes("ATTR_COR_NPP").Value = ReplyRows(s.SelectedRow-1).Attributes("ATTR_COR_NPP").Value + 1
'    
    ReplyRows.Swap ReplyRows(s.SelectedRow), ReplyRows(s.SelectedRow-1)
    
    ReplyRows.Update

End Sub


'=================================
Sub BTNDOWN_OnClick()
    set s = thisForm.Controls("ATTR_KD_TCP").ActiveX
    if s.RowCOunt = 0 then exit sub   
    if s.SelectedRow = s.RowCOunt-1 then exit sub
    
    Set ReplyRows = ThisObject.Attributes("ATTR_KD_TCP").Rows

    
'    ReplyRows(s.SelectedRow).Attributes("ATTR_COR_NPP").Value = ReplyRows(s.SelectedRow).Attributes("ATTR_COR_NPP").Value + 1
'    ReplyRows(s.SelectedRow+1).Attributes("ATTR_COR_NPP").Value = ReplyRows(s.SelectedRow+1).Attributes("ATTR_COR_NPP").Value - 1
'    
    ReplyRows.Swap ReplyRows(s.SelectedRow), ReplyRows(s.SelectedRow+1)
    
    ReplyRows.Update
End Sub

'=================================
Sub QUERY_COR_GET_CORDENTs_DblClick(iItem, bCancelDefault)

    call BTNADD_OnClick()
    
    bCancelDefault = true
    
    thisForm.Refresh() ' EV иначе не обновляемся атрибуты

End Sub

''=================================
'Sub ATTR_CORR_RECIPIENT_OUT_CellChecked(nRow, nCol, bChecked, bCancel)
'  needCancel = false

'  set rows = ThisObject.Attributes("ATTR_CORR_RECIPIENT_OUT").Rows
'  set row = rows(nRow)
'  set CorDent = row.Attributes("ATTR_CORR_PERCON").Object
'  if  CorDent is nothing then 
'        msgbox "Невозможно изменить реквизиты получателя, добавленного в старой переписке" & chr(10) & _
'          "Пожалуйста, удалите данного получателя и добавьте его еще раз в новой системе. ", VbOKOnly + VbCritical
'        bCancel = true
'        exit sub
'  end if
'  
'  select case nCol 
'    case 7 needCancel = SetEMAIL(Row,bChecked,CorDent)  
'          if not needCancel then  bCancel = true
'    case 8 needCancel = SetFax(Row,bChecked,CorDent)  
'          if not needCancel then  bCancel = true   
'    case 9 needCancel = SetPost(Row,bChecked,CorDent)  
'          if not needCancel then  bCancel = true                
'  end select
'  rows.update
'  thisObject.Update ' EV иначе не обнавляет и не верно работает на выставление галок
'  thisform.Refresh
'End Sub


'=================================
Sub BTNSET_OnClick()
  set s = thisForm.Controls("QUERY_COR_GET_CORDENTs").ActiveX
  if s.SelectedItem < 0 then exit sub   
  ar = thisapplication.Utility.ArrayToVariant(Thisform.Controls("QUERY_COR_GET_CORDENTs").SelectedItems)
   
  set cor = Thisform.Controls("QUERY_COR_GET_CORDENTs").value.RowValue(ar(0))
  if cor.Permissions.Edit = 0 then 
    msgbox "У Вас нет прав на редактирование сотрудника " & Cor.Description, vbExclamation, "Редактирование не доступно"
    exit sub
  end if
  frmName = thisForm.SysName
  RemoveGlobalVarrible("ShowForm")

  Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
  EditObjDlg.Object = cor
  EditObjDlg.Show  
  call SetGlobalVarrible("ShowForm",frmName)
      
End Sub

'EV создание организации
'=================================
Sub BTN_ADD_ORG_OnClick()
    set cord = CreateOrg()
'    if not cord is nothing then 
'         call AddCorDent(thisObject,cord, true)
'    end if
End Sub

'Создание сотрудника
'=================================
Sub BTN_ADD_PERS_OnClick()
    set pers = CreatePerson()
    if not pers is nothing then 
      call AddCorDent(thisObject,pers, true)
    end if
End Sub

'=================================
'EV добавляем организацию
function CreateOrg()
  set CreateOrg = nothing
  set ObjRoots = thisApplication.GetObjectByGUID("{A60FEBB1-E4EF-4DC0-A8B6-32D720FEFBF2}") ' Корреспонденты
  if ObjRoots is nothing then 
      msgbox "Не удалось найти папку Корреспонденты!"
      exit function
    end if  
    
    
  ObjRoots.Permissions = SysAdminPermissions
  set objType = thisApplication.ObjectDefs("OBJECT_CORRESPONDENT")
'  Set CreateDocObject = ObjRoots.Objects.Create(objType)
' CreateDocObject.Update   
'  Set_Permition CreateDocObject
'  if isEmpty(thisForm) then 
'  frmName = thisForm.SysName
'  RemoveGlobalVarrible("ShowForm")

' 'Инициализация свойств диалога создания объекта
'  Set CreateObjDlg = ThisApplication.Dialogs..EditObjectDlg
'  CreateObjDlg.Object = CreateDocObject
'  CreateObjDlg.WarnModifiedOnCancel = false
  Set CreateObjDlg = ThisApplication.Dialogs.CreateObjectDlg
  CreateObjDlg.ObjectDef = objType
  CreateObjDlg.ParentObject = ObjRoots
  CreateObjDlg.WarnModifiedOnCancel = false
  ans = CreateObjDlg.Show
  if ans = true then set CreateOrg = CreateObjDlg.Object
'  call SetGlobalVarrible("ShowForm",frmName)
  
end function

'=================================
'EV добавляем сотрудника
function CreatePerson
  set CreatePerson = nothing
  Set SelDlg = ThisApplication.Dialogs.SelectDlg
'    set Obj = thisApplication.GetObjectByGUID("{A60FEBB1-E4EF-4DC0-A8B6-32D720FEFBF2}") 'корреспонденты
'    if obj is nothing then 
'      exit function
'    end if  
    
    Set Q = ThisApplication.Queries("QUERY_KORREESPONDENTES")
    set sh = Q.Sheet
    if sh.RowsCount = 0 then exit function

    SelDlg.SelectFrom = sh'obj.Objects
    SelDlg.Caption = "Выбор организации"
    SelDlg.Prompt = "Выберите организацию"
    RetVal = SelDlg.Show

    If RetVal  Then
      if SelDlg.Objects.Objects.count = 0 then 
            exit function
      end if  
      frmName = thisForm.SysName
      RemoveGlobalVarrible("ShowForm")
      Set SelectedArray = SelDlg.Objects.Objects
      set ParentObj = SelectedArray(0)
      set CreatePerson = CreatePersonByCord(ParentObj)
      call SetGlobalVarrible("ShowForm",frmName)
    end if
end function
'=================================
function CreatePersonByCord(CorDent)
    set CreatePersonByCord = nothing
    set objType = thisApplication.ObjectDefs("OBJECT_CORR_ADDRESS_PERCON")
    thisScript.SysAdminModeOn
    CorDent.Permissions = sysAdminPermissions
    Set persObj = CorDent.Objects.Create(objType)
    if persObj is nothing then 
      msgbox "Неудалось создать пользователя!", vbCritical, "Ошибка!"
      exit function
    end if
    'Инициализация свойств диалога создания объекта
    Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg
    CreateObjDlg.Object = persObj
    ans = CreateObjDlg.Show
    if ans = true then set CreatePersonByCord = persObj
end function 
'=================================
Sub BTN_EDIT_ORG_OnClick()
  frmName = thisForm.SysName
  RemoveGlobalVarrible("ShowForm")

  set s = thisForm.Controls("QUERY_COR_GET_CORDENTs").ActiveX
  if s.SelectedItem < 0 then exit sub   
  ar = thisapplication.Utility.ArrayToVariant(Thisform.Controls("QUERY_COR_GET_CORDENTs").SelectedItems)
   
  set cor = Thisform.Controls("QUERY_COR_GET_CORDENTs").value.RowValue(ar(0))
  set CorOrg = cor.Attributes("ATTR_COR_USER_CORDENT").Object
  if CorOrg is nothing then exit sub
  if CorOrg.Permissions.Edit = 0 then 
    msgbox "У Вас нет прав на редактирование организации " & CorOrg.Description, vbExclamation, "Редактирование не доступно"
    exit sub
  end if
  Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
  EditObjDlg.Object = CorOrg
  EditObjDlg.Show  
  call SetGlobalVarrible("ShowForm",frmName)
End Sub
