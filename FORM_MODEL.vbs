

Sub BTN_MODEL_ADD_OnClick()
  ThisApplication.ExecuteCommand "CMD_LINK_TO_DRAWING_CREATE", ThisObject
  ThisObject.Update
End Sub
