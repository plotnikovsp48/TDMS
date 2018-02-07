' Автор: Стромков С.А.
'
' Этап строительства
'------------------------------------------------------------------------------------------------------
' Авторское право © ЗАО «СиСофт», 2016 г.


Sub Object_BeforeCreate(Obj, Parent, Cancel)
  Call ThisApplication.ExecuteScript("CMD_ROUTER", "Run",Parent,Parent.Status,Obj,Obj.ObjectDef.InitialStatus)  
End Sub

Sub Object_BeforeErase(o_, cn_)
  Dim result1,result2
  result1 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckContent", o_)
  result2 = ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "CheckReferencedBy", o_) 
  cn_=result1 Or result2
  If cn_ Then Exit Sub
  Call ThisApplication.ExecuteScript("CMD_OBJECT_BEFORE_ERASE", "SetEraseFlag", o_) 
End Sub

Sub Object_PropertiesDlgBeforeClose(Obj, OkBtnPressed, Cancel)
  If OkBtnPressed = True Then
    Cancel = Not ThisApplication.ExecuteScript("CMD_S_DLL","CheckBeforeClose",Obj)
  End If
End Sub

