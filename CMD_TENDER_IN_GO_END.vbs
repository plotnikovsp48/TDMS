' Команда - Закрыть Закупку (Внутренняя закупка)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject, form)

Sub Main(Obj, form)
 
  ThisScript.SysAdminModeOn
  
  Set Objects = Obj.Objects
  'Проверка состава
  Check = True
  For Each Child in Objects
    If Child.ObjectDefName = "OBJECT_PURCHASE_LOT" or Child.ObjectDefName = "OBJECT_PURCHASE_DOC" Then
      If Child.StatusName <> "STATUS_DOC_IS_END" and Child.StatusName <> "STATUS_S_INVALIDATED" and _
      Child.StatusName <> "STATUS_LOT_IS_END" Then
        Check = False
        Exit For
      End If
    End If
  Next
  If Check = False Then
    'Подтверждение
    result = ThisApplication.ExecuteScript("CMD_MESSAGE","ShowWarning",vbQuestion+VbYesNo,6003,Obj.Description)
    If result = vbNo Then Exit Sub
  End If
   'Подтверждение
   If Check = True Then
  Answer = MsgBox("Завершить закупку?", vbQuestion + vbYesNo,"")
  if Answer <> vbYes then exit sub
   End If
  ThisApplication.Utility.WaitCursor = True
  
  'Смена статусов состава
  For Each Child in Objects
    If Child.ObjectDefName = "OBJECT_PURCHASE_LOT" and Child.StatusName <> "STATUS_LOT_IS_END" and _
    Child.StatusName <> "STATUS_S_INVALIDATED" Then
      StatusName = "STATUS_LOT_IS_END"
      RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Child,Child.Status,Child,StatusName)
      If RetVal = -1 Then
        Child.Status = ThisApplication.Statuses(StatusName)
      End If
    ElseIf Child.ObjectDefName = "OBJECT_PURCHASE_DOC" and Child.StatusName <> "STATUS_DOC_IS_END" and _
    Child.StatusName <> "STATUS_S_INVALIDATED" Then
      StatusName = "STATUS_DOC_IS_END"
      RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Child,Child.Status,Child,StatusName)
      If RetVal = -1 Then
        Child.Status = ThisApplication.Statuses(StatusName)
      End If
    End If
  Next
  

  
  'Создание поручений
  str = ""
  Set Doc = Nothing
  AttrName = "ATTR_TENDER_PROTOCOL"
  If Obj.Attributes.Has(AttrName) Then
    If Obj.Attributes(AttrName).Empty = False Then
      If not Obj.Attributes(AttrName).Object is Nothing Then Set Doc = Obj.Attributes(AttrName).Object
    End If
  End If
  Set CU = ThisApplication.CurrentUser
'  Set u0 = ThisApplication.ExecuteScript("CMD_DLL","OrgUserGet","Отдел по договорной работе и закупочным процедурам")
 AttrName = "ATTR_TENDER_ACC_CHIF"
'  If Obj.Attributes.Has(AttrName) Then
'   If Obj.Attributes(AttrName).Empty = False Then
'    Set User = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,AttrName)
'    If not User is Nothing Then 
'    Set u0 = User
'   End If
'  End If    
' End If    
'  Set u0 = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,"ATTR_TENDER_PEO_CHIF")

 Set Dept = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetDeptByID","ID_TENDER_INSIDE_DISTR_STRU_OBJ")
  If not Dept is Nothing Then
    Set User = ThisApplication.ExecuteScript("CMD_STRU_OBJ_DLL", "GetChiefByDept",Dept)
    If not User is Nothing Then 
    Set u0 = User
    End If 
  End If 
  
  Set u1 = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,"ATTR_TENDER_ACC_CHIF")
  Set u2 = ThisApplication.ExecuteScript("CMD_DLL","GetUserFromAttr",Obj,"ATTR_TENDER_GROUP_CHIF")
  
  resol = "NODE_CORR_REZOL_INF"
  ObjType = "OBJECT_KD_ORDER_NOTICE"
  txt = "Прошу ознакомиться с результатами проведенной закупки"
  Set Roles = Obj.RolesByDef("ROLE_TENDER_INICIATOR")
  If not Doc is Nothing Then
  
    'Руководитель отдела по договорной работе и закупочным процедурам
    If not u0 is Nothing Then
      If u0.SysName <> CU.SysName Then
        ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Doc,ObjType,u0,CU,resol,txt,""
        If str = "" Then
          str = u0.Description
        Else
          str = str & ", " & u0.Description
        End If
      End If
    End If
    
    'Курирующий зам (бывший Главный бухгалтер)
    If not u1 is Nothing Then
      If u1.SysName <> CU.SysName and u1.SysName <> u0.SysName Then
        ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Doc,ObjType,u1,CU,resol,txt,""
        If str = "" Then
          str = u1.Description
        Else
          str = str & ", " & u1.Description
        End If
      End If
    End If
    
     'Руководитель группы
    If not u2 is Nothing Then
      If u2.SysName <> CU.SysName and u2.SysName <> u0.SysName and u2.SysName <> u1.SysName Then
        ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Doc,ObjType,u2,CU,resol,txt,""
        If str = "" Then
          str = u2.Description
        Else
          str = str & ", " & u2.Description
        End If
      End If
    End If
    
    'Роль Инициатор закупки
    For Each Role in Roles
      If not Role.User is Nothing Then
        Set u = Role.User
        If u.SysName <> CU.SysName Then
          ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Doc,ObjType,u,CU,resol,txt,""
          If str = "" Then
            str = u.Description
          Else
            str = str & ", " & u.Description
          End If
        End If
      End If
    Next
  End If
  
  If str <> "" Then
    Msgbox "Закупка завершена." & chr(10) & "Пользователям " & str &_
    " выдано поручение на ознакомление с результатами закупки",vbInformation
  Else
    Msgbox "Закупка завершена",vbInformation
  End If
  
    'Маршрут
  StatusName = "STATUS_TENDER_END"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
 If IsEmpty(Form) = false then
 Form.close
 End If
  ThisApplication.Utility.WaitCursor = False
  ThisScript.SysAdminModeOff
End Sub
