' Автор: Чернышов Д.С.
'
' Форма ввода "Задание"
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016

'USE "CMD_KD_COMMON_BUTTON_LIB"
'USE "CMD_KD_COMMON_LIB"
USE "CMD_DLL_COMMON_BUTTON"
USE "CMD_S_DLL"
USE "CMD_DLL_ROLES"
USE "CMD_FILES_LIBRARY"
USE "CMD_PROJECT_DOCS_LIBRARY"

Sub Form_BeforeShow(Form, Obj)
'  ThisApplication.AddNotify "Form_BeforeShow " & Time
  Call SetLabels(Form, Obj)
  Call SetFilesActionButtonLocked(Form,False)
'  ThisApplication.AddNotify "Form_BeforeShow -1 " & Time
  Call SetContolEnable(Form, Obj)
'  ThisApplication.AddNotify "Form_BeforeShow -2 " & Time
  
  Call SetBlockRouteButton(Form,Obj)
'  ThisApplication.AddNotify "Form_BeforeShow -3 " & Time
  if Obj.Permissions.ViewFiles=tdmAllow then
    if Obj.Permissions.EditFiles=tdmallow then
      Call setEnabledButtonLocked (Form, Obj)
    End If
  End If
'  ThisApplication.AddNotify "Form_BeforeShow -4 " & Time
  Call BtnTaskOpenChange(Form,Obj)
'  ThisApplication.AddNotify "Form_BeforeShow (end) " & Time
End Sub

''Кнопка - Сконвертировать в PDF
'Sub BTN_ConvertToPDF_OnClick()
'  Set fCreated = BlockFilesConvertPDF(ThisForm,ThisObject)
''  fCreated.FileDef = ThisApplication.FileDefs("FILE_KD_SCAN_DOC")
'End Sub

Sub SetContolEnable(Form, Obj)
thisapplication.DebugPrint "SetContolEnable " & Time
  Set CU = ThisApplication.CurrentUser
  Set cCtrl = Form.Controls
  sName = Obj.StatusName
  isResp = userIsResponsible(Obj,CU)
  isDvlp = IsDeveloper(Obj,CU)
  isGip = ThisApplication.ExecuteScript("CMD_DLL_ROLES","isGipOrDep",Obj,CU)
  '----------------------------------------------------------------------------
  
  Check0 = CheckObj0(Obj)
  Check1 = CheckObj1(Obj)
  Check2 = CheckObj2(Obj)
  Check3 = CheckObj3(Obj)
  
  Check4 = (Obj.StatusName = "STATUS_T_TASK_IN_WORK") 'Функция проверки доступности атрибутов "Проверил" и "Разработал"
  usCanEdit = IsCanEdit(Obj)
                
' check12 перенесено в код кнопки   BTN_TASK_DUPLICATE 19.12.2017
'    If (Obj.StatusName = "STATUS_T_TASK_APPROVED" or Obj.StatusName = "STATUS_T_TASK_INVALIDATED") And _
'      Check12 = True Then

    If (Obj.StatusName = "STATUS_T_TASK_APPROVED" or Obj.StatusName = "STATUS_T_TASK_INVALIDATED") Then
      cCtrl("BTN_TASK_DUPLICATE").Visible = True ' Выдать повторно
      cCtrl("BTN_TASK_DUPLICATE").Enabled = True
    Else
      cCtrl("BTN_TASK_DUPLICATE").Visible = False
    End If
  
  cCtrl("BTN_ADD_ANNEX").Enabled = Check0 or Check1 or Check2
  cCtrl("BTN_DEL_ANNEX").Enabled = Check0 or Check1 or Check2
  
    
  cCtrl("BTN_OBJECT_TASK_CREATE_RETURN").Visible = (sName = "STATUS_T_TASK_APPROVED") And _
                                                      Obj.RolesForUser(CU).Has("ROLE_T_TASK_IN_CHECKER")
  
  cCtrl("ATTR_T_TASK_LINK").Visible = Not Obj.Attributes("ATTR_T_TASK_LINK").Empty
  cCtrl("T_ATTR_T_TASK_LINK").Visible = Not Obj.Attributes("ATTR_T_TASK_LINK").Empty
  

  cCtrl("ATTR_RESPONSIBLE").ReadOnly = Not AttrIsEmpty(Obj,"ATTR_RESPONSIBLE")
  ' Открыли атрибут Утверждающий, чтобы можно было выбрать другого
  '  cCtrl("ATTR_DOCUMENT_CONF").ReadOnly = Not AttrIsEmpty(Obj,"ATTR_DOCUMENT_CONF")
  ' Поле открыто для ГИПов и Замов по требованию ОП Тюмень Заявка 4956
  cCtrl("ATTR_SIGNER").ReadOnly =   Not (isGip And (sName = "STATUS_T_TASK_IN_WORK" or sName = "STATUS_T_TASK_IS_CHECKING")) 'Not AttrIsEmpty(Obj,"ATTR_SIGNER")

  cCtrl("ATTR_T_TASK_DEVELOPED").ReadOnly = not (Check4 and isResp)
  cCtrl("ATTR_T_TASK_DEPARTMENT").ReadOnly = Not (ThisObject.Attributes("ATTR_T_TASK_DEPARTMENT").Empty = True And isGip)'Check7


  ' Перенесено с формы Результаты
  isRowSel = TblRowSelected("ATTR_T_TASK_DOC")
  cCtrl("BUTTON_ADD").Enabled = (isResp or isDvlp) And usCanEdit
  cCtrl("BUTTON_DEL").Enabled = CheckObjDel or (isRowSel And (isResp or isDvlp)) And usCanEdit
  cCtrl("BUTTON_INFO").Enabled = isRowSel  'And usCanEdit 'And CheckObjDel
  thisapplication.DebugPrint "SetContolEnable (end) " & Time
