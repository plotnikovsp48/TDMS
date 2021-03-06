' Форма ввода - Материалы ЕИС
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "CMD_KD_ORDER_LIB"
use "CMD_KD_COMMON_LIB"
USE "CMD_DLL_COMMON_BUTTON"

'События
'-----------------------------------------------------------------------
'-----------------------------------------------------------------------

'Событие Открытие формы
'-----------------------------------------------------------------------

Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Call TenderConcurentNumEnable(Form,Obj)
  Call TenderNumEIScheck(Form,Obj)
  Call BtnEnable0(Form,Obj)
'  Call PriceCheckBtnEnable(Form,Obj)
'Блокируем контролы
'   ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnEnable0",Form, Obj
  ThisForm.Controls("BUTTON_DOC_P_DEL").Enabled = False
  ThisForm.Controls("BUTTON_DOC_P_EDIT").Enabled = False 
  
  Set Roles = Obj.RolesForUser(CU)
  Form.Controls("BUTTON_DOC_DEL").Enabled = False

 
  
  'Руководитель группы 
  If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") = False Then
    Form.Controls("ATTR_TENDER_GROUP_CHIF").ReadOnly = True
  End If

 '     Делаем не доступным для чтения Заявки на запрос предложений для всех кроме группы и экспертов
'    ----------------------------------------------------------------------------------------------
Set CU = ThisApplication.CurrentUser
  If Obj.RolesForUser(CU).Has("ROLE_TENDER_INICIATOR") = False Then
    If CU.Groups.Has("GROUP_TENDER_INSIDE") = false and CU.Groups.Has("GROPE_TENDER_EXPERT") = false and CU.Groups.Has("GROUP_TENDER") = false Then
     If Form.Controls.Has("ATTR_TENDER_INSIDE_ORDER_LIST") Then Form.Controls("ATTR_TENDER_INSIDE_ORDER_LIST").Visible = False
     If Form.Controls.Has("QUERY_TENDER_ORDER_DOCS_LIST") Then Form.Controls("QUERY_TENDER_ORDER_DOCS_LIST").Visible = True
     If Form.Controls.Has("STATIC_ACC_DEN") Then Form.Controls("STATIC_ACC_DEN").Visible = True
     If Form.Controls.Has("BUTTON_REQ_ACC") Then Form.Controls("BUTTON_REQ_ACC").Visible = True
    End If
   End If
  '--------------------------------------------------------------------------------------------------
 ' Проверяем кол-во строк
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CheckOne",Obj,"ATTR_TENDER_WINER_PRICE" 
End Sub

'Событие Закрытие формы
'---------------------------------------------------------------------
Sub Form_BeforeClose(Form, Obj, Cancel)
  Set Dict = ThisApplication.Dictionary(ThisObject.GUID)
  ItemName = ThisApplication.CurrentUser.SysName
  If Dict.Exists(ItemName) Then Dict.Item(ItemName) = ""
End Sub

'События при изменении атрибутов
'---------------------------------------------------------------------
Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = True
  Call BtnEnable0(Form,Obj)
   Set CU = ThisApplication.CurrentUser
 'WWW
  If Attribute.AttributeDefName = "ATTR_TENDER_WEB_ADDRESS" Then
  Form.Controls("www").ActiveX.url = Obj.Attributes("ATTR_TENDER_WEB_ADDRESS")
  ThisForm.Refresh
  End If
    'Начальная (максимальная) цена согласно извещения
  If Attribute.AttributeDefName = "ATTR_TENDER_INVITATION_PRICE_EIS" Then
'    Call Pricesync(Obj)
'Msgbox "Документ завершен.",vbInformation
   Call BtnEnable0(Form,Obj)
    Exit Sub
  End If
  'Дата публикации извещения о закупке
  If Attribute.AttributeDefName = "ATTR_TENDER_INVITATION_DATA_EIS" Then
      data2 = Attribute.Value
      Data3 = Obj.Attributes("ATTR_TENDER_END_DATA_EIS")
      delta = 0
      flag = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMaxData",Data3,Data2,Delta)
      If Flag Then
        Cancel = flag
        Exit Sub
      End If
    Call TenderConcurentNumEnable(Form,Obj)
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_END_DATA_EIS" Then
    Data1 = Obj.Attributes("ATTR_TENDER_INVITATION_DATA_EIS")
    Data2 = Attribute.Value
    Data3 = Obj.Attributes("ATTR_TENDER_OPEN_CASE_DATA_EIS")
    Delta = 0
    flag = (Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Delta)) Or _
           Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMaxData",Data3,Data2,Delta)
    If Flag Then
        Cancel = flag
        Exit Sub
    End If
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_OPEN_CASE_DATA_EIS" Then
    Data1 = Obj.Attributes("ATTR_TENDER_END_DATA_EIS")
    Data2 = Attribute.Value
    Data3 = Obj.Attributes("ATTR_TENDER_RESULT_DATA_EIS")
    Delta = 0
    flag = (Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Delta)) Or _
           Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMaxData",Data3,Data2,Delta)
    If Flag Then
        Cancel = flag
        Exit Sub
    End If
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_RESULT_DATA_EIS" Then
    Data1 = Obj.Attributes("ATTR_TENDER_OPEN_CASE_DATA_EIS")
    Data2 = Attribute.Value
    Delta = 0
    Cancel = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckMinData",Data1,Data2,Delta)
  'Номер извещения в ЕИС
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_NUM_EIS" Then
    Call TenderNumEIScheck(Form,Obj)
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_WINER_PRICE_EIS" Then
    flag = not ThisApplication.ExecuteScript("CMD_DLL","CheckPrice",Obj,Attribute.AttributeDefName)
    Cancel = flag
    
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_STATUS_EIS" Then
   If Obj.Attributes.Has("ATTR_TENDER_STATUS_EIS") Then
