' Тип объекта - Накладная
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.
USE "CMD_DLL_ROLES"

Sub Object_BeforeCreate(Obj, Parent, Cancel)
  sysID = ThisApplication.ExecuteScript ("CMD_KD_REGNO_KIB","Get_Sys_Id",Obj)
  if sysID = 0 then 
      Cancel = true
      exit sub
  else  
    Obj.Attributes("ATTR_KD_IDNUMBER").value = sysID
  end if
  
  'Заполняем атрибуты
  Set Dict = ThisApplication.Dictionary("INVOICE_CREATE")
  If Dict.Exists("PROJECT") Then 
    Set proj = ThisApplication.GetObjectByGUID(Dict.Item("PROJECT"))
    Dict.Remove("PROJECT")
  End If
  
' Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Parent,Parent.Status,Obj,Obj.ObjectDef.InitialStatus)  
  
  Call SetAttrs(Obj,proj)
  'Назначение стандартных ролей
  Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,"ROLE_VIEW",ThisApplication.Groups("ALL_USERS"))
  Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,"ROLE_OPERATOR_EA",ThisApplication.Groups("GROUP_COMPL"))
  Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,"ROLE_INVOICE_CREATE",ThisApplication.Groups("GROUP_COMPL"))
  Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,"ROLE_INVOICE_FORTHEPICKING",ThisApplication.Groups("GROUP_COMPL"))
End Sub

Sub Object_Created(Obj, Parent)
  'Удаляем накладную из состава родителя
  'If not Parent is Nothing Then
  '  If Obj.Attributes("ATTR_PROJECT").Empty = False Then
  '    Guid = Obj.GUID
  '    ThisApplication.Dictionary("EraseObjects").Add Guid, Guid
  '    Parent.Content.Remove Obj
  '  End If
  'End If
  Call RolesCreate(Obj)
End Sub



'Процедура создания ролей
Sub RolesCreate(Obj)
  'ГИП и Куратор договора
  Set Project = Nothing
  If Obj.Attributes("ATTR_PROJECT").Empty = False Then
    If not Obj.Attributes("ATTR_PROJECT").Object is Nothing Then
      Set Project = Obj.Attributes("ATTR_PROJECT").Object
      'ГИПа берем из проекта
      RoleName = "ROLE_GIP"
      Set User = RoleSeek(Project,RoleName)
      Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,User)
      'Куратора договора берем из договора проекта
      If Project.Attributes("ATTR_CONTRACT").Empty = False Then
        If not Project.Attributes("ATTR_CONTRACT").Object is Nothing Then
          Set Contract = Project.Attributes("ATTR_CONTRACT").Object
          RoleName = "ROLE_CONTRACT_RESPONSIBLE"
          Set User = RoleSeek(Contract,RoleName)
          Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,User)
        End If
      End If
    End If
  End If
End Sub

'Функция поиска роли
'Возвращает пользователя или группу роли
Function RoleSeek(Obj,RoleName)
  Set RoleSeek = Nothing
  For Each Role in Obj.Roles
    If Role.RoleDefName = RoleName Then
      If not Role.User is Nothing Then
        Set RoleSeek = Role.User
      Else
        Set RoleSeek = Role.Group
      End If
    End If
  Next
End Function


'Автоматическое заполнение атрибутов
Sub SetAttrs(Obj,oParent)
  If isEmpty(oParent) = True Then Exit Sub
  'Ссылка на проект
  
  Set Project = Nothing
  
    If not oParent is Nothing Then
      If oParent.Attributes.Has("ATTR_PROJECT") Then
        If oParent.Attributes("ATTR_PROJECT").Empty = False Then
          If not oParent.Attributes("ATTR_PROJECT").Object is Nothing Then
            Set Project = oParent.Attributes("ATTR_PROJECT").Object
          End If
        End If
      ElseIf oParent.ObjectDefName = "OBJECT_PROJECT" Then
        Set Project = oParent
      End If
    End If
  If not Project is Nothing Then
    Obj.Attributes("ATTR_PROJECT").Object = Project
  End If
  
  'Получатель
  Set Recipient = Nothing
  If not Project is Nothing Then
    If Project.Attributes.Has("ATTR_CUSTOMER_CLS") Then
      If Project.Attributes("ATTR_CUSTOMER_CLS").Empty = False Then
        If not Project.Attributes("ATTR_CUSTOMER_CLS").Object is Nothing Then
          Set Recipient = Project.Attributes("ATTR_CUSTOMER_CLS").Object
          Obj.Attributes("ATTR_INVOICE_RECIPIENT").Object = Recipient
        End If
      End If
    End If
  End If
  
  'Адрес отправки
  If not Recipient is Nothing Then
    If Recipient.Attributes.Has("ATTR_CORDENT_ADDRES") Then
      If Recipient.Attributes("ATTR_CORDENT_ADDRES").Empty = False Then
        Obj.Attributes("ATTR_INVOICE_ADDRESS").Value = Recipient.Attributes("ATTR_CORDENT_ADDRES").Value
      End If
    End If
  End If
  
  ' Проверил
  Set checker = oParent.Attributes("ATTR_PROJECT_GIP").user
  If Not checker Is Nothing Then
    Obj.Attributes("ATTR_CHECKER") = checker
  End If
  
  ' Подписант
  Set signer = oParent.Attributes("ATTR_CURATOR").user
  If Not signer Is Nothing Then
    Obj.Attributes("ATTR_SIGNER") = signer
  End If
  
  'Тип электронной версии
  Obj.Attributes("ATTR_INVOICE_EVERTYPE").Classifier = _
    ThisApplication.Classifiers("NODE_EVERTYPE").Classifiers.Find("1")
  
  'Тип носителя
  Obj.Attributes("ATTR_INVOICE_DISCTYPE").Classifier = _
    ThisApplication.Classifiers("NODE_DISCTYPE").Classifiers.Find("DVD-R 4.7 Гб")
    
  'Электронная версия
  Obj.Attributes("ATTR_INVOICE_FILES").Value = True
