Function SetFlag (Flag)
Extern SetFlag
  If ThisApplication.CurrentUser.Attributes.Has("ATTR_USER_SHOW_TIPS") Then
     ThisApplication.CurrentUser.Attributes("ATTR_USER_SHOW_TIPS").Value = Not Flag
  End if
End Function