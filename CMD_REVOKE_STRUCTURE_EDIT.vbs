Option Explicit

USE CMD_SS_TRANSACTION

Go ThisObject

Private Sub Go(obj)

  ' collect assignees
  Dim assignees
  Set assignees = ThisApplication.ExecuteScript( _
    "CMD_SS_LIB", "CollectAssignees", obj, "ROLE_PROJECT_STRUCTURE_EDIT")
  If 0 = assignees.Count Then Exit Sub
  
  ' pick one
  Dim u
  Set u = ThisApplication.ExecuteScript("CMD_SS_LIB", "PickUser", _
    "Отозвать разрешение редактирования состава проекта", assignees)
  If u Is Nothing Then Exit Sub
  
  ' wrap into transaction
  Dim tr
  Set tr = New Transaction
  
  ' remove role CMD_DLL, DelUserRole
  ThisApplication.ExecuteScript _
    "CMD_DLL", "DelUserRole", obj, u, "ROLE_PROJECT_STRUCTURE_EDIT"
    
  ' update history table
  ThisApplication.ExecuteScript "CMD_SS_LIB", "UpdateAssignmentsHistory", _
    Obj, "ROLE_PROJECT_STRUCTURE_EDIT", "Разрешение отозвано", u
  
  tr.Commit
End Sub

Public Function DisableCommand(obj)
  DisableCommand = ThisApplication.ExecuteScript( _
    "CMD_SS_LIB", "CollectAssignees", obj, "ROLE_PROJECT_STRUCTURE_EDIT").Count < 1
End Function