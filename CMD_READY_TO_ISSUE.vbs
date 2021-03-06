' Команда - Вернуть на доработку (Документ)
'------------------------------------------------------------------------------
' Автор: Стромков С.А.
' Авторское право © ЗАО «СИСОФТ», 2017 г.
Option Explicit


Call Main(ThisObject)

Function Main(Obj)
  Main = False
  
  ' Подтверждение
  If vbNo =  ThisApplication.ExecuteScript( _
    "CMD_MESSAGE", "ShowWarning", vbQuestion + vbYesNo, 1228, Obj.Description) Then _
    Exit Function
    
  Obj.Permissions = SysAdminPermissions
  Obj.Attributes("ATTR_READY_TO_SEND").Value = True
  
  SendOrders Obj
  
  Main = True
End Function

Sub SendOrders(Obj)
  Set uToUser = Obj.Attributes("ATTR_RESPONSIBLE").User
  If uToUser Is Nothing Then Exit Sub
  Set uFromUser = ThisApplication.CurrentUser
  resol = "NODE_CORR_REZOL_INF"
  txt = Obj.ObjectDef.Description & " """ & Obj.Description & """ готов к отправке"
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB", "CreateSystemOrder", _
    Obj, "OBJECT_KD_ORDER_SYS", uToUser, uFromUser, resol, txt, ""
    
  Dim project
  Set project = Obj.Attributes("ATTR_PROJECT").Object
  Set uToUser = project.Attributes("ATTR_PROJECT_GIP").User
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB", "CreateSystemOrder", _
    Obj, "OBJECT_KD_ORDER_SYS", uToUser, uFromUser, resol, txt, ""
End Sub

