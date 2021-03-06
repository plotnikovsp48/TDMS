' Форма ввода - Внутренняя закупка. Разработчики. 
'--------------------------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

USE "CMD_DLL_COMMON_BUTTON"

'Событие открытие формы
Sub Form_BeforeShow(Form, Obj)
  form.Caption = form.Description
  Set CU = ThisApplication.CurrentUser
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnEnable0",Form, Obj
  AttrName = "ATTR_TENDER_GROUP_CHIF"
  If Obj.Attributes.Has(AttrName) Then
   If Obj.Attributes(AttrName).Empty = False Then
    If not Obj.Attributes(AttrName).User is Nothing Then
     If Obj.Attributes(AttrName).User.sysname = CU.sysname Then
     Form.Controls("ATTR_TENDER_RESPONSIBLE_EIS").readOnly = False
     End If
    End If
   End If
  End If
End Sub

'Событие закрытия формы
Sub Form_BeforeClose(Form, Obj, Cancel)
  Cancel = Not ThisApplication.ExecuteScript("OBJECT_PURCHASE_DOC","CheckBeforeClose",Obj)
End Sub

  'Кнопка - Сохранить Перенести в библиотеку!
Sub BUTTON_CUSTOM_SAVE_OnClick()
  ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomSave", ThisForm, ThisObject
End Sub
'Кнопка - Отменить Перенести в библиотеку!
Sub BUTTON_CUSTOM_CANCEL_OnClick()
 ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","CastomCancel", ThisForm, ThisObject 
End Sub





'Событие Изменение атрибутов
'--------------------------------------------------------------------
 Sub Form_AttributeChange(Form, Obj, Attribute, Cancel, OldAttribute)
  ThisApplication.Dictionary(Obj.GUID).Item("ObjEdit") = True
  Set CU = ThisApplication.CurrentUser   
  'Ответственное структурное подразделение за подготовку заявки. 
  If Attribute.AttributeDefName = "ATTR_TENDER_DEPT_RESP" Then
    AttrName = "ATTR_TENDER_MATERIAL_RESP"
    If Obj.Attributes.Has(AttrName) Then
'      OrgName = "Ответственное структурное подразделение за подготовку заявки"
   OrgName = Obj.Attributes("ATTR_TENDER_DEPT_RESP").Value
'     msgbox OrgName ,vbExclamation
      Set User = ThisApplication.ExecuteScript("CMD_DLL", "OrgUserGet", OrgName)
      If not User is Nothing Then Obj.Attributes(AttrName).User = User
      If User is Nothing Then Obj.Attributes(AttrName) = empty
      End If
    
     'Ответственный за предоставление материалов
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_MATERIAL_RESP" Then
    AttrName = "ATTR_TENDER_DEPT_RESP"
    If Obj.Attributes.Has(AttrName) Then
'      OrgName = "Ответственное структурное подразделение за подготовку заявки"
  Set OrgName = Obj.Attributes("ATTR_TENDER_MATERIAL_RESP")
'     msgbox OrgName.description ,vbExclamation
     Set Dept = ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB", "OrgGet", OrgName)
'       msgbox Dept ,vbExclamation
'       ThisForm.Controls(AttrName).Value = Dept
  If not Dept is Nothing Then Obj.Attributes(AttrName) = Dept
  If Dept is Nothing Then Obj.Attributes(AttrName) = empty
        ThisForm.Refresh
    End If
    
     'Исполнитель по закупке
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_RESP" Then
    AttrName = "ATTR_TENDER_RESP"
    If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      If not Obj.Attributes(AttrName).User is Nothing Then
        Set uToUser = Obj.Attributes(AttrName).User
        If Obj.Status.SysName = "STATUS_TENDER_IN_WORK" then
        ans = msgbox("Назначить пользователя " & uToUser.description & " ответственным за подготовку документации по закупке?" ,vbQuestion+vbYesNo )
         If ans <> vbYes Then 
         Cancel = True
         Exit Sub
         End If
        
      
         'Создание поручения новому исполнителю
       Set uFromUser = ThisApplication.CurrentUser   
       resol = "NODE_CORR_REZOL_POD"
'       resol = "NODE_COR_STAT_MAIN"
       ObjType = "OBJECT_KD_ORDER_NOTICE"
       txt = "Прошу обеспечить подготовку материалов для закупки " & Obj.Description & " в указанные сроки"
       PlanDate = Obj.Attributes("ATTR_TENDER_PLAN_ZD_PRESENT")
       If PlanDate = "" Then PlanDate = Date
       If uToUser.SysName <> uFromUser.SysName Then
       ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,uToUser,uFromUser,resol,txt,PlanDate 
       End If
