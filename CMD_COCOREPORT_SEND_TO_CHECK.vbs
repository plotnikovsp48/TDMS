' Команда - Отправить на проверку (Акт)
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Call Main(ThisObject)

Function Main(Obj)
  Main = False
  ThisScript.SysAdminModeOn
  'Проверка состояния
  Check = CheckObj(Obj)
  If Check = False Then
    Msgbox "Заполните поле ""Проверил""", vbCritical
    Exit Function
  End If
  
  'Запрос подтверждения
  Key = Msgbox ("Отправить """ & Obj.Description & """ на проверку?",vbYesNo+vbQuestion)
  If Key = vbNo Then Exit Function

  'Маршрут
  StatusName = "STATUS_COCOREPORT_CHECK"
  RetVal = ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Obj,Obj.Status,Obj,StatusName)
  If RetVal = -1 Then
    Obj.Status = ThisApplication.Statuses(StatusName)
  End If
  
  'Создание роли
  Call ThisApplication.ExecuteScript("CMD_DLL_ROLES","UpdateAttrRole",Obj,"ATTR_USER_CHECKED","ROLE_CHECKER")

    
  'Оповещение пользователя
  Set u = Obj.Attributes("ATTR_USER_CHECKED").User
  ThisApplication.ExecuteScript "CMD_MESSAGE", "SendMessage", 1537, u, Obj, Nothing, Obj.Description, ThisApplication.CurrentUser.Description,Date
  
  'Создание поручения
  Set CU = ThisApplication.CurrentUser
  resol = "NODE_KD_CHECK"
  ObjType = "OBJECT_KD_ORDER_SYS"
  txt = "акт выполнения работ """ & Obj.Description & """"
  planDate = DateAdd ("d", 1, Date) 'Date + 1
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","CreateSystemOrder",Obj,ObjType,u,CU,resol,txt,PlanDate
  
  
  ThisScript.SysAdminModeOff
  Main = True
End Function

'Функция проверки состояния договора
Function CheckObj(Obj)
  CheckObj = False
  'Проверил
  If Obj.Attributes.Has("ATTR_USER_CHECKED") Then
    If Obj.Attributes("ATTR_USER_CHECKED").Empty = False Then
      If not Obj.Attributes("ATTR_USER_CHECKED").User is Nothing Then CheckObj = True
    End If
  End If
End Function
