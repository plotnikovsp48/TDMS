' $Workfile: OBJECTDEF.SCRIPT.OBJECT_VOLUME.scr $ 
' $Date: 30.01.07 19:38 $ 
' $Revision: 1 $ 
' $Author: Oreshkin $ 
'
' Том
'------------------------------------------------------------------------------
' Авторское право c ЗАО <НАНОСОФТ>, 2008 г.

USE CMD_SS_SYSADMINMODE

Sub Object_BeforeCreate(o_, p_, cn_)
  '  Проверяем выполнение входных условий
  Dim result
  result=Not StartCondCheck (o_,p_)
  If result Then 
    cn_= result
    Exit Sub
  End If

  Dim vOInitialStatus
  Dim vPInitialStatus
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",p_,p_.Status,o_,o_.ObjectDef.InitialStatus)    
  Call SetAttrs(p_,o_)
End Sub

Sub Object_Created(Obj, Parent)
' создание плановой задачи
  Call ThisApplication.ExecuteScript("CMD_ADD_TO_PLATAN", "Main", Obj)
End Sub

Sub Object_BeforeErase(o_, cn_)
  Dim result1,result2
  result1 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckContent", o_)
  result2 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckReferencedBy", o_) 
  cn_=result1 Or result2
  Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", o_) 
End Sub
 
Sub Object_ContentAdded(Obj, AddCollection)
  Obj.Permissions = SysAdminPermissions
'  ThisScript.SysAdminModeOn

  ' Переводим в статус Сборка Тома при добавлении объекта состава, производного от OBJECT_DOC, 
  ' если Том в статусе Том создан
  If Obj.StatusName = "STATUS_VOLUME_CREATED" Then
    For Each oDoc In AddCollection
      If oDoc.ObjectDef.SuperObjectDefs.Has("OBJECT_DOC") Then
        Call ThisApplication.ExecuteScript ("CMD_VOLUME_SET_TO_WORK", "RunMain", Obj)
        Exit For
      End If
    Next
  End If
End Sub

'  Sub Object_BeforeContentRemove(Obj, RemoveCollection, Cancel)
'   Cancel = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckEraseFlag", RemoveCollection)
' End Sub

Sub Object_BeforeContentRemove(o_, RemoveCollection, Cancel)
  Dim result,o
  result = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckEraseFlag", RemoveCollection)
  If Not result Then Exit Sub
  ' Проверка наличие контейнеров непосредственно содержащие удаляемые объекты
  Set o = CheckUplinks(RemoveCollection)
  If o Is Nothing Then Exit Sub
  ' Подтверждение удаления
  result = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning", vbExclamation+vbYesNo, 1125,o.ObjectDef.Description,o.ObjectDef.Description)
  If result <> vbYes Then Cancel=True
End Sub

Sub ContextMenu_BeforeShow(Commands, Obj, Cancel)
  If Obj.Attributes.Has("ATTR_SUBCONTRACTOR_WORK") Then
    If Obj.Attributes("ATTR_SUBCONTRACTOR_WORK").Value = False Then
      Commands.Remove ThisApplication.Commands("CMD_SECTION_CREATE")
      Commands.Remove ThisApplication.Commands("CMD_FOLDER_IMPORT")
    End If
  End If
End Sub

Sub Object_StatusBeforeChange(Obj, Status, Cancel)
  ThisScript.SysAdminModeOn
  'Записываем текущий статус в словарь
  Obj.Dictionary.Item("PrevStatusName") = Obj.StatusName
End Sub

Sub Object_StatusChanged(Obj, Status)
  If Status is Nothing Then Exit Sub
  ThisScript.SysAdminModeOn
  
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
    If Obj.Dictionary.Exists("PrevStatusName") Then
      sName = Obj.Dictionary.Item("PrevStatusName")
      If ThisApplication.Statuses.Has(sName) Then
        Set PrevSt = ThisApplication.Statuses(sName)
        Call ThisApplication.ExecuteScript("CMD_ROUTER","RunNonStatusChange",Obj,PrevSt,Obj,Status.SysName) 
      End If
    End If
  End If
  ' reset ready_to_send flag
  If "STATUS_VOLUME_IS_APPROVED" <> Status.SysName Then
    Obj.Attributes("ATTR_READY_TO_SEND").Value = False
  End If
  
  ' Закрываем плановую задачу
  If Status.SysName = "STATUS_VOLUME_IS_APPROVED" or Status.SysName = "STATUS_S_INVALIDATED" Then
    Call ThisApplication.ExecuteScript("CMD_PLAN_TASK_LIB", "ClosePlanTask",Obj)
  End If