End Sub

Sub SetBlockRouteButton(Form,Obj)
thisapplication.DebugPrint "SetBlockRouteButton " & Time
  Set CU = ThisApplication.CurrentUser
  Set cCtrl = Form.Controls

  isChk = IsChecker(Obj,CU)
  isSgn = IsSigner(Obj,CU)
  usCanEdit = IsCanEdit(Obj)
  
  
  Check0 = CheckObj0(Obj)
  Check1 = CheckObj1(Obj)
  Check2 = CheckObj2(Obj)
  Check3 = CheckObj3(Obj)
  Check5 = CheckObj5()
  Check8 = CheckObj8()
  Check9 = Check0 And isChk 'CheckObj9() ' Проверка, что разработчик и проверяющий - один пользователь
  Check10 = CheckObj10() or (Check0 And isSgn)  ' Проверка, что разработчик и подписант - один пользователь
  Check11 = Obj.StatusName = "STATUS_T_TASK_IS_CHECKING" And _
            ThisApplication.ExecuteScript("CMD_TASK_SEND_TO_SIGN","needToChangeStatus",Obj)

 
  
  
  cCtrl("ATTR_NAME_SHORT").ReadOnly = Not (Check0 or Check1 or Check2)
  cCtrl("ATTR_CONTRACT_STAGE").ReadOnly = Not (Check0 or Check1 or Check2)
  cCtrl("ATTR_UNIT").ReadOnly = Not (Check0 or Check1 or Check2)
  cCtrl("ATTR_T_TASK_CHECKED").ReadOnly = Not (Check0)
  cCtrl("ATTR_USER_CHECKED").ReadOnly = Not (Check0)
  cCtrl("ATTR_KD_NOTE").ReadOnly = Not (Check0)
  
  
  ' Кнопка - На проверку
'  cCtrl("BTN_SEND_TO_CHECK").Visible = Check0 And Not check9 ' Передать на проверу
  cCtrl("BTN_SEND_TO_CHECK").Visible = Check0 And Not isChk ' Передать на проверу
  ' Кнопка - На подписание/Проверено
  If (Check11 or Check9) = True Then
    cCtrl("BTN_SEND_TO_SIGN").Value = "На подписание"
    cCtrl("BTN_SEND_TO_SIGN").ActiveX.Image =  ThisApplication.Icons("IMG_APPROVAL_FORWARD")
  End If
  cCtrl("BTN_SEND_TO_SIGN").Visible = Check1 OR check9' Передать на подписание
  cCtrl("BTN_SEND_TO_SIGN").Enabled = Check1 OR check9' Передать на подписание
    
  ' Кнопка - Подписать
  cCtrl("BTN_SIGN").Visible = Check2
  cCtrl("BTN_SIGN").Enabled = Check2
      
  ' Кнопка - На согласование
  cCtrl("BTN_TO_AGREE").Visible = Check10 or Check2
  cCtrl("BTN_TO_AGREE").Enabled = Check10 or Check2
   
  cCtrl("ACCEPT_TASK").Visible = Check3 ' Утвердить задание
  cCtrl("ACCEPT_TASK").Enabled = Check3 ' Утвердить задание
  cCtrl("BUTTON_INVALIDATE").Visible = Check8 or Check2' Аннулировать задание
  cCtrl("BUTTON_INVALIDATE").Enabled = Check8 or Check2' Аннулировать задание
  cCtrl("REJECT_TASK").Visible = Check3 or Check1 or Check2 ' Вернуть на доработку с Утверждения
  cCtrl("REJECT_TASK").Enabled = Check3 or Check1 or Check2 ' Вернуть на доработку с Утверждения
  
  
  
  cCtrl("CMD_TDEPT_ADD").Enabled = (Check5 or check0 or check1 or check2) And usCanEdit
  cCtrl("BUTTON_TDEPT_DEL").Enabled = (Check5 or check0 or check1 or check2) And TblRowSelected("ATTR_T_TASK_TDEPTS_TBL") And usCanEdit
  
  ' -- > Case 5632 --
'  Check12 = Not Form.Attributes("ATTR_SIGN_DATA").Empty
'  cCtrl("ATTR_SIGN_DATA").Visible = Check12
'  cCtrl("T_ATTR_SIGN_DATA").Visible = Check12
  ' -- Case 5632 < --
  
End Sub


Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  Set CU = ThisApplication.CurrentUser
  ' Обновление обозначения задания
  If Attribute.AttributeDefName = "ATTR_T_TASK_DEPARTMENT" Then
    If Not Attribute.Value = OldAttribute.Value Then
      Call SetCode(Obj)
    End If
  End If
  If Attribute.AttributeDefName = "ATTR_T_TASK_CHECKED" Then
  '  If Attribute.Empty = False Then
      Call SetBlockRouteButton(Form,Obj)
   ' End If
  End If

 ' If form.Controls.Has("TXT_" & Attribute.AttributeDefName) Then ShowUser(Attribute.AttributeDefName)
  'Изменение отдела после изменения ответственного
  If Attribute.AttributeDefName = "ATTR_RESPONSIBLE" Then
    AttrName = "ATTR_T_TASK_DEPARTMENT"
    If Attribute.Empty = False Then
      'Obj.Attributes(AttrName).Classifier = Attribute.User.DepartmentClassifier
      Set User = Attribute.User
      If User.Attributes.Has("ATTR_KD_USER_DEPT") Then
        If User.Attributes("ATTR_KD_USER_DEPT").Empty = False Then
          If not User.Attributes("ATTR_KD_USER_DEPT").Object is Nothing Then
            Obj.Attributes(AttrName).Object = User.Attributes("ATTR_KD_USER_DEPT").Object
          End If
        End If
      End If
    Else
      Obj.Attributes(AttrName).Object = Nothing
    End If
