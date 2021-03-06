' Команда - Передать Документ на проверку
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

USE "CMD_PROJECT_DOCS_LIBRARY"

Call Run(ThisObject)

Function Run(Obj)
  Run = False
  ThisScript.SysAdminModeOn
  Set User = Nothing
  
  'Проверка объекта
  If Obj.Files.count <= 0 Then
    ThisApplication.ExecuteScript "CMD_MESSAGE", "ShowWarning", vbExclamation, 1004, Obj.ObjectDef.Description
    Exit Function
  End If
  Set Row = GetRowCheckList(Obj,"check",User,Nothing,Nothing)
  NeedToSetChecker = False
  If Row is Nothing Then
    NeedToSetChecker = True
  Else
    Set User = Row.Attributes("ATTR_USER").User
    If User Is Nothing Then NeedToSetChecker = True
  End If
  
  If NeedToSetChecker Then
    Msgbox "Укажите проверяющего",vbExclamation
    Exit Function
  End If
  
  If Obj.Status is Nothing Then Exit Function
  
  'Подтверждение
  ans = ThisApplication.ExecuteScript("CMD_MESSAGE", "ShowWarning",vbQuestion+vbYesNo, 1267, Obj.ObjectDef.Description, Obj.Description)    
  If ans = vbNo Then Exit Function
  
  
    
  'Изменение статуса
  StatusName = "STATUS_DOCUMENT_CHECK"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  Call ThisApplication.ExecuteScript("CMD_DLL","SetAttr_F",Obj,"ATTR_DEVELOP_DATE",Obj.StatusModifyTime,True)
  
  ' Закрываем поручение
  Call ThisApplication.ExecuteScript("CMD_DLL_ORDERS","CloseOrderByResol",Obj,"NODE_KD_RETUN_USER")

  'Создание роли
  RoleName = "ROLE_DOC_CHECKER"
  'Set Row = Obj.Attributes("ATTR_CHECK_LIST").Rows(0)
  Set User = Row.Attributes("ATTR_USER").User
  Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,RoleName,User)
  Call ThisApplication.ExecuteScript("CMD_DLL","SetRole",Obj,"ROLE_INITIATOR",User)
  
  'Создание поручения
  Set CU = ThisApplication.CurrentUser
  resol = "NODE_KD_CHECK"
  ObjType = "OBJECT_KD_ORDER_SYS"
  txt = "документ """ & Obj.Description & """"
  planDate = DateAdd ("d", 1, Date) 'Date + 1
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,User,CU,resol,txt,PlanDate
  
  'Оповещение
  ThisApplication.ExecuteScript "CMD_MESSAGE","SendMessage",1118,User,Obj,Nothing,Obj.Description,CU.Description,Date
  Run = True
End Function