End Sub

Sub Object_PropertiesDlgInit(Dialog, Obj, Forms)
  ' Закрываем информационные поручения 
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_CORR_REZOL_INF")
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_STAT_MAIN")
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_DEL_MAIN")
  
  ' отмечаем все поручения по документу прочитанными
  if obj.StatusName <> "STATUS_INVOICE_DRAFT" then _
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","Set_OrdersReaded",Obj
End Sub

Sub File_CheckedIn(File, Object)
  dim FileDef
'  if IsExistsGlobalVarrible("FileTpRename") then call ReNameFiles(file,Object)
  FileDef =  File.FileDefName
  'call AddToFileList(file,object)   ' Пока нет такой таблицы
    select case FileDef
      case "FILE_KD_SCAN_DOC","FILE_E-THE_ORIGINAL","FILE_DOC_PDF" Object.Files.Main = File 'если скан документ
      case "FILE_KD_ANNEX","FILE_TRANSFER_DOCUMENT"
        call ThisApplication.ExecuteScript("OBJECT_KD_BASE_DOC","delElScan",file,Object)' call CreatePDFFromFile(File.WorkFileName, Object, nothing) ' .WorkFileName .FileName
    end select  
End Sub



Sub File_Erased(File, Object)
  thisScript.SysAdminModeOn
  Call ThisApplication.ExecuteScript("OBJECT_DOC","File_Erased",File, Object)
  
'   pdfFileName = ThisApplication.ExecuteScript("OBJECT_KD_BASE_DOC","getFileName",File.FileName) & ".pdf"
'   if object.Files.Has(pdfFileName) then 
'      on error resume next
'      object.Files(pdfFileName).Erase
'      if err.Number<> 0 then err.Clear
'      on error goto 0
'    end if
End Sub

Sub ContextMenu_BeforeShow(Commands, Obj, Cancel)
  
  Dim cmd, remove
  Set cmd = ThisApplication.Commands("CMD_INVOICE_TO_FORM_STATEMENT_EVKD")
  If Commands.Has(cmd) Then
    remove = Not ThisApplication.ExecuteScript( _
      "CMD_INVOICE_TO_FORM_STATEMENT_EVKD", "EnableCommand", Obj)
    If remove Then Commands.Remove cmd
  End If
End Sub

Sub Object_SignExternalPropertiesDlg(Object, Sign)
' отмечаем все поручения по документу прочитанными
  if obj.StatusName <> "STATUS_INVOICE_DRAFT" then _
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","Set_OrdersReaded",Obj
End Sub

Sub Object_BeforeModify(Obj, Cancel)
  Call SetDescription(Obj)
End Sub


function Check_FinishStatus(stName)
  Check_FinishStatus = (stName = "STATUS_INVOICE_INVALIDATED") or _
                        (stName = "STATUS_INVOICE_CLOSED")
end function

