use CMD_KD_REGNO_KIB

'=================================
Sub Object_BeforeCreate(Obj, Parent, Cancel)
  
  sysID = Get_Sys_Id(obj)
  if sysID = 0 then 
      Cancel = true
      exit sub
  else  
    Obj.Attributes("ATTR_KD_IDNUMBER").value = sysID
  end if
End Sub
'=============================================
function CanIssueOrder(DocObj)
  CanIssueOrder = true
end function
'=============================================
function GetTypeFileArr(docObj)
    GetTypeFileArr = array("Приложение")  
end function

'=============================================
Sub Object_PropertiesDlgInit(Dialog, Obj, Forms)
   call thisApplication.ExecuteScript("CMD_KD_ORDER_LIB","Set_OrdersReaded",Obj)
    Dialog.ActiveForm = "FORM_KD_DOC_ORDERS"
End Sub