'      Удаление ролей прежнему пользователю  
       If not OldAttribute is Nothing Then
       resol = "NODE_COR_DEL_MAIN"
       Set uToUser = OldAttribute.User
       Call ThisApplication.ExecuteScript("CMD_TENDER_OBJ_LIB","RoleUserDel",Obj,uToUser, "ROLE_PURCHASE_RESPONSIBLE,ROLE_INITIATOR,")
       End If
      End If
       
     'Создание роли новому куратору - Инициатор согласования и Отв. за материалы 
        Set uToUser = Obj.Attributes(AttrName).User     
       ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","RoleStrTakeUser",Obj,uToUser,"ROLE_PURCHASE_RESPONSIBLE,ROLE_INITIATOR,"
  End If
 End If  
End If    

     'Сотрудник Группы, ответственный за закупку
  ElseIf Attribute.AttributeDefName = "ATTR_TENDER_RESPONSIBLE_EIS" Then
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





'Кнопка - Создать договор
'-----------------------------------------------------------------------

'Кнопка - Добавить
Sub BUTTON_ADD_OnClick()
 ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnDesignerAddOnClick",ThisForm, ThisObject

End Sub

'Кнопка - Удалить
Sub BUTTON_DEL_OnClick()
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","BtnDesignerDellOnClick",ThisForm, ThisObject

End Sub

'Процедура удаления роли пользователя
Sub RoleUserDel(Obj,User)
  Set Roles = Obj.RolesForUser(User)
  RoleName = "ROLE_TENDER_DOCS_RESP_DEVELOPER"
  If Roles.Has(RoleName) Then
    Obj.Roles.Remove Roles(RoleName)
    If Obj.ObjectDefName = "OBJECT_PURCHASE_DOC" Then
      If not Obj.Parent is Nothing Then
        Set Obj0 = Obj.Parent
      Else
        Set Obj0 = Obj
      End If
    Else
      Set Obj0 = Obj
    End If
    ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 6006, User, Obj0, Nothing, Obj0.Description
  End If
End Sub

'Событие - выделение пользователя в выборке Разработчики
Sub QUERY_TENDER_DESIGNER_LIST_Selected(iItem, action)
ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","DesignerSelDelBtnEnable",ThisForm, ThisObject, iItem, action
End Sub

'Кнопка - Опубликовать. Перенести в библиотеку!
sub ShowBTN_TENDER_DOC_TO_PUBLISH_Icon()
  AttrName = "ATTR_TENDER_DOC_TO_PUBLISH"
  BtnName = "BTN_TENDER_DOC_TO_PUBLISH"
  set btnfav = thisForm.Controls(BtnName).ActiveX
  Set Obj = ThisObject
 
  If not Obj.Attributes.Has(AttrName) Then ThisForm.Controls(BtnName).Visible = False
  If Obj.Attributes.Has(AttrName) Then
    val = Obj.Attributes(AttrName).Value
    If val = True Then
      btnfav.Image = thisApplication.Icons("IMG_DOCUMENT_POSITIVE")
    else    
      btnfav.Image = thisApplication.Icons("IMG_DOCUMENT_BASIC")
    End If
  End if
end sub

Sub BTN_TENDER_DOC_TO_PUBLISH_OnClick()
  set btnfav = thisForm.Controls("BTN_TENDER_DOC_TO_PUBLISH").ActiveX
  Set Obj = ThisObject
  If Obj.Permissions.Locked <> FALSE Then 
    If Obj.Permissions.LockUser.SysName <> ThisApplication.CurrentUser.SysName Then
      Msgbox "Документ заблокирован пользователем " & Obj.Permissions.LockUser.Description,vbInformation,"Ошибка изменения документа"
      Exit Sub
    End If
  End If
  
  If Obj.Attributes.Has("ATTR_TENDER_DOC_TO_PUBLISH") Then
    val = Obj.Attributes("ATTR_TENDER_DOC_TO_PUBLISH").Value
    If val = True Then
      Obj.Attributes("ATTR_TENDER_DOC_TO_PUBLISH") = False
      msgbox "Документ удален из заявки",vbInformation,"Документ удален"
    else    
      Obj.Attributes("ATTR_TENDER_DOC_TO_PUBLISH") = True
      msgbox "Документ добавлен в заявку",vbInformation,"Документ добавлен"
    end if
  End If
  Call ShowBTN_TENDER_DOC_TO_PUBLISH_Icon()
  thisForm.Refresh
End Sub

'Ссылка на закупку
Sub PARENT_LinkClick(Button, Shift, url, bCancelDefault)  
 ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","GoParentTextOnClick",ThisForm, ThisObject 
End Sub

Sub ATTR_TENDER_RESPONSIBLE_EIS_Modified()
 Set Obj = ThisObject
  Set User = Obj.Attributes("ATTR_TENDER_RESPONSIBLE_EIS").User 
  If  Obj.Attributes.Has("ATTR_TENDER_IN_RESP_CONTACT_INF") Then
  Obj.Attributes("ATTR_TENDER_IN_RESP_CONTACT_INF").Value =  User.Description & ", газ.: (721) 4-" & User.Phone & " "& User.Mail
 End If
End Sub
