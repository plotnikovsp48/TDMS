use CMD_KD_COMMON_LIB
use CMD_KD_COMMON_BUTTON_LIB

'=============================================
Sub BTN_ADD_DOC_OnClick()
  AskToAddRelDoc ()
  thisObject.Update
End Sub

'=============================================
Sub BTN_DEL_DOC_OnClick()
  call  Del_FromTableWithPerm("ATTR_KD_T_LINKS", "ATTR_KD_LINKS_DOC", "ATTR_KD_LINKS_USER") 
End Sub

''=============================================
'Sub BTN_REPLY_ADD_OnClick()
'     Set SelObjDlg = ThisApplication.Dialogs.SelectObjectDlg 
'     SelObjDlg.Prompt = "Выберите один или несколько документов:"
'     select case thisObject.ObjectDefName 
'        case "OBJECT_KD_DOC_IN" SelObjDlg.ObjectDef = "OBJECT_KD_DOC_OUT"
'        case "OBJECT_KD_DOC_OUT" SelObjDlg.ObjectDef = "OBJECT_KD_DOC_IN"
'        Case Else  SelObjDlg.ObjectDef = thisObject.ObjectDefName
'     end select    

'     RetVal = SelObjDlg.Show 
'     Set ObjCol = SelObjDlg.Objects
'     If (RetVal<>TRUE) Or (ObjCol.Count=0) Then Exit Sub
'    
'     For Each obj In ObjCol
'         call AddReplDoc(thisObject, obj)   
'     Next

'End Sub
'=============================================
Sub BTN_REPLY_DELETE_OnClick()
 call Del_FromTable("ATTR_KD_VD_REPGAZ", "ATTR_KD_D_REFGAZNUM" ) 
End Sub
'=============================================
Sub BTN_DEL_PRO_OnClick()
  call Del_FromTable("ATTR_KD_TLINKPROJ", "ATTR_KD_LINKPROJ" ) 
End Sub
'=============================================
Sub Form_BeforeShow(Form, Obj)
    form.Caption = form.Description
    call SetGlobalVarrible("ShowForm", "FORM_KD_DOC_LINKS")
End Sub
''=============================================
'Sub Form_BeforeClose(Form, Obj, Cancel)
'    RemoveGlobalVarrible("ShowForm")
'End Sub

'Sub ATTR_KD_WITHOUT_PROJ_BeforeModify(Text,Cancel)

'End Sub
'Sub ATTR_KD_WITHOUT_PROJ_Modified()
'End Sub

'=============================================
Sub BTN_ADD_FILE_OnClick()
  call AddObjLinkFile(thisObject)
End Sub