End Sub

Sub Object_BeforeModify(Obj, Cancel)
  ' Меняем описание объекта
  Call ThisApplication.ExecuteScript ("CMD_DLL","SetDescription",Obj)
End Sub

Sub Object_Modified(Obj)
  ' Отправляем оповещения ответственному и бывшему ответственному
  Call ThisApplication.ExecuteScript ("CMD_DLL_ORDERS", "SendOrderToResponsible",Obj)
  ThisApplication.Shell.Update Obj.Parent
  ' Обновление данных плановой задачи
  Call ThisApplication.ExecuteScript("CMD_PLAN_TASK_LIB","UpdatePlanTask",Obj)
End Sub

Sub Object_PropertiesDlgInit(Dialog, Obj, Forms)
    'отмечаем все поручения по тому прочитанными
    'if obj.StatusName <> "STATUS_VOLUME_CREATED" And obj.StatusName <> "STATUS_VOLUME_IS_BUNDLING" then _
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","Set_OrdersReaded",Obj
    ' Закрываем информационные поручения 
    Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_CORR_REZOL_INF")
    Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_STAT_MAIN")
    Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_DEL_MAIN")
  
  If Obj.Attributes.Has("ATTR_SUBCONTRACTOR_WORK") Then
    If Obj.Attributes("ATTR_SUBCONTRACTOR_WORK").Value = False Then
      If Dialog.InputForms.Has("FORM_SUBCONTRACTOR") Then
        Dialog.InputForms.Remove Dialog.InputForms("FORM_SUBCONTRACTOR")
      End If
    Else
      If Obj.Dictionary.Exists("FormActive") Then
        If Dialog.InputForms.Has("FORM_SUBCONTRACTOR") and Obj.Dictionary.Item("FormActive") = True Then
          Dialog.ActiveForm = Dialog.InputForms("FORM_SUBCONTRACTOR")
          Obj.Dictionary.Remove("FormActive")
        End If
      End If
    End If
  End If
End Sub

Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
  if obj.permissions.view <> 0 then
    If OkBtnPressed = True Then 
      check1 = Not CheckAttributes(Obj)
      Check2 = ThisApplication.ExecuteScript("CMD_S_NUMBERING","CheckObjExist",Obj,"ATTR_VOLUME_NUM",Obj.Attributes("ATTR_VOLUME_NUM"),1227)
      Cancel = Not((Not check1) And Not Check2)
    End If
  
    if thisObject.Permissions.LockOwner then 
      if ThisObject.Permissions.Locked = true Then 
        ThisObject.Unlock ThisObject.Permissions.LockType
      end if
    end if
  end if
End Sub

'==============================================================================
' Проверка входных условий
'------------------------------------------------------------------------------
' o_:TDMSObject - Основной комплект
' p_:TDMSObject - Полный комплект
' StartCondCheck: Boolean   True - входные условия выполнены
'                           False - входные условия не выполнены
'==============================================================================
Private Function StartCondCheck(o_,p_)
  StartCondCheck = False
  ' Проверяем статус полного комплекта
'  If p_.Status.SysName <> "STATUS_DOCS_FOR_CUSTOMER_IS_DEVELOPING" Then
'    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1181
'    Exit Function
'  End If
  ' Проверяем принадлежность пользователя к группе Группа комплектации
  Set CU = ThisApplication.CurrentUser
  If o_.RolesForUser(CU).Has("ROLE_STRUCT_DEVELOPER") AND Not ThisApplication.Groups("GROUP_LEAD_DEVELOPERS").Users.Has(CU) Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 1181
    Exit Function
  End If
  
  StartCondCheck = True
End Function


'==============================================================================
' Функция проверяет наличие контейнеров непосредственно содержащие данный 
' объект
'------------------------------------------------------------------------------
' os_:TDMSObjects - Коллекция удаляемых из состава объектов
' CheckUplinks:TDMSObject - Объект не входящий не в один контейнер и не 
'    содержащийся на рабочем столе
'==============================================================================
Private Function CheckUplinks(os_)
  Set CheckUplinks = Nothing
  For Each o In os_
    If ((o.Uplinks.Count <= 1) And (Not ThisApplication.Desktop.Objects.Has(o.GUID))) Then
      Set CheckUplinks = o
      Exit Function
    End If
  Next
End Function

