' Тип объекта - Документ закупки
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "CMD_FILES_LIBRARY"
USE "CMD_KD_USER_PERMISSIONS"

'  Set User = ThisApplication.CurrentUser
'  If User.Groups.Has("GROUP_CONTRACTS") = False and User.SysName <> "SYSADMIN" Then
'    If Dialog.InputForms.Has("FORM_CONTRACT_INFO") Then
'      Dialog.InputForms.Remove Dialog.InputForms("FORM_CONTRACT_INFO")
'    End If
'  End If
  
  
Sub Object_PropertiesDlgInit(Dialog, Obj, Forms)
  ThisScript.SysAdminModeOn

  'Скрываем прочитанные поручения
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_CORR_REZOL_INF")
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_STAT_MAIN")
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_DEL_MAIN")
    
  'Помечаем прочитанные поручения. Проверка отключена т.к. ответственный может назначаться в начальном статусе
'  if obj.StatusName <> "STATUS_T_TASK_IN_WORK" then _
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","Set_OrdersReaded",Obj


  'Скрываем формы
  Set User = ThisApplication.CurrentUser
  If Obj.Attributes.Has("ATTR_PURCHASE_DOC_TYPE") Then
    Val = Obj.Attributes("ATTR_PURCHASE_DOC_TYPE").Value
    If StrComp(Val,"Информационная карта",vbTextCompare) <> 0 Then
      Arr = Split("FORM_TENDER_INF_LIST_MAIN,FORM_TENDER_INF_LIST_CLIENT_REQUIREMENTS," &_
      "FORM_TENDER_INF_LIST_MAIN_REQUIREMENTS,FORM_TENDER_POSSIBLE_CLIENT,FORM_TENDER_FULL_DOCUMENTATION,FORM_TENDER_MATERIAL_EIS," &_
      "FORM_TENDER_FULL_IN_DOCS_DOCUMENTATION",",")
      For i = 0 to Ubound(Arr)
        If Dialog.InputForms.Has(Arr(i)) Then
          Dialog.InputForms.Remove Dialog.InputForms(Arr(i))
        End If
      Next
     End If
    showInfoFormMain = False
    
    
    '     Делаем не доступным для чтения Заявки на запрос предложений для всех кроме группы и экспертов
'    ----------------------------------------------------------------------------------------------
Set CU = ThisApplication.CurrentUser
If Obj.Attributes.Has("ATTR_PURCHASE_DOC_TYPE") Then
Val = Obj.Attributes("ATTR_PURCHASE_DOC_TYPE").Value
 If StrComp(Val,"Заявка на запрос предложений",vbTextCompare) = 0 Then
  If Obj.RolesForUser(CU).Has("ROLE_TENDER_DOCS_RESP_DEVELOPER") = False Then
   If CU.Groups.Has("GROUP_TENDER_INSIDE") = false and CU.Groups.Has("GROPE_TENDER_EXPERT") = false  and CU.Groups.Has("GROUP_TENDER") = false Then
        Arr = Split("FORM_KD_DOC_AGREE,FORM_KD_DOC_ORDERS",",")
           For i = 0 to Ubound(Arr)
        If Dialog.InputForms.Has(Arr(i)) Then
          Dialog.InputForms.Remove Dialog.InputForms(Arr(i))
        End If
      Next
   End If
  End If
 End If 
End If  
    '-----------------------------------------------------------------------------------------------  
    
    
    
    'Определение активной формы
    If Obj.Dictionary.Exists("FormActive") Then
      FormName = Obj.Dictionary.Item("FormActive")
      If Dialog.InputForms.Has(FormName) Then
        Dialog.ActiveForm = Dialog.InputForms(FormName)
      Else
        showInfoFormMain = True
      End If
      Obj.Dictionary.Remove("FormActive")
'    End If
    Else
      showInfoFormMain = True
    End If
    
    If showInfoFormMain = True Then
      If StrComp(Val,"Информационная карта",vbTextCompare) = 0 Then
        If not Obj.StatusName = "STATUS_KD_AGREEMENT" Then
          Dialog.ActiveForm = Dialog.InputForms("FORM_TENDER_INF_LIST_MAIN")
        End If
      End If
    End If
  End If
  
  'Создание 1 строки в табличных атрибутах цены
  Call OneRowCreate(Obj,"ATTR_TENDER_ITEM_PRICE_MAX_VALUE")
  
'  Делаем разработчика инициатором согласования, т.к. она почему то слетает
   AttrName = "ATTR_RESPONSIBLE"
      RoleName = "ROLE_INITIATOR"
      Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName)
      
      If not User is Nothing Then
        Set Roles = Obj.RolesForUser(User)
        If Roles.Has(RoleName) = False Then
      Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,User.SysName)
        End If
      End If

 End Sub

