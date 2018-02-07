
Call Main(ThisObject)

Sub Main(Obj)
  Select Case Obj.ObjectDefName
    Case "OBJECT_WORK_DOCS_SET"
      Call run(Obj)
    Case "OBJECT_VOLUME"
      Call run(Obj)
  End Select
End Sub

Sub Run(o)
  ThisScript.SysAdminModeOn
  Set Versions = ThisObject.Versions
  If Versions.Count < 2 Then Exit Sub
  Key = Msgbox("Отменить все изменения?",vbQuestion+vbYesNo)
  If Key = vbNo Then Exit Sub
  Set Ver = Versions.Item(Versions.Count-1)
  newVersion = Ver.Versions.Create(,"Отмена аннулирования")
  ThisObject.Update
  ThisScript.SysAdminModeOff
End Sub