'=============================================
function GetTypeFileArr(docObj)
  Set CU = ThisApplication.CurrentUser
  isAuth = IsAuthor(docObj,CU)
  isSign = IsSigner(docObj,CU)
  isChck = IsChecker(docObj,CU)
  isInit  = IsInitiator(docObj,CU)

  st = docObj.StatusName
  select case st
    case "STATUS_INVOICE_DRAFT","STATUS_INVOICE_FORTHEPICKING","STATUS_INVOICE_EDIT"
      if isAuth  then _
          GetTypeFileArr = array("Передаточный документ","Скан документа")  
    case "STATUS_INVOICE_ONCHECK"
      if isChck then _
          GetTypeFileArr = array("Скан документа")  
    case "STATUS_INVOICE_ONSIGN"
      if isSign or isAuth then _
          GetTypeFileArr = array("Скан документа")  
    case "STATUS_INVOICE_SIGNED"
      if isSign or isAuth then _
          GetTypeFileArr = array("Скан документа")  
    case "STATUS_INVOICE_SENDED"
      if isAuth then _
          GetTypeFileArr = array("Скан документа")  
    case "STATUS_INVOICE_CLOSED"
      if isAuth then _
          GetTypeFileArr = array("Скан документа")
    case "STATUS_INVOICE_INVALIDATED"
      if isSign or isAuth then _
          GetTypeFileArr = array("Скан документа")      
  end select
end function


Extern GetStageList [Alias ("Этапы"), HelpString ("Этапы")]
Function GetStageList(Obj) 
  GetStageList = " "
  If Obj.Attributes.Has("ATTR_INVOICE_TDOCS") = False Then Exit Function
  Set q = ThisApplication.Queries("QUERY_INVOISE_STAGES")
  q.Parameter("PARAM0") = Obj.Handle
  Set sh = q.Sheet
  RCount = sh.RowsCount
    For i=0 To RCount-1
      code = sh(i,"Номер этапа")
      If i = 0 Then
        List = code
      Else
        List = List & "," & code
      End If
  Next
  If List <> "" Then
    GetStageList = List
  End If
End Function

Extern GetProjStageList [Alias ("Стадии проектирования"), HelpString ("Стадии проектирования")]
Function GetProjStageList(Obj) 
  GetProjStageList = " "
  If Obj.Attributes.Has("ATTR_INVOICE_TDOCS") = False Then Exit Function
  Set q = ThisApplication.Queries("QUERY_INVOISE_PROJECT_STAGES")
  q.Parameter("PARAM0") = Obj.Handle
  Set sh = q.Sheet
  RCount = sh.RowsCount
    For i=0 To RCount-1
      code = sh(i,"Стадия проектирования")
      If i = 0 Then
        List = code
      Else
        List = List & "," & code
      End If
  Next
  GetProjStageList = List
End Function

Extern DocTypeOption [Alias ("Вариант документации"), HelpString ("Вариант документации")]
Function DocTypeOption(Obj) 
  DocTypeOption = " "
  txt = vbNullString
  If Obj.Attributes.Has("ATTR_INVOICE_PAPER") = True Then
    If Obj.Attributes("ATTR_INVOICE_PAPER") = True Then
      txt = "в бумажном виде"
    End If
  End If
  If Obj.Attributes.Has("ATTR_INVOICE_FILES") = True Then
    If Obj.Attributes("ATTR_INVOICE_FILES") = True Then
      If txt = vbNullString Then
        txt = "в электронном виде"
      Else
        txt = txt & ", " & "в электронном виде"
      End If
    End If
  End If
  DocTypeOption = txt
End Function

Extern DiscType [Alias ("Тип носителя"), HelpString ("Тип носителя")]
Function DiscType(Obj) 
  DiscType = " "
  txt = vbNullString
  If Obj.Attributes.Has("ATTR_INVOICE_DISCTYPE") = True Then
    If Obj.Attributes("ATTR_INVOICE_DISCTYPE").Empty = False Then
      txt = Obj.Attributes("ATTR_INVOICE_DISCTYPE").Value
    End If
  End If
  If txt <> vbNullString Then
    txt = "на " & txt & " носителе"
  End If
  DiscType = txt
End Function

Extern GetPEOChief [Alias ("Руководитель планового подразделения"), HelpString ("Руководитель планового подразделения")]
Function GetPEOChief(Obj) 
  GetPEOChief = " "
  Set oDept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL","GetDeptByID","ID_PLANING_DEPT")
  If oDept Is Nothing Then Exit Function
  
  If oDept.Attributes.Has("ATTR_KD_CHIEF") = True Then
    If oDept.Attributes("ATTR_KD_CHIEF").Empty = False Then
      If Not oDept.Attributes("ATTR_KD_CHIEF").User Is Nothing Then
        Set User = oDept.Attributes("ATTR_KD_CHIEF").User
        chief = User.Description
      End If
    End If
  End If
  GetPEOChief = chief
End Function

Extern GetDeptChief [Alias ("Руководитель подразделения выпускающего документацию"), HelpString ("Руководитель подразделения выпускающего документацию")]
Function GetDeptChief(Obj) 
  GetDeptChief = " "
  Set auth = Obj.Attributes("ATTR_AUTOR").User
  If auth Is Nothing Then Exit Function
  set chief = thisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetChiefForUserByGroup", auth, "GROUP_LEAD_DEPT")
  If chief Is Nothing Then Exit Function
  GetDeptChief = chief.Description
End Function

