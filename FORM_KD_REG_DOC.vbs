use CMD_KD_REGNO_KIB
use CMD_KD_GLOBAL_VAR_LIB 
use CMD_KD_CURUSER_LIB
'==============================================================================
Sub BTN_FROM_RESERVE_OnClick()
    set docObj = thisForm.Attributes("ATTR_KD_DOCBASE").Object
    if docObj is nothing then exit sub
  
    Set Q = ThisApplication.Queries("QUERY_GET_RESRVE_NUMS")
    Q.Parameter("PARAM0") = docObj.ObjectDefName
    set sh = Q.Sheet
    set SelObjDlg = thisApplication.Dialogs.SelectDlg'SelectObjectDlg
    SelObjDlg.Prompt = "Выберите номер:"
    SelObjDlg.SelectFrom = sh 'SelectFromObjects = Objs

    RetVal = SelObjDlg.Show 
     If (RetVal<>TRUE) Then Exit Sub  
     Set ObjCol = SelObjDlg.Objects
     if (ObjCol.RowsCount = 0) Then Exit Sub  
     if (ObjCol.RowsCount > 1) Then 
       msgbox "Можно выбрать только один номер!", vbExclamation
       Exit Sub  
     end if
     set obj = ObjCol.Objects(0)
     obj.Permissions = SysAdminPermissions
     thisForm.Attributes("ATTR_KD_NUM").Value = Obj.Attributes("ATTR_KD_NUM").Value 
     thisForm.Controls("ATTR_KD_NUM").ReadOnly = true  
     thisForm.Attributes("ATTR_KD_HIST_OBJECT").value = obj
End Sub

'==============================================================================
Sub OK_OnClick()
  Set dict = ThisApplication.Dictionary("Packages")
  if dict.Exists("OK") then dict.remove("OK")
  dict.Add "OK", True
End Sub

'==============================================================================
Sub CANCEL_OnClick()
  Set Dict = ThisApplication.Dictionary("Packages")
  if dict.Exists("OK") then dict.remove("OK")
  dict.Add "OK", False
End Sub
'==============================================================================
Sub Form_BeforeClose(Form, Obj, Cancel)
  Set Dict = ThisApplication.Dictionary("Packages")
  If dict.Exists("OK") Then
    If dict("OK") Then 
      set docObj = thisForm.Attributes("ATTR_KD_DOCBASE").Object
      if docObj is nothing then exit sub

      if thisForm.Attributes("ATTR_KD_NUM").Value = "" or thisForm.Attributes("ATTR_KD_NUM").Value = 0 then 
        Msgbox "Регистрационный номер не задан. Введите номер или выберите из зарезервированных.", _
          vbExlamation, "Регистрация документа невозможна."
        Cancel = true
        exit sub 
      end if
      str = Check_Date(thisForm.Attributes("ATTR_KD_ISSUEDATE").Value)
      if str <>"" then 
          msgbox str, vbExclamation, "Регистрация документа невозможна."
          cancel = true
          exit sub
      end if    
  
      If not ThisApplication.IsActiveTransaction Then  ThisApplication.StartTransaction
    
    'перенести в другой год, если нужно
      set obj = thisForm.Attributes("ATTR_KD_HIST_OBJECT").object
      if not MoveToYear(docObj,obj) then 
        msgbox "Не удалось переместить документ в папку года", vbExclamation
        If ThisApplication.IsActiveTransaction Then ThisApplication.AbortTransaction
        cancel = true
        exit sub
      end if
       ' удаляем резервирование
'      set obj = thisForm.Attributes("ATTR_KD_HIST_OBJECT").Object
      if not obj is nothing then 
          obj.Permissions = SysAdminPermissions
          obj.erase
          thisForm.Attributes("ATTR_KD_HIST_OBJECT").value = ""
          thisForm.Controls("ATTR_KD_NUM").ReadOnly = false  
      end if
      LetNo = CheckRegNo(docObj, thisForm.Attributes("ATTR_KD_NUM").Value)
      if LetNo >"" then
        Msgbox "Регистрационный номер " & RegNo & " присвоен другому документу ["& LetNo &"]."& vbNewLine & _
            "Введите другой номер. Регистрация документа невозможна.", VbCritical, "Регистрация документа невозможна."
        Cancel = true
        If ThisApplication.IsActiveTransaction Then ThisApplication.AbortTransaction
        exit sub 
      else
        If ThisApplication.IsActiveTransaction Then ThisApplication.CommitTransaction 
      end if
    end if
  end if    
  if dict.Exists("OK") then dict.remove("OK")
  RemoveGlobalVarrible("DOC_DEF")

End Sub

'==============================================================================
Sub Form_BeforeShow(Form, Obj)
    set docObj = thisForm.Attributes("ATTR_KD_DOCBASE").Object
    if docObj is nothing then exit sub
End Sub
'==============================================================================
Sub QUERY_GET_RESRVE_NUMS_Selected(iItem, action)
    thisscript.SysAdminModeOn
    if iItem < 0 then exit sub
    Set control = thisForm.Controls("QUERY_GET_RESRVE_NUMS")
    set numRow =  control.value.RowValue(iItem) 
    numRow.Permissions = SysAdminPermissions
    set exec = numRow.Attributes("ATTR_KD_REG").user
    if exec is nothing then exit sub
    num = numRow.Attributes("ATTR_KD_NUM").Value  'Obj.Attributes("ATTR_KD_NUM").Value 
    if not IsInCurUsers(exec) then 
      msgbox "Номер " & num &" зарезервирован другим пользователем - " & exec.description & _
          ". Использовать его нельзя", vbExclamation, "Выберите другой номер"
      exit sub
    end if
    thisForm.Attributes("ATTR_KD_NUM").Value = num 
    thisForm.Controls("ATTR_KD_NUM").ReadOnly = true  
    thisForm.Attributes("ATTR_KD_ISSUEDATE").Value = numRow.Attributes("ATTR_KD_ISSUEDATE").Value 
    thisForm.Attributes("ATTR_KD_HIST_OBJECT").value = numRow
    thisForm.Refresh
End Sub
'==============================================================================
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  str = Check_Date(Attribute.Value)
  if str <>"" then 
      msgbox str, vbExclamation
      cancel = true
      exit sub
  end if    

'  if Attribute.AttributeDefName = "ATTR_KD_ISSUEDATE" then 
'    if thisForm.Controls("ATTR_KD_NUM").ReadOnly then exit sub ' EV значит из выбранных номеров
'    sDate = Attribute.Value
'    if sDate = "" then exit sub
'    if not isDate(sDate) then exit sub
'    dDate = cDate(sDate)
'    if Year(dDate) <> Year(Date) then 
'      msgbox "Нельзя зарегистировать письмо предыдущим или следующим годом", vbExclamation
'      cancel = true
'      exit sub
'    end if
'  end if
End Sub