'    If Obj.Attributes(AttrName).Empty = False Then
'      Form.Controls(AttrName).ReadOnly = True
'    Else
'      Form.Controls(AttrName).ReadOnly = False
'    End If
  End If
  
  ' разработал
  If Attribute.AttributeDefName = "ATTR_T_TASK_DEVELOPED" Then
    Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","ChangeResponsible",Obj,Attribute.User,OldAttribute.User)
  End If
  'Ожидаемая дата = Планируемая дата
  If Attribute.AttributeDefName = "ATTR_ENDDATE_PLAN" Then
    Obj.Attributes("ATTR_ENDDATE_ESTIMATED").Value = Attribute.Value
  End If
End Sub


'Кнопка - Добавить отдел - адресат
Sub CMD_TDEPT_ADD_OnClick()
  Set Obj = ThisObject
  Set osDept = ThisApplication.Queries("QUERY_DEPARTMENTS")
  
  Set Dlg = ThisApplication.Dialogs.SelectDlg
  dlg.SelectFrom = osDept.Sheet
  dlg.Caption = "Выбор отдела-получателя"
  dlg.Prompt = "Выберите отделы-получатели:"
  RetVal = dlg.Show
  
  If Not RetVal Then Exit Sub
  Set os = dlg.Objects
  If os.objects.count = 0 Then Exit Sub
  
    Set Rows = Obj.Attributes("ATTR_T_TASK_TDEPTS_TBL").Rows
      For Each o in os.Objects
        Check = True
        For Each Row in Rows
          Set o1 = Row.Attributes("ATTR_T_TASK_DEPT").Object
          If Not o1 Is Nothing Then
            If o1.Handle = o.Handle Then
              Check = False
              Exit For
            End If
          End If
        Next
        If Check = True Then
          Call Add_Dept(Rows,o)
          'Автоформирование обозначения задания
          Call SetCode(Obj)
          'Set Table = ThisForm.Controls("ATTR_T_TASK_TDEPTS_TBL").ActiveX
          ThisForm.Refresh
        End If
      Next

'  ThisForm.Controls("BUTTON_TDEPT_DEL").Enabled = CheckObj5 And TblRowSelected("ATTR_T_TASK_TDEPTS_TBL") And IsCanEdit(Obj)
End Sub

'Sub CMD_TDEPT_ADD_OnClick()
'  Set Obj = ThisObject
'  Set us = SelectUsersByGroup("GROUP_LEAD_DEPT")
'  If us Is Nothing Then Exit Sub
'  
'    If us.Count <> 0 Then
'    
'    Set Rows = Obj.Attributes("ATTR_T_TASK_TDEPTS_TBL").Rows
'      For Each User in us
'        Check = True
'        For Each Row in Rows
'          Set u1 = Row.Attributes("ATTR_T_TASK_DEPT_PERSON").User
'          If Not u1 Is Nothing Then
'            If u1.SysName = User.SysName Then
'              Check = False
'              Exit For
'            End If
'          End If
'        Next
'        If Check = True Then
'          Call Add_Reciever(Obj,User)
'          'Автоформирование обозначения задания
'          Call SetCode(Obj)
'          'Set Table = ThisForm.Controls("ATTR_T_TASK_TDEPTS_TBL").ActiveX
'          ThisForm.Refresh
'        End If
'      Next
'    End If
'  ThisForm.Controls("BUTTON_TDEPT_DEL").Enabled = CheckObj5 And TblRowSelected("ATTR_T_TASK_TDEPTS_TBL") And IsCanEdit(Obj)
'End Sub

Sub Add_Dept(Rows,Dept)
  Set NewRow = Rows.Create
  
  Set chief = Dept.Attributes("ATTR_KD_CHIEF").User
  If chief Is Nothing Then Exit Sub
  
  If not chief.PositionClassifier is nothing then
    Set Position = chief.PositionClassifier
  End If
  
  NewRow.Attributes("ATTR_T_TASK_DEPT").Object = Dept
  NewRow.Attributes("ATTR_T_TASK_DEPT_PERSON").User = chief
  NewRow.Attributes("ATTR_POST") = Position
  
'  'NewRow.Attributes("ATTR_T_TASK_DEPT").Classifier = User.DepartmentClassifier
'  If User.Attributes.Has("ATTR_KD_USER_DEPT") Then
'    If User.Attributes("ATTR_KD_USER_DEPT").Empty = False Then
'      If not User.Attributes("ATTR_KD_USER_DEPT").Object is Nothing Then
'        NewRow.Attributes("ATTR_T_TASK_DEPT").Object = User.Attributes("ATTR_KD_USER_DEPT").Object
'      End If
'    End If
'  End If
'  NewRow.Attributes("ATTR_T_TASK_DEPT_PERSON").User = User
'  If not User.PositionClassifier is nothing then
'    NewRow.Attributes("ATTR_POST") = User.PositionClassifier
'  End If
End Sub

