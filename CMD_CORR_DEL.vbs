
on error resume next
retval = MsgBox("Вы уверены, что хотите удалить контактное лицо " _
    & thisobject.Description&"?", vbQuestion + vbYesNo)' deleted by PlotnikovSP так как дублирует функционал
If (RetVal = vbYes) Then thisobject.Erase
if err.Number <> 0 then err.Clear
on error goto 0