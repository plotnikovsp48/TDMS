' Автор: Чернышов Д.С.
'
' Форма ввода - Связанные части проекта
'------------------------------------------------------------------------------
' Авторское право c ЗАО <СиСофт>, 2016 г.

USE "CMD_DLL"
USE "CMD_S_DLL"
USE "CMD_LIBRARY"
USE "CMD_DLL_ROLES"

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Call SetFormPermissions(Form, Obj)
  Call SetControls(Form, Obj)
  Call ClearOrderAttr()
End Sub

' Сохраняет в словарь права пользователя на кнопки формы
Sub SetFormPermissions(Form, Obj)
  Set frm = ThisApplication.Dictionary(Form.Sysname)
    
  If frm.Exists("Check0") = True Then frm.Remove "Check0"
  If frm.Exists("Check1") = True Then frm.Remove "Check1"
  If frm.Exists("Check2") = True Then frm.Remove "Check2"
  If frm.Exists("Check3") = True Then frm.Remove "Check3"

  frm.Add "Check0", ThisApplication.ExecuteScript("FORM_S_TASK","CheckObj0",Obj)
  frm.Add "Check1", ThisApplication.ExecuteScript("FORM_S_TASK","CheckObj1",Obj)
  frm.Add "Check2", ThisApplication.ExecuteScript("FORM_S_TASK","CheckObj2",Obj)
  frm.Add "Check3", ThisApplication.ExecuteScript("FORM_PROJECT_PARTS_LINKED","CheckObj3",Obj)
End Sub

Sub SetControls(Form,Obj)
  Set frm = ThisApplication.Dictionary(Form.Sysname)
  Set CU = ThisApplication.CurrentUser
  Set cCtrl = Form.Controls

  Check0 = frm.Item("Check0") 
  Check1 = frm.Item("Check1") 
  Check2 = frm.Item("Check2") 
  Check3 = frm.Item("Check3") 
  
  If Obj.Status is Nothing Then Exit Sub
    If Obj.StatusName = "STATUS_T_TASK_INVALIDATED" Then 'Obj.StatusName = "STATUS_T_TASK_APPROVED"  or
      Call SetControlReadOnly(Form,"CMD_PPART_ADD")
  '    Call SetControlVisible(Form,"CMD_PPART_ADD,CMD_PPART_DEL" ,False)
    End If
  
  
  Form.Controls("BUTTON_ADD").Enabled = Check3 or Check1 or Check2
  Form.Controls("BUTTON_DEL").Enabled = Check3 or Check1 or Check2
  Form.Controls("CMD_PPART_DEL").Enabled = Check0 or Check1 or Check2
  
  Form.Controls("BUTTON_DOC_ADD").Enabled = CheckObjAdd() 
  Form.Controls("BTN_ADD_FILE").Enabled = CheckObjAdd() 
  Form.Controls("BUTTON_DOC_DEL").Enabled = CheckObjDel() 
  
  Form.Controls("ATTR_KD_TEXT").Enabled = True
  Form.Controls("ATTR_KD_HIST_NOTE").Enabled = True
End Sub

'Кнопка - Добавить
Sub CMD_PPART_ADD_OnClick()
  ThisScript.SysAdminModeOn
  Set TableRows = ThisObject.Attributes("ATTR_T_TASK_PPLINKED").Rows
  Set Project = Nothing
  If ThisObject.Attributes("ATTR_PROJECT").Empty = False Then
    If not ThisObject.Attributes("ATTR_PROJECT").Object is Nothing Then
      Set Project = ThisObject.Attributes("ATTR_PROJECT").Object
    End If
  End If
  If Project is Nothing Then Exit Sub
  Set q = ThisApplication.Queries("QUERY_PROJECT_PARTS_FOR_TASK")
  q.Parameter("PARAM0") = ThisObject
  
 
  Set Objects = q.Objects
  If Objects.count = 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1701
    Exit Sub
  End If  
  
  'Исключаем объекты, которые уже есть в таблице
  ThisApplication.ExecuteScript "CMD_DLL", "QueryObjectsFilter", Objects, "ATTR_T_LINKEDOBJECT", TableRows
  
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
        Call Add_ProjParts_Link(TableRows,Obj)
        