'    If Obj.Attributes("ATTR_TENDER_STATUS_EIS") = "В работе" Then
'    'Запрос о смене статуса
'     Result = ThisApplication.ExecuteScript("CMD_MESSAGE","ShowWarning",vbQuestion+VbYesNo,6017,Obj.Description)
'     If Result = vbNo Then Exit Sub
'  
'  'Маршрут
'  StatusName = "STATUS_TENDER_IN_PUBLIC"
'  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
'  If RetVal = -1 Then
'    Obj.Status = ThisApplication.Statuses(StatusName)
'  End If
'  Obj.Attributes("ATTR_TENDER_BARGAIN_FLAG") = False
'  End If
'  End If
'  ThisObject.Update 
   Res = Obj.Attributes("ATTR_TENDER_STATUS_EIS")
   If Res = "Подготовка к публикации" Then
   Resc = ThisApplication.ExecuteScript("CMD_TENDER_IN_APPROV","Main",ThisForm, ThisObject)'
    If Resc = false then cancel = true
    If Resc = true Then
    ThisObject.Update
    ThisForm.Close True
    End If
   End If 
' ThisObject.Dictionary.Item("FormActive") = "FORM_TENDER_MATERIAL_EIS"
'ThisObject.Update
   If Res = "В работе" Then 
   
   ThisApplication.ExecuteScript "CMD_TENDER_IN_UPLOAD", "Main", ThisObject 'Obj.Attributes("ATTR_TENDER_BARGAIN_FLAG") = True
   ThisObject.Update
   End If 
   
    If Res = "Закупка проведена" or Res = "Признана несостоявшейся" or Res = "Отказ от проведения" Then
     ThisApplication.ExecuteScript "CMD_TENDER_IN_GO_END", "Main", ThisObject, Thisform
    End If 
   
  End If   
'    If Obj.Attributes(ATTR_TENDER_STATUS_EIS).Classifier = ThisApplication.Classifiers.FindBySysId("NODE_1980636C_4EB8_4A87_91BA_8A659C0BA11E") Then
'    Key = Msgbox("Перевести закупку в размещенные на площадке?",vbYesNo+vbQuestion)
'    If Key = vbNo Then Exit Sub
'  Else 
 
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_WINER_EIS" Then
    Set tWINER = Attribute.Object
    If Not tWINER Is Nothing Then
      flag = Attribute.Object.Attributes("ATTR_KD_COREDENT_TYPE")
      If Obj.Attributes.Has("ATTR_TENDER_WINER_SMOLL_FLAG_EIS") Then
        Obj.Attributes("ATTR_TENDER_WINER_SMOLL_FLAG_EIS") = flag
      End If
    End If
 
  
   ElseIf Attribute.AttributeDefName = "ATTR_TENDER_PROTOCOL" Then
    Set Doc = Attribute.Object
    If Doc Is Nothing Then
       Obj.Attributes("ATTR_TENDER_PROTOCOL").Object = Nothing
       Obj.Attributes("ATTR_TENDER_PROTOCOL_DATA_NUM_EIS").Value = ""
    Exit Sub
   End If
 If not IsEmpty(Doc) = True Then
   Obj.Attributes("ATTR_TENDER_PROTOCOL_DATA_NUM_EIS").Value = Doc.Attributes("ATTR_REG_NUMBER").Value  
 End If 
 
     'Сотрудник Группы, ответственный за закупку
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_RESPONSIBLE_EIS" Then
  If Obj.StatusName = "STATUS_TENDER_IN_IS_APPROVING" Then Exit Sub 
    AttrName = "ATTR_TENDER_RESPONSIBLE_EIS"
    If Obj.Attributes.Has(AttrName) Then
     If Obj.Attributes(AttrName).Empty = False Then
      If not Obj.Attributes(AttrName).User is Nothing Then
        Set uToUser = Obj.Attributes(AttrName).User
          If uToUser.sysname = CU.sysname Then Exit Sub