'==============================================================================
' Функция Устанавливает начальные атрибуты по умолчанию
'------------------------------------------------------------------------------
' p_:TDMSObject - Родительский объект (Раздел, Подраздел)
' o_:TDMSObject - Создаваемый объект
'==============================================================================
Private Sub SetAttrs(p_,Obj)
  ' Установка атрибута "Раздел(Подраздел)"
  ThisApplication.ExecuteScript "CMD_DLL", "SetAttr", Obj,"ATTR_VOLUME_SECTION",p_
    'Формируем номер тома
    Obj.Attributes("ATTR_VOLUME_NUM") = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "VolumeNumCodeGen",Obj)
    'Формируем обозначение тома
    Obj.Attributes("ATTR_VOLUME_CODE") = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "VolumeCodeGen",Obj)
    'Формируем обозначение тома
    Obj.Attributes("ATTR_VOLUME_NAME") = ThisApplication.ExecuteScript("CMD_S_NUMBERING", "VolumeNameGen",Obj)
  ' Заполняем отдел
  Call ThisApplication.ExecuteScript("CMD_DEVELOPER_APPOINT","SetDept",Obj,Obj.Attributes("ATTR_RESPONSIBLE").User)
End Sub

Function CheckAttributes(Obj)
  CheckAttributes = True
  txt = "Не заполнен атрибут: " 
  If Obj.Attributes("ATTR_BOOK_NUM").Empty = False And Obj.Attributes("ATTR_BOOK_NAME").Empty = True Then
    txt = txt & chr(10) & "- Наименование книги"
    CheckAttributes = False
  End If
  If Obj.Attributes("ATTR_VOLUME_PART_NUM").Empty = False And Obj.Attributes("ATTR_VOLUME_PART_NAME").Empty = True Then
    txt = txt & chr(10) & "- Наименование части"
    CheckAttributes = False
  End If
  If CheckAttributes = False Then
    Msgbox txt,vbExclamation,"Не заполнены атрибуты"
  End If
End Function

'Функция проверки значения номера части тома
Function CheckPartNum(Val)
  CheckPartNum = True
  If Val = "" Then Exit Function
  If IsNumeric(Val) = False Then
    CheckPartNum = False
  Else
    ValNum = CDbl(Val)
    If ValNum <= 0 Then
      CheckPartNum = False
    ElseIf ValNum <> Int(ValNum) Then
      CheckPartNum = False
    End If
  End If
End Function

'Функция проверки значения номера книги тома
Function CheckBookNum(Val)
  CheckBookNum = True
  If Val = "" Then Exit Function
  Arr = Array("1","2","3","4","5","6","7","8","9","0",".")
  For i = 1 to Len(Val)
    Symbol = Mid(Val,i,1)
    Check = False
    For j = 0 to Ubound(Arr)
      If Arr(j) = Symbol Then
        Check = True
        If Symbol = "0" and i > 1 Then
          If Mid(Val,i-1,1) = "." Then
            Check = False
          End If
        ElseIf Symbol = "." and i = Len(Val) Then
          Check = False
        End If
        Exit For
      End If
    Next
    If Check = False Then
      CheckBookNum = False
      Exit Function
    End If
  Next
End Function

'======================== Внешние функции для извлечения данных из Тома в другие объекты
Extern GetVolumeName [Alias ("Наименование тома"), HelpString ("Наименование тома")]
Function GetVolumeName(Obj) 
  GetVolumeName = vbNullString
  Set vol = ThisApplication.ExecuteScript("CMD_S_DLL","GetUplinkObj",Obj,"OBJECT_VOLUME")
  If vol Is Nothing Then Exit Function
  GetVolumeName= vol.Attributes("ATTR_VOLUME_NAME").Value
End Function

Extern GetVolumeNum [Alias ("Номер тома"), HelpString ("Номер тома")]
Function GetVolumeNum(Obj) 
  GetVolumeNum = vbNullString
  Set vol = ThisApplication.ExecuteScript("CMD_S_DLL","GetUplinkObj",Obj,"OBJECT_VOLUME")
  If vol Is Nothing Then Exit Function
  GetVolumeNum= vol.Attributes("ATTR_VOLUME_NUM")
End Function

Extern GetVolumeCode [Alias ("Обозначение тома"), HelpString ("Обозначение тома")]
Function GetVolumeCode(Obj) 
  GetVolumeCode = vbNullString
  Set vol = ThisApplication.ExecuteScript("CMD_S_DLL","GetUplinkObj",Obj,"OBJECT_VOLUME")
  If vol Is Nothing Then Exit Function
  GetVolumeCode= vol.Attributes("ATTR_VOLUME_CODE")
End Function