'        Check = True
'        GUID = Obj.GUID
'        For Each Row in TableRows
'          If Row.Attributes("ATTR_T_LINKEDOBJECT").Empty = False Then
'            If not Row.Attributes("ATTR_T_LINKEDOBJECT").Object is Nothing Then
'              If Row.Attributes("ATTR_T_LINKEDOBJECT").Object.GUID = GUID Then
'                Check = False
'                Exit For
'              End If
'            End If
'          End If
'        Next
'        If Check = True Then
'          'Создаем новую запись в таблице
'          Set NewRow = TableRows.Create
'          NewRow.Attributes("ATTR_T_LINKEDOBJECT").Object = Obj
'          NewRow.Attributes("ATTR_OBJECT_TYPE").Value = Obj.ObjectDef.Description
'        End If
      Next
'      ThisForm.Refresh
'      Call ButtonDelEnable()
      ThisApplication.ExecuteScript "CMD_DLL", "TableRowsSort", TableRows, "ATTR_T_LINKEDOBJECT"
      ThisObject.SaveChanges(0)
    End If
  End If
End Sub

'Событие - изменено выделение в таблице исходных документов
Sub ATTR_T_TASK_PPLINKED_SelChanged()
  Set Form = ThisForm
  Set frm = ThisApplication.Dictionary(Form.Sysname)
  Check0 = frm.Item("Check0") 
  Check1 = frm.Item("Check1") 
  Check2 = frm.Item("Check2") 
  ThisForm.Controls("CMD_PPART_ADD").Enabled = True
  ThisForm.Controls("CMD_PPART_DEL").Enabled = CMD_PPART_DEL_Check() And (Check0 or Check1 or Check2)
End Sub

Function CMD_PPART_DEL_Check()
  CMD_PPART_DEL_Check = False
  Set Table = ThisForm.Controls("ATTR_T_TASK_PPLINKED")
  Arr = Table.ActiveX.SelectedRows
  If UBound(Arr) >-1 Then
    CMD_PPART_DEL_Check = True
  End If
End Function

' Кнопка Удалить
Sub CMD_PPART_DEL_OnClick()
  ThisScript.SysAdminModeOn
  Set Table = ThisForm.Controls("ATTR_T_TASK_PPLINKED")
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
'  Call ButtonDelEnable()
End Sub

'Кнопка - Добавить
Sub BUTTON_ADD_OnClick()
  ThisScript.SysAdminModeOn
  Set TableRows = ThisObject.Attributes("ATTR_T_TASK_LINKED").Rows
  Set Query = ThisApplication.Queries("QUERY_TASK_IN_PROJECT_FOR_LINKS")
  Query.Parameter("OBJ") = ThisObject
  Query.Parameter("NOTOBJ") = "<> '" & ThisObject.Description & "'"
  Set Objects = Query.Objects
  
  'Исключаем задания, которые уже есть в таблице
  ThisApplication.ExecuteScript "CMD_DLL", "QueryObjectsFilter", Objects, "ATTR_T_TASK_LINK", TableRows
  
  If Objects.Count = 0 Then
    Msgbox "В системе нет подходящих объектов.", vbExclamation
    Exit Sub
  End If
  
  Set Dlg = ThisApplication.Dialogs.SelectObjectDlg
  Dlg.SelectFromObjects = Objects
  If Dlg.Show Then
    If Dlg.Objects.Count <> 0 Then
      For Each Obj in Dlg.Objects
        'Создаем новую запись в таблице
        Call Add_Task_Link(TableRows,Obj)
'          
'          Set NewRow = TableRows.Create
'          NewRow.Attributes("ATTR_T_TASK_LINK").Object = Obj
      Next
      ThisObject.Update
      'ThisForm.Refresh
    End If
  End If
End Sub

Sub Add_Task_Link(TableRows,Obj)
  'Создаем новую запись в таблице
  Set NewRow = TableRows.Create
  NewRow.Attributes("ATTR_T_TASK_LINK").Object = Obj
