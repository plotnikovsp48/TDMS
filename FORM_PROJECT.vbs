'USE "CMD_KD_COMMON_LIB"
USE "CMD_DLL_COMMON_BUTTON"
USE "OBJECT_PROJECT"
USE "CMD_DLL_ROLES"
USE "CMD_PROJECT_DOCS_LIBRARY"


Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description  
  Call ThisApplication.ExecuteScript("CMD_DLL", "ShowBtnIcon",Form,Obj)
  Call SetControls(Form, Obj)
'  ' Выбор диспетчера доступен только ГИПу
'  Form.Controls("CMD_DISPATCHER_SELECT").Visible = _
'    ThisApplication.CurrentUser.Type > 0 Or _ 
'    Obj.RolesForUser(ThisApplication.CurrentUser).Has("ROLE_GIP")
End Sub

Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  Select case Attribute.AttributeDefName
    Case "ATTR_CUSTOMER_CLS"
      Cancel = Not CheckCustomerChange(Attribute.Object)
    Case "ATTR_CONTRACT"
      Call SetCurator(ThisForm, Obj)
      Call SetDates(Obj)
'      Call SetControls(ThisForm, Obj)
      Call SetControlsAfterContractChange()
  End Select
End Sub

' Выбирает ГИПа
Sub CMD_GIP_SELECT_OnClick()
  Set u = SelectUserByGroup("GROUP_GIP")
  If Not u Is Nothing Then 
    ThisForm.Controls("ATTR_PROJECT_GIP") = u
  End If
End Sub

' Выбирает Диспетчера
Sub CMD_DISPATCHER_SELECT_OnClick()
  Set u = SelectUserByGroup("ALL_USERS")
  'If Not u Is Nothing Then 
    ThisForm.Controls("ATTR_PROJECT_DISPATCHER") = u
  'End If
End Sub

'Кнопка - Выбрать договор 
Sub BUTTON_CONTRACT_SEL_OnClick()
  Set Cust = Nothing
  
  Set Obj = ThisObject
  Set Query = ThisApplication.Queries("QUERY_CONTRACTS_FOR_PROJECT")
  ' Заказчик
  If Obj.Attributes("ATTR_CUSTOMER_CLS").Empty = False Then
    If not ThisObject.Attributes("ATTR_CUSTOMER_CLS").Object is Nothing Then
      Set Cust = Obj.Attributes("ATTR_CUSTOMER_CLS").Object
      Query.Parameter("CUSTOMER") = Cust.Handle
    End If
  End If
  
  ' Если заказчик не задан, то ищем договор где КРСК - исполнитель
  If Cust is Nothing Then
    Set Contractor = ThisApplication.ExecuteScript("CMD_DLL_CONTRACTS","GetMyCompany")
    If not Contractor is Nothing Then
      Query.Parameter("CONTRACTOR") = Contractor
    End If
  End If
  NeedToSelectContract = True
  Set Objects = Query.Objects
  If Objects.Count = 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 1604
    Exit Sub
  End If
  ' Отключено 18.01.2018: в системе может не быть нужного договора, чтобы не выбрался ненужный
'  If Objects.Count = 1 Then
'    Obj.Attributes("ATTR_CONTRACT").Object = Objects(0)
'    NeedToSelectContract = False
'  End If
  
  If NeedToSelectContract = True Then
    Set Dlg = ThisApplication.Dialogs.SelectDlg
    Dlg.Caption = "Выбор договора"
    Dlg.Prompt = "Выберите договор:"
    Dlg.SelectFrom = Query.Sheet

    'Если пользователь отменил диалог или ничего не выбрал, закончить работу.
    If Dlg.Show Then 
      Set sel = Dlg.Objects
      If sel.RowsCount >0 Then
        Set Contract = sel.RowValue(0)
        Obj.Attributes("ATTR_CONTRACT").Object = Contract
      End If
    End If
  End If
  If Obj.Attributes("ATTR_CONTRACT").Empty = False Then
    Call SetCurator(ThisForm, Obj)
    Call SetDates(Obj)
    Call SetControls(ThisForm, Obj)
  End If
  If Obj.Attributes("ATTR_CUSTOMER_CLS").Empty = True Then 
    Obj.Attributes("ATTR_CUSTOMER_CLS").Object = _
          ThisApplication.ExecuteScript("OBJECT_CONTRACT","GetContractor",Contract)
  End If