Sub Object_Modified(Obj)
If Obj.Attributes.Has("ATTR_PURCHASE_DOC_TYPE") Then
    Val = Obj.Attributes("ATTR_PURCHASE_DOC_TYPE").Value
    If StrComp(Val,"Информационная карта",vbTextCompare) <> 0 Then
 Call AttrsSync(Obj)
 End If
End If
  'Модификация роли "Инициатор согласования"
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","InitiatorModified",Obj,"")
End Sub

Sub Object_BeforeErase(Obj, Cancel)
  Set CU = ThisApplication.CurrentUser
  isCanDel = UserCanDelete(CU,Obj)
  If isCanDel = False Then
    Msgbox "Удалить объект могут только ""Ответственный по закупке"", ""Ответственный разработчик""", VbCritical
    Cancel = True
    Exit Sub
  End If
End Sub

'Редактирование меню КМ
'----------------------------------------------------
Sub ContextMenu_BeforeShow(Commands, Obj, Cancel)
  ThisScript.SysAdminModeOn
  'Удаление команды Редактировать
  Commands.Remove ThisApplication.Commands("CMD_PURCHASE_INSIDE_FULLEDIT")
'  Commands.Remove ThisApplication.Commands("CMD_EDIT")
End Sub

'Процедура синхронизации атрибутов с внутренней закупкой
Sub AttrsSync(Obj)
  If StrComp(Obj.Attributes("ATTR_PURCHASE_DOC_TYPE").Value,"Информационная карта",vbTextCompare) = 0 Then
    If not Obj.Parent is Nothing Then
      Set Parent = Obj.Parent
      AttrStr = "ATTR_TENDER_FACT_MATERIAL_TAKE_OFF_DATA,ATTR_TENDER_ITEM_PRICE_MAX_VALUE," &_
      "ATTR_NDS_VALUE,ATTR_LOT_NDS_VALUE,ATTR_TENDER_START_WORK_DATA,ATTR_TENDER_INVOCE_PUBLIC_DATA," &_
      "ATTR_TENDER_ADVANCE_PLAN_PAY,ATTR_TENDER_ADDITIONAL_REQUIREMENTS,ATTR_TENDER_BID_REQUIREMENTS," &_
      "ATTR_TENDER_GUARANTEE_REQUIREMENTS,ATTR_TENDER_RF_CONF_REQUIREMENTS_DOC_LIST," &_
      "ATTR_TENDER_EXPERIENCE_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_PERSONAL_CONF_REQUIREMENTS_DOC_LIST," &_
      "ATTR_TENDER_RIG_CONF_REQUIREMENTS_DOC_LIST,ATTR_TENDER_ISO9001_REQUIREMENTS,ATTR_TENDER_SMALL_BUSINESS_FLAG," &_
      "ATTR_TENDER_ADDITIONAL_INFORMATION,ATTR_TENDER_END_WORK_DATA,ATTR_TENDER_POSSIBLE_CLIENT"
      ThisApplication.ExecuteScript "CMD_DLL","AttrsSyncBetweenObjs", Obj, Parent, AttrStr
    End If
  End If
End Sub

'Создание строки в табличных атрибутах
Sub OneRowCreate(Obj,AttrName)
  ThisScript.SysAdminModeOn
  If Obj.Attributes.Has(AttrName) Then
    Set TableRows = Obj.Attributes(AttrName).Rows
    If TableRows.Count = 0 Then TableRows.Create
  End If
End Sub

'Событие до создания
Sub Object_BeforeCreate(Obj, Parent, Cancel)
  sysID = ThisApplication.ExecuteScript ("CMD_KD_REGNO_KIB","Get_Sys_Id",Obj)
  If sysID = 0 then 
    Cancel = true
    Exit Sub
  Else  
    Obj.Attributes("ATTR_KD_IDNUMBER").value = sysID
  End if
  
  'Заполнение атрибутов
  'Отдел
  ThisScript.SysAdminModeOn
  If Obj.Attributes.Has("ATTR_T_TASK_DEPARTMENT") Then
    Set CU = ThisApplication.CurrentUser
    If CU.Attributes.Has("ATTR_KD_USER_DEPT") Then
      If CU.Attributes("ATTR_KD_USER_DEPT").Empty = False Then
        If not CU.Attributes("ATTR_KD_USER_DEPT").Object is Nothing Then
          Obj.Attributes("ATTR_T_TASK_DEPARTMENT").Object = CU.Attributes("ATTR_KD_USER_DEPT").Object
        End If
      End If
    End If
  End If
  If Obj.Attributes.Has("ATTR_TENDER_DOC_TO_PUBLISH") Then Obj.Attributes("ATTR_TENDER_DOC_TO_PUBLISH") = True
    
   If StrComp(Obj.Attributes("ATTR_PURCHASE_DOC_TYPE").Value,"Информационная карта",vbTextCompare) = 0 Then
'       Msgbox "Информационная карта ",vbExclamation
       Call AttrsSync(Obj)
       Call Pricesync(Obj)
   End If  
  'Маршрут
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Parent,Parent.Status,Obj,Obj.ObjectDef.InitialStatus)
  