End Sub

Sub Add_ProjParts_Link(TableRows,Obj)
  'Создаем новую запись в таблице
  Set NewRow = TableRows.Create
  NewRow.Attributes("ATTR_T_LINKEDOBJECT").Object = Obj
  NewRow.Attributes("ATTR_OBJECT_TYPE").Value = Obj.ObjectDef.Description
End Sub

'Кнопка - Удалить
Sub BUTTON_DEL_OnClick()
  ThisScript.SysAdminModeOn
  Set Query = ThisForm.Controls("QUERY_PARENT_TASK")
  Set Objects = Query.SelectedObjects
  
  'Подтверждение удаления
  If Objects.Count <> 0 Then
    Key = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion + vbYesNo, 1607, Objects.Count)
    If Key = vbNo Then Exit Sub
  End If
  
  'Удаление строк из таблицы
  Set TableRows = ThisObject.Attributes("ATTR_T_TASK_LINKED").Rows
  For Each Row in TableRows
    If Row.Attributes("ATTR_T_TASK_LINK").Empty = False Then
      If not Row.Attributes("ATTR_T_TASK_LINK").Object is Nothing Then
        If Objects.Has(Row.Attributes("ATTR_T_TASK_LINK").Object) Then
          TableRows.Remove Row
        End If
      End If
    End If
  Next
  ThisObject.Update
  ThisForm.Refresh
End Sub

Sub QUERY_PARENT_TASK_Selected(iItem, action)
  Set Form = ThisForm
  Set frm = ThisApplication.Dictionary(Form.Sysname)
  Check0 = frm.Item("Check0") 
  Check1 = frm.Item("Check1") 
  Check2 = frm.Item("Check2") 
  
  If iItem <> -1 Then
    ThisForm.Controls("BUTTON_DEL").Enabled = Check0 or Check1 or Check2
  Else
    ThisForm.Controls("BUTTON_DEL").Enabled = False
  End If
End Sub




'==============================================================
' Перенесено с вкладки Результаты






'Функция проверки формы на доступность удаления
Function CheckObjAdd()
  CheckObjAdd = False
  Set Obj = ThisObject
  Set CU = ThisApplication.CurrentUser
  Set Roles = Obj.RolesForUser(CU)
  If ThisApplication.ObjectDefs("OBJECT_T_TASK").Objects.Has(Obj) = False Then
    'Проверка на заполнение обязательных атрибутов
    If Obj.Attributes.Has("ATTR_T_TASK_DEPARTMENT") and Obj.Attributes.Has("ATTR_T_TASK_CODE") Then
      If Obj.Attributes("ATTR_T_TASK_DEPARTMENT").Empty = False and Obj.Attributes("ATTR_T_TASK_CODE").Empty = False Then
        'CheckObjAdd = True
      Else
        Msgbox "Для работы на этой форме, сначала нужно заполнить обязательные атрибуты - Обозначение, Отдел.", vbInformation
      End If
      Exit Function
    End If
  End If
  If userIsReciever(Obj,CU)  Then 'or Roles.Has("ROLE_T_TASK_DEVELOPER")
    CheckObjAdd = True
  End If
End Function

'Функция проверки формы на доступность удаления
Function CheckObjDel()
  CheckObjDel = False
  Set Obj = ThisObject
  Set CU = ThisApplication.CurrentUser
  Set Roles = ThisObject.RolesForUser(CU)
'  Set Query = ThisForm.Controls("QUERY_DOCS_TLINKS")
  Set Query = ThisForm.Controls("QUERY_KD_DOC_RELATIONS")
  Set Objects = Query.SelectedObjects
  If Objects.Count <> 0 Then
    If ThisApplication.ObjectDefs("OBJECT_T_TASK").Objects.Has(ThisObject) = False Then
      CheckObjDel = True
      Exit Function
    End If
    If userIsReciever(Obj,CU) Then 'or Roles.Has("ROLE_T_TASK_DEVELOPER") 
      CheckObjDel = True
    End If
  End If
End Function