End Sub

' Кнопка добавить Зам ГИПа

Sub CMD_USER_ADD_OnClick()
  NeedRolesUpdate = False
  Set Table = ThisObject.Attributes("ATTR_GIP_DEPUTIES")
  Set Rows = Table.Rows
  Set q = ThisApplication.Queries("QUERY_GIP_DEP_TO_SELECT")
  q.Parameter("PARAM0") = ThisObject
  Set coll = q.Users
  Call QueryObjectsFilter(Coll,"ATTR_USER",Rows)
  Set us = ThisApplication.ExecuteScript("CMD_DIALOGS","SelectUsersFromCollDlg",coll)
  
  If us Is Nothing Then Exit Sub
      For Each User in us
        Check = True
        For Each Row in Rows
          If Row.Attributes("ATTR_USER").User.SysName = User.SysName Then
            Check = False
            Exit For
          End If
        Next
        If Check = True Then
          Set NewRow = Rows.Create
          If User.Attributes.Has("ATTR_KD_USER_DEPT") Then
            If User.Attributes("ATTR_KD_USER_DEPT").Empty = False Then
              If not User.Attributes("ATTR_KD_USER_DEPT").Object is Nothing Then
                NewRow.Attributes("ATTR_USER_DEPT").Object = User.Attributes("ATTR_KD_USER_DEPT").Object
              End If
            End If
          End If
          NewRow.Attributes("ATTR_USER").User = User

          NeedRolesUpdate = True
        End If
      Next
      
      If NeedRolesUpdate = True Then
        ThisApplication.Dictionary(ThisObject.GUID).Item("UpdateGipDeptRoles") = True
      End If
End Sub

'Sub CMD_USER_ADD_OnClick()
'  NeedRolesUpdate = False
'  Set Rows = ThisObject.Attributes("ATTR_GIP_DEPUTIES").Rows
'  Set us = SelectUsersByGroup("GROUP_GIP")
'  If us Is Nothing Then Exit Sub
'      For Each User in us
'        Check = True
'        For Each Row in Rows
'          If Row.Attributes("ATTR_USER").User.SysName = User.SysName Then
'            Check = False
'            Exit For
'          End If
'        Next
'        If Check = True Then
'          Set NewRow = Rows.Create
'          If User.Attributes.Has("ATTR_KD_USER_DEPT") Then
'            If User.Attributes("ATTR_KD_USER_DEPT").Empty = False Then
'              If not User.Attributes("ATTR_KD_USER_DEPT").Object is Nothing Then
'                NewRow.Attributes("ATTR_USER_DEPT").Object = User.Attributes("ATTR_KD_USER_DEPT").Object
'              End If
'            End If
'          End If
'          NewRow.Attributes("ATTR_USER").User = User
'          NeedRolesUpdate = True
'        End If
'      Next
'      
'      If NeedRolesUpdate = True Then
'        ThisApplication.Dictionary(ThisObject.GUID).Item("UpdateGipDeptRoles") = True
'      End If
'End Sub

' Кнопка удалить Зам ГИПа
Sub CMD_USER_DEL_OnClick()
  ThisScript.SysAdminModeOn
  NeedRolesUpdate = False
  Set Table = ThisForm.Controls("ATTR_GIP_DEPUTIES")
  Arr = Table.ActiveX.SelectedRows
  If UBound(Arr)+1 = 0 Then Exit Sub
  'Подтверждение удаления
  Key = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion + vbYesNo, 1607, UBound(Arr)+1)
  If Key = vbNo Then Exit Sub
  NeedRolesUpdate = True
  'Удаление строк
  For i = 0 to UBound(Arr)
    Set Row = Table.ActiveX.RowValue(Arr(i))
    Row.Erase
  Next
  If NeedRolesUpdate = True Then
    ThisApplication.Dictionary(ThisObject.GUID).Item("UpdateGipDeptRoles") = True
  End If
  ThisForm.Refresh
