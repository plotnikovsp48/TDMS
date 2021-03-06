' Тип объекта - Лот
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Sub Object_BeforeCreate(Obj, Parent, Cancel)
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Parent,Parent.Status,Obj,Obj.ObjectDef.InitialStatus) 
 If Obj.Attributes.Has("ATTR_LOT_NUM") Then Obj.Attributes("ATTR_LOT_NUM") =  ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","LotNumGen", Obj) 
 If Obj.Attributes.Has("ATTR_TENDER_LOT_NAME") Then 
  If Parent.Attributes.Has("ATTR_TENDER_REASON") Then
  Obj.Attributes("ATTR_TENDER_LOT_NAME") = Parent.Attributes("ATTR_TENDER_REASON").Value
  End If  
 End If
End Sub

Sub ContextMenu_BeforeShow(Commands, Obj, Cancel)
  Set CU = ThisApplication.CurrentUser
  'Удаление команды Аннулировать
'  Set User = ThisApplication.ExecuteScript("CMD_DLL", "OrgUserGet", "Группа планирования и проведения конкурентных закупок")
'  If CU.SysName <> User.SysName Then
  If ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsGroupMember",CU,"GROUP_TENDER_INSIDE") = False Then
    Commands.Remove ThisApplication.Commands("CMD_TENDER_IN_GO_PLAN")
  End If
End Sub

Sub Object_BeforeErase(Obj, Cancel)
  Cancel = Not checkBeforeErase(Obj,ThisApplication.CurrentUser,False)
End Sub

Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
  If OkBtnPressed = True Then
    'Проверка состояния
    str = CheckRequedFields(Obj)
    If str <> "" Then
      Msgbox "Не заполнен обязательный атрибут """ & str & """",vbExclamation
      Cancel = True
      Exit Sub
    End If
  End If
End Sub

'Функция проверки заполнения обязательных полей
Function CheckRequedFields(Obj)
  CheckRequedFields = ""
  '№ лота Заказчика
  If Obj.Attributes("ATTR_LOT_NUM").Value = False Then
    CheckRequedFields = "№ лота Заказчика"
    Exit Function
  End If
  'Наименование лота
  If Obj.Attributes("ATTR_TENDER_LOT_NAME").Empty = True Then
    CheckRequedFields = "Наименование лота"
    Exit Function
  End If
  'Тип позиции
  If Obj.Attributes("ATTR_TENDER_LOT_POS_TYPE").Empty = True Then
    CheckRequedFields = "Тип позиции"
    Exit Function
  End If
  'Цена лота без НДС
  If Obj.Attributes("ATTR_TENDER_LOT_PRICE").Empty = True Then
    CheckRequedFields = "Цена лота без НДС"
    Exit Function
  End If
  'Ставка НДС лота
  If Obj.Attributes("ATTR_LOT_NDS_VALUE").Empty = True Then
    CheckRequedFields = "Ставка НДС лота"
    Exit Function
  End If
  'Цена лота с НДС
  If Obj.Attributes("ATTR_TENDER_LOT_NDS_PRICE").Empty = True Then
    CheckRequedFields = "Цена лота с НДС"
    Exit Function
  End If
  'Валюта закупки
  If Obj.Attributes("ATTR_TENDER_CURRENCY").Empty = True Then
    CheckRequedFields = "Валюта закупки"
    Exit Function
  End If
  'Код по ОКАТО
  If Obj.Attributes("ATTR_TENDER_OKATO").Empty = True Then
    CheckRequedFields = "Код по ОКАТО"
    Exit Function
  End If
  
  ' Состав
  Set posType = Obj.Attributes("ATTR_TENDER_LOT_POS_TYPE").Classifier
    If Not posType Is Nothing Then
      If posType.Description = "Материалы" or posType.Description = "Оборудование" Then
        Set Table = Obj.Attributes("ATTR_LOT_DETAIL")
        Set Rows = Table.Rows
        If Rows.Count=0 Then
          CheckRequedFields = "Состав"
          Exit Function
        End If
      End If
    End If
End Function

' Проверка возможности удаления лота пользователем
Function checkBeforeErase(Obj,User,silent)
  checkBeforeErase = False
   If Obj.Parent is nothing Then
    checkBeforeErase = True
    Exit Function
   End If
  If (Obj.RolesForUser(User).Has("ROLE_PURCHASE_RESPONSIBLE") = False And _
      Obj.Parent.RolesForUser(User).Has("ROLE_PURCHASE_RESPONSIBLE") = False) and _
        User.SysName <> "SYSADMIN" Then
        If silent = False Then
          Msgbox "Удалить объект может только ""Ответственный по закупке""", VbCritical
        End If
    Exit Function
  End If
  checkBeforeErase = True
End Function