'Кнопка - Добавить
Sub BUTTON_DOC_ADD_OnClick()
  ThisScript.SysAdminModeOn
  Set Obj = ThisObject
'  If Not Obj.Attributes.Has("ATTR_DOCS_TLINKS") Then Exit Sub
  If Not Obj.Attributes.Has("ATTR_KD_T_LINKS") Then Exit Sub
      
  ' Отбираем объекты
  Dim q
  Set oProj = ThisObject.Attributes("ATTR_PROJECT").Object
  Set q = ThisApplication.CreateQuery
  q.Permissions = sysadminpermissions
  q.AddCondition tdmQueryConditionObjectDef, "'OBJECT_WORK_DOCS_SET' Or 'OBJECT_DOC' Or 'OBJECT_PROJECT_SECTION' Or 'OBJECT_PROJECT_SECTION_SUBSECTION'"
  q.AddCondition tdmQueryConditionAttribute, oProj, "ATTR_PROJECT"
  Set Objects = q.Objects
  If Objects.Count = 0 Then
    Msgbox "Нет доступных объектов для добавления.", vbExclamation
    Exit Sub
  End If
  
 
'  Set Table = Obj.Attributes("ATTR_DOCS_TLINKS")
  Set Table = Obj.Attributes("ATTR_KD_T_LINKS")
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

'  If Dlg.Show Then
'    If Dlg.Objects.Count <> 0 Then
'      ' Добавляем строки
'      Set Obj = ThisObject
'      If Not Obj.Attributes.Has("ATTR_T_TASK_DOC") Then Exit Sub
'      Set Table = Obj.Attributes("ATTR_T_TASK_DOC")
'      For Each o In Dlg.Objects
'          Set Rows = Table.Rows
'        If Not ObjExist(Table, "ATTR_DOC_REF",o) Then
'          Set NewRow = Rows.Create
'          NewRow.Attributes("ATTR_DOC_REF").Object = o
'        End If
'      Next
'    Else
'      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 1605
'    End If
'  End If
'  ThisObject.Update

  If Dlg.Show Then
    If Dlg.Objects.Count <> 0 Then
      ' Добавляем строки
      For Each o In Dlg.Objects
        Set Rows = Table.Rows
        If Not ObjExist(Table, TableRows.AttributeDefs(0).SysName,o) Then
        Call ThisApplication.ExecuteScript ("CMD_S_DLL","SetLinkToBaseDoc",o,Obj,noteTxt)
'        
'          Set NewRow = Rows.Create
'          NewRow.Attributes(0).Object = o
'          NewRow.Attributes(1).Value = thisApplication.CurrentUser
'          NewRow.Attributes(2).Value = noteTxt
'          Rows.Update
        End If
      Next
      ThisObject.SaveChanges (0)
    Else
      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", , 1605
    End If
  End If
End Sub

'Кнопка - Удалить
Sub BUTTON_DOC_DEL_OnClick()
  ThisScript.SysAdminModeOn
'  Set Query = ThisForm.Controls("QUERY_DOCS_TLINKS")
  Set Query = ThisForm.Controls("QUERY_KD_DOC_RELATIONS")
  Set Objects = Query.SelectedObjects
  
  If Objects.Count = 0 Then 
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbQuestion + vbYesNo, 1605
    Exit Sub
  End If
  
  If Objects.Count = 0 Then Exit Sub
  'Подтверждение удаления
  Key = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbQuestion + vbYesNo, 1607, Objects.Count)
  If Key = vbNo Then Exit Sub

'  Set Table = ThisObject.Attributes("ATTR_DOCS_TLINKS")
  Set Table = ThisObject.Attributes("ATTR_KD_T_LINKS")
  Set Rows = Table.Rows
  For Each o in Objects
    For Each row In Rows
      If IsTheSameObj(row.attributes(0).Object,o) Then 
        Rows.Remove row
      End If
    Next
  Next
  ThisObject.Update
End Sub


Sub QUERY_DOCS_TLINKS_Selected(iItem, action)
  If iItem <> -1 Then
    ThisForm.Controls("BUTTON_DOC_DEL").Enabled = CheckObjDel()
  Else
    ThisForm.Controls("BUTTON_DOC_DEL").Enabled = False
  End If