End Sub

'До закрытия окна свойств
'-------------------------------------------------------------------
Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
  ThisScript.SysAdminModeOn
  If OkBtnPressed = True Then
    Cancel = Not CheckBeforeClose(Obj)
  End If
  
  'Удаление наследуемых атрибутов из объекта
  AttrName = "ATTR_PURCHASE_DOC_TYPE"
  If OkBtnPressed = True and Obj.Attributes.Has(AttrName) and not Obj.Parent is Nothing Then
    If StrComp(Obj.Attributes(AttrName).Value, "Информационная карта", vbTextCompare) <> 0 Then
      'Удаление наследуемых атрибутов
      Set pAttrs = ThisApplication.ObjectDefs("OBJECT_TENDER_INSIDE").AttributeDefs
      Set oAttrs = Obj.ObjectDef.AttributeDefs
      For Each Attr in oAttrs
        SysName = Attr.SysName
        If SysName <> "ATTR_TENDER_INVITATION_COUNT_EIS" AND SysName <> "ATTR_KD_IDNUMBER" AND SysName <> "ATTR_PROJECT_ORDINAL_NUM" _ 
        AND SysName <> "ATTR_TENDER_INF_CARD_DOC_FLAG" AND SysName <> "ATTR_TENDER_DOC_TIPE_LOC" AND SysName <> "ATTR_TENDER_PLAN_DOC"  Then
          If pAttrs.Has(SysName) and Obj.Attributes.Has(SysName) Then
            Obj.Attributes.Remove Obj.Attributes(SysName)
            ' разблокируем Инф карту, если заблокирована
        End If
       End If
      Next
    Else
      'Проверка на возможность создания информационной карты
      If Obj.ObjectDef.Objects.Has(Obj.GUID) = False Then
        If Obj.Parent.ObjectDefName = "OBJECT_PURCHASE_OUTSIDE" Then
          Msgbox "Информационная карта может быть создана только в составе Внутренней закупки",vbExclamation
          Cancel = True
          Exit Sub
        ElseIf Obj.Parent.StatusName <> "STATUS_TENDER_IN_WORK" and Obj.Parent.Attributes("ATTR_TENDER_URGENTLY_FLAG") <> True Then
          Msgbox "Информационная карта может быть создана только в статусе Разработка документации",vbExclamation
          Cancel = True
          Exit Sub
        End If
      End If
      Call AttrsSync(Obj)
    End If
  End If
   ThisScript.SysAdminModeOff
    ' разблокируем Инф карту, если заблокирована
  If Obj.Attributes.Has(AttrName)  Then'PlotnikovSP added bugfix не закрывалось окно со свойствами
    If StrComp(Obj.Attributes(AttrName).Value, "Информационная карта", vbTextCompare) = 0 Then
    Set CU = ThisApplication.CurrentUser
    Set Obj = ThisObject
  '   If OkBtnPressed = True or Cancel = true Then 
      If Obj.Permissions.Locked = True Then
       If Obj.Permissions.LockUser.SysName = CU.SysName Then
       Obj.Unlock Obj.Permissions.LockType 
  '     msgbox ""
       End If 
      End If 
     End If
  '  End If
  End If

End Sub

'По событию изменения статуса
Sub Object_StatusChanged(Obj, Status)
  ThisScript.SysAdminModeOn
  Attr1 = "ATTR_PURCHASE_DOC_TYPE"
  sName = ""
  OrgName = "Группа планирования и проведения конкурентных закупок"
  Set CU = ThisApplication.CurrentUser
  Set u = ThisApplication.ExecuteScript("CMD_DLL", "OrgUserGet", OrgName)
  If Status is Nothing or Obj.Parent is Nothing or Obj.Attributes.Has(Attr1) = False or u is Nothing Then
    Exit Sub
  End If
  Set Parent = Obj.Parent
  If Obj.Dictionary.Exists("PrevStatusName") Then
    sName = Obj.Dictionary.Item("PrevStatusName")
  End If
'  
'  'Переход в статус Согласовано
  If Status.SysName = "STATUS_DOC_AGREED" Then