Extern GetSectionNum [Alias ("Раздел №"), HelpString ("Раздел №")]
Function GetSectionNum(Obj) 
  GetSectionNum = vbNullString
  Set vol = ThisApplication.ExecuteScript("CMD_S_DLL","GetUplinkObj",Obj,"OBJECT_PROJECT_SECTION")
  If vol Is Nothing Then Exit Function
  If vol.Attributes.Has("ATTR_SECTION_NUM") Then
  GetSectionNum = vol.Attributes("ATTR_SECTION_NUM")
  End If
End Function

Extern GetSectionName [Alias ("Наименование раздела"), HelpString ("Наименование раздела")]
Function GetSectionName(Obj) 
  GetSectionName = vbNullString
  Set src = ThisApplication.ExecuteScript("CMD_S_DLL","GetUplinkObj",Obj,"OBJECT_PROJECT_SECTION")
  If src Is Nothing Then Exit Function
  GetSectionName= src.Attributes("ATTR_NAME").Value
End Function

Extern GetSubSectionName [Alias ("Наименование подраздела"), HelpString ("Наименование подраздела")]
Function GetSubSectionName(Obj) 
  GetSubSectionName = vbNullString
  Set src = ThisApplication.ExecuteScript("CMD_S_DLL","GetUplinkObj",Obj,"OBJECT_PROJECT_SECTION_SUBSECTION")
  If src Is Nothing Then Exit Function
  GetSubSectionName= src.Attributes("ATTR_NAME").Value
End Function

Extern GetVolumePartNum [Alias ("Наименование части"), HelpString ("Наименование части")]
Function GetVolumePartNum(Obj) 
  GetVolumePartNum = vbNullString
  Set src = Obj.Parent
  If src Is Nothing Then Exit Function
  If src.Attributes.Has("ATTR_VOLUME_PART_NUM") Then
    If src.Attributes("ATTR_VOLUME_PART_NUM").Empty = False Then
      GetVolumePartNum = " Часть " & src.Attributes("ATTR_VOLUME_PART_NUM")
      If src.Attributes.Has("ATTR_VOLUME_PART_NAME") Then
        If src.Attributes("ATTR_VOLUME_PART_NAME").Empty = False Then
          GetVolumePartNum = GetVolumePartNum & chr(13) & src.Attributes("ATTR_VOLUME_PART_NAME")
        End If
      End If
    End If
  End If
  GetVolumePartNum = Trim(GetVolumePartNum)
End Function

'Extern GetVolumePartName [Alias ("Наименование части"), HelpString ("Наименование части")]
'Function GetVolumePartName(Obj) 
'  GetVolumePartName = vbNullString
'  If Obj.Attributes("ATTR_VOLUME_PART_NAME").Empty = False Then
'    GetVolumePartName = vol.Attributes("ATTR_VOLUME_PART_NAME")
'  End If
'End Function

Extern GetVolumeBookNum [Alias ("Наименование Книги"), HelpString ("Наименование Книги")]
Function GetVolumeBookNum(Obj) 
  GetVolumeBookNum = vbNullString
  Set src = Obj.Parent
  If src Is Nothing Then Exit Function
  If src.Attributes.Has("ATTR_BOOK_NUM") Then
    If src.Attributes("ATTR_BOOK_NUM").Empty = False Then
      GetVolumeBookNum = " Книга " & src.Attributes("ATTR_BOOK_NUM")
      If src.Attributes.Has("ATTR_BOOK_NAME") Then
        If src.Attributes("ATTR_BOOK_NAME").Empty = False Then
          GetVolumeBookNum = GetVolumeBookNum & chr(13) & src.Attributes("ATTR_BOOK_NAME")
        End If
      End If
    End If
  End If
  GetVolumeBookNum = Trim(GetVolumeBookNum)
End Function

'Extern GetVolumeBookName [Alias ("Наименование Книги"), HelpString ("Наименование Книги")]
'Function GetVolumeBookName(Obj) 
'  GetVolumeBookName = vbNullString
'  If Obj.Attributes("ATTR_BOOK_NAME").Empty = False Then
'    GetVolumeBookName = vol.Attributes("ATTR_BOOK_NAME")
'  End If
'End Function

Extern GetSignerFIO [Alias ("Подписант. ФИО"), HelpString ("Подписант ФИО")]
Function GetSignerFIO(Obj) 
  GetSignerFIO = " "
  set src = Obj.Parent
  If src Is Nothing Then Exit Function
  If src.Attributes.Has("ATTR_SIGNER") = False Then Exit Function
  Set user = src.Attributes("ATTR_SIGNER").User
  If user Is Nothing Then Exit Function
  GetSignerFIO= user.Attributes("ATTR_KD_FIO")
End Function