End Sub

Function userIsReciever(Obj,user)
  userIsReciever = False
  Set Roles = Obj.RolesForUser(user)
  If Roles.Has("ROLE_T_TASK_IN_CHECKER") Then 
    userIsReciever = True
  Else
    If not Obj.Attributes.has("ATTR_T_TASK_TDEPTS_TBL") then exit function
    Set Table = Obj.Attributes("ATTR_T_TASK_TDEPTS_TBL")
    For each row in Table.Rows
      set Checker = row.Attributes("ATTR_T_TASK_DEPT_PERSON").User
      If Checker is nothing then exit function
      check = (Checker.SysName = user.SysName)
      If check Then 
        userIsReciever = check
        Exit Function
      End If
    Next
  End If
End Function


Sub BTN_ADD_FILE_OnClick()
'  Call ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","AddObjLinkFile",ThisObject)
  Call AddObjLinkFile(ThisObject)
End Sub

sub AddObjLinkFile(docObj)
  dim SelFileDlg,FDef,FileNames
  ThisScript.SysAdminModeOn

  Set SelFileDlg = ThisApplication.Dialogs.FileDlg
  retVal = SelFileDlg.Show
  If retVal <> TRUE Then Exit sub
  
  Set noteDlg = ThisApplication.Dialogs.SimpleEditDlg
  noteDlg.Caption = "Введите примечание"
  noteDlg.Prompt = "Примечание к связи с файлами"
  If not noteDlg.Show Then exit sub

  FileNames = SelFileDlg.FileNames
  for i = 0 to Ubound(SelFileDlg.FileNames)
    Call ThisApplication.ExecuteScript("CMD_KD_COMMON_LIB","CreateObjFile",FileNames(i),docObj,noteDlg.Text)
  next
  thisForm.Refresh
End Sub

Sub QUERY_KD_DOC_RELATIONS_Selected(iItem, action)
  If iItem <> -1 Then
    ThisForm.Controls("BUTTON_DOC_DEL").Enabled = CheckObjDel()
  Else
    ThisForm.Controls("BUTTON_DOC_DEL").Enabled = False
  End If
End Sub

Function CheckObj3(Obj)
  CheckObj3 = False
  Set CU = ThisApplication.CurrentUser
  isExec = ThisApplication.ExecuteScript("CMD_KD_USER_PERMISSIONS", "isInic",CU, Obj)
  isDvlp = IsDeveloper(Obj,CU)
  
  If (Obj.StatusName = "STATUS_T_TASK_IS_SIGNED" or Obj.StatusName = "STATUS_T_TASK_IN_WORK") And isDvlp Then
    CheckObj3 = True
  End If
End Function

Sub QUERY_ALL_ORDERS_BY_DOCUMENT_Selected(iItem, action)
  set table = thisForm.Controls("QUERY_ALL_ORDERS_BY_DOCUMENT") 
  Set Objects = table.SelectedObjects
  Set order = Nothing
  If Objects.count <> 1 Then 
    Call ClearOrderAttr()
  Else
    Set order = Objects(0)
  End If
  Call ShowOrderDetails(order)
End Sub

sub ClearOrderAttr()
  for each contr in thisForm.Controls
    if left(contr.Name,5) = "EDIT_" then contr.value = ""  
  next 
end sub

Sub ShowOrderDetails(order)
  If order Is Nothing Then Exit Sub
  With ThisForm.Controls
      .Item("ATTR_KD_TEXT").Value = order.Attributes("ATTR_KD_TEXT").Value
      .Item("ATTR_KD_HIST_NOTE").Value = order.Attributes("ATTR_KD_HIST_NOTE").Value
      .Item("EDIT_ATTR_KD_OP_DELIVERY").Value = order.Attributes("ATTR_KD_OP_DELIVERY").Value
      .Item("EDIT_ATTR_KD_AUTH").Value = order.Attributes("ATTR_KD_AUTH").Value
  End With
End Sub

