

Sub BUTTON1_OnClick()
Set SelUserDlg = Thisapplication.Dialogs.SelectUserDlg


 RetVal = SelUserDlg.Show
        
        ' Если выбрана хотя бы одна группа...
        If SelUserDlg.Groups.Count > 0 Then
                
                'Получить ссылку на коллекцию выбранных групп
                Set selected = SelUserDlg.Groups
                
                ' Выводим описание каждой группы
                For Each group In selected
                        With group
                             StrInfo = .Description & Chr(13) 
                             StrInfo = StrInfo & "автоформируемая: " & .Autoforming & Chr(13)
                             StrInfo = StrInfo & "включено пользователей: " & .Users.Count
                        End With
                        ThisApplication.AddNotify StrInfo 
                Next
        End If
        
        ' Если выбран хотя бы один пользователь...
        If SelUserDlg.Users.Count > 0 Then
                
                'Получить ссылку на коллекцию выбранных пользователей
                Set selected = SelUserDlg.Users
                
                ' Выводим описание каждого пользователя
                For Each user In selected
                        user.Attributes("ATTR_KD_DEPART")= ThisObject
                        'ThisApplication.AddNotify user.Description
                Next
        End If 
End Sub