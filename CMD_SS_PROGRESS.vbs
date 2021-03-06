' 
Class CProgress
  Private mDlg, mPosition, mRange
  
  Public Sub Class_Initialize()
    mRange = 1: mPosition = 0
    Set mDlg = ThisApplication.Dialogs.ProgressDlg
    mDlg.Start
  End Sub
  
  Public Sub Class_Terminate()
    mDlg.Stop
    Set mDlg = Nothing
  End Sub
  
  Public Sub SetRange(left, right)
    If left >= right Then
      Err.Raise vbObjectError, "CProgress.SetRange", "Invalid progress range"
    End If
    mRange = right - left
    mPosition = 0
  End Sub
  
  Public Sub Step()
    mPosition = mPosition + 1
    mDlg.Position = 100 * mPosition / mRange
  End Sub
  
  Public Property Let Text(newVal)
    mDlg.Text = newVal
  End Property
  
  Public Property Get Cancel()
    Cancel = mDlg.Cancel
  End Property
End Class
