' textual inclusion of this file intended

Class SysAdminMode

  Public Sub Class_Initialize()
    ThisScript.SysAdminModeOn
  End Sub
  
  Public Sub Class_Terminate()
    ThisScript.SysAdminModeOff
  End Sub
End Class