'        If Obj.Status.SysName = "STATUS_TENDER_IN_WORK" then
        ans = msgbox("Назначить пользователя " & uToUser.description & " ответственным за подготовку документации по закупке?" ,vbQuestion+vbYesNo )
         If ans <> vbYes Then 
         Cancel = True
         Exit Sub
         End If
        
      
         'Создание поручения и роли новому Сотруднику Группы, ответственному за закупку
       Set uFromUser = CU  
       resol = "NODE_CORR_REZOL_POD"
'       resol = "NODE_COR_STAT_MAIN"
       ObjType = "OBJECT_KD_ORDER_NOTICE"
       txt = "Прошу обеспечить подготовку материалов для закупки " & Obj.Description & " в указанные сроки"
       PlanDate = Obj.Attributes("ATTR_TENDER_PRESENT_PLAN_DATA")
       If PlanDate = "" Then PlanDate = Date
       If uToUser.SysName <> uFromUser.SysName Then
       ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,uToUser,uFromUser,resol,txt,PlanDate 
      
            'Создание роли 
'        Set uToUser = Obj.Attributes(AttrName).User     

       ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,uToUser,"ROLE_PURCHASE_RESPONSIBLE,ROLE_INITIATOR,"
        End If
'      Удаление ролей прежнему пользователю  
       If not OldAttribute is Nothing Then
       resol = "NODE_COR_DEL_MAIN"
       Set uToUser = OldAttribute.User
       Call ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","RoleUserDel",Obj,uToUser, "ROLE_PURCHASE_RESPONSIBLE,ROLE_INITIATOR,")
       End If
      End If
      End If
      End If 
  End If
 End Sub

Sub Form_TableAttributeChange(Form, Object, TableAttribute, TableRow, ColumnAttributeDefName, OldTableRow, Cancel)
  ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = True
  Call BtnEnable0(Form,Object)
End Sub

'Процедура проверки и окрашивания атрибута "Номер извещения в ЕИС"
Sub TenderNumEIScheck(Form,Obj)
  Set AttrName = Form.Controls("T_ATTR_TENDER_NUM_EIS").ActiveX
  If Len(Obj.Attributes("ATTR_TENDER_NUM_EIS").Value) <> 11 Then
  If not Obj.Attributes("ATTR_TENDER_NUM_EIS").empty then
  AttrName.BackColor = RGB(255,255,0)
'    AttrName.ForeColor = RGB(255,0,0)
  Else
  AttrName.BackColor = RGB(230,230,230)
'    AttrName.ForeColor = RGB(0,0,0)
  End If
  End If
End Sub

'Процедура управления доступностью кнопки "Заполнить номер
Sub TenderConcurentNumEnable(Form,Obj)
  Check = True
  'Проверка атрибутов
  AttrName0 = "ATTR_TENDER_UNIQUE_NUM"
  AttrName1 = "ATTR_TENDER_INVITATION_DATA_EIS"
  If Obj.Attributes.Has(AttrName0) and Obj.Attributes.Has(AttrName1) Then
    If Obj.Attributes(AttrName0).Empty or Obj.Attributes(AttrName1).Empty Then
      Check = False
    End If
  Else
    Check = False
  End If
  Form.Controls("BUTTON_NUM").Enabled = Check
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB", AttrBlockByGropeRoleStatForm, Obj, "BUTTON_NUM", CU, Stat, "GROUP_TENDER_INSIDE", False
End Sub

'Проверка значения атрибута Номер извещения в ЕИС
Sub ATTR_TENDER_NUM_EIS_BeforeModify(Text,Cancel)
  If InStr(Text,".") <> 0 Then
    Cancel = True
    Exit Sub
  ElseIf InStr(Text,",") <> 0 Then
    Cancel = True
    Exit Sub
  End If 
End Sub

'Событие - Смена выделения в таблице Заявки
'Sub ATTR_TENDER_INSIDE_ORDER_LIST_SelChanged()
'  If ThisObject.Attributes.Has("ATTR_TENDER_INSIDE_ORDER_LIST") = False Then Exit Sub
'  Set Table = ThisForm.Controls("ATTR_TENDER_INSIDE_ORDER_LIST").ActiveX
'  nRow = Table.SelectedRow
'  If nRow+1 => Table.RowCount Then Exit Sub
'  Set Row = Table.RowValue(nRow)
'  If Row is Nothing Then Exit Sub
'  If Row.Attributes("ATTR_TENDER_INVITATION_COUNT_EIS").Empty Then Exit Sub
'  If Row.Attributes("ATTR_TENDER_INVITATION_COUNT_EIS").Object is Nothing Then Exit Sub
'  Set Obj0 = Row.Attributes("ATTR_TENDER_INVITATION_COUNT_EIS").Object
'  Set Dict = ThisApplication.Dictionary(ThisObject.GUID)
'  Dict.Item(ThisApplication.CurrentUser.SysName) = Obj0.Guid
'  ThisForm.Refresh
'End Sub
'Событие - Выделение в выборке Документов закупки
Sub QUERY_TENDER_ORDER_DOCS_LIST_Selected(iItem, action)
  Set Query = ThisForm.Controls("QUERY_TENDER_ORDER_DOCS_LIST")
  Set Objects = Query.SelectedObjects
     
  If iItem <> -1 Then
    
    If Objects.Count => 1 Then
     flag = ThisApplication.ExecuteScript("OBJECT_PURCHASE_DOC","UserCanDelete",ThisApplication.CurrentUser,Objects(0))
     ThisForm.Controls("BUTTON_DOC_DEL").Enabled = True  And flag 
    Else
      ThisForm.Controls("BUTTON_DOC_DEL").Enabled = False
    End If
  Else
    ThisForm.Controls("BUTTON_DOC_DEL").Enabled = False
  End If