End Sub

Sub SetCurator(f_, o_)
  Set oContr = o_.attributes("ATTR_CONTRACT").Object
  If oContr is Nothing Then
    f_.controls("ATTR_CURATOR").readonly = False
    Exit Sub
  End If
  Set uCur1 = oContr.attributes("ATTR_CURATOR").user 'Куратор на договоре
  Set uCur2 = o_.attributes("ATTR_CURATOR").user     'Куратор на проекте
  If Not uCur1 Is Nothing Then
    If not uCur2 is nothing Then 
      If  uCur1.handle = uCur2.handle Then Exit Sub
    End If
    If not uCur1 is nothing Then o_.attributes("ATTR_CURATOR") = uCur1
    f_.refresh
  End If
End Sub

' Подлистываение списка для атрибута ГИП
Sub ATTR_PROJECT_GIP_BeforeAutoComplete(text)
  grName = "GROUP_GIP"
  If Not ThisApplication.Groups.Has(grName) Then Exit Sub
  Set ctrl = thisForm.Controls("ATTR_PROJECT_GIP").ActiveX
  ' Если ввели 1 буквы и более
  If Len(text)>0 then
'    ctrl.ComboItems = ThisApplication.Groups(grName).Users
    ctrl.ComboItems = ThisApplication.Queries("QUERY_ALL_GIP").Users
  End If
End Sub

Sub CMD_CUSTOMER_ADD_OnClick()
  Set o = ThisObject
  changed = False
  Set OldCorr = o.Attributes("ATTR_CUSTOMER_CLS").Object
  Set oCorr = ThisApplication.ExecuteScript("CMD_S_DLL", "GetCompany")
  If oCorr is Nothing Then Exit Sub
  Set Obj = oCorr.Objects.Item(oCorr.CellValue(0,0))
  ' 
  If o.Attributes("ATTR_CUSTOMER_CLS").Empty = False Then
    If OldCorr.Handle <> Obj.Handle Then
      changed = True
    End If
  Else
    changed = True
  End If
  
  If Not changed Then Exit Sub
  
  o.Attributes("ATTR_CUSTOMER_CLS").Object = Obj
  
  If Not CheckCustomerChange(Obj) Then _
    o.Attributes("ATTR_CUSTOMER_CLS").Object = OldCorr
End Sub

Sub CMD_CUSTOMER_CREATE_OnClick()
  Set NewOrg = CreateOrg()
  Set Obj = ThisObject
  aDef = "ATTR_CUSTOMER_CLS"
  If Not NewOrg Is Nothing Then
    Call ThisApplication.ExecuteScript("CMD_DLL", "SetAttr", Obj,aDef,NewOrg)
  End If
End Sub

' Копирование даты начала и окончания по проекту с договора
Sub SetDates(Obj)
  If Obj Is Nothing Then Exit Sub
  
  Set oContr = Obj.Attributes("ATTR_CONTRACT").Object
  If oContr Is Nothing Then Exit Sub
  
  Obj.Attributes("ATTR_STARTDATE_PLAN") = oContr.Attributes("ATTR_STARTDATE_PLAN")
  Obj.Attributes("ATTR_ENDDATE_PLAN") = oContr.Attributes("ATTR_ENDDATE_PLAN")
End Sub

Sub SetControls(Form, Obj)
  Set CU = ThisApplication.CurrentUser
  isGip = ThisApplication.ExecuteScript("CMD_DLL_ROLES","isGipOrDep",Obj,CU)
  
  chk = (Obj.Attributes("ATTR_CONTRACT").Empty = True)
  chk1 = chk And isGIP
  Call SetControlsAfterContractChange()
  With Form.controls