Sub Add_Reciever(Obj,User)
  Set Rows = Obj.Attributes("ATTR_T_TASK_TDEPTS_TBL").Rows
  Set NewRow = Rows.Create
  'NewRow.Attributes("ATTR_T_TASK_DEPT").Classifier = User.DepartmentClassifier
  If User.Attributes.Has("ATTR_KD_USER_DEPT") Then
    If User.Attributes("ATTR_KD_USER_DEPT").Empty = False Then
      If not User.Attributes("ATTR_KD_USER_DEPT").Object is Nothing Then
        NewRow.Attributes("ATTR_T_TASK_DEPT").Object = User.Attributes("ATTR_KD_USER_DEPT").Object
      End If
    End If
  End If
  NewRow.Attributes("ATTR_T_TASK_DEPT_PERSON").User = User
  If not User.PositionClassifier is nothing then
    NewRow.Attributes("ATTR_POST") = User.PositionClassifier
  End If
End Sub

'Кнопка - Удалить отдел-адресат
Sub BUTTON_TDEPT_DEL_OnClick()
  ThisScript.SysAdminModeOn
  Set Table = ThisForm.Controls("ATTR_T_TASK_TDEPTS_TBL")
  If Table.SelectedObjects.count < 1  Then
    msgbox "Не выраны отделы",vbExclamation,"Удаление отдела-получателя"
    Exit Sub
  End If

  str = ""
  For Each Row in Table.SelectedObjects
    If Row.Attributes("ATTR_T_TASK_DEPT_PERSON").Empty = False Then
      Tdept = Row.Attributes("ATTR_T_TASK_DEPT").Value
      If str <> "" Then
        str = str & ", " & Chr(10) & "- " & Tdept
      Else
        str = "- " & Tdept
      End If
    End If
  Next
  'Подтверждение удаления
  Result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion+vbYesNo, 3122, str)
  If Result = vbNo Then
    Exit Sub
  End If
  
  'Удаление строк и ролей
  Arr = Table.ActiveX.SelectedRows
  For i = 0 to UBound(Arr)
    Set Row = Table.ActiveX.RowValue(Arr(i))
    'Удаляем роль (хотя в данном состоянии ее быть не должно)
    If Row.Attributes("ATTR_T_TASK_DEPT_PERSON").Empty = False Then
      Set UG = Row.Attributes("ATTR_T_TASK_DEPT_PERSON").User
      Set Roles = ThisObject.RolesForUser(UG)
      For Each Role in Roles
        If Role.RoleDefName = "ROLE_T_TASK_IN_CHECKER" Then
          Role.Erase
        End If
      Next
    End If
    Row.Erase
  Next
  'Автоформирование обозначения задания
  Call SetCode(ThisObject)
End Sub

'Кнопка - Сформировать обозначение задания
Sub BUTTON_CODE_GEN_OnClick()
  'Автоформирование обозначения задания
  Call SetCode(ThisObject)
End Sub

'Автоформирование обозначения задания
Sub SetCode(Obj)
  Obj.Attributes("ATTR_T_TASK_CODE").Value = _
    ThisApplication.ExecuteScript("CMD_S_NUMBERING", "TtaskCodeGen",Obj)
End Sub


'Событие - Двойной клик мыши по файлу в выборке файлов

' Кнопка - Передать на проверку
Sub BTN_SEND_TO_CHECK_OnClick()
  If CheckForLock() Then Exit Sub
  
  ThisObject.Permissions = SysAdminPermissions 
  if ThisObject.permissions.view <> 0 then
    if thisObject.Permissions.LockOwner then 
      if ThisObject.Permissions.Locked = true Then 
        ThisObject.Unlock ThisObject.Permissions.LockType
      end if
    end if
  end if
  
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_TASK_TO_CHECK", "TaskToCheck", ThisObject)
  If Res = True Then
    ThisObject.Savechanges(0)
    ThisForm.Close True
  End If
End Sub

' Кнопка - Передать на подписание
Sub BTN_SEND_TO_SIGN_OnClick()
  If CheckForLock() Then Exit Sub
  ThisObject.Permissions = SysAdminPermissions 
  if ThisObject.permissions.view <> 0 then
    if thisObject.Permissions.LockOwner then 
      if ThisObject.Permissions.Locked = true Then 
        ThisObject.Unlock ThisObject.Permissions.LockType
      end if
    end if
  end if
  
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_TASK_SEND_TO_SIGN", "TaskToSign", ThisObject)
  If Res = True Then
    ThisObject.Savechanges(0)
    ThisForm.Close True
  End If
End Sub

'Кнопка - Подписать и передать на согласование
Sub BTN_SIGN_OnClick()
  If CheckForLock() Then Exit Sub
  ThisObject.Permissions = SysAdminPermissions 
  
  if ThisObject.permissions.view <> 0 then
    if thisObject.Permissions.LockOwner then 
      if ThisObject.Permissions.Locked = true Then 
        ThisObject.Unlock ThisObject.Permissions.LockType
      end if
    end if
  end if
  
  Dim res
  Res = ThisApplication.ExecuteScript("CMD_TASK_ISSUE", "TaskIssue", ThisObject)
  If Res = True Then
    ' -- > Case 5632 --
    ThisObject.Attributes("ATTR_SIGN_DATA") = FormatDateTime(ThisApplication.CurrentTime, 2)
    ' -- Case 5632 < --
    ThisObject.Update
    ans = msgbox("Вы хотите передать задание на согласование?",vbQuestion+vbYesNo,"Передача на согласование")
    If ans <> vbYes Then
      ThisObject.Savechanges(0)
      ThisForm.Close True
    Else
      Call BTN_TO_AGREE_OnClick()
    End If
  End If
