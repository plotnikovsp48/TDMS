
  Set CreateObjDlg = ThisApplication.Dialogs.EditObjectDlg 
  set order = thisObject.Attributes("ATTR_KD_ORDER_BASE").Object
  if not order is nothing then 
    CreateObjDlg.Object = order
   ' CreateObjDlg.ActiveForm = order.ObjectDef.InputForms(1)
    ans = CreateObjDlg.Show
  end if
