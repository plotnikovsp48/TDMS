use OBJECT_KD_ORDER

'=============================================
function GetTypeFileArr(Obj)
  isEx = fIsExec(Obj)
  if not isEx then exit function
  
  st = Obj.StatusName
  if st = "STATUS_KD_ORDER_IN_WORK" then _
          GetTypeFileArr = array("Приложение")  
end function