End Sub

'Кнопка - Вернуть на доработку\Отклонить задание
Sub REJECT_TASK_OnClick()
  If CheckForLock() Then Exit Sub
  ThisObject.Permissions = SysAdminPermissions 
  if ThisObject.permissions.view <> 0 then
    if thisObject.Permissions.LockOwner then 
      if ThisObject.Permissions.Locked = true Then 
        ThisObject.Unlock ThisObject.Permissions.LockType
      end if
    end if
  end if
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_TASK_BACK_TO_WORK", "TaskReturn", ThisObject)
  If Res = True Then
    ThisObject.Savechanges(0)
    ThisForm.Close True
  End If
End Sub

'Кнопка - Утвердить задание
Sub ACCEPT_TASK_OnClick()
  If CheckForLock() Then Exit Sub
  ThisObject.Permissions = SysAdminPermissions 
  if ThisObject.permissions.view <> 0 then
    if thisObject.Permissions.LockOwner then 
      if ThisObject.Permissions.Locked = true Then 
        ThisObject.Unlock ThisObject.Permissions.LockType
      end if
    end if
  end if
  
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_TASK_ACCEPT", "TaskAccept", ThisObject)
  If Res = True Then
    ThisObject.Savechanges(0)
    ThisForm.Close True
  End If
End Sub

'Кнопка - Аннулировать задание
Sub BUTTON_INVALIDATE_OnClick()
  If CheckForLock() Then Exit Sub
  ThisObject.Permissions = SysAdminPermissions 
  Dim Res
  Res = ThisApplication.ExecuteScript("CMD_TASK_INVALIDATED", "TaskInvalidated", ThisObject)
  If Res = True Then
    ThisObject.Savechanges(0)
    ThisForm.Close True
  End If
End Sub

