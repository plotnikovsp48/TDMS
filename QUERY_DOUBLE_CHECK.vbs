Sub Query_BeforeExecute(Query, Obj, Cancel)
  if IsEmpty(thisObject) then exit sub
  If Obj is nothing then 
        set Obj = thisApplication.GetObjectByGUID("{BDBA0986-3514-47A1-9209-A78BF627FF22}") ' EV для тестирования
        if Obj is nothing then
          cancel = true
          exit sub
        end if
  end if
  if Obj.Attributes("ATTR_KD_VD_INСNUM").value = "" or Obj.Attributes("ATTR_KD_VD_SENDDATE").value = "" or _
      Obj.Attributes("ATTR_KD_CPNAME").value = "" then
    msgbox "Незаполнены обязательные поля", vbCritical
    cancel = true
    exit sub  
  end if    
  Query.Parameter("PARAM0") = Obj.Attributes("ATTR_KD_VD_INСNUM").value
  Query.Parameter("PARAM1") = Obj.Attributes("ATTR_KD_VD_SENDDATE").value 
  Query.Parameter("PARAM2") = Obj.Attributes("ATTR_KD_CPNAME").object
  Query.Parameter("PARAM3") = Obj
'  Query.Parameter("PARAM3") = Obj.Handle
End Sub
 
