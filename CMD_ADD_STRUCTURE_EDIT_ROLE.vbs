Option Explicit

USE CMD_SS_TRANSACTION

Go ThisObject

Private Sub Go(obj)

  ' pick user
  Dim u
  Set u = ThisApplication.ExecuteScript("CMD_SS_LIB", "PickUser", _
    "Выдать разрешение на редактирование состава проекта")
  If u Is Nothing Then Exit Sub
  
  ' confirmation
  Dim msg
  msg = "Разрешить пользователю " & u.Description & _
    " редактировать состав проекта ?"
  If vbNo = MsgBox(msg, vbQuestion + vbYesNo) Then Exit Sub

  ' wrap into transaction
  Dim tr
  Set tr = New Transaction
      
  ' setup roles
  ThisApplication.ExecuteScript "CMD_DLL_ROLES", "SetRole", _
    obj, "ROLE_PROJECT_STRUCTURE_EDIT", u.SysName
    
  msg = "Вам разрешено редактировать состав проекта по стадии " & _
    obj.Description
  ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB", "CreateSystemOrder", _
    obj, obj.ObjectDefName, u, ThisApplication.CurrentUser, _
    "NODE_CORR_REZOL_OTV", msg, ""
    
  ThisApplication.ExecuteScript "CMD_SS_LIB", "UpdateAssignmentsHistory", _
    Obj, "ROLE_PROJECT_STRUCTURE_EDIT", "Разрешение выдано", u
  
  tr.Commit
End Sub