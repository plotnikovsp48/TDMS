USE "CMD_KD_LIB_DOC_IN"
use CMD_KD_COMMON_BUTTON_LIB 
use CMD_KD_ORDER_LIB

Set FSO = CreateObject("Scripting.FileSystemObject")  
Set CurrentUser = ThisApplication.CurrentUser
Set objShell = CreateObject("Shell.Application")

'=============================================
Sub Form_BeforeShow(Form, Obj)
  SetContolEnable()
End Sub

'=============================================
sub SetContolEnable()

'  isExec = IsAutor(thisApplication.CurrentUser, thisObject)
'  isSecr = isSecretary(thisApplication.CurrentUser)
'  isSign = IsSigner(thisApplication.CurrentUser, thisObject)

'  isCanEd = isCanEdit()
'  stDraft = thisObject.StatusName = "STATUS_KD_DRAFT"
  stSinged = thisObject.StatusName = "STATUS_KD_VIEWED_RUK"'"STATUS_SIGNED"
'  stSigning = thisObject.StatusName = "STATUS_SIGNING"

  thisForm.Controls("BTNADD").Enabled = stSinged
  thisForm.Controls("BTNDEL").Enabled = stSinged
  thisForm.Controls("BTNEDIT").Enabled = stSinged
  thisForm.Controls("BTN_REORDER").Enabled = stSinged
  thisForm.Controls("BTN_CANCEL").Enabled = stSinged
  thisForm.Controls("BTN_EXC").Enabled = stSinged
  thisForm.Controls("BTN_COPY").Enabled = stSinged
end sub
'=============================================
Sub QUERY_KD_FILES_IN_DOC_Selected(iItem, action)
    a = ThisForm.Controls("PREVIEW1").Value 
    Set s = thisForm.Controls("QUERY_KD_FILES_IN_DOC").ActiveX
    Set FileS = s.ItemObject(iItem) 
    ThisForm.Controls("PREVIEW1").Value = FileS.FileName
    ThisForm.Refresh()
End Sub

'=============================================
Sub QUERY_KD_FILES_IN_DOC_DblClick(iItem, bCancelDefault)
    bCancelDefault = True
End Sub

'=============================================
Sub BTNPackUnLoad_OnClick()
    UnloadFilesFromDoc()
End Sub

'=============================================
Sub BTNADD_OnClick()
  'set order = GetCurUserOrder()
  if  CreateOrders( nothing, thisObject ) then _
      msgbox "Добавление завершено"
End Sub

'=============================================
Sub BTNDEL_OnClick()
  call delSelectedOrder()
End Sub

'=============================================
Sub BTNEDIT_OnClick()
  set order =  GetOrderFromForm()
  if order is nothing then exit sub
  call edit_Order(order)
End Sub

'=============================================
Sub BTN_EXC_OnClick()
  set order = GetCurUserOrder() 'берем свое
  if order is nothing then 
    set order =  GetOrderFromForm() 'если нет своего, то выделенное
    if order is nothing then exit sub
  end if  
  call Set_order_Done(order)
End Sub
'=============================================
Sub BTN_REORDER_OnClick()
  set order = GetCurUserOrder() 'берем свое
  if order is nothing then 
    set order =  GetOrderFromForm() 'если нет своего, то выделенное
    if order is nothing then exit sub
  end if  
  CreateSubOrder(order)
End Sub

'=============================================
Sub BTN_CANCEL_OnClick()
  set order =  GetOrderFromForm()
  if order is nothing then exit sub
  call Set_From_Order_Cancel(order) 
End Sub
