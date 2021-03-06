USE "CMD_DLL_ROLES"

Sub Form_BeforeShow(Form, Obj)
thisapplication.DebugPrint "Form_BeforeShow: " & Time
  form.Caption = form.Description
  Call SetContolEnable(Form, Obj)
End Sub

Sub SetContolEnable(Form, Obj)
  set cCtl=ThisForm.controls
  Set CU = ThisApplication.CurrentUser
  isAuth = IsAuthor(Obj,CU)
  isSign = IsSigner(Obj,CU)
  isChck = IsChecker(Obj,CU)
End Sub

'Кнопка - Добавить накладную
Sub BUTTON_ADD_OnClick()
  Set TableRows = ThisObject.Attributes("ATTR_TINVOICES").Rows
  Set Query = ThisApplication.Queries("QUERY_CONTRACT_COMPL_REPORT_INVOICE")
  Set Contract = ThisApplication.ExecuteScript("CMD_S_NUMBERING","ObjectLinkGet",ThisObject,"ATTR_CONTRACT")

  Set project = ThisObject.Attributes("ATTR_PROJECT").Object
  If project is Nothing Then
    msgbox "Проект не задан!",vbCritical,"Ошибка"
    Exit Sub
  End If

  Query.Parameter("PROJ") = project

  Set Objects = Query.Objects
  Call QueryObjectsFilter(Objects,"ATTR_INVOICE",TableRows)
  
  If Objects.Count <> 0 Then
    Set Dlg = ThisApplication.Dialogs.SelectObjectDlg
    Dlg.Caption = "Выбор накладной"
    Dlg.SelectFromObjects = Objects
    If Dlg.Show Then
      For Each Obj in Dlg.Objects
        Set NewRow = TableRows.Create
        NewRow.Attributes("ATTR_INVOICE").Object = Obj
        ThisObject.SaveChanges (0)
      Next
    End If
  Else
    Msgbox "Нет доступных для выбора накладных.", vbExclamation
    Exit Sub
  End If
End Sub

'Кнопка - Удалить накладную
Sub BUTTON_DEL_OnClick()
'  Set Table = ThisForm.Controls("ATTR_TINVOICES")
'  Set TableRows = ThisObject.Attributes("ATTR_TINVOICES").Rows
'  If Table.SelectedObjects.Count <> 0 Then
'    Key = Msgbox("Удалить связь с выбранными накладными?",vbYesNo+vbQuestion)
'    If Key = vbYes Then
'      For Each Row in Table.SelectedObjects
'        TableRows.Remove Row
'      Next
'    End If
'  End If

  ThisScript.SysAdminModeOn
  Set Query = ThisForm.Controls("QUERY_CCR_INVOICE")
  Set Objects = Query.SelectedObjects
  
  'Подтверждение удаления
  If Objects.Count <> 0 Then
    Key = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion + vbYesNo, 1607, Objects.Count)
    If Key = vbNo Then Exit Sub
  End If
  
  'Удаление строк из таблицы
  Set TableRows = ThisObject.Attributes("ATTR_TINVOICES").Rows
  For Each Row in TableRows
    If Row.Attributes("ATTR_INVOICE").Empty = False Then
      If not Row.Attributes("ATTR_INVOICE").Object is Nothing Then
        If Objects.Has(Row.Attributes("ATTR_INVOICE").Object) Then
          TableRows.Remove Row
        End If
      End If
    End If
  Next
  ThisObject.SaveChanges (0)
End Sub

Sub BUTTON_DOCS_ADD_OnClick()
  ThisScript.SysAdminModeOn
  Set TableRows = ThisObject.Attributes("ATTR_DOCS_TLINKS").Rows
  
  If ThisObject.Attributes.Has("ATTR_CONTRACT") Then 
    Set oContr = ThisObject.Attributes("ATTR_CONTRACT").Object
    If oContr is Nothing Then Exit Sub
  End If
  If ThisObject.Attributes.Has("ATTR_PROJECT") Then
    Set Project = ThisObject.Attributes("ATTR_PROJECT").Object
    If Project is Nothing Then 
      msgbox "Проект не задан!",vbCritical,"Ошибка"
      Exit Sub
    End If
  End If

  
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "'OBJECT_WORK_DOCS_SET' Or 'OBJECT_VOLUME' Or 'OBJECT_INVOICE'"
  q.AddCondition tdmQueryConditionAttribute,  Project, "ATTR_PROJECT"
  If ThisObject.Attributes("ATTR_CCR_INCOMING") = True Then
    q.AddCondition tdmQueryConditionAttribute,  1, "ATTR_SUBCONTRACTOR_WORK"
    q.AddCondition tdmQueryConditionAttribute,  oContr, "ATTR_CONTRACT_SUBCONTRACTOR"
  End If
  
  Set Objects = q.Objects
  Objects.Sort True
  If Objects.count = 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1701
    Exit Sub
  End If  
  
  'Исключаем объекты, которые уже есть в таблице
  ThisApplication.ExecuteScript "CMD_DLL", "QueryObjectsFilter", Objects, "ATTR_DOC_REF", TableRows
  
  If Objects.Count = 0 Then
    Msgbox "В системе нет подходящих объектов.", vbExclamation
    Exit Sub
  End If
  
  Set Dlg = ThisApplication.Dialogs.SelectObjectDlg
  Dlg.SelectFromObjects = Objects
  If Dlg.Show Then
    If Dlg.Objects.Count <> 0 Then
      For Each Obj in Dlg.Objects
        'Проверка на наличие задания в таблице
        Check = True
        GUID = Obj.GUID
        For Each Row in TableRows
          If Row.Attributes("ATTR_DOC_REF").Empty = False Then
            If not Row.Attributes("ATTR_DOC_REF").Object is Nothing Then
              If Row.Attributes("ATTR_DOC_REF").Object.GUID = GUID Then
                Check = False
                Exit For
              End If
            End If
          End If
        Next
        If Check = True Then
          'Создаем новую запись в таблице
          Set NewRow = TableRows.Create
          NewRow.Attributes("ATTR_DOC_REF").Object = Obj
          NewRow.Attributes("ATTR_USER").Value = ThisApplication.CurrentUser
          NewRow.Attributes("ATTR_DATA").Value = ThisApplication.CurrentTime
        End If
      Next
      ThisApplication.ExecuteScript "CMD_DLL", "TableRowsSort", TableRows, "ATTR_DOC_REF"
      ThisForm.Refresh
    End If
  End If
End Sub


Sub BUTTON_DOCS_DEL_OnClick()
  ThisScript.SysAdminModeOn
  Set Table = ThisForm.Controls("ATTR_DOCS_TLINKS")
  Arr = Table.ActiveX.SelectedRows
  'Подтверждение удаления
  Key = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion + vbYesNo, 1607, UBound(Arr)+1)
  If Key = vbNo Then Exit Sub
  
  'Удаление строк
  For i = 0 to UBound(Arr)
    Set Row = Table.ActiveX.RowValue(Arr(i))    
    Row.Erase
  Next
  ThisForm.Refresh
End Sub


