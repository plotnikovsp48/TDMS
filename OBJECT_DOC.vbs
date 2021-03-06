USE "CMD_FILES_LIBRARY"

Sub Object_BeforeErase(Obj, Cancel)
  Dim result1, result2
  result1 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckContent", Obj)
  result2 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckReferencedBy", Obj) 
  Cancel = result1 Or result2
  
  Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", Obj)
End Sub

Sub File_Erased(File, Object)
  thisScript.SysAdminModeOn
   pdfFileName = ThisApplication.ExecuteScript("OBJECT_KD_BASE_DOC","getFileName",File.FileName) & "###.pdf"
   if object.Files.Has(pdfFileName) then 
      on error resume next
      object.Files(pdfFileName).Erase
      if err.Number<> 0 then err.Clear
      on error goto 0
    end if
End Sub

Sub Object_Modified(Obj)
  Call ThisApplication.ExecuteScript ("CMD_DLL_ORDERS", "SendOrderToResponsible",Obj)
  ThisApplication.ExecuteScript "CMD_DLL","SetIcon",Obj
End Sub

Sub Object_CheckedIn(Obj)
 'Запись в журнал сессиий - Загружен
  ThisApplication.ExecuteScript "CMD_DLL", "TsessionRowCreate", Obj, True
End Sub

Sub Object_BeforeCheckOut(Obj, Cancel)
  'Запись в журнал сессиий - Выгружен
  ThisApplication.ExecuteScript "CMD_DLL", "TsessionRowCreate", Obj, False
End Sub

Sub File_CheckedIn(File, Object)
  Call FileChkInProcessing(File, Object)
'  dim FileDef
''  if IsExistsGlobalVarrible("FileTpRename") then call ReNameFiles(file,Object)
'  FileDef =  File.FileDefName
'  'call AddToFileList(file,object)   ' Пока нет такой таблицы
'    select case FileDef
'      case "FILE_KD_SCAN_DOC","FILE_E-THE_ORIGINAL","FILE_DOC_PDF" Object.Files.Main = File 'если скан документ
'      case "FILE_ANY","FILE_KD_ANNEX","FILE_AUTOCAD_DWG","FILE_DOC_DOC","FILE_DOC_XLS","FILE_T_TEMPLATE"
'        call ThisApplication.ExecuteScript("OBJECT_KD_BASE_DOC","delElScan",file,Object)' call CreatePDFFromFile(File.WorkFileName, Object, nothing) ' .WorkFileName .FileName
'        call ThisApplication.ExecuteScript("CMD_FILES_LIBRARY","deldwgsupportfiles",file,Object)
'        
'    end select  
End Sub

Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
'ThisApplication.AddNotify "OBJECT_DOC - Object_PropertiesDlgBeforeClose"
  If OkBtnPressed = False Then Exit Sub
  Obj.Permissions = SysAdminPermissions
  '  If Obj.Files.Count = 0 Then
'    If Obj.StatusName = "STATUS_DOC_IS_ADDED" Then
'      Cancel = True
'      ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbInformation, 117        
'    End If
'  End If
  If Obj.ObjectDefName = "OBJECT_DRAWING" Then
    check1 = ThisApplication.ExecuteScript("CMD_S_NUMBERING","CheckObjExist",_
            Obj,"ATTR_DOC_CODE",Obj.Attributes("ATTR_DOC_CODE").Value,1226)
  ElseIf Obj.ObjectDefName = "OBJECT_DOC_DEV" Then
    check1 = ThisApplication.ExecuteScript("CMD_S_NUMBERING","CheckObjExist",_
            Obj,"ATTR_DOC_CODE",Obj.Attributes("ATTR_DOC_CODE").Value,1226)
  Else
    check1 = False
  End If
