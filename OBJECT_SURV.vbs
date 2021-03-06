Sub Object_BeforeCreate(Obj, Parent, Cancel)
  Dim vOInitialStatus
  Dim vPInitialStatus
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Parent,Parent.Status,Obj,Obj.ObjectDef.InitialStatus)    
End Sub

Sub Object_BeforeErase(o_, cn_)
  Dim result1,result2
  result1 = ThisApplication.ExecuteScript("CMD_S_DLL", "CheckProjectContent", o_)
  result2 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckReferencedBy", o_) 
  cn_=result1 Or result2
  Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", o_) 
End Sub

Sub Object_BeforeContentRemove(Obj, RemoveCollection, Cancel)
  Cancel = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckEraseFlag", RemoveCollection)
End Sub

Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
  if OkBtnPressed then 
    Dim oAttr,CheckValue
    oAttr="ATTR_S_SURV_TYPE"
    CheckValue=ThisApplication.ExecuteScript("CMD_S_NUMBERING", "GetObjNumber", Obj)
    if ThisApplication.ExecuteScript( "CMD_S_NUMBERING", "CheckObjExist",Obj,oAttr,CheckValue,1201) then
      Cancel=true
    end if
  End If
End Sub

Sub ContextMenu_BeforeShow(Commands, Obj, Cancel)
  ' В зависимости от статуса, скрываем команду "Добавить вид изысканий"
  If Obj.StatusName <> "STATUS_IN_WORK" Then
    Commands.Remove ThisApplication.Commands("CMD_SURVS_CREATE")
  End If
  If Obj.Attributes.Has("ATTR_SUBCONTRACTOR_WORK") Then
    If Obj.Attributes("ATTR_SUBCONTRACTOR_WORK").Value = False Then
      Commands.Remove ThisApplication.Commands("CMD_SECTION_CREATE")
    End If
  End If
End Sub

Sub Object_PropertiesDlgInit(Dialog, Obj, Forms)
  If Obj.Attributes.Has("ATTR_SUBCONTRACTOR_WORK") Then
    If Obj.Attributes("ATTR_SUBCONTRACTOR_WORK").Value = False Then
      If Dialog.InputForms.Has("FORM_SUBCONTRACTOR") Then
        Dialog.InputForms.Remove Dialog.InputForms("FORM_SUBCONTRACTOR")
      End If
    Else
      If Obj.Dictionary.Exists("FormActive") Then
        If Dialog.InputForms.Has("FORM_SUBCONTRACTOR") and Obj.Dictionary.Item("FormActive") = True Then
          Dialog.ActiveForm = Dialog.InputForms("FORM_SUBCONTRACTOR")
          Obj.Dictionary.Remove("FormActive")
        End If
      End If
    End If
  End If
  ' отмечаем все поручения по виду изысканий прочитанными
  'if obj.StatusName <> "STATUS_T_TASK_IN_WORK" then _
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","Set_OrdersReaded",Obj
End Sub