'    .Item("ATTR_STARTDATE_PLAN").ReadOnly = Not chk1
'    .Item("ATTR_ENDDATE_PLAN").ReadOnly = Not chk1
'    .Item("ATTR_CURATOR").Readonly = Not chk 'Not chk1
    .Item("ATTR_PROJECT_DISPATCHER").Readonly = Not (isGIP or ThisApplication.CurrentUser.Type > 0)
  
  
  ' Для новых проектов открываем поле Код проекта
  ' str 29/01/2018
    Set Dict = ThisObject.Dictionary
    If Dict.Exists("newproject") Then _
      .Item("ATTR_PROJECT_CODE").Readonly = False

  End With
End Sub

Sub ATTR_CONTRACT_BeforeAutoComplete(Text)
  Set Obj = ThisObject
  Set Query = ThisApplication.Queries("QUERY_CONTRACTS_FOR_PROJECT")
  Set ctrl = thisForm.Controls("ATTR_CONTRACT").ActiveX
  
  ' Заказчик
  If Obj.Attributes("ATTR_CUSTOMER_CLS").Empty = False Then
    If not Obj.Attributes("ATTR_CUSTOMER_CLS").Object is Nothing Then
      Set Cust = Obj.Attributes("ATTR_CUSTOMER_CLS").Object
      Query.Parameter("CUSTOMER") = Cust.Handle
    End If
  End If
  
  ' Если заказчик не задан, то ищем договор где КРСК - исполнитель
  If Cust is Nothing Then
    Set Contractor = ThisApplication.ExecuteScript("CMD_DLL_CONTRACTS","GetMyCompany")
    If not Contractor is Nothing Then
      Query.Parameter("CONTRACTOR") = Contractor
    End If
  End If

  If Len(text)>0 then
    ctrl.ComboItems = Query.Sheet.Objects
  End If

End Sub

' Управление полем Куратор Договора
Sub SetControlsAfterContractChange()
  Set CU = ThisApplication.CurrentUser
  isGip = ThisApplication.ExecuteScript("CMD_DLL_ROLES","isGipOrDep",ThisObject,CU)
  
  chk = (ThisObject.Attributes("ATTR_CONTRACT").Empty = True)
  chk1 = chk And isGIP

  With ThisForm.controls
    .Item("ATTR_CURATOR").Readonly = Not chk
    .Item("ATTR_STARTDATE_PLAN").ReadOnly = Not chk
    .Item("ATTR_ENDDATE_PLAN").ReadOnly = Not chk
  End With
End Sub

Sub ATTR_CONTRACT_ButtonClick(Cancel)
  If ThisObject.Permissions.Edit <> 1 Then Exit Sub
  Call BUTTON_CONTRACT_SEL_OnClick()
  Cancel = True
End Sub

Sub ATTR_CUSTOMER_CLS_ButtonClick(Cancel)
  Call CMD_CUSTOMER_ADD_OnClick()
  Cancel = True
End Sub

' Проверка необходимости очистки поля договор
Function CheckCustomerChange(oProjCust)
  CheckCustomerChange = False
  Set Obj = ThisObject
  Set Form = ThisForm
      '  Подтверждение замены Заказчика
      If Not oProjCust Is Nothing Then
        Set oContr = ThisObject.Attributes("ATTR_CONTRACT").Object
        If Not oContr Is Nothing Then
          Set oContrCust = oContr.Attributes("ATTR_CUSTOMER").Object
          If IsTheSameObj(oProjCust,oContrCust) Then
            CheckCustomerChange = True
            Exit Function
          End If
        
  '        result=ThisApplication.ExecuteScript ("CMD_MESSAGE", "ShowWarning", vbQuestion+VbYesNo, 1033)
          ans = msgbox("Заказчик указанного договора " & oContrCust.Description & " не соответствует заказчику проекта. Поле Договор будет очищено. Продолжить?",vbQuestion+vbYesNo,"")
          If ans <> vbYes Then Exit Function
        
          If Form.Attributes.Has("ATTR_CONTRACT") = True Then _
            Form.Attributes("ATTR_CONTRACT").Object = Nothing
            Call SetControlsAfterContractChange()
          End If
'          If Form.Attributes.Has("ATTR_CURATOR") = True Then 'Exit Function
''            Form.Attributes("ATTR_CURATOR").User = Nothing
'          End If
      End If

      CheckCustomerChange = True
End Function
