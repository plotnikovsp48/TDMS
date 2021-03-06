' Команда - Создать старый договор
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © ЗАО «СИСОФТ», 2017 г.

USE "CMD_DLL_CONTRACTS"

Call CreateOldContract(Nothing)

Function CreateOldContract(Obj)
  Set CreateOldContract = nothing
  Set CU = ThisApplication.CurrentUser
  ThisScript.SysAdminModeOn
      
  Set clsRoot = ThisApplication.Classifiers("NODE_CONTRACT_CLASS")
  Cnt = clsRoot.Classifiers.Count
  Dim ContractClassArray()
  ReDim ContractClassArray(Cnt)
  i = 0
  For Each chObjType in clsRoot.Classifiers
    ContractClassArray(i)= chObjType.Description
    i = i + 1
  Next
  
  Set SelDlg = ThisApplication.Dialogs.SelectDlg
  SelDlg.SelectFrom = ContractClassArray
  SelDlg.Caption = "Выбор класса договора"
  SelDlg.Prompt = "Выберите класс договора:"
  
  RetVal = SelDlg.Show
    
  'Если пользователь отменил диалог или ничего не выбрал, закончить работу.
  If ( (RetVal <> TRUE) or (UBound(SelDlg.Objects)<0) ) Then  
    Exit function
  End if
   
  SelectedArray = SelDlg.Objects  
  If SelectedArray(0) = "" Then Exit Function
  
  Set cls = clsRoot.Classifiers.Find(SelectedArray(0))
  Set NewObj =  CreateOldContractByClass(Obj, cls) 
  
  'Маршрут
  StatusName = "STATUS_CONTRACT_COMPLETION"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",NewObj,NewObj.Status,NewObj,StatusName)
  
  'Создание поручения
  Str = ""
  CurSysName = ""
  'Куратор договора
  AttrName = "ATTR_CURATOR"
  If NewObj.Attributes.Has(AttrName) Then
    If not NewObj.Attributes(AttrName).User is Nothing Then
      Str = NewObj.Attributes(AttrName).User.SysName
      CurSysName = Str
    End If
  End If
  'Управление актами
  For Each User in ThisApplication.Groups("GROUP_CCR").Users
    Val = User.SysName
    If Val <> CurSysName Then
      If Str <> "" Then
        Str = Str & "," & Val
      Else
        Str = Val
      End If
    End If
  Next
  Arr = Split(Str,",")
  
  resol = "NODE_KD_NOTICE"
  ObjType = "OBJECT_KD_ORDER_NOTICE"
  txt = "Прошу ознакомиться"
  PlanDate = Data
  For i = 0 to Ubound(Arr)
    uSysName = Arr(i)
    Set User = ThisApplication.Users(uSysName)
    If uSysName <> CU.SysName Then
      ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",NewObj,ObjType,User,CU,resol,txt,PlanDate
    End If
  Next
  
  Set CreateOldContract =  NewObj
End Function


Function CreateOldContractByClass(objType, cls)
  Set CreateOldContractByClass = Nothing
  Set ObjRoots = GetContractRoot()
  Set NewObj = Nothing
  Set CU = ThisApplication.CurrentUser

  If ObjRoots Is Nothing Then 
    Msgbox "Не могу найти папку Договоры. Операция завершена!", vbCritical, "Объект не был создан"
    Exit Function
  End If
  
  'Создаем объект
  ObjRoots.Permissions = SysAdminPermissions
  On error Resume Next
  Set NewObj = ObjRoots.Objects.Create("OBJECT_CONTRACT")
  If NewObj Is Nothing or err.Number <> 0 Then
    err.clear
    on error GoTo 0
    Exit Function
  End If
  
  NewObj.Attributes("ATTR_CONTRACT_CLASS").Classifier = cls
  NewObj.Attributes("ATTR_OLD_CONTRACT").Value = True
  NewObj.Attributes("ATTR_IS_SIGNED_BY_CORRESPONDENT").Value = True
  NewObj.Attributes("ATTR_REGISTERED").Value = True
  NewObj.Attributes("ATTR_REG").User = CU
  NewObj.Status = ThisApplication.Statuses("STATUS_CONRACT_DRAFT_OLD")
  
  Call FillCompany(NewObj)
  Call SetBaseDocInfo(objType,NewObj)
  Set Dlg = ThisApplication.Dialogs.EditObjectDlg
  Dlg.Object = NewObj
  RetVal = Dlg.Show
      
  If NewObj.StatusName = "STATUS_CONTRACT_DRAFT" Then
    If Not RetVal Then
      NewObj.Erase
      Exit Function
    End If
  End If
  
  Set CreateOldContractByClass = NewObj
End Function