' Кнопка Выдать повторно
Sub BTN_TASK_DUPLICATE_OnClick()
  ThisApplication.Utility.WaitCursor = True
  Check12 = CheckObj12()
  If Not Check12 Then 
    msgbox "Недостаточно прав для выдачи задания повторно. т.к. вы не являетесь сотрудником отдела """ & ThisObject.Attributes("ATTR_T_TASK_DEPARTMENT").Object.Description & """"
'    ThisApplication.Utility.WaitCursor = False
    Exit Sub
  End If
  ThisForm.Close
  ThisApplication.Utility.WaitCursor = False
  Call CopyTask(ThisObject)
End Sub

'Функция проверки объекта на передачу на проверку
Function CheckObj0(Obj)
  thisapplication.DebugPrint "CheckObj0 " & Time
  CheckObj0 = False
  Set CU = ThisApplication.CurrentUser
  If Obj.StatusName = "STATUS_T_TASK_IN_WORK" And IsDeveloper(Obj,CU) Then
    CheckObj0 = True
  End If
End Function

'Функция проверки объекта на Отклонение с проверки или передачи на подпись
Function CheckObj1(Obj)
  thisapplication.DebugPrint "CheckObj1 " & Time
  CheckObj1 = False
  Set CU = ThisApplication.CurrentUser
  If Obj.StatusName = "STATUS_T_TASK_IS_CHECKING" And IsChecker(Obj,CU) Then
    CheckObj1 = True
  End If
End Function

'Функция проверки объекта на выдачу
Function CheckObj2(Obj)
  thisapplication.DebugPrint "CheckObj2 " & Time
  CheckObj2 = False
  Set CU = ThisApplication.CurrentUser
  If Obj.StatusName = "STATUS_T_TASK_IS_SIGNING" And IsSigner(Obj,CU) Then
    CheckObj2 = True
  End If
End Function

'Функция проверки объекта на утверждение
Function CheckObj3(Obj)
  thisapplication.DebugPrint "CheckObj3 " & Time
  CheckObj3 = False
  Set CU = ThisApplication.CurrentUser
  isGipDep = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsProjectGipDep",Obj,CU)
  
  If Obj.StatusName = "STATUS_T_TASK_IS_APPROVING" And (userIsAcceptor(Obj,CU) or isGipDep) Then
    CheckObj3 = True
  End If
End Function



'Функция проверки доступности добавления отдела-адресата
Function CheckObj5()
  thisapplication.DebugPrint "CheckObj5 " & Time
  CheckObj5 = False
  Set Obj = ThisObject
  Set CU = ThisApplication.CurrentUser
  
  'Момент создания объекта
  If ThisApplication.ObjectDefs("OBJECT_T_TASK").Objects.Has(ThisObject) = False Then
    CheckObj5 = True
    Exit Function
  End If
'  'Статус, роль
'  If ThisObject.StatusName = "STATUS_T_TASK_IN_WORK" and IsDeveloper(Obj,CU) Then
'    CheckObj5 = True
'    Exit Function
'  ElseIf ThisObject.StatusName = "STATUS_T_TASK_IS_CHECKING" and IsChecker(Obj,CU) Then
'    CheckObj5 = True
'    Exit Function
'  ElseIf ThisObject.StatusName = "STATUS_T_TASK_IS_SIGNING" and IsSigner(Obj,CU) Then
'    CheckObj5 = True
'    Exit Function
'  End If
End Function

Function CheckObj7()
  thisapplication.DebugPrint "CheckObj7 " & Time
  CheckObj7 = False
  Set CU = ThisApplication.CurrentUser
  Set Obj = ThisObject
  
  
  If CU.SysName = "SYSADMIN" Then 
    CheckObj7 = True
    Exit Function
  End If
  CheckObj7 = (ThisObject.Attributes("ATTR_T_TASK_DEPARTMENT").Empty = False)
End Function

Function CheckObj8()
  thisapplication.DebugPrint "CheckObj8 " & Time
  CheckObj8 = False
  Set Obj = ThisObject
  Set CU = ThisApplication.CurrentUser
  Set Roles = ThisObject.RolesForUser(CU)
  If CU.SysName = "SYSADMIN" Then 
    CheckObj8 = True
    Exit Function
  End If
  If Obj.StatusName = "STATUS_T_TASK_IN_WORK" or Obj.StatusName = "STATUS_T_TASK_APPROVED" or _
    Obj.StatusName = "STATUS_T_TASK_IS_CHECKING" or Obj.StatusName = "STATUS_T_TASK_IS_APPROVING" Then
    If Roles.Has("ROLE_T_TASK_INVALIDATE") or Roles.Has("ROLE_GIP") or Roles.Has("ROLE_GIP_DEP") or _
    Roles.Has("ROLE_T_TASK_OUT_CHECKER") Then
      CheckObj8 = True
    End If
  End If
End Function

Function CheckObj10()
  thisapplication.DebugPrint "CheckObj10 " & Time
  CheckObj10 = False
  Set Obj = ThisObject
  Set CU = ThisApplication.CurrentUser
  isExec = ThisApplication.ExecuteScript("CMD_KD_USER_PERMISSIONS", "isInic",CU, Obj)
  isDvlp = IsDeveloper(Obj,CU)
  isSgn = IsSigner(Obj,CU)
  
  If (Obj.StatusName = "STATUS_T_TASK_IS_SIGNED" And (isDvlp or isExec)) or _
     (Obj.StatusName = "STATUS_T_TASK_IS_SIGNING" And ((isSgn And isDvlp) or isExec)) Then
     '     (ThisObject.StatusName = "STATUS_T_TASK_IN_WORK" And (isSgn And isDvlp)) Or _
    CheckObj10 = True
  End If
End Function

Function CheckObj11()
  thisapplication.DebugPrint "CheckObj11 " & Time
  CheckObj11 = False
  Set Obj = ThisObject
  Set CU = ThisApplication.CurrentUser
  Select Case Obj.StatusName
    Case "STATUS_T_TASK_IS_CHECKING"
        CheckObj11 =  ThisApplication.ExecuteScript("CMD_TASK_SEND_TO_SIGN","needToChangeStatus",Obj)
  End Select
End Function

Function CheckObj12()
  thisapplication.DebugPrint "CheckObj12 " & Time
  Set CU = ThisApplication.CurrentUser
  Set Obj = ThisObject
  Set Resp = Obj.Attributes("ATTR_RESPONSIBLE").User
  CheckObj12 =ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","IsTheSameDeptByUsers",CU,Resp)
End Function

'=========================================================================================
' Функция проверки наличия роли пользователя ROLE_TASK_ACCEPT или записи в атрибут Утверждающий
'-----------------------------------------------------------------------------------------
' Obj: - объект
' user - пользователь
' userIsAcceptor: True - есть роль ROLE_TASK_ACCEPT
'                 False - нет роли ROLE_TASK_ACCEPT
'=========================================================================================
Function userIsAcceptor(Obj,user)
  thisapplication.DebugPrint "userIsAcceptor " & Time
  userIsAcceptor = False
  Set Roles = Obj.RolesForUser(user)
  If Roles.Has("ROLE_TASK_ACCEPT") Then 
    userIsAcceptor = True
  Else
    If not Obj.Attributes.has("ATTR_DOCUMENT_CONF") then exit function
    set accept = Obj.Attributes("ATTR_DOCUMENT_CONF").user
    If accept is nothing then exit function
    userIsAcceptor = (accept.SysName = user.SysName)
  End If
End Function


Function userIsResponsible(Obj,user)
  thisapplication.DebugPrint "userIsResponsible " & Time
  userIsResponsible = False
  Set Roles = ThisObject.RolesForUser(user)
  If Roles.Has("ROLE_T_TASK_OUT_CHECKER") Then 
    userIsResponsible = True
  Else
    If not Obj.Attributes.has("ATTR_RESPONSIBLE") then exit function
    set Responsible = Obj.Attributes("ATTR_RESPONSIBLE").user
    If Responsible is nothing then exit function
    userIsResponsible = (Responsible.SysName = user.SysName)
  End If
End Function

'Событие - изменено выделение в таблице отделов-адресатов
Sub ATTR_T_TASK_TDEPTS_TBL_SelChanged()
  Set Obj = ThisObject
  Check0 = CheckObj0(Obj)
  Check1 = CheckObj1(Obj)
  Check2 = CheckObj2(Obj)
  ThisForm.Controls("BUTTON_TDEPT_DEL").Enabled = (CheckObj5() or check0 or check1 or check2) And _
            TblRowSelected("ATTR_T_TASK_TDEPTS_TBL") And  IsCanEdit(Obj)
End Sub

'====================================================================
' Перенесено с формы Результаты

'Функция проверки формы на доступность удаления
Function CheckObjAdd()
  CheckObjAdd = True
  Set Obj = ThisObject
  If ThisApplication.ObjectDefs("OBJECT_T_TASK").Objects.Has(Obj) = False Then
    'Проверка на заполнение обязательных атрибутов
    If Obj.Attributes("ATTR_T_TASK_DEPARTMENT").Empty = True or _
              Obj.Attributes("ATTR_T_TASK_CODE").Empty = True Then
      CheckObjAdd = False
    Else
      CheckObjAdd = False
      Msgbox "Для работы на этой форме, сначала нужно заполнить бязательные атрибуты - Обозначение, Отдел.", vbInformation
    End If
    Exit Function
  End If
End Function

'Функция проверки формы на доступность удаления
Function CheckObjDel()
  CheckObjDel = False
  Set Obj = ThisObject
    If ThisApplication.ObjectDefs("OBJECT_T_TASK").Objects.Has(Obj) = False Then
      CheckObjDel = True
      Exit Function
    End If
End Function

'=========================================================================================
' Функция проверки выбора строк таблицы
'-----------------------------------------------------------------------------------------
' tblAttr: - системный идентификатор табличного атрибута объекта
' TblRowSelected: True - выбраны строки
'                 False - не выбраны строки
'=========================================================================================
Function TblRowSelected(tblAttr)
  TblRowSelected = False
  If Not ThisForm.Controls.Has(tblAttr) Then Exit Function
  
  Set Table = ThisForm.Controls(tblAttr)
  If Table.SelectedObjects.Count <> 0 Then
    TblRowSelected = True
  End If
End Function

'Кнопка - Добавить
Sub BUTTON_ADD_OnClick()
  ThisScript.SysAdminModeOn
  Set Obj = ThisObject
  If Obj.Permissions.LockOwner = False Then
    If not Obj.Permissions.LockUser Is Nothing Then
      msgbox "Невозможно редактировать документ, т.к. " & Obj.Permissions.LockUser.Description & _
            " уже заблокировал документ.", vbCritical, "Редактирование не возможно!"
      Exit Sub
    End If
  End If
  ' Отбираем объекты
  
  Set oProj = ThisObject.Attributes("ATTR_PROJECT").Object
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "'OBJECT_DOC' Or 'OBJECT_DOC_DEV' Or 'OBJECT_DOCUMENT' Or 'OBJECT_DRAWING' Or 'OBJECT_DOCUMENT_AN' Or 'OBJECT_LIST_AN'"
  q.AddCondition tdmQueryConditionAttribute, oProj, "ATTR_PROJECT"
  Set Objects = q.Objects
  Set q2 = ThisApplication.Queries("QUERY_TASK_ADD_DATA")
  q2.Parameter("PROJECT") = oProj
  For Each oDoc in q2.Objects
    Objects.Add oDoc
  Next
  
  If Objects.Count = 0 Then
    Msgbox "Нет доступных объектов для добавления.", vbExclamation
    Exit Sub
  End If
  
  
  If Not Obj.Attributes.Has("ATTR_T_TASK_DOC") Then Exit Sub
  Set Table = Obj.Attributes("ATTR_T_TASK_DOC")
  Set Rows = Table.Rows
  Set CU = ThisApplication.CurrentUser
  
  'Исключаем объекты, которые уже есть в таблице
  ThisApplication.ExecuteScript "CMD_DLL", "QueryObjectsFilter", Objects, "ATTR_DOC_REF", Rows
  
  If Objects.Count = 0 Then
    Msgbox "Нет доступных объектов для добавления.", vbExclamation
    Exit Sub
  End If
  
  'Показываем диалог выбора
  Set Dlg = ThisApplication.Dialogs.SelectObjectDlg
  Dlg.Prompt = "Выберите объекты для добавления"
  Dlg.SelectFromObjects = Objects

  If Dlg.Show Then
    If Dlg.Objects.Count <> 0 Then
      ' Добавляем строки
      For Each o In Dlg.Objects
        If Not ObjExist(Table, "ATTR_DOC_REF",o) Then
          Set NewRow = Rows.Create
          NewRow.Attributes("ATTR_DOC_REF").Object = o
          NewRow.Attributes("ATTR_USER").User = CU
        End If
      Next
    Else
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 1605
    End If
  End If
End Sub

'Кнопка - Удалить
Sub BUTTON_DEL_OnClick()
  ThisScript.SysAdminModeOn
  Set Table = ThisForm.Controls("ATTR_T_TASK_DOC")
  Set CU = ThisApplication.CurrentUser
  Set Obj = ThisObject
  Arr = Table.ActiveX.SelectedRows
  'Проверка прав
  Check0 = False
  Check1 = True
  'ГИП
  If ThisObject.RolesForUser(CU).Has("ROLE_GIP") Then Check0 = True
  'Ответственный
  If Check0 = False Then
    AttrName = "ATTR_RESPONSIBLE"
    If ThisObject.Attributes(AttrName).Empty = False Then
      If not ThisObject.Attributes(AttrName).User is Nothing Then
        If ThisObject.Attributes(AttrName).User.SysName = CU.SysName Then Check0 = True
      End If
    End If
  End If
  'Каждую строку на добавляющего
  If Check0 = False Then
    Check1 = True
    AttrName = "ATTR_USER"
    For i = 0 to UBound(Arr)
      Set Row = Table.ActiveX.RowValue(Arr(i))
      If Row.Attributes(AttrName).Empty = False Then
        If not Row.Attributes(AttrName).User is Nothing Then
          If Row.Attributes(AttrName).User.SysName <> CU.SysName Then
            Check1 = False
            Exit For
          End If
        Else
          Check1 = False
          Exit For
        End If
      Else
        Check1 = False
        Exit For
      End If
    Next
  End If
  If Check0 = False And Check1 = False Then
    Msgbox "У вас нет прав удалять выделенные строки.", vbExclamation
    Exit Sub
  End If
  
  'Подтверждение удаления
  Key = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion + vbYesNo, 1607, UBound(Arr)+1)
  If Key = vbNo Then Exit Sub
  
  'Удаление строк
  For i = 0 to UBound(Arr)
    Set Row = Table.ActiveX.RowValue(Arr(i))    
    Row.Erase
  Next
  ThisForm.Refresh
  isRowSel = TblRowSelected("ATTR_T_TASK_DOC")
  isResp = userIsResponsible(Obj,CU)
  isDvlp = IsDeveloper(Obj,CU)
  usCanEdit = IsCanEdit(Obj)
  ThisForm.Controls("BUTTON_DEL").Enabled = CheckObjDel or (isRowSel And (isResp or isDvlp)) And usCanEdit'TblRowSelected("ATTR_T_TASK_DOC") And CheckObjDel
End Sub

'Событие - изменено выделение в таблице исходных документов
Sub ATTR_T_TASK_DOC_SelChanged()
  Set CU = ThisApplication.CurrentUser
  Set Obj = ThisObject
  isRowSel = TblRowSelected("ATTR_T_TASK_DOC")
  isResp = userIsResponsible(Obj,CU)
  isDvlp = IsDeveloper(Obj,CU)
  usCanEdit = IsCanEdit(Obj)
  ThisForm.Controls("BUTTON_DEL").Enabled = CheckObjDel or (isRowSel And (isResp or isDvlp)) And usCanEdit'TblRowSelected("ATTR_T_TASK_DOC") And CheckObjDel
  ThisForm.Controls("BUTTON_INFO").Enabled = isRowSel 'And CheckObjDel
End Sub

Sub BTN_TO_AGREE_OnClick()
  ThisForm.Close True
  
  ' Запоминаем, какую форму нужно активировать при переоткрытии диалога свойств
  Set dict = ThisObject.Dictionary
  If Not dict.Exists("FormActive") Then 
    dict.Add "FormActive", "FORM_KD_DOC_AGREE"
  End If 
  
  Call ThisApplication.ExecuteScript ("CMD_DOC_SENT_TO_AGREED", "Run", ThisObject)
End Sub



Sub BTN_DEL_ANNEX_OnClick()
'  Call ThisApplication.ExecuteScript("CMD_DLL","DeleteFromTable",ThisForm,"ATTR_DOCS_TLINKS")
  Call DeleteFromTable(thisobject,ThisForm,"ATTR_DOCS_TLINKS")
End Sub

' Кнопка - Добавить приложение
Sub BTN_ADD_ANNEX_OnClick()
  Set oProj = ThisObject.Parent.Attributes("ATTR_PROJECT").Object
  Set q = ThisApplication.Queries("QUERY_PROJECT_DOCS_ALL")
  q.Parameter("PARAM0") = oProj.handle

  Set Objects = q.Objects
  If Objects.Count = 0 Then
    msgbox "В проекте нет документов",vbExclamation,"Добавить приложение"
    Exit Sub
  End If



  Set Table = ThisObject.Attributes("ATTR_DOCS_TLINKS")
  Set TableRows = Table.Rows
  
  'Исключаем объекты, которые уже есть в таблице
'  ThisApplication.ExecuteScript "CMD_DLL", "QueryObjectsFilter", Objects, "ATTR_DOC_REF", TableRows
  ThisApplication.ExecuteScript "CMD_DLL", "QueryObjectsFilter", Objects, TableRows.AttributeDefs(0).SysName, TableRows
  
  If Objects.Count = 0 Then
    Msgbox "Нет доступных объектов для добавления.", vbExclamation
    Exit Sub
  End If
  
  'Показываем диалог выбора
  Set Dlg = ThisApplication.Dialogs.SelectObjectDlg
  Dlg.Prompt = "Выберите объекты для добавления"
  Dlg.SelectFromObjects = Objects

  If Dlg.Show Then
    If Dlg.Objects.Count <> 0 Then
      ' Добавляем строки
      For Each o In Dlg.Objects
        Set Rows = Table.Rows
'        If Not ObjExist(Table, TableRows.AttributeDefs(0).SysName,o) Then
'        Call ThisApplication.ExecuteScript ("CMD_S_DLL","SetLinkToBaseDoc",o,Obj,noteTxt)
'        
          Set NewRow = Rows.Create
          NewRow.Attributes(0).Object = o
          NewRow.Attributes(1).Value = thisApplication.CurrentUser
          NewRow.Attributes(2).Value = FormatDateTime(Date,vbShortDate)
          Rows.Update
'        End If
      Next
      ThisObject.SaveChanges (0)
    Else
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 1605
    End If
  End If


End Sub

Sub BTN_ADD_FILE_OnClick()
  Call AddObjLinkFile(ThisObject)
End Sub


Sub BTN_OBJECT_TASK_CREATE_RETURN_OnClick()
  Set Obj = ThisObject
  ThisForm.Close True
  Set ReplyTask = ThisApplication.ExecuteScript("CMD_OBJECT_TASK_CREATE_RETURN","CreateTask",ThisObject)
End Sub

Sub BTN_ANNEX_INFO_OnClick()
  Call ShowTableObj(ThisForm.Controls("ATTR_DOCS_TLINKS"),"ATTR_DOC_REF")
End Sub

' Открыте объекта
Sub BUTTON_INFO_OnClick()
  Call ShowTableObj(ThisForm.Controls("ATTR_T_TASK_DOC"),"ATTR_DOC_REF")
End Sub