End Sub

'Событие - Выделение в выборке Документов закупки
'-----------------------------------------------------------------------
Sub QUERY_TENDER_DOCS_PB_Selected(iItem, action)
  Set Query = ThisForm.Controls("QUERY_TENDER_DOCS_PB")
  Set Objects = Query.SelectedObjects
  If iItem <> -1 Then
    If Objects.Count => 1 Then
      ThisForm.Controls("BUTTON_DOC_P_EDIT").Enabled = True
      flag = ThisApplication.ExecuteScript("OBJECT_PURCHASE_DOC","UserCanDelete",ThisApplication.CurrentUser,Objects(0))
      ThisForm.Controls("BUTTON_DOC_P_DEL").Enabled = True And flag
    Else
      ThisForm.Controls("BUTTON_DOC_P_EDIT").Enabled = False
      ThisForm.Controls("BUTTON_DOC_P_DEL").Enabled = False
    End If
  Else
    ThisForm.Controls("BUTTON_DOC_P_DEL").Enabled = False
    ThisForm.Controls("BUTTON_DOC_P_EDIT").Enabled = False
  End If
End Sub

'Кнопка - Заполнить номер
Sub BUTTON_NUM_OnClick()
  Code = ThisApplication.ExecuteScript("CMD_S_NUMBERING","TenderConcurentNumGen",ThisObject)
  AttrName = "ATTR_TENDER_CONCURENT_NUM_EIS"
  If ThisObject.Attributes.Has(AttrName) Then
    ThisObject.Attributes(AttrName).Value = Code
  End If
End Sub