'    'Создание поручения
'    resol = "NODE_CORR_REZOL_POD"
'    ObjType = "OBJECT_KD_ORDER_NOTICE"
'    txt = "Прошу подготовить документацию по закупке"
'    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Parent,ObjType,u,CU,resol,txt,""
'    
'    'Если Документ - Информационная карта
'    If StrComp(Obj.Attributes("ATTR_PURCHASE_DOC_TYPE").Value,"Информационная карта",vbTextCompare) = 0 Then
'      'Закупку переводим в статус На утверждении
'      StatusName = "STATUS_TENDER_IN_IS_APPROVING"
'      RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Parent,Parent.Status,Parent,StatusName)
'      If RetVal = -1 Then
'        Parent.Status = ThisApplication.Statuses(StatusName)
'      End If
'      'Создаем поручение
'      resol = "NODE_CORR_REZOL_POD"
'      ObjType = "OBJECT_KD_ORDER_NOTICE"
'      Set u0 = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Parent,"ATTR_TENDER_GROUP_CHIF")
'      Set u1 = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Parent,"ATTR_TENDER_ACC_CHIF")
'      txt = "Прошу подготовить и разместить закупку в ЕИС"
'      PlanDate = ""
'      AttrName = "ATTR_TENDER_PRESENT_PLAN_DATA"
'      If Parent.Attributes.Has(AttrName) Then
'        If Parent.Attributes(AttrName).Empty = False Then
'          PlanDate = Parent.Attributes(AttrName).Value
'        End If
'      End If
'      If PlanDate = "" Then PlanDate = Date + 1
'      ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Parent,ObjType,u0,u1,resol,txt,PlanDate
      'Синхронизация атрибутов
      AttrStr = "ATTR_TENDER_ITEM_PRICE_MAX_VALUE,ATTR_TENDER_PRICE,ATTR_TENDER_NDS_PRICE," &_
      "ATTR_TENDER_SUM_NDS,ATTR_NDS_VALUE,ATTR_TENDER_INVITATION_PRICE_EIS"
      ThisApplication.ExecuteScript "CMD_DLL","AttrsSyncBetweenObjs", Obj, Parent, AttrStr
'    End If
    
    'Заполнение атрибута "Дата фактического предоставления материалов для подготовки закупочной документации"
    
    If StrComp(Obj.Attributes(Attr1).Value, "Информационная карта", vbTextCompare) = 0 Then
      AttrName = "ATTR_TENDER_FACT_MATERIAL_TAKE_OFF_DATA"
      If Obj.Attributes.Has(AttrName) Then Obj.Attributes(AttrName).Value = Date
      If Parent.Attributes.Has(AttrName) Then Parent.Attributes(AttrName).Value = Date
    End If
  End If