'  Cancel = (Not CheckBeforeClose(Obj)) or check1
  Cancel = (Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckBeforeClose",Obj)) or check1
  if obj.permissions.view <> 0 then
    if thisObject.Permissions.LockOwner then 
      if ThisObject.Permissions.Locked = true Then 
        ThisObject.Unlock ThisObject.Permissions.LockType
      end if
    end if
  end if
End Sub

Sub File_Added(File, Object)
  Set Obj = Object
  Obj.Permissions = SysAdminPermissions
  ' При добавлении файла переводим в состояние Документ в разработке
  If Object.StatusName = "STATUS_DOC_IS_ADDED" Then
  'Изменение статуса
    StatusName = "STATUS_DOCUMENT_CREATED"
    ThisApplication.ExecuteScript "CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName
  End If
End Sub

Sub Object_PropertiesDlgInit(Dialog, Obj, Forms)
  Call ThisApplication.ExecuteScript("CMD_DLL","ShowDefaultForm",Dialog, Obj, Forms)
  ' Закрываем информационные поручения 
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_CORR_REZOL_INF")
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_STAT_MAIN")
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_COR_DEL_MAIN")
  ' отмечаем все поручения по документу прочитанными
  if obj.StatusName <> "STATUS_DOC_IS_ADDED" then _
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","Set_OrdersReaded",Obj
  
  If Obj.Attributes.Has("ATTR_NEED_AGREE") Then
    Call ShowHideAgreeForm(Dialog, Obj, "FORM_KD_DOC_AGREE", Obj.Attributes("ATTR_NEED_AGREE"))
  End If
    
'  'Определение активной формы
'  If Obj.Dictionary.Exists("FormActive") Then
'    FormName = Obj.Dictionary.Item("FormActive")
'    If Dialog.InputForms.Has(FormName) Then
'      Dialog.ActiveForm = Dialog.InputForms(FormName)
'    End If
'    Obj.Dictionary.Remove("FormActive")
'  End If
End Sub


Sub ShowHideAgreeForm(Dialog, Obj, FormName, flag)
  If Dialog.InputForms.Has(FormName) Then
    If flag = False Then
      Dialog.InputForms.Remove Dialog.InputForms(FormName)
    Else
      Dialog.InputForms.Add Dialog.InputForms(FormName)
    End If
  End If
End Sub


function Check_FinishStatus(stName)
  Check_FinishStatus = (stName = "STATUS_DOCUMENT_INVALIDATED")
end function

'=============================================
function GetTypeFileArr(docObj)
  Set CU = thisApplication.CurrentUser
  
    isAuth = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsAuthor",docObj,CU)
    isDevl = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsDeveloper",docObj,CU)
    isChck = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsChecker",docObj,CU)
    isInit = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsInitiator",docObj,CU)
    isAprv = ThisApplication.ExecuteScript("CMD_DLL_ROLES","IsAprover",docObj,CU)
    isNkr = ThisApplication.ExecuteScript("CMD_DLL_ROLES","isNCUser",docObj,CU)
    isCanAppr = ThisApplication.ExecuteScript("CMD_KD_USER_PERMISSIONS","IsCanAprove",CU,docObj)

  st = docObj.StatusName
  select case st
    case "STATUS_DOC_IS_ADDED","STATUS_DOCUMENT_CREATED"
      if isAuth or isDevl  then _
          GetTypeFileArr = array("Документ","Таблица","Файл","Скан документа")  
    case "STATUS_DOCUMENT_CHECK"
      if isChck then _
          GetTypeFileArr = array("Файл","Скан документа")  
    case "STATUS_DOCUMENT_DEVELOPED"
      if isInit then _
          GetTypeFileArr = array("Файл","Скан документа")  
    case "STATUS_DOCUMENT_IS_TAKEN_NK"
      if isNkr then _
          GetTypeFileArr = array("Файл","Скан документа")  
    case "STATUS_KD_AGREEMENT"
      if isSin or isCanAppr then _
          GetTypeFileArr = array("Файл","Скан документа")  
    case "STATUS_DOCUMENT_AGREED"
      if isAuth or isDevl then _
          GetTypeFileArr = array("Файл","Скан документа")        
    case "STATUS_DOCUMENT_IS_APPROVING"
      if isAprv then _
          GetTypeFileArr = array("Файл","Скан документа")  
    case "STATUS_DOCUMENT_FIXED"
'      if ThisApplication.ExecuteScript("FORM_S_TASK","userIsAcceptor",docObj,CU) then _
'          GetTypeFileArr = array("Файл","Скан документа")  
  end select
end function


function CanIssueOrder(DocObj)
'  CanIssueOrder = false
'  docStat = DocObj.StatusName
'  str = ";STATUS_DOCUMENT_CHECK;STATUS_DOCUMENT_IS_CHECKED_BY_NK;STATUS_DOCUMENT_CREATED;STATUS_DOCUMENT_FIXED;"
'  if Instr(";" & str & ";", ";" & docStat & ";") > 0 then _
      CanIssueOrder = true
end function