'Кнопка - Сохранить
Sub BUTTON_CUSTOM_SAVE_OnClick()
  ThisScript.SysAdminModeOn
  Key = Msgbox("Сохранить внесенные изменения?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
  ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = False
  ThisObject.Update
  'Call BtnEnable0(ThisForm,ThisObject)
End Sub

'Кнопка - Отменить
Sub BUTTON_CUSTOM_CANCEL_OnClick()
  ThisScript.SysAdminModeOn
  Key = Msgbox("Отменить внесенные изменения?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
  ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = False
  Guid = ThisObject.GUID
  ThisForm.Close False
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Set Obj = ThisApplication.GetObjectByGUID(Guid)
  Dlg.Object = Obj
  Dlg.Show
End Sub

'Кнопка - Подготовка к публикации
Sub BUTTON_APPROVE_OnClick()
   Res = ThisApplication.ExecuteScript("CMD_TENDER_IN_APPROV","Main",ThisForm, ThisObject)'
    If Res Then
    ThisObject.Update
    ThisForm.Close True
    End If
' ThisObject.Dictionary.Item("FormActive") = "FORM_TENDER_MATERIAL_EIS"
'ThisObject.Update
      End Sub

'Кнопка - Опубликовать
Sub BUTTON_PUBLIC_OnClick()
  ThisApplication.ExecuteScript "CMD_TENDER_IN_UPLOAD", "Main", ThisObject 'Obj.Attributes("ATTR_TENDER_BARGAIN_FLAG") = True
  ThisObject.Update
End Sub

'Кнопка - Загрузить протокол
Sub BUTTON_LOAD_PROTOCOL_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_IN_PROTOCOL_LOAD", "Main", ThisObject
ThisObject.Update
ThisObject.Dictionary.Item("FormActive") = "FORM_TENDER_MATERIAL_EIS"
End Sub

'Кнопка - Добавить Документ закупки
Sub BUTTON_DOC_ADD_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_IN_EIS_DOC_LOAD", "Main", ThisObject, ThisForm
      ThisObject.Dictionary.Item("FormActive") = "FORM_TENDER_MATERIAL_EIS"
'      ThisObject.Update 
End Sub

'Кнопка - Удалить Документ закупки
Sub BUTTON_DOC_DEL_OnClick()
  ThisScript.SysAdminModeOn
  Set Query = ThisForm.Controls("QUERY_TENDER_ORDER_DOCS_LIST")
  Set Objects = Query.SelectedObjects
  str = ""
  
  'Подтверждение удаления
  If Objects.Count <> 0 Then
    For Each Obj in Objects
      If Obj.Attributes.Has("ATTR_DOCUMENT_NAME") Then
        If Obj.Attributes("ATTR_DOCUMENT_NAME").Empty = False Then
          If str <> "" Then
            str = str & ", """ & Obj.Attributes("ATTR_DOCUMENT_NAME").Value & """"
          Else
            str = """" & Obj.Attributes("ATTR_DOCUMENT_NAME").Value & """"
          End If
        End If
      End If
    Next
    If str = "" Then str = Objects.Count & " документов закупки"
    Key = Msgbox("Удалить " & str & " из системы?",vbYesNo+vbQuestion)
    If Key = vbNo Then Exit Sub
  Else
    Exit Sub
  End If
  
  'Удаление строк из таблицы
  For Each Obj in Objects
    Obj.Erase
  Next
  ThisForm.Refresh
End Sub

'Кнопка - Загрузить Акт
Sub BUTTON_LOAD_ACT_OnClick()
 ThisApplication.ExecuteScript "CMD_TENDER_IN_ACT_LOAD", "Main", ThisObject
 ThisObject.Update
 ThisObject.Dictionary.Item("FormActive") = "FORM_TENDER_MATERIAL_EIS"
  ThisObject.Update
End Sub
  
' 'Поле  - Статус закупки
'Sub ATTR_TENDER_STATUS_EIS_OnClick()
'  ThisApplication.ExecuteScript "CMD_TENDER_IN_APPROV", "Main", ThisObject
'  ThisObject.SaveChanges
'End Sub
 
'Кнопка - Запрос на уторговывание
Sub BUTTON_AGREED_OnClick()
  ThisScript.SysAdminModeOn
  If ThisObject.Attributes.Has("ATTR_TENDER_BARGAIN_FLAG") Then
  ThisObject.Attributes("ATTR_TENDER_BARGAIN_FLAG") = True
  End If
  RoleName = "ROLE_INITIATOR"
  If ThisObject.Roles.Has(RoleName) = False Then
    Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",ThisObject,RoleName,ThisApplication.CurrentUser)
  End If
  
  ThisObject.Update
  ThisObject.Dictionary.Item("FormActive") = "FORM_KD_DOC_AGREE"
  ThisForm.Close False
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = ThisObject
     Dlg.Show
  
End Sub


'Кнопка - На рассмотрение
Sub BUTTON_GO_EXPERT_OnClick()
  ThisApplication.ExecuteScript "CMD_TENDER_IN_GO_EXPERT", "Main", ThisObject
  ThisObject.Update
End Sub

'Кнопка - Завершить
Sub BUTTON_FINISH_OnClick()
  ThisApplication.ExecuteScript "CMD_TENDER_IN_GO_END", "Main", ThisObject, Thisform
'  ThisObject.Update
End Sub

'Процедура управления доступностью кнопок Сохранить, Отменить, Согласовать, Запланировать
'В разработку документации, Разработчики, На утверждение, Вернуть в работу, Утверждено, Загрузить документ, Удалить документ
Sub BtnEnable0(Form,Obj)
  ThisScript.SysAdminModeOn
  AttrName0 = "ATTR_TENDER_GROUP_CHIF"
  Data1 = Obj.Attributes("ATTR_TENDER_INVITATION_DATA_EIS")
  Set u0 = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName0)
  Set CU = ThisApplication.CurrentUser
  Set Roles = Obj.RolesForUser(CU)
  Set Dict = ThisApplication.Dictionary(Obj.Guid & " - BlockRoute")
  Dict.RemoveAll
  BtnList = "BUTTON_ADD_CONTRACT,BUTTON_CUSTOM_SAVE,BUTTON_CUSTOM_CANCEL,BUTTON_APPROVE,BUTTON_PUBLIC,BUTTON_GO_EXPERT," &_
  "BUTTON_AGREED,BUTTON_FINISH,BUTTON_LOAD_PROTOCOL,BUTTON_LOAD_ACT,BUTTON_TENDER_RES_CHECK_METOD_ADD,BUTTON_DATA_EDIT"
  Arr = Split(BtnList,",")
  ConcurentNum = ""
  If Obj.Attributes.Has("ATTR_TENDER_CONCURENT_NUM_EIS") Then
    ConcurentNum = Obj.Attributes("ATTR_TENDER_CONCURENT_NUM_EIS").Value
  End If
    If ThisApplication.Dictionary(ThisObject.GUID).Exists("ObjEdit") Then
    If ThisApplication.Dictionary(ThisObject.GUID).Item("ObjEdit") = True Then
      Dict.Item("BUTTON_CUSTOM_SAVE") = True
      Dict.Item("BUTTON_CUSTOM_CANCEL") = True
    End If
  End If
  
  
 If ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsGroupMember",CU,"GROUP_CONTRACTS") = True Then
 Dict.Item("BUTTON_ADD_CONTRACT") = True
 End If
  
  
  'Блокировка кнопки Подготовка к публикации ,если не заполнен атрибут Начальная (максимальная) цена согласно извещения 
  If Obj.Attributes.Has("ATTR_TENDER_INVITATION_PRICE_EIS") Then
    Set TableRows = Obj.Attributes("ATTR_TENDER_INVITATION_PRICE_EIS").Rows
    If TableRows.Count <> 1 Then 'Exit Sub
for i = 1 to TableRows.Count 
TableRows(i).Erase
i = i + 1
next
 End If  
    
    Set Row = TableRows(0)
    Check = True
    For Each Attr in Row.Attributes
      If Attr.Empty = True Then
        Check = False
        Exit For
'      ElseIf Attr.AttributeDefName = "ATTR_NDS_VALUE" Then
'        If StrComp(Attr.Value, "Составной", vbTextCompare) = 0 Then
'          Check = False
'          Exit For
'        End If
      End If
    Next
    Attrinvitprice = Check
    End If
  
  Select Case Obj.StatusName
    'Согласовано
    Case "STATUS_TENDER_IN_AGREED"
      If ConcurentNum <> "" Then
        If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
          Dict.Item("BUTTON_PUBLIC") = True
          Dict.Item("BUTTON_LOAD_PROTOCOL") = True
          Dict.Item("BUTTON_GO_EXPERT") = True
        Else
          Set u = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,"ATTR_TENDER_GROUP_CHIF")
          If not u is Nothing Then
            If u.SysName = CU.SysName Then
              Dict.Item("BUTTON_GO_EXPERT") = True
            End If
          End If
        End If
      End If
      
    'На утверждении
    Case "STATUS_TENDER_IN_IS_APPROVING"
'    Msgbox "" & Attrinvitprice,vbInformation
      If not u0 is Nothing Then 
        If CU.SysName = u0.SysName Then
'        If ConcurentNum <> "" and CU.SysName = u0.SysName and Data1 <> "" and Attrinvitprice <> "Ложь" Then
          Dict.Item("BUTTON_APPROVE") = True
        End If
      Else
        If ConcurentNum <> "" and Data1 <> "" and Attrinvitprice <> "Ложь" Then
          Dict.Item("BUTTON_APPROVE") = True
        End If
      End If
    
    'Утверждена
    Case "STATUS_TENDER_IN_APPROVED"
      If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") and ConcurentNum <> "" Then
        Dict.Item("BUTTON_PUBLIC") = True
      End If
      
    'Размещена на площадке
    Case "STATUS_TENDER_IN_PUBLIC"
      If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
        If ConcurentNum <> "" Then
          Dict.Item("BUTTON_LOAD_PROTOCOL") = True
          Dict.Item("BUTTON_LOAD_ACT") = True
          Dict.Item("BUTTON_TENDER_RES_CHECK_METOD_ADD") = True
          Dict.Item("BUTTON_DATA_EDIT") = True
        End If
        Dict.Item("BUTTON_AGREED") = True
        Dict.Item("BUTTON_GO_EXPERT") = True
      Else
        Set u = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,"ATTR_TENDER_GROUP_CHIF")
        If not u is Nothing Then
          If u.SysName = CU.SysName Then
            Dict.Item("BUTTON_GO_EXPERT") = True
          End If
        End If
      End If
    
    'Рассмотрение результатов
    Case "STATUS_TENDER_CHECK_RESULT"
      If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") Then
          Dict.Item("BUTTON_FINISH") = True
          Dict.Item("BUTTON_LOAD_PROTOCOL") = True
          Dict.Item("BUTTON_LOAD_ACT") = True
          Dict.Item("BUTTON_TENDER_RES_CHECK_METOD_ADD") = True
          Dict.Item("BUTTON_DATA_EDIT") = True        
      End If
    
  End Select
  
  'Блокировка кнопок
  For i = 0 to Ubound(Arr)
    BtnName = Arr(i)
    If Dict.Exists(BtnName) Then
      Check = True
    Else
      Check = False
    End If
    If Form.Controls.Has(BtnName) Then
      'Form.Controls(BtnName).Visible = Check
      Form.Controls(BtnName).Enabled = Check
    End If
  Next
  
  Form.Controls("BUTTON_DOC_P_ADD").Enabled = CU.Groups.Has("GROUP_TENDER_INSIDE")
  Form.Controls("BUTTON_DOC_P_DEL").Enabled = CU.Groups.Has("GROUP_TENDER_INSIDE")
  Form.Controls("BUTTON_DOC_P_EDIT").Enabled = CU.Groups.Has("GROUP_TENDER_INSIDE")

  
End Sub

'Sub ATTR_TENDER_INSIDE_ORDER_LIST_DblClick(nRow,nCol)
'msgbox nRow & " - " & nCol
'End Sub

Sub BUTTON_WIN_OnClick()
  Set Table = ThisForm.Controls("ATTR_TENDER_INSIDE_ORDER_LIST").ActiveX
  nRow = Table.SelectedRow
  If nRow+1 => Table.RowCount Then Exit Sub
  Set Row = Table.RowValue(Table.SelectedRow)
  Set SelObj = row.Attributes("ATTR_TENDER_INVITATION_COUNT_EIS").Object
  If SelObj Is Nothing Then Exit Sub
  Set Obj = ThisObject
  If Obj.Attributes("ATTR_TENDER_WINER_EIS").Empty = False Then
    Set winner = Obj.Attributes("ATTR_TENDER_WINER_EIS").Object
    If not winner is nothing Then
    If winner.handle = SelObj.handle Then
      Price1 = row.Attributes("ATTR_TENDER_MEMBERS_PRICE_EIS").Value
      Price2 = row.Attributes("ATTR_TENDER_MEMBER_PRICE_FINAL_EIS").Value
      Price3 =  Obj.Attributes("ATTR_TENDER_WINER_PRICE_EIS").Value
'         msgbox Price1 &" " &Price2 &" " &Price3
      If row.Attributes("ATTR_TENDER_MEMBERS_PRICE_EIS").Empty = True Or _
      row.Attributes("ATTR_TENDER_MEMBERS_PRICE_EIS").Value = "0" Or _
       Price2 = Price3 Then Exit Sub
   
     End If 
    
      If winner.handle <> SelObj.handle Then
        ans = Msgbox("Победитель уже указан. Вы уверены, что хотите заменить победителя?",vbQuestion+vbYesNo,"Указать победителя")
        If ans <> vbYes Then Exit Sub
      End If
    End If
  End If
  Obj.Attributes("ATTR_TENDER_WINER_EIS") = SelObj 
  If row.Attributes("ATTR_TENDER_MEMBER_PRICE_FINAL_EIS").Empty = True Or _
      row.Attributes("ATTR_TENDER_MEMBER_PRICE_FINAL_EIS").Value = "0" Then
    Obj.Attributes("ATTR_TENDER_WINER_PRICE_EIS") = row.Attributes("ATTR_TENDER_MEMBERS_PRICE_EIS")
  Else
    Obj.Attributes("ATTR_TENDER_WINER_PRICE_EIS") = row.Attributes("ATTR_TENDER_MEMBER_PRICE_FINAL_EIS")
  End If
  'Заполняем цену победителя с НДС
   Set TableRows = Obj.Attributes("ATTR_TENDER_WINER_PRICE").Rows
   If TableRows.Count = 0 Then TableRows.Create
   Set Row1 = TableRows(0)
   If Row1.Attributes.Has("ATTR_TENDER_NDS_PRICE") Then
   Row1.Attributes("ATTR_TENDER_NDS_PRICE").Value = Obj.Attributes("ATTR_TENDER_WINER_PRICE_EIS")
   End If 
   'Обнулим незаполняемые поля    
   If Row1.Attributes.Has("ATTR_TENDER_PRICE") Then
   Row1.Attributes("ATTR_TENDER_PRICE").Value = ""
   End If  
   If Row1.Attributes.Has("ATTR_TENDER_SUM_NDS") Then
   Row1.Attributes("ATTR_TENDER_SUM_NDS").Value = ""
   End If    
'   If Row1.Attributes.Has("ATTR_NDS_VALUE") Then
'   Row1.Attributes("ATTR_NDS_VALUE").Value = ""
'   End If      
  flag = SelObj.Attributes("ATTR_KD_COREDENT_TYPE")
  If Obj.Attributes.Has("ATTR_TENDER_WINER_SMOLL_FLAG_EIS") Then
    Obj.Attributes("ATTR_TENDER_WINER_SMOLL_FLAG_EIS") = flag
  End If  
End Sub

'Кнопка - Создать договор
'-----------------------------------------------------------------------
Sub BUTTON_ADD_CONTRACT_OnClick()
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnAddContract",ThisForm, ThisObject
End Sub

'function DellRow(Obj,row)
'  thisScript.SysAdminModeOn
'  DellRow = false
'  set crows = Obj.Attributes("ATTR_TENDER_INVITATION_PRICE_EIS").Rows
'  msgbox " " & row & " "
'  set r = crows(row)

'  Obj.Permissions = sysAdminPermissions
'  r.Erase
''  Obj.Update
'  DellRow = true
'end function

Sub BUTTON_DATA_EDIT_OnClick()
  Set Obj = ThisObject
  Set target = Obj.Attributes("ATTR_TENDER_PROTOCOL").Object
  If target Is Nothing Then Exit Sub
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.ActiveForm = "FORM_PURCHASE_DOC"
     Dlg.Object = target
     Retval = Dlg.Show 
     
     If RetVal = False Then Exit Sub
     num = target.Attributes("ATTR_REG_NUMBER").Value
     aDefName = "ATTR_TENDER_PROTOCOL_DATA_NUM_EIS"
     If Obj.Attributes(aDefName).Value <> num Then
       Obj.Attributes(aDefName).Value = num
     End If
' If Form.Controls.has(CtrlName) Then
' Form.Controls(CtrlName).Enabled = not form.Controls(CtrlName).Enabled
' Form.Controls(CtrlName).ReadOnly = not Form.Controls(CtrlName).ReadOnly
' End If
End Sub

Sub BUTTON_ORDER_OnClick()

'"NODE_KD_PR_DIRECT"
  Set Obj = ThisObject
  set objType = thisApplication.ObjectDefs("OBJECT_KD_DIRECTION")
  Set Order = Create_Doc_by_Type(objType, Obj)
  If Order Is nothing Then Exit Sub
   AttrName = "ATTR_TENDER_ORDER"
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr_F",Obj, AttrName, Order, True
'  If Obj.Attributes.Has(AttrName) = False Then Exit Sub
'  Obj.Attributes(AttrName).Value = Create_Doc_by_Type
End Sub

Sub BUTTON_TENDER_RES_CHECK_METOD_ADD_OnClick()
 ThisApplication.ExecuteScript "CMD_TENDER_IN_METOD_LOAD", "Main", ThisObject
 ThisObject.Update
 ThisObject.Dictionary.Item("FormActive") = "FORM_TENDER_MATERIAL_EIS"
  ThisObject.Update
End Sub

'Кнопка - Добавить Документ закупки
'-----------------------------------------------------------------------
Sub BUTTON_DOC_P_ADD_OnClick()
  Set NewObj = ThisObject.Objects.Create("OBJECT_PURCHASE_DOC")
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = NewObj
  Dlg.Show
End Sub

'Кнопка - Удалить Документ закупки
'-----------------------------------------------------------------------
Sub BUTTON_DOC_P_DEL_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnDocDelOnclic",ThisForm, ThisObject
End Sub

'Кнопка - Редактировать Документ закупки
'-----------------------------------------------------------------------
Sub BUTTON_DOC_P_EDIT_OnClick()
  Set Query = ThisForm.Controls("QUERY_TENDER_DOCS_PB")
  Set Objects = Query.SelectedObjects
  If Objects.Count = 1 Then
    Set Dlg = ThisApplication.Dialogs.EditObjectDlg
    Dlg.Object = Objects(0)
    Dlg.Show
  End If
End Sub
'Кнопка - Показать Документы закупки по заявке
'-----------------------------------------------------------------------
Sub BUTTON_DOC_SHOW_OnClick()
If ThisObject.Attributes.Has("ATTR_TENDER_INSIDE_ORDER_LIST") = False Then Exit Sub
  Set Table = ThisForm.Controls("ATTR_TENDER_INSIDE_ORDER_LIST").ActiveX
  nRow = Table.SelectedRow
  If nRow+1 => Table.RowCount Then Exit Sub
  Set Row = Table.RowValue(nRow)
  If Row is Nothing Then Exit Sub
  If Row.Attributes("ATTR_TENDER_INVITATION_COUNT_EIS").Empty Then Exit Sub
  If Row.Attributes("ATTR_TENDER_INVITATION_COUNT_EIS").Object is Nothing Then Exit Sub
  Set Obj0 = Row.Attributes("ATTR_TENDER_INVITATION_COUNT_EIS").Object
  Set Dict = ThisApplication.Dictionary(ThisObject.GUID)
  Dict.Item(ThisApplication.CurrentUser.SysName) = Obj0.Guid
  ThisForm.Refresh
End Sub

Sub BUTTON_REQ_ACC_OnClick()
 txt = "Прошу предоставить доступ к просмотру файлов заявки на запрос предложений"
 ThisApplication.ExecuteScript "CMD_TENDER_OUT_REQUEST", "Main", ThisObject, txt
End Sub

Sub ATTR_TENDER_RESPONSIBLE_EIS_Modified()
 Set Obj = ThisObject
  If Obj.Attributes("ATTR_TENDER_RESPONSIBLE_EIS").Empty = False Then
 Set User = Obj.Attributes("ATTR_TENDER_RESPONSIBLE_EIS").User 

  If  Obj.Attributes.Has("ATTR_TENDER_IN_RESP_CONTACT_INF") Then
  Obj.Attributes("ATTR_TENDER_IN_RESP_CONTACT_INF").Value =  User.Description & ", газ.: (721) 4-" & User.Phone & " "& User.Mail
 End If
 End If
End Sub