'  End If
' End If
  'Определение статуса после согласования
  StatusAfterAgreed = ""
  Set Rows = ThisApplication.Attributes("ATTR_AGREENENT_SETTINGS").Rows
  For Each Row in Rows
    If Row.Attributes("ATTR_KD_OBJ_TYPE").Value = Obj.ObjectDefName Then
      StatusAfterAgreed = Row.Attributes("ATTR_KD_FINISH_STATUS")
      Exit For
    End If
  Next
  
  'Отработка маршрутов для механизма согласования
  If Status.SysName = "STATUS_KD_AGREEMENT" or Status.SysName = StatusAfterAgreed Then
    If sName <> "" Then
      If ThisApplication.Statuses.Has(sName) Then
        Set PrevSt = ThisApplication.Statuses(sName)
        Call ThisApplication.ExecuteScript("CMD_ROUTER","RunNonStatusChange",Obj,PrevSt,Obj,Status.SysName) 
      End If
    End If
  End If
  
  'Создание ролей у документа и закупки
  If Status.SysName = "STATUS_KD_AGREEMENT" Then
    RoleName = "ROLE_TENDER_DOCS_DEVELOPER" 
    AttrStr = "ATTR_TENDER_RESP,ATTR_TENDER_MATERIAL_RESP,ATTR_TENDER_PEO_CHIF,ATTR_TENDER_KP_DESI"
    Arr = Split(AttrStr,",")
    For i = 0 to Ubound(Arr)
      AttrName = Arr(i)
      If Parent.Attributes.Has(AttrName) Then
        Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Parent,AttrName)
        If not User is Nothing Then
          If Parent.RolesForUser(User).Has(RoleName) = False Then
            Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Parent,RoleName,User.SysName)
          End If
          If Obj.RolesForUser(User).Has(RoleName) = False Then
            Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,User.SysName)
          End If
        End If
      End If
    Next
   End If
  
  'Если возвращено с согласования  - поручение Инициатору от Последнего согласующего "Исправить согласно результатам согласования"
  'Если согласовано  - поручение Инициатору от Последнего согласующего "Ознакомиться с результатом согласования"
  'Если согласована Информационная карта - закрытие Документа, перевод закупки На утверждение
  ' и поручение Руководителю группы от Руководителя на подготовку Закупки к публикации.
   If Obj.StatusName = "STATUS_DOC_IN_WORK" Then  
    Set uToUser = Obj.Attributes("ATTR_RESPONSIBLE").User
     If uToUser Is Nothing Then Exit Sub
     Set uFromUser = CU
     resol = "NODE_CORR_REZOL_POD"
     txt = "Прошу внести изменения """ & Obj.Description & """согласно результатам согласования"
     planDate = Date + 3
    elseif Obj.StatusName = "STATUS_DOC_AGREED" Then
     If StrComp(Obj.Attributes("ATTR_PURCHASE_DOC_TYPE").Value,"Информационная карта",vbTextCompare) = 0 Then
       Res = ThisApplication.ExecuteScript("CMD_TENDER_DOC_GO_END","Main",Obj)' Смена статуса Документа закупки
       Exit sub
     End If 
       Set uToUser = Obj.Attributes("ATTR_RESPONSIBLE").User
        If uToUser Is Nothing Then Exit Sub
         Set uFromUser = CU
         resol = "NODE_CORR_REZOL_POD"
         txt = "Документ закупки""" & Obj.Description & """согласован"
         planDate = Date + 1
        end if
       ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
             
 End Sub

'Перед сменой статуса
Sub Object_StatusBeforeChange(Obj, Status, Cancel)
  ThisScript.SysAdminModeOn
          
  'Записываем текущий статус в словарь
  Obj.Dictionary.Item("PrevStatusName") = Obj.StatusName
End Sub

'Sub Object_Created(Obj, Parent)
'  'Оповещение Ответственного руководителя
'  AttrName = "ATTR_PURCHASE_DOC_TYPE"
'  If Obj.Attributes.Has(AttrName) and not Parent is Nothing Then
'    If Obj.Attributes(AttrName).Empty = False and Parent.ObjectDefName = "OBJECT_TENDER_INSIDE" Then
'      If StrComp(Obj.Attributes(AttrName).Value,"Протокол подведения итогов",vbTextCompare) = 0 Then
'        Set User0 = Nothing
'        Set User1 = Nothing
'        AttrName0 = "ATTR_TENDER_ACC_CHIF"
'        AttrName1 = "ATTR_TENDER_MATERIAL_RESP"
'        If Parent.Attributes.Has(AttrName0) Then
'          If Parent.Attributes(AttrName0).Empty = False Then
'            If not Parent.Attributes(AttrName0).User is Nothing Then Set User0 = Parent.Attributes(AttrName0).User
'          End If
'        End If
'        If Parent.Attributes.Has(AttrName1) Then
'          If Parent.Attributes(AttrName1).Empty = False Then
'            If not Parent.Attributes(AttrName1).User is Nothing Then Set User1 = Parent.Attributes(AttrName1).User
'          End If
'        End If
'        Check = True
'        If not User0 is Nothing Then
'          ThisApplication.ExecuteScript "CMD_MESSAGE","SendMessage",6007,User0,Obj,Nothing,Obj.Description
'          If not User1 is Nothing Then
'            If User0.SysName = User1.SysName Then Check = False
'          Else
'            Check = False
'          End If
'        End If
'        If Check = True Then
'          ThisApplication.ExecuteScript "CMD_MESSAGE","SendMessage",6007,User1,Obj,Nothing,Obj.Description
'        End If
'      End If
'    End If
'  End If
'End Sub

'Sub Files_DragAndDropped(FilesPathArray, Object, Cancel)
'    if Ubound(FilesPathArray)>0 then 
'      For i=0 to Ubound(FilesPathArray)
'        msgbox FilesPathArray(i) 'AddFilesToDoc
'        'call LoadFileByObj("FILE_KD_ANNEX", FilesPathArray(i), true, Object)
'        Call LoadFiles(Object,"FILE_ANY",FilesPathArray(i),False)
'      Next 
'    else
'      Call LoadFiles(Object,"FILE_ANY",FilesPathArray(0),False)
''      AddFilesToDoc(FilesPathArray(0))   
'    end if
'    Object.Permissions = SysAdminPermissions
'    Object.upDate
'End Sub

Sub File_CheckedIn(File, Object)
ThisScript.SysAdminModeOn
  dim FileDef
'  if IsExistsGlobalVarrible("FileTpRename") then call ReNameFiles(file,Object)
  FileDef =  File.FileDefName
  'call AddToFileList(file,object)   ' Пока нет такой таблицы
    select case FileDef
      case "FILE_KD_SCAN_DOC","FILE_E-THE_ORIGINAL"  Object.Files.Main = File 'если скан документ
      case "FILE_KD_WORD","FILE_DOC_XLS","FILE_ANY"
        call ThisApplication.ExecuteScript("OBJECT_KD_BASE_DOC","delElScan",file,Object)' call CreatePDFFromFile(File.WorkFileName, Object, nothing) ' .WorkFileName .FileName
    end select  
    ThisScript.SysAdminModeOff  
End Sub

Function UserCanDelete(user,Obj)
  UserCanDelete = False
  Set Roles = Obj.RolesForUser(user)
  If Roles.Has("ROLE_PURCHASE_RESPONSIBLE") = False and user.SysName <> "SYSADMIN" and _
  Roles.Has("ROLE_TENDER_DOCS_RESP_DEVELOPER") = False Then
    Exit Function
  End If
  UserCanDelete = True
End Function

' Проверка перед закрытием формы
Function CheckBeforeClose(Obj)
  CheckBeforeClose = False
  str = CheckRequedFieldsBeforeClose(Obj)
  If str <> "" Then
    Msgbox "Не заполнены обязательные атрибуты: " & str,vbExclamation
    Exit Function
  End If
  CheckBeforeClose = True
End Function

' Функция проверки заполнения обязательных полей
Function CheckRequedFieldsBeforeClose(Obj)
  CheckRequedFieldsBeforeClose = ""
  str = ""
  'Тип документа
 If Obj.Attributes.has("ATTR_PURCHASE_DOC_TYPE") then
  If Obj.Attributes("ATTR_PURCHASE_DOC_TYPE").Empty = True Then
    CheckRequedFieldsBeforeClose = "Тип документа"
    str = str & chr(10) & "- " & CheckRequedFieldsBeforeClose
    'Exit Function
  End If
 End If
  'Разработал
  If Obj.Attributes.has("ATTR_RESPONSIBLE") then
  If Obj.Attributes("ATTR_RESPONSIBLE").Empty = True Then
    CheckRequedFieldsBeforeClose = "Разработал"
    str = str & chr(10) & "- " & CheckRequedFieldsBeforeClose
    'Exit Function
  End If
  End If
  CheckRequedFieldsBeforeClose = str
  
End Function


Function GetRegNumber(Obj)
  GetRegNumber = ""
  Set parent = Obj.parent
  If Parent Is Nothing Then exit Function
  GetNewNO = 0
  Set QueryDoc = ThisApplication.Queries("QUERY_GET_PDOCMAX_NO")
  QueryDoc.Parameter("PARAM0") = parent.handle
  QueryDoc.Parameter("PARAM1") = obj.ObjectDefName
  Set sh = QueryDoc.Sheet
  if not sh is nothing then 
    if sh.RowsCount >0 then 
      IntValue = sh.CellValue(0,0)
'       IntValue = IntTryParse(sh.CellValue(0,0))
       GetNewNO = IntValue
    end if 
  end if 
  GetNewNO = GetNewNO + 1
  GetRegNumber = GetNewNO
End Function

'Функция проверки Документа закупки перед согласованием
'OBJECT_PURCHASE_DOC;PurchaseDocCheck
Function PurchaseDocCheck(Obj)
  PurchaseDocCheck = True
'  call GetAggrList(Obj)
'  CheckBeforeAgree = GetAggrList(Obj) ' Закоментил для переноса проверки на инф карту
'  Exit Function
  'Проверка типа документа
  Check = True
  AttrName = "ATTR_PURCHASE_DOC_TYPE"
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      DocType = Obj.Attributes(AttrName).Value
      If StrComp(DocType,"Информационная карта",vbTextCompare) = 0 Then 
      Check = False
      PurchaseDocCheck = False
      End If
    End If
  End If
  
  'Проверка атрибутов
  If Check = False Then
    Str = ""
    AttrStr = "ATTR_TENDER_INVOCE_PUBLIC_DATA,ATTR_TENDER_START_WORK_DATA,"&_
    "ATTR_TENDER_END_WORK_DATA,ATTR_TENDER_ITEM_PRICE_MAX_VALUE"'ATTR_TENDER_FACT_MATERIAL_TAKE_OFF_DATA,
    Arr = Split(AttrStr,",")
    For i = 0 to Ubound(Arr)
      AttrName = Arr(i)
      If ThisApplication.AttributeDefs.Has(AttrName) and Obj.Attributes.Has(AttrName) Then
        Set Attr = ThisApplication.AttributeDefs(AttrName)
        Check = True
        If AttrName = "ATTR_TENDER_ITEM_PRICE_MAX_VALUE" Then
          If Obj.Attributes(AttrName).Rows.Count = 0 Then
            Check = False
          Else
            For Each Attr0 in Obj.Attributes(AttrName).Rows(0).Attributes
              If Attr0.AttributeDef.Type = 14 Then
                If Attr0.Value = 0  and Attr0.AttributeDefname <> "ATTR_TENDER_SUM_NDS" Then Check = False ' 
'              msgbox  Attr0.AttributeDefname
              Else
                If Attr0.Value = "" Then Check = False
              End If
            Next
          End If
        ElseIf Obj.Attributes(AttrName).Empty Then
          Check = False
        End If
        If Check = False Then
          If Str = "" Then
            Str = Attr.Description
          Else
            Str = Str & ", " & Attr.Description
          End If
        End If
      End If
    Next
    
    If Str <> "" Then
      Msgbox "Обязательные атрибуты не заполнены:" & chr(10) & Str, vbExclamation
      Exit Function
    End If
  
   Set User = Obj.parent.Attributes("ATTR_TENDER_ACC_CHIF").User
   Set User1 = Obj.parent.Attributes("ATTR_TENDER_PEO_CHIF").User
   Userstr = User.sysname & "," & User1.sysname
   If Userstr <> "" Then
   PurchaseDocCheck =  ThisApplication.ExecuteScript ("CMD_TENDER_OBJ_LIB","GetAggrList", Obj, Userstr) 
   End if
  End If
End Function  

''Функция проверки листа согласования
'function GetAggrList(Obj)
'Set User = Obj.parent.Attributes("ATTR_TENDER_ACC_CHIF").User
'Set User1 = Obj.parent.Attributes("ATTR_TENDER_PEO_CHIF").User
'Userstr = User.sysname & "," & User1.sysname
'If Userstr <> "" Then
'ThisApplication.ExecuteScript "CMD_TENDER_OBJ_LIB","GetAggrList",Obj, Userstr
'End if
'end function

'Function CheckBeforeAgree(Obj)

'  call GetAggrList(Obj)
'  CheckBeforeAgree = GetAggrList(Obj) ' Закоментил для переноса проверки на инф карту
'  Exit Function
'  CheckBeforeAgree = TenderInsideCheck(Obj)
'  Exit Function
'  CheckBeforeAgree = False
'  str = CheckRequedFieldsBeforeAgree(Obj)
'  If str <> "" Then
'    Msgbox "Не заполнены обязательные атрибуты: " & str,vbExclamation
'    Exit Function
'  End If
'  CheckBeforeAgree = True
'End Function

function CanIssueOrder(DocObj)
  CanIssueOrder = false
  docStat = DocObj.StatusName
  str = ";STATUS_DOC_IN_WORK;STATUS_KD_AGREEMENT;STATUS_DOC_AGREED;" &_
  "STATUS_DOC_IS_END;"
  if Instr(";" & str & ";", ";" & docStat & ";") > 0 then _
      CanIssueOrder = true
end function

'Заполнение поля Расчетная (максимальная) цена предмета закупки (договора), цена с НДС, сумма НДС и цена без НДС.
Sub Pricesync(Obj)
ThisScript.SysAdminModeOn
  AttrName0 = "ATTR_TENDER_ITEM_PRICE_MAX_VALUE" 'Расчетная (максимальная) цена предмета закупки
  AttrName1 = "ATTR_TENDER_PLAN_NDS_PRICE" 'Планируемая цена закупки с НДС
  AttrName2 = "ATTR_TENDER_PLAN_PRICE" 'Планируемая цена закупки без НДС      
  AttrName3 = "ATTR_NDS_VALUE" 'Ставка НДС закупки
  AttrName4 = "ATTR_TENDER_NDS_PRICE" 'Цена закупки с НДС
  AttrName5 = "ATTR_TENDER_PRICE" 'Цена закупки без НДС
  AttrName7 = "ATTR_TENDER_SUM_NDS" 'Сумма НДС
' AttrName1 = "ATTR_TENDER_INVITATION_PRICE_EIS"
'  and Obj.Attributes.Has(AttrName1)and Obj.Attributes.Has(AttrName2) and Obj.Attributes.Has(AttrName3)_
  If Obj.Attributes.Has(AttrName0) and Obj.parent.Attributes.Has(AttrName1)_ 
   and Obj.parent.Attributes.Has(AttrName2)and Obj.parent.Attributes.Has(AttrName3) Then
    Set TableRows0 = Obj.Attributes(AttrName0).Rows
    If TableRows0.Count = 0 Then TableRows0.Create
    '  Удаляем лишние строки из таблицы
    If TableRows0.Count <> 1 Then 
     for i = 1 to TableRows0.Count 
     TableRows0(i).Erase
     i = i + 1
     next
    End If  
    Set Row0 = TableRows0(0)
     If Row0.Attributes.has(AttrName3) then Row0.Attributes(AttrName3) = Obj.parent.Attributes(AttrName3)
     If Row0.Attributes.has(AttrName4) then Row0.Attributes(AttrName4).Value = Obj.parent.Attributes(AttrName1).Value
     If Row0.Attributes.has(AttrName5) then Row0.Attributes(AttrName5).Value = Obj.parent.Attributes(AttrName2).Value
      If Row0.Attributes.has(AttrName7) then 
      If Obj.parent.Attributes.has(AttrName7) then Row0.Attributes(AttrName7).Value = Obj.parent.Attributes(AttrName7).Value
      End if
   End If  
   
  'Заполнение полей Срок начала и конца выполнения работ 
   AttrName1 = "ATTR_TENDER_WORK_START_PLAN_DATA" 'Дата начала заключения договора по предмету закупки (план) из Сроков
   AttrName2 = "ATTR_TENDER_WORK_END_PLAN_DATA" 'Дата окончания работ по предмету закупки (план) из Сроков
   AttrName3 = "ATTR_TENDER_START_WORK_DATA" 'Срок начала выполнения работ в Инф. карте
   AttrName4 = "ATTR_TENDER_END_WORK_DATA" 'Срок окончания выполнения работ в Инф. карте
   If Obj.Attributes.Has(AttrName3) and Obj.Attributes.Has(AttrName4)_ 
   and Obj.parent.Attributes.Has(AttrName1)and Obj.parent.Attributes.Has(AttrName2) Then
    Obj.Attributes(AttrName3) = Obj.parent.Attributes(AttrName1)
    Obj.Attributes(AttrName4) = Obj.parent.Attributes(AttrName2)
    Call AttrsSync(Obj)
   End If 
   ThisScript.SysAdminModeOff
End Sub

'Функция создания поручения после согласования
Sub SendOrder(Obj)
'  If Obj.StatusName = "STATUS_DOC_AGREED" Then
'   If StrComp(Obj.Attributes("ATTR_PURCHASE_DOC_TYPE").Value,"Информационная карта",vbTextCompare) = 0 Then
'       Res = ThisApplication.ExecuteScript("CMD_TENDER_DOC_GO_END","Main",Obj)' Смена статуса Документа закупки
'   End If 
'  End If 
'   If Obj.StatusName = "STATUS_DOC_IN_WORK" Then
'       Res = ThisApplication.ExecuteScript("CMD_TENDER_DOC_GO_END","Main",Obj)' Смена статуса Документа закупки
'  End If 
End Sub
   '  Перенесено в Завершить
'  Set uToUser = Obj.parent.Attributes("ATTR_TENDER_GROUP_CHIF").User
'  If uToUser Is Nothing Then Exit Sub
'   msgbox "" & StrComp(Obj.Attributes("ATTR_PURCHASE_DOC_TYPE").Value,"Информационная карта",vbTextCompare), vbCritical  
'  If StrComp(Obj.Attributes("ATTR_PURCHASE_DOC_TYPE").Value,"Информационная карта",vbTextCompare) = 0 Then
''  If StrComp(Obj.Attributes("ATTR_PURCHASE_DOC_TYPE").Classifier.Description,"Информационная карта",vbTextCompare) = 0 Then
'  Res = ThisApplication.ExecuteScript("CMD_TENDER_DOC_GO_END","Main",Obj)' 
'   AttrStr = "ATTR_TENDER_ITEM_PRICE_MAX_VALUE,ATTR_TENDER_PRICE,ATTR_TENDER_NDS_PRICE," &_
'      "ATTR_TENDER_SUM_NDS,ATTR_NDS_VALUE,ATTR_TENDER_INVITATION_PRICE_EIS"
'      ThisApplication.ExecuteScript "CMD_DLL","AttrsSyncBetweenObjs", Obj, Obj.Parent, AttrStr


'  Set uFromUser = Obj.Attributes("ATTR_TENDER_ACC_CHIF").User
'  resol = "NODE_CORR_REZOL_POD"
'  txt = "Информационная карта""" & Obj.Description & """по закупке""" & Obj.parent.Description & """согласована. Завершите документ для передачи закупки на подготовку к публикации"
'  planDate = Date + 3
'  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,"OBJECT_KD_ORDER_SYS",uToUser,uFromUser,resol,txt,planDate
'  End If
' End If

'Функция ограничения типов файлов для загрузки в объект по статусам и ролям
function GetTypeFileArr(docObj)
  Set CU = ThisApplication.CurrentUser
  isSin = isResp(CU) or isRole(CU,docObj)
  isCanAppr = ThisApplication.ExecuteScript("CMD_KD_USER_PERMISSIONS","IsCanAprove",CU,docObj)
  
  st = docObj.StatusName
  select case st
    case "STATUS_DOC_IN_WORK" 'Плановая
    if IsExecutor(CU, docObj) or isSin or isCanAppr then GetTypeFileArr = array("Файл") 
    case "STATUS_TENDER_OUT_ADD_APPROVED" 'Одобрена
    if IsExecutor(CU, docObj) or isSin or isCanAppr then GetTypeFileArr = array("Файл") 
    case "STATUS_KD_AGREEMENT" 'На согласовании
    if IsExecutor(CU, docObj) or isSin or isCanAppr then GetTypeFileArr = array("Файл") 
    case "STATUS_DOC_AGREED" 'Согласовано
    if IsExecutor(CU, docObj) or isSin or isCanAppr then GetTypeFileArr = array("Файл") 
   end select
end function

function isResp(user)
  isResp = user.Groups.Has("GROUP_TENDER_INSIDE")
end function

function isRole(user, docObj)
  isRole = false
  RoleStr = "ROLE_TENDER_DOCS_RESP_DEVELOPER,ROLE_TENDER_DOCS_DEVELOPER,ROLE_PURCHASE_RESPONSIBLE,ROLE_INITIATOR"
  Set CU = ThisApplication.CurrentUser
  Set Roles = docObj.RolesForUser(CU)
   Rol = Split(RoleStr,",")
    For j = 0 to Ubound(Rol)
    if Rol(j) <> "" then 
    RoleName = Rol(j)
     If Roles.Has(RoleName) Then
     isRole = True  
     Exit function
     End If
    End If 
    next
end function

