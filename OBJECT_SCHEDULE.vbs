

Sub Object_PropertiesDlgInit(Dialog, Obj, Forms)
  ' отмечаем все поручения по виду изысканий прочитанными
  'if obj.StatusName <> "STATUS_T_TASK_IN_WORK" then _
    ThisApplication.ExecuteScript "CMD_KD_ORDER_LIB","Set_OrdersReaded",Obj
End Sub