' Форма ввода - Окно просмотра файла
'------------------------------------------------------------------------------
' Автор: Чернышов Д.С.
' Авторское право © АО «СИСОФТ», 2017 г.

Sub Form_BeforeShow(Form, Obj)
  Set View = Form.Controls("VIEW").ActiveX
  fName = Form.Attributes("ATTR_FILE_NAME").Value
  Ext = Right(fName,Len(fName)-InStrRev(fName,"."))
  Check = False
  For Each Format in View.SupportedFormats
    If StrComp(Format.Name,Ext,vbTextCompare) = 0 Then
      Check = True
      Exit For
    End If
  Next
  If Check = False Then
    Msgbox "Неподдерживаемый формат файла.",vbExclamation
    Form.Close
    Exit Sub
  End If
  View.Open fName
  View.ToolBarType = 16
End Sub

'Кнопка - Печать
Sub BUTTON_PRINT_OnClick()
  Set View = ThisForm.Controls("VIEW").ActiveX
  View.ShowPrinterSetup View.PrinterSetup
End Sub

'Кнопка - Масштаб: вписать в окно
Sub BUTTON_ZOOM_BYSCALE_OnClick()
  Set View = ThisForm.Controls("VIEW").ActiveX
  View.ZoomAll
End Sub

'Кнопка - Менеджер слоев
Sub BUTTON_LAYER_MANAGER_OnClick()
  Set View = ThisForm.Controls("VIEW").ActiveX
  View.ShowLayerManager
End Sub

'Кнопка - Настойки просмотра
Sub BUTTON_SETUP_OnClick()
  Set View = ThisForm.Controls("VIEW").ActiveX
  View.SetupPreferences
End Sub

'Кнопка - Смена режима курсора
Sub BUTTON_PAN_MODE_OnClick()
  Set View = ThisForm.Controls("VIEW").ActiveX
  View.PanMode = not View.PanMode
End Sub

'Кнопка - Предыдущий лист
Sub BUTTON_PREV_LIST_OnClick()
  Set View = ThisForm.Controls("VIEW").ActiveX
  Set Pages = View.Pages
  Set ActivePage = View.Pages.Active
  If ActivePage.Index > 1 Then
    Set Page = View.Pages.Item(ActivePage.Index-1)
    
  End If
End Sub

'Кнопка - Следующий лист
Sub BUTTON_NEXT_LIST_OnClick()
  Set View = ThisForm.Controls("VIEW").ActiveX
  Set ActivePage = View.Pages.Active
  If ActivePage.Index < View.Pages.Count Then
    Set Page = View.Pages.Item(ActivePage.Index)
    View.Pages.Active = Page
    View.Refresh
  End If
End Sub



