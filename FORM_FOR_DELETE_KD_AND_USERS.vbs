Sub Form_BeforeShow(Form, Obj)
  Set collectionList = thisform.Controls("collectionList").ActiveX
  set col = Form.Dictionary("coll")
  collectionList.init col
End Sub

Sub collectionList_DblClick(hItem, bCancelDefault)
  Set EditObjDlg = ThisApplication.Dialogs.EditObjectDlg
  EditObjDlg.Object = ThisForm.Dictionary("coll")(hItem) 
  EditObjDlg.Show
End Sub